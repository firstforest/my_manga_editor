# Tasks: 作品タグ

## 前提
- Requirements: [requirements.md](./requirements.md)
- Design: [design.md](./design.md)
- 関連コード生成: 本機能は **root / data 両パッケージ**でコード生成が必要になる
  - data 側: `Manga` (`@freezed`) / `CloudManga` (`@freezed` + `@JsonSerializable`) の変更
  - root 側: `TagFilter` (`@freezed`) と新規 `@riverpod` プロバイダ
  - 実行方法は [.claude/rules/code-generation.md](../../../../.claude/rules/code-generation.md) を参照
- Firestore スキーマに触るため [.claude/rules/data-layer.md](../../../../.claude/rules/data-layer.md) の
  チェックリストを確認する（本 spec では **schemaVersion は据え置き**。判断理由は design.md 参照）

## 実装順序の原則
1. データ層（model → service → repository）を先に固め、後方互換テストで既存データの読み込みを守る
2. State 層（導出プロバイダ・絞り込み状態）を追加する
3. UI を最後に組み、AC を 1 つずつ確認する
4. ドキュメント（data-model / rules / CHANGELOG）を最後に整合させる

## タスク一覧

### T-001: ドメインモデル / クラウドモデルに `tags` を追加 [P] ✅ 完了 (2026-08-08)
- 対象:
  - `local_package/my_manga_editor_data/lib/model/manga.dart`
  - `local_package/my_manga_editor_data/lib/service/firebase/model/cloud_manga.dart`
  - `local_package/my_manga_editor_data/lib/repository/manga_repository.dart`（変換 extension 2 箇所）
- 内容:
  - `Manga` に `@Default(<String>[]) List<String> tags` を追加
  - `CloudManga` に `List<String>? tags` を追加
  - `CloudMangaExt.fromFirestore` で `(data['tags'] as List<dynamic>?)?.cast<String>()` を読む
  - `CloudMangaExt.toFirestore` で `'tags': tags ?? const <String>[]` を**常に**書き込む
  - `CloudMangaConversion.toManga` で `tags: tags ?? const []`、
    `MangaToCloudConversion.toCloudManga` で `tags: tags`
  - `schemaVersion` は **1 のまま変更しない**（design.md「schemaVersion を上げない判断」参照）
- 完了条件:
  - data パッケージで `dart run build_runner build -d` が成功する
  - `flutter analyze` が通る
  - 既存テストが全て green のまま
- 依存: なし

### T-002: `CloudManga` の後方互換 fixture テストを追加 [P] ✅ 完了 (2026-08-08)
- 対象:
  - `test/data_migration/fixtures/manga/`（新規ディレクトリ）
  - `test/data_migration/schema_version_fixture_test.dart`
- 内容:
  - fixture 3 件を追加（既存 `manga_page` fixture と同じ `description` / `document` / `expected` 形式）
    - `v1_no_tags.json` — `tags` フィールドが無い旧ドキュメント → `[]`
    - `v1_empty_tags.json` — `tags: []` → `[]`
    - `v1_with_tags.json` — `tags: ['連載:ヒーロー', '商業']` → 同じ順序の配列
  - `schema_version_fixture_test.dart` に `CloudManga` 用の group を追加し、
    fixture ディレクトリを全件読んで `toManga().tags` を検証する
  - `CloudManga.toFirestore` が `tags` キーを常に含むことのテストを追加
- 完了条件:
  - FR-007 / NFR-003 / NFR-004 をカバー
  - `flutter test test/data_migration/` が全件パス
- 依存: T-001

### T-003: `FirebaseService` に配列差分操作を追加 [P] ✅ 完了 (2026-08-08)
- 対象: `local_package/my_manga_editor_data/lib/service/firebase/firebase_service.dart`
- 内容:
  - `Future<void> addMangaTag(String mangaId, String tag)` — `FieldValue.arrayUnion([tag])` と
    `updatedAt: FieldValue.serverTimestamp()` で update
  - `Future<void> removeMangaTag(String mangaId, String tag)` — `FieldValue.arrayRemove([tag])` で update
  - 既存メソッドと同じく `FirebaseException` を `FirebaseServiceException` に包む
  - `FieldValue` を Service の外に漏らさない
    （[architecture.md](../../../design/architecture.md) の 3rd party ラップ方針）
- 完了条件:
  - `flutter analyze` が通る
  - `fake_cloud_firestore` で追加・削除が配列に反映されることを確認するテストがある
- 依存: なし

### T-004: `MangaRepository` にタグの追加・削除を追加 ✅ 完了 (2026-08-08)
- 対象: `local_package/my_manga_editor_data/lib/repository/manga_repository.dart`
- 内容:
  - `Future<void> addTag(MangaId id, String tag)`
    - 未認証なら `AuthException`（既存 `updateMangaName` と同じ形）
    - trim して空文字なら Service を呼ばず正常終了（AC-1.4）
    - 30 文字超なら `ValidationException('Tag must be 1-30 characters')`
    - 現在のタグが 20 個以上なら `ValidationException('Too many tags')`
    - `FirebaseService.addMangaTag` を呼ぶ
  - `Future<void> removeTag(MangaId id, String tag)` — `FirebaseService.removeMangaTag` を呼ぶ
  - `createNewManga` に `List<String> tags = const []` 引数を追加し、`CloudManga` に載せる
- 完了条件:
  - `flutter analyze` が通る
  - T-005 のテストがパス
- 依存: T-001, T-003

### T-005: `MangaRepository` のタグ操作のユニットテスト [P] ✅ 完了 (2026-08-08)
- 対象: `local_package/my_manga_editor_data/test/repository/manga_repository_tags_test.dart`（新規）
- 内容: 既存 `manga_repository_export_test.dart` と同じ `MockFirebaseService` 方式で以下を検証
  - `addTag` が `addMangaTag(id, 'X')` を呼ぶ / `removeTag` が `removeMangaTag(id, 'X')` を呼ぶ
  - 前後に空白のある入力が trim されて渡る
  - 空文字・空白のみは Service を呼ばずに正常終了する（AC-1.4）
  - 31 文字で `ValidationException`、30 文字ちょうどは成功（AC-1.6）
  - 既に 20 個ある作品への追加で `ValidationException`（AC-1.7）
  - `createNewManga(tags: ['X'])` が `tags` 入りの `CloudManga` を作る
- 完了条件:
  - 上記 AC をカバーし `flutter test` が全件パス
- 依存: T-004

### T-006: タグ関連のプロバイダを追加 ✅ 完了 (2026-08-08)
- 対象: `lib/feature/manga/provider/tag_providers.dart`（新規）
- 内容:
  - `TagFilter` を freezed union (`all` / `untagged` / `tag(String)`) として定義
  - `tagList` — `allMangaList` の `tags` を平坦化し、重複除去・昇順ソート
  - `TagFilterNotifier` — 初期値 `TagFilter.all()`、`select(TagFilter)` を公開。
    `build()` 内で `tagList` を `ref.listen` し、選択中のタグが消えたら `all()` に戻す
  - `filteredMangaList` — `allMangaList` を現在の `TagFilter` で絞った `List<Manga>`
- 完了条件:
  - root パッケージで `dart run build_runner build -d` が成功する
  - `flutter analyze` が通る
  - T-007 のテストがパス
- 依存: T-001

### T-007: タグ関連プロバイダのユニットテスト [P] ✅ 完了 (2026-08-08)
- 対象: `test/feature/manga/provider/tag_providers_test.dart`（新規）
- 内容: `ProviderContainer` + `allMangaListProvider` の override で以下を検証
  - `tagList` が平坦化・重複除去・昇順（AC-2.2）
  - `filteredMangaList` が `all` で全件、`untagged` でタグ無しのみ、`tag` で該当のみ（AC-2.3 / AC-2.4）
  - 複数タグを持つ作品がどのタグで絞ってもヒットする（SC-003）
  - 選択中タグの作品が 0 件になったら `TagFilter.all()` に戻る（AC-2.8）
  - タグが 1 つも無いとき `tagList` が空リスト
- 完了条件:
  - 上記 AC をカバーし `flutter test` が全件パス
- 依存: T-006

### T-008: カンバンにタグ絞り込みバーを追加 ✅ 完了 (2026-08-08)
- 対象:
  - `lib/feature/manga/view/tag_filter_bar.dart`（新規）
  - `lib/feature/manga/page/manga_select_page.dart`
- 内容:
  - `TagFilterBar` — `すべて` / `タグなし` / 各タグ の `ChoiceChip` を横スクロール可能に並べる。
    選択で `TagFilterNotifier.select` を呼ぶ
  - `MangaSelectPage` が `allMangaListProvider` ではなく `filteredMangaListProvider` を watch し、
    AppBar の下に `TagFilterBar` を置く
  - 列のバッジ件数は絞り込み後のリスト長になる（`KanbanColumn` は変更不要）
- 完了条件:
  - AC-2.1 / AC-2.3 / AC-2.4 / AC-2.5 を満たす
  - タグが 0 件でも `すべて` / `タグなし` だけが出て崩れない
  - `flutter analyze` が通る
- 依存: T-006

### T-009: カンバンのカードにタグを表示 [P] ✅ 完了 (2026-08-08)
- 対象: `lib/feature/manga/view/kanban_card.dart`
- 内容:
  - カード下部（ページ数の行の近く）にタグを小さいチップで先頭から最大 3 個表示
  - 4 個目以降がある場合は `+N` を末尾に出す
  - タグが 0 個のときはその行ごと出さない（カードの高さを増やさない）
- 完了条件:
  - AC-2.10 を満たす
  - ドラッグ中の feedback (`width: 280`) でもレイアウトが崩れない
  - `flutter analyze` が通る
- 依存: T-001

### T-010: 絞り込み中の新規作成を選択中タグに紐づける ✅ 完了 (2026-08-08)
- 対象:
  - `lib/feature/manga/page/manga_select_page.dart`（新規作成ボタン）
  - `lib/feature/manga/provider/manga_page_view_model.dart`（`createNewManga` にタグを渡す）
- 内容:
  - 現在の `TagFilter` が `tag` のときだけ、そのタグを付けて作品を作る
  - `all` / `untagged` のときは従来どおりタグ無しで作る
- 完了条件:
  - AC-2.6 を満たす
  - `flutter analyze` が通る
- 依存: T-004, T-006, T-008

### T-011: 編集画面にタグ編集欄を追加 ✅ 完了 (2026-08-08)
- 対象:
  - `lib/feature/manga/view/manga_tags_widget.dart`（新規）
  - `lib/feature/manga/page/manga_edit_page.dart`（`MangaTitle` に差し込む）
  - `lib/feature/manga/provider/manga_providers.dart`（`MangaNotifier.addTag` / `removeTag`）
- 内容:
  - 現在のタグを `Chip`（`onDeleted` 付き）で並べ、末尾に「＋タグ」ボタンを置く
  - 追加入力は `Autocomplete<String>` で `tagList` を候補に出す（入力文字列を含むものを提示）
  - 確定時に trim して `MangaNotifier.addTag` を呼ぶ。空文字なら何もせず閉じる
  - `ValidationException` / `StorageException` を catch して SnackBar を出す
- 完了条件:
  - AC-1.1 〜 AC-1.8 を満たす
  - AppBar の高さ (`toolbarHeight: 100.r`) に収まり、作品名・開始ページ選択の表示が崩れない
    （収まらない場合は AppBar 高さの調整を本タスクに含める）
  - `flutter analyze` が通る
- 依存: T-004, T-006

### T-012: ウィジェットテスト [P] ✅ 完了 (2026-08-08)
- 対象:
  - `test/feature/manga/view/tag_filter_bar_test.dart`（新規）
  - `test/feature/manga/view/manga_tags_widget_test.dart`（新規）
  - `test/feature/manga/view/kanban_card_tags_test.dart`（新規）
- 内容:
  - Chip を選ぶとカンバンに出るカードとバッジ件数が変わる（AC-2.3 / AC-2.5）
  - カードがタグ 4 個のとき 3 個 + `+1` を表示する（AC-2.10）
  - × でタグが 1 つだけ外れる（AC-1.3）
  - 入力途中で既存タグが候補に出る（AC-1.8）
  - 31 文字入力で SnackBar が出て追加されない（AC-1.6）
- 完了条件:
  - `flutter test` が全件パス
- 依存: T-008, T-009, T-011

### T-013: ドキュメント整合 ✅ 完了 (2026-08-08)
- 対象:
  - [docs/design/data-model.md](../../../design/data-model.md)
  - [.claude/rules/data-layer.md](../../../../.claude/rules/data-layer.md)
  - [CHANGELOG.md](../../../../CHANGELOG.md)
  - [requirements.md](./requirements.md) / [design.md](./design.md)
- 内容:
  - data-model.md の `Manga` / `CloudManga` の表に `tags` を追記。
    スキーマバージョン履歴表に「`tags` 追加。欠損時は空配列で読めるため版は据え置き」の注記を足す
  - data-layer.md の Firestore Schema 節の `CloudManga` の括弧書きに `tags` を追記
  - CHANGELOG の `## [Unreleased]` に `### 追加` として利用者の言葉で 1 行
    （例: 「作品にタグを付けて、作品一覧をタグごとに絞り込めるようになりました。
    連載の各話に同じタグを付ければ、シリーズとしてまとめて見られます」）
  - 本 spec の `Status` を `implemented` に、`Last Updated` を作業日に更新
- 完了条件:
  - spec とコード・既存ドキュメントの間に乖離がない
  - PR description に `Closes AC-1.1, ...` の対応関係が書かれている
- 依存: T-001 〜 T-012

## 残っている手動確認

自動テストでは代替できないもの。実機 (または `mise run run`) で確認する。

- [ ] 絞り込み中にカードをドラッグしてステータスを変えてもタグが外れない（AC-2.7）
- [ ] 絞り込み中の「新規作成」がそのタグ付きの作品を作る（AC-2.6）
- [ ] 2 端末（またはブラウザ 2 タブ）で同じ作品に別々のタグを足すと両方残る（FR-006）
- [ ] オフラインでタグを足し、再接続後に同期される（NFR-002）
- [ ] タグが 20 個以上ある状態で絞り込みバーが横スクロールし、カンバンの高さを圧迫しない

## レビューで決めたいこと

実装着手前に人間のレビューで確認したい判断は以下の 4 点。
（いずれも design.md で方針を出しているので、異論がなければそのまま進める）

1. **シリーズ専用の仕組みを作らず、タグの付け方（例 `連載:ヒーロー`）で表現する**判断でよいか
   （design.md 代替案 A）
2. **`CloudManga.schemaVersion` を据え置く**判断でよいか（design.md「schemaVersion を上げない判断」）
3. **表記ゆれを完全一致で別タグ扱いにする**判断でよいか。
   大文字小文字・全半角を吸収せず、AC-1.8 の候補提示だけで予防する
4. **絞り込みは単一タグのみ**（複数タグの AND / OR はスコープ外）、
   かつ**絞り込み状態を永続化しない**（リロードで `すべて` に戻る）判断でよいか
