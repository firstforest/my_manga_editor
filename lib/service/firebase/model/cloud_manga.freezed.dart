// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cloud_manga.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CloudManga {
  String get id; // Firestore document ID
  String get userId; // Owner UID
  String get name; // Manga title
  String get startPageDirection; // 'left' or 'right'
  Map<String, dynamic> get ideaMemo; // Quill Delta as Map
  DateTime get createdAt; // Creation timestamp
  DateTime get updatedAt; // Last modification timestamp
  @JsonKey(name: 'editLock')
  EditLock? get editLock;

  /// Create a copy of CloudManga
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CloudMangaCopyWith<CloudManga> get copyWith =>
      _$CloudMangaCopyWithImpl<CloudManga>(this as CloudManga, _$identity);

  /// Serializes this CloudManga to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CloudManga &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.startPageDirection, startPageDirection) ||
                other.startPageDirection == startPageDirection) &&
            const DeepCollectionEquality().equals(other.ideaMemo, ideaMemo) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.editLock, editLock) ||
                other.editLock == editLock));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      name,
      startPageDirection,
      const DeepCollectionEquality().hash(ideaMemo),
      createdAt,
      updatedAt,
      editLock);

  @override
  String toString() {
    return 'CloudManga(id: $id, userId: $userId, name: $name, startPageDirection: $startPageDirection, ideaMemo: $ideaMemo, createdAt: $createdAt, updatedAt: $updatedAt, editLock: $editLock)';
  }
}

/// @nodoc
abstract mixin class $CloudMangaCopyWith<$Res> {
  factory $CloudMangaCopyWith(
          CloudManga value, $Res Function(CloudManga) _then) =
      _$CloudMangaCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String startPageDirection,
      Map<String, dynamic> ideaMemo,
      DateTime createdAt,
      DateTime updatedAt,
      @JsonKey(name: 'editLock') EditLock? editLock});

  $EditLockCopyWith<$Res>? get editLock;
}

/// @nodoc
class _$CloudMangaCopyWithImpl<$Res> implements $CloudMangaCopyWith<$Res> {
  _$CloudMangaCopyWithImpl(this._self, this._then);

  final CloudManga _self;
  final $Res Function(CloudManga) _then;

  /// Create a copy of CloudManga
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? startPageDirection = null,
    Object? ideaMemo = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? editLock = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      startPageDirection: null == startPageDirection
          ? _self.startPageDirection
          : startPageDirection // ignore: cast_nullable_to_non_nullable
              as String,
      ideaMemo: null == ideaMemo
          ? _self.ideaMemo
          : ideaMemo // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      editLock: freezed == editLock
          ? _self.editLock
          : editLock // ignore: cast_nullable_to_non_nullable
              as EditLock?,
    ));
  }

  /// Create a copy of CloudManga
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EditLockCopyWith<$Res>? get editLock {
    if (_self.editLock == null) {
      return null;
    }

    return $EditLockCopyWith<$Res>(_self.editLock!, (value) {
      return _then(_self.copyWith(editLock: value));
    });
  }
}

/// Adds pattern-matching-related methods to [CloudManga].
extension CloudMangaPatterns on CloudManga {
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
    TResult Function(_CloudManga value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CloudManga() when $default != null:
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
    TResult Function(_CloudManga value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CloudManga():
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
    TResult? Function(_CloudManga value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CloudManga() when $default != null:
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
    TResult Function(
            String id,
            String userId,
            String name,
            String startPageDirection,
            Map<String, dynamic> ideaMemo,
            DateTime createdAt,
            DateTime updatedAt,
            @JsonKey(name: 'editLock') EditLock? editLock)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CloudManga() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.name,
            _that.startPageDirection,
            _that.ideaMemo,
            _that.createdAt,
            _that.updatedAt,
            _that.editLock);
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
            String id,
            String userId,
            String name,
            String startPageDirection,
            Map<String, dynamic> ideaMemo,
            DateTime createdAt,
            DateTime updatedAt,
            @JsonKey(name: 'editLock') EditLock? editLock)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CloudManga():
        return $default(
            _that.id,
            _that.userId,
            _that.name,
            _that.startPageDirection,
            _that.ideaMemo,
            _that.createdAt,
            _that.updatedAt,
            _that.editLock);
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
    TResult? Function(
            String id,
            String userId,
            String name,
            String startPageDirection,
            Map<String, dynamic> ideaMemo,
            DateTime createdAt,
            DateTime updatedAt,
            @JsonKey(name: 'editLock') EditLock? editLock)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CloudManga() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.name,
            _that.startPageDirection,
            _that.ideaMemo,
            _that.createdAt,
            _that.updatedAt,
            _that.editLock);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CloudManga implements CloudManga {
  const _CloudManga(
      {required this.id,
      required this.userId,
      required this.name,
      required this.startPageDirection,
      required final Map<String, dynamic> ideaMemo,
      required this.createdAt,
      required this.updatedAt,
      @JsonKey(name: 'editLock') this.editLock})
      : _ideaMemo = ideaMemo;
  factory _CloudManga.fromJson(Map<String, dynamic> json) =>
      _$CloudMangaFromJson(json);

  @override
  final String id;
// Firestore document ID
  @override
  final String userId;
// Owner UID
  @override
  final String name;
// Manga title
  @override
  final String startPageDirection;
// 'left' or 'right'
  final Map<String, dynamic> _ideaMemo;
// 'left' or 'right'
  @override
  Map<String, dynamic> get ideaMemo {
    if (_ideaMemo is EqualUnmodifiableMapView) return _ideaMemo;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_ideaMemo);
  }

// Quill Delta as Map
  @override
  final DateTime createdAt;
// Creation timestamp
  @override
  final DateTime updatedAt;
// Last modification timestamp
  @override
  @JsonKey(name: 'editLock')
  final EditLock? editLock;

  /// Create a copy of CloudManga
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CloudMangaCopyWith<_CloudManga> get copyWith =>
      __$CloudMangaCopyWithImpl<_CloudManga>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CloudMangaToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CloudManga &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.startPageDirection, startPageDirection) ||
                other.startPageDirection == startPageDirection) &&
            const DeepCollectionEquality().equals(other._ideaMemo, _ideaMemo) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.editLock, editLock) ||
                other.editLock == editLock));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      name,
      startPageDirection,
      const DeepCollectionEquality().hash(_ideaMemo),
      createdAt,
      updatedAt,
      editLock);

  @override
  String toString() {
    return 'CloudManga(id: $id, userId: $userId, name: $name, startPageDirection: $startPageDirection, ideaMemo: $ideaMemo, createdAt: $createdAt, updatedAt: $updatedAt, editLock: $editLock)';
  }
}

/// @nodoc
abstract mixin class _$CloudMangaCopyWith<$Res>
    implements $CloudMangaCopyWith<$Res> {
  factory _$CloudMangaCopyWith(
          _CloudManga value, $Res Function(_CloudManga) _then) =
      __$CloudMangaCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String startPageDirection,
      Map<String, dynamic> ideaMemo,
      DateTime createdAt,
      DateTime updatedAt,
      @JsonKey(name: 'editLock') EditLock? editLock});

  @override
  $EditLockCopyWith<$Res>? get editLock;
}

/// @nodoc
class __$CloudMangaCopyWithImpl<$Res> implements _$CloudMangaCopyWith<$Res> {
  __$CloudMangaCopyWithImpl(this._self, this._then);

  final _CloudManga _self;
  final $Res Function(_CloudManga) _then;

  /// Create a copy of CloudManga
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? startPageDirection = null,
    Object? ideaMemo = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? editLock = freezed,
  }) {
    return _then(_CloudManga(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      startPageDirection: null == startPageDirection
          ? _self.startPageDirection
          : startPageDirection // ignore: cast_nullable_to_non_nullable
              as String,
      ideaMemo: null == ideaMemo
          ? _self._ideaMemo
          : ideaMemo // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      editLock: freezed == editLock
          ? _self.editLock
          : editLock // ignore: cast_nullable_to_non_nullable
              as EditLock?,
    ));
  }

  /// Create a copy of CloudManga
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EditLockCopyWith<$Res>? get editLock {
    if (_self.editLock == null) {
      return null;
    }

    return $EditLockCopyWith<$Res>(_self.editLock!, (value) {
      return _then(_self.copyWith(editLock: value));
    });
  }
}

// dart format on
