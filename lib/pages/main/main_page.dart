import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/pages/main/manga_page_view_model.dart';
import 'package:my_manga_editor/views/manga_page_widget.dart';
import 'package:my_manga_editor/views/workspace.dart';

class MainPage extends HookConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(mangaPageViewModelNotifierProvider);

    final nameEditController =
        useTextEditingController(text: viewModel.valueOrNull?.manga.name);
    ref.listen(
        mangaPageViewModelNotifierProvider
            .select((v) => v.valueOrNull?.manga.name), (prev, next) {
      if (next != null) {
        nameEditController.text = next;
      }
    });
    final isNameEdit = useState(false);
    final scrollController = useScrollController();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: isNameEdit.value
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
                      onSubmitted: (value) {
                        ref
                            .read(mangaPageViewModelNotifierProvider.notifier)
                            .updateName(value);
                        isNameEdit.value = false;
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref
                          .read(mangaPageViewModelNotifierProvider.notifier)
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
                  child: Text(
                    viewModel.valueOrNull?.manga.name ?? '無名',
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    isNameEdit.value = true;
                  },
                ),
              ),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(mangaPageViewModelNotifierProvider.notifier).saveManga();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('保存しました')),
              );
            },
            icon: const Icon(Icons.save),
          ),
          IconButton(
            onPressed: () {
              ref.read(mangaPageViewModelNotifierProvider.notifier).loadManga();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('読み込みしました')),
              );
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () async {
              await ref
                  .read(mangaPageViewModelNotifierProvider.notifier)
                  .clearData();
              ref
                  .read(mangaPageViewModelNotifierProvider.notifier)
                  .resetManga();
            },
            icon: const Icon(
              Icons.delete_forever,
            ),
          ),
        ],
      ),
      body: Row(
        key: ValueKey(viewModel.asData?.value.uuid),
        children: [
          Expanded(
              flex: 1,
              child: Workspace(
                initialText: viewModel.valueOrNull?.manga.ideaMemo,
                onTextChanged: (value) {
                  ref
                      .read(mangaPageViewModelNotifierProvider.notifier)
                      .updateIdeaMemo(value);
                },
              )),
          Expanded(
            flex: 3,
            child: ColoredBox(
              color: Colors.black12,
              child: viewModel.when(
                data: (data) => ReorderableListView.builder(
                  padding: EdgeInsets.all(8.r),
                  itemBuilder: (context, index) {
                    final page = data.manga.pages[index];
                    return Card(
                      key: ValueKey(page.id),
                      child: Container(
                        padding: EdgeInsets.only(
                          top: 8.r,
                          bottom: 8.r,
                          left: 24.r,
                          right: 24.r + 8.r,
                        ),
                        child: MangaPageWidget(
                            pageIndex: index + 1,
                            startPage: data.manga.startPage,
                            mangaPage: page,
                            onMemoChanged: (value) {
                              ref
                                  .read(mangaPageViewModelNotifierProvider
                                      .notifier)
                                  .updateMemo(page.id, value);
                            },
                            onDialogueChanged: (value) {
                              ref
                                  .read(mangaPageViewModelNotifierProvider
                                      .notifier)
                                  .updateDialogue(page.id, value);
                            },
                            onDeleteButtonPressed: () {
                              ref
                                  .read(mangaPageViewModelNotifierProvider
                                      .notifier)
                                  .deletePage(page.id);
                            }),
                      ),
                    );
                  },
                  itemCount: data.manga.pages.length,
                  onReorder: (oldIndex, newIndex) {
                    ref
                        .read(mangaPageViewModelNotifierProvider.notifier)
                        .reorderPage(oldIndex, newIndex);
                  },
                  scrollController: scrollController,
                ),
                error: (_, __) => const Text('error'),
                loading: () => const CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(mangaPageViewModelNotifierProvider.notifier).addPage();
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
    );
  }
}
