# Data Model Design

## Overview

My Manga Editor のデータモデル設計書。
Firestore をバックエンドとし、ドメインモデル / クラウドモデル / Firestore ドキュメントの3層構造で管理する。

## Firestore スキーマ

```
users/{userId}/
  mangas/{mangaId}/
    pages/{pageId}          → CloudMangaPage
    deltas/{deltaId}        → CloudDelta
```

- `mangas` — 漫画プロジェクト (CloudManga)
- `pages` — 各ページ (CloudMangaPage)、`mangas` のサブコレクション
- `deltas` — リッチテキスト内容 (CloudDelta)、`mangas` のサブコレクション

## ドメインモデル

### Manga

漫画プロジェクトのルートエンティティ。

| フィールド | 型 | 説明 |
|---|---|---|
| id | `MangaId` | 一意識別子 |
| name | `String` | 作品名 |
| startPage | `MangaStartPage` | 開始ページ方向 (left / right) |
| ideaMemoDeltaId | `DeltaId` | アイデアメモの Delta への参照 |
| status | `MangaStatus` | ステータス (idea / inProgress / complete) |

### MangaPage

漫画の1ページ。メモと複数の SceneUnit（セリフ+ト書きのペア）を持つ。

| フィールド | 型 | 説明 |
|---|---|---|
| id | `MangaPageId` | ページ識別子 |
| mangaId | `MangaId` | 親 Manga への参照 |
| memoDeltaId | `DeltaId` | メモ用 Delta |
| sceneUnits | `List<SceneUnit>` | セリフ+ト書きのペアのリスト |

### SceneUnit

セリフとト書きのペア。1ページに複数持てる。

| フィールド | 型 | 説明 |
|---|---|---|
| dialoguesDeltaId | `DeltaId` | セリフ用 Delta |
| stageDirectionDeltaId | `DeltaId` | ト書き用 Delta |

### 型安全 ID

Extension types でIDの混同を防止:

```dart
extension type MangaId(String id) {}
extension type MangaPageId(String id) {}
extension type DeltaId(String id) {}
```

### Enum

- **MangaStartPage** — `left` / `right` (読み方向。`reverted` getter で反転)
- **MangaStatus** — `idea` / `inProgress` / `complete`

## クラウドモデル (Firestore 永続化層)

### CloudManga

Firestore `mangas/{mangaId}` ドキュメント。

| フィールド | 型 | 説明 |
|---|---|---|
| schemaVersion | `int` | スキーマバージョン (なし = 1)。現行: 1 |
| id | `String` | ドキュメント ID |
| userId | `String` | 所有者 UID |
| name | `String` | 作品名 |
| startPageDirection | `String` | 'left' / 'right' |
| createdAt | `DateTime` | 作成日時 |
| updatedAt | `DateTime` | 更新日時 |
| ideaMemoDeltaId | `String?` | アイデアメモ Delta の参照 |
| editLock | `EditLock?` | 編集ロック (埋め込み) |
| status | `String?` | ステータス文字列 |

### CloudMangaPage

Firestore `mangas/{mangaId}/pages/{pageId}` ドキュメント。

| フィールド | 型 | 説明 |
|---|---|---|
| schemaVersion | `int` | スキーマバージョン (なし = 1)。現行: 2 |
| id | `String` | ドキュメント ID |
| mangaId | `String` | 親 Manga ID |
| pageIndex | `int` | ページ順序 (0始まり) |
| createdAt | `DateTime` | 作成日時 |
| updatedAt | `DateTime` | 更新日時 |
| memoDeltaId | `String?` | メモ Delta ID |
| sceneUnits | `List<Map>?` | SceneUnit リスト (各要素: `{dialoguesDeltaId, stageDirectionDeltaId}`) |
| stageDirectionDeltaId | `String?` | (レガシー) 旧ト書き Delta ID — 読み取り専用、マイグレーション用 |
| dialoguesDeltaId | `String?` | (レガシー) 旧セリフ Delta ID — 読み取り専用、マイグレーション用 |

### CloudDelta

Firestore `mangas/{mangaId}/deltas/{deltaId}` ドキュメント。Flutter Quill の Delta 形式でリッチテキストを保存。

| フィールド | 型 | 説明 |
|---|---|---|
| schemaVersion | `int` | スキーマバージョン (なし = 1)。現行: 1 |
| id | `String` | ドキュメント ID |
| mangaId | `String` | 親 Manga ID |
| ops | `List<dynamic>` | Quill Delta operations |
| fieldName | `String` | フィールド種別: 'ideaMemo' / 'memoDelta' / 'stageDirectionDelta' / 'dialoguesDelta' |
| pageId | `String?` | ページ ID (Manga レベルの場合は null) |
| createdAt | `DateTime` | 作成日時 |
| updatedAt | `DateTime` | 更新日時 |

### EditLock

CloudManga に埋め込まれる同時編集防止用ロック。

| フィールド | 型 | 説明 |
|---|---|---|
| lockedBy | `String` | ロック保持者の UID |
| lockedAt | `DateTime` | ロック取得時刻 |
| expiresAt | `DateTime` | 有効期限 |
| deviceId | `String` | デバイス識別子 (UUID) |

- ロック有効期間: 60秒
- ハートビート間隔: 30秒
- `isExpired` / `isOwnedBy(userId)` で状態確認

## スキーマバージョンと移行

各 Cloud モデルはドキュメントに `schemaVersion` フィールドを持つ（フィールドなし = v1）。
読み込みは `fromFirestore` 内の**単方向アップグレードチェーン**で最新版へ変換する（lazy migration）。
書き込みは常に最新版の形式 + 現行の `schemaVersion` で行う。

運用ルール（詳細は [.claude/rules/data-layer.md](../../.claude/rules/data-layer.md) と
[docs/notes/firestore-schema-migration.md](../notes/firestore-schema-migration.md) を参照）:

- 過去の移行ステップは編集せず、新しいステップを追記するだけ
- expand-contract: 旧フィールドは旧クライアントの消滅を確認するまで削除しない
- スキーマ変更時は `test/data_migration/fixtures/` に変更前の版の fixture を追加する

### スキーマバージョン履歴

| モデル | 版 | 変更内容 | 移行方法 | 旧フィールド削除 (contract) |
|---|---|---|---|---|
| CloudManga | 1 | 初版 | — | — |
| CloudMangaPage | 1 | 初版 (`stageDirectionDeltaId` / `dialoguesDeltaId` をトップレベルに保持) | — | — |
| CloudMangaPage | 2 | SceneUnit 導入。セリフ+ト書きのペアを `sceneUnits` 配列に保持 | 読み込み時に旧2フィールドを `sceneUnits` 1要素へ変換 (`_migrateV1ToV2`) | 未定 (v1 クライアント消滅後) |
| CloudDelta | 1 | 初版 | — | — |

## エンティティ関係図

```
Manga (1) ──── (N) MangaPage
  │                    │
  │ ideaMemoDeltaId    │ memoDeltaId
  │                    │ sceneUnits: List<SceneUnit>
  │                    │   └─ dialoguesDeltaId + stageDirectionDeltaId
  ▼                    ▼
Delta ◄──────────────────
  (deltas サブコレクションに一括格納)
```

- Manga は 1つの ideaMemo Delta を持つ
- MangaPage は 1つのメモ Delta と複数の SceneUnit を持つ
- 各 SceneUnit は セリフ Delta + ト書き Delta のペア
- Delta はすべて `mangas/{mangaId}/deltas/` サブコレクションにフラットに格納
- Delta の `fieldName` と `pageId` でどのエンティティのどのフィールドかを識別
- 旧データ（`dialoguesDeltaId` / `stageDirectionDeltaId` フィールド）は読み取り時に自動で `sceneUnits` 形式に変換（遅延マイグレーション）

## データ変換フロー

```
ドメインモデル (Manga / MangaPage)
    ↕  CloudMangaConversion / CloudMangaPageConversion
クラウドモデル (CloudManga / CloudMangaPage / CloudDelta)
    ↕  toFirestore() / fromFirestore()
Firestore ドキュメント (JSON Map)
```

## レイヤー構成

```
UI (lib/feature/)
  ↓ Riverpod Provider
ViewModel (Notifier)
  ↓
Repository (MangaRepository / AuthRepository / SettingRepository / AiRepository)
  ↓
Service (FirebaseService / AuthService / LockManager)
  ↓
Firestore
```

### Repository

| Repository | 役割 |
|---|---|
| MangaRepository | Manga / MangaPage / Delta の CRUD、リアクティブストリーム、Markdown エクスポート |
| AuthRepository | 認証 (匿名 / Google サインイン) |
| SettingRepository | SharedPreferences ベースの設定管理 |
| AiRepository | OpenAI API 連携 (コメント生成) |

### 例外階層

```
RepositoryException (abstract)
  ├── AuthException        — 未認証
  ├── NotFoundException    — リソース未発見 (resourceType, resourceId)
  ├── ValidationException  — 入力不正
  ├── StorageException     — Firestore エラー (code)
  └── PermissionException  — セキュリティルール拒否
```

## 設計上の特徴

- **型安全 ID** — Extension types で MangaId / MangaPageId / DeltaId を区別
- **オフラインファースト** — Firestore のオフライン永続化を有効化
- **リアクティブ** — すべての watch 系メソッドが Stream を返す
- **編集ロック** — Firestore トランザクションによる同時編集防止
- **Delta ベースコンテンツ** — Flutter Quill 互換のリッチテキスト保存
- **Freezed** — イミュータブルなドメインモデル
