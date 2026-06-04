<p align="center">
  <img src="assets/brand/inkumo-mark.svg" width="104" alt="Inkumo ink-cloud mark">
</p>

<h1 align="center">Inkumo</h1>

<p align="center"><strong>墨云</strong> · A restrained XeLaTeX resume template for technical work.</p>

<p align="center">
  <a href="https://github.com/iwannabewater/inkumo/actions/workflows/build.yml"><img alt="Build" src="https://github.com/iwannabewater/inkumo/actions/workflows/build.yml/badge.svg"></a>
  <a href="LICENSE"><img alt="MIT License" src="https://img.shields.io/badge/license-MIT-1B365D?style=flat-square"></a>
  <a href="#quick-start"><img alt="XeLaTeX" src="https://img.shields.io/badge/engine-XeLaTeX-1B365D?style=flat-square"></a>
</p>

Inkumo is a Chinese and English resume template for technical profiles,
especially students and early-career researchers. It combines a warm paper
canvas, ink-blue detail, TsangerJinKai02 Chinese text, and XCharter Latin text
in a modular source layout.

`Inkumo` means `墨云`: ink on paper, cloud in motion. The bundled content is a
layout-ready sample and should be replaced with personal details before use.

## Features

- XeLaTeX document class with explicit engine and font handling.
- Modular resume sections, including education, awards, internship, research,
  projects, and campus experience.
- Flow-based entries with page markers and a last-page-only footer.
- A named icon API with codepoint bindings and public mappings isolated in
  separate modules.
- Break-friendly contact rows and relaxed row text tuned for long names, roles,
  profile labels, and mixed Chinese / English content.
- SHA-256 verified local retrieval for untracked font and icon assets.
- GitHub Actions validation for the PDF, embedded fonts, page markers, footer,
  log cleanliness, and icon mappings.

## Quick Start

```bash
git clone https://github.com/iwannabewater/inkumo.git
cd inkumo
make setup
make lint
make test
```

`make setup` retrieves the local third-party font assets and verifies their
checksums. `make lint` runs source checks that do not need a TeX runtime.
`make test` builds `resume.pdf` when needed and validates the rendered output.

## Requirements

| Tool | Purpose |
|---|---|
| `make` | build entry point |
| `xelatex` | PDF rendering |
| `curl` or `wget` | asset downloads |
| `tar` | Simple Icons package extraction |
| `python3` | checksum and metadata checks |
| `pdfinfo`, `pdffonts`, `pdftotext` | PDF validation |
| `rg` | source and log validation |
| `latexmk` | optional live rebuilds |

### Debian / Ubuntu

```bash
sudo apt update
sudo apt install -y \
  make \
  curl \
  wget \
  tar \
  python3 \
  fontconfig \
  poppler-utils \
  ripgrep \
  texlive-xetex \
  texlive-latex-recommended \
  texlive-latex-extra \
  texlive-fonts-recommended \
  texlive-fonts-extra \
  texlive-lang-chinese \
  latexmk
```

### macOS

```bash
brew install --cask mactex-no-gui
brew install poppler ripgrep
```

Restart the shell after installing MacTeX.

### Windows

Use WSL and follow the Debian / Ubuntu commands.

## Commands

| Command | Description |
|---|---|
| `make setup` | Retrieve and verify local fonts and icon fonts |
| `make lint` | Validate source invariants without compiling the PDF |
| `make test` | Build if needed and validate `resume.pdf` |
| `make clean && make test` | Rebuild from a clean tree and validate |
| `make watch` | Rebuild on file changes with `latexmk` |
| `make clean` | Remove LaTeX byproducts |
| `make distclean` | Run `make clean` and remove `resume.pdf` |

## Repository Layout

| Path | Purpose |
|---|---|
| `resume.tex` | document entry point and section order |
| `inkumo.cls` | layout, typography, and PDF metadata |
| `content/` | independent sample resume sections |
| `lib/icons.tex` | stable icon facade and font loading |
| `lib/icon-glyphs.tex` | pinned-font codepoint bindings |
| `lib/icon-registry.tex` | public technology icon mappings |
| `scripts/fetch-fonts.sh` | verified TsangerJinKai02 retrieval |
| `scripts/fetch-icons.sh` | verified Devicon and Simple Icons retrieval |
| `scripts/check-source.sh` | source-level validation |
| `scripts/check-pdf.sh` | structural PDF validation |
| `assets/brand/inkumo-mark.svg` | first-party README mark |
| `fonts/`, `assets/devicon/`, `assets/simple-icons/` | local third-party artifacts and tracked source notes |

## Editing

Update the files under `content/` first:

| File | Content |
|---|---|
| `content/header.tex` | name, contact line, role, and summary |
| `content/education.tex` | education |
| `content/skills.tex` | skill rows |
| `content/awards.tex` | awards |
| `content/internship.tex` | internship experience |
| `content/research.tex` | research entries |
| `content/projects.tex` | project entries |
| `content/campus.tex` | campus experience |

Use `\ContactHref{key}{url}{label}` for email, website, profile, and handle
labels in the header. It keeps the icon attached to the label while allowing
long labels and the contact line to wrap cleanly.

Detailed project or research entries use `\Project`:

```latex
\inkumosection{Selected Projects}

\Project
  {Multimodal Evaluation Platform}
  {Lab Project}
  [Technical Lead]
  {2023.11 -- 2024.04}
\Stack{\Tech{python}{Python}\sep \Tech{pytorch}{PyTorch}\sep \Tech{react}{React}}
\Desc{Built an evaluation workflow for vision-language models.}
\begin{Bullets}
  \item Added task schemas, metric aggregation, and searchable error cases
\end{Bullets}
```

Compact internship or professional rows use `\Experience{Organisation}{Role}{Date}`
followed by optional `\Stack`, `\Desc`, and `Bullets`.

## Icons

Inkumo renders font-based icons only.

| Source | Local artifact | Usage |
|---|---|---|
| Font Awesome 5 Free | TeX Live package | contact and generic icons |
| Devicon | `assets/devicon/devicon.ttf` | languages and developer tools |
| Simple Icons | `assets/simple-icons/SimpleIcons.ttf` | etcd, CodeMirror, and NVIDIA / CUDA |

Technology keys stay readable at the content boundary:

```latex
\definePIcon{blog}{\faRssSquare}
\definePIcon{go}{\DeviconGo}
\definePIcon{etcd}{\SimpleIconEtcd}
\definePIcon{cuda}{\SimpleIconNvidia}
```

Public mappings live in `lib/icon-registry.tex`; font codepoint bindings stay
isolated in `lib/icon-glyphs.tex`; `lib/icons.tex` is the stable import facade.

## Reproducible Assets

Third-party fonts are not committed. `make setup` downloads them from pinned
upstream references and checks their SHA-256 digests before use. The source
notes under `fonts/` and `assets/` describe each artifact and its license
boundary. Do not commit downloaded font files or generated PDFs.

## Validation

`make lint` checks:

- Every `\Tech`, `\ContactItem`, `\ContactHref`, and `\PIcon` key used in
  content has a public mapping.
- Icon registry keys are unique.
- Generated PDFs, downloaded fonts, and local third-party icon artifacts are
  not tracked.
- The class does not use zero-width `\rlap` headings.
- Shell scripts stay compatible with macOS Bash 3.2.

`make test` also checks:

- `resume.pdf` and its matching LaTeX log exist, rebuilding if a stale PDF has
  lost its log after cleanup.
- LaTeX produced no warnings, missing glyphs, or layout warnings.
- Devicon and Simple Icons are embedded.
- Every page has a centered page marker.
- The copyright footer appears only on the last page.
- The footer name matches `content/header.tex`.
- Every `\Tech{...}` key used in `content/` is registered.

See `CONTRIBUTING.md` for the clean-build and submission checklist, and
`CHANGELOG.md` for notable changes.

## License

Source code, documentation, and `assets/brand/inkumo-mark.svg` are MIT
licensed. Third-party fonts, icons, brands, and generated PDFs retain their
respective license constraints. See `NOTICE.md`.
