import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/models/manga.dart';
import 'package:my_manga_editor/repositories/manga_providers.dart';
import 'package:my_manga_editor/views/tategaki.dart';

class MangaGridPage extends HookConsumerWidget {
  MangaGridPage({
    super.key,
    required this.mangaId,
  });

  final _key = GlobalKey();
  final MangaId mangaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crossAxisCount = 4;
    final scrollController = useScrollController();
    final list = ref.watch(mangaPageIdListProvider(mangaId)).maybeMap(
          orElse: () => <MangaPageId?>[],
          data: (data) => (data.value.map<MangaPageId?>((e) => e).toList()
                ..insert(0, null))
              .slices(crossAxisCount)
              .map((e) => e.length != crossAxisCount
                  ? e + List.filled(crossAxisCount - e.length, null)
                  : e)
              .map((e) => e.reversed)
              .flattened
              .toList(),
        );

    final generatedChildren = list
        .mapIndexed((index, id) => id != null
            ? MangaGridPageView(
                key: ValueKey('$id'),
                mangaPageId: id,
                index: index,
              )
            : SizedBox(
                key: ValueKey('$index'),
              ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manga Grid'),
      ),
      body: ReorderableBuilder<MangaPageId?>(
          scrollController: scrollController,
          onReorder: (ReorderedListFunction<MangaPageId?> reorder) {
            final newOrder = reorder(list);
            ref.read(mangaNotifierProvider(mangaId).notifier).reorderPage(
                newOrder
                    .slices(crossAxisCount)
                    .map((e) => e.reversed)
                    .flattened
                    .nonNulls
                    .toList(),
                0,
                0);
          },
          enableLongPress: false,
          children: generatedChildren,
          builder: (children) {
            return GridView(
              key: _key,
              controller: scrollController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 8.r,
                  mainAxisSpacing: 24.r),
              children: children,
            );
          }),
    );
  }
}

class MangaGridPageView extends HookConsumerWidget {
  const MangaGridPageView({
    super.key,
    required this.mangaPageId,
    required this.index,
  });

  final MangaPageId mangaPageId;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mangaPage = ref.watch(mangaPageNotifierProvider(mangaPageId));

    return Align(
      alignment: index.isOdd ? Alignment.centerLeft : Alignment.centerRight,
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(8.r),
            child: Column(
              children: [
                Expanded(
                  child: mangaPage.map(
                    data: (mangaPage) {
                      final delta = ref.watch(deltaNotifierProvider(
                          mangaPage.value.dialoguesDelta));
                      return switch (delta.valueOrNull) {
                        Delta d when d.isNotEmpty => SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.all(8.r),
                              child: Tategaki(
                                Document.fromDelta(d).toPlainText(),
                                style: GoogleFonts.shipporiAntique(height: 1.0),
                              ),
                            ),
                          ),
                        _ => Text('セリフなし'),
                      };
                    },
                    error: (error) => Text('$error'),
                    loading: (loading) =>
                        const Center(child: CircularProgressIndicator()),
                  ),
                ),
                Text('Page ${4 - (index % 4) + 4 * (index ~/ 4) - 1}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
