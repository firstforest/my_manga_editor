import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_manga_editor_data/service/firebase/model/cloud_manga.dart';

/// `CloudManga.fromFirestore` の読み取りが、壊れた値・未確定の値を
/// その場で処理しきることを確認する。
void main() {
  const mangaPath = 'users/uid/mangas/mid';

  late FakeFirebaseFirestore firestore;

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  Future<CloudManga> read() async {
    final snapshot = await firestore.doc(mangaPath).get();
    return CloudMangaExt.fromFirestore(snapshot);
  }

  Future<void> write(Map<String, dynamic> overrides) async {
    await firestore.doc(mangaPath).set({
      'userId': 'uid',
      'name': 'TestManga',
      'startPageDirection': 'left',
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      ...overrides,
    });
  }

  test('tags は読み込み時点でコピーされる (後から遅延して落ちない)', () async {
    await write({
      'tags': ['連載:ヒーロー', '商業'],
    });

    final manga = await read();

    expect(manga.tags, ['連載:ヒーロー', '商業']);
    // 反復しても型エラーにならない = 遅延ビューではない
    expect(manga.tags!.join(','), '連載:ヒーロー,商業');
  });

  test('tags に型不正な要素があれば読み込み時点で失敗する', () async {
    await write({
      'tags': ['商業', 42],
    });

    expect(read, throwsA(isA<TypeError>()));
  });

  test('tags フィールドが無ければ null で読む', () async {
    await write({});

    expect((await read()).tags, isNull);
  });

  test('未確定の serverTimestamp (null) でも読める', () async {
    await write({
      'createdAt': null,
      'updatedAt': null,
    });

    final manga = await read();

    expect(manga.name, 'TestManga');
    expect(manga.createdAt, isNotNull);
    expect(manga.updatedAt, isNotNull);
  });
}
