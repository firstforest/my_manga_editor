// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Manga _$MangaFromJson(Map<String, dynamic> json) => _Manga(
  id: json['id'] as String,
  name: json['name'] as String,
  startPage: $enumDecode(_$MangaStartPageEnumMap, json['startPage']),
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  updatedAt: const TimestampConverter().fromJson(
    json['updatedAt'] as Timestamp,
  ),
);

Map<String, dynamic> _$MangaToJson(_Manga instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'startPage': _$MangaStartPageEnumMap[instance.startPage]!,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
};

const _$MangaStartPageEnumMap = {
  MangaStartPage.left: 'left',
  MangaStartPage.right: 'right',
};

_MangaPage _$MangaPageFromJson(Map<String, dynamic> json) => _MangaPage(
  id: json['id'] as String,
  pageIndex: (json['pageIndex'] as num).toInt(),
  memoDelta: const DeltaConverter().fromJson(
    json['memoDelta'] as Map<String, dynamic>,
  ),
  stageDirectionDelta: const DeltaConverter().fromJson(
    json['stageDirectionDelta'] as Map<String, dynamic>,
  ),
  dialoguesDelta: const DeltaConverter().fromJson(
    json['dialoguesDelta'] as Map<String, dynamic>,
  ),
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  updatedAt: const TimestampConverter().fromJson(
    json['updatedAt'] as Timestamp,
  ),
);

Map<String, dynamic> _$MangaPageToJson(_MangaPage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pageIndex': instance.pageIndex,
      'memoDelta': const DeltaConverter().toJson(instance.memoDelta),
      'stageDirectionDelta': const DeltaConverter().toJson(
        instance.stageDirectionDelta,
      ),
      'dialoguesDelta': const DeltaConverter().toJson(instance.dialoguesDelta),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };
