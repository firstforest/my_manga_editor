import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_manga_editor/models/manga.dart';
import 'package:my_manga_editor/repositories/manga_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'manga_providers.g.dart';

@riverpod
Stream<List<Manga>> allMangaList(Ref ref) {
  return ref.watch(mangaRepositoryProvider).watchAllMangaList();
}

@riverpod
Stream<List<MangaPageId>> mangaPageIdList(Ref ref, MangaId mangaId) {
  return ref.watch(mangaRepositoryProvider).watchAllMangaPageIdList(mangaId);
}

@riverpod
class MangaNotifier extends _$MangaNotifier {
  @override
  Stream<Manga?> build(int id) {
    final repo = ref.watch(mangaRepositoryProvider);
    return repo.getMangaStream(id);
  }

  Future<void> addNewPage(int index) async {
    final repo = ref.watch(mangaRepositoryProvider);
    await repo.createNewMangaPage(id);
    final pageIdList = await repo.watchAllMangaPageIdList(id).first;
    await reorderPage(pageIdList, pageIdList.length - 1, index);
  }

  Future<void> reorderPage(
      List<MangaPageId> pageIdList, int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = pageIdList.removeAt(oldIndex);
    pageIdList.insert(newIndex, item);
    ref.read(mangaRepositoryProvider).reorderPages(id, pageIdList);
  }

  Future<void> updateName(String value) async {
    await ref.read(mangaRepositoryProvider).updateMangaName(id, value);
  }

  void delete() {
    ref.read(mangaRepositoryProvider).deleteManga(id);
  }
}

@riverpod
class MangaPageNotifier extends _$MangaPageNotifier {
  @override
  Stream<MangaPage> build(MangaPageId pageId) {
    final repo = ref.watch(mangaRepositoryProvider);
    return repo.getMangaPageStream(pageId).where((e) => e != null).cast();
  }

  void delete() {
    ref.read(mangaRepositoryProvider).deleteMangaPage(pageId);
  }
}

@riverpod
class DeltaNotifier extends _$DeltaNotifier {
  @override
  Stream<Delta?> build(DeltaId? id) {
    if (id == null) {
      return Stream.value(null);
    }
    final repo = ref.watch(mangaRepositoryProvider);
    return repo.getDeltaStream(id);
  }

  void updateDelta(Delta delta) {
    if (id != null) {
      ref.read(mangaRepositoryProvider).saveDelta(id!, delta);
    }
  }
}
