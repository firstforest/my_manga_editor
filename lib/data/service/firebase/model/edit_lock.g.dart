// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_lock.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EditLock _$EditLockFromJson(Map<String, dynamic> json) => _EditLock(
      lockedBy: json['lockedBy'] as String,
      lockedAt: DateTime.parse(json['lockedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      deviceId: json['deviceId'] as String,
    );

Map<String, dynamic> _$EditLockToJson(_EditLock instance) => <String, dynamic>{
      'lockedBy': instance.lockedBy,
      'lockedAt': instance.lockedAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'deviceId': instance.deviceId,
    };
