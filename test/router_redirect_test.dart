import 'package:flutter_test/flutter_test.dart';
import 'package:my_manga_editor/router.dart';

String? _redirect({
  required String location,
  bool needsUpdate = false,
  bool authLoading = false,
  bool isLoggedIn = false,
}) {
  return resolveRedirect(
    needsUpdate: needsUpdate,
    authLoading: authLoading,
    isLoggedIn: isLoggedIn,
    location: location,
  );
}

void main() {
  group('resolveRedirect', () {
    group('バージョンゲート (認証より優先)', () {
      test('更新が必要なら /update-required へ送る', () {
        expect(_redirect(location: '/manga', needsUpdate: true),
            '/update-required');
      });

      test('認証状態が未確定でも更新案内は出す', () {
        expect(
          _redirect(location: '/', needsUpdate: true, authLoading: true),
          '/update-required',
        );
      });

      test('すでに /update-required にいるなら留まる', () {
        expect(
          _redirect(location: '/update-required', needsUpdate: true),
          isNull,
        );
      });

      test('更新が不要になったら /update-required から出す', () {
        expect(_redirect(location: '/update-required'), '/');
      });
    });

    group('認証', () {
      test('確定するまでは / で待つ', () {
        expect(_redirect(location: '/', authLoading: true), isNull);
      });

      test('未ログインなら /login へ送る', () {
        expect(_redirect(location: '/'), '/login');
        expect(_redirect(location: '/manga'), '/login');
      });

      test('未ログインで /login にいるなら留まる', () {
        expect(_redirect(location: '/login'), isNull);
      });

      test('ログイン済みで /login にいるなら /manga へ送る', () {
        expect(_redirect(location: '/login', isLoggedIn: true), '/manga');
      });

      // `/` は SplashPage の中継地点。留めると永久ローディングになる
      test('ログイン済みで / に来たら /manga へ送る', () {
        expect(_redirect(location: '/', isLoggedIn: true), '/manga');
      });

      test('ログイン済みで通常の画面にいるなら留まる', () {
        expect(_redirect(location: '/manga', isLoggedIn: true), isNull);
        expect(_redirect(location: '/manga/abc', isLoggedIn: true), isNull);
      });
    });
  });
}
