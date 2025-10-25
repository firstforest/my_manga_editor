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

@freezed
abstract class Manga with _$Manga {
  const factory Manga({
    required MangaId id,
    required String name,
    required MangaStartPage startPage,
    required String ideaMemoDeltaId, // CloudDelta document ID
  }) = _Manga;
}

@freezed
abstract class MangaPage with _$MangaPage {
  const factory MangaPage({
    required MangaPageId id,
    required MangaId mangaId,
    required String memoDeltaId, // CloudDelta document ID
    required String stageDirectionDeltaId, // CloudDelta document ID
    required String dialoguesDeltaId, // CloudDelta document ID
  }) = _MangaPage;
}
