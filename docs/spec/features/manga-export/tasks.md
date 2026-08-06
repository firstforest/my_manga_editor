# Tasks: Manga Export

**状態: 全タスク完了 (2026-08-03)。** requirements.md / design.md は `Status: implemented`。

## 前提
- Requirements: [requirements.md](./requirements.md)
- Design: [design.md](./design.md)
- 本 spec は **既存実装の後追い文書化** が主目的のため、タスクは「テスト整備」と
  「`[NEEDS CLARIFICATION]` 解消後の改善」が中心。新機能追加は無い。
- 関連コード生成: 本タスク群では `@freezed` / `@riverpod` の変更は想定していない。
  もしプロバイダ追加に発展したら、root パッケージで `dart run build_runner build -d` を実行する。

## 実装順序の原則
1. まず **回帰検証用テスト** を入れ、現状挙動を固定する（T-001 〜 T-003）
2. **NEEDS CLARIFICATION を解消** する（T-004。設計判断のため人間レビュー必須）
3. 解消結果に応じた**改善実装**を行う（T-005 〜 T-008）
4. 最後に**ドキュメント整合**（T-009）

## タスク一覧

### T-001: `MangaRepository.toMarkdown` の回帰テストを追加 [P] ✅ 完了 (2026-05-17)
- 実装: [local_package/my_manga_editor_data/test/repository/manga_repository_export_test.dart](../../../../local_package/my_manga_editor_data/test/repository/manga_repository_export_test.dart)
- 採用方針: **`FirebaseService` を mockito でモック**して Repository 本体を実物で動かす方式
- Connectivity 切り出し: `connectivity_plus` を直接 import していた箇所を新規 [`ConnectivityService`](../../../../local_package/my_manga_editor_data/lib/service/connectivity_service.dart) でラップし、Repository に DI する設計に変更。テストでは `MockConnectivityService` で `Stream.empty()` / `Future.value(true)` を返してプラットフォームチャネルを起動させない
- 6 シナリオ全てパス: SceneUnit 0 / 1 / 複数、空 Delta 混在、アイデアメモあり / なし
- AC-2.4 / AC-2.5 をカバー
- 追加した依存: `local_package/my_manga_editor_data/pubspec.yaml` の dev_dependencies に `mockito: ^5.4.5`

### T-002: `DeltaNotifier.exportPlainText` の回帰テストを追加 [P] ✅ 完了 (2026-05-17)
- 実装: [test/feature/manga/provider/delta_notifier_export_test.dart](../../../../test/feature/manga/provider/delta_notifier_export_test.dart)
- 採用方針: `MangaRepository` の自動 Mock 生成は extension type (`MangaId` / `DeltaId`) の fallback で詰まるため、
  必要メソッドだけ実装した手書き `_FakeMangaRepository extends Fake` を使用
- 4 シナリオ全てパス: 3 連改行圧縮 / 装飾落ち / 空 Delta / trim
- AC-1.5 をカバー
- 既存テスト (`manga_providers_test.dart` の 1 件) もそのまま green を維持

### T-003: ページコピーのウィジェットテストを追加 [P] ✅ 完了 (2026-08-03)
- 実装: [test/feature/manga/view/manga_page_widget_copy_test.dart](../../../../test/feature/manga/view/manga_page_widget_copy_test.dart)
- 採用方針: `SystemClipboard.instance` を新規 [`clipboardWriterProvider`](../../../../lib/feature/manga/provider/clipboard_provider.dart)
  でラップし、テストでは `ClipboardWriter` の Fake / null に差し替える。
  Repository は `getDeltaStream` だけ実装した手書き Fake（T-002 と同じ理由）
- `MangaPageWidget` 本体は Quill エディタを含んで重いため、コピー導線
  (`copyPageDialoguesWithFeedback`) をボタン 1 つの最小画面に載せて検証する
- 5 シナリオ全てパス: 成功 SnackBar (AC-1.2) / 空のとき書き込まない (AC-1.3) /
  クリップボード無しで失敗 SnackBar (AC-1.4) / 複数カットが 1 回の書き込みにまとまる /
  カット順を保った空行区切りの連結 (AC-1.1)

### T-004: `[NEEDS CLARIFICATION]` 解消 ✅ 完了 (2026-05-17)
確定事項：
  1. AC-1.4: クリップボード書き込み失敗時は **SnackBar で通知**（`Page <N> のコピーに失敗しました`）
  2. AC-2.3: ダウンロード拡張子は **`.md`**、MIME は `text/markdown`
  3. AC-2.6: ダウンロード失敗時は **SnackBar** で通知（`保存に失敗しました`）。詳細は logger.e へ
  4. 作品名サニタイズ: 禁止文字 `/ \ : * ? " < > |` + 制御文字を `_` に置換
  5. FR-005: 変換ロジックは **`my_manga_editor_common/lib/delta_text.dart`** に
     `String deltaToPlainText(Delta delta)` として集約。UI / Data 両層から呼ぶ
- 反映: requirements.md / design.md 更新済み、Status を `reviewed` に変更

### T-005: クリップボード書き込み失敗時の UI フィードバック [P] ✅ 完了 (2026-08-03)
- 実装: [lib/feature/manga/view/copy_page_dialogues.dart](../../../../lib/feature/manga/view/copy_page_dialogues.dart)（新規）
- `manga_page_widget.dart` にあった `_copyAllDialoguesToClipboard` をこのファイルへ移し、
  結果を `CopyPageDialoguesResult` (copied / empty / unavailable / failed) で返すようにした。
  SnackBar の出し分けは `copyPageDialoguesWithFeedback` に集約（呼び出し 2 箇所の重複も解消）
- クリップボードが無い環境 (`unavailable`) だけでなく、`write` が例外を投げた場合 (`failed`) も
  拾って SnackBar を出す。捕まえないと Future が捨てられて利用者に何も表示されないため
- **spec 追記**: 実装時に AC-1.3（セリフが空）も同じくサイレント no-op だと分かったため、
  `Page <N> にコピーするセリフがありません` を出すようにし requirements.md の AC-1.3 を更新した。
  これまでは空でも「コピーしました」と表示されていた
- AC-1.2 / AC-1.3 / AC-1.4 を満たす。検証は T-003 のウィジェットテスト

### T-006: ダウンロード処理の拡張子 / エラー UI 整備 ✅ 完了 (2026-08-03)
- 実装:
  - [lib/feature/manga/provider/manga_providers.dart](../../../../lib/feature/manga/provider/manga_providers.dart)
    (`MangaNotifier.download` / `sanitizeFileName`)
  - [lib/feature/manga/page/manga_edit_page.dart](../../../../lib/feature/manga/page/manga_edit_page.dart)（呼び出し側）
- **spec 訂正**: 呼び出し側は `manga_grid_page` ではなく編集画面 `manga_edit_page` の
  ツールバーだった。requirements.md (AC-2.1) と design.md を実装に合わせて訂正した
- 拡張子 `.md` / `MimeType.markdown` に統一（AC-2.3）、作品名は `sanitizeFileName` を通す（AC-2.2）
- `download()` は失敗を `logger.e` に残して rethrow し、画面側で catch して
  `保存に失敗しました` を表示する（AC-2.6 / FR-006）。作品が取得できない場合も同様に失敗として扱う
- 完了通知に出す作品名は `download()` の戻り値を使う。画面側で `mangaProvider` を読み直すと、
  まだ loading のときに `null をダウンロードしました` と表示されてしまうため
- サニタイズのテストは [manga_providers_test.dart](../../../../test/feature/manga/provider/manga_providers_test.dart) に追加

### T-007: Delta → プレーンテキスト変換ロジックの集約 ✅ 完了 (2026-08-03)
- 実装: [local_package/my_manga_editor_common/lib/delta_text.dart](../../../../local_package/my_manga_editor_common/lib/delta_text.dart)（新規）
  と [delta_text_test.dart](../../../../local_package/my_manga_editor_common/test/delta_text_test.dart)（新規、6 ケース）
- 依存追加: `flutter_quill`（UI 一式）ではなく Delta 実装のみの `dart_quill_delta` を common に追加。
  `flutter_quill/quill_delta.dart` はこのパッケージの再 export なので型は互換
- 差し替え済み: `DeltaNotifier.exportPlainText` と `MangaRepository.toMarkdown`。
  Repository 側は見出しの出力判定も「変換後テキストが空か」に統一した（AC-2.5）
- **副作用**: 作品全体の書き出しでも本文の trim・改行圧縮が効くようになった。
  出力フォーマットも見出しの後に必ず空行が入る形に揃えた（design.md を更新済み）
- **CI 追加**: common にテストを置いたため、`ci.yml` / `mise run check` / `release.sh` の
  品質ゲートに common の `flutter analyze` / `flutter test` を追加した
  （どちらもカレントパッケージしか見ないため）
- FR-005 を満たす。T-001 / T-002 は引き続きパス、`flutter analyze` もパス

### T-008: 不要メソッド削除 (`MangaNotifier.toMarkdown`) ✅ 完了 (2026-08-03)
- `lib/` / `test/` を検索して未参照であることを確認したうえで削除した
  （実体の Markdown 化は `MangaRepository.toMarkdown` 側にある）
- `flutter analyze` / 既存テストともにパス

### T-009: 関連ドキュメントの整合 ✅ 完了 (2026-08-03)
- requirements.md / design.md を `Status: implemented` に更新し、`Last Updated` を作業日に変更
- 実装で判明した記載の誤りを訂正:
  - ダウンロードの導線は `manga_grid_page` ではなく `manga_edit_page` のツールバー
  - AC-1.3 にセリフが空のときの通知を追記（T-005 参照）
- API 一覧・シーケンス図・出力フォーマット・エラー設計・テスト戦略を実装後の状態に更新
- 利用者から見える変更は [CHANGELOG.md](../../../../CHANGELOG.md) の `## [Unreleased]` に追記済み
