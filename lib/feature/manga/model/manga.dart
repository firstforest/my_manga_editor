import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'manga.freezed.dart';
part 'manga.g.dart';

// Custom JsonConverter for Quill Delta
class DeltaConverter implements JsonConverter<Delta, Map<String, dynamic>> {
  const DeltaConverter();

  @override
  Delta fromJson(Map<String, dynamic> json) {
    return Delta.fromJson(json['ops'] ?? []);
  }

  @override
  Map<String, dynamic> toJson(Delta delta) {
    return {'ops': delta.toJson()};
  }
}

// Custom JsonConverter for Firestore Timestamp
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) {
    return timestamp.toDate();
  }

  @override
  Timestamp toJson(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }
}

enum MangaStartPage {
  left,
  right,
  ;

  MangaStartPage get reverted => switch (this) {
        MangaStartPage.left => MangaStartPage.right,
        MangaStartPage.right => MangaStartPage.left,
      };
}

typedef MangaId = String;
typedef MangaPageId = String;
typedef DeltaId = int; // Temporary: for Drift compatibility during migration

@freezed
abstract class Manga with _$Manga {
  const factory Manga({
    required MangaId id,
    required String name,
    required MangaStartPage startPage,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _Manga;

  factory Manga.fromJson(Map<String, dynamic> json) => _$MangaFromJson(json);
}

@freezed
abstract class MangaPage with _$MangaPage {
  const factory MangaPage({
    required MangaPageId id,
    required int pageIndex,
    @DeltaConverter() required Delta memoDelta,
    @DeltaConverter() required Delta stageDirectionDelta,
    @DeltaConverter() required Delta dialoguesDelta,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _MangaPage;

  factory MangaPage.fromJson(Map<String, dynamic> json) =>
      _$MangaPageFromJson(json);
}
