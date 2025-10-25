# Repository API Contract

**Feature**: `002-firebase-only-persistence`
**Date**: 2025-10-25
**Version**: 1.0.0

## Overview

This document defines the contract between the Repository Layer and UI Layer (Presentation) for the Firebase-only persistence architecture. The API maintains backwards compatibility with the existing Drift-based interface while migrating to Firestore internally.

---

## Design Principles

1. **Interface Stability**: UI components should not require changes (or minimal changes)
2. **Stream-Based**: Reactive data access using Dart `Stream<>` for automatic UI updates
3. **Error Handling**: Typed exceptions for offline, auth, and Firestore errors
4. **Type Safety**: Strong typing with Freezed domain models
5. **Offline-First**: All operations work offline, sync when connected

---

## Domain Models

### Manga

```dart
@freezed
class Manga with _$Manga {
  const factory Manga({
    required String id,           // Changed: String (was int)
    required String name,
    required MangaStartPage startPage,
    required Delta ideaMemo,      // Changed: Delta object (was int DeltaId)
  }) = _Manga;

  factory Manga.fromJson(Map<String, dynamic> json) => _$MangaFromJson(json);
}

enum MangaStartPage {
  left,   // 左開き (left-to-right reading)
  right,  // 右開き (right-to-left reading)
}
```

**Breaking Changes**:
- `id`: `int` → `String` (Firestore document IDs are strings)
- `ideaMemo`: `int` (DeltaId foreign key) → `Delta` (direct object)

**Migration Strategy**:
- Update all UI code referencing `manga.id` to handle `String` type
- Update all UI code using `ideaMemo` to use `Delta` directly (no repository lookup needed)

### MangaPage

```dart
@freezed
class MangaPage with _$MangaPage {
  const factory MangaPage({
    required String id,                   // Changed: String (was int)
    required Delta memoDelta,             // Changed: Delta object (was int DeltaId)
    required Delta stageDirectionDelta,   // Changed: Delta object (was int DeltaId)
    required Delta dialoguesDelta,        // Changed: Delta object (was int DeltaId)
  }) = _MangaPage;

  factory MangaPage.fromJson(Map<String, dynamic> json) => _$MangaPageFromJson(json);
}
```

**Breaking Changes**:
- `id`: `int` → `String`
- All delta fields: `int` → `Delta` object

### SyncStatus (New)

```dart
@freezed
class SyncStatus with _$SyncStatus {
  const factory SyncStatus({
    required bool isOnline,
    required bool isSyncing,
    required DateTime? lastSyncedAt,
    @Default([]) List<String> pendingMangaIds,
  }) = _SyncStatus;
}
```

**Purpose**: Provide sync status to UI for status indicator widget

---

## Repository Interface

### MangaRepository

```dart
@Riverpod(keepAlive: true)
class MangaRepository {
  MangaRepository({
    required FirebaseService firebaseService,
    required AuthService authService,
  });

  // ============================================================================
  // Manga CRUD Operations
  // ============================================================================

  /// Create a new manga project
  /// Returns the manga ID (Firestore document ID)
  /// Throws: AuthException if user not authenticated
  Future<String> createNewManga({String name = '無名の傑作'}) async;

  /// Watch a specific manga by ID (reactive)
  /// Returns null if manga doesn't exist or user doesn't have access
  /// Emits updates when manga changes (local or remote)
  Stream<Manga?> getMangaStream(String id);

  /// Watch all user's manga projects (reactive)
  /// Emits updates when any manga is added/updated/deleted
  /// Returns empty list if user has no mangas
  Stream<List<Manga>> watchAllMangaList();

  /// Update manga name
  /// Throws: AuthException, NotFoundException
  Future<void> updateMangaName(String id, String name);

  /// Update manga reading direction
  /// Throws: AuthException, NotFoundException
  Future<void> updateStartPage(String id, MangaStartPage value);

  /// Update manga idea memo (rich text)
  /// Throws: AuthException, NotFoundException
  Future<void> updateIdeaMemo(String id, Delta delta);

  /// Delete manga and all its pages
  /// Throws: AuthException, NotFoundException
  Future<void> deleteManga(String id);

  /// Export manga to Markdown format
  /// Includes all pages and formatted content
  /// Throws: NotFoundException
  Future<String> toMarkdown(String mangaId);

  // ============================================================================
  // MangaPage CRUD Operations
  // ============================================================================

  /// Create a new page in a manga
  /// Automatically assigns next pageIndex
  /// Throws: AuthException, NotFoundException
  Future<String> createNewMangaPage(String mangaId);

  /// Watch a specific manga page by ID (reactive)
  /// Returns null if page doesn't exist
  Stream<MangaPage?> getMangaPageStream(String pageId);

  /// Watch all page IDs for a manga, ordered by pageIndex (reactive)
  /// Used for displaying page list in grid/editor
  Stream<List<String>> watchAllMangaPageIdList(String mangaId);

  /// Update page memo content (rich text)
  /// Throws: AuthException, NotFoundException
  Future<void> updatePageMemo(String pageId, Delta delta);

  /// Update page dialogue content (rich text)
  /// Throws: AuthException, NotFoundException
  Future<void> updatePageDialogue(String pageId, Delta delta);

  /// Update page stage direction content (rich text)
  /// Throws: AuthException, NotFoundException
  Future<void> updatePageStageDirection(String pageId, Delta delta);

  /// Reorder pages by updating pageIndex
  /// pageIdList should contain all page IDs in desired order
  /// Throws: AuthException, ValidationException
  Future<void> reorderPages(String mangaId, List<String> pageIdList);

  /// Delete a manga page
  /// Throws: AuthException, NotFoundException
  Future<void> deleteMangaPage(String pageId);

  // ============================================================================
  // Sync & Status
  // ============================================================================

  /// Watch sync status for UI indicator
  /// Emits updates when online/offline state changes or sync operations occur
  Stream<SyncStatus> watchSyncStatus();

  /// Force sync all pending changes
  /// Useful for "sync now" button in UI
  /// No-op if already online and synced
  Future<void> forceSyncAll();
}
```

---

## API Changes from Drift Version

### Removed Methods

```dart
// REMOVED: Drift-specific methods no longer needed with Firebase

Future<void> saveManga(String fileName, Manga manga);     // File export
Future<Manga?> loadManga(String fileName);                // File import
Future<void> clearData();                                 // Clear all (dangerous)
Stream<Delta?> getDeltaStream(DeltaId id);                // Separate delta access
void saveDelta(DeltaId id, Delta delta);                  // Direct delta save
Future<Delta?> loadDelta(DeltaId id);                     // Direct delta load
```

**Rationale**:
- Deltas now embedded in manga/page objects (no separate access needed)
- File-based save/load replaced by cloud persistence
- Clearing data done via Firebase Console (admin operation)

### New Methods

```dart
// NEW: Added for Firebase-specific functionality

Future<void> updateIdeaMemo(String id, Delta delta);
Future<void> updatePageMemo(String pageId, Delta delta);
Future<void> updatePageDialogue(String pageId, Delta delta);
Future<void> updatePageStageDirection(String pageId, Delta delta);
Stream<SyncStatus> watchSyncStatus();
Future<void> forceSyncAll();
```

**Rationale**:
- Explicit update methods for delta fields (cleaner than generic update)
- Sync status visibility for offline-first UX

### Changed Signatures

| Method | Drift Signature | Firebase Signature | Change |
|--------|----------------|-------------------|--------|
| `createNewManga` | `Future<MangaId>` (int) | `Future<String>` (Firestore doc ID) | Return type |
| `createNewMangaPage` | `Future<void>` | `Future<String>` (page ID) | Return page ID |
| `getMangaStream` | `Stream<Manga?>` with `int id` | `Stream<Manga?>` with `String id` | Param type |
| `reorderPages` | `Future<void> reorderPages(MangaId id, List<MangaPageId> pageIdList)` | `Future<void> reorderPages(String mangaId, List<String> pageIdList)` | Type change |

---

## Exception Handling

### Custom Exceptions

```dart
/// Base exception for repository operations
abstract class RepositoryException implements Exception {
  String get message;
}

/// User not authenticated or auth token expired
class AuthException implements RepositoryException {
  final String message;
  AuthException([this.message = 'User not authenticated']);
}

/// Requested resource (manga/page) not found
class NotFoundException implements RepositoryException {
  final String resourceType;  // 'Manga' or 'MangaPage'
  final String resourceId;
  String get message => '$resourceType with ID $resourceId not found';

  NotFoundException(this.resourceType, this.resourceId);
}

/// Validation error (e.g., invalid pageIndex, empty name)
class ValidationException implements RepositoryException {
  final String message;
  ValidationException(this.message);
}

/// Firestore operation failed (network error, quota exceeded, etc.)
class StorageException implements RepositoryException {
  final String message;
  final String? code;  // Firestore error code
  StorageException(this.message, {this.code});
}

/// User has insufficient permissions (Firestore security rules denied)
class PermissionException implements RepositoryException {
  final String message;
  PermissionException([this.message = 'Permission denied']);
}
```

### Error Handling Patterns

**In Repository**:
```dart
Future<void> updateMangaName(String id, String name) async {
  try {
    if (name.isEmpty || name.length > 100) {
      throw ValidationException('Name must be 1-100 characters');
    }

    final userId = _authService.currentUserId;
    if (userId == null) {
      throw AuthException();
    }

    await _firebaseService.updateManga(id, {'name': name});

  } on FirebaseAuthException catch (e) {
    throw AuthException(e.message);
  } on FirebaseException catch (e) {
    if (e.code == 'permission-denied') {
      throw PermissionException();
    } else if (e.code == 'not-found') {
      throw NotFoundException('Manga', id);
    } else {
      throw StorageException(e.message ?? 'Storage error', code: e.code);
    }
  }
}
```

**In UI**:
```dart
try {
  await ref.read(mangaRepositoryProvider).updateMangaName(mangaId, newName);
  showSnackBar('Manga name updated');
} on AuthException catch (e) {
  showSnackBar('Please sign in to continue');
  navigateToSignIn();
} on ValidationException catch (e) {
  showSnackBar(e.message);
} on NotFoundException catch (e) {
  showSnackBar('Manga not found (may have been deleted)');
} on StorageException catch (e) {
  showSnackBar('Failed to save changes (offline or network error)');
}
```

---

## Data Flow Examples

### Example 1: Load Manga Grid Page

**UI Component**: `MangaGridPage`

```dart
class MangaGridPage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch all user's mangas (reactive stream)
    final mangasAsync = ref.watch(allMangasProvider);

    return mangasAsync.when(
      data: (mangas) => GridView.builder(
        itemCount: mangas.length,
        itemBuilder: (context, index) => MangaCard(manga: mangas[index]),
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}

// Provider
@riverpod
Stream<List<Manga>> allMangas(Ref ref) {
  return ref.watch(mangaRepositoryProvider).watchAllMangaList();
}
```

**Data Flow**:
1. UI calls `watchAllMangaList()` → Stream emitted
2. Repository queries Firestore: `/users/{userId}/mangas`
3. Firestore checks local cache first (offline-capable)
4. Stream emits `List<Manga>` to UI
5. UI rebuilds GridView with manga cards
6. **On Change**: Any manga update triggers stream emission → UI auto-updates

### Example 2: Edit Manga Page Content

**UI Component**: `MangaEditWidget`

```dart
class MangaEditWidget extends HookConsumerWidget {
  final String pageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(mangaPageProvider(pageId));

    return pageAsync.when(
      data: (page) {
        final quillController = useQuillController(
          initialDelta: page.memoDelta,
          onChanged: (delta) {
            // Debounced save on content change
            ref.read(mangaRepositoryProvider).updatePageMemo(pageId, delta);
          },
        );

        return QuillEditor(controller: quillController);
      },
      loading: () => Skeleton(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}

// Provider
@riverpod
Stream<MangaPage?> mangaPage(Ref ref, String pageId) {
  return ref.watch(mangaRepositoryProvider).getMangaPageStream(pageId);
}
```

**Data Flow**:
1. UI watches `getMangaPageStream(pageId)` → Stream emitted
2. Repository queries: `/users/{userId}/mangas/{mangaId}/pages/{pageId}`
3. Page data (with embedded deltas) returned
4. QuillEditor initialized with `page.memoDelta`
5. **User types** → `onChanged` callback fired
6. Repository calls `updatePageMemo(pageId, newDelta)`
7. Firestore update queued (instant local cache update)
8. **Offline**: Write queued for sync when online
9. **Online**: Write sent to Firestore, triggers stream update

### Example 3: Create New Manga

**UI Component**: Create button handler

```dart
Future<void> handleCreateManga(WidgetRef ref) async {
  try {
    final newMangaId = await ref.read(mangaRepositoryProvider).createNewManga(
      name: 'My New Manga',
    );

    // Navigate to new manga editor
    context.push('/manga/$newMangaId');

  } on AuthException catch (e) {
    showSnackBar('Please sign in first');
  } on StorageException catch (e) {
    showSnackBar('Failed to create manga (offline or error)');
  }
}
```

**Data Flow**:
1. UI calls `createNewManga(name: '...')`
2. Repository generates Firestore doc ID
3. Repository creates `CloudManga` with empty `ideaMemo`
4. Firestore write: `/users/{userId}/mangas/{newId}`
5. **Offline**: Write queued, manga created in local cache
6. **Online**: Write sent to Firestore immediately
7. Method returns new manga ID
8. UI navigates to editor with new ID
9. `watchAllMangaList()` stream auto-emits updated list (includes new manga)

---

## Backward Compatibility Strategy

### Phase 1: Add New Methods (Keep Old)

**Approach**: Dual API during transition

```dart
class MangaRepository {
  // NEW: Firebase-based methods
  Stream<Manga?> getMangaStream(String id) { /* ... */ }

  // DEPRECATED: Drift-based methods (marked for removal)
  @deprecated
  Stream<Delta?> getDeltaStream(int id) {
    throw UnimplementedError('Use Manga.ideaMemo directly');
  }
}
```

**UI Migration**:
```dart
// OLD (Drift-based)
final manga = await getMangaStream(mangaId).first;
final delta = await getDeltaStream(manga.ideaMemo).first;

// NEW (Firebase-based)
final manga = await getMangaStream(mangaId).first;
final delta = manga.ideaMemo;  // Direct access
```

### Phase 2: Remove Deprecated Methods

**Timeline**: After all UI components migrated and tested

```dart
class MangaRepository {
  // Only Firebase-based methods remain
  Stream<Manga?> getMangaStream(String id) { /* ... */ }
  // getDeltaStream() removed
}
```

---

## Testing Contract

### Unit Tests (Repository Layer)

**Test File**: `test/feature/manga/repository/manga_repository_test.dart`

```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:my_manga_editor/feature/manga/repository/manga_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MangaRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = MangaRepository(
      firebaseService: FirebaseService(firestore: fakeFirestore),
      authService: MockAuthService(userId: 'test_user'),
    );
  });

  group('createNewManga', () {
    test('creates manga with default name', () async {
      final mangaId = await repository.createNewManga();

      final doc = await fakeFirestore
        .collection('users').doc('test_user')
        .collection('mangas').doc(mangaId)
        .get();

      expect(doc.exists, true);
      expect(doc.data()?['name'], '無名の傑作');
    });

    test('throws AuthException if not authenticated', () async {
      repository = MangaRepository(
        firebaseService: FirebaseService(firestore: fakeFirestore),
        authService: MockAuthService(userId: null),  // Not authenticated
      );

      expect(
        () => repository.createNewManga(),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('getMangaStream', () {
    test('emits manga when document exists', () async {
      await fakeFirestore
        .collection('users').doc('test_user')
        .collection('mangas').doc('manga1')
        .set({
          'name': 'Test Manga',
          'startPageDirection': 'left',
          'ideaMemo': {'ops': []},
          // ...
        });

      final stream = repository.getMangaStream('manga1');
      final manga = await stream.first;

      expect(manga?.name, 'Test Manga');
      expect(manga?.startPage, MangaStartPage.left);
    });

    test('emits null when document does not exist', () async {
      final stream = repository.getMangaStream('nonexistent');
      final manga = await stream.first;

      expect(manga, isNull);
    });
  });

  // More tests for update, delete, page operations...
}
```

### Integration Tests (UI Layer)

**Test File**: `integration_test/manga_editing_test.dart`

```dart
void main() {
  testWidgets('User can create and edit manga', (tester) async {
    await tester.pumpWidget(MyApp());

    // Create new manga
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verify manga grid shows new manga
    expect(find.text('無名の傑作'), findsOneWidget);

    // Navigate to editor
    await tester.tap(find.text('無名の傑作'));
    await tester.pumpAndSettle();

    // Edit manga name
    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'My Manga');
    await tester.pumpAndSettle();

    // Verify name updated
    expect(find.text('My Manga'), findsOneWidget);
  });
}
```

---

## Performance Expectations

| Operation | Target | Measurement |
|-----------|--------|-------------|
| Load manga list (10 items) | <500ms | First paint to grid visible |
| Load manga + pages (50 pages) | <1s | Document fetch to editor ready |
| Update page delta (offline) | <50ms | User input to UI update |
| Create new manga (offline) | <100ms | Button tap to navigation |
| Sync after reconnect (10 changes) | <3s | Online detection to sync complete |

**Monitoring**:
- Use Firebase Performance Monitoring for Firestore query times
- Add custom traces for repository method durations
- Log cache hit/miss rates

---

## Versioning & Changelog

**Version 1.0.0** (2025-10-25):
- Initial Firebase-only API
- Changed ID types from `int` to `String`
- Embedded Delta objects in domain models
- Removed Drift-specific methods
- Added sync status tracking
- Added explicit delta update methods

**Future Versions**:
- 1.1.0: Add edit locking for multi-device conflict prevention
- 1.2.0: Add batch operations for bulk page updates
- 2.0.0: Potential migration to Firestore Data Bundles for faster initial load

---

## Migration Checklist

UI components must be updated to:

- [x] Change `manga.id` type from `int` to `String`
- [x] Access `manga.ideaMemo` directly (Delta object) instead of `getDeltaStream(manga.ideaMemo)`
- [x] Change `page.id` type from `int` to `String`
- [x] Access page deltas directly (`page.memoDelta`, etc.) instead of separate stream lookups
- [x] Handle new exceptions: `AuthException`, `NotFoundException`, etc.
- [x] Remove calls to deprecated methods: `saveDelta()`, `loadDelta()`, `getDeltaStream()`
- [x] Update Riverpod providers to use new repository signatures
- [x] Add sync status indicator using `watchSyncStatus()` stream
- [x] Test offline editing behavior (auto-queue for sync)

---

## Open Questions

1. ✅ **Delta caching**: Resolved - deltas embedded in models, no caching needed
2. ✅ **ID type migration**: Resolved - use `String` for Firestore compatibility
3. ⚠️ **Pagination**: If user has 100+ mangas, should `watchAllMangaList()` paginate?
   - **Decision**: Defer to Phase 2 (not urgent, most users have <20 mangas)
4. ⚠️ **Bulk operations**: Add batch create/delete for pages?
   - **Decision**: Defer to Phase 2 (single operations sufficient for MVP)
