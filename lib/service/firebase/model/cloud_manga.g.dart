// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloud_manga.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CloudManga _$CloudMangaFromJson(Map<String, dynamic> json) => _CloudManga(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      startPageDirection: json['startPageDirection'] as String,
      ideaMemo: json['ideaMemo'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      editLock: json['editLock'] == null
          ? null
          : EditLock.fromJson(json['editLock'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CloudMangaToJson(_CloudManga instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'startPageDirection': instance.startPageDirection,
      'ideaMemo': instance.ideaMemo,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'editLock': instance.editLock,
    };
