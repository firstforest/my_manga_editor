import 'package:flutter/material.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/manga/page/manga_edit_page.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor_data/repository/manga_repository.dart';

/// AppBar のタイトル部 (作品名 / 開始ページ / タグ) が toolbarHeight に収まることを見る。
///
/// タグ欄を足したことで行が増えると RenderFlex overflow になる。
/// overflow は例外として投げられるため、描画できればテストは pass する。
class _FakeMangaRepository extends Fake implements MangaRepository {
  _FakeMangaRepository(this.manga);

  final Manga manga;

  @override
  Stream<Manga?> getMangaStream(MangaId id) => Stream.value(manga);

  @override
  Stream<Delta?> getDeltaStream(MangaId mangaId, DeltaId deltaId) =>
      Stream.value(Delta());
}

Manga _manga({List<String> tags = const []}) => Manga(
      id: MangaId('1'),
      name: '作品名',
      startPage: MangaStartPage.left,
      ideaMemoDeltaId: DeltaId('idea-1'),
      status: MangaStatus.idea,
      tags: tags,
    );

Future<void> _pumpTitle(WidgetTester tester, Manga manga) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mangaRepositoryProvider.overrideWithValue(_FakeMangaRepository(manga)),
      ],
      child: ScreenUtilInit(
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              centerTitle: false,
              toolbarHeight: 100.r,
              title: SizedBox(
                height: 100.r,
                child: MangaTitle(mangaId: manga.id),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('タグが無くても AppBar が崩れない', (tester) async {
    await _pumpTitle(tester, _manga());

    expect(find.text('作品名'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, 'タグ'), findsOneWidget);
  });

  testWidgets('タグが複数あっても AppBar が崩れない', (tester) async {
    await _pumpTitle(
      tester,
      _manga(tags: ['連載:ヒーロー', '商業', '没ネタ', 'あとで読む']),
    );

    expect(find.text('作品名'), findsOneWidget);
    expect(find.widgetWithText(Chip, '連載:ヒーロー'), findsOneWidget);
    // 横スクロールするので、はみ出したタグは描画されないことがある。
    // ここでは overflow 例外が出ないことが確認できればよい。
  });

  testWidgets('長いタグ名があっても AppBar が崩れない', (tester) async {
    await _pumpTitle(tester, _manga(tags: ['あ' * 30]));

    expect(find.text('作品名'), findsOneWidget);
  });
}
