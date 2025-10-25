# Tasks: Firebase-Only Persistence Migration

**Input**: Design documents from `/specs/002-firebase-only-persistence/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/repository_api.md, quickstart.md

**Tests**: Tests are NOT included in this task list as they were not explicitly requested in the feature specification.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

**Design Decision**: Delta objects are managed by **ID reference** to minimize domain model changes. Repository layer converts between Firestore embedded deltas and in-memory DeltaId cache.

## Format: `[ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

## Path Conventions
- Flutter project structure: `lib/` at repository root
- Test files: `test/` at repository root
- Paths assume Flutter cross-platform application structure

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization, dependency configuration, and Firebase setup

- [X] T001 Create feature branch `002-firebase-only-persistence` from main branch
- [X] T002 Enable Firestore offline persistence in lib/main.dart (add Settings with persistenceEnabled: true)
- [X] T003 [P] Add fake_cloud_firestore ^3.1.0 to pubspec.yaml dev_dependencies for testing
- [ ] T004 Configure Firestore Security Rules in Firebase Console (user data isolation rules from quickstart.md) **[USER ACTION REQUIRED]**
- [X] T005 Run flutter pub get to install new dependencies

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T006 [P] Create custom exceptions in lib/feature/manga/repository/exceptions.dart (AuthException, NotFoundException, ValidationException, StorageException, PermissionException)
- [X] T007 [P] Update MangaId typedef in lib/feature/manga/model/manga.dart (change from int to String for Firestore compatibility)
- [X] T008 [P] Update MangaPageId typedef in lib/feature/manga/model/manga.dart (change from int to String for Firestore compatibility)
- [X] T009 [P] Keep DeltaId typedef in lib/feature/manga/model/manga.dart (remain as int for in-memory cache reference)
- [X] T010 [P] Add MangaStartPageExt extension in lib/feature/manga/model/manga.dart (fromString helper for enum conversion)
- [X] T011 [P] Create SyncStatus model in lib/feature/manga/model/sync_status.dart (isOnline, isSyncing, lastSyncedAt, pendingMangaIds)
- [X] T012 Run dart run build_runner build -d to regenerate Freezed models (manga.freezed.dart, manga.g.dart, sync_status.freezed.dart)
- [X] T013 [P] Update CloudManga model in lib/service/firebase/model/cloud_manga.dart (verify embedded ideaMemo map structure)
- [X] T014 [P] Update CloudMangaPage model in lib/service/firebase/model/cloud_manga_page.dart (verify embedded delta map structures)
- [X] T015 Run dart run build_runner build -d to regenerate cloud model files (cloud_manga.g.dart, cloud_manga_page.g.dart)

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Data Persists Across Sessions (Priority: P1) 🎯 MVP

**Goal**: Implement Firebase-only persistence so user's manga projects, pages, dialogues, and memos are automatically saved and available when restarting the application

**Independent Test**: Create a new manga project with multiple pages and content, close the application completely, reopen it, and verify all data is intact and accessible

### Implementation for User Story 1

#### Repository Delta Cache Management

- [X] T016 [US1] Create DeltaCache class in lib/feature/manga/repository/delta_cache.dart (in-memory cache for Delta ↔ DeltaId mapping)
- [X] T017 [US1] Implement storeDelta method in lib/feature/manga/repository/delta_cache.dart (Delta → DeltaId, returns auto-incremented int)
- [X] T018 [US1] Implement getDelta method in lib/feature/manga/repository/delta_cache.dart (DeltaId → Delta?, returns null if not found)
- [X] T019 [US1] Implement getDeltaStream method in lib/feature/manga/repository/delta_cache.dart (DeltaId → Stream<Delta?>, reactive delta updates)
- [X] T020 [US1] Implement updateDelta method in lib/feature/manga/repository/delta_cache.dart (DeltaId → void, updates cached delta and emits stream)
- [X] T021 [US1] Implement clearCache method in lib/feature/manga/repository/delta_cache.dart (clears all cached deltas, for testing)

#### Repository Conversion Layer

- [X] T022 [P] [US1] Add CloudMangaConversion extension in lib/feature/manga/repository/manga_repository.dart (toManga method: embedded Delta → DeltaId via cache)
- [X] T023 [P] [US1] Add MangaToCloudConversion extension in lib/feature/manga/repository/manga_repository.dart (toCloudManga method: DeltaId → embedded Delta from cache)
- [X] T024 [P] [US1] Add CloudMangaPageConversion extension in lib/feature/manga/repository/manga_repository.dart (toMangaPage method: embedded Deltas → DeltaIds)
- [X] T025 [P] [US1] Add MangaPageToCloudConversion extension in lib/feature/manga/repository/manga_repository.dart (toCloudMangaPage method: DeltaIds → embedded Deltas)

#### Repository Core Implementation

- [X] T026 [US1] Update MangaRepository constructor in lib/feature/manga/repository/manga_repository.dart (remove MangaDao, add FirebaseService and DeltaCache dependencies)
- [X] T027 [US1] Implement createNewManga method in lib/feature/manga/repository/manga_repository.dart (returns String mangaId, creates empty Delta and stores in cache)
- [X] T028 [US1] Implement getMangaStream method in lib/feature/manga/repository/manga_repository.dart (Stream<Manga?> with String id, converts CloudManga → Manga with Delta caching)
- [X] T029 [US1] Implement watchAllMangaList method in lib/feature/manga/repository/manga_repository.dart (Stream<List<Manga>>, caches all deltas from fetched mangas)
- [X] T030 [US1] Implement updateMangaName method in lib/feature/manga/repository/manga_repository.dart (validates 1-100 chars, throws ValidationException)
- [X] T031 [US1] Implement updateStartPage method in lib/feature/manga/repository/manga_repository.dart (updates manga reading direction)
- [X] T032 [US1] Implement deleteManga method in lib/feature/manga/repository/manga_repository.dart (deletes manga, pages, and clears cached deltas)

#### Repository Delta Management Methods

- [X] T033 [US1] Implement saveDelta method in lib/feature/manga/repository/manga_repository.dart (DeltaId → Delta → void, updates cache and syncs to Firestore)
- [X] T034 [US1] Implement loadDelta method in lib/feature/manga/repository/manga_repository.dart (DeltaId → Future<Delta?>, retrieves from cache or Firestore)
- [X] T035 [US1] Implement getDeltaStream method in lib/feature/manga/repository/manga_repository.dart (DeltaId → Stream<Delta?>, delegates to DeltaCache)

#### Repository Page Operations

- [X] T036 [US1] Implement createNewMangaPage method in lib/feature/manga/repository/manga_repository.dart (returns String pageId, creates empty Deltas and stores in cache)
- [X] T037 [US1] Implement getMangaPageStream method in lib/feature/manga/repository/manga_repository.dart (Stream<MangaPage?>, converts CloudMangaPage → MangaPage with Delta caching)
- [X] T038 [US1] Implement watchAllMangaPageIdList method in lib/feature/manga/repository/manga_repository.dart (Stream<List<String>> ordered by pageIndex)
- [X] T039 [US1] Implement reorderPages method in lib/feature/manga/repository/manga_repository.dart (batch updates pageIndex for all pages in Firestore)
- [X] T040 [US1] Implement deleteMangaPage method in lib/feature/manga/repository/manga_repository.dart (deletes page and clears cached deltas)

#### Repository Error Handling

- [X] T041 [US1] Add Firebase exception handling helper in lib/feature/manga/repository/manga_repository.dart (_handleFirebaseException method converting FirebaseException to custom exceptions)

#### Repository Code Generation

- [X] T042 Run dart run build_runner build -d to regenerate repository provider (manga_repository.g.dart)

#### Provider Layer Updates

- [X] T043 [US1] Update manga provider in lib/feature/manga/provider/manga_providers.dart (change id parameter from int to String)
- [X] T044 [US1] Update mangaPage provider in lib/feature/manga/provider/manga_providers.dart (change id parameter from int to String)
- [X] T045 [US1] Verify delta provider in lib/feature/manga/provider/manga_providers.dart (getDeltaStream should work unchanged with int DeltaId)
- [X] T046 Run dart run build_runner build -d to regenerate provider files (manga_providers.g.dart)

#### UI Layer Updates

- [X] T047 [US1] Update MangaGridPage in lib/feature/manga/page/manga_grid_page.dart (handle String manga IDs, getDeltaStream remains unchanged)
- [X] T048 [US1] Update MainPage in lib/feature/manga/page/main_page.dart (handle String page IDs, getDeltaStream usage remains unchanged)
- [X] T049 [US1] Update MangaEditWidget in lib/feature/manga/view/manga_edit_widget.dart (getDeltaStream usage remains unchanged, DeltaId is still int)
- [X] T050 [US1] Update MangaPageWidget in lib/feature/manga/view/manga_page_widget.dart (getDeltaStream usage remains unchanged)
- [X] T051 [US1] Add error handling in UI components (catch AuthException, NotFoundException, ValidationException, StorageException)
- [X] T052 Run flutter analyze to verify no compilation errors

**Checkpoint**: ✅ **User Story 1 Complete** - Data persists to Firebase with Delta ID reference pattern (0 compilation errors)

---

## Phase 4: User Story 2 - Offline Work Continuity (Priority: P2)

**Goal**: Enable users to continue working on manga projects without internet connection, with automatic synchronization when reconnecting

**Independent Test**: Disconnect from internet, create/edit manga content, verify changes are stored locally, reconnect and confirm data synchronizes to cloud

### Implementation for User Story 2

- [ ] T053 [US2] Implement watchSyncStatus method in lib/feature/manga/repository/manga_repository.dart (Stream<SyncStatus> monitoring connection and sync state)
- [ ] T054 [US2] Implement forceSyncAll method in lib/feature/manga/repository/manga_repository.dart (manually trigger pending sync for all cached deltas)
- [ ] T055 [US2] Add delta sync logic in lib/feature/manga/repository/manga_repository.dart (when delta updated in cache, sync to Firestore for parent manga/page)
- [ ] T056 [US2] Create syncStatus provider in lib/feature/manga/provider/manga_providers.dart (exposes watchSyncStatus stream to UI)
- [ ] T057 Run dart run build_runner build -d to regenerate provider file
- [ ] T058 [US2] Update SyncStatusIndicator in lib/feature/manga/view/sync_status_indicator.dart (show offline/syncing/synced states using syncStatusProvider)
- [ ] T059 [US2] Add sync status indicator to MangaGridPage in lib/feature/manga/page/manga_grid_page.dart (display sync state in app bar)
- [ ] T060 [US2] Add sync status indicator to MainPage in lib/feature/manga/page/main_page.dart (display sync state in editor)
- [ ] T061 Run flutter analyze to verify no compilation errors

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently - offline editing with automatic sync

---

## Phase 5: Data Migration from Drift to Firebase

**Purpose**: Migrate existing Drift SQLite data to Firestore without data loss

**⚠️ CRITICAL**: This phase requires Drift dependencies to remain until migration is complete

- [ ] T062 Create DriftToFirebaseMigration service in lib/service/migration/drift_to_firebase_migration.dart (migrate, verify, fetchDelta methods)
- [ ] T063 Implement migrate method in lib/service/migration/drift_to_firebase_migration.dart (fetch Drift data, convert to CloudManga/CloudMangaPage with embedded deltas, upload to Firestore)
- [ ] T064 Implement verify method in lib/service/migration/drift_to_firebase_migration.dart (compare Drift count vs Firestore count, throw on mismatch)
- [ ] T065 Add migration check in lib/main.dart (_checkMigrationNeeded function to detect existing Drift database)
- [ ] T066 Create MigrationScreen in lib/feature/migration/migration_screen.dart (show progress UI, run migration, handle errors)
- [ ] T067 Update MyApp in lib/main.dart (conditional rendering: show MigrationScreen if needsMigration, else show normal app)
- [ ] T068 Add migration error handling in lib/feature/migration/migration_screen.dart (show retry button on failure, preserve Drift DB until verified)
- [ ] T069 Test migration with sample data (create test manga in Drift, run migration, verify in Firestore and delta cache)

**Checkpoint**: Migration complete - existing user data successfully migrated to Firestore with delta cache populated

---

## Phase 6: Cleanup & Final Polish

**Purpose**: Remove Drift dependencies and migration code after successful migration

- [ ] T070 Remove Drift dependencies from pubspec.yaml (drift, drift_flutter from dependencies, drift_dev from dev_dependencies)
- [ ] T071 Run flutter pub get to remove Drift packages
- [ ] T072 Delete Drift database service directory lib/service/database/ (database.dart, database.g.dart, model/)
- [ ] T073 Remove all Drift imports from codebase (search for 'package:drift', 'package:drift_flutter', remove unused imports)
- [ ] T074 Remove sync queue models in lib/service/firebase/model/ (sync_queue_entry.dart, sync_queue_entry.freezed.dart, sync_queue_entry.g.dart if exists)
- [ ] T075 Remove SyncStateNotifier in lib/feature/manga/provider/ (sync_state_notifier.dart, sync_state_notifier.g.dart if exists)
- [ ] T076 Evaluate and remove edit lock manager if not needed in lib/service/firebase/lock_manager.dart (or keep for Phase 2 enhancement)
- [ ] T077 Run dart run build_runner build -d --delete-conflicting-outputs to clean up generated files
- [ ] T078 Run flutter analyze to verify no compilation errors
- [ ] T079 Run flutter test to verify all tests pass with new architecture
- [ ] T080 [P] Update CLAUDE.md documentation to reflect Firebase-only architecture with Delta ID reference pattern
- [ ] T081 [P] Add performance monitoring in lib/feature/manga/repository/manga_repository.dart (log Firestore operation durations, delta cache hit/miss rates)
- [ ] T082 Run quickstart.md validation (follow all steps from quickstart.md to verify implementation)
- [ ] T083 Test offline editing behavior (enable airplane mode, edit content via saveDelta, verify queued for sync, disable airplane mode, verify sync)
- [ ] T084 Test delta cache persistence across app restarts (verify deltas reload from Firestore on app launch)
- [ ] T085 Test across target platforms (Windows, macOS, Linux at minimum for desktop app)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational phase completion - Core persistence with Delta cache
- **User Story 2 (Phase 4)**: Depends on User Story 1 completion - Builds on persistence with offline sync
- **Data Migration (Phase 5)**: Depends on User Story 1 completion - Can run in parallel with User Story 2
- **Cleanup (Phase 6)**: Depends on successful Data Migration - Final step

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Depends on User Story 1 - Adds offline/sync capabilities to existing persistence

### Within Each User Story

- **User Story 1 (P1)**:
  - Delta cache implementation (T016-T021) must complete first
  - Conversion extensions (T022-T025) can run in parallel after cache exists
  - Repository core (T026-T042) builds on cache and conversions
  - Provider updates (T043-T046) depend on repository completion
  - UI updates (T047-T052) depend on provider completion

- **User Story 2 (P2)**:
  - Repository sync methods (T053-T055) sequential (building on each other)
  - Provider creation (T056) depends on repository methods
  - UI updates (T058-T061) depend on provider completion

### Parallel Opportunities

- **Setup (Phase 1)**: T003 and T004 can run in parallel (independent setup tasks)
- **Foundational (Phase 2)**: T006-T011 can run in parallel (creating different models/files), T013-T014 can run in parallel
- **User Story 1 Delta Cache**: T017-T020 methods can be implemented in parallel (different methods in same class)
- **User Story 1 Conversions**: T022-T025 can run in parallel (extension methods in different sections)
- **Cleanup (Phase 6)**: T080 and T081 can run in parallel (documentation and monitoring are independent)

---

## Parallel Example: User Story 1 Delta Cache Methods

```bash
# Launch all delta cache method implementations together:
Task: "Implement storeDelta method in lib/feature/manga/repository/delta_cache.dart"
Task: "Implement getDelta method in lib/feature/manga/repository/delta_cache.dart"
Task: "Implement getDeltaStream method in lib/feature/manga/repository/delta_cache.dart"
Task: "Implement updateDelta method in lib/feature/manga/repository/delta_cache.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1 (with Delta cache pattern)
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Data persists with Delta IDs ✅
3. Add User Story 2 → Test independently → Offline editing with sync ✅
4. Run Data Migration → Migrate existing users → Migration complete ✅
5. Cleanup → Remove Drift, finalize → Production ready ✅

### Delta Cache Strategy

**Cache Lifecycle**:
1. **App Launch**: Cache starts empty
2. **Data Fetch**: When Manga/MangaPage loaded from Firestore, embedded Deltas stored in cache with auto-generated DeltaIds
3. **Data Edit**: saveDelta() updates cache and syncs embedded Delta to Firestore
4. **App Restart**: Cache cleared, re-populated on next data fetch

**Cache Benefits**:
- ✅ Minimal domain model changes (DeltaId remains int)
- ✅ UI layer unchanged (getDeltaStream works as before)
- ✅ Firestore optimization (embedded deltas reduce reads)
- ✅ Offline-first (cache provides instant access)

**Cache Considerations**:
- ⚠️ Memory usage (all deltas cached in-memory)
- ⚠️ Cache invalidation on concurrent edits (handled by Firestore streams)

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Code generation (`dart run build_runner build -d`) required after model changes
- Commit after each logical task group
- Stop at any checkpoint to validate story independently
- Migration is one-time operation, can be removed after all users migrated
- **Delta ID pattern**: Repository maintains in-memory cache mapping DeltaId (int) ↔ Delta object
- **Firestore structure**: Deltas embedded in CloudManga/CloudMangaPage documents (cost optimization)
- **UI compatibility**: Existing getDeltaStream calls work unchanged with int DeltaId
