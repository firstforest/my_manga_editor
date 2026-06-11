import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor_data/repository/manga_repository.dart';
import 'package:my_manga_editor_data/service/firebase/model/cloud_manga_page.dart';

/// main (デプロイ済み) → develop (これからデプロイ) のページドキュメント移行を検証する。
///
/// main は pages ドキュメントに stageDirectionDeltaId / dialoguesDeltaId を
/// トップレベルフィールドとして保存する。develop は sceneUnits 配列に保存し、
/// 読み込み時に旧フィールドを lazy migration する。
void main() {
  late FakeFirebaseFirestore firestore;
  const pagePath = 'users/uid/mangas/mid/pages/pid';
  final createdAt = DateTime(2026, 1, 1);

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  /// main がデプロイされている現行アプリの保存形式でページを書き込む
  Future<void> writeLegacyPage({
    String? memoDeltaId = 'memo-1',
    String? stageDirectionDeltaId = 'stage-1',
    String? dialoguesDeltaId = 'dialogue-1',
  }) async {
    await firestore.doc(pagePath).set({
      'pageIndex': 0,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(createdAt),
      if (memoDeltaId != null) 'memoDeltaId': memoDeltaId,
      if (stageDirectionDeltaId != null)
        'stageDirectionDeltaId': stageDirectionDeltaId,
      if (dialoguesDeltaId != null) 'dialoguesDeltaId': dialoguesDeltaId,
    });
  }

  Future<CloudMangaPage> readPage() async {
    final snapshot = await firestore
        .doc(pagePath)
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snap, _) => snap.data()!,
          toFirestore: (data, _) => data,
        )
        .get();
    return CloudMangaPageExt.fromFirestore(snapshot, 'mid');
  }

  group('main形式 → develop読み込み (lazy migration)', () {
    test('mainが書いたページは1つのSceneUnitとして読み込まれる', () async {
      await writeLegacyPage();

      final cloudPage = await readPage();

      expect(cloudPage.sceneUnits, hasLength(1));
      expect(cloudPage.sceneUnits!.first['dialoguesDeltaId'], 'dialogue-1');
      expect(
          cloudPage.sceneUnits!.first['stageDirectionDeltaId'], 'stage-1');
      expect(cloudPage.memoDeltaId, 'memo-1');

      final page = cloudPage.toMangaPage();
      expect(page.sceneUnits, hasLength(1));
      expect(page.sceneUnits.first.dialoguesDeltaId, DeltaId('dialogue-1'));
      expect(page.sceneUnits.first.stageDirectionDeltaId,
          DeltaId('stage-1'));
      expect(page.memoDeltaId, DeltaId('memo-1'));
    });

    test('旧フィールドが片方しかなくても移行できる', () async {
      await writeLegacyPage(stageDirectionDeltaId: null);

      final page = (await readPage()).toMangaPage();

      expect(page.sceneUnits, hasLength(1));
      expect(page.sceneUnits.first.dialoguesDeltaId, DeltaId('dialogue-1'));
      expect(page.sceneUnits.first.stageDirectionDeltaId, DeltaId(''));
    });

    test('delta参照を一切持たないページは空のsceneUnitsになる', () async {
      await writeLegacyPage(
        memoDeltaId: null,
        stageDirectionDeltaId: null,
        dialoguesDeltaId: null,
      );

      final page = (await readPage()).toMangaPage();

      expect(page.sceneUnits, isEmpty);
    });

    test('sceneUnitsと旧フィールドが両方ある場合はsceneUnitsを優先する', () async {
      await firestore.doc(pagePath).set({
        'pageIndex': 0,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(createdAt),
        'stageDirectionDeltaId': 'stale-stage',
        'dialoguesDeltaId': 'stale-dialogue',
        'sceneUnits': [
          {
            'dialoguesDeltaId': 'dialogue-2',
            'stageDirectionDeltaId': 'stage-2',
          },
        ],
      });

      final page = (await readPage()).toMangaPage();

      expect(page.sceneUnits, hasLength(1));
      expect(page.sceneUnits.first.dialoguesDeltaId, DeltaId('dialogue-2'));
      expect(page.sceneUnits.first.stageDirectionDeltaId,
          DeltaId('stage-2'));
    });
  });

  group('develop書き込み → main読み込み (ロールバック互換性)', () {
    test('developがset(merge:true)で保存しても旧フィールドはFirestore上に残る', () async {
      await writeLegacyPage();

      // FirebaseService.saveMangaPage と同じ保存パスを再現する
      final migrated = (await readPage()).toMangaPage();
      await firestore.doc(pagePath).set(
            migrated.toCloudMangaPage(0).toFirestore(),
            SetOptions(merge: true),
          );

      final raw = (await firestore.doc(pagePath).get()).data()!;
      // develop が読むための sceneUnits が書かれている
      expect(raw['sceneUnits'], [
        {
          'dialoguesDeltaId': 'dialogue-1',
          'stageDirectionDeltaId': 'stage-1',
        },
      ]);
      // main にロールバックしても旧フィールドから同じdeltaを参照できる
      expect(raw['dialoguesDeltaId'], 'dialogue-1');
      expect(raw['stageDirectionDeltaId'], 'stage-1');
    });

    test('toFirestoreは旧フィールドを書き込まない (sceneUnitsが正)', () {
      final cloudPage = CloudMangaPage(
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
        stageDirectionDeltaId: 'stage-1',
        dialoguesDeltaId: 'dialogue-1',
      );

      final data = cloudPage.toFirestore();

      expect(data.containsKey('stageDirectionDeltaId'), isFalse);
      expect(data.containsKey('dialoguesDeltaId'), isFalse);
      expect(data['sceneUnits'], hasLength(1));
    });

    test('developが新規作成したページには旧フィールドがなくmainでは空ページになる', () async {
      final newPage = MangaPage(
        id: MangaPageId('pid'),
        mangaId: MangaId('mid'),
        memoDeltaId: DeltaId('memo-1'),
        sceneUnits: [
          SceneUnit(
            dialoguesDeltaId: DeltaId('dialogue-1'),
            stageDirectionDeltaId: DeltaId('stage-1'),
          ),
        ],
      );
      await firestore.doc(pagePath).set(newPage.toCloudMangaPage(0).toFirestore());

      final raw = (await firestore.doc(pagePath).get()).data()!;
      // main の fromFirestore はこの2フィールドだけを見るため、
      // develop で新規作成したページはロールバック後は空ページとして表示される
      expect(raw['dialoguesDeltaId'], isNull);
      expect(raw['stageDirectionDeltaId'], isNull);
      expect(raw['sceneUnits'], isNotNull);
    });
  });
}
