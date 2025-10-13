// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Manga _$MangaFromJson(Map<String, dynamic> json) => _Manga(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      startPage: $enumDecode(_$MangaStartPageEnumMap, json['startPage']),
      ideaMemo: (json['ideaMemo'] as num).toInt(),
    );

Map<String, dynamic> _$MangaToJson(_Manga instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'startPage': _$MangaStartPageEnumMap[instance.startPage]!,
      'ideaMemo': instance.ideaMemo,
    };

const _$MangaStartPageEnumMap = {
  MangaStartPage.left: 'left',
  MangaStartPage.right: 'right',
};

_MangaPage _$MangaPageFromJson(Map<String, dynamic> json) => _MangaPage(
      id: (json['id'] as num).toInt(),
      memoDelta: (json['memoDelta'] as num).toInt(),
      stageDirectionDelta: (json['stageDirectionDelta'] as num).toInt(),
      dialoguesDelta: (json['dialoguesDelta'] as num).toInt(),
    );

Map<String, dynamic> _$MangaPageToJson(_MangaPage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memoDelta': instance.memoDelta,
      'stageDirectionDelta': instance.stageDirectionDelta,
      'dialoguesDelta': instance.dialoguesDelta,
    };
