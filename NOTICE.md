# Notices

This repository contains an MIT-licensed XeLaTeX resume template. The MIT
license applies to the source code and documentation in this repository, not to
third-party fonts, installed TeX packages, or generated PDFs.

## TsangerJinKai02

Inkumo is designed for TsangerJinKai02 W04 and W05. These font files are not
tracked by Git and must not be redistributed from this repository.

Tsanger states that its site fonts can be downloaded for free and used for
personal, non-commercial purposes. Commercial use requires a commercial license
from Tsanger. Users are responsible for confirming that their own use case is
covered before distributing generated materials.

Generated PDFs may embed subsets of TsangerJinKai02. Do not publish or sell a
PDF that embeds the font unless your font license permits that use.

## XCharter

Inkumo uses XCharter for Latin text. XCharter extends Bitstream Charter. The
font files are distributed under the Bitstream free font license; the TeX support
files are distributed under the LaTeX Project Public License.

## Font Awesome 5

Inkumo uses the `fontawesome5` LaTeX package for icons. Font Awesome 5 Free
icons are under SIL OFL 1.1; the LaTeX package is under LPPL 1.3c.

## Devicon

Inkumo bundles the Devicon font at `assets/devicon/devicon.ttf` for technology
logo glyphs. Devicon is distributed under the MIT License; the license text is
included at `assets/devicon/LICENSE`.

Product names, logos, and brands represented by Devicon remain the property of
their respective owners. They are used only for identification in the generated
resume.

## Local Font Artifacts

The `fonts/` directory may contain local `.ttf`, `.otf`, `.woff`, or `.woff2`
files after running `make fonts` or installing custom fonts. These files are
ignored by Git.

Before publishing a fork, release, artifact, or generated PDF, verify the
license terms for every embedded or bundled font.
