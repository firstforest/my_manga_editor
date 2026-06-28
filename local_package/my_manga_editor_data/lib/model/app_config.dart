import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_config.freezed.dart';

/// アプリ全体のリモート設定 (ドメインモデル)。
@freezed
abstract class AppConfig with _$AppConfig {
  const factory AppConfig({
    /// この値より小さいビルド番号のクライアントは更新必須とみなす。
    required int minSupportedBuildNumber,
  }) = _AppConfig;
}
