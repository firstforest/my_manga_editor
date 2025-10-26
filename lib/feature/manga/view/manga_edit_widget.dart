import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/manga/view/workspace.dart';
import 'package:my_manga_editor/feature/manga/model/manga.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_providers.dart';
import 'package:my_manga_editor/feature/ai_comment/view/ai_comment_area.dart';
import 'package:my_manga_editor/feature/manga/view/manga_page_list.dart';

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
                  child: TabBarView(
                    children: [
                      Workspace(deltaId: manga.ideaMemoDeltaId),
                      MangaPageList(
                        manga: manga,
                        scrollController: scrollController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        _ => Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Expanded(
                      child: Workspace(
                        key: ValueKey(manga.id),
                        deltaId: manga.ideaMemoDeltaId,
                      ),
                    ),
                    SizedBox(height: 120.r, child: AiCommentArea(manga.id)),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: ColoredBox(
                  color: Colors.black12,
                  child: MangaPageList(
                    manga: manga,
                    scrollController: scrollController,
                  ),
                ),
              ),
            ],
          )
      },
    );
  }
}
