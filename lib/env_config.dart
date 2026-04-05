import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart' as prod;
import 'firebase_options_dev.dart' as dev;

const _env = String.fromEnvironment('ENV', defaultValue: 'dev');

class EnvConfig {
  const EnvConfig._({
    required this.firebaseOptions,
    required this.webClientId,
  });

  final FirebaseOptions firebaseOptions;
  final String? webClientId;

  static const _prod = EnvConfig._(
    firebaseOptions: prod.DefaultFirebaseOptions.web, // replaced at runtime
    webClientId:
        '948924085739-adqjuonj6bf2le0kscqisgoptfjhbm1l.apps.googleusercontent.com',
  );

  static const _dev = EnvConfig._(
    firebaseOptions: dev.DefaultFirebaseOptions.web, // replaced at runtime
    webClientId:
        '411539508745-cvecht9c5v0iohf0e38a2j61mde9tgqb.apps.googleusercontent.com',
  );

  static EnvConfig get current => switch (_env) {
        'prod' => _prod
            ._withPlatformOptions(prod.DefaultFirebaseOptions.currentPlatform),
        _ =>
          _dev._withPlatformOptions(dev.DefaultFirebaseOptions.currentPlatform),
      };

  EnvConfig _withPlatformOptions(FirebaseOptions options) {
    return EnvConfig._(
      firebaseOptions: options,
      webClientId: webClientId,
    );
  }
}
