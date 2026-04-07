#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
LIBDIR="$REPO/Libraries"
TARBALL="$REPO/Libraries.tar.gz"
CACHE_DIR="$REPO/.cache/runtime"

WINE_URL="https://github.com/Gcenx/macOS_Wine_builds/releases/download/11.0/wine-stable-11.0-osx64.tar.xz"
DXVK_URL="https://github.com/doitsujin/dxvk/releases/download/v2.7.1/dxvk-2.7.1.tar.gz"
NUM_CORES="$(sysctl -n hw.ncpu 2>/dev/null || echo 4)"

mkdir -p "$LIBDIR"
mkdir -p "$CACHE_DIR"

rm -rf "$LIBDIR"/*

download_and_extract() {
  local url="$1"
  local filename
  filename="$(basename "$url")"
  local tmp="$CACHE_DIR/$filename"

  if [[ -f "$tmp" ]]; then
    echo "Reusing cached $(basename "$url")"
  else
    echo "Downloading $url"
    if ! curl -L -f "$url" -o "$tmp"; then
      echo "Failed to download $url"
      return 1
    fi
  fi

  case "$tmp" in
    *.tar.xz) tar -xJf "$tmp" -C "$LIBDIR" ;;
    *.tar.gz) tar -xzf "$tmp" -C "$LIBDIR" ;;
    *) echo "Unknown archive format: $tmp"; return 1 ;;
  esac

  return 0
}

download_and_extract "$WINE_URL"
download_and_extract "$DXVK_URL"
CABEXTRACT_BIN="$(command -v cabextract 2>/dev/null || true)"
if [[ -z "$CABEXTRACT_BIN" ]]; then
  cat <<'EOF'
cabextract is required to assemble Libraries.tar.gz.
Install it via Homebrew before running this script:

  brew install cabextract

After installing cabextract rerun this script so the system binary is copied into Libraries/.
EOF
  exit 1
fi

CABEXTRACT_TARGET="$LIBDIR/cabextract"
cp "$CABEXTRACT_BIN" "$CABEXTRACT_TARGET"
chmod +x "$CABEXTRACT_TARGET"

if [[ -f "$TARBALL" ]]; then
  rm -f "$TARBALL"
fi

echo "Creating Libraries.tar.gz"
tar -czf "$TARBALL" -C "$LIBDIR" .
