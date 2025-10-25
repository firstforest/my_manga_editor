import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_manga_editor/service/firebase/model/edit_lock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'lock_manager.g.dart';

/// Manages edit locks for manga documents to prevent concurrent modifications
@riverpod
LockManager lockManager(Ref ref) {
  return LockManager();
}

class LockManager {
  final _firestore = FirebaseFirestore.instance;
  final _deviceId = const Uuid().v4(); // Generate unique device ID

  /// Duration before lock expires (60 seconds)
  static const lockDuration = Duration(seconds: 60);

  /// Interval for lock renewal heartbeat (30 seconds)
  static const heartbeatInterval = Duration(seconds: 30);

  /// Acquire lock for a manga document
  /// Returns true if lock acquired successfully, false if locked by another user
  Future<bool> acquireLock(String userId, String mangaId) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('mangas')
        .doc(mangaId);

    try {
      return await _firestore.runTransaction<bool>((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          // Document doesn't exist, cannot acquire lock
          return false;
        }

        final data = snapshot.data();
        final lockData = data?['editLock'] as Map<String, dynamic>?;

        // Check if lock exists and is not expired
        if (lockData != null) {
          final lock = EditLock.fromJson(lockData);

          // If lock is not expired and owned by different user, acquisition fails
          if (!lock.isExpired && lock.lockedBy != userId) {
            return false;
          }
        }

        // Acquire lock (or renew if already owned)
        final newLock = EditLock(
          lockedBy: userId,
          lockedAt: DateTime.now(),
          expiresAt: DateTime.now().add(lockDuration),
          deviceId: _deviceId,
        );

        transaction.update(docRef, {
          'editLock': newLock.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return true;
      });
    } catch (e) {
      // Transaction failed
      return false;
    }
  }

  /// Renew lock to prevent expiration
  /// Returns true if renewal successful, false otherwise
  Future<bool> renewLock(String userId, String mangaId) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('mangas')
        .doc(mangaId);

    try {
      return await _firestore.runTransaction<bool>((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          return false;
        }

        final data = snapshot.data();
        final lockData = data?['editLock'] as Map<String, dynamic>?;

        if (lockData == null) {
          // No lock to renew
          return false;
        }

        final lock = EditLock.fromJson(lockData);

        // Only renew if owned by current user and device
        if (lock.lockedBy != userId || lock.deviceId != _deviceId) {
          return false;
        }

        // Renew lock with new expiration time
        final renewedLock = EditLock(
          lockedBy: userId,
          lockedAt: lock.lockedAt,
          expiresAt: DateTime.now().add(lockDuration),
          deviceId: _deviceId,
        );

        transaction.update(docRef, {
          'editLock': renewedLock.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return true;
      });
    } catch (e) {
      return false;
    }
  }

  /// Release lock for a manga document
  /// Returns true if release successful, false otherwise
  Future<bool> releaseLock(String userId, String mangaId) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('mangas')
        .doc(mangaId);

    try {
      return await _firestore.runTransaction<bool>((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          return false;
        }

        final data = snapshot.data();
        final lockData = data?['editLock'] as Map<String, dynamic>?;

        if (lockData == null) {
          // No lock to release
          return true;
        }

        final lock = EditLock.fromJson(lockData);

        // Only release if owned by current user and device
        if (lock.lockedBy != userId || lock.deviceId != _deviceId) {
          return false;
        }

        // Remove lock field
        transaction.update(docRef, {
          'editLock': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return true;
      });
    } catch (e) {
      return false;
    }
  }

  /// Check if manga is currently locked by another user
  /// Returns EditLock if locked, null if unlocked or expired
  Future<EditLock?> checkLock(String userId, String mangaId) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('mangas')
          .doc(mangaId);

      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data();
      final lockData = data?['editLock'] as Map<String, dynamic>?;

      if (lockData == null) {
        return null;
      }

      final lock = EditLock.fromJson(lockData);

      // Return null if lock is expired
      if (lock.isExpired) {
        return null;
      }

      return lock;
    } catch (e) {
      return null;
    }
  }

  /// Check if current user owns the lock
  Future<bool> ownsLock(String userId, String mangaId) async {
    final lock = await checkLock(userId, mangaId);
    if (lock == null) return false;
    return lock.lockedBy == userId && lock.deviceId == _deviceId;
  }

  /// Get device ID for this instance
  String get deviceId => _deviceId;
}
