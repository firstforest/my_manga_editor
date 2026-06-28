import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
          child: Padding(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
