---
paths:
  - ".github/workflows/**"
---

# CI/CD

GitHub Actions で Flutter Web を Cloudflare Workers (静的アセット) にデプロイする。
配信設定は [wrangler.jsonc](../../wrangler.jsonc)。
リリースの実施手順・バックアップ・ロールバックは [docs/release.md](../../docs/release.md) を参照
（リリースは `mise run release` = [scripts/release.sh](../../scripts/release.sh) で行う）。

## Workflow

| ファイル | トリガー | 処理 |
|---|---|---|
| `ci.yml` | PR / `develop` への push / 手動 | 両パッケージの `flutter analyze`・`flutter test` と、デプロイと同条件の Web ビルド |
| `preview.yml` | PR / `develop` への push / 手動 | `ENV=dev` でビルド → プレビュー用 Worker (`my-manga-editor-preview`) へ。PR は `pr-<番号>` エイリアスの URL を PR にコメント、`develop` は固定 URL へデプロイ |
| `main.yml` | `main` への push / 手動 (`workflow_dispatch`) | `flutter build web --release --dart-define=ENV=prod` → 本番 Worker (`my-manga-editor`、カスタムドメイン `komakusa.firstforest.jp`) へ `wrangler deploy` → 公開ページの疎通確認 |
| `release.yml` | `v*` タグの push | GitHub Release を作成（リリース後に手で行う作業のチェックリスト付き） |
| `claude-review.yml` | PR の作成 / draft 解除 | `claude-code-action` + code-review プラグインで PR にインラインコメントを 1 回だけ付ける (手元の `/code-review` の保険)。認証は secrets の `CLAUDE_CODE_OAUTH_TOKEN` (`claude setup-token` で作る 1 年有効のトークン)。未登録ならスキップ |

- バージョン管理: `mise` で Flutter / Dart のバージョンを固定
- `main.yml` の `workflow_dispatch` はロールバックの実行口も兼ねる
  （`mise run rollback-web <tag>` が過去タグの ref で起動する）

## 変更時の注意

- 環境変数を扱う場合は `--dart-define` 経由で渡す（`ENV` など）
- Firebase の prod / dev 切り替えは `ENV` で行う（[lib/env_config.dart](../../lib/env_config.dart)）。
  **Web デプロイのビルドには `--dart-define=ENV=prod` が必須**（未指定だと dev Firebase に繋がる）
- **プレビューは必ず `ENV=dev` でビルドする**。プレビューから本番データに触れさせない。
  本番 Worker とプレビュー Worker は別物で、`preview.yml` は `--env preview` 以外で wrangler を呼ばない
- 配信はドメイン直下なので `--base-href /` でビルドする
- wrangler は `package.json` で固定し、CI では `npm ci` → `npx wrangler` で使う。
  認証は secrets の `CLOUDFLARE_API_TOKEN` だけ (アカウント ID はトークンから決まる)、
  本番 URL は vars の `PRODUCTION_URL` (疎通確認とリリースノートで使う)
- `mise-action` の `install_args` は必要なツールだけにする (`flutter`、wrangler を使うジョブは `flutter node`)。
  `mise.toml` の `ruby` はソースビルドになり CI 時間を大きく浪費するため入れない
- `claude-review.yml` は、PR 上の workflow ファイルが**デフォルトブランチ (`develop`) のものと同じ内容でないと動かない** (claude-code-action の検証)。
  このときジョブは失敗ではなく pass になり、ログに `Workflow validation failed` の注記が出るだけなので、
  `claude-review.yml` 自体を変える PR ではレビューが付かない前提で見る
- `flutter analyze` / `flutter test` は**カレントパッケージしか対象にしない**。
  `local_package/my_manga_editor_data` は個別に実行する
  （`ci.yml` と [scripts/release.sh](../../scripts/release.sh) の双方で対応済み。
  ローカルでは `mise run check`）

## リリース時のバージョン運用

`pubspec.yaml` の `version: x.y.z+N` のうち **ビルド番号 `N` を最小バージョンゲートの判定に使う**
（[docs/design/data-model.md](../../docs/design/data-model.md) の「最小バージョンゲート」参照）。
Web は旧ビルドが開きっぱなしのタブやブラウザキャッシュに残り続けるため、以下を守る。

- **リリースごとにビルド番号 `N` を必ずインクリメントする**。`N` は単調増加させ、過去の値を再利用しない
- 破壊的なスキーマ変更（[.claude/rules/data-layer.md](./data-layer.md) の expand-contract で旧クライアントを締め出したいケース）を含むリリースでは、デプロイ後に Firestore の `config/app.minSupportedBuildNumber` をそのリリースの `N` に更新し、旧クライアントに更新を強制する
- 後方互換なリリースでは `minSupportedBuildNumber` の更新は不要（ビルド番号のインクリメントのみ）
