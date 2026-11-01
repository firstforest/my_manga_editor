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
  _FakeMangaRepository(this.memo);

  final Delta memo;

  @override
  Stream<Delta?> getDeltaStream(MangaId mangaId, DeltaId deltaId) =>
      Stream.value(memo);

  @override
  Stream<List<MangaPageId>> watchAllMangaPageIdList(MangaId mangaId) =>
      Stream.value(const []);
}

Future<void> _pumpCard(
  WidgetTester tester,
  List<String> tags, {
  String memo = '',
}) async {
  final memoDelta = memo.isEmpty ? Delta() : (Delta()..insert('$memo\n'));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mangaRepositoryProvider
            .overrideWithValue(_FakeMangaRepository(memoDelta)),
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

  group('スクリーンリーダー', () {
    // SemanticsHandle は addTearDown より前に行われる終了時の検査で
    // 破棄済みであることを求められるので、try / finally で破棄する
    testWidgets('カードは作品名をラベル、ページ数とタグを値にしたボタンとして伝わる', (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await _pumpCard(tester, ['商業', '没ネタ'], memo: 'メモの本文');

        final card = find.bySemanticsLabel('作品');
        expect(card, findsOneWidget);
        expect(
          tester.getSemantics(card),
          isSemantics(
            label: '作品',
            value: 'ページ数: 0、タグ: 商業、没ネタ',
            isButton: true,
            hasTapAction: true,
          ),
        );
        expect(find.bySemanticsLabel(RegExp('メモの本文')), findsNothing);
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('削除ボタンはカード本体のボタンの外にある別のボタンとして伝わる', (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await _pumpCard(tester, const []);

        final cardNode = tester.getSemantics(find.bySemanticsLabel('作品'));
        final deleteNode = tester.getSemantics(find.byTooltip('作品を削除'));
        expect(
          deleteNode,
          isSemantics(tooltip: '作品を削除', isButton: true, hasTapAction: true),
        );

        var ancestor = deleteNode.parent;
        while (ancestor != null) {
          expect(ancestor.id, isNot(cardNode.id));
          ancestor = ancestor.parent;
        }
      } finally {
        semantics.dispose();
      }
    });
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
