import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// QuillEditor をセマンティクス上の「複数行のテキスト欄」として名乗らせる。
///
/// Flutter Web でセマンティクスが有効なとき、キー入力はセマンティクスの
/// テキスト欄（`textField` の付いたノード）にフォーカスがある間だけアプリへ届く。
/// QuillEditor は自分をテキスト欄として名乗らないため、そのままでは
/// カーソルは出ても文字が入らない。標準の TextField（EditableText）が付けているのと
/// 同じ情報をここで補う。
class QuillTextFieldSemantics extends HookWidget {
  const QuillTextFieldSemantics({
    super.key,
    required this.focusNode,
    required this.child,
    this.label,
  });

  /// QuillEditor に渡しているのと同じ FocusNode
  final FocusNode focusNode;

  /// 読み上げに使う欄の名前（プレースホルダと同じ文言）
  final String? label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    useListenable(focusNode);
    return Semantics(
      textField: true,
      multiline: true,
      enabled: true,
      focused: focusNode.hasFocus,
      label: label,
      onFocus: focusNode.requestFocus,
      onTap: focusNode.requestFocus,
      child: child,
    );
  }
}
