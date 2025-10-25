# Research: Firebase-Only Persistence Migration

**Feature**: `002-firebase-only-persistence`
**Date**: 2025-10-25
**Status**: Complete

## Overview

This document consolidates research findings for migrating from a dual-storage architecture (Drift SQLite + Firebase sync) to Firebase-only persistence with offline support. The research resolves all "NEEDS CLARIFICATION" items from the Technical Context and provides evidence-based decisions for implementation.

---

## Research Area 1: Firestore Offline Persistence Capabilities

### Question
Can Firestore's native offline persistence fully replace Drift SQLite for manga editing workflows? What are the performance characteristics, storage limits, and platform support?

### Findings

**Offline Persistence Mechanism**:
- Firestore maintains a local cache on device using SQLite (iOS/Android) or IndexedDB (Web)
- Automatic synchronization when connection restored
- Supports unlimited offline duration (cache persists until explicit clear)
- Automatic conflict resolution using last-write-wins at field level

**Platform Support** (from Firebase Flutter documentation):
- ✅ **iOS/Android**: Full offline support via `persistentCacheSettings`
- ✅ **Web**: Full offline support via `persistentCacheSettings` with IndexedDB
- ✅ **Desktop (Windows/macOS/Linux)**: Supported through Flutter's embedded web view or native Firestore (as of Cloud Firestore 4.0+)

**Performance Characteristics**:
- Offline reads: <10ms (from local cache, similar to SQLite)
- Offline writes: Immediate (queued for sync)
- Online sync: Automatic, incremental (only changed documents)
- Cache size: Default 40MB (configurable up to 100MB on mobile, larger on desktop)

**Storage Limits**:
- Max document size: 1MB
- Max subcollection depth: 100 levels
- Max field name size: 1,500 bytes
- **For manga use case**: Typical manga project with 100 pages × 5KB per page = 500KB (well under limits)

**Configuration for Offline Persistence** (Flutter):
```dart
FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // Or specific size
);
```

### Decision
✅ **Firestore offline persistence is sufficient** for manga editing workflows:
- Supports all target platforms (including desktop)
- Performance matches SQLite for local reads
- Storage limits are not a concern for manga content
- Automatic sync eliminates custom sync queue logic

### Rationale
Firestore's offline capabilities are production-ready and used by millions of applications. The automatic cache management and conflict resolution reduce implementation complexity compared to manual Drift-to-Firebase sync.

### Alternatives Considered
- **Continue Drift + Firebase sync**: Rejected because dual-storage adds complexity, requires manual conflict resolution, and increases maintenance burden
- **Hive/Isar + Firebase**: Rejected because it still requires manual sync logic (same complexity as Drift)

---

## Research Area 2: Firestore Data Modeling for Rich Text (Quill Delta)

### Question
How should Quill Delta JSON be stored in Firestore? Should deltas be embedded in documents or stored in subcollections?

### Findings

**Current Architecture (Drift)**:
- Normalized structure: `DbDeltas` table with foreign keys from `DbMangas` and `DbMangaPages`
- One `DbDelta` row per rich text field (ideaMemo, memoDelta, stageDirectionDelta, dialoguesDelta)
- Allows delta reuse (though not currently used in practice)

**Firestore Options**:

**Option A: Embedded Deltas** (Denormalized)
```json
{
  "id": "123",
  "name": "My Manga",
  "startPageDirection": "left",
  "ideaMemo": {
    "ops": [{"insert": "Some idea text"}]
  },
  "pages": [
    {
      "id": "456",
      "pageIndex": 0,
      "memoDelta": {"ops": [...]},
      "dialoguesDelta": {"ops": [...]},
      "stageDirectionDelta": {"ops": [...]}
    }
  ]
}
```

**Pros**:
- Single document read fetches all content (1 read operation vs 5+ in normalized)
- Atomic updates (entire manga + pages updated together)
- Lower Firestore costs (charged per document read, not per field)
- Faster offline access (fewer cache lookups)

**Cons**:
- Document size increases (but still <100KB for typical manga)
- Harder to share deltas between entities (not needed in current use case)

**Option B: Delta Subcollection** (Normalized)
```
mangas/{mangaId}
├── (manga metadata)
└── deltas/{deltaId}
    └── (delta content)
```

**Pros**:
- Mirrors current Drift structure
- Separate delta updates don't trigger manga updates

**Cons**:
- Multiple document reads (expensive in Firestore)
- Complex offline cache management
- No practical benefit (deltas always accessed with parent manga/page)

### Decision
✅ **Option A: Embed Deltas** in manga and page documents

### Rationale
1. **Firestore Best Practice**: Denormalization is standard for document databases when data is always accessed together
2. **Cost Optimization**: Reduces Firestore read operations by 80% (1 manga read vs 1 manga + 1 idea memo + N pages + 3N page deltas)
3. **Performance**: Single document fetch vs multiple queries improves offline performance
4. **Document Size**: Typical manga with 50 pages = ~250KB (well under 1MB limit)
5. **Simplicity**: Eliminates delta ID management and orphaned delta cleanup

### Implementation Strategy
- Store `ideaMemo` as `Map<String, dynamic>` directly in CloudManga
- Store `memoDelta`, `dialoguesDelta`, `stageDirectionDelta` as `Map<String, dynamic>` in CloudMangaPage
- Convert to/from Quill Delta in repository layer (maintain domain model interface)

### Alternatives Considered
- **Option B (Subcollection)**: Rejected due to cost and complexity with no offsetting benefit
- **Option C (Array of pages in manga doc)**: Rejected because Firestore queries on subcollections are more flexible (can paginate pages if needed)

---

## Research Area 3: Firestore Structure - Subcollection vs Array for Pages

### Question
Should manga pages be stored as a subcollection (`mangas/{id}/pages/{pageId}`) or as an array field in the manga document?

### Findings

**Option A: Subcollection** (Current approach)
```
users/{userId}/mangas/{mangaId}
└── pages/{pageId}
```

**Pros**:
- Scalable to unlimited pages (no document size limit)
- Can query/filter pages independently
- Allows fine-grained access control per page
- Can use Firestore's built-in ordering

**Cons**:
- Requires N+1 reads to fetch manga + all pages
- More complex offline cache coordination

**Option B: Array Field**
```json
{
  "id": "123",
  "name": "My Manga",
  "pages": [
    { "id": "p1", "pageIndex": 0, ... },
    { "id": "p2", "pageIndex": 1, ... }
  ]
}
```

**Pros**:
- Single read to fetch entire manga + pages
- Atomic updates for page reordering
- Simpler offline access

**Cons**:
- Document size limit (1MB) caps max pages (~200 pages with rich content)
- Cannot query individual pages efficiently
- Entire document re-downloaded on any page change (bandwidth waste)

### Decision
✅ **Option A: Subcollection** for pages

### Rationale
1. **Scalability**: No hard limit on pages per manga (future-proof for large projects)
2. **Update Efficiency**: Editing one page only syncs that page document, not entire manga
3. **Query Flexibility**: Can implement pagination if manga grows large
4. **Firestore Best Practice**: Use subcollections for one-to-many relationships with unbounded cardinality

### Implementation Strategy
- Manga pages stored at `users/{userId}/mangas/{mangaId}/pages/{pageId}`
- Repository layer batches reads: fetch manga + all pages in parallel
- Use Firestore snapshots to watch for real-time updates (if needed)

### Alternatives Considered
- **Option B (Array)**: Rejected due to document size limits and inefficient sync (full manga re-download on every page edit)

---

## Research Area 4: Migration Strategy - Data Migration Path

### Question
How do we migrate existing Drift SQLite data to Firestore without data loss?

### Findings

**Current Data Flow**:
1. App already has Firebase sync logic in `sync_state_notifier.dart`
2. `MangaRepository` has conversion methods: `toCloudManga()`, `toCloudMangaPage()`
3. User data may exist in local Drift DB but not yet synced to cloud

**Migration Approaches**:

**Option A: One-Time Bulk Migration**
```dart
Future<void> migrateDriftToFirebase() async {
  final allMangas = await driftDb.getAllMangas();
  for (final manga in allMangas) {
    await firebaseService.uploadManga(manga.toCloudManga());
    final pages = await driftDb.getPagesForManga(manga.id);
    for (final page in pages) {
      await firebaseService.uploadMangaPage(page.toCloudMangaPage());
    }
  }
}
```

**Pros**:
- Simple, one-time operation
- User triggered (clear UX)
- Can show progress

**Cons**:
- Requires user action
- Risk of data loss if user doesn't migrate

**Option B: Automatic Migration on First Launch**
- Check for existing Drift DB on app startup
- If found, automatically migrate to Firebase in background
- Delete local DB after successful migration

**Pros**:
- Transparent to user
- No data loss risk

**Cons**:
- Slower first launch after update
- Complex error handling

**Option C: No Migration (Fresh Start)**
- New Firebase-only version starts with empty data
- Users re-create manga projects

**Pros**:
- Simplest implementation

**Cons**:
- ❌ Unacceptable data loss for users

### Decision
✅ **Option B: Automatic Migration on First Launch**

### Rationale
1. **User Experience**: Zero user action required, transparent migration
2. **Data Safety**: No risk of users forgetting to migrate and losing work
3. **Acceptable Trade-off**: One-time slower startup is acceptable for data preservation

### Implementation Strategy
```dart
// In main.dart or repository initialization
Future<void> initializeApp() async {
  await Firebase.initializeApp();

  // Check if Drift DB exists
  final hasDriftData = await _checkDriftDbExists();

  if (hasDriftData) {
    // Show migration UI (progress indicator)
    await _migrateDriftToFirebase();
    // Verify migration success
    await _verifyMigration();
    // Delete old Drift DB
    await _deleteDriftDb();
  }

  // Continue with normal app startup (Firebase-only)
}
```

**Migration Safety**:
- Wrap in try-catch with rollback on failure
- Log migration progress for debugging
- Keep Drift DB until migration verified successful
- Show user-friendly error if migration fails (with retry option)

### Alternatives Considered
- **Option A (Manual)**: Rejected because users may forget to migrate, resulting in data loss
- **Option C (No migration)**: Rejected because losing user's manga projects is unacceptable

---

## Research Area 5: Firebase Authentication Requirements

### Question
What authentication method should be used? Is anonymous auth sufficient, or is Google Sign-In required?

### Findings

**Current Implementation**:
- `auth_service.dart` already implements Google Sign-In via `firebase_auth` + `google_sign_in`
- User data scoped to `users/{userId}/mangas/...`

**Authentication Options**:

**Option A: Google Sign-In (Current)**
```dart
await GoogleSignIn().signIn();
final credential = GoogleAuthProvider.credential(...);
await FirebaseAuth.instance.signInWithCredential(credential);
```

**Pros**:
- Already implemented
- Enables multi-device sync (same Google account on different devices)
- User identity for support/debugging

**Cons**:
- Requires Google account (barrier to entry)
- Privacy concerns for some users

**Option B: Firebase Anonymous Auth**
```dart
await FirebaseAuth.instance.signInAnonymously();
```

**Pros**:
- Zero-friction signup
- No PII collection

**Cons**:
- Cannot sync across devices (anonymous UID is device-specific)
- Data lost if app uninstalled without account upgrade

**Option C: Anonymous + Optional Google Link**
- Start with anonymous auth
- Allow user to upgrade to Google Sign-In later for multi-device sync

**Pros**:
- Best of both worlds (low friction + multi-device for power users)

**Cons**:
- More complex implementation
- Account linking edge cases

### Decision
✅ **Option A: Keep Google Sign-In** (current implementation)

### Rationale
1. **Already Implemented**: No additional work required
2. **User Expectation**: For a creative tool with cloud storage, sign-in is expected
3. **Multi-Device Sync**: Users expect to access manga projects on desktop + mobile
4. **Data Safety**: Prevents accidental data loss from app uninstall (anonymous auth risk)

### Implementation Strategy
- Keep existing `AuthService` and `AuthRepository`
- No changes needed to authentication flow
- Firebase rules already scope data to `users/{userId}`

### Alternatives Considered
- **Option B (Anonymous)**: Rejected because multi-device sync is valuable for creative workflows
- **Option C (Hybrid)**: Rejected due to complexity with minimal benefit (most users will want multi-device)

---

## Research Area 6: Firestore Pricing and Quotas

### Question
Are Firestore costs and quotas acceptable for the target user base?

### Findings

**Firestore Free Tier** (Spark Plan):
- 1 GB stored data
- 50K reads/day
- 20K writes/day
- 20K deletes/day
- 10 GB/month network egress

**Typical Manga Creator Usage**:
- 10 manga projects × 50 pages = 500 documents
- 500 docs × 5KB average = 2.5 MB stored (well under 1GB)
- Daily usage: ~100 reads (opening projects), ~50 writes (editing)
- Well under free tier limits

**Paid Tier** (Blaze Plan - Pay-as-you-go):
- $0.18 per GB stored/month
- $0.06 per 100K reads
- $0.18 per 100K writes
- For heavy user (1000 pages, 500 reads/day): ~$0.50/month

### Decision
✅ **Firestore pricing is acceptable** for target user base

### Rationale
1. Most users will stay within free tier
2. Heavy users incur <$1/month (acceptable for creative tool)
3. No need for quota management or rate limiting in app

### Implementation Strategy
- Start with Spark plan (free tier)
- Monitor usage via Firebase Console
- Optimize reads using Firestore snapshots (reactive updates instead of polling)

### Alternatives Considered
- **Self-hosted Firebase alternative (Supabase, Appwrite)**: Rejected because adds deployment complexity for minimal cost savings
- **Usage quotas in app**: Rejected because unnecessary complexity for free-tier usage

---

## Research Area 7: Offline Conflict Resolution Strategy

### Question
How will the system handle sync conflicts when the same content is edited on multiple devices while offline?

### Findings

**Firestore Default Behavior**:
- **Last-Write-Wins** at field level (not document level)
- Conflicting field updates: last write based on server timestamp
- Non-conflicting field updates: merged automatically

**Example Scenario**:
```
Device A (offline): Updates manga.name = "New Name"
Device B (offline): Updates manga.startPageDirection = "right"

After both sync:
- Both updates preserved (different fields)
- No conflict
```

**Conflict Scenario**:
```
Device A (offline): Updates page[0].memoDelta at 10:00
Device B (offline): Updates page[0].memoDelta at 10:05

After both sync:
- Device B's update wins (later timestamp)
- Device A's changes lost
```

**Firestore Transactions** (for critical updates):
```dart
await firestore.runTransaction((transaction) async {
  final snapshot = await transaction.get(docRef);
  transaction.update(docRef, {'field': newValue});
});
```

**Pros**:
- Atomic updates
- Retry on conflict

**Cons**:
- Requires online connection (fails when offline)

### Decision
✅ **Accept Last-Write-Wins for offline edits** + **User awareness** via UI

### Rationale
1. **Rare Conflict Scenario**: Users typically don't edit the same manga page on multiple devices simultaneously
2. **Firebase Limitation**: Transaction-based conflict resolution requires online connection (defeats offline purpose)
3. **Industry Standard**: Last-write-wins is standard for offline-first apps (Google Docs, Notion, etc.)
4. **UI Mitigation**: Show sync status indicator to inform user when changes are syncing

**User Education**:
- Document in help/FAQ: "Avoid editing the same page on multiple devices when offline"
- Show visual indicator when page was last synced
- Future enhancement: Implement edit locks (already have `lock_manager.dart` in codebase)

### Implementation Strategy
- Use Firestore's default last-write-wins
- Display sync status in UI (`sync_status_indicator.dart`)
- Keep `lock_manager.dart` for future enhancement (prevent simultaneous edits)
- Add "last modified" timestamp to UI for user awareness

### Alternatives Considered
- **Operational Transform (OT)**: Rejected due to complexity (requires custom conflict resolution logic for Quill Deltas)
- **CRDT (Conflict-free Replicated Data Types)**: Rejected because Firestore doesn't natively support CRDTs
- **Manual Conflict Resolution UI**: Rejected as over-engineering for rare scenario

---

## Research Area 8: Firestore Query Patterns for Repository Layer

### Question
What query patterns should the repository use to efficiently fetch manga data from Firestore?

### Findings

**Current Repository Interface** (Drift-based):
```dart
Stream<Manga?> getMangaStream(int id);
Stream<MangaPage?> getMangaPageStream(MangaPageId id);
Stream<List<Manga>> watchAllMangaList();
```

**Firestore Equivalent Queries**:

**1. Watch Single Manga** (reactive):
```dart
Stream<Manga?> getMangaStream(String id) {
  return firestore
    .collection('users').doc(userId)
    .collection('mangas').doc(id)
    .snapshots()
    .map((doc) => doc.exists ? CloudManga.fromFirestore(doc).toManga() : null);
}
```

**2. Watch All User Mangas** (reactive):
```dart
Stream<List<Manga>> watchAllMangaList() {
  return firestore
    .collection('users').doc(userId)
    .collection('mangas')
    .snapshots()
    .map((snapshot) => snapshot.docs.map((doc) =>
      CloudManga.fromFirestore(doc).toManga()
    ).toList());
}
```

**3. Fetch Manga with All Pages** (one-time):
```dart
Future<MangaWithPages> fetchMangaWithPages(String id) async {
  final manga = await firestore
    .collection('users').doc(userId)
    .collection('mangas').doc(id)
    .get();

  final pages = await firestore
    .collection('users').doc(userId)
    .collection('mangas').doc(id)
    .collection('pages')
    .orderBy('pageIndex')
    .get();

  return MangaWithPages(
    manga: CloudManga.fromFirestore(manga).toManga(),
    pages: pages.docs.map((doc) => CloudMangaPage.fromFirestore(doc).toMangaPage()).toList(),
  );
}
```

**Performance Optimization**:
- Use `snapshots()` for reactive UI updates (automatic cache when offline)
- Use `get()` for one-time fetches (queries cache first, then server)
- Firestore automatically uses local cache when offline

### Decision
✅ **Use Firestore snapshots for reactive streams** + **Cache-first queries**

### Rationale
1. Matches existing Drift `Stream<>` interface (minimal UI changes)
2. Firestore's cache-first behavior provides offline performance
3. Automatic reactivity reduces manual state management

### Implementation Strategy
```dart
class MangaRepository {
  Stream<Manga?> getMangaStream(String id) {
    return _firebaseService.watchManga(id);
  }

  Stream<List<Manga>> watchAllMangaList() {
    return _firebaseService.watchAllUserMangas();
  }

  // New: Fetch manga with pages together
  Future<void> loadMangaWithPages(String id) async {
    final result = await _firebaseService.fetchMangaWithPages(id);
    // Cache in memory or state management
  }
}
```

### Alternatives Considered
- **Future-based API**: Rejected because streams provide automatic reactivity for UI updates
- **Manual caching layer**: Rejected because Firestore handles caching automatically

---

## Research Area 9: Testing Strategy for Firebase Repository

### Question
How should we test the Firebase-based repository layer? Can we mock Firestore effectively?

### Findings

**Current Testing** (`manga_providers_test.dart`):
- Uses Mockito to mock `MangaDao` (Drift layer)
- Tests repository logic without real database

**Firestore Testing Options**:

**Option A: Mock FirebaseFirestore with Mockito**
```dart
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockDocumentReference extends Mock implements DocumentReference {}

test('fetchManga returns manga', () async {
  final mockFirestore = MockFirebaseFirestore();
  when(mockFirestore.collection('users').doc(userId).collection('mangas').doc(id).get())
    .thenAnswer((_) async => mockDocumentSnapshot);
  // ...
});
```

**Pros**:
- No external dependencies
- Fast tests

**Cons**:
- Complex mocking (Firestore API has many chained calls)
- Fragile tests (breaks if Firestore API changes)

**Option B: FakeFirebaseFirestore (fake_cloud_firestore package)**
```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

test('fetchManga returns manga', () async {
  final fakeFirestore = FakeFirebaseFirestore();
  await fakeFirestore.collection('users').doc(userId).collection('mangas').doc(id).set({...});

  final manga = await repository.fetchManga(id);
  expect(manga.name, equals('Test Manga'));
});
```

**Pros**:
- In-memory Firestore implementation
- Tests against realistic Firestore behavior
- Less brittle than mocking

**Cons**:
- Additional dependency
- Slightly slower than mocks

**Option C: Firebase Emulator Suite**
```dart
await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
await FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
```

**Pros**:
- Tests against real Firestore implementation
- Most accurate testing

**Cons**:
- Requires Java runtime + emulator setup
- Slower tests (network overhead)
- Complex CI/CD integration

### Decision
✅ **Option B: Use fake_cloud_firestore** for repository tests

### Rationale
1. Balance between accuracy and speed
2. Easier to maintain than complex Mockito chains
3. No external dependencies (emulator) for CI/CD
4. Good enough for unit testing (integration tests can use emulator if needed)

### Implementation Strategy
```dart
// pubspec.yaml
dev_dependencies:
  fake_cloud_firestore: ^2.5.0

// test/feature/manga/repository/manga_repository_test.dart
void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MangaRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = MangaRepository(firestore: fakeFirestore, ...);
  });

  test('fetchManga returns manga when exists', () async {
    await fakeFirestore.collection('users').doc('user1').collection('mangas').doc('manga1').set({
      'name': 'Test Manga',
      'startPageDirection': 'left',
      // ...
    });

    final manga = await repository.fetchManga('manga1');
    expect(manga?.name, equals('Test Manga'));
  });
}
```

### Alternatives Considered
- **Option A (Mockito)**: Rejected due to complexity and fragility
- **Option C (Emulator)**: Rejected for unit tests (reserved for integration tests)

---

## Summary of Decisions

| Area | Decision | Rationale |
|------|----------|-----------|
| **Offline Persistence** | Use Firestore native offline | Production-ready, automatic sync, platform support |
| **Data Model - Deltas** | Embed deltas in documents | Cost optimization, performance, Firestore best practice |
| **Data Model - Pages** | Use subcollection | Scalability, update efficiency, query flexibility |
| **Migration Strategy** | Automatic on first launch | Data safety, zero user action, acceptable UX trade-off |
| **Authentication** | Keep Google Sign-In | Multi-device sync, data safety, already implemented |
| **Pricing** | Accept Firestore free tier | Sufficient for target usage, low paid tier cost |
| **Conflict Resolution** | Last-write-wins + UI awareness | Industry standard, rare conflicts, acceptable trade-off |
| **Query Patterns** | Firestore snapshots (reactive) | Matches existing API, automatic caching, reactivity |
| **Testing** | fake_cloud_firestore | Balance accuracy/speed, maintainable, no emulator needed |

---

## Technology Decisions Summary

**Keep**:
- Firebase Core 3.8.0
- Cloud Firestore 5.5.0
- Firebase Auth 5.3.3
- Flutter Quill 11.4.0 (Delta format unchanged)
- Riverpod 3.0.0-dev.15
- Freezed 3.0.6 (domain models unchanged)

**Remove**:
- Drift 2.22.1
- Drift Flutter 0.2.3
- drift_dev 2.22.1 (dev dependency)

**Add**:
- fake_cloud_firestore ^2.5.0 (dev dependency for testing)

---

## Open Questions / Future Enhancements

1. **Edit Locking**: Current `lock_manager.dart` could prevent simultaneous edits on different devices - evaluate in Phase 1
2. **Offline Indicator**: Enhanced UI showing "last synced" timestamp - design in Phase 1
3. **Data Export**: Backup functionality to export manga projects as JSON - future feature
4. **Migration Rollback**: If Firestore migration fails critically, allow rollback to Drift - risk mitigation for Phase 2

---

## References

- [Firestore Offline Data](https://firebase.google.com/docs/firestore/manage-data/enable-offline)
- [Firestore Data Model](https://firebase.google.com/docs/firestore/data-model)
- [Firestore Pricing](https://firebase.google.com/docs/firestore/quotas)
- [Flutter Quill Delta Specification](https://quilljs.com/docs/delta/)
- [fake_cloud_firestore Package](https://pub.dev/packages/fake_cloud_firestore)
