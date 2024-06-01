import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_manga_editor/models/manga.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'manga_page_view_model.freezed.dart';
part 'manga_page_view_model.g.dart';

@freezed
class MangaPageViewModel with _$MangaPageViewModel {
  const factory MangaPageViewModel({
    required Manga manga,
  }) = _MangaPageViewModel;
}

@riverpod
class MangaPageViewModelNotifier extends _$MangaPageViewModelNotifier {
  @override
  FutureOr<MangaPageViewModel> build() async {
    return MangaPageViewModel(
      manga: Manga(
        name: 'test',
        startPage: MangaStartPage.left,
        pages: [1, 2, 3]
            .map(
              (i) => MangaPage(
                id: i,
                memo: 'memo $i',
                dialogues: 'dialogues',
              ),
            )
            .toList(),
      ),
    );
  }

  void reorderPage(int oldIndex, int newIndex) {
    state.whenOrNull(data: (data) {
      final pages = List<MangaPage>.from(data.manga.pages);
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = pages.removeAt(oldIndex);
      pages.insert(newIndex, item);
      state = AsyncValue.data(data.copyWith.manga(pages: pages));
    });
  }
}
