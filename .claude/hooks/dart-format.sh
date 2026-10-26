#!/usr/bin/env bash
# PostToolUse hook: Claude が編集した .dart ファイルを dart format する。
# 生成ファイルは build_runner の出力をそのまま保つため対象外。
set -u

file_path=$(jq -r '.tool_input.file_path // empty')

case "$file_path" in
  *.g.dart | *.freezed.dart | *.mocks.dart) exit 0 ;;
  *.dart) ;;
  *) exit 0 ;;
esac

[ -f "$file_path" ] || exit 0

dart format "$file_path" >/dev/null 2>&1 || true
exit 0
