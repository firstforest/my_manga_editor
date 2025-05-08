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
import 'package:my_manga_editor/views/start_page_selector.dart';
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
    final mediaQuery = MediaQuery.of(context);
    final crossAxisCount = mediaQuery.size.width < 920 ? 2 : 4;
    final scrollController = useScrollController();
    final startPage = ref.watch(mangaNotifierProvider(mangaId)).maybeMap(
        orElse: () => MangaStartPage.left,
        data: (data) => data.value?.startPage ?? MangaStartPage.left);
    final list = ref.watch(mangaPageIdListProvider(mangaId)).maybeMap(
          orElse: () => <MangaPageId?>[],
          data: (data) {
            final pageIdList = data.value.map<MangaPageId?>((e) => e).toList();
            if (startPage == MangaStartPage.left) {
              pageIdList.insert(0, null);
            }
            return pageIdList;
          },
        );

    final generatedChildren = list
        .mapIndexed((index, id) => id != null
            ? MangaGridPageView(
                key: ValueKey('$id'),
                mangaPageId: id,
                pageNumber: switch (startPage) {
                  MangaStartPage.left => index,
                  MangaStartPage.right => index + 1,
                },
                startPage: startPage,
              )
            : SizedBox(
                key: ValueKey('no-$index'),
              ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ページ一覧表示'),
            SizedBox(
              width: 4.r,
            ),
            StartPageSelector(mangaId: mangaId),
          ],
        ),
      ),
      body: ReorderableBuilder<MangaPageId?>(
          scrollController: scrollController,
          onReorder: (ReorderedListFunction<MangaPageId?> reorder) {
            final newOrder = reorder(list);
            ref
                .read(mangaNotifierProvider(mangaId).notifier)
                .reorderPage(newOrder.nonNulls.toList(), 0, 0);
          },
          enableLongPress: false,
          children: generatedChildren,
          builder: (children) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: GridView(
                key: _key,
                padding: EdgeInsets.all(16.r),
                controller: scrollController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 8.r,
                  mainAxisSpacing: 24.r,
                  childAspectRatio: 2 / 3,
                ),
                children: children,
              ),
            );
          }),
    );
  }
}

class MangaGridPageView extends HookConsumerWidget {
  const MangaGridPageView({
    super.key,
    required this.mangaPageId,
    required this.pageNumber,
    required this.startPage,
  });

  final MangaPageId mangaPageId;
  final int pageNumber;
  final MangaStartPage startPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mangaPage = ref.watch(mangaPageNotifierProvider(mangaPageId));

    return Padding(
      padding: switch (startPage) {
        MangaStartPage.left => pageNumber.isOdd
            ? EdgeInsets.only(left: 16.r)
            : EdgeInsets.only(right: 16.r),
        MangaStartPage.right => pageNumber.isOdd
            ? EdgeInsets.only(right: 16.r)
            : EdgeInsets.only(left: 16.r),
      },
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: Card(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.r, horizontal: 8.r),
            child: Column(
              children: [
                Expanded(
                  child: mangaPage.map(
                    data: (mangaPage) {
                      final delta = ref.watch(deltaNotifierProvider(
                          mangaPage.value.dialoguesDelta));
                      return switch (delta.valueOrNull) {
                        Delta d when d.isNotEmpty => SingleChildScrollView(
                            child: Tategaki(
                              Document.fromDelta(d).toPlainText(),
                              style: GoogleFonts.shipporiAntique(height: 1.0),
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
                Text('Page $pageNumber'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
