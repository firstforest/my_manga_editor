import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_providers.dart';
import 'package:my_manga_editor/router.dart';
import 'package:my_manga_editor_data/model/manga.dart';

/// カード上のタグ表示。
///
/// カードの高さが作品ごとにばらつかないよう、表示は先頭 3 個までに揃え、
/// 残りは `+N` で件数だけ示す。
class _TagRow extends StatelessWidget {
  const _TagRow({required this.tags});

  static const _maxVisible = 3;

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final visible = tags.take(_maxVisible).toList();
    final hidden = tags.length - visible.length;
    final scheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final tag in visible)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: 10,
                color: scheme.onSecondaryContainer,
              ),
            ),
          ),
        if (hidden > 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '+$hidden',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ),
      ],
    );
  }
}

class KanbanCard extends ConsumerWidget {
  const KanbanCard({super.key, required this.manga});

  final Manga manga;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delta =
        ref.watch(deltaProvider(manga.id, manga.ideaMemoDeltaId)).value;
    final pageCount = ref.watch(mangaPageIdListProvider(manga.id)).maybeMap(
          data: (data) => data.value.length,
          orElse: () => 0,
        );

    final card = _buildCard(context, ref, delta, pageCount);

    return Draggable<String>(
      data: manga.id.id,
      // ドラッグ中の影は操作できないので、同じボタンが 2 つ読まれないよう外す
      feedback: ExcludeSemantics(
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 280,
            child: card,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: card,
      ),
      child: card,
    );
  }

  Widget _buildCard(
      BuildContext context, WidgetRef ref, Delta? delta, int pageCount) {
    final previewText = delta != null && delta.isNotEmpty
        ? Document.fromDelta(delta).toPlainText()
        : '';

    void open() => ref.read(routerProvider).go('/manga/${manga.id.id}');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      // Card がまとめたノードに削除ボタンまで入らないよう、まとめは下で作る
      semanticContainer: false,
      child: Stack(
        children: [
          // カード本体は作品を開くボタン。中の文字をつないだラベルだと
          // メモのプレビューまで読まれるので、ラベルと値を明示して中は読ませない。
          // 中を読ませないと InkWell のタップも外れるので、onTap もここで渡す
          Semantics(
            container: true,
            button: true,
            label: manga.name,
            value: _semanticsValue(pageCount),
            onTap: open,
            excludeSemantics: true,
            child: _buildBody(open, previewText, pageCount),
          ),
          // 削除ボタンは本体のボタンの中に入れ子にすると、スクリーンリーダーで
          // 単独のボタンとして届かなくなるので、本体の外に重ねる
          Positioned(
            top: 12,
            right: 12,
            child: SizedBox(
              width: _deleteButtonSize,
              height: _deleteButtonSize,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 16,
                onPressed: () {
                  ref.read(mangaProvider(manga.id).notifier).delete();
                },
                tooltip: '作品を削除',
                icon: const Icon(Icons.delete, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _deleteButtonSize = 24.0;

  String _semanticsValue(int pageCount) {
    final pages = 'ページ数: $pageCount';
    if (manga.tags.isEmpty) {
      return pages;
    }
    return '$pages、タグ: ${manga.tags.join('、')}';
  }

  Widget _buildBody(VoidCallback onTap, String previewText, int pageCount) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    manga.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 上に重ねる削除ボタンの場所を空けておく
                const SizedBox(
                  width: _deleteButtonSize,
                  height: _deleteButtonSize,
                ),
              ],
            ),
            if (previewText.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                previewText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'ページ数: $pageCount',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
            if (manga.tags.isNotEmpty) ...[
              const SizedBox(height: 6),
              _TagRow(tags: manga.tags),
            ],
          ],
        ),
      ),
    );
  }
}
