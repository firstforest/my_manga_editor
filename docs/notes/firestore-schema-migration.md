# Firestore スキーマ移行の仕組み化 — 調査ノート

調査日: 2026-06-11

Firestore のスキーマが変わってもデータ移行が安全に行えるようにするための、
業界ベストプラクティスの調査結果と本リポジトリへの適用案をまとめる。

## 背景

SceneUnit 導入 (`a5af2db`) で `CloudMangaPage` のスキーマが変わった。
このときの移行方式は以下の通り:

- 旧形式: ページドキュメントに `stageDirectionDeltaId` / `dialoguesDeltaId` をトップレベルで保持
- 新形式: `sceneUnits` 配列 (`[{dialoguesDeltaId, stageDirectionDeltaId}]`) で保持
- 読み込み時に旧フィールドを検出して `sceneUnits` に変換する lazy migration
- 書き込みは `sceneUnits` のみ。`set(merge: true)` / `update()` のため旧フィールドは Firestore 上に残り、旧バージョンへのロールバックが可能

この方式は機能したが、「旧フィールドの有無」で版を推測しており、
変更が重なると判定が壊れやすい。今後のスキーマ変更に備えて仕組み化したい。

## ベストプラクティス (調査結果)

### 1. 各ドキュメントに `schemaVersion` フィールドを持たせる

ドキュメント自体に「どの版の形式か」を明示的に記録する。
[Cosmos DB の公式デザインパターン](https://devblogs.microsoft.com/cosmosdb/azure-cosmos-db-design-patterns-part-9-schema-versioning/)
でも同じパターンが推奨されている。

- フィールドがない既存データは **version 1 とみなす規約** にすれば、過去データの一括書き換えは不要
- 書き込みは常に最新版の形式 + 最新の版番号で行う

### 2. 読み込み口を1箇所に集約し、単方向アップグレードチェーンを置く

[Captain Codeman の記事](https://www.captaincodeman.com/schema-versioning-with-google-firestore)
が示す型安全なパターン。`fromFirestore` で版番号による `switch` の
fall-through を使い、v1→v2→v3 と段階的に変換する。

```
fromFirestore(snapshot):
  version = data['schemaVersion'] ?? 1
  if (version < 2) data = _migrateV1ToV2(data)
  if (version < 3) data = _migrateV2ToV3(data)
  return CloudXxx.fromMigrated(data)
```

運用ルール:

- **過去の変換ステップは二度と編集しない。新しいステップを追記するだけ**
- 変換ロジックはモデルごとに1箇所に集約する (本リポジトリでは既に `CloudMangaPageExt.fromFirestore` に集約済み)

### 3. lazy migration + 必要時のみバッチ移行のハイブリッド

[ELCA のゼロダウンタイム移行記事](https://medium.com/elca-it/schema-versioning-and-upgrade-in-document-store-without-service-downtime-d15a2cecd4e9)
や [データバージョニングパターン集](https://bool.dev/blog/detail/data-versioning-patterns) の整理:

- **Upgrade-on-read / Upgrade-on-write (lazy)**: 普段はこれで運用する。デプロイと同期した一括移行が不要
- **Upgrade-by-script (バッチ)**: 古い版の変換コードを削除したくなった時点で、Admin SDK のスクリプトを一括実行して旧版ドキュメントを絶滅させる
- バッチ移行ツールとして [fireway](https://github.com/kevlened/fireway) (Firestore 版 Flyway) がある

### 4. N-1 互換 (expand-contract) ルール

ロールバックと「ブラウザにキャッシュされた旧クライアント」対策として、
破壊的なスキーマ変更は2段階のリリースに分ける:

| 段階 | やること |
|---|---|
| **expand 期** | 新フィールドを追加するが**旧フィールドは削除しない**。書き込みは `set(merge: true)` / `update()` を使い、旧フィールドを物理削除しない。新旧クライアントが共存できる |
| **contract 期** | 旧クライアントが消えた後のリリースで、旧フィールドと変換コードを削除する (必要ならバッチ移行を先に実行) |

SceneUnit 移行は結果的にこの形になっていた。これを明文化されたルールにする。

注意点 (SceneUnit 移行で確認済みの制約):

- 新バージョンで**新規作成**したデータは旧フィールドを持たないため、ロールバック後は空に見える (データ自体は失われない)
- 新バージョンが旧フィールドの参照先ドキュメントを**削除**すると、ロールバック後に壊れた参照になる。expand 期は削除も避けるのが安全

### 5. 移行の回帰テストを CI に組み込む

各スキーマ版の「ゴールデンデータ」(その版のアプリが実際に書く生のドキュメント) を
fixture として保存し、全 fixture が最新モデルに正しく変換されることをテストする。

- 本リポジトリでは `test/data_migration/cloud_manga_page_migration_test.dart` が第一歩
  (fake_cloud_firestore で main 形式のドキュメントを書き、develop のコードで読み書きを検証)
- 「スキーマを変えたら fixture とテストを追加する」を規約化する

### 6. 旧クライアント対策: 最小バージョンゲート (実装済み: 2026-06-28)

Web デプロイ (GitHub Pages) では旧ビルドがブラウザにキャッシュされ残り続ける。
Firestore 上の設定ドキュメント (または Remote Config) に `minSupportedVersion` を置き、
旧クライアントに「リロードしてください」を表示する仕組みがあると、
contract 期に入ってよいかの判断材料になる。

実装方針 (Firestore 設定ドキュメント方式、ハード必須ゲート):

- 配信元は `config/app` ドキュメントの `minSupportedBuildNumber` (Remote Config 依存を増やさない判断)
- 比較対象はビルド番号 (`pubspec.yaml` の `version: x.y.z+N` の N、`package_info_plus` で実行時取得)
- `AppConfigRepository.watchAppConfig` でリアルタイム購読 → `updateRequiredProvider` →
  `lib/router.dart` の redirect で `/update-required` へ。既存の認証ゲートと同じ redirect + refreshListenable パターン
- fail-open: 設定未取得・読み取り失敗時はゲートしない
- 運用手順とセキュリティルールは [docs/design/data-model.md](../design/data-model.md) の「最小バージョンゲート」節を参照

## 本リポジトリへの適用案 (優先度順)

> 2026-06-11: 1〜3 を実装済み。4・5 は未着手 (必要になったら対応)。
> 2026-06-28: 「6. 最小バージョンゲート」を実装済み (下記参照)。5 (バッチ移行) は未着手。

1. **ルールの明文化** — `.claude/rules/data-layer.md` にスキーマ変更チェックリストを、
   `docs/design/data-model.md` にスキーマ版履歴表 (版、変更内容、移行方法、旧フィールド削除予定) を追加する。
   AGENTS.md 経由で AI エージェントにも強制されるため、費用対効果が最大
   - チェックリスト案: `schemaVersion` をインクリメント / 変換ステップを追記 /
     fixture テストを追加 / 旧フィールドは次リリースまで削除禁止 / 版履歴表を更新
2. **`schemaVersion` フィールドの導入** — `CloudManga` / `CloudMangaPage` / `CloudDelta` に追加し、
   `fromFirestore` を版番号ベースのアップグレードチェーンに書き換える
   (現行の lazy migration は v1→v2 変換ステップとして吸収する)
3. **fixture ベースの移行テスト** — 版ごとの生ドキュメント JSON を
   `test/data_migration/fixtures/` に置き、全版→最新の変換をパラメータ化テストで回す
4. **最小バージョンゲート** — 上記 6 の仕組み (任意)
5. **バッチ移行スクリプト** — 必要になったら Admin SDK のスクリプトを `scripts/` に用意し、
   旧版データを絶滅させてから変換コードを削除する (必要になるまで作らない)

## 関連する過去の知見

- デプロイ時の注意: develop 以降は Firebase 接続先が `--dart-define=ENV=prod` で切り替わる
  (デフォルトは dev)。CI には指定済み (`.github/workflows/main.yml`)
- SceneUnit 移行の検証テスト: `test/data_migration/cloud_manga_page_migration_test.dart`

## 参考資料

- [Schema Versioning with Google Firestore | Captain Codeman](https://www.captaincodeman.com/schema-versioning-with-google-firestore)
- [Schema versioning and upgrade in document store without service downtime | ELCA IT](https://medium.com/elca-it/schema-versioning-and-upgrade-in-document-store-without-service-downtime-d15a2cecd4e9)
- [Azure Cosmos DB design patterns – Part 9: Schema versioning](https://devblogs.microsoft.com/cosmosdb/azure-cosmos-db-design-patterns-part-9-schema-versioning/)
- [Data Versioning and Schema Evolution Patterns](https://bool.dev/blog/detail/data-versioning-patterns)
- [fireway — A schema migration tool for Firestore](https://github.com/kevlened/fireway)
- [How to handle Firebase Firestore data migration and schema evolution](https://bootstrapped.app/guide/how-to-handle-firebase-firestore-data-migration-and-schema-evolution)
- [Evolutionary Database Design | Martin Fowler](https://martinfowler.com/articles/evodb.html)
