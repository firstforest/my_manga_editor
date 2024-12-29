import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/models/manga.dart';
import 'package:my_manga_editor/quill_controller_hook.dart';
import 'package:my_manga_editor/repositories/manga_providers.dart';
import 'package:super_clipboard/super_clipboard.dart';

class MangaPageWidget extends HookConsumerWidget {
  const MangaPageWidget({
    super.key,
    required this.pageIndex,
    required this.startPage,
    required this.mangaPageId,
  });

  final int pageIndex;
  final MangaStartPage startPage;
  final MangaPageId mangaPageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = mangaPageNotifierProvider(mangaPageId);
    final page = ref.watch(provider);
    final dialoguesDelta =
        ref.watch(deltaNotifierProvider(page.valueOrNull?.dialoguesDelta));

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 300.r,
      ),
      child: page.map(
          data: (data) => Row(
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
                          if (dialoguesDelta.valueOrNull != null) {
                            await _copyToClipboard(dialoguesDelta.value!);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Page $pageIndex をコピーしました')));
                            }
                          }
                        },
                        icon: const Icon(Icons.copy),
                      ),
                      IconButton(
                        onPressed: () {
                          ref.read(provider.notifier).delete();
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: 300.r,
                      ),
                      color: Colors.indigo.shade100,
                      child: _QuillTextAreaWidget(
                        deltaId: data.value.memoDelta,
                        placeholder: 'このページで描きたいこと',
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
                        minHeight: 300.r,
                      ),
                      color: Colors.black12,
                      child: _QuillTextAreaWidget(
                        key: ValueKey(data.value.dialoguesDelta),
                        deltaId: data.value.dialoguesDelta,
                        placeholder: 'セリフ',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 2.r,
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: 300.r,
                      ),
                      color: Colors.black12,
                      child: _QuillTextAreaWidget(
                        key: ValueKey(data.value.stageDirectionDelta),
                        deltaId: data.value.stageDirectionDelta,
                        placeholder: 'ト書き',
                      ),
                    ),
                  ),
                ],
              ),
          error: (error) => Text('error'),
          loading: (loading) => const CircularProgressIndicator()),
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

  Future<void> _copyToClipboard(Delta delta) async {
    final clipboard = SystemClipboard.instance;
    if (clipboard == null) {
      return; // Clipboard API is not supported on this platform.
    }
    final item = DataWriterItem();
    item.add(Formats.plainText(Document.fromDelta(delta).toPlainText()));
    await clipboard.write([item]);
  }
}

class _QuillTextAreaWidget extends HookConsumerWidget {
  const _QuillTextAreaWidget({
    super.key,
    required this.deltaId,
    this.placeholder,
  });

  final DeltaId deltaId;
  final String? placeholder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quillController = useQuillController(null);
    final focusNode = useFocusNode();

    useEffect(() {
      () async {
        final initialText =
            await ref.read(deltaNotifierProvider(deltaId).future);
        if (initialText != null && initialText.isNotEmpty && context.mounted) {
          quillController.document = Document.fromDelta(initialText);
        }
      }();
      return null;
    }, [deltaId]);

    final onTextChanged = useCallback(() {
      final delta = quillController.document.toDelta();
      ref.read(deltaNotifierProvider(deltaId).notifier).updateDelta(delta);
    }, [deltaId]);

    useEffect(() {
      quillController.addListener(onTextChanged);
      return () {
        quillController.removeListener(onTextChanged);
      };
    }, [deltaId]);

    return QuillEditor.basic(
        controller: quillController,
        focusNode: focusNode,
        configurations: QuillEditorConfigurations(
          placeholder: placeholder,
          padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
          maxHeight: 300.r,
        ));
  }
}
