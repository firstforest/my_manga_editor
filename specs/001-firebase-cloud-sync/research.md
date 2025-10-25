# Research: Firebase Cloud Sync Technical Decisions

**Feature**: 001-firebase-cloud-sync
**Date**: 2025-10-19
**Purpose**: Document technical decisions for implementing Firebase cloud synchronization with Google authentication

## 1. Firebase Package Selection

### Decision
Use the following official FlutterFire packages:
- **firebase_core: ^3.8.0+** - Firebase SDK initialization
- **firebase_auth: ^5.3.3+** - Authentication services
- **google_sign_in: ^6.2.2+** - Google Sign-In for mobile/web
- **cloud_firestore: ^5.5.0+** - Cloud Firestore database

### Rationale
- `firebase_core` is mandatory as all other Firebase plugins depend on it
- `firebase_auth` provides official authentication with native platform integration
- `cloud_firestore` offers offline persistence, real-time sync, and cross-platform support
- Official packages from Google provide best long-term support and feature parity
- All packages support iOS, Android, Web, and macOS in production

### Platform Support Matrix
| Platform | firebase_core | firebase_auth | cloud_firestore | google_sign_in | Production Ready |
|----------|--------------|---------------|-----------------|----------------|------------------|
| iOS | ✅ | ✅ | ✅ | ✅ | ✅ |
| Android | ✅ | ✅ | ✅ | ✅ | ✅ |
| Web | ✅ | ✅ | ✅ | ✅ | ✅ |
| macOS | ✅ | ✅ | ✅ | Via third-party | ✅ |
| Windows | ⚠️ Dev only | ⚠️ Dev only | ⚠️ Dev only | Via third-party | ❌ |
| Linux | ⚠️ Dev only | ⚠️ Dev only | ⚠️ Dev only | Via third-party | ❌ |

**Windows/Linux Note**: Desktop platforms other than macOS have limited official Firebase support (development only, not production). For production desktop apps, consider using web build or implementing custom backend.

### Alternatives Considered
- **firedart** (community package): Rejected because it's a workaround for desktop platforms and lacks official support, feature parity, and long-term maintenance guarantees
- **Firebase C++ SDK**: Rejected due to complexity and limited Flutter integration
- **Custom REST API wrapper**: Rejected to avoid reinventing Firebase SDK capabilities

---

## 2. Firestore Data Model Best Practices

### Decision: User-Scoped Subcollections with Map Storage

**Data Structure:**
```
/users/{uid}/mangas/{mangaId}
  - name: string
  - startPageDirection: string
  - createdAt: timestamp
  - updatedAt: timestamp
  - lastEditedAt: timestamp
  - ideaMemo: map (Quill Delta as nested Map)
  - editLock: map (optional)
    - lockedBy: uid
    - lockedAt: timestamp
    - expiresAt: timestamp
    - deviceId: string

/users/{uid}/mangas/{mangaId}/pages/{pageId}
  - pageIndex: number
  - memoDelta: map (Quill Delta as nested Map)
  - stageDirectionDelta: map (Quill Delta as nested Map)
  - dialoguesDelta: map (Quill Delta as nested Map)
  - createdAt: timestamp
  - updatedAt: timestamp
```

### Rationale

**User-Scoped Collections (`/users/{uid}/`):**
- Inherent security isolation (path-based rules: `allow read, write: if request.auth.uid == userId`)
- Better data organization and privacy
- Easier per-user quotas and limits
- Natural fit for user-owned content
- Simpler security rules without field-level checks

**Subcollections vs Embedded for Pages:**
- **Chosen**: Subcollections (`/mangas/{mangaId}/pages/{pageId}`)
- **Why**:
  - Pages can expand indefinitely (manga can have hundreds of pages)
  - Firestore document size limit is 1 MiB - embedding pages would hit this quickly
  - Each page has multiple rich text fields (memo, dialogue, stageDirection)
  - Subcollections support better queries (e.g., "get pages 10-20")
  - Easier page-level operations (reorder, delete, duplicate)
  - Better performance for large manga projects

**Delta JSON Storage:**
- **Chosen**: Store Quill Delta as native Firestore Map (not serialized string)
- **Why**:
  - Firestore natively supports nested maps and arrays
  - Type-safe with proper data validation
  - No serialization/deserialization overhead
  - Better integration with Firestore offline persistence
  - Preserves data types (numbers, booleans) within Delta operations

**Indexing Requirements:**
- Single-field auto-indexing covers most queries (userId, mangaId, pageIndex)
- Composite indexes only needed for complex sorting (e.g., "get all mangas sorted by updatedAt")
- Avoid over-indexing to reduce write costs

### Alternatives Considered
- **Global `/mangas/` with userId field**: Rejected because security rules become more complex (`resource.data.userId` checks), doesn't provide natural user isolation
- **Embedded pages as array**: Rejected due to 1 MiB document limit, poor scalability, inefficient partial updates
- **Serialized JSON strings for Delta**: Rejected because it loses Firestore's type safety, queryability, and offline persistence benefits
- **Separate Delta collection**: Rejected to avoid complexity of managing references similar to current local DB schema

---

## 3. Google Sign-In Integration

### Decision: Multi-Client OAuth Configuration

**OAuth Client Setup:**
```
Google Cloud Console → Credentials:
1. Web Application (for backend/token verification)
2. iOS Application (Bundle ID + Team ID)
3. Android Application (Package name + SHA-1 fingerprints)
```

### Platform-Specific Setup

**iOS/macOS:**
- Configure iOS OAuth client with Bundle ID and Apple Developer Team ID
- Add reversed client ID to Info.plist as custom URL scheme
- Use official `google_sign_in` package

**Android:**
- Register Package name + SHA-1 certificate fingerprint
- **Important**: Separate OAuth clients for debug and release builds (different SHA-1)
- Each development machine needs its own debug fingerprint registered

**Web:**
- Configure authorized JavaScript origins (localhost for dev, production domains)
- Web uses implicit flow with redirect URIs

### Session Persistence
- **Mobile/Desktop**: Tokens stored in platform-native secure storage
  - Android: SharedPreferences (encrypted)
  - iOS/macOS: Keychain
  - Windows/Linux: Platform-specific credential stores
- **Web**: LocalStorage with configurable persistence modes
- **Token Refresh**: Firebase automatically handles token refresh (ID tokens expire after 1 hour, but refresh tokens are long-lived)

### Implementation Pattern
```dart
final GoogleSignIn googleSignIn = GoogleSignIn();

// Firebase auth automatically persists session
final credential = GoogleAuthProvider.credential(
  idToken: googleAuth.idToken,
  accessToken: googleAuth.accessToken,
);
await FirebaseAuth.instance.signInWithCredential(credential);

// Listen to auth state changes (includes token refresh)
FirebaseAuth.instance.authStateChanges().listen((user) {
  // User object automatically refreshed
});
```

### Rationale
- Each platform requires platform-specific configuration
- Firebase SDK handles token refresh automatically (no manual token management needed)
- Native secure storage provides best security for credentials
- Auth state stream provides reactive updates for UI

### Alternatives Considered
- **Single OAuth client for all platforms**: Rejected because each platform requires platform-specific configuration
- **Custom token management**: Rejected because Firebase SDK handles refresh automatically
- **Third-party auth providers (Auth0, Supabase)**: Rejected to maintain Firebase ecosystem consistency

---

## 4. Offline Sync Patterns

### Decision: Hybrid Approach - Firestore Offline Persistence + Custom Queue

**Architecture:**
1. Use Firestore's built-in offline persistence for caching
2. Implement custom queue in SQLite for pending operations
3. Periodic sync timer (30-60 seconds) + manual sync trigger
4. Sync queue processes operations in FIFO order with retry logic

### Firestore Offline Capabilities
- **Enabled by default** on iOS/Android (40-100 MB cache, configurable)
- **Must enable explicitly** on Web
- **Limitations**:
  - Acts as cache, not true sync mechanism
  - No control over sync timing (syncs immediately when online)
  - Cannot batch operations for periodic upload

### Custom Queue Implementation
```dart
// SQLite table for sync queue
CREATE TABLE sync_queue (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  operation_type TEXT NOT NULL, -- 'create', 'update', 'delete'
  collection_path TEXT NOT NULL,
  document_id TEXT,
  data TEXT, -- JSON payload
  timestamp INTEGER NOT NULL,
  retry_count INTEGER DEFAULT 0,
  status TEXT DEFAULT 'pending' -- 'pending', 'syncing', 'completed', 'failed'
);
```

### Rationale

**Why Hybrid Approach:**
- **Firestore offline persistence**: Handles read caching automatically, provides instant UI updates
- **Custom queue**: Provides control over sync timing, batching, and retry logic
- **30-60 second interval**: Balances battery life, network usage, and data freshness
- **Persistent queue**: Survives app restarts and crashes
- **Exponential backoff**: Prevents hammering server on transient failures

**Partial Sync Failure Handling:**
- Queue operations can be processed independently
- Failed operations retry with exponential backoff (max 3 retries)
- User notified of persistent failures with actionable error messages
- Successful operations removed from queue immediately

**Cache Configuration:**
```dart
// Mobile (default enabled)
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);

// Web (must enable)
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: 100 * 1024 * 1024, // 100 MB
);
```

### Alternatives Considered
- **Real-time listeners only**: Rejected because doesn't provide control over sync timing, wastes battery, can cause conflicts with rapid local edits
- **Manual sync only**: Rejected because users may forget to sync, leading to data loss
- **In-memory queue**: Rejected because operations lost on app restart
- **Firestore transactions for all operations**: Rejected because transactions don't work offline

---

## 5. Lock-Based Editing in Firestore

### Decision: Document-Based Pessimistic Locks with TTL and Heartbeat Renewal

**Lock Document Structure:**
```dart
// Stored in manga document
{
  "editLock": {
    "lockedBy": "user123",
    "lockedAt": Timestamp(1704067200),
    "expiresAt": Timestamp(1704067260), // 60 seconds from lock
    "deviceId": "device-uuid-123"
  }
}
```

### Lock Acquisition Pattern
```dart
class LockManager {
  Future<bool> acquireLock(String mangaId, String userId) async {
    final docRef = FirebaseFirestore.instance
      .doc('/users/$userId/mangas/$mangaId');

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final lock = snapshot.data()?['editLock'] as Map<String, dynamic>?;

      // Check if lock exists and is not expired
      if (lock != null) {
        final expiresAt = (lock['expiresAt'] as Timestamp).toDate();
        if (expiresAt.isAfter(DateTime.now()) &&
            lock['lockedBy'] != userId) {
          return false; // Lock acquisition failed
        }
      }

      // Acquire lock (or renew if already owned)
      transaction.update(docRef, {
        'editLock': {
          'lockedBy': userId,
          'lockedAt': FieldValue.serverTimestamp(),
          'expiresAt': Timestamp.fromDate(
            DateTime.now().add(Duration(seconds: 60))
          ),
        }
      });

      return true;
    });
  }
}
```

### Heartbeat Renewal
- **Lock duration**: 60 seconds
- **Heartbeat interval**: 30 seconds (renews before expiration)
- Heartbeat runs while user actively editing
- Stopped when user closes document or app

### Lock Release Strategy
```dart
Future<void> releaseLock(String mangaId, String userId) async {
  await FirebaseFirestore.instance.runTransaction((transaction) async {
    final snapshot = await transaction.get(docRef);
    final lock = snapshot.data()?['editLock'];

    // Only release if owned by current user
    if (lock?['lockedBy'] == userId) {
      transaction.update(docRef, {'editLock': FieldValue.delete()});
    }
  });
}
```

### Edge Case Handling
- **App backgrounded**: Release lock immediately
- **Network lost**: Stop heartbeat, attempt reacquire on reconnect
- **App crash**: Lock expires after 60 seconds (one missed heartbeat)
- **Concurrent acquisition**: Firestore transaction ensures atomic operation

### Rationale

**Why Document-Based:**
- Firestore doesn't support native pessimistic locking
- Storing lock in document avoids separate lock collection overhead
- Easier to query "is this manga locked?" without additional reads

**Transactions vs Batch Writes:**
- **Chosen**: Firestore transactions for lock acquisition/release
- **Why**: Transactions provide atomic read-then-write, essential for checking lock state
- Batch writes rejected: No read operations, can't check current lock state

**Lock TTL Strategy:**
- 60-second TTL allows one missed heartbeat before expiration
- 30-second heartbeat keeps lock alive during active editing
- Minimizes time document is locked if user crashes/disconnects
- Client-side expiration check provides immediate validation

### Alternatives Considered
- **Separate lock collection**: Rejected because it requires additional reads and increases complexity
- **Optimistic locking only (version numbers)**: Rejected because it doesn't prevent concurrent editing, only detects conflicts after they occur
- **Firestore native TTL policies**: Rejected because TTL deletion is not immediate (up to 24 hours)
- **WebSocket-based presence detection**: Rejected due to complexity and battery drain

---

## Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/mangas/{mangaId} {
      allow read, write: if request.auth != null &&
                            request.auth.uid == userId;

      match /pages/{pageId} {
        allow read, write: if request.auth != null &&
                              request.auth.uid == userId;
      }
    }
  }
}
```

---

## Migration Strategy

Given existing SQLite database:

1. **Dual-Write Period**:
   - Keep SQLite as source of truth initially
   - Write to both SQLite and Firestore
   - Read from SQLite for consistency

2. **Validation Phase**:
   - Compare SQLite and Firestore data periodically
   - Verify sync queue processing
   - Test conflict resolution

3. **Gradual Cutover**:
   - Enable Firestore reads for new users first
   - Monitor for issues
   - Gradually migrate existing users
   - Keep SQLite as fallback for 1-2 releases

---

## Cost Optimization

- **Reads**: Use Firestore offline cache to minimize reads
- **Writes**: Batch operations in sync queue (up to 500 per batch)
- **Indexes**: Only create composite indexes when explicitly needed
- **Storage**: Monitor Delta JSON sizes; compress if exceeding 500KB per field

---

## Summary

This architecture provides:
- ✅ Cross-platform support (iOS, Android, Web, macOS production-ready)
- ✅ Secure user isolation with path-based security rules
- ✅ Scalable data model with subcollections for unlimited pages
- ✅ Controlled sync timing via custom queue + Firestore offline persistence
- ✅ Conflict prevention via TTL-based pessimistic locks
- ✅ Graceful degradation when offline
- ✅ Preserves Quill Delta format throughout sync process

**Implementation Priority**:
1. Firebase setup (core, auth, firestore)
2. Create Firestore data models (CloudManga, CloudMangaPage, CloudDelta)
3. Implement Google Sign-In authentication flow
4. Build sync queue with periodic timer
5. Implement lock manager with heartbeat
6. Add offline detection and queue processing
7. Test migration strategy with subset of data
