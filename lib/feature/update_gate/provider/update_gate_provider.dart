import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:my_manga_editor/feature/app_config/provider/app_config_provider.dart';
import 'package:my_manga_editor/feature/app_info/provider/app_info_provider.dart';

part 'update_gate_provider.g.dart';

/// 実行中クライアントのビルド番号 (pubspec の `version: x.y.z+N` の N)。
/// 取得失敗時は 0 を返し、ゲートが誤作動しないようにする。
@Riverpod(keepAlive: true)
Future<int> currentBuildNumber(Ref ref) async {
  final info = await ref.watch(packageInfoProvider.future);
  return int.tryParse(info.buildNumber) ?? 0;
}

/// このクライアントが更新必須かどうか。
///
/// `自ビルド番号 < minSupportedBuildNumber` のとき true。
/// ビルド番号未取得・設定ドキュメント未取得・読み取り失敗のいずれの場合も
/// false (fail-open) とし、設定不備でユーザーを締め出さない。
@riverpod
bool updateRequired(Ref ref) {
  final buildNumber = ref.watch(currentBuildNumberProvider).asData?.value;
  final config = ref.watch(appConfigProvider).asData?.value;
  if (buildNumber == null || config == null) {
    return false;
  }
  return buildNumber < config.minSupportedBuildNumber;
}
