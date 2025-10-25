# Quickstart Guide: Firebase-Only Persistence Migration

**Feature**: `002-firebase-only-persistence`
**Date**: 2025-10-25
**Audience**: Developers implementing the migration

## Overview

This guide provides step-by-step instructions for migrating from Drift SQLite + Firebase sync to Firebase-only persistence. Follow these steps in order to ensure a smooth transition.

---

## Prerequisites

Before starting implementation, ensure:

- ✅ Firebase project already configured (`firebase_options.dart` exists)
- ✅ Firebase Auth with Google Sign-In working
- ✅ Cloud Firestore enabled in Firebase Console
- ✅ Current codebase uses Drift 2.22.1 + Firebase sync (baseline)
- ✅ All tests passing on current `main` branch

---

## Phase 0: Preparation

### Step 1: Create Feature Branch

```bash
git checkout -b 002-firebase-only-persistence
```

### Step 2: Enable Firestore Offline Persistence

**File**: `lib/main.dart`

Add Firestore settings before `runApp()`:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // NEW: Enable Firestore offline persistence
  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(ProviderScope(child: MyApp()));
}
```

### Step 3: Update Dependencies

**File**: `pubspec.yaml`

```yaml
dependencies:
  # ... existing dependencies ...

  # REMOVE (after migration complete):
  # drift: ^2.22.1
  # drift_flutter: ^0.2.3

dev_dependencies:
  # ... existing dev dependencies ...

  # REMOVE (after migration complete):
  # drift_dev: ^2.22.1

  # ADD for testing:
  fake_cloud_firestore: ^2.5.0
```

**Run**:
```bash
flutter pub get
```

**NOTE**: Do NOT remove Drift dependencies yet (needed for migration script).

### Step 4: Configure Firestore Security Rules

**Firebase Console** → Firestore Database → Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function: check if user is authenticated and matches userId
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // User data isolation
    match /users/{userId} {
      allow read, write: if isOwner(userId);

      // Manga documents
      match /mangas/{mangaId} {
        allow read, write: if isOwner(userId);

        // Validate manga fields on write
        allow create, update: if
          request.resource.data.name is string &&
          request.resource.data.name.size() > 0 &&
          request.resource.data.name.size() <= 100 &&
          request.resource.data.startPageDirection in ['left', 'right'] &&
          request.resource.data.ideaMemo is map &&
          request.resource.data.ideaMemo.ops is list &&
          request.resource.data.userId == userId;

        // Page subcollection
        match /pages/{pageId} {
          allow read, write: if isOwner(userId);

          // Validate page fields on write
          allow create, update: if
            request.resource.data.pageIndex is int &&
            request.resource.data.pageIndex >= 0 &&
            request.resource.data.memoDelta is map &&
            request.resource.data.memoDelta.ops is list &&
            request.resource.data.dialoguesDelta is map &&
            request.resource.data.dialoguesDelta.ops is list &&
            request.resource.data.stageDirectionDelta is map &&
            request.resource.data.stageDirectionDelta.ops is list;
        }
      }
    }
  }
}
```

**Publish** the rules in Firebase Console.

---

## Phase 1: Update Domain Models

### Step 1: Update Manga Model

**File**: `lib/feature/manga/model/manga.dart`

**Before**:
```dart
@freezed
class Manga with _$Manga {
  const factory Manga({
    required int id,
    required String name,
    required MangaStartPage startPage,
    required int ideaMemo,  // DeltaId
  }) = _Manga;
}
```

**After**:
```dart
import 'package:flutter_quill/quill_delta.dart';

@freezed
class Manga with _$Manga {
  const factory Manga({
    required String id,        // Changed: String (Firestore doc ID)
    required String name,
    required MangaStartPage startPage,
    required Delta ideaMemo,   // Changed: Delta object
  }) = _Manga;

  factory Manga.fromJson(Map<String, dynamic> json) => _$MangaFromJson(json);
}

// Helper extension for MangaStartPage enum
extension MangaStartPageExt on MangaStartPage {
  static MangaStartPage fromString(String value) {
    return MangaStartPage.values.firstWhere((e) => e.name == value);
  }
}
```

### Step 2: Update MangaPage Model

**File**: `lib/feature/manga/model/manga.dart` (or separate file)

**Before**:
```dart
@freezed
class MangaPage with _$MangaPage {
  const factory MangaPage({
    required int id,
    required int memoDelta,
    required int stageDirectionDelta,
    required int dialoguesDelta,
  }) = _MangaPage;
}
```

**After**:
```dart
@freezed
class MangaPage with _$MangaPage {
  const factory MangaPage({
    required String id,                   // Changed: String
    required Delta memoDelta,             // Changed: Delta
    required Delta stageDirectionDelta,   // Changed: Delta
    required Delta dialoguesDelta,        // Changed: Delta
  }) = _MangaPage;

  factory MangaPage.fromJson(Map<String, dynamic> json) => _$MangaPageFromJson(json);
}
```

### Step 3: Regenerate Code

```bash
dart run build_runner build -d
```

**Expected output**: `manga.freezed.dart` and `manga.g.dart` regenerated with new structure.

---

## Phase 2: Update Cloud Models

### Step 1: Update CloudManga to Embed Deltas

**File**: `lib/service/firebase/model/cloud_manga.dart`

**Before**:
```dart
@freezed
class CloudManga with _$CloudManga {
  const factory CloudManga({
    required String id,
    required String userId,
    required String name,
    required String startPageDirection,
    required Map<String, dynamic> ideaMemo,  // Already correct!
    // ...
  }) = _CloudManga;
}
```

**Verify** structure matches data-model.md. Should already be correct from previous Firebase sync implementation.

### Step 2: Update CloudMangaPage to Embed Deltas

**File**: `lib/service/firebase/model/cloud_manga_page.dart`

**Verify** structure:
```dart
@freezed
class CloudMangaPage with _$CloudMangaPage {
  const factory CloudMangaPage({
    required String id,
    required String mangaId,
    required int pageIndex,
    required Map<String, dynamic> memoDelta,
    required Map<String, dynamic> dialoguesDelta,
    required Map<String, dynamic> stageDirectionDelta,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CloudMangaPage;
}
```

---

## Phase 3: Update Repository Layer

### Step 1: Add Custom Exceptions

**File**: `lib/feature/manga/repository/exceptions.dart` (new file)

```dart
/// Base exception for repository operations
abstract class RepositoryException implements Exception {
  String get message;

  @override
  String toString() => message;
}

class AuthException implements RepositoryException {
  final String message;
  AuthException([this.message = 'User not authenticated']);
}

class NotFoundException implements RepositoryException {
  final String resourceType;
  final String resourceId;
  String get message => '$resourceType with ID $resourceId not found';

  NotFoundException(this.resourceType, this.resourceId);
}

class ValidationException implements RepositoryException {
  final String message;
  ValidationException(this.message);
}

class StorageException implements RepositoryException {
  final String message;
  final String? code;
  StorageException(this.message, {this.code});
}

class PermissionException implements RepositoryException {
  final String message;
  PermissionException([this.message = 'Permission denied']);
}
```

### Step 2: Update MangaRepository to Use Firestore Only

**File**: `lib/feature/manga/repository/manga_repository.dart`

**Key Changes**:
1. Remove `MangaDao` dependency
2. Use `FirebaseService` exclusively
3. Update conversion methods to work with new domain models
4. Remove `saveDelta()`, `loadDelta()`, `getDeltaStream()` methods
5. Add new `updateIdeaMemo()`, `updatePageMemo()`, etc. methods

**Example (partial implementation)**:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_manga_editor/feature/manga/model/manga.dart';
import 'package:my_manga_editor/feature/manga/repository/exceptions.dart';
import 'package:my_manga_editor/service/firebase/firebase_service.dart';
import 'package:my_manga_editor/service/firebase/auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'manga_repository.g.dart';

@Riverpod(keepAlive: true)
MangaRepository mangaRepository(Ref ref) {
  return MangaRepository(
    firebaseService: ref.watch(firebaseServiceProvider),
    authService: ref.watch(authServiceProvider),
  );
}

class MangaRepository {
  MangaRepository({
    required FirebaseService firebaseService,
    required AuthService authService,
  })  : _firebaseService = firebaseService,
        _authService = authService;

  final FirebaseService _firebaseService;
  final AuthService _authService;

  String get _userId {
    final userId = _authService.currentUserId;
    if (userId == null) throw AuthException();
    return userId;
  }

  // ============================================================================
  // Manga CRUD
  // ============================================================================

  Future<String> createNewManga({String name = '無名の傑作'}) async {
    final mangaId = _firebaseService.generateDocId();

    final cloudManga = CloudManga(
      id: mangaId,
      userId: _userId,
      name: name,
      startPageDirection: MangaStartPage.left.name,
      ideaMemo: {'ops': []},  // Empty delta
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      editLock: null,
    );

    await _firebaseService.uploadManga(cloudManga);
    return mangaId;
  }

  Stream<Manga?> getMangaStream(String id) {
    return _firebaseService.watchManga(id).map((cloudManga) {
      return cloudManga?.toManga();
    });
  }

  Stream<List<Manga>> watchAllMangaList() {
    return _firebaseService.watchAllUserMangas().map((cloudMangas) {
      return cloudMangas.map((cm) => cm.toManga()).toList();
    });
  }

  Future<void> updateMangaName(String id, String name) async {
    if (name.isEmpty || name.length > 100) {
      throw ValidationException('Name must be 1-100 characters');
    }

    try {
      await _firebaseService.updateManga(id, {
        'name': name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      _handleFirebaseException(e, 'Manga', id);
    }
  }

  Future<void> updateIdeaMemo(String id, Delta delta) async {
    try {
      await _firebaseService.updateManga(id, {
        'ideaMemo': {'ops': delta.toJson()},
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      _handleFirebaseException(e, 'Manga', id);
    }
  }

  // ... more methods (see contracts/repository_api.md)

  // ============================================================================
  // Helper Methods
  // ============================================================================

  Never _handleFirebaseException(FirebaseException e, String resourceType, String resourceId) {
    if (e.code == 'permission-denied') {
      throw PermissionException();
    } else if (e.code == 'not-found') {
      throw NotFoundException(resourceType, resourceId);
    } else {
      throw StorageException(e.message ?? 'Storage error', code: e.code);
    }
  }
}

// ============================================================================
// Conversion Extensions
// ============================================================================

extension CloudMangaConversion on CloudManga {
  Manga toManga() {
    final ideaMemoOps = ideaMemo['ops'] as List? ?? [];
    return Manga(
      id: id,
      name: name,
      startPage: MangaStartPageExt.fromString(startPageDirection),
      ideaMemo: Delta.fromJson(ideaMemoOps),
    );
  }
}

extension MangaToCloudConversion on Manga {
  CloudManga toCloudManga(String userId) {
    return CloudManga(
      id: id,
      userId: userId,
      name: name,
      startPageDirection: startPage.name,
      ideaMemo: {'ops': ideaMemo.toJson()},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      editLock: null,
    );
  }
}
```

### Step 3: Regenerate Provider Code

```bash
dart run build_runner build -d
```

---

## Phase 4: Migrate Existing Data

### Step 1: Create Migration Service

**File**: `lib/service/migration/drift_to_firebase_migration.dart` (new file)

```dart
import 'package:my_manga_editor/service/database/database.dart';
import 'package:my_manga_editor/feature/manga/repository/manga_repository.dart';
import 'package:my_manga_editor/service/firebase/model/cloud_manga.dart';

class DriftToFirebaseMigration {
  DriftToFirebaseMigration({
    required this.driftDb,
    required this.repository,
  });

  final AppDatabase driftDb;
  final MangaRepository repository;

  Future<void> migrate() async {
    // 1. Fetch all mangas from Drift
    final dbMangas = await driftDb.select(driftDb.dbMangas).get();

    for (final dbManga in dbMangas) {
      // 2. Fetch idea memo delta
      final ideaMemoData = await driftDb.select(driftDb.dbDeltas)
        ..where((t) => t.id.equals(dbManga.ideaMemo));
      final ideaMemo = await ideaMemoData.getSingle();

      // 3. Create CloudManga
      final cloudManga = CloudManga(
        id: dbManga.id.toString(),  // int → String
        userId: repository._userId,
        name: dbManga.name,
        startPageDirection: dbManga.startPage.name,
        ideaMemo: {'ops': ideaMemo.delta.toJson()},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        editLock: null,
      );

      // 4. Upload to Firestore
      await repository._firebaseService.uploadManga(cloudManga);

      // 5. Migrate pages
      await _migratePages(dbManga.id, cloudManga.id);
    }
  }

  Future<void> _migratePages(int driftMangaId, String firebaseMangaId) async {
    final dbPages = await (driftDb.select(driftDb.dbMangaPages)
      ..where((t) => t.mangaId.equals(driftMangaId))).get();

    for (final dbPage in dbPages) {
      // Fetch all deltas
      final memoDelta = await _fetchDelta(dbPage.memoDelta);
      final dialoguesDelta = await _fetchDelta(dbPage.dialoguesDelta);
      final stageDirectionDelta = await _fetchDelta(dbPage.stageDirectionDelta);

      // Create CloudMangaPage
      final cloudPage = CloudMangaPage(
        id: dbPage.id.toString(),
        mangaId: firebaseMangaId,
        pageIndex: dbPage.pageIndex,
        memoDelta: {'ops': memoDelta.toJson()},
        dialoguesDelta: {'ops': dialoguesDelta.toJson()},
        stageDirectionDelta: {'ops': stageDirectionDelta.toJson()},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Upload to Firestore
      await repository._firebaseService.uploadMangaPage(cloudPage);
    }
  }

  Future<Delta> _fetchDelta(int deltaId) async {
    final result = await (driftDb.select(driftDb.dbDeltas)
      ..where((t) => t.id.equals(deltaId))).getSingle();
    return result.delta;
  }

  Future<void> verify() async {
    // Count Drift mangas
    final driftCount = await driftDb.select(driftDb.dbMangas).get();
    logger.i('Drift mangas: ${driftCount.length}');

    // Count Firestore mangas
    final cloudMangas = await repository.watchAllMangaList().first;
    logger.i('Firestore mangas: ${cloudMangas.length}');

    if (driftCount.length != cloudMangas.length) {
      throw Exception('Migration verification failed: count mismatch');
    }
  }
}
```

### Step 2: Run Migration on First Launch

**File**: `lib/main.dart`

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Check if migration needed
  final needsMigration = await _checkMigrationNeeded();

  runApp(ProviderScope(child: MyApp(needsMigration: needsMigration)));
}

Future<bool> _checkMigrationNeeded() async {
  // Check if Drift database exists
  final driftDb = AppDatabase();
  final mangas = await driftDb.select(driftDb.dbMangas).get();
  await driftDb.close();

  return mangas.isNotEmpty;
}

class MyApp extends ConsumerWidget {
  final bool needsMigration;

  MyApp({required this.needsMigration});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (needsMigration) {
      return MigrationScreen();  // Show migration UI
    }

    return MaterialApp(/* ... */);
  }
}
```

### Step 3: Create Migration UI

**File**: `lib/feature/migration/migration_screen.dart` (new file)

```dart
class MigrationScreen extends ConsumerStatefulWidget {
  @override
  _MigrationScreenState createState() => _MigrationScreenState();
}

class _MigrationScreenState extends ConsumerState<MigrationScreen> {
  double _progress = 0.0;
  String _status = 'Preparing migration...';

  @override
  void initState() {
    super.initState();
    _runMigration();
  }

  Future<void> _runMigration() async {
    try {
      setState(() => _status = 'Migrating data to cloud...');

      final driftDb = AppDatabase();
      final repository = ref.read(mangaRepositoryProvider);
      final migration = DriftToFirebaseMigration(
        driftDb: driftDb,
        repository: repository,
      );

      await migration.migrate();
      setState(() => _progress = 0.8);

      setState(() => _status = 'Verifying migration...');
      await migration.verify();
      setState(() => _progress = 0.9);

      setState(() => _status = 'Cleaning up...');
      await driftDb.close();
      // Delete Drift database file
      setState(() => _progress = 1.0);

      // Navigate to main app
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MainApp()),
      );

    } catch (e) {
      setState(() => _status = 'Migration failed: $e');
      // Show retry button
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(value: _progress),
            SizedBox(height: 20),
            Text(_status),
          ],
        ),
      ),
    );
  }
}
```

---

## Phase 5: Update UI Layer

### Step 1: Update Providers

**File**: `lib/feature/manga/provider/manga_providers.dart`

**Before** (Drift-based):
```dart
@riverpod
Stream<Manga?> manga(Ref ref, int id) {
  return ref.watch(mangaRepositoryProvider).getMangaStream(id);
}
```

**After** (Firebase-based):
```dart
@riverpod
Stream<Manga?> manga(Ref ref, String id) {  // Changed: String id
  return ref.watch(mangaRepositoryProvider).getMangaStream(id);
}
```

### Step 2: Update UI Components

**Example**: `lib/feature/manga/page/manga_grid_page.dart`

**Before**:
```dart
final manga = await repository.getMangaStream(mangaId).first;
final delta = await repository.getDeltaStream(manga.ideaMemo).first;
```

**After**:
```dart
final manga = await repository.getMangaStream(mangaId).first;
final delta = manga.ideaMemo;  // Direct access
```

### Step 3: Add Sync Status Indicator

**File**: `lib/feature/manga/view/sync_status_indicator.dart`

**Update to use new sync status**:
```dart
class SyncStatusIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);

    return syncStatus.when(
      data: (status) {
        if (!status.isOnline) {
          return Chip(label: Text('Offline'), icon: Icon(Icons.cloud_off));
        } else if (status.isSyncing) {
          return Chip(label: Text('Syncing...'), icon: CircularProgressIndicator());
        } else {
          return Chip(label: Text('Synced'), icon: Icon(Icons.cloud_done));
        }
      },
      loading: () => SizedBox.shrink(),
      error: (_, __) => Icon(Icons.error),
    );
  }
}

@riverpod
Stream<SyncStatus> syncStatus(Ref ref) {
  return ref.watch(mangaRepositoryProvider).watchSyncStatus();
}
```

---

## Phase 6: Update Tests

### Step 1: Update Repository Tests

**File**: `test/feature/manga/repository/manga_repository_test.dart`

**Before** (Mockito for Drift):
```dart
class MockMangaDao extends Mock implements MangaDao {}
```

**After** (FakeFirebaseFirestore):
```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MangaRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = MangaRepository(
      firebaseService: FirebaseService(firestore: fakeFirestore, ...),
      authService: MockAuthService(userId: 'test_user'),
    );
  });

  // ... tests (see contracts/repository_api.md)
}
```

### Step 2: Regenerate Mocks

```bash
dart run build_runner build -d
```

### Step 3: Run Tests

```bash
flutter test
```

**Expected**: All tests pass (update test expectations for ID type changes).

---

## Phase 7: Cleanup (After Migration Complete)

### Step 1: Remove Drift Dependencies

**File**: `pubspec.yaml`

```yaml
dependencies:
  # ... keep other dependencies ...

  # REMOVED:
  # drift: ^2.22.1
  # drift_flutter: ^0.2.3

dev_dependencies:
  # ... keep other dev dependencies ...

  # REMOVED:
  # drift_dev: ^2.22.1
```

```bash
flutter pub get
```

### Step 2: Delete Drift Service Layer

```bash
# Delete entire directory
rm -rf lib/service/database/
```

### Step 3: Remove Drift Imports

Search for and remove:
```dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:my_manga_editor/service/database/database.dart';
```

### Step 4: Remove Migration Code

After confirming all users have migrated:

```bash
rm lib/service/migration/drift_to_firebase_migration.dart
rm lib/feature/migration/migration_screen.dart
```

Update `main.dart` to remove migration check.

### Step 5: Regenerate Code (Final)

```bash
dart run build_runner build -d --delete-conflicting-outputs
```

### Step 6: Final Testing

```bash
flutter analyze
flutter test
flutter run --release
```

**Verify**:
- App launches without errors
- Manga list loads from Firestore
- Creating/editing manga works
- Offline editing queues for sync
- Sync works when online

---

## Troubleshooting

### Issue: "User not authenticated" exception

**Cause**: Firebase Auth not initialized before Firestore access

**Fix**: Ensure user is signed in before accessing repository:
```dart
final authService = ref.watch(authServiceProvider);
if (authService.currentUser == null) {
  await authService.signIn();  // Trigger Google Sign-In
}
```

### Issue: "Permission denied" on Firestore read/write

**Cause**: Security rules not configured or userId mismatch

**Fix**:
1. Verify security rules deployed in Firebase Console
2. Check `request.auth.uid == userId` in rules
3. Verify `CloudManga.userId` matches `FirebaseAuth.currentUser.uid`

### Issue: Migration fails with "Delta conversion error"

**Cause**: Invalid Delta JSON in Drift database

**Fix**:
```dart
try {
  final delta = Delta.fromJson(deltaJson);
} catch (e) {
  // Fallback to empty delta
  final delta = Delta();
}
```

### Issue: Offline writes not syncing when online

**Cause**: Firestore offline persistence not enabled

**Fix**: Verify `persistenceEnabled: true` in Firestore settings (see Phase 0, Step 2)

### Issue: Tests fail with "FakeFirebaseFirestore not found"

**Cause**: Package not added to `dev_dependencies`

**Fix**:
```yaml
dev_dependencies:
  fake_cloud_firestore: ^2.5.0
```

```bash
flutter pub get
```

---

## Verification Checklist

After completing all phases:

- [ ] App launches without Drift imports
- [ ] Manga list loads from Firestore
- [ ] Creating new manga works
- [ ] Editing manga name/direction works
- [ ] Editing page content (memo/dialogue/stage direction) works
- [ ] Creating new pages works
- [ ] Deleting pages works
- [ ] Deleting mangas works
- [ ] Reordering pages works
- [ ] Offline editing queues changes (verify in Network tab)
- [ ] Changes sync when reconnecting (test airplane mode toggle)
- [ ] Sync status indicator shows correct state
- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] No Firestore permission errors in console
- [ ] Migration completed successfully for existing data

---

## Rollback Plan

If critical issues arise during migration:

1. **Revert Code**: `git checkout main`
2. **Keep Firestore Data**: Cloud data preserved (can re-attempt migration)
3. **Re-enable Drift**: Restore `pubspec.yaml` dependencies
4. **Restore Database**: If Drift DB deleted, restore from backup

**Prevention**: Test migration thoroughly on development/staging before production release.

---

## Performance Monitoring

After deployment, monitor:

1. **Firestore Usage** (Firebase Console → Firestore → Usage):
   - Document reads/writes per day
   - Quota consumption
   - Error rates

2. **App Performance**:
   - Manga list load time
   - Page editor load time
   - Offline write latency

3. **User Reports**:
   - Sync failures
   - Data loss incidents
   - Authentication issues

**Target Metrics** (from Technical Context):
- App launch: <2s
- Manga list load: <500ms
- Page load: <1s
- Offline write: <50ms

---

## Next Steps

After successful migration:

1. ✅ Deploy to production
2. Monitor Firestore usage and performance
3. Implement Phase 2 enhancements:
   - Edit locking for multi-device conflict prevention
   - Enhanced sync status UI (last synced timestamp)
   - Data export (backup functionality)
4. Remove migration code after confirming all users migrated
5. Optimize Firestore queries (pagination, indexing)

---

## References

- [Feature Specification](./spec.md)
- [Research Document](./research.md)
- [Data Model](./data-model.md)
- [Repository API Contract](./contracts/repository_api.md)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Flutter + Firestore Guide](https://firebase.google.com/docs/flutter/setup)
