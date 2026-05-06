# Inkumo

[![Build](https://github.com/iwannabewater/inkumo/actions/workflows/build.yml/badge.svg)](https://github.com/iwannabewater/inkumo/actions/workflows/build.yml)

Inkumo is a XeLaTeX resume template for Chinese/English technical resumes. It
uses a warm parchment canvas, restrained ink-blue accents, CJK-first spacing,
and a serif-led type stack built around TsangerJinKai02 and XCharter.

Inkumo means `墨云`: `Ink` carries the printed texture of the page; `umo` echoes
Japanese `雲 / くも` and the lightness of cloud systems. The template keeps the
visual language restrained, precise, and print-oriented.

## Features

- XeLaTeX-only class with explicit engine checks.
- Modular content files under `content/` for education, skills, awards,
  research, projects, and campus experience.
- Automatic page numbers at the bottom center of every page.
- Last-page signature and compile date derived from `content/header.tex`.
- Flow-based section and entry layout: long titles wrap before colliding with
  dates or roles.
- Expanded icon registry backed by Font Awesome and Devicon, covering contact
  platforms, programming languages, frameworks, databases, cloud systems, and
  developer tools with real logo glyphs where available.
- Local font fetch workflow for TsangerJinKai02 without committing font files.
- CI validation for build health, PDF metadata, embedded fonts, page numbers,
  and last-page footer metadata.

## Requirements

Inkumo requires XeLaTeX. The Makefile assumes a POSIX shell.

| Tool | Required for |
|---|---|
| `make` | build orchestration |
| `xelatex` | PDF rendering |
| `latexmk` | optional live rebuilds |
| `curl` or `wget` | downloading TsangerJinKai02 |
| `fontconfig` | system font discovery on Linux |
| `pdfinfo`, `pdffonts`, `pdftotext` | PDF inspection and `make test` |
| `rg` | source checks |
| `python3` | PDF metadata checks |

### Debian / Ubuntu

```bash
sudo apt update
sudo apt install -y \
  make \
  curl \
  wget \
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

Restart the shell after installing MacTeX so TeX binaries are on `PATH`.

### Windows

Use TeX Live or MiKTeX with XeLaTeX, then run the project from WSL, Git Bash, or
another shell that provides `make`. Install Poppler and ripgrep if you want
`make test` to run locally.

## Quick Start

```bash
git clone https://github.com/iwannabewater/inkumo.git
cd inkumo
make fonts
make
make test
```

The generated file is `resume.pdf`.

`resume.pdf` is intentionally ignored by Git. Generated PDFs may contain local
font subsets, and TsangerJinKai02 is not licensed for redistribution through
this repository.

## Editing

The entry point is `resume.tex`. It only loads the icon registry and content
sections:

```latex
\input{lib/icons.tex}
\input{content/header.tex}
\input{content/education.tex}
\input{content/skills.tex}
\input{content/awards.tex}
\input{content/research.tex}
\input{content/projects.tex}
\input{content/campus.tex}
```

Edit these files first:

| File | Purpose |
|---|---|
| `content/header.tex` | name, alias, contact line, role, summary |
| `content/education.tex` | education history |
| `content/skills.tex` | skill tiers |
| `content/awards.tex` | awards and rankings |
| `content/research.tex` | research entries |
| `content/projects.tex` | project entries |
| `content/campus.tex` | campus or extracurricular entries |
| `lib/icons.tex` | contact and technology icon mappings |
| `inkumo.cls` | visual system, macros, spacing, page metadata |

Common macros:

```latex
\inkumosection{项目经历}

\Project{轻量级容器云平台}{实验室项目}[方向主导]{2022.03 — 2022.12}
\Stack{\Tech{go}{Go}\sep \Tech{kubernetes}{Kubernetes}\sep \Tech{prometheus}{Prometheus}\sep \Tech{react}{React}}
\Desc{面向高校实验室场景的容器编排平台。}
\begin{Bullets}
  \item 设计并实现多租户权限模型，资源申请时延缩短到分钟级
\end{Bullets}

\Award{ACM-ICPC 区域赛}{铜奖}{2021.12}
```

## Layout Model

Inkumo does not position resume content with absolute coordinates. Sections and
entries participate in the normal TeX page flow, so content can grow, wrap, and
paginate naturally.

The class uses `\Needspace` only as a pagination guard: it prevents a section
title or entry header from being stranded at the bottom of a page. The footer is
drawn as a page overlay, so page numbers and the final signature do not consume
body text height.

Entry headers use bounded left/right regions. Long project names, award names,
roles, and dates wrap within those regions instead of overlapping.

## Build Commands

```bash
make          # build resume.pdf with two XeLaTeX passes
make fonts    # fetch TsangerJinKai02 W04/W05 into fonts/
make test     # build and validate resume.pdf
make watch    # live rebuild with latexmk
make clean    # remove LaTeX byproducts
make distclean
```

`make test` validates that:

- Every page contains a page marker matching the final page count.
- The copyright signature appears only on the last page.
- The last-page signature uses the name from `content/header.tex`.

## Continuous Integration

`.github/workflows/build.yml` runs on pushes, pull requests, and manual
dispatches. The workflow installs TeX Live, fetches local-use font artifacts,
builds the resume, runs the validation suite, and uploads the generated PDF as a
workflow artifact.

## Fonts and Licensing

Inkumo's source code and documentation are MIT licensed. Font files and
generated PDFs are governed by their own licenses and are not covered by the MIT
license.

| Asset | Role | License / notice |
|---|---|---|
| TsangerJinKai02 W04/W05 | Chinese text | Free for personal, non-commercial use from Tsanger. Commercial usage requires a Tsanger license. |
| XCharter | Latin text | XCharter extends Bitstream Charter; font files use the Bitstream free font license, and TeX support files use LPPL. |
| Font Awesome 5 Free | icons | Font files use SIL OFL 1.1; the LaTeX package uses LPPL 1.3c. |
| Devicon | technology icons | MIT licensed. Product names, logos, and brands remain the property of their respective owners. |

See `NOTICE.md` for the full project-specific notice.

## Changelog

Recent changes since the previous GitHub version:

- Added bottom-center page numbers and a last-page copyright footer.
- Improved flow layout for long headings, roles, and date ranges.
- Replaced text technology badges with bundled Devicon logo glyphs and added
  the corresponding third-party notice.

See `CHANGELOG.md` for version history.

## License

MIT for source code and documentation. See `LICENSE` and `NOTICE.md`.
