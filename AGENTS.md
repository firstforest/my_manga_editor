# AGENTS.md

This file provides guidance to coding agents when working with code in this repository.

## Project Overview

**My Manga Editor** — Flutter desktop / Web app for manga plot editing.
Pages have 3 editing areas: memo, dialogue (セリフ), stage direction (ト書き). Exports dialogue text for ClipStudio Paint integration.

## Development Commands

```bash
# Setup (requires mise: https://mise.jdx.dev/)
mise i

# Run
flutter run
flutter run --dart-define=ENV=prod                 # switch Firebase project (default: dev)

# Code generation (REQUIRED after model/provider changes)
dart run build_runner build -d                                # root package
cd local_package/my_manga_editor_data && dart run build_runner build -d && cd -  # data package

# Quality
flutter analyze
flutter test
flutter test test/feature/manga/provider/manga_providers_test.dart  # single test
```

## Architecture (Summary)

```
UI (lib/feature/) → Riverpod Notifier → Repository → Service → Firestore
```

- **Root package** (`lib/`) — UI 層。`feature/{auth,manga}` で機能別に分割
- **`my_manga_editor_data`** (`local_package/`) — データ層。`repository/ service/ model/` の3層
- **`my_manga_editor_common`** (`local_package/`) — 共有ユーティリティ（logger）

詳細は **[docs/design/architecture.md](docs/design/architecture.md)** を参照（全体俯瞰・レイヤー構造・技術スタック）。

## 検証とレビュー

- コミット・PR の前に `verify` スキル ([.claude/skills/verify/SKILL.md](.claude/skills/verify/SKILL.md)) で analyze・test・コード生成の漏れを確認する。コマンドの出力を見ずに「通った」と報告しない
- テストを削除する・skip する・期待値を実装に合わせて書き換える、で通さない。テストのほうが間違っていると判断したら、直さずに根拠を添えて報告する
- PR を作る前に `/code-review high` を実行し、指摘に対応する。スキーマ移行・`firestore.rules`・認証に触れる変更は `/code-review ultra` も検討する
- `.dart` の整形は PostToolUse hook ([.claude/hooks/dart-format.sh](.claude/hooks/dart-format.sh)) が編集のたびに行う
- この仕組みの全体像と今後の導入計画は [docs/notes/ai-dev-flow.md](docs/notes/ai-dev-flow.md)

## Reference Documentation

作業対象に応じて以下を必ず参照する。

| 作業対象 | 参照ドキュメント |
|---|---|
| リリース・バックアップ・ロールバック | [docs/release.md](docs/release.md) |
| **利用者から見て何かが変わる変更を入れたとき** | [CHANGELOG.md](CHANGELOG.md) の `## [Unreleased]` に利用者の言葉で追記する（[書き方](docs/release.md#リリースノートを書く)）|
| 機能 spec の作成・更新時 | [docs/spec/README.md](docs/spec/README.md) |
| 全体アーキテクチャ・レイヤー構造 | [docs/design/architecture.md](docs/design/architecture.md) |
| ドメインモデル / Firestore スキーマ | [docs/design/data-model.md](docs/design/data-model.md) |
| `@freezed` / `@riverpod` を含む `.dart` 編集時 | [.claude/rules/code-generation.md](.claude/rules/code-generation.md) |
| `local_package/my_manga_editor_data/**` 編集時 | [.claude/rules/data-layer.md](.claude/rules/data-layer.md) |
| Riverpod Provider 追加・テスト時 | [.claude/rules/providers.md](.claude/rules/providers.md) |
| `lib/router.dart` / 画面追加時 | [.claude/rules/routing.md](.claude/rules/routing.md) |
| `.github/workflows/**` 編集時 | [.claude/rules/ci.md](.claude/rules/ci.md) |
