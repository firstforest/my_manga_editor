import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_status.freezed.dart';

enum SyncState {
  synced, // Fully synchronized with cloud
  syncing, // Sync in progress
  pending, // Waiting to sync
  error, // Sync failed
  offline, // User offline, sync paused
}

@freezed
abstract class SyncStatus with _$SyncStatus {
  const factory SyncStatus({
    required SyncState state,
    DateTime? lastSyncedAt, // Null if never synced
    String? errorMessage, // Null if no error
    int? pendingOperations, // Count of operations in queue
  }) = _SyncStatus;
}
