import 'dart:async';
import 'package:flutter_quill/quill_delta.dart';
import 'package:my_manga_editor/feature/manga/model/manga.dart';

/// In-memory cache for Delta objects referenced by DeltaId
///
/// This cache bridges between Firestore's embedded delta storage (Map)
/// and the domain model's DeltaId reference pattern (int).
class DeltaCache {
  final Map<DeltaId, Delta> _cache = {};
  final Map<DeltaId, StreamController<Delta?>> _controllers = {};
  DeltaId _nextId = DeltaId(1);

  /// Store a Delta and return its DeltaId
  ///
  /// The Delta is cached in memory and assigned an auto-incrementing integer ID.
  /// This ID can be used to retrieve the Delta later via [getDelta] or [getDeltaStream].
  DeltaId storeDelta(Delta delta) {
    final id = DeltaId(_nextId.id + 1);
    _cache[id] = delta;
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
  void updateDelta(DeltaId id, Delta delta) {
    _cache[id] = delta;
    // Notify stream listeners
    if (_controllers.containsKey(id)) {
      _controllers[id]!.add(delta);
    }
  }

  /// Clear all cached deltas
  ///
  /// Removes all cached deltas and closes all stream controllers.
  /// This is primarily for testing purposes.
  void clearCache() {
    _cache.clear();
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
    _nextId = DeltaId(1);
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
