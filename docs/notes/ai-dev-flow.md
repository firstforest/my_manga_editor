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
| 動作確認 | `/verify-ui` で claude-in-chrome から AC を 1 つずつ操作し、スクリーンショットを証拠に残す | PR のプレビュー URL に Maestro で最低限の確認 | リリース前に develop の固定 URL で Google ログイン込みの確認 |
| レビュー | `verify` に続けて PR 前に `/code-review high`。スキーマ・`firestore.rules`・認証を触るときは `ultra` も | PR を開いたときに 1 回だけ `claude-code-action` がインラインコメント (保険) | 指摘の採否とマージ |

## 導入済み

| もの | 場所 |
|---|---|
| `verify` スキル。PR を作る前なら続けて `/code-review high` を実行する | [.claude/skills/verify/SKILL.md](../../.claude/skills/verify/SKILL.md) |
| `.dart` を編集のたびに `dart format` する hook | [.claude/settings.json](../../.claude/settings.json), [.claude/hooks/dart-format.sh](../../.claude/hooks/dart-format.sh) |
| 検証とレビューの方針、レビューで必ず見る観点 | [AGENTS.md](../../AGENTS.md) の「検証とレビュー」 |
| PR テンプレート | [.github/pull_request_template.md](../../.github/pull_request_template.md) |
| PR を開いたときに 1 回だけ付く AI レビュー (保険) | [.github/workflows/claude-review.yml](../../.github/workflows/claude-review.yml) |
| テストの流儀 (レイヤーごとに何を差し替えるか) | [.claude/rules/testing.md](../../.claude/rules/testing.md) |
| CI の format の差分チェックとコード生成のし忘れチェック | [.github/workflows/ci.yml](../../.github/workflows/ci.yml) |
| プレビュー URL への smoke テスト (Maestro) | [e2e/](../../e2e/), [.github/workflows/preview.yml](../../.github/workflows/preview.yml) の `smoke` ジョブ |

## Phase 1 — 手元のレビューを主軸にし、CI のレビューを保険で付ける

### 試運転の結果 (2026-10-28, PR #24)

わざと問題を 2 つ入れた PR で動かした。所要 46 秒で、2 件ともインラインコメントで指摘された。

| 入れた問題 | 指摘 |
|---|---|
| タグ上限の判定を `>` → `>=` (ちょうど 20 個が拒否される) | 指摘あり。修正案 (suggestion) 付き |
| `addTag` を `arrayUnion` から配列全体の read-modify-write に変更 | 指摘あり。AGENTS.md の「配列フィールドは read-modify-write しない」を名指しし、重複の発生も指摘 |

CLAUDE.md の `@AGENTS.md` をたどって AGENTS.md の観点が使われることも、2 件目で確かめられた。

### 残りの作業 (人)

1. **トークンの更新**: `CLAUDE_CODE_OAUTH_TOKEN` は 2026-10-28 に登録した 1 年有効のトークン。失効する前に `claude setup-token` で作り直し、`gh secret set CLAUDE_CODE_OAUTH_TOKEN` で登録し直す (値はプロンプトに貼る。引数に書くと改行の混入やシェル履歴への残留が起きる)
2. **普段の PR で CI を残すか決める**。サブスクの使用量を確認し、手元のレビューの指摘と比べる
   - CI が手元で見落とした指摘をほとんど出さず、手元のレビューを飛ばした PR も見つからない → `claude-review.yml` を外す
   - 手元のレビューを飛ばした PR がたびたび見つかる → 残す

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
- PR 上の `claude-review.yml` がデフォルトブランチ (`develop`) のものと同じ内容でないと、レビューは走らずにジョブが pass になる。このためデフォルトブランチを `develop` にしている
- 失敗の詳細はログで伏せられる (公開リポジトリのため)。認証エラーは「1 ターン・`modelUsage` が空・`is_error: true`」として現れる

## Phase 2 — プレビューへの自動ブラウザ確認 (半日)

`preview.yml` の `smoke` ジョブが、デプロイしたプレビュー URL に対して `e2e/` の Maestro フローをブラウザ画面なしで流す。いまのフローは `e2e/smoke.yaml` の 1 本 (匿名ログイン → 作品一覧 → 新規作成 → 編集画面のボタン類 → 作った作品の削除)。

手元で流すとき:

```bash
flutter build web --release --dart-define=ENV=dev --base-href /
python3 -m http.server 50505 --directory build/web   # 別のターミナルで
maestro test --headless -e BASE_URL=http://localhost:50505 e2e/
```

Maestro CLI は Java 17 が要る。CI と同じ版 (`preview.yml` の `MAESTRO_VERSION`) を使う。

### 残りの作業

- 実行のたびに dev Firebase に匿名ユーザーが 1 人ずつ溜まる (作った作品はフローの最後で消している)。定期的に掃除する仕組みを用意する
- タグの絞り込みをフローで確かめるときは、チップに `Semantics(identifier:)` を付けて Maestro の `id:` で指定する

### Flutter Web と Maestro の注意

- Maestro は Flutter のセマンティクスで要素を探す。`ENV=dev` (手元・プレビュー) のビルドだけ起動時に有効にしている ([lib/env_config.dart](../../lib/env_config.dart) の `enableSemanticsOnStart`)。本番は Flutter の既定どおり無効で、スクリーンリーダーの利用者が隠しボタン (Enable accessibility) で有効にする。e2e は本番のビルドに対しては流せない
- アイコンだけのボタンは tooltip の文言で指定する。ボタンを足すときは tooltip を付ける
- 作品カードは、作品名をラベル、ページ数とタグを値にしたボタン。削除ボタンはカードとは別のボタン ([kanban_card.dart](../../lib/feature/manga/view/kanban_card.dart))
- タグの絞り込みチップ (「すべて」「タグなし」) はラベル付きのボタンでスクリーンリーダーは読めるが、Maestro からは文言で見つけられない
- Maestro の Web 対応はベータ。待ち時間は `extendedWaitUntil` で長めに取る
- 手元の Chrome (claude-in-chrome) で確かめるときは、タブが裏に回ると描画が止まり、画面遷移やアニメーションが進まない。`document.visibilityState` が `hidden` なら結果を信用しない
- 合成したホイールイベントは CanvasKit に届かない ([ai-ui-review.md](./ai-ui-review.md))。スクロールが要る確認は画面内の操作で代替する
- 画面から `ref.read(xxxProvider.notifier)` で呼ぶ非同期メソッドは、`await` の間に autoDispose の Provider が破棄されうる。破棄されるかは描画のタイミングで変わり、セマンティクスの有無でも変わる。状態を持たない操作は `@Riverpod(keepAlive: true)` の Notifier に置く ([manga_creator.dart](../../lib/feature/manga/provider/manga_creator.dart))

## Phase 3 — 動作確認とテスト追加のスキル化 (使いながら)

1. **`.claude/skills/verify-ui/SKILL.md`** (`disable-model-invocation: true`、手動で起動)
   - 引数は feature slug かプレビュー URL
   - ローカルなら `flutter run -d web-server --web-port=50505` (`-d chrome` は拡張が入らないので不可)
   - claude-in-chrome で開き、匿名ログイン (`ENV=dev` のビルドはセマンティクスを起動時に有効にするので、アクセシビリティツリーはそのまま読める)
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
| integration_test / Patrol (web) | ソースから自前でビルドして手元で配信する前提で、デプロイ済みのプレビュー URL を確認できない |
| Playwright | Maestro と同じくセマンティクスの DOM を使えるが、YAML で書ける Maestro を選んだ。Maestro の Web 対応 (ベータ) が不安定なら、同じセマンティクスを使って Playwright に移せる |
| カバレッジ下限で CI を止める | 個人開発では、変更箇所の未テスト行を見て判断するほうが効く |
| CI の中で AI にブラウザを操作させる | Flutter Web で有効か確かめられておらず、毎 PR のサブスク消費も大きい。手元の claude-in-chrome に寄せる |
| テストファイルの編集を hook で禁止 | AI にテストを書かせる目的と矛盾する。AGENTS.md の方針とレビューで担保する |

## コスト

- GitHub Actions: 公開リポジトリの標準ランナーは無料。Maestro の smoke テストで +2〜3 分、AI レビューで +数分〜十数分
- AI レビュー: CI では PR 1 本につき 1 回。OAuth トークンならサブスクの使用量から消費され、追加の請求はない。API キーで動かす場合、1 PR あたりの公式の目安はない (概算で $0.5〜2)
- 自動生成ファイルの差分がレビューの入力を大きく膨らませる。`ci.yml` のコード生成のし忘れチェックで、余計な差分が入るのを防ぐ

## 確かめていないこと

- `verify` という名前のスキルがコミット前に自動で実行されるか (公式 docs の記述にもとづくが未確認)
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
- Maestro: [Web](https://docs.maestro.dev/platform-support/web-desktop-browser) / [Flutter](https://docs.maestro.dev/get-started/supported-platform/flutter)
- Patrol: [Web](https://patrol.leancode.co/documentation/web)
- [Riverpod のテスト](https://riverpod.dev/docs/how_to/testing) / [coverage](https://pub.dev/packages/coverage) / [mutation_test](https://pub.dev/packages/mutation_test)
- [GitHub Actions の課金](https://docs.github.com/en/billing/concepts/product-billing/github-actions) / [Claude の料金](https://platform.claude.com/docs/en/about-claude/pricing)
