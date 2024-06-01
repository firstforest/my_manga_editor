import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';

QuillController useQuillController(Delta? initialDelta) {
  return use(_QuillControllerHook(initialDelta));
}

class _QuillControllerHook extends Hook<QuillController> {
  const _QuillControllerHook(this.initialDelta);

  final Delta? initialDelta;

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
    if (hook.initialDelta != null) {
      _controller.document = Document.fromDelta(hook.initialDelta!);
    }
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
