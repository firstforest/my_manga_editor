import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor_data/model/manga.dart';
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

    return page.when(
        data: (value) => LayoutBuilder(builder: (context, constraints) {
              return switch (constraints.maxWidth) {
                < 480 => _MobileLayout(
                    pageIndex: pageIndex,
                    startPage: startPage,
                    mangaPageId: mangaPageId,
                    page: value,
                  ),
                _ => _DesktopLayout(
                    pageIndex: pageIndex,
                    startPage: startPage,
                    mangaPageId: mangaPageId,
                    page: value,
                  ),
              };
            }),
        error: (_, __) => Text('error'),
        loading: () => const CircularProgressIndicator());
  }
}

class _DesktopLayout extends HookConsumerWidget {
  const _DesktopLayout({
    required this.pageIndex,
    required this.startPage,
    required this.mangaPageId,
    required this.page,
  });

  final int pageIndex;
  final MangaStartPage startPage;
  final MangaPageId mangaPageId;
  final MangaPage page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildToolBar(ref, context),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: _buildMemo(),
            ),
            SizedBox(width: 4.r),
            Expanded(
              flex: 5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < page.sceneUnits.length; i++) ...[
                    if (i > 0) SizedBox(height: 4.r),
                    SizedBox(
                      height: 300.r,
                      child: _SceneUnitWidget(
                        mangaId: page.mangaId,
                        sceneUnit: page.sceneUnits[i],
                        index: i,
                        canRemove: page.sceneUnits.length > 1,
                        onRemove: () {
                          ref
                              .read(mangaPageProvider(mangaPageId).notifier)
                              .removeSceneUnit(i);
                        },
                      ),
                    ),
                  ],
                  SizedBox(height: 4.r),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {
                        ref
                            .read(mangaPageProvider(mangaPageId).notifier)
                            .addSceneUnit();
                      },
                      icon: const Icon(Icons.add),
                      tooltip: 'カットを追加',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Row _buildToolBar(WidgetRef ref, BuildContext context) {
    return Row(
      children: [
        _buildPageIndicator(),
        SizedBox(width: 4.r),
        IconButton(
          onPressed: () async {
            await _copyAllDialoguesToClipboard(ref, page);
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

  Container _buildMemo() {
    return Container(
      height: 300.r,
      constraints: BoxConstraints(minWidth: 300.r),
      color: Colors.indigo.shade100,
      child: _QuillTextAreaWidget(
        mangaId: page.mangaId,
        deltaId: page.memoDeltaId,
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
}

class _MobileLayout extends HookConsumerWidget {
  const _MobileLayout({
    required this.pageIndex,
    required this.startPage,
    required this.mangaPageId,
    required this.page,
  });

  final int pageIndex;
  final MangaStartPage startPage;
  final MangaPageId mangaPageId;
  final MangaPage page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalPages = 1 + page.sceneUnits.length * 2;
    final tabController = useTabController(initialLength: totalPages);
    final currentPageIndex = useState(1);
    final pageController =
        usePageController(initialPage: currentPageIndex.value);

    // Build page list: memo, then for each sceneUnit: dialogue, stageDirection
    final pages = <Widget>[
      _buildMemo(),
      for (final unit in page.sceneUnits) ...[
        _buildDialogues(unit),
        _buildStageDirection(unit),
      ],
    ];

    return SizedBox(
      height: 300.r,
      child: Column(
        children: [
          _buildToolBar(ref, context),
          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: (index) {
                tabController.index = index;
                currentPageIndex.value = index;
              },
              children: pages,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: 0 < currentPageIndex.value
                    ? () {
                        pageController.previousPage(
                          duration: const Duration(milliseconds: 400),
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
                onPressed: currentPageIndex.value < totalPages - 1
                    ? () {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
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
    );
  }

  Row _buildToolBar(WidgetRef ref, BuildContext context) {
    return Row(
      children: [
        Text(
          '$pageIndex${_startPageToString(pageIndex.isOdd ? startPage : startPage.reverted)}',
          style: const TextStyle(color: Colors.black54),
        ),
        SizedBox(width: 4.r),
        IconButton(
          onPressed: () async {
            await _copyAllDialoguesToClipboard(ref, page);
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

  Container _buildMemo() {
    return Container(
      height: double.infinity,
      constraints: BoxConstraints(minWidth: 300.r),
      color: Colors.indigo.shade100,
      child: _QuillTextAreaWidget(
        mangaId: page.mangaId,
        deltaId: page.memoDeltaId,
        placeholder: 'このページで描きたいこと',
      ),
    );
  }

  Container _buildDialogues(SceneUnit unit) {
    return Container(
      height: double.infinity,
      constraints: BoxConstraints(minWidth: 300.r),
      color: Colors.black12,
      child: _QuillTextAreaWidget(
        key: ValueKey(unit.dialoguesDeltaId),
        mangaId: page.mangaId,
        deltaId: unit.dialoguesDeltaId,
        placeholder: 'セリフ',
      ),
    );
  }

  Container _buildStageDirection(SceneUnit unit) {
    return Container(
      height: double.infinity,
      constraints: BoxConstraints(minWidth: 300.r),
      color: Colors.black12,
      child: _QuillTextAreaWidget(
        key: ValueKey(unit.stageDirectionDeltaId),
        mangaId: page.mangaId,
        deltaId: unit.stageDirectionDeltaId,
        placeholder: 'ト書き',
      ),
    );
  }
}

class _SceneUnitWidget extends StatelessWidget {
  const _SceneUnitWidget({
    required this.mangaId,
    required this.sceneUnit,
    required this.index,
    required this.canRemove,
    required this.onRemove,
  });

  final MangaId mangaId;
  final SceneUnit sceneUnit;
  final int index;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Container(
            height: double.infinity,
            color: Colors.black12,
            child: _QuillTextAreaWidget(
              key: ValueKey(sceneUnit.dialoguesDeltaId),
              mangaId: mangaId,
              deltaId: sceneUnit.dialoguesDeltaId,
              placeholder: 'セリフ',
            ),
          ),
        ),
        SizedBox(width: 2.r),
        Expanded(
          flex: 2,
          child: Container(
            height: double.infinity,
            color: Colors.black12,
            child: _QuillTextAreaWidget(
              key: ValueKey(sceneUnit.stageDirectionDeltaId),
              mangaId: mangaId,
              deltaId: sceneUnit.stageDirectionDeltaId,
              placeholder: 'ト書き',
            ),
          ),
        ),
        if (canRemove)
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 16),
            tooltip: 'カットを削除',
          ),
      ],
    );
  }
}

String _startPageToString(MangaStartPage startPage) {
  return switch (startPage) {
    MangaStartPage.left => 'L',
    MangaStartPage.right => 'R',
  };
}

Future<void> _copyAllDialoguesToClipboard(
    WidgetRef ref, MangaPage page) async {
  final parts = <String>[];
  for (final unit in page.sceneUnits) {
    final text = await ref
        .read(deltaProvider(page.mangaId, unit.dialoguesDeltaId).notifier)
        .exportPlainText();
    if (text.isNotEmpty) {
      parts.add(text);
    }
  }
  final combined = parts.join('\n\n');
  final clipboard = SystemClipboard.instance;
  if (clipboard == null || combined.isEmpty) {
    return;
  }
  final item = DataWriterItem();
  item.add(Formats.plainText(combined));
  await clipboard.write([item]);
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
