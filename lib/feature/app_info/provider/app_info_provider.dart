import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_info_provider.g.dart';

/// 実行中クライアントの PackageInfo。
/// バージョン表示 ([appVersionLabel]) と更新ゲート (`currentBuildNumber`) が共有する。
@Riverpod(keepAlive: true)
Future<PackageInfo> packageInfo(Ref ref) => PackageInfo.fromPlatform();

/// 画面に出すバージョン表記。例: `1.0.1 (build 2)`
///
/// ビルド番号まで見せるのは、不具合報告を受けたときに
/// どのデプロイのコードかを一意に特定できるようにするため
/// (Web はブラウザキャッシュで旧ビルドが残ることがある)。
@Riverpod(keepAlive: true)
Future<String> appVersionLabel(Ref ref) async {
  final info = await ref.watch(packageInfoProvider.future);
  return '${info.version} (build ${info.buildNumber})';
}
