// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'edit_lock.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EditLock {
  String get lockedBy; // User UID who holds the lock
  DateTime get lockedAt; // Lock acquisition time
  DateTime get expiresAt; // Lock expiration time (TTL)
  String get deviceId;

  /// Create a copy of EditLock
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EditLockCopyWith<EditLock> get copyWith =>
      _$EditLockCopyWithImpl<EditLock>(this as EditLock, _$identity);

  /// Serializes this EditLock to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is EditLock &&
            (identical(other.lockedBy, lockedBy) ||
                other.lockedBy == lockedBy) &&
            (identical(other.lockedAt, lockedAt) ||
                other.lockedAt == lockedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, lockedBy, lockedAt, expiresAt, deviceId);

  @override
  String toString() {
    return 'EditLock(lockedBy: $lockedBy, lockedAt: $lockedAt, expiresAt: $expiresAt, deviceId: $deviceId)';
  }
}

/// @nodoc
abstract mixin class $EditLockCopyWith<$Res> {
  factory $EditLockCopyWith(EditLock value, $Res Function(EditLock) _then) =
      _$EditLockCopyWithImpl;
  @useResult
  $Res call(
      {String lockedBy,
      DateTime lockedAt,
      DateTime expiresAt,
      String deviceId});
}

/// @nodoc
class _$EditLockCopyWithImpl<$Res> implements $EditLockCopyWith<$Res> {
  _$EditLockCopyWithImpl(this._self, this._then);

  final EditLock _self;
  final $Res Function(EditLock) _then;

  /// Create a copy of EditLock
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lockedBy = null,
    Object? lockedAt = null,
    Object? expiresAt = null,
    Object? deviceId = null,
  }) {
    return _then(_self.copyWith(
      lockedBy: null == lockedBy
          ? _self.lockedBy
          : lockedBy // ignore: cast_nullable_to_non_nullable
              as String,
      lockedAt: null == lockedAt
          ? _self.lockedAt
          : lockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: null == expiresAt
          ? _self.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deviceId: null == deviceId
          ? _self.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [EditLock].
extension EditLockPatterns on EditLock {
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
    TResult Function(_EditLock value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EditLock() when $default != null:
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
    TResult Function(_EditLock value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EditLock():
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
    TResult? Function(_EditLock value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EditLock() when $default != null:
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
    TResult Function(String lockedBy, DateTime lockedAt, DateTime expiresAt,
            String deviceId)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EditLock() when $default != null:
        return $default(
            _that.lockedBy, _that.lockedAt, _that.expiresAt, _that.deviceId);
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
    TResult Function(String lockedBy, DateTime lockedAt, DateTime expiresAt,
            String deviceId)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EditLock():
        return $default(
            _that.lockedBy, _that.lockedAt, _that.expiresAt, _that.deviceId);
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
    TResult? Function(String lockedBy, DateTime lockedAt, DateTime expiresAt,
            String deviceId)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EditLock() when $default != null:
        return $default(
            _that.lockedBy, _that.lockedAt, _that.expiresAt, _that.deviceId);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _EditLock implements EditLock {
  const _EditLock(
      {required this.lockedBy,
      required this.lockedAt,
      required this.expiresAt,
      required this.deviceId});
  factory _EditLock.fromJson(Map<String, dynamic> json) =>
      _$EditLockFromJson(json);

  @override
  final String lockedBy;
// User UID who holds the lock
  @override
  final DateTime lockedAt;
// Lock acquisition time
  @override
  final DateTime expiresAt;
// Lock expiration time (TTL)
  @override
  final String deviceId;

  /// Create a copy of EditLock
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EditLockCopyWith<_EditLock> get copyWith =>
      __$EditLockCopyWithImpl<_EditLock>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$EditLockToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _EditLock &&
            (identical(other.lockedBy, lockedBy) ||
                other.lockedBy == lockedBy) &&
            (identical(other.lockedAt, lockedAt) ||
                other.lockedAt == lockedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, lockedBy, lockedAt, expiresAt, deviceId);

  @override
  String toString() {
    return 'EditLock(lockedBy: $lockedBy, lockedAt: $lockedAt, expiresAt: $expiresAt, deviceId: $deviceId)';
  }
}

/// @nodoc
abstract mixin class _$EditLockCopyWith<$Res>
    implements $EditLockCopyWith<$Res> {
  factory _$EditLockCopyWith(_EditLock value, $Res Function(_EditLock) _then) =
      __$EditLockCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String lockedBy,
      DateTime lockedAt,
      DateTime expiresAt,
      String deviceId});
}

/// @nodoc
class __$EditLockCopyWithImpl<$Res> implements _$EditLockCopyWith<$Res> {
  __$EditLockCopyWithImpl(this._self, this._then);

  final _EditLock _self;
  final $Res Function(_EditLock) _then;

  /// Create a copy of EditLock
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? lockedBy = null,
    Object? lockedAt = null,
    Object? expiresAt = null,
    Object? deviceId = null,
  }) {
    return _then(_EditLock(
      lockedBy: null == lockedBy
          ? _self.lockedBy
          : lockedBy // ignore: cast_nullable_to_non_nullable
              as String,
      lockedAt: null == lockedAt
          ? _self.lockedAt
          : lockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: null == expiresAt
          ? _self.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deviceId: null == deviceId
          ? _self.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
