#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DERIVED_DATA="$REPO_ROOT/DerivedData"
LIBRARIES_DIR="$REPO_ROOT/Libraries"
LIBRARIES_TARBALL="$REPO_ROOT/Libraries.tar.gz"
MODULE_CACHE_PATH="${CLANG_MODULE_CACHE_PATH:-/tmp/clang-cache}"
mkdir -p "$MODULE_CACHE_PATH"
export CLANG_MODULE_CACHE_PATH="$MODULE_CACHE_PATH"

cd "$REPO_ROOT"

xcodebuild -project Whisky.xcodeproj \
  -scheme Whisky \
  -destination 'platform=macOS' \
  -derivedDataPath "$DERIVED_DATA" \
  CLANG_MODULE_CACHE_PATH="$CLANG_MODULE_CACHE_PATH" \
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

if [[ ! -f "$LIBRARIES_TARBALL" ]]; then
  if [[ -d "$LIBRARIES_DIR" && $(find "$LIBRARIES_DIR" -mindepth 1 -print -quit) ]]; then
    echo "Packaging Libraries/ into Libraries.tar.gz"
    tar -czf "$LIBRARIES_TARBALL" -C "$REPO_ROOT" Libraries
  else
    echo "Libraries/ is empty; please populate it before packaging."
  fi
fi
