import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';
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
    final page = ref.watch(mangaPageNotifierProvider(mangaPageId));

    final tabController = useTabController(initialLength: 3);
    return SizedBox(
      height: 300.r,
      child: page.when(
          data: (value) => LayoutBuilder(builder: (context, constraints) {
                return switch (constraints.maxWidth) {
                  < 480 => Column(
                      children: [
                        _buildToolBar(ref, value, context, tabController),
                        Expanded(
                          child: PageView(
                            onPageChanged: (index) {
                              tabController.index = index;
                            },
                            children: [
                              _buildMemo(value),
                              _buildDialogues(value),
                              _buildStageDirection(value),
                            ],
                          ),
                        ),
                      ],
                    ),
                  _ => Column(
                      children: [
                        _buildToolBar(ref, value, context, null),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // buildColumn(ref, value, context, deletePage),
                              Expanded(
                                flex: 1,
                                child: _buildMemo(value),
                              ),
                              SizedBox(width: 4.r),
                              Expanded(
                                flex: 3,
                                child: _buildDialogues(value),
                              ),
                              SizedBox(width: 2.r),
                              Expanded(
                                flex: 2,
                                child: _buildStageDirection(value),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                };
              }),
          error: (_, __) => Text('error'),
          loading: () => const CircularProgressIndicator()),
    );
  }

  Row _buildToolBar(WidgetRef ref, MangaPage value, BuildContext context,
      TabController? tabController) {
    return Row(
      children: [
        _buildPageIndicator(),
        SizedBox(
          width: 4.r,
        ),
        IconButton(
          onPressed: () async {
            await _copyToClipboard(ref, value.dialoguesDelta);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Page $pageIndex をコピーしました')));
            }
          },
          icon: const Icon(Icons.copy),
        ),
        if (tabController != null) ...[
          Spacer(),
          TabPageSelector(
            controller: tabController,
          ),
        ],
        Spacer(),
        IconButton(
          onPressed: () {
            ref.read(mangaPageNotifierProvider(mangaPageId).notifier).delete();
          },
          icon: const Icon(Icons.delete),
        ),
      ],
    );
  }

  Container _buildStageDirection(MangaPage value) {
    return Container(
      height: double.infinity,
      constraints: BoxConstraints(minWidth: 300.r),
      color: Colors.black12,
      child: _QuillTextAreaWidget(
        key: ValueKey(value.stageDirectionDelta),
        deltaId: value.stageDirectionDelta,
        placeholder: 'ト書き',
      ),
    );
  }

  Container _buildDialogues(MangaPage value) {
    return Container(
      height: double.infinity,
      constraints: BoxConstraints(minWidth: 300.r),
      color: Colors.black12,
      child: _QuillTextAreaWidget(
        key: ValueKey(value.dialoguesDelta),
        deltaId: value.dialoguesDelta,
        placeholder: 'セリフ',
      ),
    );
  }

  Container _buildMemo(MangaPage value) {
    return Container(
      height: double.infinity,
      constraints: BoxConstraints(minWidth: 300.r),
      color: Colors.indigo.shade100,
      child: _QuillTextAreaWidget(
        deltaId: value.memoDelta,
        placeholder: 'このページで描きたいこと',
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

  Future<void> _copyToClipboard(WidgetRef ref, DeltaId deltaId) async {
    final delta = await ref
        .read(deltaNotifierProvider(deltaId).notifier)
        .exportPlainText();
    final clipboard = SystemClipboard.instance;
    if (clipboard == null || delta.isEmpty) {
      return; // Clipboard API is not supported on this platform.
    }
    final item = DataWriterItem();
    item.add(Formats.plainText(delta));
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
