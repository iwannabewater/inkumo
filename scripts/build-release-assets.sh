#!/usr/bin/env bash
# Build and validate the two PDF assets attached to an Inkumo release.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

TAG="${1:-}"
OUTPUT_DIR="${2:-$ROOT_DIR/dist}"
AVATAR_PATH="$ROOT_DIR/content/avatar.jpeg"
BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/inkumo-release-build.XXXXXX")"
trap 'rm -rf "$BUILD_DIR"' EXIT

[[ -n "$TAG" ]] || inkumo_fail "usage: $0 vMAJOR.MINOR.PATCH [output-directory]"

inkumo_require_command make
inkumo_require_command pdfinfo
inkumo_require_command python3
inkumo_require_command xelatex
inkumo_require_file \
  "$AVATAR_PATH" \
  "content/avatar.jpeg is required for the avatar release PDF"

python3 "$ROOT_DIR/scripts/validate.py" release \
  --root "$ROOT_DIR" \
  --tag "$TAG"

make -C "$ROOT_DIR" lint

build_pdf() {
  local job_name="$1"
  local input="$2"
  local pass

  for pass in 1 2; do
    if ! (
      cd "$ROOT_DIR"
      xelatex -interaction=nonstopmode -halt-on-error -file-line-error \
        -output-directory="$BUILD_DIR" \
        -jobname="$job_name" \
        "$input"
    ) >"$BUILD_DIR/$job_name-pass-$pass.txt" 2>&1; then
      cat "$BUILD_DIR/$job_name-pass-$pass.txt" >&2
      inkumo_fail "$job_name failed on XeLaTeX pass $pass"
    fi
  done
}

build_pdf "resume" "resume.tex"
bash "$ROOT_DIR/scripts/check-pdf.sh" "$BUILD_DIR"

avatar_input="\\def\\InkumoHeaderSetup{\\inkumoavatar[24mm]{content/avatar.jpeg}}\\input{resume.tex}"
build_pdf "resume-avatar" "$avatar_input"
bash "$ROOT_DIR/scripts/check-rendered-pdf.sh" resume-avatar "$BUILD_DIR"

text_pages="$(pdfinfo "$BUILD_DIR/resume.pdf" | awk '/^Pages:/ {print $2}')"
avatar_pages="$(pdfinfo "$BUILD_DIR/resume-avatar.pdf" | awk '/^Pages:/ {print $2}')"
[[ "$text_pages" = "$avatar_pages" ]] \
  || inkumo_fail "release PDFs must have the same page count"

if cmp -s "$BUILD_DIR/resume.pdf" "$BUILD_DIR/resume-avatar.pdf"; then
  inkumo_fail "avatar release PDF is identical to the text-only PDF"
fi

mkdir -p "$OUTPUT_DIR"
cp "$BUILD_DIR/resume.pdf" "$OUTPUT_DIR/resume.pdf"
cp "$BUILD_DIR/resume-avatar.pdf" "$OUTPUT_DIR/resume-avatar.pdf"

echo "OK: release assets built in $OUTPUT_DIR"
echo "  resume.pdf        $(inkumo_sha256 "$OUTPUT_DIR/resume.pdf")"
echo "  resume-avatar.pdf $(inkumo_sha256 "$OUTPUT_DIR/resume-avatar.pdf")"
