// プラットフォームごとの再読み込み実装を選ぶ。
// Web だけがブラウザのリロードを持ち、デスクトップでは何もしない。
export 'app_reload_stub.dart'
    if (dart.library.js_interop) 'app_reload_web.dart';
