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
      child: Row(
        children: [
          Expanded(child: _buildChips(tags, selected, select)),
          const Padding(
            padding: EdgeInsets.only(left: 8, right: 16),
            child: _FilteredSummary(),
          ),
        ],
      ),
    );
  }

  Widget _buildChips(
    List<String> tags,
    TagFilter selected,
    void Function(TagFilter) select,
  ) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
    );
  }
}

/// 絞り込み後の作品数とページ数の合計。
class _FilteredSummary extends ConsumerWidget {
  const _FilteredSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mangaCount = ref.watch(filteredMangaListProvider).length;
    final pageTotal = ref.watch(filteredPageTotalProvider);

    final theme = Theme.of(context);
    return Center(
      child: Text(
        pageTotal == null
            ? '$mangaCount作品・ページ数を集計中'
            : '$mangaCount作品・計 $pageTotalページ',
        style: theme.textTheme.bodySmall
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
      // 横向きの ListView は子をバーの高さいっぱいに伸ばすので、チップは自然な高さで縦中央に置く
      child: Center(
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          // 選択中のチップを押しても選択は外れない (「すべて」に戻すには
          // 「すべて」を押す)。絞り込み無しの状態が 2 通りできるのを避ける。
          onSelected: (_) => onSelected(),
        ),
      ),
    );
  }
}
