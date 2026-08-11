import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_providers.dart';
import 'package:my_manga_editor/router.dart';
import 'package:my_manga_editor/feature/manga/view/manga_edit_widget.dart';
import 'package:my_manga_editor/feature/manga/view/manga_name_widget.dart';
import 'package:my_manga_editor/feature/manga/view/start_page_selector.dart';
import 'package:my_manga_editor/feature/manga/view/sync_status_indicator.dart';

class MangaEditPage extends HookConsumerWidget {
  const MangaEditPage({super.key, required this.mangaId});

  final MangaId mangaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    // 作品がまだ読み込めていない間は保存ボタンを押せなくする。
    // 読み込み中に押すと download() が「作品が無い」で失敗し、
    // 実際には存在する作品なのに「保存に失敗しました」が出てしまうため
    final canDownload = ref
        .watch(mangaProvider(mangaId).select((manga) => manga.value != null));

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
              onPressed: canDownload
                  ? () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final String name;
                      try {
                        // 作品名は download() の戻り値を使う。ここで mangaProvider を
                        // 読むと、まだ loading のときに名前が取れず null になる
                        name = await ref
                            .read(mangaProvider(mangaId).notifier)
                            .download();
                      } catch (_) {
                        // 詳細は download 内で logger.e に残している
                        if (!context.mounted) {
                          return;
                        }
                        messenger.showSnackBar(
                            const SnackBar(content: Text('保存に失敗しました')));
                        return;
                      }
                      // 書き出し中に画面を離れていたら通知しない
                      if (!context.mounted) {
                        return;
                      }
                      messenger.showSnackBar(
                          SnackBar(content: Text('$nameをダウンロードしました')));
                    }
                  : null,
              icon: Icon(Icons.save_alt)),
          IconButton(
            onPressed: () {
              ref.read(routerProvider).go('/manga/${mangaId.id}/grid');
            },
            icon: const Icon(Icons.grid_view),
          ),
          // Online status indicator
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: OnlineStatusIndicator(),
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
