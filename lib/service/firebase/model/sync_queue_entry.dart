import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_queue_entry.freezed.dart';
part 'sync_queue_entry.g.dart';

enum SyncOperationType {
  create,
  update,
  delete,
}

enum SyncQueueStatus {
  pending,
  syncing,
  completed,
  failed,
}

@freezed
abstract class SyncQueueEntry with _$SyncQueueEntry {
  const factory SyncQueueEntry({
    required int id, // SQLite auto-increment ID
    required SyncOperationType operationType, // CRUD operation type
    required String collectionPath, // Firestore collection path
    required String? documentId, // Document ID (null for create)
    required Map<String, dynamic>? data, // JSON payload
    required DateTime timestamp, // Queue entry creation time
    @Default(0) int retryCount, // Number of retry attempts
    @Default(SyncQueueStatus.pending) SyncQueueStatus status,
  }) = _SyncQueueEntry;

  factory SyncQueueEntry.fromJson(Map<String, dynamic> json) =>
      _$SyncQueueEntryFromJson(json);
}
