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

@freezed
class Manga with _$Manga {
  const factory Manga({
    required String name,
    required MangaStartPage startPage,
    required List<MangaPage> pages,
  }) = _Manga;

  factory Manga.fromJson(Map<String, dynamic> json) => _$MangaFromJson(json);
}

@freezed
class MangaPage with _$MangaPage {
  const factory MangaPage({
    required int id,
    required String? memoDelta,
    required String? dialoguesDelta,
  }) = _MangaPage;

  factory MangaPage.fromJson(Map<String, dynamic> json) =>
      _$MangaPageFromJson(json);
}
