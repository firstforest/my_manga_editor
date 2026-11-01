import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_manga_editor/widgets/quill_text_field_semantics.dart';

/// Flutter Web のセマンティクス有効時にキー入力を受け取るための条件
/// （テキスト欄・複数行・有効・フォーカス状態・フォーカス操作、内側にフォーカスを奪うノードが無いこと）を、
/// 実際の QuillEditor を包んで確かめる。
/// Web エンジン側でキー入力が届くことはウィジェットテストでは確かめられないので、
/// プレビューの dev ビルドで手で確認する。
void main() {
  late FocusNode focusNode;
  late QuillController controller;

  setUp(() {
    focusNode = FocusNode();
    controller = QuillController.basic();
  });
  tearDown(() {
    controller.dispose();
    focusNode.dispose();
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates:
            FlutterQuillLocalizations.localizationsDelegates,
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 200,
            child: QuillTextFieldSemantics(
              controller: controller,
              focusNode: focusNode,
              label: 'セリフ',
              child: QuillEditor.basic(
                controller: controller,
                focusNode: focusNode,
                config: const QuillEditorConfig(placeholder: 'セリフ'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  SemanticsNode fieldNode(WidgetTester tester) =>
      tester.getSemantics(find.bySemanticsLabel('セリフ'));

  testWidgets('複数行のテキスト欄として名乗り、内側にフォーカスを奪うノードを持たない', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester);

    expect(
      fieldNode(tester),
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
    expect(fieldNode(tester).childrenCount, 0);

    handle.dispose();
  });

  testWidgets('フォーカス状態と本文を伝える', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester);

    focusNode.requestFocus();
    controller.document.insert(0, 'こんにちは');
    await tester.pumpAndSettle();

    expect(fieldNode(tester), isSemantics(isFocused: true, value: 'こんにちは'));
    expect(fieldNode(tester).childrenCount, 0);

    handle.dispose();
  });

  testWidgets('セマンティクスからのフォーカス・タップで欄にフォーカスが移る', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester);
    final node = fieldNode(tester);

    node.owner!.performAction(node.id, SemanticsAction.focus);
    await tester.pumpAndSettle();
    expect(focusNode.hasFocus, isTrue);

    focusNode.unfocus();
    await tester.pumpAndSettle();
    node.owner!.performAction(node.id, SemanticsAction.tap);
    await tester.pumpAndSettle();
    expect(focusNode.hasFocus, isTrue);

    handle.dispose();
  });
}
