import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_providers.dart';
import 'package:my_manga_editor/theme/app_theme.dart';

/// Widget that displays online/offline status
/// Shows connection state icon based on network connectivity
class OnlineStatusIndicator extends ConsumerWidget {
  const OnlineStatusIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onlineStatusAsync = ref.watch(onlineStatusProvider);

    return onlineStatusAsync.when(
      data: (isOnline) => _buildStatusWidget(context, isOnline),
      loading: () => const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
      error: (error, _) => Tooltip(
        message: 'エラー',
        child: Icon(
          Icons.error,
          color: Theme.of(context).colorScheme.error,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildStatusWidget(BuildContext context, bool isOnline) {
    if (isOnline) {
      return Tooltip(
        message: 'オンライン',
        child: Icon(
          Icons.cloud_done,
          color: AppTokens.of(context).success,
          size: 20,
        ),
      );
    } else {
      return Tooltip(
        message: 'オフライン',
        child: Icon(
          Icons.cloud_off,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 20,
        ),
      );
    }
  }
}
