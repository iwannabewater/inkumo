#!/usr/bin/env bash
# Upload release PDFs and verify the remote bytes match the local build.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

TAG="${1:-}"
ASSET_DIR="$ROOT_DIR/dist"
DOWNLOAD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/inkumo-release-download.XXXXXX")"
trap 'rm -rf "$DOWNLOAD_DIR"' EXIT

[[ -n "$TAG" ]] || inkumo_fail "usage: $0 vMAJOR.MINOR.PATCH"

inkumo_require_command gh
inkumo_require_command git

REPOSITORY="${INKUMO_REPOSITORY:-$(gh repo view --json nameWithOwner --jq '.nameWithOwner')}"
[[ -n "$REPOSITORY" ]] || inkumo_fail "could not resolve the GitHub repository"

if [[ -n "$(git -C "$ROOT_DIR" status --porcelain --untracked-files=no)" ]]; then
  inkumo_fail "tracked worktree must be clean before publishing release assets"
fi

head_commit="$(git -C "$ROOT_DIR" rev-parse HEAD)"
tag_commit="$(git -C "$ROOT_DIR" rev-parse "$TAG^{}")"
[[ "$head_commit" = "$tag_commit" ]] \
  || inkumo_fail "HEAD must match $TAG before publishing release assets"

gh release view "$TAG" --repo "$REPOSITORY" >/dev/null \
  || inkumo_fail "GitHub Release $TAG does not exist"

bash "$ROOT_DIR/scripts/build-release-assets.sh" "$TAG" "$ASSET_DIR"

gh release upload "$TAG" \
  "$ASSET_DIR/resume.pdf" \
  "$ASSET_DIR/resume-avatar.pdf" \
  --repo "$REPOSITORY" \
  --clobber

gh release download "$TAG" \
  --repo "$REPOSITORY" \
  --pattern "resume*.pdf" \
  --dir "$DOWNLOAD_DIR"

for asset in resume.pdf resume-avatar.pdf; do
  local_hash="$(inkumo_sha256 "$ASSET_DIR/$asset")"
  remote_hash="$(inkumo_sha256 "$DOWNLOAD_DIR/$asset")"
  [[ "$local_hash" = "$remote_hash" ]] \
    || inkumo_fail "$asset checksum mismatch after upload"
  echo "OK: $asset $remote_hash"
done
