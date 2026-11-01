# Tasks: ページとカットの並べ替え

## 前提
- Requirements: [requirements.md](./requirements.md)
- Design: [design.md](./design.md)
- 関連コード生成:
  - root: `MangaNotifier` (`@riverpod`) にメソッドを足すので `dart run build_runner build -d`
  - data: `@freezed` / `@riverpod` の変更はないが、テストのモック (`@GenerateNiceMocks`) を更新するため
    `cd local_package/my_manga_editor_data && dart run build_runner build -d`
- Firestore スキーマは変えない（`schemaVersion` 据え置き。理由は design.md「データモデル」）

## 実装順序の原則
1. データ層（Service の batch → Repository の `moveSceneUnit`）をテスト付きで固める
2. Notifier を追加する
3. ページの「︙」メニューとページリストの `ListView` 化を先に入れる（ページのドラッグを外す）
4. カットのドラッグを組み、AC を 1 つずつ確認する
5. ドキュメント（data-model / CHANGELOG）を整合させる

## タスク一覧

### T-001: `FirebaseBatchWrapper` に Delta 更新・ページ削除・Delta 削除を追加
- 対象: `local_package/my_manga_editor_data/lib/service/firebase/firebase_service.dart`
- 内容:
  - `updateDelta(mangaId, deltaId, updates)`（`updatedAt` を付ける）、`deletePage(mangaId, pageId)`、`deleteDelta(mangaId, deltaId)` を追加
  - `FieldValue` は wrapper の中に閉じ、Repository へは出さない
- 完了条件:
  - `flutter analyze` が通る
- 依存: なし

### T-002: `MangaRepository.moveSceneUnit` を追加
- 対象:
  - `local_package/my_manga_editor_data/lib/repository/manga_repository.dart`
  - `local_package/my_manga_editor_data/test/repository/manga_repository_scene_unit_test.dart`
- 内容:
  - 同じページなら index を読み替えて `reorderSceneUnit` と同じ処理をする
  - 別のページなら 2 ページを読み、1 つの batch で「元から取り除く／移動先へ挿入／Delta 2 件の `pageId` 書き換え」を行う
  - 元ページが空になるなら、同じ batch で元ページと、移したもの以外の元ページの Delta を削除し、`_pageToMangaMap` から外す。戻り値 `true`
  - ページが見つからなければ `NotFoundException`、index 範囲外なら何もしない
  - design.md「テスト戦略」のユニットテストを追加
- 完了条件:
  - AC-2.1, AC-2.4, AC-2.5, AC-2.7, FR-003 をテストで確認できる
  - data パッケージで build_runner（モック再生成）後、`flutter test` が通る
- 依存: T-001

### T-003: `MangaNotifier.moveSceneUnit` を追加
- 対象:
  - `lib/feature/manga/provider/manga_providers.dart`
  - `test/feature/manga/provider/manga_providers_test.dart`
- 内容: Repository への委譲。ページをまたいだ移動もここで受ける
- 完了条件:
  - root で build_runner 後、`flutter analyze` / `flutter test` が通る
- 依存: T-002

### T-004: ページリストからページのドラッグを外し、ページの「︙」メニューを追加 [P]
- 対象:
  - `lib/feature/manga/view/manga_page_list.dart`
  - `lib/feature/manga/view/manga_page_widget.dart`（両レイアウトのツールバー）
- 内容:
  - `ReorderableListView.builder` → `ListView.builder`。右のハンドル用余白（`8.w`）を除く
  - ページごとに `GlobalKey` を持ち、移動後に `Scrollable.ensureVisible` で見える位置へスクロール
  - `MangaPageWidget` にページ数を渡し、「︙」メニュー（前のページへ移動／次のページへ移動／ページを削除）を置く。
    ゴミ箱アイコンを外し、コピーのアイコンは残す
  - 失敗時は SnackBar
  - ウィジェットテスト: 先頭・末尾の無効表示、ゴミ箱アイコンがない
- 完了条件:
  - AC-3.1〜AC-3.7, AC-4.1, AC-4.2 が満たされる
- 依存: なし（T-001〜T-003 と並行可）

### T-005: カットのハンドルと挿入スロットで、同じページ内のドラッグを実装
- 対象: `lib/feature/manga/view/manga_page_widget.dart`（大きくなるならカットのドラッグ部品を `scene_unit_drag.dart` などに切り出す）
- 内容:
  - `_SceneUnitDragData`、ハンドル (`Draggable`)、`_SceneUnitDropSlot` (`DragTarget`) と挿入線
  - スロット位置 → 移動先 index の変換を純粋関数にして単体テスト
  - この時点では同じページ内のスロットだけ受け付ける
- 完了条件:
  - AC-1.1〜AC-1.7 が満たされる（手動確認: テキスト欄内のドラッグで範囲選択になる）
- 依存: T-003, T-004

### T-006: ページをまたぐドロップと最後のカットの確認ダイアログ
- 対象: `lib/feature/manga/view/manga_page_widget.dart`（または T-005 で切り出したファイル）
- 内容:
  - 別のページのスロットも受け付け、`MangaNotifier.moveSceneUnit` を呼ぶ
  - 元ページのカットが 1 つでメモの平文が空でないとき、確認ダイアログ（AC-2.6 の文言）
  - ページが見つからない等の失敗は SnackBar
- 完了条件:
  - AC-2.1, AC-2.3, AC-2.5, AC-2.6 が満たされる（手動確認）
- 依存: T-005

### T-007: ドラッグ中の自動スクロール
- 対象: `lib/feature/manga/view/` に小さなヘルパを追加し、ページリストとカット欄で使う
- 内容: design.md「ドラッグ中の自動スクロール」の通り。ドラッグ終了で必ず止める
- 完了条件:
  - AC-2.2 と US-1 Edge Cases の自動スクロールが満たされる（手動確認）
  - SC-001, SC-002, SC-003 を手動で確認
- 依存: T-005

### T-008: ドキュメントと CHANGELOG
- 対象:
  - `docs/design/data-model.md`（`CloudDelta.pageId` を「現在所属するページ」に）
  - `CHANGELOG.md` の `## [Unreleased]`
  - 本 spec の `Status` を `implemented` に
- 内容: CHANGELOG は利用者の言葉で。
  「追加: カットをドラッグで並べ替え・別のページへ移せる」「変更: 編集画面ではページをドラッグで並べ替えられなくなり、
  ページの『︙』メニューかページ一覧表示で並べ替える。ページの削除も『︙』メニューへ移動」。
  既存の「︙」メニューのカット並べ替えの記述と重複しないよう整理する
- 完了条件:
  - `verify` スキルが通る
- 依存: T-004, T-006, T-007
