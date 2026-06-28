// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for AppConfigRepository

@ProviderFor(appConfigRepository)
final appConfigRepositoryProvider = AppConfigRepositoryProvider._();

/// Provider for AppConfigRepository

final class AppConfigRepositoryProvider extends $FunctionalProvider<
    AppConfigRepository,
    AppConfigRepository,
    AppConfigRepository> with $Provider<AppConfigRepository> {
  /// Provider for AppConfigRepository
  AppConfigRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appConfigRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appConfigRepositoryHash();

  @$internal
  @override
  $ProviderElement<AppConfigRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppConfigRepository create(Ref ref) {
    return appConfigRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppConfigRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppConfigRepository>(value),
    );
  }
}

String _$appConfigRepositoryHash() =>
    r'cf629094e28791aee2e1149476c4df746c500898';
