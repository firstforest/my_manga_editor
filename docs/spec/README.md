# Spec Format Reference

このディレクトリ ([docs/spec/](./)) は、My Manga Editor の機能仕様 (spec) を格納する。
本書は **AI コーディングエージェントが読み書きする前提** での仕様書フォーマットを定義する Reference。

仕様を書く・更新するとき、そして AI に実装を依頼するときに必ず参照する。

## なぜ spec を書くのか

AI に「いい感じに作って」と頼んでも、毎回違うものが出る。
コードではなく **spec を Single Source of Truth とする** ことで、

- AI は自己検証ループを持てる（Acceptance Criteria に対する pass/fail）
- 人間と AI が同じ前提で会話できる（曖昧さが残るならマーカーで顕在化）
- 仕様変更時に「何を直すか」が一意に決まる（コードを diff せずに方針を確認できる）

業界の合流点として 2025–2026 にかけて GitHub Spec Kit / AWS Kiro / OpenSpec などが採用したのが
**「Requirements → Design → Tasks の 3 ファイル構造 + EARS 記法」** であり、本プロジェクトもこの形式に倣う。

## ディレクトリ構成

```
docs/spec/
├── README.md                          ← 本書（フォーマット規約）
└── features/
    └── <feature-slug>/                ← 機能ごとに 1 フォルダ
        ├── requirements.md            ← WHAT / WHY（仕様）
        ├── design.md                  ← HOW（設計）
        └── tasks.md                   ← 実装タスクの分解
```

- `<feature-slug>` は kebab-case（例: `ai-comment`, `manga-export`, `page-grid`）
- 既存機能を後追いで spec 化する場合も同じ構造を踏襲する
- バグ修正 spec の場合は `bugfix.md` 1 ファイルでよい（後述）

## 3 つの spec ファイルの責務

| ファイル | 答える問い | 主な読者 | 書かない内容 |
|---|---|---|---|
| `requirements.md` | **何を**作るか / **なぜ**作るか | プロダクト側・AI | 技術選定、クラス設計、ライブラリ名 |
| `design.md` | **どう**実現するか | 実装者（人間・AI） | コード片の貼り付け、行レベルの実装詳細 |
| `tasks.md` | **どの順で**やるか | 実装する AI | 設計議論、要件の再定義 |

ファイルをまたいで同じことを書かない。**各ファイルは別のレイヤーの議論を扱う。**

---

## requirements.md

### 構造

```markdown
# Requirements: <機能名>

## メタデータ
- Status: draft | reviewed | implemented | deprecated
- Owner: <担当者 / "TBD">
- Last Updated: YYYY-MM-DD
- Related: <関連 spec へのリンク>

## 概要
<2–5 行で「これは何で、誰のためのものか」を書く。実装方法は書かない。>

## ユーザーストーリー

### US-1: <タイトル> (priority: P1 | P2 | P3)

As a <ユーザー種別>,
I want <達成したいこと>,
so that <得られる価値>.

#### Acceptance Criteria

- AC-1.1: WHEN <トリガ> THE SYSTEM SHALL <応答>
- AC-1.2: WHILE <状態> THE SYSTEM SHALL <応答>
- AC-1.3: IF <異常条件> THEN THE SYSTEM SHALL <応答>

#### Edge Cases
- <境界条件、空・極端値・並行操作・オフライン時など>

## 機能要件 (Functional Requirements)

- FR-001: THE SYSTEM SHALL <恒常的にあるべき振る舞い>
- FR-002: WHEN <イベント> THE SYSTEM SHALL <応答>
- FR-003: [NEEDS CLARIFICATION: <未確定事項>]

## 非機能要件 (Non-Functional Requirements)

- NFR-001: パフォーマンス: <具体的な閾値>
- NFR-002: オフライン挙動: <Firestore キャッシュ前提でどう振る舞うか>
- NFR-003: アクセシビリティ・i18n など必要なもの

## 成功基準 (Success Criteria)

- SC-001: <測定可能な達成条件。例: 「セリフ抽出のクリックから出力まで 1 秒以内」>
- SC-002: <ユーザーが「できる」と判定できる行動レベルの基準>

## スコープ外 (Out of Scope)

- <この spec では扱わないこと。次フェーズ送りなど。>

## 仮定 (Assumptions)

- <この spec が前提とする既存仕様。例: 「Manga モデルは [docs/design/data-model.md](../../design/data-model.md) の現行構造」>
```

### EARS 記法（Easy Approach to Requirements Syntax）

Acceptance Criteria と Functional Requirements は **EARS の 5 パターン** で書く。
曖昧さを潰し、AI が「この条件を満たせたか」を機械的に判定できるようにするため。

| パターン | テンプレート | いつ使うか |
|---|---|---|
| Ubiquitous | `THE SYSTEM SHALL <応答>` | 常に成立すべき不変条件 |
| Event-driven | `WHEN <トリガ> THE SYSTEM SHALL <応答>` | ユーザー操作・イベント発火時 |
| State-driven | `WHILE <状態> THE SYSTEM SHALL <応答>` | 特定状態の間だけ成立する振る舞い |
| Optional | `WHERE <機能フラグ> THE SYSTEM SHALL <応答>` | フラグや環境で有無が分かれる |
| Unwanted | `IF <異常条件> THEN THE SYSTEM SHALL <応答>` | エラー処理・防御的挙動 |

複合形：`WHILE <状態>, WHEN <トリガ> THE SYSTEM SHALL <応答>`

#### 例（このプロジェクトの想定機能）

良い例：
- `WHEN ユーザーがページの「セリフ抽出」ボタンを押下した THE SYSTEM SHALL 全 SceneUnit のセリフ Delta をプレーンテキストに変換しクリップボードへコピーする`
- `WHILE Firestore が未接続 THE SYSTEM SHALL ローカルキャッシュの内容で編集を継続でき、再接続時に自動同期する`
- `IF ページ削除中に他クライアントが同じページを編集した場合 THEN THE SYSTEM SHALL 楽観ロックエラーを返し UI 側で再読み込みを促す`

悪い例（曖昧 / 検証不能）：
- ❌「ユーザーフレンドリーな UI を提供する」
- ❌「適切にエラーハンドリングする」
- ❌「高速に動作する」（数値がない）

### 曖昧マーカー

未確定事項は **`[NEEDS CLARIFICATION: <内容>]`** で明示する。
削除せずに残し、レビュー時にすべて解消してから `Status: reviewed` に進める。

### Acceptance Criteria の品質基準

- **独立して検証可能**：他の AC を読まなくても判定できる
- **機械的に判定可能**：UI の振る舞いなら見れば分かる / バックエンドならテストで書ける
- **10 秒ルール**：人間が出力を 10 秒見ただけで pass/fail が言える粒度

---

## design.md

要件が「何を」なら、設計は「どう」。
**実装の骨子** を書く。コードの完全な写経はしない。

### 構造

```markdown
# Design: <機能名>

## 設計サマリ
<3–10 行で全体像を述べる。読み手はこのセクションだけで方針を把握できる。>

## アーキテクチャ上の位置づけ

参照: [docs/design/architecture.md](../../design/architecture.md)

| レイヤー | この機能の追加・変更点 |
|---|---|
| UI (lib/feature/...) | <新規 page / view / 影響範囲> |
| State (provider/) | <新規 Notifier / 変更する provider> |
| Repository | <既存 repository に追加するメソッド / 新規 repository> |
| Service | <Firestore I/O の変更点。なければ「変更なし」> |
| Backend | <Firestore スキーマ変更 / セキュリティルール変更> |

## データモデル

参照: [docs/design/data-model.md](../../design/data-model.md)

<追加・変更するドメインモデルがあればここに表で書く。既存モデルのみ使う場合は「変更なし」>

## 主要フロー

<シーケンス図を mermaid で。最低 1 つは golden path、必要に応じて異常系も。>

\`\`\`mermaid
sequenceDiagram
  participant U as User
  participant V as View
  participant N as Notifier
  participant R as Repository
  participant F as Firestore
  U->>V: 操作
  V->>N: メソッド呼び出し
  N->>R: ドメイン操作
  R->>F: read/write
  F-->>R: snapshot
  R-->>N: domain model
  N-->>V: state 更新
\`\`\`

## 主要 API / インターフェース

<新規追加するメソッドのシグネチャだけを列挙。本体実装は書かない。>

```dart
// MangaRepository
Stream<List<MangaPage>> watchPages(MangaId mangaId);
Future<void> deletePage(MangaId mangaId, PageId pageId);
```

## 状態遷移 / ライフサイクル

<状態を持つ機能なら state diagram。Manga.status のように既存のものなら参照のみでよい。>

## エラー / 例外設計

| ケース | 検出箇所 | 振る舞い |
|---|---|---|
| Firestore 書き込み失敗 | Service | リトライ後 UI に SnackBar |
| 楽観ロック衝突 | Repository | 上位に専用 Exception を投げる |

## テスト戦略

- ユニット: <provider / repository に対するテストの方針>
- ウィジェット: <重要な UI 振る舞いのみ>
- 手動: <UI 確認が必要なケースを列挙>

## 既存仕様への影響

<既存機能との後方互換、Firestore データ移行の要否、設定値の変更などを列挙。>

## 代替案 (Alternatives Considered)

- 案 A: <概要> — 採用しない理由
- 案 B: <概要> — 採用しない理由
```

### 設計を書く際の指針

- **既存ドキュメントへリンクし、再記述しない**。`docs/design/architecture.md`・`data-model.md`・`.claude/rules/*` で既に定義済みの規約は参照だけで十分。
- mermaid を使う図は **sequenceDiagram / stateDiagram / classDiagram** のみ。手描きの ASCII アートは情報が少ないので避ける。
- 「コード片」は API シグネチャ・型定義など **インターフェース** に限る。実装の中身は tasks.md と実コードに任せる。

---

## tasks.md

実装者（人間・AI）に対する **チェックリスト形式の指示書**。

### 構造

```markdown
# Tasks: <機能名>

## 前提
- Requirements: [requirements.md](./requirements.md)
- Design: [design.md](./design.md)
- 関連コード生成: `dart run build_runner build -d` を root と data 両方で実行する場面があるか確認

## 実装順序の原則
1. データ層 (model → service → repository) を先に固める
2. provider を追加する
3. UI を最後に組む
4. UI が完成した時点で AC を 1 つずつ確認する

## タスク一覧

### T-001: <概要> [P]
- 対象: `local_package/my_manga_editor_data/lib/model/<file>.dart`
- 内容: <50–250 行程度に収まる粒度の作業を具体的に>
- 完了条件:
  - `flutter analyze` が通る
  - 該当 model のテストが追加されている
- 依存: なし

### T-002: <概要>
- 対象: <ファイルパス>
- 内容: ...
- 完了条件:
  - AC-1.1 が満たされる
- 依存: T-001
```

### タスクの書き方

- **1 タスク = 50〜250 行の diff** が目安。これより大きくなりそうなら分割する。
- 並列実行可能なタスクには `[P]` マークを付ける（互いに依存がないことの宣言）。
- **完了条件** には対応する AC 番号、または「テストが通る」「analyzer が通る」など機械的に判定可能なものを書く。
- **依存** は他タスクの ID を列挙。なければ「なし」。

### 本プロジェクト固有の確認事項

タスクごとに、以下に該当するものがあれば完了条件に含める：

- `@freezed` / `@riverpod` を変更 → 該当パッケージで `dart run build_runner build -d` を実行
  - `lib/` 配下は root で、`local_package/my_manga_editor_data/` 配下は data パッケージ側で
- Firestore スキーマ変更 → `docs/design/data-model.md` を同 PR で更新
- 新規画面 → `lib/router.dart` への登録と Auth Guard の確認
- ロック制御が絡む変更 → `.claude/rules/data-layer.md` の Lock セクションを参照

---

## バグ修正用 spec (bugfix.md)

機能追加でなくバグ修正の場合は `features/<bug-slug>/bugfix.md` 1 ファイルで足りる。

```markdown
# Bugfix: <タイトル>

## 再現手順
1. ...
2. ...

## 現在の挙動
<観察される挙動>

## 期待される挙動
<EARS 記法で書く: 例 `WHEN ... THE SYSTEM SHALL ...`>

## 影響範囲
<どの機能・データに波及するか>

## 制約 / リグレッション防止
- WHEN <修正後の条件> THEN システムは SHALL CONTINUE TO <既存動作>
- <この修正で壊してはいけない既存挙動を明示>

## 修正方針
<2–5 行。詳細は実装 PR に任せてよい>

## 検証
- [ ] 再現手順で再現しなくなった
- [ ] リグレッション防止条件を満たすテストを追加
```

---

## 共通の原則

### 1. WHAT/WHY を Spec に、HOW を Design に、STEP を Tasks に分ける

要件に「Riverpod の AsyncNotifier を使う」と書かれていたら、それは設計の侵入であり剥がす。
設計に「2 文字の変数 i を使う」と書かれていたら、それは実装の侵入であり剥がす。

### 2. 既存ドキュメントを再記述しない

`docs/design/architecture.md`・`data-model.md`・`.claude/rules/*` で定義済みのことは
**リンクで参照** する。spec 内に同じ情報をコピーしない（drift の温床になる）。

### 3. 曖昧な日本語を避ける

| ❌ NG | ✅ OK |
|---|---|
| 適切に処理する | エラー時はトーストを表示し、入力を保持する |
| 高速に表示する | ページ遷移から First Paint まで 300ms 以内 |
| わかりやすい UI | ボタンラベルは動詞 + 目的語の形式（例: "ページを追加"） |
| 必要に応じて再取得 | Firestore の snapshot が更新された時点で再描画する |

### 4. spec はコードと同時に進化させる

実装中に要件と乖離が見つかったら、**先に spec を直す**。
これを徹底することで spec が「過去の遺物」ではなく Source of Truth であり続ける。
PR レビュー時にも `requirements.md` の AC とコード変更が対応しているかを見る。

### 5. 完了の判定は Acceptance Criteria

「実装が終わった」ではなく「**すべての AC が満たされている**」が完了の基準。
PR 説明には `Closes AC-1.1, AC-1.2, ...` のように対応関係を書く。

---

## 既存リファレンスとの対応

| 知りたいこと | 参照先 |
|---|---|
| 既存の全体アーキテクチャ | [docs/design/architecture.md](../design/architecture.md) |
| 既存のドメインモデル / Firestore スキーマ | [docs/design/data-model.md](../design/data-model.md) |
| コード生成・Freezed・Riverpod の規約 | [.claude/rules/code-generation.md](../../.claude/rules/code-generation.md) |
| データ層の規約 | [.claude/rules/data-layer.md](../../.claude/rules/data-layer.md) |
| Provider の使い分け | [.claude/rules/providers.md](../../.claude/rules/providers.md) |
| ルーティング規約 | [.claude/rules/routing.md](../../.claude/rules/routing.md) |
| 開発コマンド全般 | [AGENTS.md](../../AGENTS.md) |

---

## 参考にした外部資料

本フォーマットは以下の業界標準・先行事例を踏まえて整備した。詳細を確認したい場合に参照する。

- GitHub Spec Kit ─ spec.md / plan.md / tasks.md の 3 ファイル構造
- AWS Kiro ─ requirements.md / design.md / tasks.md の構造、EARS 採用
- EARS (Easy Approach to Requirements Syntax) ─ Rolls-Royce 由来の要件記法
- Addy Osmani "How to write a good spec for AI agents" ─ Boundaries（Always/Ask/Never）の 3 層思考
