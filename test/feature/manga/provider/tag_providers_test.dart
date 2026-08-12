import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_providers.dart';
import 'package:my_manga_editor/feature/manga/provider/tag_providers.dart';
import 'package:my_manga_editor_data/model/manga.dart';

Manga _manga(String id, {List<String> tags = const []}) => Manga(
      id: MangaId(id),
      name: '作品$id',
      startPage: MangaStartPage.left,
      ideaMemoDeltaId: DeltaId('idea-$id'),
      status: MangaStatus.idea,
      tags: tags,
    );

/// allMangaList を差し替えた ProviderContainer を作る。
/// 一覧を後から流し込めるよう StreamController を返す。
///
/// broadcast ではなく単一購読の controller を使う。broadcast だと
/// provider が購読するより前に add した値が捨てられ、テストが競合する。
({ProviderContainer container, StreamController<List<Manga>> controller})
    _containerWith(List<Manga> initial) {
  final controller = StreamController<List<Manga>>();
  final container = ProviderContainer(
    overrides: [
      allMangaListProvider.overrideWith((ref) => controller.stream),
    ],
  );
  addTearDown(container.dispose);
  addTearDown(controller.close);
  controller.add(initial);
  return (container: container, controller: controller);
}

/// allMangaList (Stream) の最初の値が state に載るまで待つ
Future<void> _settle(ProviderContainer container) async {
  container.listen(allMangaListProvider, (_, __) {});
  await container.read(allMangaListProvider.future);
}

/// Stream に流した値が provider を伝播しきるまで待つ。
/// `allMangaList.future` は最初の値で完了済みなので await しても待てない。
Future<void> _pump() => Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  group('tagList', () {
    test('全作品のタグを平坦化し、重複を除いて昇順に並べる', () async {
      final env = _containerWith([
        _manga('1', tags: ['商業', '連載:ヒーロー']),
        _manga('2', tags: ['連載:ヒーロー', 'あとで読む']),
        _manga('3'),
      ]);
      await _settle(env.container);

      expect(
        env.container.read(tagListProvider),
        ['あとで読む', '商業', '連載:ヒーロー'],
      );
    });

    test('タグが 1 つも無ければ空リストを返す', () async {
      final env = _containerWith([_manga('1'), _manga('2')]);
      await _settle(env.container);

      expect(env.container.read(tagListProvider), isEmpty);
    });

    test('タグと無関係な変更で作品一覧が流れても下流に通知しない', () async {
      final env = _containerWith([
        _manga('1', tags: ['商業']),
        _manga('2'),
      ]);
      await _settle(env.container);

      var notified = 0;
      env.container.listen(tagListProvider, (_, __) => notified++);
      final before = env.container.read(tagListProvider);

      // 作品名の変更やカードの列移動でも作品一覧は emit される
      env.controller.add([
        _manga('1', tags: ['商業']).copyWith(name: '改題した作品'),
        _manga('2').copyWith(status: MangaStatus.inProgress),
      ]);
      await _pump();

      expect(notified, 0);
      expect(identical(env.container.read(tagListProvider), before), isTrue);
    });

    test('タグの顔ぶれが変わったら下流に通知する', () async {
      final env = _containerWith([
        _manga('1', tags: ['商業']),
      ]);
      await _settle(env.container);

      var notified = 0;
      env.container.listen(tagListProvider, (_, __) => notified++);

      env.controller.add([
        _manga('1', tags: ['商業', '連載:ヒーロー']),
      ]);
      await _pump();

      expect(notified, 1);
      expect(env.container.read(tagListProvider), ['商業', '連載:ヒーロー']);
    });
  });

  group('filteredMangaList', () {
    test('すべて: 全作品を返す', () async {
      final env = _containerWith([
        _manga('1', tags: ['商業']),
        _manga('2'),
      ]);
      await _settle(env.container);

      final filtered = env.container.read(filteredMangaListProvider);
      expect(filtered.map((m) => m.id.id), ['1', '2']);
    });

    test('タグなし: タグが 1 つも付いていない作品だけを返す', () async {
      final env = _containerWith([
        _manga('1', tags: ['商業']),
        _manga('2'),
        _manga('3', tags: []),
      ]);
      await _settle(env.container);

      env.container
          .read(tagFilterProvider.notifier)
          .select(const TagFilter.untagged());

      final filtered = env.container.read(filteredMangaListProvider);
      expect(filtered.map((m) => m.id.id), ['2', '3']);
    });

    test('タグ指定: そのタグを持つ作品だけを返す', () async {
      final env = _containerWith([
        _manga('1', tags: ['連載:ヒーロー']),
        _manga('2', tags: ['商業']),
        _manga('3', tags: ['連載:ヒーロー', '商業']),
      ]);
      await _settle(env.container);

      env.container
          .read(tagFilterProvider.notifier)
          .select(const TagFilter.tag('連載:ヒーロー'));

      final filtered = env.container.read(filteredMangaListProvider);
      expect(filtered.map((m) => m.id.id), ['1', '3']);
    });

    test('複数タグを持つ作品は、どのタグで絞ってもヒットする', () async {
      final env = _containerWith([
        _manga('1', tags: ['連載:ヒーロー', '商業']),
      ]);
      await _settle(env.container);

      final notifier = env.container.read(tagFilterProvider.notifier);

      notifier.select(const TagFilter.tag('連載:ヒーロー'));
      expect(env.container.read(filteredMangaListProvider), hasLength(1));

      notifier.select(const TagFilter.tag('商業'));
      expect(env.container.read(filteredMangaListProvider), hasLength(1));
    });
  });

  group('tagFilter の自動復帰', () {
    test('選択中のタグを持つ作品が 0 件になったら「すべて」に戻る', () async {
      final env = _containerWith([
        _manga('1', tags: ['連載:ヒーロー']),
        _manga('2'),
      ]);
      await _settle(env.container);
      // tagList の変化を監視させるため、絞り込み state を購読しておく
      env.container.listen(tagFilterProvider, (_, __) {});
      env.container.listen(tagListProvider, (_, __) {});

      env.container
          .read(tagFilterProvider.notifier)
          .select(const TagFilter.tag('連載:ヒーロー'));
      expect(env.container.read(tagFilterProvider),
          const TagFilter.tag('連載:ヒーロー'));

      // タグの付いた作品が消える (削除された / 他端末でタグが外された)
      env.controller.add([_manga('2')]);
      await _pump();

      expect(env.container.read(tagFilterProvider), const TagFilter.all());
      expect(env.container.read(filteredMangaListProvider), hasLength(1));
    });

    test('別のタグが消えただけなら選択は維持される', () async {
      final env = _containerWith([
        _manga('1', tags: ['連載:ヒーロー']),
        _manga('2', tags: ['没ネタ']),
      ]);
      await _settle(env.container);
      env.container.listen(tagFilterProvider, (_, __) {});
      env.container.listen(tagListProvider, (_, __) {});

      env.container
          .read(tagFilterProvider.notifier)
          .select(const TagFilter.tag('連載:ヒーロー'));

      env.controller.add([_manga('1', tags: ['連載:ヒーロー'])]);
      await _pump();

      expect(env.container.read(tagFilterProvider),
          const TagFilter.tag('連載:ヒーロー'));
    });
  });
}
