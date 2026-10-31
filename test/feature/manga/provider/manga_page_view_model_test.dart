import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_page_view_model.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor_data/repository/manga_repository.dart';

/// createNewManga / createNewMangaPage だけ使う Fake。
/// 作品の作成を [createGate] で止めておき、その間に Provider が破棄される状況を作る。
class _FakeMangaRepository extends Fake implements MangaRepository {
  final createGate = Completer<void>();
  final createdPagesFor = <MangaId>[];

  @override
  Future<MangaId> createNewManga({
    String name = '無名の傑作',
    List<String> tags = const [],
  }) async {
    await createGate.future;
    return MangaId('mid');
  }

  @override
  Future<String> createNewMangaPage(MangaId mangaId) async {
    createdPagesFor.add(mangaId);
    return 'pid';
  }
}

void main() {
  test('作成を待っている間に誰も監視していなくても、作成を最後まで終えて ID を返す', () async {
    final fakeRepo = _FakeMangaRepository();
    final container = ProviderContainer(overrides: [
      mangaRepositoryProvider.overrideWithValue(fakeRepo),
    ]);
    addTearDown(container.dispose);

    // 画面と同じく、listen せずに notifier を読んで呼ぶ
    final pending =
        container.read(mangaPageViewModelProvider.notifier).createNewManga();

    // 監視者のいない autoDispose の Provider が破棄される機会を与える
    await container.pump();
    await Future<void>.delayed(Duration.zero);

    fakeRepo.createGate.complete();

    expect(await pending, MangaId('mid'));
    expect(fakeRepo.createdPagesFor, [MangaId('mid')]);
  });
}
