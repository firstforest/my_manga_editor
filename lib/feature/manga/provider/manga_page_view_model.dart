import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_manga_editor/feature/manga/model/manga.dart';
import 'package:my_manga_editor/feature/manga/repository/manga_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'manga_page_view_model.freezed.dart';
part 'manga_page_view_model.g.dart';

@freezed
abstract class MangaPageViewModel with _$MangaPageViewModel {
  const factory MangaPageViewModel({required MangaId? mangaId}) =
      _MangaPageViewModel;
}

@riverpod
class MangaPageViewModelNotifier extends _$MangaPageViewModelNotifier {
  @override
  FutureOr<MangaPageViewModel> build() async {
    return MangaPageViewModel(mangaId: null);
  }

  void selectManga(MangaId mangaId) {
    state = AsyncValue.data(MangaPageViewModel(mangaId: mangaId));
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
