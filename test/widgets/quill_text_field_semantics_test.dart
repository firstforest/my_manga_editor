import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_manga_editor/widgets/quill_text_field_semantics.dart';

/// Flutter Web のセマンティクス有効時にキー入力を受け取るための条件
/// （テキスト欄・複数行・有効・フォーカス状態・フォーカス操作）が付いていることを確かめる。
/// Web エンジン側でキー入力が届くことはウィジェットテストでは確かめられないので、
/// プレビューの dev ビルドで手で確認する。
void main() {
  late FocusNode focusNode;

  setUp(() {
    focusNode = FocusNode();
  });
  tearDown(() => focusNode.dispose());

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuillTextFieldSemantics(
            focusNode: focusNode,
            label: 'セリフ',
            child: Focus(
              focusNode: focusNode,
              child: const SizedBox(width: 200, height: 100),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('複数行のテキスト欄として名乗り、フォーカス状態を伝える', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester);

    final finder = find.bySemanticsLabel('セリフ');
    expect(
      tester.getSemantics(finder),
      matchesSemantics(
        label: 'セリフ',
        isTextField: true,
        isMultiline: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasFocusAction: true,
        hasTapAction: true,
      ),
    );

    focusNode.requestFocus();
    await tester.pump();
    expect(tester.getSemantics(finder), isSemantics(isFocused: true));

    handle.dispose();
  });

  testWidgets('セマンティクスからのフォーカス・タップで欄にフォーカスが移る', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester);
    final node = tester.getSemantics(find.bySemanticsLabel('セリフ'));

    node.owner!.performAction(node.id, SemanticsAction.focus);
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    focusNode.unfocus();
    await tester.pump();
    node.owner!.performAction(node.id, SemanticsAction.tap);
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    handle.dispose();
  });
}
