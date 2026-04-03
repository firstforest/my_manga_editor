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

enum MangaStatus {
  idea,
  inProgress,
  complete,
}

/// Helper extension for MangaStatus enum conversion
extension MangaStatusExt on MangaStatus {
  static MangaStatus fromString(String? value) {
    if (value == null) return MangaStatus.idea;
    return MangaStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MangaStatus.idea,
    );
  }
}

extension type MangaId(String id) {}
extension type MangaPageId(String id) {}
extension type DeltaId(String id) {}

@freezed
abstract class Manga with _$Manga {
  const factory Manga({
    required MangaId id,
    required String name,
    required MangaStartPage startPage,
    required DeltaId ideaMemoDeltaId,
    required MangaStatus status,
  }) = _Manga;
}

@freezed
abstract class MangaPage with _$MangaPage {
  const factory MangaPage({
    required MangaPageId id,
    required MangaId mangaId,
    required DeltaId memoDeltaId,
    required DeltaId stageDirectionDeltaId,
    required DeltaId dialoguesDeltaId,
  }) = _MangaPage;
}
