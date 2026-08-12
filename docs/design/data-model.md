# Data Model Design

## Overview

My Manga Editor のデータモデル設計書。
Firestore をバックエンドとし、ドメインモデル / クラウドモデル / Firestore ドキュメントの3層構造で管理する。

## Firestore スキーマ

```
config/app                  → CloudAppConfig (グローバル設定、ユーザー非依存)
users/{userId}/
  mangas/{mangaId}/
    pages/{pageId}          → CloudMangaPage
    deltas/{deltaId}        → CloudDelta
```

- `config/app` — アプリ全体のリモート設定 (CloudAppConfig)。ユーザーに依存しないグローバル設定。全クライアントから読み取り可能にする (書き込みは管理者のみ)
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
| tags | `List<String>` | 作品に付いたタグ。追加順。空リストは「タグなし」 |

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
| tags | `List<String>?` | タグ配列。フィールド欠損・null はいずれも「タグなし」として読む |

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
| CloudManga | 1 | 初版。後に `status` / `tags` を追加したが、欠損時はデフォルト値 (`idea` / 空配列 = タグなし) で読めるため版は据え置き | — | — |
| CloudMangaPage | 1 | 初版 (`stageDirectionDeltaId` / `dialoguesDeltaId` をトップレベルに保持) | — | — |
| CloudMangaPage | 2 | SceneUnit 導入。セリフ+ト書きのペアを `sceneUnits` 配列に保持 | 読み込み時に旧2フィールドを `sceneUnits` 1要素へ変換 (`_migrateV1ToV2`) | 未定 (v1 クライアント消滅後) |
| CloudDelta | 1 | 初版 | — | — |
| CloudAppConfig | 1 | 初版 (`minSupportedBuildNumber`)。後に `noticeMessage` / `noticeId` を追加したが、欠損時はデフォルト値 (`0` / 空文字) で読めるため版は据え置き | — | — |

## 作品タグ

作品 (`Manga`) を自分の分類でまとめるための自由入力のタグ。
連載のまとまり (`連載:ヒーロー` など) も、このタグの付け方で表現する
(シリーズ専用の仕組みは持たない)。

- 保存先: `mangas/{mangaId}` ドキュメントの `tags` (string の配列)
- タグは独立したエンティティを持たない。「存在するタグの一覧」は
  全作品の `tags` を平坦化・重複除去して導出する (`tagListProvider`)
- 同一性は **trim 後の完全一致**。表記ゆれ (全半角・大文字小文字) は別タグ扱いで、
  入力時の候補提示でタグの分裂を防ぐ
- 制約: 1 タグは trim 後 1〜30 文字、1 作品あたり最大 20 個、同一作品内で重複不可
- 追加・削除は **`FieldValue.arrayUnion` / `arrayRemove` による差分操作**
  (`FirebaseService.addMangaTag` / `removeMangaTag`)。
  配列全体を read-modify-write すると 2 端末の同時追加で片方が消えるため
- 個数上限は `MangaRepository.addTag` が判定する。判定のために作品ドキュメントを
  タグ追加 1 回につき 1 回読む (`FirebaseService.fetchManga`)。
  読み取りと `arrayUnion` の間に排他はないので 2 端末の同時追加で 21 個目が入りうるが、
  上限は UI 保護のための目安として扱う (読み込み側は個数で失敗しない)
- 一覧の絞り込みは Firestore へクエリを投げず、購読済みの一覧をクライアント側で filter する
- 実装: `MangaRepository.addTag` / `removeTag` → `tagFilterProvider` /
  `filteredMangaListProvider` → `TagFilterBar` (一覧) / `MangaTagsWidget` (編集画面)
- spec: [docs/spec/features/manga-tags/](../spec/features/manga-tags/)

## アプリ内お知らせ

リリース前の予告など、アプリのデプロイを待たずに全利用者へ伝えたいことを表示する。

- 配信元: `config/app` ドキュメントの `noticeMessage` (string) と `noticeId` (string)
- 両方が空でないときだけ、全画面の上部にバナーを表示する
  (片方だけ設定された中途半端な状態では出さない)
- `noticeId` は「利用者が閉じたか」を記録するキー。端末ローカル (`shared_preferences`) に保存する。
  本文を変えるときは `noticeId` も変える (`mise run notice-prod` が自動でそうする)
- リアルタイム購読 (`watchAppConfig`) のため、設定した瞬間に開いている画面へ届く
- ログイン前の画面にも出る (`config/app` は未認証でも読める。下記「読み取り権限」参照)
- 実装: `AppConfigRepository.watchAppConfig` → `visibleNoticeProvider` →
  `AppNoticeScope` (`lib/main.dart` の `MaterialApp.builder`)
- 運用: `mise run notice-prod "<本文>"` / `mise run notice-clear-prod`
  ([docs/release.md](../release.md) の「利用者への影響が大きい変更」参照)

## 最小バージョンゲート

古いクライアント (特に Web のブラウザキャッシュに残った旧ビルド) が新スキーマのデータを
壊すのを防ぐため、最小サポートバージョンによるゲートを持つ。

- 配信元: `config/app` ドキュメントの `minSupportedBuildNumber` (int)
- クライアントは起動時に自分のビルド番号 (`package_info_plus`) と比較し、
  `自ビルド番号 < minSupportedBuildNumber` なら全画面の更新案内 (`/update-required`) を表示し、それ以外の操作をブロックする
- リアルタイム購読 (`watchAppConfig`) のため、閾値を引き上げると開きっぱなしの旧クライアントもその場でゲートされる
- fail-open: 設定ドキュメント未設定・フィールド欠落・読み取り失敗時はゲートしない (設定不備でユーザーを締め出さない)
- **認証より先に評価する** (`lib/router.dart` の redirect)。旧ビルドがキャッシュされていて
  ログイン自体が動かない状況こそ更新案内を出したいので、ログイン前でもゲートする
- 実装: `AppConfigRepository.watchAppConfig` → `updateRequiredProvider` → `lib/router.dart` の redirect

### 読み取り権限

`config/app` は **未認証でも読み取り可能**にしている ([firestore.rules](../../firestore.rules))。

```
match /config/app {
  allow read: if true;
  allow write: if false;
}
```

- ログイン前に読めないと、上記の「認証より先にゲートする」も
  「ログイン画面の利用者にお知らせを届ける」も成立しない
- 中身は最小ビルド番号とお知らせ本文だけで、秘匿すべき情報は置かない
  (置きたくなったら別ドキュメントに分けること)
- 書き込みは常に拒否。更新は [scripts/config.mjs](../../scripts/config.mjs) が
  IAM 権限でルールをバイパスして行う

### 運用手順

破壊的なスキーマ変更を含むリリースで旧クライアントを締め出したいとき:

1. リリースする版の `pubspec.yaml` の `version: x.y.z+N` のビルド番号 `N` をインクリメントする
   (リリースごとのインクリメントは必須。[.claude/rules/ci.md](../../.claude/rules/ci.md) の「リリース時のバージョン運用」を参照)
2. **デプロイ完了を確認してから**、Firestore の `config/app` ドキュメントの `minSupportedBuildNumber` を、
   締め出したい旧ビルド番号より大きい値 (= 新リリースの `N`) に更新する
   - ⚠️ 順番が重要。デプロイ完了前に上げると、新ビルドが配信される前に既存ユーザー全員がゲートされる
   - 後方互換なリリースではこの更新は不要 (ビルド番号のインクリメントのみ)
3. `config/app` の読み取り権限は [firestore.rules](../../firestore.rules) で管理している
   (上記「読み取り権限」参照)。ルールを変更したら `mise run deploy-rules-prod` が必要

#### `minSupportedBuildNumber` の更新方法

`allow write: if false` のため、クライアントからは更新できない。
セキュリティルールをバイパスできる **Firebase コンソール** または **Admin SDK** から更新する。
対象は**本番プロジェクト `my-manga-editor`** (dev は `my-manga-editor-dev`、取り違え注意)。

Firebase コンソールでの手順:

1. [Firebase コンソール](https://console.firebase.google.com/) → プロジェクト `my-manga-editor` を選択
2. Firestore Database → `config` コレクション → `app` ドキュメント
   (無ければ `config` / ドキュメント ID `app` を新規作成)
3. `minSupportedBuildNumber` (型: number) を目的の値に更新して保存
4. 保存した瞬間、リアルタイム購読しているクライアントに反映される

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
