import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    // 入力欄を閉じるのは追加できたときだけ。弾かれたときは入力内容を
    // 残したままにして、打ち直せるようにする。
    Future<void> add(String value) async {
      if (value.trim().isEmpty) {
        // 空文字は追加せず閉じる (AC-1.4)
        isAdding.value = false;
        return;
      }
      // 大文字小文字だけが違う既存タグがあれば保存済みの表記で追加し、
      // 同じつもりのタグが別表記で分裂するのを防ぐ
      final query = value.trim().toLowerCase();
      final tag = ref
              .read(tagListProvider)
              .firstWhereOrNull((t) => t.toLowerCase() == query) ??
          value;
      try {
        await ref.read(mangaProvider(manga.id).notifier).addTag(tag);
      } on ValidationException catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_messageFor(e))),
        );
        return;
      } catch (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('タグの保存に失敗しました')),
        );
        return;
      }
      if (!context.mounted) return;
      isAdding.value = false;
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
              onCommit: add,
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
    // Repository の例外は英語のメッセージを持つので、利用者向けの文言はここで作る。
    // 何に引っかかったかは例外の型で見分ける。メッセージ本文を読むと、
    // Repository 側の文言が変わっただけで無関係な案内を出してしまう。
    return switch (e) {
      TagLengthException(:final maxLength) => 'タグは$maxLength文字以内で入力してください',
      TagLimitException(:final maxCount) => 'タグは1作品につき$maxCount個までです',
      _ => 'このタグは追加できません',
    };
  }
}

class _TagInput extends HookWidget {
  const _TagInput({
    required this.suggestions,
    required this.onCommit,
    required this.onCancel,
  });

  final List<String> suggestions;

  /// 候補をタップしたとき、または Enter で入力中の文字列を確定したときに、
  /// 確定したタグ名を渡して呼ばれる。
  final ValueChanged<String> onCommit;

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    // Tab での補完と候補のタップはどちらも onSelected を通る。
    // 補完のときは入力欄に候補を入れるだけで、確定はしない。
    final completing = useRef(false);

    return SizedBox(
      width: 200,
      child: Autocomplete<String>(
        optionsBuilder: (value) {
          final query = value.text.toLowerCase();
          if (query.isEmpty) return suggestions;
          // 大文字小文字の違いで候補から漏れると、利用者が同じつもりの
          // タグを別表記で作ってしまう。マッチ判定だけ無視し、
          // 入力されるのは保存済みの表記そのものにする。
          return suggestions.where((t) => t.toLowerCase().contains(query));
        },
        onSelected: (option) {
          if (completing.value) return;
          onCommit(option);
        },
        fieldViewBuilder:
            (context, controller, focusNode, selectHighlightedOption) => Focus(
          canRequestFocus: false,
          skipTraversal: true,
          // Tab でハイライト中の候補を入力欄に補完する。
          // 候補が無ければ何もしない (フォーカス移動もしない)。
          onKeyEvent: (_, event) {
            if (event is! KeyDownEvent ||
                event.logicalKey != LogicalKeyboardKey.tab) {
              return KeyEventResult.ignored;
            }
            completing.value = true;
            selectHighlightedOption();
            completing.value = false;
            return KeyEventResult.handled;
          },
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: true,
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(
              isDense: true,
              hintText: 'タグを入力',
            ),
            // Enter は候補が出ていても入力中の文字列で確定する。
            // 既存タグの一部にあたる名前 (「連載:ヒーロー」がある中の「連載」) も作れるようにする。
            onSubmitted: onCommit,
            // フォーカスが外れたら入力を破棄して閉じる。
            // 入力途中の文字列を勝手にタグにしない。
            onTapOutside: (_) => onCancel(),
          ),
        ),
      ),
    );
  }
}
