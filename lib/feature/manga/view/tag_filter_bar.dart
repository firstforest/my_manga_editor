import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/manga/provider/tag_providers.dart';

/// 作品一覧をタグで絞り込むバー。
///
/// `すべて` / `タグなし` の後に、存在するタグを昇順で並べる。
/// タグが増えても一覧の高さを圧迫しないよう横スクロールさせる。
class TagFilterBar extends ConsumerWidget {
  const TagFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(tagListProvider);
    final selected = ref.watch(tagFilterProvider);

    void select(TagFilter filter) {
      ref.read(tagFilterProvider.notifier).select(filter);
    }

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          _FilterChip(
            label: 'すべて',
            selected: selected is TagFilterAll,
            onSelected: () => select(const TagFilter.all()),
          ),
          _FilterChip(
            label: 'タグなし',
            selected: selected is TagFilterUntagged,
            onSelected: () => select(const TagFilter.untagged()),
          ),
          for (final tag in tags)
            _FilterChip(
              label: tag,
              selected: selected is TagFilterTag && selected.name == tag,
              onSelected: () => select(TagFilter.tag(tag)),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        // 選択中のチップを押しても選択は外れない (「すべて」に戻すには
        // 「すべて」を押す)。絞り込み無しの状態が 2 通りできるのを避ける。
        onSelected: (_) => onSelected(),
      ),
    );
  }
}
