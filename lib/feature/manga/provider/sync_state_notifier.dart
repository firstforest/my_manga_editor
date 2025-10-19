import 'dart:async';

import 'package:my_manga_editor/common/logger.dart';
import 'package:my_manga_editor/feature/manga/model/manga.dart';
import 'package:my_manga_editor/feature/manga/model/sync_status.dart';
import 'package:my_manga_editor/feature/manga/repository/auth_repository.dart';
import 'package:my_manga_editor/feature/manga/repository/manga_repository.dart';
import 'package:my_manga_editor/service/firebase/firebase_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_state_notifier.g.dart';

/// Notifier for managing sync state and queue
/// Handles periodic sync, retry logic, and sync status tracking
@riverpod
class SyncStateNotifier extends _$SyncStateNotifier {
  Timer? _periodicSyncTimer;
  bool _isSyncing = false;

  @override
  Map<MangaId, SyncStatus> build() {
    // Start periodic sync timer (30-60 seconds)
    _startPeriodicSync();

    // Clean up timer when disposed
    ref.onDispose(() {
      _periodicSyncTimer?.cancel();
    });

    return {};
  }

  /// Start periodic sync timer
  /// Triggers sync every 45 seconds (middle of 30-60 second range)
  void _startPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(
      const Duration(seconds: 45),
      (_) => processSyncQueue(),
    );
  }

  /// Pause periodic sync (e.g., when app is backgrounded)
  void pausePeriodicSync() {
    logger.d('Pausing periodic sync');
    _periodicSyncTimer?.cancel();
  }

  /// Resume periodic sync (e.g., when app is foregrounded)
  void resumePeriodicSync() {
    logger.d('Resuming periodic sync');
    _startPeriodicSync();
  }

  /// Queue a manga for sync
  /// Updates the sync status to pending
  void queueMangaSync(MangaId mangaId) {
    logger.d('Queueing manga for sync: $mangaId');
    state = {
      ...state,
      mangaId: const SyncStatus(
        state: SyncState.pending,
        pendingOperations: 1,
      ),
    };
  }

  /// Queue a manga page for sync
  void queuePageSync(MangaId mangaId) {
    logger.d('Queueing page sync for manga: $mangaId');
    final currentStatus = state[mangaId];
    final pendingOps = (currentStatus?.pendingOperations ?? 0) + 1;

    state = {
      ...state,
      mangaId: SyncStatus(
        state: SyncState.pending,
        pendingOperations: pendingOps,
        lastSyncedAt: currentStatus?.lastSyncedAt,
      ),
    };
  }

  /// Process sync queue for all pending mangas
  /// Uploads pending manga data to Firestore
  Future<void> processSyncQueue() async {
    // Check if user is authenticated
    final authRepo = ref.read(authRepositoryProvider);
    if (!authRepo.isSignedIn) {
      logger.d('Sync skipped: User not authenticated');
      // Update all pending to offline
      state = {
        for (final entry in state.entries)
          if (entry.value.state == SyncState.pending)
            entry.key: const SyncStatus(state: SyncState.offline)
          else
            entry.key: entry.value,
      };
      return;
    }

    // Skip if already syncing
    if (_isSyncing) {
      logger.d('Sync already in progress, skipping');
      return;
    }

    _isSyncing = true;

    try {
      final pendingMangaIds = state.entries
          .where((e) => e.value.state == SyncState.pending)
          .map((e) => e.key)
          .toList();

      if (pendingMangaIds.isEmpty) {
        logger.d('No pending sync operations');
        return;
      }

      logger.d('Processing sync queue: ${pendingMangaIds.length} mangas');

      for (final mangaId in pendingMangaIds) {
        await _syncManga(mangaId);
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync a single manga with retry logic
  Future<void> _syncManga(MangaId mangaId, {int retryCount = 0}) async {
    const maxRetries = 3;

    try {
      // Update status to syncing
      _updateStatus(
        mangaId,
        const SyncStatus(state: SyncState.syncing),
      );

      final mangaRepo = ref.read(mangaRepositoryProvider);
      final firebaseService = ref.read(firebaseServiceProvider);
      final userId = ref.read(authRepositoryProvider).currentUser?.uid;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Fetch manga from local DB
      final manga = await mangaRepo.getMangaStream(mangaId).first;
      if (manga == null) {
        logger.w('Manga $mangaId not found in local DB');
        _removeStatus(mangaId);
        return;
      }

      // Convert to CloudManga and upload
      final cloudManga = await manga.toCloudManga(mangaRepo, userId);
      await firebaseService.uploadManga(cloudManga);

      logger.d('Uploaded manga: ${manga.name}');

      // Sync all pages
      final pageIds = await mangaRepo.watchAllMangaPageIdList(mangaId).first;
      for (int i = 0; i < pageIds.length; i++) {
        final pageId = pageIds[i];
        final page = await mangaRepo.getMangaPageStream(pageId).first;

        if (page != null) {
          final cloudPage = await page.toCloudMangaPage(
            mangaRepo,
            cloudManga.id,
            i, // pageIndex
          );
          await firebaseService.uploadMangaPage(cloudPage);
        }
      }

      logger.d('Uploaded ${pageIds.length} pages for manga: ${manga.name}');

      // Update status to synced
      _updateStatus(
        mangaId,
        SyncStatus(
          state: SyncState.synced,
          lastSyncedAt: DateTime.now(),
          pendingOperations: 0,
        ),
      );
    } on FirebaseServiceException catch (e) {
      logger.e('Sync failed for manga $mangaId: $e');

      if (retryCount < maxRetries) {
        // Exponential backoff: 2^retry seconds
        final delaySeconds = 1 << retryCount; // 1, 2, 4 seconds
        logger.d('Retrying sync in $delaySeconds seconds (attempt ${retryCount + 1}/$maxRetries)');
        await Future.delayed(Duration(seconds: delaySeconds));
        return _syncManga(mangaId, retryCount: retryCount + 1);
      } else {
        // Max retries reached, mark as error
        _updateStatus(
          mangaId,
          SyncStatus(
            state: SyncState.error,
            errorMessage: e.message,
            pendingOperations: 1,
          ),
        );
      }
    } catch (e) {
      logger.e('Unexpected error syncing manga $mangaId: $e');
      _updateStatus(
        mangaId,
        SyncStatus(
          state: SyncState.error,
          errorMessage: 'Unexpected error: $e',
          pendingOperations: 1,
        ),
      );
    }
  }

  /// Delete manga from cloud
  Future<void> deleteMangaFromCloud(MangaId mangaId) async {
    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      await firebaseService.deleteManga(mangaId.toString());
      _removeStatus(mangaId);
      logger.d('Deleted manga from cloud: $mangaId');
    } on FirebaseServiceException catch (e) {
      logger.e('Failed to delete manga from cloud: $e');
      _updateStatus(
        mangaId,
        SyncStatus(
          state: SyncState.error,
          errorMessage: 'Delete failed: ${e.message}',
        ),
      );
    }
  }

  /// Delete manga page from cloud
  Future<void> deletePageFromCloud(MangaId mangaId, MangaPageId pageId) async {
    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      await firebaseService.deleteMangaPage(
        mangaId.toString(),
        pageId.toString(),
      );
      logger.d('Deleted page from cloud: $pageId');
    } on FirebaseServiceException catch (e) {
      logger.e('Failed to delete page from cloud: $e');
    }
  }

  /// Manually trigger sync for a specific manga
  Future<void> syncMangaManually(MangaId mangaId) async {
    logger.d('Manual sync triggered for manga: $mangaId');
    queueMangaSync(mangaId);
    await processSyncQueue();
  }

  /// Retry failed sync
  Future<void> retryFailedSync(MangaId mangaId) async {
    logger.d('Retrying failed sync for manga: $mangaId');
    queueMangaSync(mangaId);
    await processSyncQueue();
  }

  /// Update sync status for a manga
  void _updateStatus(MangaId mangaId, SyncStatus status) {
    state = {...state, mangaId: status};
  }

  /// Remove sync status for a manga
  void _removeStatus(MangaId mangaId) {
    state = Map.from(state)..remove(mangaId);
  }

  /// Get sync status for a manga
  SyncStatus? getSyncStatus(MangaId mangaId) {
    return state[mangaId];
  }

  /// Perform initial sync - download all user data from cloud
  /// Called when user signs in for the first time or on a fresh device
  Future<void> performInitialSync() async {
    logger.d('Starting initial sync from cloud');

    // Check if user is authenticated
    final authRepo = ref.read(authRepositoryProvider);
    if (!authRepo.isSignedIn) {
      logger.w('Cannot perform initial sync: User not authenticated');
      return;
    }

    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      final mangaRepo = ref.read(mangaRepositoryProvider);

      // Fetch all user mangas from Firestore
      logger.d('Fetching user mangas from Firestore');
      final cloudMangas = await firebaseService.fetchUserMangas();
      logger.d('Found ${cloudMangas.length} mangas in cloud');

      if (cloudMangas.isEmpty) {
        logger.d('No cloud data to download');
        return;
      }

      // Download each manga and its pages
      for (final cloudManga in cloudMangas) {
        logger.d('Downloading manga: ${cloudManga.name}');

        // Download manga
        final mangaId = await mangaRepo.downloadCloudManga(cloudManga);

        // Download all pages for this manga
        final cloudPages = await firebaseService.fetchMangaPages(cloudManga.id);
        logger.d('Found ${cloudPages.length} pages for manga: ${cloudManga.name}');

        for (final cloudPage in cloudPages) {
          await mangaRepo.downloadCloudMangaPage(cloudPage, mangaId);
        }

        // Mark as synced
        _updateStatus(
          mangaId,
          SyncStatus(
            state: SyncState.synced,
            lastSyncedAt: DateTime.now(),
          ),
        );
      }

      logger.d('Initial sync completed successfully');
    } catch (e) {
      logger.e('Initial sync failed: $e');
      // Don't throw - allow app to continue with local data
    }
  }
}

/// Provider for sync status of a specific manga
@riverpod
SyncStatus? mangaSyncStatus(Ref ref, MangaId mangaId) {
  final syncState = ref.watch(syncStateProvider);
  return syncState[mangaId];
}
