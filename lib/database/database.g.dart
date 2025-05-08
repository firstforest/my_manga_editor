// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DbDeltasTable extends DbDeltas with TableInfo<$DbDeltasTable, DbDelta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbDeltasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  @override
  late final GeneratedColumnWithTypeConverter<Delta, String> delta =
      GeneratedColumn<String>('delta', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Delta>($DbDeltasTable.$converterdelta);
  @override
  List<GeneratedColumn> get $columns => [id, delta];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_deltas';
  @override
  VerificationContext validateIntegrity(Insertable<DbDelta> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbDelta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbDelta(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      delta: $DbDeltasTable.$converterdelta.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}delta'])!),
    );
  }

  @override
  $DbDeltasTable createAlias(String alias) {
    return $DbDeltasTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Delta, String, String> $converterdelta =
      const QuillDeltaConverter();
}

class DbDelta extends DataClass implements Insertable<DbDelta> {
  final int id;
  final Delta delta;
  const DbDelta({required this.id, required this.delta});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['delta'] =
          Variable<String>($DbDeltasTable.$converterdelta.toSql(delta));
    }
    return map;
  }

  DbDeltasCompanion toCompanion(bool nullToAbsent) {
    return DbDeltasCompanion(
      id: Value(id),
      delta: Value(delta),
    );
  }

  factory DbDelta.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbDelta(
      id: serializer.fromJson<int>(json['id']),
      delta: $DbDeltasTable.$converterdelta
          .fromJson(serializer.fromJson<String>(json['delta'])),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'delta': serializer
          .toJson<String>($DbDeltasTable.$converterdelta.toJson(delta)),
    };
  }

  DbDelta copyWith({int? id, Delta? delta}) => DbDelta(
        id: id ?? this.id,
        delta: delta ?? this.delta,
      );
  DbDelta copyWithCompanion(DbDeltasCompanion data) {
    return DbDelta(
      id: data.id.present ? data.id.value : this.id,
      delta: data.delta.present ? data.delta.value : this.delta,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbDelta(')
          ..write('id: $id, ')
          ..write('delta: $delta')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, delta);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbDelta && other.id == this.id && other.delta == this.delta);
}

class DbDeltasCompanion extends UpdateCompanion<DbDelta> {
  final Value<int> id;
  final Value<Delta> delta;
  const DbDeltasCompanion({
    this.id = const Value.absent(),
    this.delta = const Value.absent(),
  });
  DbDeltasCompanion.insert({
    this.id = const Value.absent(),
    required Delta delta,
  }) : delta = Value(delta);
  static Insertable<DbDelta> custom({
    Expression<int>? id,
    Expression<String>? delta,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (delta != null) 'delta': delta,
    });
  }

  DbDeltasCompanion copyWith({Value<int>? id, Value<Delta>? delta}) {
    return DbDeltasCompanion(
      id: id ?? this.id,
      delta: delta ?? this.delta,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (delta.present) {
      map['delta'] =
          Variable<String>($DbDeltasTable.$converterdelta.toSql(delta.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbDeltasCompanion(')
          ..write('id: $id, ')
          ..write('delta: $delta')
          ..write(')'))
        .toString();
  }
}

class $DbMangasTable extends DbMangas with TableInfo<$DbMangasTable, DbManga> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbMangasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<MangaStartPage, int> startPage =
      GeneratedColumn<int>('start_page', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<MangaStartPage>($DbMangasTable.$converterstartPage);
  static const VerificationMeta _ideaMemoMeta =
      const VerificationMeta('ideaMemo');
  @override
  late final GeneratedColumn<int> ideaMemo = GeneratedColumn<int>(
      'idea_memo', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES db_deltas (id)'));
  @override
  List<GeneratedColumn> get $columns => [id, name, startPage, ideaMemo];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_mangas';
  @override
  VerificationContext validateIntegrity(Insertable<DbManga> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('idea_memo')) {
      context.handle(_ideaMemoMeta,
          ideaMemo.isAcceptableOrUnknown(data['idea_memo']!, _ideaMemoMeta));
    } else if (isInserting) {
      context.missing(_ideaMemoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbManga map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbManga(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      startPage: $DbMangasTable.$converterstartPage.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_page'])!),
      ideaMemo: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}idea_memo'])!,
    );
  }

  @override
  $DbMangasTable createAlias(String alias) {
    return $DbMangasTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MangaStartPage, int, int> $converterstartPage =
      const EnumIndexConverter<MangaStartPage>(MangaStartPage.values);
}

class DbManga extends DataClass implements Insertable<DbManga> {
  final int id;
  final String name;
  final MangaStartPage startPage;
  final int ideaMemo;
  const DbManga(
      {required this.id,
      required this.name,
      required this.startPage,
      required this.ideaMemo});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['start_page'] =
          Variable<int>($DbMangasTable.$converterstartPage.toSql(startPage));
    }
    map['idea_memo'] = Variable<int>(ideaMemo);
    return map;
  }

  DbMangasCompanion toCompanion(bool nullToAbsent) {
    return DbMangasCompanion(
      id: Value(id),
      name: Value(name),
      startPage: Value(startPage),
      ideaMemo: Value(ideaMemo),
    );
  }

  factory DbManga.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbManga(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      startPage: $DbMangasTable.$converterstartPage
          .fromJson(serializer.fromJson<int>(json['startPage'])),
      ideaMemo: serializer.fromJson<int>(json['ideaMemo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'startPage': serializer
          .toJson<int>($DbMangasTable.$converterstartPage.toJson(startPage)),
      'ideaMemo': serializer.toJson<int>(ideaMemo),
    };
  }

  DbManga copyWith(
          {int? id, String? name, MangaStartPage? startPage, int? ideaMemo}) =>
      DbManga(
        id: id ?? this.id,
        name: name ?? this.name,
        startPage: startPage ?? this.startPage,
        ideaMemo: ideaMemo ?? this.ideaMemo,
      );
  DbManga copyWithCompanion(DbMangasCompanion data) {
    return DbManga(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      startPage: data.startPage.present ? data.startPage.value : this.startPage,
      ideaMemo: data.ideaMemo.present ? data.ideaMemo.value : this.ideaMemo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbManga(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('startPage: $startPage, ')
          ..write('ideaMemo: $ideaMemo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, startPage, ideaMemo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbManga &&
          other.id == this.id &&
          other.name == this.name &&
          other.startPage == this.startPage &&
          other.ideaMemo == this.ideaMemo);
}

class DbMangasCompanion extends UpdateCompanion<DbManga> {
  final Value<int> id;
  final Value<String> name;
  final Value<MangaStartPage> startPage;
  final Value<int> ideaMemo;
  const DbMangasCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.startPage = const Value.absent(),
    this.ideaMemo = const Value.absent(),
  });
  DbMangasCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required MangaStartPage startPage,
    required int ideaMemo,
  })  : name = Value(name),
        startPage = Value(startPage),
        ideaMemo = Value(ideaMemo);
  static Insertable<DbManga> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? startPage,
    Expression<int>? ideaMemo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (startPage != null) 'start_page': startPage,
      if (ideaMemo != null) 'idea_memo': ideaMemo,
    });
  }

  DbMangasCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<MangaStartPage>? startPage,
      Value<int>? ideaMemo}) {
    return DbMangasCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      startPage: startPage ?? this.startPage,
      ideaMemo: ideaMemo ?? this.ideaMemo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (startPage.present) {
      map['start_page'] = Variable<int>(
          $DbMangasTable.$converterstartPage.toSql(startPage.value));
    }
    if (ideaMemo.present) {
      map['idea_memo'] = Variable<int>(ideaMemo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbMangasCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('startPage: $startPage, ')
          ..write('ideaMemo: $ideaMemo')
          ..write(')'))
        .toString();
  }
}

class $DbMangaPagesTable extends DbMangaPages
    with TableInfo<$DbMangaPagesTable, DbMangaPage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbMangaPagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _mangaIdMeta =
      const VerificationMeta('mangaId');
  @override
  late final GeneratedColumn<int> mangaId = GeneratedColumn<int>(
      'manga_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES db_mangas (id) ON DELETE CASCADE'));
  static const VerificationMeta _pageIndexMeta =
      const VerificationMeta('pageIndex');
  @override
  late final GeneratedColumn<int> pageIndex = GeneratedColumn<int>(
      'page_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _memoDeltaMeta =
      const VerificationMeta('memoDelta');
  @override
  late final GeneratedColumn<int> memoDelta = GeneratedColumn<int>(
      'memo_delta', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES db_deltas (id)'));
  static const VerificationMeta _stageDirectionDeltaMeta =
      const VerificationMeta('stageDirectionDelta');
  @override
  late final GeneratedColumn<int> stageDirectionDelta = GeneratedColumn<int>(
      'stage_direction_delta', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES db_deltas (id)'));
  static const VerificationMeta _dialoguesDeltaMeta =
      const VerificationMeta('dialoguesDelta');
  @override
  late final GeneratedColumn<int> dialoguesDelta = GeneratedColumn<int>(
      'dialogues_delta', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES db_deltas (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, mangaId, pageIndex, memoDelta, stageDirectionDelta, dialoguesDelta];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_manga_pages';
  @override
  VerificationContext validateIntegrity(Insertable<DbMangaPage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('manga_id')) {
      context.handle(_mangaIdMeta,
          mangaId.isAcceptableOrUnknown(data['manga_id']!, _mangaIdMeta));
    } else if (isInserting) {
      context.missing(_mangaIdMeta);
    }
    if (data.containsKey('page_index')) {
      context.handle(_pageIndexMeta,
          pageIndex.isAcceptableOrUnknown(data['page_index']!, _pageIndexMeta));
    } else if (isInserting) {
      context.missing(_pageIndexMeta);
    }
    if (data.containsKey('memo_delta')) {
      context.handle(_memoDeltaMeta,
          memoDelta.isAcceptableOrUnknown(data['memo_delta']!, _memoDeltaMeta));
    } else if (isInserting) {
      context.missing(_memoDeltaMeta);
    }
    if (data.containsKey('stage_direction_delta')) {
      context.handle(
          _stageDirectionDeltaMeta,
          stageDirectionDelta.isAcceptableOrUnknown(
              data['stage_direction_delta']!, _stageDirectionDeltaMeta));
    } else if (isInserting) {
      context.missing(_stageDirectionDeltaMeta);
    }
    if (data.containsKey('dialogues_delta')) {
      context.handle(
          _dialoguesDeltaMeta,
          dialoguesDelta.isAcceptableOrUnknown(
              data['dialogues_delta']!, _dialoguesDeltaMeta));
    } else if (isInserting) {
      context.missing(_dialoguesDeltaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbMangaPage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbMangaPage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      mangaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}manga_id'])!,
      pageIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_index'])!,
      memoDelta: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}memo_delta'])!,
      stageDirectionDelta: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}stage_direction_delta'])!,
      dialoguesDelta: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}dialogues_delta'])!,
    );
  }

  @override
  $DbMangaPagesTable createAlias(String alias) {
    return $DbMangaPagesTable(attachedDatabase, alias);
  }
}

class DbMangaPage extends DataClass implements Insertable<DbMangaPage> {
  final int id;
  final int mangaId;
  final int pageIndex;
  final int memoDelta;
  final int stageDirectionDelta;
  final int dialoguesDelta;
  const DbMangaPage(
      {required this.id,
      required this.mangaId,
      required this.pageIndex,
      required this.memoDelta,
      required this.stageDirectionDelta,
      required this.dialoguesDelta});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['manga_id'] = Variable<int>(mangaId);
    map['page_index'] = Variable<int>(pageIndex);
    map['memo_delta'] = Variable<int>(memoDelta);
    map['stage_direction_delta'] = Variable<int>(stageDirectionDelta);
    map['dialogues_delta'] = Variable<int>(dialoguesDelta);
    return map;
  }

  DbMangaPagesCompanion toCompanion(bool nullToAbsent) {
    return DbMangaPagesCompanion(
      id: Value(id),
      mangaId: Value(mangaId),
      pageIndex: Value(pageIndex),
      memoDelta: Value(memoDelta),
      stageDirectionDelta: Value(stageDirectionDelta),
      dialoguesDelta: Value(dialoguesDelta),
    );
  }

  factory DbMangaPage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbMangaPage(
      id: serializer.fromJson<int>(json['id']),
      mangaId: serializer.fromJson<int>(json['mangaId']),
      pageIndex: serializer.fromJson<int>(json['pageIndex']),
      memoDelta: serializer.fromJson<int>(json['memoDelta']),
      stageDirectionDelta:
          serializer.fromJson<int>(json['stageDirectionDelta']),
      dialoguesDelta: serializer.fromJson<int>(json['dialoguesDelta']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mangaId': serializer.toJson<int>(mangaId),
      'pageIndex': serializer.toJson<int>(pageIndex),
      'memoDelta': serializer.toJson<int>(memoDelta),
      'stageDirectionDelta': serializer.toJson<int>(stageDirectionDelta),
      'dialoguesDelta': serializer.toJson<int>(dialoguesDelta),
    };
  }

  DbMangaPage copyWith(
          {int? id,
          int? mangaId,
          int? pageIndex,
          int? memoDelta,
          int? stageDirectionDelta,
          int? dialoguesDelta}) =>
      DbMangaPage(
        id: id ?? this.id,
        mangaId: mangaId ?? this.mangaId,
        pageIndex: pageIndex ?? this.pageIndex,
        memoDelta: memoDelta ?? this.memoDelta,
        stageDirectionDelta: stageDirectionDelta ?? this.stageDirectionDelta,
        dialoguesDelta: dialoguesDelta ?? this.dialoguesDelta,
      );
  DbMangaPage copyWithCompanion(DbMangaPagesCompanion data) {
    return DbMangaPage(
      id: data.id.present ? data.id.value : this.id,
      mangaId: data.mangaId.present ? data.mangaId.value : this.mangaId,
      pageIndex: data.pageIndex.present ? data.pageIndex.value : this.pageIndex,
      memoDelta: data.memoDelta.present ? data.memoDelta.value : this.memoDelta,
      stageDirectionDelta: data.stageDirectionDelta.present
          ? data.stageDirectionDelta.value
          : this.stageDirectionDelta,
      dialoguesDelta: data.dialoguesDelta.present
          ? data.dialoguesDelta.value
          : this.dialoguesDelta,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbMangaPage(')
          ..write('id: $id, ')
          ..write('mangaId: $mangaId, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('memoDelta: $memoDelta, ')
          ..write('stageDirectionDelta: $stageDirectionDelta, ')
          ..write('dialoguesDelta: $dialoguesDelta')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, mangaId, pageIndex, memoDelta, stageDirectionDelta, dialoguesDelta);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbMangaPage &&
          other.id == this.id &&
          other.mangaId == this.mangaId &&
          other.pageIndex == this.pageIndex &&
          other.memoDelta == this.memoDelta &&
          other.stageDirectionDelta == this.stageDirectionDelta &&
          other.dialoguesDelta == this.dialoguesDelta);
}

class DbMangaPagesCompanion extends UpdateCompanion<DbMangaPage> {
  final Value<int> id;
  final Value<int> mangaId;
  final Value<int> pageIndex;
  final Value<int> memoDelta;
  final Value<int> stageDirectionDelta;
  final Value<int> dialoguesDelta;
  const DbMangaPagesCompanion({
    this.id = const Value.absent(),
    this.mangaId = const Value.absent(),
    this.pageIndex = const Value.absent(),
    this.memoDelta = const Value.absent(),
    this.stageDirectionDelta = const Value.absent(),
    this.dialoguesDelta = const Value.absent(),
  });
  DbMangaPagesCompanion.insert({
    this.id = const Value.absent(),
    required int mangaId,
    required int pageIndex,
    required int memoDelta,
    required int stageDirectionDelta,
    required int dialoguesDelta,
  })  : mangaId = Value(mangaId),
        pageIndex = Value(pageIndex),
        memoDelta = Value(memoDelta),
        stageDirectionDelta = Value(stageDirectionDelta),
        dialoguesDelta = Value(dialoguesDelta);
  static Insertable<DbMangaPage> custom({
    Expression<int>? id,
    Expression<int>? mangaId,
    Expression<int>? pageIndex,
    Expression<int>? memoDelta,
    Expression<int>? stageDirectionDelta,
    Expression<int>? dialoguesDelta,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mangaId != null) 'manga_id': mangaId,
      if (pageIndex != null) 'page_index': pageIndex,
      if (memoDelta != null) 'memo_delta': memoDelta,
      if (stageDirectionDelta != null)
        'stage_direction_delta': stageDirectionDelta,
      if (dialoguesDelta != null) 'dialogues_delta': dialoguesDelta,
    });
  }

  DbMangaPagesCompanion copyWith(
      {Value<int>? id,
      Value<int>? mangaId,
      Value<int>? pageIndex,
      Value<int>? memoDelta,
      Value<int>? stageDirectionDelta,
      Value<int>? dialoguesDelta}) {
    return DbMangaPagesCompanion(
      id: id ?? this.id,
      mangaId: mangaId ?? this.mangaId,
      pageIndex: pageIndex ?? this.pageIndex,
      memoDelta: memoDelta ?? this.memoDelta,
      stageDirectionDelta: stageDirectionDelta ?? this.stageDirectionDelta,
      dialoguesDelta: dialoguesDelta ?? this.dialoguesDelta,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mangaId.present) {
      map['manga_id'] = Variable<int>(mangaId.value);
    }
    if (pageIndex.present) {
      map['page_index'] = Variable<int>(pageIndex.value);
    }
    if (memoDelta.present) {
      map['memo_delta'] = Variable<int>(memoDelta.value);
    }
    if (stageDirectionDelta.present) {
      map['stage_direction_delta'] = Variable<int>(stageDirectionDelta.value);
    }
    if (dialoguesDelta.present) {
      map['dialogues_delta'] = Variable<int>(dialoguesDelta.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbMangaPagesCompanion(')
          ..write('id: $id, ')
          ..write('mangaId: $mangaId, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('memoDelta: $memoDelta, ')
          ..write('stageDirectionDelta: $stageDirectionDelta, ')
          ..write('dialoguesDelta: $dialoguesDelta')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DbDeltasTable dbDeltas = $DbDeltasTable(this);
  late final $DbMangasTable dbMangas = $DbMangasTable(this);
  late final $DbMangaPagesTable dbMangaPages = $DbMangaPagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [dbDeltas, dbMangas, dbMangaPages];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('db_mangas',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('db_manga_pages', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$DbDeltasTableCreateCompanionBuilder = DbDeltasCompanion Function({
  Value<int> id,
  required Delta delta,
});
typedef $$DbDeltasTableUpdateCompanionBuilder = DbDeltasCompanion Function({
  Value<int> id,
  Value<Delta> delta,
});

final class $$DbDeltasTableReferences
    extends BaseReferences<_$AppDatabase, $DbDeltasTable, DbDelta> {
  $$DbDeltasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DbMangasTable, List<DbManga>> _dbMangasRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.dbMangas,
          aliasName:
              $_aliasNameGenerator(db.dbDeltas.id, db.dbMangas.ideaMemo));

  $$DbMangasTableProcessedTableManager get dbMangasRefs {
    final manager = $$DbMangasTableTableManager($_db, $_db.dbMangas)
        .filter((f) => f.ideaMemo.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dbMangasRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DbMangaPagesTable, List<DbMangaPage>>
      _memoDeltaTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.dbMangaPages,
          aliasName:
              $_aliasNameGenerator(db.dbDeltas.id, db.dbMangaPages.memoDelta));

  $$DbMangaPagesTableProcessedTableManager get memoDelta {
    final manager = $$DbMangaPagesTableTableManager($_db, $_db.dbMangaPages)
        .filter((f) => f.memoDelta.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_memoDeltaTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DbMangaPagesTable, List<DbMangaPage>>
      _stageDirectionDeltaTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.dbMangaPages,
              aliasName: $_aliasNameGenerator(
                  db.dbDeltas.id, db.dbMangaPages.stageDirectionDelta));

  $$DbMangaPagesTableProcessedTableManager get stageDirectionDelta {
    final manager = $$DbMangaPagesTableTableManager($_db, $_db.dbMangaPages)
        .filter((f) =>
            f.stageDirectionDelta.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_stageDirectionDeltaTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DbMangaPagesTable, List<DbMangaPage>>
      _dialoguesDeltaTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.dbMangaPages,
              aliasName: $_aliasNameGenerator(
                  db.dbDeltas.id, db.dbMangaPages.dialoguesDelta));

  $$DbMangaPagesTableProcessedTableManager get dialoguesDelta {
    final manager = $$DbMangaPagesTableTableManager($_db, $_db.dbMangaPages)
        .filter((f) => f.dialoguesDelta.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dialoguesDeltaTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DbDeltasTableFilterComposer
    extends Composer<_$AppDatabase, $DbDeltasTable> {
  $$DbDeltasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Delta, Delta, String> get delta =>
      $composableBuilder(
          column: $table.delta,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  Expression<bool> dbMangasRefs(
      Expression<bool> Function($$DbMangasTableFilterComposer f) f) {
    final $$DbMangasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dbMangas,
        getReferencedColumn: (t) => t.ideaMemo,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbMangasTableFilterComposer(
              $db: $db,
              $table: $db.dbMangas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> memoDelta(
      Expression<bool> Function($$DbMangaPagesTableFilterComposer f) f) {
    final $$DbMangaPagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dbMangaPages,
        getReferencedColumn: (t) => t.memoDelta,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbMangaPagesTableFilterComposer(
              $db: $db,
              $table: $db.dbMangaPages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> stageDirectionDelta(
      Expression<bool> Function($$DbMangaPagesTableFilterComposer f) f) {
    final $$DbMangaPagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dbMangaPages,
        getReferencedColumn: (t) => t.stageDirectionDelta,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbMangaPagesTableFilterComposer(
              $db: $db,
              $table: $db.dbMangaPages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> dialoguesDelta(
      Expression<bool> Function($$DbMangaPagesTableFilterComposer f) f) {
    final $$DbMangaPagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dbMangaPages,
        getReferencedColumn: (t) => t.dialoguesDelta,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbMangaPagesTableFilterComposer(
              $db: $db,
              $table: $db.dbMangaPages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DbDeltasTableOrderingComposer
    extends Composer<_$AppDatabase, $DbDeltasTable> {
  $$DbDeltasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get delta => $composableBuilder(
      column: $table.delta, builder: (column) => ColumnOrderings(column));
}

class $$DbDeltasTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbDeltasTable> {
  $$DbDeltasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Delta, String> get delta =>
      $composableBuilder(column: $table.delta, builder: (column) => column);

  Expression<T> dbMangasRefs<T extends Object>(
      Expression<T> Function($$DbMangasTableAnnotationComposer a) f) {
    final $$DbMangasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dbMangas,
        getReferencedColumn: (t) => t.ideaMemo,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbMangasTableAnnotationComposer(
              $db: $db,
              $table: $db.dbMangas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> memoDelta<T extends Object>(
      Expression<T> Function($$DbMangaPagesTableAnnotationComposer a) f) {
    final $$DbMangaPagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dbMangaPages,
        getReferencedColumn: (t) => t.memoDelta,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbMangaPagesTableAnnotationComposer(
              $db: $db,
              $table: $db.dbMangaPages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> stageDirectionDelta<T extends Object>(
      Expression<T> Function($$DbMangaPagesTableAnnotationComposer a) f) {
    final $$DbMangaPagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dbMangaPages,
        getReferencedColumn: (t) => t.stageDirectionDelta,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbMangaPagesTableAnnotationComposer(
              $db: $db,
              $table: $db.dbMangaPages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> dialoguesDelta<T extends Object>(
      Expression<T> Function($$DbMangaPagesTableAnnotationComposer a) f) {
    final $$DbMangaPagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dbMangaPages,
        getReferencedColumn: (t) => t.dialoguesDelta,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbMangaPagesTableAnnotationComposer(
              $db: $db,
              $table: $db.dbMangaPages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DbDeltasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DbDeltasTable,
    DbDelta,
    $$DbDeltasTableFilterComposer,
    $$DbDeltasTableOrderingComposer,
    $$DbDeltasTableAnnotationComposer,
    $$DbDeltasTableCreateCompanionBuilder,
    $$DbDeltasTableUpdateCompanionBuilder,
    (DbDelta, $$DbDeltasTableReferences),
    DbDelta,
    PrefetchHooks Function(
        {bool dbMangasRefs,
        bool memoDelta,
        bool stageDirectionDelta,
        bool dialoguesDelta})> {
  $$DbDeltasTableTableManager(_$AppDatabase db, $DbDeltasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbDeltasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbDeltasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbDeltasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<Delta> delta = const Value.absent(),
          }) =>
              DbDeltasCompanion(
            id: id,
            delta: delta,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required Delta delta,
          }) =>
              DbDeltasCompanion.insert(
            id: id,
            delta: delta,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$DbDeltasTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {dbMangasRefs = false,
              memoDelta = false,
              stageDirectionDelta = false,
              dialoguesDelta = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (dbMangasRefs) db.dbMangas,
                if (memoDelta) db.dbMangaPages,
                if (stageDirectionDelta) db.dbMangaPages,
                if (dialoguesDelta) db.dbMangaPages
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dbMangasRefs)
                    await $_getPrefetchedData<DbDelta, $DbDeltasTable, DbManga>(
                        currentTable: table,
                        referencedTable:
                            $$DbDeltasTableReferences._dbMangasRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DbDeltasTableReferences(db, table, p0)
                                .dbMangasRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.ideaMemo == item.id),
                        typedResults: items),
                  if (memoDelta)
                    await $_getPrefetchedData<DbDelta, $DbDeltasTable,
                            DbMangaPage>(
                        currentTable: table,
                        referencedTable:
                            $$DbDeltasTableReferences._memoDeltaTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DbDeltasTableReferences(db, table, p0).memoDelta,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.memoDelta == item.id),
                        typedResults: items),
                  if (stageDirectionDelta)
                    await $_getPrefetchedData<DbDelta, $DbDeltasTable,
                            DbMangaPage>(
                        currentTable: table,
                        referencedTable: $$DbDeltasTableReferences
                            ._stageDirectionDeltaTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DbDeltasTableReferences(db, table, p0)
                                .stageDirectionDelta,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.stageDirectionDelta == item.id),
                        typedResults: items),
                  if (dialoguesDelta)
                    await $_getPrefetchedData<DbDelta, $DbDeltasTable,
                            DbMangaPage>(
                        currentTable: table,
                        referencedTable:
                            $$DbDeltasTableReferences._dialoguesDeltaTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DbDeltasTableReferences(db, table, p0)
                                .dialoguesDelta,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.dialoguesDelta == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DbDeltasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DbDeltasTable,
    DbDelta,
    $$DbDeltasTableFilterComposer,
    $$DbDeltasTableOrderingComposer,
    $$DbDeltasTableAnnotationComposer,
    $$DbDeltasTableCreateCompanionBuilder,
    $$DbDeltasTableUpdateCompanionBuilder,
    (DbDelta, $$DbDeltasTableReferences),
    DbDelta,
    PrefetchHooks Function(
        {bool dbMangasRefs,
        bool memoDelta,
        bool stageDirectionDelta,
        bool dialoguesDelta})>;
typedef $$DbMangasTableCreateCompanionBuilder = DbMangasCompanion Function({
  Value<int> id,
  required String name,
  required MangaStartPage startPage,
  required int ideaMemo,
});
typedef $$DbMangasTableUpdateCompanionBuilder = DbMangasCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<MangaStartPage> startPage,
  Value<int> ideaMemo,
});

final class $$DbMangasTableReferences
    extends BaseReferences<_$AppDatabase, $DbMangasTable, DbManga> {
  $$DbMangasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DbDeltasTable _ideaMemoTable(_$AppDatabase db) => db.dbDeltas
      .createAlias($_aliasNameGenerator(db.dbMangas.ideaMemo, db.dbDeltas.id));

  $$DbDeltasTableProcessedTableManager get ideaMemo {
    final $_column = $_itemColumn<int>('idea_memo')!;

    final manager = $$DbDeltasTableTableManager($_db, $_db.dbDeltas)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ideaMemoTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$DbMangaPagesTable, List<DbMangaPage>>
      _dbMangaPagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.dbMangaPages,
          aliasName:
              $_aliasNameGenerator(db.dbMangas.id, db.dbMangaPages.mangaId));

  $$DbMangaPagesTableProcessedTableManager get dbMangaPagesRefs {
    final manager = $$DbMangaPagesTableTableManager($_db, $_db.dbMangaPages)
        .filter((f) => f.mangaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dbMangaPagesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DbMangasTableFilterComposer
    extends Composer<_$AppDatabase, $DbMangasTable> {
  $$DbMangasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<MangaStartPage, MangaStartPage, int>
      get startPage => $composableBuilder(
          column: $table.startPage,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  $$DbDeltasTableFilterComposer get ideaMemo {
    final $$DbDeltasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ideaMemo,
        referencedTable: $db.dbDeltas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbDeltasTableFilterComposer(
              $db: $db,
              $table: $db.dbDeltas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> dbMangaPagesRefs(
      Expression<bool> Function($$DbMangaPagesTableFilterComposer f) f) {
    final $$DbMangaPagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dbMangaPages,
        getReferencedColumn: (t) => t.mangaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbMangaPagesTableFilterComposer(
              $db: $db,
              $table: $db.dbMangaPages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DbMangasTableOrderingComposer
    extends Composer<_$AppDatabase, $DbMangasTable> {
  $$DbMangasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startPage => $composableBuilder(
      column: $table.startPage, builder: (column) => ColumnOrderings(column));

  $$DbDeltasTableOrderingComposer get ideaMemo {
    final $$DbDeltasTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ideaMemo,
        referencedTable: $db.dbDeltas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbDeltasTableOrderingComposer(
              $db: $db,
              $table: $db.dbDeltas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DbMangasTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbMangasTable> {
  $$DbMangasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MangaStartPage, int> get startPage =>
      $composableBuilder(column: $table.startPage, builder: (column) => column);

  $$DbDeltasTableAnnotationComposer get ideaMemo {
    final $$DbDeltasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ideaMemo,
        referencedTable: $db.dbDeltas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbDeltasTableAnnotationComposer(
              $db: $db,
              $table: $db.dbDeltas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> dbMangaPagesRefs<T extends Object>(
      Expression<T> Function($$DbMangaPagesTableAnnotationComposer a) f) {
    final $$DbMangaPagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dbMangaPages,
        getReferencedColumn: (t) => t.mangaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbMangaPagesTableAnnotationComposer(
              $db: $db,
              $table: $db.dbMangaPages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DbMangasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DbMangasTable,
    DbManga,
    $$DbMangasTableFilterComposer,
    $$DbMangasTableOrderingComposer,
    $$DbMangasTableAnnotationComposer,
    $$DbMangasTableCreateCompanionBuilder,
    $$DbMangasTableUpdateCompanionBuilder,
    (DbManga, $$DbMangasTableReferences),
    DbManga,
    PrefetchHooks Function({bool ideaMemo, bool dbMangaPagesRefs})> {
  $$DbMangasTableTableManager(_$AppDatabase db, $DbMangasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbMangasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbMangasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbMangasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<MangaStartPage> startPage = const Value.absent(),
            Value<int> ideaMemo = const Value.absent(),
          }) =>
              DbMangasCompanion(
            id: id,
            name: name,
            startPage: startPage,
            ideaMemo: ideaMemo,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required MangaStartPage startPage,
            required int ideaMemo,
          }) =>
              DbMangasCompanion.insert(
            id: id,
            name: name,
            startPage: startPage,
            ideaMemo: ideaMemo,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$DbMangasTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {ideaMemo = false, dbMangaPagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (dbMangaPagesRefs) db.dbMangaPages],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (ideaMemo) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ideaMemo,
                    referencedTable:
                        $$DbMangasTableReferences._ideaMemoTable(db),
                    referencedColumn:
                        $$DbMangasTableReferences._ideaMemoTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dbMangaPagesRefs)
                    await $_getPrefetchedData<DbManga, $DbMangasTable,
                            DbMangaPage>(
                        currentTable: table,
                        referencedTable: $$DbMangasTableReferences
                            ._dbMangaPagesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DbMangasTableReferences(db, table, p0)
                                .dbMangaPagesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.mangaId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DbMangasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DbMangasTable,
    DbManga,
    $$DbMangasTableFilterComposer,
    $$DbMangasTableOrderingComposer,
    $$DbMangasTableAnnotationComposer,
    $$DbMangasTableCreateCompanionBuilder,
    $$DbMangasTableUpdateCompanionBuilder,
    (DbManga, $$DbMangasTableReferences),
    DbManga,
    PrefetchHooks Function({bool ideaMemo, bool dbMangaPagesRefs})>;
typedef $$DbMangaPagesTableCreateCompanionBuilder = DbMangaPagesCompanion
    Function({
  Value<int> id,
  required int mangaId,
  required int pageIndex,
  required int memoDelta,
  required int stageDirectionDelta,
  required int dialoguesDelta,
});
typedef $$DbMangaPagesTableUpdateCompanionBuilder = DbMangaPagesCompanion
    Function({
  Value<int> id,
  Value<int> mangaId,
  Value<int> pageIndex,
  Value<int> memoDelta,
  Value<int> stageDirectionDelta,
  Value<int> dialoguesDelta,
});

final class $$DbMangaPagesTableReferences
    extends BaseReferences<_$AppDatabase, $DbMangaPagesTable, DbMangaPage> {
  $$DbMangaPagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DbMangasTable _mangaIdTable(_$AppDatabase db) =>
      db.dbMangas.createAlias(
          $_aliasNameGenerator(db.dbMangaPages.mangaId, db.dbMangas.id));

  $$DbMangasTableProcessedTableManager get mangaId {
    final $_column = $_itemColumn<int>('manga_id')!;

    final manager = $$DbMangasTableTableManager($_db, $_db.dbMangas)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mangaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $DbDeltasTable _memoDeltaTable(_$AppDatabase db) =>
      db.dbDeltas.createAlias(
          $_aliasNameGenerator(db.dbMangaPages.memoDelta, db.dbDeltas.id));

  $$DbDeltasTableProcessedTableManager get memoDelta {
    final $_column = $_itemColumn<int>('memo_delta')!;

    final manager = $$DbDeltasTableTableManager($_db, $_db.dbDeltas)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memoDeltaTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $DbDeltasTable _stageDirectionDeltaTable(_$AppDatabase db) =>
      db.dbDeltas.createAlias($_aliasNameGenerator(
          db.dbMangaPages.stageDirectionDelta, db.dbDeltas.id));

  $$DbDeltasTableProcessedTableManager get stageDirectionDelta {
    final $_column = $_itemColumn<int>('stage_direction_delta')!;

    final manager = $$DbDeltasTableTableManager($_db, $_db.dbDeltas)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stageDirectionDeltaTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $DbDeltasTable _dialoguesDeltaTable(_$AppDatabase db) =>
      db.dbDeltas.createAlias(
          $_aliasNameGenerator(db.dbMangaPages.dialoguesDelta, db.dbDeltas.id));

  $$DbDeltasTableProcessedTableManager get dialoguesDelta {
    final $_column = $_itemColumn<int>('dialogues_delta')!;

    final manager = $$DbDeltasTableTableManager($_db, $_db.dbDeltas)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dialoguesDeltaTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DbMangaPagesTableFilterComposer
    extends Composer<_$AppDatabase, $DbMangaPagesTable> {
  $$DbMangaPagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageIndex => $composableBuilder(
      column: $table.pageIndex, builder: (column) => ColumnFilters(column));

  $$DbMangasTableFilterComposer get mangaId {
    final $$DbMangasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mangaId,
        referencedTable: $db.dbMangas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbMangasTableFilterComposer(
              $db: $db,
              $table: $db.dbMangas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DbDeltasTableFilterComposer get memoDelta {
    final $$DbDeltasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.memoDelta,
        referencedTable: $db.dbDeltas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbDeltasTableFilterComposer(
              $db: $db,
              $table: $db.dbDeltas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DbDeltasTableFilterComposer get stageDirectionDelta {
    final $$DbDeltasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.stageDirectionDelta,
        referencedTable: $db.dbDeltas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbDeltasTableFilterComposer(
              $db: $db,
              $table: $db.dbDeltas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DbDeltasTableFilterComposer get dialoguesDelta {
    final $$DbDeltasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dialoguesDelta,
        referencedTable: $db.dbDeltas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbDeltasTableFilterComposer(
              $db: $db,
              $table: $db.dbDeltas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DbMangaPagesTableOrderingComposer
    extends Composer<_$AppDatabase, $DbMangaPagesTable> {
  $$DbMangaPagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageIndex => $composableBuilder(
      column: $table.pageIndex, builder: (column) => ColumnOrderings(column));

  $$DbMangasTableOrderingComposer get mangaId {
    final $$DbMangasTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mangaId,
        referencedTable: $db.dbMangas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbMangasTableOrderingComposer(
              $db: $db,
              $table: $db.dbMangas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DbDeltasTableOrderingComposer get memoDelta {
    final $$DbDeltasTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.memoDelta,
        referencedTable: $db.dbDeltas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbDeltasTableOrderingComposer(
              $db: $db,
              $table: $db.dbDeltas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DbDeltasTableOrderingComposer get stageDirectionDelta {
    final $$DbDeltasTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.stageDirectionDelta,
        referencedTable: $db.dbDeltas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbDeltasTableOrderingComposer(
              $db: $db,
              $table: $db.dbDeltas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DbDeltasTableOrderingComposer get dialoguesDelta {
    final $$DbDeltasTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dialoguesDelta,
        referencedTable: $db.dbDeltas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbDeltasTableOrderingComposer(
              $db: $db,
              $table: $db.dbDeltas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DbMangaPagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbMangaPagesTable> {
  $$DbMangaPagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pageIndex =>
      $composableBuilder(column: $table.pageIndex, builder: (column) => column);

  $$DbMangasTableAnnotationComposer get mangaId {
    final $$DbMangasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mangaId,
        referencedTable: $db.dbMangas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbMangasTableAnnotationComposer(
              $db: $db,
              $table: $db.dbMangas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DbDeltasTableAnnotationComposer get memoDelta {
    final $$DbDeltasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.memoDelta,
        referencedTable: $db.dbDeltas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbDeltasTableAnnotationComposer(
              $db: $db,
              $table: $db.dbDeltas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DbDeltasTableAnnotationComposer get stageDirectionDelta {
    final $$DbDeltasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.stageDirectionDelta,
        referencedTable: $db.dbDeltas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbDeltasTableAnnotationComposer(
              $db: $db,
              $table: $db.dbDeltas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DbDeltasTableAnnotationComposer get dialoguesDelta {
    final $$DbDeltasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dialoguesDelta,
        referencedTable: $db.dbDeltas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbDeltasTableAnnotationComposer(
              $db: $db,
              $table: $db.dbDeltas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DbMangaPagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DbMangaPagesTable,
    DbMangaPage,
    $$DbMangaPagesTableFilterComposer,
    $$DbMangaPagesTableOrderingComposer,
    $$DbMangaPagesTableAnnotationComposer,
    $$DbMangaPagesTableCreateCompanionBuilder,
    $$DbMangaPagesTableUpdateCompanionBuilder,
    (DbMangaPage, $$DbMangaPagesTableReferences),
    DbMangaPage,
    PrefetchHooks Function(
        {bool mangaId,
        bool memoDelta,
        bool stageDirectionDelta,
        bool dialoguesDelta})> {
  $$DbMangaPagesTableTableManager(_$AppDatabase db, $DbMangaPagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbMangaPagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbMangaPagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbMangaPagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> mangaId = const Value.absent(),
            Value<int> pageIndex = const Value.absent(),
            Value<int> memoDelta = const Value.absent(),
            Value<int> stageDirectionDelta = const Value.absent(),
            Value<int> dialoguesDelta = const Value.absent(),
          }) =>
              DbMangaPagesCompanion(
            id: id,
            mangaId: mangaId,
            pageIndex: pageIndex,
            memoDelta: memoDelta,
            stageDirectionDelta: stageDirectionDelta,
            dialoguesDelta: dialoguesDelta,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int mangaId,
            required int pageIndex,
            required int memoDelta,
            required int stageDirectionDelta,
            required int dialoguesDelta,
          }) =>
              DbMangaPagesCompanion.insert(
            id: id,
            mangaId: mangaId,
            pageIndex: pageIndex,
            memoDelta: memoDelta,
            stageDirectionDelta: stageDirectionDelta,
            dialoguesDelta: dialoguesDelta,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DbMangaPagesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {mangaId = false,
              memoDelta = false,
              stageDirectionDelta = false,
              dialoguesDelta = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (mangaId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.mangaId,
                    referencedTable:
                        $$DbMangaPagesTableReferences._mangaIdTable(db),
                    referencedColumn:
                        $$DbMangaPagesTableReferences._mangaIdTable(db).id,
                  ) as T;
                }
                if (memoDelta) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.memoDelta,
                    referencedTable:
                        $$DbMangaPagesTableReferences._memoDeltaTable(db),
                    referencedColumn:
                        $$DbMangaPagesTableReferences._memoDeltaTable(db).id,
                  ) as T;
                }
                if (stageDirectionDelta) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.stageDirectionDelta,
                    referencedTable: $$DbMangaPagesTableReferences
                        ._stageDirectionDeltaTable(db),
                    referencedColumn: $$DbMangaPagesTableReferences
                        ._stageDirectionDeltaTable(db)
                        .id,
                  ) as T;
                }
                if (dialoguesDelta) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.dialoguesDelta,
                    referencedTable:
                        $$DbMangaPagesTableReferences._dialoguesDeltaTable(db),
                    referencedColumn: $$DbMangaPagesTableReferences
                        ._dialoguesDeltaTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$DbMangaPagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DbMangaPagesTable,
    DbMangaPage,
    $$DbMangaPagesTableFilterComposer,
    $$DbMangaPagesTableOrderingComposer,
    $$DbMangaPagesTableAnnotationComposer,
    $$DbMangaPagesTableCreateCompanionBuilder,
    $$DbMangaPagesTableUpdateCompanionBuilder,
    (DbMangaPage, $$DbMangaPagesTableReferences),
    DbMangaPage,
    PrefetchHooks Function(
        {bool mangaId,
        bool memoDelta,
        bool stageDirectionDelta,
        bool dialoguesDelta})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DbDeltasTableTableManager get dbDeltas =>
      $$DbDeltasTableTableManager(_db, _db.dbDeltas);
  $$DbMangasTableTableManager get dbMangas =>
      $$DbMangasTableTableManager(_db, _db.dbMangas);
  $$DbMangaPagesTableTableManager get dbMangaPages =>
      $$DbMangaPagesTableTableManager(_db, _db.dbMangaPages);
}

mixin _$MangaDaoMixin on DatabaseAccessor<AppDatabase> {
  $DbDeltasTable get dbDeltas => attachedDatabase.dbDeltas;
  $DbMangasTable get dbMangas => attachedDatabase.dbMangas;
  $DbMangaPagesTable get dbMangaPages => attachedDatabase.dbMangaPages;
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$databaseHash() => r'e5a1fa0e8ff9aa131f847f28519ec2098e6d0f76';

/// See also [database].
@ProviderFor(database)
final databaseProvider = Provider<AppDatabase>.internal(
  database,
  name: r'databaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$databaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DatabaseRef = ProviderRef<AppDatabase>;
String _$mangaDaoHash() => r'b414ae23e61df1fccf30bc57e1c9bbd715d87fcf';

/// See also [mangaDao].
@ProviderFor(mangaDao)
final mangaDaoProvider = AutoDisposeProvider<MangaDao>.internal(
  mangaDao,
  name: r'mangaDaoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$mangaDaoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MangaDaoRef = AutoDisposeProviderRef<MangaDao>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
