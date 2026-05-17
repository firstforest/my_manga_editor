import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_service.g.dart';

/// 接続状態の取得・購読を担うサービス。
/// `connectivity_plus` をラップし、Repository 等から DI 可能にする。
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// 現在の接続状態を一度だけ取得する。
  /// `ConnectivityResult.none` のみの場合は `false`。
  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// 接続状態の変化を bool で流す Stream。
  /// `true` = オンライン、`false` = オフライン。
  Stream<bool> onConnectivityChanged() {
    return _connectivity.onConnectivityChanged
        .map((result) => !result.contains(ConnectivityResult.none));
  }
}

@Riverpod(keepAlive: true)
ConnectivityService connectivityService(Ref ref) {
  return ConnectivityService();
}
