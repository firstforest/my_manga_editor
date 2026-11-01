import 'package:flutter/material.dart';

enum PageAction {
  moveBackward,
  moveForward,
  delete,
}

/// ページのツールバーに置く「︙」メニュー（前後への移動と削除）
class PageMenuButton extends StatelessWidget {
  const PageMenuButton({
    super.key,
    required this.pageIndex,
    required this.pageCount,
    required this.onMovePage,
    required this.onDelete,
  });

  /// 1 始まりのページ番号
  final int pageIndex;
  final int pageCount;
  final ValueChanged<int> onMovePage;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PageAction>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'ページの操作',
      onSelected: (action) {
        switch (action) {
          case PageAction.moveBackward:
            onMovePage(-1);
          case PageAction.moveForward:
            onMovePage(1);
          case PageAction.delete:
            onDelete();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: PageAction.moveBackward,
          enabled: pageIndex > 1,
          child: const ListTile(
            leading: Icon(Icons.arrow_upward),
            title: Text('前のページへ移動'),
          ),
        ),
        PopupMenuItem(
          value: PageAction.moveForward,
          enabled: pageIndex < pageCount,
          child: const ListTile(
            leading: Icon(Icons.arrow_downward),
            title: Text('次のページへ移動'),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: PageAction.delete,
          child: ListTile(
            leading: Icon(Icons.delete),
            title: Text('ページを削除'),
          ),
        ),
      ],
    );
  }
}
