import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// QuillEditor をセマンティクス上の「複数行のテキスト欄」として名乗らせる。
///
/// Flutter Web でセマンティクスが有効なとき、キー入力はセマンティクスの
/// テキスト欄（`textField` の付いたノード）にフォーカスがある間だけアプリへ届く。
/// QuillEditor は自分をテキスト欄として名乗らないため、そのままでは
/// カーソルは出ても文字が入らない。
///
/// QuillEditor の内側には、フォーカスを受け取れる別のノード（flutter_quill 内部の Focus）がある。
/// 残すとフォーカス時に Web のテキスト欄とフォーカスを奪い合い、入力が途切れるので、
/// 内側のセマンティクスは外し、このノードだけを独立したテキスト欄にする。
class QuillTextFieldSemantics extends HookWidget {
  const QuillTextFieldSemantics({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.child,
    this.label,
  });

  /// QuillEditor に渡しているのと同じコントローラ。読み上げる本文に使う
  final QuillController controller;

  /// QuillEditor に渡しているのと同じ FocusNode
  final FocusNode focusNode;

  /// 読み上げに使う欄の名前（プレースホルダと同じ文言）
  final String? label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    useListenable(focusNode);
    useListenable(controller);
    return Semantics(
      container: true,
      textField: true,
      multiline: true,
      enabled: true,
      focused: focusNode.hasFocus,
      label: label,
      value: controller.document.toPlainText().trimRight(),
      onFocus: focusNode.requestFocus,
      onTap: focusNode.requestFocus,
      child: ExcludeSemantics(child: child),
    );
  }
}
