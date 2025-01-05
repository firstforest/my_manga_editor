import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown_quill/markdown_quill.dart';
import 'package:my_manga_editor/logger.dart';
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

  void updateStartPage(MangaStartPage value) {
    ref.read(mangaRepositoryProvider).updateStartPage(id, value);
  }

  Future<void> download() async {
    final manga = await future;
    if (manga != null) {
      logger.d('download $manga}');
      final content = await toMarkdown();
      await FileSaver.instance.saveFile(
        name: 'komatto_${manga.name}',
        ext: 'txt',
        mimeType: MimeType.text,
        bytes: Uint8List.fromList(utf8.encode(content)),
      );
    }
  }

  Future<String> toMarkdown() async {
    final manga = await future;
    if (manga == null) {
      return '';
    }

    final repo = ref.watch(mangaRepositoryProvider);
    final pageIdList = await repo.watchAllMangaPageIdList(id).first;
    final pageContents = (await Future.wait(pageIdList.map((id) async {
      final page = await ref.read(mangaPageNotifierProvider(id).future);
      final memo = await ref
          .read(deltaNotifierProvider(page.memoDelta).notifier)
          .exportMarkdown();
      final dialogue = await ref
          .read(deltaNotifierProvider(page.dialoguesDelta).notifier)
          .exportMarkdown();
      final stageDirection = await ref
          .read(deltaNotifierProvider(page.stageDirectionDelta).notifier)
          .exportMarkdown();
      final builder = StringBuffer();
      builder.writeln('### 描きたいこと');
      builder.writeln();
      builder.writeln(memo);
      builder.writeln('### セリフ');
      builder.writeln();
      builder.writeln(dialogue);
      builder.writeln('### ト書き');
      builder.writeln();
      builder.writeln(stageDirection);
      return builder.toString();
    })));
    final builder = StringBuffer();
    builder.writeln('# ${manga.name}');
    builder.writeln();
    builder.writeln(await ref
        .read(deltaNotifierProvider(manga.ideaMemo).notifier)
        .exportMarkdown());
    for (int i = 0; i < pageContents.nonNulls.length; i++) {
      builder.writeln('## Page ${i + 1}');
      builder.writeln();
      builder.writeln(pageContents[i]);
    }
    return builder.toString();
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

  Future<String> exportPlainText() async {
    final delta = await future;
    return switch (delta) {
      Delta d when d.isNotEmpty => Document.fromDelta(delta).toPlainText(),
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
