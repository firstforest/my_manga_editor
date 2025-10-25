import 'dart:async';

import 'package:my_manga_editor/common/logger.dart';
import 'package:my_manga_editor/feature/manga/model/manga.dart';
import 'package:my_manga_editor/feature/manga/model/sync_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_state_notifier.g.dart';

/// Notifier for managing sync state and queue
/// NOTE: This is a stub implementation for Firebase-only persistence
/// Full sync functionality will be implemented in User Story 2
@riverpod
class SyncStateNotifier extends _$SyncStateNotifier {
  Timer? _periodicSyncTimer;

  @override
  SyncStatus build() {
    // Auto-sync is handled by Firestore offline persistence
    // This stub just provides a simple sync status

    ref.onDispose(() {
      _periodicSyncTimer?.cancel();
    });

    return SyncStatus(
      isOnline: true,
      isSyncing: false,
      lastSyncedAt: DateTime.now(),
      pendingMangaIds: [],
    );
  }

  /// Queue a manga for sync (no-op with Firestore)
  void queueMangaSync(MangaId mangaId) {
    logger.d('Queueing manga for sync: $mangaId (handled by Firestore)');
    // Firestore handles sync automatically with offline persistence
  }

  /// Queue a page for sync (no-op with Firestore)
  void queuePageSync(MangaId mangaId) {
    logger.d('Queueing page sync for manga: $mangaId (handled by Firestore)');
    // Firestore handles sync automatically with offline persistence
  }

  /// Process sync queue (no-op with Firestore)
  Future<void> processSyncQueue() async {
    logger.d('Processing sync queue (handled by Firestore)');
    // Firestore handles sync automatically with offline persistence
  }

  /// Force retry failed syncs (no-op with Firestore)
  Future<void> retryFailedSyncs() async {
    logger.d('Retrying failed syncs (handled by Firestore)');
    // Firestore handles retry logic automatically
  }

  /// Clear sync queue (no-op with Firestore)
  void clearSyncQueue() {
    logger.d('Clearing sync queue (handled by Firestore)');
    // Firestore manages sync queue internally
  }
}

/// Provider for getting sync status of a specific manga
/// Returns null if manga is not in sync queue
@riverpod
SyncStatus? mangaSyncStatus(Ref ref, MangaId mangaId) {
  // With Firestore offline persistence, all data is automatically synced
  // Return a simple "synced" status
  return SyncStatus(
    isOnline: true,
    isSyncing: false,
    lastSyncedAt: DateTime.now(),
    pendingMangaIds: [],
  );
}
