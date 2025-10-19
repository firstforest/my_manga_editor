import 'package:drift/drift.dart';
import 'package:my_manga_editor/feature/manga/model/manga.dart';

import 'db_delta.dart';

@DataClassName('DbManga')
class DbMangas extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  IntColumn get startPage => intEnum<MangaStartPage>()();

  IntColumn get ideaMemo => integer().references(DbDeltas, #id)();

}
