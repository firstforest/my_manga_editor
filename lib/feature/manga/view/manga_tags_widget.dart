import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_providers.dart';
import 'package:my_manga_editor/feature/manga/provider/tag_providers.dart';
import 'package:my_manga_editor_data/repository/exceptions.dart';
import 'package:my_manga_editor_data/model/manga.dart';

/// 編集画面のタグ編集欄。
///
/// 付いているタグをチップで並べ、末尾の「＋タグ」から追加する。
/// 追加入力では既存のタグを候補に出す。同じものを指す表記ゆれ
/// (全半角・大文字小文字) は別タグとして扱うため、候補から選んでもらうことで
/// タグが分裂するのを防ぐ。
class MangaTagsWidget extends HookConsumerWidget {
  const MangaTagsWidget({super.key, required this.manga});

  final Manga manga;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdding = useState(false);

    Future<void> add(String value) async {
      isAdding.value = false;
      if (value.trim().isEmpty) return;
      try {
        await ref.read(mangaProvider(manga.id).notifier).addTag(value);
      } on ValidationException catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_messageFor(e))),
        );
      } catch (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('タグの保存に失敗しました')),
        );
      }
    }

    Future<void> remove(String tag) async {
      try {
        await ref.read(mangaProvider(manga.id).notifier).removeTag(tag);
      } catch (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('タグの保存に失敗しました')),
        );
      }
    }

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final tag in manga.tags)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Chip(
                label: Text(tag, style: const TextStyle(fontSize: 12)),
                onDeleted: () => remove(tag),
                deleteButtonTooltipMessage: '$tag を外す',
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          if (isAdding.value)
            _TagInput(
              // 自分に既に付いているタグは候補に出さない
              suggestions: ref
                  .watch(tagListProvider)
                  .where((t) => !manga.tags.contains(t))
                  .toList(),
              onSubmitted: add,
              onCancel: () => isAdding.value = false,
            )
          else
            ActionChip(
              avatar: const Icon(Icons.add, size: 14),
              label: const Text('タグ', style: TextStyle(fontSize: 12)),
              onPressed: () => isAdding.value = true,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
        ],
      ),
    );
  }

  String _messageFor(ValidationException e) {
    // Repository は英語のメッセージを持つので、利用者向けの文言はここで作る
    if (e.message.contains('Too many tags')) {
      return 'タグは1作品につき20個までです';
    }
    return 'タグは30文字以内で入力してください';
  }
}

class _TagInput extends HookWidget {
  const _TagInput({
    required this.suggestions,
    required this.onSubmitted,
    required this.onCancel,
  });

  final List<String> suggestions;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Autocomplete<String>(
        optionsBuilder: (value) {
          if (value.text.isEmpty) return suggestions;
          return suggestions.where((t) => t.contains(value.text));
        },
        onSelected: onSubmitted,
        fieldViewBuilder:
            (context, controller, focusNode, onFieldSubmitted) => TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: true,
          style: const TextStyle(fontSize: 14),
          decoration: const InputDecoration(
            isDense: true,
            hintText: 'タグを入力',
          ),
          onSubmitted: onSubmitted,
          // フォーカスが外れたら入力を破棄して閉じる。
          // 入力途中の文字列を勝手にタグにしない。
          onTapOutside: (_) => onCancel(),
        ),
      ),
    );
  }
}
