# Contributing to Inkumo

Inkumo is a small typesetting project with a strict visual and licensing
boundary. Keep changes focused, readable, and reproducible.

## Build and Verify

```bash
make setup
make lint
make clean && make test
```

Run `make lint` for every change. Run a clean validation for any change to the
class, content sections, icon modules, asset scripts, build rules, or
continuous integration workflow.
Inspect the rendered pages when changing typography, spacing, header behavior,
avatar support, or sample content.

## Structure

- Keep resume content in independent `content/*.tex` modules.
- Add reusable layout primitives to `inkumo.cls` only when they express a
  stable document concept.
- Keep `lib/icons.tex` as the public facade; codepoints belong in
  `lib/icon-glyphs.tex` and key mappings in `lib/icon-registry.tex`.
- Use `\ContactHref` for clickable header labels so long labels and the contact
  line can wrap cleanly without detaching icons from labels.
- Use `\inkumoavatar` for optional profile photos. Keep personal image files
  local by default and verify both avatar and text-only headers after layout
  changes.
- Keep shell orchestration, structured parsing, and TeX fixtures separate:
  `scripts/*.sh` coordinates commands, `scripts/validate.py` parses repository
  data, and `tests/fixtures/` owns isolated TeX documents.
- Preserve the restrained paper-and-ink visual language unless a change has a
  documented design purpose.

## Assets and Licensing

`make setup` retrieves third-party font assets locally and verifies their
digests. Do not commit downloaded fonts, icon font artifacts, or rendered
PDFs. Review `NOTICE.md` before publishing generated material that embeds
licensed fonts or brand glyphs.

## Releases

Every release publishes `resume.pdf` and `resume-avatar.pdf`. The avatar build
uses the ignored local file `content/avatar.jpeg`; never add that file to Git.

After versioning, committing, tagging, and creating the GitHub Release, run:

```bash
make release-upload VERSION=vX.Y.Z
```

The command refuses to publish from a dirty tracked worktree or from a commit
that does not match the tag. It validates both PDFs and verifies the downloaded
release assets against the local SHA-256 checksums.

## Pull Requests

Explain the document or engineering behavior being changed, include the
verification command run, and note whether rendered pages were inspected.
Before submission, review `git status --short --ignored` to ensure local
licensed assets and generated PDFs remain untracked.
