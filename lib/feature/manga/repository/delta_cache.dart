import 'dart:async';
import 'package:flutter_quill/quill_delta.dart';
import 'package:my_manga_editor/feature/manga/model/manga.dart';

/// Metadata for tracking delta ownership and sync state
class DeltaMetadata {
  final DeltaId deltaId;
  final MangaId? mangaId;       // Parent manga ID (for ideaMemo or page deltas)
  final MangaPageId? pageId;     // Page ID (for page deltas like memoDelta, etc.)
  final String fieldName;        // 'ideaMemo', 'memoDelta', 'stageDirectionDelta', 'dialoguesDelta'
  String? firestoreDeltaId;      // Firestore document ID (set after sync)
  bool needsSync = false;

  DeltaMetadata({
    required this.deltaId,
    required this.fieldName,
    this.mangaId,
    this.pageId,
    this.firestoreDeltaId,
  });
}

/// In-memory cache for Delta objects referenced by DeltaId
///
/// This cache bridges between Firestore's separate delta storage (Cloud Deltas)
/// and the domain model's DeltaId reference pattern (int).
/// Also tracks delta metadata for cloud sync and Firestore ID mapping.
class DeltaCache {
  final Map<DeltaId, Delta> _cache = {};
  final Map<DeltaId, StreamController<Delta?>> _controllers = {};
  final Map<DeltaId, DeltaMetadata> _metadata = {};
  // Map from Firestore Delta ID to internal DeltaId for efficient lookups
  final Map<String, DeltaId> _firestoreIdToInternalId = {};
  DeltaId _nextId = DeltaId(1);

  /// Store a Delta and return its DeltaId
  ///
  /// The Delta is cached in memory and assigned an auto-incrementing integer ID.
  /// This ID can be used to retrieve the Delta later via [getDelta] or [getDeltaStream].
  /// Optional metadata tracks ownership for cloud sync.
  DeltaId storeDelta(Delta delta, {DeltaMetadata? metadata}) {
    final id = DeltaId(_nextId.id + 1);
    _cache[id] = delta;

    // Store metadata if provided
    if (metadata != null) {
      _metadata[id] = metadata;
    }

    // If there's an existing stream controller for this ID, emit the delta
    if (_controllers.containsKey(id)) {
      _controllers[id]!.add(delta);
    }
    return id;
  }

  /// Get Delta by DeltaId
  ///
  /// Returns the cached Delta if found, or null if the DeltaId doesn't exist.
  Delta? getDelta(DeltaId id) => _cache[id];

  /// Get reactive stream for Delta updates
  ///
  /// Returns a Stream that emits the current Delta and any future updates.
  /// The stream is created lazily and cached for each DeltaId.
  Stream<Delta?> getDeltaStream(DeltaId id) {
    if (!_controllers.containsKey(id)) {
      _controllers[id] = StreamController<Delta?>.broadcast();
      // Emit current value if exists
      _controllers[id]!.add(_cache[id]);
    }
    return _controllers[id]!.stream;
  }

  /// Update Delta and notify listeners
  ///
  /// Updates the cached delta and emits the new value to all stream listeners.
  /// Marks delta as needing sync if provided.
  void updateDelta(DeltaId id, Delta delta, {bool markForSync = true}) {
    _cache[id] = delta;

    // Mark for sync if metadata exists
    if (markForSync && _metadata.containsKey(id)) {
      _metadata[id]!.needsSync = true;
    }

    // Notify stream listeners
    if (_controllers.containsKey(id)) {
      _controllers[id]!.add(delta);
    }
  }

  /// Get metadata for a delta
  DeltaMetadata? getMetadata(DeltaId id) => _metadata[id];

  /// Mark delta as needing sync
  void markForSync(DeltaId id) {
    if (_metadata.containsKey(id)) {
      _metadata[id]!.needsSync = true;
    }
  }

  /// Get all deltas that need sync
  List<DeltaId> getDeltasNeedingSync() {
    return _metadata.entries
        .where((e) => e.value.needsSync)
        .map((e) => e.key)
        .toList();
  }

  /// Mark delta as synced
  void markSynced(DeltaId id) {
    if (_metadata.containsKey(id)) {
      _metadata[id]!.needsSync = false;
    }
  }

  /// Clear all cached deltas
  ///
  /// Removes all cached deltas and closes all stream controllers.
  /// This is primarily for testing purposes.
  void clearCache() {
    _cache.clear();
    _metadata.clear();
    _firestoreIdToInternalId.clear();
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
    _nextId = DeltaId(1);
  }

  /// Get internal DeltaId from Firestore Delta ID
  DeltaId? getInternalIdByFirestoreId(String firestoreDeltaId) {
    return _firestoreIdToInternalId[firestoreDeltaId];
  }

  /// Store mapping from Firestore Delta ID to internal DeltaId
  void setFirestoreIdMapping(String firestoreDeltaId, DeltaId internalId) {
    _firestoreIdToInternalId[firestoreDeltaId] = internalId;
  }

  /// Dispose of all resources
  ///
  /// Closes all stream controllers. Call this when the cache is no longer needed.
  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
}
