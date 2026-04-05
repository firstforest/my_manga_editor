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
  MangaId get id;
  String get name;
  MangaStartPage get startPage;
  DeltaId get ideaMemoDeltaId;
  MangaStatus get status;

  /// Create a copy of Manga
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MangaCopyWith<Manga> get copyWith =>
      _$MangaCopyWithImpl<Manga>(this as Manga, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Manga &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.startPage, startPage) ||
                other.startPage == startPage) &&
            (identical(other.ideaMemoDeltaId, ideaMemoDeltaId) ||
                other.ideaMemoDeltaId == ideaMemoDeltaId) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, startPage, ideaMemoDeltaId, status);

  @override
  String toString() {
    return 'Manga(id: $id, name: $name, startPage: $startPage, ideaMemoDeltaId: $ideaMemoDeltaId, status: $status)';
  }
}

/// @nodoc
abstract mixin class $MangaCopyWith<$Res> {
  factory $MangaCopyWith(Manga value, $Res Function(Manga) _then) =
      _$MangaCopyWithImpl;
  @useResult
  $Res call(
      {MangaId id,
      String name,
      MangaStartPage startPage,
      DeltaId ideaMemoDeltaId,
      MangaStatus status});
}

/// @nodoc
class _$MangaCopyWithImpl<$Res> implements $MangaCopyWith<$Res> {
  _$MangaCopyWithImpl(this._self, this._then);

  final Manga _self;
  final $Res Function(Manga) _then;

  /// Create a copy of Manga
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? startPage = null,
    Object? ideaMemoDeltaId = null,
    Object? status = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as MangaId,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      startPage: null == startPage
          ? _self.startPage
          : startPage // ignore: cast_nullable_to_non_nullable
              as MangaStartPage,
      ideaMemoDeltaId: null == ideaMemoDeltaId
          ? _self.ideaMemoDeltaId
          : ideaMemoDeltaId // ignore: cast_nullable_to_non_nullable
              as DeltaId,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as MangaStatus,
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Manga value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Manga() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Manga value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Manga():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Manga value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Manga() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(MangaId id, String name, MangaStartPage startPage,
            DeltaId ideaMemoDeltaId, MangaStatus status)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Manga() when $default != null:
        return $default(_that.id, _that.name, _that.startPage,
            _that.ideaMemoDeltaId, _that.status);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(MangaId id, String name, MangaStartPage startPage,
            DeltaId ideaMemoDeltaId, MangaStatus status)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Manga():
        return $default(_that.id, _that.name, _that.startPage,
            _that.ideaMemoDeltaId, _that.status);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(MangaId id, String name, MangaStartPage startPage,
            DeltaId ideaMemoDeltaId, MangaStatus status)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Manga() when $default != null:
        return $default(_that.id, _that.name, _that.startPage,
            _that.ideaMemoDeltaId, _that.status);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Manga implements Manga {
  const _Manga(
      {required this.id,
      required this.name,
      required this.startPage,
      required this.ideaMemoDeltaId,
      required this.status});

  @override
  final MangaId id;
  @override
  final String name;
  @override
  final MangaStartPage startPage;
  @override
  final DeltaId ideaMemoDeltaId;
  @override
  final MangaStatus status;

  /// Create a copy of Manga
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MangaCopyWith<_Manga> get copyWith =>
      __$MangaCopyWithImpl<_Manga>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Manga &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.startPage, startPage) ||
                other.startPage == startPage) &&
            (identical(other.ideaMemoDeltaId, ideaMemoDeltaId) ||
                other.ideaMemoDeltaId == ideaMemoDeltaId) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, startPage, ideaMemoDeltaId, status);

  @override
  String toString() {
    return 'Manga(id: $id, name: $name, startPage: $startPage, ideaMemoDeltaId: $ideaMemoDeltaId, status: $status)';
  }
}

/// @nodoc
abstract mixin class _$MangaCopyWith<$Res> implements $MangaCopyWith<$Res> {
  factory _$MangaCopyWith(_Manga value, $Res Function(_Manga) _then) =
      __$MangaCopyWithImpl;
  @override
  @useResult
  $Res call(
      {MangaId id,
      String name,
      MangaStartPage startPage,
      DeltaId ideaMemoDeltaId,
      MangaStatus status});
}

/// @nodoc
class __$MangaCopyWithImpl<$Res> implements _$MangaCopyWith<$Res> {
  __$MangaCopyWithImpl(this._self, this._then);

  final _Manga _self;
  final $Res Function(_Manga) _then;

  /// Create a copy of Manga
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? startPage = null,
    Object? ideaMemoDeltaId = null,
    Object? status = null,
  }) {
    return _then(_Manga(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as MangaId,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      startPage: null == startPage
          ? _self.startPage
          : startPage // ignore: cast_nullable_to_non_nullable
              as MangaStartPage,
      ideaMemoDeltaId: null == ideaMemoDeltaId
          ? _self.ideaMemoDeltaId
          : ideaMemoDeltaId // ignore: cast_nullable_to_non_nullable
              as DeltaId,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as MangaStatus,
    ));
  }
}

/// @nodoc
mixin _$SceneUnit {
  DeltaId get dialoguesDeltaId;
  DeltaId get stageDirectionDeltaId;

  /// Create a copy of SceneUnit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SceneUnitCopyWith<SceneUnit> get copyWith =>
      _$SceneUnitCopyWithImpl<SceneUnit>(this as SceneUnit, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SceneUnit &&
            (identical(other.dialoguesDeltaId, dialoguesDeltaId) ||
                other.dialoguesDeltaId == dialoguesDeltaId) &&
            (identical(other.stageDirectionDeltaId, stageDirectionDeltaId) ||
                other.stageDirectionDeltaId == stageDirectionDeltaId));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, dialoguesDeltaId, stageDirectionDeltaId);

  @override
  String toString() {
    return 'SceneUnit(dialoguesDeltaId: $dialoguesDeltaId, stageDirectionDeltaId: $stageDirectionDeltaId)';
  }
}

/// @nodoc
abstract mixin class $SceneUnitCopyWith<$Res> {
  factory $SceneUnitCopyWith(SceneUnit value, $Res Function(SceneUnit) _then) =
      _$SceneUnitCopyWithImpl;
  @useResult
  $Res call({DeltaId dialoguesDeltaId, DeltaId stageDirectionDeltaId});
}

/// @nodoc
class _$SceneUnitCopyWithImpl<$Res> implements $SceneUnitCopyWith<$Res> {
  _$SceneUnitCopyWithImpl(this._self, this._then);

  final SceneUnit _self;
  final $Res Function(SceneUnit) _then;

  /// Create a copy of SceneUnit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dialoguesDeltaId = null,
    Object? stageDirectionDeltaId = null,
  }) {
    return _then(_self.copyWith(
      dialoguesDeltaId: null == dialoguesDeltaId
          ? _self.dialoguesDeltaId
          : dialoguesDeltaId // ignore: cast_nullable_to_non_nullable
              as DeltaId,
      stageDirectionDeltaId: null == stageDirectionDeltaId
          ? _self.stageDirectionDeltaId
          : stageDirectionDeltaId // ignore: cast_nullable_to_non_nullable
              as DeltaId,
    ));
  }
}

/// Adds pattern-matching-related methods to [SceneUnit].
extension SceneUnitPatterns on SceneUnit {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SceneUnit value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SceneUnit() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SceneUnit value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SceneUnit():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SceneUnit value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SceneUnit() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(DeltaId dialoguesDeltaId, DeltaId stageDirectionDeltaId)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SceneUnit() when $default != null:
        return $default(_that.dialoguesDeltaId, _that.stageDirectionDeltaId);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(DeltaId dialoguesDeltaId, DeltaId stageDirectionDeltaId)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SceneUnit():
        return $default(_that.dialoguesDeltaId, _that.stageDirectionDeltaId);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(DeltaId dialoguesDeltaId, DeltaId stageDirectionDeltaId)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SceneUnit() when $default != null:
        return $default(_that.dialoguesDeltaId, _that.stageDirectionDeltaId);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _SceneUnit implements SceneUnit {
  const _SceneUnit(
      {required this.dialoguesDeltaId, required this.stageDirectionDeltaId});

  @override
  final DeltaId dialoguesDeltaId;
  @override
  final DeltaId stageDirectionDeltaId;

  /// Create a copy of SceneUnit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SceneUnitCopyWith<_SceneUnit> get copyWith =>
      __$SceneUnitCopyWithImpl<_SceneUnit>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SceneUnit &&
            (identical(other.dialoguesDeltaId, dialoguesDeltaId) ||
                other.dialoguesDeltaId == dialoguesDeltaId) &&
            (identical(other.stageDirectionDeltaId, stageDirectionDeltaId) ||
                other.stageDirectionDeltaId == stageDirectionDeltaId));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, dialoguesDeltaId, stageDirectionDeltaId);

  @override
  String toString() {
    return 'SceneUnit(dialoguesDeltaId: $dialoguesDeltaId, stageDirectionDeltaId: $stageDirectionDeltaId)';
  }
}

/// @nodoc
abstract mixin class _$SceneUnitCopyWith<$Res>
    implements $SceneUnitCopyWith<$Res> {
  factory _$SceneUnitCopyWith(
          _SceneUnit value, $Res Function(_SceneUnit) _then) =
      __$SceneUnitCopyWithImpl;
  @override
  @useResult
  $Res call({DeltaId dialoguesDeltaId, DeltaId stageDirectionDeltaId});
}

/// @nodoc
class __$SceneUnitCopyWithImpl<$Res> implements _$SceneUnitCopyWith<$Res> {
  __$SceneUnitCopyWithImpl(this._self, this._then);

  final _SceneUnit _self;
  final $Res Function(_SceneUnit) _then;

  /// Create a copy of SceneUnit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? dialoguesDeltaId = null,
    Object? stageDirectionDeltaId = null,
  }) {
    return _then(_SceneUnit(
      dialoguesDeltaId: null == dialoguesDeltaId
          ? _self.dialoguesDeltaId
          : dialoguesDeltaId // ignore: cast_nullable_to_non_nullable
              as DeltaId,
      stageDirectionDeltaId: null == stageDirectionDeltaId
          ? _self.stageDirectionDeltaId
          : stageDirectionDeltaId // ignore: cast_nullable_to_non_nullable
              as DeltaId,
    ));
  }
}

/// @nodoc
mixin _$MangaPage {
  MangaPageId get id;
  MangaId get mangaId;
  DeltaId get memoDeltaId;
  List<SceneUnit> get sceneUnits;

  /// Create a copy of MangaPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MangaPageCopyWith<MangaPage> get copyWith =>
      _$MangaPageCopyWithImpl<MangaPage>(this as MangaPage, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MangaPage &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.mangaId, mangaId) || other.mangaId == mangaId) &&
            (identical(other.memoDeltaId, memoDeltaId) ||
                other.memoDeltaId == memoDeltaId) &&
            const DeepCollectionEquality()
                .equals(other.sceneUnits, sceneUnits));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, mangaId, memoDeltaId,
      const DeepCollectionEquality().hash(sceneUnits));

  @override
  String toString() {
    return 'MangaPage(id: $id, mangaId: $mangaId, memoDeltaId: $memoDeltaId, sceneUnits: $sceneUnits)';
  }
}

/// @nodoc
abstract mixin class $MangaPageCopyWith<$Res> {
  factory $MangaPageCopyWith(MangaPage value, $Res Function(MangaPage) _then) =
      _$MangaPageCopyWithImpl;
  @useResult
  $Res call(
      {MangaPageId id,
      MangaId mangaId,
      DeltaId memoDeltaId,
      List<SceneUnit> sceneUnits});
}

/// @nodoc
class _$MangaPageCopyWithImpl<$Res> implements $MangaPageCopyWith<$Res> {
  _$MangaPageCopyWithImpl(this._self, this._then);

  final MangaPage _self;
  final $Res Function(MangaPage) _then;

  /// Create a copy of MangaPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? mangaId = null,
    Object? memoDeltaId = null,
    Object? sceneUnits = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as MangaPageId,
      mangaId: null == mangaId
          ? _self.mangaId
          : mangaId // ignore: cast_nullable_to_non_nullable
              as MangaId,
      memoDeltaId: null == memoDeltaId
          ? _self.memoDeltaId
          : memoDeltaId // ignore: cast_nullable_to_non_nullable
              as DeltaId,
      sceneUnits: null == sceneUnits
          ? _self.sceneUnits
          : sceneUnits // ignore: cast_nullable_to_non_nullable
              as List<SceneUnit>,
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MangaPage value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MangaPage() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MangaPage value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MangaPage():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MangaPage value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MangaPage() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(MangaPageId id, MangaId mangaId, DeltaId memoDeltaId,
            List<SceneUnit> sceneUnits)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MangaPage() when $default != null:
        return $default(
            _that.id, _that.mangaId, _that.memoDeltaId, _that.sceneUnits);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(MangaPageId id, MangaId mangaId, DeltaId memoDeltaId,
            List<SceneUnit> sceneUnits)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MangaPage():
        return $default(
            _that.id, _that.mangaId, _that.memoDeltaId, _that.sceneUnits);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(MangaPageId id, MangaId mangaId, DeltaId memoDeltaId,
            List<SceneUnit> sceneUnits)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MangaPage() when $default != null:
        return $default(
            _that.id, _that.mangaId, _that.memoDeltaId, _that.sceneUnits);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _MangaPage implements MangaPage {
  const _MangaPage(
      {required this.id,
      required this.mangaId,
      required this.memoDeltaId,
      required final List<SceneUnit> sceneUnits})
      : _sceneUnits = sceneUnits;

  @override
  final MangaPageId id;
  @override
  final MangaId mangaId;
  @override
  final DeltaId memoDeltaId;
  final List<SceneUnit> _sceneUnits;
  @override
  List<SceneUnit> get sceneUnits {
    if (_sceneUnits is EqualUnmodifiableListView) return _sceneUnits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sceneUnits);
  }

  /// Create a copy of MangaPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MangaPageCopyWith<_MangaPage> get copyWith =>
      __$MangaPageCopyWithImpl<_MangaPage>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MangaPage &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.mangaId, mangaId) || other.mangaId == mangaId) &&
            (identical(other.memoDeltaId, memoDeltaId) ||
                other.memoDeltaId == memoDeltaId) &&
            const DeepCollectionEquality()
                .equals(other._sceneUnits, _sceneUnits));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, mangaId, memoDeltaId,
      const DeepCollectionEquality().hash(_sceneUnits));

  @override
  String toString() {
    return 'MangaPage(id: $id, mangaId: $mangaId, memoDeltaId: $memoDeltaId, sceneUnits: $sceneUnits)';
  }
}

/// @nodoc
abstract mixin class _$MangaPageCopyWith<$Res>
    implements $MangaPageCopyWith<$Res> {
  factory _$MangaPageCopyWith(
          _MangaPage value, $Res Function(_MangaPage) _then) =
      __$MangaPageCopyWithImpl;
  @override
  @useResult
  $Res call(
      {MangaPageId id,
      MangaId mangaId,
      DeltaId memoDeltaId,
      List<SceneUnit> sceneUnits});
}

/// @nodoc
class __$MangaPageCopyWithImpl<$Res> implements _$MangaPageCopyWith<$Res> {
  __$MangaPageCopyWithImpl(this._self, this._then);

  final _MangaPage _self;
  final $Res Function(_MangaPage) _then;

  /// Create a copy of MangaPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? mangaId = null,
    Object? memoDeltaId = null,
    Object? sceneUnits = null,
  }) {
    return _then(_MangaPage(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as MangaPageId,
      mangaId: null == mangaId
          ? _self.mangaId
          : mangaId // ignore: cast_nullable_to_non_nullable
              as MangaId,
      memoDeltaId: null == memoDeltaId
          ? _self.memoDeltaId
          : memoDeltaId // ignore: cast_nullable_to_non_nullable
              as DeltaId,
      sceneUnits: null == sceneUnits
          ? _self._sceneUnits
          : sceneUnits // ignore: cast_nullable_to_non_nullable
              as List<SceneUnit>,
    ));
  }
}

// dart format on
