import 'package:flutter_test/flutter_test.dart';
import 'package:my_manga_editor/feature/manga/view/scene_unit_drag.dart';
import 'package:my_manga_editor_data/model/manga.dart';

void main() {
  final p1 = MangaPageId('p1');
  final p2 = MangaPageId('p2');

  SceneUnitDragData data({int index = 1, int unitCount = 3}) =>
      SceneUnitDragData(
        mangaId: MangaId('mid'),
        pageId: p1,
        pageNumber: 1,
        index: index,
        unitCount: unitCount,
        memoDeltaId: DeltaId('memo'),
        dialoguesDeltaId: DeltaId('d'),
      );

  group('sceneUnitDropIndex', () {
    test('同じページで元の位置の前後の挿入位置は並びが変わらないので null', () {
      expect(sceneUnitDropIndex(data(), p1, 1), isNull);
      expect(sceneUnitDropIndex(data(), p1, 2), isNull);
    });

    test('同じページのそれ以外の挿入位置はそのまま返す', () {
      expect(sceneUnitDropIndex(data(), p1, 0), 0);
      expect(sceneUnitDropIndex(data(), p1, 3), 3);
    });

    test('別のページではどの挿入位置でも返す', () {
      for (final slot in [0, 1, 2, 3]) {
        expect(sceneUnitDropIndex(data(), p2, slot), slot);
      }
    });
  });

  group('SceneUnitDragData.removesSourcePageWhenMovedTo', () {
    test('最後の 1 カットを別のページへ移すときだけ true', () {
      expect(data(index: 0, unitCount: 1).removesSourcePageWhenMovedTo(p2),
          isTrue);
      expect(data(index: 0, unitCount: 1).removesSourcePageWhenMovedTo(p1),
          isFalse);
      expect(data().removesSourcePageWhenMovedTo(p2), isFalse);
    });
  });
}
