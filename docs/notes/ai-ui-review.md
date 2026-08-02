# AI による UI レビューのための情報取得方法 — 調査ノート

調査日: 2026-07-08 / 実地検証にもとづく改訂: 2026-08-02

AI (Claude Code 等) にアプリの UI をレビューさせるために、
UI 階層構造やスクリーンショットを取得する方法の調査結果をまとめる。

## 結論

**Dart SDK 3.12 に同梱されている公式の Dart/Flutter MCP サーバー (`dart mcp-server`) を
Claude Code に登録する。** 追加パッケージなし・アプリコードの変更なしで、
実行中アプリへの接続、ウィジェットツリー取得、実行時エラー取得、hot reload まで行える。

ただし**レビュー対象は Web (`flutter run`) とする**。初版は macOS デスクトップを前提に
していたが、本リポジトリに macOS デスクトップ対応は入っていない (下記の訂正を参照)。

## 初版の誤りと訂正 (2026-08-02 実地検証)

| 初版の記述 | 実際 |
|---|---|
| 「本アプリはデスクトップ対応なので問題ない」 | **`macos/` ディレクトリが存在せず、macOS デスクトップは未対応。** git 管理下のプラットフォームは `android` / `ios` / `web` のみ。`mise run` も `flutter run --web-port=50505` で、実運用ターゲットは Web (GitHub Pages) |
| `flutter run -d macos --print-dtd` で DTD URI を表示させる | **Flutter 3.44.4 の `flutter run` に `--print-dtd` は存在しない** (`flutter run --help` に該当オプションなし) |
| (記載なし) | **`.mcp.json` を追加しても実行中の Claude Code セッションには反映されない。** MCP サーバーはセッション起動時に読み込まれるため、登録後にセッションを開き直す必要がある |
| (記載なし) | **`dart mcp-server` 自身がアプリを起動・管理できる** (`launch_app` / `list_running_apps` / `stop_app`)。DTD URI を人間が手で渡す前提の手順は必須ではない |

## セットアップ

リポジトリ直下の `.mcp.json` で登録済み (プロジェクト共有):

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

個人環境だけに入れる場合は `claude mcp add dart -- dart mcp-server`。

**登録後は Claude Code のセッションを開き直すこと。** 既存セッションには反映されない。

## Dart MCP サーバーの機能一覧

`dart mcp-server --help` の `--enable` / `--disable` 候補として列挙される
(Flutter 3.44.4 / Dart 3.12.2 で確認):

```
analyze_files, create_project, dart_fix, dart_format, dtd, flutter_driver_command,
get_active_location, get_app_logs, get_runtime_errors, hot_reload, hot_restart,
launch_app, list_devices, list_running_apps, lsp, pub, pub_dev_search,
read_package_uris, rip_grep_packages, roots, run_tests, stop_app, widget_inspector,
flutter_driver_user_journey_test
```

UI レビューに直結するもの:

| ツール | できること |
|---|---|
| `launch_app` / `list_running_apps` / `stop_app` | MCP サーバー自身がアプリを起動・列挙・停止する |
| `dtd` | Dart Tooling Daemon 経由で実行中アプリに接続する (`listDtdUris` → `connect`) |
| `widget_inspector` | ウィジェットツリー取得 (`get_widget_tree`)。`summaryOnly: true` でユーザーコード由来の widget のみに絞れる |
| `get_runtime_errors` | RenderFlex overflow などの実行時レイアウトエラー取得 |
| `get_app_logs` | アプリログ取得 |
| `hot_reload` / `hot_restart` | 修正 → 即反映 → 再確認のループが回せる |
| `flutter_driver_command` | `tap` / `enter_text` / `scroll` / `waitFor` / `screenshot`。ただし Web での可否は未確認 (下記) |

## Web でのレビュー手順

```bash
mise run setup                                   # 依存解決 (worktree では毎回必要)
flutter run -d web-server --web-port=50505       # http://localhost:50505 で配信
```

- 生成コード (`*.g.dart` / `*.freezed.dart`) は git 管理下なので `build_runner` は不要。
- ログインは **匿名サインイン**が使えるため、Google OAuth を通さずにレビューできる
  (`lib/feature/auth/view/sign_in_button.dart` の "Sign in anonymously")。
- ポートを 50505 に固定するのは Firebase Auth のログイン状態を origin 単位で維持するため。
  レビュー時もこのポートを保つこと。

### `-d chrome` と `-d web-server` の違い

- `-d chrome`: Flutter が専用プロファイルの Chrome を新規に起動する。
  そのウィンドウには Claude の Chrome 拡張が入っていないため、拡張経由の操作はできない。
- `-d web-server`: HTTP 配信のみ。任意の Chrome で開けるので拡張経由の操作と組み合わせられる。
  ただし起動時に「デバッグには Dart Debug Chrome 拡張が必要」と警告が出る。

## ブラウザ操作側 (claude-in-chrome) の注意

- **claude-in-chrome は「実行マシン」ではなく「アカウント」単位で Chrome 拡張に接続する。**
  Anthropic 側のリレー経由で繋がるため、拡張が入っている Chrome は別マシンのものでも
  `list_connected_browsers` に出てくる。`isLocal` フィールドで同一マシンかを判定できる。
- 接続先の Chrome が別マシンだと、その Chrome の `localhost:50505` は
  **そのマシン自身の** localhost を指すため `ERR_CONNECTION_REFUSED` になる。
- 対処は **SSH ポートフォワード**。ブラウザ側のマシンから:

  ```
  ssh -N -L 50505:127.0.0.1:50505 <user>@<flutter run しているホスト>
  ```

  既存の SSH セッションがあるなら、エスケープシーケンスで後付けもできる
  (`Enter` → `~C` → `ssh> -L 50505:127.0.0.1:50505`)。
- LAN の IP で直接開く方法もあるが、オリジンが `localhost:50505` から変わってしまい
  Firebase Auth のログイン状態の維持やドメイン制約に影響するため、
  ポートフォワードでオリジンを保つほうがよい。

## 未確認事項

- `widget_inspector` の `get_widget_tree` が Web (dwds) 経由で機能するか。
  `-d web-server` は VM service デバッグに Dart Debug Chrome 拡張を要求する旨の
  警告を出すため、拡張なしでは繋がらない可能性がある。
- `flutter_driver_command` の `screenshot` が Web で使えるか。
  使えない場合は Chrome 拡張側の screenshot で代替する
  (CanvasKit 描画でも画面のピクセルは取得できるので視覚レビューには支障ない)。
- Flutter Web はセマンティクスを有効化すると DOM にアクセシビリティツリーを構築するため、
  ウィジェット階層の代替として利用できる可能性がある (未検証)。

## 検討した代替案 (非推奨)

### macOS デスクトップ対応を追加する

`flutter create --platforms=macos .` で `macos/` 一式を追加すれば初版の想定どおりになるが、
Firebase の macOS 設定やネットワーク entitlement の整備が必要で差分が大きい。
実運用ターゲットが Web である以上、レビュー環境としても Web のほうが実機に近い。

### integration_test + ゴールデンテスト

CI で決まった画面を機械的に撮るには良いが、Firebase 認証のモックが必要で
初期コストが高く、「AI が対話的に見る」用途には不向き。
将来スクリーンショットの自動リグレッション検知をしたくなったら再検討する。

### VM service を直接叩く自作スクリプト

`ext.flutter.debugDumpApp` 等でウィジェット階層は取れるが、
公式 MCP サーバーがやることの下位互換にしかならない。
