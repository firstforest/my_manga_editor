import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_quill/quill_delta.dart';

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
