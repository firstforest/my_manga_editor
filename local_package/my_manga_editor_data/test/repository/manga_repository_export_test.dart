import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor_data/repository/manga_repository.dart';
import 'package:my_manga_editor_data/service/connectivity_service.dart';
import 'package:my_manga_editor_data/service/firebase/auth_service.dart';
import 'package:my_manga_editor_data/service/firebase/firebase_service.dart';
import 'package:my_manga_editor_data/service/firebase/model/cloud_delta.dart';
import 'package:my_manga_editor_data/service/firebase/model/cloud_manga.dart';
import 'package:my_manga_editor_data/service/firebase/model/cloud_manga_page.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseService>(),
  MockSpec<AuthService>(),
  MockSpec<ConnectivityService>(),
])
import 'manga_repository_export_test.mocks.dart';

CloudManga _cloudManga({String name = 'TestManga', String? ideaMemoDeltaId}) {
  final now = DateTime(2026, 1, 1);
  return CloudManga(
    id: 'mid',
    userId: 'uid',
    name: name,
    startPageDirection: 'left',
    createdAt: now,
    updatedAt: now,
    ideaMemoDeltaId: ideaMemoDeltaId,
    editLock: null,
    status: 'idea',
  );
}

CloudMangaPage _cloudPage({
  required String id,
  required int pageIndex,
  String? memoDeltaId,
  List<Map<String, dynamic>>? sceneUnits,
}) {
  final now = DateTime(2026, 1, 1);
  return CloudMangaPage(
    id: id,
    mangaId: 'mid',
    pageIndex: pageIndex,
    createdAt: now,
    updatedAt: now,
    memoDeltaId: memoDeltaId,
    sceneUnits: sceneUnits,
  );
}

CloudDelta _cloudDelta({
  required String id,
  required String fieldName,
  String? pageId,
  required String text,
}) {
  final now = DateTime(2026, 1, 1);
  final delta = text.isEmpty ? Delta() : (Delta()..insert(text));
  return CloudDelta(
    id: id,
    mangaId: 'mid',
    ops: delta.toJson() as List<dynamic>,
    fieldName: fieldName,
    pageId: pageId,
    createdAt: now,
    updatedAt: now,
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
    repository = MangaRepository(
      firebaseService: firebase,
      authService: auth,
      connectivityService: connectivity,
    );
  });

  group('MangaRepository.toMarkdown', () {
    test('SceneUnit が 0 件のページはタイトルとページ見出しのみ出力する', () async {
      when(firebase.fetchManga('mid'))
          .thenAnswer((_) async => _cloudManga(name: '空作品'));
      when(firebase.fetchMangaPages('mid')).thenAnswer((_) async => [
            _cloudPage(id: 'p1', pageIndex: 0),
          ]);
      when(firebase.fetchDeltas('mid')).thenAnswer((_) async => []);

      final markdown = await repository.toMarkdown(MangaId('mid'));

      expect(markdown, contains('# 空作品'));
      expect(markdown, contains('## ページ 1'));
      expect(markdown, isNot(contains('### メモ')));
      expect(markdown, isNot(contains('### カット')));
      expect(markdown, isNot(contains('### ト書き')));
      expect(markdown, isNot(contains('### セリフ')));
    });

    test('SceneUnit が 1 件のページは ### ト書き / ### セリフ を直下に出力する', () async {
      when(firebase.fetchManga('mid'))
          .thenAnswer((_) async => _cloudManga(name: '単カット作品'));
      when(firebase.fetchMangaPages('mid')).thenAnswer((_) async => [
            _cloudPage(
              id: 'p1',
              pageIndex: 0,
              memoDeltaId: 'd-memo',
              sceneUnits: [
                {
                  'dialoguesDeltaId': 'd-dlg',
                  'stageDirectionDeltaId': 'd-stg',
                },
              ],
            ),
          ]);
      when(firebase.fetchDeltas('mid')).thenAnswer((_) async => [
            _cloudDelta(
                id: 'd-memo',
                fieldName: 'memoDelta',
                pageId: 'p1',
                text: 'メモ本文'),
            _cloudDelta(
                id: 'd-dlg',
                fieldName: 'dialoguesDelta',
                pageId: 'p1',
                text: 'セリフ本文'),
            _cloudDelta(
                id: 'd-stg',
                fieldName: 'stageDirectionDelta',
                pageId: 'p1',
                text: 'ト書き本文'),
          ]);

      final markdown = await repository.toMarkdown(MangaId('mid'));

      expect(markdown, contains('# 単カット作品'));
      expect(markdown, contains('## ページ 1'));
      expect(markdown, contains('### メモ'));
      expect(markdown, contains('メモ本文'));
      // 単カットなので '### ト書き' / '### セリフ' (### のまま、#### にはならない)
      expect(markdown, contains('### ト書き'));
      expect(markdown, contains('### セリフ'));
      expect(markdown, contains('ト書き本文'));
      expect(markdown, contains('セリフ本文'));
      expect(markdown, isNot(contains('### カット 1')));
      expect(markdown, isNot(contains('#### ト書き')));
    });

    test('SceneUnit が 2 件以上のページは ### カット N 配下に #### ト書き / #### セリフ を出力する',
        () async {
      when(firebase.fetchManga('mid'))
          .thenAnswer((_) async => _cloudManga(name: 'マルチカット'));
      when(firebase.fetchMangaPages('mid')).thenAnswer((_) async => [
            _cloudPage(
              id: 'p1',
              pageIndex: 0,
              sceneUnits: [
                {
                  'dialoguesDeltaId': 'd-dlg1',
                  'stageDirectionDeltaId': 'd-stg1',
                },
                {
                  'dialoguesDeltaId': 'd-dlg2',
                  'stageDirectionDeltaId': 'd-stg2',
                },
              ],
            ),
          ]);
      when(firebase.fetchDeltas('mid')).thenAnswer((_) async => [
            _cloudDelta(
                id: 'd-dlg1',
                fieldName: 'dialoguesDelta',
                pageId: 'p1',
                text: 'セリフ1'),
            _cloudDelta(
                id: 'd-stg1',
                fieldName: 'stageDirectionDelta',
                pageId: 'p1',
                text: 'ト書き1'),
            _cloudDelta(
                id: 'd-dlg2',
                fieldName: 'dialoguesDelta',
                pageId: 'p1',
                text: 'セリフ2'),
            _cloudDelta(
                id: 'd-stg2',
                fieldName: 'stageDirectionDelta',
                pageId: 'p1',
                text: 'ト書き2'),
          ]);

      final markdown = await repository.toMarkdown(MangaId('mid'));

      expect(markdown, contains('### カット 1'));
      expect(markdown, contains('### カット 2'));
      expect(markdown, contains('#### ト書き'));
      expect(markdown, contains('#### セリフ'));
      expect(markdown, contains('セリフ1'));
      expect(markdown, contains('セリフ2'));
      expect(markdown, contains('ト書き1'));
      expect(markdown, contains('ト書き2'));
      // 「### ト書き」(単カット形式) は出ない
      expect(markdown, isNot(RegExp(r'^### ト書き$', multiLine: true)));
    });

    test('空 Delta が混じった場合、その見出しは出力されない', () async {
      when(firebase.fetchManga('mid'))
          .thenAnswer((_) async => _cloudManga(name: '空デルタ混在'));
      when(firebase.fetchMangaPages('mid')).thenAnswer((_) async => [
            _cloudPage(
              id: 'p1',
              pageIndex: 0,
              memoDeltaId: 'd-memo',
              sceneUnits: [
                {
                  'dialoguesDeltaId': 'd-dlg',
                  'stageDirectionDeltaId': 'd-stg',
                },
              ],
            ),
          ]);
      when(firebase.fetchDeltas('mid')).thenAnswer((_) async => [
            // memo は空
            _cloudDelta(
                id: 'd-memo',
                fieldName: 'memoDelta',
                pageId: 'p1',
                text: ''),
            // セリフのみ本文あり
            _cloudDelta(
                id: 'd-dlg',
                fieldName: 'dialoguesDelta',
                pageId: 'p1',
                text: '唯一のセリフ'),
            // ト書きは空
            _cloudDelta(
                id: 'd-stg',
                fieldName: 'stageDirectionDelta',
                pageId: 'p1',
                text: ''),
          ]);

      final markdown = await repository.toMarkdown(MangaId('mid'));

      expect(markdown, contains('### セリフ'));
      expect(markdown, contains('唯一のセリフ'));
      // 空のメモ / ト書きは出ない
      expect(markdown, isNot(contains('### メモ')));
      expect(markdown, isNot(contains('### ト書き')));
    });

    test('アイデアメモがある場合は ## アイデアメモ セクションが先頭近くに出力される', () async {
      when(firebase.fetchManga('mid')).thenAnswer((_) async =>
          _cloudManga(name: 'アイデア持ち', ideaMemoDeltaId: 'd-idea'));
      when(firebase.fetchMangaPages('mid')).thenAnswer((_) async => []);
      when(firebase.fetchDeltas('mid')).thenAnswer((_) async => [
            _cloudDelta(
                id: 'd-idea', fieldName: 'ideaMemo', text: 'これがアイデアです'),
          ]);

      final markdown = await repository.toMarkdown(MangaId('mid'));

      expect(markdown, contains('# アイデア持ち'));
      expect(markdown, contains('## アイデアメモ'));
      expect(markdown, contains('これがアイデアです'));
      // タイトルがアイデアメモより前に来ること
      expect(markdown.indexOf('# アイデア持ち'),
          lessThan(markdown.indexOf('## アイデアメモ')));
    });

    test('アイデアメモが空 Delta の場合はセクションが出力されない', () async {
      when(firebase.fetchManga('mid')).thenAnswer((_) async =>
          _cloudManga(name: '空アイデア', ideaMemoDeltaId: 'd-idea'));
      when(firebase.fetchMangaPages('mid')).thenAnswer((_) async => []);
      when(firebase.fetchDeltas('mid')).thenAnswer((_) async => [
            _cloudDelta(id: 'd-idea', fieldName: 'ideaMemo', text: ''),
          ]);

      final markdown = await repository.toMarkdown(MangaId('mid'));

      expect(markdown, contains('# 空アイデア'));
      expect(markdown, isNot(contains('## アイデアメモ')));
    });
  });
}
