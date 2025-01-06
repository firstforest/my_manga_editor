import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/models/manga.dart';
import 'package:my_manga_editor/views/manga_page_list.dart';
import 'package:my_manga_editor/views/workspace.dart';

class MangaEditWidget extends HookConsumerWidget {
  const MangaEditWidget({
    super.key,
    required this.manga,
    required this.scrollController,
  });

  final Manga manga;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      key: ValueKey(manga.id),
      children: [
        Expanded(
          flex: 2,
          child: Workspace(
            key: ValueKey(manga.id),
            deltaId: manga.ideaMemo,
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
    );
  }
}
