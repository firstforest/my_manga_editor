---
paths:
  - ".github/workflows/**"
---

# CI/CD

GitHub Actions で Flutter Web を GitHub Pages にデプロイする。

## Workflow

- ファイル: `.github/workflows/main.yml`
- トリガー: `main` ブランチへの push、または手動実行 (`workflow_dispatch`)
- 処理: `flutter build web --release` → GitHub Pages アーティファクトとしてデプロイ
- バージョン管理: `mise` で Flutter / Dart のバージョンを固定

## 変更時の注意

- 環境変数を扱う場合は `--dart-define` 経由で渡す（`ENV`, `OPENAI_API_KEY` など）
- Firebase の prod / dev 切り替えは `ENV` で行う（[lib/env_config.dart](../../lib/env_config.dart)）
- デプロイ先 URL の base-href は `--base-href` で指定される点に注意
