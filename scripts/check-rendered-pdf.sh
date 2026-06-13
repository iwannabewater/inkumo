#!/usr/bin/env bash
# Validate one rendered Inkumo PDF and its matching LaTeX log.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

DOCUMENT="${1:-resume}"
case "$DOCUMENT" in
  ""|*[!A-Za-z0-9._-]*)
    inkumo_fail "invalid document basename: $DOCUMENT"
    ;;
esac

PDF="$ROOT_DIR/$DOCUMENT.pdf"
LOG="$ROOT_DIR/$DOCUMENT.log"
TEXT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/inkumo-render-check.XXXXXX")"
trap 'rm -rf "$TEXT_DIR"' EXIT

inkumo_require_command pdfinfo
inkumo_require_command pdffonts
inkumo_require_command pdftotext
inkumo_require_command python3
inkumo_require_command rg

inkumo_require_file "$PDF" "$DOCUMENT.pdf is missing or empty"
inkumo_require_file "$LOG" "$DOCUMENT.log is missing or empty"

for asset in \
  "$ROOT_DIR/assets/devicon/devicon.ttf" \
  "$ROOT_DIR/assets/simple-icons/SimpleIcons.ttf"; do
  inkumo_require_file \
    "$asset" \
    "missing icon asset: ${asset#$ROOT_DIR/} (run: make setup)"
done

inkumo_assert_clean_log \
  "$LOG" \
  "$INKUMO_LOG_PROBLEM_PATTERN" \
  "$DOCUMENT.log contains warnings or layout issues"

pdffonts "$PDF" | rg -q "devicon" \
  || inkumo_fail "Devicon font is not embedded in $DOCUMENT.pdf"
pdffonts "$PDF" | rg -q "SimpleIcons" \
  || inkumo_fail "Simple Icons font is not embedded in $DOCUMENT.pdf"

pages="$(pdfinfo "$PDF" | awk '/^Pages:/ {print $2}')"
[[ "$pages" =~ ^[0-9]+$ ]] || inkumo_fail "invalid page count: ${pages:-missing}"

for page in $(seq 1 "$pages"); do
  page_text="$TEXT_DIR/page-$page.txt"
  pdftotext -layout -f "$page" -l "$page" "$PDF" "$page_text"
  rg -q "(^|[[:space:]])$page[[:space:]]*/[[:space:]]*$pages([[:space:]]|$)" "$page_text" \
    || inkumo_fail "missing centered page marker '$page/$pages' on page $page"
done

if [[ "$pages" -gt 1 ]]; then
  for page in $(seq 1 $((pages - 1))); do
    if rg -q "Copyright|编译于" "$TEXT_DIR/page-$page.txt"; then
      inkumo_fail "copyright signature should only appear on the last page"
    fi
  done
fi

last_page_text="$TEXT_DIR/page-$pages.txt"
rg -q "Copyright .* [0-9]{4}-[0-9]{2}-[0-9]{2}" "$last_page_text" \
  || inkumo_fail "missing copyright date on the last page"

if rg -q "[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}" "$last_page_text"; then
  inkumo_fail "copyright date should not include a clock time"
fi

python3 "$ROOT_DIR/scripts/validate.py" footer \
  --header "$ROOT_DIR/content/header.tex" \
  --page-text "$last_page_text"

echo "OK: $DOCUMENT.pdf passed rendered PDF checks"
