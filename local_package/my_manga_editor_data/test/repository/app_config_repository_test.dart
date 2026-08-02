import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_manga_editor_data/model/app_config.dart';
import 'package:my_manga_editor_data/repository/app_config_repository.dart';
import 'package:my_manga_editor_data/service/firebase/firebase_service.dart';
import 'package:my_manga_editor_data/service/firebase/model/cloud_app_config.dart';

@GenerateNiceMocks([MockSpec<FirebaseService>()])
import 'app_config_repository_test.mocks.dart';

/// [cloud] を 1 件だけ流す FirebaseService を差し込み、変換結果を取り出す。
Future<AppConfig?> _mapped(CloudAppConfig? cloud) {
  final service = MockFirebaseService();
  when(service.watchAppConfig()).thenAnswer((_) => Stream.value(cloud));
  return AppConfigRepository(firebaseService: service).watchAppConfig().first;
}

CloudAppConfig _cloud({String message = '', String id = ''}) => CloudAppConfig(
      minSupportedBuildNumber: 3,
      noticeMessage: message,
      noticeId: id,
    );

void main() {
  group('watchAppConfig のお知らせ変換', () {
    test('本文と ID が揃っていればお知らせとして流す', () async {
      final config = await _mapped(
        _cloud(message: '8/10 に更新します', id: '2026-08-02T10:00:00.000Z'),
      );

      expect(config?.minSupportedBuildNumber, 3);
      expect(
        config?.notice,
        const AppNotice(
          id: '2026-08-02T10:00:00.000Z',
          message: '8/10 に更新します',
        ),
      );
    });

    // 片方だけ書かれた状態で出すと、ID が無いので「閉じる」を押しても消えない
    // (閉じた記録は ID で持つ) お知らせが居座ることになる。
    test('本文だけの中途半端な状態では出さない', () async {
      final config = await _mapped(_cloud(message: '8/10 に更新します'));

      expect(config?.notice, isNull);
    });

    test('ID だけの中途半端な状態では出さない', () async {
      final config = await _mapped(_cloud(id: '2026-08-02T10:00:00.000Z'));

      expect(config?.notice, isNull);
    });

    test('どちらも空ならお知らせなし (notice-clear した状態)', () async {
      final config = await _mapped(_cloud());

      expect(config?.minSupportedBuildNumber, 3);
      expect(config?.notice, isNull);
    });

    test('設定ドキュメントが無ければ null を流す (呼び出し側で fail-open)', () async {
      expect(await _mapped(null), isNull);
    });
  });
}
