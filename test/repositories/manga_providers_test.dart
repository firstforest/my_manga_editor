import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_manga_editor/repositories/manga_providers.dart';
import 'package:my_manga_editor/repositories/manga_repository.dart';

@GenerateNiceMocks([MockSpec<MangaRepository>()])
import 'manga_providers_test.mocks.dart';

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
    final deltaId = 10;

    test('クリスタ用のセリフとして出力する', () async {
      when(mockMangaRepository.getDeltaStream(any))
          .thenAnswer((_) => Stream.value(Delta()..insert(testDialogues)));

      final exported = await providerContainer
          .read(deltaNotifierProvider(deltaId).notifier)
          .exportPlainText();

      expect(exported, dataForClipStudio);
    });
  });
}
