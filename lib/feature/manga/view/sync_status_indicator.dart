import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/manga/model/manga.dart';
import 'package:my_manga_editor/feature/manga/model/sync_status.dart';
import 'package:my_manga_editor/feature/manga/provider/sync_state_notifier.dart';

/// Widget that displays sync status for a manga
/// Shows sync state icon and allows manual sync retry
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({
    required this.mangaId,
    super.key,
  });

  final MangaId mangaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(mangaSyncStatusProvider(mangaId));

    if (syncStatus == null) {
      // No sync status - not queued for sync yet
      return const SizedBox.shrink();
    }

    return _buildStatusWidget(context, ref, syncStatus);
  }

  Widget _buildStatusWidget(
    BuildContext context,
    WidgetRef ref,
    SyncStatus status,
  ) {
    switch (status.state) {
      case SyncState.synced:
        return Tooltip(
          message: status.lastSyncedAt != null
              ? '同期済み (${_formatDateTime(status.lastSyncedAt!)})'
              : '同期済み',
          child: const Icon(
            Icons.cloud_done,
            color: Colors.green,
            size: 20,
          ),
        );

      case SyncState.syncing:
        return const Tooltip(
          message: '同期中...',
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        );

      case SyncState.pending:
        return Tooltip(
          message: '同期待ち (${status.pendingOperations ?? 0}件)',
          child: const Icon(
            Icons.cloud_upload,
            color: Colors.orange,
            size: 20,
          ),
        );

      case SyncState.error:
        return Tooltip(
          message: '同期エラー: ${status.errorMessage ?? "不明なエラー"}',
          child: InkWell(
            onTap: () => _showErrorDialog(context, ref, status),
            child: const Icon(
              Icons.cloud_off,
              color: Colors.red,
              size: 20,
            ),
          ),
        );

      case SyncState.offline:
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

  void _showErrorDialog(
    BuildContext context,
    WidgetRef ref,
    SyncStatus status,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('同期エラー'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('クラウド同期中にエラーが発生しました。'),
            const SizedBox(height: 16),
            Text(
              'エラー詳細:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              status.errorMessage ?? '不明なエラー',
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(syncStateProvider.notifier)
                  .retryFailedSync(mangaId);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('再試行'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'たった今';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}時間前';
    } else {
      return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// Compact sync status indicator for list views
class CompactSyncStatusIndicator extends ConsumerWidget {
  const CompactSyncStatusIndicator({
    required this.mangaId,
    super.key,
  });

  final MangaId mangaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(mangaSyncStatusProvider(mangaId));

    if (syncStatus == null) {
      return const SizedBox.shrink();
    }

    return _buildCompactIndicator(syncStatus);
  }

  Widget _buildCompactIndicator(SyncStatus status) {
    IconData icon;
    Color color;

    switch (status.state) {
      case SyncState.synced:
        icon = Icons.cloud_done;
        color = Colors.green;
        break;
      case SyncState.syncing:
        icon = Icons.cloud_upload;
        color = Colors.blue;
        break;
      case SyncState.pending:
        icon = Icons.cloud_queue;
        color = Colors.orange;
        break;
      case SyncState.error:
        icon = Icons.cloud_off;
        color = Colors.red;
        break;
      case SyncState.offline:
        icon = Icons.cloud_off;
        color = Colors.grey;
        break;
    }

    return Icon(icon, color: color, size: 16);
  }
}

/// Manual sync trigger button
class ManualSyncButton extends ConsumerWidget {
  const ManualSyncButton({
    required this.mangaId,
    super.key,
  });

  final MangaId mangaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(mangaSyncStatusProvider(mangaId));
    final isSyncing = syncStatus?.state == SyncState.syncing;

    return IconButton(
      onPressed: isSyncing
          ? null
          : () => ref
              .read(syncStateProvider.notifier)
              .syncMangaManually(mangaId),
      icon: isSyncing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.cloud_sync),
      tooltip: isSyncing ? '同期中...' : '今すぐ同期',
    );
  }
}
