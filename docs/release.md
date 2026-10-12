# リリース運用ガイド

本番 (prod) への安全なリリース手順・バックアップ・ロールバックをまとめる。

## 全体像

| 対象 | デプロイ方法 | ロールバック方法 |
|---|---|---|
| Web アプリ | `main` への push → GitHub Actions → Cloudflare Workers | 直前のデプロイへ即時に戻す (`mise run rollback-web-now`) / 過去タグから再デプロイ (`mise run rollback-web`) |
| Web プレビュー | PR / `develop` への push → GitHub Actions → プレビュー用 Worker (dev Firebase) | 不要 (本番に影響しない) |
| Firestore セキュリティルール | `mise run deploy-rules-prod` (手動) | 過去タグの `firestore.rules` を再デプロイ |
| Firestore データ | アプリが書き込む | バックアップから復元 (`mise run restore-prod`) |
| `config/app` 設定 | `mise run config-set-prod` | 同コマンドで前の値に戻す |
| 変更履歴の公開 | [CHANGELOG.md](../CHANGELOG.md) → GitHub Release (タグの push で `release.yml` が自動作成) | Release を編集・削除 |
| 利用者への事前告知 | `mise run notice-prod "..."` (アプリ内バナー。デプロイ不要で即時) | `mise run notice-clear-prod` |

GitHub Actions は 4 つに分かれている ([.claude/rules/ci.md](../.claude/rules/ci.md) 参照)。

| workflow | いつ動くか | 役割 |
|---|---|---|
| `ci.yml` | PR / `develop` への push | analyze・test・Web ビルドの確認。**リリース前の品質ゲート** |
| `preview.yml` | PR / `develop` への push | dev Firebase でビルドしてプレビュー URL に公開 (下記「プレビュー」参照) |
| `main.yml` | `main` への push | 本番ビルド → Cloudflare Workers へデプロイ → 公開ページの疎通確認 |
| `release.yml` | `v*` タグの push | GitHub Release の作成（CHANGELOG の変更点 + リリース後の手動作業チェックリスト） |

- 作業ブランチは `develop`、リリースブランチは `main`。`main` に push されると
  [.github/workflows/main.yml](../.github/workflows/main.yml) が `--dart-define=ENV=prod` で
  Flutter Web をビルドし Cloudflare Workers の本番 Worker (`my-manga-editor`) へデプロイする。
  本番 URL はリポジトリ変数 `PRODUCTION_URL` に登録してある (`gh variable get PRODUCTION_URL`)
- リリースごとに `pubspec.yaml` の `version: x.y.z+N` の **ビルド番号 N を必ず +1** する
  (旧ビルドがブラウザにキャッシュされ続けるため。[.claude/rules/ci.md](../.claude/rules/ci.md) 参照)
- リリースごとに `v<x.y.z+N>` 形式のタグを打つ。**タグがロールバックの単位**になる
- リリースごとに [CHANGELOG.md](../CHANGELOG.md) の `## [Unreleased]` に利用者向けの変更点を書く。
  空のままではリリースできない (下記「リリースノートを書く」参照)

## リリースノートを書く

利用者がいる以上、**何がどう変わったかを伝えるところまでがリリース**。

作業中、利用者から見て何かが変わる変更を入れたら、その場で
[CHANGELOG.md](../CHANGELOG.md) の `## [Unreleased]` に 1 行足しておく
(リリース直前にまとめて書こうとすると、必ず何か漏れる)。

- **利用者の言葉で書く。** コミットメッセージの流用は禁止。
  「SceneUnit を1つのスクロール領域に変更」ではなく「ページ一覧でセリフが全部見えるようになりました」
- **利用者から見て何も変わらない変更は書かない** (リファクタリング・テスト・CI・ドキュメント)
- **データが消える・移行される変更は影響を必ず書く。** 一番の信頼喪失は「勝手に消えた」

`mise run release` は `[Unreleased]` の中身を

1. 確認プロンプトの前にプレビュー表示し (`--dry-run` でも確認できる)
2. 空なら **リリースを中断し**
3. `## [x.y.z+N] - YYYY-MM-DD` の見出しに確定してコミットする

その後、タグの push を受けた [release.yml](../.github/workflows/release.yml) が
タグ時点の CHANGELOG からそのバージョンのセクションを読み、GitHub Release のノート先頭に載せる。

> **GitHub Release を作るのは `release.yml` だけ**。`release.sh` 側でも `gh release create` すると
> 二重作成になり、先に勝ったほうしか残らない (= workflow が付ける「リリース後の手動チェック」が
> 失われる)。リリース手順を触るときはこの分担を崩さないこと。

緊急のホットフィックスなどで飛ばしたい場合のみ `--skip-changelog` を付ける (非推奨。
Release のノートが変更点なしになる)。

## 通常リリース手順

```bash
mise run release              # patch リリース (x.y.z の z を +1、N を +1)
mise run release minor        # minor リリース
mise run release major        # major リリース
mise run release --dry-run    # 何が起こるかの確認だけ
```

[scripts/release.sh](../scripts/release.sh) が以下を自動で行う。途中で失敗したら push まで到達しない
(push が最後の不可逆ポイント)。

1. **前提チェック** — `develop` ブランチ / クリーンな作業ツリー / `origin/develop` と同期済み /
   `origin/main` のコミットがすべて `develop` に取り込み済み
2. **確認** — リリース内容 (`origin/main..develop` のコミット一覧)、リリースノート
   (CHANGELOG の `[Unreleased]`)、新バージョンを表示して y/N。ノートが空ならここで中断
3. **品質ゲート** — `flutter analyze` && `flutter test`
   (ルートと `local_package/` 配下の各パッケージ。`mise run check` と同内容)
4. **prod バックアップ** — `scripts/firestore_backup.mjs prod` で Firestore 全データを
   `backups/prod-<日時>/` にダンプ (git 管理外)。ロールバック時の保険
5. **バージョン更新** — `pubspec.yaml` と `CHANGELOG.md` を書き換えて `chore(release): v...` をコミット
6. **タグ付け・マージ・push** — `v<x.y.z+N>` タグ → `main` へマージ → `develop` / `main` / タグを push

push 後は 2 つの workflow が走る。`main` への push で `main.yml` がデプロイし、
タグの push で `release.yml` が GitHub Release を作る。
デプロイ完了を待って本番 URL で動作確認する:

```bash
gh run watch          # デプロイの進行状況を追う
```

### リリース前チェックリスト

- [ ] `develop` の CI (`ci.yml`) が緑か (`gh run list --branch develop --limit 1`)
- [ ] **ロールバック先のタグが存在するか** (`git tag -l 'v*'`)。
      タグが 1 つも無い状態では `mise run rollback-web` が使えないため、
      最初のリリース前に現在の `main` にタグを打っておく:
      `git tag v1.0.0+1 origin/main && git push origin v1.0.0+1`
- [ ] `develop` のプレビュー (固定 URL) で動作確認済みか (dev Firebase に接続している)
- [ ] [CHANGELOG.md](../CHANGELOG.md) の `[Unreleased]` に利用者向けの変更点が書けているか
- [ ] スキーマ変更を含む場合、[.claude/rules/data-layer.md](../.claude/rules/data-layer.md) の
      expand-contract ルールに従っているか (旧フィールドの削除は次リリース以降)
- [ ] 移行 fixture テストを追加したか (`test/data_migration/`)
- [ ] 利用者に影響の大きい変更なら、事前告知を済ませたか (下記「利用者への影響が大きい変更」参照)
- [ ] `firestore.rules` を変更している場合、**アプリより先に**
      `mise run deploy-rules-prod` を実行したか (下記「セキュリティルールとアプリの順序」参照)

### セキュリティルールとアプリの順序

`firestore.rules` の変更は Web デプロイと連動しない。`mise run deploy-rules-prod` を
実行するまで本番には反映されないので、**ルールの緩和はアプリより先にデプロイする**
(逆順だと、新しいアプリが読めないはずのものを読もうとして失敗する)。

たとえばアプリ内お知らせと更新ゲートは、ログイン前の利用者に届けるために
`config/app` の未認証読み取りに依存している。ルール未デプロイのままアプリだけ出すと、
未ログイン時の `watchAppConfig` が permission-denied になり、
**ログイン前のバナーとゲートが黙って出なくなる**
(fail-open なので既存ユーザーの操作は壊れないが、告知は届かない)。

ルールの**厳格化**は逆で、アプリを先に出してからルールを締める。
どちらも「新旧クライアントが同時に存在しても壊れない順序」を選ぶ。

### 利用者への影響が大きい変更

以下のいずれかに当てはまるリリースは、**先に告知してから**出す。

- 保存済みのデータが移行される / 表示されなくなる / 消える
- 使っていた機能がなくなる
- URL が変わる (ブックマークが切れる)
- 最小バージョンゲートを引き上げる (旧クライアントを締め出す)

告知は**アプリ内**で行う。利用者はアプリを開いているのであって、
GitHub や X を見ているとは限らない。届かない場所に書いても告知したことにならない。

1. リリースの数日前に、お知らせを出す。全利用者の画面上部にバナーが出る:

   ```bash
   mise run notice-prod "8/10 20時ごろに更新します。ページに挿入した画像は表示されなくなります"
   ```

   `config/app` を書き換えるだけなので**アプリのデプロイは不要**。
   Firestore の stream で購読しているため、いま開いている画面にもその場で届く
2. データに触る変更なら、告知の時点で `mise run backup-prod` を取っておく
3. リリース後、告知を取り下げる:

   ```bash
   mise run notice-clear-prod
   ```

お知らせの挙動:

- 本文は 150 文字まで。バナーの高さは編集画面を潰さない範囲に抑えてあり、
  収まらない分はバナー内をスクロールして読む (切り捨てはしない)
- 利用者が「閉じる」を押すと、そのお知らせは端末に記録され再表示されない
- `mise run notice-prod` を出し直すと識別子が変わるので、閉じた利用者にも改めて表示される
- いま何が出ているかは `mise run config-get-prod` の `noticeMessage` で確認できる
- 取り下げを忘れると出っぱなしになる。リリース後の手順に必ず含めること
- ログイン前の画面にも出る (`config/app` は未認証でも読める)。
  ログインできない障害の告知にも使える

**リリースする時間帯**にも注意する。Web 版は `main` に push した瞬間に全員へ配られ、
利用者が編集している最中でも切り替わる。特に `minSupportedBuildNumber` を上げると、
**開きっぱなしのタブがその場で「更新が必要です」画面に切り替わる**
(`appConfig` を Firestore の stream で購読しているため)。
編集中の内容が失われうるので、締め出しは本当に必要なときだけにし、
利用者が使っていなさそうな時間帯に行う。

### リリース後 (破壊的スキーマ変更を含む場合のみ)

旧クライアントを締め出す必要があるリリースでは、デプロイ完了・動作確認の後に
最小バージョンゲートを引き上げる ([docs/design/data-model.md](design/data-model.md) の「最小バージョンゲート」参照):

```bash
mise run config-set-prod minSupportedBuildNumber <このリリースの N>
```

後方互換なリリースでは何もしなくてよい。

### Firestore ルールの変更を含む場合

ルールのデプロイは Web デプロイと連動していない。リリース手順の一部として手動で行う:

```bash
mise run deploy-rules-prod
```

順序の原則: **ルールを緩める変更はアプリより先に、締める変更はアプリより後に**デプロイする
(新旧どちらのクライアントも動く状態を保つ)。

## プレビュー

PR を作るか `develop` に push すると、[preview.yml](../.github/workflows/preview.yml) が
dev Firebase に繋いだ Web ビルドをプレビュー用 Worker (`my-manga-editor-preview`) に公開する。
本番 Worker とは別物なので、プレビューが本番の利用者やデータに影響することはない。

| きっかけ | URL | 使いどころ |
|---|---|---|
| PR (push のたびに更新) | `https://pr-<番号>-my-manga-editor-preview.<subdomain>.workers.dev` (PR にコメントされる) | 変更ごとの見た目・動作の確認 |
| `develop` への push | `https://my-manga-editor-preview.<subdomain>.workers.dev` | リリース前の確認。Google ログインも使える |

- **PR の URL では Google ログインが使えない**。Firebase Auth の承認済みドメインは
  ワイルドカード指定ができず、PR ごとの URL は登録していないため。匿名ログインで確認する
- 動作確認で作ったデータは dev Firebase に入る
- PR が閉じても URL は残る (エイリアスは Cloudflare 側で直近 1000 件まで保持され、古いものから消える)
- フォークからの PR と Dependabot の PR では secrets が使えないため、プレビューは作られない

## Cloudflare の初期設定

最初に 1 回だけ行う。

1. Cloudflare の API トークンを作り (テンプレート「Edit Cloudflare Workers」)、GitHub に登録する:
   ```bash
   gh secret set CLOUDFLARE_API_TOKEN
   gh secret set CLOUDFLARE_ACCOUNT_ID
   ```
2. プレビュー用 Worker を作る。PR のプレビューは Worker が存在しないと作れないので、
   ローカルから 1 回デプロイしておく (以降は `develop` への push で更新される):
   ```bash
   npx wrangler login
   flutter build web --release --dart-define=ENV=dev --base-href /
   npx wrangler deploy --env preview
   ```
3. 本番 URL を登録する。URL は `https://my-manga-editor.<subdomain>.workers.dev/`
   (`<subdomain>` は Cloudflare ダッシュボードの Workers & Pages で確認できる)。末尾の `/` まで含める:
   ```bash
   gh variable set PRODUCTION_URL --body 'https://my-manga-editor.<subdomain>.workers.dev/'
   ```
4. Firebase Auth の承認済みドメインに追加する (Google ログインのため)。
   Firebase コンソール → Authentication → 設定 → 承認済みドメイン
   - prod (`my-manga-editor`): `my-manga-editor.<subdomain>.workers.dev`
   - dev (`my-manga-editor-dev`): `my-manga-editor-preview.<subdomain>.workers.dev`
5. Google Cloud コンソールの OAuth クライアント (Web) の「承認済みの JavaScript 生成元」に
   同じドメインを追加する

## Firestore バックアップ

```bash
mise run backup-prod          # prod → backups/prod-<日時>/
mise run backup               # dev  → backups/dev-<日時>/
```

- 認証は ADC。初回は `gcloud auth application-default login` を実行しておく
- 出力は 1 行 1 ドキュメントの `firestore.jsonl` + `meta.json`。Firestore REST の typed value を
  そのまま保存するため無劣化で復元できる
- `backups/` は **git 管理外** (ユーザーデータを含むためコミット禁止)。ローカルディスクにしか
  残らないので、長期保管したい場合は別の場所へコピーすること
- リリース時は `mise run release` が自動でバックアップを取るが、スキーマ移行の実験前など
  リスクのある作業の前には手動でも取っておく

## ロールバック

### 1. Web アプリを前のバージョンに戻す (最速の応急処置)

直前のデプロイに戻すだけなら、Cloudflare に残っている前のバージョンへ切り替える。
ビルドしないので数秒で終わる:

```bash
mise run rollback-web-now              # = npx wrangler rollback (確認プロンプトあり)
```

`npx wrangler login` を対話ターミナルで済ませておくこと。
戻し先を選びたい場合は `npx wrangler deployments list` で一覧を見て
`npx wrangler rollback <version-id>` を使う (デプロイのメッセージに `main@<コミット>` が入っている)。

2 つ以上前のリリースに戻したい・Cloudflare 側の履歴に頼れない場合は、タグから再ビルドする:

```bash
git tag -l 'v*'                        # 戻せるタグを確認
mise run rollback-web v1.0.1+2         # そのタグの時点のコードで再デプロイ
gh run watch                           # デプロイ完了を待つ
```

仕組み: GitHub Actions の `workflow_dispatch` をタグ ref で起動し、そのタグの時点のコードを
ビルド・デプロイする。`production` environment に deployment branch policy を付けると
タグ ref からのデプロイが止まるので、付ける場合は `v*` タグも許可すること。

注意点:

- **`main` ブランチは壊れたまま**。応急処置の後、`develop` で revert または修正をコミットし、
  通常リリース (`mise run release`) で恒久対応すること。恒久対応の前に誤って `main` に push すると
  壊れたコードが再デプロイされる
- ロールバック先のビルド番号が `config/app.minSupportedBuildNumber` 未満だと、戻した途端に
  全ユーザーが「更新してください」画面で締め出される。その場合は先にゲートを下げる:
  ```bash
  mise run config-get-prod                                      # 現在値の確認
  mise run config-set-prod minSupportedBuildNumber <戻す先の N>
  ```

### 2. Firestore ルールを戻す

```bash
git stash                              # 作業中の変更があれば退避
git checkout v1.0.1+2 -- firestore.rules
mise run deploy-rules-prod
git checkout develop -- firestore.rules   # 作業ツリーを元に戻す
git stash pop                          # 退避していた場合
```

### 3. Firestore データを戻す

```bash
# 全体を戻す (バックアップに含まれる全ドキュメントを上書き)
mise run restore-prod backups/prod-20260706-120000

# 特定ユーザー・特定作品だけ戻す (部分復元)
mise run restore-prod backups/prod-20260706-120000 --only users/<uid>
mise run restore-prod backups/prod-20260706-120000 --only users/<uid>/mangas/<mangaId>
```

復元の性質 ([scripts/firestore_restore.mjs](../scripts/firestore_restore.mjs)):

- バックアップに含まれるドキュメントの**上書き復元**。バックアップ後に新規作成された
  ドキュメントは削除されない (完全なポイントインタイム復元ではない)
- 上書きなので実行前に必ず現状のバックアップも取る (`mise run backup-prod`)。
  「復元が間違いだった」場合に戻せるようにするため
- 実行時に対象件数を表示して y/N の確認を挟む

### 症状別の初動

| 症状 | 初動 |
|---|---|
| 新バージョンで画面が壊れた・起動しない | `mise run rollback-web <前のタグ>` |
| permission-denied が多発 | 直前にルールを変えたなら「2. ルールを戻す」 |
| データが壊れた・消えた | まず `mise run backup-prod` で現状保全 → 「3. データを戻す」 |
| 旧クライアントが不正なデータを書いている | `minSupportedBuildNumber` を上げて締め出す |

## 制約と今後の改善候補

- バックアップはローカル保存のみで、リリース時以外は自動化されていない。
  Blaze プランに上げる場合は gcloud のマネージドエクスポート
  (`gcloud firestore export gs://...`) と PITR (ポイントインタイムリカバリ) が使える
- データ復元は「上書き復元」であり、バックアップ後に作られたドキュメントの削除はしない
  (安全側に倒した仕様。完全復元が必要になったら削除モードを追加する)
