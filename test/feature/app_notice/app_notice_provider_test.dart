import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/app_config/provider/app_config_provider.dart';
import 'package:my_manga_editor/feature/app_notice/provider/app_notice_provider.dart';
import 'package:my_manga_editor_data/my_manga_editor_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _notice = AppNotice(id: 'notice-1', message: '8/10 に更新します');

/// [notice] を配信し、[dismissed] を「閉じた記録」として持つコンテナを作る。
Future<ProviderContainer> _buildContainer({
  required AppNotice? notice,
  String? dismissed,
}) async {
  SharedPreferences.setMockInitialValues(
    dismissed == null ? {} : {'dismissedNoticeId': dismissed},
  );
  final container = ProviderContainer(
    overrides: [
      appConfigProvider.overrideWith(
        (ref) => Stream.value(
          AppConfig(minSupportedBuildNumber: 0, notice: notice),
        ),
      ),
    ],
  );
  addTearDown(container.dispose);

  // autoDispose の provider が読み取り直後に破棄されないようリスナーを張る。
  container.listen(visibleNoticeProvider, (_, __) {}, fireImmediately: true);
  await container.read(appConfigProvider.future);
  await container.read(dismissedNoticeIdProvider.future);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('visibleNoticeProvider', () {
    test('お知らせが設定されていて未読なら表示する', () async {
      final container = await _buildContainer(notice: _notice);
      expect(container.read(visibleNoticeProvider), _notice);
    });

    test('お知らせが設定されていなければ表示しない', () async {
      final container = await _buildContainer(notice: null);
      expect(container.read(visibleNoticeProvider), isNull);
    });

    test('同じ ID を閉じた記録があれば表示しない', () async {
      final container = await _buildContainer(
        notice: _notice,
        dismissed: 'notice-1',
      );
      expect(container.read(visibleNoticeProvider), isNull);
    });

    test('別の ID を閉じた記録があっても新しいお知らせは表示する', () async {
      final container = await _buildContainer(
        notice: _notice,
        dismissed: 'notice-0',
      );
      expect(container.read(visibleNoticeProvider), _notice);
    });

    test('閉じるとその場で表示されなくなり、記録が残る', () async {
      final container = await _buildContainer(notice: _notice);
      await container.read(dismissedNoticeIdProvider.notifier).dismiss('notice-1');

      expect(container.read(visibleNoticeProvider), isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('dismissedNoticeId'), 'notice-1');
    });
  });
}
