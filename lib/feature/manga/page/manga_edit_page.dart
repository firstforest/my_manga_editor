import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_providers.dart';
import 'package:my_manga_editor/router.dart';
import 'package:my_manga_editor/feature/manga/view/manga_edit_widget.dart';
import 'package:my_manga_editor/feature/manga/view/manga_name_widget.dart';
import 'package:my_manga_editor/feature/auth/view/sign_in_button.dart';
import 'package:my_manga_editor/feature/manga/view/start_page_selector.dart';
import 'package:my_manga_editor/feature/manga/view/sync_status_indicator.dart';

class MangaEditPage extends HookConsumerWidget {
  const MangaEditPage({super.key, required this.mangaId});

  final MangaId mangaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        toolbarHeight: 100.r,
        title: SizedBox(
          height: 100.r,
          child: MangaTitle(mangaId: mangaId),
        ),
        actions: [
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
          IconButton(
            onPressed: () {
              ref.read(routerProvider).go('/manga/${mangaId.id}/grid');
            },
            icon: const Icon(Icons.grid_view),
          ),
          IconButton(
            onPressed: () {
              ref.read(routerProvider).go('/');
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
              ref.read(routerProvider).go('/settings');
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
      body: MangaEditWidget(mangaId: mangaId, scrollController: scrollController),
      floatingActionButton: FloatingActionButton(
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
