import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_manga_editor/feature/app_info/app_links.dart';
import 'package:my_manga_editor/feature/app_info/app_reload.dart';
import 'package:my_manga_editor/feature/app_info/view/external_link.dart';

/// クライアントが最小サポートバージョン未満のときに全画面で表示する更新案内。
/// このページ以外への遷移は router の redirect でブロックされる。
class UpdateRequiredPage extends StatelessWidget {
  const UpdateRequiredPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = kIsWeb
        ? 'アプリが更新されました。ページを再読み込み（リロード）して最新版をご利用ください。'
        : 'アプリが更新されました。最新版に更新してからご利用ください。';

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.system_update,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  '更新が必要です',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                if (kIsWeb) ...[
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: reloadApp,
                    icon: const Icon(Icons.refresh),
                    label: const Text('再読み込み'),
                  ),
                ],
                const SizedBox(height: 24),
                const Divider(),
                const ExternalLinkTile(
                  icon: Icons.history,
                  label: '更新内容を見る',
                  description: '今回のリリースで変わった点',
                  url: AppLinks.releaseNotes,
                ),
                const ExternalLinkTile(
                  icon: Icons.bug_report_outlined,
                  label: '不具合報告・ご要望',
                  description: '再読み込みしても直らないときはこちら',
                  url: AppLinks.issues,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
