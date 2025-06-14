// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'manga_page_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MangaPageViewModel {
  MangaId? get mangaId;

  /// Create a copy of MangaPageViewModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MangaPageViewModelCopyWith<MangaPageViewModel> get copyWith =>
      _$MangaPageViewModelCopyWithImpl<MangaPageViewModel>(
          this as MangaPageViewModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MangaPageViewModel &&
            (identical(other.mangaId, mangaId) || other.mangaId == mangaId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, mangaId);

  @override
  String toString() {
    return 'MangaPageViewModel(mangaId: $mangaId)';
  }
}

/// @nodoc
abstract mixin class $MangaPageViewModelCopyWith<$Res> {
  factory $MangaPageViewModelCopyWith(
          MangaPageViewModel value, $Res Function(MangaPageViewModel) _then) =
      _$MangaPageViewModelCopyWithImpl;
  @useResult
  $Res call({MangaId? mangaId});
}

/// @nodoc
class _$MangaPageViewModelCopyWithImpl<$Res>
    implements $MangaPageViewModelCopyWith<$Res> {
  _$MangaPageViewModelCopyWithImpl(this._self, this._then);

  final MangaPageViewModel _self;
  final $Res Function(MangaPageViewModel) _then;

  /// Create a copy of MangaPageViewModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mangaId = freezed,
  }) {
    return _then(_self.copyWith(
      mangaId: freezed == mangaId
          ? _self.mangaId
          : mangaId // ignore: cast_nullable_to_non_nullable
              as MangaId?,
    ));
  }
}

/// @nodoc

class _MangaPageViewModel implements MangaPageViewModel {
  const _MangaPageViewModel({required this.mangaId});

  @override
  final MangaId? mangaId;

  /// Create a copy of MangaPageViewModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MangaPageViewModelCopyWith<_MangaPageViewModel> get copyWith =>
      __$MangaPageViewModelCopyWithImpl<_MangaPageViewModel>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MangaPageViewModel &&
            (identical(other.mangaId, mangaId) || other.mangaId == mangaId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, mangaId);

  @override
  String toString() {
    return 'MangaPageViewModel(mangaId: $mangaId)';
  }
}

/// @nodoc
abstract mixin class _$MangaPageViewModelCopyWith<$Res>
    implements $MangaPageViewModelCopyWith<$Res> {
  factory _$MangaPageViewModelCopyWith(
          _MangaPageViewModel value, $Res Function(_MangaPageViewModel) _then) =
      __$MangaPageViewModelCopyWithImpl;
  @override
  @useResult
  $Res call({MangaId? mangaId});
}

/// @nodoc
class __$MangaPageViewModelCopyWithImpl<$Res>
    implements _$MangaPageViewModelCopyWith<$Res> {
  __$MangaPageViewModelCopyWithImpl(this._self, this._then);

  final _MangaPageViewModel _self;
  final $Res Function(_MangaPageViewModel) _then;

  /// Create a copy of MangaPageViewModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? mangaId = freezed,
  }) {
    return _then(_MangaPageViewModel(
      mangaId: freezed == mangaId
          ? _self.mangaId
          : mangaId // ignore: cast_nullable_to_non_nullable
              as MangaId?,
    ));
  }
}

// dart format on
