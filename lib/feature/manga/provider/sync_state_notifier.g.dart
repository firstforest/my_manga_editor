// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_state_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing sync state and queue
/// Handles periodic sync, retry logic, and sync status tracking

@ProviderFor(SyncStateNotifier)
const syncStateProvider = SyncStateNotifierProvider._();

/// Notifier for managing sync state and queue
/// Handles periodic sync, retry logic, and sync status tracking
final class SyncStateNotifierProvider
    extends $NotifierProvider<SyncStateNotifier, Map<MangaId, SyncStatus>> {
  /// Notifier for managing sync state and queue
  /// Handles periodic sync, retry logic, and sync status tracking
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
  Override overrideWithValue(Map<MangaId, SyncStatus> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<MangaId, SyncStatus>>(value),
    );
  }
}

String _$syncStateNotifierHash() => r'd9eff3d13d05814fa50536ed4d84ab0c2113f7d0';

/// Notifier for managing sync state and queue
/// Handles periodic sync, retry logic, and sync status tracking

abstract class _$SyncStateNotifier extends $Notifier<Map<MangaId, SyncStatus>> {
  Map<MangaId, SyncStatus> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<Map<MangaId, SyncStatus>, Map<MangaId, SyncStatus>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Map<MangaId, SyncStatus>, Map<MangaId, SyncStatus>>,
        Map<MangaId, SyncStatus>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

/// Provider for sync status of a specific manga

@ProviderFor(mangaSyncStatus)
const mangaSyncStatusProvider = MangaSyncStatusFamily._();

/// Provider for sync status of a specific manga

final class MangaSyncStatusProvider
    extends $FunctionalProvider<SyncStatus?, SyncStatus?, SyncStatus?>
    with $Provider<SyncStatus?> {
  /// Provider for sync status of a specific manga
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

String _$mangaSyncStatusHash() => r'816af98ad76ac15bd9dbf74de913d7602f7ca825';

/// Provider for sync status of a specific manga

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

  /// Provider for sync status of a specific manga

  MangaSyncStatusProvider call(
    MangaId mangaId,
  ) =>
      MangaSyncStatusProvider._(argument: mangaId, from: this);

  @override
  String toString() => r'mangaSyncStatusProvider';
}
