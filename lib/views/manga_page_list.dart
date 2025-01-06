import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/models/manga.dart';
import 'package:my_manga_editor/repositories/manga_providers.dart';
import 'package:my_manga_editor/views/manga_page_widget.dart';

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
    final pageIdList =
        ref.watch(mangaPageIdListProvider(manga.id)).valueOrNull ?? [];

    return ReorderableListView.builder(
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
              right: 24.r + 8.w,
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
                          .read(mangaNotifierProvider(manga.id).notifier)
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
    );
  }
}
