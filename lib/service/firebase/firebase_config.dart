import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Configure Firestore settings for offline persistence
Future<void> configureFirestore() async {
  final firestore = FirebaseFirestore.instance;

  // Configure offline persistence
  if (kIsWeb) {
    // Web requires explicit enabling
    await firestore.enablePersistence(
      const PersistenceSettings(synchronizeTabs: true),
    );
  } else {
    // Mobile/Desktop: already enabled by default, configure cache size
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
}
