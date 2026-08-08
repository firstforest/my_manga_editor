import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_providers.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tag_providers.freezed.dart';
part 'tag_providers.g.dart';

/// 作品一覧の絞り込み条件。
///
/// 「すべて」と「タグなし」という 2 種類の "無い" を `String?` の
/// null / 空文字に押し込むと分岐を読み違えるため union で持つ。
/// 複数タグの同時選択が必要になったら `tags(List<String>)` を足す。
@freezed
sealed class TagFilter with _$TagFilter {
  const factory TagFilter.all() = TagFilterAll;
  const factory TagFilter.untagged() = TagFilterUntagged;
  const factory TagFilter.tag(String name) = TagFilterTag;
}

/// 全作品に付いているタグを平坦化し、重複を除いて昇順に並べたもの。
///
/// タグは独立したエンティティを持たないので、「存在するタグ」はここで導出する。
@riverpod
List<String> tagList(Ref ref) {
  final mangaList = ref.watch(allMangaListProvider).value ?? const <Manga>[];
  final names = <String>{
    for (final manga in mangaList) ...manga.tags,
  }.toList()
    ..sort();
  return names;
}

/// 作品一覧の絞り込み状態。アプリ起動中のみ保持し、永続化しない。
@riverpod
class TagFilterNotifier extends _$TagFilterNotifier {
  @override
  TagFilter build() {
    // 選択中のタグが付いた作品が 0 件になったら、存在しないタグで
    // 空の画面に取り残さないよう「すべて」へ戻す。
    // 同じ判定を UI 側に書かず、状態の正しさはここ 1 箇所に置く。
    ref.listen(tagListProvider, (_, next) {
      final current = state;
      if (current is TagFilterTag && !next.contains(current.name)) {
        state = const TagFilter.all();
      }
    });
    return const TagFilter.all();
  }

  void select(TagFilter filter) {
    state = filter;
  }
}

/// 作品一覧を現在の絞り込み条件で絞ったもの。
///
/// Firestore へ追加のクエリは投げず、購読済みの一覧をクライアント側で filter する。
@riverpod
List<Manga> filteredMangaList(Ref ref) {
  final mangaList = ref.watch(allMangaListProvider).value ?? const <Manga>[];
  final filter = ref.watch(tagFilterProvider);

  return switch (filter) {
    TagFilterAll() => mangaList,
    TagFilterUntagged() => mangaList.where((m) => m.tags.isEmpty).toList(),
    TagFilterTag(:final name) =>
      mangaList.where((m) => m.tags.contains(name)).toList(),
  };
}
