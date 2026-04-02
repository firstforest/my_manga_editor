// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// SharedPreferencesのプロバイダー

@ProviderFor(sharedPreferences)
const sharedPreferencesProvider = SharedPreferencesProvider._();

/// SharedPreferencesのプロバイダー

final class SharedPreferencesProvider extends $FunctionalProvider<
        AsyncValue<SharedPreferences>,
        SharedPreferences,
        FutureOr<SharedPreferences>>
    with
        $FutureModifier<SharedPreferences>,
        $FutureProvider<SharedPreferences> {
  /// SharedPreferencesのプロバイダー
  const SharedPreferencesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sharedPreferencesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $FutureProviderElement<SharedPreferences> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SharedPreferences> create(Ref ref) {
    return sharedPreferences(ref);
  }
}

String _$sharedPreferencesHash() => r'd22b545aefe95500327f9dce52c645d746349271';

/// SettingRepositoryのプロバイダー

@ProviderFor(settingRepository)
const settingRepositoryProvider = SettingRepositoryProvider._();

/// SettingRepositoryのプロバイダー

final class SettingRepositoryProvider extends $FunctionalProvider<
    SettingRepository,
    SettingRepository,
    SettingRepository> with $Provider<SettingRepository> {
  /// SettingRepositoryのプロバイダー
  const SettingRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'settingRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$settingRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SettingRepository create(Ref ref) {
    return settingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingRepository>(value),
    );
  }
}

String _$settingRepositoryHash() => r'e24f289aa5e04dbc622fe53c79455ab7a49737c1';

/// OpenAI API Keyのストリームプロバイダー

@ProviderFor(OpenAiApiKey)
const openAiApiKeyProvider = OpenAiApiKeyProvider._();

/// OpenAI API Keyのストリームプロバイダー
final class OpenAiApiKeyProvider
    extends $NotifierProvider<OpenAiApiKey, String?> {
  /// OpenAI API Keyのストリームプロバイダー
  const OpenAiApiKeyProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'openAiApiKeyProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$openAiApiKeyHash();

  @$internal
  @override
  OpenAiApiKey create() => OpenAiApiKey();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$openAiApiKeyHash() => r'70e1293c096942832ee2787e2c5b98cb1cb3cb4a';

/// OpenAI API Keyのストリームプロバイダー

abstract class _$OpenAiApiKey extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String?, String?>, String?, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
