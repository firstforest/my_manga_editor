import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Initialize Firebase and configure Firestore.
/// Call this once in main() before runApp().
Future<void> initializeFirebase({required FirebaseOptions options}) async {
  await Firebase.initializeApp(options: options);
  await configureFirestore();
}

/// Configure Firestore settings for offline persistence
Future<void> configureFirestore() async {
  final firestore = FirebaseFirestore.instance;

  // Configure offline persistence
  firestore.settings = Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
}
