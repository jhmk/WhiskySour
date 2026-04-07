#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
LIBDIR="$REPO/Libraries"
TARBALL="$REPO/Libraries.tar.gz"
CACHE_DIR="$REPO/.cache/runtime"

WINE_URL="https://github.com/Gcenx/macOS_Wine_builds/releases/download/11.0/wine-stable-11.0-osx64.tar.xz"
DXVK_URL="https://github.com/doitsujin/dxvk/releases/download/v2.7.1/dxvk-2.7.1.tar.gz"
CABEXTRACT_URLS=(
  "https://www.cabextract.org.uk/cabextract-1.11.tar.gz"
)

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
CABEXTRACT_TARGET="$LIBDIR/cabextract"
for url in "${CABEXTRACT_URLS[@]}"; do
  if download_and_extract "$url"; then
    CABEXTRACT_BIN=$(find "$LIBDIR" -name cabextract -type f -perm +111 -print -quit)
    if [[ -n "$CABEXTRACT_BIN" ]]; then
      cp "$CABEXTRACT_BIN" "$CABEXTRACT_TARGET"
      chmod +x "$CABEXTRACT_TARGET"
      break
    else
  echo "cabextract binary not found in $url, trying next URL"
    fi
  else
    echo "Skipping $url due to download/extract failure"
  fi
done

if [[ ! -f "$CABEXTRACT_TARGET" ]]; then
  echo "Attempting to build cabextract from source"
  for src_dir in "$LIBDIR"/cabextract*; do
    if [[ -d "$src_dir/src" && -f "$src_dir/configure" ]]; then
      pushd "$src_dir" > /dev/null
      ./configure --prefix="$LIBDIR" && make -j$(sysctl -n hw.ncpu)
      if [[ -f src/cabextract ]]; then
        cp src/cabextract "$CABEXTRACT_TARGET"
        chmod +x "$CABEXTRACT_TARGET"
        popd > /dev/null
        break
      fi
      popd > /dev/null
    fi
  done
fi

if [[ ! -f "$CABEXTRACT_TARGET" && -x "$(command -v cabextract 2>/dev/null)" ]]; then
  echo "Using system cabextract binary from $(command -v cabextract)"
  cp "$(command -v cabextract)" "$CABEXTRACT_TARGET"
  chmod +x "$CABEXTRACT_TARGET"
fi

if [[ ! -f "$CABEXTRACT_TARGET" ]]; then
  echo "error: cabextract binary still missing after all downloads and builds"
  exit 1
fi

if [[ -f "$TARBALL" ]]; then
  rm -f "$TARBALL"
fi

echo "Creating Libraries.tar.gz"
tar -czf "$TARBALL" -C "$LIBDIR" .
