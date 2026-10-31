import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor_data/repository/manga_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'manga_creator.g.dart';

/// 作品の新規作成。状態は持たない。
///
/// 画面は listen せずに notifier を読んで [create] を呼ぶ。autoDispose だと
/// 書き込みを待つ間に破棄されて、続きで ref を使えなくなるので keepAlive にする。
@Riverpod(keepAlive: true)
class MangaCreator extends _$MangaCreator {
  @override
  void build() {}

  /// 作品と最初のページを作り、作品の ID を返す。
  ///
  /// [tags] を渡すとその作品に最初から付いた状態で作られる
  /// (一覧をタグで絞り込んでいる最中の新規作成で使う)。
  Future<MangaId> create({List<String> tags = const []}) async {
    final repository = ref.read(mangaRepositoryProvider);
    final mangaId = await repository.createNewManga(tags: tags);
    await repository.createNewMangaPage(mangaId);
    return mangaId;
  }
}
