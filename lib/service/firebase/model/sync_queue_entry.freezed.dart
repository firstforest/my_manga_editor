// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_queue_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SyncQueueEntry {
  int get id; // SQLite auto-increment ID
  SyncOperationType get operationType; // CRUD operation type
  String get collectionPath; // Firestore collection path
  String? get documentId; // Document ID (null for create)
  Map<String, dynamic>? get data; // JSON payload
  DateTime get timestamp; // Queue entry creation time
  int get retryCount; // Number of retry attempts
  SyncQueueStatus get status;

  /// Create a copy of SyncQueueEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SyncQueueEntryCopyWith<SyncQueueEntry> get copyWith =>
      _$SyncQueueEntryCopyWithImpl<SyncQueueEntry>(
          this as SyncQueueEntry, _$identity);

  /// Serializes this SyncQueueEntry to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SyncQueueEntry &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.operationType, operationType) ||
                other.operationType == operationType) &&
            (identical(other.collectionPath, collectionPath) ||
                other.collectionPath == collectionPath) &&
            (identical(other.documentId, documentId) ||
                other.documentId == documentId) &&
            const DeepCollectionEquality().equals(other.data, data) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.retryCount, retryCount) ||
                other.retryCount == retryCount) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      operationType,
      collectionPath,
      documentId,
      const DeepCollectionEquality().hash(data),
      timestamp,
      retryCount,
      status);

  @override
  String toString() {
    return 'SyncQueueEntry(id: $id, operationType: $operationType, collectionPath: $collectionPath, documentId: $documentId, data: $data, timestamp: $timestamp, retryCount: $retryCount, status: $status)';
  }
}

/// @nodoc
abstract mixin class $SyncQueueEntryCopyWith<$Res> {
  factory $SyncQueueEntryCopyWith(
          SyncQueueEntry value, $Res Function(SyncQueueEntry) _then) =
      _$SyncQueueEntryCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      SyncOperationType operationType,
      String collectionPath,
      String? documentId,
      Map<String, dynamic>? data,
      DateTime timestamp,
      int retryCount,
      SyncQueueStatus status});
}

/// @nodoc
class _$SyncQueueEntryCopyWithImpl<$Res>
    implements $SyncQueueEntryCopyWith<$Res> {
  _$SyncQueueEntryCopyWithImpl(this._self, this._then);

  final SyncQueueEntry _self;
  final $Res Function(SyncQueueEntry) _then;

  /// Create a copy of SyncQueueEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? operationType = null,
    Object? collectionPath = null,
    Object? documentId = freezed,
    Object? data = freezed,
    Object? timestamp = null,
    Object? retryCount = null,
    Object? status = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      operationType: null == operationType
          ? _self.operationType
          : operationType // ignore: cast_nullable_to_non_nullable
              as SyncOperationType,
      collectionPath: null == collectionPath
          ? _self.collectionPath
          : collectionPath // ignore: cast_nullable_to_non_nullable
              as String,
      documentId: freezed == documentId
          ? _self.documentId
          : documentId // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      retryCount: null == retryCount
          ? _self.retryCount
          : retryCount // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as SyncQueueStatus,
    ));
  }
}

/// Adds pattern-matching-related methods to [SyncQueueEntry].
extension SyncQueueEntryPatterns on SyncQueueEntry {
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
    TResult Function(_SyncQueueEntry value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SyncQueueEntry() when $default != null:
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
    TResult Function(_SyncQueueEntry value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SyncQueueEntry():
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
    TResult? Function(_SyncQueueEntry value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SyncQueueEntry() when $default != null:
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
            int id,
            SyncOperationType operationType,
            String collectionPath,
            String? documentId,
            Map<String, dynamic>? data,
            DateTime timestamp,
            int retryCount,
            SyncQueueStatus status)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SyncQueueEntry() when $default != null:
        return $default(
            _that.id,
            _that.operationType,
            _that.collectionPath,
            _that.documentId,
            _that.data,
            _that.timestamp,
            _that.retryCount,
            _that.status);
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
            int id,
            SyncOperationType operationType,
            String collectionPath,
            String? documentId,
            Map<String, dynamic>? data,
            DateTime timestamp,
            int retryCount,
            SyncQueueStatus status)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SyncQueueEntry():
        return $default(
            _that.id,
            _that.operationType,
            _that.collectionPath,
            _that.documentId,
            _that.data,
            _that.timestamp,
            _that.retryCount,
            _that.status);
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
            int id,
            SyncOperationType operationType,
            String collectionPath,
            String? documentId,
            Map<String, dynamic>? data,
            DateTime timestamp,
            int retryCount,
            SyncQueueStatus status)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SyncQueueEntry() when $default != null:
        return $default(
            _that.id,
            _that.operationType,
            _that.collectionPath,
            _that.documentId,
            _that.data,
            _that.timestamp,
            _that.retryCount,
            _that.status);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SyncQueueEntry implements SyncQueueEntry {
  const _SyncQueueEntry(
      {required this.id,
      required this.operationType,
      required this.collectionPath,
      required this.documentId,
      required final Map<String, dynamic>? data,
      required this.timestamp,
      this.retryCount = 0,
      this.status = SyncQueueStatus.pending})
      : _data = data;
  factory _SyncQueueEntry.fromJson(Map<String, dynamic> json) =>
      _$SyncQueueEntryFromJson(json);

  @override
  final int id;
// SQLite auto-increment ID
  @override
  final SyncOperationType operationType;
// CRUD operation type
  @override
  final String collectionPath;
// Firestore collection path
  @override
  final String? documentId;
// Document ID (null for create)
  final Map<String, dynamic>? _data;
// Document ID (null for create)
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

// JSON payload
  @override
  final DateTime timestamp;
// Queue entry creation time
  @override
  @JsonKey()
  final int retryCount;
// Number of retry attempts
  @override
  @JsonKey()
  final SyncQueueStatus status;

  /// Create a copy of SyncQueueEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SyncQueueEntryCopyWith<_SyncQueueEntry> get copyWith =>
      __$SyncQueueEntryCopyWithImpl<_SyncQueueEntry>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SyncQueueEntryToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SyncQueueEntry &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.operationType, operationType) ||
                other.operationType == operationType) &&
            (identical(other.collectionPath, collectionPath) ||
                other.collectionPath == collectionPath) &&
            (identical(other.documentId, documentId) ||
                other.documentId == documentId) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.retryCount, retryCount) ||
                other.retryCount == retryCount) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      operationType,
      collectionPath,
      documentId,
      const DeepCollectionEquality().hash(_data),
      timestamp,
      retryCount,
      status);

  @override
  String toString() {
    return 'SyncQueueEntry(id: $id, operationType: $operationType, collectionPath: $collectionPath, documentId: $documentId, data: $data, timestamp: $timestamp, retryCount: $retryCount, status: $status)';
  }
}

/// @nodoc
abstract mixin class _$SyncQueueEntryCopyWith<$Res>
    implements $SyncQueueEntryCopyWith<$Res> {
  factory _$SyncQueueEntryCopyWith(
          _SyncQueueEntry value, $Res Function(_SyncQueueEntry) _then) =
      __$SyncQueueEntryCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      SyncOperationType operationType,
      String collectionPath,
      String? documentId,
      Map<String, dynamic>? data,
      DateTime timestamp,
      int retryCount,
      SyncQueueStatus status});
}

/// @nodoc
class __$SyncQueueEntryCopyWithImpl<$Res>
    implements _$SyncQueueEntryCopyWith<$Res> {
  __$SyncQueueEntryCopyWithImpl(this._self, this._then);

  final _SyncQueueEntry _self;
  final $Res Function(_SyncQueueEntry) _then;

  /// Create a copy of SyncQueueEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? operationType = null,
    Object? collectionPath = null,
    Object? documentId = freezed,
    Object? data = freezed,
    Object? timestamp = null,
    Object? retryCount = null,
    Object? status = null,
  }) {
    return _then(_SyncQueueEntry(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      operationType: null == operationType
          ? _self.operationType
          : operationType // ignore: cast_nullable_to_non_nullable
              as SyncOperationType,
      collectionPath: null == collectionPath
          ? _self.collectionPath
          : collectionPath // ignore: cast_nullable_to_non_nullable
              as String,
      documentId: freezed == documentId
          ? _self.documentId
          : documentId // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _self._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      retryCount: null == retryCount
          ? _self.retryCount
          : retryCount // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as SyncQueueStatus,
    ));
  }
}

// dart format on
