import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/manga/view/manga_page_list.dart';
import 'package:my_manga_editor/feature/manga/view/scene_unit_drag.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor_data/repository/manga_repository.dart';

final _mangaId = MangaId('mid');
final _p1 = MangaPageId('p1');
final _p2 = MangaPageId('p2');

typedef _Move = ({
  MangaPageId from,
  int fromIndex,
  MangaPageId to,
  int toIndex,
});

// 使うメソッド: watchAllMangaPageIdList / getMangaPageStream / getMangaStream /
// getDeltaStream / moveSceneUnit / reorderPages
class _FakeMangaRepository extends Fake implements MangaRepository {
  _FakeMangaRepository({required this.pages, this.deltas = const {}});

  final List<MangaPage> pages;
  final Map<String, Delta> deltas;
  final moves = <_Move>[];
  final reorders = <List<MangaPageId>>[];

  @override
  Stream<List<MangaPageId>> watchAllMangaPageIdList(MangaId mangaId) =>
      Stream.value(pages.map((p) => p.id).toList());

  @override
  Stream<MangaPage?> getMangaPageStream(MangaPageId pageId) =>
      Stream.value(pages.firstWhere((p) => p.id == pageId));

  @override
  Stream<Manga?> getMangaStream(MangaId mangaId) => Stream.value(_manga);

  @override
  Stream<Delta?> getDeltaStream(MangaId mangaId, DeltaId deltaId) =>
      Stream.value(deltas[deltaId.id]);

  @override
  Future<bool> moveSceneUnit({
    required MangaId mangaId,
    required MangaPageId fromPageId,
    required int fromIndex,
    required MangaPageId toPageId,
    required int toIndex,
  }) async {
    moves.add((
      from: fromPageId,
      fromIndex: fromIndex,
      to: toPageId,
      toIndex: toIndex,
    ));
    return false;
  }

  @override
  Future<void> reorderPages(
      MangaId mangaId, List<MangaPageId> pageIdList) async {
    reorders.add(pageIdList);
  }
}

final _manga = Manga(
  id: _mangaId,
  name: 'test',
  startPage: MangaStartPage.left,
  ideaMemoDeltaId: DeltaId('idea'),
  status: MangaStatus.idea,
);

MangaPage _page(MangaPageId id, List<String> units) => MangaPage(
      id: id,
      mangaId: _mangaId,
      memoDeltaId: DeltaId('${id.id}-memo'),
      sceneUnits: [
        for (final u in units)
          SceneUnit(
            dialoguesDeltaId: DeltaId('$u-d'),
            stageDirectionDeltaId: DeltaId('$u-s'),
          ),
      ],
    );

/// 実際の編集画面のページリストを、デスクトップ幅のレイアウトになる広さで表示する。
/// Firestore への保存は検証しない（Repository は呼び出しを記録するだけの Fake）。
Future<ScrollController> _pump(
    WidgetTester tester, _FakeMangaRepository repository) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final scrollController = ScrollController();
  addTearDown(scrollController.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [mangaRepositoryProvider.overrideWithValue(repository)],
      child: ScreenUtilInit(
        designSize: const Size(1200, 2400),
        child: MaterialApp(
          localizationsDelegates:
              FlutterQuillLocalizations.localizationsDelegates,
          home: Scaffold(
            body: MangaPageList(
              manga: _manga,
              scrollController: scrollController,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return scrollController;
}

Finder _handle(int i) => find.byIcon(Icons.drag_indicator).at(i);
Finder _cut(int i) => find.byType(SceneUnitDropTarget).at(i);

/// [handle] をつかんで [target] の上半分 / 下半分で離す
Future<void> _drag(WidgetTester tester, Finder handle, Finder target,
    {required bool lowerHalf}) async {
  final rect = tester.getRect(target);
  final to = Offset(rect.center.dx,
      lowerHalf ? rect.bottom - rect.height / 4 : rect.top + rect.height / 4);
  final gesture = await tester.startGesture(tester.getCenter(handle),
      kind: PointerDeviceKind.mouse);
  for (var i = 1; i <= 10; i++) {
    final from = tester.getCenter(handle);
    await gesture.moveTo(Offset.lerp(from, to, i / 10)!);
    await tester.pump(const Duration(milliseconds: 16));
  }
  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('同じページ内で、先頭のカットを 2 番目のカットの下へ移す', (tester) async {
    final repository = _FakeMangaRepository(pages: [
      _page(_p1, ['a', 'b']),
      _page(_p2, ['x'])
    ]);
    await _pump(tester, repository);

    await _drag(tester, _handle(0), _cut(1), lowerHalf: true);

    expect(repository.moves, [
      (from: _p1, fromIndex: 0, to: _p1, toIndex: 2),
    ]);
  });

  testWidgets('別のページのカットの下へ移す', (tester) async {
    final repository = _FakeMangaRepository(pages: [
      _page(_p1, ['a', 'b']),
      _page(_p2, ['x'])
    ]);
    await _pump(tester, repository);

    await _drag(tester, _handle(1), _cut(2), lowerHalf: true);

    expect(repository.moves, [
      (from: _p1, fromIndex: 1, to: _p2, toIndex: 1),
    ]);
  });

  testWidgets('元の位置のすぐ前後に落としても移動しない', (tester) async {
    final repository = _FakeMangaRepository(pages: [
      _page(_p1, ['a', 'b']),
      _page(_p2, ['x'])
    ]);
    await _pump(tester, repository);

    await _drag(tester, _handle(0), _cut(1), lowerHalf: false);

    expect(repository.moves, isEmpty);
  });

  testWidgets('メモのあるページの最後のカットを移すときは確認し、キャンセルなら移さない', (tester) async {
    final repository = _FakeMangaRepository(
      pages: [
        _page(_p1, ['a', 'b']),
        _page(_p2, ['x'])
      ],
      deltas: {'p2-memo': Delta()..insert('描きたいこと\n')},
    );
    await _pump(tester, repository);

    await _drag(tester, _handle(2), _cut(0), lowerHalf: false);
    expect(find.text('ページ 2 を削除します。このページのメモも削除されます'), findsOneWidget);
    await tester.tap(find.text('キャンセル'));
    await tester.pumpAndSettle();
    expect(repository.moves, isEmpty);

    await _drag(tester, _handle(2), _cut(0), lowerHalf: false);
    await tester.tap(find.text('移動して削除'));
    await tester.pumpAndSettle();
    expect(repository.moves, [
      (from: _p2, fromIndex: 0, to: _p1, toIndex: 0),
    ]);
  });

  testWidgets('メモが空なら最後のカットでも確認せずに移す', (tester) async {
    final repository = _FakeMangaRepository(pages: [
      _page(_p1, ['a', 'b']),
      _page(_p2, ['x'])
    ]);
    await _pump(tester, repository);

    await _drag(tester, _handle(2), _cut(0), lowerHalf: false);

    expect(find.byType(AlertDialog), findsNothing);
    expect(repository.moves, [
      (from: _p2, fromIndex: 0, to: _p1, toIndex: 0),
    ]);
  });

  testWidgets('ページの「︙」メニューから次のページへ移し、ゴミ箱アイコンは無い', (tester) async {
    final repository = _FakeMangaRepository(pages: [
      _page(_p1, ['a']),
      _page(_p2, ['x'])
    ]);
    await _pump(tester, repository);

    expect(find.byIcon(Icons.delete), findsNothing);
    await tester.tap(find.byTooltip('ページの操作').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('次のページへ移動'));
    await tester.pumpAndSettle();

    expect(repository.reorders, [
      [_p2, _p1],
    ]);
  });

  testWidgets('カットをドラッグしたままリストの下端に近づけると自動でスクロールし、離すと止まる',
      (tester) async {
    final repository = _FakeMangaRepository(pages: [
      for (var i = 0; i < 8; i++) _page(MangaPageId('p$i'), ['u$i']),
    ]);
    final scrollController = await _pump(tester, repository);
    expect(scrollController.offset, 0);

    final gesture = await tester.startGesture(tester.getCenter(_handle(0)),
        kind: PointerDeviceKind.mouse);
    await gesture.moveBy(const Offset(0, 20));
    await tester.pump();
    await gesture.moveTo(const Offset(600, 2390));
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    final scrolled = scrollController.offset;
    expect(scrolled, greaterThan(0));

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 500));
    expect(scrollController.offset, scrolled);
  });
}
