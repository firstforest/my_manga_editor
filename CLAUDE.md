# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**My Manga Editor** (漫画制作用プロットエディター) is a Flutter cross-platform desktop application for manga creators to manage story plots, dialogues, and page layouts. Integrates with ClipStudio Paint for seamless workflow.

## Development Commands

```bash
# Setup (requires mise: https://mise.jdx.dev/)
mise i

# Run
flutter run
flutter run --dart-define=OPENAI_API_KEY=your_key  # with AI comment feature

# Code generation (REQUIRED after model/provider changes)
dart run build_runner build -d   # or: mise run gen

# Quality
flutter analyze
flutter test
flutter test test/feature/manga/provider/manga_providers_test.dart  # single test
```

## Architecture

### Data Flow
```
UI (lib/feature/) → ViewModels (Riverpod Notifiers) → Repository → Service ↔ Firestore
                                                        ↑ local_package/my_manga_editor_data/
```

### Key Technology
- **Flutter 3.32.4**, **Riverpod 3.x** (with hooks), **Freezed** for immutable models
- **Cloud Firestore** with offline persistence (no local database)
- **Flutter Quill** for rich text editing (Delta format)
- **dart_openai** for AI comment generation

### Multi-Package Structure
The project is split into three packages:
- **my_manga_editor** (root) — UI layer (`lib/feature/`, `lib/hooks/`)
- **my_manga_editor_data** (`local_package/my_manga_editor_data/`) — data layer (repository, service, domain model)
- **my_manga_editor_common** (`local_package/my_manga_editor_common/`) — shared utilities (logger)

```
lib/                                        # UI layer (root package)
├── feature/
│   ├── manga/                              # Core manga editing
│   │   ├── provider/                       # Riverpod providers & view models
│   │   ├── page/                           # Screen-level: main_page, manga_grid_page
│   │   └── view/                           # Widgets: tategaki, workspace, lock_indicator, etc.
│   ├── ai_comment/view/                    # AI comment generation (OpenAI)
│   └── setting/page/                       # App settings (SharedPreferences)
├── hooks/quill_controller_hook.dart
└── main.dart

local_package/my_manga_editor_data/lib/     # Data layer
├── model/manga.dart                        # Domain models (Manga, MangaPage, ID types)
├── repository/                             # manga, auth, ai, setting repositories
└── service/firebase/                       # Firebase integration
    ├── firebase_service.dart               # Firestore CRUD
    ├── auth_service.dart                   # Firebase Auth + Google Sign-In
    ├── lock_manager.dart                   # Collaborative edit lock
    └── model/                              # Firestore document models (CloudManga, etc.)

local_package/my_manga_editor_common/lib/   # Shared utilities
└── logger.dart
```

### Firestore Schema
```
users/{userId}/mangas/{mangaId}           → CloudManga (name, startPageDirection, editLock)
users/{userId}/mangas/{mangaId}/pages/    → CloudMangaPage (pageIndex)
users/{userId}/mangas/{mangaId}/deltas/   → CloudDelta (ops, fieldName, pageId?)
```

Deltas are stored in a **separate `deltas` subcollection** (not embedded in parent documents). Each CloudDelta has a `fieldName` ('ideaMemo', 'memoDelta', 'stageDirectionDelta', 'dialoguesDelta') and optional `pageId` for page-level deltas.

### Domain Model ID Types (Extension Types)
Defined in `local_package/my_manga_editor_data/lib/model/manga.dart`:
- `MangaId(String)`, `MangaPageId(String)`, `DeltaId(String)` — type-safe ID wrappers
- Domain models (`Manga`, `MangaPage`) reference Deltas by `DeltaId`, not by Delta objects

### Repository Pattern
- `MangaRepository` (keepAlive Riverpod provider) handles all data operations
- Maintains `_pageToMangaMap` for MangaPageId → MangaId reverse lookups
- Connectivity monitoring via `connectivity_plus` with automatic sync on reconnect
- Converts between `CloudManga`/`CloudMangaPage`/`CloudDelta` (Firestore) and `Manga`/`MangaPage` (domain)

### Edit Lock System
- `LockManager` prevents concurrent editing via Firestore transactions
- Lock duration: 60s, heartbeat: 30s, tracked by device ID
- `EditLock` embedded in CloudManga document

### Riverpod Provider Patterns
- `@riverpod` (function-style) for streams/futures: `allMangaList`, `mangaPageIdList`, `onlineStatus`
- `@Riverpod(keepAlive: true)` for persistent state: `MangaRepository`, `FirebaseService`
- `@riverpod` class notifiers for complex UI state: `MangaPageViewModelNotifier`

## Critical Development Notes

### Code Generation is Mandatory
After modifying any of these, run `dart run build_runner build -d`:
- `@freezed` classes (model files)
- `@riverpod` / `@Riverpod` annotated providers
- Cloud models in `local_package/my_manga_editor_data/lib/service/firebase/model/`
- Any file importing `*.g.dart` or `*.freezed.dart`

Generated files (`*.g.dart`, `*.freezed.dart`) are excluded from analysis via `analysis_options.yaml`.

### Testing
- Tests in `test/feature/manga/provider/` using Mockito with `@GenerateNiceMocks`
- Uses `ProviderContainer` for Riverpod provider isolation
- `fake_cloud_firestore` package available for Firestore mocking

### CI/CD
- GitHub Actions deploys Flutter Web to GitHub Pages on push to `main`
- Workflow: `.github/workflows/main.yml`
