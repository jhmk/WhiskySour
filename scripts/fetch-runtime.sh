#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
LIBDIR="$REPO/Libraries"
TARBALL="$REPO/Libraries.tar.gz"

WINE_URL="https://github.com/Gcenx/macOS_Wine_builds/releases/download/11.0/wine-stable-11.0-osx64.tar.xz"
DXVK_URL="https://github.com/doitsujin/dxvk/releases/download/v2.7.1/dxvk-2.7.1.tar.gz"
CABEXTRACT_URLS=(
  "https://github.com/deepin-community/cabextract/archive/refs/tags/1.11-1.tar.gz"
  "https://github.com/baskerville/cabextract/releases/download/1.12/cabextract-1.12.tar.gz"
)

mkdir -p "$LIBDIR"

rm -rf "$LIBDIR"/*

download_and_extract() {
  local url="$1"
  local tmp="$REPO/$(basename "$url")"

  if [[ -f "$tmp" ]]; then
    echo "Reusing cached $(basename "$url")"
  else
    echo "Downloading $url"
    curl -L -f "$url" -o "$tmp"
  fi

  case "$tmp" in
    *.tar.xz) tar -xJf "$tmp" -C "$LIBDIR" ;;
    *.tar.gz) tar -xzf "$tmp" -C "$LIBDIR" ;;
    *) echo "Unknown archive format: $tmp"; exit 1 ;;
  esac

  rm -f "$tmp"
}

download_and_extract "$WINE_URL"
download_and_extract "$DXVK_URL"
CABEXTRACT_TARGET="$LIBDIR/cabextract"
for url in "${CABEXTRACT_URLS[@]}"; do
  download_and_extract "$url"
    CABEXTRACT_BIN=$(find "$LIBDIR" -name cabextract -type f -perm +111 -print -quit)
  if [[ -n "$CABEXTRACT_BIN" ]]; then
    cp "$CABEXTRACT_BIN" "$CABEXTRACT_TARGET"
    chmod +x "$CABEXTRACT_TARGET"
    break
  else
    echo "cabextract binary not found in $url, trying next URL"
  fi
done

if [[ ! -f "$CABEXTRACT_TARGET" ]]; then
  echo "warning: cabextract binary still missing after all downloads"
fi

if [[ -f "$TARBALL" ]]; then
  rm -f "$TARBALL"
fi

echo "Creating Libraries.tar.gz"
tar -czf "$TARBALL" -C "$LIBDIR" .
