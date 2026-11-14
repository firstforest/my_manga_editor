import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// メモに貼った画像 (`{"insert": {"image": "<URL>"}}`) を本文中に描く。
class MemoImageEmbedBuilder extends EmbedBuilder {
  const MemoImageEmbedBuilder();

  /// 画像の高さの上限。縦長の画像でメモが埋まらないようにする。
  static const maxHeight = 320.0;

  @override
  String get key => BlockEmbed.imageType;

  @override
  bool get expanded => false;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final url = embedContext.node.value.data as String;
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: maxHeight),
          child: Image.network(
            url,
            semanticLabel: 'メモの画像',
            fit: BoxFit.contain,
            // Storage のバケットは CORS を設定していないため、
            // Web では最初から <img> 要素で読み込む
            webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : const SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(child: CircularProgressIndicator()),
                  ),
            errorBuilder: (context, _, __) =>
                const _EmbedNotice(label: '画像を読み込めませんでした'),
          ),
        ),
      ),
    );
  }
}

/// このバージョンが知らない種類の埋め込み。
/// 新しいバージョンで書いたメモを開いても、エディタごと落ちないようにする。
class UnknownEmbedBuilder extends EmbedBuilder {
  const UnknownEmbedBuilder();

  @override
  String get key => '';

  @override
  bool get expanded => false;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    return const _EmbedNotice(label: 'このバージョンでは表示できない内容です');
  }
}

class _EmbedNotice extends StatelessWidget {
  const _EmbedNotice({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Icon(Icons.broken_image_outlined,
              size: 16, color: colorScheme.onSurfaceVariant),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
