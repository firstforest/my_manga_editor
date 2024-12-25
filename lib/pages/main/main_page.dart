import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/models/manga.dart';
import 'package:my_manga_editor/pages/main/manga_page_view_model.dart';
import 'package:my_manga_editor/repositories/manga_providers.dart';
import 'package:my_manga_editor/views/manga_page_widget.dart';
import 'package:my_manga_editor/views/workspace.dart';

class MainPage extends HookConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(mangaPageViewModelNotifierProvider);

    final scrollController = useScrollController();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        toolbarHeight: 64.r,
        title: switch (viewModel.valueOrNull) {
          MangaPageViewModel viewModel when viewModel.manga != null =>
            MangaTitle(manga: viewModel.manga!),
          _ => null,
        },
        actions: [
          IconButton(
            onPressed: () async {
              if (context.mounted) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return MangaSelectDialog();
                    });
              }
            },
            icon: const Icon(Icons.list),
          ),
        ],
      ),
      body: switch (viewModel.valueOrNull?.manga) {
        Manga manga => Column(
            children: [
              Text('selectedMangaId = ${viewModel.valueOrNull?.manga}',
                  style: TextStyle(fontSize: 4.sp)),
              Expanded(
                child: _MangaEditWidget(
                    manga: manga, scrollController: scrollController),
              ),
            ],
          ),
        // 自動で作るかボタンを用意する
        null => Center(
            child: TextButton(
              onPressed: () {
                ref
                    .read(mangaPageViewModelNotifierProvider.notifier)
                    .createNewManga();
              },
              child: Text(
                '新しく作品を作る',
                style: TextStyle(fontSize: 32.r),
              ),
            ),
          ),
      },
      floatingActionButton: switch (viewModel.valueOrNull?.manga?.id) {
        MangaId mangaId => FloatingActionButton(
            onPressed: () async {
              final pageIdList =
                  await ref.read(mangaPageIdListProvider(mangaId).future);
              await ref
                  .read(mangaNotifierProvider(mangaId).notifier)
                  .addNewPage(pageIdList.length);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: const Duration(seconds: 1),
                  curve: Curves.fastOutSlowIn,
                );
              });
            },
            child: const Icon(Icons.add),
          ),
        _ => null,
      },
    );
  }
}

class MangaTitle extends HookConsumerWidget {
  const MangaTitle({
    super.key,
    required this.manga,
  });

  final Manga manga;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameEditController = useTextEditingController(text: manga.name);
    final isNameEdit = useState(false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(isNameEdit, nameEditController, ref),
        DropdownButton(
          value: manga.startPage,
          items: MangaStartPage.values
              .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text('${switch (e) {
                    MangaStartPage.left => '左',
                    MangaStartPage.right => '右',
                  }}始まり')))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              ref
                  .read(mangaNotifierProvider(manga.id).notifier)
                  .updateStartPage(value);
            }
          },
        ),
      ],
    );
  }

  RenderObjectWidget _buildTitle(ValueNotifier<bool> isNameEdit,
      TextEditingController nameEditController, WidgetRef ref) {
    return isNameEdit.value
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 200.r,
                  maxWidth: 500.r,
                ),
                child: TextField(
                  controller: nameEditController,
                  style: TextStyle(fontSize: 24.r),
                  onSubmitted: (value) {
                    ref
                        .read(mangaNotifierProvider(manga.id).notifier)
                        .updateName(value);
                    isNameEdit.value = false;
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  ref
                      .read(mangaNotifierProvider(manga.id).notifier)
                      .updateName(nameEditController.text);
                  isNameEdit.value = false;
                },
                icon: const Icon(Icons.done),
              ),
            ],
          )
        : ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 200.r,
              maxWidth: 500.r,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                isNameEdit.value = true;
              },
              child: Text(
                manga.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 24.r),
              ),
            ),
          );
  }
}

class _MangaEditWidget extends HookConsumerWidget {
  const _MangaEditWidget({
    required this.manga,
    required this.scrollController,
  });

  final Manga manga;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageIdList =
        ref.watch(mangaPageIdListProvider(manga.id)).valueOrNull ?? [];

    return Row(
      key: ValueKey(manga.id),
      children: [
        Expanded(flex: 1, child: _MemoArea(manga: manga)),
        Expanded(
          flex: 3,
          child: ColoredBox(
            color: Colors.black12,
            child: ReorderableListView.builder(
              padding: EdgeInsets.all(8.r),
              itemBuilder: (context, index) {
                final pageId = pageIdList[index];
                return Card(
                  key: ValueKey(pageId),
                  child: Container(
                    padding: EdgeInsets.only(
                      top: 8.r,
                      bottom: 8.r,
                      left: 24.r,
                      right: 24.r + 8.r,
                    ),
                    child: Column(
                      children: [
                        MangaPageWidget(
                          pageIndex: index + 1,
                          startPage: manga.startPage,
                          mangaPageId: pageId,
                        ),
                        SizedBox(
                          height: 4.r,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: IconButton(
                            onPressed: () {
                              ref
                                  .read(
                                      mangaNotifierProvider(manga.id).notifier)
                                  .addNewPage(index + 1);
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: pageIdList.length,
              onReorder: (oldIndex, newIndex) {
                ref
                    .read(mangaNotifierProvider(manga.id).notifier)
                    .reorderPage(pageIdList, oldIndex, newIndex);
              },
              scrollController: scrollController,
            ),
          ),
        ),
      ],
    );
  }
}

class _MemoArea extends HookConsumerWidget {
  const _MemoArea({
    required this.manga,
  });

  final Manga manga;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Workspace(
      key: ValueKey(manga.id),
      deltaId: manga.ideaMemo,
    );
  }
}

class MangaSelectDialog extends HookConsumerWidget {
  const MangaSelectDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mangaList = ref.watch(allMangaListProvider).valueOrNull ?? [];

    return AlertDialog(
      title: Text('漫画を選択'),
      content: SizedBox(
          width: 400,
          child: ListView.builder(
              itemCount: mangaList.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ListTile(
                    title: const Text('新規作成'),
                    subtitle: const Text('新しい漫画を作成します'),
                    onTap: () async {
                      await ref
                          .read(mangaPageViewModelNotifierProvider.notifier)
                          .createNewManga();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  );
                }
                final manga = mangaList[index - 1];
                final delta = ref
                    .watch(deltaNotifierProvider(manga.ideaMemo))
                    .valueOrNull;
                return ListTile(
                  title: Text(manga.name),
                  subtitle: Text(
                      delta != null && delta.isNotEmpty
                          ? Document.fromDelta(delta).toPlainText()
                          : '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  onTap: () {
                    ref
                        .read(mangaPageViewModelNotifierProvider.notifier)
                        .selectManga(manga.id);
                    Navigator.pop(context);
                  },
                  trailing: IconButton(
                    onPressed: () {
                      ref
                          .read(mangaNotifierProvider(manga.id).notifier)
                          .delete();
                    },
                    icon: Icon(Icons.delete),
                  ),
                );
              })),
    );
  }
}
