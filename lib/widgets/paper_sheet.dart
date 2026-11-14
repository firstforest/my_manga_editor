import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// 書き込める場所の面。机に置いた紙として、角の立った面に罫線色の細い縁を付ける。
/// 中のエディタが入力中のあいだは差し色の縁を出す。
///
/// 1 枚の紙を欄に区切って使うとき（カットの中のセリフとト書き）は
/// outlined を false にして、縁は外側の紙に任せる。外側の紙は focusOutline を
/// false にして、入力中の縁を中の欄だけに出す
class PaperSheet extends HookWidget {
  const PaperSheet({
    super.key,
    required this.color,
    required this.child,
    this.outlined = true,
    this.focusOutline = true,
  });

  final Color color;
  final bool outlined;
  final bool focusOutline;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final focused = useState(false);
    final scheme = Theme.of(context).colorScheme;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      // 欄のセマンティクスは QuillTextFieldSemantics が出すので、ここでは足さない
      includeSemantics: false,
      onFocusChange: (value) => focused.value = focusOutline && value,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          border: outlined ? Border.all(color: scheme.outlineVariant) : null,
        ),
        foregroundDecoration: BoxDecoration(
          border: focused.value
              ? Border.all(color: scheme.primary, width: 2)
              : null,
        ),
        child: child,
      ),
    );
  }
}
