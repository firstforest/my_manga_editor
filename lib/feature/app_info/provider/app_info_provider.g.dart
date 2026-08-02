// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 実行中クライアントの PackageInfo。
/// バージョン表示 ([appVersionLabel]) と更新ゲート (`currentBuildNumber`) が共有する。

@ProviderFor(packageInfo)
final packageInfoProvider = PackageInfoProvider._();

/// 実行中クライアントの PackageInfo。
/// バージョン表示 ([appVersionLabel]) と更新ゲート (`currentBuildNumber`) が共有する。

final class PackageInfoProvider extends $FunctionalProvider<
        AsyncValue<PackageInfo>, PackageInfo, FutureOr<PackageInfo>>
    with $FutureModifier<PackageInfo>, $FutureProvider<PackageInfo> {
  /// 実行中クライアントの PackageInfo。
  /// バージョン表示 ([appVersionLabel]) と更新ゲート (`currentBuildNumber`) が共有する。
  PackageInfoProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'packageInfoProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$packageInfoHash();

  @$internal
  @override
  $FutureProviderElement<PackageInfo> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<PackageInfo> create(Ref ref) {
    return packageInfo(ref);
  }
}

String _$packageInfoHash() => r'854bbb0e381edfdddbd736229351d6cc918a2ad1';

/// 画面に出すバージョン表記。例: `1.0.1 (build 2)`
///
/// ビルド番号まで見せるのは、不具合報告を受けたときに
/// どのデプロイのコードかを一意に特定できるようにするため
/// (Web はブラウザキャッシュで旧ビルドが残ることがある)。

@ProviderFor(appVersionLabel)
final appVersionLabelProvider = AppVersionLabelProvider._();

/// 画面に出すバージョン表記。例: `1.0.1 (build 2)`
///
/// ビルド番号まで見せるのは、不具合報告を受けたときに
/// どのデプロイのコードかを一意に特定できるようにするため
/// (Web はブラウザキャッシュで旧ビルドが残ることがある)。

final class AppVersionLabelProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// 画面に出すバージョン表記。例: `1.0.1 (build 2)`
  ///
  /// ビルド番号まで見せるのは、不具合報告を受けたときに
  /// どのデプロイのコードかを一意に特定できるようにするため
  /// (Web はブラウザキャッシュで旧ビルドが残ることがある)。
  AppVersionLabelProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appVersionLabelProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appVersionLabelHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appVersionLabel(ref);
  }
}

String _$appVersionLabelHash() => r'c5b25c7d5e2c57ed1be5b0bc29b47f2c540142b0';
