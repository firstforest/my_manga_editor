import 'package:my_manga_editor_data/model/app_config.dart';
import 'package:my_manga_editor_data/service/firebase/firebase_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_config_repository.g.dart';

/// アプリ全体のリモート設定 (`config/app`) を扱う Repository。
/// UI とデータ層の橋渡しを行い、Cloud モデルをドメインモデルへ変換する。
class AppConfigRepository {
  AppConfigRepository({required FirebaseService firebaseService})
      : _firebaseService = firebaseService;

  final FirebaseService _firebaseService;

  /// リモート設定を購読する。
  /// ドキュメント未設定や読み取り失敗時は null を流す（呼び出し側で fail-open する）。
  Stream<AppConfig?> watchAppConfig() {
    return _firebaseService.watchAppConfig().map(
          (cloud) => cloud == null
              ? null
              : AppConfig(minSupportedBuildNumber: cloud.minSupportedBuildNumber),
        );
  }
}

/// Provider for AppConfigRepository
@Riverpod(keepAlive: true)
AppConfigRepository appConfigRepository(Ref ref) {
  return AppConfigRepository(
    firebaseService: ref.watch(firebaseServiceProvider),
  );
}
