import 'dart:async';
import 'package:flutter_quill/quill_delta.dart';

/// In-memory cache for Delta objects keyed by Firestore Delta document ID
///
/// This cache stores Delta objects during editing and tracks pending sync state
/// for offline support. Keys are Firestore CloudDelta document IDs (strings).
class DeltaCache {
  final Map<String, Delta> _cache = {}; // firestoreDeltaId -> Delta
  final Map<String, StreamController<Delta?>> _controllers = {};
  final Set<String> _pendingSync = {}; // Delta IDs needing sync
  final Map<String, String> _deltaToMangaMap = {}; // firestoreDeltaId -> mangaId

  /// Store or update a Delta in cache
  ///
  /// [firestoreDeltaId] is the CloudDelta document ID in Firestore
  /// [mangaId] is the parent manga ID for sync operations
  /// Returns the firestoreDeltaId for chaining
  String storeDelta(String firestoreDeltaId, Delta delta, String mangaId) {
    _cache[firestoreDeltaId] = delta;
    _deltaToMangaMap[firestoreDeltaId] = mangaId;

    // Notify listeners
    if (_controllers.containsKey(firestoreDeltaId)) {
      _controllers[firestoreDeltaId]!.add(delta);
    }
    return firestoreDeltaId;
  }

  /// Get Delta by Firestore document ID
  Delta? getDelta(String firestoreDeltaId) => _cache[firestoreDeltaId];

  /// Get manga ID for a delta
  String? getMangaId(String firestoreDeltaId) => _deltaToMangaMap[firestoreDeltaId];

  /// Get reactive stream for Delta updates
  Stream<Delta?> getDeltaStream(String firestoreDeltaId) {
    if (!_controllers.containsKey(firestoreDeltaId)) {
      _controllers[firestoreDeltaId] = StreamController<Delta?>.broadcast();
      // Emit current value if exists
      _controllers[firestoreDeltaId]!.add(_cache[firestoreDeltaId]);
    }
    return _controllers[firestoreDeltaId]!.stream;
  }

  /// Update Delta and mark for sync if offline
  void updateDelta(String firestoreDeltaId, Delta delta) {
    _cache[firestoreDeltaId] = delta;
    _pendingSync.add(firestoreDeltaId);

    // Notify listeners
    if (_controllers.containsKey(firestoreDeltaId)) {
      _controllers[firestoreDeltaId]!.add(delta);
    }
  }

  /// Get all Delta IDs needing sync
  List<String> getDeltasNeedingSync() => _pendingSync.toList();

  /// Mark Delta as synced
  void markSynced(String firestoreDeltaId) {
    _pendingSync.remove(firestoreDeltaId);
  }

  /// Mark Delta for sync
  void markForSync(String firestoreDeltaId) {
    _pendingSync.add(firestoreDeltaId);
  }

  /// Clear all cached deltas and pending sync state
  void clearCache() {
    _cache.clear();
    _pendingSync.clear();
    _deltaToMangaMap.clear();
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }

  /// Dispose of all resources
  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
}
