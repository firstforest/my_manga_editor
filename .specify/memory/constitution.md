<!--
Sync Impact Report:
Version change: [none] → 1.0.0
Modified principles: N/A (initial constitution)
Added sections:
  - I. Layered Architecture & Entity Segregation
  - II. Code Generation Discipline
  - III. Repository Pattern & Data Access
  - IV. State Management with Riverpod
  - V. Rich Text Data Consistency
  - Development Workflow
  - Testing Standards
Removed sections: N/A (initial constitution)
Templates requiring updates:
  ✅ plan-template.md - Constitution Check section aligned
  ✅ spec-template.md - Requirements structure aligns with principles
  ✅ tasks-template.md - Task organization supports layered architecture
Follow-up TODOs: None
-->

# My Manga Editor Constitution

## Core Principles

### I. Layered Architecture & Entity Segregation

**MUST** maintain strict separation between architectural layers. Each layer MUST define its own entities and MUST NOT leak abstractions to other layers.

**Layer Definition**:
- **Service Layer** (`lib/service/`): Database schemas (Drift tables), raw data operations
- **Domain/Repository Layer** (`lib/feature/*/repository/`, `lib/feature/*/model/`): Business entities (Freezed models), business logic
- **Presentation Layer** (`lib/feature/*/page/`, `lib/feature/*/view/`, `lib/feature/*/provider/`): UI state models, view models

**Mandatory Entity Conversion**:
- Service → Domain: Database entities (`DbManga`, `DbMangaPage`, `DbDelta`) MUST be converted to domain models (`Manga`, `MangaPage`) in repositories
- Domain → Presentation: Domain models MAY be used directly in UI or converted to view-specific state models when needed
- Presentation → Domain: UI state MUST be converted to domain models before passing to repositories

**Rationale**: Prevents tight coupling between database schema and business logic. Allows independent evolution of persistence strategy without affecting domain models or UI. Enables testing of business logic without database dependencies.

### II. Code Generation Discipline (NON-NEGOTIABLE)

**MUST** run `dart run build_runner build -d` (or `mise run gen`) after ANY modification to:
- Models with `@freezed` annotation
- Database tables in `database.dart`
- Files with `@riverpod` or `@Riverpod` annotations
- Any file importing `*.g.dart` or `*.freezed.dart`

**Verification**: Before marking any code task as complete, verify generated files are up-to-date. Build failures due to missing code generation are considered blocking errors.

**Rationale**: Code generation is not optional in this project. Freezed, Drift, and Riverpod rely on generated code for immutability, serialization, and dependency injection. Skipping generation causes compilation failures and runtime errors.

### III. Repository Pattern & Data Access

**MUST** access all data through repository interfaces. UI components MUST NOT directly query the database.

**Repository Responsibilities**:
- Encapsulate all database operations (CRUD)
- Convert database entities to domain models and vice versa
- Handle business logic related to data persistence
- Provide async APIs for all data operations

**Prohibited Patterns**:
- Direct database queries from UI (pages/views)
- Passing database entities (`Db*` classes) to presentation layer
- Business logic in database layer

**Rationale**: Separation of concerns. Repositories provide a clean boundary between data storage and business logic, enabling testability and future migration (e.g., from SQLite to cloud storage).

### IV. State Management with Riverpod

**MUST** use Riverpod for dependency injection and cross-widget state. **MAY** use Flutter Hooks for local widget state.

**Provider Usage**:
- Database instance: `@riverpod` provider
- Repositories: `@riverpod` provider with database dependency
- ViewModels: `@riverpod` class with state management logic
- Simple derived state: `@riverpod` functional providers

**Local State**: Use `useState`, `useEffect`, etc. from Flutter Hooks for UI-specific ephemeral state (e.g., text editing controllers, animation controllers).

**Rationale**: Riverpod provides compile-time safe dependency injection and reactive state management. Hooks reduce boilerplate for local state without compromising Riverpod's global state capabilities.

### V. Rich Text Data Consistency

**MUST** store ALL rich text content (memos, dialogues, stage directions) as Quill Delta JSON in `DbDeltas` table. UI components MUST reference deltas by foreign key ID.

**Delta Storage Rules**:
- One `DbDelta` row per rich text field
- Delta IDs stored as foreign keys in parent tables (`DbManga`, `DbMangaPage`)
- CASCADE delete enforced to maintain referential integrity
- Export operations convert Delta JSON to Markdown or plain text as needed

**Prohibited Patterns**:
- Storing plain text or HTML directly in manga/page tables
- Duplicating text content across tables
- Bypassing Delta table for rich text storage

**Rationale**: Quill Delta is the source of truth for formatted text. Centralized storage in `DbDeltas` enables consistent rendering, versioning, and export. Foreign key constraints prevent orphaned content.

## Development Workflow

**Code Quality Gates**:
1. `flutter analyze` MUST pass with zero errors before commit
2. Code generation MUST be run after model/database changes
3. All modified features MUST be manually tested before commit
4. Breaking changes to database schema MUST include migration strategy

**Commit Discipline**:
- Commit after completing logical units of work (single feature, bug fix, refactor)
- DO NOT commit generated files separately from source changes
- Include context in commit messages (e.g., "refactor: migrate manga feature to layered structure")

**Branching Strategy**:
- Feature branches for non-trivial changes
- Main branch deployable at all times
- Squash commits when merging if history is messy

## Testing Standards

**Test Coverage Priorities** (in order):
1. Repository layer: Business logic, entity conversions, database interactions
2. ViewModels: State transitions, user action handling
3. Widget tests: Critical user journeys (optional, resource permitting)

**Test Requirements**:
- Use Mockito for mocking dependencies (database, repositories)
- Repository tests MUST verify entity conversion correctness
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
- **MAJOR**: Backward-incompatible changes (e.g., removing a layer requirement)
- **MINOR**: New principles or expanded guidance (e.g., adding performance standards)
- **PATCH**: Clarifications, typo fixes, non-semantic changes

**Compliance Review**:
- All feature plans MUST include Constitution Check section
- PRs MUST verify compliance with relevant principles
- Complexity violations MUST be justified in plan.md Complexity Tracking table

**Guidance Files**: This constitution defines architectural rules. For runtime development guidance, refer to `CLAUDE.md`.

**Version**: 1.0.0 | **Ratified**: 2025-01-19 | **Last Amended**: 2025-01-19
