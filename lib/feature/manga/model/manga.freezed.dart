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
  DeltaId get ideaMemo;

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
            (identical(other.ideaMemo, ideaMemo) ||
                other.ideaMemo == ideaMemo));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, startPage, ideaMemo);

  @override
  String toString() {
    return 'Manga(id: $id, name: $name, startPage: $startPage, ideaMemo: $ideaMemo)';
  }
}

/// @nodoc
abstract mixin class $MangaCopyWith<$Res> {
  factory $MangaCopyWith(Manga value, $Res Function(Manga) _then) =
      _$MangaCopyWithImpl;
  @useResult
  $Res call(
      {MangaId id, String name, MangaStartPage startPage, DeltaId ideaMemo});
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
    Object? ideaMemo = null,
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
      ideaMemo: null == ideaMemo
          ? _self.ideaMemo
          : ideaMemo // ignore: cast_nullable_to_non_nullable
              as DeltaId,
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
            DeltaId ideaMemo)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Manga() when $default != null:
        return $default(_that.id, _that.name, _that.startPage, _that.ideaMemo);
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
    TResult Function(
            MangaId id, String name, MangaStartPage startPage, DeltaId ideaMemo)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Manga():
        return $default(_that.id, _that.name, _that.startPage, _that.ideaMemo);
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
            DeltaId ideaMemo)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Manga() when $default != null:
        return $default(_that.id, _that.name, _that.startPage, _that.ideaMemo);
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
      required this.ideaMemo});

  @override
  final MangaId id;
  @override
  final String name;
  @override
  final MangaStartPage startPage;
  @override
  final DeltaId ideaMemo;

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
            (identical(other.ideaMemo, ideaMemo) ||
                other.ideaMemo == ideaMemo));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, startPage, ideaMemo);

  @override
  String toString() {
    return 'Manga(id: $id, name: $name, startPage: $startPage, ideaMemo: $ideaMemo)';
  }
}

/// @nodoc
abstract mixin class _$MangaCopyWith<$Res> implements $MangaCopyWith<$Res> {
  factory _$MangaCopyWith(_Manga value, $Res Function(_Manga) _then) =
      __$MangaCopyWithImpl;
  @override
  @useResult
  $Res call(
      {MangaId id, String name, MangaStartPage startPage, DeltaId ideaMemo});
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
    Object? ideaMemo = null,
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
      ideaMemo: null == ideaMemo
          ? _self.ideaMemo
          : ideaMemo // ignore: cast_nullable_to_non_nullable
              as DeltaId,
    ));
  }
}

/// @nodoc
mixin _$MangaPage {
  MangaPageId get id;
  DeltaId get memoDelta;
  DeltaId get stageDirectionDelta;
  DeltaId get dialoguesDelta;

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
            (identical(other.memoDelta, memoDelta) ||
                other.memoDelta == memoDelta) &&
            (identical(other.stageDirectionDelta, stageDirectionDelta) ||
                other.stageDirectionDelta == stageDirectionDelta) &&
            (identical(other.dialoguesDelta, dialoguesDelta) ||
                other.dialoguesDelta == dialoguesDelta));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, memoDelta, stageDirectionDelta, dialoguesDelta);

  @override
  String toString() {
    return 'MangaPage(id: $id, memoDelta: $memoDelta, stageDirectionDelta: $stageDirectionDelta, dialoguesDelta: $dialoguesDelta)';
  }
}

/// @nodoc
abstract mixin class $MangaPageCopyWith<$Res> {
  factory $MangaPageCopyWith(MangaPage value, $Res Function(MangaPage) _then) =
      _$MangaPageCopyWithImpl;
  @useResult
  $Res call(
      {MangaPageId id,
      DeltaId memoDelta,
      DeltaId stageDirectionDelta,
      DeltaId dialoguesDelta});
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
    Object? memoDelta = null,
    Object? stageDirectionDelta = null,
    Object? dialoguesDelta = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as MangaPageId,
      memoDelta: null == memoDelta
          ? _self.memoDelta
          : memoDelta // ignore: cast_nullable_to_non_nullable
              as DeltaId,
      stageDirectionDelta: null == stageDirectionDelta
          ? _self.stageDirectionDelta
          : stageDirectionDelta // ignore: cast_nullable_to_non_nullable
              as DeltaId,
      dialoguesDelta: null == dialoguesDelta
          ? _self.dialoguesDelta
          : dialoguesDelta // ignore: cast_nullable_to_non_nullable
              as DeltaId,
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
    TResult Function(MangaPageId id, DeltaId memoDelta,
            DeltaId stageDirectionDelta, DeltaId dialoguesDelta)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MangaPage() when $default != null:
        return $default(_that.id, _that.memoDelta, _that.stageDirectionDelta,
            _that.dialoguesDelta);
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
    TResult Function(MangaPageId id, DeltaId memoDelta,
            DeltaId stageDirectionDelta, DeltaId dialoguesDelta)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MangaPage():
        return $default(_that.id, _that.memoDelta, _that.stageDirectionDelta,
            _that.dialoguesDelta);
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
    TResult? Function(MangaPageId id, DeltaId memoDelta,
            DeltaId stageDirectionDelta, DeltaId dialoguesDelta)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MangaPage() when $default != null:
        return $default(_that.id, _that.memoDelta, _that.stageDirectionDelta,
            _that.dialoguesDelta);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _MangaPage implements MangaPage {
  const _MangaPage(
      {required this.id,
      required this.memoDelta,
      required this.stageDirectionDelta,
      required this.dialoguesDelta});

  @override
  final MangaPageId id;
  @override
  final DeltaId memoDelta;
  @override
  final DeltaId stageDirectionDelta;
  @override
  final DeltaId dialoguesDelta;

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
            (identical(other.memoDelta, memoDelta) ||
                other.memoDelta == memoDelta) &&
            (identical(other.stageDirectionDelta, stageDirectionDelta) ||
                other.stageDirectionDelta == stageDirectionDelta) &&
            (identical(other.dialoguesDelta, dialoguesDelta) ||
                other.dialoguesDelta == dialoguesDelta));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, memoDelta, stageDirectionDelta, dialoguesDelta);

  @override
  String toString() {
    return 'MangaPage(id: $id, memoDelta: $memoDelta, stageDirectionDelta: $stageDirectionDelta, dialoguesDelta: $dialoguesDelta)';
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
      DeltaId memoDelta,
      DeltaId stageDirectionDelta,
      DeltaId dialoguesDelta});
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
    Object? memoDelta = null,
    Object? stageDirectionDelta = null,
    Object? dialoguesDelta = null,
  }) {
    return _then(_MangaPage(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as MangaPageId,
      memoDelta: null == memoDelta
          ? _self.memoDelta
          : memoDelta // ignore: cast_nullable_to_non_nullable
              as DeltaId,
      stageDirectionDelta: null == stageDirectionDelta
          ? _self.stageDirectionDelta
          : stageDirectionDelta // ignore: cast_nullable_to_non_nullable
              as DeltaId,
      dialoguesDelta: null == dialoguesDelta
          ? _self.dialoguesDelta
          : dialoguesDelta // ignore: cast_nullable_to_non_nullable
              as DeltaId,
    ));
  }
}

// dart format on
