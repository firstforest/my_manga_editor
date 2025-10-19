// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'manga.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Manga {

 MangaId get id; String get name; MangaStartPage get startPage;@TimestampConverter() DateTime get createdAt;@TimestampConverter() DateTime get updatedAt;
/// Create a copy of Manga
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MangaCopyWith<Manga> get copyWith => _$MangaCopyWithImpl<Manga>(this as Manga, _$identity);

  /// Serializes this Manga to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Manga&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.startPage, startPage) || other.startPage == startPage)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,startPage,createdAt,updatedAt);

@override
String toString() {
  return 'Manga(id: $id, name: $name, startPage: $startPage, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $MangaCopyWith<$Res>  {
  factory $MangaCopyWith(Manga value, $Res Function(Manga) _then) = _$MangaCopyWithImpl;
@useResult
$Res call({
 MangaId id, String name, MangaStartPage startPage,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class _$MangaCopyWithImpl<$Res>
    implements $MangaCopyWith<$Res> {
  _$MangaCopyWithImpl(this._self, this._then);

  final Manga _self;
  final $Res Function(Manga) _then;

/// Create a copy of Manga
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? startPage = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as MangaId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,startPage: null == startPage ? _self.startPage : startPage // ignore: cast_nullable_to_non_nullable
as MangaStartPage,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Manga].
extension MangaPatterns on Manga {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Manga value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Manga() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Manga value)  $default,){
final _that = this;
switch (_that) {
case _Manga():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Manga value)?  $default,){
final _that = this;
switch (_that) {
case _Manga() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MangaId id,  String name,  MangaStartPage startPage, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Manga() when $default != null:
return $default(_that.id,_that.name,_that.startPage,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MangaId id,  String name,  MangaStartPage startPage, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Manga():
return $default(_that.id,_that.name,_that.startPage,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MangaId id,  String name,  MangaStartPage startPage, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Manga() when $default != null:
return $default(_that.id,_that.name,_that.startPage,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Manga implements Manga {
  const _Manga({required this.id, required this.name, required this.startPage, @TimestampConverter() required this.createdAt, @TimestampConverter() required this.updatedAt});
  factory _Manga.fromJson(Map<String, dynamic> json) => _$MangaFromJson(json);

@override final  MangaId id;
@override final  String name;
@override final  MangaStartPage startPage;
@override@TimestampConverter() final  DateTime createdAt;
@override@TimestampConverter() final  DateTime updatedAt;

/// Create a copy of Manga
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MangaCopyWith<_Manga> get copyWith => __$MangaCopyWithImpl<_Manga>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MangaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Manga&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.startPage, startPage) || other.startPage == startPage)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,startPage,createdAt,updatedAt);

@override
String toString() {
  return 'Manga(id: $id, name: $name, startPage: $startPage, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MangaCopyWith<$Res> implements $MangaCopyWith<$Res> {
  factory _$MangaCopyWith(_Manga value, $Res Function(_Manga) _then) = __$MangaCopyWithImpl;
@override @useResult
$Res call({
 MangaId id, String name, MangaStartPage startPage,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class __$MangaCopyWithImpl<$Res>
    implements _$MangaCopyWith<$Res> {
  __$MangaCopyWithImpl(this._self, this._then);

  final _Manga _self;
  final $Res Function(_Manga) _then;

/// Create a copy of Manga
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? startPage = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Manga(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as MangaId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,startPage: null == startPage ? _self.startPage : startPage // ignore: cast_nullable_to_non_nullable
as MangaStartPage,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$MangaPage {

 MangaPageId get id; int get pageIndex;@DeltaConverter() Delta get memoDelta;@DeltaConverter() Delta get stageDirectionDelta;@DeltaConverter() Delta get dialoguesDelta;@TimestampConverter() DateTime get createdAt;@TimestampConverter() DateTime get updatedAt;
/// Create a copy of MangaPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MangaPageCopyWith<MangaPage> get copyWith => _$MangaPageCopyWithImpl<MangaPage>(this as MangaPage, _$identity);

  /// Serializes this MangaPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MangaPage&&(identical(other.id, id) || other.id == id)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex)&&(identical(other.memoDelta, memoDelta) || other.memoDelta == memoDelta)&&(identical(other.stageDirectionDelta, stageDirectionDelta) || other.stageDirectionDelta == stageDirectionDelta)&&(identical(other.dialoguesDelta, dialoguesDelta) || other.dialoguesDelta == dialoguesDelta)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,pageIndex,memoDelta,stageDirectionDelta,dialoguesDelta,createdAt,updatedAt);

@override
String toString() {
  return 'MangaPage(id: $id, pageIndex: $pageIndex, memoDelta: $memoDelta, stageDirectionDelta: $stageDirectionDelta, dialoguesDelta: $dialoguesDelta, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $MangaPageCopyWith<$Res>  {
  factory $MangaPageCopyWith(MangaPage value, $Res Function(MangaPage) _then) = _$MangaPageCopyWithImpl;
@useResult
$Res call({
 MangaPageId id, int pageIndex,@DeltaConverter() Delta memoDelta,@DeltaConverter() Delta stageDirectionDelta,@DeltaConverter() Delta dialoguesDelta,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class _$MangaPageCopyWithImpl<$Res>
    implements $MangaPageCopyWith<$Res> {
  _$MangaPageCopyWithImpl(this._self, this._then);

  final MangaPage _self;
  final $Res Function(MangaPage) _then;

/// Create a copy of MangaPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? pageIndex = null,Object? memoDelta = null,Object? stageDirectionDelta = null,Object? dialoguesDelta = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as MangaPageId,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,memoDelta: null == memoDelta ? _self.memoDelta : memoDelta // ignore: cast_nullable_to_non_nullable
as Delta,stageDirectionDelta: null == stageDirectionDelta ? _self.stageDirectionDelta : stageDirectionDelta // ignore: cast_nullable_to_non_nullable
as Delta,dialoguesDelta: null == dialoguesDelta ? _self.dialoguesDelta : dialoguesDelta // ignore: cast_nullable_to_non_nullable
as Delta,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MangaPage].
extension MangaPagePatterns on MangaPage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MangaPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MangaPage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MangaPage value)  $default,){
final _that = this;
switch (_that) {
case _MangaPage():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MangaPage value)?  $default,){
final _that = this;
switch (_that) {
case _MangaPage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MangaPageId id,  int pageIndex, @DeltaConverter()  Delta memoDelta, @DeltaConverter()  Delta stageDirectionDelta, @DeltaConverter()  Delta dialoguesDelta, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MangaPage() when $default != null:
return $default(_that.id,_that.pageIndex,_that.memoDelta,_that.stageDirectionDelta,_that.dialoguesDelta,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MangaPageId id,  int pageIndex, @DeltaConverter()  Delta memoDelta, @DeltaConverter()  Delta stageDirectionDelta, @DeltaConverter()  Delta dialoguesDelta, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MangaPage():
return $default(_that.id,_that.pageIndex,_that.memoDelta,_that.stageDirectionDelta,_that.dialoguesDelta,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MangaPageId id,  int pageIndex, @DeltaConverter()  Delta memoDelta, @DeltaConverter()  Delta stageDirectionDelta, @DeltaConverter()  Delta dialoguesDelta, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MangaPage() when $default != null:
return $default(_that.id,_that.pageIndex,_that.memoDelta,_that.stageDirectionDelta,_that.dialoguesDelta,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MangaPage implements MangaPage {
  const _MangaPage({required this.id, required this.pageIndex, @DeltaConverter() required this.memoDelta, @DeltaConverter() required this.stageDirectionDelta, @DeltaConverter() required this.dialoguesDelta, @TimestampConverter() required this.createdAt, @TimestampConverter() required this.updatedAt});
  factory _MangaPage.fromJson(Map<String, dynamic> json) => _$MangaPageFromJson(json);

@override final  MangaPageId id;
@override final  int pageIndex;
@override@DeltaConverter() final  Delta memoDelta;
@override@DeltaConverter() final  Delta stageDirectionDelta;
@override@DeltaConverter() final  Delta dialoguesDelta;
@override@TimestampConverter() final  DateTime createdAt;
@override@TimestampConverter() final  DateTime updatedAt;

/// Create a copy of MangaPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MangaPageCopyWith<_MangaPage> get copyWith => __$MangaPageCopyWithImpl<_MangaPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MangaPageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MangaPage&&(identical(other.id, id) || other.id == id)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex)&&(identical(other.memoDelta, memoDelta) || other.memoDelta == memoDelta)&&(identical(other.stageDirectionDelta, stageDirectionDelta) || other.stageDirectionDelta == stageDirectionDelta)&&(identical(other.dialoguesDelta, dialoguesDelta) || other.dialoguesDelta == dialoguesDelta)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,pageIndex,memoDelta,stageDirectionDelta,dialoguesDelta,createdAt,updatedAt);

@override
String toString() {
  return 'MangaPage(id: $id, pageIndex: $pageIndex, memoDelta: $memoDelta, stageDirectionDelta: $stageDirectionDelta, dialoguesDelta: $dialoguesDelta, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MangaPageCopyWith<$Res> implements $MangaPageCopyWith<$Res> {
  factory _$MangaPageCopyWith(_MangaPage value, $Res Function(_MangaPage) _then) = __$MangaPageCopyWithImpl;
@override @useResult
$Res call({
 MangaPageId id, int pageIndex,@DeltaConverter() Delta memoDelta,@DeltaConverter() Delta stageDirectionDelta,@DeltaConverter() Delta dialoguesDelta,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class __$MangaPageCopyWithImpl<$Res>
    implements _$MangaPageCopyWith<$Res> {
  __$MangaPageCopyWithImpl(this._self, this._then);

  final _MangaPage _self;
  final $Res Function(_MangaPage) _then;

/// Create a copy of MangaPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? pageIndex = null,Object? memoDelta = null,Object? stageDirectionDelta = null,Object? dialoguesDelta = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_MangaPage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as MangaPageId,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,memoDelta: null == memoDelta ? _self.memoDelta : memoDelta // ignore: cast_nullable_to_non_nullable
as Delta,stageDirectionDelta: null == stageDirectionDelta ? _self.stageDirectionDelta : stageDirectionDelta // ignore: cast_nullable_to_non_nullable
as Delta,dialoguesDelta: null == dialoguesDelta ? _self.dialoguesDelta : dialoguesDelta // ignore: cast_nullable_to_non_nullable
as Delta,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
