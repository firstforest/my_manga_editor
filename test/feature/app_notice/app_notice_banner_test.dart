import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/app_config/provider/app_config_provider.dart';
import 'package:my_manga_editor/feature/app_notice/view/app_notice_banner.dart';
import 'package:my_manga_editor_data/my_manga_editor_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _message = '8/10 20時ごろに更新します';

Future<void> _pump(WidgetTester tester, {AppNotice? notice}) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWith(
          (ref) => Stream.value(
            AppConfig(minSupportedBuildNumber: 0, notice: notice),
          ),
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: AppNoticeScope(child: Center(child: Text('本文'))),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('お知らせがあればバナーを出し、閉じると消える', (tester) async {
    await _pump(
      tester,
      notice: const AppNotice(id: 'notice-1', message: _message),
    );

    expect(find.text(_message), findsOneWidget);
    // バナーを出しても下の画面は消えない
    expect(find.text('本文'), findsOneWidget);

    await tester.tap(find.text('閉じる'));
    await tester.pumpAndSettle();

    expect(find.text(_message), findsNothing);
    expect(find.text('本文'), findsOneWidget);
  });

  testWidgets('お知らせが無ければバナーの領域を取らない', (tester) async {
    await _pump(tester, notice: null);

    expect(find.text('閉じる'), findsNothing);
    expect(find.text('本文'), findsOneWidget);
  });
}
