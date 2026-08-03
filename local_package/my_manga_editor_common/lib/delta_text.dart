import 'package:dart_quill_delta/dart_quill_delta.dart';

/// Quill の [Delta] から書き出し用のプレーンテキストを取り出す。
///
/// UI 層 (セリフのコピー) とデータ層 (作品全体の Markdown 書き出し) の
/// 両方から呼ばれる唯一の変換ロジック。
///
/// - `op.data` が String の挿入だけを順に連結する (装飾・埋め込みは捨てる)
/// - 3 連続以上の改行は 2 連続改行に圧縮する (Delta の構造上できる空行を整える)
/// - 先頭末尾を trim する
String deltaToPlainText(Delta delta) {
  final buffer = StringBuffer();
  for (final op in delta.toList()) {
    final data = op.data;
    if (data is String) {
      buffer.write(data);
    }
  }
  return buffer.toString().replaceAll(RegExp(r'\n\s*\n\s*\n\s*'), '\n\n').trim();
}
