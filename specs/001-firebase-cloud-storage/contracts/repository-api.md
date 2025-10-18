# Repository API Contract: Firebase Cloud Storage

**Feature**: Firebase Cloud Storage for My Manga Editor
**Date**: 2025-10-18
**Status**: Contract Defined

## Overview

This document defines the Dart repository interfaces and Riverpod providers for Firebase Cloud Storage integration. The API maintains compatibility with existing Drift-based interfaces while adapting to Firestore's async/reactive patterns.

---

## Repository Interface

### FirestoreMangaRepository

**Purpose**: Provide data access layer for manga and page operations using Firestore

**Location**: `lib/firebase/firestore/firestore_manga_repository.dart`

**Dependencies**:
- `cloud_firestore: ^5.0.0`
- `flutter_quill` for Delta types
- Freezed models: `Manga`, `MangaPage`

---

## Manga Operations

### createNewManga

```dart
Future<MangaId> createNewManga()
```

**Purpose**: Create a new manga with default values

**Behavior**:
- Generates new Firestore document with auto-ID
- Sets default name: "無名の傑作"
- Sets default startPage: `left`
- Initializes empty idea memo delta
- Sets createdAt and updatedAt to server timestamp

**Returns**: Firestore-generated manga ID (string)

**Firestore Operations**: 1 write

**Example**:
```dart
final mangaId = await ref.read(firestoreMangaRepositoryProvider).createNewManga();
// Returns: "abc123xyz789"
```

---

### watchManga

```dart
Stream<Manga?> watchManga(MangaId id)
```

**Purpose**: Reactive stream of manga document changes

**Parameters**:
- `id`: Manga document ID

**Behavior**:
- Returns Stream that emits on document changes
- Includes metadata changes for sync tracking (optional)
- Emits null if document doesn't exist
- Automatically handles offline mode

**Returns**: `Stream<Manga?>` - null if not found

**Firestore Operations**: 1 snapshot listener (continuous)

**Example**:
```dart
final mangaStream = ref.watch(watchMangaProvider(mangaId));
mangaStream.when(
  data: (manga) => manga != null ? Text(manga.name) : Text('Not found'),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

---

### watchAllMangaList

```dart
Stream<List<Manga>> watchAllMangaList(String userId)
```

**Purpose**: Reactive stream of all mangas for a user, ordered by last update

**Parameters**:
- `userId`: Firebase Auth UID

**Behavior**:
- Queries `/users/{userId}/mangas` collection
- Orders by `updatedAt` descending (most recent first)
- Returns empty list if user has no mangas
- Automatically updates when mangas added/removed/modified

**Returns**: `Stream<List<Manga>>`

**Firestore Operations**: 1 collection snapshot listener (continuous)

**Example**:
```dart
final mangasStream = ref.watch(watchAllMangaListProvider(userId));
```

---

### updateMangaName

```dart
Future<void> updateMangaName(MangaId id, String name)
```

**Purpose**: Update manga title

**Parameters**:
- `id`: Manga document ID
- `name`: New manga name (1-200 characters)

**Behavior**:
- Updates `name` field
- Updates `updatedAt` to server timestamp
- Throws if name is empty or >200 characters
- Works offline (queues write)

**Returns**: `Future<void>` - completes when write acknowledged

**Firestore Operations**: 1 write

**Example**:
```dart
await repository.updateMangaName(mangaId, '新しいタイトル');
```

---

### updateStartPage

```dart
Future<void> updateStartPage(MangaId id, MangaStartPage startPage)
```

**Purpose**: Update manga reading direction

**Parameters**:
- `id`: Manga document ID
- `startPage`: `MangaStartPage.left` or `MangaStartPage.right`

**Behavior**:
- Updates `startPage` field (stored as 'left' or 'right' string)
- Updates `updatedAt` to server timestamp
- Works offline

**Returns**: `Future<void>`

**Firestore Operations**: 1 write

**Example**:
```dart
await repository.updateStartPage(mangaId, MangaStartPage.right);
```

---

### deleteManga

```dart
Future<void> deleteManga(MangaId id, String userId)
```

**Purpose**: Delete manga and all its pages (cascade delete)

**Parameters**:
- `id`: Manga document ID
- `userId`: Owner user ID

**Behavior**:
- Deletes all pages in `/users/{userId}/mangas/{id}/pages` subcollection
- Deletes manga document
- Uses Firestore batch write for atomicity (max 500 pages)
- For >500 pages, uses multiple batches sequentially

**Returns**: `Future<void>`

**Firestore Operations**: 1+ batch writes (depends on page count)

**Example**:
```dart
await repository.deleteManga(mangaId, userId);
```

**Note**: Firestore doesn't cascade delete subcollections automatically. This method implements manual cascade.

---

## Page Operations

### createNewMangaPage

```dart
Future<MangaPageId> createNewMangaPage(MangaId mangaId, String userId)
```

**Purpose**: Create new page at end of manga

**Parameters**:
- `mangaId`: Parent manga ID
- `userId`: Owner user ID

**Behavior**:
- Queries existing pages to determine next `pageIndex`
- Creates page with `pageIndex = max(existing) + 1`
- Initializes all deltas as empty (`Delta()`)
- Sets timestamps to server time

**Returns**: Firestore-generated page ID

**Firestore Operations**: 1 read (get max pageIndex) + 1 write

**Example**:
```dart
final pageId = await repository.createNewMangaPage(mangaId, userId);
```

---

### watchMangaPage

```dart
Stream<MangaPage?> watchMangaPage(MangaId mangaId, MangaPageId pageId, String userId)
```

**Purpose**: Reactive stream of page document changes

**Parameters**:
- `mangaId`: Parent manga ID
- `pageId`: Page document ID
- `userId`: Owner user ID

**Behavior**:
- Returns Stream that emits on page changes
- Includes metadata for sync tracking
- Emits null if page doesn't exist
- Handles offline mode

**Returns**: `Stream<MangaPage?>`

**Firestore Operations**: 1 snapshot listener (continuous)

**Example**:
```dart
final pageStream = ref.watch(watchMangaPageProvider(mangaId, pageId, userId));
```

---

### watchAllMangaPageIdList

```dart
Stream<List<MangaPageId>> watchAllMangaPageIdList(MangaId mangaId, String userId)
```

**Purpose**: Reactive stream of page IDs in order

**Parameters**:
- `mangaId`: Parent manga ID
- `userId`: Owner user ID

**Behavior**:
- Queries `/users/{userId}/mangas/{mangaId}/pages` collection
- Orders by `pageIndex` ascending
- Returns only document IDs (lightweight query)
- Updates when pages added/removed/reordered

**Returns**: `Stream<List<MangaPageId>>`

**Firestore Operations**: 1 collection snapshot listener (continuous)

**Example**:
```dart
final pageIdsStream = ref.watch(watchAllMangaPageIdListProvider(mangaId, userId));
```

---

### updatePageDelta

```dart
Future<void> updatePageDelta(
  MangaId mangaId,
  MangaPageId pageId,
  String userId,
  String deltaField, // 'memoDelta' | 'stageDirectionDelta' | 'dialoguesDelta'
  Delta delta,
)
```

**Purpose**: Update specific delta field on a page

**Parameters**:
- `mangaId`: Parent manga ID
- `pageId`: Page document ID
- `userId`: Owner user ID
- `deltaField`: Which delta to update
- `delta`: New Quill Delta content

**Behavior**:
- Updates specified delta field with new ops array
- Converts Delta to `{"ops": [...]}` map structure
- Updates `updatedAt` to server timestamp
- Works offline (queued write)

**Returns**: `Future<void>`

**Firestore Operations**: 1 write

**Example**:
```dart
await repository.updatePageDelta(
  mangaId,
  pageId,
  userId,
  'memoDelta',
  myQuillController.document.toDelta(),
);
```

---

### reorderPages

```dart
Future<void> reorderPages(
  MangaId mangaId,
  String userId,
  List<MangaPageId> orderedPageIds,
)
```

**Purpose**: Update page order based on new arrangement

**Parameters**:
- `mangaId`: Parent manga ID
- `userId`: Owner user ID
- `orderedPageIds`: Page IDs in desired order

**Behavior**:
- Updates `pageIndex` for each page: `pageIndex = position in list`
- Uses Firestore batch write for atomicity
- Updates `updatedAt` for all modified pages
- Handles up to 500 pages (batch limit)

**Returns**: `Future<void>`

**Firestore Operations**: 1 batch write

**Example**:
```dart
final reorderedIds = [page3Id, page1Id, page2Id];
await repository.reorderPages(mangaId, userId, reorderedIds);
```

---

### deleteMangaPage

```dart
Future<void> deleteMangaPage(MangaId mangaId, MangaPageId pageId, String userId)
```

**Purpose**: Delete a single page

**Parameters**:
- `mangaId`: Parent manga ID
- `pageId`: Page document ID
- `userId`: Owner user ID

**Behavior**:
- Deletes page document from subcollection
- Embedded deltas are automatically deleted
- Does NOT reindex remaining pages (pageIndex values may have gaps)

**Returns**: `Future<void>`

**Firestore Operations**: 1 delete

**Example**:
```dart
await repository.deleteMangaPage(mangaId, pageId, userId);
```

**Note**: Consider calling `reorderPages` after deletion to remove gaps in pageIndex sequence.

---

## Export Operations

### toMarkdown

```dart
Future<String> toMarkdown(MangaId mangaId, String userId)
```

**Purpose**: Export manga to Markdown format for AI processing

**Parameters**:
- `mangaId`: Manga to export
- `userId`: Owner user ID

**Behavior**:
- Fetches manga and all pages
- Converts Quill Deltas to Markdown using `DeltaToMarkdown`
- Structures as: Title → Idea Memo → Page 1 (Memo → Dialogue → Stage Direction) → Page 2 → ...
- Returns complete Markdown string

**Returns**: `Future<String>` - Markdown formatted content

**Firestore Operations**: 1 read (manga) + N reads (pages)

**Example**:
```dart
final markdown = await repository.toMarkdown(mangaId, userId);
print(markdown);
// # 漫画タイトル
//
// アイデアメモ内容
//
// ## Page 1
// ### 描きたいこと
// ...
```

---

## Riverpod Providers

### Singleton Repository Provider

```dart
@Riverpod(keepAlive: true)
FirestoreMangaRepository firestoreMangaRepository(Ref ref) {
  return FirestoreMangaRepository(FirebaseFirestore.instance);
}
```

**Purpose**: Provide singleton repository instance

**Lifecycle**: Keep alive (never dispose)

**Usage**:
```dart
final repository = ref.read(firestoreMangaRepositoryProvider);
```

---

### Stream Providers

#### watchMangaProvider

```dart
@riverpod
Stream<Manga?> watchManga(Ref ref, MangaId mangaId, String userId) {
  return ref
      .watch(firestoreMangaRepositoryProvider)
      .watchManga(mangaId);
}
```

**Purpose**: Reactive provider for single manga

**Auto-dispose**: Yes (stops listening when no widgets watch)

**Usage**:
```dart
final mangaAsync = ref.watch(watchMangaProvider(mangaId, userId));
```

---

#### watchAllMangaListProvider

```dart
@riverpod
Stream<List<Manga>> watchAllMangaList(Ref ref, String userId) {
  return ref
      .watch(firestoreMangaRepositoryProvider)
      .watchAllMangaList(userId);
}
```

**Purpose**: Reactive provider for manga list

**Usage**:
```dart
final mangasAsync = ref.watch(watchAllMangaListProvider(userId));
```

---

#### watchMangaPageProvider

```dart
@riverpod
Stream<MangaPage?> watchMangaPage(
  Ref ref,
  MangaId mangaId,
  MangaPageId pageId,
  String userId,
) {
  return ref
      .watch(firestoreMangaRepositoryProvider)
      .watchMangaPage(mangaId, pageId, userId);
}
```

**Purpose**: Reactive provider for single page

**Usage**:
```dart
final pageAsync = ref.watch(watchMangaPageProvider(mangaId, pageId, userId));
```

---

#### watchAllMangaPageIdListProvider

```dart
@riverpod
Stream<List<MangaPageId>> watchAllMangaPageIdList(
  Ref ref,
  MangaId mangaId,
  String userId,
) {
  return ref
      .watch(firestoreMangaRepositoryProvider)
      .watchAllMangaPageIdList(mangaId, userId);
}
```

**Purpose**: Reactive provider for page ID list

**Usage**:
```dart
final pageIdsAsync = ref.watch(watchAllMangaPageIdListProvider(mangaId, userId));
```

---

## Error Handling

### Firebase Exceptions

```dart
try {
  await repository.updateMangaName(mangaId, newName);
} on FirebaseException catch (e) {
  switch (e.code) {
    case 'permission-denied':
      // User doesn't have access to this manga
      showError('アクセス権限がありません');
    case 'not-found':
      // Manga document doesn't exist
      showError('漫画が見つかりません');
    case 'resource-exhausted':
      // Firestore quota exceeded
      showError('ストレージ容量を超えています');
    case 'unauthenticated':
      // User not signed in
      navigateToLogin();
    default:
      // Generic error
      showError('エラーが発生しました: ${e.message}');
  }
}
```

### Network Errors

Repository methods work offline (writes are queued), but:
- Initial page load may fail if network unavailable and no cache
- Use connectivity monitoring to show offline status
- Firestore SDK handles retry logic automatically

---

## Performance Characteristics

### Read Operations

| Operation | Firestore Reads | Latency (Online) | Latency (Offline) |
|-----------|----------------|------------------|-------------------|
| watchManga | 1 | 50-200ms | <10ms (cache) |
| watchAllMangaList (100 mangas) | 100 | 200-500ms | <50ms (cache) |
| watchMangaPage | 1 | 50-200ms | <10ms (cache) |
| watchAllMangaPageIdList (1000 pages) | 1000 | 500-2000ms | <100ms (cache) |

**Cache Behavior**:
- First read fetches from server
- Subsequent reads served from cache
- Stream updates when server data changes
- Offline mode uses cache exclusively

### Write Operations

| Operation | Firestore Writes | Latency (Online) | Latency (Offline) |
|-----------|-----------------|------------------|-------------------|
| createNewManga | 1 | 100-300ms | Instant (queued) |
| updateMangaName | 1 | 100-300ms | Instant (queued) |
| updatePageDelta | 1 | 100-300ms | Instant (queued) |
| reorderPages (100 pages) | 1 batch (100 ops) | 200-500ms | Instant (queued) |
| deleteManga (with 100 pages) | 2 batches (101 ops) | 300-700ms | Instant (queued) |

**Offline Behavior**:
- Writes appear instant in UI (optimistic updates)
- Queued writes sync when connection restored
- `hasPendingWrites` metadata tracks sync status

---

## Migration Compatibility

### Drift API Mapping

| Drift Method | Firestore Equivalent |
|--------------|---------------------|
| `mangaDao.createNewManga()` | `repository.createNewManga()` |
| `mangaDao.watchManga(id)` | `repository.watchManga(id)` |
| `mangaDao.watchAllMangaList()` | `repository.watchAllMangaList(userId)` |
| `mangaDao.updateMangaName(id, name)` | `repository.updateMangaName(id, name)` |
| `mangaDao.deleteManga(id)` | `repository.deleteManga(id, userId)` |
| `mangaDao.createNewMangaPage(mangaId)` | `repository.createNewMangaPage(mangaId, userId)` |
| `mangaDao.watchMangaPage(id)` | `repository.watchMangaPage(mangaId, pageId, userId)` |
| `mangaDao.selectAllMangaPageIdList(mangaId)` | `repository.watchAllMangaPageIdList(mangaId, userId)` |
| `mangaDao.updateDelta(deltaId, delta)` | `repository.updatePageDelta(mangaId, pageId, userId, field, delta)` |
| `mangaDao.deleteMangaPage(id)` | `repository.deleteMangaPage(mangaId, pageId, userId)` |

**Key Differences**:
- All Firestore methods require `userId` parameter for security
- Drift returns `Future<T>`, Firestore often returns `Stream<T>` for reactive updates
- Foreign key references (delta IDs) become embedded data (no separate `updateDelta` for each field)

---

## Contract Summary

This API contract provides:
- ✅ **Type Safety**: All parameters and return types explicitly defined
- ✅ **Reactive Streams**: Real-time updates via Riverpod stream providers
- ✅ **Offline Support**: All operations work offline with automatic sync
- ✅ **Error Handling**: Comprehensive Firebase exception handling
- ✅ **Performance**: Optimized read/write operations with caching
- ✅ **Migration Path**: Clear mapping from Drift to Firestore methods

**Next**: See `quickstart.md` for implementation guide.
