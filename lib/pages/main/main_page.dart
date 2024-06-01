import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_manga_editor/pages/main/manga_page_view_model.dart';
import 'package:my_manga_editor/views/manga_page_widget.dart';
import 'package:my_manga_editor/views/workspace.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(mangaPageViewModelNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('漫画用エディタ'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(mangaPageViewModelNotifierProvider.notifier).saveManga();
            },
            icon: const Icon(Icons.save),
          ),
          IconButton(
            onPressed: () {
              ref.read(mangaPageViewModelNotifierProvider.notifier).loadManga();
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              ref.read(mangaPageViewModelNotifierProvider.notifier).clearData();
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
          const Expanded(flex: 1, child: Workspace()),
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
                        padding: EdgeInsets.symmetric(
                          vertical: 8.r,
                          horizontal: 24.r,
                        ),
                        child: MangaPageWidget(
                          pageIndex: index + 1,
                          startPage: data.manga.startPage,
                          mangaPage: page,
                          onMemoChanged: (value) {
                            ref
                                .read(
                                    mangaPageViewModelNotifierProvider.notifier)
                                .updateMemo(page.id, value);
                          },
                          onDialogueChanged: (value) {
                            ref
                                .read(
                                    mangaPageViewModelNotifierProvider.notifier)
                                .updateDialogue(page.id, value);
                          },
                        ),
                      ),
                    );
                  },
                  itemCount: data.manga.pages.length,
                  onReorder: (oldIndex, newIndex) {
                    ref
                        .read(mangaPageViewModelNotifierProvider.notifier)
                        .reorderPage(oldIndex, newIndex);
                  },
                ),
                error: (_, __) => const Text('error'),
                loading: () => const CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
