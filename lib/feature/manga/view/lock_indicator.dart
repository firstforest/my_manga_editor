import 'package:flutter/material.dart';
import 'package:my_manga_editor/service/firebase/model/edit_lock.dart';

/// Widget to display manga edit lock status
/// Shows whether a manga is locked by another user/device
class LockIndicator extends StatelessWidget {
  final EditLock? lock;
  final String? currentUserId;
  final String? currentDeviceId;
  final VoidCallback? onRequestLock;

  const LockIndicator({
    super.key,
    required this.lock,
    this.currentUserId,
    this.currentDeviceId,
    this.onRequestLock,
  });

  @override
  Widget build(BuildContext context) {
    if (lock == null || lock!.isExpired) {
      // No lock or expired lock - unlocked state
      return const SizedBox.shrink();
    }

    final isOwnedByCurrentUser =
        lock!.lockedBy == currentUserId && lock!.deviceId == currentDeviceId;

    if (isOwnedByCurrentUser) {
      // Current user owns the lock
      return _buildOwnedLockIndicator(context);
    } else {
      // Locked by another user/device
      return _buildLockedIndicator(context);
    }
  }

  Widget _buildOwnedLockIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.edit,
            size: 16,
            color: Colors.green.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            'Editing',
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedIndicator(BuildContext context) {
    // Calculate time remaining until lock expires
    final timeRemaining = lock!.expiresAt.difference(DateTime.now());
    final secondsRemaining = timeRemaining.inSeconds;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock,
            size: 16,
            color: Colors.orange.shade700,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Locked by another device',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Unlocks in ${secondsRemaining}s',
                  style: TextStyle(
                    color: Colors.orange.shade600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (onRequestLock != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRequestLock,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Request Lock',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.orange.shade700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Simple read-only mode indicator for locked mangas
class ReadOnlyBanner extends StatelessWidget {
  final String? lockedByDevice;
  final VoidCallback? onRequestLock;

  const ReadOnlyBanner({
    super.key,
    this.lockedByDevice,
    this.onRequestLock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.orange.shade100,
      child: Row(
        children: [
          Icon(Icons.visibility, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Read-Only Mode',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
                Text(
                  lockedByDevice != null
                      ? 'This manga is being edited on another device'
                      : 'This manga is locked',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
          if (onRequestLock != null) ...[
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onRequestLock,
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Request Edit Access'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
