// 編集画面の AppBar (作品名 / 開始ページ / タグ) が toolbarHeight に収まることを見る。
//
// AppBar の高さやタイトルの構造はテスト側で組み直さず、実物の MangaEditPage を
// そのまま描画して確かめる。検証は 2 つ。
// - タイトル行が AppBar の高さをはみ出さないこと。AppBar は title を
//   toolbarHeight に押し込まないので、はみ出しても例外にはならない
// - 行が増えるなどしてタイトルの高さが足りなくなると RenderFlex overflow の
//   例外が出る。これは描画できた時点で検出される

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/manga/page/manga_edit_page.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor_data/repository/manga_repository.dart';

class _FakeMangaRepository extends Fake implements MangaRepository {
  _FakeMangaRepository(this.manga);

  final Manga manga;

  @override
  Stream<Manga?> getMangaStream(MangaId id) => Stream.value(manga);

  @override
  Stream<List<Manga>> watchAllMangaList() => Stream.value([manga]);

  @override
  Stream<Delta?> getDeltaStream(MangaId mangaId, DeltaId deltaId) =>
      Stream.value(Delta());

  @override
  Stream<List<MangaPageId>> watchAllMangaPageIdList(MangaId mangaId) =>
      Stream.value(const []);

  @override
  Stream<bool> watchOnlineStatus() => Stream.value(true);
}

Manga _manga({List<String> tags = const []}) => Manga(
      id: MangaId('1'),
      name: '作品名',
      startPage: MangaStartPage.left,
      ideaMemoDeltaId: DeltaId('idea-1'),
      status: MangaStatus.idea,
      tags: tags,
    );

Future<void> _pumpEditPage(WidgetTester tester, Manga manga) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mangaRepositoryProvider.overrideWithValue(_FakeMangaRepository(manga)),
      ],
      child: ScreenUtilInit(
        builder: (context, child) => MaterialApp(
          localizationsDelegates:
              FlutterQuillLocalizations.localizationsDelegates,
          home: MangaEditPage(mangaId: manga.id),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// タイトル行が AppBar の高さに収まっていることを確かめる
void _expectTitleFitsInAppBar(WidgetTester tester) {
  final appBar = tester.getRect(find.byType(AppBar));
  final title = tester.getRect(find.byType(MangaTitle));

  expect(
    title.height,
    lessThanOrEqualTo(appBar.height),
    reason: 'タイトル行が AppBar (toolbarHeight) からはみ出している',
  );
  expect(
    title.bottom,
    lessThanOrEqualTo(appBar.bottom),
    reason: 'タイトル行が AppBar の下端からはみ出している',
  );
}

void main() {
  testWidgets('タグが無くても AppBar が崩れない', (tester) async {
    await _pumpEditPage(tester, _manga());

    expect(find.text('作品名'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, 'タグ'), findsOneWidget);
    _expectTitleFitsInAppBar(tester);
  });

  testWidgets('タグが複数あっても AppBar が崩れない', (tester) async {
    await _pumpEditPage(
      tester,
      _manga(tags: ['連載:ヒーロー', '商業', '没ネタ', 'あとで読む']),
    );

    expect(find.text('作品名'), findsOneWidget);
    expect(find.widgetWithText(Chip, '連載:ヒーロー'), findsOneWidget);
    // 横スクロールするので、はみ出したタグは描画されないことがある。
    // ここでは高さが収まっていることが確認できればよい。
    _expectTitleFitsInAppBar(tester);
  });

  testWidgets('長いタグ名があっても AppBar が崩れない', (tester) async {
    await _pumpEditPage(tester, _manga(tags: ['あ' * 30]));

    expect(find.text('作品名'), findsOneWidget);
    _expectTitleFitsInAppBar(tester);
  });
}
