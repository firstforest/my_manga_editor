import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_config.freezed.dart';

/// アプリ全体のリモート設定 (ドメインモデル)。
@freezed
abstract class AppConfig with _$AppConfig {
  const factory AppConfig({
    /// この値より小さいビルド番号のクライアントは更新必須とみなす。
    required int minSupportedBuildNumber,

    /// 全利用者に見せるお知らせ。出していないときは null。
    AppNotice? notice,
  }) = _AppConfig;
}

/// アプリ内に表示するお知らせ。
/// リリース前の予告など、アプリのデプロイを待たずに伝えたいことに使う。
@freezed
abstract class AppNotice with _$AppNotice {
  const factory AppNotice({
    /// 利用者が「閉じた」状態を記録するための識別子。
    /// 本文を変えたらこの値も変える (再度表示させるため)。
    required String id,

    /// 表示する本文。
    required String message,
  }) = _AppNotice;
}
