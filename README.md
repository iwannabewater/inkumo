# Inkumo

Inkumo is a XeLaTeX resume template shaped around the Kami document system:
warm parchment paper, ink-blue accents, restrained separators, and a serif-led
Chinese/English typography stack.

## Build

```bash
make fonts   # optional if TsangerJinKai02 is already installed locally
make
```

The output is `resume.pdf`.
It is ignored by Git because generated PDFs can embed local font subsets.

The GitHub Actions workflow in `.github/workflows/build.yml` runs the same
font fetch and XeLaTeX build on pushes and pull requests.

## System Dependencies

On Debian/Ubuntu:

```bash
sudo apt update
sudo apt install -y \
  make \
  curl \
  wget \
  fontconfig \
  texlive-xetex \
  texlive-latex-recommended \
  texlive-latex-extra \
  texlive-fonts-recommended \
  texlive-fonts-extra \
  texlive-lang-chinese \
  latexmk
```

`curl` or `wget` is enough for `make fonts`; both are listed because either one
can be available in a fresh environment.

## Fonts

Inkumo uses:

- Chinese: TsangerJinKai02 W04/W05
- English: XCharter
- Mono: Latin Modern Mono Light

TsangerJinKai02 is free for personal use only. The font files in `fonts/` are
local artifacts downloaded by each user and are ignored by Git. Do not commit or
redistribute `fonts/*.ttf` in a public repository unless you have the right
license.

## Editing

- Main entry: `resume.tex`
- Content sections: `content/*.tex`
- Platform and skill icons: `lib/icons.tex`
- Visual system and macros: `inkumo.cls`

For platform icons, edit `lib/icons.tex` and replace a mapping such as:

```latex
\definePIcon{github}{\faGithub}
```

Then use it from content files:

```latex
\ContactItem{github}{github.com/your-name}
\Tech{python}{Python}
```

If FontAwesome does not provide a faithful icon for a specific technology, keep
the text un-iconed rather than using an approximate or misleading glyph.

The default registry covers common contact platforms such as GitHub, GitLab,
LinkedIn, Telegram, Discord, Slack, WhatsApp, WeChat, QQ, Weibo, ORCID, and
major technology marks available in FontAwesome5 such as Python, Java, Rust,
React, Vue, Docker, AWS, HTML5, CSS3, Node.js, npm, Yarn, PHP, Laravel, Swift,
R, Jenkins, WordPress, and browser/OS icons.
