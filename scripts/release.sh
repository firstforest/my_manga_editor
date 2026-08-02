#!/bin/bash
# 本番リリーススクリプト。手順の詳細は docs/release.md を参照。
#
# Usage: ./scripts/release.sh [patch|minor|major] [--dry-run] [--skip-backup] [--skip-checks]
#                             [--skip-changelog]
#   (mise タスク: `mise run release`, `mise run release minor` など)
#
# やること (この順):
#   1. 前提チェック: develop ブランチ / クリーンな作業ツリー / origin と同期済み
#   2. リリース内容 (origin/main..develop)・新バージョン・リリースノートを表示して確認プロンプト
#   3. flutter analyze && flutter test (ルート + local_package/my_manga_editor_data)
#   4. prod Firestore のバックアップ (scripts/firestore_backup.mjs → backups/)
#   5. pubspec.yaml のバージョンと CHANGELOG.md を更新してコミット (ビルド番号は必ず +1)
#   6. タグ付け → main へマージ → push (main への push で GitHub Pages に自動デプロイ)
#
# リリースノートは CHANGELOG.md の `## [Unreleased]` セクションから取る。
# 空のままではリリースできない (利用者に何が変わったか伝わらないため)。
#
# GitHub Release の作成は .github/workflows/release.yml が行う (v* タグの push で起動し、
# タグ時点の CHANGELOG.md とリリース後チェックリストを合わせてノートにする)。
# ここで `gh release create` してはいけない。二重作成になり、
# workflow 側が付けるチェックリスト (rules の手動デプロイ督促など) が失われる。
#
# --dry-run        何も変更せず、実行される内容だけ表示する
# --skip-backup    prod バックアップを飛ばす (ADC 未設定の環境など。非推奨)
# --skip-checks    analyze / test を飛ばす (緊急時のみ。非推奨)
# --skip-changelog CHANGELOG の確認・更新を飛ばす (緊急時のみ。非推奨。
#                  workflow が作る Release ノートが変更点なしになる)
#
# ロールバック手順は docs/release.md の「ロールバック」節を参照。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$(dirname "$SCRIPT_DIR")"

BUMP="patch"
DRY_RUN=false
SKIP_BACKUP=false
SKIP_CHECKS=false
SKIP_CHANGELOG=false
for arg in "$@"; do
  case "$arg" in
    patch|minor|major) BUMP="$arg" ;;
    --dry-run) DRY_RUN=true ;;
    --skip-backup) SKIP_BACKUP=true ;;
    --skip-checks) SKIP_CHECKS=true ;;
    --skip-changelog) SKIP_CHANGELOG=true ;;
    *) echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

step() { echo; echo "==> $1"; }
die() { echo "Error: $1" >&2; exit 1; }

# CHANGELOG.md の `## [Unreleased]` セクション本文を取り出す (前後の空行は落とす)。
# 出力がそのまま GitHub Release のノートになる。
changelog_unreleased() {
  awk '
    /^## \[Unreleased\]/ { inside = 1; next }   # ここから
    inside && /^## \[/   { exit }               # 次のバージョン見出しで終わり
    inside && NF {
      if (started) while (pending-- > 0) print ""  # 段落間の空行は保留してから出す
      pending = 0
      started = 1
      print
      next
    }
    inside { pending++ }                        # 先頭と末尾の空行は捨てられる
  ' CHANGELOG.md
}

# --- 1. 前提チェック --------------------------------------------------------

step "前提チェック"

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
[ "$BRANCH" = "develop" ] || die "develop ブランチから実行してください (現在: $BRANCH)"

[ -z "$(git status --porcelain)" ] || die "作業ツリーに未コミットの変更があります"

git fetch origin main develop --tags

[ "$(git rev-parse develop)" = "$(git rev-parse origin/develop)" ] \
  || die "develop が origin/develop と一致しません (push または pull してください)"

git merge-base --is-ancestor origin/main develop \
  || die "origin/main に develop に無いコミットがあります (先に develop へ取り込んでください)"

if ! $SKIP_CHANGELOG; then
  [ -f CHANGELOG.md ] || die "CHANGELOG.md がありません"
fi

# --- 2. バージョン計算とリリース内容の確認 ----------------------------------

CURRENT="$(grep -E '^version:' pubspec.yaml | sed -E 's/^version:[[:space:]]*//')"
SEMVER="${CURRENT%+*}"
BUILD="${CURRENT#*+}"
[ "$CURRENT" != "$SEMVER" ] && [ "$BUILD" -ge 0 ] 2>/dev/null \
  || die "pubspec.yaml の version を解釈できません: $CURRENT (x.y.z+N 形式が必要)"

IFS='.' read -r MAJOR MINOR PATCH <<< "$SEMVER"
case "$BUMP" in
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  patch) PATCH=$((PATCH + 1)) ;;
esac
NEW_BUILD=$((BUILD + 1))
NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}+${NEW_BUILD}"
TAG="v${NEW_VERSION}"

git rev-parse -q --verify "refs/tags/$TAG" > /dev/null && die "タグ $TAG は既に存在します"

step "リリース内容 (origin/main..develop)"
if [ -z "$(git log --oneline origin/main..develop)" ]; then
  die "origin/main..develop に差分がありません (リリースするものが無い)"
fi
git log --oneline origin/main..develop

if $SKIP_CHANGELOG; then
  echo
  echo "(--skip-changelog: CHANGELOG は更新しません。Release ノートに変更点が載りません)"
else
  RELEASE_NOTES="$(changelog_unreleased)"
  [ -n "$RELEASE_NOTES" ] || die \
    "CHANGELOG.md の [Unreleased] が空です。利用者から見て何が変わったかを書いてください"
  step "リリースノート (CHANGELOG.md の [Unreleased] → release.yml が Release に載せる)"
  printf '%s\n' "$RELEASE_NOTES"
fi

echo
echo "  バージョン: ${CURRENT} -> ${NEW_VERSION}"
echo "  タグ:       ${TAG}"
echo "  デプロイ先: prod (GitHub Pages, main への push で自動)"

if $DRY_RUN; then
  echo
  echo "(--dry-run: ここで終了。変更は行いません)"
  exit 0
fi

printf '\nprod へリリースします。よろしいですか? [y/N] '
read -r ANSWER
case "$ANSWER" in
  y|Y|yes) ;;
  *) echo "Aborted."; exit 1 ;;
esac

# --- 3. 静的解析とテスト -----------------------------------------------------

if $SKIP_CHECKS; then
  echo "(--skip-checks: analyze / test を飛ばします)"
else
  # analyze / test はカレントパッケージのみが対象なので、データ層パッケージも個別に流す
  # (CI の .github/workflows/ci.yml と同じ内容)
  step "flutter analyze"
  flutter analyze
  (cd local_package/my_manga_editor_data && flutter analyze)
  step "flutter test"
  flutter test
  (cd local_package/my_manga_editor_data && flutter test)
fi

# --- 4. prod Firestore バックアップ ------------------------------------------

if $SKIP_BACKUP; then
  echo "(--skip-backup: prod バックアップを飛ばします)"
else
  step "prod Firestore バックアップ"
  node scripts/firestore_backup.mjs prod
fi

# --- 5. バージョン更新コミット ------------------------------------------------

step "pubspec.yaml を ${NEW_VERSION} へ更新"
sed -i '' -E "s/^version:[[:space:]]*.*/version: ${NEW_VERSION}/" pubspec.yaml
git add pubspec.yaml

if ! $SKIP_CHANGELOG; then
  step "CHANGELOG.md の [Unreleased] を ${NEW_VERSION} として確定"
  # [Unreleased] の中身をそのまま新バージョンの見出しの下に残し、空の [Unreleased] を上に作る
  awk -v ver="$NEW_VERSION" -v today="$(date +%Y-%m-%d)" '
    !bumped && /^## \[Unreleased\]/ {
      print "## [Unreleased]"
      print ""
      print "## [" ver "] - " today
      bumped = 1
      next
    }
    { print }
  ' CHANGELOG.md > CHANGELOG.md.tmp && mv CHANGELOG.md.tmp CHANGELOG.md
  git add CHANGELOG.md
fi

git commit -m "chore(release): ${TAG}"

# --- 6. タグ付け・main へマージ・push ----------------------------------------

step "タグ付けと main へのマージ"
git tag "$TAG"
git checkout main
git merge --ff-only origin/main
git merge --no-edit develop

step "push (main への push で本番デプロイが走ります)"
git push origin develop main "refs/tags/${TAG}"
git checkout develop

# GitHub Release はタグの push を受けて .github/workflows/release.yml が作成する。
# ここで作ると二重作成になるので何もしない (ヘッダのコメント参照)。

step "完了"
echo "デプロイの進行状況: gh run watch  (または GitHub Actions のページ)"
echo "GitHub Release は release.yml がタグの push を受けて作成します"
echo
echo "次のアクション:"
echo "  - デプロイ完了後、本番 URL で動作確認する"
echo "  - 破壊的スキーマ変更を含む場合のみ:"
echo "      mise run config-set-prod minSupportedBuildNumber ${NEW_BUILD}"
echo "  - 問題があった場合のロールバック: docs/release.md の「ロールバック」節"
