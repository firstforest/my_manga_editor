import 'package:web/web.dart' as web;

/// ブラウザのページを再読み込みし、配信済みの最新ビルドを取得し直す。
void reloadApp() => web.window.location.reload();
