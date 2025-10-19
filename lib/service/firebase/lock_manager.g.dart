// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lock_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages edit locks for manga documents to prevent concurrent modifications

@ProviderFor(lockManager)
const lockManagerProvider = LockManagerProvider._();

/// Manages edit locks for manga documents to prevent concurrent modifications

final class LockManagerProvider
    extends $FunctionalProvider<LockManager, LockManager, LockManager>
    with $Provider<LockManager> {
  /// Manages edit locks for manga documents to prevent concurrent modifications
  const LockManagerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'lockManagerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$lockManagerHash();

  @$internal
  @override
  $ProviderElement<LockManager> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LockManager create(Ref ref) {
    return lockManager(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LockManager value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LockManager>(value),
    );
  }
}

String _$lockManagerHash() => r'8617dd1bfc5f867fc4f1d9f9e25a5e00807bca56';
