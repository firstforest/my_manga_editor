// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MangaImpl _$$MangaImplFromJson(Map<String, dynamic> json) => _$MangaImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      startPage: $enumDecode(_$MangaStartPageEnumMap, json['startPage']),
      ideaMemo: (json['ideaMemo'] as num).toInt(),
    );

Map<String, dynamic> _$$MangaImplToJson(_$MangaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'startPage': _$MangaStartPageEnumMap[instance.startPage]!,
      'ideaMemo': instance.ideaMemo,
    };

const _$MangaStartPageEnumMap = {
  MangaStartPage.left: 'left',
  MangaStartPage.right: 'right',
};

_$MangaPageImpl _$$MangaPageImplFromJson(Map<String, dynamic> json) =>
    _$MangaPageImpl(
      id: (json['id'] as num).toInt(),
      memoDelta: (json['memoDelta'] as num).toInt(),
      stageDirectionDelta: (json['stageDirectionDelta'] as num).toInt(),
      dialoguesDelta: (json['dialoguesDelta'] as num).toInt(),
    );

Map<String, dynamic> _$$MangaPageImplToJson(_$MangaPageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memoDelta': instance.memoDelta,
      'stageDirectionDelta': instance.stageDirectionDelta,
      'dialoguesDelta': instance.dialoguesDelta,
    };
