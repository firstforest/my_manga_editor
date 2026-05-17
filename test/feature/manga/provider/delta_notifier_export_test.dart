import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_providers.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor_data/repository/manga_repository.dart';

// MangaId/DeltaId は extension type のため mockito の自動 fallback と相性が悪い。
// このテストでは getDeltaStream / saveDelta だけ使うので Fake で十分。
class _FakeMangaRepository extends Fake implements MangaRepository {
  Delta? delta;

  @override
  Stream<Delta?> getDeltaStream(MangaId mangaId, DeltaId deltaId) =>
      Stream.value(delta);

  @override
  Future<void> saveDelta(MangaId mangaId, DeltaId deltaId, Delta delta) async {
    this.delta = delta;
  }
}

Future<String> _exportFor(
  ProviderContainer container,
  MangaId mangaId,
  DeltaId deltaId,
) async {
  final subscription = container.listen(
    deltaProvider(mangaId, deltaId),
    (_, __) {},
  );
  await container.read(deltaProvider(mangaId, deltaId).future);
  final result = await container
      .read(deltaProvider(mangaId, deltaId).notifier)
      .exportPlainText();
  subscription.close();
  return result;
}

void main() {
  late _FakeMangaRepository fakeRepo;
  late ProviderContainer container;

  setUp(() {
    fakeRepo = _FakeMangaRepository();
    container = ProviderContainer(overrides: [
      mangaRepositoryProvider.overrideWithValue(fakeRepo),
    ]);
  });

  tearDown(() {
    container.dispose();
  });

  final mangaId = MangaId('mid');
  final deltaId = DeltaId('did');

  group('DeltaNotifier.exportPlainText', () {
    // 注意: flutter_quill の Document は末尾改行必須なので、各 Delta の末尾には \n を入れる。
    test('3 連続以上の改行が 2 連続改行に圧縮される', () async {
      fakeRepo.delta = Delta()..insert('A\n\n\n\nB\n');

      final exported = await _exportFor(container, mangaId, deltaId);

      expect(exported, 'A\n\nB');
      expect(exported, isNot(contains('\n\n\n')));
    });

    test('装飾付き Delta から装飾が落ちて本文のみ抽出される', () async {
      fakeRepo.delta = Delta()
        ..insert('Bold', {'bold': true})
        ..insert(' and ')
        ..insert('italic', {'italic': true})
        ..insert('\n');

      final exported = await _exportFor(container, mangaId, deltaId);

      expect(exported, 'Bold and italic');
    });

    test('空 Delta では空文字列を返す', () async {
      fakeRepo.delta = Delta();

      final exported = await _exportFor(container, mangaId, deltaId);

      expect(exported, '');
    });

    test('先頭末尾の空白が trim される', () async {
      fakeRepo.delta = Delta()..insert('   \n\nセリフ本文\n\n   \n');

      final exported = await _exportFor(container, mangaId, deltaId);

      expect(exported, 'セリフ本文');
    });
  });
}
