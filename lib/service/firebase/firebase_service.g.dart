// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for FirebaseFirestore instance

@ProviderFor(firebaseFirestore)
const firebaseFirestoreProvider = FirebaseFirestoreProvider._();

/// Provider for FirebaseFirestore instance

final class FirebaseFirestoreProvider extends $FunctionalProvider<
    FirebaseFirestore,
    FirebaseFirestore,
    FirebaseFirestore> with $Provider<FirebaseFirestore> {
  /// Provider for FirebaseFirestore instance
  const FirebaseFirestoreProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'firebaseFirestoreProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$firebaseFirestoreHash();

  @$internal
  @override
  $ProviderElement<FirebaseFirestore> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FirebaseFirestore create(Ref ref) {
    return firebaseFirestore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseFirestore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseFirestore>(value),
    );
  }
}

String _$firebaseFirestoreHash() => r'963402713bf9b7cc1fb259d619d9b0184d4dcec1';

/// Provider for FirebaseService

@ProviderFor(firebaseService)
const firebaseServiceProvider = FirebaseServiceProvider._();

/// Provider for FirebaseService

final class FirebaseServiceProvider extends $FunctionalProvider<FirebaseService,
    FirebaseService, FirebaseService> with $Provider<FirebaseService> {
  /// Provider for FirebaseService
  const FirebaseServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'firebaseServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$firebaseServiceHash();

  @$internal
  @override
  $ProviderElement<FirebaseService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FirebaseService create(Ref ref) {
    return firebaseService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseService>(value),
    );
  }
}

String _$firebaseServiceHash() => r'7d0641d1b97027647a1a19481b9318455e7748f4';
