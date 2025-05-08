// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_comment_area.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AiComment {
  String get text;

  /// Create a copy of AiComment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AiCommentCopyWith<AiComment> get copyWith =>
      _$AiCommentCopyWithImpl<AiComment>(this as AiComment, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AiComment &&
            (identical(other.text, text) || other.text == text));
  }

  @override
  int get hashCode => Object.hash(runtimeType, text);

  @override
  String toString() {
    return 'AiComment(text: $text)';
  }
}

/// @nodoc
abstract mixin class $AiCommentCopyWith<$Res> {
  factory $AiCommentCopyWith(AiComment value, $Res Function(AiComment) _then) =
      _$AiCommentCopyWithImpl;
  @useResult
  $Res call({String text});
}

/// @nodoc
class _$AiCommentCopyWithImpl<$Res> implements $AiCommentCopyWith<$Res> {
  _$AiCommentCopyWithImpl(this._self, this._then);

  final AiComment _self;
  final $Res Function(AiComment) _then;

  /// Create a copy of AiComment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
  }) {
    return _then(_self.copyWith(
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _AiComment implements AiComment {
  const _AiComment({required this.text});

  @override
  final String text;

  /// Create a copy of AiComment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AiCommentCopyWith<_AiComment> get copyWith =>
      __$AiCommentCopyWithImpl<_AiComment>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AiComment &&
            (identical(other.text, text) || other.text == text));
  }

  @override
  int get hashCode => Object.hash(runtimeType, text);

  @override
  String toString() {
    return 'AiComment(text: $text)';
  }
}

/// @nodoc
abstract mixin class _$AiCommentCopyWith<$Res>
    implements $AiCommentCopyWith<$Res> {
  factory _$AiCommentCopyWith(
          _AiComment value, $Res Function(_AiComment) _then) =
      __$AiCommentCopyWithImpl;
  @override
  @useResult
  $Res call({String text});
}

/// @nodoc
class __$AiCommentCopyWithImpl<$Res> implements _$AiCommentCopyWith<$Res> {
  __$AiCommentCopyWithImpl(this._self, this._then);

  final _AiComment _self;
  final $Res Function(_AiComment) _then;

  /// Create a copy of AiComment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? text = null,
  }) {
    return _then(_AiComment(
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
