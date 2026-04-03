import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_page_view_model.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_providers.dart';
import 'package:my_manga_editor/feature/manga/view/kanban_column.dart';
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
    final mangaList = ref.watch(allMangaListProvider).value ?? [];

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
              final mangaId = await ref
                  .read(mangaPageViewModelProvider.notifier)
                  .createNewManga();
              if (context.mounted) {
                ref.read(routerProvider).go('/manga/${mangaId.id}');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
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
    );
  }
}
