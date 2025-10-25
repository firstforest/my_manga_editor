// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SyncStatus _$SyncStatusFromJson(Map<String, dynamic> json) => _SyncStatus(
      isOnline: json['isOnline'] as bool,
      isSyncing: json['isSyncing'] as bool,
      lastSyncedAt: json['lastSyncedAt'] == null
          ? null
          : DateTime.parse(json['lastSyncedAt'] as String),
      pendingMangaIds: (json['pendingMangaIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SyncStatusToJson(_SyncStatus instance) =>
    <String, dynamic>{
      'isOnline': instance.isOnline,
      'isSyncing': instance.isSyncing,
      'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
      'pendingMangaIds': instance.pendingMangaIds,
    };
