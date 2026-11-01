import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor_data/repository/manga_repository.dart';
import 'package:my_manga_editor_data/service/connectivity_service.dart';
import 'package:my_manga_editor_data/service/firebase/auth_service.dart';
import 'package:my_manga_editor_data/service/firebase/firebase_service.dart';
import 'package:my_manga_editor_data/repository/exceptions.dart';
import 'package:my_manga_editor_data/service/firebase/model/cloud_delta.dart';
import 'package:my_manga_editor_data/service/firebase/model/cloud_manga_page.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseService>(),
  MockSpec<AuthService>(),
  MockSpec<ConnectivityService>(),
  MockSpec<User>(),
  MockSpec<FirebaseBatchWrapper>(),
])
import 'manga_repository_scene_unit_test.mocks.dart';

Map<String, dynamic> _unit(String name) => {
      'dialoguesDeltaId': '$name-d',
      'stageDirectionDeltaId': '$name-s',
    };

CloudMangaPage _cloudPage(List<Map<String, dynamic>> units,
    {String id = 'pid'}) {
  final now = DateTime(2026, 1, 1);
  return CloudMangaPage(
    id: id,
    mangaId: 'mid',
    pageIndex: 0,
    createdAt: now,
    updatedAt: now,
    memoDeltaId: '$id-memo',
    sceneUnits: units,
  );
}

void main() {
  late MockFirebaseService firebase;
  late MangaRepository repository;

  setUp(() {
    firebase = MockFirebaseService();
    final auth = MockAuthService();
    final connectivity = MockConnectivityService();
    when(connectivity.onConnectivityChanged())
        .thenAnswer((_) => const Stream<bool>.empty());
    when(connectivity.isOnline()).thenAnswer((_) async => true);

    final user = MockUser();
    when(user.uid).thenReturn('uid');
    when(auth.currentUser).thenReturn(user);

    when(firebase.fetchMangaPage('mid', 'pid')).thenAnswer(
        (_) async => _cloudPage([_unit('a'), _unit('b'), _unit('c')]));

    repository = MangaRepository(
      firebaseService: firebase,
      authService: auth,
      connectivityService: connectivity,
    );
  });

  List<Map<String, dynamic>> savedUnits() {
    final captured =
        verify(firebase.updateMangaPage('mid', 'pid', captureAny)).captured;
    return (captured.single as Map<String, dynamic>)['sceneUnits']
        as List<Map<String, dynamic>>;
  }

  List<String?> dialogueIds(List<Map<String, dynamic>> units) =>
      units.map((u) => u['dialoguesDeltaId'] as String?).toList();

  group('MangaRepository.addSceneUnit', () {
    setUp(() {
      var count = 0;
      when(firebase.createDelta('mid', any))
          .thenAnswer((_) async => 'new${count++}');
    });

    test('index を省略すると末尾に追加する', () async {
      await repository.addSceneUnit(MangaId('mid'), MangaPageId('pid'));

      expect(dialogueIds(savedUnits()), ['a-d', 'b-d', 'c-d', 'new0']);
    });

    test('index を指定するとその位置に挿入する', () async {
      await repository.addSceneUnit(MangaId('mid'), MangaPageId('pid'),
          index: 1);

      final units = savedUnits();
      expect(dialogueIds(units), ['a-d', 'new0', 'b-d', 'c-d']);
      expect(units[1]['stageDirectionDeltaId'], 'new1');
    });

    test('先頭に挿入できる', () async {
      await repository.addSceneUnit(MangaId('mid'), MangaPageId('pid'),
          index: 0);

      expect(dialogueIds(savedUnits()), ['new0', 'a-d', 'b-d', 'c-d']);
    });
  });

  group('MangaRepository.reorderSceneUnit', () {
    test('下へ移動する', () async {
      await repository.reorderSceneUnit(
          MangaId('mid'), MangaPageId('pid'), 0, 1);

      expect(dialogueIds(savedUnits()), ['b-d', 'a-d', 'c-d']);
    });

    test('上へ移動する', () async {
      await repository.reorderSceneUnit(
          MangaId('mid'), MangaPageId('pid'), 2, 0);

      expect(dialogueIds(savedUnits()), ['c-d', 'a-d', 'b-d']);
    });

    test('範囲外や同じ位置への移動では保存しない', () async {
      await repository.reorderSceneUnit(
          MangaId('mid'), MangaPageId('pid'), 0, -1);
      await repository.reorderSceneUnit(
          MangaId('mid'), MangaPageId('pid'), 2, 3);
      await repository.reorderSceneUnit(
          MangaId('mid'), MangaPageId('pid'), 1, 1);

      verifyNever(firebase.updateMangaPage(any, any, any));
    });
  });

  group('MangaRepository.moveSceneUnit', () {
    late MockFirebaseBatchWrapper batch;

    CloudDelta delta(String id, String pageId) {
      final now = DateTime(2026, 1, 1);
      return CloudDelta(
        id: id,
        mangaId: 'mid',
        ops: const [],
        fieldName: 'dialoguesDelta',
        pageId: pageId,
        createdAt: now,
        updatedAt: now,
      );
    }

    setUp(() {
      batch = MockFirebaseBatchWrapper();
      when(firebase.batch()).thenReturn(batch);
      when(firebase.fetchMangaPage('mid', 'p2')).thenAnswer(
          (_) async => _cloudPage([_unit('x'), _unit('y')], id: 'p2'));
      when(firebase.fetchMangaPage('mid', 'solo')).thenAnswer(
          (_) async => _cloudPage([_unit('s')], id: 'solo'));
      when(firebase.fetchDeltas('mid')).thenAnswer((_) async => [
            delta('solo-memo', 'solo'),
            delta('s-d', 'solo'),
            delta('s-s', 'solo'),
            delta('pid-memo', 'pid'),
            delta('a-d', 'pid'),
          ]);
    });

    List<Map<String, dynamic>> batchedUnits(String pageId) {
      final captured =
          verify(batch.updatePage('mid', pageId, captureAny)).captured;
      return (captured.single as Map<String, dynamic>)['sceneUnits']
          as List<Map<String, dynamic>>;
    }

    test('同じページ内では取り除いた後の位置に読み替えて並べ替える', () async {
      // スロット 3 (末尾) へ先頭のカットを運ぶ
      final deleted = await repository.moveSceneUnit(
        mangaId: MangaId('mid'),
        fromPageId: MangaPageId('pid'),
        fromIndex: 0,
        toPageId: MangaPageId('pid'),
        toIndex: 3,
      );

      expect(deleted, isFalse);
      expect(dialogueIds(savedUnits()), ['b-d', 'c-d', 'a-d']);
      verifyNever(firebase.batch());
    });

    test('同じページ内で元の位置の前後のスロットに置いても保存しない', () async {
      for (final slot in [1, 2]) {
        await repository.moveSceneUnit(
          mangaId: MangaId('mid'),
          fromPageId: MangaPageId('pid'),
          fromIndex: 1,
          toPageId: MangaPageId('pid'),
          toIndex: slot,
        );
      }

      verifyNever(firebase.updateMangaPage(any, any, any));
    });

    test('別のページの指定位置へ移し、Delta の pageId を書き換える', () async {
      final deleted = await repository.moveSceneUnit(
        mangaId: MangaId('mid'),
        fromPageId: MangaPageId('pid'),
        fromIndex: 1,
        toPageId: MangaPageId('p2'),
        toIndex: 0,
      );

      expect(deleted, isFalse);
      expect(dialogueIds(batchedUnits('pid')), ['a-d', 'c-d']);
      expect(dialogueIds(batchedUnits('p2')), ['b-d', 'x-d', 'y-d']);
      verify(batch.updateDelta('mid', 'b-d', {'pageId': 'p2'})).called(1);
      verify(batch.updateDelta('mid', 'b-s', {'pageId': 'p2'})).called(1);
      verify(batch.commit()).called(1);
      verifyNever(batch.deletePage(any, any));
      verifyNever(batch.deleteDelta(any, any));
      verifyNever(firebase.updateMangaPage(any, any, any));
    });

    test('移動先の末尾へ移せる', () async {
      await repository.moveSceneUnit(
        mangaId: MangaId('mid'),
        fromPageId: MangaPageId('pid'),
        fromIndex: 0,
        toPageId: MangaPageId('p2'),
        toIndex: 2,
      );

      expect(dialogueIds(batchedUnits('p2')), ['x-d', 'y-d', 'a-d']);
    });

    test('最後の 1 カットを移すと元ページと残りの Delta を同じ batch で削除する', () async {
      final deleted = await repository.moveSceneUnit(
        mangaId: MangaId('mid'),
        fromPageId: MangaPageId('solo'),
        fromIndex: 0,
        toPageId: MangaPageId('p2'),
        toIndex: 1,
      );

      expect(deleted, isTrue);
      expect(dialogueIds(batchedUnits('p2')), ['x-d', 's-d', 'y-d']);
      verify(batch.deletePage('mid', 'solo')).called(1);
      verify(batch.deleteDelta('mid', 'solo-memo')).called(1);
      verifyNever(batch.deleteDelta('mid', 's-d'));
      verifyNever(batch.deleteDelta('mid', 's-s'));
      verifyNever(batch.deleteDelta('mid', 'pid-memo'));
      verifyNever(batch.updatePage('mid', 'solo', any));
      verify(batch.updateDelta('mid', 's-d', {'pageId': 'p2'})).called(1);
      verify(batch.commit()).called(1);
    });

    test('index が範囲外なら何も書かない', () async {
      await repository.moveSceneUnit(
        mangaId: MangaId('mid'),
        fromPageId: MangaPageId('pid'),
        fromIndex: 3,
        toPageId: MangaPageId('p2'),
        toIndex: 0,
      );
      await repository.moveSceneUnit(
        mangaId: MangaId('mid'),
        fromPageId: MangaPageId('pid'),
        fromIndex: 0,
        toPageId: MangaPageId('p2'),
        toIndex: 3,
      );

      verifyNever(firebase.batch());
    });

    test('ページが見つからなければ NotFoundException', () async {
      when(firebase.fetchMangaPage('mid', 'gone'))
          .thenAnswer((_) async => null);

      await expectLater(
        repository.moveSceneUnit(
          mangaId: MangaId('mid'),
          fromPageId: MangaPageId('pid'),
          fromIndex: 0,
          toPageId: MangaPageId('gone'),
          toIndex: 0,
        ),
        throwsA(isA<NotFoundException>()),
      );
      verifyNever(firebase.batch());
    });
  });
}
