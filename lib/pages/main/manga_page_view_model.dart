import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_manga_editor/models/manga.dart';
import 'package:my_manga_editor/repositories/manga_providers.dart';
import 'package:my_manga_editor/repositories/manga_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'manga_page_view_model.freezed.dart';
part 'manga_page_view_model.g.dart';

@freezed
class MangaPageViewModel with _$MangaPageViewModel {
  const factory MangaPageViewModel({
    required Manga? manga,
  }) = _MangaPageViewModel;
}

@riverpod
class MangaPageViewModelNotifier extends _$MangaPageViewModelNotifier {
  MangaId? selectedMangaId;

  @override
  FutureOr<MangaPageViewModel> build() async {
    final mangaId = selectedMangaId;
    if (mangaId == null) {
      return MangaPageViewModel(manga: null);
    }
    return MangaPageViewModel(
        manga: ref.watch(mangaNotifierProvider(mangaId)).valueOrNull);
  }

  void selectManga(MangaId mangaId) {
    selectedMangaId = mangaId;
    state = AsyncValue.data(
      MangaPageViewModel(
          manga: ref.watch(mangaNotifierProvider(mangaId)).valueOrNull),
    );
  }

  Future<void> clearData() async {
    await ref.read(mangaRepositoryProvider).clearData();
  }

  Future<void> createNewManga() async {
    final mangaRepository = ref.read(mangaRepositoryProvider);
    final selectedId = await mangaRepository.createNewManga();

    for (int i = 0; i < 4; i++) {
      await mangaRepository.createNewMangaPage(selectedId);
    }

    selectManga(selectedId);
  }
}
