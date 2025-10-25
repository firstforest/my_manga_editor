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
# Generate code for Freezed, JSON serialization, Riverpod providers, and Drift DAOs
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
- **Drift 2.22.1** - SQLite ORM for local persistence
- **Flutter Quill 11.4.0** - Rich text editor for manga content
- **Freezed 3.0.6** - Immutable data classes with code generation
- **dart_openai 5.1.0** - AI comment generation

### Data Flow Architecture
```
UI Layer (Pages/Views) 
    ↓ consumes
ViewModels (Riverpod Notifiers)
    ↓ uses
Repositories (Data Access Layer)
    ↓ queries
Database (Drift/SQLite)
```

### Database Schema
Three main tables with foreign key relationships:
- **DbMangas**: Manga metadata (id, name, startPage direction, ideaMemo deltaId)
- **DbMangaPages**: Page content (mangaId FK, pageIndex, memo/dialogue/stageDirection deltaIds)
- **DbDeltas**: Quill Delta JSON storage for all rich text content

All text content (memos, dialogues, stage directions) is stored as Quill Delta format in the DbDeltas table and referenced by foreign keys.

### Key Architectural Patterns

#### State Management
- **Riverpod Providers** for dependency injection and state management
- **ViewModels** (`*_view_model.dart`) handle complex UI state
- **Repository Pattern** abstracts data access from UI
- **Flutter Hooks** for local widget state

#### Rich Text Handling
- All text uses Quill Delta format stored as JSON
- Delta IDs reference the DbDeltas table
- Export functionality converts Deltas to Markdown for AI processing
- ClipStudio integration extracts plain text from Deltas

#### Code Generation Dependencies
Files requiring regeneration after changes:
- `*.freezed.dart` - Freezed immutable classes
- `*.g.dart` - JSON serialization and Drift DAOs
- Riverpod provider files with `@riverpod` annotations

### Project Structure
```
lib/
├── models/          # Freezed data models (Manga, MangaPage)
├── database/        # Drift database schema and DAOs
├── repositories/    # Data access layer with Riverpod providers
│   ├── manga_repository.dart    # Main data operations
│   ├── manga_providers.dart     # Manga-specific providers
│   └── ai_repository.dart       # OpenAI integration
├── pages/           # Screen-level components
│   ├── main/        # Main editor with rich text editing
│   └── grid/        # Manga overview with drag-drop reordering
├── views/           # Reusable UI components
│   ├── ai_comment_area.dart     # AI feedback widget
│   ├── manga_edit_widget.dart   # Page editing interface
│   └── manga_page_widget.dart   # Individual page display
└── quill_controller_hook.dart   # Custom hook for Quill editor

```

## Critical Development Notes

### Code Generation is Mandatory
After modifying any of these file types, you MUST run `dart run build_runner build -d`:
- Models with `@freezed` annotation
- Database tables in `database.dart`
- Files with `@riverpod` or `@Riverpod` annotations
- Any file importing `*.g.dart` or `*.freezed.dart`

### Database Operations
- Foreign keys are enforced with CASCADE delete
- All database operations are asynchronous
- Web deployment uses SQLite WASM configuration
- Delta storage handles rich text formatting persistence

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
