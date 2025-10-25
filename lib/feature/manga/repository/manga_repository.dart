import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart'
    show Connectivity, ConnectivityResult;
import 'package:flutter_quill/quill_delta.dart';
import 'package:my_manga_editor/common/logger.dart';
import 'package:my_manga_editor/feature/manga/model/manga.dart';
import 'package:my_manga_editor/feature/manga/model/sync_status.dart';
import 'package:my_manga_editor/feature/manga/repository/delta_cache.dart'
    show DeltaCache;
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
        _authService = authService,
        _deltaCache = DeltaCache() {
    _initializeConnectivityMonitoring();
  }

  final FirebaseService _firebaseService;
  final AuthService _authService;
  final DeltaCache _deltaCache;

  // Track mangaId for each pageId to enable efficient lookups
  final Map<MangaPageId, MangaId> _pageToMangaMap = {};

  // Sync status tracking
  final StreamController<SyncStatus> _syncStatusController =
      StreamController<SyncStatus>.broadcast();
  DateTime? _lastSyncTime;
  bool _isOnline = true;
  bool _isSyncing = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Performance monitoring (T081)
  int _cacheHits = 0;
  int _cacheMisses = 0;
  final int _firestoreOperations = 0;

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

      // Store delta in cache immediately
      _deltaCache.storeDelta(firestoreDeltaId, emptyDelta, mangaId);

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

  /// Save delta to cache and sync to Firestore (T055)
  /// Updates the delta document in Firestore
  /// Syncs immediately if online, or queues for later sync if offline
  Future<void> saveDelta(DeltaId firestoreDeltaId, Delta delta) async {
    _deltaCache.updateDelta(firestoreDeltaId.id, delta);

    final mangaId = _deltaCache.getMangaId(firestoreDeltaId.id);
    if (mangaId == null) {
      logger.w('Cannot sync delta - mangaId not found for: $firestoreDeltaId');
      return;
    }

    if (_isOnline) {
      // Sync immediately if online
      try {
        await _syncDeltaToFirestore(mangaId, firestoreDeltaId.id, delta);
        _deltaCache.markSynced(firestoreDeltaId.id);
        logger.d('Delta synced to Firestore: $firestoreDeltaId');
      } catch (e) {
        logger.e('Failed to sync delta to Firestore: $firestoreDeltaId',
            error: e);
        _deltaCache.markForSync(firestoreDeltaId.id);
        _emitSyncStatus();
      }
    } else {
      // Queue for sync if offline
      _deltaCache.markForSync(firestoreDeltaId.id);
      logger.d('Delta queued for sync (offline): $firestoreDeltaId');
      _emitSyncStatus();
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

  /// Load delta from cache or Firestore
  Future<Delta?> loadDelta(DeltaId firestoreDeltaId) async {
    final delta = _deltaCache.getDelta(firestoreDeltaId.id);
    if (delta != null) {
      logger.d('Loaded delta from cache: $firestoreDeltaId');
      _cacheHits++;
      _logPerformanceMetrics();
      return delta;
    }

    // If not in cache, it should have been loaded when the manga/page was loaded
    _cacheMisses++;
    _logPerformanceMetrics();
    logger.w('Delta not found in cache: $firestoreDeltaId');
    return null;
  }

  /// Watch delta changes (reactive)
  Stream<Delta?> getDeltaStream(String firestoreDeltaId) {
    return _deltaCache.getDeltaStream(firestoreDeltaId);
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

        // Store delta in cache immediately
        _deltaCache.storeDelta(firestoreDeltaId, emptyDelta, mangaId.id);
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
  // Sync & Status
  // ============================================================================

  /// Watch sync status for UI indicator (T053)
  /// Monitors online status and syncing state for the UI
  Stream<SyncStatus> watchSyncStatus() {
    _emitSyncStatus();
    return _syncStatusController.stream;
  }

  /// Force sync all pending changes (T054)
  /// Manually triggers sync for all cached deltas that need syncing
  Future<void> forceSyncAll() async {
    final pendingDeltas = _deltaCache.getDeltasNeedingSync();
    if (pendingDeltas.isEmpty) {
      logger.d('No pending delta changes to sync');
      return;
    }

    _isSyncing = true;
    _emitSyncStatus();

    try {
      logger.d('Force syncing ${pendingDeltas.length} delta(s)');

      // Sync each pending delta
      for (final firestoreDeltaId in pendingDeltas) {
        final delta = _deltaCache.getDelta(firestoreDeltaId);
        final mangaId = _deltaCache.getMangaId(firestoreDeltaId);

        if (delta != null && mangaId != null) {
          try {
            await _syncDeltaToFirestore(mangaId, firestoreDeltaId, delta);
            _deltaCache.markSynced(firestoreDeltaId);
            logger.d('Synced delta: $firestoreDeltaId');
          } catch (e) {
            logger.e('Failed to sync delta $firestoreDeltaId', error: e);
          }
        }
      }

      _lastSyncTime = DateTime.now();
      _isSyncing = false;
      _emitSyncStatus();
      logger.d('Force sync completed');
    } catch (e) {
      logger.e('Force sync failed', error: e);
      _isSyncing = false;
      _emitSyncStatus();
      rethrow;
    }
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
      final ideaMemoDelta = deltas
          .where((d) => d.fieldName == 'ideaMemo' && d.pageId == null)
          .firstOrNull;
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
            pageDeltas.where((d) => d.fieldName == 'memoDelta').firstOrNull;
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
            .where((d) => d.fieldName == 'stageDirectionDelta')
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
        final dialoguesDeltaDoc = pageDeltas
            .where((d) => d.fieldName == 'dialoguesDelta')
            .firstOrNull;
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
  // Sync Status Helpers
  // ============================================================================

  /// Initialize connectivity monitoring (T053)
  void _initializeConnectivityMonitoring() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      final wasOnline = _isOnline;
      _isOnline = !result.contains(ConnectivityResult.none);

      if (wasOnline != _isOnline) {
        logger.d('Connection state changed: $_isOnline');
        _emitSyncStatus();

        // If we just came online, trigger a sync
        if (_isOnline && _deltaCache.getDeltasNeedingSync().isNotEmpty) {
          logger.d('Connection restored, syncing pending changes');
          forceSyncAll();
        }
      }
    });

    // Check initial connectivity
    Connectivity().checkConnectivity().then((result) {
      _isOnline = !result.contains(ConnectivityResult.none);
      _emitSyncStatus();
    });
  }

  /// Emit current sync status to listeners
  void _emitSyncStatus() {
    // Derive pending manga IDs from pending deltas
    final pendingDeltaIds = _deltaCache.getDeltasNeedingSync();
    final pendingMangaIds = pendingDeltaIds
        .map((deltaId) => _deltaCache.getMangaId(deltaId))
        .whereType<String>()
        .toSet()
        .toList();

    final status = SyncStatus(
      isOnline: _isOnline,
      isSyncing: _isSyncing,
      lastSyncedAt: _lastSyncTime,
      pendingMangaIds: pendingMangaIds,
    );
    _syncStatusController.add(status);
  }

  /// Log performance metrics (T081)
  void _logPerformanceMetrics() {
    // Log cache performance periodically (every 50 operations)
    final totalOps = _cacheHits + _cacheMisses;
    if (totalOps > 0 && totalOps % 50 == 0) {
      final hitRate = (_cacheHits / totalOps * 100).toStringAsFixed(1);
      logger.d(
          'Cache Performance: $_cacheHits hits, $_cacheMisses misses ($hitRate% hit rate)');
      logger.d('Firestore Operations: $_firestoreOperations');
    }
  }

  /// Dispose resources
  void dispose() {
    _deltaCache.dispose();
    _connectivitySubscription?.cancel();
    _syncStatusController.close();
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
