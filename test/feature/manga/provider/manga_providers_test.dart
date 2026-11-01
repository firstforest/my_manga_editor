import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_providers.dart';
import 'package:my_manga_editor_data/repository/manga_repository.dart';

@GenerateNiceMocks([
  MockSpec<MangaRepository>(
      fallbackGenerators: {#createNewManga: mockCreateNewManga})
])
import 'manga_providers_test.mocks.dart';

Future<MangaId> mockCreateNewManga({
  String? name = '無名の傑作',
  List<String>? tags = const [],
}) =>
    Future.value(MangaId('0'));

final testDialogues = '''セリフ1

セリフ2
の続き


セリフ3

セリフ4


''';

final dataForClipStudio = '''セリフ1

セリフ2
の続き

セリフ3

セリフ4''';

void main() {
  final mockMangaRepository = MockMangaRepository();
  final providerContainer = ProviderContainer(overrides: [
    mangaRepositoryProvider.overrideWithValue(mockMangaRepository)
  ]);

  tearDown(() {
    reset(mockMangaRepository);
  });

  group('DeltaNotifier', () {
    final mangaId = MangaId('mangaId');
    final deltaId = DeltaId('test-delta-id-10');

    test('クリスタ用のセリフとして出力する', () async {
      when(mockMangaRepository.getDeltaStream(any, any))
          .thenAnswer((_) => Stream.value(Delta()..insert(testDialogues)));

      // Keep the provider alive by listening
      final subscription = providerContainer.listen(
        deltaProvider(mangaId, deltaId),
        (previous, next) {},
      );

      // Wait for the stream provider to emit its first value
      await providerContainer.read(deltaProvider(mangaId, deltaId).future);

      final exported = await providerContainer
          .read(deltaProvider(mangaId, deltaId).notifier)
          .exportPlainText();

      expect(exported, dataForClipStudio);

      // Clean up
      subscription.close();
    });
  });

  group('sanitizeFileName', () {
    test('ファイル名に使えない記号がすべて _ に置換される', () {
      expect(sanitizeFileName(r'a/b\c:d*e?f"g<h>i|j'), 'a_b_c_d_e_f_g_h_i_j');
    });

    test('制御文字が _ に置換される', () {
      expect(sanitizeFileName('前\n中\t後'), '前_中_後');
    });

    test('日本語・英数字・その他の記号はそのまま残る', () {
      expect(sanitizeFileName('作品名 vol.2 (完成) - 第1話'), '作品名 vol.2 (完成) - 第1話');
    });

    test('空文字はそのまま空文字を返す', () {
      expect(sanitizeFileName(''), '');
    });
  });

  group('MangaNotifier', () {
    final mangaId = MangaId('mid');
    final p1 = MangaPageId('p1');
    final p2 = MangaPageId('p2');
    final p3 = MangaPageId('p3');

    MangaNotifier notifier() {
      when(mockMangaRepository.getMangaStream(any))
          .thenAnswer((_) => const Stream.empty());
      return providerContainer.read(mangaProvider(mangaId).notifier);
    }

    test('movePage は最新の並びに対してページを前後に動かす', () async {
      when(mockMangaRepository.watchAllMangaPageIdList(mangaId))
          .thenAnswer((_) => Stream.value([p1, p2, p3]));

      expect(await notifier().movePage(p2, 1), isTrue);
      verify(mockMangaRepository.reorderPages(mangaId, [p1, p3, p2])).called(1);

      await notifier().movePage(p2, -1);
      verify(mockMangaRepository.reorderPages(mangaId, [p2, p1, p3])).called(1);
    });

    test('movePage は先頭より前・末尾より後ろへは動かさない', () async {
      when(mockMangaRepository.watchAllMangaPageIdList(mangaId))
          .thenAnswer((_) => Stream.value([p1, p2, p3]));

      expect(await notifier().movePage(p1, -1), isFalse);
      expect(await notifier().movePage(p3, 1), isFalse);

      verifyNever(mockMangaRepository.reorderPages(any, any));
    });

    test('moveSceneUnit は Repository に委譲する', () async {
      await notifier().moveSceneUnit(
        fromPageId: p1,
        dialoguesDeltaId: DeltaId('d'),
        toPageId: p3,
        toIndex: 0,
      );

      verify(mockMangaRepository.moveSceneUnit(
        mangaId: mangaId,
        fromPageId: p1,
        dialoguesDeltaId: DeltaId('d'),
        toPageId: p3,
        toIndex: 0,
      )).called(1);
    });
  });
}
