# AI による UI レビューのための情報取得方法 — 調査ノート

調査日: 2026-07-08

AI (Claude Code 等) にアプリの UI をレビューさせるために、
UI 階層構造やスクリーンショットを取得する方法の調査結果をまとめる。

## 結論

**Dart SDK 3.12 に同梱されている公式の Dart/Flutter MCP サーバー (`dart mcp-server`) を
Claude Code に登録する方法が最適。**
追加パッケージなし・アプリコードの変更なしで、実行中アプリへの接続、
ウィジェットツリー取得、スクリーンショット取得、画面操作までできる。

## 公式 Dart MCP サーバーで確認できた機能

ローカルで `dart mcp-server` を起動し、JSON-RPC 経由でツール一覧を取得して確認済み
(Flutter 3.44.4 / Dart 3.12.2)。UI レビューに直結するツールは以下:

| ツール | できること |
|---|---|
| `dtd` | Dart Tooling Daemon 経由で実行中アプリに接続する。`listDtdUris` → `connect` の順で使う |
| `widget_inspector` | ウィジェットツリー取得 (`get_widget_tree`)。`summaryOnly: true` でユーザーコード由来の widget のみに絞れる |
| `flutter_driver_command` | **`screenshot`** によるスクリーンショット取得。`tap` / `enter_text` / `scroll` / `waitFor` 等で AI が画面を操作して遷移できる |
| `get_runtime_errors` | RenderFlex overflow などの実行時レイアウトエラー取得 |
| `hot_reload` / `hot_restart` | 修正 → 即反映 → 再スクリーンショットのループが回せる |

これにより「起動中のアプリに接続 → 画面を操作しながらスクリーンショットと
階層構造を取得 → レビュー → 修正 → hot reload → 再確認」というループが実現できる。

## セットアップ手順

```bash
# Claude Code に登録 (プロジェクト共有なら .mcp.json に書く)
claude mcp add dart -- dart mcp-server
```

`.mcp.json` に書く場合:

```json
{
  "mcpServers": {
    "dart": {
      "command": "dart",
      "args": ["mcp-server"]
    }
  }
}
```

### 利用時の流れ

1. `flutter run -d macos --print-dtd` でアプリを起動 (DTD URI が表示される)
2. Claude に「DTD `<uri>` に接続して UI をレビューして」と依頼
3. `dtd` ツールで接続後、上記の各ツールが使えるようになる

## 注意点

- **macOS デスクトップで実行するのが前提。**
  Flutter Web は canvas 描画のため VM service 経由のスクリーンショットが使えず、
  Playwright 等でページを撮っても DOM から UI 階層は取れない。
  本アプリはデスクトップ対応なので問題ない。
- `flutter_driver_command screenshot` が macOS デスクトップで確実に動くかは
  実際にアプリを起動しての実地確認が未了 (ツールの存在は確認済み)。
  動かない場合のフォールバックとして、macOS 標準の `screencapture -l <windowID>` で
  アプリウィンドウだけを撮るスクリプトを用意する手がある
  (ウィンドウ ID は `GetWindowID` や AppleScript で取得可能)。

## 検討した代替案 (非推奨)

### integration_test + ゴールデンテスト

CI で決まった画面を機械的に撮るには良いが、Firebase 認証のモックが必要で
初期コストが高く、「AI が対話的に見る」用途には不向き。
将来スクリーンショットの自動リグレッション検知をしたくなったら再検討する。

### VM service を直接叩く自作スクリプト

`ext.flutter.debugDumpApp` 等でウィジェット階層は取れるが、
公式 MCP サーバーがやることの下位互換にしかならない。
