import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/app_config/provider/app_config_provider.dart';
import 'package:my_manga_editor/feature/update_gate/provider/update_gate_provider.dart';
import 'package:my_manga_editor_data/my_manga_editor_data.dart';

/// updateRequiredProvider をテストするためのコンテナを構築する。
/// [buildNumber] が null のときはビルド番号未取得状態を、
/// [config] が null のときは設定ドキュメント未取得状態を再現する。
Future<ProviderContainer> _buildContainer({
  required int? buildNumber,
  required AppConfig? config,
}) async {
  final container = ProviderContainer(
    overrides: [
      if (buildNumber != null)
        currentBuildNumberProvider.overrideWith((ref) async => buildNumber),
      appConfigProvider.overrideWith((ref) => Stream.value(config)),
    ],
  );
  addTearDown(container.dispose);

  // autoDispose の provider が読み取り直後に破棄されないようリスナーを張る。
  container.listen(updateRequiredProvider, (_, __) {}, fireImmediately: true);

  if (buildNumber != null) {
    await container.read(currentBuildNumberProvider.future);
  }
  await container.read(appConfigProvider.future);
  return container;
}

void main() {
  group('updateRequiredProvider', () {
    test('自ビルド番号 < minSupportedBuildNumber なら更新必須', () async {
      final container = await _buildContainer(
        buildNumber: 5,
        config: const AppConfig(minSupportedBuildNumber: 10),
      );
      expect(container.read(updateRequiredProvider), isTrue);
    });

    test('自ビルド番号 == minSupportedBuildNumber なら更新不要', () async {
      final container = await _buildContainer(
        buildNumber: 10,
        config: const AppConfig(minSupportedBuildNumber: 10),
      );
      expect(container.read(updateRequiredProvider), isFalse);
    });

    test('自ビルド番号 > minSupportedBuildNumber なら更新不要', () async {
      final container = await _buildContainer(
        buildNumber: 11,
        config: const AppConfig(minSupportedBuildNumber: 10),
      );
      expect(container.read(updateRequiredProvider), isFalse);
    });

    test('設定ドキュメント未取得なら fail-open (更新不要)', () async {
      final container = await _buildContainer(
        buildNumber: 1,
        config: null,
      );
      expect(container.read(updateRequiredProvider), isFalse);
    });

    test('ビルド番号未取得 (loading) なら fail-open (更新不要)', () async {
      final container = await _buildContainer(
        buildNumber: null,
        config: const AppConfig(minSupportedBuildNumber: 10),
      );
      expect(container.read(updateRequiredProvider), isFalse);
    });
  });
}
