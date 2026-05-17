# Tasks: Manga Export

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

### T-003: ページコピーのウィジェットテストを追加 [P] ⏸ 保留（T-005 の後に着手）
- 理由: 現在の `_copyAllDialoguesToClipboard` は `SystemClipboard.instance`（静的 singleton）を
  直接参照しており、テストから差し替えるには DI 化が必須。
  T-005 で失敗時 SnackBar を追加する際にここを clipboard の引数渡しか provider 化するので、
  その変更とセットで書く方が手戻りが少ない（spec の備考通り）
- 対象（着手時）: `test/feature/manga/view/manga_page_widget_copy_test.dart`（新規）
- 内容（着手時）:
  - コピーボタン押下後に SnackBar `Page <N> をコピーしました` が表示（AC-1.2）
  - dialogues が全 SceneUnit で空のとき、クリップボードに書き込まない（AC-1.3）
  - clipboard が null のとき、失敗 SnackBar が表示される（AC-1.4 / T-005 のテスト）
- 依存: T-005

### T-004: `[NEEDS CLARIFICATION]` 解消 ✅ 完了 (2026-05-17)
確定事項：
  1. AC-1.4: クリップボード書き込み失敗時は **SnackBar で通知**（`Page <N> のコピーに失敗しました`）
  2. AC-2.3: ダウンロード拡張子は **`.md`**、MIME は `text/markdown`
  3. AC-2.6: ダウンロード失敗時は **SnackBar** で通知（`保存に失敗しました`）。詳細は logger.e へ
  4. 作品名サニタイズ: 禁止文字 `/ \ : * ? " < > |` + 制御文字を `_` に置換
  5. FR-005: 変換ロジックは **`my_manga_editor_common/lib/delta_text.dart`** に
     `String deltaToPlainText(Delta delta)` として集約。UI / Data 両層から呼ぶ
- 反映: requirements.md / design.md 更新済み、Status を `reviewed` に変更

### T-005: クリップボード書き込み失敗時の UI フィードバック [P]
- 対象: `lib/feature/manga/view/manga_page_widget.dart` (`_copyAllDialoguesToClipboard`)
- 内容:
  - `SystemClipboard.instance == null` の場合、`SnackBar` で失敗を通知
  - 既存の成功時 SnackBar との出し分けを `ScaffoldMessenger` で行う
- 完了条件:
  - AC-1.4 を満たす
  - T-003 のウィジェットテストに失敗ケースの assertion を追加し、パス
- 依存: T-003, T-004

### T-006: ダウンロード処理の拡張子 / エラー UI 整備
- 対象:
  - `lib/feature/manga/provider/manga_providers.dart` (`MangaNotifier.download`)
  - `lib/feature/manga/page/manga_grid_page.dart`（呼び出し側）
- 内容:
  - T-004 で確定した拡張子 (`.txt` or `.md`) と `MimeType` に統一
  - `download()` 中の例外を catch し、UI 側で SnackBar / Dialog を表示
  - 作品名のサニタイズ（決定された方針に従う）
- 完了条件:
  - AC-2.2, AC-2.3, AC-2.6 を満たす
  - 既存 `MangaNotifier.download` を呼ぶ箇所すべてが新しい挙動で動く
- 依存: T-004

### T-007: Delta → プレーンテキスト変換ロジックの集約
- 対象:
  - `local_package/my_manga_editor_common/lib/delta_text.dart`（新規）
  - `local_package/my_manga_editor_common/lib/my_manga_editor_common.dart`（export 追加）
  - `lib/feature/manga/provider/manga_providers.dart` (`DeltaNotifier.exportPlainText` を差し替え)
  - `local_package/my_manga_editor_data/lib/repository/manga_repository.dart` (`toMarkdown` 内の op ループを差し替え)
- 内容:
  - `String deltaToPlainText(Delta delta)` を新規実装
    - `op.data is String` のものを順に連結
    - 3 連続以上の改行を 2 連続に圧縮（既存 `RegExp(r'\n\s*\n\s*\n\s*')` と同等）
    - 先頭末尾 trim
  - `my_manga_editor_common` の `pubspec.yaml` に `flutter_quill` 依存が必要なら追加
  - 既存 2 箇所をこの関数呼び出しに置換
- 完了条件:
  - FR-005 を満たす
  - T-001, T-002 が引き続きパス
  - `flutter analyze` がパス
- 依存: T-004, T-001, T-002

### T-008: 不要メソッド削除 (`MangaNotifier.toMarkdown`)
- 対象: `lib/feature/manga/provider/manga_providers.dart`
- 内容:
  - `MangaNotifier.toMarkdown()` は `'Markdown export not yet implemented'` を返すだけの未実装メソッド。
    実体の Markdown 化は `MangaRepository.toMarkdown` 側で行われており、UI からこの未実装メソッドへの参照は無い
  - 呼び出し元を全リポジトリ検索（`grep -rn 'toMarkdown' lib/`）で確認後、未参照なら削除
- 完了条件:
  - `flutter analyze` がパス
  - 既存テストがパス
- 依存: T-001（toMarkdown の責務が Repository 側にあることを確定してから）

### T-009: 関連ドキュメントの整合
- 対象:
  - [docs/spec/features/manga-export/requirements.md](./requirements.md)
  - [docs/spec/features/manga-export/design.md](./design.md)
- 内容:
  - T-005 〜 T-008 の結果を反映し、`Status: implemented` に更新
  - 実装後に変わった API シグネチャ・出力フォーマットを反映
  - `Last Updated` を作業日に更新
- 完了条件:
  - spec とコードの間に乖離がない
  - PR description に `Closes AC-x.y` の対応関係が書かれている
- 依存: T-005, T-006, T-007, T-008
