// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_gate_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 実行中クライアントのビルド番号 (pubspec の `version: x.y.z+N` の N)。
/// 取得失敗時は 0 を返し、ゲートが誤作動しないようにする。

@ProviderFor(currentBuildNumber)
final currentBuildNumberProvider = CurrentBuildNumberProvider._();

/// 実行中クライアントのビルド番号 (pubspec の `version: x.y.z+N` の N)。
/// 取得失敗時は 0 を返し、ゲートが誤作動しないようにする。

final class CurrentBuildNumberProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// 実行中クライアントのビルド番号 (pubspec の `version: x.y.z+N` の N)。
  /// 取得失敗時は 0 を返し、ゲートが誤作動しないようにする。
  CurrentBuildNumberProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentBuildNumberProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentBuildNumberHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return currentBuildNumber(ref);
  }
}

String _$currentBuildNumberHash() =>
    r'93ed4d635c9b465142bd46905fbaad45916a5eaf';

/// リモートのアプリ設定 (`config/app`) を購読する。
/// 未設定・読み取り失敗時は null を流す。

@ProviderFor(appConfig)
final appConfigProvider = AppConfigProvider._();

/// リモートのアプリ設定 (`config/app`) を購読する。
/// 未設定・読み取り失敗時は null を流す。

final class AppConfigProvider extends $FunctionalProvider<
        AsyncValue<AppConfig?>, AppConfig?, Stream<AppConfig?>>
    with $FutureModifier<AppConfig?>, $StreamProvider<AppConfig?> {
  /// リモートのアプリ設定 (`config/app`) を購読する。
  /// 未設定・読み取り失敗時は null を流す。
  AppConfigProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appConfigProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appConfigHash();

  @$internal
  @override
  $StreamProviderElement<AppConfig?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AppConfig?> create(Ref ref) {
    return appConfig(ref);
  }
}

String _$appConfigHash() => r'8d065ca8746c878c95e1d9c02c9d5d0e792c5b1d';

/// このクライアントが更新必須かどうか。
///
/// `自ビルド番号 < minSupportedBuildNumber` のとき true。
/// ビルド番号未取得・設定ドキュメント未取得・読み取り失敗のいずれの場合も
/// false (fail-open) とし、設定不備でユーザーを締め出さない。

@ProviderFor(updateRequired)
final updateRequiredProvider = UpdateRequiredProvider._();

/// このクライアントが更新必須かどうか。
///
/// `自ビルド番号 < minSupportedBuildNumber` のとき true。
/// ビルド番号未取得・設定ドキュメント未取得・読み取り失敗のいずれの場合も
/// false (fail-open) とし、設定不備でユーザーを締め出さない。

final class UpdateRequiredProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// このクライアントが更新必須かどうか。
  ///
  /// `自ビルド番号 < minSupportedBuildNumber` のとき true。
  /// ビルド番号未取得・設定ドキュメント未取得・読み取り失敗のいずれの場合も
  /// false (fail-open) とし、設定不備でユーザーを締め出さない。
  UpdateRequiredProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'updateRequiredProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$updateRequiredHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return updateRequired(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$updateRequiredHash() => r'c754ceb564028df9e39ac60a380843140076f969';
