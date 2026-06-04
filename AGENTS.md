# AGENTS.md

Guidance for AI-assisted edits in this repository.

## Project Map

- `inkumo.cls` owns layout, typography, PDF metadata, and public document
  commands.
- `resume.tex` is only the document orchestrator.
- `content/*.tex` contains sample resume content.
- `lib/icons.tex` is the stable icon facade.
- `lib/icon-glyphs.tex` contains raw font codepoints.
- `lib/icon-registry.tex` contains public icon key mappings.
- `scripts/fetch-*.sh` retrieve ignored third-party assets with checksum checks.
- `scripts/check-source.sh` validates source invariants without TeX.
- `scripts/check-pdf.sh` validates the rendered PDF and LaTeX log.

## Hard Boundaries

- Do not commit generated PDFs, downloaded fonts, downloaded icon fonts, or
  local asset metadata fetched by `make setup`.
- Do not replace the restrained paper-and-ink direction without an explicit
  design reason. Keep the parchment canvas, ink-blue accent, serif hierarchy,
  dotted hairlines, and compact resume density.
- Do not add image-backed icons to the default build. Font-based icons are the
  supported path.
- Do not put raw codepoints in content files or `lib/icon-registry.tex`.
  Codepoints belong in `lib/icon-glyphs.tex`.
- Do not introduce a new build runtime when Make and XeLaTeX are enough.
- Keep shell scripts compatible with macOS Bash 3.2. Do not use associative
  arrays or newer Bash-only conveniences.

## Verification

- Run `make lint` for every change.
- Run `make setup` before a full local PDF validation if local fonts or icon
  fonts are missing.
- Run `make clean && make test` for changes to `inkumo.cls`, `resume.tex`,
  `content/`, `lib/`, `scripts/`, `Makefile`, or `.github/workflows/`.
- Inspect the rendered PDF after typography, spacing, pagination, sample
  content, or visual changes. Check at least: long contact links, long project
  titles, wrapped skill rows, page markers, last-page footer, and log warnings.
- If the local machine lacks XeLaTeX, report that as an environment blocker and
  rely on GitHub Actions for the PDF compile result after pushing.

## Typesetting Rules

- Prefer flow-based rows that allow wrapping over zero-width overlays or
  hand-positioned text.
- Use `\ContactHref{key}{url}{label}` for clickable header labels so the contact
  line can wrap cleanly between items.
- Keep icons attached to their labels, but allow breaks between contact items.
- Keep dates and short metadata in the right column. If metadata becomes long,
  let it wrap rather than shrinking the main text below the document rhythm.
- Add layout primitives to `inkumo.cls` only when they express a reusable resume
  concept.

## Release Notes

- Record user-visible template, validation, asset, or documentation changes in
  `CHANGELOG.md` under `Unreleased`.
- Keep changelog items concise and user-facing. Avoid one-off audit notes.
