import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_manga_editor_data/service/firebase/firebase_service.dart';
import 'package:my_manga_editor_data/service/firebase/model/cloud_manga.dart';
import 'package:my_manga_editor_data/service/firebase/model/edit_lock.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(),
  MockSpec<User>(),
])
import 'firebase_service_create_manga_test.mocks.dart';

/// `createManga` が渡された `CloudManga` の中身を落とさずに書き込むことを、
/// 実際の Firestore ドキュメントに対して確認する。
///
/// Repository 側のテストは FirebaseService をモックするため、
/// Service がフィールドを写し忘れても検出できない。その穴をここで塞ぐ。
void main() {
  late FakeFirebaseFirestore firestore;
  late FirebaseService service;

  CloudManga cloudManga({
    List<String>? tags,
    String? status = 'idea',
    EditLock? editLock,
  }) {
    final now = DateTime(2026, 1, 1);
    return CloudManga(
      id: '',
      userId: 'uid',
      name: 'TestManga',
      startPageDirection: 'left',
      createdAt: now,
      updatedAt: now,
      ideaMemoDeltaId: 'delta-id',
      editLock: editLock,
      status: status,
      tags: tags,
    );
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    final user = MockUser();
    when(user.uid).thenReturn('uid');
    when(auth.currentUser).thenReturn(user);

    service = FirebaseService(firestore: firestore, auth: auth);
  });

  Future<Map<String, dynamic>> readManga(String mangaId) async {
    final snapshot = await firestore.doc('users/uid/mangas/$mangaId').get();
    return snapshot.data()!;
  }

  test('tags を Firestore ドキュメントへ書く', () async {
    final mangaId =
        await service.createManga(cloudManga(tags: ['連載:ヒーロー', '商業']));

    final data = await readManga(mangaId);
    expect(data['tags'], ['連載:ヒーロー', '商業']);
  });

  test('status を Firestore ドキュメントへ書く', () async {
    final mangaId =
        await service.createManga(cloudManga(status: 'inProgress'));

    final data = await readManga(mangaId);
    expect(data['status'], 'inProgress');
  });

  test('tags 無しでもキーは空配列で書く (タグなしを空配列で表すため)', () async {
    final mangaId = await service.createManga(cloudManga());

    final data = await readManga(mangaId);
    expect(data['tags'], isEmpty);
  });

  test('ideaMemoDeltaId など他のフィールドも落とさない', () async {
    final mangaId = await service.createManga(cloudManga(tags: ['商業']));

    final data = await readManga(mangaId);
    expect(data['userId'], 'uid');
    expect(data['name'], 'TestManga');
    expect(data['startPageDirection'], 'left');
    expect(data['ideaMemoDeltaId'], 'delta-id');
  });

  test('書き込んだドキュメントを読み直すと同じ tags / status が返る', () async {
    final mangaId = await service.createManga(
      cloudManga(tags: ['連載:ヒーロー'], status: 'complete'),
    );

    final fetched = await service.fetchManga(mangaId);
    expect(fetched!.id, mangaId);
    expect(fetched.tags, ['連載:ヒーロー']);
    expect(fetched.status, 'complete');
  });
}
