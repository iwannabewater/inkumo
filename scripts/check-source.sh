#!/usr/bin/env bash
# Validate source-level invariants that do not require a TeX runtime.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "missing required command: $1"
}

require_command python3
require_command rg

if rg -n "\\\\rlap" "$ROOT_DIR/inkumo.cls"; then
  fail "flow layout should not use zero-width rlapped headings"
fi

if rg -n "declare[[:space:]]+-A" "$ROOT_DIR/scripts"; then
  fail "shell scripts must stay compatible with macOS Bash 3.2"
fi

python3 - "$ROOT_DIR" <<'PY'
import collections
import fnmatch
import re
import subprocess
import sys
from pathlib import Path

root = Path(sys.argv[1])


def fail(message: str) -> None:
    raise SystemExit(f"FAIL: {message}")


registry = (root / "lib" / "icon-registry.tex").read_text(encoding="utf-8")
definitions = re.findall(r"^\\definePIcon\{([^{}]+)\}", registry, re.M)
duplicates = sorted(key for key, count in collections.Counter(definitions).items() if count > 1)
if duplicates:
    fail("duplicate icon registry keys: " + ", ".join(duplicates))
if not definitions:
    fail("icon registry is empty")

sources = [root / "resume.tex", *sorted((root / "content").glob("*.tex"))]
content = "\n".join(path.read_text(encoding="utf-8") for path in sources)
used = set(re.findall(r"\\(?:Tech|ContactItem|ContactHref|PIcon)\{([^{}]+)\}", content))
missing = sorted(used - set(definitions))
if missing:
    fail("missing icon mappings for content keys: " + ", ".join(missing))

try:
    git_check = subprocess.run(
        ["git", "-C", str(root), "rev-parse", "--is-inside-work-tree"],
        text=True,
        encoding="utf-8",
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
except FileNotFoundError:
    git_check = subprocess.CompletedProcess(args=["git"], returncode=1)
tracked = []
if git_check.returncode == 0:
    tracked = subprocess.check_output(
        ["git", "-C", str(root), "ls-files"],
        text=True,
        encoding="utf-8",
    ).splitlines()

forbidden_patterns = [
    "*.pdf",
    "fonts/*.ttf",
    "fonts/*.otf",
    "fonts/*.woff",
    "fonts/*.woff2",
    "assets/devicon/devicon.ttf",
    "assets/devicon/LICENSE",
    "assets/simple-icons/SimpleIcons.ttf",
    "assets/simple-icons/simple-icons.json",
    "assets/simple-icons/LICENSE.md",
    "assets/simple-icons/DISCLAIMER.md",
]
if tracked:
    forbidden = [
        path
        for path in tracked
        if any(fnmatch.fnmatch(path, pattern) for pattern in forbidden_patterns)
    ]
    if forbidden:
        fail("tracked generated or third-party local assets: " + ", ".join(forbidden))
PY

echo "OK: source checks passed"
