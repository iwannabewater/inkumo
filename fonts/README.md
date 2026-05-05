# Fonts

Inkumo uses TsangerJinKai02 for Chinese text and XCharter for Latin text. Font
Awesome supplies the contact and technology icons.

| Family | Weight files | Role | License |
|---|---|---|---|
| **TsangerJinKai02** (仓耳今楷02) | `TsangerJinKai02-W04.ttf` (regular) · `TsangerJinKai02-W05.ttf` (medium) | Chinese text | **Free for personal, non-commercial use.** [Tsanger Foundry](https://tsanger.cn). Commercial work requires a paid license. |
| **XCharter** | shipped with TeX Live as `xcharter` package | Latin text | Bitstream Charter free font license for font files; LPPL for TeX support files. |
| **Font Awesome 5 Free** | shipped through the TeX Live `fontawesome5` package | icons | SIL OFL 1.1 for icon fonts; LPPL 1.3c for the LaTeX package. |

XCharter is available through recent TeX Live and MiKTeX installations.

TsangerJinKai02 must be obtained separately. Two options:

## Option 1: Download fonts locally

```bash
bash fonts/fetch.sh
```

The script downloads `TsangerJinKai02-W04.ttf` and `TsangerJinKai02-W05.ttf`
from the [Kami project's CDN mirrors](https://github.com/tw93/kami) into this
directory. The download is approximately 30 MB.
It uses `curl` when available and falls back to `wget`.

The `inkumo` class detects local fonts in `fonts/` and uses them directly.

## Option 2: Install system-wide

If you prefer to install TsangerJinKai02 once and reuse across projects:

| OS | Steps |
|---|---|
| macOS | Open `TsangerJinKai02-W04.ttf` and `TsangerJinKai02-W05.ttf` in Font Book → *Install Font* |
| Linux | `mkdir -p ~/.local/share/fonts/Tsanger && cp *.ttf ~/.local/share/fonts/Tsanger/ && fc-cache -fv` |
| Windows | Right-click each `.ttf` → *Install for all users* |

After a system install, the `fonts/` directory can stay empty. The class falls
back to fontconfig.

## License notice

TsangerJinKai02 is **free for personal, non-commercial use**. If you use this resume template
for any commercial activity (paid client work, monetised channels, sale of a service that
uses the font, etc.), you must purchase a Tsanger commercial license from
<https://tsanger.cn> or substitute another CJK serif in `inkumo.cls`:

```latex
% in inkumo.cls — replace TsangerJinKai02 with your alternative
\setCJKmainfont{Source Han Serif SC}[
  UprightFont=*-Regular,
  BoldFont=*-Medium,
  ...
]
```

Source Han Serif SC (思源宋体), Noto Serif CJK SC, and Songti SC are all reasonable substitutes.

## Why fonts are not tracked

`fonts/*.ttf` is gitignored by default. Bundling TsangerJinKai02 in a public
repository would redistribute the font files. Each user should fetch a local copy
with `fonts/fetch.sh` or install the fonts system-wide.
