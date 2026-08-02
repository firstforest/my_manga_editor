import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/app_config/provider/app_config_provider.dart';
import 'package:my_manga_editor/feature/app_notice/view/app_notice_banner.dart';
import 'package:my_manga_editor_data/my_manga_editor_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _message = '8/10 20時ごろに更新します';

/// 本番と同じ設置場所 (`MaterialApp.builder`) で組む。
/// Scaffold の中に置いてしまうと、画面を問わず出るという性質も、
/// バナーが画面を押し下げる挙動も検証したことにならない。
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
      child: MaterialApp(
        builder: (context, child) =>
            AppNoticeScope(child: child ?? const SizedBox.shrink()),
        home: const Scaffold(body: Center(child: Text('本文'))),
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

  testWidgets('バナーは下の画面を押し下げる (重ねて隠さない)', (tester) async {
    await _pump(
      tester,
      notice: const AppNotice(id: 'notice-1', message: _message),
    );

    final bannerBottom = tester.getBottomLeft(find.byType(AppNoticeBanner)).dy;
    final contentTop = tester.getTopLeft(find.text('本文')).dy;

    expect(bannerBottom, greaterThan(0));
    expect(contentTop, greaterThanOrEqualTo(bannerBottom));
  });

  testWidgets('長い本文でも切り捨てない (収まらない分はスクロールして読む)', (tester) async {
    // 上限 (scripts/config.mjs の NOTICE_MAX_LENGTH) いっぱいの本文
    final longMessage = 'あ' * 150;
    await _pump(
      tester,
      notice: AppNotice(id: 'notice-1', message: longMessage),
    );

    final text = tester.widget<Text>(find.text(longMessage));
    // maxLines + ellipsis で切ると、告知の一番伝えたい後半が黙って消える
    expect(text.maxLines, isNull);
    expect(text.overflow, isNot(TextOverflow.ellipsis));
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
