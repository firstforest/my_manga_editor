import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/logger.dart';
import 'package:my_manga_editor/models/manga.dart';
import 'package:my_manga_editor/quill_controller_hook.dart';
import 'package:my_manga_editor/repositories/manga_providers.dart';

class Workspace extends HookConsumerWidget {
  const Workspace({
    super.key,
    required this.deltaId,
  });

  final DeltaId deltaId;

  void _onTextChanged(QuillController controller) {
    final selection = controller.selection;
    final index = selection.baseOffset - 3;
    if (0 <= index) {
      if (controller.document.getPlainText(index, 3) == '\n* ') {
        logger.d('text: ${controller.document.toPlainText()}');
        controller.document.format(selection.baseOffset - 2, 2, Attribute.ul);
        controller.document.delete(selection.baseOffset - 2, 2);
        controller.updateSelection(
          selection.copyWith(baseOffset: selection.baseOffset - 2),
          ChangeSource.silent,
        );
      }
    } else if (index == -1) {
      if (controller.document.getPlainText(0, 2) == '* ') {
        logger.d('text: ${controller.document.toPlainText()}');
        controller.document.format(0, 2, Attribute.ul);
        controller.document.delete(0, 1);
        controller.updateSelection(
          selection.copyWith(baseOffset: 1),
          ChangeSource.silent,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useQuillController(null);
    final focusNode = useFocusNode();

    ref.listen(deltaNotifierProvider(deltaId), (previous, next) {
      if (previous?.hasValue != true && next.hasValue) {
        final initialText = next.requireValue;
        if (initialText != null && initialText.isNotEmpty) {
          controller.document = Document.fromDelta(initialText);
        }
      }
    });

    final onTextChanged = useCallback(() {
      final delta = controller.document.toDelta();
      ref.read(deltaNotifierProvider(deltaId).notifier).updateDelta(delta);
    }, [deltaId]);

    final formatText = useCallback(() {
      _onTextChanged(controller);
    }, [controller]);

    useEffect(() {
      controller.addListener(onTextChanged);
      controller.addListener(formatText);
      return () {
        controller.removeListener(onTextChanged);
        controller.removeListener(formatText);
      };
    }, [deltaId]);

    return Column(
      children: [
        QuillSimpleToolbar(
          controller: controller,
          config: QuillSimpleToolbarConfig(
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
            showRedo: false,
            showUndo: false,
            embedButtons: FlutterQuillEmbeds.toolbarButtons(),
          ),
        ),
        Expanded(
          child: QuillEditor.basic(
            controller: controller,
            focusNode: focusNode,
            config: QuillEditorConfig(
              padding: EdgeInsets.symmetric(vertical: 8.r, horizontal: 16.r),
              placeholder: '何でも書ける場所',
              embedBuilders: kIsWeb
                  ? FlutterQuillEmbeds.editorWebBuilders()
                  : FlutterQuillEmbeds.editorBuilders(),
            ),
          ),
        ),
      ],
    );
  }
}
