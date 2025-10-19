import 'package:drift/drift.dart';

import 'db_delta.dart';
import 'db_manga.dart';

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
