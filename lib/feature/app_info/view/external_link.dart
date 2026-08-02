import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 外部ブラウザで [url] を開く。
/// 開けなかった場合は URL を SnackBar で見せ、手でコピーできるようにする。
Future<void> openExternalLink(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  var opened = false;
  try {
    opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  } on Exception {
    opened = false;
  }
  if (!opened) {
    messenger?.showSnackBar(
      SnackBar(content: Text('リンクを開けませんでした: $url')),
    );
  }
}

/// 外部リンクを 1 行で見せるタイル。アプリ情報ダイアログと更新案内で共有する。
class ExternalLinkTile extends StatelessWidget {
  const ExternalLinkTile({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    required this.url,
  });

  final IconData icon;
  final String label;
  final String description;
  final String url;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(description),
      trailing: const Icon(Icons.open_in_new, size: 16),
      onTap: () => openExternalLink(context, url),
    );
  }
}
