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

## リリース時のバージョン運用

`pubspec.yaml` の `version: x.y.z+N` のうち **ビルド番号 `N` を最小バージョンゲートの判定に使う**
（[docs/design/data-model.md](../../docs/design/data-model.md) の「最小バージョンゲート」参照）。
Web は GitHub Pages にデプロイされ旧ビルドがブラウザにキャッシュされ続けるため、以下を守る。

- **リリースごとにビルド番号 `N` を必ずインクリメントする**。`N` は単調増加させ、過去の値を再利用しない
- 破壊的なスキーマ変更（[.claude/rules/data-layer.md](./data-layer.md) の expand-contract で旧クライアントを締め出したいケース）を含むリリースでは、デプロイ後に Firestore の `config/app.minSupportedBuildNumber` をそのリリースの `N` に更新し、旧クライアントに更新を強制する
- 後方互換なリリースでは `minSupportedBuildNumber` の更新は不要（ビルド番号のインクリメントのみ）
