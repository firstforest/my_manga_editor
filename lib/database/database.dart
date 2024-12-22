import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_manga_editor/models/manga.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database.g.dart';

@Riverpod(keepAlive: true)
AppDatabase database(Ref ref) {
  return AppDatabase();
}

@DataClassName('DbManga')
class DbMangas extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  IntColumn get startPage => intEnum<MangaStartPage>()();

  IntColumn get ideaMemo => integer().references(DbDeltas, #id)();
}

class DbMangaPages extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get mangaId =>
      integer().references(DbMangas, #id, onDelete: KeyAction.cascade)();

  IntColumn get pageIndex => integer()();

  @ReferenceName('memoDelta')
  IntColumn get memoDelta => integer().references(DbDeltas, #id)();

  @ReferenceName('stageDirectionDelta')
  IntColumn get stageDirectionDelta => integer().references(DbDeltas, #id)();

  @ReferenceName('dialoguesDelta')
  IntColumn get dialoguesDelta => integer().references(DbDeltas, #id)();
}

@DataClassName('DbDelta')
class DbDeltas extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get delta => text().map(const QuillDeltaConverter())();
}

class QuillDeltaConverter extends TypeConverter<Delta, String>
    with JsonTypeConverter<Delta, String> {
  const QuillDeltaConverter();

  @override
  Delta fromSql(String fromDb) {
    return Delta.fromJson(json.decode(fromDb));
  }

  @override
  String toSql(Delta value) {
    return json.encode(value.toJson());
  }
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
    return driftDatabase(name: 'my_database');
  }
}

@riverpod
MangaDao mangaDao(Ref ref) {
  return MangaDao(ref.watch(databaseProvider));
}

@DriftAccessor(tables: [DbMangas, DbMangaPages, DbDeltas])
class MangaDao extends DatabaseAccessor<AppDatabase> with _$MangaDaoMixin {
  MangaDao(super.db);

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

  Future<MangaId> insertManga(DbMangasCompanion dbManga) {
    return into(dbMangas).insert(dbManga);
  }

  Future<void> insertMangaPage(DbMangaPagesCompanion dbMangaPagesCompanion) {
    return into(dbMangaPages).insert(dbMangaPagesCompanion);
  }

  Stream<List<MangaPageId>> watchAllMangaPageIdList(int mangaId) {
    final query = select(dbMangaPages)
      ..where((t) => t.mangaId.equals(mangaId))
      ..orderBy([(t) => OrderingTerm.asc(t.pageIndex)]);
    return query.map((e) => e.id).watch();
  }

  void updateMangaPages(List<DbMangaPagesCompanion> list) {
    batch((b) {
      for (final item in list) {
        b.update(dbMangaPages, item, where: (t) => t.id.equals(item.id.value));
      }
    });
  }

  Future<List<MangaPageId>> selectAllMangaPageIdList(MangaId mangaId) async {
    final query = select(dbMangaPages)..where((t) => t.mangaId.equals(mangaId));
    return await query.map((e) => e.id).get();
  }

  Future updateManga(MangaId id, DbMangasCompanion dbMangasCompanion) async {
    return (update(dbMangas)..where((t) => t.id.equals(id)))
        .write(dbMangasCompanion);
  }

  Future<void> deleteMangaPage(int pageId) {
    return transaction(() async {
      final page = await (select(dbMangaPages)
            ..where((t) => t.id.equals(pageId)))
          .getSingle();
      await (delete(dbMangaPages)..where((t) => t.id.equals(pageId))).go();
      await (delete(dbDeltas)..where((t) => t.id.equals(page.memoDelta))).go();
      await (delete(dbDeltas)
            ..where((t) => t.id.equals(page.stageDirectionDelta)))
          .go();
      await (delete(dbDeltas)..where((t) => t.id.equals(page.dialoguesDelta)))
          .go();
    });
  }

  Future<void> deleteManga(int id) {
    return (delete(dbMangas)..where((t) => t.id.equals(id))).go();
  }
}
