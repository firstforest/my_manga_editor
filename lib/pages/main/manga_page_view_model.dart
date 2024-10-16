import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_manga_editor/logger.dart';
import 'package:my_manga_editor/models/manga.dart';
import 'package:my_manga_editor/repositories/manga_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'manga_page_view_model.freezed.dart';
part 'manga_page_view_model.g.dart';

@freezed
class MangaPageViewModel with _$MangaPageViewModel {
  const factory MangaPageViewModel({
    required String fileName,
    required Manga manga,
  }) = _MangaPageViewModel;
}

@riverpod
class MangaPageViewModelNotifier extends _$MangaPageViewModelNotifier {
  @override
  FutureOr<MangaPageViewModel> build(String fileName) async {
    return _createInitialState();
  }

  Future<MangaPageViewModel> _createInitialState() async {
    final loadedViewModel = await loadViewModel();
    return loadedViewModel ??
        MangaPageViewModel(
          fileName: fileName,
          manga: Manga(
            name: '無名の傑作',
            startPage: MangaStartPage.left,
            ideaMemo: null,
            pages: [1, 2, 3]
                .map(
                  (i) => MangaPage(
                    id: i,
                    memoDelta: null,
                    stageDirectionDelta: null,
                    dialoguesDelta: null,
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
      return ref
          .read(mangaRepositoryProvider)
          .saveManga(data.fileName, data.manga);
    });
  }

  Future<MangaPageViewModel?> loadViewModel() async {
    final manga = await ref.read(mangaRepositoryProvider).loadManga(fileName);
    if (manga != null) {
      return MangaPageViewModel(fileName: fileName, manga: manga);
    } else {
      return null;
    }
  }

  Future<void> resetManga() async {
    state = await AsyncValue.guard(_createInitialState);
  }

  Future<void> updateMemo(int id, String value) async {
    logger.d('updateMemo: $id, $value');
    state.whenOrNull(data: (data) {
      final pages = data.manga.pages.map((page) {
        if (page.id == id) {
          return page.copyWith(memoDelta: value);
        }
        return page;
      }).toList();
      state = AsyncValue.data(data.copyWith.manga(pages: pages));
    });
  }

  Future<void> updateStageDirection(int id, String value) async {
    logger.d('updateStageDirection: $id, $value');
    state.whenOrNull(data: (data) {
      final pages = data.manga.pages.map((page) {
        if (page.id == id) {
          return page.copyWith(stageDirectionDelta: value);
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
          return page.copyWith(dialoguesDelta: value);
        }
        return page;
      }).toList();
      state = AsyncValue.data(data.copyWith.manga(pages: pages));
    });
  }

  Future<void> clearData() async {
    await ref.read(mangaRepositoryProvider).clearData();
  }

  Future<void> updateName(String value) async {
    state.whenOrNull(data: (data) {
      state = AsyncValue.data(data.copyWith.manga(name: value));
    });
  }

  Future<void> addPage() async {
    state.whenOrNull(data: (data) {
      final pages = List<MangaPage>.from(data.manga.pages);
      pages.add(
        MangaPage(
          id: pages.length + 1,
          memoDelta: null,
          stageDirectionDelta: null,
          dialoguesDelta: null,
        ),
      );
      state = AsyncValue.data(data.copyWith.manga(pages: pages));
    });
  }

  Future<void> updateIdeaMemo(String value) async {
    state.whenOrNull(data: (data) {
      state = AsyncValue.data(data.copyWith.manga(ideaMemo: value));
    });
  }

  Future<void> deletePage(int id) async {
    state.whenOrNull(data: (data) {
      final pages = data.manga.pages.where((page) => page.id != id).toList();
      state = AsyncValue.data(data.copyWith.manga(pages: pages));
    });
  }
}
