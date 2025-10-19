import 'package:cloud_firestore/cloud_firestore.dart';

/// Configure Firestore settings for offline persistence
Future<void> configureFirestore() async {
  final firestore = FirebaseFirestore.instance;

  // Configure offline persistence
  firestore.settings = Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
}
