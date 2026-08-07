# Tasks: シリーズ管理

## 前提
- Requirements: [requirements.md](./requirements.md)
- Design: [design.md](./design.md)
- 関連コード生成: 本機能は **root / data 両パッケージ**でコード生成が必要になる
  - data 側: `Manga` (`@freezed`) / `CloudManga` (`@freezed` + `@JsonSerializable`) の変更
  - root 側: `SeriesFilter` (`@freezed`) と新規 `@riverpod` プロバイダ
  - 実行方法は [.claude/rules/code-generation.md](../../../../.claude/rules/code-generation.md) を参照
- Firestore スキーマに触るため [.claude/rules/data-layer.md](../../../../.claude/rules/data-layer.md) の
  チェックリストを確認する（本 spec では **schemaVersion は据え置き**。判断理由は design.md 参照）

## 実装順序の原則
1. データ層（model → repository）を先に固め、後方互換テストで既存データの読み込みを守る
2. State 層（導出プロバイダ・絞り込み状態）を追加する
3. UI を最後に組み、AC を 1 つずつ確認する
4. ドキュメント（data-model / rules / CHANGELOG）を最後に整合させる

## タスク一覧

### T-001: ドメインモデル / クラウドモデルに `seriesName` を追加 [P]
- 対象:
  - `local_package/my_manga_editor_data/lib/model/manga.dart`
  - `local_package/my_manga_editor_data/lib/service/firebase/model/cloud_manga.dart`
  - `local_package/my_manga_editor_data/lib/repository/manga_repository.dart`（変換 extension 2 箇所）
- 内容:
  - `Manga` に `@Default('') String seriesName` を追加
  - `CloudManga` に `String? seriesName` を追加
  - `CloudMangaExt.fromFirestore` で `data['seriesName'] as String?` を読む
  - `CloudMangaExt.toFirestore` で `'seriesName': seriesName ?? ''` を**常に**書き込む
  - `CloudMangaConversion.toManga` で `seriesName: seriesName ?? ''`、
    `MangaToCloudConversion.toCloudManga` で `seriesName: seriesName`
  - `schemaVersion` は **1 のまま変更しない**（design.md「schemaVersion を上げない判断」参照）
- 完了条件:
  - data パッケージで `dart run build_runner build -d` が成功する
  - `flutter analyze` が通る
  - 既存テストが全て green のまま
- 依存: なし

### T-002: `CloudManga` の後方互換 fixture テストを追加 [P]
- 対象:
  - `test/data_migration/fixtures/manga/`（新規ディレクトリ）
  - `test/data_migration/schema_version_fixture_test.dart`
- 内容:
  - fixture 3 件を追加（既存 `manga_page` fixture と同じ `description` / `document` / `expected` 形式）
    - `v1_no_series_name.json` — `seriesName` フィールドが無い旧ドキュメント → `''`
    - `v1_empty_series_name.json` — `seriesName: ''` → `''`
    - `v1_with_series_name.json` — `seriesName: 'ヒーロー連載'` → `'ヒーロー連載'`
  - `schema_version_fixture_test.dart` に `CloudManga` 用の group を追加し、
    fixture ディレクトリを全件読んで `toManga().seriesName` を検証する
  - `CloudManga.toFirestore` が `seriesName` キーを常に含むことのテストを追加
- 完了条件:
  - FR-005 / NFR-003 / NFR-004 をカバー
  - `flutter test test/data_migration/` が全件パス
- 依存: T-001

### T-003: `MangaRepository` にシリーズ名の読み書きを追加
- 対象: `local_package/my_manga_editor_data/lib/repository/manga_repository.dart`
- 内容:
  - `Future<void> updateSeriesName(MangaId id, String seriesName)` を追加
    - 未認証なら `AuthException`（既存 `updateMangaName` と同じ形）
    - 100 文字超なら `ValidationException('Series name must be 100 characters or less')`
    - 空文字は許容し、`updateManga(id, {'seriesName': ''})` で更新する（`FieldValue.delete()` は使わない）
    - trim は呼び出し側（UI）で済ませる前提だが、Repository でも防御的に trim する
  - `createNewManga` に `String seriesName = ''` 引数を追加し、`CloudManga` に載せる
- 完了条件:
  - `flutter analyze` が通る
  - T-004 のテストがパス
- 依存: T-001

### T-004: `MangaRepository.updateSeriesName` のユニットテスト [P]
- 対象: `local_package/my_manga_editor_data/test/repository/manga_repository_series_test.dart`（新規）
- 内容: 既存 `manga_repository_export_test.dart` と同じ `MockFirebaseService` 方式で以下を検証
  - `updateSeriesName` が `updateManga(id, {'seriesName': 'X'})` を呼ぶ
  - 空文字を渡すと `{'seriesName': ''}` で更新される（削除ではない）
  - 前後に空白のある入力が trim されて渡る
  - 101 文字で `ValidationException`、100 文字ちょうどは成功
  - `createNewManga(seriesName: 'X')` が `seriesName` 入りの `CloudManga` を作る
- 完了条件:
  - AC-1.2 / AC-1.4 / AC-1.6 をカバー
  - `flutter test` が全件パス
- 依存: T-003

### T-005: シリーズ関連のプロバイダを追加
- 対象: `lib/feature/manga/provider/series_providers.dart`（新規）
- 内容:
  - `SeriesFilter` を freezed union (`all` / `unassigned` / `named(String)`) として定義
  - `seriesNameList` — `allMangaList` から `seriesName` を取り、空文字除外・重複除去・昇順ソート
  - `SeriesFilterNotifier` — 初期値 `SeriesFilter.all()`、`select(SeriesFilter)` を公開。
    `build()` 内で `seriesNameList` を `ref.listen` し、選択中の名前が消えたら `all()` に戻す
  - `filteredMangaList` — `allMangaList` を現在の `SeriesFilter` で絞った `List<Manga>`
- 完了条件:
  - root パッケージで `dart run build_runner build -d` が成功する
  - `flutter analyze` が通る
  - T-006 のテストがパス
- 依存: T-001

### T-006: シリーズ関連プロバイダのユニットテスト [P]
- 対象: `test/feature/manga/provider/series_providers_test.dart`（新規）
- 内容: `ProviderContainer` + `allMangaListProvider` の override で以下を検証
  - `seriesNameList` が重複除去・空文字除外・昇順（AC-2.2）
  - `filteredMangaList` が `all` で全件、`unassigned` で空文字のみ、`named` で一致のみ（AC-2.3 / AC-2.4）
  - 選択中シリーズの作品が 0 件になったら `SeriesFilter.all()` に戻る（AC-2.8）
  - シリーズが 1 つも無いとき `seriesNameList` が空リスト
- 完了条件:
  - 上記 AC をカバーし `flutter test` が全件パス
- 依存: T-005

### T-007: カンバンにシリーズ絞り込みバーを追加
- 対象:
  - `lib/feature/manga/view/series_filter_bar.dart`（新規）
  - `lib/feature/manga/page/manga_select_page.dart`
- 内容:
  - `SeriesFilterBar` — `すべて` / `未所属` / 各シリーズ名 の `ChoiceChip` を横スクロール可能に並べる。
    選択で `SeriesFilterNotifier.select` を呼ぶ
  - `MangaSelectPage` が `allMangaListProvider` ではなく `filteredMangaListProvider` を watch し、
    AppBar の下に `SeriesFilterBar` を置く
  - 列のバッジ件数は絞り込み後のリスト長になる（`KanbanColumn` は変更不要）
- 完了条件:
  - AC-2.1 / AC-2.3 / AC-2.4 / AC-2.5 を満たす
  - シリーズが 0 件でも `すべて` / `未所属` だけが出て崩れない
  - `flutter analyze` が通る
- 依存: T-005

### T-008: 絞り込み中の新規作成を選択中シリーズに紐づける
- 対象:
  - `lib/feature/manga/page/manga_select_page.dart`（新規作成ボタン）
  - `lib/feature/manga/provider/manga_page_view_model.dart`（`createNewManga` にシリーズ名を渡す）
- 内容:
  - 現在の `SeriesFilter` が `named` のときだけ、そのシリーズ名で作品を作る
  - `all` / `unassigned` のときは従来どおり未所属で作る
- 完了条件:
  - AC-2.6 を満たす
  - `flutter analyze` が通る
- 依存: T-003, T-005, T-007

### T-009: 編集画面にシリーズ名入力欄を追加
- 対象:
  - `lib/feature/manga/view/series_name_widget.dart`（新規）
  - `lib/feature/manga/page/manga_edit_page.dart`（`MangaTitle` に差し込む）
  - `lib/feature/manga/provider/manga_providers.dart`（`MangaNotifier.updateSeriesName`）
- 内容:
  - `MangaNameWidget` と同じタップ→編集の作法に揃えつつ、`Autocomplete<String>` で
    `seriesNameList` を候補に出す（入力文字列を含むものを提示）
  - 未所属時はプレースホルダ `シリーズ未設定` を表示
  - 確定時に trim して `MangaNotifier.updateSeriesName` を呼ぶ
  - `ValidationException` / `StorageException` を catch して SnackBar を出す
- 完了条件:
  - AC-1.1 / AC-1.2 / AC-1.3 / AC-1.4 / AC-1.5 / AC-1.6 を満たす
  - AppBar の高さ (`toolbarHeight: 100.r`) に収まり、作品名の表示が崩れない
  - `flutter analyze` が通る
- 依存: T-003, T-005

### T-010: ウィジェットテスト [P]
- 対象:
  - `test/feature/manga/view/series_filter_bar_test.dart`（新規）
  - `test/feature/manga/view/series_name_widget_test.dart`（新規）
- 内容:
  - Chip を選ぶとカンバンに出るカードとバッジ件数が変わる（AC-2.3 / AC-2.5）
  - 未所属の作品でプレースホルダが出る（AC-1.3）
  - 入力途中で既存シリーズ名が候補に出る（AC-1.5）
  - 101 文字入力で SnackBar が出て値が戻る（AC-1.6）
- 完了条件:
  - `flutter test` が全件パス
- 依存: T-007, T-009

### T-011: ドキュメント整合
- 対象:
  - [docs/design/data-model.md](../../../design/data-model.md)
  - [.claude/rules/data-layer.md](../../../../.claude/rules/data-layer.md)
  - [CHANGELOG.md](../../../../CHANGELOG.md)
  - [requirements.md](./requirements.md) / [design.md](./design.md)
- 内容:
  - data-model.md の `Manga` / `CloudManga` の表に `seriesName` を追記。
    スキーマバージョン履歴表に「`seriesName` 追加。欠損時は空文字で読めるため版は据え置き」の注記を足す
  - data-layer.md の Firestore Schema 節の `CloudManga` の括弧書きに `seriesName` を追記
  - CHANGELOG の `## [Unreleased]` に `### 追加` として利用者の言葉で 1 行
    （例: 「作品にシリーズ名を付けて、作品一覧をシリーズごとに絞り込めるようになりました」）
  - 本 spec の `Status` を `implemented` に、`Last Updated` を作業日に更新
- 完了条件:
  - spec とコード・既存ドキュメントの間に乖離がない
  - PR description に `Closes AC-1.1, ...` の対応関係が書かれている
- 依存: T-001 〜 T-010

## レビューで決めたいこと

実装着手前に人間のレビューで確認したい判断は以下の 3 点。
（いずれも design.md で方針を出しているので、異論がなければそのまま進める）

1. **`CloudManga.schemaVersion` を据え置く**判断でよいか（design.md「schemaVersion を上げない判断」）
2. **表記ゆれを完全一致で別シリーズ扱いにする**判断でよいか。
   大文字小文字・全半角を吸収せず、AC-1.5 の候補提示だけで予防する
3. **絞り込み状態を永続化しない**（リロードで `すべて` に戻る）判断でよいか
