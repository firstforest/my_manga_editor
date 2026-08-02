// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppConfig {
  /// この値より小さいビルド番号のクライアントは更新必須とみなす。
  int get minSupportedBuildNumber;

  /// 全利用者に見せるお知らせ。出していないときは null。
  AppNotice? get notice;

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AppConfigCopyWith<AppConfig> get copyWith =>
      _$AppConfigCopyWithImpl<AppConfig>(this as AppConfig, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppConfig &&
            (identical(
                    other.minSupportedBuildNumber, minSupportedBuildNumber) ||
                other.minSupportedBuildNumber == minSupportedBuildNumber) &&
            (identical(other.notice, notice) || other.notice == notice));
  }

  @override
  int get hashCode => Object.hash(runtimeType, minSupportedBuildNumber, notice);

  @override
  String toString() {
    return 'AppConfig(minSupportedBuildNumber: $minSupportedBuildNumber, notice: $notice)';
  }
}

/// @nodoc
abstract mixin class $AppConfigCopyWith<$Res> {
  factory $AppConfigCopyWith(AppConfig value, $Res Function(AppConfig) _then) =
      _$AppConfigCopyWithImpl;
  @useResult
  $Res call({int minSupportedBuildNumber, AppNotice? notice});

  $AppNoticeCopyWith<$Res>? get notice;
}

/// @nodoc
class _$AppConfigCopyWithImpl<$Res> implements $AppConfigCopyWith<$Res> {
  _$AppConfigCopyWithImpl(this._self, this._then);

  final AppConfig _self;
  final $Res Function(AppConfig) _then;

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minSupportedBuildNumber = null,
    Object? notice = freezed,
  }) {
    return _then(_self.copyWith(
      minSupportedBuildNumber: null == minSupportedBuildNumber
          ? _self.minSupportedBuildNumber
          : minSupportedBuildNumber // ignore: cast_nullable_to_non_nullable
              as int,
      notice: freezed == notice
          ? _self.notice
          : notice // ignore: cast_nullable_to_non_nullable
              as AppNotice?,
    ));
  }

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppNoticeCopyWith<$Res>? get notice {
    if (_self.notice == null) {
      return null;
    }

    return $AppNoticeCopyWith<$Res>(_self.notice!, (value) {
      return _then(_self.copyWith(notice: value));
    });
  }
}

/// Adds pattern-matching-related methods to [AppConfig].
extension AppConfigPatterns on AppConfig {
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
    TResult Function(_AppConfig value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AppConfig() when $default != null:
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
    TResult Function(_AppConfig value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppConfig():
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
    TResult? Function(_AppConfig value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppConfig() when $default != null:
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
    TResult Function(int minSupportedBuildNumber, AppNotice? notice)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AppConfig() when $default != null:
        return $default(_that.minSupportedBuildNumber, _that.notice);
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
    TResult Function(int minSupportedBuildNumber, AppNotice? notice) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppConfig():
        return $default(_that.minSupportedBuildNumber, _that.notice);
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
    TResult? Function(int minSupportedBuildNumber, AppNotice? notice)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppConfig() when $default != null:
        return $default(_that.minSupportedBuildNumber, _that.notice);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _AppConfig implements AppConfig {
  const _AppConfig({required this.minSupportedBuildNumber, this.notice});

  /// この値より小さいビルド番号のクライアントは更新必須とみなす。
  @override
  final int minSupportedBuildNumber;

  /// 全利用者に見せるお知らせ。出していないときは null。
  @override
  final AppNotice? notice;

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AppConfigCopyWith<_AppConfig> get copyWith =>
      __$AppConfigCopyWithImpl<_AppConfig>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AppConfig &&
            (identical(
                    other.minSupportedBuildNumber, minSupportedBuildNumber) ||
                other.minSupportedBuildNumber == minSupportedBuildNumber) &&
            (identical(other.notice, notice) || other.notice == notice));
  }

  @override
  int get hashCode => Object.hash(runtimeType, minSupportedBuildNumber, notice);

  @override
  String toString() {
    return 'AppConfig(minSupportedBuildNumber: $minSupportedBuildNumber, notice: $notice)';
  }
}

/// @nodoc
abstract mixin class _$AppConfigCopyWith<$Res>
    implements $AppConfigCopyWith<$Res> {
  factory _$AppConfigCopyWith(
          _AppConfig value, $Res Function(_AppConfig) _then) =
      __$AppConfigCopyWithImpl;
  @override
  @useResult
  $Res call({int minSupportedBuildNumber, AppNotice? notice});

  @override
  $AppNoticeCopyWith<$Res>? get notice;
}

/// @nodoc
class __$AppConfigCopyWithImpl<$Res> implements _$AppConfigCopyWith<$Res> {
  __$AppConfigCopyWithImpl(this._self, this._then);

  final _AppConfig _self;
  final $Res Function(_AppConfig) _then;

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? minSupportedBuildNumber = null,
    Object? notice = freezed,
  }) {
    return _then(_AppConfig(
      minSupportedBuildNumber: null == minSupportedBuildNumber
          ? _self.minSupportedBuildNumber
          : minSupportedBuildNumber // ignore: cast_nullable_to_non_nullable
              as int,
      notice: freezed == notice
          ? _self.notice
          : notice // ignore: cast_nullable_to_non_nullable
              as AppNotice?,
    ));
  }

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppNoticeCopyWith<$Res>? get notice {
    if (_self.notice == null) {
      return null;
    }

    return $AppNoticeCopyWith<$Res>(_self.notice!, (value) {
      return _then(_self.copyWith(notice: value));
    });
  }
}

/// @nodoc
mixin _$AppNotice {
  /// 利用者が「閉じた」状態を記録するための識別子。
  /// 本文を変えたらこの値も変える (再度表示させるため)。
  String get id;

  /// 表示する本文。
  String get message;

  /// Create a copy of AppNotice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AppNoticeCopyWith<AppNotice> get copyWith =>
      _$AppNoticeCopyWithImpl<AppNotice>(this as AppNotice, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppNotice &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, message);

  @override
  String toString() {
    return 'AppNotice(id: $id, message: $message)';
  }
}

/// @nodoc
abstract mixin class $AppNoticeCopyWith<$Res> {
  factory $AppNoticeCopyWith(AppNotice value, $Res Function(AppNotice) _then) =
      _$AppNoticeCopyWithImpl;
  @useResult
  $Res call({String id, String message});
}

/// @nodoc
class _$AppNoticeCopyWithImpl<$Res> implements $AppNoticeCopyWith<$Res> {
  _$AppNoticeCopyWithImpl(this._self, this._then);

  final AppNotice _self;
  final $Res Function(AppNotice) _then;

  /// Create a copy of AppNotice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? message = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [AppNotice].
extension AppNoticePatterns on AppNotice {
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
    TResult Function(_AppNotice value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AppNotice() when $default != null:
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
    TResult Function(_AppNotice value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppNotice():
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
    TResult? Function(_AppNotice value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppNotice() when $default != null:
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
    TResult Function(String id, String message)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AppNotice() when $default != null:
        return $default(_that.id, _that.message);
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
    TResult Function(String id, String message) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppNotice():
        return $default(_that.id, _that.message);
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
    TResult? Function(String id, String message)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppNotice() when $default != null:
        return $default(_that.id, _that.message);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _AppNotice implements AppNotice {
  const _AppNotice({required this.id, required this.message});

  /// 利用者が「閉じた」状態を記録するための識別子。
  /// 本文を変えたらこの値も変える (再度表示させるため)。
  @override
  final String id;

  /// 表示する本文。
  @override
  final String message;

  /// Create a copy of AppNotice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AppNoticeCopyWith<_AppNotice> get copyWith =>
      __$AppNoticeCopyWithImpl<_AppNotice>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AppNotice &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, message);

  @override
  String toString() {
    return 'AppNotice(id: $id, message: $message)';
  }
}

/// @nodoc
abstract mixin class _$AppNoticeCopyWith<$Res>
    implements $AppNoticeCopyWith<$Res> {
  factory _$AppNoticeCopyWith(
          _AppNotice value, $Res Function(_AppNotice) _then) =
      __$AppNoticeCopyWithImpl;
  @override
  @useResult
  $Res call({String id, String message});
}

/// @nodoc
class __$AppNoticeCopyWithImpl<$Res> implements _$AppNoticeCopyWith<$Res> {
  __$AppNoticeCopyWithImpl(this._self, this._then);

  final _AppNotice _self;
  final $Res Function(_AppNotice) _then;

  /// Create a copy of AppNotice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? message = null,
  }) {
    return _then(_AppNotice(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
