import 'package:freezed_annotation/freezed_annotation.dart';

part 'manga.freezed.dart';

enum MangaStartPage {
  left,
  right,
  ;

  MangaStartPage get reverted => switch (this) {
        MangaStartPage.left => MangaStartPage.right,
        MangaStartPage.right => MangaStartPage.left,
      };
}

/// Helper extension for MangaStartPage enum conversion
extension MangaStartPageExt on MangaStartPage {
  static MangaStartPage fromString(String value) {
    return MangaStartPage.values.firstWhere((e) => e.name == value);
  }
}

extension type MangaId(String id) {}
extension type MangaPageId(String id) {}
extension type DeltaId(int id) {}

@freezed
abstract class Manga with _$Manga {
  const factory Manga({
    required MangaId id,
    required String name,
    required MangaStartPage startPage,
    required DeltaId ideaMemo,
  }) = _Manga;
}

@freezed
abstract class MangaPage with _$MangaPage {
  const factory MangaPage({
    required MangaPageId id,
    required DeltaId memoDelta,
    required DeltaId stageDirectionDelta,
    required DeltaId dialoguesDelta,
  }) = _MangaPage;
}
