// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cloud_manga_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CloudMangaPage {
  String get id; // Firestore document ID
  String get mangaId; // Parent manga ID
  int get pageIndex; // Page order (0-based)
  Map<String, dynamic> get memoDelta; // Quill Delta for memo
  Map<String, dynamic>
      get stageDirectionDelta; // Quill Delta for stage directions
  Map<String, dynamic> get dialoguesDelta; // Quill Delta for dialogues
  DateTime get createdAt; // Creation timestamp
  DateTime get updatedAt;

  /// Create a copy of CloudMangaPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CloudMangaPageCopyWith<CloudMangaPage> get copyWith =>
      _$CloudMangaPageCopyWithImpl<CloudMangaPage>(
          this as CloudMangaPage, _$identity);

  /// Serializes this CloudMangaPage to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CloudMangaPage &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.mangaId, mangaId) || other.mangaId == mangaId) &&
            (identical(other.pageIndex, pageIndex) ||
                other.pageIndex == pageIndex) &&
            const DeepCollectionEquality().equals(other.memoDelta, memoDelta) &&
            const DeepCollectionEquality()
                .equals(other.stageDirectionDelta, stageDirectionDelta) &&
            const DeepCollectionEquality()
                .equals(other.dialoguesDelta, dialoguesDelta) &&
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
      pageIndex,
      const DeepCollectionEquality().hash(memoDelta),
      const DeepCollectionEquality().hash(stageDirectionDelta),
      const DeepCollectionEquality().hash(dialoguesDelta),
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'CloudMangaPage(id: $id, mangaId: $mangaId, pageIndex: $pageIndex, memoDelta: $memoDelta, stageDirectionDelta: $stageDirectionDelta, dialoguesDelta: $dialoguesDelta, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $CloudMangaPageCopyWith<$Res> {
  factory $CloudMangaPageCopyWith(
          CloudMangaPage value, $Res Function(CloudMangaPage) _then) =
      _$CloudMangaPageCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String mangaId,
      int pageIndex,
      Map<String, dynamic> memoDelta,
      Map<String, dynamic> stageDirectionDelta,
      Map<String, dynamic> dialoguesDelta,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$CloudMangaPageCopyWithImpl<$Res>
    implements $CloudMangaPageCopyWith<$Res> {
  _$CloudMangaPageCopyWithImpl(this._self, this._then);

  final CloudMangaPage _self;
  final $Res Function(CloudMangaPage) _then;

  /// Create a copy of CloudMangaPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? mangaId = null,
    Object? pageIndex = null,
    Object? memoDelta = null,
    Object? stageDirectionDelta = null,
    Object? dialoguesDelta = null,
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
      pageIndex: null == pageIndex
          ? _self.pageIndex
          : pageIndex // ignore: cast_nullable_to_non_nullable
              as int,
      memoDelta: null == memoDelta
          ? _self.memoDelta
          : memoDelta // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      stageDirectionDelta: null == stageDirectionDelta
          ? _self.stageDirectionDelta
          : stageDirectionDelta // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      dialoguesDelta: null == dialoguesDelta
          ? _self.dialoguesDelta
          : dialoguesDelta // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
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

/// Adds pattern-matching-related methods to [CloudMangaPage].
extension CloudMangaPagePatterns on CloudMangaPage {
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
    TResult Function(_CloudMangaPage value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CloudMangaPage() when $default != null:
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
    TResult Function(_CloudMangaPage value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CloudMangaPage():
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
    TResult? Function(_CloudMangaPage value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CloudMangaPage() when $default != null:
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
            int pageIndex,
            Map<String, dynamic> memoDelta,
            Map<String, dynamic> stageDirectionDelta,
            Map<String, dynamic> dialoguesDelta,
            DateTime createdAt,
            DateTime updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CloudMangaPage() when $default != null:
        return $default(
            _that.id,
            _that.mangaId,
            _that.pageIndex,
            _that.memoDelta,
            _that.stageDirectionDelta,
            _that.dialoguesDelta,
            _that.createdAt,
            _that.updatedAt);
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
            int pageIndex,
            Map<String, dynamic> memoDelta,
            Map<String, dynamic> stageDirectionDelta,
            Map<String, dynamic> dialoguesDelta,
            DateTime createdAt,
            DateTime updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CloudMangaPage():
        return $default(
            _that.id,
            _that.mangaId,
            _that.pageIndex,
            _that.memoDelta,
            _that.stageDirectionDelta,
            _that.dialoguesDelta,
            _that.createdAt,
            _that.updatedAt);
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
            int pageIndex,
            Map<String, dynamic> memoDelta,
            Map<String, dynamic> stageDirectionDelta,
            Map<String, dynamic> dialoguesDelta,
            DateTime createdAt,
            DateTime updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CloudMangaPage() when $default != null:
        return $default(
            _that.id,
            _that.mangaId,
            _that.pageIndex,
            _that.memoDelta,
            _that.stageDirectionDelta,
            _that.dialoguesDelta,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CloudMangaPage implements CloudMangaPage {
  const _CloudMangaPage(
      {required this.id,
      required this.mangaId,
      required this.pageIndex,
      required final Map<String, dynamic> memoDelta,
      required final Map<String, dynamic> stageDirectionDelta,
      required final Map<String, dynamic> dialoguesDelta,
      required this.createdAt,
      required this.updatedAt})
      : _memoDelta = memoDelta,
        _stageDirectionDelta = stageDirectionDelta,
        _dialoguesDelta = dialoguesDelta;
  factory _CloudMangaPage.fromJson(Map<String, dynamic> json) =>
      _$CloudMangaPageFromJson(json);

  @override
  final String id;
// Firestore document ID
  @override
  final String mangaId;
// Parent manga ID
  @override
  final int pageIndex;
// Page order (0-based)
  final Map<String, dynamic> _memoDelta;
// Page order (0-based)
  @override
  Map<String, dynamic> get memoDelta {
    if (_memoDelta is EqualUnmodifiableMapView) return _memoDelta;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_memoDelta);
  }

// Quill Delta for memo
  final Map<String, dynamic> _stageDirectionDelta;
// Quill Delta for memo
  @override
  Map<String, dynamic> get stageDirectionDelta {
    if (_stageDirectionDelta is EqualUnmodifiableMapView)
      return _stageDirectionDelta;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_stageDirectionDelta);
  }

// Quill Delta for stage directions
  final Map<String, dynamic> _dialoguesDelta;
// Quill Delta for stage directions
  @override
  Map<String, dynamic> get dialoguesDelta {
    if (_dialoguesDelta is EqualUnmodifiableMapView) return _dialoguesDelta;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_dialoguesDelta);
  }

// Quill Delta for dialogues
  @override
  final DateTime createdAt;
// Creation timestamp
  @override
  final DateTime updatedAt;

  /// Create a copy of CloudMangaPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CloudMangaPageCopyWith<_CloudMangaPage> get copyWith =>
      __$CloudMangaPageCopyWithImpl<_CloudMangaPage>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CloudMangaPageToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CloudMangaPage &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.mangaId, mangaId) || other.mangaId == mangaId) &&
            (identical(other.pageIndex, pageIndex) ||
                other.pageIndex == pageIndex) &&
            const DeepCollectionEquality()
                .equals(other._memoDelta, _memoDelta) &&
            const DeepCollectionEquality()
                .equals(other._stageDirectionDelta, _stageDirectionDelta) &&
            const DeepCollectionEquality()
                .equals(other._dialoguesDelta, _dialoguesDelta) &&
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
      pageIndex,
      const DeepCollectionEquality().hash(_memoDelta),
      const DeepCollectionEquality().hash(_stageDirectionDelta),
      const DeepCollectionEquality().hash(_dialoguesDelta),
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'CloudMangaPage(id: $id, mangaId: $mangaId, pageIndex: $pageIndex, memoDelta: $memoDelta, stageDirectionDelta: $stageDirectionDelta, dialoguesDelta: $dialoguesDelta, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$CloudMangaPageCopyWith<$Res>
    implements $CloudMangaPageCopyWith<$Res> {
  factory _$CloudMangaPageCopyWith(
          _CloudMangaPage value, $Res Function(_CloudMangaPage) _then) =
      __$CloudMangaPageCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String mangaId,
      int pageIndex,
      Map<String, dynamic> memoDelta,
      Map<String, dynamic> stageDirectionDelta,
      Map<String, dynamic> dialoguesDelta,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$CloudMangaPageCopyWithImpl<$Res>
    implements _$CloudMangaPageCopyWith<$Res> {
  __$CloudMangaPageCopyWithImpl(this._self, this._then);

  final _CloudMangaPage _self;
  final $Res Function(_CloudMangaPage) _then;

  /// Create a copy of CloudMangaPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? mangaId = null,
    Object? pageIndex = null,
    Object? memoDelta = null,
    Object? stageDirectionDelta = null,
    Object? dialoguesDelta = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_CloudMangaPage(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      mangaId: null == mangaId
          ? _self.mangaId
          : mangaId // ignore: cast_nullable_to_non_nullable
              as String,
      pageIndex: null == pageIndex
          ? _self.pageIndex
          : pageIndex // ignore: cast_nullable_to_non_nullable
              as int,
      memoDelta: null == memoDelta
          ? _self._memoDelta
          : memoDelta // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      stageDirectionDelta: null == stageDirectionDelta
          ? _self._stageDirectionDelta
          : stageDirectionDelta // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      dialoguesDelta: null == dialoguesDelta
          ? _self._dialoguesDelta
          : dialoguesDelta // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
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
