import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor_data/repository/manga_repository.dart';
import 'package:my_manga_editor_data/service/connectivity_service.dart';
import 'package:my_manga_editor_data/service/firebase/auth_service.dart';
import 'package:my_manga_editor_data/service/firebase/firebase_service.dart';
import 'package:my_manga_editor_data/service/firebase/model/cloud_manga_page.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseService>(),
  MockSpec<AuthService>(),
  MockSpec<ConnectivityService>(),
  MockSpec<User>(),
])
import 'manga_repository_scene_unit_test.mocks.dart';

Map<String, dynamic> _unit(String name) => {
      'dialoguesDeltaId': '$name-d',
      'stageDirectionDeltaId': '$name-s',
    };

CloudMangaPage _cloudPage(List<Map<String, dynamic>> units) {
  final now = DateTime(2026, 1, 1);
  return CloudMangaPage(
    id: 'pid',
    mangaId: 'mid',
    pageIndex: 0,
    createdAt: now,
    updatedAt: now,
    memoDeltaId: 'memo',
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
}
