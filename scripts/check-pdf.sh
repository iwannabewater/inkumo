#!/usr/bin/env bash
# Validate the generated resume PDF and the LaTeX log.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PDF="$ROOT_DIR/resume.pdf"
LOG="$ROOT_DIR/resume.log"
TEXT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/inkumo-pdf-check.XXXXXX")"
trap 'rm -rf "$TEXT_DIR"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "missing required command: $1"
}

require_command pdfinfo
require_command pdffonts
require_command pdftotext
require_command python3
require_command rg

[[ -s "$PDF" ]] || fail "resume.pdf is missing or empty"
[[ -s "$LOG" ]] || fail "resume.log is missing or empty"

for asset in \
  "$ROOT_DIR/assets/devicon/devicon.ttf" \
  "$ROOT_DIR/assets/simple-icons/SimpleIcons.ttf"; do
  [[ -s "$asset" ]] || fail "missing icon asset: ${asset#$ROOT_DIR/} (run: make setup)"
done

if rg -n "^!|Error:|Package .* Error|LaTeX .*Warning|Package .*Warning|Overfull|Underfull|undefined|Unknown CJK|Missing character" "$LOG"; then
  fail "LaTeX log contains warnings or layout issues"
fi

pdffonts "$PDF" | rg -q "devicon" \
  || fail "Devicon font is not embedded; run make setup and rebuild"
pdffonts "$PDF" | rg -q "SimpleIcons" \
  || fail "Simple Icons font is not embedded; run make setup and rebuild"

pages="$(pdfinfo "$PDF" | awk '/^Pages:/ {print $2}')"
[[ -n "$pages" ]] || fail "could not read page count"
[[ "$pages" =~ ^[0-9]+$ ]] || fail "invalid page count: $pages"

for page in $(seq 1 "$pages"); do
  pdftotext -layout -f "$page" -l "$page" "$PDF" "$TEXT_DIR/page-$page.txt"
  rg -q "(^|[[:space:]])$page[[:space:]]*/[[:space:]]*$pages([[:space:]]|$)" "$TEXT_DIR/page-$page.txt" \
    || fail "missing centered page marker '$page/$pages' on page $page"
done

if [[ "$pages" -gt 1 ]]; then
  for page in $(seq 1 $((pages - 1))); do
    if rg -q "Copyright|编译于" "$TEXT_DIR/page-$page.txt"; then
      fail "copyright signature should only appear on the last page"
    fi
  done
fi

rg -q "Copyright .* [0-9]{4}-[0-9]{2}-[0-9]{2}" "$TEXT_DIR/page-$pages.txt" \
  || fail "missing copyright date on the last page"

if rg -q "[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}" "$TEXT_DIR/page-$pages.txt"; then
  fail "copyright date should not include a clock time"
fi

python3 - "$ROOT_DIR/content/header.tex" "$TEXT_DIR/page-$pages.txt" <<'PY'
import re
import sys
from pathlib import Path

header = Path(sys.argv[1]).read_text(encoding="utf-8")
page_text = Path(sys.argv[2]).read_text(encoding="utf-8")

match = re.search(r"\\inkumoheader\s*\{([^{}]+)\}", header, re.S)
if not match:
    raise SystemExit("FAIL: could not read name from content/header.tex")

name = re.sub(r"%.*", "", match.group(1))
name = name.replace("~", " ")
name = re.sub(r"\\[ ,;:!]+", " ", name)
name = re.sub(r"\s+", " ", name).strip()

normalized_page = re.sub(r"\s+", " ", page_text)
if name not in normalized_page:
    raise SystemExit(f"FAIL: missing header name in last-page signature: {name}")
PY

if rg -n "\\\\rlap" "$ROOT_DIR/inkumo.cls"; then
  fail "flow layout should not use zero-width rlapped headings"
fi

python3 - "$ROOT_DIR" <<'PY'
import re
import sys
from pathlib import Path

root = Path(sys.argv[1])
content = "\n".join(path.read_text(encoding="utf-8") for path in (root / "content").glob("*.tex"))
icons = "\n".join(path.read_text(encoding="utf-8") for path in sorted((root / "lib").glob("*.tex")))

used = set(re.findall(r"\\Tech\{([^{}]+)\}", content))
defined = set(re.findall(r"\\definePIcon\{([^{}]+)\}", icons))
missing = sorted(used - defined)
if missing:
    raise SystemExit("FAIL: missing icon mappings for \\Tech keys: " + ", ".join(missing))
PY

echo "OK: resume.pdf passed structural PDF checks"
