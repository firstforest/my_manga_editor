// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MangaImpl _$$MangaImplFromJson(Map<String, dynamic> json) => _$MangaImpl(
      name: json['name'] as String,
      startPage: $enumDecode(_$MangaStartPageEnumMap, json['startPage']),
      pages: (json['pages'] as List<dynamic>)
          .map((e) => MangaPage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$MangaImplToJson(_$MangaImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'startPage': _$MangaStartPageEnumMap[instance.startPage]!,
      'pages': instance.pages,
    };

const _$MangaStartPageEnumMap = {
  MangaStartPage.left: 'left',
  MangaStartPage.right: 'right',
};

_$MangaPageImpl _$$MangaPageImplFromJson(Map<String, dynamic> json) =>
    _$MangaPageImpl(
      id: (json['id'] as num).toInt(),
      memoDelta: json['memoDelta'] as String?,
      dialoguesDelta: json['dialoguesDelta'] as String?,
    );

Map<String, dynamic> _$$MangaPageImplToJson(_$MangaPageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memoDelta': instance.memoDelta,
      'dialoguesDelta': instance.dialoguesDelta,
    };
