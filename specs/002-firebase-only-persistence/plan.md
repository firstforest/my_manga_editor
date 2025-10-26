# Implementation Plan: Firebase-Only Persistence Migration

**Branch**: `002-firebase-only-persistence` | **Date**: 2025-10-25 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-firebase-only-persistence/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Migrate from dual-storage architecture (Drift SQLite + Firebase sync) to Firebase-only persistence with offline support via Firebase's built-in offline persistence. This simplifies the codebase by eliminating the local database layer while maintaining full offline functionality through Firestore's native offline capabilities. The migration involves removing Drift dependencies, converting repositories to use Firestore directly, and leveraging Firebase's automatic sync when connectivity is restored.

## Technical Context

**Language/Version**: Dart 3.4.1+ / Flutter 3.32.4
**Primary Dependencies**: Firebase Core 3.8.0, Cloud Firestore 5.5.0, Firebase Auth 5.3.3, Flutter Quill 11.4.0, Riverpod 3.0.0-dev.15
**Storage**: Cloud Firestore with offline persistence (replacing Drift SQLite)
**Testing**: flutter test with Mockito 5.4.5 for repository mocking
**Target Platform**: Windows, macOS, Linux, iOS, Android, Web (cross-platform desktop/mobile)
**Project Type**: Mobile/Desktop cross-platform application
**Performance Goals**: <2s app launch, <200ms UI response for data access, maintain 60fps during editing
**Constraints**: Must support offline editing with unlimited duration, automatic sync on reconnect, maintain existing UI/UX performance
**Scale/Scope**: Personal productivity app (single user, 10-100 manga projects, 50-500 pages per project)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### I. Layered Architecture & Entity Segregation
**Status**: ✅ PASS (with migration required)

Current architecture maintains strict layer separation:
- **Service Layer**: Currently `lib/service/database/` (Drift) + `lib/service/firebase/` (Firebase)
- **Repository Layer**: `lib/feature/manga/repository/` with entity conversion
- **Presentation Layer**: `lib/feature/manga/page/`, `lib/feature/manga/view/`, `lib/feature/manga/provider/`

**Migration Impact**:
- Remove Drift service layer (`lib/service/database/`)
- Convert Firebase service layer to primary storage
- Repository layer will convert between Firestore documents and domain models
- Presentation layer unchanged (already uses domain models)

**Entity Conversion Flow (After Migration)**:
- Firestore → Domain: `CloudManga`/`CloudMangaPage` → `Manga`/`MangaPage` (in repositories)
- Domain → Firestore: `Manga`/`MangaPage` → `CloudManga`/`CloudMangaPage` (in repositories)
- Domain → Presentation: Direct usage of `Manga`/`MangaPage` models (unchanged)

### II. Code Generation Discipline
**Status**: ✅ PASS

Migration will reduce code generation requirements:
- **Remove**: Drift table generation (`database.g.dart`, DAO generation)
- **Keep**: Freezed models (`*.freezed.dart`), JSON serialization (`*.g.dart`), Riverpod providers (`*.g.dart`)

Post-migration: `dart run build_runner build -d` still required for Freezed, JSON, and Riverpod.

### III. Repository Pattern & Data Access
**Status**: ✅ PASS

Migration strengthens this pattern:
- All data access remains through `MangaRepository`
- UI components continue to use repository methods (no direct Firestore access)
- Repository will encapsulate Firestore operations (replacing Drift DAO calls)
- Existing repository interface preserved for UI compatibility

### IV. State Management with Riverpod
**Status**: ✅ PASS (no changes required)

State management architecture unchanged:
- Riverpod providers for repositories and ViewModels remain
- Firebase service providers already exist (`firebaseServiceProvider`, `authServiceProvider`)
- UI continues using Riverpod for dependency injection
- Flutter Hooks usage for local state unchanged

### V. Rich Text Data Consistency
**Status**: ✅ RESOLVED

**Decision**: Hybrid approach - Firestore embeds deltas, Domain models use DeltaId references

Current: Quill Delta stored in `DbDeltas` table with foreign key references (DeltaId = int)
Migration:
- **Firestore layer**: Deltas embedded as `Map<String, dynamic>` in CloudManga/CloudMangaPage documents
- **Domain layer**: Delta references preserved as `DeltaId` (int) in Manga/MangaPage models
- **Repository layer**: DeltaCache bridges between embedded deltas and DeltaId references

**Benefits**:
1. **Minimal domain model changes**: DeltaId (int) unchanged, only MangaId/MangaPageId change to String
2. **UI compatibility**: Existing `getDeltaStream(DeltaId)` calls work unchanged
3. **Firestore optimization**: Embedded deltas reduce document reads (cost savings)
4. **Offline-first**: In-memory cache provides instant delta access

**Constitution Alignment**:
- Firestore denormalization is standard practice (document-oriented storage)
- Domain model maintains referential pattern (preserves existing architecture)
- Repository layer encapsulates conversion logic (clean separation of concerns)
- Delta cache cleared on app restart, re-populated from Firestore (stateless design)

### Pre-Research Gate Decision
✅ **PASS** - All constitution principles maintained or improved. Rich text storage pattern requires architectural decision (documented in research phase).

## Project Structure

### Documentation (this feature)

```
specs/002-firebase-only-persistence/
├── spec.md              # Feature specification
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
│   └── repository_api.md
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```
lib/
├── feature/
│   ├── manga/
│   │   ├── model/              # Domain models (Freezed)
│   │   │   ├── manga.dart
│   │   │   ├── manga.freezed.dart
│   │   │   ├── manga.g.dart
│   │   │   ├── sync_status.dart
│   │   │   └── sync_status.freezed.dart
│   │   ├── repository/         # Data access layer
│   │   │   ├── manga_repository.dart      # [MODIFY] Remove Drift, use Firebase only
│   │   │   ├── manga_repository.g.dart
│   │   │   ├── auth_repository.dart       # [KEEP] Firebase auth
│   │   │   └── auth_repository.g.dart
│   │   ├── provider/           # Riverpod state management
│   │   │   ├── manga_providers.dart       # [MODIFY] Update for new repo interface
│   │   │   ├── manga_providers.g.dart
│   │   │   ├── manga_page_view_model.dart # [KEEP] No changes
│   │   │   ├── manga_page_view_model.g.dart
│   │   │   ├── sync_state_notifier.dart   # [REMOVE] No longer needed
│   │   │   └── sync_state_notifier.g.dart
│   │   ├── page/               # Screen components
│   │   │   ├── main_page.dart             # [KEEP] No changes
│   │   │   └── manga_grid_page.dart       # [KEEP] No changes
│   │   └── view/               # Reusable UI widgets
│   │       ├── manga_edit_widget.dart     # [KEEP] No changes
│   │       ├── manga_page_widget.dart     # [KEEP] No changes
│   │       ├── sync_status_indicator.dart # [MODIFY] Update for Firebase sync status
│   │       └── ...
│   └── ai_comment/
│       └── ...                 # [KEEP] No changes
├── service/
│   ├── database/               # [REMOVE] Entire directory
│   │   ├── database.dart       # [DELETE] Drift database
│   │   ├── database.g.dart
│   │   └── model/
│   │       ├── db_manga.dart   # [DELETE]
│   │       ├── db_manga_page.dart # [DELETE]
│   │       └── db_delta.dart   # [DELETE]
│   └── firebase/               # [KEEP] Firebase services
│       ├── firebase_service.dart          # [KEEP] Firestore CRUD
│       ├── firebase_service.g.dart
│       ├── auth_service.dart              # [KEEP] Authentication
│       ├── auth_service.g.dart
│       ├── firebase_config.dart           # [KEEP] Configuration
│       ├── lock_manager.dart              # [EVALUATE] May not be needed
│       ├── lock_manager.g.dart
│       └── model/
│           ├── cloud_manga.dart           # [KEEP] Firestore models
│           ├── cloud_manga.freezed.dart
│           ├── cloud_manga.g.dart
│           ├── cloud_manga_page.dart      # [KEEP]
│           ├── cloud_manga_page.freezed.dart
│           ├── cloud_manga_page.g.dart
│           ├── edit_lock.dart             # [EVALUATE] May not be needed
│           ├── edit_lock.freezed.dart
│           ├── edit_lock.g.dart
│           ├── sync_queue_entry.dart      # [REMOVE] No manual sync queue
│           ├── sync_queue_entry.freezed.dart
│           └── sync_queue_entry.g.dart
├── hooks/
│   └── quill_controller_hook.dart # [KEEP] No changes
├── common/
│   └── logger.dart             # [KEEP] No changes
├── firebase_options.dart       # [KEEP] Firebase config
└── main.dart                   # [MODIFY] Remove Drift initialization

test/
└── feature/
    └── manga/
        ├── repository/
        │   └── manga_repository_test.dart # [MODIFY] Update mocks
        └── provider/
            ├── manga_providers_test.dart  # [MODIFY] Update for new interface
            └── manga_providers_test.mocks.dart
```

**Structure Decision**: Flutter cross-platform mobile/desktop application structure. Migration involves:
1. **Removing** `lib/service/database/` (Drift SQLite layer)
2. **Keeping** `lib/service/firebase/` (Firebase/Firestore services)
3. **Modifying** `lib/feature/manga/repository/manga_repository.dart` to use Firebase directly
4. **Minimal changes** to presentation layer (pages/views maintain existing interface)
5. **Removing** sync queue logic (Firebase handles sync automatically)

## Complexity Tracking

*Fill ONLY if Constitution Check has violations that must be justified*

No constitution violations. This migration actually **reduces** complexity:
- Removes dual-storage architecture (Drift + Firebase)
- Eliminates manual sync queue management
- Reduces code generation requirements (no Drift DAO generation)
- Leverages Firebase's built-in offline persistence instead of custom sync logic

---

## Post-Phase 1 Constitution Check

*Re-evaluation after design artifacts generated*

### I. Layered Architecture & Entity Segregation
**Status**: ✅ CONFIRMED PASS

Design maintains strict layer separation:
- **Service Layer**: `lib/service/firebase/` (Firestore operations only)
- **Repository Layer**: `lib/feature/manga/repository/manga_repository.dart` with conversion methods (`CloudManga` ↔ `Manga`)
- **Presentation Layer**: Unchanged, continues using domain models (`Manga`, `MangaPage`)

**Entity Conversion**:
- `CloudManga.toManga()`: Converts Firestore map deltas to `Delta` objects
- `Manga.toCloudManga()`: Converts `Delta` objects to Firestore map format
- No service layer entities exposed to UI (constitution maintained)

### II. Code Generation Discipline
**Status**: ✅ CONFIRMED PASS

Post-migration code generation requirements:
- ✅ Freezed models: `manga.freezed.dart` (domain models updated)
- ✅ JSON serialization: `manga.g.dart`, `cloud_manga.g.dart`
- ✅ Riverpod providers: `manga_repository.g.dart`, `firebase_service.g.dart`
- ❌ Removed: Drift table generation (no longer needed)

**Verification**: Quickstart guide includes explicit `dart run build_runner build -d` steps after model changes.

### III. Repository Pattern & Data Access
**Status**: ✅ CONFIRMED PASS

Repository pattern strengthened:
- All Firestore operations encapsulated in `FirebaseService`
- `MangaRepository` provides domain-focused API (see `contracts/repository_api.md`)
- UI components use repository methods exclusively (no direct Firestore access)
- New exception types (`AuthException`, `NotFoundException`) improve error handling

**Improvement**: Cleaner separation than Drift version (no DAO leakage).

### IV. State Management with Riverpod
**Status**: ✅ CONFIRMED PASS

State management unchanged:
- Riverpod providers for repository and Firebase services
- Stream-based reactive updates maintained
- ViewModels continue using `@riverpod` annotations
- Flutter Hooks usage for local state unchanged

**No breaking changes** to state management layer.

### V. Rich Text Data Consistency
**Status**: ✅ RESOLVED

**Previous Status**: ⚠️ REQUIRES ATTENTION (decision needed on delta storage)

**Resolution** (from research.md and data-model.md):
- **Decision**: Hybrid approach - Firestore embeds deltas, Domain models use DeltaId references
- **Rationale**: Combines Firestore optimization with minimal domain model changes
- **Constitution Alignment**: Acceptable because:
  1. Firestore is document-oriented (denormalization is standard)
  2. Domain model preserves existing DeltaId pattern (minimal breaking changes)
  3. Repository DeltaCache encapsulates conversion logic (clean separation)
  4. Document size <100KB for typical manga (well under 1MB limit)

**Implementation Pattern**:
- **Firestore layer**: `ideaMemo`, `memoDelta`, etc. stored as nested maps in documents
- **Domain layer**: `DeltaId` (int) references maintained in Manga/MangaPage models
- **Repository layer**: DeltaCache converts between embedded maps and DeltaId references
- **UI layer**: Unchanged - continues using `getDeltaStream(DeltaId)`

**Constitution Compliance**: ✅ Pattern documented in data-model.md, preserves existing architecture while adopting Firestore best practices.

### Post-Design Gate Decision
✅ **PASS** - All constitution principles confirmed. Design artifacts complete and compliant. Ready for task generation phase.

