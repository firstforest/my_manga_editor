import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_providers.dart';
import 'package:my_manga_editor/feature/manga/view/manga_tags_widget.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor_data/repository/exceptions.dart';
import 'package:my_manga_editor_data/repository/manga_repository.dart';

Manga _manga(String id, {List<String> tags = const []}) => Manga(
      id: MangaId(id),
      name: '作品$id',
      startPage: MangaStartPage.left,
      ideaMemoDeltaId: DeltaId('idea-$id'),
      status: MangaStatus.idea,
      tags: tags,
    );

/// MangaRepository の自動 Mock は extension type (MangaId) の fallback で
/// 詰まるため、タグ操作だけを実装した手書き Fake を使う
/// (delta_notifier_export_test.dart と同じ方針)。
class _FakeMangaRepository extends Fake implements MangaRepository {
  final added = <String>[];
  final removed = <String>[];
  Exception? throwOnAdd;

  @override
  Future<void> addTag(MangaId id, String tag) async {
    if (throwOnAdd != null) throw throwOnAdd!;
    added.add(tag);
  }

  @override
  Future<void> removeTag(MangaId id, String tag) async {
    removed.add(tag);
  }
}

Future<_FakeMangaRepository> _pumpWidget(
  WidgetTester tester,
  Manga manga, {
  List<Manga> allManga = const [],
}) async {
  final repository = _FakeMangaRepository();
  final controller = StreamController<List<Manga>>();
  // 誰も購読していない controller の close() は完了しないので await しない。
  // (タグ候補は入力欄を開いたときだけ購読されるため、購読者がいないことがある)
  addTearDown(() => unawaited(controller.close()));
  controller.add(allManga.isEmpty ? [manga] : allManga);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mangaRepositoryProvider.overrideWithValue(repository),
        allMangaListProvider.overrideWith((ref) => controller.stream),
      ],
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: SizedBox(height: 60, child: MangaTagsWidget(manga: manga)),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repository;
}

void main() {
  testWidgets('付いているタグをチップで表示する', (tester) async {
    await _pumpWidget(tester, _manga('1', tags: ['連載:ヒーロー', '商業']));

    expect(find.widgetWithText(Chip, '連載:ヒーロー'), findsOneWidget);
    expect(find.widgetWithText(Chip, '商業'), findsOneWidget);
  });

  testWidgets('タグが無ければ「＋タグ」だけを出す', (tester) async {
    await _pumpWidget(tester, _manga('1'));

    expect(find.byType(Chip), findsNothing);
    expect(find.widgetWithText(ActionChip, 'タグ'), findsOneWidget);
  });

  testWidgets('× を押すとそのタグだけが外れる', (tester) async {
    final repository =
        await _pumpWidget(tester, _manga('1', tags: ['連載:ヒーロー', '商業']));

    await tester.tap(find.byTooltip('商業 を外す'));
    await tester.pumpAndSettle();

    expect(repository.removed, ['商業']);
  });

  testWidgets('入力して確定するとタグが追加される', (tester) async {
    final repository = await _pumpWidget(tester, _manga('1'));

    await tester.tap(find.widgetWithText(ActionChip, 'タグ'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '没ネタ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(repository.added, ['没ネタ']);
  });

  testWidgets('空文字で確定しても何も追加しない', (tester) async {
    final repository = await _pumpWidget(tester, _manga('1'));

    await tester.tap(find.widgetWithText(ActionChip, 'タグ'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '   ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(repository.added, isEmpty);
  });

  testWidgets('入力途中で既存のタグが候補に出る', (tester) async {
    await _pumpWidget(
      tester,
      _manga('1'),
      allManga: [
        _manga('1'),
        _manga('2', tags: ['連載:ヒーロー']),
        _manga('3', tags: ['商業']),
      ],
    );

    await tester.tap(find.widgetWithText(ActionChip, 'タグ'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '連載');
    await tester.pumpAndSettle();

    expect(find.text('連載:ヒーロー'), findsOneWidget);
    expect(find.text('商業'), findsNothing);
  });

  testWidgets('既に自分に付いているタグは候補に出さない', (tester) async {
    await _pumpWidget(
      tester,
      _manga('1', tags: ['商業']),
      allManga: [
        _manga('1', tags: ['商業']),
        _manga('2', tags: ['商業', '連載:ヒーロー']),
      ],
    );

    await tester.tap(find.widgetWithText(ActionChip, 'タグ'));
    await tester.pumpAndSettle();

    // 既に付いている '商業' は候補に出ないので、画面上の '商業' はチップの 1 つだけ
    await tester.enterText(find.byType(TextField), '商');
    await tester.pumpAndSettle();
    expect(find.text('商業'), findsOneWidget);
    expect(find.widgetWithText(Chip, '商業'), findsOneWidget);

    // 付いていないタグは候補に出る
    await tester.enterText(find.byType(TextField), '連載');
    await tester.pumpAndSettle();
    expect(find.text('連載:ヒーロー'), findsOneWidget);
  });

  testWidgets('文字数超過は SnackBar で知らせ、タグは増えない', (tester) async {
    final repository = await _pumpWidget(tester, _manga('1'));
    repository.throwOnAdd = ValidationException('Tag must be 1-30 characters');

    await tester.tap(find.widgetWithText(ActionChip, 'タグ'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'あ' * 31);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('タグは30文字以内で入力してください'), findsOneWidget);
    expect(repository.added, isEmpty);
  });

  testWidgets('個数超過は専用の SnackBar で知らせる', (tester) async {
    final repository = await _pumpWidget(tester, _manga('1'));
    repository.throwOnAdd = ValidationException('Too many tags (max 20)');

    await tester.tap(find.widgetWithText(ActionChip, 'タグ'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '21個目');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('タグは1作品につき20個までです'), findsOneWidget);
  });

  testWidgets('保存に失敗したら SnackBar で知らせる', (tester) async {
    final repository = await _pumpWidget(tester, _manga('1'));
    repository.throwOnAdd = StorageException('boom');

    await tester.tap(find.widgetWithText(ActionChip, 'タグ'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '商業');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('タグの保存に失敗しました'), findsOneWidget);
  });
}
