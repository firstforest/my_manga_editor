import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/models/manga.dart';
import 'package:my_manga_editor/pages/grid/manga_grid_page.dart';
import 'package:my_manga_editor/pages/main/manga_page_view_model.dart';
import 'package:my_manga_editor/repositories/manga_providers.dart';
import 'package:my_manga_editor/views/manga_edit_widget.dart';
import 'package:my_manga_editor/views/manga_name_widget.dart';
import 'package:my_manga_editor/views/start_page_selector.dart';

class MainPage extends HookConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(mangaPageViewModelNotifierProvider);

    final scrollController = useScrollController();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        toolbarHeight: 100.r,
        title: SizedBox(
          height: 100.r,
          child: switch (viewModel.valueOrNull) {
            MangaPageViewModel viewModel when viewModel.manga != null =>
              MangaTitle(manga: viewModel.manga!),
            _ => null,
          },
        ),
        actions: [
          if (viewModel.valueOrNull?.manga case final Manga manga)
            IconButton(
                onPressed: () async {
                  await ref
                      .read(mangaNotifierProvider(manga.id).notifier)
                      .download();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${manga.name}をダウンロードしました')));
                  }
                },
                icon: Icon(Icons.save_alt)),
          if (viewModel.valueOrNull?.manga case final Manga manga)
            IconButton(
              onPressed: () async {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MangaGridPage(
                          mangaId: manga.id,
                        )));
              },
              icon: const Icon(Icons.grid_view),
            ),
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
        Manga manga =>
          MangaEditWidget(manga: manga, scrollController: scrollController),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: MangaNameWidget(manga: manga)),
        StartPageSelector(mangaId: manga.id),
      ],
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
