import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/app_info/provider/app_info_provider.dart';
import 'package:my_manga_editor/feature/app_info/view/app_info_dialog.dart';
import 'package:my_manga_editor/feature/update_gate/page/update_required_page.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        packageInfoProvider.overrideWith(
          (ref) async => PackageInfo(
            appName: 'my_manga_editor',
            packageName: 'com.example.my_manga_editor',
            version: '1.2.3',
            buildNumber: '7',
          ),
        ),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('アプリ情報ダイアログにバージョンと問い合わせ先が出る', (tester) async {
    await _pump(tester, const AppInfoDialog());

    // 不具合報告を受けたときにビルドまで特定できるよう、build 番号まで見せる
    expect(find.text('バージョン 1.2.3 (build 7)'), findsOneWidget);
    expect(find.text('更新履歴'), findsOneWidget);
    expect(find.text('不具合報告・ご要望'), findsOneWidget);
    expect(find.text('閉じる'), findsOneWidget);
  });

  testWidgets('更新案内から更新履歴と問い合わせ先へ辿れる', (tester) async {
    await _pump(tester, const UpdateRequiredPage());

    expect(find.text('更新が必要です'), findsOneWidget);
    expect(find.text('更新内容を見る'), findsOneWidget);
    expect(find.text('不具合報告・ご要望'), findsOneWidget);
    // 再読み込みボタンは Web 限定。テストは VM 実行なので出ない
    expect(find.text('再読み込み'), findsNothing);
  });
}
