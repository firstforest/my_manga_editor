import 'package:flutter/material.dart';

/// 起動直後、認証状態が確定するまでの待機画面 (`/`)。
///
/// `/` は router の redirect が行き先を決めるまでの中継地点で、
/// 確定すると `/login` か `/manga` へ飛ぶ。
/// このルートが無いと、認証状態のロード中に「Page Not Found」が見えてしまう
/// (Flutter Web の hash 戦略では、ルート URL を開いたときのロケーションが `/` になる)。
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
