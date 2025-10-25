// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_queue_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SyncQueueEntry _$SyncQueueEntryFromJson(Map<String, dynamic> json) =>
    _SyncQueueEntry(
      id: (json['id'] as num).toInt(),
      operationType:
          $enumDecode(_$SyncOperationTypeEnumMap, json['operationType']),
      collectionPath: json['collectionPath'] as String,
      documentId: json['documentId'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
      status: $enumDecodeNullable(_$SyncQueueStatusEnumMap, json['status']) ??
          SyncQueueStatus.pending,
    );

Map<String, dynamic> _$SyncQueueEntryToJson(_SyncQueueEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'operationType': _$SyncOperationTypeEnumMap[instance.operationType]!,
      'collectionPath': instance.collectionPath,
      'documentId': instance.documentId,
      'data': instance.data,
      'timestamp': instance.timestamp.toIso8601String(),
      'retryCount': instance.retryCount,
      'status': _$SyncQueueStatusEnumMap[instance.status]!,
    };

const _$SyncOperationTypeEnumMap = {
  SyncOperationType.create: 'create',
  SyncOperationType.update: 'update',
  SyncOperationType.delete: 'delete',
};

const _$SyncQueueStatusEnumMap = {
  SyncQueueStatus.pending: 'pending',
  SyncQueueStatus.syncing: 'syncing',
  SyncQueueStatus.completed: 'completed',
  SyncQueueStatus.failed: 'failed',
};
