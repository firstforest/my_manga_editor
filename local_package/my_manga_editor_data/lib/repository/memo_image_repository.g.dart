// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo_image_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(memoImageRepository)
final memoImageRepositoryProvider = MemoImageRepositoryProvider._();

final class MemoImageRepositoryProvider extends $FunctionalProvider<
    MemoImageRepository,
    MemoImageRepository,
    MemoImageRepository> with $Provider<MemoImageRepository> {
  MemoImageRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'memoImageRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$memoImageRepositoryHash();

  @$internal
  @override
  $ProviderElement<MemoImageRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MemoImageRepository create(Ref ref) {
    return memoImageRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemoImageRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemoImageRepository>(value),
    );
  }
}

String _$memoImageRepositoryHash() =>
    r'95d1067f891dbbd65910d182a11e340d9a171c4f';
