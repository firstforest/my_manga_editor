import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:my_manga_editor_data/my_manga_editor_data.dart';

part 'app_config_provider.g.dart';

/// リモートのアプリ設定 (`config/app`) を購読する。
/// 未設定・読み取り失敗時は null を流す。
///
/// Firestore の stream なので、アプリを再デプロイしなくても
/// 設定変更が起動中のクライアントへその場で届く。
/// 更新ゲート (`updateRequired`) とアプリ内お知らせ (`visibleNotice`) が共有する。
@riverpod
Stream<AppConfig?> appConfig(Ref ref) {
  return ref.watch(appConfigRepositoryProvider).watchAppConfig();
}
