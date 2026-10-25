import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_manga_editor_data/repository/manga_repository.dart';
import 'package:my_manga_editor_data/service/firebase/model/cloud_delta.dart';
import 'package:my_manga_editor_data/service/firebase/model/cloud_manga.dart';
import 'package:my_manga_editor_data/service/firebase/model/cloud_manga_page.dart';

/// fixture ベースのスキーマ移行回帰テスト。
///
/// test/data_migration/fixtures/manga_page/ に置かれた各スキーマ版の
/// 生ドキュメント (ゴールデンデータ) を全件読み込み、現行モデルへ
/// 正しく変換されることを検証する。
///
/// スキーマを変更したら、変更前の版の fixture を必ず追加すること
/// (.claude/rules/data-layer.md のチェックリスト参照)。
void main() {
  const pagePath = 'users/uid/mangas/mid/pages/pid';
  const mangaPath = 'users/uid/mangas/mid';

  /// fixture の document を Firestore に書ける形式に変換する
  /// (ISO 8601 文字列の createdAt / updatedAt を Timestamp 化)
  Map<String, dynamic> toFirestoreData(Map<String, dynamic> document) {
    return document.map((key, value) {
      if ((key == 'createdAt' || key == 'updatedAt') && value is String) {
        return MapEntry(key, Timestamp.fromDate(DateTime.parse(value)));
      }
      return MapEntry(key, value);
    });
  }

  Future<CloudMangaPage> readPage(FakeFirebaseFirestore firestore) async {
    final snapshot = await firestore
        .doc(pagePath)
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snap, _) => snap.data()!,
          toFirestore: (data, _) => data,
        )
        .get();
    return CloudMangaPageExt.fromFirestore(snapshot, 'mid');
  }

  Future<CloudManga> readManga(FakeFirebaseFirestore firestore) async {
    final snapshot = await firestore
        .doc(mangaPath)
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snap, _) => snap.data()!,
          toFirestore: (data, _) => data,
        )
        .get();
    return CloudMangaExt.fromFirestore(snapshot);
  }

  group('CloudMangaPage: 全スキーマ版の fixture が現行モデルへ変換できる', () {
    final fixtureDir = Directory('test/data_migration/fixtures/manga_page');
    final fixtureFiles = fixtureDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    test('fixture が存在する', () {
      expect(fixtureFiles, isNotEmpty);
    });

    for (final file in fixtureFiles) {
      final fixture =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final description = fixture['description'] as String;
      final document = fixture['document'] as Map<String, dynamic>;
      final expected = fixture['expected'] as Map<String, dynamic>;

      test(description, () async {
        final firestore = FakeFirebaseFirestore();
        await firestore.doc(pagePath).set(toFirestoreData(document));

        final page = (await readPage(firestore)).toMangaPage();

        expect(page.memoDeltaId.id, expected['memoDeltaId']);

        final expectedUnits = (expected['sceneUnits'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
        expect(page.sceneUnits, hasLength(expectedUnits.length));
        for (var i = 0; i < expectedUnits.length; i++) {
          expect(page.sceneUnits[i].dialoguesDeltaId.id,
              expectedUnits[i]['dialoguesDeltaId'],
              reason: 'sceneUnits[$i].dialoguesDeltaId');
          expect(page.sceneUnits[i].stageDirectionDeltaId.id,
              expectedUnits[i]['stageDirectionDeltaId'],
              reason: 'sceneUnits[$i].stageDirectionDeltaId');
        }
      });
    }
  });

  group('CloudManga: 全スキーマ版の fixture が現行モデルへ変換できる', () {
    final fixtureDir = Directory('test/data_migration/fixtures/manga');
    final fixtureFiles = fixtureDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    test('fixture が存在する', () {
      expect(fixtureFiles, isNotEmpty);
    });

    for (final file in fixtureFiles) {
      final fixture =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final description = fixture['description'] as String;
      final document = fixture['document'] as Map<String, dynamic>;
      final expected = fixture['expected'] as Map<String, dynamic>;

      test(description, () async {
        final firestore = FakeFirebaseFirestore();
        await firestore.doc(mangaPath).set(toFirestoreData(document));

        final manga = (await readManga(firestore)).toManga();

        expect(manga.name, expected['name']);
        expect(manga.tags, (expected['tags'] as List<dynamic>).cast<String>());
      });
    }
  });

  group('schemaVersion の書き込み', () {
    final createdAt = DateTime(2026, 1, 1);

    test('CloudMangaPage.toFirestore は現行 schemaVersion を書き込む', () {
      final data = CloudMangaPage(
        id: 'pid',
        mangaId: 'mid',
        pageIndex: 0,
        createdAt: createdAt,
        updatedAt: createdAt,
        sceneUnits: const [],
      ).toFirestore();

      expect(data['schemaVersion'], CloudMangaPageExt.schemaVersion);
    });

    test('CloudManga.toFirestore は現行 schemaVersion を書き込む', () {
      final data = CloudManga(
        id: 'mid',
        userId: 'uid',
        name: 'TestManga',
        startPageDirection: 'left',
        createdAt: createdAt,
        updatedAt: createdAt,
      ).toFirestore();

      expect(data['schemaVersion'], CloudMangaExt.schemaVersion);
    });

    test('CloudManga.toFirestore は tags キーを常に書き込む', () {
      final withoutTags = CloudManga(
        id: 'mid',
        userId: 'uid',
        name: 'TestManga',
        startPageDirection: 'left',
        createdAt: createdAt,
        updatedAt: createdAt,
      ).toFirestore();

      // タグなしはキーの欠損ではなく空配列で表す
      expect(withoutTags['tags'], isEmpty);

      final withTags = CloudManga(
        id: 'mid',
        userId: 'uid',
        name: 'TestManga',
        startPageDirection: 'left',
        createdAt: createdAt,
        updatedAt: createdAt,
        tags: const ['連載:ヒーロー'],
      ).toFirestore();

      expect(withTags['tags'], ['連載:ヒーロー']);
    });

    test('CloudDelta.toFirestore は現行 schemaVersion を書き込む', () {
      final data = CloudDelta(
        id: 'did',
        mangaId: 'mid',
        ops: const [],
        fieldName: 'memoDelta',
        createdAt: createdAt,
        updatedAt: createdAt,
      ).toFirestore();

      expect(data['schemaVersion'], CloudDeltaExt.schemaVersion);
    });

    test('toFirestore で書いた現行形式のページを roundtrip できる', () async {
      final firestore = FakeFirebaseFirestore();
      final page = CloudMangaPage(
        id: 'pid',
        mangaId: 'mid',
        pageIndex: 0,
        createdAt: createdAt,
        updatedAt: createdAt,
        memoDeltaId: 'memo-1',
        sceneUnits: const [
          {
            'dialoguesDeltaId': 'dialogue-1',
            'stageDirectionDeltaId': 'stage-1',
          },
        ],
      );
      await firestore.doc(pagePath).set(page.toFirestore());

      final restored = await readPage(firestore);

      expect(restored.memoDeltaId, page.memoDeltaId);
      expect(restored.sceneUnits, page.sceneUnits);
      expect(restored.pageIndex, page.pageIndex);
    });
  });
}
