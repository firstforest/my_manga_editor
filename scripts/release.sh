#!/bin/bash
# 本番リリーススクリプト。手順の詳細は docs/release.md を参照。
#
# Usage: ./scripts/release.sh [patch|minor|major] [--dry-run] [--skip-backup] [--skip-checks]
#   (mise タスク: `mise run release`, `mise run release minor` など)
#
# やること (この順):
#   1. 前提チェック: develop ブランチ / クリーンな作業ツリー / origin と同期済み
#   2. リリース内容 (origin/main..develop) と新バージョンを表示して確認プロンプト
#   3. flutter analyze && flutter test
#   4. prod Firestore のバックアップ (scripts/firestore_backup.mjs → backups/)
#   5. pubspec.yaml のバージョンを更新してコミット (ビルド番号は必ず +1)
#   6. タグ付け → main へマージ → push (main への push で GitHub Pages に自動デプロイ)
#
# --dry-run     何も変更せず、実行される内容だけ表示する
# --skip-backup prod バックアップを飛ばす (ADC 未設定の環境など。非推奨)
# --skip-checks analyze / test を飛ばす (緊急時のみ。非推奨)
#
# ロールバック手順は docs/release.md の「ロールバック」節を参照。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$(dirname "$SCRIPT_DIR")"

BUMP="patch"
DRY_RUN=false
SKIP_BACKUP=false
SKIP_CHECKS=false
for arg in "$@"; do
  case "$arg" in
    patch|minor|major) BUMP="$arg" ;;
    --dry-run) DRY_RUN=true ;;
    --skip-backup) SKIP_BACKUP=true ;;
    --skip-checks) SKIP_CHECKS=true ;;
    *) echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

step() { echo; echo "==> $1"; }
die() { echo "Error: $1" >&2; exit 1; }

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
  step "flutter analyze"
  flutter analyze
  step "flutter test"
  flutter test
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

step "完了"
echo "デプロイの進行状況: gh run watch  (または GitHub Actions のページ)"
echo
echo "次のアクション:"
echo "  - デプロイ完了後、本番 URL で動作確認する"
echo "  - 破壊的スキーマ変更を含む場合のみ:"
echo "      mise run config-set-prod minSupportedBuildNumber ${NEW_BUILD}"
echo "  - 問題があった場合のロールバック: docs/release.md の「ロールバック」節"
