import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:my_manga_editor/logger.dart';

class Workspace extends StatefulHookWidget {
  const Workspace({
    super.key,
    required this.initialText,
    required this.onTextChanged,
  });

  final String? initialText;
  final Function(String value) onTextChanged;

  @override
  State<Workspace> createState() => _WorkspaceState();
}

class _WorkspaceState extends State<Workspace> {
  final _controller = QuillController.basic();

  @override
  void initState() {
    super.initState();
    logger.d('initial text: ${widget.initialText}');
    if (widget.initialText != null) {
      _controller.document =
          Document.fromDelta(Delta.fromJson(json.decode(widget.initialText!)));
    }
    _controller.addListener(() {
      widget
          .onTextChanged(json.encode(_controller.document.toDelta().toJson()));
    });
  }

  @override
  Widget build(BuildContext context) {
    final focusNode = useFocusNode();

    return Column(
      children: [
        QuillToolbar.simple(
          configurations: QuillSimpleToolbarConfigurations(
            controller: _controller,
            showFontFamily: false,
            showFontSize: false,
            showBoldButton: false,
            showItalicButton: false,
            showUnderLineButton: false,
            showStrikeThrough: false,
            showInlineCode: false,
            showSubscript: false,
            showSuperscript: false,
            showColorButton: false,
            showBackgroundColorButton: false,
            showClearFormat: false,
            showHeaderStyle: false,
            showCodeBlock: false,
            showQuote: false,
            showIndent: false,
            showLink: false,
            showClipboardCut: false,
            showClipboardCopy: false,
            showClipboardPaste: false,
          ),
        ),
        Expanded(
          child: QuillEditor.basic(
            focusNode: focusNode,
            configurations: QuillEditorConfigurations(
              controller: _controller,
              padding: const EdgeInsets.all(8.0),
            ),
          ),
        ),
      ],
    );
  }
}
