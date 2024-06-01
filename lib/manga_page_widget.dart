import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/manga.dart';
import 'package:my_manga_editor/quill_controller_hoook.dart';
import 'package:super_clipboard/super_clipboard.dart';

class MangaPageWidget extends HookConsumerWidget {
  const MangaPageWidget({
    super.key,
    required this.pageIndex,
    required this.startPage,
    required this.mangaPage,
  });

  final int pageIndex;
  final MangaStartPage startPage;
  final MangaPage mangaPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoController = useQuillController(mangaPage.memo);
    final dialoguesController = useQuillController(mangaPage.dialogues);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$pageIndex${_startPageToString(pageIndex.isOdd ? startPage : startPage.reverted)}',
              style: const TextStyle(
                color: Colors.black54,
              ),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Page $pageIndex をコピーしました')));
                },
                icon: const Icon(Icons.copy))
          ],
        ),
        SizedBox(
          height: 8.r,
        ),
        SizedBox(
          height: 200.r,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: QuillEditor.basic(
                  configurations: QuillEditorConfigurations(
                    controller: memoController,
                    expands: true,
                    scrollable: true,
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.black12,
                  child: QuillEditor.basic(
                    configurations: QuillEditorConfigurations(
                      controller: dialoguesController,
                      expands: true,
                      scrollable: true,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 24.r,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _startPageToString(MangaStartPage startPage) {
    return switch (startPage) {
      MangaStartPage.left => 'L',
      MangaStartPage.right => 'R',
    };
  }
}
