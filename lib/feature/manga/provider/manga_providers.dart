import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:markdown_quill/markdown_quill.dart';
import 'package:my_manga_editor/common/logger.dart';
import 'package:my_manga_editor/feature/manga/model/manga.dart';
import 'package:my_manga_editor/feature/manga/model/sync_status.dart';
import 'package:my_manga_editor/feature/manga/repository/manga_repository.dart';
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
Stream<SyncStatus> syncStatus(Ref ref) {
  return ref.watch(mangaRepositoryProvider).watchSyncStatus();
}

@riverpod
class MangaNotifier extends _$MangaNotifier {
  @override
  Stream<Manga?> build(MangaId id) {
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

  void updateStartPage(MangaStartPage value) {
    ref.read(mangaRepositoryProvider).updateStartPage(id, value);
  }

  Future<void> download() async {
    final manga = await future;
    if (manga != null) {
      logger.d('download $manga}');
      // TODO: Implement toMarkdown functionality
      // For now, create a simple text export
      final content = 'Manga: ${manga.name}';
      await FileSaver.instance.saveFile(
        name: 'komatto_${manga.name}',
        fileExtension: 'txt',
        mimeType: MimeType.text,
        bytes: Uint8List.fromList(utf8.encode(content)),
      );
    }
  }

  Future<String> toMarkdown() async {
    // TODO: Implement toMarkdown functionality
    return 'Markdown export not yet implemented';
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
  Stream<Delta?> build(DeltaId id) {
    if (id.id.isEmpty) {
      return Stream.value(null);
    }
    final repo = ref.read(mangaRepositoryProvider);
    return repo.getDeltaStream(id.id);
  }

  void updateDelta(Delta delta) {
    ref.read(mangaRepositoryProvider).saveDelta(id, delta);
    state = AsyncValue.data(delta);
  }

  Future<String> exportPlainText() async {
    final delta = await future;
    return switch (delta) {
      Delta d when d.isNotEmpty => Document.fromDelta(delta)
          .toPlainText()
          .replaceAll(RegExp(r'\n\s*\n\s*\n\s*'), '\n\n')
          .trim(),
      _ => '',
    };
  }

  Future<String> exportMarkdown() async {
    final delta = await future;
    final deltaToMd = DeltaToMarkdown();
    return switch (delta) {
      Delta d when d.isNotEmpty => deltaToMd.convert(d),
      _ => '',
    };
  }
}
