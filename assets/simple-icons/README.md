# Simple Icons

This directory is the local target for the Simple Icons font used by
`lib/icons.tex` for brand glyphs not covered by Devicon, including etcd,
CodeMirror, and NVIDIA / CUDA.

The font package is fetched by `make setup` and is intentionally ignored by Git.

- Source: https://github.com/simple-icons/simple-icons-font
- Package: `simple-icons-font@16.18.1`
- Package tarball SHA-256: `5115e9afecc20e523f05a104b974ee4fece0aa9eb420b17601fc5a924c501077`
- Files: `SimpleIcons.ttf`, `simple-icons.json`, `LICENSE.md`, `DISCLAIMER.md`
- Extracted files are checked against the digests encoded in
  `scripts/fetch-icons.sh`.
- License: CC0-1.0 for the Simple Icons package; individual brands may have
  trademark or usage restrictions documented in `simple-icons.json`
