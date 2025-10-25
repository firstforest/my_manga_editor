// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_state_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing sync state and queue
/// NOTE: This is a stub implementation for Firebase-only persistence
/// Full sync functionality will be implemented in User Story 2

@ProviderFor(SyncStateNotifier)
const syncStateProvider = SyncStateNotifierProvider._();

/// Notifier for managing sync state and queue
/// NOTE: This is a stub implementation for Firebase-only persistence
/// Full sync functionality will be implemented in User Story 2
final class SyncStateNotifierProvider
    extends $NotifierProvider<SyncStateNotifier, SyncStatus> {
  /// Notifier for managing sync state and queue
  /// NOTE: This is a stub implementation for Firebase-only persistence
  /// Full sync functionality will be implemented in User Story 2
  const SyncStateNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'syncStateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$syncStateNotifierHash();

  @$internal
  @override
  SyncStateNotifier create() => SyncStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncStatus>(value),
    );
  }
}

String _$syncStateNotifierHash() => r'548f93222e1d7c76a6095360bad43d7ab30939ad';

/// Notifier for managing sync state and queue
/// NOTE: This is a stub implementation for Firebase-only persistence
/// Full sync functionality will be implemented in User Story 2

abstract class _$SyncStateNotifier extends $Notifier<SyncStatus> {
  SyncStatus build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SyncStatus, SyncStatus>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SyncStatus, SyncStatus>, SyncStatus, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

/// Provider for getting sync status of a specific manga
/// Returns null if manga is not in sync queue

@ProviderFor(mangaSyncStatus)
const mangaSyncStatusProvider = MangaSyncStatusFamily._();

/// Provider for getting sync status of a specific manga
/// Returns null if manga is not in sync queue

final class MangaSyncStatusProvider
    extends $FunctionalProvider<SyncStatus?, SyncStatus?, SyncStatus?>
    with $Provider<SyncStatus?> {
  /// Provider for getting sync status of a specific manga
  /// Returns null if manga is not in sync queue
  const MangaSyncStatusProvider._(
      {required MangaSyncStatusFamily super.from,
      required MangaId super.argument})
      : super(
          retry: null,
          name: r'mangaSyncStatusProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mangaSyncStatusHash();

  @override
  String toString() {
    return r'mangaSyncStatusProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<SyncStatus?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncStatus? create(Ref ref) {
    final argument = this.argument as MangaId;
    return mangaSyncStatus(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncStatus? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncStatus?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MangaSyncStatusProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mangaSyncStatusHash() => r'4b0b56c84d6291a242facabbb8a231f6b8d66916';

/// Provider for getting sync status of a specific manga
/// Returns null if manga is not in sync queue

final class MangaSyncStatusFamily extends $Family
    with $FunctionalFamilyOverride<SyncStatus?, MangaId> {
  const MangaSyncStatusFamily._()
      : super(
          retry: null,
          name: r'mangaSyncStatusProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for getting sync status of a specific manga
  /// Returns null if manga is not in sync queue

  MangaSyncStatusProvider call(
    MangaId mangaId,
  ) =>
      MangaSyncStatusProvider._(argument: mangaId, from: this);

  @override
  String toString() => r'mangaSyncStatusProvider';
}
