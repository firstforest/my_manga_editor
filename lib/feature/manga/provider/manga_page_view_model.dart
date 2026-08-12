import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor_data/repository/manga_repository.dart';
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

  /// 新しい作品を作る。
  ///
  /// [tags] を渡すとその作品に最初から付いた状態で作られる
  /// (一覧をタグで絞り込んでいる最中の新規作成で使う)。
  Future<MangaId> createNewManga({List<String> tags = const []}) async {
    final mangaRepository = ref.read(mangaRepositoryProvider);
    final selectedId = await mangaRepository.createNewManga(tags: tags);
    await mangaRepository.createNewMangaPage(selectedId);

    selectManga(selectedId);
    return selectedId;
  }
}
