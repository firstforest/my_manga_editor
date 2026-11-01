import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_creator.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor_data/repository/manga_repository.dart';

/// createNewManga / createNewMangaPage だけ使う Fake。
/// 作品の作成を [createGate] で止めておき、その間に Provider が破棄されうる状況を作る。
class _FakeMangaRepository extends Fake implements MangaRepository {
  final createGate = Completer<void>();
  final createdTags = <List<String>>[];
  final createdPagesFor = <MangaId>[];

  @override
  Future<MangaId> createNewManga({
    String name = '無名の傑作',
    List<String> tags = const [],
  }) async {
    createdTags.add(tags);
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
  test('監視していなくても、書き込みを待つ間に破棄されずに作品と最初のページを作る', () async {
    final repository = _FakeMangaRepository();
    final container = ProviderContainer(overrides: [
      mangaRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);

    // 画面と同じく、listen せずに notifier を読んで呼ぶ
    final pending = container
        .read(mangaCreatorProvider.notifier)
        .create(tags: const ['商業']);

    // 監視者のいない Provider が破棄される機会を与える
    await container.pump();
    await Future<void>.delayed(Duration.zero);

    repository.createGate.complete();

    expect(await pending, MangaId('mid'));
    expect(repository.createdTags, [
      const ['商業'],
    ]);
    expect(repository.createdPagesFor, [MangaId('mid')]);
  });
}
