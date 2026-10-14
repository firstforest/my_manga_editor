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
      expect(markdown, isNot(contains('### 本文')));
    });

    test('ト書きとセリフは ### 本文 に空行区切りで並ぶ', () async {
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
                text: 'A「こんにちは」'),
            _cloudDelta(
                id: 'd-stg',
                fieldName: 'stageDirectionDelta',
                pageId: 'p1',
                text: '夜の教室。窓際に二人'),
          ]);

      final markdown = await repository.toMarkdown(MangaId('mid'));

      expect(markdown, contains('### メモ'));
      expect(markdown, contains('メモ本文'));
      // ト書きが先、セリフが後。ト書きは （ト書き） で見分けられる
      expect(markdown, contains('### 本文\n\n（ト書き）夜の教室。窓際に二人\n\nA「こんにちは」\n'));
      // ト書き / セリフ の個別見出しは出さない
      expect(markdown, isNot(contains('### ト書き')));
      expect(markdown, isNot(contains('### セリフ')));
    });

    test('カットが複数でも見出しを挟まず、カット順に空行区切りで並ぶ', () async {
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

      expect(
          markdown,
          contains('### 本文\n\n'
              '（ト書き）ト書き1\n\n'
              'セリフ1\n\n'
              '（ト書き）ト書き2\n\n'
              'セリフ2\n'));
      expect(markdown, isNot(contains('### カット')));
    });

    test('中身が空のカットは何も出力しない', () async {
      when(firebase.fetchManga('mid'))
          .thenAnswer((_) async => _cloudManga(name: '空カット混在'));
      when(firebase.fetchMangaPages('mid')).thenAnswer((_) async => [
            _cloudPage(
              id: 'p1',
              pageIndex: 0,
              sceneUnits: [
                {
                  'dialoguesDeltaId': 'd-dlg1',
                  'stageDirectionDeltaId': 'd-stg1',
                },
                // 2 つ目のカットは追加しただけで中身が無い
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
                text: ''),
            _cloudDelta(
                id: 'd-dlg2',
                fieldName: 'dialoguesDelta',
                pageId: 'p1',
                text: ''),
            _cloudDelta(
                id: 'd-stg2',
                fieldName: 'stageDirectionDelta',
                pageId: 'p1',
                text: ''),
          ]);

      final markdown = await repository.toMarkdown(MangaId('mid'));

      expect(markdown, contains('### 本文\n\nセリフ1\n'));
      expect(markdown, isNot(contains('（ト書き）')));
    });

    test('本文が複数行なら 1 行ずつ空行で区切られ、余分な空行は増えない', () async {
      when(firebase.fetchManga('mid'))
          .thenAnswer((_) async => _cloudManga(name: '改行確認'));
      when(firebase.fetchMangaPages('mid')).thenAnswer((_) async => [
            _cloudPage(
              id: 'p1',
              pageIndex: 0,
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
              id: 'd-dlg',
              fieldName: 'dialoguesDelta',
              pageId: 'p1',
              text: 'A「こんにちは」\nB「やあ」\n\nC「またね」',
            ),
          ]);

      final markdown = await repository.toMarkdown(MangaId('mid'));

      expect(markdown, contains('A「こんにちは」\n\nB「やあ」\n\nC「またね」\n'));
      expect(markdown, isNot(contains('\n\n\n')));
    });

    test('セリフの行頭の記号は Markdown の記法にならないようエスケープされる', () async {
      when(firebase.fetchManga('mid'))
          .thenAnswer((_) async => _cloudManga(name: 'エスケープ確認'));
      when(firebase.fetchMangaPages('mid')).thenAnswer((_) async => [
            _cloudPage(
              id: 'p1',
              pageIndex: 0,
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
              id: 'd-dlg',
              fieldName: 'dialoguesDelta',
              pageId: 'p1',
              text: '---\n# 回想\n1. 教室\n> つぶやき',
            ),
          ]);

      final markdown = await repository.toMarkdown(MangaId('mid'));

      expect(markdown, contains('\\---\n'));
      expect(markdown, contains('\\# 回想\n'));
      expect(markdown, contains('1\\. 教室\n'));
      expect(markdown, contains('\\> つぶやき\n'));
      // 作品名・ページ・セクションの見出しはエスケープしない
      expect(markdown, contains('# エスケープ確認'));
      expect(markdown, contains('### 本文'));
    });

    test('ト書きはラベルが付くのでエスケープしない', () async {
      when(firebase.fetchManga('mid'))
          .thenAnswer((_) async => _cloudManga(name: 'ト書きエスケープ'));
      when(firebase.fetchMangaPages('mid')).thenAnswer((_) async => [
            _cloudPage(
              id: 'p1',
              pageIndex: 0,
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
              id: 'd-stg',
              fieldName: 'stageDirectionDelta',
              pageId: 'p1',
              text: '---\n夜の教室',
            ),
          ]);

      final markdown = await repository.toMarkdown(MangaId('mid'));

      expect(markdown, contains('（ト書き）---\n\n（ト書き）夜の教室\n'));
    });

    test('メモは 1 段落にまとめ、続く行を強制改行でつなぐ', () async {
      when(firebase.fetchManga('mid'))
          .thenAnswer((_) async => _cloudManga(name: 'メモ確認'));
      when(firebase.fetchMangaPages('mid')).thenAnswer((_) async => [
            _cloudPage(id: 'p1', pageIndex: 0, memoDeltaId: 'd-memo'),
          ]);
      when(firebase.fetchDeltas('mid')).thenAnswer((_) async => [
            _cloudDelta(
              id: 'd-memo',
              fieldName: 'memoDelta',
              pageId: 'p1',
              text: 'メモ1行目\nメモ2行目',
            ),
          ]);

      final markdown = await repository.toMarkdown(MangaId('mid'));

      expect(markdown, contains('### メモ\n\nメモ1行目  \nメモ2行目\n'));
    });

    test('アイデアメモがある場合は ## アイデアメモ セクションが先頭近くに出力される', () async {
      when(firebase.fetchManga('mid')).thenAnswer(
          (_) async => _cloudManga(name: 'アイデア持ち', ideaMemoDeltaId: 'd-idea'));
      when(firebase.fetchMangaPages('mid')).thenAnswer((_) async => []);
      when(firebase.fetchDeltas('mid')).thenAnswer((_) async => [
            _cloudDelta(id: 'd-idea', fieldName: 'ideaMemo', text: 'これがアイデアです'),
          ]);

      final markdown = await repository.toMarkdown(MangaId('mid'));

      expect(markdown, contains('# アイデア持ち'));
      expect(markdown, contains('## アイデアメモ'));
      expect(markdown, contains('これがアイデアです'));
      // タイトルがアイデアメモより前に来ること
      expect(markdown.indexOf('# アイデア持ち'),
          lessThan(markdown.indexOf('## アイデアメモ')));
    });

    // 変換は my_manga_editor_common の deltaToPlainText に集約されている (FR-005)。
    // Repository の出力にもその整形が効いていることを確認する。
    test('本文の 3 連続以上の改行が圧縮され、前後の空白が落ちる', () async {
      when(firebase.fetchManga('mid'))
          .thenAnswer((_) async => _cloudManga(name: '整形確認'));
      when(firebase.fetchMangaPages('mid')).thenAnswer((_) async => [
            _cloudPage(id: 'p1', pageIndex: 0, memoDeltaId: 'd-memo'),
          ]);
      when(firebase.fetchDeltas('mid')).thenAnswer((_) async => [
            _cloudDelta(
              id: 'd-memo',
              fieldName: 'memoDelta',
              pageId: 'p1',
              text: '  \n\n1 つ目のメモ\n\n\n\n2 つ目のメモ\n  \n',
            ),
          ]);

      final markdown = await repository.toMarkdown(MangaId('mid'));

      expect(markdown, contains('1 つ目のメモ\n\n2 つ目のメモ'));
      expect(markdown, isNot(contains('\n\n\n\n')));
    });

    test('アイデアメモが空 Delta の場合はセクションが出力されない', () async {
      when(firebase.fetchManga('mid')).thenAnswer(
          (_) async => _cloudManga(name: '空アイデア', ideaMemoDeltaId: 'd-idea'));
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
