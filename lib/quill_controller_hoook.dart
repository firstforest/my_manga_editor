import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';

QuillController useQuillController(String text) {
  return use(_QuillControllerHook(text));
}

class _QuillControllerHook extends Hook<QuillController> {
  const _QuillControllerHook(this.text);

  final String text;

  @override
  HookState<QuillController, Hook<QuillController>> createState() =>
      _QuillControllerHookState();
}

class _QuillControllerHookState
    extends HookState<QuillController, _QuillControllerHook> {
  late QuillController _controller;

  @override
  void initHook() {
    super.initHook();
    _controller = QuillController.basic();
    _controller.document = Document.fromHtml(hook.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  QuillController build(BuildContext context) {
    return _controller;
  }
}
