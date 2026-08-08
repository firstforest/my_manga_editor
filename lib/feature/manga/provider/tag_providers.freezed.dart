// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tag_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TagFilter {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is TagFilter);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TagFilter()';
  }
}

/// @nodoc
class $TagFilterCopyWith<$Res> {
  $TagFilterCopyWith(TagFilter _, $Res Function(TagFilter) __);
}

/// Adds pattern-matching-related methods to [TagFilter].
extension TagFilterPatterns on TagFilter {
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
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TagFilterAll value)? all,
    TResult Function(TagFilterUntagged value)? untagged,
    TResult Function(TagFilterTag value)? tag,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case TagFilterAll() when all != null:
        return all(_that);
      case TagFilterUntagged() when untagged != null:
        return untagged(_that);
      case TagFilterTag() when tag != null:
        return tag(_that);
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
  TResult map<TResult extends Object?>({
    required TResult Function(TagFilterAll value) all,
    required TResult Function(TagFilterUntagged value) untagged,
    required TResult Function(TagFilterTag value) tag,
  }) {
    final _that = this;
    switch (_that) {
      case TagFilterAll():
        return all(_that);
      case TagFilterUntagged():
        return untagged(_that);
      case TagFilterTag():
        return tag(_that);
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
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TagFilterAll value)? all,
    TResult? Function(TagFilterUntagged value)? untagged,
    TResult? Function(TagFilterTag value)? tag,
  }) {
    final _that = this;
    switch (_that) {
      case TagFilterAll() when all != null:
        return all(_that);
      case TagFilterUntagged() when untagged != null:
        return untagged(_that);
      case TagFilterTag() when tag != null:
        return tag(_that);
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
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? all,
    TResult Function()? untagged,
    TResult Function(String name)? tag,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case TagFilterAll() when all != null:
        return all();
      case TagFilterUntagged() when untagged != null:
        return untagged();
      case TagFilterTag() when tag != null:
        return tag(_that.name);
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
  TResult when<TResult extends Object?>({
    required TResult Function() all,
    required TResult Function() untagged,
    required TResult Function(String name) tag,
  }) {
    final _that = this;
    switch (_that) {
      case TagFilterAll():
        return all();
      case TagFilterUntagged():
        return untagged();
      case TagFilterTag():
        return tag(_that.name);
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
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? all,
    TResult? Function()? untagged,
    TResult? Function(String name)? tag,
  }) {
    final _that = this;
    switch (_that) {
      case TagFilterAll() when all != null:
        return all();
      case TagFilterUntagged() when untagged != null:
        return untagged();
      case TagFilterTag() when tag != null:
        return tag(_that.name);
      case _:
        return null;
    }
  }
}

/// @nodoc

class TagFilterAll implements TagFilter {
  const TagFilterAll();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is TagFilterAll);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TagFilter.all()';
  }
}

/// @nodoc

class TagFilterUntagged implements TagFilter {
  const TagFilterUntagged();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is TagFilterUntagged);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TagFilter.untagged()';
  }
}

/// @nodoc

class TagFilterTag implements TagFilter {
  const TagFilterTag(this.name);

  final String name;

  /// Create a copy of TagFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TagFilterTagCopyWith<TagFilterTag> get copyWith =>
      _$TagFilterTagCopyWithImpl<TagFilterTag>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TagFilterTag &&
            (identical(other.name, name) || other.name == name));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name);

  @override
  String toString() {
    return 'TagFilter.tag(name: $name)';
  }
}

/// @nodoc
abstract mixin class $TagFilterTagCopyWith<$Res>
    implements $TagFilterCopyWith<$Res> {
  factory $TagFilterTagCopyWith(
          TagFilterTag value, $Res Function(TagFilterTag) _then) =
      _$TagFilterTagCopyWithImpl;
  @useResult
  $Res call({String name});
}

/// @nodoc
class _$TagFilterTagCopyWithImpl<$Res> implements $TagFilterTagCopyWith<$Res> {
  _$TagFilterTagCopyWithImpl(this._self, this._then);

  final TagFilterTag _self;
  final $Res Function(TagFilterTag) _then;

  /// Create a copy of TagFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
  }) {
    return _then(TagFilterTag(
      null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
