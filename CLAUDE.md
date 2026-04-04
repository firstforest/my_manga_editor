# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**My Manga Editor** — Flutter desktop app (Windows/macOS) for manga plot editing. Pages have 3 editing areas: memo, dialogue (セリフ), stage direction (ト書き). Exports dialogue text for ClipStudio Paint integration.

## Development Commands

```bash
# Setup (requires mise: https://mise.jdx.dev/)
mise i

# Run
flutter run
flutter run --dart-define=OPENAI_API_KEY=your_key  # with AI comment feature

# Code generation (REQUIRED after model/provider changes)
dart run build_runner build -d   # or: mise run gen
# Data layer has separate build_runner:
cd local_package/my_manga_editor_data && dart run build_runner build -d && cd -

# Quality
flutter analyze
flutter test
flutter test test/feature/manga/provider/manga_providers_test.dart  # single test
```

## Architecture

### Data Flow
```
UI (lib/feature/) → ViewModels (Riverpod Notifiers) → Repository → Service ↔ Firestore
```

### Multi-Package Structure
- **my_manga_editor** (root) — UI layer (`lib/feature/`, `lib/hooks/`)
- **my_manga_editor_data** (`local_package/my_manga_editor_data/`) — data layer (repository, service, domain model)
- **my_manga_editor_common** (`local_package/my_manga_editor_common/`) — shared utilities (logger)

### Feature Structure
```
lib/feature/{name}/
  ├── page/       # screen-level widgets
  ├── view/       # reusable sub-widgets
  └── provider/   # Riverpod providers & view models
```

### Key Technology
- **Flutter 3.32.4**, **Riverpod 3.x** (with hooks), **Freezed** for immutable models
- **Cloud Firestore** with offline persistence (no local database)
- **Flutter Quill** for rich text editing (Delta format)
- **go_router** for routing (auth guard redirects unauthenticated users to `/login`)
- Widgets use `HookConsumerWidget` or `ConsumerWidget` as needed

### Testing
- `ProviderContainer` with overrides for Riverpod provider isolation
- `@GenerateNiceMocks` (Mockito) for mock generation
- Tests in `test/feature/manga/provider/`

## Critical Notes

### Code Generation is Mandatory
After modifying `@freezed` classes, `@riverpod` providers, or any file importing `*.g.dart`/`*.freezed.dart`, run `dart run build_runner build -d`. Root and data package have **separate** `build_runner` — see `.claude/rules/data-layer.md`.

### CI/CD
- GitHub Actions deploys Flutter Web to GitHub Pages on push to `main`
- Workflow: `.github/workflows/main.yml`
