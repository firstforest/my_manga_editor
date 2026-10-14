import 'package:flutter/material.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/manga/provider/clipboard_provider.dart';
import 'package:my_manga_editor/feature/manga/view/copy_page_dialogues.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor_data/repository/manga_repository.dart';
import 'package:super_clipboard/super_clipboard.dart';

// MangaId/DeltaId は extension type のため mockito の自動 fallback と相性が悪い。
// このテストで使うのは getDeltaStream だけなので Fake で十分。
class _FakeMangaRepository extends Fake implements MangaRepository {
  _FakeMangaRepository(this.deltas);

  final Map<String, Delta> deltas;

  @override
  Stream<Delta?> getDeltaStream(MangaId mangaId, DeltaId deltaId) =>
      Stream.value(deltas[deltaId.id]);
}

class _FakeClipboardWriter implements ClipboardWriter {
  int writeCount = 0;

  @override
  Future<void> write(Iterable<DataWriterItem> items) async {
    writeCount++;
  }
}

/// Delta の読み込み自体が失敗するリポジトリ (権限エラー・オフライン等)。
class _FailingMangaRepository extends Fake implements MangaRepository {
  @override
  Stream<Delta?> getDeltaStream(MangaId mangaId, DeltaId deltaId) =>
      Stream.error(StateError('permission denied'));
}

/// クリップボードは存在するが書き込みが失敗する環境。
class _ThrowingClipboardWriter implements ClipboardWriter {
  @override
  Future<void> write(Iterable<DataWriterItem> items) async =>
      throw StateError('clipboard write failed');
}

final _mangaId = MangaId('mid');

MangaPage _page(List<(String, String)> unitDeltaIds) => MangaPage(
      id: MangaPageId('pid'),
      mangaId: _mangaId,
      memoDeltaId: DeltaId('d-memo'),
      sceneUnits: unitDeltaIds
          .map((ids) => SceneUnit(
                dialoguesDeltaId: DeltaId(ids.$1),
                stageDirectionDeltaId: DeltaId(ids.$2),
              ))
          .toList(),
    );

/// コピーボタンだけを持つ最小の画面。
/// MangaPageWidget 本体は Quill エディタを含んで重いので、
/// コピー導線 (ボタン押下 → SnackBar) だけを取り出して検証する。
/// そのため `manga_page_widget.dart` のボタン配線自体はここでは検証していない。
Widget _host({
  required MangaPage page,
  required MangaRepository repository,
  required ClipboardWriter? clipboard,
}) =>
    ProviderScope(
      overrides: [
        mangaRepositoryProvider.overrideWithValue(repository),
        clipboardWriterProvider.overrideWithValue(clipboard),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) => ElevatedButton(
              onPressed: () =>
                  copyPageDialoguesWithFeedback(context, ref, page, 1),
              child: const Text('コピー'),
            ),
          ),
        ),
      ),
    );

Future<void> _tapCopy(WidgetTester tester) async {
  await tester.tap(find.text('コピー'));
  await tester.pumpAndSettle();
}

void main() {
  group('ページのセリフのコピー', () {
    testWidgets('コピーできたら成功の SnackBar が出る (AC-1.2)', (tester) async {
      final clipboard = _FakeClipboardWriter();
      await tester.pumpWidget(_host(
        page: _page([('d-dlg', 'd-stg')]),
        repository: _FakeMangaRepository({
          'd-dlg': Delta()..insert('セリフ本文\n'),
        }),
        clipboard: clipboard,
      ));

      await _tapCopy(tester);

      expect(find.text('Page 1 をコピーしました'), findsOneWidget);
      expect(clipboard.writeCount, 1);
    });

    testWidgets('セリフが空ならクリップボードを書き換えない (AC-1.3)', (tester) async {
      final clipboard = _FakeClipboardWriter();
      await tester.pumpWidget(_host(
        page: _page([('d-dlg', 'd-stg')]),
        repository: _FakeMangaRepository({'d-dlg': Delta()}),
        clipboard: clipboard,
      ));

      await _tapCopy(tester);

      expect(clipboard.writeCount, 0);
      expect(find.text('Page 1 をコピーしました'), findsNothing);
      expect(find.text('Page 1 にコピーするセリフがありません'), findsOneWidget);
    });

    testWidgets('クリップボードが使えない環境では失敗の SnackBar が出る (AC-1.4)', (tester) async {
      await tester.pumpWidget(_host(
        page: _page([('d-dlg', 'd-stg')]),
        repository: _FakeMangaRepository({
          'd-dlg': Delta()..insert('セリフ本文\n'),
        }),
        clipboard: null,
      ));

      await _tapCopy(tester);

      expect(find.text('Page 1 のコピーに失敗しました'), findsOneWidget);
      expect(find.text('Page 1 をコピーしました'), findsNothing);
    });

    testWidgets('クリップボードへの書き込みが失敗しても失敗の SnackBar が出る (AC-1.4)',
        (tester) async {
      await tester.pumpWidget(_host(
        page: _page([('d-dlg', 'd-stg')]),
        repository: _FakeMangaRepository({
          'd-dlg': Delta()..insert('セリフ本文\n'),
        }),
        clipboard: _ThrowingClipboardWriter(),
      ));

      await _tapCopy(tester);

      expect(find.text('Page 1 のコピーに失敗しました'), findsOneWidget);
      expect(find.text('Page 1 をコピーしました'), findsNothing);
    });

    testWidgets('セリフの読み込みに失敗しても失敗の SnackBar が出る (AC-1.4)', (tester) async {
      final clipboard = _FakeClipboardWriter();
      await tester.pumpWidget(_host(
        page: _page([('d-dlg', 'd-stg')]),
        repository: _FailingMangaRepository(),
        clipboard: clipboard,
      ));

      await _tapCopy(tester);

      expect(find.text('Page 1 のコピーに失敗しました'), findsOneWidget);
      expect(clipboard.writeCount, 0);
    });

    testWidgets('複数カットのセリフは 1 回の書き込みにまとめられる (AC-1.1)', (tester) async {
      final clipboard = _FakeClipboardWriter();
      await tester.pumpWidget(_host(
        page: _page([('d-dlg1', 'd-stg1'), ('d-dlg2', 'd-stg2')]),
        repository: _FakeMangaRepository({
          'd-dlg1': Delta()..insert('1 つ目\n'),
          'd-dlg2': Delta()..insert('2 つ目\n'),
        }),
        clipboard: clipboard,
      ));

      await _tapCopy(tester);

      expect(clipboard.writeCount, 1);
      expect(find.text('Page 1 をコピーしました'), findsOneWidget);
    });

    // クリップボードへ渡す本文そのものは DataWriterItem からは取り出せないため、
    // 連結結果は buildPageDialoguesText を直接呼んで確認する。
    testWidgets('カットの順序を保ったまま空行区切りで連結される (AC-1.1)', (tester) async {
      late WidgetRef capturedRef;
      final page = _page([
        ('d-dlg1', 'd-stg1'),
        ('d-dlg2', 'd-stg2'),
        ('d-dlg3', 'd-stg3'),
      ]);
      await tester.pumpWidget(ProviderScope(
        overrides: [
          mangaRepositoryProvider.overrideWithValue(_FakeMangaRepository({
            'd-dlg1': Delta()..insert('1 つ目\n'),
            // 2 つ目は空。空のカットは詰めて連結される
            'd-dlg2': Delta(),
            'd-dlg3': Delta()..insert('3 つ目\n'),
          })),
        ],
        child: MaterialApp(
          home: Consumer(builder: (context, ref, _) {
            capturedRef = ref;
            return const SizedBox.shrink();
          }),
        ),
      ));

      final text = await buildPageDialoguesText(capturedRef, page);

      expect(text, '1 つ目\n\n3 つ目');
    });
  });
}
