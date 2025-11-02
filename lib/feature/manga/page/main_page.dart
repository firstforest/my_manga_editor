import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/manga/model/manga.dart';
import 'package:my_manga_editor/feature/manga/page/manga_grid_page.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_page_view_model.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_providers.dart';
import 'package:my_manga_editor/feature/manga/repository/auth_repository.dart';
import 'package:my_manga_editor/feature/manga/view/manga_edit_widget.dart';
import 'package:my_manga_editor/feature/manga/view/manga_name_widget.dart';
import 'package:my_manga_editor/feature/manga/view/sign_in_button.dart';
import 'package:my_manga_editor/feature/manga/view/start_page_selector.dart';
import 'package:my_manga_editor/feature/manga/view/sync_status_indicator.dart';
import 'package:my_manga_editor/feature/setting/page/setting_page.dart';

class MainPage extends HookConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(mangaPageViewModelProvider);
    final user = ref.watch(currentUserProvider);
    final scrollController = useScrollController();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        toolbarHeight: 100.r,
        title: SizedBox(
          height: 100.r,
          child: switch (viewModel.value?.mangaId) {
            MangaId mangaId => MangaTitle(mangaId: mangaId),
            _ => null,
          },
        ),
        actions: [
          if (viewModel.value?.mangaId case final MangaId mangaId)
            IconButton(
                onPressed: () async {
                  await ref.read(mangaProvider(mangaId).notifier).download();
                  final manga = ref.read(mangaProvider(mangaId)).value;
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${manga?.name}をダウンロードしました')));
                  }
                },
                icon: Icon(Icons.save_alt)),
          if (viewModel.value?.mangaId case final MangaId mangaId)
            IconButton(
              onPressed: () async {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MangaGridPage(
                          mangaId: mangaId,
                        )));
              },
              icon: const Icon(Icons.grid_view),
            ),
          if (user != null)
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
          // Online status indicator
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: OnlineStatusIndicator(),
          ),
          // Settings button
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingPage(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
          // Firebase Authentication Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: const SignInButton(),
          ),
        ],
      ),
      body: switch (viewModel.value?.mangaId) {
        MangaId mangaId =>
          MangaEditWidget(mangaId: mangaId, scrollController: scrollController),
        // ログイン状態に応じて表示を切り替える
        null => user != null
            ? Center(
                child: TextButton(
                  onPressed: () {
                    ref
                        .read(mangaPageViewModelProvider.notifier)
                        .createNewManga();
                  },
                  child: Text(
                    '新しく作品を作る',
                    style: TextStyle(fontSize: 32.r),
                  ),
                ),
              )
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ログインしてください',
                      style: TextStyle(fontSize: 32.r, color: Colors.grey),
                    ),
                    SizedBox(height: 16.r),
                    Text(
                      '作品を作成するにはログインが必要です',
                      style: TextStyle(fontSize: 16.r, color: Colors.grey),
                    ),
                  ],
                ),
              ),
      },
      floatingActionButton: switch (viewModel.value?.mangaId) {
        MangaId mangaId => FloatingActionButton(
            onPressed: () async {
              final pageIdList =
                  await ref.read(mangaPageIdListProvider(mangaId).future);
              await ref
                  .read(mangaProvider(mangaId).notifier)
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
    required this.mangaId,
  });

  final MangaId mangaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manga = ref.watch(mangaProvider(mangaId)).value;
    if (manga == null) {
      return const SizedBox.shrink();
    }
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
    final mangaList = ref.watch(allMangaListProvider).value ?? [];

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
                          .read(mangaPageViewModelProvider.notifier)
                          .createNewManga();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  );
                }
                final manga = mangaList[index - 1];
                final delta = ref
                    .watch(deltaProvider(manga.id, manga.ideaMemoDeltaId))
                    .value;
                final pageCount = ref.watch(mangaPageIdListProvider(manga.id)).maybeMap(
                  data: (data) => data.value.length,
                  orElse: () => 0,
                );
                return ListTile(
                  title: Text(manga.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          delta != null && delta.isNotEmpty
                              ? Document.fromDelta(delta).toPlainText()
                              : '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      SizedBox(height: 4),
                      Text(
                        'ページ数: $pageCount',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  onTap: () {
                    ref
                        .read(mangaPageViewModelProvider.notifier)
                        .selectManga(manga.id);
                    Navigator.pop(context);
                  },
                  trailing: IconButton(
                    onPressed: () {
                      ref.read(mangaProvider(manga.id).notifier).delete();
                    },
                    icon: Icon(Icons.delete),
                  ),
                );
              })),
    );
  }
}
