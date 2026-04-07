#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
LIBDIR="$REPO/Libraries"
TARBALL="$REPO/Libraries.tar.gz"

WINE_URL="https://github.com/Gcenx/macOS_Wine_builds/releases/download/11.0/wine-stable-11.0-osx64.tar.xz"
DXVK_URL="https://github.com/doitsujin/dxvk/releases/download/v2.7.1/dxvk-2.7.1.tar.gz"
CABEXTRACT_URL="https://github.com/baskerville/cabextract/releases/download/1.12/cabextract-1.12.tar.gz"

mkdir -p "$LIBDIR"

rm -rf "$LIBDIR"/*

download_and_extract() {
  local url="$1"
  local tmp="$REPO/$(basename "$url")"

  echo "Downloading $url"
  curl -L -f "$url" -o "$tmp"

  case "$tmp" in
    *.tar.xz) tar -xJf "$tmp" -C "$LIBDIR" ;;
    *.tar.gz) tar -xzf "$tmp" -C "$LIBDIR" ;;
    *) echo "Unknown archive format: $tmp"; exit 1 ;;
  esac

  rm -f "$tmp"
}

download_and_extract "$WINE_URL"
download_and_extract "$DXVK_URL"
download_and_extract "$CABEXTRACT_URL"

if [[ -f "$TARBALL" ]]; then
  rm -f "$TARBALL"
fi

echo "Creating Libraries.tar.gz"
tar -czf "$TARBALL" -C "$LIBDIR" .
