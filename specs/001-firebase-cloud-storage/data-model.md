# Data Model: Firebase Cloud Storage

**Feature**: Firebase Cloud Storage for My Manga Editor
**Date**: 2025-10-18
**Status**: Design Complete

## Overview

This document defines the Firestore data model for storing manga content with user isolation, referential integrity, and Quill Delta preservation. The model maintains compatibility with existing Freezed models while adapting to Firestore's document-based structure.

---

## Collection Hierarchy

```
/users/{userId}
  ├─ email: string
  ├─ createdAt: timestamp
  └─ /mangas/{mangaId}
      ├─ name: string
      ├─ startPage: string ('left' | 'right')
      ├─ createdAt: timestamp
      ├─ updatedAt: timestamp
      └─ /pages/{pageId}
      │   ├─ pageIndex: number
      │   ├─ memoDelta: map (Quill Delta)
      │   ├─ stageDirectionDelta: map (Quill Delta)
      │   ├─ dialoguesDelta: map (Quill Delta)
      │   ├─ createdAt: timestamp
      │   └─ updatedAt: timestamp
      └─ /deltas/{deltaId}
          ├─ delta: map (Quill Delta)
          ├─ createdAt: timestamp
          └─ updatedAt: timestamp
```

---

## Entity Definitions

### 1. User Document

**Collection**: `/users`
**Document ID**: Firebase Auth UID
**Purpose**: Store user metadata and serve as parent for user-owned data

**Schema**:
```typescript
{
  email: string,              // User email from Firebase Auth
  createdAt: timestamp,       // Account creation time
  displayName?: string,       // Optional display name
  lastSignIn?: timestamp      // Last authentication time
}
```

**Validation Rules**:
- `email` must be valid email format
- `createdAt` required on creation
- Document ID must match authenticated user UID

**Access Pattern**: Read on app startup, updated on auth state changes

---

### 2. Manga Document

**Collection**: `/users/{userId}/mangas`
**Document ID**: Auto-generated Firestore ID
**Purpose**: Store manga metadata and serve as parent for pages

**Schema**:
```typescript
{
  name: string,               // Manga title (1-200 characters)
  startPage: 'left' | 'right', // Reading direction
  createdAt: timestamp,       // Creation time
  updatedAt: timestamp        // Last modification time
}
```

**Freezed Model**:
```dart
@freezed
class Manga with _$Manga {
  const factory Manga({
    required String id,
    required String name,
    required MangaStartPage startPage,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _Manga;

  factory Manga.fromJson(Map<String, dynamic> json) => _$MangaFromJson(json);
}

enum MangaStartPage {
  left,
  right;
}
```

**Validation Rules**:
- `name` required, 1-200 characters
- `startPage` must be 'left' or 'right'
- `createdAt` and `updatedAt` required timestamps
- Auto-update `updatedAt` on any field modification

**Indexes**:
- `updatedAt` (descending) for recent manga list

**Access Patterns**:
- List all mangas: `query.orderBy('updatedAt', descending: true)`
- Watch single manga: `doc(mangaId).snapshots()`

---

### 3. MangaPage Document

**Collection**: `/users/{userId}/mangas/{mangaId}/pages`
**Document ID**: Auto-generated Firestore ID
**Purpose**: Store page content with embedded Quill Deltas

**Schema**:
```typescript
{
  pageIndex: number,           // Page order (0-based)
  memoDelta: {
    ops: Array<{               // Quill Delta operations
      insert?: string,
      delete?: number,
      retain?: number,
      attributes?: object
    }>
  },
  stageDirectionDelta: {
    ops: Array<...>            // Same structure as memoDelta
  },
  dialoguesDelta: {
    ops: Array<...>            // Same structure as memoDelta
  },
  createdAt: timestamp,
  updatedAt: timestamp
}
```

**Freezed Model**:
```dart
@freezed
class MangaPage with _$MangaPage {
  const factory MangaPage({
    required String id,
    required int pageIndex,
    @DeltaConverter() required Delta memoDelta,
    @DeltaConverter() required Delta stageDirectionDelta,
    @DeltaConverter() required Delta dialoguesDelta,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _MangaPage;

  factory MangaPage.fromJson(Map<String, dynamic> json) =>
      _$MangaPageFromJson(json);
}

// Custom converter for Quill Delta
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

**Validation Rules**:
- `pageIndex` required, integer >= 0
- All delta fields required (can be empty Delta with `ops: []`)
- `createdAt` and `updatedAt` required timestamps
- Document size should not exceed 1MB (monitor in production)

**Indexes**:
- `pageIndex` (ascending) for ordered page list

**Access Patterns**:
- List all pages for manga: `collection('pages').orderBy('pageIndex')`
- Watch single page: `doc(pageId).snapshots()`
- Reorder pages: Batch update `pageIndex` values

---

### 4. Delta Document (Legacy Reference Storage)

**Collection**: `/users/{userId}/mangas/{mangaId}/deltas`
**Document ID**: Custom ID (e.g., `delta_{driftId}`) or auto-generated
**Purpose**: Store standalone deltas for idea memos or future versioning

**Schema**:
```typescript
{
  delta: {
    ops: Array<{               // Quill Delta operations
      insert?: string,
      delete?: number,
      retain?: number,
      attributes?: object
    }>
  },
  createdAt: timestamp,
  updatedAt: timestamp,
  type?: string                // Optional: 'idea_memo', 'version', etc.
}
```

**Freezed Model**:
```dart
@freezed
class FirestoreDelta with _$FirestoreDelta {
  const factory FirestoreDelta({
    required String id,
    @DeltaConverter() required Delta delta,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
    String? type,
  }) = _FirestoreDelta;

  factory FirestoreDelta.fromJson(Map<String, dynamic> json) =>
      _$FirestoreDeltaFromJson(json);
}
```

**Note**: In the recommended architecture, deltas are embedded in pages. This separate collection is maintained for:
- Idea memos at manga level (if not embedded in manga doc)
- Future delta versioning/history feature
- Migration compatibility (preserve Drift foreign key pattern)

---

## Migration Mapping

### Drift → Firestore Transformation

| Drift Table | Drift Column | Firestore Location | Firestore Field |
|-------------|--------------|-------------------|-----------------|
| `DbMangas` | `id` | `/users/{userId}/mangas/{mangaId}` | Document ID |
| `DbMangas` | `name` | Same | `name` |
| `DbMangas` | `startPage` | Same | `startPage` (enum → string) |
| `DbMangas` | `ideaMemo` (FK) | `/mangas/{mangaId}/deltas/{deltaId}` | Reference or embed in manga doc |
| `DbMangaPages` | `id` | `/mangas/{mangaId}/pages/{pageId}` | Document ID |
| `DbMangaPages` | `mangaId` (FK) | Same | Implicit (subcollection path) |
| `DbMangaPages` | `pageIndex` | Same | `pageIndex` |
| `DbMangaPages` | `memoDelta` (FK) | Same | `memoDelta` (embedded map) |
| `DbMangaPages` | `stageDirectionDelta` (FK) | Same | `stageDirectionDelta` (embedded map) |
| `DbMangaPages` | `dialoguesDelta` (FK) | Same | `dialoguesDelta` (embedded map) |
| `DbDeltas` | `id` | `/mangas/{mangaId}/deltas/{deltaId}` | Document ID |
| `DbDeltas` | `delta` (JSON text) | Same | `delta` (structured map) |

**Key Changes**:
- **Foreign Keys → Subcollections**: `mangaId` FK becomes subcollection path
- **Foreign Keys → Embedded Data**: Delta FKs become embedded maps in pages
- **Enum → String**: `MangaStartPage` enum stored as string value
- **JSON Text → Structured Map**: Delta JSON parsed and stored as native Firestore map
- **Auto-increment IDs → UUIDs**: Firestore auto-generates unique string IDs

---

## Data Relationships

### Parent-Child Relationships

```
User (Auth UID)
  └─ owns → Manga (1:N)
              └─ contains → MangaPage (1:N)
                              └─ embeds → Deltas (1:3)
```

**Cascade Delete Behavior**:
- Deleting user → NOT HANDLED (requires manual cleanup or Cloud Function)
- Deleting manga → Manually delete all pages subcollection (batch writes)
- Deleting page → Embedded deltas automatically deleted

**Referential Integrity**:
- Enforced by subcollection hierarchy (pages cannot exist without parent manga)
- Embedded deltas ensure no orphaned delta data
- User ID in path enforces owner isolation

---

## Quill Delta Structure

### Delta Format (embedded in pages)

```json
{
  "ops": [
    {
      "insert": "Plain text\n"
    },
    {
      "insert": "Bold text",
      "attributes": {
        "bold": true
      }
    },
    {
      "insert": "\n"
    },
    {
      "insert": "Heading",
      "attributes": {
        "header": 1
      }
    },
    {
      "insert": "\n"
    }
  ]
}
```

**Storage Considerations**:
- Store `ops` array as native Firestore list (not JSON string)
- Preserve attribute objects exactly as Quill generates them
- Empty delta: `{"ops": []}`
- Typical size: 1-10KB per delta
- Max size per page (3 deltas): ~30KB (well under 1MB document limit)

**Validation**:
- `ops` must be array
- Each op must have at least one of: `insert`, `delete`, `retain`
- `attributes` is optional object

---

## Data Constraints

### Document Size Limits

| Entity | Typical Size | Max Size (Firestore Limit) |
|--------|--------------|----------------------------|
| Manga | ~500 bytes | 1 MB |
| MangaPage (with 3 deltas) | 5-20 KB | 1 MB |
| Delta (standalone) | 1-10 KB | 1 MB |

**Mitigation for Large Deltas**:
- Monitor delta sizes in development
- Warn users if any delta exceeds 100 KB
- Implement pagination for extremely long text (rare)

### Collection Size Limits

- **Mangas per user**: No Firestore limit (practical: <1000 for UI performance)
- **Pages per manga**: No Firestore limit (practical: <1000 as per spec)
- **Deltas per manga**: No limit (only if using separate deltas collection)

---

## Indexes

### Required Indexes

```
Collection: /users/{userId}/mangas
- Field: updatedAt (Descending)
- Query: List recent mangas

Collection: /users/{userId}/mangas/{mangaId}/pages
- Field: pageIndex (Ascending)
- Query: List pages in order
```

### Optional Indexes (for future features)

```
Collection: /users/{userId}/mangas
- Field: name (Ascending)
- Query: Search mangas by name

Collection group: pages
- Fields: updatedAt (Descending), pageIndex (Ascending)
- Query: Recently edited pages across all mangas
```

---

## Validation Rules

### Firestore Security Rules (abbreviated)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    match /users/{userId} {
      allow read, write: if isOwner(userId);

      match /mangas/{mangaId} {
        allow read, write: if isOwner(userId);

        // Validate manga fields
        allow create: if request.resource.data.name is string
                      && request.resource.data.name.size() > 0
                      && request.resource.data.name.size() <= 200
                      && request.resource.data.startPage in ['left', 'right'];

        match /pages/{pageId} {
          allow read, write: if isOwner(userId);

          // Validate page fields
          allow create: if request.resource.data.pageIndex is int
                        && request.resource.data.pageIndex >= 0
                        && request.resource.data.memoDelta is map
                        && request.resource.data.stageDirectionDelta is map
                        && request.resource.data.dialoguesDelta is map;
        }

        match /deltas/{deltaId} {
          allow read, write: if isOwner(userId);

          allow create: if request.resource.data.delta is map
                        && request.resource.data.delta.ops is list;
        }
      }
    }
  }
}
```

---

## Example Documents

### Complete Manga Document

```json
{
  "id": "manga_abc123",
  "name": "無名の傑作",
  "startPage": "left",
  "createdAt": "2025-10-18T10:00:00Z",
  "updatedAt": "2025-10-18T15:30:00Z"
}
```

### Complete Page Document

```json
{
  "id": "page_xyz789",
  "pageIndex": 0,
  "memoDelta": {
    "ops": [
      {"insert": "描きたいこと\n", "attributes": {"bold": true}},
      {"insert": "主人公が決断する重要なシーン\n"}
    ]
  },
  "stageDirectionDelta": {
    "ops": [
      {"insert": "雨の降る夜の街角\n"}
    ]
  },
  "dialoguesDelta": {
    "ops": [
      {"insert": "「行くしかない」\n"}
    ]
  },
  "createdAt": "2025-10-18T10:05:00Z",
  "updatedAt": "2025-10-18T15:30:00Z"
}
```

---

## State Transitions

### Manga Lifecycle

```
[Create New Manga]
    ↓
[Empty Manga: name="無名の傑作", startPage="left", no pages]
    ↓
[Edit Manga Name]
    ↓
[Manga with Pages: 0-N pages in subcollection]
    ↓
[Delete Manga] → Cascade delete all pages (manual batch)
```

### Page Lifecycle

```
[Create New Page]
    ↓
[Empty Page: pageIndex=N, empty deltas]
    ↓
[Edit Page Deltas]
    ↓
[Reorder Pages] → Update pageIndex values
    ↓
[Delete Page] → Remove from subcollection
```

---

## Consistency Guarantees

### Firestore Consistency Model

- **Strong Consistency**: All reads reflect latest committed writes
- **Optimistic Concurrency**: Last write wins by default
- **Atomic Batch Writes**: Up to 500 operations per batch
- **No Cross-Document Transactions**: Each document write is atomic, but subcollection deletes require batching

### Application-Level Guarantees

- **User Isolation**: Security rules enforce user-scoped access
- **Referential Integrity**: Subcollection hierarchy prevents orphaned pages
- **Delta Integrity**: Embedded deltas prevent orphaned delta documents
- **Conflict Resolution**: Last-write-wins with server timestamp

---

## Summary

This data model provides:
- ✅ **User Isolation**: All data scoped under `/users/{userId}`
- ✅ **Hierarchical Structure**: Mangas → Pages → Deltas (embedded)
- ✅ **Quill Compatibility**: Preserves exact Delta format for editor
- ✅ **Migration Path**: Clear mapping from Drift to Firestore
- ✅ **Performance**: Embedded deltas reduce read operations
- ✅ **Scalability**: Handles 100 mangas × 1000 pages per user
- ✅ **Security**: Field validation and access control via rules

**Next**: See `contracts/` directory for repository API specifications.
