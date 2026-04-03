import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_page_view_model.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_providers.dart';

class MangaSelectDialog extends HookConsumerWidget {
  const MangaSelectDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mangaList = ref.watch(allMangaListProvider).value ?? [];
    final selectedMangaIds = useState<Set<MangaId>>({});

    // Calculate total page count for selected manga
    int totalPageCount = 0;
    for (final mangaId in selectedMangaIds.value) {
      final pageCount = ref.watch(mangaPageIdListProvider(mangaId)).maybeMap(
            data: (data) => data.value.length,
            orElse: () => 0,
          );
      totalPageCount += pageCount;
    }

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('漫画を選択'),
          if (selectedMangaIds.value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '選択中: ${selectedMangaIds.value.length}作品 / 合計ページ数: $totalPageCount',
                style: TextStyle(fontSize: 14, color: Colors.blue),
              ),
            ),
        ],
      ),
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
                final pageCount =
                    ref.watch(mangaPageIdListProvider(manga.id)).maybeMap(
                          data: (data) => data.value.length,
                          orElse: () => 0,
                        );
                final isSelected = selectedMangaIds.value.contains(manga.id);

                return ListTile(
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: (bool? value) {
                      if (value == true) {
                        selectedMangaIds.value = {
                          ...selectedMangaIds.value,
                          manga.id
                        };
                      } else {
                        selectedMangaIds.value = selectedMangaIds.value
                            .where((id) => id != manga.id)
                            .toSet();
                      }
                    },
                  ),
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
