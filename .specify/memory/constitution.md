<!--
Sync Impact Report:
Version change: 1.0.0 → 1.1.0
Modified principles:
  - V. Rich Text Data Consistency (clarified Firestore Delta subcollection model)
Added sections: None
Removed sections: None
Templates requiring updates:
  ✅ plan-template.md - Existing Constitution Check remains compatible
  ✅ spec-template.md - Requirements align with Delta subcollection model
  ✅ tasks-template.md - Task organization supports Delta CRUD operations
Follow-up TODOs: None
-->

# My Manga Editor Constitution

## Core Principles

### I. Layered Architecture & Entity Segregation

**MUST** maintain strict separation between architectural layers. Each layer MUST define its own entities and MUST NOT leak abstractions to other layers.

**Layer Definition**:
- **Service Layer** (`lib/service/`): Cloud storage schemas (Firestore), raw data operations
- **Domain/Repository Layer** (`lib/feature/*/repository/`, `lib/feature/*/model/`): Business entities (Freezed models), business logic
- **Presentation Layer** (`lib/feature/*/page/`, `lib/feature/*/view/`, `lib/feature/*/provider/`): UI state models, view models

**Mandatory Entity Conversion**:
- Service → Domain: Cloud entities (`CloudManga`, `CloudMangaPage`, `CloudDelta`) MUST be converted to domain models (`Manga`, `MangaPage`) in repositories
- Domain → Presentation: Domain models MAY be used directly in UI or converted to view-specific state models when needed
- Presentation → Domain: UI state MUST be converted to domain models before passing to repositories

**Rationale**: Prevents tight coupling between cloud schema and business logic. Allows independent evolution of persistence strategy without affecting domain models or UI. Enables testing of business logic without database dependencies.

### II. Code Generation Discipline (NON-NEGOTIABLE)

**MUST** run `dart run build_runner build -d` (or `mise run gen`) after ANY modification to:
- Models with `@freezed` annotation
- Cloud models in `lib/service/firebase/model/`
- Files with `@riverpod` or `@Riverpod` annotations
- Any file importing `*.g.dart` or `*.freezed.dart`

**Verification**: Before marking any code task as complete, verify generated files are up-to-date. Build failures due to missing code generation are considered blocking errors.

**Rationale**: Code generation is not optional in this project. Freezed and Riverpod rely on generated code for immutability, serialization, and dependency injection. Skipping generation causes compilation failures and runtime errors.

### III. Repository Pattern & Data Access

**MUST** access all data through repository interfaces. UI components MUST NOT directly query the database.

**Repository Responsibilities**:
- Encapsulate all database operations (CRUD)
- Convert cloud entities to domain models and vice versa
- Handle business logic related to data persistence
- Provide async APIs for all data operations
- Manage Delta cache for efficient in-memory access

**Prohibited Patterns**:
- Direct database queries from UI (pages/views)
- Passing cloud entities (`Cloud*` classes) to presentation layer
- Business logic in database/service layer

**Rationale**: Separation of concerns. Repositories provide a clean boundary between data storage and business logic, enabling testability and future migration (e.g., schema refactoring, provider switching).

### IV. State Management with Riverpod

**MUST** use Riverpod for dependency injection and cross-widget state. **MAY** use Flutter Hooks for local widget state.

**Provider Usage**:
- Cloud storage instance: `@riverpod` provider
- Repositories: `@riverpod` provider with storage dependency
- ViewModels: `@riverpod` class with state management logic
- Simple derived state: `@riverpod` functional providers

**Local State**: Use `useState`, `useEffect`, etc. from Flutter Hooks for UI-specific ephemeral state (e.g., text editing controllers, animation controllers).

**Rationale**: Riverpod provides compile-time safe dependency injection and reactive state management. Hooks reduce boilerplate for local state without compromising Riverpod's global state capabilities.

### V. Rich Text Data Consistency (Delta Subcollection Model)

**MUST** store ALL rich text content (memos, dialogues, stage directions) as separate CloudDelta documents in Firestore subcollections. Domain models MUST reference deltas by DeltaId (integer) using the in-memory DeltaCache.

**Delta Storage Rules**:
- One `CloudDelta` document per rich text field
- CloudDelta documents stored in `mangas/{mangaId}/deltas/{deltaId}` subcollection
- CloudDelta contains: `ops` (Quill Delta array), `fieldName` (string: 'ideaMemo', 'memoDelta', etc.), `pageId` (optional), timestamps
- Firestore automatically cascades delete when parent manga is deleted
- Domain models use `DeltaId` (int) references, not Delta objects directly
- Repository DeltaCache maps internal DeltaId → Delta for efficient in-memory access

**Metadata Tracking**:
- Each Delta must track: `mangaId`, `fieldName`, `pageId` (if page-level delta)
- Enables efficient querying and deletion of related deltas

**Prohibited Patterns**:
- Storing rich text embedded within Manga/Page documents
- Storing plain text or HTML directly in manga/page documents
- Duplicating text content across documents
- Bypassing Delta subcollection for rich text storage

**Rationale**: Separate Delta storage enables granular updates (changing one field's Delta doesn't rewrite parent document), efficient querying by field type, and straightforward deletion semantics. In-memory DeltaCache bridges the gap between cloud storage (separate documents) and domain model (DeltaId references), avoiding unnecessary serialization while maintaining type safety.

## Development Workflow

**Code Quality Gates**:
1. `flutter analyze` MUST pass with zero errors before commit
2. Code generation MUST be run after model/cloud schema changes
3. All modified features MUST be manually tested before commit
4. Breaking changes to cloud schema MUST include migration strategy or data format notes

**Commit Discipline**:
- Commit after completing logical units of work (single feature, bug fix, refactor)
- DO NOT commit generated files separately from source changes
- Include context in commit messages (e.g., "refactor: migrate deltas to subcollection model")

**Branching Strategy**:
- Feature branches for non-trivial changes
- Main branch deployable at all times
- Squash commits when merging if history is messy

**Delta Sync**:
- Repository MUST handle both online and offline Delta sync
- Offline Delta changes queued in DeltaCache with `needsSync` flag
- Sync triggered automatically on connection restore or via `forceSyncAll()`
- All Delta CRUD operations in repositories MUST update parent document timestamps

## Testing Standards

**Test Coverage Priorities** (in order):
1. Repository layer: Business logic, entity conversions, Delta cache operations
2. ViewModels: State transitions, user action handling
3. Widget tests: Critical user journeys (optional, resource permitting)

**Test Requirements**:
- Use Mockito for mocking dependencies (Firestore, repositories)
- Repository tests MUST verify entity conversion correctness
- Repository tests MUST verify DeltaCache synchronization
- ViewModel tests MUST verify state management logic
- Tests located in `test/` directory mirroring `lib/` structure

**Testing Tools**:
- `flutter test` for unit and widget tests
- Mockito for dependency mocking
- Test files: `test/repositories/*_test.dart`

## Governance

**Constitution Authority**: This constitution supersedes all other development practices. When conflicts arise, constitution principles take precedence.

**Amendment Process**:
1. Identify principle violation or gap
2. Propose amendment with rationale
3. Update constitution with version bump (MAJOR/MINOR/PATCH)
4. Propagate changes to dependent templates (plan, spec, tasks)
5. Document migration path for existing code if needed

**Version Policy**:
- **MAJOR**: Backward-incompatible changes (e.g., removing a layer requirement, incompatible schema overhaul)
- **MINOR**: New principles or expanded guidance (e.g., adding performance standards, refining Delta storage model)
- **PATCH**: Clarifications, typo fixes, non-semantic changes

**Compliance Review**:
- All feature plans MUST include Constitution Check section
- PRs MUST verify compliance with relevant principles
- Complexity violations MUST be justified in plan.md Complexity Tracking table

**Guidance Files**: This constitution defines architectural rules. For runtime development guidance (CLAUDE.md), refer to `CLAUDE.md`.

**Version**: 1.1.0 | **Ratified**: 2025-01-19 | **Last Amended**: 2025-10-25
