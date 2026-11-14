# Tasks: アイデアメモの画像

## 前提
- Requirements: [requirements.md](./requirements.md)
- Design: [design.md](./design.md)
- 関連コード生成: root と data の両方で `dart run build_runner build -d`

## タスク一覧

### T-001: Storage サービスと Repository
- 対象: `local_package/my_manga_editor_data/lib/service/firebase/memo_image_storage_service.dart`,
  `lib/repository/memo_image_repository.dart`, `lib/repository/exceptions.dart`
- 完了条件: `memo_image_repository_test.dart` が通る
- 依存: なし
- [x] 完了

### T-002: セキュリティルール
- 対象: `storage.rules`, `firebase.json`, `mise.toml` の `deploy-rules*`, `release.yml` の変更検知
- 依存: なし
- [x] 完了

### T-003: アイデアメモの UI
- 対象: `lib/feature/manga/view/workspace.dart`, `memo_image_embed.dart`, `lib/hooks/quill_controller_hook.dart`
- 完了条件: AC-1.1〜1.5, AC-3.1
- 依存: T-001
- [x] 完了

### T-004: カードのプレビューと作品削除
- 対象: `kanban_card.dart`, `manga_providers.dart` (`MangaNotifier.delete`)
- 完了条件: AC-1.6, AC-2.1, AC-2.2
- 依存: T-001
- [x] 完了

### T-005: 環境の準備 (手作業)
- [ ] dev / prod の Firebase プロジェクトを Blaze プランにし、Cloud Storage のバケットを作る
- [ ] `mise run deploy-rules` / `mise run deploy-rules-prod` で `storage.rules` をデプロイする
- [ ] リリース後、`minSupportedBuildNumber` をこのリリースのビルド番号に上げる
