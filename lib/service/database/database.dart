import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:my_manga_editor/common/logger.dart';
import 'package:my_manga_editor/feature/manga/model/manga.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'model/db_delta.dart';
import 'model/db_manga.dart';
import 'model/db_manga_page.dart';

part 'database.g.dart';

@Riverpod(keepAlive: true)
AppDatabase database(Ref ref) {
  return AppDatabase();
}

@DriftDatabase(tables: [DbMangas, DbMangaPages, DbDeltas])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'my_database',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
        onResult: (result) {
          if (result.missingFeatures.isNotEmpty) {
            logger.d(
              'Using ${result.chosenImplementation} due to unsupported '
              'browser features: ${result.missingFeatures}',
            );
          }
        },
      ),
    );
  }
}

@riverpod
MangaDao mangaDao(Ref ref) {
  return MangaDao(ref.watch(databaseProvider));
}

@DriftAccessor(tables: [DbMangas, DbMangaPages, DbDeltas])
class MangaDao extends DatabaseAccessor<AppDatabase> with _$MangaDaoMixin {
  MangaDao(super.db);

  // NOTE: Drift database methods are deprecated - use FirebaseService instead
  // These methods are kept for backwards compatibility during migration

  Stream<DbManga?> watchManga(int id) {
    final query = select(dbMangas)..where((t) => t.id.equals(id));
    return query.watchSingleOrNull();
  }

  Stream<List<DbManga>> watchAllMangaList() {
    final query = select(dbMangas);
    return query.watch();
  }

  Stream<DbDelta?> watchDelta(int id) {
    final query = select(dbDeltas)..where((t) => t.id.equals(id));
    return query.watchSingleOrNull();
  }

  Future<int> upsertDelta(DbDeltasCompanion dbDelta) {
    return into(dbDeltas).insertOnConflictUpdate(dbDelta);
  }

  Stream<DbMangaPage?> watchMangaPage(int id) {
    final query = select(dbMangaPages)..where((t) => t.id.equals(id));
    return query.watchSingleOrNull();
  }

  Future<MangaId> insertManga(DbMangasCompanion dbManga) async {
    final id = await into(dbMangas).insert(dbManga);
    return id.toString(); // Convert int to String for MangaId
  }

  Future<void> insertMangaPage(DbMangaPagesCompanion dbMangaPagesCompanion) {
    return into(dbMangaPages).insert(dbMangaPagesCompanion);
  }

  Stream<List<MangaPageId>> watchAllMangaPageIdList(int mangaId) {
    final query = select(dbMangaPages)
      ..where((t) => t.mangaId.equals(mangaId))
      ..orderBy([(t) => OrderingTerm.asc(t.pageIndex)]);
    return query.map((e) => e.id.toString()).watch(); // Convert to String
  }

  void updateMangaPages(List<DbMangaPagesCompanion> list) {
    batch((b) {
      for (final item in list) {
        b.update(dbMangaPages, item, where: (t) => t.id.equals(item.id.value));
      }
    });
  }

  Future<List<MangaPageId>> selectAllMangaPageIdList(MangaId mangaId) async {
    final mangaIdInt = int.tryParse(mangaId) ?? 0;
    final query = select(dbMangaPages)..where((t) => t.mangaId.equals(mangaIdInt));
    final results = await query.map((e) => e.id.toString()).get();
    return results; // Already List<String>
  }

  Future updateManga(MangaId id, DbMangasCompanion dbMangasCompanion) async {
    final idInt = int.tryParse(id) ?? 0;
    return (update(
      dbMangas,
    )..where((t) => t.id.equals(idInt))).write(dbMangasCompanion);
  }

  Future<void> deleteMangaPage(int pageId) {
    return transaction(() async {
      final page = await (select(
        dbMangaPages,
      )..where((t) => t.id.equals(pageId))).getSingle();
      await (delete(dbMangaPages)..where((t) => t.id.equals(pageId))).go();
      await (delete(dbDeltas)..where((t) => t.id.equals(page.memoDelta))).go();
      await (delete(
        dbDeltas,
      )..where((t) => t.id.equals(page.stageDirectionDelta))).go();
      await (delete(
        dbDeltas,
      )..where((t) => t.id.equals(page.dialoguesDelta))).go();
    });
  }

  Future<void> deleteManga(int id) {
    return (delete(dbMangas)..where((t) => t.id.equals(id))).go();
  }
}
