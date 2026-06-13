#!/usr/bin/env bash
# Run rendered-PDF checks plus isolated icon and avatar smoke tests.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

TEXT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/inkumo-pdf-check.XXXXXX")"
trap 'rm -rf "$TEXT_DIR"' EXIT

inkumo_require_command pdftoppm
inkumo_require_command python3
inkumo_require_command rg
inkumo_require_command xelatex

run_xelatex() {
  local job_name="$1"
  local passes="$2"
  local input="$3"
  local pass=1

  while [[ "$pass" -le "$passes" ]]; do
    if ! (
      cd "$ROOT_DIR"
      xelatex -interaction=nonstopmode -halt-on-error -file-line-error \
        -output-directory="$TEXT_DIR" \
        -jobname="$job_name" \
        "$input"
    ) >"$TEXT_DIR/$job_name-pass-$pass.txt" 2>&1; then
      cat "$TEXT_DIR/$job_name-pass-$pass.txt" >&2
      inkumo_fail "$job_name failed on XeLaTeX pass $pass"
    fi
    pass=$((pass + 1))
  done
}

assert_smoke_log() {
  local job_name="$1"
  inkumo_assert_clean_log \
    "$TEXT_DIR/$job_name.log" \
    "$INKUMO_LOG_PROBLEM_PATTERN" \
    "$job_name log contains warnings or layout issues"
}

bash "$ROOT_DIR/scripts/check-rendered-pdf.sh" resume

icon_audit_tex="$TEXT_DIR/icon-registry-audit.tex"
python3 "$ROOT_DIR/scripts/validate.py" icon-audit \
  --registry "$ROOT_DIR/lib/icon-registry.tex" \
  --output "$icon_audit_tex"
run_xelatex "icon-registry-audit" 2 "$icon_audit_tex"
assert_smoke_log "icon-registry-audit"

run_xelatex "avatar-demo" 1 "$ROOT_DIR/tests/fixtures/avatar-demo.tex"
assert_smoke_log "avatar-demo"
pdftoppm -png -singlefile -r 200 \
  "$TEXT_DIR/avatar-demo.pdf" "$TEXT_DIR/avatar-demo" >/dev/null
pdftoppm -jpeg -singlefile -r 200 \
  "$TEXT_DIR/avatar-demo.pdf" "$TEXT_DIR/avatar-demo" >/dev/null
mv "$TEXT_DIR/avatar-demo.jpg" "$TEXT_DIR/avatar-demo.jpeg"

for extension in pdf png jpeg; do
  job_name="avatar-smoke-$extension"
  input="\\def\\InkumoAvatarFixture{$TEXT_DIR/avatar-demo.$extension}\\input{tests/fixtures/avatar-smoke.tex}"
  run_xelatex "$job_name" 2 "$input"
  assert_smoke_log "$job_name"
done

run_xelatex "avatar-missing" 2 "$ROOT_DIR/tests/fixtures/avatar-missing.tex"
rg -q "Avatar file .* not found" "$TEXT_DIR/avatar-missing.log" \
  || inkumo_fail "missing-avatar fallback did not emit the expected class warning"
inkumo_assert_clean_log \
  "$TEXT_DIR/avatar-missing.log" \
  "$INKUMO_LOG_ERROR_PATTERN" \
  "missing-avatar fallback smoke test has unexpected log issues"

run_xelatex \
  "avatar-invalid-size" \
  2 \
  "\\def\\InkumoAvatarFixture{$TEXT_DIR/avatar-demo.jpeg}\\input{tests/fixtures/avatar-invalid-size.tex}"
rg -q "Avatar size .* must be positive" "$TEXT_DIR/avatar-invalid-size.log" \
  || inkumo_fail "invalid avatar size did not emit the expected class warning"
inkumo_assert_clean_log \
  "$TEXT_DIR/avatar-invalid-size.log" \
  "$INKUMO_LOG_ERROR_PATTERN" \
  "invalid-avatar-size smoke test has unexpected log issues"

echo "OK: resume.pdf and isolated smoke fixtures passed PDF checks"
