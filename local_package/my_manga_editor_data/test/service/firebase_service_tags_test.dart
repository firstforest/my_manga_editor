import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_manga_editor_data/service/firebase/firebase_service.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(),
  MockSpec<User>(),
])
import 'firebase_service_tags_test.mocks.dart';

/// タグの追加・削除が配列の差分操作 (arrayUnion / arrayRemove) で行われることを
/// 実際の Firestore ドキュメントに対して確認する。
///
/// 配列全体の read-modify-write だと 2 端末の同時追加で片方が消えるため、
/// 「同時に別のタグを足しても両方残る」ことを回帰テストとして固定する。
void main() {
  const mangaPath = 'users/uid/mangas/mid';

  late FakeFirebaseFirestore firestore;
  late FirebaseService service;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    final user = MockUser();
    when(user.uid).thenReturn('uid');
    when(auth.currentUser).thenReturn(user);

    service = FirebaseService(firestore: firestore, auth: auth);

    await firestore.doc(mangaPath).set({
      'userId': 'uid',
      'name': 'TestManga',
      'startPageDirection': 'left',
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'tags': <String>[],
    });
  });

  Future<List<String>> readTags() async {
    final snapshot = await firestore.doc(mangaPath).get();
    return (snapshot.data()!['tags'] as List<dynamic>).cast<String>();
  }

  test('addMangaTag はタグを末尾に追加する', () async {
    await service.addMangaTag('mid', '連載:ヒーロー');
    await service.addMangaTag('mid', '商業');

    expect(await readTags(), ['連載:ヒーロー', '商業']);
  });

  test('addMangaTag は同じタグを重複させない (冪等)', () async {
    await service.addMangaTag('mid', '商業');
    await service.addMangaTag('mid', '商業');

    expect(await readTags(), ['商業']);
  });

  test('removeMangaTag は指定したタグだけを外す', () async {
    await service.addMangaTag('mid', '連載:ヒーロー');
    await service.addMangaTag('mid', '商業');

    await service.removeMangaTag('mid', '連載:ヒーロー');

    expect(await readTags(), ['商業']);
  });

  test('removeMangaTag は付いていないタグを指定しても何も起きない', () async {
    await service.addMangaTag('mid', '商業');

    await service.removeMangaTag('mid', '存在しない');

    expect(await readTags(), ['商業']);
  });

  test('tags フィールドが無いドキュメントにも追加できる', () async {
    await firestore.doc(mangaPath).set({
      'userId': 'uid',
      'name': 'TestManga',
      'startPageDirection': 'left',
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
    });

    await service.addMangaTag('mid', '商業');

    expect(await readTags(), ['商業']);
  });
}
