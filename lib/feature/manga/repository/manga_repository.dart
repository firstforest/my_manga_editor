import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:markdown_quill/markdown_quill.dart';
import 'package:my_manga_editor/common/logger.dart';
import 'package:my_manga_editor/feature/manga/model/manga.dart';
import 'package:my_manga_editor/feature/manga/provider/sync_state_notifier.dart';
import 'package:my_manga_editor/service/database/database.dart';
import 'package:my_manga_editor/service/firebase/model/cloud_manga.dart';
import 'package:my_manga_editor/service/firebase/model/cloud_manga_page.dart';
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
    final mangaId = await mangaDao.insertManga(DbMangasCompanion.insert(
      name: '無名の傑作',
      startPage: MangaStartPage.left,
      ideaMemo: ideaMemoId,
    ));

    // Queue for sync
    _ref.read(syncStateProvider.notifier).queueMangaSync(mangaId);

    return mangaId;
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

  Future<Delta?> loadDelta(DeltaId id) async {
    logger.d('loadDelta: $id');
    final dbDelta = await _ref.read(mangaDaoProvider).watchDelta(id).first;
    return dbDelta?.toDelta();
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

    // Note: Delta changes trigger manga sync via parent manga/page updates
    // No direct sync queue here as deltas are always part of manga/page
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

    await mangaDao.insertMangaPage(DbMangaPagesCompanion.insert(
      mangaId: mangaId,
      pageIndex: pageIndex,
      memoDelta: memoDeltaId,
      stageDirectionDelta: stageDirectionDeltaId,
      dialoguesDelta: dialoguesDeltaId,
    ));

    // Queue parent manga for sync (includes all pages)
    _ref.read(syncStateProvider.notifier).queuePageSync(mangaId);
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

  Future<void> updateMangaName(MangaId id, String name) async {
    await _ref
        .read(mangaDaoProvider)
        .updateManga(id, DbMangasCompanion(name: Value(name)));

    // Queue for sync
    _ref.read(syncStateProvider.notifier).queueMangaSync(id);
  }

  Future<void> deleteMangaPage(int pageId) async {
    await _ref.read(mangaDaoProvider).deleteMangaPage(pageId);

    // Note: Page deletion sync is handled as part of manga sync
    // The entire manga (including all pages) will be re-synced
    // TODO: Track mangaId for page deletion cloud sync optimization
  }

  Future<void> deleteManga(int id) async {
    // Delete from cloud first
    await _ref
        .read(syncStateProvider.notifier)
        .deleteMangaFromCloud(id);

    // Then delete from local DB
    await _ref.read(mangaDaoProvider).deleteManga(id);
  }

  Future<void> updateStartPage(int id, MangaStartPage value) async {
    await _ref
        .read(mangaDaoProvider)
        .updateManga(id, DbMangasCompanion(startPage: Value(value)));

    // Queue for sync
    _ref.read(syncStateProvider.notifier).queueMangaSync(id);
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
      final stageDirection =
          await _exportDeltaToMarkdown(page.stageDirectionDelta);

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

  // ============================================================================
  // Firebase Sync Helper Methods
  // ============================================================================

  /// Convert Quill Delta to Map (for Cloud)
  /// Used when uploading delta data to Firestore
  Future<Map<String, dynamic>> getDeltaAsMap(DeltaId id) async {
    final delta = await getDeltaStream(id).first;
    if (delta == null) return {};
    // toJson() returns a list, wrap it in the expected format
    return {'ops': delta.toJson()};
  }

  /// Convert Map to Quill Delta and insert to local DB
  /// Used when downloading delta data from Firestore
  /// Returns the DeltaId of the upserted delta
  Future<DeltaId> upsertDeltaFromMap(Map<String, dynamic> deltaMap) async {
    // Convert Map to List format expected by Delta.fromJson
    final List<dynamic> deltaList = deltaMap['ops'] ?? [];
    final delta = Delta.fromJson(deltaList);
    return await _ref.watch(mangaDaoProvider).upsertDelta(
          DbDeltasCompanion.insert(delta: delta),
        );
  }

  // ============================================================================
  // Cloud Download Methods
  // ============================================================================

  /// Download a CloudManga and insert/update in local DB
  /// Returns the local MangaId
  Future<MangaId> downloadCloudManga(CloudManga cloudManga) async {
    logger.d('Downloading cloud manga: ${cloudManga.name}');

    // Convert CloudManga to local format
    final manga = await cloudManga.toManga(this);

    final mangaDao = _ref.watch(mangaDaoProvider);

    // Upsert: insert or update if exists
    await mangaDao.into(mangaDao.dbMangas).insertOnConflictUpdate(
          DbMangasCompanion.insert(
            id: Value(manga.id),
            name: manga.name,
            startPage: manga.startPage,
            ideaMemo: manga.ideaMemo,
          ),
        );

    logger.d('Upserted manga: ${manga.name} (ID: ${manga.id})');
    return manga.id;
  }

  /// Download a CloudMangaPage and insert/update in local DB
  Future<void> downloadCloudMangaPage(
    CloudMangaPage cloudPage,
    MangaId mangaId,
  ) async {
    logger.d('Downloading cloud page: ${cloudPage.id} for manga: $mangaId');

    // Convert CloudMangaPage to local format
    final page = await cloudPage.toMangaPage(this);

    final mangaDao = _ref.watch(mangaDaoProvider);

    // Upsert: insert or update if exists
    await mangaDao.into(mangaDao.dbMangaPages).insertOnConflictUpdate(
          DbMangaPagesCompanion.insert(
            id: Value(page.id),
            mangaId: mangaId,
            pageIndex: cloudPage.pageIndex,
            memoDelta: page.memoDelta,
            stageDirectionDelta: page.stageDirectionDelta,
            dialoguesDelta: page.dialoguesDelta,
          ),
        );

    logger.d('Upserted page: ${page.id} (pageIndex: ${cloudPage.pageIndex})');
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

// ==============================================================================
// Firebase Cloud Model Conversion Extensions
// ==============================================================================

/// Extension for converting CloudManga to Manga
extension CloudMangaConversion on CloudManga {
  /// Convert CloudManga to Manga domain model
  /// Requires MangaRepository to handle delta conversion
  Future<Manga> toManga(MangaRepository repo) async {
    // Convert Delta Map back to DeltaId by upserting to local DB
    final ideaMemoId = await repo.upsertDeltaFromMap(ideaMemo);

    return Manga(
      id: int.parse(id), // Firestore string ID → SQLite int ID
      name: name,
      startPage: MangaStartPage.values.firstWhere(
        (e) => e.name == startPageDirection,
      ),
      ideaMemo: ideaMemoId,
    );
  }
}

/// Extension for converting Manga to CloudManga
extension MangaToCloudConversion on Manga {
  /// Convert Manga to CloudManga for Firestore upload
  /// Requires MangaRepository to handle delta conversion and userId
  Future<CloudManga> toCloudManga(
    MangaRepository repo,
    String userId,
  ) async {
    // Fetch Delta from local DB and convert to Map
    final ideaMemoMap = await repo.getDeltaAsMap(ideaMemo);

    return CloudManga(
      id: id.toString(), // SQLite int ID → Firestore string ID
      userId: userId,
      name: name,
      startPageDirection: startPage.name,
      ideaMemo: ideaMemoMap,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      editLock: null,
    );
  }
}

/// Extension for converting CloudMangaPage to MangaPage
extension CloudMangaPageConversion on CloudMangaPage {
  /// Convert CloudMangaPage to MangaPage domain model
  /// Requires MangaRepository to handle delta conversion
  Future<MangaPage> toMangaPage(MangaRepository repo) async {
    // Convert Delta Maps back to DeltaIds by upserting to local DB
    final memoDeltaId = await repo.upsertDeltaFromMap(memoDelta);
    final stageDirectionDeltaId =
        await repo.upsertDeltaFromMap(stageDirectionDelta);
    final dialoguesDeltaId = await repo.upsertDeltaFromMap(dialoguesDelta);

    return MangaPage(
      id: int.parse(id), // Firestore string ID → SQLite int ID
      memoDelta: memoDeltaId,
      stageDirectionDelta: stageDirectionDeltaId,
      dialoguesDelta: dialoguesDeltaId,
    );
  }
}

/// Extension for converting MangaPage to CloudMangaPage
extension MangaPageToCloudConversion on MangaPage {
  /// Convert MangaPage to CloudMangaPage for Firestore upload
  /// Requires MangaRepository to handle delta conversion, mangaId, and pageIndex
  Future<CloudMangaPage> toCloudMangaPage(
    MangaRepository repo,
    String mangaId,
    int pageIndex,
  ) async {
    // Fetch Deltas from local DB and convert to Maps
    final memoDeltaMap = await repo.getDeltaAsMap(memoDelta);
    final stageDirectionDeltaMap =
        await repo.getDeltaAsMap(stageDirectionDelta);
    final dialoguesDeltaMap = await repo.getDeltaAsMap(dialoguesDelta);

    return CloudMangaPage(
      id: id.toString(), // SQLite int ID → Firestore string ID
      mangaId: mangaId,
      pageIndex: pageIndex,
      memoDelta: memoDeltaMap,
      stageDirectionDelta: stageDirectionDeltaMap,
      dialoguesDelta: dialoguesDeltaMap,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
