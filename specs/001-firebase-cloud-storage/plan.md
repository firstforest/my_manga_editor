# Implementation Plan: Firebase Cloud Storage

**Branch**: `001-firebase-cloud-storage` | **Date**: 2025-10-18 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-firebase-cloud-storage/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Replace the existing Drift-based local SQLite storage with Firebase cloud storage to enable cross-device data synchronization for manga creators. This implementation will provide user authentication via email/password, bidirectional sync between devices, offline-first capabilities with automatic sync when online, and a migration path from existing Drift databases to Firebase. The system will maintain the current Quill Delta format for rich text content while storing data in the cloud with proper user isolation and security rules.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.32.4
**Primary Dependencies**: Firebase Core, Firebase Auth, Cloud Firestore, Riverpod 3.0.0-dev.15, Freezed 3.0.6, connectivity_plus (network monitoring)
**Storage**: Cloud Firestore (replacing Drift/SQLite), Firebase Authentication for user management
**Testing**: flutter test, Mockito for repository mocking
**Target Platform**: Windows, macOS, Linux, iOS, Android, Web (all existing platforms)
**Project Type**: Mobile/Desktop cross-platform (Flutter multi-platform)
**Performance Goals**: <5 second sync time for data changes, <30 second initial load on new device, 60fps UI during sync operations
**Constraints**: Offline-capable (must work without connectivity), preserve existing Quill Delta format, maintain 100% data fidelity during Drift migration, last-write-wins conflict resolution
**Scale/Scope**: Support for 100 manga titles per user, 1000 total pages, existing codebase with established Repository pattern and Riverpod architecture

**Key Technical Decisions Requiring Research**:
- **Firebase Service Choice**: NEEDS CLARIFICATION - Cloud Firestore vs Realtime Database for manga data storage (structured documents vs real-time JSON)
- **Offline Persistence**: NEEDS CLARIFICATION - Best practices for Firestore offline persistence in Flutter with complex nested data
- **Auth UI Implementation**: NEEDS CLARIFICATION - Custom Flutter forms vs FirebaseUI Auth package for email/password flows
- **Migration Strategy**: NEEDS CLARIFICATION - One-time bulk upload vs incremental background migration patterns
- **Security Rules Structure**: NEEDS CLARIFICATION - Optimal Firestore security rules pattern for user-isolated collections
- **Sync State Management**: NEEDS CLARIFICATION - How to track and display sync status (pending uploads, conflicts) in Riverpod architecture
- **Delta Storage**: NEEDS CLARIFICATION - Store Quill Deltas as JSON strings in Firestore fields vs subcollections vs separate collection

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Principle I: Code Generation Discipline ⚠️ MODIFIED

**Status**: REQUIRES ATTENTION - Drift code generation will be replaced/removed

**Assessment**: Currently, the project uses `build_runner` for:
- Freezed models (`*.freezed.dart`)
- Drift DAOs and queries (`*.g.dart` for database)
- Riverpod providers (`*.g.dart`)
- JSON serialization (`*.g.dart`)

**Impact of Firebase Migration**:
- ✅ **PRESERVED**: Freezed models will still be used for Manga/MangaPage data classes
- ✅ **PRESERVED**: Riverpod code generation continues for providers and notifiers
- ✅ **PRESERVED**: JSON serialization for Freezed models (needed for Firestore document conversion)
- ❌ **REMOVED**: Drift database schema and DAO generation (replaced by Firestore API)

**Compliance**: PASSES - Code generation discipline remains critical. Firebase reduces generation scope but doesn't eliminate it. Models, providers, and JSON serialization still require `build_runner`.

---

### Principle II: Repository Pattern for Data Access ✅ PRESERVED

**Status**: FULLY COMPATIBLE

**Assessment**: Firebase implementation will maintain the existing repository pattern:
- Current: `MangaRepository` abstracts Drift DAO operations
- Future: `MangaRepository` will abstract Firestore collection operations
- ViewModels continue consuming Riverpod providers
- UI layer remains unaware of storage implementation (Drift → Firestore is transparent)

**Compliance**: PASSES - Repository layer provides ideal abstraction point for storage migration. Existing repository interfaces can be preserved while swapping implementation.

---

### Principle III: Rich Text Storage as Quill Deltas ✅ PRESERVED

**Status**: FULLY COMPATIBLE

**Assessment**: Quill Delta JSON format will be maintained in Firebase:
- Current: Deltas stored as JSON text in `DbDeltas` table with foreign keys
- Future: Deltas stored as JSON in Firestore documents (either embedded or referenced)
- Delta structure remains unchanged (JSON serialization compatible with Firestore)
- Export functions (Markdown, plain text) continue to work without modification

**Compliance**: PASSES - Firestore natively supports JSON storage, making Delta preservation straightforward. The format is storage-agnostic.

---

### Principle IV: State Management via Riverpod + Hooks ✅ PRESERVED

**Status**: FULLY COMPATIBLE

**Assessment**: Riverpod architecture integrates well with Firebase:
- Riverpod providers can wrap Firestore streams (real-time listeners)
- ViewModels continue using `@riverpod` notifiers for complex state
- Flutter Hooks remain available for local widget state
- Firebase Auth state can be exposed via Riverpod provider

**Compliance**: PASSES - No changes required to state management architecture. Firebase streams map naturally to Riverpod's reactive model.

---

### Principle V: Database Referential Integrity ⚠️ MODIFIED

**Status**: REQUIRES DESIGN ADAPTATION

**Assessment**: Firestore does not enforce foreign key constraints or CASCADE deletes:
- Current: Drift enforces FK constraints; deleting manga cascades to pages and deltas
- Future: Application logic must handle cascading deletes manually
- Risk: Orphaned data if delete operations fail partway through

**Mitigation Strategy**:
- Implement cascading delete logic in repository layer (delete children before parent)
- Use Firestore batch writes to ensure atomic multi-document deletes
- Consider Firestore subcollections for hierarchical data (manga > pages > deltas) where parent deletion automatically removes children
- Add validation checks to prevent orphaned references

**Compliance**: CONDITIONAL PASS - Referential integrity principle must be maintained through application logic rather than database enforcement. This is acceptable for cloud NoSQL but requires careful implementation and testing.

---

### Summary

**Overall Status**: ✅ PASSES WITH MODIFICATIONS

**Violations Requiring Justification**: None - all principles remain applicable

**Adaptations Required**:
1. Reduced code generation scope (no Drift, keep Freezed/Riverpod/JSON)
2. Manual referential integrity enforcement in repository layer

**Blocker Check**: No constitutional blockers identified. Firebase architecture is compatible with project principles. Proceed to Phase 0 research.

---

## Post-Design Constitution Re-Evaluation

*Re-checked after Phase 1 design completion (2025-10-18)*

### Principle I: Code Generation Discipline ✅ CONFIRMED COMPATIBLE

**Post-Design Assessment**: Design confirms code generation requirements remain:
- Freezed models for `Manga` and `MangaPage` with custom `@DeltaConverter` and `@TimestampConverter`
- Riverpod providers for repository and authentication (`@riverpod` annotations)
- JSON serialization for Firestore document conversion (`*.g.dart`)

**Impact**: Developers must still run `dart run build_runner build -d` after modifying models or providers. Documented in quickstart.md.

### Principle II: Repository Pattern ✅ CONFIRMED PRESERVED

**Post-Design Assessment**: `FirestoreMangaRepository` successfully abstracts Firestore operations:
- Repository interface defined in `contracts/repository-api.md`
- All Firestore queries encapsulated in repository methods
- UI layer accesses data via Riverpod stream providers (no direct Firestore calls)
- Existing ViewModels can migrate by swapping repository provider

**Implementation**: See `firestore_manga_repository.dart` in quickstart.md.

### Principle III: Rich Text Storage as Quill Deltas ✅ CONFIRMED PRESERVED

**Post-Design Assessment**: Quill Delta format maintained in Firestore:
- Deltas stored as structured maps: `{"ops": [...]}`
- Custom `DeltaConverter` handles serialization (Freezed JsonConverter)
- Data model document confirms Delta structure preservation
- No changes to export functions (Markdown conversion still works)

**Storage Pattern**: Embedded deltas in page documents (see data-model.md).

### Principle IV: State Management via Riverpod + Hooks ✅ CONFIRMED COMPATIBLE

**Post-Design Assessment**: Firebase streams integrate seamlessly with Riverpod:
- Stream providers wrap Firestore `snapshots()` for real-time updates
- Existing `@riverpod` patterns continue (e.g., `watchMangaProvider`)
- Flutter Hooks remain available for local widget state
- Firebase Auth state exposed via `authStateChangesProvider`

**Example**: See auth_providers.dart and repository providers in quickstart.md.

### Principle V: Database Referential Integrity ✅ MITIGATION IMPLEMENTED

**Post-Design Assessment**: Referential integrity enforced via application logic:
- Subcollection hierarchy prevents orphaned pages (pages cannot exist without parent manga)
- Embedded deltas ensure no orphaned delta data
- Cascade delete implemented in `deleteManga()` using batch writes (see repository-api.md)
- Security rules validate document structure and relationships

**Implementation**: Manual cascade delete in repository layer (batch writes). Tested in quickstart checklist.

**Alternative Considered**: Cloud Functions for server-side cascade deletes (deferred to future enhancement).

---

### Final Verdict: ✅ ALL PRINCIPLES MAINTAINED

**Summary**: The completed design successfully maintains all five constitutional principles. Firebase migration is architecturally sound and ready for implementation.

**Design Artifacts Generated**:
1. ✅ research.md - All technical decisions researched and documented
2. ✅ data-model.md - Firestore schema defined with validation rules
3. ✅ contracts/repository-api.md - Repository interfaces specified
4. ✅ quickstart.md - Step-by-step implementation guide created
5. ✅ Agent context updated - Firebase/Firestore added to CLAUDE.md

**Ready for Phase 2**: Implementation can proceed with `/speckit.tasks` command.

## Project Structure

### Documentation (this feature)

```
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```
lib/
├── models/                    # Freezed data models
│   ├── manga.dart             # MODIFIED: Add Firestore serialization
│   ├── manga_page.dart        # MODIFIED: Add Firestore serialization
│   └── sync_status.dart       # NEW: Sync state model
├── database/                  # LEGACY: To be deprecated
│   └── database.dart          # Drift schema (migration source only)
├── firebase/                  # NEW: Firebase integration
│   ├── firebase_config.dart   # Firebase initialization
│   ├── auth/
│   │   ├── auth_repository.dart
│   │   └── auth_service.dart
│   ├── firestore/
│   │   ├── firestore_manga_repository.dart
│   │   ├── firestore_delta_repository.dart
│   │   └── collections.dart   # Collection/document path constants
│   └── migration/
│       ├── drift_to_firebase_migrator.dart
│       └── migration_status.dart
├── repositories/              # MODIFIED: Existing repositories
│   ├── manga_repository.dart  # Interface remains, impl delegates to Firebase
│   └── manga_providers.dart   # MODIFIED: Provide Firebase-backed repo
├── pages/                     # UI layer (minimal changes)
│   ├── auth/                  # NEW: Auth screens
│   │   ├── sign_in_page.dart
│   │   ├── sign_up_page.dart
│   │   └── password_reset_page.dart
│   ├── main/                  # MODIFIED: Add sync status indicator
│   └── grid/                  # Existing pages (unchanged)
└── views/                     # Reusable widgets
    ├── sync_status_indicator.dart  # NEW: Sync status widget
    └── [existing widgets]

test/
├── repositories/              # MODIFIED: Update mocks for Firebase
│   └── manga_repository_test.dart
└── firebase/                  # NEW: Firebase logic tests
    ├── auth_repository_test.dart
    └── migration_test.dart

firebase/                      # NEW: Firebase project config (root level)
├── firestore.rules            # Security rules
└── firestore.indexes.json     # Composite indexes if needed
```

**Structure Decision**: Flutter single-project structure with new `lib/firebase/` module for cloud functionality. The existing `lib/repositories/` layer provides abstraction, allowing Drift → Firebase migration without UI changes. Legacy `lib/database/` will remain temporarily for migration purposes, then be removed. Firebase project configuration files live at repository root following Flutter conventions.

## Complexity Tracking

*Fill ONLY if Constitution Check has violations that must be justified*

**Status**: No violations - table not applicable for this feature.

All constitutional principles are preserved or adapted within acceptable parameters. The Firebase migration maintains existing architectural patterns (Repository, Riverpod, Freezed, Quill Deltas) while swapping the storage backend.

