// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo_image_storage_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(memoImageStorageService)
final memoImageStorageServiceProvider = MemoImageStorageServiceProvider._();

final class MemoImageStorageServiceProvider extends $FunctionalProvider<
    MemoImageStorageService,
    MemoImageStorageService,
    MemoImageStorageService> with $Provider<MemoImageStorageService> {
  MemoImageStorageServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'memoImageStorageServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$memoImageStorageServiceHash();

  @$internal
  @override
  $ProviderElement<MemoImageStorageService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MemoImageStorageService create(Ref ref) {
    return memoImageStorageService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemoImageStorageService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemoImageStorageService>(value),
    );
  }
}

String _$memoImageStorageServiceHash() =>
    r'b7b17a1d34ed2ed56eababb753ee0eda7d897b44';
