import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/manga/model/manga.dart';
import 'package:my_manga_editor/feature/manga/repository/manga_repository.dart';

/// Widget that displays sync status for a manga
/// Shows sync state icon based on online/sync status
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({
    required this.mangaId,
    super.key,
  });

  final MangaId mangaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatusAsync = ref.watch(mangaRepositoryProvider).watchSyncStatus();

    return StreamBuilder(
      stream: syncStatusAsync,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final status = snapshot.data!;
        return _buildStatusWidget(context, status);
      },
    );
  }

  Widget _buildStatusWidget(BuildContext context, status) {
    // Determine state based on status fields
    if (!status.isOnline) {
      return const Tooltip(
        message: 'オフライン',
        child: Icon(
          Icons.cloud_off,
          color: Colors.grey,
          size: 20,
        ),
      );
    }

    if (status.isSyncing) {
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
    }

    if (status.pendingMangaIds.isNotEmpty) {
      return Tooltip(
        message: '同期待ち (${status.pendingMangaIds.length}件)',
        child: const Icon(
          Icons.cloud_upload,
          color: Colors.orange,
          size: 20,
        ),
      );
    }

    // Synced state
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
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Manual sync button widget
class ManualSyncButton extends ConsumerWidget {
  const ManualSyncButton({
    required this.mangaId,
    super.key,
  });

  final MangaId mangaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.sync),
      tooltip: '手動同期',
      onPressed: () async {
        await ref.read(mangaRepositoryProvider).forceSyncAll();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('同期を開始しました')),
          );
        }
      },
    );
  }
}
