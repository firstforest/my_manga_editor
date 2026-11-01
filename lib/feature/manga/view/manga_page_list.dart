import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor_common/logger.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_providers.dart';
import 'package:my_manga_editor/feature/manga/view/manga_page_widget.dart';
import 'package:my_manga_editor/feature/manga/view/scene_unit_drag.dart';

class MangaPageList extends HookConsumerWidget {
  const MangaPageList({
    super.key,
    required this.manga,
    required this.scrollController,
  });

  final Manga manga;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageIdList = ref.watch(mangaPageIdListProvider(manga.id)).value ?? [];
    final pageKeys = useMemoized(() => <MangaPageId, GlobalKey>{});
    // 削除されたページのキーを持ち続けない
    pageKeys.removeWhere((pageId, _) => !pageIdList.contains(pageId));
    // メニューで動かしたページ。新しい並びが届いたら見える位置までスクロールする。
    // height は動かす前のページの高さで、移動先がまだ組み立てられていないときの送り量に使う
    final reveal =
        useRef<({MangaPageId pageId, int offset, double height})?>(null);

    void ensureVisible(BuildContext targetContext, int offset) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        // 前へ動かしたらページの上端、後ろへ動かしたら下端を表示領域に入れる
        alignmentPolicy: offset < 0
            ? ScrollPositionAlignmentPolicy.keepVisibleAtStart
            : ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    }

    useEffect(() {
      final target = reveal.value;
      if (target == null) return null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        reveal.value = null;
        final targetContext = pageKeys[target.pageId]?.currentContext;
        if (targetContext != null && targetContext.mounted) {
          ensureVisible(targetContext, target.offset);
          return;
        }
        // 移動先が表示範囲の外で組み立てられていない。動かした向きへ送ってから合わせる
        if (!scrollController.hasClients) return;
        final position = scrollController.position;
        position.jumpTo((position.pixels + target.offset.sign * target.height)
            .clamp(position.minScrollExtent, position.maxScrollExtent));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final targetContext = pageKeys[target.pageId]?.currentContext;
          if (targetContext != null && targetContext.mounted) {
            ensureVisible(targetContext, target.offset);
          }
        });
      });
      return null;
    }, [pageIdList]);

    Future<void> movePage(MangaPageId pageId, int offset) async {
      final messenger = ScaffoldMessenger.of(context);
      final notifier = ref.read(mangaProvider(manga.id).notifier);
      final height = pageKeys[pageId]?.currentContext?.size?.height ?? 0;
      reveal.value = (pageId: pageId, offset: offset, height: height);
      try {
        final moved = await notifier.movePage(pageId, offset);
        if (!moved) {
          reveal.value = null;
        }
      } catch (e, stackTrace) {
        reveal.value = null;
        logger.e('ページの移動に失敗しました', error: e, stackTrace: stackTrace);
        messenger.showSnackBar(
          const SnackBar(content: Text('ページを移動できませんでした')),
        );
      }
    }

    return CutDragScope(
      scrollController: scrollController,
      child: ListView.builder(
        controller: scrollController,
        padding: EdgeInsets.all(8.r),
        itemCount: pageIdList.length,
        itemBuilder: (context, index) {
          final pageId = pageIdList[index];
          return Card(
            key: pageKeys.putIfAbsent(pageId, GlobalKey.new),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8.r, horizontal: 24.r),
              child: Column(
                children: [
                  MangaPageWidget(
                    pageIndex: index + 1,
                    pageCount: pageIdList.length,
                    startPage: manga.startPage,
                    mangaPageId: pageId,
                    onMovePage: (offset) => movePage(pageId, offset),
                  ),
                  SizedBox(
                    height: 4.r,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: IconButton(
                      onPressed: () {
                        ref
                            .read(mangaProvider(manga.id).notifier)
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
      ),
    );
  }
}
