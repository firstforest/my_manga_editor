# Implementation Plan: Firebase Cloud Sync with Google Authentication

**Branch**: `001-firebase-cloud-sync` | **Date**: 2025-10-19 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-firebase-cloud-sync/spec.md`

## Summary

Enable manga creators to sync their local manga projects to Firebase Cloud Firestore and access them from multiple devices. Implement Google Sign-In authentication, cloud-first data merge strategy, 30-60 second periodic sync, and lock-based editing to prevent concurrent modification conflicts. The implementation will preserve the existing `Manga` domain model and introduce new `CloudManga` models for Firebase communication, with repositories handling conversion between layers.

## Technical Context

**Language/Version**: Dart 3.4.1+, Flutter 3.32.4
**Primary Dependencies**:
- `firebase_core` (Firebase SDK initialization)
- `firebase_auth` (Google authentication)
- `cloud_firestore` (Cloud data storage)
- `google_sign_in` (Google OAuth)
- Existing: `drift` 2.22.1, `riverpod` 3.0.2, `freezed` 3.0.6, `flutter_quill` 11.4.0

**Storage**:
- Local: SQLite via Drift (existing - `DbMangas`, `DbMangaPages`, `DbDeltas`)
- Cloud: Cloud Firestore (new - user-scoped collections)

**Testing**: `flutter test` with `mockito` for repository/service layer unit tests

**Target Platform**: Cross-platform desktop (Windows, macOS, Linux), mobile (iOS, Android), web

**Project Type**: Single Flutter project with layered architecture

**Performance Goals**:
- Sign-in < 30 seconds
- Sync operation < 2 minutes for 10-50 page manga
- Lock acquisition < 2 seconds
- Periodic sync every 30-60 seconds

**Constraints**:
- Offline-first: Full functionality without internet
- Non-blocking UI: All sync operations in background
- Data consistency: No data loss during sync
- Cloud-first merge: Cloud data overwrites local on conflict

**Scale/Scope**:
- Single-user workflows (no real-time collaboration in v1)
- 10-50 pages per manga typical
- 1-5 concurrent manga projects per user
- Support for 3+ devices per user

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### I. Layered Architecture & Entity Segregation

**Status**: ✅ COMPLIANT (with new service layer)

**Implementation**:
- **Service Layer** (`lib/service/firebase/`): New `CloudManga`, `CloudMangaPage`, `CloudDelta` models for Firestore, `FirebaseService` class
- **Domain/Repository Layer** (`lib/feature/manga/repository/`): Existing `Manga`, `MangaPage` models preserved, repositories handle `CloudManga` ↔ `Manga` conversion
- **Presentation Layer** (`lib/feature/manga/page|view|provider/`): No changes, continues using existing `Manga` domain models

**Entity Conversion**:
- Firebase ↔ Domain: `FirebaseService` returns `CloudManga`, `MangaRepository` converts to `Manga`
- Service → Domain: `CloudManga.toManga()` extension methods in repository
- Domain → Service: `Manga.toCloudManga()` extension methods in repository

**Rationale**: Follows existing pattern where `DbManga` ↔ `Manga` conversion happens in repository (lines 219-245 in `manga_repository.dart`). Firebase layer is analogous to database layer.

### II. Code Generation Discipline

**Status**: ✅ COMPLIANT

**Actions Required**:
- Run `dart run build_runner build -d` after adding:
  - `CloudManga`, `CloudMangaPage`, `CloudDelta` with `@freezed` and `@JsonSerializable`
  - New `@riverpod` providers for auth state, sync state
  - Firebase service provider with `@Riverpod`
- Add to task checklist: "Run code generation" after each model/provider change

### III. Repository Pattern & Data Access

**Status**: ✅ COMPLIANT

**Implementation**:
- UI continues calling `MangaRepository` methods (no direct Firebase access)
- `MangaRepository` gains new responsibility: orchestrate local DB + Firebase sync
- New `FirebaseService` injected into `MangaRepository` via Riverpod
- Repository methods updated to:
  1. Perform local operation (existing Drift code)
  2. Queue/trigger cloud sync (new Firebase code)

**Prohibited Patterns Avoided**:
- ❌ No direct `FirebaseService` calls from UI
- ❌ No `CloudManga` models exposed to presentation layer
- ❌ No business logic in `FirebaseService` (pure CRUD only)

### IV. State Management with Riverpod

**Status**: ✅ COMPLIANT

**New Providers**:
- `@riverpod FirebaseAuth authProvider()` - auth state
- `@riverpod FirebaseService firebaseService(Ref ref)` - service instance
- `@riverpod Stream<User?> authStateStream(Ref ref)` - current user
- `@riverpod class SyncStateNotifier` - sync queue and status tracking

**Local State** (Flutter Hooks):
- Sign-in button loading state
- Sync progress indicators

### V. Rich Text Data Consistency

**Status**: ✅ COMPLIANT

**Cloud Storage**:
- Firestore documents for `CloudDelta` store Quill Delta JSON as map field
- Cloud schema mirrors local schema: `mangas/{mangaId}/pages/{pageId}` with delta references
- Sync preserves Delta format bidirectionally (no lossy conversions)
- Foreign key relationships encoded as Firestore document references

## Project Structure

### Documentation (this feature)

```
specs/001-firebase-cloud-sync/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output - technology decisions
├── data-model.md        # Phase 1 output - CloudManga schema
├── quickstart.md        # Phase 1 output - Firebase setup guide
├── contracts/           # Phase 1 output
│   └── firestore-schema.json   # Firestore collections structure
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```
lib/
├── feature/
│   └── manga/
│       ├── model/
│       │   ├── manga.dart              # Existing domain model (NO CHANGES)
│       │   └── sync_status.dart        # NEW: enum for sync states
│       ├── repository/
│       │   ├── manga_repository.dart   # MODIFIED: add sync orchestration
│       │   └── auth_repository.dart    # NEW: authentication operations
│       ├── provider/
│       │   ├── manga_providers.dart    # MODIFIED: add auth/sync providers
│       │   └── sync_state_notifier.dart # NEW: sync queue management
│       ├── page/
│       │   └── main_page.dart          # MODIFIED: add auth UI
│       └── view/
│           ├── sign_in_button.dart     # NEW: Google sign-in widget
│           ├── sync_status_indicator.dart # NEW: shows sync state
│           └── lock_indicator.dart     # NEW: shows edit lock status
├── service/
│   ├── database/                       # Existing local storage (NO CHANGES)
│   │   ├── database.dart
│   │   └── model/
│   │       ├── db_manga.dart
│   │       ├── db_manga_page.dart
│   │       └── db_delta.dart
│   └── firebase/                       # NEW: Cloud storage service layer
│       ├── firebase_service.dart       # NEW: Firestore CRUD operations
│       ├── auth_service.dart           # NEW: Google sign-in wrapper
│       ├── model/
│       │   ├── cloud_manga.dart        # NEW: Firestore manga model
│       │   ├── cloud_manga_page.dart   # NEW: Firestore page model
│       │   ├── cloud_delta.dart        # NEW: Firestore delta model
│       │   └── edit_lock.dart          # NEW: lock management model
│       └── firebase_options.dart       # NEW: Generated by FlutterFire CLI
│
test/
├── repositories/
│   ├── manga_repository_test.dart      # MODIFIED: add sync tests
│   └── auth_repository_test.dart       # NEW: auth flow tests
└── service/
    └── firebase/
        ├── firebase_service_test.dart   # NEW: CRUD tests
        └── auth_service_test.dart       # NEW: auth service tests
```

**Structure Decision**: Single Flutter project with layered architecture (existing pattern). New Firebase service layer mirrors existing database layer structure. Repository layer handles all entity conversions between Firebase cloud models and domain models, maintaining strict separation per Constitution principle I.

## Complexity Tracking

*No constitution violations - feature follows existing architectural patterns*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| N/A | N/A | N/A |

## Implementation Phases Overview

### Phase 0: Research & Technical Decisions ✅

**Deliverable**: `research.md` with Firebase package selection, auth flow, sync strategy, conflict resolution approach

**Key Research Areas**:
1. Flutter Firebase packages (official vs community)
2. Firestore data model best practices for hierarchical data
3. Google Sign-In integration for Flutter cross-platform
4. Offline sync patterns (queue-based vs real-time listeners)
5. Lock-based editing implementation in Firestore

### Phase 1: Design & Contracts ✅

**Deliverables**:
- `data-model.md`: CloudManga, CloudMangaPage, CloudDelta, EditLock schemas
- `contracts/firestore-schema.json`: Firestore collection/document structure
- `quickstart.md`: Firebase project setup, FlutterFire CLI configuration
- Updated `.claude/CONTEXT.md` with Firebase technology stack

**Key Design Decisions**:
- Firestore document structure: `/users/{uid}/mangas/{mangaId}` vs `/mangas/{mangaId}`
- Delta JSON storage: nested map vs serialized string
- Edit lock TTL and renewal strategy
- Sync queue persistence: in-memory (Firebase offline persistence handles local caching)

### Phase 2: Task Breakdown

*Created by `/speckit.tasks` command (not part of `/speckit.plan`)*

## Post-Design Constitution Re-Check

*Re-evaluate after Phase 1 design complete*

### I. Layered Architecture & Entity Segregation

**Final Status**: ✅ COMPLIANT

**Verified**:
- ✅ `CloudManga` models defined in `lib/service/firebase/model/`
- ✅ `Manga` domain models unchanged in `lib/feature/manga/model/`
- ✅ Conversion logic in `MangaRepository` (service layer abstraction)
- ✅ No `Cloud*` types exposed to presentation layer

### II. Code Generation Discipline

**Final Status**: ✅ COMPLIANT

**Files Requiring Generation**:
- `cloud_manga.freezed.dart`, `cloud_manga.g.dart`
- `cloud_manga_page.freezed.dart`, `cloud_manga_page.g.dart`
- `cloud_delta.freezed.dart`, `cloud_delta.g.dart`
- `edit_lock.freezed.dart`, `edit_lock.g.dart`
- `sync_status.freezed.dart`, `sync_status.g.dart`
- `auth_repository.g.dart`
- `firebase_service.g.dart`
- `auth_service.g.dart`
- `sync_state_notifier.g.dart`, `sync_state_notifier.freezed.dart`

**Verification Steps** (added to tasks):
1. After model creation: `mise run gen`
2. Before commit: `flutter analyze`
3. Test build: `flutter build <platform>`

### III. Repository Pattern & Data Access

**Final Status**: ✅ COMPLIANT

**Verified Flow**:
```
UI (manga_page_widget.dart)
  ↓ calls
MangaRepository.createNewManga()
  ↓ performs
  1. MangaDao.insertManga() → local DB
  2. FirebaseService.uploadManga() → cloud
  ↓ converts
  DbManga → Manga (existing)
  Manga → CloudManga → Firestore (new)
```

**No Direct Firebase Access from UI**: Confirmed by architecture review

### IV. State Management with Riverpod

**Final Status**: ✅ COMPLIANT

**Provider Hierarchy**:
```
authProvider (FirebaseAuth instance)
  ↓ depends on
authStateStreamProvider (Stream<User?>)
  ↓ consumed by
mangaRepositoryProvider (sync enabled when authenticated)
  ↓ uses
firebaseServiceProvider (CRUD operations)

syncStateNotifierProvider (manages sync queue)
  ↓ consumed by
syncStatusIndicatorWidget (UI feedback)
```

### V. Rich Text Data Consistency

**Final Status**: ✅ COMPLIANT

**Cloud Delta Storage Verified**:
- Firestore document field: `deltaJson: Map<String, dynamic>` (Quill Delta structure preserved)
- Sync flow: `DbDelta.delta` → JSON map → Firestore → JSON map → `CloudDelta.delta` → `DbDelta.delta`
- No conversion to plain text or HTML
- Foreign keys: Firestore document references mirror Drift foreign keys

## Notes

**User-Specified Constraints**:
- Use official Flutter Firebase libraries (`firebase_core`, `firebase_auth`, `cloud_firestore`)
- Preserve existing `Manga` model (do not modify)
- Create new `CloudManga` model for Firebase communication
- `FirebaseService` class uses `CloudManga` models for server interaction
- Repository handles `CloudManga` ↔ `Manga` conversion

**Architecture Alignment**:
- This approach mirrors the existing `DbManga` ↔ `Manga` pattern (see `manga_repository.dart:219-228`)
- Maintains constitution compliance by keeping service layer (Firebase) separate from domain layer
- Repository remains the only layer that performs entity conversions

**Risk Mitigation**:
- Offline-first design ensures app remains functional without internet
- Cloud-first merge strategy prevents accidental local-only data proliferation
- Lock-based editing chosen over last-write-wins to prevent silent data loss
- Periodic 30-60s sync balances UX responsiveness with battery/network efficiency
