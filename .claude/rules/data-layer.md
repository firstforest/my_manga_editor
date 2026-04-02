---
paths:
  - "local_package/my_manga_editor_data/**"
---

# Data Layer (my_manga_editor_data)

## Code Generation
This package has its own `build_runner`. Run from this directory:
```bash
cd local_package/my_manga_editor_data && dart run build_runner build -d && cd -
```
Root `build_runner` does NOT process this package.

## Firestore Schema
```
users/{userId}/mangas/{mangaId}           → CloudManga (name, startPageDirection, editLock)
users/{userId}/mangas/{mangaId}/pages/    → CloudMangaPage (pageIndex)
users/{userId}/mangas/{mangaId}/deltas/   → CloudDelta (ops, fieldName, pageId?)
```

Deltas are stored in a **separate `deltas` subcollection** (not embedded in parent documents). Each CloudDelta has a `fieldName` ('ideaMemo', 'memoDelta', 'stageDirectionDelta', 'dialoguesDelta') and optional `pageId` for page-level deltas.

## Domain Model ID Types (Extension Types)
Defined in `model/manga.dart`:
- `MangaId(String)`, `MangaPageId(String)`, `DeltaId(String)` — type-safe ID wrappers
- Domain models (`Manga`, `MangaPage`) reference Deltas by `DeltaId`, not by Delta objects

## Repository Pattern
- `MangaRepository` (keepAlive Riverpod provider) handles all data operations
- Maintains `_pageToMangaMap` for MangaPageId → MangaId reverse lookups
- Connectivity monitoring via `connectivity_plus` with automatic sync on reconnect
- Converts between `CloudManga`/`CloudMangaPage`/`CloudDelta` (Firestore) and `Manga`/`MangaPage` (domain)

## Edit Lock System
- `LockManager` prevents concurrent editing via Firestore transactions
- Lock duration: 60s, heartbeat: 30s, tracked by device ID
- `EditLock` embedded in CloudManga document
