import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_providers.dart';
import 'package:my_manga_editor/feature/manga/provider/tag_providers.dart';
import 'package:my_manga_editor/feature/manga/view/tag_filter_bar.dart';
import 'package:my_manga_editor_data/model/manga.dart';

Manga _manga(String id, {List<String> tags = const []}) => Manga(
      id: MangaId(id),
      name: '作品$id',
      startPage: MangaStartPage.left,
      ideaMemoDeltaId: DeltaId('idea-$id'),
      status: MangaStatus.idea,
      tags: tags,
    );

/// 絞り込みバーと、絞り込み結果の件数だけを出す最小の画面。
/// カンバン本体は Firestore 依存 (KanbanCard が delta を読む) なので、
/// ここでは filteredMangaList の結果を件数として観測する。
class _Harness extends ConsumerWidget {
  const _Harness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredMangaListProvider);
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            const TagFilterBar(),
            Text('件数: ${filtered.length}'),
            for (final manga in filtered) Text('作品名: ${manga.name}'),
          ],
        ),
      ),
    );
  }
}

Future<void> _pumpHarness(WidgetTester tester, List<Manga> mangaList) async {
  final controller = StreamController<List<Manga>>();
  addTearDown(controller.close);
  controller.add(mangaList);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        allMangaListProvider.overrideWith((ref) => controller.stream),
      ],
      child: const _Harness(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('すべて / タグなし と存在するタグが昇順で並ぶ', (tester) async {
    await _pumpHarness(tester, [
      _manga('1', tags: ['連載:ヒーロー']),
      _manga('2', tags: ['商業']),
      _manga('3'),
    ]);

    expect(find.widgetWithText(ChoiceChip, 'すべて'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'タグなし'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, '商業'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, '連載:ヒーロー'), findsOneWidget);
  });

  testWidgets('タグが 1 つも無ければ すべて / タグなし だけを出す', (tester) async {
    await _pumpHarness(tester, [_manga('1'), _manga('2')]);

    expect(find.byType(ChoiceChip), findsNWidgets(2));
  });

  testWidgets('タグを選ぶとそのタグの作品だけになる', (tester) async {
    await _pumpHarness(tester, [
      _manga('1', tags: ['連載:ヒーロー']),
      _manga('2', tags: ['商業']),
      _manga('3'),
    ]);
    expect(find.text('件数: 3'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, '連載:ヒーロー'));
    await tester.pumpAndSettle();

    expect(find.text('件数: 1'), findsOneWidget);
    expect(find.text('作品名: 作品1'), findsOneWidget);
    expect(find.text('作品名: 作品2'), findsNothing);
  });

  testWidgets('タグなしを選ぶとタグの付いていない作品だけになる', (tester) async {
    await _pumpHarness(tester, [
      _manga('1', tags: ['連載:ヒーロー']),
      _manga('2'),
    ]);

    await tester.tap(find.widgetWithText(ChoiceChip, 'タグなし'));
    await tester.pumpAndSettle();

    expect(find.text('件数: 1'), findsOneWidget);
    expect(find.text('作品名: 作品2'), findsOneWidget);
  });

  testWidgets('すべてを選ぶと絞り込みが解除される', (tester) async {
    await _pumpHarness(tester, [
      _manga('1', tags: ['商業']),
      _manga('2'),
    ]);

    await tester.tap(find.widgetWithText(ChoiceChip, '商業'));
    await tester.pumpAndSettle();
    expect(find.text('件数: 1'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'すべて'));
    await tester.pumpAndSettle();
    expect(find.text('件数: 2'), findsOneWidget);
  });

  testWidgets('選択中のチップをもう一度押しても絞り込みは外れない', (tester) async {
    await _pumpHarness(tester, [
      _manga('1', tags: ['商業']),
      _manga('2'),
    ]);

    await tester.tap(find.widgetWithText(ChoiceChip, '商業'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, '商業'));
    await tester.pumpAndSettle();

    expect(find.text('件数: 1'), findsOneWidget);
  });
}
