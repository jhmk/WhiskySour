#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DERIVED_DATA="$REPO_ROOT/DerivedData"

cd "$REPO_ROOT"

xcodebuild -project Whisky.xcodeproj \
  -scheme Whisky \
  -destination 'platform=macOS' \
  -derivedDataPath "$DERIVED_DATA" \
  build

APP_PATH="$(find "$DERIVED_DATA/Build/Products/Debug" -maxdepth 1 -name "*.app" -print -quit)"
if [[ -n "$APP_PATH" && -d "$APP_PATH" ]]; then
  TARGET_APP="$REPO_ROOT/WhiskeySour.app"
  rm -rf "$TARGET_APP"
  cp -R "$APP_PATH" "$TARGET_APP"
  echo "Built WhiskeySour.app in $REPO_ROOT"
  open "$TARGET_APP"
else
  echo "Build succeeded but no .app bundle was found under $DERIVED_DATA/Build/Products/Debug"
  exit 1
fi
