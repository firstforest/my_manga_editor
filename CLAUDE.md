# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**My Manga Editor** (漫画制作用プロットエディター) is a Flutter cross-platform desktop application for manga creators to manage story plots, dialogues, and page layouts. The app integrates with ClipStudio Paint for seamless workflow integration.

## Development Environment

### Setup Commands
```bash
# Install development tools (requires mise: https://mise.jdx.dev/)
mise i

# Run the application
flutter run

# Generate code (freezed, JSON serialization, Riverpod providers, Drift DAOs)
dart run build_runner build -d
# Or use the mise task:
mise run gen

# Analyze code
flutter analyze

# Run tests
flutter test
```

### Dependencies Management
```bash
# Check for outdated dependencies
flutter pub outdated

# Update dependencies
flutter pub upgrade --major-versions
```

## Technology Stack

- **Flutter 3.32.4** - Cross-platform UI framework
- **Riverpod 3.0.0-dev.15** - State management with hooks architecture
- **Drift 2.22.1** - SQLite ORM for local data persistence
- **Flutter Quill 11.4.0** - Rich text editor (core feature)
- **Freezed 3.0.6** - Immutable data classes with code generation

## Architecture

### Data Layer
- **Models** (`lib/models/`): `Manga` and `MangaPage` with Freezed data classes
- **Database** (`lib/database/`): Drift-based SQLite schema with three tables:
  - `DbMangas`: Manga metadata (ID, name, start page direction, idea memo)  
  - `DbMangaPages`: Page content (memo, stage directions, dialogues as rich text deltas)
  - `DbDeltas`: Quill Delta JSON storage for rich text formatting
- **Repositories** (`lib/repositories/`): Data access layer with Riverpod providers

### UI Layer
- **Pages** (`lib/pages/`): 
  - `main/`: Main editor interface with rich text editing
  - `grid/`: Manga overview with drag-and-drop page reordering
- **Views** (`lib/views/`): Reusable UI components
- **State Management**: ViewModels with Riverpod for complex UI state

### Key Files
- `lib/main.dart`: App entry point with ScreenUtil and ProviderScope setup
- `lib/logger.dart`: Centralized logging utilities
- `lib/quill_controller_hook.dart`: Custom Flutter hooks for Quill editor integration

## Code Generation Requirements

This project heavily relies on code generation. After modifying any of the following, run `dart run build_runner build -d`:

- Freezed data classes (`.freezed.dart` files)
- JSON serialization (`.g.dart` files)  
- Riverpod providers
- Drift database DAOs

## Development Workflow

### State Management Pattern
- Use Riverpod providers for dependency injection
- ViewModels handle complex UI state and business logic
- Repository pattern abstracts data access
- Hooks provide React-like state management in widgets

### Rich Text Handling
- All text content uses Quill Delta format stored as JSON
- Rich text editors are implemented with Flutter Quill
- Export functionality converts Deltas for ClipStudio Paint integration

### Database Operations
- Foreign key relationships with cascade deletion
- Asynchronous operations with proper error handling
- Web deployment uses SQLite WASM for browser compatibility

## Platform Support

The app supports Windows, macOS, Linux, iOS, Android, and Web. Platform-specific configurations are in respective directories (`android/`, `ios/`, `macos/`, `windows/`, `linux/`, `web/`).

For macOS development, additional tools are managed via `mise.mac.toml`:
- Ruby (latest)
- CocoaPods 1.16.2

## Testing

Unit tests focus on the repository layer with Mockito for dependency mocking. Run tests with `flutter test`.