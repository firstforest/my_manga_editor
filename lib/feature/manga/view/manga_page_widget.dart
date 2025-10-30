import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/manga/model/manga.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_providers.dart';
import 'package:my_manga_editor/hooks/quill_controller_hook.dart';
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
    final page = ref.watch(mangaPageProvider(mangaPageId));

    final tabController = useTabController(initialLength: 3);
    final currentPageIndex = useState(1);
    final pageController =
        usePageController(initialPage: currentPageIndex.value);

    return SizedBox(
      height: 300.r,
      child: page.when(
          data: (value) => LayoutBuilder(builder: (context, constraints) {
                return switch (constraints.maxWidth) {
                  < 480 => Column(
                      children: [
                        _buildToolBar(ref, value, context),
                        Expanded(
                          child: PageView(
                            controller: pageController,
                            onPageChanged: (index) {
                              tabController.index = index;
                              currentPageIndex.value = index;
                            },
                            children: [
                              _buildMemo(value),
                              _buildDialogues(value),
                              _buildStageDirection(value),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: 0 < currentPageIndex.value
                                  ? () {
                                      pageController.previousPage(
                                        duration:
                                            const Duration(milliseconds: 400),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  : null,
                              icon: Icon(Icons.arrow_left_rounded),
                            ),
                            TabPageSelector(
                              controller: tabController,
                            ),
                            IconButton(
                              onPressed: currentPageIndex.value < 3 - 1
                                  ? () {
                                      pageController.nextPage(
                                        duration:
                                            const Duration(milliseconds: 400),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  : null,
                              icon: Icon(Icons.arrow_right_rounded),
                            ),
                          ],
                        )
                      ],
                    ),
                  _ => Column(
                      children: [
                        _buildToolBar(ref, value, context),
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

  Row _buildToolBar(WidgetRef ref, MangaPage value, BuildContext context) {
    return Row(
      children: [
        _buildPageIndicator(),
        SizedBox(
          width: 4.r,
        ),
        IconButton(
          onPressed: () async {
            await _copyToClipboard(ref, value.mangaId, value.dialoguesDeltaId);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Page $pageIndex をコピーしました')));
            }
          },
          icon: const Icon(Icons.copy),
        ),
        Spacer(),
        IconButton(
          onPressed: () {
            ref.read(mangaPageProvider(mangaPageId).notifier).delete();
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
        key: ValueKey(value.stageDirectionDeltaId),
        mangaId: value.mangaId,
        deltaId: value.stageDirectionDeltaId,
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
        key: ValueKey(value.dialoguesDeltaId),
        mangaId: value.mangaId,
        deltaId: value.dialoguesDeltaId,
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
        mangaId: value.mangaId,
        deltaId: value.memoDeltaId,
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

  Future<void> _copyToClipboard(
      WidgetRef ref, MangaId mangaId, DeltaId deltaId) async {
    final delta = await ref
        .read(deltaProvider(mangaId, deltaId).notifier)
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
    required this.mangaId,
    required this.deltaId,
    this.placeholder,
  });

  final MangaId mangaId;
  final DeltaId deltaId;
  final String? placeholder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onTextChanged = useCallback((delta) {
      ref.read(deltaProvider(mangaId, deltaId).notifier).updateDelta(delta);
    }, [deltaId]);

    final deltaAsync = ref.watch(deltaProvider(mangaId, deltaId));

    return switch (deltaAsync) {
      AsyncData<Delta?>(:final value) => _QuillEditor(
          placeholder: placeholder,
          initialDelta: value,
          onTextChanged: onTextChanged),
      _ => SizedBox.shrink(),
    };
  }
}

class _QuillEditor extends HookWidget {
  const _QuillEditor({
    required this.placeholder,
    required this.initialDelta,
    required this.onTextChanged,
  });

  final String? placeholder;
  final Delta? initialDelta;
  final Function(Delta delta) onTextChanged;

  @override
  Widget build(BuildContext context) {
    final quillController = useQuillController(initialDelta);
    final focusNode = useFocusNode();

    final listener = useCallback(() {
      onTextChanged(quillController.document.toDelta());
    }, []);

    useEffect(() {
      quillController.addListener(listener);
      return () {
        quillController.removeListener(listener);
      };
    }, []);

    return QuillEditor.basic(
        controller: quillController,
        focusNode: focusNode,
        config: QuillEditorConfig(
          placeholder: placeholder,
          padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
          maxHeight: 300.r,
        ));
  }
}
