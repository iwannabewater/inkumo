#!/usr/bin/env bash
# scripts/fetch-icons.sh - download local icon assets used by lib/icons.tex.
#
# The repository does not track third-party icon fonts. This script fetches
# pinned upstream assets into ./assets/.
#
# Usage: bash scripts/fetch-icons.sh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSET_DIR="$ROOT_DIR/assets"
DEVICON_DIR="$ASSET_DIR/devicon"
SIMPLE_DIR="$ASSET_DIR/simple-icons"

DEVICON_COMMIT="7330accdbc47e2dc0c19789a48533c4a3c50fe58"
SIMPLE_ICONS_FONT_VERSION="16.18.1"

c_green=$'\033[32m'
c_red=$'\033[31m'
c_yellow=$'\033[33m'
c_dim=$'\033[2m'
c_reset=$'\033[0m'

download() {
  local url="$1" target="$2"
  rm -f "$target.tmp"

  local ok=1
  if command -v curl >/dev/null 2>&1; then
    curl --retry 2 --connect-timeout 15 --max-time 300 \
      -fSL "$url" -o "$target.tmp" 2>/dev/null && ok=0
  elif command -v wget >/dev/null 2>&1; then
    wget --tries=3 --connect-timeout=15 --read-timeout=300 \
      -q -O "$target.tmp" "$url" && ok=0
  else
    echo "${c_red}FAIL${c_reset}: install curl or wget to download icons"
    return 1
  fi

  if [[ "$ok" -eq 0 && -s "$target.tmp" ]]; then
    mv "$target.tmp" "$target"
    return 0
  fi

  rm -f "$target.tmp"
  return 1
}

require_min_size() {
  local file="$1" min_bytes="$2"
  [[ -f "$file" ]] || return 1
  local size
  size=$(wc -c < "$file" | tr -d ' ')
  [[ "$size" -ge "$min_bytes" ]]
}

fetch_devicon() {
  mkdir -p "$DEVICON_DIR"
  local base="https://raw.githubusercontent.com/devicons/devicon/$DEVICON_COMMIT"

  if require_min_size "$DEVICON_DIR/devicon.ttf" 1000000; then
    echo "${c_dim}skip${c_reset} Devicon font"
  else
    echo "fetch Devicon font"
    download "$base/fonts/devicon.ttf" "$DEVICON_DIR/devicon.ttf" \
      || { echo "${c_red}FAIL${c_reset}: Devicon font"; return 1; }
    require_min_size "$DEVICON_DIR/devicon.ttf" 1000000 \
      || { echo "${c_red}FAIL${c_reset}: Devicon font is incomplete"; return 1; }
  fi

  if require_min_size "$DEVICON_DIR/LICENSE" 500; then
    echo "${c_dim}skip${c_reset} Devicon license"
  else
    echo "fetch Devicon license"
    download "$base/LICENSE" "$DEVICON_DIR/LICENSE" \
      || { echo "${c_red}FAIL${c_reset}: Devicon license"; return 1; }
    require_min_size "$DEVICON_DIR/LICENSE" 500 \
      || { echo "${c_red}FAIL${c_reset}: Devicon license is incomplete"; return 1; }
  fi
}

fetch_simple_icons() {
  mkdir -p "$SIMPLE_DIR"

  if require_min_size "$SIMPLE_DIR/SimpleIcons.ttf" 1000000 \
    && require_min_size "$SIMPLE_DIR/simple-icons.json" 100000; then
    echo "${c_dim}skip${c_reset} Simple Icons font"
    return 0
  fi

  echo "fetch Simple Icons font $SIMPLE_ICONS_FONT_VERSION"
  local tarball tmpdir
  tarball="$(mktemp "${TMPDIR:-/tmp}/inkumo-simple-icons.XXXXXX.tgz")"
  tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/inkumo-simple-icons.XXXXXX")"

  if ! download "https://registry.npmjs.org/simple-icons-font/-/simple-icons-font-${SIMPLE_ICONS_FONT_VERSION}.tgz" "$tarball"; then
    rm -rf "$tmpdir" "$tarball"
    echo "${c_red}FAIL${c_reset}: Simple Icons package"
    return 1
  fi

  if ! tar -xzf "$tarball" -C "$tmpdir"; then
    rm -rf "$tmpdir" "$tarball"
    echo "${c_red}FAIL${c_reset}: could not extract Simple Icons package"
    return 1
  fi

  install -m 0644 "$tmpdir/package/font/SimpleIcons.ttf" "$SIMPLE_DIR/SimpleIcons.ttf"
  install -m 0644 "$tmpdir/package/font/simple-icons.json" "$SIMPLE_DIR/simple-icons.json"
  install -m 0644 "$tmpdir/package/LICENSE.md" "$SIMPLE_DIR/LICENSE.md"
  install -m 0644 "$tmpdir/package/DISCLAIMER.md" "$SIMPLE_DIR/DISCLAIMER.md"

  require_min_size "$SIMPLE_DIR/SimpleIcons.ttf" 1000000 \
    || { rm -rf "$tmpdir" "$tarball"; echo "${c_red}FAIL${c_reset}: Simple Icons font is incomplete"; return 1; }
  require_min_size "$SIMPLE_DIR/simple-icons.json" 100000 \
    || { rm -rf "$tmpdir" "$tarball"; echo "${c_red}FAIL${c_reset}: Simple Icons metadata is incomplete"; return 1; }

  if ! python3 - "$SIMPLE_DIR/simple-icons.json" <<'PY'
import json
import sys
from pathlib import Path

icons = {item["slug"]: item for item in json.loads(Path(sys.argv[1]).read_text())}
required = {"etcd": "ed88", "codemirror": "ec41", "nvidia": "f1f4"}
missing = []
for slug, code in required.items():
    if slug not in icons or icons[slug].get("code", "").lower() != code:
        missing.append(f"{slug}:{code}")
if missing:
    raise SystemExit("missing expected Simple Icons glyphs: " + ", ".join(missing))
PY
  then
    rm -rf "$tmpdir" "$tarball"
    echo "${c_red}FAIL${c_reset}: Simple Icons metadata check failed"
    return 1
  fi

  rm -rf "$tmpdir" "$tarball"
}

mkdir -p "$ASSET_DIR"

fetch_devicon
fetch_simple_icons

cat <<EOF
${c_green}DONE${c_reset}: icon assets ready
  ${c_dim}Devicon:${c_reset}       $DEVICON_DIR/devicon.ttf
  ${c_dim}Simple Icons:${c_reset}  $SIMPLE_DIR/SimpleIcons.ttf

${c_yellow}Note:${c_reset} these local assets are intentionally ignored by Git.
EOF
