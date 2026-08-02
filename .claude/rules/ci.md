---
paths:
  - ".github/workflows/**"
---

# CI/CD

GitHub Actions で Flutter Web を GitHub Pages にデプロイする。
リリースの実施手順・バックアップ・ロールバックは [docs/release.md](../../docs/release.md) を参照
（リリースは `mise run release` = [scripts/release.sh](../../scripts/release.sh) で行う）。

## Workflow

| ファイル | トリガー | 処理 |
|---|---|---|
| `ci.yml` | PR / `develop` への push / 手動 | 両パッケージの `flutter analyze`・`flutter test` と、デプロイと同条件の Web ビルド |
| `main.yml` | `main` への push / 手動 (`workflow_dispatch`) | `flutter build web --release --dart-define=ENV=prod` → GitHub Pages へデプロイ → 公開ページの疎通確認 |
| `release.yml` | `v*` タグの push | GitHub Release を作成（リリース後に手で行う作業のチェックリスト付き） |

- バージョン管理: `mise` で Flutter / Dart のバージョンを固定
- `main.yml` の `workflow_dispatch` はロールバックの実行口も兼ねる
  （`mise run rollback-web <tag>` が過去タグの ref で起動する）

## 変更時の注意

- 環境変数を扱う場合は `--dart-define` 経由で渡す（`ENV` など）
- Firebase の prod / dev 切り替えは `ENV` で行う（[lib/env_config.dart](../../lib/env_config.dart)）。
  **Web デプロイのビルドには `--dart-define=ENV=prod` が必須**（未指定だと dev Firebase に繋がる）
- デプロイ先 URL の base-href は `--base-href` で指定される点に注意
- `mise-action` には `install_args: flutter` を指定する。`mise.toml` には `ruby` / `node` も
  含まれるが CI では不要で、特に `ruby` はソースビルドになり CI 時間を大きく浪費する
- `flutter analyze` / `flutter test` は**カレントパッケージしか対象にしない**。
  `local_package/my_manga_editor_data` は個別に実行する
  （`ci.yml` と [scripts/release.sh](../../scripts/release.sh) の双方で対応済み。
  ローカルでは `mise run check`）

## リリース時のバージョン運用

`pubspec.yaml` の `version: x.y.z+N` のうち **ビルド番号 `N` を最小バージョンゲートの判定に使う**
（[docs/design/data-model.md](../../docs/design/data-model.md) の「最小バージョンゲート」参照）。
Web は GitHub Pages にデプロイされ旧ビルドがブラウザにキャッシュされ続けるため、以下を守る。

- **リリースごとにビルド番号 `N` を必ずインクリメントする**。`N` は単調増加させ、過去の値を再利用しない
- 破壊的なスキーマ変更（[.claude/rules/data-layer.md](./data-layer.md) の expand-contract で旧クライアントを締め出したいケース）を含むリリースでは、デプロイ後に Firestore の `config/app.minSupportedBuildNumber` をそのリリースの `N` に更新し、旧クライアントに更新を強制する
- 後方互換なリリースでは `minSupportedBuildNumber` の更新は不要（ビルド番号のインクリメントのみ）
