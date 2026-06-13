#!/usr/bin/env bash
# Validate source-level invariants that do not require a TeX runtime.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

inkumo_require_command python3
inkumo_require_command rg
inkumo_require_command git

if rg -n "\\\\rlap" "$ROOT_DIR/inkumo.cls"; then
  inkumo_fail "flow layout should not use zero-width rlapped headings"
fi

if rg -n "\\\\includegraphics" "$ROOT_DIR/resume.tex" "$ROOT_DIR/content"; then
  inkumo_fail "content should use \\inkumoavatar or a class-level primitive instead of raw \\includegraphics"
fi

if rg -n "declare[[:space:]]+-A" "$ROOT_DIR/scripts"; then
  inkumo_fail "shell scripts must stay compatible with macOS Bash 3.2"
fi

python3 "$ROOT_DIR/scripts/validate.py" source --root "$ROOT_DIR"

echo "OK: source checks passed"
