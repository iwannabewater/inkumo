# Fonts

Inkumo uses two typefaces, both real foundry work — never reflex defaults.

| Family | Weight files | Role | License |
|---|---|---|---|
| **TsangerJinKai02** (仓耳今楷02) | `TsangerJinKai02-W04.ttf` (regular) · `TsangerJinKai02-W05.ttf` (medium) | Chinese text | **Free for personal use only.** [Tsanger Foundry license](https://tsanger.cn). Commercial work requires a paid license. |
| **XCharter** | shipped with TeX Live as `xcharter` package | Latin text | SIL Open Font License (OFL). |

XCharter is automatic if you have a recent TeX Live or MiKTeX install — no action needed.

TsangerJinKai02 must be obtained separately. Two options:

## Option 1 — auto-download (recommended)

```bash
bash fonts/fetch.sh
```

The script downloads `TsangerJinKai02-W04.ttf` and `TsangerJinKai02-W05.ttf` from the
[Kami project's CDN mirrors](https://github.com/tw93/kami) into this directory. Total ~30 MB.
It uses `curl` when available and falls back to `wget`.

The `inkumo` class auto-detects local fonts in `fonts/` and uses them directly — no system install required.

## Option 2 — install system-wide

If you prefer to install TsangerJinKai02 once and reuse across projects:

| OS | Steps |
|---|---|
| macOS | Open `TsangerJinKai02-W04.ttf` and `TsangerJinKai02-W05.ttf` in Font Book → *Install Font* |
| Linux | `mkdir -p ~/.local/share/fonts/Tsanger && cp *.ttf ~/.local/share/fonts/Tsanger/ && fc-cache -fv` |
| Windows | Right-click each `.ttf` → *Install for all users* |

After a system install, the `fonts/` directory can stay empty — the class falls back to fontconfig.

## License notice

TsangerJinKai02 is **free for personal use only**. If you use this resume template for any
commercial activity (paid client work, monetised channels, sale of a service that uses the
font, etc.), you must purchase a Tsanger commercial license from <https://tsanger.cn> or
substitute another CJK serif. The class makes substitution easy:

```latex
% in inkumo.cls — replace TsangerJinKai02 with your alternative
\setCJKmainfont{Source Han Serif SC}[
  UprightFont=*-Regular,
  BoldFont=*-Medium,
  ...
]
```

Source Han Serif SC (思源宋体), Noto Serif CJK SC, and Songti SC are all reasonable substitutes.

## Why not download into the repo?

`fonts/*.ttf` is gitignored by default. Fonts are personal-license artifacts; bundling
them in a public repo would be re-distribution. Each user fetches their own copy via
`fonts/fetch.sh` (or installs system-wide).
