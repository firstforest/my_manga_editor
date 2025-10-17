<!--
Sync Impact Report:
Version change: None (Initial ratification) → 1.0.0
Modified principles: N/A (Initial creation)
Added sections:
  - Core Principles (5 principles)
  - Data Integrity & Persistence
  - Quality Standards
  - Governance
Removed sections: N/A
Templates requiring updates:
  ✅ plan-template.md: Verified - Constitution Check section already compatible
  ✅ spec-template.md: Verified - Requirements section aligns with principles
  ✅ tasks-template.md: Verified - Phase structure supports code generation and testing requirements
Follow-up TODOs: None
-->

# My Manga Editor Constitution

## Core Principles

### I. Code Generation Discipline (NON-NEGOTIABLE)

Code generation via `build_runner` is MANDATORY after any modification to:
- Models with `@freezed` annotation
- Database schema in `database.dart` (Drift tables)
- Files with `@riverpod` or `@Riverpod` annotations
- Any file importing `*.g.dart` or `*.freezed.dart`

**Rationale**: The project architecture relies on generated code for immutability (Freezed),
database access (Drift DAOs), JSON serialization, and dependency injection (Riverpod).
Skipping code generation causes compilation failures and runtime errors.

**Implementation**: Run `dart run build_runner build -d` or `mise run gen` after schema/model changes.

### II. Repository Pattern for Data Access

All database operations MUST be accessed through the repository layer:
- Direct database queries are prohibited in UI/ViewModel layers
- Repositories provide the single source of truth for data operations
- ViewModels consume Riverpod providers that expose repository methods
- Drift DAOs are implementation details hidden behind repositories

**Rationale**: Separation of concerns enables testability (mocking repositories),
maintains clear architectural boundaries, and provides a consistent data access API
across the application.

### III. Rich Text Storage as Quill Deltas

All rich text content (memos, dialogues, stage directions) MUST be stored as
Quill Delta JSON format in the `DbDeltas` table with foreign key references:
- No plain text storage for editable content
- Delta IDs serve as foreign keys from content tables
- Export functions convert Deltas to other formats (Markdown, plain text)
- ClipStudio integration extracts plain text from Delta JSON

**Rationale**: Quill Delta format preserves formatting information, supports rich editing
features, and enables consistent export to multiple target formats while maintaining
a single source of truth.

### IV. State Management via Riverpod + Hooks

State management follows a strict hierarchy:
- **Riverpod Providers**: Dependency injection, global state, repository access
- **ViewModels** (`*_view_model.dart`): Complex UI state with `@riverpod` notifiers
- **Flutter Hooks**: Local widget state (text controllers, animation, ephemeral UI)
- Direct `StatefulWidget` usage is discouraged unless hooks are insufficient

**Rationale**: This pattern provides compile-time safety, reduces boilerplate compared
to traditional StatefulWidget, enables easy testing via provider overrides, and maintains
clear separation between business logic and UI state.

### V. Database Referential Integrity

All database foreign key relationships MUST enforce CASCADE delete behavior:
- Deleting a `DbMangas` row cascades to all `DbMangaPages` and their `DbDeltas`
- No orphaned data in the database
- Drift schema definitions explicitly declare foreign key constraints
- Web platform uses SQLite WASM with full foreign key support

**Rationale**: Referential integrity prevents data corruption, simplifies deletion logic
(no manual cleanup required), and ensures consistency across all supported platforms
including web browsers.

## Data Integrity & Persistence

**Database as Single Source of Truth**: The SQLite database via Drift ORM is the
authoritative data source. All UI state is derived from database queries through
repository streams.

**Asynchronous Operations**: All database operations are asynchronous (`Future`/`Stream`
based) to avoid blocking the UI thread, even for small operations.

**Migration Safety**: Database schema changes require explicit migration definitions
in Drift to preserve user data across app updates.

## Quality Standards

**Testing Focus**: Unit tests target the repository layer using Mockito for database
mocking. Tests reside in `test/repositories/`.

**Code Analysis**: `flutter analyze` must pass with zero errors before commits.
Warnings should be addressed or explicitly suppressed with justification.

**Platform Support**: All features must be tested on Windows and macOS as primary
development targets. Web, Linux, iOS, and Android are supported but may have
platform-specific limitations.

**Cross-Platform UI**: Flutter widgets must be platform-agnostic. Platform-specific
code (if required) is isolated in `windows/`, `macos/`, `linux/`, `ios/`, `android/`,
`web/` directories.

## Governance

This constitution supersedes all other development practices and guidelines.
Amendments require:
1. Documentation of the proposed change with rationale
2. Validation that dependent templates remain consistent
3. Version increment following semantic versioning
4. Update of this constitution file and affected templates

**Compliance Review**: All pull requests must verify adherence to these principles.
Violations require explicit justification in the PR description and approval from
a project maintainer.

**Versioning Policy**:
- MAJOR: Breaking changes to core principles (e.g., removing Repository Pattern)
- MINOR: New principles added or material expansions to existing principles
- PATCH: Clarifications, wording improvements, typo fixes

**Runtime Guidance**: Development instructions and commands are documented in
`CLAUDE.md` for AI assistants and `README.md` for human developers.

**Version**: 1.0.0 | **Ratified**: 2025-10-18 | **Last Amended**: 2025-10-18
