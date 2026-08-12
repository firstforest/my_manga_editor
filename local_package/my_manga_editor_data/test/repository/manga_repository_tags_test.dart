import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor_data/repository/exceptions.dart'
    as repo_exceptions;
import 'package:my_manga_editor_data/repository/manga_repository.dart';
import 'package:my_manga_editor_data/service/connectivity_service.dart';
import 'package:my_manga_editor_data/service/firebase/auth_service.dart';
import 'package:my_manga_editor_data/service/firebase/firebase_service.dart';
import 'package:my_manga_editor_data/service/firebase/model/cloud_manga.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseService>(),
  MockSpec<AuthService>(),
  MockSpec<ConnectivityService>(),
  MockSpec<User>(),
])
import 'manga_repository_tags_test.mocks.dart';

CloudManga _cloudManga({List<String>? tags}) {
  final now = DateTime(2026, 1, 1);
  return CloudManga(
    id: 'mid',
    userId: 'uid',
    name: 'TestManga',
    startPageDirection: 'left',
    createdAt: now,
    updatedAt: now,
    editLock: null,
    status: 'idea',
    tags: tags,
  );
}

void main() {
  late MockFirebaseService firebase;
  late MockAuthService auth;
  late MockConnectivityService connectivity;
  late MangaRepository repository;

  setUp(() {
    firebase = MockFirebaseService();
    auth = MockAuthService();
    connectivity = MockConnectivityService();
    // 接続イベントを発火させない静かな Stream を返し、初期接続チェックは true を返す
    when(connectivity.onConnectivityChanged())
        .thenAnswer((_) => const Stream<bool>.empty());
    when(connectivity.isOnline()).thenAnswer((_) async => true);

    final user = MockUser();
    when(user.uid).thenReturn('uid');
    when(auth.currentUser).thenReturn(user);

    // 上限判定のために読む現在のタグ。既定はタグなし
    when(firebase.fetchManga('mid')).thenAnswer((_) async => _cloudManga());

    repository = MangaRepository(
      firebaseService: firebase,
      authService: auth,
      connectivityService: connectivity,
    );
  });

  group('MangaRepository.addTag', () {
    test('Service の addMangaTag に委譲する (配列全体の上書きはしない)', () async {
      await repository.addTag(MangaId('mid'), '連載:ヒーロー');

      verify(firebase.addMangaTag('mid', '連載:ヒーロー')).called(1);
      verifyNever(firebase.updateManga(any, any));
    });

    test('前後の空白は取り除いて渡す', () async {
      await repository.addTag(MangaId('mid'), '  商業  ');

      verify(firebase.addMangaTag('mid', '商業')).called(1);
    });

    test('空文字は Service を呼ばずに正常終了する', () async {
      await repository.addTag(MangaId('mid'), '');

      verifyNever(firebase.addMangaTag(any, any));
    });

    test('空白のみも Service を呼ばずに正常終了する', () async {
      await repository.addTag(MangaId('mid'), '   ');

      verifyNever(firebase.addMangaTag(any, any));
    });

    test('30 文字ちょうどは追加できる', () async {
      final tag = 'あ' * 30;

      await repository.addTag(MangaId('mid'), tag);

      verify(firebase.addMangaTag('mid', tag)).called(1);
    });

    test('31 文字は TagLengthException を投げ、Service を呼ばない', () async {
      final tag = 'あ' * 31;

      await expectLater(
        () => repository.addTag(MangaId('mid'), tag),
        throwsA(isA<repo_exceptions.TagLengthException>()),
      );
      verifyNever(firebase.addMangaTag(any, any));
    });

    test('絵文字 30 個ちょうどは追加できる (書記素クラスタで数える)', () async {
      final tag = '🎉' * 30;

      await repository.addTag(MangaId('mid'), tag);

      verify(firebase.addMangaTag('mid', tag)).called(1);
    });

    test('絵文字 31 個は TagLengthException を投げる', () async {
      final tag = '🎉' * 31;

      await expectLater(
        () => repository.addTag(MangaId('mid'), tag),
        throwsA(isA<repo_exceptions.TagLengthException>()),
      );
      verifyNever(firebase.addMangaTag(any, any));
    });

    test('既にタグが 20 個あると TagLimitException を投げる', () async {
      when(firebase.fetchManga('mid')).thenAnswer(
        (_) async => _cloudManga(
          tags: List.generate(20, (i) => 'tag$i'),
        ),
      );

      await expectLater(
        () => repository.addTag(MangaId('mid'), '21個目'),
        throwsA(isA<repo_exceptions.TagLimitException>()),
      );
      verifyNever(firebase.addMangaTag(any, any));
    });

    test('Service が失敗したら StorageException に変換する', () async {
      when(firebase.addMangaTag(any, any)).thenThrow(
        FirebaseServiceException('Failed to add manga tag', code: 'unavailable'),
      );

      await expectLater(
        () => repository.addTag(MangaId('mid'), '商業'),
        throwsA(
          isA<repo_exceptions.StorageException>()
              .having((e) => e.code, 'code', 'unavailable'),
        ),
      );
    });

    test('fetchManga が失敗しても StorageException に変換する', () async {
      when(firebase.fetchManga('mid'))
          .thenThrow(FirebaseServiceException('Failed to fetch manga'));

      await expectLater(
        () => repository.addTag(MangaId('mid'), '商業'),
        throwsA(isA<repo_exceptions.StorageException>()),
      );
      verifyNever(firebase.addMangaTag(any, any));
    });

    test('タグが 20 個でも既に付いているタグの再追加は通す (冪等)', () async {
      final existing = List.generate(20, (i) => 'tag$i');
      when(firebase.fetchManga('mid'))
          .thenAnswer((_) async => _cloudManga(tags: existing));

      await repository.addTag(MangaId('mid'), 'tag0');

      verify(firebase.addMangaTag('mid', 'tag0')).called(1);
    });

    test('未認証なら AuthException を投げる', () async {
      when(auth.currentUser).thenReturn(null);

      await expectLater(
        () => repository.addTag(MangaId('mid'), '商業'),
        throwsA(isA<repo_exceptions.AuthException>()),
      );
      verifyNever(firebase.addMangaTag(any, any));
    });
  });

  group('MangaRepository.removeTag', () {
    test('Service の removeMangaTag に委譲する', () async {
      await repository.removeTag(MangaId('mid'), '商業');

      verify(firebase.removeMangaTag('mid', '商業')).called(1);
      verifyNever(firebase.updateManga(any, any));
    });

    test('前後の空白は取り除いて渡す', () async {
      await repository.removeTag(MangaId('mid'), ' 商業 ');

      verify(firebase.removeMangaTag('mid', '商業')).called(1);
    });

    test('空文字は Service を呼ばずに正常終了する', () async {
      await repository.removeTag(MangaId('mid'), '');

      verifyNever(firebase.removeMangaTag(any, any));
    });

    test('未認証なら AuthException を投げる', () async {
      when(auth.currentUser).thenReturn(null);

      await expectLater(
        () => repository.removeTag(MangaId('mid'), '商業'),
        throwsA(isA<repo_exceptions.AuthException>()),
      );
      verifyNever(firebase.removeMangaTag(any, any));
    });

    test('Service が失敗したら StorageException に変換する', () async {
      when(firebase.removeMangaTag(any, any)).thenThrow(
        FirebaseServiceException('Failed to remove manga tag',
            code: 'unavailable'),
      );

      await expectLater(
        () => repository.removeTag(MangaId('mid'), '商業'),
        throwsA(
          isA<repo_exceptions.StorageException>()
              .having((e) => e.code, 'code', 'unavailable'),
        ),
      );
    });
  });

  group('MangaRepository.createNewManga', () {
    test('tags 引数を CloudManga に載せて作成する', () async {
      when(firebase.createManga(any)).thenAnswer((_) async => 'new-mid');
      when(firebase.createDelta(any, any)).thenAnswer((_) async => 'delta-id');

      await repository.createNewManga(name: '新作', tags: ['連載:ヒーロー']);

      final created =
          verify(firebase.createManga(captureAny)).captured.single as CloudManga;
      expect(created.tags, ['連載:ヒーロー']);
      expect(created.name, '新作');
    });

    test('tags を渡さなければ空リストで作成する', () async {
      when(firebase.createManga(any)).thenAnswer((_) async => 'new-mid');
      when(firebase.createDelta(any, any)).thenAnswer((_) async => 'delta-id');

      await repository.createNewManga();

      final created =
          verify(firebase.createManga(captureAny)).captured.single as CloudManga;
      expect(created.tags, isEmpty);
    });

    test('前後の空白を落として保存する (removeTag で外せなくなるため)', () async {
      when(firebase.createManga(any)).thenAnswer((_) async => 'new-mid');
      when(firebase.createDelta(any, any)).thenAnswer((_) async => 'delta-id');

      await repository.createNewManga(tags: ['  商業  ']);

      final created =
          verify(firebase.createManga(captureAny)).captured.single as CloudManga;
      expect(created.tags, ['商業']);
    });

    test('空文字・空白のみのタグは落とす', () async {
      when(firebase.createManga(any)).thenAnswer((_) async => 'new-mid');
      when(firebase.createDelta(any, any)).thenAnswer((_) async => 'delta-id');

      await repository.createNewManga(tags: ['', '   ', '商業']);

      final created =
          verify(firebase.createManga(captureAny)).captured.single as CloudManga;
      expect(created.tags, ['商業']);
    });

    test('重複するタグは 1 つにまとめる', () async {
      when(firebase.createManga(any)).thenAnswer((_) async => 'new-mid');
      when(firebase.createDelta(any, any)).thenAnswer((_) async => 'delta-id');

      await repository.createNewManga(tags: ['商業', ' 商業 ', '連載:ヒーロー']);

      final created =
          verify(firebase.createManga(captureAny)).captured.single as CloudManga;
      expect(created.tags, ['商業', '連載:ヒーロー']);
    });

    test('31 文字のタグは TagLengthException を投げ、作品を作らない', () async {
      await expectLater(
        () => repository.createNewManga(tags: ['あ' * 31]),
        throwsA(isA<repo_exceptions.TagLengthException>()),
      );
      verifyNever(firebase.createManga(any));
    });

    test('21 個のタグは TagLimitException を投げ、作品を作らない', () async {
      await expectLater(
        () => repository.createNewManga(tags: List.generate(21, (i) => 'tag$i')),
        throwsA(isA<repo_exceptions.TagLimitException>()),
      );
      verifyNever(firebase.createManga(any));
    });
  });
}
