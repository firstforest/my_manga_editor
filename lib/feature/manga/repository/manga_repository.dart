import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:markdown_quill/markdown_quill.dart';
import 'package:my_manga_editor/database/database.dart';
import 'package:my_manga_editor/logger.dart';
import 'package:my_manga_editor/feature/manga/model/manga.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'manga_repository.g.dart';

@Riverpod(keepAlive: true)
MangaRepository mangaRepository(Ref ref) {
  return MangaRepository(
    ref: ref,
    sharedPreferences: SharedPreferences.getInstance(),
  );
}

const directoryName = 'MangaEditor';

class MangaRepository {
  MangaRepository({
    required Ref ref,
    required Future<SharedPreferences> sharedPreferences,
  })  : _ref = ref,
        _sharedPreferences = sharedPreferences;

  final Ref _ref;
  final Future<SharedPreferences> _sharedPreferences;

  Future<void> saveManga(String fileName, Manga manga) async {
    logger.d('saveManga: $manga');
    final directoryRoot = await getApplicationDocumentsDirectory();
    final directory = Directory('${directoryRoot.path}/$directoryName');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(json.encode(manga.toJson()));
  }

  Future<MangaId> createNewManga() async {
    final mangaDao = _ref.watch(mangaDaoProvider);
    final ideaMemoId =
        await mangaDao.upsertDelta(DbDeltasCompanion.insert(delta: Delta()));
    return mangaDao.insertManga(DbMangasCompanion.insert(
      name: '無名の傑作',
      startPage: MangaStartPage.left,
      ideaMemo: ideaMemoId,
    ));
  }

  Future<Manga?> loadManga(String fileName) async {
    logger.d('loadManga');
    final directoryRoot = await getApplicationDocumentsDirectory();
    final file = File('${directoryRoot.path}/$directoryName/$fileName');
    final jsonString = (await file.exists()) ? await file.readAsString() : null;
    if (jsonString == null) {
      return null;
    }
    return Manga.fromJson(json.decode(jsonString));
  }

  Stream<Manga?> watchManga(int id) async* {
    logger.d('watchManga: $id');
  }

  Future<void> clearData() async {
    logger.d('clearData');
    final prefs = await _sharedPreferences;
    await prefs.clear();
  }

  final pages = <MangaPageId, MangaPage>{};

  Stream<MangaPage?> getMangaPageStream(MangaPageId id) {
    return _ref.watch(mangaDaoProvider).watchMangaPage(id).map((dbMangaPage) {
      return dbMangaPage?.toMangaPage();
    });
  }

  Stream<Manga?> getMangaStream(int id) {
    return _ref
        .watch(mangaDaoProvider)
        .watchManga(id)
        .map((dbManga) => dbManga?.toManga());
  }

  Stream<List<Manga>> watchAllMangaList() {
    return _ref
        .watch(mangaDaoProvider)
        .watchAllMangaList()
        .map((mangaList) => mangaList.map((e) => e.toManga()).toList());
  }

  Stream<Delta?> getDeltaStream(DeltaId id) {
    logger.d('getDeltaStream: $id');
    return _ref.watch(mangaDaoProvider).watchDelta(id).map((dbDelta) {
      return dbDelta?.toDelta();
    });
  }

  void saveDelta(DeltaId id, Delta delta) {
    logger.d('saveDelta: $id, $delta');
    _ref
        .watch(mangaDaoProvider)
        .upsertDelta(DbDelta(id: id, delta: delta).toCompanion(true));
  }

  Future<void> createNewMangaPage(MangaId mangaId) async {
    final mangaDao = _ref.watch(mangaDaoProvider);
    final memoDeltaId =
        await mangaDao.upsertDelta(DbDeltasCompanion.insert(delta: Delta()));
    final stageDirectionDeltaId =
        await mangaDao.upsertDelta(DbDeltasCompanion.insert(delta: Delta()));
    final dialoguesDeltaId =
        await mangaDao.upsertDelta(DbDeltasCompanion.insert(delta: Delta()));
    final pageIndex = (await mangaDao.selectAllMangaPageIdList(mangaId)).length;

    return mangaDao.insertMangaPage(DbMangaPagesCompanion.insert(
      mangaId: mangaId,
      pageIndex: pageIndex,
      memoDelta: memoDeltaId,
      stageDirectionDelta: stageDirectionDeltaId,
      dialoguesDelta: dialoguesDeltaId,
    ));
  }

  Stream<List<MangaPageId>> watchAllMangaPageIdList(MangaId mangaId) {
    return _ref.watch(mangaDaoProvider).watchAllMangaPageIdList(mangaId);
  }

  Future<void> reorderPages(MangaId id, List<MangaPageId> pageIdList) async {
    final dao = _ref.read(mangaDaoProvider);
    dao.updateMangaPages(pageIdList
        .mapIndexed((index, pageId) =>
            DbMangaPagesCompanion(id: Value(pageId), pageIndex: Value(index)))
        .toList());
  }

  Future<void> updateMangaName(MangaId id, String name) {
    return _ref
        .read(mangaDaoProvider)
        .updateManga(id, DbMangasCompanion(name: Value(name)));
  }

  Future<void> deleteMangaPage(int pageId) {
    return _ref.read(mangaDaoProvider).deleteMangaPage(pageId);
  }

  Future<void> deleteManga(int id) {
    return _ref.read(mangaDaoProvider).deleteManga(id);
  }

  Future<void> updateStartPage(int id, MangaStartPage value) async {
    return _ref
        .read(mangaDaoProvider)
        .updateManga(id, DbMangasCompanion(startPage: Value(value)));
  }

  Future<String> toMarkdown(MangaId mangaId) async {
    final manga = await getMangaStream(mangaId).first;
    if (manga == null) {
      return '';
    }

    final pageIdList = await watchAllMangaPageIdList(mangaId).first;
    final pageContents = (await Future.wait(pageIdList.map((pageId) async {
      final page = await getMangaPageStream(pageId).first;
      if (page == null) return '';
      
      final memo = await _exportDeltaToMarkdown(page.memoDelta);
      final dialogue = await _exportDeltaToMarkdown(page.dialoguesDelta);
      final stageDirection = await _exportDeltaToMarkdown(page.stageDirectionDelta);
      
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
    builder.writeln(await _exportDeltaToMarkdown(manga.ideaMemo));
    for (int i = 0; i < pageContents.nonNulls.length; i++) {
      builder.writeln('## Page ${i + 1}');
      builder.writeln();
      builder.writeln(pageContents[i]);
    }
    return builder.toString();
  }

  Future<String> _exportDeltaToMarkdown(DeltaId? deltaId) async {
    if (deltaId == null) return '';
    
    final delta = await getDeltaStream(deltaId).first;
    final deltaToMd = DeltaToMarkdown();
    return switch (delta) {
      Delta d when d.isNotEmpty => deltaToMd.convert(d),
      _ => '',
    };
  }
}

extension DbMangaExt on DbManga {
  Manga toManga() {
    return Manga(
      id: id,
      name: name,
      startPage: startPage,
      ideaMemo: ideaMemo,
    );
  }
}

extension DbMangaPageExt on DbMangaPage {
  MangaPage toMangaPage() {
    return MangaPage(
      id: id,
      memoDelta: memoDelta,
      stageDirectionDelta: stageDirectionDelta,
      dialoguesDelta: dialoguesDelta,
    );
  }
}

extension DbDeltaExt on DbDelta {
  Delta toDelta() {
    return delta;
  }
}
