// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SyncStatus {
  bool get isOnline;
  bool get isSyncing;
  DateTime? get lastSyncedAt;
  List<String> get pendingMangaIds;

  /// Create a copy of SyncStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SyncStatusCopyWith<SyncStatus> get copyWith =>
      _$SyncStatusCopyWithImpl<SyncStatus>(this as SyncStatus, _$identity);

  /// Serializes this SyncStatus to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SyncStatus &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.isSyncing, isSyncing) ||
                other.isSyncing == isSyncing) &&
            (identical(other.lastSyncedAt, lastSyncedAt) ||
                other.lastSyncedAt == lastSyncedAt) &&
            const DeepCollectionEquality()
                .equals(other.pendingMangaIds, pendingMangaIds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, isOnline, isSyncing,
      lastSyncedAt, const DeepCollectionEquality().hash(pendingMangaIds));

  @override
  String toString() {
    return 'SyncStatus(isOnline: $isOnline, isSyncing: $isSyncing, lastSyncedAt: $lastSyncedAt, pendingMangaIds: $pendingMangaIds)';
  }
}

/// @nodoc
abstract mixin class $SyncStatusCopyWith<$Res> {
  factory $SyncStatusCopyWith(
          SyncStatus value, $Res Function(SyncStatus) _then) =
      _$SyncStatusCopyWithImpl;
  @useResult
  $Res call(
      {bool isOnline,
      bool isSyncing,
      DateTime? lastSyncedAt,
      List<String> pendingMangaIds});
}

/// @nodoc
class _$SyncStatusCopyWithImpl<$Res> implements $SyncStatusCopyWith<$Res> {
  _$SyncStatusCopyWithImpl(this._self, this._then);

  final SyncStatus _self;
  final $Res Function(SyncStatus) _then;

  /// Create a copy of SyncStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isOnline = null,
    Object? isSyncing = null,
    Object? lastSyncedAt = freezed,
    Object? pendingMangaIds = null,
  }) {
    return _then(_self.copyWith(
      isOnline: null == isOnline
          ? _self.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      isSyncing: null == isSyncing
          ? _self.isSyncing
          : isSyncing // ignore: cast_nullable_to_non_nullable
              as bool,
      lastSyncedAt: freezed == lastSyncedAt
          ? _self.lastSyncedAt
          : lastSyncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pendingMangaIds: null == pendingMangaIds
          ? _self.pendingMangaIds
          : pendingMangaIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// Adds pattern-matching-related methods to [SyncStatus].
extension SyncStatusPatterns on SyncStatus {
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
    TResult Function(_SyncStatus value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SyncStatus() when $default != null:
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
    TResult Function(_SyncStatus value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SyncStatus():
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
    TResult? Function(_SyncStatus value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SyncStatus() when $default != null:
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
    TResult Function(bool isOnline, bool isSyncing, DateTime? lastSyncedAt,
            List<String> pendingMangaIds)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SyncStatus() when $default != null:
        return $default(_that.isOnline, _that.isSyncing, _that.lastSyncedAt,
            _that.pendingMangaIds);
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
    TResult Function(bool isOnline, bool isSyncing, DateTime? lastSyncedAt,
            List<String> pendingMangaIds)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SyncStatus():
        return $default(_that.isOnline, _that.isSyncing, _that.lastSyncedAt,
            _that.pendingMangaIds);
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
    TResult? Function(bool isOnline, bool isSyncing, DateTime? lastSyncedAt,
            List<String> pendingMangaIds)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SyncStatus() when $default != null:
        return $default(_that.isOnline, _that.isSyncing, _that.lastSyncedAt,
            _that.pendingMangaIds);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SyncStatus implements SyncStatus {
  const _SyncStatus(
      {required this.isOnline,
      required this.isSyncing,
      required this.lastSyncedAt,
      final List<String> pendingMangaIds = const []})
      : _pendingMangaIds = pendingMangaIds;
  factory _SyncStatus.fromJson(Map<String, dynamic> json) =>
      _$SyncStatusFromJson(json);

  @override
  final bool isOnline;
  @override
  final bool isSyncing;
  @override
  final DateTime? lastSyncedAt;
  final List<String> _pendingMangaIds;
  @override
  @JsonKey()
  List<String> get pendingMangaIds {
    if (_pendingMangaIds is EqualUnmodifiableListView) return _pendingMangaIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pendingMangaIds);
  }

  /// Create a copy of SyncStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SyncStatusCopyWith<_SyncStatus> get copyWith =>
      __$SyncStatusCopyWithImpl<_SyncStatus>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SyncStatusToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SyncStatus &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.isSyncing, isSyncing) ||
                other.isSyncing == isSyncing) &&
            (identical(other.lastSyncedAt, lastSyncedAt) ||
                other.lastSyncedAt == lastSyncedAt) &&
            const DeepCollectionEquality()
                .equals(other._pendingMangaIds, _pendingMangaIds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, isOnline, isSyncing,
      lastSyncedAt, const DeepCollectionEquality().hash(_pendingMangaIds));

  @override
  String toString() {
    return 'SyncStatus(isOnline: $isOnline, isSyncing: $isSyncing, lastSyncedAt: $lastSyncedAt, pendingMangaIds: $pendingMangaIds)';
  }
}

/// @nodoc
abstract mixin class _$SyncStatusCopyWith<$Res>
    implements $SyncStatusCopyWith<$Res> {
  factory _$SyncStatusCopyWith(
          _SyncStatus value, $Res Function(_SyncStatus) _then) =
      __$SyncStatusCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool isOnline,
      bool isSyncing,
      DateTime? lastSyncedAt,
      List<String> pendingMangaIds});
}

/// @nodoc
class __$SyncStatusCopyWithImpl<$Res> implements _$SyncStatusCopyWith<$Res> {
  __$SyncStatusCopyWithImpl(this._self, this._then);

  final _SyncStatus _self;
  final $Res Function(_SyncStatus) _then;

  /// Create a copy of SyncStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isOnline = null,
    Object? isSyncing = null,
    Object? lastSyncedAt = freezed,
    Object? pendingMangaIds = null,
  }) {
    return _then(_SyncStatus(
      isOnline: null == isOnline
          ? _self.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      isSyncing: null == isSyncing
          ? _self.isSyncing
          : isSyncing // ignore: cast_nullable_to_non_nullable
              as bool,
      lastSyncedAt: freezed == lastSyncedAt
          ? _self.lastSyncedAt
          : lastSyncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pendingMangaIds: null == pendingMangaIds
          ? _self._pendingMangaIds
          : pendingMangaIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

// dart format on
