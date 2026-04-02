import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_lock.freezed.dart';
part 'edit_lock.g.dart';

@freezed
abstract class EditLock with _$EditLock {
  const factory EditLock({
    required String lockedBy, // User UID who holds the lock
    required DateTime lockedAt, // Lock acquisition time
    required DateTime expiresAt, // Lock expiration time (TTL)
    required String deviceId, // Device identifier
  }) = _EditLock;

  factory EditLock.fromJson(Map<String, dynamic> json) =>
      _$EditLockFromJson(json);
}

extension EditLockExt on EditLock {
  // Helper to check if lock is still valid
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool isOwnedBy(String userId) => lockedBy == userId && !isExpired;
}
