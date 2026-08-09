import 'package:dart_quill_delta/dart_quill_delta.dart';

/// Quill の [Delta] から書き出し用のプレーンテキストを取り出す。
///
/// UI 層 (セリフのコピー) とデータ層 (作品全体の Markdown 書き出し) の
/// 両方から呼ばれる唯一の変換ロジック。
///
/// - `op.data` が String の挿入だけを順に連結する (装飾・埋め込みは捨てる)
/// - 空行が 2 行以上続く箇所は空行 1 行に詰める (Delta の構造上できる空行を整える)
/// - 先頭・末尾の空行を落とす
///
/// 行頭の字下げは残す。日本語の原稿は全角スペース (U+3000) で字下げすることがあり、
/// `\s` や [String.trim] はこれを空白として扱うため、消さないよう明示的に避けている。
String deltaToPlainText(Delta delta) {
  final buffer = StringBuffer();
  for (final op in delta.toList()) {
    final data = op.data;
    if (data is String) {
      buffer.write(data);
    }
  }
  // `[^\S\n]` = 改行以外の空白。改行の直後の空白を食べないので字下げが残る
  return buffer
      .toString()
      .replaceAll(RegExp(r'\n(?:[^\S\n]*\n){2,}'), '\n\n')
      .replaceFirst(RegExp(r'^(?:[^\S\n]*\n)+'), '')
      .replaceFirst(RegExp(r'\s+$'), '');
}
