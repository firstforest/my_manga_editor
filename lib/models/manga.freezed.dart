// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'manga.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Manga _$MangaFromJson(Map<String, dynamic> json) {
  return _Manga.fromJson(json);
}

/// @nodoc
mixin _$Manga {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  MangaStartPage get startPage => throw _privateConstructorUsedError;
  int get ideaMemo => throw _privateConstructorUsedError;

  /// Serializes this Manga to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Manga
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MangaCopyWith<Manga> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MangaCopyWith<$Res> {
  factory $MangaCopyWith(Manga value, $Res Function(Manga) then) =
      _$MangaCopyWithImpl<$Res, Manga>;
  @useResult
  $Res call({int id, String name, MangaStartPage startPage, int ideaMemo});
}

/// @nodoc
class _$MangaCopyWithImpl<$Res, $Val extends Manga>
    implements $MangaCopyWith<$Res> {
  _$MangaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Manga
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? startPage = null,
    Object? ideaMemo = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      startPage: null == startPage
          ? _value.startPage
          : startPage // ignore: cast_nullable_to_non_nullable
              as MangaStartPage,
      ideaMemo: null == ideaMemo
          ? _value.ideaMemo
          : ideaMemo // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MangaImplCopyWith<$Res> implements $MangaCopyWith<$Res> {
  factory _$$MangaImplCopyWith(
          _$MangaImpl value, $Res Function(_$MangaImpl) then) =
      __$$MangaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name, MangaStartPage startPage, int ideaMemo});
}

/// @nodoc
class __$$MangaImplCopyWithImpl<$Res>
    extends _$MangaCopyWithImpl<$Res, _$MangaImpl>
    implements _$$MangaImplCopyWith<$Res> {
  __$$MangaImplCopyWithImpl(
      _$MangaImpl _value, $Res Function(_$MangaImpl) _then)
      : super(_value, _then);

  /// Create a copy of Manga
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? startPage = null,
    Object? ideaMemo = null,
  }) {
    return _then(_$MangaImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      startPage: null == startPage
          ? _value.startPage
          : startPage // ignore: cast_nullable_to_non_nullable
              as MangaStartPage,
      ideaMemo: null == ideaMemo
          ? _value.ideaMemo
          : ideaMemo // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MangaImpl implements _Manga {
  const _$MangaImpl(
      {required this.id,
      required this.name,
      required this.startPage,
      required this.ideaMemo});

  factory _$MangaImpl.fromJson(Map<String, dynamic> json) =>
      _$$MangaImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final MangaStartPage startPage;
  @override
  final int ideaMemo;

  @override
  String toString() {
    return 'Manga(id: $id, name: $name, startPage: $startPage, ideaMemo: $ideaMemo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MangaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.startPage, startPage) ||
                other.startPage == startPage) &&
            (identical(other.ideaMemo, ideaMemo) ||
                other.ideaMemo == ideaMemo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, startPage, ideaMemo);

  /// Create a copy of Manga
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MangaImplCopyWith<_$MangaImpl> get copyWith =>
      __$$MangaImplCopyWithImpl<_$MangaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MangaImplToJson(
      this,
    );
  }
}

abstract class _Manga implements Manga {
  const factory _Manga(
      {required final int id,
      required final String name,
      required final MangaStartPage startPage,
      required final int ideaMemo}) = _$MangaImpl;

  factory _Manga.fromJson(Map<String, dynamic> json) = _$MangaImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  MangaStartPage get startPage;
  @override
  int get ideaMemo;

  /// Create a copy of Manga
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MangaImplCopyWith<_$MangaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MangaPage _$MangaPageFromJson(Map<String, dynamic> json) {
  return _MangaPage.fromJson(json);
}

/// @nodoc
mixin _$MangaPage {
  int get id => throw _privateConstructorUsedError;
  int get memoDelta => throw _privateConstructorUsedError;
  int get stageDirectionDelta => throw _privateConstructorUsedError;
  int get dialoguesDelta => throw _privateConstructorUsedError;

  /// Serializes this MangaPage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MangaPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MangaPageCopyWith<MangaPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MangaPageCopyWith<$Res> {
  factory $MangaPageCopyWith(MangaPage value, $Res Function(MangaPage) then) =
      _$MangaPageCopyWithImpl<$Res, MangaPage>;
  @useResult
  $Res call(
      {int id, int memoDelta, int stageDirectionDelta, int dialoguesDelta});
}

/// @nodoc
class _$MangaPageCopyWithImpl<$Res, $Val extends MangaPage>
    implements $MangaPageCopyWith<$Res> {
  _$MangaPageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MangaPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? memoDelta = null,
    Object? stageDirectionDelta = null,
    Object? dialoguesDelta = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      memoDelta: null == memoDelta
          ? _value.memoDelta
          : memoDelta // ignore: cast_nullable_to_non_nullable
              as int,
      stageDirectionDelta: null == stageDirectionDelta
          ? _value.stageDirectionDelta
          : stageDirectionDelta // ignore: cast_nullable_to_non_nullable
              as int,
      dialoguesDelta: null == dialoguesDelta
          ? _value.dialoguesDelta
          : dialoguesDelta // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MangaPageImplCopyWith<$Res>
    implements $MangaPageCopyWith<$Res> {
  factory _$$MangaPageImplCopyWith(
          _$MangaPageImpl value, $Res Function(_$MangaPageImpl) then) =
      __$$MangaPageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id, int memoDelta, int stageDirectionDelta, int dialoguesDelta});
}

/// @nodoc
class __$$MangaPageImplCopyWithImpl<$Res>
    extends _$MangaPageCopyWithImpl<$Res, _$MangaPageImpl>
    implements _$$MangaPageImplCopyWith<$Res> {
  __$$MangaPageImplCopyWithImpl(
      _$MangaPageImpl _value, $Res Function(_$MangaPageImpl) _then)
      : super(_value, _then);

  /// Create a copy of MangaPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? memoDelta = null,
    Object? stageDirectionDelta = null,
    Object? dialoguesDelta = null,
  }) {
    return _then(_$MangaPageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      memoDelta: null == memoDelta
          ? _value.memoDelta
          : memoDelta // ignore: cast_nullable_to_non_nullable
              as int,
      stageDirectionDelta: null == stageDirectionDelta
          ? _value.stageDirectionDelta
          : stageDirectionDelta // ignore: cast_nullable_to_non_nullable
              as int,
      dialoguesDelta: null == dialoguesDelta
          ? _value.dialoguesDelta
          : dialoguesDelta // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MangaPageImpl implements _MangaPage {
  const _$MangaPageImpl(
      {required this.id,
      required this.memoDelta,
      required this.stageDirectionDelta,
      required this.dialoguesDelta});

  factory _$MangaPageImpl.fromJson(Map<String, dynamic> json) =>
      _$$MangaPageImplFromJson(json);

  @override
  final int id;
  @override
  final int memoDelta;
  @override
  final int stageDirectionDelta;
  @override
  final int dialoguesDelta;

  @override
  String toString() {
    return 'MangaPage(id: $id, memoDelta: $memoDelta, stageDirectionDelta: $stageDirectionDelta, dialoguesDelta: $dialoguesDelta)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MangaPageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.memoDelta, memoDelta) ||
                other.memoDelta == memoDelta) &&
            (identical(other.stageDirectionDelta, stageDirectionDelta) ||
                other.stageDirectionDelta == stageDirectionDelta) &&
            (identical(other.dialoguesDelta, dialoguesDelta) ||
                other.dialoguesDelta == dialoguesDelta));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, memoDelta, stageDirectionDelta, dialoguesDelta);

  /// Create a copy of MangaPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MangaPageImplCopyWith<_$MangaPageImpl> get copyWith =>
      __$$MangaPageImplCopyWithImpl<_$MangaPageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MangaPageImplToJson(
      this,
    );
  }
}

abstract class _MangaPage implements MangaPage {
  const factory _MangaPage(
      {required final int id,
      required final int memoDelta,
      required final int stageDirectionDelta,
      required final int dialoguesDelta}) = _$MangaPageImpl;

  factory _MangaPage.fromJson(Map<String, dynamic> json) =
      _$MangaPageImpl.fromJson;

  @override
  int get id;
  @override
  int get memoDelta;
  @override
  int get stageDirectionDelta;
  @override
  int get dialoguesDelta;

  /// Create a copy of MangaPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MangaPageImplCopyWith<_$MangaPageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
