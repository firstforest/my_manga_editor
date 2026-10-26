# AI でテスト・動作確認・レビューを回す開発フロー — 計画

調査日: 2026-10-25

テスト・動作確認・コードレビューを AI (Claude Code) に任せ、人は受け入れ条件 (AC) と出荷判断に集中するための計画。

## 方針

- **決まった手順で白黒がつく確認**は CI で行う
- **判断が要る動作確認とレビュー**は、手元の Claude Code で行う
- **PR には AI レビューを 1 本だけ**自動で付ける (書いた本人とは別の文脈で読ませる)
- **人が担うこと**: spec と AC を書く、AI の指摘を採用するか決める、マージ・リリース・事前告知

| | 手元 (Claude Code) | PR / CI | 人 |
|---|---|---|---|
| テスト | `verify` スキルで analyze / test / コード生成の漏れを確認。`/test-gaps` で変更箇所の未テスト行からテストを追加 | `ci.yml` に format とコード生成のズレの検知を追加 | AC を書く |
| 動作確認 | `/verify-ui` で claude-in-chrome から AC を 1 つずつ操作し、スクリーンショットを証拠に残す | PR のプレビュー URL に Playwright で最低限の確認 | リリース前に develop の固定 URL で Google ログイン込みの確認 |
| レビュー | PR 前に `/code-review high`。スキーマ・`firestore.rules`・認証を触るときは `ultra` も | `claude-code-action` が PR にインラインコメント | 指摘の採否とマージ |

## 導入済み (Phase 0)

| もの | 場所 |
|---|---|
| `verify` スキル | [.claude/skills/verify/SKILL.md](../../.claude/skills/verify/SKILL.md) |
| `.dart` を編集のたびに `dart format` する hook | [.claude/settings.json](../../.claude/settings.json), [.claude/hooks/dart-format.sh](../../.claude/hooks/dart-format.sh) |
| 検証とレビューの方針 | [AGENTS.md](../../AGENTS.md) の「検証とレビュー」 |
| PR テンプレート | [.github/pull_request_template.md](../../.github/pull_request_template.md) |

## Phase 1 — PR の自動 AI レビュー (1〜2 時間)

### やること

1. **`.github/workflows/claude-review.yml`** を追加する。Claude Code で `/install-github-app` を実行し、review workflow を選ぶと雛形が作られる
   - `uses: anthropics/claude-code-action@v1`
   - `plugins: "code-review@claude-code-plugins"`、`prompt` で `/code-review:code-review --comment <owner/repo>/pull/<番号>` を実行
   - `claude_args: '--allowedTools "mcp__github_inline_comment__create_inline_comment"'` (インラインコメント以外は許可しない)
   - `permissions`: `contents: read` / `pull-requests: read` / `issues: read` / `id-token: write`。リポジトリには書き込ませない
   - トリガー: `pull_request: [opened, synchronize, ready_for_review, reopened]`。`concurrency` で同じ ref の古い実行を打ち切り、`timeout-minutes: 20`
2. **認証 (人の作業)**: `claude setup-token` で 1 年有効の OAuth トークンを作り、GitHub の secrets `CLAUDE_CODE_OAUTH_TOKEN` に登録する。失効日をカレンダーに入れる
3. 小さな PR で 1 回動かし、所要時間とサブスクの使用量を確認する
4. **`.claude/rules/testing.md`** (`paths: test/**, local_package/**/test/**`) に既存テストの流儀を明文化する
   - mockito `@GenerateNiceMocks`、extension type の ID には `Fake`
   - `ProviderContainer` はテストごとに作る
   - Notifier ではなく依存先の Repository をモックする
   - Quill を含む重い Widget は導線だけを切り出して検証する
   - スキーマ変更時は `test/data_migration/fixtures/` に変更前の生ドキュメントを足す

### 注意

- `.claude/rules/*.md` と AGENTS.md はレビュー時にも読まれるので、プロジェクト固有の観点 (expand-contract、`FieldValue` を Service の外に出さない等) はそこに書けばよい
- フォークからの PR には secrets が渡らないので、AI レビューは動かない (`preview.yml` と同じ)
- `.claude/rules/ci.md` の Workflow 表に `claude-review.yml` を足す

## Phase 2 — プレビューへの自動ブラウザ確認と CI の強化 (半日)

### やること

1. **事前準備**: アイコンだけのボタンに `tooltip` か `Semantics(label:)` を付ける。名前がないと Playwright がボタンを特定できない (利用者のアクセシビリティにもなる)
2. **`e2e/`** を追加する (`playwright.config.ts`, `tests/smoke.spec.ts`)。`@playwright/test` は既存の `package.json` に devDependency で入れる。確認するのは 3〜5 本だけ:
   - ページが開き、`flt-semantics-placeholder` をクリックしてセマンティクスを有効にすると「Sign in anonymously」ボタンが見える
   - 匿名ログイン → 作品一覧の見出しが出る
   - 新規作成 → 編集画面に遷移し、カットの「︙」メニューがある
3. **`preview.yml` に `smoke` ジョブ**を追加する。`preview` ジョブの `outputs.url` を `BASE_URL` として渡し、`npx playwright install --with-deps chromium` → `npx playwright test`。失敗時は HTML レポートを artifact に残す
4. **`ci.yml` に 2 ステップ**追加する (各パッケージで)
   - `dart format --output=none --set-exit-if-changed lib test`
   - `dart run build_runner build -d` → `git diff --exit-code` (コード生成のし忘れを検知)

### Flutter Web 特有の注意

- セマンティクスは既定で OFF。`flt-semantics-placeholder` をクリックするか、アプリ側で `SemanticsBinding.instance.ensureSemantics()` を呼ぶ。まずはアプリ変更が要らないクリックで始める
- `Text` は accessible name になるので、文言付きボタンは `getByRole('button', { name: ... })` で取れる
- 合成したホイールイベントは CanvasKit に届かない ([ai-ui-review.md](./ai-ui-review.md) で確認済み)。スクロールが要る確認は画面内の操作で代替する
- 空の `flt-semantics` がクリックを遮る既知バグがある (flutter/flutter#193705)。その場合は `click({ force: true })`
- `integration_test` / `flutter drive` はデプロイ済みの URL を叩けないので、プレビュー URL の確認は Playwright で行う
- Playwright の匿名ログインで dev Firebase に匿名ユーザーとデータが溜まる。定期的な掃除の仕組みを用意する

## Phase 3 — 動作確認とテスト追加のスキル化 (使いながら)

1. **`.claude/skills/verify-ui/SKILL.md`** (`disable-model-invocation: true`、手動で起動)
   - 引数は feature slug かプレビュー URL
   - ローカルなら `flutter run -d web-server --web-port=50505` (`-d chrome` は拡張が入らないので不可)
   - claude-in-chrome で開き、`javascript_tool` で `flt-semantics-placeholder` をクリック → 匿名ログイン
   - `docs/spec/features/<slug>/requirements.md` の AC を 1 つずつ操作し、pass / fail / 未確認 と証拠 (スクリーンショット・`read_page` の抜粋) を表で出す
   - ローカル実行時は dart MCP の `get_runtime_errors` で RenderFlex overflow なども拾う
   - 既知の制約 (ホイールスクロール不可、名前のないアイコンボタン、DEBUG バナー) を本文に書く
2. **`.claude/skills/test-gaps/SKILL.md`**
   - パッケージごとに `flutter test --coverage` (カレントパッケージしか対象にならない)
   - `coverage/lcov.info` から生成ファイルを除き、**今回の diff で触ったファイルの未テスト行**だけを抽出
   - 振る舞いを確かめるテストを `.claude/rules/testing.md` の流儀で追加し、実行結果を証拠に報告
   - 全体のカバレッジ下限は設けない
3. **`docs/spec/README.md` のテンプレート**の「テスト戦略」にある `- 手動:` を `- ブラウザ検証 (/verify-ui):` にし、AC 番号を添える。既存 spec (manga-export, manga-tags) の手動項目を `/verify-ui` で一度流す

## 必要になったら

- 危険な PR に `/code-review ultra` (クラウドで 15〜25 分。Pro/Max は無料枠 3 回、以降は 1 回 $5〜25)
- Repository などロジック層に `mutation_test` を単発で回し、テストが実際に壊れた実装を検出できるかを測る
- Dart MCP の `flutter_driver_command` を `-d web-server` で試し、Web で使えるか判断する

## 採用しないもの

| もの | 理由 |
|---|---|
| Anthropic がホストする Code Review | Team / Enterprise 限定で、個人プランでは使えない |
| `anthropics/claude-code-security-review` Action | API キー専用で既定モデルも古い。手元の `/security-review` で足りる |
| integration_test / Patrol (web) | 自前でビルドする前提でプレビュー URL を叩けない。Firebase Auth の扱いの初期コストも高い |
| カバレッジ下限で CI を止める | 個人開発では、変更箇所の未テスト行を見て判断するほうが効く |
| CI の中で AI にブラウザを操作させる | Flutter Web で有効か確かめられておらず、毎 PR のサブスク消費も大きい。手元の claude-in-chrome に寄せる |
| テストファイルの編集を hook で禁止 | AI にテストを書かせる目的と矛盾する。AGENTS.md の方針とレビューで担保する |

## コスト

- GitHub Actions: 公開リポジトリの標準ランナーは無料。Playwright の確認で +2〜3 分、AI レビューで +数分〜十数分
- AI レビュー: OAuth トークンならサブスクの使用量から消費され、追加の請求はない。API キーで動かす場合、1 PR あたりの公式の目安はない (概算で $0.5〜2)
- 自動生成ファイルの差分がレビューの入力を大きく膨らませる。Phase 2 のコード生成のズレの検知で、生成し忘れによる余計な差分を防ぐ

## 確かめていないこと

- `verify` という名前のスキルがコミット前に自動で実行されるか (公式 docs の記述にもとづくが未確認)
- Dart MCP の `flutter_driver_command` が Flutter Web (debug) で動くか
- Playwright MCP のアクセシビリティスナップショットが Flutter Web で役に立つか
- OAuth トークンを CI で使うことの利用規約上の扱い (Claude Code の docs では許容されている)
- Firebase Auth に匿名アカウントを自動削除する設定があるか
- 空の `flt-semantics` がクリックを遮るバグが Flutter 3.44.4 で起きるか

## 出典

- Claude Code: [best practices](https://code.claude.com/docs/en/best-practices) / [GitHub Actions](https://code.claude.com/docs/en/github-actions) / [長期トークン](https://code.claude.com/docs/en/authentication#generate-a-long-lived-token) / [skills](https://code.claude.com/docs/en/skills) / [hooks](https://code.claude.com/docs/en/hooks) / [path 指定の rules](https://code.claude.com/docs/en/memory#path-specific-rules) / [ローカルの code review](https://code.claude.com/docs/en/code-review-local) / [ultrareview](https://code.claude.com/docs/en/ultrareview) / [プラン別の提供状況](https://code.claude.com/docs/en/feature-availability#availability-by-subscription-plan)
- [anthropics/claude-code-action](https://github.com/anthropics/claude-code-action) ([入力一覧](https://github.com/anthropics/claude-code-action/blob/main/docs/usage.md#inputs), [セキュリティ](https://github.com/anthropics/claude-code-action/blob/main/docs/security.md))
- [Solving code review at Anthropic](https://claude.dev/blog/solving-code-review-at-anthropic/)
- Flutter: [Web のアクセシビリティ](https://docs.flutter.dev/ui/accessibility/web-accessibility) / [flutter/flutter#177670](https://github.com/flutter/flutter/issues/177670) / [flutter/flutter#193705](https://github.com/flutter/flutter/issues/193705) / [integration tests](https://docs.flutter.dev/testing/integration-tests)
- Playwright: [CI](https://playwright.dev/docs/ci-intro) / [ロケータ](https://playwright.dev/docs/locators)
- [Riverpod のテスト](https://riverpod.dev/docs/how_to/testing) / [coverage](https://pub.dev/packages/coverage) / [mutation_test](https://pub.dev/packages/mutation_test)
- [GitHub Actions の課金](https://docs.github.com/en/billing/concepts/product-billing/github-actions) / [Claude の料金](https://platform.claude.com/docs/en/about-claude/pricing)
