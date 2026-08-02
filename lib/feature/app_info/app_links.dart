/// アプリから開く外部リンク。README の「不具合報告・お問い合わせ」節と同じ場所を指す。
abstract final class AppLinks {
  /// 更新履歴。リリースごとの変更点 (CHANGELOG.md の内容が公開される)
  static const releaseNotes =
      'https://github.com/firstforest/my_manga_editor/releases';

  /// 不具合報告・要望の受け付け先
  static const issues = 'https://github.com/firstforest/my_manga_editor/issues';

  /// GitHub アカウントを持たない利用者向けの連絡先
  static const x = 'https://x.com/firstforest';

  /// [x] の表示用アカウント名
  static const xAccount = '@firstforest';

  /// ソースコード
  static const repository = 'https://github.com/firstforest/my_manga_editor';
}
