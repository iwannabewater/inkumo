#!/usr/bin/env bash
# Shared shell helpers for Inkumo validation and release tooling.

INKUMO_LOG_ERROR_PATTERN="^!|Error:|Package .* Error|LaTeX .*Warning|Package .*Warning|Overfull|Underfull|undefined|Unknown CJK|Missing character"
INKUMO_LOG_PROBLEM_PATTERN="Class .*Warning|$INKUMO_LOG_ERROR_PATTERN"

inkumo_fail() {
  echo "FAIL: $*" >&2
  exit 1
}

inkumo_require_command() {
  command -v "$1" >/dev/null 2>&1 \
    || inkumo_fail "missing required command: $1"
}

inkumo_require_file() {
  [[ -s "$1" ]] || inkumo_fail "$2"
}

inkumo_assert_clean_log() {
  local log="$1"
  local pattern="$2"
  local message="$3"

  if rg -n "$pattern" "$log"; then
    inkumo_fail "$message"
  fi
}

inkumo_sha256() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    inkumo_fail "missing required command: shasum or sha256sum"
  fi
}
