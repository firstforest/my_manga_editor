import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/manga/page/manga_select_page.dart';
import 'package:my_manga_editor/feature/manga/provider/tag_providers.dart';
import 'package:my_manga_editor/router.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor_data/repository/manga_repository.dart';

/// 一覧の表示と、新規作成 (作品 → 最初のページ) だけ answer する Fake。
/// 作品の作成を [createGate] で止めておき、書き込みを待つ間の描画を挟めるようにする。
class _FakeMangaRepository extends Fake implements MangaRepository {
  _FakeMangaRepository(this.mangaList);

  final List<Manga> mangaList;
  final createGate = Completer<void>();
  final createdTags = <List<String>>[];
  final createdPagesFor = <MangaId>[];

  @override
  Stream<List<Manga>> watchAllMangaList() => Stream.value(mangaList);

  @override
  Stream<Delta?> getDeltaStream(MangaId mangaId, DeltaId deltaId) =>
      Stream.value(Delta());

  @override
  Stream<List<MangaPageId>> watchAllMangaPageIdList(MangaId mangaId) =>
      Stream.value(const []);

  @override
  Future<MangaId> createNewManga({
    String name = '無名の傑作',
    List<String> tags = const [],
  }) async {
    createdTags.add(tags);
    await createGate.future;
    return MangaId('new');
  }

  @override
  Future<String> createNewMangaPage(MangaId mangaId) async {
    createdPagesFor.add(mangaId);
    return 'pid';
  }
}

Manga _manga({required String id, List<String> tags = const []}) => Manga(
      id: MangaId(id),
      name: '作品$id',
      startPage: MangaStartPage.left,
      ideaMemoDeltaId: DeltaId('idea-$id'),
      status: MangaStatus.idea,
      tags: tags,
    );

Future<void> _pumpSelectPage(
  WidgetTester tester,
  _FakeMangaRepository repository,
) async {
  final router = GoRouter(
    initialLocation: '/manga',
    routes: [
      GoRoute(
        path: '/manga',
        builder: (context, state) => const MangaSelectPage(),
      ),
      GoRoute(
        path: '/manga/:mangaId',
        builder: (context, state) =>
            Text('opened ${state.pathParameters['mangaId']}'),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mangaRepositoryProvider.overrideWithValue(repository),
        routerProvider.overrideWithValue(router),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('新規作成は作品と最初のページを作り、書き込みが終わったら作品の画面へ移る', (tester) async {
    final repository = _FakeMangaRepository(const []);
    await _pumpSelectPage(tester, repository);

    await tester.tap(find.byTooltip('新規作成'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    repository.createGate.complete();
    await tester.pumpAndSettle();

    expect(repository.createdTags, [const <String>[]]);
    expect(repository.createdPagesFor, [MangaId('new')]);
    expect(find.text('opened new'), findsOneWidget);
  });

  testWidgets('タグで絞り込んでいる最中の新規作成は、そのタグを付けて作る', (tester) async {
    final repository = _FakeMangaRepository([
      _manga(id: '1', tags: const ['商業']),
    ]);
    await _pumpSelectPage(tester, repository);

    ProviderScope.containerOf(tester.element(find.byType(MangaSelectPage)))
        .read(tagFilterProvider.notifier)
        .select(const TagFilter.tag('商業'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('新規作成'));
    await tester.pump();
    repository.createGate.complete();
    await tester.pumpAndSettle();

    expect(repository.createdTags, [
      const ['商業'],
    ]);
    expect(find.text('opened new'), findsOneWidget);
  });
}
