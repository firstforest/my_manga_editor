// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'manga_page_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MangaPageViewModel {
  Manga get manga => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MangaPageViewModelCopyWith<MangaPageViewModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MangaPageViewModelCopyWith<$Res> {
  factory $MangaPageViewModelCopyWith(
          MangaPageViewModel value, $Res Function(MangaPageViewModel) then) =
      _$MangaPageViewModelCopyWithImpl<$Res, MangaPageViewModel>;
  @useResult
  $Res call({Manga manga});

  $MangaCopyWith<$Res> get manga;
}

/// @nodoc
class _$MangaPageViewModelCopyWithImpl<$Res, $Val extends MangaPageViewModel>
    implements $MangaPageViewModelCopyWith<$Res> {
  _$MangaPageViewModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? manga = null,
  }) {
    return _then(_value.copyWith(
      manga: null == manga
          ? _value.manga
          : manga // ignore: cast_nullable_to_non_nullable
              as Manga,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MangaCopyWith<$Res> get manga {
    return $MangaCopyWith<$Res>(_value.manga, (value) {
      return _then(_value.copyWith(manga: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MangaPageViewModelImplCopyWith<$Res>
    implements $MangaPageViewModelCopyWith<$Res> {
  factory _$$MangaPageViewModelImplCopyWith(_$MangaPageViewModelImpl value,
          $Res Function(_$MangaPageViewModelImpl) then) =
      __$$MangaPageViewModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Manga manga});

  @override
  $MangaCopyWith<$Res> get manga;
}

/// @nodoc
class __$$MangaPageViewModelImplCopyWithImpl<$Res>
    extends _$MangaPageViewModelCopyWithImpl<$Res, _$MangaPageViewModelImpl>
    implements _$$MangaPageViewModelImplCopyWith<$Res> {
  __$$MangaPageViewModelImplCopyWithImpl(_$MangaPageViewModelImpl _value,
      $Res Function(_$MangaPageViewModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? manga = null,
  }) {
    return _then(_$MangaPageViewModelImpl(
      manga: null == manga
          ? _value.manga
          : manga // ignore: cast_nullable_to_non_nullable
              as Manga,
    ));
  }
}

/// @nodoc

class _$MangaPageViewModelImpl implements _MangaPageViewModel {
  const _$MangaPageViewModelImpl({required this.manga});

  @override
  final Manga manga;

  @override
  String toString() {
    return 'MangaPageViewModel(manga: $manga)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MangaPageViewModelImpl &&
            (identical(other.manga, manga) || other.manga == manga));
  }

  @override
  int get hashCode => Object.hash(runtimeType, manga);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MangaPageViewModelImplCopyWith<_$MangaPageViewModelImpl> get copyWith =>
      __$$MangaPageViewModelImplCopyWithImpl<_$MangaPageViewModelImpl>(
          this, _$identity);
}

abstract class _MangaPageViewModel implements MangaPageViewModel {
  const factory _MangaPageViewModel({required final Manga manga}) =
      _$MangaPageViewModelImpl;

  @override
  Manga get manga;
  @override
  @JsonKey(ignore: true)
  _$$MangaPageViewModelImplCopyWith<_$MangaPageViewModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
