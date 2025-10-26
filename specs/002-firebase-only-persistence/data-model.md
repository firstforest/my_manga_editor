# Data Model: Firebase-Only Persistence

**Feature**: `002-firebase-only-persistence`
**Date**: 2025-10-25
**Status**: Complete

## Overview

This document defines the Firestore data model for manga persistence, replacing the Drift SQLite schema. The model follows Firestore best practices for document-oriented storage while maintaining compatibility with existing domain models (`Manga`, `MangaPage`).

---

## Firestore Collection Structure

```
firestore/
└── users/                           # Top-level collection
    └── {userId}/                    # User document (auto-created by auth)
        ├── profile: {...}           # (Future: user preferences)
        └── mangas/                  # User's manga collection
            └── {mangaId}/           # Manga document
                ├── (manga fields)
                └── pages/           # Pages subcollection
                    └── {pageId}/    # Page document
                        └── (page fields)
```

**Security Rules Scoping**:
- All data under `/users/{userId}` is accessible only by authenticated user with matching UID
- Firestore security rules enforce user isolation

---

## Entity 1: Manga (Cloud)

**Firestore Path**: `/users/{userId}/mangas/{mangaId}`

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | ✅ | Unique manga identifier (document ID) |
| `userId` | string | ✅ | Owner's Firebase Auth UID |
| `name` | string | ✅ | Manga project name (e.g., "無名の傑作") |
| `startPageDirection` | string | ✅ | Reading direction: `"left"` or `"right"` |
| `ideaMemo` | map | ✅ | Embedded Quill Delta for idea/concept memo |
| `createdAt` | timestamp | ✅ | Document creation time (server timestamp) |
| `updatedAt` | timestamp | ✅ | Last update time (server timestamp) |
| `editLock` | map | ❌ | (Optional) Edit lock info for multi-device conflict prevention |

### Field Details

**`ideaMemo` Structure** (Quill Delta):
```json
{
  "ops": [
    {"insert": "Main story concept: ...\n"},
    {"insert": "Character notes", "attributes": {"bold": true}},
    {"insert": "\n"}
  ]
}
```

**`editLock` Structure** (Optional):
```json
{
  "deviceId": "device_abc123",
  "userId": "user_xyz789",
  "lockedAt": "2025-10-25T10:30:00Z",
  "expiresAt": "2025-10-25T11:30:00Z"
}
```

### Validation Rules

- `name`: 1-100 characters
- `startPageDirection`: Must be `"left"` or `"right"`
- `ideaMemo.ops`: Valid Quill Delta array
- `createdAt`, `updatedAt`: Server-generated (not writable by client)

### Indexes

Default Firestore indexes sufficient (no complex queries on manga fields).

**Future optimization**: If querying by `updatedAt` for "recently edited" feature:
```
Collection: mangas
Fields: userId (Ascending), updatedAt (Descending)
```

---

## Entity 2: MangaPage (Cloud)

**Firestore Path**: `/users/{userId}/mangas/{mangaId}/pages/{pageId}`

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | ✅ | Unique page identifier (document ID) |
| `mangaId` | string | ✅ | Parent manga ID (for reference, matches subcollection path) |
| `pageIndex` | number | ✅ | Page order/position (0-indexed) |
| `memoDelta` | map | ✅ | Embedded Quill Delta for page memo ("描きたいこと") |
| `dialoguesDelta` | map | ✅ | Embedded Quill Delta for dialogues ("セリフ") |
| `stageDirectionDelta` | map | ✅ | Embedded Quill Delta for stage directions ("ト書き") |
| `createdAt` | timestamp | ✅ | Document creation time (server timestamp) |
| `updatedAt` | timestamp | ✅ | Last update time (server timestamp) |

### Field Details

**Delta Field Structures** (all follow same format):
```json
{
  "ops": [
    {"insert": "Page content here...\n"}
  ]
}
```

**Empty Delta** (for new pages):
```json
{
  "ops": []
}
```

### Validation Rules

- `pageIndex`: Non-negative integer
- `memoDelta.ops`, `dialoguesDelta.ops`, `stageDirectionDelta.ops`: Valid Quill Delta arrays
- `createdAt`, `updatedAt`: Server-generated

### Indexes

**Required Index** (for ordered page retrieval):
```
Collection: pages (collection group)
Fields: mangaId (Ascending), pageIndex (Ascending)
```

Or scoped to specific manga:
```
Collection: /users/{userId}/mangas/{mangaId}/pages
Fields: pageIndex (Ascending)
```

---

## Entity 3: User (Implicit)

**Firestore Path**: `/users/{userId}`

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | ❌ | User's email (from Firebase Auth, optional to store) |
| `displayName` | string | ❌ | User's display name (from Google Sign-In) |
| `createdAt` | timestamp | ✅ | Account creation time |
| `lastLoginAt` | timestamp | ✅ | Last login timestamp |

**Note**: User profile is managed by Firebase Auth. This document is optional and only needed for app-specific user preferences (future enhancement).

---

## Domain Model Mapping

### Current Domain Models (Freezed)

**`Manga` Model** (`lib/feature/manga/model/manga.dart`):
```dart
typedef MangaId = int;
typedef DeltaId = int;

@freezed
class Manga with _$Manga {
  const factory Manga({
    required MangaId id,        // int (will change to String for Firestore)
    required String name,
    required MangaStartPage startPage,
    required DeltaId ideaMemo,  // DeltaId (int reference to in-memory cache)
  }) = _Manga;
}
```

**`MangaPage` Model**:
```dart
typedef MangaPageId = int;

@freezed
class MangaPage with _$MangaPage {
  const factory MangaPage({
    required MangaPageId id,          // int (will change to String for Firestore)
    required DeltaId memoDelta,           // DeltaId (int reference)
    required DeltaId stageDirectionDelta, // DeltaId (int reference)
    required DeltaId dialoguesDelta,      // DeltaId (int reference)
  }) = _MangaPage;
}
```

### Migration Changes Required

**✅ SELECTED APPROACH: Minimal Changes with Delta Cache**

Keep domain model structure unchanged (DeltaId as int), use in-memory cache for Delta management:

```dart
// Domain model - MINIMAL CHANGES
typedef MangaId = String;      // Change: int → String (Firestore doc ID)
typedef MangaPageId = String;  // Change: int → String
typedef DeltaId = int;         // Keep: int (in-memory cache reference)

@freezed
class Manga with _$Manga {
  const factory Manga({
    required MangaId id,        // Changed to String
    required String name,
    required MangaStartPage startPage,
    required DeltaId ideaMemo,  // Unchanged: int DeltaId
  }) = _Manga;
}

@freezed
class MangaPage with _$MangaPage {
  const factory MangaPage({
    required MangaPageId id,          // Changed to String
    required DeltaId memoDelta,           // Unchanged: int DeltaId
    required DeltaId stageDirectionDelta, // Unchanged: int DeltaId
    required DeltaId dialoguesDelta,      // Unchanged: int DeltaId
  }) = _MangaPage;
}
```

**DeltaCache Architecture** (new component):

```dart
/// In-memory cache for Delta objects referenced by DeltaId
class DeltaCache {
  final Map<DeltaId, Delta> _cache = {};
  final Map<DeltaId, StreamController<Delta?>> _controllers = {};
  int _nextId = 1;

  /// Store a Delta and return its DeltaId
  DeltaId storeDelta(Delta delta) {
    final id = _nextId++;
    _cache[id] = delta;
    return id;
  }

  /// Get Delta by DeltaId
  Delta? getDelta(DeltaId id) => _cache[id];

  /// Get reactive stream for Delta updates
  Stream<Delta?> getDeltaStream(DeltaId id) {
    if (!_controllers.containsKey(id)) {
      _controllers[id] = StreamController<Delta?>.broadcast();
      _controllers[id]!.add(_cache[id]);
    }
    return _controllers[id]!.stream;
  }

  /// Update Delta and notify listeners
  void updateDelta(DeltaId id, Delta delta) {
    _cache[id] = delta;
    _controllers[id]?.add(delta);
  }
}
```

**Repository Conversion Layer**:

```dart
extension CloudMangaConversion on CloudManga {
  Manga toManga(DeltaCache cache) {
    // Convert embedded Delta map to DeltaId
    final ideaMemoOps = ideaMemo['ops'] as List? ?? [];
    final delta = Delta.fromJson(ideaMemoOps);
    final deltaId = cache.storeDelta(delta);  // Store in cache, get int ID

    return Manga(
      id: id,  // Already String in CloudManga
      name: name,
      startPage: MangaStartPageExt.fromString(startPageDirection),
      ideaMemo: deltaId,  // int DeltaId reference
    );
  }
}

extension MangaToCloudConversion on Manga {
  CloudManga toCloudManga(String userId, DeltaCache cache) {
    // Convert DeltaId to embedded Delta map
    final delta = cache.getDelta(ideaMemo);
    if (delta == null) {
      throw Exception('Delta not found in cache for DeltaId: $ideaMemo');
    }

    return CloudManga(
      id: id,
      userId: userId,
      name: name,
      startPageDirection: startPage.name,
      ideaMemo: {'ops': delta.toJson()},  // Embed Delta in Firestore
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      editLock: null,
    );
  }
}
```

### Rationale for Selected Approach

✅ **Why Delta Cache Pattern**:

1. **Minimal Domain Model Changes**: Only MangaId/MangaPageId change from int → String (required for Firestore). DeltaId remains int.
2. **UI Layer Compatibility**: Existing `getDeltaStream(DeltaId)` calls work unchanged
3. **Firestore Optimization**: Deltas embedded in Firestore documents (reduces read costs)
4. **Memory Efficiency**: Cache only active deltas, cleared on app restart
5. **Backwards Compatible**: Repository API maintains same signatures

**Migration Impact**:
- Update MangaId/MangaPageId typedefs in `manga.dart` (int → String)
- Create `DeltaCache` class in repository layer
- Update repository conversion methods to use cache
- UI layer: Change manga/page ID types from int → String, DeltaId usage unchanged
- Re-run `dart run build_runner build -d` for Freezed generation

---

## Data Relationships

### Current (Drift) vs New (Firestore)

**Current Architecture**:
```
DbMangas (1) ──┬──> DbDeltas (1) [ideaMemo]
               │
               └──> DbMangaPages (N)
                    ├──> DbDeltas (1) [memoDelta]
                    ├──> DbDeltas (1) [stageDirectionDelta]
                    └──> DbDeltas (1) [dialoguesDelta]
```

**New Architecture**:
```
CloudManga
├── ideaMemo: {...}           [embedded]
└── pages/ (subcollection)
    └── CloudMangaPage
        ├── memoDelta: {...}       [embedded]
        ├── dialoguesDelta: {...}  [embedded]
        └── stageDirectionDelta: {...} [embedded]
```

**Key Changes**:
- ❌ Removed: Separate `DbDeltas` table
- ✅ Added: Embedded delta objects in manga/page documents
- ✅ Added: Subcollection relationship for pages
- ✅ Benefit: Fewer Firestore reads (1 manga read vs 1 manga + 4 delta reads)

---

## Data Constraints & Limits

### Firestore Limits

| Constraint | Limit | Manga App Impact |
|------------|-------|------------------|
| Max document size | 1 MB | ✅ Typical manga doc: ~50 KB |
| Max subcollection depth | 100 levels | ✅ Only 1 level (pages) |
| Max writes per second | 1 per second per document | ✅ User edits slower than limit |
| Max field name length | 1,500 bytes | ✅ Short field names |

### Estimated Document Sizes

**Manga Document**:
- Metadata: ~200 bytes
- `ideaMemo` (typical): ~5 KB (500 characters formatted)
- Total: ~5.2 KB

**MangaPage Document**:
- Metadata: ~150 bytes
- `memoDelta` (typical): ~3 KB
- `dialoguesDelta` (typical): ~4 KB
- `stageDirectionDelta` (typical): ~3 KB
- Total: ~10 KB per page

**Project with 100 pages**:
- 1 manga doc: 5 KB
- 100 page docs: 1 MB
- **Total**: ~1 MB (within all limits)

---

## Data Access Patterns

### Pattern 1: Load All User Mangas (Grid View)

**Query**:
```dart
firestore.collection('users').doc(userId).collection('mangas').get()
```

**Expected Load**:
- User with 10 projects: 10 document reads
- Cached offline: 0 billable reads

**Optimization**: Use snapshots for reactive updates
```dart
firestore.collection('users').doc(userId).collection('mangas').snapshots()
```

### Pattern 2: Load Manga with All Pages (Editor View)

**Queries** (parallel):
```dart
// Manga document
firestore.collection('users').doc(userId).collection('mangas').doc(mangaId).get()

// All pages
firestore.collection('users').doc(userId).collection('mangas').doc(mangaId)
  .collection('pages').orderBy('pageIndex').get()
```

**Expected Load**:
- Manga with 50 pages: 51 document reads (1 manga + 50 pages)
- Cached offline: 0 billable reads (after initial load)

### Pattern 3: Update Single Page

**Write**:
```dart
firestore.collection('users').doc(userId).collection('mangas').doc(mangaId)
  .collection('pages').doc(pageId).update({
    'memoDelta': updatedDelta,
    'updatedAt': FieldValue.serverTimestamp(),
  })
```

**Cost**: 1 document write

**Offline Behavior**:
- Write queued locally (instant UI update)
- Synced when online
- Auto-retry on failure

### Pattern 4: Reorder Pages

**Batch Write**:
```dart
final batch = firestore.batch();
for (int i = 0; i < pageIds.length; i++) {
  batch.update(pageRef(pageIds[i]), {'pageIndex': i});
}
await batch.commit();
```

**Cost**: N document writes (where N = number of reordered pages)

**Optimization**: Only update changed indices
```dart
// If moving page 3 to position 0, only update pages 0-3
```

---

## Migration Data Mapping

### Drift → Firestore Field Mapping

**DbManga → CloudManga**:
```
id (int)              → id (string, convert via toString())
name (string)         → name (string)
startPage (enum)      → startPageDirection (string, use enum.name)
ideaMemo (int FK)     → ideaMemo (map, fetch delta and embed)
(none)                → userId (string, from current Firebase Auth)
(none)                → createdAt (timestamp, use current time)
(none)                → updatedAt (timestamp, use current time)
```

**DbMangaPage → CloudMangaPage**:
```
id (int)                   → id (string, convert via toString())
mangaId (int FK)           → mangaId (string, parent relationship)
pageIndex (int)            → pageIndex (number)
memoDelta (int FK)         → memoDelta (map, fetch delta and embed)
stageDirectionDelta (int FK) → stageDirectionDelta (map, fetch delta and embed)
dialoguesDelta (int FK)    → dialoguesDelta (map, fetch delta and embed)
(none)                     → createdAt (timestamp, use current time)
(none)                     → updatedAt (timestamp, use current time)
```

**DbDelta** (removed):
```
id (int PK)      → (embedded in parent document)
delta (JSON)     → (embedded as map in ideaMemo/memoDelta/etc.)
```

---

## Validation & Business Rules

### Application-Level Validation (in Repository)

**Manga Creation**:
```dart
Future<void> createManga(String name, MangaStartPage startPage) async {
  if (name.isEmpty || name.length > 100) {
    throw ValidationException('Name must be 1-100 characters');
  }

  final manga = CloudManga(
    id: generateId(),  // UUID or Firestore auto-ID
    userId: currentUserId,
    name: name,
    startPageDirection: startPage.name,
    ideaMemo: {'ops': []},  // Empty delta
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  await firebaseService.uploadManga(manga);
}
```

**Page Reordering**:
```dart
Future<void> reorderPages(List<String> pageIds) async {
  if (pageIds.isEmpty) return;

  // Validate all pages belong to same manga
  final pages = await fetchPages(pageIds);
  if (pages.map((p) => p.mangaId).toSet().length > 1) {
    throw ValidationException('Cannot reorder pages from different mangas');
  }

  // Update pageIndex in batch
  // ...
}
```

### Firestore Security Rules Validation

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User data isolation
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // Manga documents
      match /mangas/{mangaId} {
        allow read, write: if request.auth.uid == userId;

        // Validate manga fields
        allow create, update: if
          request.resource.data.name is string &&
          request.resource.data.name.size() > 0 &&
          request.resource.data.name.size() <= 100 &&
          request.resource.data.startPageDirection in ['left', 'right'] &&
          request.resource.data.ideaMemo is map &&
          request.resource.data.ideaMemo.ops is list;

        // Page subcollection
        match /pages/{pageId} {
          allow read, write: if request.auth.uid == userId;

          // Validate page fields
          allow create, update: if
            request.resource.data.pageIndex is int &&
            request.resource.data.pageIndex >= 0 &&
            request.resource.data.memoDelta is map &&
            request.resource.data.dialoguesDelta is map &&
            request.resource.data.stageDirectionDelta is map;
        }
      }
    }
  }
}
```

---

## Comparison Summary

| Aspect | Drift (Current) | Firestore (New) |
|--------|----------------|-----------------|
| **Storage** | SQLite on device | Cloud + local cache |
| **Data Structure** | Normalized (FK references) | Denormalized (embedded) |
| **Offline** | Full (but limited to device) | Full (automatic sync) |
| **Multi-Device** | Requires manual sync | Automatic |
| **Deltas** | Separate table (DbDeltas) | Embedded in docs |
| **Queries** | SQL joins | Document/subcollection reads |
| **Cost** | Free (local storage) | Free tier sufficient |
| **Complexity** | Higher (manual sync) | Lower (automatic) |

---

## Open Questions

1. ✅ **Delta embedding**: Resolved - embed deltas in documents
2. ✅ **Page storage**: Resolved - use subcollections
3. ⚠️ **Edit locking**: Keep `editLock` field structure for future enhancement?
   - **Decision**: Keep field definition, implement locking in Phase 2 if needed
4. ⚠️ **User profile document**: Create on first auth or lazy create?
   - **Decision**: Lazy create when needed (future feature)

---

## Next Steps (Phase 1)

1. ✅ Define Firestore data model (this document)
2. ⏭️ Generate API contracts (`contracts/repository_api.md`)
3. ⏭️ Create quickstart guide for Firestore setup
4. ⏭️ Update domain models (`Manga`, `MangaPage`) to use `Delta` directly
5. ⏭️ Implement repository conversion methods
