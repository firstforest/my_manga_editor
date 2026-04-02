// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloud_delta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CloudDelta _$CloudDeltaFromJson(Map<String, dynamic> json) => _CloudDelta(
      id: json['id'] as String,
      mangaId: json['mangaId'] as String,
      ops: json['ops'] as List<dynamic>,
      fieldName: json['fieldName'] as String,
      pageId: json['pageId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CloudDeltaToJson(_CloudDelta instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mangaId': instance.mangaId,
      'ops': instance.ops,
      'fieldName': instance.fieldName,
      'pageId': instance.pageId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
