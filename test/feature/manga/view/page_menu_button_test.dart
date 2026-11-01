import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_manga_editor/feature/manga/view/page_menu_button.dart';

/// ページの「︙」メニューだけを置いた画面で、項目の有効・無効と選んだときの呼び出しを確かめる。
/// MangaPageWidget への組み込み（ゴミ箱アイコンが無いこと）は Quill を含み重いので手動で確認する。
void main() {
  late List<int> moved;
  late int deleted;

  setUp(() {
    moved = [];
    deleted = 0;
  });

  Widget host({required int pageIndex, required int pageCount}) {
    return ScreenUtilInit(
      child: MaterialApp(
        home: Scaffold(
          body: PageMenuButton(
            pageIndex: pageIndex,
            pageCount: pageCount,
            onMovePage: moved.add,
            onDelete: () => deleted++,
          ),
        ),
      ),
    );
  }

  bool isEnabled(WidgetTester tester, String label) {
    final item = tester.widget<PopupMenuItem<PageAction>>(
      find.ancestor(
        of: find.text(label),
        matching: find.byType(PopupMenuItem<PageAction>),
      ),
    );
    return item.enabled;
  }

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byTooltip('ページの操作'));
    await tester.pumpAndSettle();
  }

  testWidgets('先頭のページでは「前のページへ移動」が無効', (tester) async {
    await tester.pumpWidget(host(pageIndex: 1, pageCount: 3));
    await openMenu(tester);

    expect(isEnabled(tester, '前のページへ移動'), isFalse);
    expect(isEnabled(tester, '次のページへ移動'), isTrue);
  });

  testWidgets('末尾のページでは「次のページへ移動」が無効', (tester) async {
    await tester.pumpWidget(host(pageIndex: 3, pageCount: 3));
    await openMenu(tester);

    expect(isEnabled(tester, '前のページへ移動'), isTrue);
    expect(isEnabled(tester, '次のページへ移動'), isFalse);
  });

  testWidgets('ページが 1 つだけなら前後どちらにも動かせない', (tester) async {
    await tester.pumpWidget(host(pageIndex: 1, pageCount: 1));
    await openMenu(tester);

    expect(isEnabled(tester, '前のページへ移動'), isFalse);
    expect(isEnabled(tester, '次のページへ移動'), isFalse);
  });

  testWidgets('選んだ項目に応じて移動量と削除を伝える', (tester) async {
    await tester.pumpWidget(host(pageIndex: 2, pageCount: 3));

    await openMenu(tester);
    await tester.tap(find.text('前のページへ移動'));
    await tester.pumpAndSettle();
    await openMenu(tester);
    await tester.tap(find.text('次のページへ移動'));
    await tester.pumpAndSettle();
    await openMenu(tester);
    await tester.tap(find.text('ページを削除'));
    await tester.pumpAndSettle();

    expect(moved, [-1, 1]);
    expect(deleted, 1);
  });
}
