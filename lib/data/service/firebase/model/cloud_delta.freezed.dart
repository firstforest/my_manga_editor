// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cloud_delta.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CloudDelta {
  String get id; // Firestore document ID
  String get mangaId; // Parent manga ID
  List<dynamic> get ops; // Quill Delta operations
  String
      get fieldName; // 'ideaMemo', 'memoDelta', 'stageDirectionDelta', 'dialoguesDelta'
  String?
      get pageId; // Page ID if this delta belongs to a page (null for ideaMemo)
  DateTime get createdAt; // Creation timestamp
  DateTime get updatedAt;

  /// Create a copy of CloudDelta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CloudDeltaCopyWith<CloudDelta> get copyWith =>
      _$CloudDeltaCopyWithImpl<CloudDelta>(this as CloudDelta, _$identity);

  /// Serializes this CloudDelta to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CloudDelta &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.mangaId, mangaId) || other.mangaId == mangaId) &&
            const DeepCollectionEquality().equals(other.ops, ops) &&
            (identical(other.fieldName, fieldName) ||
                other.fieldName == fieldName) &&
            (identical(other.pageId, pageId) || other.pageId == pageId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      mangaId,
      const DeepCollectionEquality().hash(ops),
      fieldName,
      pageId,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'CloudDelta(id: $id, mangaId: $mangaId, ops: $ops, fieldName: $fieldName, pageId: $pageId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $CloudDeltaCopyWith<$Res> {
  factory $CloudDeltaCopyWith(
          CloudDelta value, $Res Function(CloudDelta) _then) =
      _$CloudDeltaCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String mangaId,
      List<dynamic> ops,
      String fieldName,
      String? pageId,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$CloudDeltaCopyWithImpl<$Res> implements $CloudDeltaCopyWith<$Res> {
  _$CloudDeltaCopyWithImpl(this._self, this._then);

  final CloudDelta _self;
  final $Res Function(CloudDelta) _then;

  /// Create a copy of CloudDelta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? mangaId = null,
    Object? ops = null,
    Object? fieldName = null,
    Object? pageId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      mangaId: null == mangaId
          ? _self.mangaId
          : mangaId // ignore: cast_nullable_to_non_nullable
              as String,
      ops: null == ops
          ? _self.ops
          : ops // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      fieldName: null == fieldName
          ? _self.fieldName
          : fieldName // ignore: cast_nullable_to_non_nullable
              as String,
      pageId: freezed == pageId
          ? _self.pageId
          : pageId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [CloudDelta].
extension CloudDeltaPatterns on CloudDelta {
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
    TResult Function(_CloudDelta value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CloudDelta() when $default != null:
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
    TResult Function(_CloudDelta value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CloudDelta():
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
    TResult? Function(_CloudDelta value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CloudDelta() when $default != null:
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
            String mangaId,
            List<dynamic> ops,
            String fieldName,
            String? pageId,
            DateTime createdAt,
            DateTime updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CloudDelta() when $default != null:
        return $default(_that.id, _that.mangaId, _that.ops, _that.fieldName,
            _that.pageId, _that.createdAt, _that.updatedAt);
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
            String mangaId,
            List<dynamic> ops,
            String fieldName,
            String? pageId,
            DateTime createdAt,
            DateTime updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CloudDelta():
        return $default(_that.id, _that.mangaId, _that.ops, _that.fieldName,
            _that.pageId, _that.createdAt, _that.updatedAt);
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
            String mangaId,
            List<dynamic> ops,
            String fieldName,
            String? pageId,
            DateTime createdAt,
            DateTime updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CloudDelta() when $default != null:
        return $default(_that.id, _that.mangaId, _that.ops, _that.fieldName,
            _that.pageId, _that.createdAt, _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CloudDelta implements CloudDelta {
  const _CloudDelta(
      {required this.id,
      required this.mangaId,
      required final List<dynamic> ops,
      required this.fieldName,
      this.pageId,
      required this.createdAt,
      required this.updatedAt})
      : _ops = ops;
  factory _CloudDelta.fromJson(Map<String, dynamic> json) =>
      _$CloudDeltaFromJson(json);

  @override
  final String id;
// Firestore document ID
  @override
  final String mangaId;
// Parent manga ID
  final List<dynamic> _ops;
// Parent manga ID
  @override
  List<dynamic> get ops {
    if (_ops is EqualUnmodifiableListView) return _ops;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ops);
  }

// Quill Delta operations
  @override
  final String fieldName;
// 'ideaMemo', 'memoDelta', 'stageDirectionDelta', 'dialoguesDelta'
  @override
  final String? pageId;
// Page ID if this delta belongs to a page (null for ideaMemo)
  @override
  final DateTime createdAt;
// Creation timestamp
  @override
  final DateTime updatedAt;

  /// Create a copy of CloudDelta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CloudDeltaCopyWith<_CloudDelta> get copyWith =>
      __$CloudDeltaCopyWithImpl<_CloudDelta>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CloudDeltaToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CloudDelta &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.mangaId, mangaId) || other.mangaId == mangaId) &&
            const DeepCollectionEquality().equals(other._ops, _ops) &&
            (identical(other.fieldName, fieldName) ||
                other.fieldName == fieldName) &&
            (identical(other.pageId, pageId) || other.pageId == pageId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      mangaId,
      const DeepCollectionEquality().hash(_ops),
      fieldName,
      pageId,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'CloudDelta(id: $id, mangaId: $mangaId, ops: $ops, fieldName: $fieldName, pageId: $pageId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$CloudDeltaCopyWith<$Res>
    implements $CloudDeltaCopyWith<$Res> {
  factory _$CloudDeltaCopyWith(
          _CloudDelta value, $Res Function(_CloudDelta) _then) =
      __$CloudDeltaCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String mangaId,
      List<dynamic> ops,
      String fieldName,
      String? pageId,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$CloudDeltaCopyWithImpl<$Res> implements _$CloudDeltaCopyWith<$Res> {
  __$CloudDeltaCopyWithImpl(this._self, this._then);

  final _CloudDelta _self;
  final $Res Function(_CloudDelta) _then;

  /// Create a copy of CloudDelta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? mangaId = null,
    Object? ops = null,
    Object? fieldName = null,
    Object? pageId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_CloudDelta(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      mangaId: null == mangaId
          ? _self.mangaId
          : mangaId // ignore: cast_nullable_to_non_nullable
              as String,
      ops: null == ops
          ? _self._ops
          : ops // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      fieldName: null == fieldName
          ? _self.fieldName
          : fieldName // ignore: cast_nullable_to_non_nullable
              as String,
      pageId: freezed == pageId
          ? _self.pageId
          : pageId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
