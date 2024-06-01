import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/logger.dart';
import 'package:my_manga_editor/models/manga.dart';
import 'package:my_manga_editor/quill_controller_hoook.dart';
import 'package:super_clipboard/super_clipboard.dart';

class MangaPageWidget extends StatelessWidget {
  const MangaPageWidget({
    super.key,
    required this.pageIndex,
    required this.startPage,
    required this.mangaPage,
    required this.onMemoChanged,
    required this.onDialogueChanged,
  });

  final int pageIndex;
  final MangaStartPage startPage;
  final MangaPage mangaPage;
  final Function(String value) onMemoChanged;

  final Function(String value) onDialogueChanged;

  @override
  Widget build(BuildContext context) {
    logger.d('build mangaPageWidget: $pageIndex');

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 200.r,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPageIndicator(),
              SizedBox(
                height: 4.r,
              ),
              IconButton(
                onPressed: () async {
                  final clipboard = SystemClipboard.instance;
                  if (clipboard == null) {
                    return; // Clipboard API is not supported on this platform.
                  }
                  final item = DataWriterItem();
                  item.add(Formats.plainText(mangaPage.dialogues));
                  await clipboard.write([item]);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Page $pageIndex をコピーしました')));
                  }
                },
                icon: const Icon(Icons.copy),
              ),
            ],
          ),
          Expanded(
            flex: 1,
            child: Container(
              constraints: BoxConstraints(
                minHeight: 200.r,
              ),
              color: Colors.indigo.shade100,
              child: _TextAreaWidget(
                initialText: mangaPage.memo,
                onChanged: onMemoChanged,
              ),
            ),
          ),
          SizedBox(
            width: 4.r,
          ),
          Expanded(
            flex: 2,
            child: Container(
              constraints: BoxConstraints(
                minHeight: 200.r,
              ),
              color: Colors.black12,
              child: _TextAreaWidget(
                key: ValueKey(mangaPage.id),
                initialText: mangaPage.dialogues,
                onChanged: onDialogueChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Text _buildPageIndicator() {
    return Text(
      '$pageIndex${_startPageToString(pageIndex.isOdd ? startPage : startPage.reverted)}',
      style: const TextStyle(
        color: Colors.black54,
      ),
    );
  }

  static String _startPageToString(MangaStartPage startPage) {
    return switch (startPage) {
      MangaStartPage.left => 'L',
      MangaStartPage.right => 'R',
    };
  }
}

class _TextAreaWidget extends HookConsumerWidget {
  const _TextAreaWidget(
      {super.key, required this.initialText, required this.onChanged});

  final String initialText;
  final Function(String value) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quillController = useQuillController(initialText);
    final focusNode = useFocusNode();

    quillController.addListener(() {
      onChanged(quillController.document.toPlainText());
    });

    return QuillEditor.basic(
        focusNode: focusNode,
        configurations: QuillEditorConfigurations(
          controller: quillController,
          padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
        ));
  }
}
