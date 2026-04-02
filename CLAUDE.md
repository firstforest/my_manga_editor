# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**My Manga Editor** — Flutter desktop app for manga plot editing. Integrates with ClipStudio Paint.

## Development Commands

```bash
# Setup (requires mise: https://mise.jdx.dev/)
mise i

# Run
flutter run
flutter run --dart-define=OPENAI_API_KEY=your_key  # with AI comment feature

# Code generation (REQUIRED after model/provider changes)
dart run build_runner build -d   # or: mise run gen
# For data layer changes — see .claude/rules/data-layer.md

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

### Key Technology
- **Flutter 3.32.4**, **Riverpod 3.x** (with hooks), **Freezed** for immutable models
- **Cloud Firestore** with offline persistence (no local database)
- **Flutter Quill** for rich text editing (Delta format)

## Critical Notes

### Code Generation is Mandatory
After modifying `@freezed` classes, `@riverpod` providers, or any file importing `*.g.dart`/`*.freezed.dart`, run `dart run build_runner build -d`. Root and data package have **separate** `build_runner` — see `.claude/rules/data-layer.md`.

### CI/CD
- GitHub Actions deploys Flutter Web to GitHub Pages on push to `main`
- Workflow: `.github/workflows/main.yml`
