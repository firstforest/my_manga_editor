# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**My Manga Editor** (漫画制作用プロットエディター) is a Flutter cross-platform desktop application for manga creators to manage story plots, dialogues, and page layouts. The app integrates with ClipStudio Paint for seamless workflow integration.

## Development Commands

### Setup & Run
```bash
# Install development tools (requires mise: https://mise.jdx.dev/)
mise i

# Run the application
flutter run

# Run with OpenAI API key (for AI comment feature)
flutter run --dart-define=OPENAI_API_KEY=your_api_key
```

### Code Generation (REQUIRED after model/database changes)
```bash
# Generate code for Freezed, JSON serialization, and Riverpod providers
dart run build_runner build -d

# Or use the mise task shortcut:
mise run gen
```

### Code Quality
```bash
# Analyze code for issues
flutter analyze

# Run tests
flutter test

# Check outdated dependencies
flutter pub outdated

# Update dependencies
flutter pub upgrade --major-versions
```

## Architecture Overview

### Technology Stack
- **Flutter 3.32.4** - Cross-platform UI framework
- **Riverpod 3.0.0-dev.15** with hooks - State management
- **Cloud Firestore 5.5.0** - Firebase cloud storage with offline persistence
- **Firebase Auth 5.3.3** - User authentication
- **Flutter Quill 11.4.0** - Rich text editor for manga content
- **Freezed 3.0.6** - Immutable data classes with code generation
- **connectivity_plus 6.0.0** - Network connectivity monitoring
- **dart_openai 5.1.0** - AI comment generation

### Data Flow Architecture
```
UI Layer (Pages/Views)
    ↓ consumes
ViewModels (Riverpod Notifiers)
    ↓ uses
Repositories (Data Access Layer)
    ↓ converts to/from
Domain Models (Manga, MangaPage)
    ↓ syncs with
Cloud Firestore (Firebase)
    ↓ offline support via
Firestore Offline Persistence
```

### Database Schema (Firebase Firestore)
Collection structure with automatic offline persistence:
- **users/{userId}/mangas/{mangaId}**: Manga metadata (name, startPageDirection, createdAt, updatedAt)
  - `ideaMemo`: Map<String, dynamic> - Embedded Quill Delta JSON
- **users/{userId}/mangas/{mangaId}/pages/{pageId}**: Page content (pageIndex, createdAt, updatedAt)
  - `memoDelta`: Map<String, dynamic> - Embedded Quill Delta JSON
  - `stageDirectionDelta`: Map<String, dynamic> - Embedded Quill Delta JSON
  - `dialoguesDelta`: Map<String, dynamic> - Embedded Quill Delta JSON

All Deltas are embedded in parent documents for cost optimization. The repository layer maintains an in-memory DeltaCache that maps DeltaId (int) to Delta objects for efficient access and updates.

### Firebase-Only Persistence Architecture
**Key Design**: Delta objects are managed by ID reference (DeltaId: int) in the repository layer:
1. **Cache Layer**: `DeltaCache` maintains in-memory Map<DeltaId, Delta> for fast access
2. **Storage Layer**: Deltas embedded in CloudManga/CloudMangaPage documents
3. **Sync Pattern**: Firestore handles automatic sync with offline persistence enabled
4. **Connection Monitoring**: `connectivity_plus` monitors online/offline state and triggers sync on reconnect

### Key Architectural Patterns

#### State Management
- **Riverpod Providers** for dependency injection and state management
- **ViewModels** (`*_view_model.dart`) handle complex UI state
- **Repository Pattern** abstracts data access from UI
- **Flutter Hooks** for local widget state

#### Rich Text Handling (Delta Cache Pattern)
- All text uses Quill Delta format stored as JSON
- Domain models use DeltaId (int) instead of Delta objects directly
- Repository cache maps DeltaId → Delta for efficient in-memory access
- Deltas are embedded in Firestore documents (CloudManga/CloudMangaPage)
- Export functionality converts Deltas to Markdown for AI processing
- ClipStudio integration extracts plain text from Deltas
- Delta cache is cleared and repopulated on each app launch from Firestore

#### Code Generation Dependencies
Files requiring regeneration after changes:
- `*.freezed.dart` - Freezed immutable classes
- `*.g.dart` - JSON serialization (Cloud models)
- Riverpod provider files with `@riverpod` or `@Riverpod` annotations
- Model files must be regenerated if any changes to `@freezed` classes or `@riverpod` providers

### Project Structure
```
lib/
├── feature/
│   └── manga/
│       ├── model/              # Freezed domain models (Manga, MangaPage, SyncStatus)
│       ├── repository/         # Data access layer with Firebase integration
│       │   ├── manga_repository.dart    # Main data operations with Delta cache
│       │   ├── delta_cache.dart         # In-memory Delta ID cache
│       │   ├── exceptions.dart          # Custom repository exceptions
│       │   └── manga_providers.dart     # Riverpod providers
│       ├── provider/            # State management and Riverpod notifiers
│       │   ├── manga_providers.dart     # Manga stream providers
│       │   └── manga_page_view_model.dart
│       ├── page/                # Screen-level components
│       │   ├── main_page.dart         # Main editor with rich text editing
│       │   ├── manga_grid_page.dart   # Manga overview with drag-drop reordering
│       │   └── auth_page.dart         # Firebase authentication
│       └── view/                # Reusable UI components
│           ├── sync_status_indicator.dart  # Online/sync status display
│           ├── manga_edit_widget.dart      # Page editing interface
│           ├── manga_page_widget.dart      # Individual page display
│           └── quill_controller_hook.dart  # Custom hook for Quill editor
├── service/
│   ├── firebase/
│   │   ├── firebase_service.dart       # Firestore CRUD operations
│   │   ├── auth_service.dart           # Firebase Auth integration
│   │   ├── model/
│   │   │   ├── cloud_manga.dart        # Firestore document models
│   │   │   ├── cloud_manga_page.dart
│   │   │   └── edit_lock.dart          # Edit lock mechanism
│   │   └── lock_manager.dart           # Collaborative edit lock management
│   └── connection_monitor.dart         # Network state monitoring
└── common/
    └── logger.dart                     # Application logging

```

## Critical Development Notes

### Code Generation is Mandatory
After modifying any of these file types, you MUST run `dart run build_runner build -d`:
- Models with `@freezed` annotation (all model files)
- Cloud models in `lib/service/firebase/model/`
- Files with `@riverpod` or `@Riverpod` annotations
- Any file importing `*.g.dart` or `*.freezed.dart`

### Firebase-Only Persistence Notes
- **Offline Support**: Firestore offline persistence is enabled in `lib/main.dart`
- **Delta Cache**: Repository maintains in-memory DeltaCache for fast access
- **Connectivity Monitoring**: Uses `connectivity_plus` to monitor network state
- **Automatic Sync**: Firestore handles automatic sync when connection is restored
- **No Local Database**: Drift SQLite has been removed - all data persists to Firestore
- **Connection Restoration**: `forceSyncAll()` method manually triggers sync on reconnect

### Repository Layer Pattern
- **CloudManga/CloudMangaPage**: Firestore document models with embedded Deltas
- **Manga/MangaPage**: Domain models with DeltaId references (not Delta objects)
- **Conversion Extensions**: Repository provides `toManga()` and `toCloudManga()` methods
- **Delta Access**: Domain models use DeltaId (int) for type safety
- **Cache Pattern**: DeltaCache maps DeltaId → Delta for efficient memory usage

### Platform Support
Configured for Windows, macOS, Linux, iOS, Android, and Web. Platform-specific code in respective directories (`windows/`, `macos/`, etc.).

### Testing
Unit tests focus on repository layer with Mockito. Test files in `test/repositories/`.

## AI Integration
The app supports OpenAI-powered comment generation on manga content. Pass API key via environment:
```bash
flutter run --dart-define=OPENAI_API_KEY=your_key
```
AI comments analyze manga plot and page content to provide creative feedback.
