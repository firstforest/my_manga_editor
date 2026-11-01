import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_providers.dart';
import 'package:my_manga_editor_common/delta_text.dart';
import 'package:my_manga_editor_data/model/manga.dart';

/// ドラッグで運ぶカットの情報
@immutable
class SceneUnitDragData {
  const SceneUnitDragData({
    required this.mangaId,
    required this.pageId,
    required this.pageNumber,
    required this.index,
    required this.unitCount,
    required this.memoDeltaId,
    required this.dialoguesDeltaId,
  });

  final MangaId mangaId;
  final MangaPageId pageId;

  /// 確認ダイアログに出す元ページの番号
  final int pageNumber;
  final int index;

  /// 元ページのカット数。1 なら別ページへ移すと元ページが削除される
  final int unitCount;
  final DeltaId memoDeltaId;
  final DeltaId dialoguesDeltaId;

  bool removesSourcePageWhenMovedTo(MangaPageId toPageId) =>
      unitCount == 1 && toPageId != pageId;
}

/// [toPageId] の挿入位置 [slot]（0..カット数）へ落としたとき、
/// 並びが変わるなら移動先の挿入位置を、変わらないなら null を返す。
int? sceneUnitDropIndex(
    SceneUnitDragData data, MangaPageId toPageId, int slot) {
  if (data.pageId == toPageId &&
      (slot == data.index || slot == data.index + 1)) {
    return null;
  }
  return slot;
}

/// ポインタが表示領域の上下端に近い間、[position] をスクロールし続ける
class EdgeAutoScroller {
  static const _edge = 48.0;
  static const _maxStep = 16.0;

  ScrollPosition? _position;
  double _step = 0;
  Timer? _timer;

  /// [viewport] 内の [globalPointer] の位置からスクロール速度を決める
  void update(
      ScrollPosition position, RenderBox viewport, Offset globalPointer) {
    final y = viewport.globalToLocal(globalPointer).dy;
    final height = viewport.size.height;
    final edge = _edge.clamp(0.0, height / 2);
    double step = 0;
    if (y < edge) {
      step = -_maxStep * (edge - y).clamp(0.0, edge) / edge;
    } else if (y > height - edge) {
      step = _maxStep * (y - (height - edge)).clamp(0.0, edge) / edge;
    }
    _position = position;
    _step = step;
    if (step == 0) {
      stop();
    } else {
      _timer ??=
          Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
    }
  }

  void _tick() {
    final position = _position;
    if (position == null || !position.hasPixels) {
      stop();
      return;
    }
    final next = (position.pixels + _step)
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    if (next == position.pixels) {
      return;
    }
    position.jumpTo(next);
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}

/// ページリスト全体を包み、カットのドラッグ中にリストの上下端で自動スクロールする。
///
/// ドラッグ元のカットはスクロールで画面外へ出ると破棄されるため、
/// ドラッグ元の Draggable ではなく、ポインタを押した時点の祖先であるこの Listener で
/// ポインタの移動と離しを受け取る。
class CutDragScope extends HookWidget {
  const CutDragScope({
    super.key,
    required this.scrollController,
    required this.child,
  });

  final ScrollController scrollController;
  final Widget child;

  static ValueNotifier<bool>? draggingOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_CutDragScope>()?.dragging;

  @override
  Widget build(BuildContext context) {
    final dragging = useValueNotifier(false);
    final scroller = useMemoized(EdgeAutoScroller.new);
    useEffect(() => scroller.stop, const []);

    void end() {
      dragging.value = false;
      scroller.stop();
    }

    return _CutDragScope(
      dragging: dragging,
      child: Listener(
        onPointerMove: (event) {
          if (!dragging.value || !scrollController.hasClients) return;
          final box = context.findRenderObject();
          if (box is! RenderBox) return;
          scroller.update(scrollController.position, box, event.position);
        },
        onPointerUp: (_) => end(),
        onPointerCancel: (_) => end(),
        child: child,
      ),
    );
  }
}

class _CutDragScope extends InheritedWidget {
  const _CutDragScope({required this.dragging, required super.child});

  final ValueNotifier<bool> dragging;

  @override
  bool updateShouldNotify(_CutDragScope oldWidget) =>
      dragging != oldWidget.dragging;
}

/// カットのドラッグハンドル。テキスト欄は包まないので、
/// 入力欄内のドラッグは範囲選択のまま
class SceneUnitDragHandle extends StatelessWidget {
  const SceneUnitDragHandle({
    super.key,
    required this.data,
    this.onDragging,
  });

  final SceneUnitDragData data;

  /// ドラッグの開始・終了を伝える（元の位置を薄く表示するため）
  final ValueChanged<bool>? onDragging;

  @override
  Widget build(BuildContext context) {
    final dragging = CutDragScope.draggingOf(context);
    void setDragging(bool value) {
      dragging?.value = value;
      onDragging?.call(value);
    }

    final icon = Icon(Icons.drag_indicator, size: 16.r, color: Colors.black45);
    return Draggable<SceneUnitDragData>(
      data: data,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: _SceneUnitDragFeedback(data: data),
      childWhenDragging: Opacity(opacity: 0.3, child: icon),
      onDragStarted: () => setDragging(true),
      onDragEnd: (_) => setDragging(false),
      child: Tooltip(
        message: 'ドラッグしてカットを移動',
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: Padding(padding: EdgeInsets.all(4.r), child: icon),
        ),
      ),
    );
  }
}

class _SceneUnitDragFeedback extends ConsumerWidget {
  const _SceneUnitDragFeedback({required this.data});

  final SceneUnitDragData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delta =
        ref.watch(deltaProvider(data.mangaId, data.dialoguesDeltaId)).value;
    final firstLine = delta == null
        ? ''
        : deltaToPlainText(delta)
            .split('\n')
            .firstWhere((line) => line.trim().isNotEmpty, orElse: () => '');
    return Transform.translate(
      offset: const Offset(12, 12),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 240,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            firstLine.isEmpty ? '（セリフなし）' : firstLine,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

/// カット 1 つを包み、上半分なら前、下半分なら後ろへの挿入位置として受け付ける。
/// ページ内のカット欄がスクロールできるときは、その上下端で自動スクロールする
class SceneUnitDropTarget extends StatefulWidget {
  const SceneUnitDropTarget({
    super.key,
    required this.pageId,
    required this.index,
    required this.onDrop,
    required this.child,
  });

  final MangaPageId pageId;
  final int index;

  /// 並びが変わる位置に落とされたときだけ、移動先の挿入位置を渡して呼ぶ
  final void Function(SceneUnitDragData data, int toIndex) onDrop;
  final Widget child;

  @override
  State<SceneUnitDropTarget> createState() => _SceneUnitDropTargetState();
}

class _SceneUnitDropTargetState extends State<SceneUnitDropTarget> {
  final _scroller = EdgeAutoScroller();
  int? _slot;

  @override
  void dispose() {
    _scroller.stop();
    super.dispose();
  }

  int? _dropIndexAt(SceneUnitDragData data, Offset globalPointer) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    final y = box.globalToLocal(globalPointer).dy;
    final slot = y < box.size.height / 2 ? widget.index : widget.index + 1;
    return sceneUnitDropIndex(data, widget.pageId, slot);
  }

  void _autoScroll(Offset globalPointer) {
    final scrollable = Scrollable.maybeOf(context);
    final viewport = scrollable?.context.findRenderObject();
    if (scrollable == null || viewport is! RenderBox) return;
    _scroller.update(scrollable.position, viewport, globalPointer);
  }

  void _clear() {
    _scroller.stop();
    if (_slot != null) {
      setState(() => _slot = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<SceneUnitDragData>(
      onMove: (details) {
        // pointerDragAnchorStrategy なので details.offset はポインタの位置
        _autoScroll(details.offset);
        final slot = _dropIndexAt(details.data, details.offset);
        if (slot != _slot) {
          setState(() => _slot = slot);
        }
      },
      onLeave: (_) => _clear(),
      onAcceptWithDetails: (details) {
        final toIndex = _dropIndexAt(details.data, details.offset);
        _clear();
        if (toIndex != null) {
          widget.onDrop(details.data, toIndex);
        }
      },
      builder: (context, candidates, rejected) {
        final slot = candidates.isEmpty ? null : _slot;
        return Stack(
          // カット欄の残りを均等に分けて伸ばす親の最小高さを、子へそのまま渡す
          fit: StackFit.passthrough,
          clipBehavior: Clip.none,
          children: [
            widget.child,
            if (slot != null)
              Positioned(
                left: 0,
                right: 0,
                top: slot == widget.index ? -3.r : null,
                bottom: slot == widget.index ? null : -3.r,
                child: IgnorePointer(
                  child: Container(
                    height: 3.r,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
