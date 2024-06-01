import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_manga_editor/logger.dart';
import 'package:my_manga_editor/models/manga.dart';
import 'package:my_manga_editor/repositories/manga_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'manga_page_view_model.freezed.dart';
part 'manga_page_view_model.g.dart';

@freezed
class MangaPageViewModel with _$MangaPageViewModel {
  const factory MangaPageViewModel({
    required String uuid,
    required Manga manga,
  }) = _MangaPageViewModel;
}

@riverpod
class MangaPageViewModelNotifier extends _$MangaPageViewModelNotifier {
  @override
  FutureOr<MangaPageViewModel> build() async {
    return MangaPageViewModel(
      uuid: const Uuid().v4(),
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

  Future<void> saveManga() async {
    await state.whenOrNull(data: (data) {
      return ref.read(mangaRepositoryProvider).saveManga(data.manga);
    });
  }

  Future<void> loadManga() async {
    final manga = await ref.read(mangaRepositoryProvider).loadManga();
    if (manga != null) {
      state = AsyncValue.data(
          MangaPageViewModel(uuid: const Uuid().v4(), manga: manga));
    }
  }

  Future<void> updateMemo(int id, String value) async {
    logger.d('updateMemo: $id, $value');
    state.whenOrNull(data: (data) {
      final pages = data.manga.pages.map((page) {
        if (page.id == id) {
          return page.copyWith(memo: value);
        }
        return page;
      }).toList();
      state = AsyncValue.data(data.copyWith.manga(pages: pages));
    });
  }

  Future<void> updateDialogue(int id, String value) async {
    logger.d('updateDialogue: $id, $value');
    state.whenOrNull(data: (data) {
      final pages = data.manga.pages.map((page) {
        if (page.id == id) {
          return page.copyWith(dialogues: value);
        }
        return page;
      }).toList();
      state = AsyncValue.data(data.copyWith.manga(pages: pages));
    });
  }
}