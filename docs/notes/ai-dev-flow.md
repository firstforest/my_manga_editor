# AI でテスト・動作確認・レビューを回す開発フロー — 計画

調査日: 2026-10-25, 2026-10-28

テスト・動作確認・コードレビューを AI (Claude Code) に任せ、人は受け入れ条件 (AC) と出荷判断に集中するための計画。

## 方針

- **決まった手順で白黒がつく確認**は CI で行う
- **判断が要る動作確認とレビュー**は、手元の Claude Code で行う
- **AI レビューの主軸は手元の `/code-review`**。指摘をその場で直せる、深さ (`high` / `ultra`) を選べる、AGENTS.md と rules が確実に読まれる。`/code-review` は会話を見ていないサブエージェントで読むので、書いた本人とは別の文脈になる
- **CI の AI レビューは保険**。PR を開いたとき (draft を外したとき) に 1 回だけ動かし、手元のレビューを飛ばした PR (エージェントが作った PR を含む) を拾う。push のたびには動かさない
- **人が担うこと**: spec と AC を書く、AI の指摘を採用するか決める、マージ・リリース・事前告知

| | 手元 (Claude Code) | PR / CI | 人 |
|---|---|---|---|
| テスト | `verify` スキルで analyze / test / コード生成の漏れを確認。`/test-gaps` で変更箇所の未テスト行からテストを追加 | `ci.yml` に format とコード生成のズレの検知を追加 | AC を書く |
| 動作確認 | `/verify-ui` で claude-in-chrome から AC を 1 つずつ操作し、スクリーンショットを証拠に残す | PR のプレビュー URL に Playwright で最低限の確認 | リリース前に develop の固定 URL で Google ログイン込みの確認 |
| レビュー | `verify` に続けて PR 前に `/code-review high`。スキーマ・`firestore.rules`・認証を触るときは `ultra` も | PR を開いたときに 1 回だけ `claude-code-action` がインラインコメント (保険) | 指摘の採否とマージ |

## 導入済み (Phase 0〜1)

| もの | 場所 |
|---|---|
| `verify` スキル。PR を作る前なら続けて `/code-review high` を実行する | [.claude/skills/verify/SKILL.md](../../.claude/skills/verify/SKILL.md) |
| `.dart` を編集のたびに `dart format` する hook | [.claude/settings.json](../../.claude/settings.json), [.claude/hooks/dart-format.sh](../../.claude/hooks/dart-format.sh) |
| 検証とレビューの方針、レビューで必ず見る観点 | [AGENTS.md](../../AGENTS.md) の「検証とレビュー」 |
| PR テンプレート | [.github/pull_request_template.md](../../.github/pull_request_template.md) |
| PR を開いたときに 1 回だけ付く AI レビュー (保険) | [.github/workflows/claude-review.yml](../../.github/workflows/claude-review.yml) |
| テストの流儀 (レイヤーごとに何を差し替えるか) | [.claude/rules/testing.md](../../.claude/rules/testing.md) |

## Phase 1 — 手元のレビューを主軸にし、CI のレビューを保険で付ける

### 残りの作業 (人)

1. **認証**: `claude setup-token` で 1 年有効の OAuth トークンを作り、GitHub の secrets `CLAUDE_CODE_OAUTH_TOKEN` に登録する。失効日をカレンダーに入れる。未登録の間、`claude-review.yml` はスキップされる
2. **数本の PR で CI を残すか決める**。所要時間とサブスクの使用量を確認し、手元のレビューの指摘と比べる
   - CI が手元で見落とした指摘をほとんど出さず、手元のレビューを飛ばした PR も見つからない → `claude-review.yml` を外す
   - 手元のレビューを飛ばした PR がたびたび見つかる → 残す
   - 20 分の timeout で打ち切られるようなら、`claude_args` に `--max-turns` を足すか timeout を延ばす

### code-review プラグインの性質

- 段階ごとに haiku / sonnet / Opus のサブエージェントを使い分ける (変更の要約、CLAUDE.md への準拠、バグ探し、指摘の検証)。モデルはプラグインが選ぶので `--model` は付けていない
- 1 回で 7 つ以上のサブエージェントを起動するので、`--max-turns` を小さく付けると途中で止まる。上限は `timeout-minutes` で付けている
- draft・クローズ済み・Claude のコメントが付いた PR は自分でスキップする
- プロジェクト固有の観点として読むのは CLAUDE.md (ルートと変更ファイルのディレクトリ) だけで、`.claude/rules/` は読まない。このリポジトリの CLAUDE.md は `@AGENTS.md` を取り込むだけなので、必須の観点は AGENTS.md に書いている
- 報告するのは「コンパイルが通らない」「入力によらず結果が誤る」「CLAUDE.md への明白な違反」に絞られる。設計や読みやすさの指摘は手元の `/code-review` に任せる

### 注意

- 手元と CI で同じ PR を何度もレビューすると、同じサブスクの使用量を重ねて消費する。CI は PR 1 本につき 1 回に留める
- `REVIEW.md` は Anthropic がホストする Code Review 用の設定で、このプラグイン構成では読まれない
- フォークからの PR には secrets が渡らないので、AI レビューは動かない (`preview.yml` と同じ)

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
| push のたびに CI で AI レビュー | 手元のレビューと重なり、使用量が push の回数に比例して増える。修正の確認は手元で行う |
| `anthropics/claude-code-security-review` Action | API キー専用で既定モデルも古い。手元の `/security-review` で足りる |
| integration_test / Patrol (web) | 自前でビルドする前提でプレビュー URL を叩けない。Firebase Auth の扱いの初期コストも高い |
| カバレッジ下限で CI を止める | 個人開発では、変更箇所の未テスト行を見て判断するほうが効く |
| CI の中で AI にブラウザを操作させる | Flutter Web で有効か確かめられておらず、毎 PR のサブスク消費も大きい。手元の claude-in-chrome に寄せる |
| テストファイルの編集を hook で禁止 | AI にテストを書かせる目的と矛盾する。AGENTS.md の方針とレビューで担保する |

## コスト

- GitHub Actions: 公開リポジトリの標準ランナーは無料。Playwright の確認で +2〜3 分、AI レビューで +数分〜十数分
- AI レビュー: CI では PR 1 本につき 1 回。OAuth トークンならサブスクの使用量から消費され、追加の請求はない。API キーで動かす場合、1 PR あたりの公式の目安はない (概算で $0.5〜2)
- 自動生成ファイルの差分がレビューの入力を大きく膨らませる。Phase 2 のコード生成のズレの検知で、生成し忘れによる余計な差分を防ぐ

## 確かめていないこと

- `verify` という名前のスキルがコミット前に自動で実行されるか (公式 docs の記述にもとづくが未確認)
- CI の code-review プラグインのサブエージェントが、CLAUDE.md の `@AGENTS.md` を辿って AGENTS.md を読むか
- Dart MCP の `flutter_driver_command` が Flutter Web (debug) で動くか
- Playwright MCP のアクセシビリティスナップショットが Flutter Web で役に立つか
- OAuth トークンを CI で使うことの利用規約上の扱い (Claude Code の docs では許容されている)
- Firebase Auth に匿名アカウントを自動削除する設定があるか
- 空の `flt-semantics` がクリックを遮るバグが Flutter 3.44.4 で起きるか

## 出典

- Claude Code: [best practices](https://code.claude.com/docs/en/best-practices) / [GitHub Actions](https://code.claude.com/docs/en/github-actions) / [長期トークン](https://code.claude.com/docs/en/authentication#generate-a-long-lived-token) / [skills](https://code.claude.com/docs/en/skills) / [hooks](https://code.claude.com/docs/en/hooks) / [path 指定の rules](https://code.claude.com/docs/en/memory#path-specific-rules) / [Code Review](https://code.claude.com/docs/en/code-review) / [ローカルの code review](https://code.claude.com/docs/en/code-review-local) / [ultrareview](https://code.claude.com/docs/en/ultrareview) / [プラン別の提供状況](https://code.claude.com/docs/en/feature-availability#availability-by-subscription-plan)
- [code-review プラグイン](https://github.com/anthropics/claude-code/blob/main/plugins/code-review/commands/code-review.md)
- [anthropics/claude-code-action](https://github.com/anthropics/claude-code-action) ([入力一覧](https://github.com/anthropics/claude-code-action/blob/main/docs/usage.md#inputs), [セキュリティ](https://github.com/anthropics/claude-code-action/blob/main/docs/security.md))
- [Solving code review at Anthropic](https://claude.dev/blog/solving-code-review-at-anthropic/)
- Flutter: [Web のアクセシビリティ](https://docs.flutter.dev/ui/accessibility/web-accessibility) / [flutter/flutter#177670](https://github.com/flutter/flutter/issues/177670) / [flutter/flutter#193705](https://github.com/flutter/flutter/issues/193705) / [integration tests](https://docs.flutter.dev/testing/integration-tests)
- Playwright: [CI](https://playwright.dev/docs/ci-intro) / [ロケータ](https://playwright.dev/docs/locators)
- [Riverpod のテスト](https://riverpod.dev/docs/how_to/testing) / [coverage](https://pub.dev/packages/coverage) / [mutation_test](https://pub.dev/packages/mutation_test)
- [GitHub Actions の課金](https://docs.github.com/en/billing/concepts/product-billing/github-actions) / [Claude の料金](https://platform.claude.com/docs/en/about-claude/pricing)
