import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cloud_app_config.freezed.dart';
part 'cloud_app_config.g.dart';

/// アプリ全体のリモート設定。`config/app` ドキュメントに格納する。
/// ユーザーに依存しないグローバル設定のため、`users/{uid}` 配下ではない。
@freezed
abstract class CloudAppConfig with _$CloudAppConfig {
  const factory CloudAppConfig({
    /// この値より小さいビルド番号のクライアントは更新必須とみなす。
    required int minSupportedBuildNumber,
  }) = _CloudAppConfig;

  factory CloudAppConfig.fromJson(Map<String, dynamic> json) =>
      _$CloudAppConfigFromJson(json);
}

extension CloudAppConfigExt on CloudAppConfig {
  /// 現行スキーマバージョン。
  /// スキーマ変更時はインクリメントし、fromFirestore に移行ステップを追記する。
  /// 過去の移行ステップは編集しない (.claude/rules/data-layer.md 参照)。
  static const schemaVersion = 1;

  /// Convert Firestore DocumentSnapshot to CloudAppConfig
  static CloudAppConfig fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    // schemaVersion は現在 v1 のみ (なし = v1)。
    // バージョン追加時はここに単方向アップグレードチェーンを追記する。
    return CloudAppConfig(
      minSupportedBuildNumber: (data['minSupportedBuildNumber'] as num?)?.toInt() ?? 0,
    );
  }
}
