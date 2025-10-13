import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/models/manga.dart';
import 'package:my_manga_editor/repositories/manga_providers.dart';

class StartPageSelector extends HookConsumerWidget {
  const StartPageSelector({
    super.key,
    required this.mangaId,
  });

  final MangaId mangaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manga = ref.watch(mangaProvider(mangaId));

    return switch (manga) {
      AsyncData(:final value) when value != null => DropdownButton(
          value: value.startPage,
          items: MangaStartPage.values
              .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text('${switch (e) {
                    MangaStartPage.left => '左',
                    MangaStartPage.right => '右',
                  }}始まり')))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              ref
                  .read(mangaProvider(mangaId).notifier)
                  .updateStartPage(value);
            }
          },
        ),
      _ => CircularProgressIndicator(),
    };
  }
}
