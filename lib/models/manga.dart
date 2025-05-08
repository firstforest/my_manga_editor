import 'package:freezed_annotation/freezed_annotation.dart';

part 'manga.freezed.dart';
part 'manga.g.dart';

enum MangaStartPage {
  left,
  right,
  ;

  MangaStartPage get reverted => switch (this) {
        MangaStartPage.left => MangaStartPage.right,
        MangaStartPage.right => MangaStartPage.left,
      };
}

typedef MangaId = int;
typedef MangaPageId = int;
typedef DeltaId = int;

@freezed
abstract class Manga with _$Manga {
  const factory Manga({
    required MangaId id,
    required String name,
    required MangaStartPage startPage,
    required DeltaId ideaMemo,
  }) = _Manga;

  factory Manga.fromJson(Map<String, dynamic> json) => _$MangaFromJson(json);
}

@freezed
abstract class MangaPage with _$MangaPage {
  const factory MangaPage({
    required MangaPageId id,
    required DeltaId memoDelta,
    required DeltaId stageDirectionDelta,
    required DeltaId dialoguesDelta,
  }) = _MangaPage;

  factory MangaPage.fromJson(Map<String, dynamic> json) =>
      _$MangaPageFromJson(json);
}
