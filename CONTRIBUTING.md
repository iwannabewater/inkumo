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
Inspect the rendered pages when changing typography, spacing, or sample
content.

## Structure

- Keep resume content in independent `content/*.tex` modules.
- Add reusable layout primitives to `inkumo.cls` only when they express a
  stable document concept.
- Keep `lib/icons.tex` as the public facade; codepoints belong in
  `lib/icon-glyphs.tex` and key mappings in `lib/icon-registry.tex`.
- Use `\ContactHref` for clickable header labels so long labels and the contact
  line can wrap cleanly without detaching icons from labels.
- Preserve the restrained paper-and-ink visual language unless a change has a
  documented design purpose.

## Assets and Licensing

`make setup` retrieves third-party font assets locally and verifies their
digests. Do not commit downloaded fonts, icon font artifacts, or rendered
PDFs. Review `NOTICE.md` before publishing generated material that embeds
licensed fonts or brand glyphs.

## Pull Requests

Explain the document or engineering behavior being changed, include the
verification command run, and note whether rendered pages were inspected.
Before submission, review `git status --short --ignored` to ensure local
licensed assets and generated PDFs remain untracked.
