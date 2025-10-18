# Research Report: Firebase Cloud Storage Implementation

**Feature**: Firebase Cloud Storage for My Manga Editor
**Date**: 2025-10-18
**Status**: Research Complete

## Overview

This document consolidates research findings for migrating My Manga Editor from Drift (SQLite) to Firebase Cloud Firestore for cloud-based data synchronization. All technical decisions have been researched and documented with rationales.

---

## 1. Firebase Service Selection

### Decision: Cloud Firestore

**Rationale**:
- **Structured Document Model**: Perfect for hierarchical manga → pages → deltas structure
- **Superior Offline Support**: Automatic offline persistence on all platforms with seamless sync
- **Better Security**: More intuitive hierarchical security rules compared to Realtime Database
- **Cost Effective**: Operation-based pricing better suits read-heavy manga editor workload
- **Query Flexibility**: Supports compound queries and collection groups for future features

**Alternatives Considered**:
- **Firebase Realtime Database**: Rejected due to flat JSON structure requiring manual path management and less sophisticated offline caching

**Implementation**: Use Cloud Firestore with offline persistence enabled via `Settings(persistenceEnabled: true, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED)`

---

## 2. Offline Persistence Strategy

### Decision: Firestore Native Offline Persistence with Unlimited Cache

**Configuration**:
```dart
FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

**Rationale**:
- Firestore SDK automatically caches all accessed documents
- Works seamlessly offline and online with identical API
- Unlimited cache prevents eviction of manga data during offline periods
- Pending writes are queued automatically and sync when connection restores

**Platform Support**:
- **Mobile/Desktop**: Full support with SQLite-backed cache
- **Web**: Limited support via IndexedDB (requires `enablePersistence()`)

**Packages Required**:
- `cloud_firestore: ^5.0.0`
- `connectivity_plus: ^6.0.0` for network state monitoring

---

## 3. Authentication Implementation

### Decision: Custom Flutter Forms with firebase_auth Package

**Rationale**:
- **Best Desktop Support**: `firebase_auth` has stable Windows/macOS/Linux support
- **Maximum Customization**: Complete control over UI to match app design
- **Smallest Bundle Size**: ~150KB vs 500KB+ for firebase_ui_auth
- **Riverpod Integration**: Fits naturally into existing architecture pattern
- **Production Ready**: Mature and widely used in production apps

**Alternatives Considered**:
- **firebase_ui_auth**: Rejected due to limited Windows/Linux support (not production-ready) and larger bundle size
- **flutterfire_ui**: Deprecated, not considered

**Implementation Pattern**:
```dart
@riverpod
class AuthRepository {
  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
```

**Packages Required**:
- `firebase_auth: ^5.3.3`
- `firebase_core: ^3.8.1`

---

## 4. Data Migration Strategy

### Decision: Hybrid Migration (Bulk Upload + Background Retry)

**Approach**:
1. **One-time bulk upload** on first Firebase sign-in for best UX
2. **Background retry mechanism** for failed uploads
3. **Progressive data deletion** after verification

**Migration Workflow**:
```
1. User signs in → Check migration state (SharedPreferences)
2. If not migrated → Show migration dialog
3. Migrate all deltas first (build ID map: Drift ID → Firestore ID)
4. Migrate mangas with pages (using WriteBatch per manga)
5. Track progress in SharedPreferences
6. On completion → Verify data integrity
7. After user confirmation → Delete Drift data
```

**Rationale**:
- Fast initial migration (users see progress once)
- Graceful failure handling with retry capability
- Safe data deletion only after verification
- Works offline (queues for later sync)

**Data Integrity Verification**:
- Count documents in Firestore vs Drift
- Sample check random manga for data fidelity
- Ensure all Quill Delta JSON preserved correctly

**Drift Data Cleanup**:
- Keep Drift data until user confirms successful migration
- Verify 100% data fidelity before deletion
- Provide manual cleanup option if automatic fails

---

## 5. Security Rules Architecture

### Decision: Subcollections with Hierarchical Security Rules

**Collection Structure**:
```
/users/{userId}
  /mangas/{mangaId}
    - name, startPage, ideaMemoId, timestamps
    /pages/{pageId}
      - pageIndex, delta IDs, timestamps
    /deltas/{deltaId}
      - delta (Quill Delta JSON), timestamps
```

**Security Rules Pattern**:
```javascript
match /users/{userId}/mangas/{mangaId} {
  allow read, write: if request.auth.uid == userId;

  match /pages/{pageId} {
    allow read, write: if request.auth.uid == userId;
  }

  match /deltas/{deltaId} {
    allow read, write: if request.auth.uid == userId;
  }
}
```

**Rationale**:
- **Subcollections Preferred**: Natural hierarchical isolation, cleaner security rules
- **User Isolation**: All data scoped under `/users/{userId}` prevents cross-user access
- **Validation**: Field type checking, enum validation (startPage: 'left'|'right')
- **Cascade Deletes**: Implemented via client-side batch writes or Cloud Functions

**Alternatives Considered**:
- **Top-level collections with userId field**: Rejected due to more complex security rules and additional indexing requirements

**Testing**:
- Firebase Emulator Suite with jest tests before deployment
- Test user isolation, field validation, and unauthorized access prevention

---

## 6. Sync Status Tracking

### Decision: Riverpod Providers Combining Firestore Metadata + Connectivity Monitoring

**Architecture**:
```dart
// Network status
@riverpod Stream<bool> networkStatus(Ref ref)

// Pending writes per collection
@riverpod Stream<int> mangaCollectionPendingWrites(Ref ref, String userId)

// Aggregated sync status
@riverpod Stream<SyncStatus> syncStatus(Ref ref, String userId)
```

**Sync States**:
- **synced**: All data synced, online
- **syncing**: Active sync in progress (hasPendingWrites = true)
- **offline**: No network, working from cache
- **error**: Sync failed (permissions, quota exceeded)

**Tracking Mechanism**:
- Monitor `DocumentSnapshot.metadata.hasPendingWrites` per document
- Use `includeMetadataChanges: true` in snapshots to track sync completion
- Combine with `connectivity_plus` for network state
- Aggregate into unified `SyncStatus` model

**UI Indicators**:
- Persistent icon in app bar showing current sync state
- Detailed status dialog on tap
- Color-coded states: green (synced), orange (syncing), grey (offline), red (error)

**Limitations**:
- No global "pending writes count" API in Firestore
- Must track per-collection or per-document
- Permission errors may only appear in console logs, not error handlers

**Packages Required**:
- `connectivity_plus: ^6.0.0`

---

## 7. Quill Delta Storage Format

### Decision: Embedded Deltas as Structured Maps (NOT JSON Strings)

**Document Structure**:
```json
{
  "pageIndex": 0,
  "memoDelta": {
    "ops": [
      {"insert": "描きたいこと", "attributes": {"bold": true}},
      {"insert": "\n"}
    ]
  },
  "stageDirectionDelta": {
    "ops": [{"insert": "ト書き content\n"}]
  },
  "dialoguesDelta": {
    "ops": [{"insert": "Dialogue\n"}]
  }
}
```

**Rationale**:
- **Embedded vs Separate**: Embed deltas in page documents (reduces 4 reads to 1 read per page)
- **Structured Map vs JSON String**: Store as native Firestore map for better querying and indexing
- **Document Size Safety**: Typical manga page with 3 deltas is ~5-20KB, well under 1MB limit
- **Atomic Operations**: All delta fields for a page are read/written together in UI

**Freezed JSON Converter**:
```dart
class DeltaConverter implements JsonConverter<Delta, Map<String, dynamic>> {
  const DeltaConverter();

  @override
  Delta fromJson(Map<String, dynamic> json) {
    return Delta.fromJson(json['ops'] ?? []);
  }

  @override
  Map<String, dynamic> toJson(Delta delta) {
    return {'ops': delta.toJson()};
  }
}
```

**Alternatives Considered**:
- **Separate deltas collection**: Rejected due to 4x more read operations and higher costs
- **JSON string storage**: Rejected due to loss of Firestore query capabilities

**Migration Compatibility**:
- Drift stores deltas as JSON text → Convert to structured map during migration
- Preserve exact `ops` array structure for Quill editor compatibility

---

## Technology Decisions Summary

| Component | Technology | Rationale |
|-----------|------------|-----------|
| Cloud Storage | Cloud Firestore | Structured documents, superior offline support, better security |
| Authentication | firebase_auth (custom forms) | Best desktop support, Riverpod integration, smallest bundle |
| Offline Persistence | Firestore native (unlimited cache) | Automatic sync, works seamlessly offline/online |
| Data Migration | Hybrid (bulk + retry) | Fast UX, graceful failure handling, safe cleanup |
| Security | Subcollections + hierarchical rules | Natural isolation, cleaner rules, easier testing |
| Sync Tracking | Riverpod + Firestore metadata | Reactive state, tracks pending writes, network-aware |
| Delta Storage | Embedded structured maps | Fewer reads, atomic operations, preserves Quill format |

---

## Dependencies Required

Add to `pubspec.yaml`:

```yaml
dependencies:
  # Firebase
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.6.0

  # Network monitoring
  connectivity_plus: ^6.0.0

  # Existing (keep)
  riverpod: ^3.0.0-dev.15
  freezed_annotation: ^3.0.6
  flutter_quill: ^11.4.0

dev_dependencies:
  # Testing
  fake_cloud_firestore: ^3.0.3  # For unit tests
```

---

## Next Steps (Phase 1: Design)

1. **Generate data-model.md**: Define Firestore document schemas with validation rules
2. **Generate API contracts**: Document repository method signatures and Riverpod providers
3. **Generate quickstart.md**: Step-by-step implementation guide for developers
4. **Update agent context**: Add Firebase/Firestore to Claude Code context for future assistance

---

## Key Risks and Mitigations

| Risk | Mitigation |
|------|-----------|
| Migration data loss | Verification step before Drift cleanup, keep backup until confirmed |
| Firestore quota exceeded | Monitor usage, implement pagination, show user warnings |
| Offline sync conflicts | Last-write-wins strategy (newest timestamp), notify user of changes |
| Large delta documents | Monitor sizes during development, add validation warnings at 100KB |
| Desktop platform issues | firebase_auth has stable desktop support, test on all platforms |
| Network interruption during migration | Track state in SharedPreferences, resume on reconnect |

---

## Conclusion

All technical decisions have been researched and documented. The recommended architecture leverages Firestore's strengths (offline-first, automatic sync, structured documents) while maintaining compatibility with existing Riverpod + Freezed + Quill architecture. The migration strategy balances user experience (fast bulk upload) with safety (verification before cleanup).

**Research Status**: ✅ Complete - Ready for Phase 1 (Design)
