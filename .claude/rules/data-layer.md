---
paths:
  - "local_package/my_manga_editor_data/**"
---

# Data Layer (my_manga_editor_data)

## Code Generation
このパッケージは独立した `build_runner` を持つ。コード生成全般のルールは [code-generation.md](./code-generation.md) を参照。

## Firestore Schema
```
users/{userId}/mangas/{mangaId}           → CloudManga (name, startPageDirection, editLock)
users/{userId}/mangas/{mangaId}/pages/    → CloudMangaPage (pageIndex)
users/{userId}/mangas/{mangaId}/deltas/   → CloudDelta (ops, fieldName, pageId?)
```

Deltas are stored in a **separate `deltas` subcollection** (not embedded in parent documents). Each CloudDelta has a `fieldName` ('ideaMemo', 'memoDelta', 'stageDirectionDelta', 'dialoguesDelta') and optional `pageId` for page-level deltas.

## Schema Migration (スキーマ変更時の必須手順)

各 Cloud モデル (`CloudManga` / `CloudMangaPage` / `CloudDelta`) はドキュメントに `schemaVersion` を持つ（フィールドなし = v1）。読み込みは `fromFirestore` の**単方向アップグレードチェーン**で最新版へ lazy migration する。背景は [docs/notes/firestore-schema-migration.md](../../docs/notes/firestore-schema-migration.md) を参照。

スキーマを変更するときは以下を**すべて**行うこと:

1. 対象モデルの `schemaVersion` 定数をインクリメントする
2. `fromFirestore` に `if (version < N) data = _migrateVN-1ToVN(data);` ステップを**追記**する。**過去の移行ステップは絶対に編集しない**
3. expand-contract を守る: **旧フィールドは削除しない**（書き込みは `set(merge: true)` / `update()` で旧フィールドを物理削除しない。モデル上は `@JsonKey(includeToJson: false)` で読み取り専用として残す）。旧フィールドが参照するドキュメントの削除も避ける。旧フィールドの削除（contract）は旧クライアントの消滅を確認した後の別リリースで行う
4. 変更**前**の版の生ドキュメントを `test/data_migration/fixtures/<model>/` に fixture (JSON) として追加し、`test/data_migration/` のテストが全件パスすることを確認する
5. [docs/design/data-model.md](../../docs/design/data-model.md) の「スキーマバージョン履歴」表を更新する

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
