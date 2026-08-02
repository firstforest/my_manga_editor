import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/app_info/app_links.dart';
import 'package:my_manga_editor/feature/app_info/provider/app_info_provider.dart';
import 'package:my_manga_editor/feature/app_info/view/external_link.dart';

/// バージョンと問い合わせ先を出す「このアプリについて」ダイアログ。
Future<void> showAppInfoDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const AppInfoDialog(),
  );
}

class AppInfoDialog extends ConsumerWidget {
  const AppInfoDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final version = ref.watch(appVersionLabelProvider).value;

    return AlertDialog(
      title: const Text('このアプリについて'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('漫画制作用プロットエディター', style: theme.textTheme.bodyLarge),
            const SizedBox(height: 4),
            Text(
              version == null ? 'バージョンを取得中…' : 'バージョン $version',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            const ExternalLinkTile(
              icon: Icons.history,
              label: '更新履歴',
              description: 'これまでの変更点を見る',
              url: AppLinks.releaseNotes,
            ),
            const ExternalLinkTile(
              icon: Icons.bug_report_outlined,
              label: '不具合報告・ご要望',
              description: 'GitHub の Issue で受け付けています',
              url: AppLinks.issues,
            ),
            const ExternalLinkTile(
              icon: Icons.alternate_email,
              label: 'X (${AppLinks.xAccount})',
              description: 'GitHub を使わない場合はこちらへ',
              url: AppLinks.x,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
      ],
    );
  }
}
