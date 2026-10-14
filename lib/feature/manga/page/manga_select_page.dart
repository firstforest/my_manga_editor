import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor/feature/app_info/view/app_info_dialog.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_page_view_model.dart';
import 'package:my_manga_editor/feature/manga/provider/tag_providers.dart';
import 'package:my_manga_editor/feature/manga/view/kanban_column.dart';
import 'package:my_manga_editor/feature/manga/view/tag_filter_bar.dart';
import 'package:my_manga_editor/router.dart';

class MangaSelectPage extends ConsumerWidget {
  const MangaSelectPage({super.key});

  static const _columns = [
    (status: MangaStatus.idea, title: 'アイデア'),
    (status: MangaStatus.inProgress, title: '制作中'),
    (status: MangaStatus.complete, title: '完成'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mangaList = ref.watch(filteredMangaListProvider);

    final mangaByStatus = <MangaStatus, List<Manga>>{
      for (final status in MangaStatus.values)
        status: mangaList.where((m) => m.status == status).toList(),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('漫画を選択'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '新規作成',
            onPressed: () async {
              // タグで絞り込んでいる最中の新規作成は、そのタグを付けて作る。
              // 作った直後に一覧から消えて見えなくなるのを避けるため。
              final filter = ref.read(tagFilterProvider);
              final mangaId = await ref
                  .read(mangaPageViewModelProvider.notifier)
                  .createNewManga(
                    tags: filter is TagFilterTag ? [filter.name] : const [],
                  );
              if (context.mounted) {
                ref.read(routerProvider).go('/manga/${mangaId.id}');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'このアプリについて',
            onPressed: () => showAppInfoDialog(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TagFilterBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final column in _columns)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: KanbanColumn(
                          status: column.status,
                          title: column.title,
                          mangaList: mangaByStatus[column.status] ?? [],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
