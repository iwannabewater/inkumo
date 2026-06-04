#!/usr/bin/env bash
# scripts/fetch-fonts.sh - download TsangerJinKai02 into ./fonts/.
#
# TsangerJinKai02 is free for personal use only (https://tsanger.cn).
# We mirror through the Kami project's CDN, falling back across mirrors and
# the official site. Downloads use curl when available, otherwise wget. The
# script is idempotent: if both fonts exist and look
# intact, it exits without re-downloading.
#
# Usage: bash scripts/fetch-fonts.sh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FONT_DIR="$ROOT_DIR/fonts"
MIN_SIZE_BYTES=8000000   # ~8 MB; smaller means a truncated download
KAMI_COMMIT="3d8ff18cd7b4693b3f451a03b5f9a31740a6b358"

FONT_LOCAL_NAMES=(
  "TsangerJinKai02-W04.ttf"
  "TsangerJinKai02-W05.ttf"
)
FONT_SOURCE_NAMES=(
  "仓耳今楷02-W04.ttf"
  "仓耳今楷02-W05.ttf"
)
FONT_SHA256S=(
  "47a9b416c27ad5436794c880ce3f666a3135a862ed1e2c91aa7db48914a6a487"
  "9744dc96801ec8c91a3390bed24c993d4722fb406e1d879177d343d40e985a6e"
)

CDN_MIRRORS=(
  "https://raw.githubusercontent.com/tw93/Kami/$KAMI_COMMIT/assets/fonts"
  "https://cdn.jsdelivr.net/gh/tw93/Kami@$KAMI_COMMIT/assets/fonts"
  "https://fastly.jsdelivr.net/gh/tw93/Kami@$KAMI_COMMIT/assets/fonts"
)

OFFICIAL_BASE="https://tsanger.cn/download"

c_green=$'\033[32m'
c_red=$'\033[31m'
c_yellow=$'\033[33m'
c_dim=$'\033[2m'
c_reset=$'\033[0m'

sha256_matches() {
  local file="$1" expected="$2"
  python3 - "$file" "$expected" <<'PY'
import hashlib
import sys
from pathlib import Path

path = Path(sys.argv[1])
expected = sys.argv[2]
actual = hashlib.sha256(path.read_bytes()).hexdigest()
raise SystemExit(0 if actual == expected else 1)
PY
}

intact() {
  local file="$1" expected="$2"
  [[ -f "$file" ]] || return 1
  local size
  size=$(wc -c < "$file" | tr -d ' ')
  [[ "$size" -ge "$MIN_SIZE_BYTES" ]] || return 1
  sha256_matches "$file" "$expected"
}

download() {
  local url="$1" target="$2" expected="$3"
  rm -f "$target.tmp"

  if command -v curl >/dev/null 2>&1; then
    curl --retry 2 --connect-timeout 15 --max-time 300 \
      -fSL "$url" -o "$target.tmp" 2>/dev/null || true
  elif command -v wget >/dev/null 2>&1; then
    wget --tries=3 --connect-timeout=15 --read-timeout=300 \
      -q -O "$target.tmp" "$url" || true
  else
    echo "  ${c_red}FAIL${c_reset}: install curl or wget to download fonts"
    return 1
  fi

  if intact "$target.tmp" "$expected"; then
    mv "$target.tmp" "$target"
    return 0
  fi

  rm -f "$target.tmp"
  return 1
}

mkdir -p "$FONT_DIR"
command -v python3 >/dev/null 2>&1 \
  || { echo "${c_red}FAIL${c_reset}: install python3 to verify font downloads"; exit 1; }

all_present=true
for i in "${!FONT_LOCAL_NAMES[@]}"; do
  local_name="${FONT_LOCAL_NAMES[$i]}"
  expected="${FONT_SHA256S[$i]}"
  intact "$FONT_DIR/$local_name" "$expected" || { all_present=false; break; }
done
if $all_present; then
  echo "${c_green}OK${c_reset}: TsangerJinKai02 fonts already present"
  exit 0
fi

failed=0
for i in "${!FONT_LOCAL_NAMES[@]}"; do
  local_name="${FONT_LOCAL_NAMES[$i]}"
  cn_name="${FONT_SOURCE_NAMES[$i]}"
  target="$FONT_DIR/$local_name"
  expected="${FONT_SHA256S[$i]}"
  if intact "$target" "$expected"; then
    echo "${c_dim}skip${c_reset} $local_name (already present)"
    continue
  fi

  echo "fetch $local_name"
  ok=false
  for base in "${CDN_MIRRORS[@]}"; do
    echo "  ${c_dim}↳ $base${c_reset}"
    if download "$base/$local_name" "$target" "$expected"; then ok=true; break; fi
  done
  if ! $ok; then
    echo "  ${c_dim}↳ $OFFICIAL_BASE/$cn_name (official, may be slow)${c_reset}"
    if download "$OFFICIAL_BASE/$cn_name" "$target" "$expected"; then ok=true; fi
  fi

  if $ok; then
    size_human=$(du -h "$target" | cut -f1)
    echo "  ${c_green}OK${c_reset}: $local_name ($size_human)"
  else
    echo "  ${c_red}FAIL${c_reset}: $local_name (all sources unreachable)"
    failed=$((failed + 1))
  fi
done

if [[ "$failed" -gt 0 ]]; then
  cat <<EOF

${c_yellow}Some downloads failed.${c_reset} Two ways forward:

  1. Try again later — the CDN mirrors occasionally rate-limit.
  2. Install Source Han Serif SC instead, then edit inkumo.cls to use it
     (see fonts/README.md → "License notice" for the exact substitution).

EOF
  exit 1
fi

echo "${c_green}DONE${c_reset}: all fonts ready in $FONT_DIR"
