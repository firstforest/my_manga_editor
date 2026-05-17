# Requirements: Manga Export

## メタデータ
- Status: reviewed（T-004 で NEEDS CLARIFICATION を全て解消済み）
- Owner: TBD
- Last Updated: 2026-05-17
- Related:
  - [design.md](./design.md) / [tasks.md](./tasks.md)
  - [docs/design/data-model.md](../../../design/data-model.md)

## 概要

漫画プロットを **外部のお絵描きアプリ（特に ClipStudio Paint）** に持ち出すための書き出し機能。
本アプリ単体ではコマ割りや作画は行わず、執筆したセリフ・ト書き・アイデアメモを
他ツールに移送して初めて完成原稿になる、という前提のための機能群。

現在は 2 つの導線がある：

1. **ページ単位のセリフ・コピー** — 編集画面で各ページの「コピー」ボタン押下時にクリップボードへ
2. **作品全体のファイル書き出し** — 一覧画面から作品全体を Markdown 風テキストファイルに保存

本 spec はこれらを Source of Truth として整理し、既存挙動の保全と、観察された不整合の解消方針を定める。

---

## ユーザーストーリー

### US-1: ページごとのセリフをネーム作業時に貼り付けたい (priority: P1)

As a 漫画家（ユーザー），
I want 編集画面の各ページから「セリフだけ」を 1 クリックでクリップボードへコピーし，
so that ClipStudio Paint に縦書きテキストとして貼り付けてネーム作業に直結させたい。

#### Acceptance Criteria

- AC-1.1: WHEN ユーザーがページ右上のコピーボタンを押下した
  THE SYSTEM SHALL 当該ページに含まれる全 SceneUnit の dialogues Delta をプレーンテキスト化し
  順番に空行区切り (`\n\n`) で連結してクリップボードへ書き込む
- AC-1.2: WHEN クリップボードへの書き込みが完了した
  THE SYSTEM SHALL `Page <N> をコピーしました` の SnackBar を表示する
- AC-1.3: WHILE 当該ページに dialogues が 1 文字も入っていない
  THE SYSTEM SHALL クリップボードを書き換えない（既存クリップボード内容を保護する）
- AC-1.4: IF 実行環境にシステムクリップボードが存在しない (Web のサンドボックス制限等)
  THEN THE SYSTEM SHALL `Page <N> のコピーに失敗しました` の SnackBar を表示し、
  クリップボードを書き換えない
- AC-1.5: THE SYSTEM SHALL プレーンテキスト化の際、3 連続以上の改行を 2 連続改行に圧縮する
  （Delta の構造上発生する不自然な空行を整える）

#### Edge Cases
- SceneUnit が 0 件のページ → コピーボタンは表示するが内容は空文字
- 1 つの SceneUnit にだけ dialogues がある → その SceneUnit の本文のみコピーされる
- dialogues がリッチテキスト装飾（太字等）を含む → 装飾は無視しプレーンテキストのみ抽出
- オフライン編集中 → ローカルキャッシュの内容で動作する（Firestore 接続不要）

---

### US-2: 作品全体をファイルとして書き出したい (priority: P2)

As a 漫画家，
I want 作品全体のアイデアメモ・各ページのメモ・ト書き・セリフを 1 つのファイルに書き出し，
so that バックアップや他者との共有、他ツールへの一括移送に使いたい。

#### Acceptance Criteria

- AC-2.1: WHEN ユーザーが作品一覧 (`manga_grid_page`) の作品メニューから「ダウンロード」を選択した
  THE SYSTEM SHALL 作品全体を Markdown 形式のテキストとして組み立て、
  ブラウザ / OS のファイル保存ダイアログを介してローカルに保存する
- AC-2.2: THE SYSTEM SHALL 出力ファイル名を `komatto_<sanitizedName>` とする。
  `sanitizedName` は作品名から OS のファイル名禁止文字 `/ \ : * ? " < > |`（および制御文字）を
  `_` に置換した文字列
- AC-2.3: THE SYSTEM SHALL 出力ファイルの拡張子を `.md`、MIME タイプを `text/markdown` とする
- AC-2.4: THE SYSTEM SHALL 以下の階層構造で出力する：
  - `# <作品名>`
  - `## アイデアメモ`（本文がある場合のみ）
  - 各ページについて `## ページ <N>` / `### メモ`
  - SceneUnit が複数あるページでは `### カット <M>` / `#### ト書き` / `#### セリフ`
  - SceneUnit が 1 つだけのページでは `### ト書き` / `### セリフ`
- AC-2.5: WHILE 当該 Delta が空（`ops.isEmpty` または変換後文字列が空）
  THE SYSTEM SHALL その見出しごと出力しない（空の `### メモ` を残さない）
- AC-2.6: IF Firestore から作品が取得できない（NotFoundException 等）または保存処理が例外を投げた
  THEN THE SYSTEM SHALL `logger.e` でエラー詳細をログに残し、
  `保存に失敗しました` の SnackBar を表示する（Dialog ではなく SnackBar を使う）

#### Edge Cases
- 作品名にファイル名禁止文字（`/` `:` `*` 等）が含まれる → AC-2.2 のサニタイズで `_` に置換される
- ページが 0 枚 → タイトルとアイデアメモのみ出力
- 全 Delta が空 → タイトルのみのファイルが生成される（許容）
- 巨大作品（200 ページ超） → 全 Delta を一括取得するためメモリ・通信量に注意

---

## 機能要件 (Functional Requirements)

### コピー系
- FR-001: THE SYSTEM SHALL ページ単位のセリフ・コピー機能を提供する（US-1）
- FR-002: THE SYSTEM SHALL `MangaPage` 内の SceneUnit 順序を保ったまま連結する

### ファイル書き出し系
- FR-003: THE SYSTEM SHALL 作品単位の Markdown 書き出し機能を提供する（US-2）
- FR-004: THE SYSTEM SHALL 書き出し処理を `MangaRepository` 層に閉じ込め、UI から直接 Firestore を読まない

### 共通
- FR-005: THE SYSTEM SHALL Quill Delta からプレーンテキストへの変換ロジックを
  `local_package/my_manga_editor_common` 配下の共通ユーティリティ関数として 1 箇所に集約し、
  UI 層 (`DeltaNotifier`) とデータ層 (`MangaRepository.toMarkdown`) の両方から同じ実装を使う。
  共通関数は最低限「op.data の文字列連結」「3 連続以上の改行を 2 連続改行に圧縮」「先頭末尾 trim」を行う
- FR-006: WHEN 書き出し処理が失敗した THE SYSTEM SHALL `logger.e` でエラー詳細をログに残す

---

## 非機能要件 (Non-Functional Requirements)

- NFR-001: パフォーマンス: 単一ページのコピーは 500ms 以内に SnackBar 表示まで完了する
  （Firestore からの読み込みはキャッシュヒット前提）
- NFR-002: オフライン挙動: いずれの書き出しも Firestore キャッシュのみで動作可能であること
- NFR-003: 文字コード: ファイル書き出しは UTF-8 固定（既存 `utf8.encode` で実装済）
- NFR-004: プラットフォーム: コピー機能は Web / Desktop の双方で動作すること
  （`super_clipboard` の `SystemClipboard.instance` が null を返すケースは AC-1.4 で扱う）

---

## 成功基準 (Success Criteria)

- SC-001: ClipStudio Paint のテキストツールにペーストしたとき、
  本アプリで入力した順序通り・空行区切りでセリフが配置される
- SC-002: 書き出したファイルを別の Markdown ビューアで開いたとき、
  作品 → ページ → カット → セリフ / ト書きの階層が崩れずに表示される
- SC-003: 書き出し処理を 50 回繰り返してもクラッシュせず、ログにエラーが残らない

---

## スコープ外 (Out of Scope)

- ClipStudio Paint プラグインや専用フォーマット（`.clip` 等）への直接書き出し
- PDF / EPUB / 画像形式での書き出し
- 部分書き出し（ページ範囲指定、特定 SceneUnit のみ等）
- インポート機能（他形式からの読み込み）
- セリフのレイアウト情報（フキダシ種別、話者）

---

## 仮定 (Assumptions)

- ドメインモデル `Manga` / `MangaPage` / `SceneUnit` / `DeltaId` の構造は
  [docs/design/data-model.md](../../../design/data-model.md) の現行定義に従う
- Quill Delta は `flutter_quill` パッケージのフォーマットに準拠する
- セリフはリッチテキスト装飾を伴うが、外部書き出しでは装飾を捨ててプレーンテキストとして扱う
  （ClipStudio Paint 側で装飾を再現する前提）
- 認証・権限制御は別 spec の責務とし、本機能は「ログイン済みユーザーが自作品を書き出す」前提で動く
