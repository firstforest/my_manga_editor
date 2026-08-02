import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/app_info/provider/app_info_provider.dart';
import 'package:my_manga_editor/feature/update_gate/provider/update_gate_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// [packageInfoProvider] だけを差し替えたコンテナを作る。
ProviderContainer _buildContainer({
  required String version,
  required String buildNumber,
}) {
  final container = ProviderContainer(
    overrides: [
      packageInfoProvider.overrideWith(
        (ref) async => PackageInfo(
          appName: 'my_manga_editor',
          packageName: 'com.example.my_manga_editor',
          version: version,
          buildNumber: buildNumber,
        ),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('appVersionLabelProvider', () {
    test('バージョン名とビルド番号を並べて表示する', () async {
      final container = _buildContainer(version: '1.2.3', buildNumber: '7');
      expect(
        await container.read(appVersionLabelProvider.future),
        '1.2.3 (build 7)',
      );
    });
  });

  group('currentBuildNumberProvider', () {
    test('PackageInfo のビルド番号を数値として返す', () async {
      final container = _buildContainer(version: '1.2.3', buildNumber: '7');
      expect(await container.read(currentBuildNumberProvider.future), 7);
    });

    test('ビルド番号が数値でなければ 0 を返す (ゲートを誤作動させない)', () async {
      final container = _buildContainer(version: '1.2.3', buildNumber: '');
      expect(await container.read(currentBuildNumberProvider.future), 0);
    });
  });
}
