#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
LIBDIR="$REPO/Libraries"
TARBALL="$REPO/Libraries.tar.gz"
CACHE_DIR="$REPO/.cache/runtime"
STAGING_DIR="$CACHE_DIR/staging"

WINE_URL="https://github.com/Gcenx/macOS_Wine_builds/releases/download/11.0/wine-stable-11.0-osx64.tar.xz"
DXVK_URL="https://github.com/doitsujin/dxvk/releases/download/v2.7.1/dxvk-2.7.1.tar.gz"
RECENT_THRESHOLD="$(date -v-3d +%s)"

mkdir -p "$LIBDIR"
mkdir -p "$CACHE_DIR"

runtime_complete() {
  [[ -x "$LIBDIR/cabextract" ]] \
    && [[ -f "$LIBDIR/WhiskyWineVersion.plist" ]] \
    && [[ -x "$LIBDIR/Wine/bin/wine64" ]] \
    && [[ -f "$LIBDIR/DXVK/x64/dxgi.dll" ]] \
    && [[ -f "$LIBDIR/DXVK/x32/dxgi.dll" ]]
}

runtime_recent() {
  local required_paths=(
    "$LIBDIR/cabextract"
    "$LIBDIR/WhiskyWineVersion.plist"
    "$LIBDIR/Wine/bin/wine64"
    "$LIBDIR/DXVK/x64/dxgi.dll"
    "$LIBDIR/DXVK/x32/dxgi.dll"
  )
  local path
  for path in "${required_paths[@]}"; do
    if [[ ! -e "$path" ]]; then
      return 1
    fi
    if (( $(stat -f %m "$path") < RECENT_THRESHOLD )); then
      return 1
    fi
  done
  return 0
}

download_archive() {
  local url="$1"
  local filename tmp
  filename="$(basename "$url")"
  tmp="$CACHE_DIR/$filename"

  if [[ -f "$tmp" ]]; then
    echo "Reusing cached $filename" >&2
  else
    echo "Downloading $url" >&2
    curl -L -f "$url" -o "$tmp"
  fi

  printf '%s\n' "$tmp"
}

extract_archive() {
  local archive="$1"
  case "$archive" in
    *.tar.xz) tar -xJf "$archive" -C "$STAGING_DIR" ;;
    *.tar.gz) tar -xzf "$archive" -C "$STAGING_DIR" ;;
    *)
      echo "Unknown archive format: $archive"
      exit 1
      ;;
  esac
}

package_runtime() {
  rm -f "$TARBALL"
  echo "Creating Libraries.tar.gz"
  tar -czf "$TARBALL" -C "$REPO" Libraries
}

if runtime_complete && runtime_recent; then
  echo "Libraries/ is complete and newer than 3 days; keeping cached runtime."
  package_runtime
  exit 0
fi

echo "Refreshing Libraries/ runtime bundle."
rm -rf "$LIBDIR"
mkdir -p "$LIBDIR"
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"

WINE_ARCHIVE="$(download_archive "$WINE_URL")"
DXVK_ARCHIVE="$(download_archive "$DXVK_URL")"

extract_archive "$WINE_ARCHIVE"
extract_archive "$DXVK_ARCHIVE"

CABEXTRACT_BIN="$(command -v cabextract 2>/dev/null || true)"
if [[ -z "$CABEXTRACT_BIN" ]]; then
  cat <<'EOF'
cabextract is required to assemble Libraries.tar.gz.
Install it via Homebrew before running this script:

  brew install cabextract
EOF
  exit 1
fi

WINE_SOURCE="$STAGING_DIR/Wine Stable.app/Contents/Resources/wine"
DXVK_SOURCE="$(find "$STAGING_DIR" -maxdepth 1 -type d -name 'dxvk-*' -print -quit)"

if [[ ! -d "$WINE_SOURCE" ]]; then
  echo "Expected Wine runtime not found in extracted archive."
  exit 1
fi

if [[ -z "$DXVK_SOURCE" || ! -d "$DXVK_SOURCE" ]]; then
  echo "Expected DXVK runtime not found in extracted archive."
  exit 1
fi

mkdir -p "$LIBDIR/Wine" "$LIBDIR/DXVK"
cp -R "$WINE_SOURCE"/. "$LIBDIR/Wine"
cp -R "$DXVK_SOURCE"/. "$LIBDIR/DXVK"
if [[ ! -e "$LIBDIR/Wine/bin/wine64" && -e "$LIBDIR/Wine/bin/wine" ]]; then
  ln -sf wine "$LIBDIR/Wine/bin/wine64"
fi
cp "$CABEXTRACT_BIN" "$LIBDIR/cabextract"
chmod +x "$LIBDIR/cabextract"
cp "$REPO/WhiskyWineVersion.plist" "$LIBDIR/WhiskyWineVersion.plist"
rm -f "$LIBDIR/.DS_Store"

if ! runtime_complete; then
  echo "Libraries/ is missing required runtime files after assembly."
  exit 1
fi

package_runtime
