import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart'
    show Connectivity, ConnectivityResult;
import 'package:flutter_quill/quill_delta.dart';
import 'package:my_manga_editor/common/logger.dart';
import 'package:my_manga_editor/feature/manga/model/manga.dart';
import 'package:my_manga_editor/feature/manga/repository/exceptions.dart'
    as repo_exceptions;
import 'package:my_manga_editor/service/firebase/auth_service.dart';
import 'package:my_manga_editor/service/firebase/firebase_service.dart';
import 'package:my_manga_editor/service/firebase/model/cloud_delta.dart';
import 'package:my_manga_editor/service/firebase/model/cloud_manga.dart';
import 'package:my_manga_editor/service/firebase/model/cloud_manga_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'manga_repository.g.dart';

@Riverpod(keepAlive: true)
MangaRepository mangaRepository(Ref ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  final authService = ref.watch(authServiceProvider);

  return MangaRepository(
    firebaseService: firebaseService,
    authService: authService,
  );
}

/// Repository for manga data access with Firebase-only persistence
///
/// This repository provides a clean interface for manga and page operations
/// while managing the conversion between Firestore documents and domain models.
class MangaRepository {
  MangaRepository({
    required FirebaseService firebaseService,
    required AuthService authService,
  })  : _firebaseService = firebaseService,
        _authService = authService {
    _initializeConnectivityMonitoring();
  }

  final FirebaseService _firebaseService;
  final AuthService _authService;

  // Track mangaId for each pageId to enable efficient lookups
  final Map<MangaPageId, MangaId> _pageToMangaMap = {};

  // Online status tracking
  final StreamController<bool> _onlineStatusController =
      StreamController<bool>.broadcast();
  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // ============================================================================
  // Manga CRUD Operations
  // ============================================================================

  /// Create a new manga project
  /// Returns the manga ID (Firestore document ID)
  /// Throws: AuthException if user not authenticated
  Future<MangaId> createNewManga({String name = '無名の傑作'}) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw repo_exceptions.AuthException();
      }

      // Create CloudManga first
      final cloudManga = CloudManga(
        id: '',
        userId: userId,
        name: name,
        startPageDirection: MangaStartPage.left.name,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        editLock: null,
      );

      // Upload manga document to Firestore
      final mangaId = await _firebaseService.createManga(cloudManga);

      // Create empty delta for ideaMemo and store as separate document
      final emptyDelta = Delta();

      // Create delta document in Firestore
      final cloudDelta = CloudDelta(
        id: '',
        mangaId: mangaId,
        ops: emptyDelta.toJson() as List<dynamic>,
        fieldName: 'ideaMemo',
        pageId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final firestoreDeltaId =
          await _firebaseService.createDelta(mangaId, cloudDelta);

      // Update manga document with delta ID reference
      await _firebaseService.updateManga(mangaId, {
        'ideaMemoDeltaId': firestoreDeltaId,
      });

      logger.d(
          'Created new manga: $mangaId with ideaMemo delta: $firestoreDeltaId');

      return MangaId(mangaId);
    } on FirebaseException catch (e) {
      logger.e('Failed to create manga', error: e);
      throw _handleFirebaseException(e);
    }
  }

  /// Watch a specific manga by ID (reactive)
  /// Returns null if manga doesn't exist or user doesn't have access
  Stream<Manga?> getMangaStream(MangaId id) {
    try {
      return _firebaseService.watchManga(id.id).map((cloudManga) {
        if (cloudManga == null) return null;

        return cloudManga.toManga();
      });
    } catch (e) {
      logger.e('Error watching manga: $id', error: e);
      rethrow;
    }
  }

  /// Watch all user's manga projects (reactive)
  Stream<List<Manga>> watchAllMangaList() {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw repo_exceptions.AuthException();
      }

      return _firebaseService.watchAllMangas(userId).map((cloudMangas) {
        return cloudMangas.map((cm) => cm.toManga()).toList();
      });
    } catch (e) {
      logger.e('Error watching manga list', error: e);
      rethrow;
    }
  }

  /// Update manga name
  /// Throws: AuthException, NotFoundException, ValidationException
  Future<void> updateMangaName(MangaId id, String name) async {
    try {
      if (name.isEmpty || name.length > 100) {
        throw repo_exceptions.ValidationException(
            'Name must be 1-100 characters');
      }

      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw repo_exceptions.AuthException();
      }

      await _firebaseService.updateManga(id.id, {'name': name});
      logger.d('Updated manga name: $id -> $name');
    } on repo_exceptions.ValidationException {
      rethrow;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    }
  }

  /// Update manga reading direction
  Future<void> updateStartPage(MangaId id, MangaStartPage value) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw repo_exceptions.AuthException();
      }

      await _firebaseService.updateManga(id.id, {
        'startPageDirection': value.name,
      });
      logger.d('Updated start page: $id -> ${value.name}');
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    }
  }

  /// Delete manga and all its pages
  Future<void> deleteManga(MangaId id) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw repo_exceptions.AuthException();
      }

      // Delete manga (pages will be deleted via cascade or manually)
      await _firebaseService.deleteManga(id.id);

      // Note: Deltas in cache will remain but that's acceptable as they'll be
      // garbage collected when no longer referenced
      logger.d('Deleted manga: $id');
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    }
  }

  // ============================================================================
  // Delta Management Operations
  // ============================================================================

  /// Save delta directly to Firestore
  /// Updates the delta document in Firestore
  /// Firestore offline persistence handles automatic sync
  Future<void> saveDelta(
      MangaId mangaId, DeltaId firestoreDeltaId, Delta delta) async {
    if (mangaId == null) {
      logger.w('Cannot save delta - mangaId not found for: $firestoreDeltaId');
      return;
    }

    try {
      await _syncDeltaToFirestore(mangaId.id, firestoreDeltaId.id, delta);
      logger.d('Delta saved to Firestore: $firestoreDeltaId');
    } catch (e) {
      logger.e('Failed to save delta to Firestore: $firestoreDeltaId',
          error: e);
      rethrow;
    }
  }

  /// Sync a delta to Firestore (delta document)
  Future<void> _syncDeltaToFirestore(
      String mangaId, String firestoreDeltaId, Delta delta) async {
    try {
      final ops = delta.toJson() as List<dynamic>;

      // Update existing delta document
      await _firebaseService.updateDelta(
        mangaId,
        firestoreDeltaId,
        {'ops': ops},
      );
      logger.d('Updated delta in Firestore: $firestoreDeltaId');
    } catch (e) {
      logger.e('Failed to sync delta to Firestore', error: e);
      rethrow;
    }
  }

  /// Load delta directly from Firestore
  Future<Delta?> loadDelta(MangaId mangaId, DeltaId firestoreDeltaId) async {
    if (mangaId == null) {
      logger.w('Cannot load delta - mangaId not found for: $firestoreDeltaId');
      return null;
    }

    try {
      final cloudDelta =
          await _firebaseService.fetchDelta(mangaId.id, firestoreDeltaId.id);
      if (cloudDelta == null) {
        logger.w('Delta not found in Firestore: $firestoreDeltaId');
        return null;
      }

      final delta = Delta.fromJson(cloudDelta.ops);
      logger.d('Loaded delta from Firestore: $firestoreDeltaId');
      return delta;
    } catch (e) {
      logger.e('Failed to load delta from Firestore: $firestoreDeltaId',
          error: e);
      return null;
    }
  }

  /// Watch delta changes (reactive) - loads directly from Firestore
  Stream<Delta?> getDeltaStream(MangaId mangaId, DeltaId firestoreDeltaId) {
    if (mangaId == null) {
      logger.w('Cannot watch delta - mangaId not found for: $firestoreDeltaId');
      return Stream.value(null);
    }

    return _firebaseService
        .watchDelta(mangaId.id, firestoreDeltaId.id)
        .map((cloudDelta) {
      if (cloudDelta == null) return null;
      return Delta.fromJson(cloudDelta.ops);
    });
  }

  // ============================================================================
  // MangaPage CRUD Operations
  // ============================================================================

  /// Create a new page in a manga
  /// Automatically assigns next pageIndex and creates separate delta documents
  Future<String> createNewMangaPage(MangaId mangaId) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw repo_exceptions.AuthException();
      }

      // Get existing pages to determine next page index
      final existingPages = await _firebaseService.fetchMangaPages(mangaId.id);
      final nextPageIndex = existingPages.length;

      // Create CloudMangaPage first (without delta IDs)
      final cloudPage = CloudMangaPage(
        id: '',
        // Will be generated by Firestore
        mangaId: mangaId.id,
        pageIndex: nextPageIndex,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final pageId =
          await _firebaseService.createMangaPage(mangaId.id, cloudPage);

      // Track the mapping for later lookups
      _pageToMangaMap[MangaPageId(pageId)] = mangaId;

      // Create empty deltas for the three page fields
      final emptyDelta = Delta();
      final fieldNames = ['memoDelta', 'stageDirectionDelta', 'dialoguesDelta'];
      final deltaIdMap = <String, String>{}; // fieldName -> firestoreDeltaId

      for (final fieldName in fieldNames) {
        // Create delta document in Firestore
        final cloudDelta = CloudDelta(
          id: '',
          mangaId: mangaId.id,
          ops: emptyDelta.toJson() as List<dynamic>,
          fieldName: fieldName,
          pageId: pageId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final firestoreDeltaId =
            await _firebaseService.createDelta(mangaId.id, cloudDelta);

        deltaIdMap[fieldName] = firestoreDeltaId;
      }

      // Update page document with delta ID references
      await _firebaseService.updateMangaPage(mangaId.id, pageId, {
        'memoDeltaId': deltaIdMap['memoDelta'],
        'stageDirectionDeltaId': deltaIdMap['stageDirectionDelta'],
        'dialoguesDeltaId': deltaIdMap['dialoguesDelta'],
      });

      logger.d('Created new manga page: $pageId for manga: $mangaId');

      return pageId;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    }
  }

  /// Watch a specific manga page by ID (reactive)
  /// Note: This requires knowing the mangaId - use getMangaPageStreamWithMangaId for better performance
  Stream<MangaPage?> getMangaPageStream(MangaPageId pageId) {
    try {
      // Try to get mangaId from cache
      final mangaId = _pageToMangaMap[pageId];
      if (mangaId != null) {
        return _firebaseService
            .watchMangaPageWithMangaId(mangaId.id, pageId.id)
            .map((cloudPage) {
          if (cloudPage == null) return null;
          return cloudPage.toMangaPage();
        });
      } else {
        // If we don't have the mangaId cached, we can't efficiently watch the page
        logger.w(
            'MangaId not found for pageId: $pageId. Use getMangaPageStreamWithMangaId instead.');
        return Stream.value(null);
      }
    } catch (e) {
      logger.e('Error watching manga page: $pageId', error: e);
      rethrow;
    }
  }

  /// Watch a specific manga page by ID with mangaId (reactive)
  /// This is more efficient than getMangaPageStream
  Stream<MangaPage?> getMangaPageStreamWithMangaId(
      MangaId mangaId, MangaPageId pageId) {
    try {
      // Update the mapping
      _pageToMangaMap[pageId] = mangaId;

      return _firebaseService
          .watchMangaPageWithMangaId(mangaId.id, pageId.id)
          .map((cloudPage) {
        if (cloudPage == null) return null;

        return cloudPage.toMangaPage();
      });
    } catch (e) {
      logger.e('Error watching manga page: $pageId', error: e);
      rethrow;
    }
  }

  /// Watch all page IDs for a manga, ordered by pageIndex (reactive)
  Stream<List<MangaPageId>> watchAllMangaPageIdList(MangaId mangaId) {
    try {
      return _firebaseService.watchMangaPages(mangaId.id).map((cloudPages) {
        // Sort by pageIndex
        final sorted = cloudPages.toList()
          ..sort((a, b) => a.pageIndex.compareTo(b.pageIndex));

        // Update the pageToMangaMap for all pages
        for (final page in sorted) {
          _pageToMangaMap[MangaPageId(page.id)] = mangaId;
        }

        return sorted.map((cp) => MangaPageId(cp.id)).toList();
      });
    } catch (e) {
      logger.e('Error watching manga page list: $mangaId', error: e);
      rethrow;
    }
  }

  /// Reorder pages by updating pageIndex
  Future<void> reorderPages(
      MangaId mangaId, List<MangaPageId> pageIdList) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw repo_exceptions.AuthException();
      }

      if (pageIdList.isEmpty) return;

      // Update pageIndex for each page in batch
      final batch = _firebaseService.batch();
      for (int i = 0; i < pageIdList.length; i++) {
        batch.updatePage(mangaId.id, pageIdList[i].id, {'pageIndex': i});
      }

      await batch.commit();
      logger.d('Reordered ${pageIdList.length} pages for manga: $mangaId');
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    }
  }

  /// Delete a manga page and its associated deltas
  Future<void> deleteMangaPage(MangaPageId pageId) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw repo_exceptions.AuthException();
      }

      // Get mangaId from cache
      final mangaId = _pageToMangaMap[pageId];
      if (mangaId == null) {
        throw repo_exceptions.NotFoundException('MangaPage', pageId.id);
      }

      // Fetch all deltas for this page and delete them
      final allDeltas = await _firebaseService.fetchDeltas(mangaId.id);
      final pageDeltas = allDeltas.where((d) => d.pageId == pageId.id).toList();

      for (final delta in pageDeltas) {
        await _firebaseService.deleteDelta(mangaId.id, delta.id);
      }

      // Delete the page document
      await _firebaseService.deleteMangaPage(mangaId.id, pageId.id);

      // Remove from cache
      _pageToMangaMap.remove(pageId);

      logger.d(
          'Deleted manga page: $pageId and ${pageDeltas.length} associated deltas');
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    }
  }

  // ============================================================================
  // Online Status
  // ============================================================================

  /// Watch online status for UI indicator
  /// Monitors network connectivity status
  Stream<bool> watchOnlineStatus() {
    _emitOnlineStatus();
    return _onlineStatusController.stream;
  }

  // ============================================================================
  // Export & Utilities
  // ============================================================================

  /// Export manga to markdown format
  Future<String> toMarkdown(MangaId mangaId) async {
    try {
      // Fetch manga and pages
      final manga = await _firebaseService.fetchManga(mangaId.id);
      if (manga == null) {
        throw repo_exceptions.NotFoundException('Manga', mangaId.id);
      }

      final pages = await _firebaseService.fetchMangaPages(mangaId.id);
      final deltas = await _firebaseService.fetchDeltas(mangaId.id);

      // Build markdown content
      final buffer = StringBuffer();
      buffer.writeln('# ${manga.name}');
      buffer.writeln();

      // Add idea memo if exists
      final ideaMemoDelta =
          deltas.where((d) => d.id == manga.ideaMemoDeltaId).firstOrNull;
      if (ideaMemoDelta != null && ideaMemoDelta.ops.isNotEmpty) {
        final delta = Delta.fromJson(ideaMemoDelta.ops);
        if (delta.isNotEmpty) {
          buffer.writeln('## アイデアメモ');
          buffer.writeln();
          // Extract plain text from delta
          for (final op in delta.toList()) {
            if (op.data is String) {
              buffer.write(op.data);
            }
          }
          buffer.writeln();
          buffer.writeln();
        }
      }

      // Add pages
      for (int i = 0; i < pages.length; i++) {
        final page = pages[i];
        buffer.writeln('## ページ ${i + 1}');
        buffer.writeln();

        // Extract plain text from deltas for this page
        final pageDeltas = deltas.where((d) => d.pageId == page.id).toList();

        // Memo
        final memoDeltaDoc =
            pageDeltas.where((d) => d.id == page.memoDeltaId).firstOrNull;
        if (memoDeltaDoc != null && memoDeltaDoc.ops.isNotEmpty) {
          final memoDelta = Delta.fromJson(memoDeltaDoc.ops);
          if (memoDelta.isNotEmpty) {
            buffer.writeln('### メモ');
            for (final op in memoDelta.toList()) {
              if (op.data is String) {
                buffer.write(op.data);
              }
            }
            buffer.writeln();
            buffer.writeln();
          }
        }

        // Stage Direction
        final stageDeltaDoc = pageDeltas
            .where((d) => d.id == page.stageDirectionDeltaId)
            .firstOrNull;
        if (stageDeltaDoc != null && stageDeltaDoc.ops.isNotEmpty) {
          final stageDelta = Delta.fromJson(stageDeltaDoc.ops);
          if (stageDelta.isNotEmpty) {
            buffer.writeln('### ト書き');
            for (final op in stageDelta.toList()) {
              if (op.data is String) {
                buffer.write(op.data);
              }
            }
            buffer.writeln();
            buffer.writeln();
          }
        }

        // Dialogues
        final dialoguesDeltaDoc =
            pageDeltas.where((d) => d.id == page.dialoguesDeltaId).firstOrNull;
        if (dialoguesDeltaDoc != null && dialoguesDeltaDoc.ops.isNotEmpty) {
          final dialoguesDelta = Delta.fromJson(dialoguesDeltaDoc.ops);
          if (dialoguesDelta.isNotEmpty) {
            buffer.writeln('### セリフ');
            for (final op in dialoguesDelta.toList()) {
              if (op.data is String) {
                buffer.write(op.data);
              }
            }
            buffer.writeln();
            buffer.writeln();
          }
        }
      }

      return buffer.toString();
    } catch (e) {
      logger.e('Failed to export manga to markdown', error: e);
      rethrow;
    }
  }

  // ============================================================================
  // Error Handling
  // ============================================================================

  Exception _handleFirebaseException(FirebaseException e) {
    if (e.code == 'permission-denied') {
      return repo_exceptions.PermissionException();
    } else if (e.code == 'not-found') {
      return repo_exceptions.NotFoundException('Resource', 'unknown');
    } else if (e.code == 'unauthenticated') {
      return repo_exceptions.AuthException();
    } else {
      return repo_exceptions.StorageException(e.message ?? 'Storage error',
          code: e.code);
    }
  }

  // ============================================================================
  // Online Status Helpers
  // ============================================================================

  /// Initialize connectivity monitoring
  void _initializeConnectivityMonitoring() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      final wasOnline = _isOnline;
      _isOnline = !result.contains(ConnectivityResult.none);

      if (wasOnline != _isOnline) {
        logger.d('Connection state changed: $_isOnline');
        _emitOnlineStatus();
      }
    });

    // Check initial connectivity
    Connectivity().checkConnectivity().then((result) {
      _isOnline = !result.contains(ConnectivityResult.none);
      _emitOnlineStatus();
    });
  }

  /// Emit current online status to listeners
  void _emitOnlineStatus() {
    _onlineStatusController.add(_isOnline);
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _onlineStatusController.close();
  }
}

// ============================================================================
// Conversion Extensions
// ============================================================================

/// Extension for converting CloudManga to Manga
extension CloudMangaConversion on CloudManga {
  Manga toManga() {
    return Manga(
      id: MangaId(id),
      name: name,
      startPage: MangaStartPageExt.fromString(startPageDirection),
      ideaMemoDeltaId: DeltaId(ideaMemoDeltaId ?? ''),
    );
  }
}

/// Extension for converting Manga to CloudManga
extension MangaToCloudConversion on Manga {
  CloudManga toCloudManga(String userId) {
    return CloudManga(
      id: id.id,
      userId: userId,
      name: name,
      startPageDirection: startPage.name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ideaMemoDeltaId: ideaMemoDeltaId.id,
      editLock: null,
    );
  }
}

/// Extension for converting CloudMangaPage to MangaPage
extension CloudMangaPageConversion on CloudMangaPage {
  MangaPage toMangaPage() {
    return MangaPage(
      id: MangaPageId(id),
      mangaId: MangaId(mangaId),
      memoDeltaId: DeltaId(memoDeltaId ?? ''),
      stageDirectionDeltaId: DeltaId(stageDirectionDeltaId ?? ''),
      dialoguesDeltaId: DeltaId(dialoguesDeltaId ?? ''),
    );
  }
}

/// Extension for converting MangaPage to CloudMangaPage
extension MangaPageToCloudConversion on MangaPage {
  CloudMangaPage toCloudMangaPage(int pageIndex) {
    return CloudMangaPage(
      id: id.id,
      mangaId: mangaId.id,
      pageIndex: pageIndex,
      memoDeltaId: memoDeltaId.id,
      stageDirectionDeltaId: stageDirectionDeltaId.id,
      dialoguesDeltaId: dialoguesDeltaId.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
