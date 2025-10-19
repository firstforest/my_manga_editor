# Data Model: Firebase Cloud Sync

**Feature**: 001-firebase-cloud-sync
**Date**: 2025-10-19
**Purpose**: Define Firestore and Flutter data models for cloud synchronization

## Overview

This document defines three layers of data models:
1. **Firestore Schema**: Cloud storage structure
2. **Cloud Models** (`CloudManga`, etc.): Dart models for Firebase service layer
3. **Sync Models**: Supporting models for sync state and locks

The existing domain models (`Manga`, `MangaPage`) and database models (`DbManga`, `DbMangaPage`, `DbDelta`) remain unchanged per architecture requirements.

---

## 1. Firestore Schema

### Collection Structure

```
/users/{uid}/
  └── mangas/{mangaId}/
      ├── Document Fields (see CloudManga)
      └── pages/{pageId}/
          └── Document Fields (see CloudMangaPage)
```

### Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User-scoped manga collections
    match /users/{userId}/mangas/{mangaId} {
      // Only authenticated users can access their own mangas
      allow read, write: if request.auth != null &&
                            request.auth.uid == userId;

      // Subcollections inherit parent rules
      match /pages/{pageId} {
        allow read, write: if request.auth.uid == userId;
      }
    }
  }
}
```

---

## 2. Cloud Models (Service Layer)

### 2.1 CloudManga

**Purpose**: Represents a manga project in Firestore

**Dart Model** (`lib/service/firebase/model/cloud_manga.dart`):

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_quill/quill_delta.dart';

part 'cloud_manga.freezed.dart';
part 'cloud_manga.g.dart';

@freezed
class CloudManga with _$CloudManga {
  const factory CloudManga({
    required String id,                    // Firestore document ID
    required String userId,                // Owner UID
    required String name,                  // Manga title
    required String startPageDirection,    // 'left' or 'right'
    required Map<String, dynamic> ideaMemo, // Quill Delta as Map
    required DateTime createdAt,           // Creation timestamp
    required DateTime updatedAt,           // Last modification timestamp
    @JsonKey(name: 'editLock') EditLock? editLock, // Optional edit lock
  }) = _CloudManga;

  factory CloudManga.fromJson(Map<String, dynamic> json) =>
      _$CloudMangaFromJson(json);

  // Convert Firestore DocumentSnapshot to CloudManga
  factory CloudManga.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return CloudManga(
      id: snapshot.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      startPageDirection: data['startPageDirection'] as String,
      ideaMemo: data['ideaMemo'] as Map<String, dynamic>,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      editLock: data['editLock'] != null
          ? EditLock.fromJson(data['editLock'] as Map<String, dynamic>)
          : null,
    );
  }

  // Convert CloudManga to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'startPageDirection': startPageDirection,
      'ideaMemo': ideaMemo,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (editLock != null) 'editLock': editLock!.toJson(),
    };
  }
}
```

**Firestore Document Fields**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| userId | string | Yes | Owner's Firebase auth UID |
| name | string | Yes | Manga title |
| startPageDirection | string | Yes | 'left' or 'right' reading direction |
| ideaMemo | map | Yes | Quill Delta JSON for idea memo |
| createdAt | timestamp | Yes | Document creation time (server timestamp) |
| updatedAt | timestamp | Yes | Last modification time (server timestamp) |
| editLock | map | No | Lock information (see EditLock) |

**Validation Rules**:
- `userId` must match authenticated user UID
- `name` length: 1-200 characters
- `startPageDirection`: enum ('left', 'right')
- `ideaMemo`: valid Quill Delta structure
- `updatedAt` >= `createdAt`

---

### 2.2 CloudMangaPage

**Purpose**: Represents a single page within a manga

**Dart Model** (`lib/service/firebase/model/cloud_manga_page.dart`):

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cloud_manga_page.freezed.dart';
part 'cloud_manga_page.g.dart';

@freezed
class CloudMangaPage with _$CloudMangaPage {
  const factory CloudMangaPage({
    required String id,                           // Firestore document ID
    required String mangaId,                      // Parent manga ID
    required int pageIndex,                       // Page order (0-based)
    required Map<String, dynamic> memoDelta,      // Quill Delta for memo
    required Map<String, dynamic> stageDirectionDelta, // Quill Delta for stage directions
    required Map<String, dynamic> dialoguesDelta, // Quill Delta for dialogues
    required DateTime createdAt,                  // Creation timestamp
    required DateTime updatedAt,                  // Last modification timestamp
  }) = _CloudMangaPage;

  factory CloudMangaPage.fromJson(Map<String, dynamic> json) =>
      _$CloudMangaPageFromJson(json);

  factory CloudMangaPage.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    String mangaId,
  ) {
    final data = snapshot.data()!;
    return CloudMangaPage(
      id: snapshot.id,
      mangaId: mangaId,
      pageIndex: data['pageIndex'] as int,
      memoDelta: data['memoDelta'] as Map<String, dynamic>,
      stageDirectionDelta: data['stageDirectionDelta'] as Map<String, dynamic>,
      dialoguesDelta: data['dialoguesDelta'] as Map<String, dynamic>,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'pageIndex': pageIndex,
      'memoDelta': memoDelta,
      'stageDirectionDelta': stageDirectionDelta,
      'dialoguesDelta': dialoguesDelta,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
```

**Firestore Document Fields**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| pageIndex | number | Yes | Zero-based page order within manga |
| memoDelta | map | Yes | Quill Delta JSON for memo field |
| stageDirectionDelta | map | Yes | Quill Delta JSON for stage directions |
| dialoguesDelta | map | Yes | Quill Delta JSON for dialogues |
| createdAt | timestamp | Yes | Document creation time |
| updatedAt | timestamp | Yes | Last modification time |

**Validation Rules**:
- `pageIndex` >= 0
- All delta fields: valid Quill Delta structure
- `updatedAt` >= `createdAt`

---

### 2.3 EditLock

**Purpose**: Represents exclusive editing rights for a manga

**Dart Model** (`lib/service/firebase/model/edit_lock.dart`):

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_lock.freezed.dart';
part 'edit_lock.g.dart';

@freezed
class EditLock with _$EditLock {
  const factory EditLock({
    required String lockedBy,     // User UID who holds the lock
    required DateTime lockedAt,   // Lock acquisition time
    required DateTime expiresAt,  // Lock expiration time (TTL)
    required String deviceId,     // Device identifier
  }) = _EditLock;

  factory EditLock.fromJson(Map<String, dynamic> json) =>
      _$EditLockFromJson(json);

  // Helper to check if lock is still valid
  const EditLock._();

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool isOwnedBy(String userId) => lockedBy == userId && !isExpired;
}
```

**Firestore Embedded Map** (within CloudManga document):

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| lockedBy | string | Yes | Firebase UID of lock holder |
| lockedAt | timestamp | Yes | Lock acquisition timestamp |
| expiresAt | timestamp | Yes | Lock expiration timestamp (60s from acquisition) |
| deviceId | string | Yes | Unique device identifier |

**Validation Rules**:
- `lockedBy`: valid Firebase UID
- `expiresAt` > `lockedAt`
- Lock duration: 60 seconds (configurable)

---

## 3. Sync State Models

### 3.1 SyncStatus

**Purpose**: Represents synchronization status for a manga

**Dart Model** (`lib/feature/manga/model/sync_status.dart`):

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_status.freezed.dart';

enum SyncState {
  synced,    // Fully synchronized with cloud
  syncing,   // Sync in progress
  pending,   // Waiting to sync
  error,     // Sync failed
  offline,   // User offline, sync paused
}

@freezed
class SyncStatus with _$SyncStatus {
  const factory SyncStatus({
    required SyncState state,
    DateTime? lastSyncedAt,    // Null if never synced
    String? errorMessage,       // Null if no error
    int? pendingOperations,     // Count of operations in queue
  }) = _SyncStatus;
}
```

---

### 3.2 SyncQueueEntry

**Purpose**: Represents a pending sync operation in SQLite queue

**Dart Model** (`lib/service/firebase/model/sync_queue_entry.dart`):

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_queue_entry.freezed.dart';
part 'sync_queue_entry.g.dart';

enum SyncOperationType {
  create,
  update,
  delete,
}

enum SyncQueueStatus {
  pending,
  syncing,
  completed,
  failed,
}

@freezed
class SyncQueueEntry with _$SyncQueueEntry {
  const factory SyncQueueEntry({
    required int id,                             // SQLite auto-increment ID
    required SyncOperationType operationType,    // CRUD operation type
    required String collectionPath,              // Firestore collection path
    required String? documentId,                 // Document ID (null for create)
    required Map<String, dynamic>? data,         // JSON payload
    required DateTime timestamp,                 // Queue entry creation time
    @Default(0) int retryCount,                  // Number of retry attempts
    @Default(SyncQueueStatus.pending) SyncQueueStatus status,
  }) = _SyncQueueEntry;

  factory SyncQueueEntry.fromJson(Map<String, dynamic> json) =>
      _$SyncQueueEntryFromJson(json);
}
```

**SQLite Schema**:

```sql
CREATE TABLE sync_queue (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  operation_type TEXT NOT NULL,
  collection_path TEXT NOT NULL,
  document_id TEXT,
  data TEXT, -- JSON string
  timestamp INTEGER NOT NULL,
  retry_count INTEGER DEFAULT 0,
  status TEXT DEFAULT 'pending'
);

CREATE INDEX idx_sync_queue_status ON sync_queue(status);
CREATE INDEX idx_sync_queue_timestamp ON sync_queue(timestamp);
```

---

## 4. Entity Relationships

### 4.1 Firestore Relationships

```
User (Firebase Auth)
  └── /users/{uid}/mangas/                [1:N]
      └── {mangaId}/
          ├── ideaMemo: Map                 [embedded]
          ├── editLock: EditLock?          [embedded, optional]
          └── pages/                        [1:N subcollection]
              └── {pageId}/
                  ├── memoDelta: Map       [embedded]
                  ├── stageDirectionDelta: Map [embedded]
                  └── dialoguesDelta: Map  [embedded]
```

### 4.2 Domain Model Mappings

**CloudManga ↔ Manga ↔ DbManga**:

```
CloudManga (Firestore)     Manga (Domain)          DbManga (SQLite)
├── id                 →   ├── id              →   ├── id
├── name               →   ├── name            →   ├── name
├── startPageDirection →   ├── startPage       →   ├── startPage
├── ideaMemo (Map)     →   ├── ideaMemo (id)   →   ├── ideaMemo (FK)
├── userId                 │                       │
├── createdAt              │                       │
├── updatedAt              │                       │
└── editLock               │                       │
                           └──                   →  └──
```

**CloudMangaPage ↔ MangaPage ↔ DbMangaPage**:

```
CloudMangaPage (Firestore)   MangaPage (Domain)      DbMangaPage (SQLite)
├── id                    →  ├── id               →  ├── id
├── pageIndex             →  │                       ├── pageIndex
├── memoDelta (Map)       →  ├── memoDelta (id)   →  ├── memoDelta (FK)
├── stageDirectionDelta   →  ├── stageDirectionDelta →  ├── stageDirectionDelta (FK)
├── dialoguesDelta (Map)  →  └── dialoguesDelta   →  └── dialoguesDelta (FK)
├── mangaId                  │                       ├── mangaId (FK)
├── createdAt                │                       │
└── updatedAt                │                       │
```

---

## 5. Conversion Logic

### 5.1 CloudManga → Manga

**Location**: `lib/feature/manga/repository/manga_repository.dart`

```dart
extension CloudMangaExt on CloudManga {
  Future<Manga> toManga(MangaRepository repo) async {
    // Convert Delta Map back to DeltaId by upserting to local DB
    final ideaMemoId = await repo.upsertDeltaFromMap(ideaMemo);

    return Manga(
      id: int.parse(id), // Firestore string ID → SQLite int ID
      name: name,
      startPage: MangaStartPage.values.firstWhere(
        (e) => e.name == startPageDirection,
      ),
      ideaMemo: ideaMemoId,
    );
  }
}
```

### 5.2 Manga → CloudManga

**Location**: `lib/feature/manga/repository/manga_repository.dart`

```dart
extension MangaExt on Manga {
  Future<CloudManga> toCloudManga(
    MangaRepository repo,
    String userId,
  ) async {
    // Fetch Delta from local DB and convert to Map
    final ideaMemoMap = await repo.getDeltaAsMap(ideaMemo);

    return CloudManga(
      id: id.toString(), // SQLite int ID → Firestore string ID
      userId: userId,
      name: name,
      startPageDirection: startPage.name,
      ideaMemo: ideaMemoMap,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      editLock: null,
    );
  }
}
```

### 5.3 Delta Map ↔ DeltaId

**Helper Methods** (`lib/feature/manga/repository/manga_repository.dart`):

```dart
// Convert Quill Delta to Map (for Cloud)
Future<Map<String, dynamic>> getDeltaAsMap(DeltaId id) async {
  final delta = await getDeltaStream(id).first;
  return delta?.toJson() ?? {};
}

// Convert Map to Quill Delta and insert to local DB
Future<DeltaId> upsertDeltaFromMap(Map<String, dynamic> deltaMap) async {
  final delta = Delta.fromJson(deltaMap);
  return await _ref.watch(mangaDaoProvider).upsertDelta(
    DbDeltasCompanion.insert(delta: delta),
  );
}
```

---

## 6. State Transitions

### 6.1 Sync State Machine

```
[offline] → (connect) → [pending] → (sync start) → [syncing]
                                                        ↓
                         (sync success) ← [synced] ←──┘
                                             ↓
                         (local change) → [pending]

                         (sync fail) → [error] → (retry) → [pending]
                                         ↓
                         (max retries) → [failed] (user action required)
```

### 6.2 Edit Lock Lifecycle

```
[unlocked] → (acquire) → [locked]
                            ↓
              (heartbeat) → [locked] (refresh)
                            ↓
              (release) → [unlocked]
                            ↓
              (expire) → [unlocked] (after 60s)
                            ↓
              (network loss) → [unknown] → (reconnect) → [reacquire attempt]
```

---

## 7. Data Validation

### 7.1 Firestore Security Rules

```javascript
function isValidManga(manga) {
  return manga.keys().hasAll(['userId', 'name', 'startPageDirection', 'ideaMemo', 'createdAt', 'updatedAt']) &&
         manga.userId is string &&
         manga.name is string &&
         manga.name.size() >= 1 &&
         manga.name.size() <= 200 &&
         manga.startPageDirection in ['left', 'right'] &&
         manga.ideaMemo is map &&
         manga.createdAt is timestamp &&
         manga.updatedAt is timestamp &&
         manga.updatedAt >= manga.createdAt;
}

function isValidPage(page) {
  return page.keys().hasAll(['pageIndex', 'memoDelta', 'stageDirectionDelta', 'dialoguesDelta', 'createdAt', 'updatedAt']) &&
         page.pageIndex is int &&
         page.pageIndex >= 0 &&
         page.memoDelta is map &&
         page.stageDirectionDelta is map &&
         page.dialoguesDelta is map &&
         page.createdAt is timestamp &&
         page.updatedAt is timestamp;
}
```

### 7.2 Client-Side Validation

**Manga Validation**:
```dart
class MangaValidator {
  static const int maxNameLength = 200;

  static String? validateName(String name) {
    if (name.isEmpty) return 'Name cannot be empty';
    if (name.length > maxNameLength) return 'Name too long (max $maxNameLength)';
    return null;
  }

  static String? validateStartPage(String direction) {
    if (!['left', 'right'].contains(direction)) {
      return 'Invalid start page direction';
    }
    return null;
  }
}
```

---

## 8. Indexing Strategy

### 8.1 Firestore Indexes

**Automatic Single-Field Indexes** (enabled by default):
- `userId` (ascending/descending)
- `updatedAt` (ascending/descending)
- `createdAt` (ascending/descending)
- `pageIndex` (ascending/descending)

**Composite Indexes** (create manually):

```
Collection: users/{userId}/mangas
Fields: updatedAt (Descending), __name__ (Ascending)
Purpose: Get mangas sorted by last modified

Collection Group: pages
Fields: userId (Ascending), pageIndex (Ascending)
Purpose: Cross-manga page queries (if needed)
```

### 8.2 SQLite Indexes

```sql
-- Sync queue indexes
CREATE INDEX idx_sync_queue_status ON sync_queue(status);
CREATE INDEX idx_sync_queue_timestamp ON sync_queue(timestamp);
CREATE INDEX idx_sync_queue_retry ON sync_queue(retry_count);

-- Existing DB indexes (no changes)
```

---

## Summary

**New Models to Create**:
1. `CloudManga` (service layer)
2. `CloudMangaPage` (service layer)
3. `EditLock` (embedded in CloudManga)
4. `SyncStatus` (domain layer)
5. `SyncQueueEntry` (service layer)

**Existing Models (No Changes)**:
- `Manga` (domain model)
- `MangaPage` (domain model)
- `DbManga` (database model)
- `DbMangaPage` (database model)
- `DbDelta` (database model)

**Conversion Responsibilities**:
- Repository layer handles all CloudModel ↔ Domain model conversions
- Service layer only works with Cloud models
- Presentation layer only works with Domain models

**Key Design Principles**:
- User-scoped Firestore collections for security
- Subcollections for scalability
- Native Map storage for Quill Deltas
- TTL-based locks with heartbeat renewal
- Persistent sync queue in SQLite
- Strict layer separation per constitution
