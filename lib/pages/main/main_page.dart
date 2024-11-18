import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/pages/main/manga_page_view_model.dart';
import 'package:my_manga_editor/repositories/manga_repository.dart';
import 'package:my_manga_editor/views/manga_page_widget.dart';
import 'package:my_manga_editor/views/workspace.dart';
import 'package:uuid/uuid.dart';

class MainPage extends HookConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uuid = useState('uuid');

    final viewModel = ref.watch(mangaPageViewModelNotifierProvider(uuid.value));

    final nameEditController =
        useTextEditingController(text: viewModel.valueOrNull?.manga.name);
    ref.listen(
        mangaPageViewModelNotifierProvider(uuid.value)
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
        toolbarHeight: 72.r,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (kDebugMode) Text(uuid.value, style: TextStyle(fontSize: 5.sp)),
            isNameEdit.value
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
                                .read(mangaPageViewModelNotifierProvider(
                                        uuid.value)
                                    .notifier)
                                .updateName(value);
                            isNameEdit.value = false;
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ref
                              .read(
                                  mangaPageViewModelNotifierProvider(uuid.value)
                                      .notifier)
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
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final mangaRepository = ref.read(mangaRepositoryProvider);
              final files = await mangaRepository.getMangaFiles();
              if (context.mounted) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('ファイル選択'),
                        content: Container(
                            width: 400,
                            child: ListView.builder(
                                itemCount: files.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return ListTile(
                                      title: const Text('新規作成'),
                                      onTap: () {
                                        final newUuid = const Uuid().v4();
                                        uuid.value = newUuid;
                                        Navigator.pop(context);
                                      },
                                    );
                                  }
                                  final manga = files[index - 1];
                                  return ListTile(
                                    title: Text(manga.name),
                                    onTap: () {
                                      uuid.value = manga.uuid;
                                      Navigator.pop(context);
                                    },
                                  );
                                })),
                      );
                    });
              }
            },
            icon: const Icon(Icons.list),
          ),
          IconButton(
            onPressed: () {
              ref
                  .read(mangaPageViewModelNotifierProvider(uuid.value).notifier)
                  .saveManga();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('保存しました')),
              );
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Row(
        key: ValueKey(uuid.value),
        children: [
          Expanded(
              flex: 1,
              child: HookConsumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final viewModel =
                      ref.watch(mangaPageViewModelNotifierProvider(uuid.value));
                  final onTextChanged = useCallback(
                    (value) {
                      ref
                          .read(mangaPageViewModelNotifierProvider(uuid.value)
                              .notifier)
                          .updateIdeaMemo(value);
                    },
                    [uuid.value],
                  );
                  return viewModel.map(
                    data: (data) => Workspace(
                      key: ValueKey(uuid.value),
                      initialText: data.value.manga.ideaMemo,
                      onTextChanged: onTextChanged,
                    ),
                    error: (error) => const CircularProgressIndicator(),
                    loading: (loading) => const CircularProgressIndicator(),
                  );
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
                                  .read(mangaPageViewModelNotifierProvider(
                                          uuid.value)
                                      .notifier)
                                  .updateMemo(page.id, value);
                            },
                            onStageDirectionChanged: (value) {
                              ref
                                  .read(mangaPageViewModelNotifierProvider(
                                          uuid.value)
                                      .notifier)
                                  .updateStageDirection(page.id, value);
                            },
                            onDialogueChanged: (value) {
                              ref
                                  .read(mangaPageViewModelNotifierProvider(
                                          uuid.value)
                                      .notifier)
                                  .updateDialogue(page.id, value);
                            },
                            onDeleteButtonPressed: () {
                              ref
                                  .read(mangaPageViewModelNotifierProvider(
                                          uuid.value)
                                      .notifier)
                                  .deletePage(page.id);
                            }),
                      ),
                    );
                  },
                  itemCount: data.manga.pages.length,
                  onReorder: (oldIndex, newIndex) {
                    ref
                        .read(mangaPageViewModelNotifierProvider(uuid.value)
                            .notifier)
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
          ref
              .read(mangaPageViewModelNotifierProvider(uuid.value).notifier)
              .addPage();
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
