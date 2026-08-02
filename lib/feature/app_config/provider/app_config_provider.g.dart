// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// リモートのアプリ設定 (`config/app`) を購読する。
/// 未設定・読み取り失敗時は null を流す。
///
/// Firestore の stream なので、アプリを再デプロイしなくても
/// 設定変更が起動中のクライアントへその場で届く。
/// 更新ゲート (`updateRequired`) とアプリ内お知らせ (`visibleNotice`) が共有する。

@ProviderFor(appConfig)
final appConfigProvider = AppConfigProvider._();

/// リモートのアプリ設定 (`config/app`) を購読する。
/// 未設定・読み取り失敗時は null を流す。
///
/// Firestore の stream なので、アプリを再デプロイしなくても
/// 設定変更が起動中のクライアントへその場で届く。
/// 更新ゲート (`updateRequired`) とアプリ内お知らせ (`visibleNotice`) が共有する。

final class AppConfigProvider extends $FunctionalProvider<
        AsyncValue<AppConfig?>, AppConfig?, Stream<AppConfig?>>
    with $FutureModifier<AppConfig?>, $StreamProvider<AppConfig?> {
  /// リモートのアプリ設定 (`config/app`) を購読する。
  /// 未設定・読み取り失敗時は null を流す。
  ///
  /// Firestore の stream なので、アプリを再デプロイしなくても
  /// 設定変更が起動中のクライアントへその場で届く。
  /// 更新ゲート (`updateRequired`) とアプリ内お知らせ (`visibleNotice`) が共有する。
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
