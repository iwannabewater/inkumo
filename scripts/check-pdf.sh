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
require_command xelatex

[[ -s "$PDF" ]] || fail "resume.pdf is missing or empty"
[[ -s "$LOG" ]] || fail "resume.log is missing or empty"

for asset in \
  "$ROOT_DIR/assets/devicon/devicon.ttf" \
  "$ROOT_DIR/assets/simple-icons/SimpleIcons.ttf"; do
  [[ -s "$asset" ]] || fail "missing icon asset: ${asset#$ROOT_DIR/} (run: make setup)"
done

LOG_ERROR_PATTERN="^!|Error:|Package .* Error|LaTeX .*Warning|Package .*Warning|Overfull|Underfull|undefined|Unknown CJK|Missing character"
LOG_PROBLEM_PATTERN="Class .*Warning|$LOG_ERROR_PATTERN"

if rg -n "$LOG_PROBLEM_PATTERN" "$LOG"; then
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
sources = [root / "resume.tex", *sorted((root / "content").glob("*.tex"))]
content = "\n".join(path.read_text(encoding="utf-8") for path in sources)
registry = (root / "lib" / "icon-registry.tex").read_text(encoding="utf-8")

used = set(re.findall(r"\\(?:Tech|ContactItem|PIcon)\{([^{}]+)\}", content))
defined = set(re.findall(r"^\\definePIcon\{([^{}]+)\}", registry, re.M))
missing = sorted(used - defined)
if missing:
    raise SystemExit("FAIL: missing icon mappings for content keys: " + ", ".join(missing))
PY

ICON_AUDIT_TEX="$TEXT_DIR/icon-registry-audit.tex"
ICON_AUDIT_LOG="$TEXT_DIR/icon-registry-audit.log"
python3 - "$ROOT_DIR/lib/icon-registry.tex" "$ICON_AUDIT_TEX" <<'PY'
import collections
import re
import sys
from pathlib import Path

registry = Path(sys.argv[1]).read_text(encoding="utf-8")
target = Path(sys.argv[2])
keys = re.findall(r"^\\definePIcon\{([^{}]+)\}", registry, re.M)
duplicates = sorted(key for key, count in collections.Counter(keys).items() if count > 1)
if duplicates:
    raise SystemExit("FAIL: duplicate icon registry keys: " + ", ".join(duplicates))
if not keys:
    raise SystemExit("FAIL: icon registry is empty")

lines = [
    r"\documentclass{inkumo}",
    r"\input{lib/icons.tex}",
    r"\begin{document}",
]
lines.extend(r"\setbox0=\hbox{\PIcon{%s}}" % key for key in keys)
lines.extend(["icon registry audit", r"\end{document}"])
target.write_text("\n".join(lines) + "\n", encoding="utf-8")
PY

for pass in 1 2; do
  if ! (
    cd "$ROOT_DIR"
    xelatex -interaction=nonstopmode -halt-on-error -file-line-error \
      -output-directory="$TEXT_DIR" "$ICON_AUDIT_TEX"
  ) >"$TEXT_DIR/icon-registry-audit-pass-$pass.txt" 2>&1; then
    cat "$TEXT_DIR/icon-registry-audit-pass-$pass.txt" >&2
    fail "icon registry smoke test failed on XeLaTeX pass $pass"
  fi
done

if rg -n "$LOG_PROBLEM_PATTERN" "$ICON_AUDIT_LOG"; then
  fail "icon registry smoke test log contains warnings or layout issues"
fi

AVATAR_ASSET_TEX="$TEXT_DIR/avatar-asset.tex"
AVATAR_ASSET_PDF="$TEXT_DIR/avatar-asset.pdf"
python3 - "$AVATAR_ASSET_TEX" <<'PY'
import sys
from pathlib import Path

Path(sys.argv[1]).write_text(
    r"""\documentclass{article}
\usepackage[papersize={24mm,24mm},margin=0pt]{geometry}
\usepackage{xcolor}
\pagecolor[HTML]{E4ECF5}
\pagestyle{empty}
\begin{document}
\centering
\vspace*{7.2mm}
{\fontsize{8pt}{8pt}\selectfont\color[HTML]{1B365D}INKUMO}
\end{document}
"""
    + "\n",
    encoding="utf-8",
)
PY

if ! (
  cd "$TEXT_DIR"
  xelatex -interaction=nonstopmode -halt-on-error -file-line-error "$AVATAR_ASSET_TEX"
) >"$TEXT_DIR/avatar-asset-build.txt" 2>&1; then
  cat "$TEXT_DIR/avatar-asset-build.txt" >&2
  fail "avatar smoke asset build failed"
fi
[[ -s "$AVATAR_ASSET_PDF" ]] || fail "avatar smoke asset PDF is missing"

AVATAR_SMOKE_TEX="$TEXT_DIR/avatar-smoke.tex"
AVATAR_SMOKE_LOG="$TEXT_DIR/avatar-smoke.log"
python3 - "$AVATAR_ASSET_PDF" "$AVATAR_SMOKE_TEX" <<'PY'
import sys
from pathlib import Path

avatar = Path(sys.argv[1]).as_posix()
target = Path(sys.argv[2])
target.write_text(
    rf"""\documentclass{{inkumo}}
\input{{lib/icons.tex}}
\inkumoavatar[22mm]{{{avatar}}}
\begin{{document}}
\inkumoheader
  {{Avatar Smoke}}
  [Yan Mo]
  {{%
    \ContactHref{{email}}{{mailto:avatar-smoke@example.com}}{{avatar-smoke@example.com}}%
    \contactsep
    \ContactHref{{github}}{{https://github.com/iwannabewater/inkumo}}{{github.com/iwannabewater/inkumo}}%
    \contactsep
    \ContactHref{{website}}{{https://example.com/a-very-long-profile-path-for-wrapping}}{{example.com/a-very-long-profile-path-for-wrapping}}%
  }}
  [Research Engineer]
  [A compact header smoke test with an optional profile photo and deliberately long contact labels.]
\end{{document}}
"""
    + "\n",
    encoding="utf-8",
)
PY

for pass in 1 2; do
  if ! (
    cd "$ROOT_DIR"
    xelatex -interaction=nonstopmode -halt-on-error -file-line-error \
      -output-directory="$TEXT_DIR" "$AVATAR_SMOKE_TEX"
  ) >"$TEXT_DIR/avatar-smoke-pass-$pass.txt" 2>&1; then
    cat "$TEXT_DIR/avatar-smoke-pass-$pass.txt" >&2
    fail "avatar header smoke test failed on XeLaTeX pass $pass"
  fi
done

if rg -n "$LOG_PROBLEM_PATTERN" "$AVATAR_SMOKE_LOG"; then
  fail "avatar header smoke test log contains warnings or layout issues"
fi

AVATAR_MISSING_TEX="$TEXT_DIR/avatar-missing.tex"
AVATAR_MISSING_LOG="$TEXT_DIR/avatar-missing.log"
python3 - "$AVATAR_MISSING_TEX" <<'PY'
import sys
from pathlib import Path

Path(sys.argv[1]).write_text(
    r"""\documentclass{inkumo}
\input{lib/icons.tex}
\inkumoavatar[22mm]{missing-avatar-file.pdf}
\begin{document}
\inkumoheader
  {Missing Avatar Smoke}
  {%
    \ContactHref{email}{mailto:missing-avatar@example.com}{missing-avatar@example.com}%
    \contactsep
    \ContactItem{location}{Beijing}%
  }
  [Research Engineer]
  [The missing avatar path should warn, keep compiling, and fall back to the text-only header.]
\end{document}
"""
    + "\n",
    encoding="utf-8",
)
PY

for pass in 1 2; do
  if ! (
    cd "$ROOT_DIR"
    xelatex -interaction=nonstopmode -halt-on-error -file-line-error \
      -output-directory="$TEXT_DIR" "$AVATAR_MISSING_TEX"
  ) >"$TEXT_DIR/avatar-missing-pass-$pass.txt" 2>&1; then
    cat "$TEXT_DIR/avatar-missing-pass-$pass.txt" >&2
    fail "missing-avatar fallback smoke test failed on XeLaTeX pass $pass"
  fi
done

rg -q "Avatar file .* not found" "$AVATAR_MISSING_LOG" \
  || fail "missing-avatar fallback did not emit the expected class warning"

if rg -n "$LOG_ERROR_PATTERN" "$AVATAR_MISSING_LOG"; then
  fail "missing-avatar fallback smoke test has unexpected log issues"
fi

echo "OK: resume.pdf passed structural PDF checks"
