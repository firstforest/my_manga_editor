import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/manga/view/kanban_card.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor_data/repository/manga_repository.dart';

Manga _manga(List<String> tags) => Manga(
      id: MangaId('1'),
      name: '作品',
      startPage: MangaStartPage.left,
      ideaMemoDeltaId: DeltaId('idea-1'),
      status: MangaStatus.idea,
      tags: tags,
    );

/// カードはアイデアメモ Delta とページ一覧を読むので、その 2 つだけ answer する Fake。
class _FakeMangaRepository extends Fake implements MangaRepository {
  @override
  Stream<Delta?> getDeltaStream(MangaId mangaId, DeltaId deltaId) =>
      Stream.value(Delta());

  @override
  Stream<List<MangaPageId>> watchAllMangaPageIdList(MangaId mangaId) =>
      Stream.value(const []);
}

Future<void> _pumpCard(WidgetTester tester, List<String> tags) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mangaRepositoryProvider.overrideWithValue(_FakeMangaRepository()),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(width: 280, child: KanbanCard(manga: _manga(tags))),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('タグが無いときはタグ行を出さない', (tester) async {
    await _pumpCard(tester, const []);

    expect(find.textContaining('+'), findsNothing);
    expect(find.text('ページ数: 0'), findsOneWidget);
  });

  testWidgets('タグが 3 個までは全部表示する', (tester) async {
    await _pumpCard(tester, ['連載:ヒーロー', '商業', '没ネタ']);

    expect(find.text('連載:ヒーロー'), findsOneWidget);
    expect(find.text('商業'), findsOneWidget);
    expect(find.text('没ネタ'), findsOneWidget);
    expect(find.textContaining('+'), findsNothing);
  });

  testWidgets('タグが 4 個以上なら先頭 3 個 + 残り件数を出す', (tester) async {
    await _pumpCard(tester, ['t1', 't2', 't3', 't4', 't5']);

    expect(find.text('t1'), findsOneWidget);
    expect(find.text('t2'), findsOneWidget);
    expect(find.text('t3'), findsOneWidget);
    expect(find.text('t4'), findsNothing);
    expect(find.text('+2'), findsOneWidget);
  });
}
