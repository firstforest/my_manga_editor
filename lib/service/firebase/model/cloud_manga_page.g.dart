// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloud_manga_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CloudMangaPage _$CloudMangaPageFromJson(Map<String, dynamic> json) =>
    _CloudMangaPage(
      id: json['id'] as String,
      mangaId: json['mangaId'] as String,
      pageIndex: (json['pageIndex'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      memoDeltaId: json['memoDeltaId'] as String?,
      stageDirectionDeltaId: json['stageDirectionDeltaId'] as String?,
      dialoguesDeltaId: json['dialoguesDeltaId'] as String?,
    );

Map<String, dynamic> _$CloudMangaPageToJson(_CloudMangaPage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mangaId': instance.mangaId,
      'pageIndex': instance.pageIndex,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'memoDeltaId': instance.memoDeltaId,
      'stageDirectionDeltaId': instance.stageDirectionDeltaId,
      'dialoguesDeltaId': instance.dialoguesDeltaId,
    };
