# Inkumo

[![Build](https://github.com/iwannabewater/inkumo/actions/workflows/build.yml/badge.svg)](https://github.com/iwannabewater/inkumo/actions/workflows/build.yml)

Inkumo is a XeLaTeX resume template for Chinese/English technical resumes,
especially for CS students. It uses a parchment page, ink-blue accents,
TsangerJinKai02 for Chinese, and XCharter for Latin text.

`Inkumo` means `墨云` in Chinese: ink on paper, cloud in motion. The name fits a technical
resume that should stay clear, restrained, and print-ready.

## Changelog

Current update:

- Removed the image-backed Raft icon path.
- Moved shell scripts into `scripts/`.
- Reworked the sample resume for large language model and multimodal research.
- Simplified the README around one reproducible Quick Start path.
- Replaced raw Devicon and Simple Icons codepoints in the public icon registry
  with named glyph macros.

See `CHANGELOG.md` for the full project history.

## Quick Start

```bash
git clone https://github.com/iwannabewater/inkumo.git
cd inkumo
make setup
make test
```

`make setup` downloads local fonts and icon fonts. `make test` builds
`resume.pdf` and validates the output.

## Features

- XeLaTeX document class with explicit engine checks.
- Modular resume content under `content/`.
- Automatic page markers and last-page copyright footer.
- Flow-based section layout for long titles, dates, roles, and lists.
- Font-icon registry backed by Font Awesome, Devicon, and Simple Icons.
- CI build that checks the PDF, log, embedded fonts, page markers, footer, and
  icon mappings.

## Requirements

| Tool | Purpose |
|---|---|
| `make` | build entry point |
| `xelatex` | PDF rendering |
| `curl` or `wget` | asset downloads |
| `tar` | Simple Icons package extraction |
| `python3` | metadata checks |
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
| `make setup` | Download local fonts and icon fonts |
| `make test` | Build and validate `resume.pdf` |
| `make watch` | Rebuild on file changes with `latexmk` |
| `make clean` | Remove LaTeX byproducts |
| `make distclean` | Run `make clean` and remove `resume.pdf` |

## Repository Layout

| Path | Purpose |
|---|---|
| `resume.tex` | document entry point |
| `inkumo.cls` | layout, typography, PDF metadata |
| `content/` | resume sections |
| `lib/icons.tex` | icon registry |
| `scripts/fetch-fonts.sh` | TsangerJinKai02 download script |
| `scripts/fetch-icons.sh` | Devicon and Simple Icons download script |
| `scripts/check-pdf.sh` | PDF validation script |
| `fonts/` | ignored local CJK font files |
| `assets/` | ignored local icon font files and tracked source notes |

## Editing

Update the files under `content/` first:

| File | Content |
|---|---|
| `content/header.tex` | name, contact line, role, summary |
| `content/education.tex` | education |
| `content/skills.tex` | skill rows |
| `content/awards.tex` | awards |
| `content/research.tex` | research entries |
| `content/projects.tex` | project entries |
| `content/campus.tex` | campus experience |

Common macros:

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

## Icons

Inkumo uses font-based icons only.

| Source | Local artifact | Usage |
|---|---|---|
| Font Awesome 5 Free | TeX Live package | contact and generic icons |
| Devicon | `assets/devicon/devicon.ttf` | programming languages and developer tools |
| Simple Icons | `assets/simple-icons/SimpleIcons.ttf` | etcd, CodeMirror, NVIDIA / CUDA |

The public registry uses named glyphs:

```latex
\definePIcon{blog}{\faRssSquare}
\definePIcon{go}{\DeviconGo}
\definePIcon{etcd}{\SimpleIconEtcd}
\definePIcon{cuda}{\SimpleIconNvidia}
```

Raw font codepoints are kept in the named glyph block inside `lib/icons.tex`.

## Validation

`make test` checks:

- `resume.pdf` and `resume.log` exist.
- LaTeX produced no warnings, missing glyphs, or layout warnings.
- Devicon and Simple Icons are embedded.
- Every page has a centered page marker.
- The copyright footer appears only on the last page.
- The footer name matches `content/header.tex`.
- Every `\Tech{...}` key used in `content/` is registered.

## License

The source code and documentation are MIT licensed. Fonts, icon fonts, brand
marks, and generated PDFs are governed by their own licenses. See `NOTICE.md`.
