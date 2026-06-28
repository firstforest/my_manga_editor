// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cloud_app_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CloudAppConfig {
  /// この値より小さいビルド番号のクライアントは更新必須とみなす。
  int get minSupportedBuildNumber;

  /// Create a copy of CloudAppConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CloudAppConfigCopyWith<CloudAppConfig> get copyWith =>
      _$CloudAppConfigCopyWithImpl<CloudAppConfig>(
          this as CloudAppConfig, _$identity);

  /// Serializes this CloudAppConfig to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CloudAppConfig &&
            (identical(
                    other.minSupportedBuildNumber, minSupportedBuildNumber) ||
                other.minSupportedBuildNumber == minSupportedBuildNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, minSupportedBuildNumber);

  @override
  String toString() {
    return 'CloudAppConfig(minSupportedBuildNumber: $minSupportedBuildNumber)';
  }
}

/// @nodoc
abstract mixin class $CloudAppConfigCopyWith<$Res> {
  factory $CloudAppConfigCopyWith(
          CloudAppConfig value, $Res Function(CloudAppConfig) _then) =
      _$CloudAppConfigCopyWithImpl;
  @useResult
  $Res call({int minSupportedBuildNumber});
}

/// @nodoc
class _$CloudAppConfigCopyWithImpl<$Res>
    implements $CloudAppConfigCopyWith<$Res> {
  _$CloudAppConfigCopyWithImpl(this._self, this._then);

  final CloudAppConfig _self;
  final $Res Function(CloudAppConfig) _then;

  /// Create a copy of CloudAppConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minSupportedBuildNumber = null,
  }) {
    return _then(_self.copyWith(
      minSupportedBuildNumber: null == minSupportedBuildNumber
          ? _self.minSupportedBuildNumber
          : minSupportedBuildNumber // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [CloudAppConfig].
extension CloudAppConfigPatterns on CloudAppConfig {
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
    TResult Function(_CloudAppConfig value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CloudAppConfig() when $default != null:
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
    TResult Function(_CloudAppConfig value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CloudAppConfig():
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
    TResult? Function(_CloudAppConfig value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CloudAppConfig() when $default != null:
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
    TResult Function(int minSupportedBuildNumber)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CloudAppConfig() when $default != null:
        return $default(_that.minSupportedBuildNumber);
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
    TResult Function(int minSupportedBuildNumber) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CloudAppConfig():
        return $default(_that.minSupportedBuildNumber);
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
    TResult? Function(int minSupportedBuildNumber)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CloudAppConfig() when $default != null:
        return $default(_that.minSupportedBuildNumber);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CloudAppConfig implements CloudAppConfig {
  const _CloudAppConfig({required this.minSupportedBuildNumber});
  factory _CloudAppConfig.fromJson(Map<String, dynamic> json) =>
      _$CloudAppConfigFromJson(json);

  /// この値より小さいビルド番号のクライアントは更新必須とみなす。
  @override
  final int minSupportedBuildNumber;

  /// Create a copy of CloudAppConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CloudAppConfigCopyWith<_CloudAppConfig> get copyWith =>
      __$CloudAppConfigCopyWithImpl<_CloudAppConfig>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CloudAppConfigToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CloudAppConfig &&
            (identical(
                    other.minSupportedBuildNumber, minSupportedBuildNumber) ||
                other.minSupportedBuildNumber == minSupportedBuildNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, minSupportedBuildNumber);

  @override
  String toString() {
    return 'CloudAppConfig(minSupportedBuildNumber: $minSupportedBuildNumber)';
  }
}

/// @nodoc
abstract mixin class _$CloudAppConfigCopyWith<$Res>
    implements $CloudAppConfigCopyWith<$Res> {
  factory _$CloudAppConfigCopyWith(
          _CloudAppConfig value, $Res Function(_CloudAppConfig) _then) =
      __$CloudAppConfigCopyWithImpl;
  @override
  @useResult
  $Res call({int minSupportedBuildNumber});
}

/// @nodoc
class __$CloudAppConfigCopyWithImpl<$Res>
    implements _$CloudAppConfigCopyWith<$Res> {
  __$CloudAppConfigCopyWithImpl(this._self, this._then);

  final _CloudAppConfig _self;
  final $Res Function(_CloudAppConfig) _then;

  /// Create a copy of CloudAppConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? minSupportedBuildNumber = null,
  }) {
    return _then(_CloudAppConfig(
      minSupportedBuildNumber: null == minSupportedBuildNumber
          ? _self.minSupportedBuildNumber
          : minSupportedBuildNumber // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
