import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:my_manga_editor_common/delta_text.dart';
import 'package:my_manga_editor_common/logger.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor_data/repository/exceptions.dart'
    as repo_exceptions;
import 'package:my_manga_editor_data/service/connectivity_service.dart';
import 'package:my_manga_editor_data/service/firebase/auth_service.dart';
import 'package:my_manga_editor_data/service/firebase/firebase_service.dart';
import 'package:my_manga_editor_data/service/firebase/model/cloud_delta.dart';
import 'package:my_manga_editor_data/service/firebase/model/cloud_manga.dart';
import 'package:my_manga_editor_data/service/firebase/model/cloud_manga_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'manga_repository.g.dart';

@Riverpod(keepAlive: true)
MangaRepository mangaRepository(Ref ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  final authService = ref.watch(authServiceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);

  return MangaRepository(
    firebaseService: firebaseService,
    authService: authService,
    connectivityService: connectivityService,
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
    required ConnectivityService connectivityService,
  })  : _firebaseService = firebaseService,
        _authService = authService,
        _connectivityService = connectivityService {
    _initializeConnectivityMonitoring();
  }

  final FirebaseService _firebaseService;
  final AuthService _authService;
  final ConnectivityService _connectivityService;

  // Track mangaId for each pageId to enable efficient lookups
  final Map<MangaPageId, MangaId> _pageToMangaMap = {};

  // Online status tracking
  final StreamController<bool> _onlineStatusController =
      StreamController<bool>.broadcast();
  bool _isOnline = true;
  StreamSubscription<bool>? _connectivitySubscription;

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
        status: MangaStatus.idea.name,
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

  /// Update manga status
  Future<void> updateMangaStatus(MangaId id, MangaStatus status) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw repo_exceptions.AuthException();
      }

      await _firebaseService.updateManga(id.id, {
        'status': status.name,
      });
      logger.d('Updated manga status: $id -> ${status.name}');
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

      // Create memo delta
      final emptyDelta = Delta();
      final memoDelta = CloudDelta(
        id: '',
        mangaId: mangaId.id,
        ops: emptyDelta.toJson() as List<dynamic>,
        fieldName: 'memoDelta',
        pageId: pageId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final memoDeltaFirestoreId =
          await _firebaseService.createDelta(mangaId.id, memoDelta);

      // Create one initial SceneUnit (dialogue + stageDirection)
      final sceneUnit =
          await _createSceneUnitDeltas(mangaId.id, pageId, emptyDelta);

      // Update page document with delta ID references
      await _firebaseService.updateMangaPage(mangaId.id, pageId, {
        'memoDeltaId': memoDeltaFirestoreId,
        'sceneUnits': [sceneUnit],
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
  Stream<bool> watchOnlineStatus() async* {
    yield _isOnline;
    yield* _onlineStatusController.stream;
  }

  // ============================================================================
  // SceneUnit Operations
  // ============================================================================

  /// Add a new SceneUnit (dialogue + stageDirection pair) to a page
  Future<void> addSceneUnit(MangaId mangaId, MangaPageId pageId) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw repo_exceptions.AuthException();
      }

      final emptyDelta = Delta();
      final sceneUnit =
          await _createSceneUnitDeltas(mangaId.id, pageId.id, emptyDelta);

      // Fetch current page to get existing sceneUnits
      final currentPage =
          await _firebaseService.fetchMangaPage(mangaId.id, pageId.id);
      if (currentPage == null) {
        throw repo_exceptions.NotFoundException('MangaPage', pageId.id);
      }

      final existingUnits =
          List<Map<String, dynamic>>.from(currentPage.sceneUnits ?? []);
      existingUnits.add(sceneUnit);

      await _firebaseService.updateMangaPage(mangaId.id, pageId.id, {
        'schemaVersion': CloudMangaPageExt.schemaVersion,
        'sceneUnits': existingUnits,
        'updatedAt': DateTime.now(),
      });

      logger.d('Added SceneUnit to page: $pageId');
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    }
  }

  /// Remove a SceneUnit at the given index from a page
  Future<void> removeSceneUnit(
      MangaId mangaId, MangaPageId pageId, int index) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw repo_exceptions.AuthException();
      }

      final currentPage =
          await _firebaseService.fetchMangaPage(mangaId.id, pageId.id);
      if (currentPage == null) {
        throw repo_exceptions.NotFoundException('MangaPage', pageId.id);
      }

      final existingUnits =
          List<Map<String, dynamic>>.from(currentPage.sceneUnits ?? []);
      if (index < 0 ||
          index >= existingUnits.length ||
          existingUnits.length <= 1) {
        return; // Cannot remove if out of bounds or last remaining unit
      }

      final removed = existingUnits.removeAt(index);

      // Delete associated delta documents
      final dialoguesDeltaId = removed['dialoguesDeltaId'] as String?;
      final stageDirectionDeltaId = removed['stageDirectionDeltaId'] as String?;
      if (dialoguesDeltaId != null) {
        await _firebaseService.deleteDelta(mangaId.id, dialoguesDeltaId);
      }
      if (stageDirectionDeltaId != null) {
        await _firebaseService.deleteDelta(mangaId.id, stageDirectionDeltaId);
      }

      await _firebaseService.updateMangaPage(mangaId.id, pageId.id, {
        'schemaVersion': CloudMangaPageExt.schemaVersion,
        'sceneUnits': existingUnits,
        'updatedAt': DateTime.now(),
      });

      logger.d('Removed SceneUnit at index $index from page: $pageId');
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    }
  }

  /// Helper: create dialogue + stageDirection delta pair for a SceneUnit
  Future<Map<String, dynamic>> _createSceneUnitDeltas(
      String mangaId, String pageId, Delta emptyDelta) async {
    final dialogueDelta = CloudDelta(
      id: '',
      mangaId: mangaId,
      ops: emptyDelta.toJson() as List<dynamic>,
      fieldName: 'dialoguesDelta',
      pageId: pageId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final dialogueDeltaId =
        await _firebaseService.createDelta(mangaId, dialogueDelta);

    final stageDirectionDelta = CloudDelta(
      id: '',
      mangaId: mangaId,
      ops: emptyDelta.toJson() as List<dynamic>,
      fieldName: 'stageDirectionDelta',
      pageId: pageId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final stageDirectionDeltaId =
        await _firebaseService.createDelta(mangaId, stageDirectionDelta);

    return {
      'dialoguesDeltaId': dialogueDeltaId,
      'stageDirectionDeltaId': stageDirectionDeltaId,
    };
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

      // 本文が空のセクションは見出しごと出力しない
      void writeSection(String heading, String body) {
        if (body.isEmpty) {
          return;
        }
        buffer.writeln(heading);
        buffer.writeln();
        buffer.writeln(_toMarkdownBody(body));
        buffer.writeln();
      }

      writeSection('## アイデアメモ', _plainTextOf(deltas, manga.ideaMemoDeltaId));

      // Add pages
      for (int i = 0; i < pages.length; i++) {
        final page = pages[i];
        buffer.writeln('## ページ ${i + 1}');
        buffer.writeln();

        final pageDeltas = deltas.where((d) => d.pageId == page.id).toList();

        writeSection('### メモ', _plainTextOf(pageDeltas, page.memoDeltaId));

        // ページ内の全カットのト書き・セリフを 1 つのまとまりとして並べる。
        // カットの順に、カットごとに「ト書き → セリフ」で並べ、1 行ずつ空行で区切る。
        // ト書きは行頭に （ト書き） を付けてセリフと見分けられるようにする
        final domainPage = page.toMangaPage();
        final paragraphs = <String>[];
        for (final unit in domainPage.sceneUnits) {
          paragraphs.addAll(_bodyParagraphs(
            _plainTextOf(pageDeltas, unit.stageDirectionDeltaId.id),
            label: 'ト書き',
          ));
          paragraphs.addAll(
            _bodyParagraphs(_plainTextOf(pageDeltas, unit.dialoguesDeltaId.id)),
          );
        }
        if (paragraphs.isNotEmpty) {
          buffer.writeln('### 本文');
          buffer.writeln();
          for (final paragraph in paragraphs) {
            buffer.writeln(paragraph);
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

  /// [deltas] から [deltaId] の Delta を探してプレーンテキスト化する。
  /// 見つからない場合や中身が空の場合は空文字列を返す。
  String _plainTextOf(List<CloudDelta> deltas, String? deltaId) {
    if (deltaId == null) {
      return '';
    }
    final doc = deltas.where((d) => d.id == deltaId).firstOrNull;
    if (doc == null || doc.ops.isEmpty) {
      return '';
    }
    return deltaToPlainText(Delta.fromJson(doc.ops));
  }

  /// 本文を 1 行 1 段落に分ける。空行は段落にしない。
  ///
  /// [label] を渡すと各段落の先頭に `（<label>）` を付ける。
  /// ラベルが付く行は行頭が記号にならないので、エスケープは不要。
  List<String> _bodyParagraphs(String body, {String? label}) {
    final paragraphs = <String>[];
    for (final line in body.split('\n')) {
      if (line.trim().isEmpty) {
        continue;
      }
      paragraphs
          .add(label == null ? _escapeMarkdownLine(line) : '（$label）$line');
    }
    return paragraphs;
  }

  /// 利用者が書いたプレーンテキストを、Markdown として開いても
  /// 書いたとおりに見える本文に直す。
  ///
  /// - 続く行は行末の半角スペース 2 つ (強制改行) でつなぐ。
  ///   そのままだと 1 行ずつの改行が無視されて 1 段落に繋がってしまうため
  /// - 行頭の記号はエスケープする ([_escapeMarkdownLine])
  ///
  /// 空行はそのままで段落の区切りとして働くので、強制改行は付けない。
  String _toMarkdownBody(String body) {
    final lines = body.split('\n');
    final buffer = StringBuffer();
    for (int i = 0; i < lines.length; i++) {
      buffer.write(_escapeMarkdownLine(lines[i]));
      if (i == lines.length - 1) {
        break;
      }
      if (lines[i].isNotEmpty && lines[i + 1].isNotEmpty) {
        buffer.write('  ');
      }
      buffer.write('\n');
    }
    return buffer.toString();
  }

  /// 行頭に来ると Markdown のブロック要素 (箇条書き・引用・見出し・罫線など) に
  /// 化ける記号を `\` でエスケープする。
  ///
  /// 行の途中の記号は、そのままでも本文として読めるほうが多いので触らない。
  /// 例: `- 場面転換` → `\- 場面転換`、`1. 導入` → `1\. 導入`
  String _escapeMarkdownLine(String line) {
    final block = RegExp(r'^([^\S\n]*)([-+*>#=_~`])').firstMatch(line);
    if (block != null) {
      return '${block.group(1)}\\${block.group(2)}'
          '${line.substring(block.end)}';
    }
    final ordered = RegExp(r'^([^\S\n]*\d+)([.)])').firstMatch(line);
    if (ordered != null) {
      return '${ordered.group(1)}\\${ordered.group(2)}'
          '${line.substring(ordered.end)}';
    }
    return line;
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
        _connectivityService.onConnectivityChanged().listen((isOnline) {
      final wasOnline = _isOnline;
      _isOnline = isOnline;

      if (wasOnline != _isOnline) {
        logger.d('Connection state changed: $_isOnline');
        _emitOnlineStatus();
      }
    });

    // Check initial connectivity
    _connectivityService.isOnline().then((isOnline) {
      _isOnline = isOnline;
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
      status: MangaStatusExt.fromString(status),
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
      status: status.name,
    );
  }
}

/// Extension for converting CloudMangaPage to MangaPage
extension CloudMangaPageConversion on CloudMangaPage {
  MangaPage toMangaPage() {
    final units = (sceneUnits ?? []).map((map) {
      return SceneUnit(
        dialoguesDeltaId: DeltaId(map['dialoguesDeltaId'] as String? ?? ''),
        stageDirectionDeltaId:
            DeltaId(map['stageDirectionDeltaId'] as String? ?? ''),
      );
    }).toList();

    return MangaPage(
      id: MangaPageId(id),
      mangaId: MangaId(mangaId),
      memoDeltaId: DeltaId(memoDeltaId ?? ''),
      sceneUnits: units,
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
      sceneUnits: sceneUnits
          .map((unit) => {
                'dialoguesDeltaId': unit.dialoguesDeltaId.id,
                'stageDirectionDeltaId': unit.stageDirectionDeltaId.id,
              })
          .toList(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
