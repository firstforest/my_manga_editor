import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_providers.dart';

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
      data: (isOnline) => _buildStatusWidget(isOnline),
      loading: () => const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
      error: (error, _) => const Tooltip(
        message: 'エラー',
        child: Icon(
          Icons.error,
          color: Colors.red,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildStatusWidget(bool isOnline) {
    if (isOnline) {
      return const Tooltip(
        message: 'オンライン',
        child: Icon(
          Icons.cloud_done,
          color: Colors.green,
          size: 20,
        ),
      );
    } else {
      return const Tooltip(
        message: 'オフライン',
        child: Icon(
          Icons.cloud_off,
          color: Colors.grey,
          size: 20,
        ),
      );
    }
  }
}
