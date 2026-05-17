# Architecture

My Manga Editor の全体アーキテクチャ概観。
個別領域の詳細は本ドキュメント末尾の [詳細リファレンス](#詳細リファレンス) を参照。

## システム概要

- Flutter 製のデスクトップ / Web 向け漫画プロット編集アプリ
- バックエンドは Firebase (Auth / Firestore)、ローカル DB は持たない
- すべての永続データは Firestore に置き、オフライン永続化キャッシュで動作

## パッケージ構成

マルチパッケージで UI 層とデータ層を物理的に分離する。

```
my_manga_editor/                          (root package: UI 層)
├── lib/
│   ├── main.dart                         エントリポイント
│   ├── router.dart                       go_router 定義
│   ├── env_config.dart                   dev / prod 切り替え
│   ├── feature/                          機能別 UI モジュール
│   ├── hooks/                            カスタム Flutter Hooks
│   └── widgets/                          共通ウィジェット
│
└── local_package/
    ├── my_manga_editor_data/             データ層パッケージ
    │   └── lib/
    │       ├── repository/               Repository（高レベル API）
    │       ├── service/                  Service（Firestore 直接操作）
    │       └── model/                    ドメインモデル
    └── my_manga_editor_common/           共通ユーティリティ（logger 等）
```

UI 層 (`lib/`) はデータ層 (`my_manga_editor_data`) に依存するが、逆方向の依存は持たない。

## レイヤー構造

```
┌────────────────────────────────────────────────────────┐
│  UI            lib/feature/*/page/  view/              │  Widget
│  ─────────────────────────────────────────────────     │
│  State         lib/feature/*/provider/                 │  Riverpod Notifier
│  ─────────────────────────────────────────────────     │
│  Repository    my_manga_editor_data/repository/        │  ドメイン操作
│  ─────────────────────────────────────────────────     │
│  Service       my_manga_editor_data/service/           │  Firestore I/O
│  ─────────────────────────────────────────────────     │
│  Backend       Firebase Auth / Cloud Firestore         │
└────────────────────────────────────────────────────────┘
```

各層の責務：

| 層 | 責務 | 主な型 |
|---|---|---|
| UI | 画面構築、ユーザー入力受付 | `HookConsumerWidget` / `ConsumerWidget` |
| State | UI 向けの状態保持・操作公開 | `@riverpod` Notifier / 関数 Provider |
| Repository | ドメイン操作、モデル変換、リアクティブストリーム | `MangaRepository` / `AuthRepository` / `SettingRepository` / `AiRepository` |
| Service | 3rd party ライブラリのラップ、Firestore CRUD、認証 API 呼び出し、ロック制御 | `FirebaseService` / `AuthService` / `ConnectivityService` / `LockManager` |
| Backend | データ永続化、認証、セキュリティルール | Firestore / Firebase Auth |

データの流れは常にこの順序で上下する。UI → Service の直接呼び出しや、Repository をスキップしての Firestore アクセスは行わない。

### 3rd party ライブラリは Service にラップして DI する

`connectivity_plus` / `cloud_firestore` / `firebase_auth` / `google_sign_in` などの外部パッケージは、
Repository / Provider / UI から直接呼ばず、必ず **Service 層でラップしてから Riverpod Provider 経由で DI** する。

| ラップ対象パッケージ | Service |
|---|---|
| `cloud_firestore` | `FirebaseService` |
| `firebase_auth` / `google_sign_in` | `AuthService` |
| `connectivity_plus` | `ConnectivityService` |

理由：

- **テスト容易性**: Service interface に対する Mock を注入できるため、プラットフォームチャネルやネットワークに依存せずユニットテストが書ける
- **置き換え容易性**: ライブラリのメジャーバージョン更新・他社製品への切り替え時、影響範囲が Service 1 ファイルに閉じる
- **依存方向の明示**: 「3rd party API は Service の中だけに存在する」という単純な不変条件で、層の境界が壊れにくい

新規に 3rd party SDK を導入する場合も、まず `local_package/my_manga_editor_data/lib/service/` に
ラッパー Service と `@Riverpod(keepAlive: true)` Provider を作り、Repository 等はそれを DI で受け取る形にする。

## 機能モジュール

`lib/feature/` 配下に機能ごとのフォルダを切り、内部は `page/ view/ provider/` の3点セットで構成する。

| モジュール | 概要 |
|---|---|
| `auth` | ログイン画面、Google サインイン |
| `manga` | 漫画一覧（カンバン）、編集画面、グリッド表示 |
| `ai_comment` | OpenAI 連携によるプロットへの AI コメント |
| `setting` | アプリ設定画面 |

## 技術スタック

| 領域 | 採用技術 |
|---|---|
| 言語 / SDK | Dart 3.4+ / Flutter 3.32 |
| 状態管理 | Riverpod 3.x (hooks_riverpod) + flutter_hooks |
| 不変モデル | Freezed + json_serializable |
| ルーティング | go_router |
| リッチテキスト | flutter_quill (Delta 形式) |
| 永続化 | Cloud Firestore（オフラインキャッシュ有効） |
| 認証 | Firebase Auth + google_sign_in |
| AI | dart_openai |
| ロギング | logger (`my_manga_editor_common`) |

## ビルド・コード生成

`build_runner` は**2 箇所**で別チェーンとして動く。

```bash
# ルート: lib/ 配下の @riverpod を生成
dart run build_runner build -d

# データ層: Freezed / Riverpod / JsonSerializable を生成
cd local_package/my_manga_editor_data && dart run build_runner build -d
```

`@freezed` / `@riverpod` を含むファイルを変更した場合は対応するパッケージ側で実行する必要がある。詳細は [.claude/rules/data-layer.md](../../.claude/rules/data-layer.md) を参照。

## 環境構成

`--dart-define=ENV=dev|prod` で Firebase プロジェクトと OAuth クライアント ID を切り替える。設定は [lib/env_config.dart](../../lib/env_config.dart) に集約。

## CI/CD

`main` ブランチへの push で GitHub Actions が Flutter Web をビルドし GitHub Pages にデプロイする (`.github/workflows/main.yml`)。

## 詳細リファレンス

レイヤー内部の細かい規約・パターンは以下を参照する。本ドキュメントは概観のみを扱う。

| トピック | 参照先 |
|---|---|
| データモデル詳細（ドメイン / クラウド / Firestore スキーマ） | [docs/design/data-model.md](./data-model.md) |
| データ層の規約（コード生成、Firestore スキーマ、ロック） | [.claude/rules/data-layer.md](../../.claude/rules/data-layer.md) |
| Riverpod Provider の使い分けとテスト方針 | [.claude/rules/providers.md](../../.claude/rules/providers.md) |
| ルーティングと Auth Guard | [.claude/rules/routing.md](../../.claude/rules/routing.md) |
| 開発コマンド全般 | [AGENTS.md](../../AGENTS.md) |
