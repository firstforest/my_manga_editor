import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_providers.dart';
import 'package:my_manga_editor/feature/manga/view/manga_page_list.dart';
import 'package:my_manga_editor/feature/manga/view/workspace.dart';

class MangaEditWidget extends HookConsumerWidget {
  const MangaEditWidget({
    super.key,
    required this.mangaId,
    required this.scrollController,
  });

  final MangaId mangaId;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manga = ref.watch(mangaProvider(mangaId)).value;
    if (manga == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return LayoutBuilder(
      key: ValueKey(mangaId),
      builder: (context, constraints) => switch (constraints.maxWidth) {
        < 640 => DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  tabs: [
                    Tab(child: Text('全体メモ')),
                    Tab(child: Text('ページリスト')),
                  ],
                ),
                SizedBox(
                  height: 8.r,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.r),
                    child: TabBarView(
                      children: [
                        Workspace(
                            mangaId: manga.id, deltaId: manga.ideaMemoDeltaId),
                        MangaPageList(
                          manga: manga,
                          scrollController: scrollController,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        // 机の端と、2 枚の紙の間を同じ幅にする
        _ => Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Workspace(
                    key: ValueKey(manga.id),
                    mangaId: manga.id,
                    deltaId: manga.ideaMemoDeltaId,
                  ),
                ),
                SizedBox(width: 16.r),
                Expanded(
                  flex: 3,
                  child: MangaPageList(
                    manga: manga,
                    scrollController: scrollController,
                  ),
                ),
              ],
            ),
          ),
      },
    );
  }
}
