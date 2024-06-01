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
  String get name => throw _privateConstructorUsedError;
  MangaStartPage get startPage => throw _privateConstructorUsedError;
  List<MangaPage> get pages => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MangaCopyWith<Manga> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MangaCopyWith<$Res> {
  factory $MangaCopyWith(Manga value, $Res Function(Manga) then) =
      _$MangaCopyWithImpl<$Res, Manga>;
  @useResult
  $Res call({String name, MangaStartPage startPage, List<MangaPage> pages});
}

/// @nodoc
class _$MangaCopyWithImpl<$Res, $Val extends Manga>
    implements $MangaCopyWith<$Res> {
  _$MangaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? startPage = null,
    Object? pages = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      startPage: null == startPage
          ? _value.startPage
          : startPage // ignore: cast_nullable_to_non_nullable
              as MangaStartPage,
      pages: null == pages
          ? _value.pages
          : pages // ignore: cast_nullable_to_non_nullable
              as List<MangaPage>,
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
  $Res call({String name, MangaStartPage startPage, List<MangaPage> pages});
}

/// @nodoc
class __$$MangaImplCopyWithImpl<$Res>
    extends _$MangaCopyWithImpl<$Res, _$MangaImpl>
    implements _$$MangaImplCopyWith<$Res> {
  __$$MangaImplCopyWithImpl(
      _$MangaImpl _value, $Res Function(_$MangaImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? startPage = null,
    Object? pages = null,
  }) {
    return _then(_$MangaImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      startPage: null == startPage
          ? _value.startPage
          : startPage // ignore: cast_nullable_to_non_nullable
              as MangaStartPage,
      pages: null == pages
          ? _value._pages
          : pages // ignore: cast_nullable_to_non_nullable
              as List<MangaPage>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MangaImpl implements _Manga {
  const _$MangaImpl(
      {required this.name,
      required this.startPage,
      required final List<MangaPage> pages})
      : _pages = pages;

  factory _$MangaImpl.fromJson(Map<String, dynamic> json) =>
      _$$MangaImplFromJson(json);

  @override
  final String name;
  @override
  final MangaStartPage startPage;
  final List<MangaPage> _pages;
  @override
  List<MangaPage> get pages {
    if (_pages is EqualUnmodifiableListView) return _pages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pages);
  }

  @override
  String toString() {
    return 'Manga(name: $name, startPage: $startPage, pages: $pages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MangaImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.startPage, startPage) ||
                other.startPage == startPage) &&
            const DeepCollectionEquality().equals(other._pages, _pages));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, name, startPage,
      const DeepCollectionEquality().hash(_pages));

  @JsonKey(ignore: true)
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
      {required final String name,
      required final MangaStartPage startPage,
      required final List<MangaPage> pages}) = _$MangaImpl;

  factory _Manga.fromJson(Map<String, dynamic> json) = _$MangaImpl.fromJson;

  @override
  String get name;
  @override
  MangaStartPage get startPage;
  @override
  List<MangaPage> get pages;
  @override
  @JsonKey(ignore: true)
  _$$MangaImplCopyWith<_$MangaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MangaPage _$MangaPageFromJson(Map<String, dynamic> json) {
  return _MangaPage.fromJson(json);
}

/// @nodoc
mixin _$MangaPage {
  int get id => throw _privateConstructorUsedError;
  String get memo => throw _privateConstructorUsedError;
  String get dialogues => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MangaPageCopyWith<MangaPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MangaPageCopyWith<$Res> {
  factory $MangaPageCopyWith(MangaPage value, $Res Function(MangaPage) then) =
      _$MangaPageCopyWithImpl<$Res, MangaPage>;
  @useResult
  $Res call({int id, String memo, String dialogues});
}

/// @nodoc
class _$MangaPageCopyWithImpl<$Res, $Val extends MangaPage>
    implements $MangaPageCopyWith<$Res> {
  _$MangaPageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? memo = null,
    Object? dialogues = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      memo: null == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String,
      dialogues: null == dialogues
          ? _value.dialogues
          : dialogues // ignore: cast_nullable_to_non_nullable
              as String,
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
  $Res call({int id, String memo, String dialogues});
}

/// @nodoc
class __$$MangaPageImplCopyWithImpl<$Res>
    extends _$MangaPageCopyWithImpl<$Res, _$MangaPageImpl>
    implements _$$MangaPageImplCopyWith<$Res> {
  __$$MangaPageImplCopyWithImpl(
      _$MangaPageImpl _value, $Res Function(_$MangaPageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? memo = null,
    Object? dialogues = null,
  }) {
    return _then(_$MangaPageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      memo: null == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String,
      dialogues: null == dialogues
          ? _value.dialogues
          : dialogues // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MangaPageImpl implements _MangaPage {
  const _$MangaPageImpl(
      {required this.id, required this.memo, required this.dialogues});

  factory _$MangaPageImpl.fromJson(Map<String, dynamic> json) =>
      _$$MangaPageImplFromJson(json);

  @override
  final int id;
  @override
  final String memo;
  @override
  final String dialogues;

  @override
  String toString() {
    return 'MangaPage(id: $id, memo: $memo, dialogues: $dialogues)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MangaPageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            (identical(other.dialogues, dialogues) ||
                other.dialogues == dialogues));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, memo, dialogues);

  @JsonKey(ignore: true)
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
      required final String memo,
      required final String dialogues}) = _$MangaPageImpl;

  factory _MangaPage.fromJson(Map<String, dynamic> json) =
      _$MangaPageImpl.fromJson;

  @override
  int get id;
  @override
  String get memo;
  @override
  String get dialogues;
  @override
  @JsonKey(ignore: true)
  _$$MangaPageImplCopyWith<_$MangaPageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
