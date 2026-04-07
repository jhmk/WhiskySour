#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DERIVED_DATA="/tmp/WhiskySourDerivedData"

cd "$REPO_ROOT"

xcodebuild -project Whisky.xcodeproj \
  -scheme Whisky \
  -destination 'platform=macOS' \
  -derivedDataPath "$DERIVED_DATA" \
  build

APP_PATH="$DERIVED_DATA/Build/Products/Debug/Whisky.app"
if [[ -d "$APP_PATH" ]]; then
  echo "Launching Whisky.app to trigger the runtime download..."
  open "$APP_PATH"
else
  echo "Build succeeded but $APP_PATH is missing"
  exit 1
fi
