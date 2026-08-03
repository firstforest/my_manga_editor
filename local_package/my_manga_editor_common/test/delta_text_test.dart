import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_manga_editor_common/delta_text.dart';

void main() {
  group('deltaToPlainText', () {
    test('3 連続以上の改行が 2 連続改行に圧縮される', () {
      final delta = Delta()..insert('A\n\n\n\nB\n');

      final text = deltaToPlainText(delta);

      expect(text, 'A\n\nB');
      expect(text, isNot(contains('\n\n\n')));
    });

    test('装飾付き Delta から装飾が落ちて本文のみ抽出される', () {
      final delta = Delta()
        ..insert('Bold', {'bold': true})
        ..insert(' and ')
        ..insert('italic', {'italic': true})
        ..insert('\n');

      expect(deltaToPlainText(delta), 'Bold and italic');
    });

    test('空 Delta では空文字列を返す', () {
      expect(deltaToPlainText(Delta()), '');
    });

    test('先頭末尾の空白が trim される', () {
      final delta = Delta()..insert('   \n\nセリフ本文\n\n   \n');

      expect(deltaToPlainText(delta), 'セリフ本文');
    });

    test('文字列以外の挿入 (埋め込み) は無視される', () {
      final delta = Delta()
        ..insert('前\n')
        ..insert({'image': 'https://example.com/a.png'})
        ..insert('後\n');

      expect(deltaToPlainText(delta), '前\n後');
    });

    test('複数の insert が順序を保って連結される', () {
      final delta = Delta()
        ..insert('1行目\n')
        ..insert('2行目\n')
        ..insert('3行目\n');

      expect(deltaToPlainText(delta), '1行目\n2行目\n3行目');
    });
  });
}
