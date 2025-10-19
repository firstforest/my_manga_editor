# Tasks: Firebase Cloud Storage

**Input**: Design documents from `/specs/001-firebase-cloud-storage/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/repository-api.md

**Tests**: Tests are NOT explicitly requested in the spec - focusing on implementation only.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `- [ ] [ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

## Path Conventions
- Flutter project structure: `lib/`, `test/` at repository root
- Firebase config: `firebase/` at repository root

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Firebase project setup and dependency installation

- [X] T001 Create Firebase project in console and enable Firestore + Authentication (Email/Password provider)
- [X] T002 Install Firebase CLI and FlutterFire CLI, run `flutterfire configure` to generate lib/firebase_options.dart
- [X] T003 Add Firebase dependencies to pubspec.yaml (firebase_core, firebase_auth, cloud_firestore, connectivity_plus)
- [X] T004 Run `flutter pub get` to install dependencies

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core Firebase initialization and data models that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T005 Initialize Firebase in lib/main.dart with `Firebase.initializeApp()` and configure Firestore offline persistence
- [X] T006 [P] Update Manga model in lib/models/manga.dart with @TimestampConverter and Firestore serialization
- [X] T007 [P] Update MangaPage model in lib/models/manga.dart with @DeltaConverter for Quill Delta storage
- [X] T008 [P] Create DeltaConverter class in lib/models/manga.dart for Quill Delta JSON conversion
- [X] T009 [P] Create TimestampConverter class in lib/models/manga.dart for Firestore Timestamp conversion
- [X] T010 Run `dart run build_runner build -d` to generate Freezed and JSON serialization code
- [X] T011 Create Firestore security rules in firestore.rules with user isolation and field validation
- [X] T012 Deploy Firestore security rules with `firebase deploy --only firestore:rules`

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 2 - User Authentication and Account Management (Priority: P1) 🎯 MVP PREREQUISITE

**Goal**: Enable users to sign up, sign in, sign out, and reset passwords with email/password authentication

**Why First**: Authentication is a prerequisite for cloud storage - users need identity before data can be associated with their account

**Independent Test**: Create account, sign out, sign back in, request password reset, verify account persistence works

### Implementation for User Story 2

- [ ] T013 [P] [US2] Create AuthRepository class in lib/firebase/auth/auth_repository.dart with sign up, sign in, sign out, password reset methods
- [ ] T014 [P] [US2] Create AuthException class in lib/firebase/auth/auth_repository.dart for localized error messages
- [ ] T015 [P] [US2] Create auth providers in lib/firebase/auth/auth_providers.dart (authStateChanges, currentUser, currentUserId, isSignedIn)
- [ ] T016 Run `dart run build_runner build -d` to generate auth provider code
- [ ] T017 [P] [US2] Create SignInPage UI in lib/pages/auth/sign_in_page.dart with email/password form
- [ ] T018 [P] [US2] Create SignUpPage UI in lib/pages/auth/sign_up_page.dart with account creation form
- [ ] T019 [P] [US2] Create PasswordResetPage UI in lib/pages/auth/password_reset_page.dart with email input
- [ ] T020 [US2] Add navigation logic in lib/main.dart to show auth pages when user is not signed in
- [ ] T021 [US2] Add sign out button in existing UI (app bar or settings)
- [ ] T022 [US2] Create User document in Firestore `/users/{userId}` after successful sign up

**Checkpoint**: Users can create accounts, sign in, sign out, and reset passwords - authentication system is fully functional

---

## Phase 4: User Story 1 - Cloud Data Synchronization (Priority: P1) 🎯 MVP CORE

**Goal**: Enable seamless cross-device manga data synchronization - users can work on desktop and continue on laptop

**Independent Test**: Create manga on one device, sign in on another device, verify all data appears correctly with formatting preserved

**Depends On**: User Story 2 (authentication must work first)

### Implementation for User Story 1

- [ ] T023 [P] [US1] Create FirestoreMangaRepository class in lib/firebase/firestore/firestore_manga_repository.dart with manga CRUD operations
- [ ] T024 [US1] Add _mangasCollection helper method with Firestore converter in lib/firebase/firestore/firestore_manga_repository.dart
- [ ] T025 [US1] Add _pagesCollection helper method with Firestore converter in lib/firebase/firestore/firestore_manga_repository.dart
- [ ] T026 [US1] Implement createNewManga method in lib/firebase/firestore/firestore_manga_repository.dart
- [ ] T027 [US1] Implement watchManga stream method in lib/firebase/firestore/firestore_manga_repository.dart
- [ ] T028 [US1] Implement watchAllMangaList stream method in lib/firebase/firestore/firestore_manga_repository.dart
- [ ] T029 [US1] Implement updateMangaName method in lib/firebase/firestore/firestore_manga_repository.dart
- [ ] T030 [US1] Implement updateStartPage method in lib/firebase/firestore/firestore_manga_repository.dart
- [ ] T031 [US1] Implement deleteManga with cascade delete (batch writes) in lib/firebase/firestore/firestore_manga_repository.dart
- [ ] T032 [US1] Implement createNewMangaPage method in lib/firebase/firestore/firestore_manga_repository.dart
- [ ] T033 [US1] Implement watchMangaPage stream method in lib/firebase/firestore/firestore_manga_repository.dart
- [ ] T034 [US1] Implement watchAllMangaPageIdList stream method in lib/firebase/firestore/firestore_manga_repository.dart
- [ ] T035 [US1] Implement updatePageDelta method in lib/firebase/firestore/firestore_manga_repository.dart
- [ ] T036 [US1] Implement reorderPages method with batch writes in lib/firebase/firestore/firestore_manga_repository.dart
- [ ] T037 [US1] Implement deleteMangaPage method in lib/firebase/firestore/firestore_manga_repository.dart
- [ ] T038 [P] [US1] Create Riverpod providers in lib/firebase/firestore/firestore_manga_repository.dart (firestoreMangaRepositoryProvider)
- [ ] T039 [P] [US1] Create stream providers in lib/firebase/firestore/manga_providers.dart (watchManga, watchAllMangaList, watchMangaPage, watchAllMangaPageIdList)
- [ ] T040 Run `dart run build_runner build -d` to generate repository provider code
- [ ] T041 [US1] Update existing manga list UI in lib/pages/grid/ to use watchAllMangaListProvider with currentUserId
- [ ] T042 [US1] Update existing manga editor UI in lib/pages/main/ to use watchMangaProvider and watchMangaPageProvider with currentUserId
- [ ] T043 [US1] Update existing page list UI to use watchAllMangaPageIdListProvider with currentUserId
- [ ] T044 [US1] Update all manga mutation operations to call FirestoreMangaRepository methods with currentUserId
- [ ] T045 [US1] Verify Quill Delta format preservation - test memo/dialogue/stageDirection rich text editing
- [ ] T046 [US1] Verify manga page ordering is maintained during sync operations
- [ ] T047 [US1] Test cross-device sync by creating data on one device and viewing on another

**Checkpoint**: Cloud synchronization works - manga data syncs across devices with preserved formatting and page order

---

## Phase 5: User Story 3 - Offline Work with Auto-Sync (Priority: P2)

**Goal**: Enable offline manga editing with automatic sync when connection restores

**Independent Test**: Disable network, make edits, re-enable network, verify changes sync automatically

**Depends On**: User Story 1 (cloud sync infrastructure must exist first)

### Implementation for User Story 3

- [ ] T048 [P] [US3] Create SyncStatus enum in lib/models/sync_status.dart (synced, syncing, offline, error)
- [ ] T049 [P] [US3] Create connectivity monitoring provider in lib/firebase/sync/connectivity_provider.dart using connectivity_plus
- [ ] T050 [US3] Create sync status provider in lib/firebase/sync/sync_status_provider.dart combining Firestore metadata + connectivity
- [ ] T051 [US3] Add hasPendingWrites tracking in sync status provider for each manga collection
- [ ] T052 Run `dart run build_runner build -d` to generate sync provider code
- [ ] T053 [P] [US3] Create SyncStatusIndicator widget in lib/views/sync_status_indicator.dart showing current sync state
- [ ] T054 [US3] Add SyncStatusIndicator to app bar in lib/main.dart or main page
- [ ] T055 [US3] Create sync status details dialog in lib/views/sync_status_dialog.dart with detailed status info
- [ ] T056 [US3] Test offline editing - disable network, create/edit manga, verify local changes persist
- [ ] T057 [US3] Test auto-sync - re-enable network, verify queued changes upload automatically
- [ ] T058 [US3] Test conflict resolution - make offline edits on two devices, reconnect both, verify last-write-wins

**Checkpoint**: Offline mode works - users can work without internet and changes auto-sync when online

---

## Phase 6: User Story 4 - Data Migration from Local Storage (Priority: P2)

**Goal**: Migrate existing Drift database content to Firestore without data loss

**Independent Test**: Create test data in Drift database, run migration, verify all content appears in Firestore with correct formatting

**Depends On**: User Story 1 (Firestore repository must exist to receive migrated data)

### Implementation for User Story 4

- [ ] T059 [P] [US4] Create MigrationStatus enum in lib/firebase/migration/migration_status.dart (not_started, in_progress, completed, failed)
- [ ] T060 [P] [US4] Create DriftToFirebaseMigrator class in lib/firebase/migration/drift_to_firebase_migrator.dart with migration orchestration
- [ ] T061 [US4] Implement migration state persistence in lib/firebase/migration/migration_status.dart using SharedPreferences
- [ ] T062 [US4] Implement delta migration method in lib/firebase/migration/drift_to_firebase_migrator.dart (build ID map: Drift ID → Firestore ID)
- [ ] T063 [US4] Implement manga migration method with pages in lib/firebase/migration/drift_to_firebase_migrator.dart using WriteBatch
- [ ] T064 [US4] Implement progress tracking in lib/firebase/migration/drift_to_firebase_migrator.dart with percentage complete
- [ ] T065 [US4] Implement data integrity verification in lib/firebase/migration/drift_to_firebase_migrator.dart (count check, sample check)
- [ ] T066 [US4] Create migration dialog UI in lib/pages/migration/migration_dialog.dart with progress bar
- [ ] T067 [US4] Add migration trigger on first sign-in in lib/main.dart or auth flow
- [ ] T068 [US4] Add retry mechanism for failed migration in lib/firebase/migration/drift_to_firebase_migrator.dart
- [ ] T069 [US4] Test migration with sample Drift data - verify all manga titles, pages, deltas migrate correctly
- [ ] T070 [US4] Test migration error handling - simulate failure mid-migration, verify Drift data remains intact
- [ ] T071 [US4] Add user confirmation dialog before Drift data cleanup
- [ ] T072 [US4] Implement Drift database cleanup after successful migration verification

**Checkpoint**: Migration works - existing users can move from Drift to Firestore without losing data

---

## Phase 7: User Story 5 - Data Privacy and Security (Priority: P3)

**Goal**: Ensure manga content is private and secure with proper access control

**Independent Test**: Attempt to access another user's data through various means, verify access is denied

**Depends On**: User Story 1 (data must exist in Firestore to test security)

### Implementation for User Story 5

- [ ] T073 [US5] Enhance Firestore security rules in firestore.rules with comprehensive field validation
- [ ] T074 [US5] Add manga name length validation (1-200 chars) to security rules
- [ ] T075 [US5] Add startPage enum validation ('left'|'right') to security rules
- [ ] T076 [US5] Add pageIndex validation (>= 0) to security rules
- [ ] T077 [US5] Add delta structure validation (ops must be list) to security rules
- [ ] T078 [US5] Deploy enhanced security rules with `firebase deploy --only firestore:rules`
- [ ] T079 [US5] Test user isolation - create two accounts, verify User A cannot read User B's manga data
- [ ] T080 [US5] Test unauthenticated access - sign out, verify all Firestore queries are denied
- [ ] T081 [US5] Test data deletion - delete manga, verify content is permanently removed from Firestore
- [ ] T082 [US5] Verify encryption in transit - check Firebase uses HTTPS for all data transmission
- [ ] T083 [US5] Add error handling for permission-denied errors in repository with user-friendly messages

**Checkpoint**: Security works - user data is properly isolated and protected

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T084 [P] Update CLAUDE.md with Firebase/Firestore architecture documentation
- [ ] T085 [P] Add Firebase error handling and logging across all repository methods
- [ ] T086 Implement toMarkdown export method in lib/firebase/firestore/firestore_manga_repository.dart for AI integration
- [ ] T087 Update ClipStudio integration to work with Firestore-backed data
- [ ] T088 Add Firestore usage monitoring setup in Firebase console
- [ ] T089 Test on all platforms (Windows, macOS, Linux, iOS, Android, Web)
- [ ] T090 Remove Drift dependencies from pubspec.yaml after successful migration
- [ ] T091 Delete legacy database files from lib/database/ directory
- [ ] T092 Run quickstart.md validation checklist to verify all features work
- [ ] T093 Performance testing with 100 mangas and 1000 pages to verify success criteria SC-005

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Story 2 (Phase 3)**: Depends on Foundational - Authentication is PREREQUISITE for all other stories
- **User Story 1 (Phase 4)**: Depends on Foundational + US2 - Cloud sync requires authentication
- **User Story 3 (Phase 5)**: Depends on Foundational + US2 + US1 - Offline sync builds on cloud sync
- **User Story 4 (Phase 6)**: Depends on Foundational + US2 + US1 - Migration requires Firestore repository
- **User Story 5 (Phase 7)**: Depends on Foundational + US2 + US1 - Security tests require data in Firestore
- **Polish (Phase 8)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 2 (Authentication) - P1**: BLOCKS all other stories - must complete first
- **User Story 1 (Cloud Sync) - P1**: Depends on US2 - BLOCKS US3, US4, US5
- **User Story 3 (Offline) - P2**: Depends on US2 + US1 - Can proceed after US1
- **User Story 4 (Migration) - P2**: Depends on US2 + US1 - Can proceed in parallel with US3
- **User Story 5 (Security) - P3**: Depends on US2 + US1 - Can proceed in parallel with US3/US4

### Within Each User Story

- Foundational: Models and converters before repository
- US2: Repository before UI pages before navigation
- US1: Repository methods before providers before UI updates
- US3: Status models before providers before UI widgets
- US4: Migrator class before dialog UI before integration
- US5: Security rules before deployment before testing

### Parallel Opportunities

**Phase 1 (Setup)**: All tasks are sequential (Firebase setup steps)

**Phase 2 (Foundational)**:
- T006, T007, T008, T009 (model updates) can run in parallel
- T011 (security rules) can run in parallel with model work

**Phase 3 (User Story 2)**:
- T013, T014, T015 (auth repository and providers) can run in parallel
- T017, T018, T019 (auth UI pages) can run in parallel after T016

**Phase 4 (User Story 1)**:
- T023-T037 (repository methods) must be sequential (same file)
- T038, T039 (providers) can run in parallel after repository complete

**Phase 5 (User Story 3)**:
- T048, T049 (status enum and connectivity) can run in parallel
- T053, T055 (UI widgets) can run in parallel after T052

**Phase 6 (User Story 4)**:
- T059, T060 (status enum and migrator class) can run in parallel

**Phase 7 (User Story 5)**:
- All security rule enhancements are in same file (sequential)

**Phase 8 (Polish)**:
- T084, T085 (documentation and logging) can run in parallel

---

## Parallel Example: User Story 1 (Cloud Sync)

```bash
# After repository methods complete, launch provider tasks in parallel:
Agent: "Create Riverpod providers in lib/firebase/firestore/firestore_manga_repository.dart"
Agent: "Create stream providers in lib/firebase/firestore/manga_providers.dart"

# After providers generated, UI updates can proceed in different files:
# (These depend on providers but touch different UI files)
```

---

## Implementation Strategy

### MVP First (User Story 2 + User Story 1)

1. Complete Phase 1: Setup (Firebase configuration)
2. Complete Phase 2: Foundational (models, converters, base infrastructure)
3. Complete Phase 3: User Story 2 (authentication system)
4. Complete Phase 4: User Story 1 (cloud synchronization)
5. **STOP and VALIDATE**: Test cross-device sync with authentication
6. Deploy/demo if ready - this is the minimal viable cloud storage feature

**Rationale**: US2 + US1 together provide the core value proposition - users can sync manga across devices with secure accounts.

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. Add User Story 2 → Test authentication independently
3. Add User Story 1 → Test cloud sync independently → **Deploy/Demo (MVP!)**
4. Add User Story 3 → Test offline mode independently → Deploy/Demo
5. Add User Story 4 → Test migration independently → Deploy/Demo
6. Add User Story 5 → Test security independently → Deploy/Demo
7. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Complete User Story 2 (authentication) together - BLOCKS everything
3. Once US2 done:
   - Developer A: User Story 1 (cloud sync)
   - Once US1 done:
     - Developer B: User Story 3 (offline)
     - Developer C: User Story 4 (migration)
     - Developer D: User Story 5 (security)

**Note**: US2 and US1 must be sequential, but US3/US4/US5 can proceed in parallel after US1.

---

## Summary Statistics

**Total Tasks**: 93 tasks

**Tasks per User Story**:
- Setup (Phase 1): 4 tasks
- Foundational (Phase 2): 8 tasks
- User Story 2 (Authentication): 10 tasks
- User Story 1 (Cloud Sync): 25 tasks
- User Story 3 (Offline): 11 tasks
- User Story 4 (Migration): 14 tasks
- User Story 5 (Security): 11 tasks
- Polish (Phase 8): 10 tasks

**Parallel Opportunities Identified**:
- Phase 2: 5 tasks can run in parallel
- Phase 3: 6 tasks can run in parallel (3 repo + 3 UI)
- Phase 4: 2 providers can run in parallel
- Phase 5: 3 tasks can run in parallel
- Phase 6: 2 tasks can run in parallel
- Phase 8: 2 tasks can run in parallel

**Suggested MVP Scope**: Phase 1 + Phase 2 + Phase 3 (US2) + Phase 4 (US1) = **47 tasks**

**Independent Test Criteria**:
- US2: Create account, sign out, sign in, verify persistence
- US1: Create manga on Device A, view on Device B with formatting intact
- US3: Offline edits auto-sync when online
- US4: Drift data migrates to Firestore with 100% fidelity
- US5: User A cannot access User B's data

**Format Validation**: ✅ All tasks follow checklist format with checkboxes, task IDs, [P] markers where applicable, [Story] labels for user story phases, and file paths in descriptions.

---

## Notes

- No tests included (not requested in spec)
- All tasks have explicit file paths
- [P] markers indicate parallelizable tasks in different files
- [Story] labels map tasks to user stories for traceability
- Each user story is independently testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Security rules deployed twice: basic in Phase 2, enhanced in Phase 7