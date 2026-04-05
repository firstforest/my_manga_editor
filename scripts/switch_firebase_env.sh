#!/bin/bash
# Usage: ./scripts/switch_firebase_env.sh [dev|prod]
# Copies the correct Firebase native config files for the specified environment.

set -euo pipefail

ENV="${1:-dev}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
FIREBASE_DIR="$PROJECT_DIR/firebase/$ENV"

if [ ! -d "$FIREBASE_DIR" ]; then
  echo "Error: firebase/$ENV directory not found"
  exit 1
fi

# Android
if [ -f "$FIREBASE_DIR/google-services.json" ]; then
  cp "$FIREBASE_DIR/google-services.json" "$PROJECT_DIR/android/app/google-services.json"
  echo "Copied google-services.json for $ENV"
fi

# iOS
if [ -f "$FIREBASE_DIR/GoogleService-Info.plist" ] && [ -s "$FIREBASE_DIR/GoogleService-Info.plist" ]; then
  cp "$FIREBASE_DIR/GoogleService-Info.plist" "$PROJECT_DIR/ios/Runner/GoogleService-Info.plist"
  echo "Copied GoogleService-Info.plist for $ENV"
fi

echo "Firebase environment switched to: $ENV"
