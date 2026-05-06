%% inkumo.cls — Museum-aesthetic resume class implementing the Kami design system.
%%
%% Direction: warm parchment canvas, ink-blue accent, serif carries hierarchy,
%% dotted hairlines, no italic, weights locked at 400/500. Print-first.
%%
%% Design tokens reproduce github.com/tw93/kami exactly.
%% Compile: xelatex resume.tex     (XeLaTeX is mandatory — xeCJK + fontspec)
%% Fonts:   TsangerJinKai02 (CJK, free for personal non-commercial use)
%%          XCharter (Latin, Bitstream Charter-derived, ships with TeX Live)

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{inkumo}[2026/05/05 v0.1.0 Inkumo - Kami-system resume class]

%% ======================================================================
%% Engine check
%% ======================================================================
\RequirePackage{iftex}
\ifXeTeX\else
  \ClassError{inkumo}{Inkumo requires XeLaTeX. Run: xelatex resume.tex}{}%
\fi

%% ======================================================================
%% Base class
%% ======================================================================
\LoadClass[10pt,a4paper]{article}

%% ======================================================================
%% Packages
%% ======================================================================
\RequirePackage[a4paper, top=11mm, bottom=11mm, left=13mm, right=13mm]{geometry}
\RequirePackage{xcolor}
\RequirePackage{pagecolor}
\RequirePackage{lastpage}
\RequirePackage{refcount}
\RequirePackage{fontspec}
\RequirePackage{xeCJK}
\RequirePackage{fontawesome5}
\RequirePackage{enumitem}
\RequirePackage{etoolbox}
\RequirePackage{xparse}
\RequirePackage{xstring}
\RequirePackage{needspace}
\RequirePackage{tabularx}
\RequirePackage{array}
\RequirePackage{tikz}
\RequirePackage[hidelinks]{hyperref}
\RequirePackage[
  protrusion=true,
  expansion=false,
  tracking=false,
  kerning=false,
  spacing=false
]{microtype}

%% ======================================================================
%% Color palette — Kami design tokens (locked)
%% ======================================================================
\definecolor{kami@parchment}{HTML}{F5F4ED}
\definecolor{kami@ivory}{HTML}{FAF9F5}
\definecolor{kami@sand}{HTML}{E8E6DC}
\definecolor{kami@border}{HTML}{E8E6DC}
\definecolor{kami@bordersoft}{HTML}{E5E3D8}
\definecolor{kami@nearblack}{HTML}{141413}
\definecolor{kami@darkwarm}{HTML}{3D3D3A}
\definecolor{kami@olive}{HTML}{504E49}
\definecolor{kami@stone}{HTML}{6B6A64}
\definecolor{kami@brand}{HTML}{1B365D}
\definecolor{kami@brandlight}{HTML}{2D5A8A}
\definecolor{kami@brandtint}{HTML}{EEF2F7}
\definecolor{kami@brandtintstrong}{HTML}{E4ECF5}
\definecolor{kami@headerline}{HTML}{E3BAA9} % warm peach header divider — a Kami signature

%% Public-facing aliases so users may reference colors in their content
\colorlet{InkBlue}{kami@brand}
\colorlet{InkBlueLight}{kami@brandlight}
\colorlet{Parchment}{kami@parchment}
\colorlet{NearBlack}{kami@nearblack}
\colorlet{Olive}{kami@olive}
\colorlet{Stone}{kami@stone}

%% ======================================================================
%% Page background & link styling
%% ======================================================================
\pagecolor{kami@parchment}
\pagestyle{empty}

\hypersetup{
  colorlinks=true,
  urlcolor=kami@brand,
  linkcolor=kami@brand,
  citecolor=kami@brand,
  pdfborderstyle={/S/U/W 0},
  pdftitle={Inkumo Resume},
  pdfcreator={Inkumo},
  pdfproducer={LaTeX with the inkumo class},
}

\newcommand{\inkumo@author}{}
\newcommand{\inkumo@twodigits}[1]{\ifnum#1<10 0\fi\number#1}
\newcommand{\inkumo@compiledate}{%
  \number\year-\inkumo@twodigits{\month}-\inkumo@twodigits{\day}%
}
\newcommand{\inkumo@footersep}{%
  \hspace{0.45em}{\color{kami@stone}\raisebox{0.26ex}{\rule{1.2pt}{1.2pt}}}\hspace{0.45em}%
}
\newcommand{\inkumo@writeicon}{{\color{kami@brandlight}\faPenNib}}

\AddToHook{shipout/foreground}{%
  \begin{tikzpicture}[remember picture, overlay]
    \node[anchor=south, inner sep=0pt] at ([yshift=5mm]current page.south) {%
      {\fontsize{8pt}{10pt}\selectfont\color{kami@stone}\tnum{\thepage/\pageref*{LastPage}}}%
    };%
    \ifnum\value{page}=\getpagerefnumber{LastPage}%
      \node[anchor=south west, inner sep=0pt] at ([xshift=13mm,yshift=5mm]current page.south west) {%
        {\fontsize{8pt}{10pt}\selectfont\color{kami@stone}%
          Copyright \textcopyright{} \inkumo@author\inkumo@footersep
          \inkumo@writeicon\hspace{0.28em}\inkumo@compiledate}%
      };%
    \fi
  \end{tikzpicture}%
}

%% ======================================================================
%% Fonts
%% TsangerJinKai02 (CJK): try local fonts/ first, then system fontconfig.
%% XCharter (Latin): TeX Live default — no manual install needed.
%% Italic is forbidden by Kami invariant #10; the class never invokes \itshape.
%% ======================================================================

% English: XCharter
\setmainfont{XCharter}[
  Ligatures=TeX,
  Numbers={Lining, Tabular},
  ItalicFont=*-Italic,
  BoldFont=*-Bold,
  BoldItalicFont=*-BoldItalic,
]

% Mono: Latin Modern Mono Light (ships with TeX Live), with real bold so
% \texttt inside bold project titles does not fall back noisily.
\setmonofont{lmmonolt10-regular.otf}[
  BoldFont=lmmonolt10-bold.otf,
  Scale=0.92,
]

% Chinese: TsangerJinKai02 — UprightFont=W04 (regular), BoldFont=W05 (medium)
% LetterSpace ≈ 3 corresponds to ~0.3pt at 9.2pt body, satisfying Kami spec
\IfFileExists{./fonts/TsangerJinKai02-W04.ttf}{%
  \setCJKmainfont{TsangerJinKai02}[%
    Path=./fonts/, Extension=.ttf,
    UprightFont=*-W04, BoldFont=*-W05,
    AutoFakeBold=false, AutoFakeSlant=false,
    LetterSpace=3.0,
  ]%
  \setCJKsansfont{TsangerJinKai02}[%
    Path=./fonts/, Extension=.ttf,
    UprightFont=*-W04, BoldFont=*-W05,
    AutoFakeBold=false, AutoFakeSlant=false,
    LetterSpace=3.0,
  ]%
  \setCJKmonofont{TsangerJinKai02}[%
    Path=./fonts/, Extension=.ttf,
    UprightFont=*-W04, BoldFont=*-W05,
    AutoFakeBold=false, AutoFakeSlant=false,
    LetterSpace=0.0,
  ]%
}{%
  \setCJKmainfont{TsangerJinKai02}[%
    UprightFont=*-W04, BoldFont=*-W05,
    AutoFakeBold=false, AutoFakeSlant=false,
    LetterSpace=3.0,
  ]%
  \setCJKsansfont{TsangerJinKai02}[%
    UprightFont=*-W04, BoldFont=*-W05,
    AutoFakeBold=false, AutoFakeSlant=false,
    LetterSpace=3.0,
  ]%
  \setCJKmonofont{TsangerJinKai02}[%
    UprightFont=*-W04, BoldFont=*-W05,
    AutoFakeBold=false, AutoFakeSlant=false,
    LetterSpace=0.0,
  ]%
}

% xeCJK: tighter Chinese-Western glue, plain punctuation
\xeCJKsetup{
  CJKecglue   = {\hskip 0.06em plus 0.03em},
  PunctStyle  = plain,
  CJKmath     = false,
}

%% Microtype — XeTeX supports protrusion only.
%% Keep this in package options above: pre-document `activate=...` also enables
%% expansion before microtype's XeTeX guard is installed.

%% ======================================================================
%% Typography baseline — 9.2pt / 13pt, paragraph rhythm
%% ======================================================================
\renewcommand{\normalsize}{\fontsize{9.2pt}{13pt}\selectfont}
\normalsize
\setlength{\baselineskip}{13pt}
\setlength{\parskip}{2pt plus 0.4pt minus 0.2pt}
\setlength{\parindent}{0pt}
\AtBeginDocument{\color{kami@nearblack}\normalsize}

% Floor: never let widows or orphans fragment a section
\widowpenalty=10000
\clubpenalty=10000
\raggedbottom

%% ======================================================================
%% Inline emphasis primitives
%%   \hl{...}        — single-figure brand highlight (≤5% surface rule)
%%   \emaccent{...}  — strong accent, brand color, weight 500
%%   \mute{...}      — secondary text in olive
%%   \tertiary{...}  — tertiary text in stone
%%   \sep / \dotsep  — fixed-size separator with stable spacing
%%   \contactsep     — slightly wider separator for the header contact strip
%%   \pipesep        — vertical-pipe separator (rare)
%% ======================================================================
\newcommand{\hl}[1]{{\color{kami@brand}#1}}
\newcommand{\emaccent}[1]{{\color{kami@brand}\bfseries #1}}
\newcommand{\mute}[1]{{\color{kami@olive}#1}}
\newcommand{\tertiary}[1]{{\color{kami@stone}#1}}
\newcommand{\inkumo@dot}{%
  {\color{kami@stone}\raisebox{0.18ex}{\fontsize{4.3pt}{4.3pt}\selectfont\textbullet}}%
}
\newcommand{\sep}{\nobreak\hspace{0.42em}\inkumo@dot\hspace{0.42em}\ignorespaces}
\newcommand{\contactsep}{\nobreak\hspace{0.56em}\inkumo@dot\hspace{0.56em}\ignorespaces}
\let\dotsep\sep
\newcommand{\pipesep}{\,{\color{kami@stone}|}\,}
\newcommand{\ContactItem}[2]{\PIcon{#1}\hspace{0.22em}#2}
\newcommand{\Tech}[2]{\PIcon{#1}\hspace{0.18em}#2}
\newcommand{\cplusplus}{\mbox{C\kern-0.03em+\kern-0.16em+}}

%% Neutralize \emph and \textit so accidental usage cannot produce italic
%% (Kami invariant #10). Both fall back to brand color, like \hl.
\renewcommand{\emph}[1]{{\color{kami@brand}#1}}
\let\textit\emph

%% Tabular numbers — for dates, ranks, GPAs
\newcommand{\tnum}[1]{{\addfontfeatures{Numbers={Tabular}}#1}}
\newcommand{\inkumo@flowrow}[3]{%
  \begin{minipage}[t]{\dimexpr\linewidth-#1-2mm\relax}\raggedright
    #2%
  \end{minipage}%
  \hfill
  \begin{minipage}[t]{#1}\raggedleft
    #3%
  \end{minipage}%
}

%% ======================================================================
%% Hairlines
%%   \entryleadline   — full-width blue hairline before a section's first entry
%%   \dottedhairline  — dashed leader in border        (between data rows)
%%   \warmhairline    — 0.5pt peach (kami@headerline)  (under header only)
%% ======================================================================
\newcommand{\entryleadline}{%
  \par\addvspace{0.25mm}%
  {\color{kami@brandlight!36!kami@border}\noindent\rule{\linewidth}{0.4pt}}%
  \par\addvspace{0.35mm}%
}
\newcommand{\dottedhairline}{%
  \par\addvspace{0.8mm}%
  \noindent
  \makebox[0pt][l]{\tikz{%
    \draw[
      dash pattern={on 0.4pt off 1.6pt},
      color=kami@border,
      line width=0.5pt,
      line cap=round,
    ] (0,0) -- (\linewidth,0);%
  }}%
  \par\addvspace{0.5mm}%
}
\newcommand{\educationhairline}{%
  \par\addvspace{0.25mm}%
  \noindent
  \makebox[0pt][l]{\tikz{%
    \draw[
      dash pattern={on 0.35pt off 1.75pt},
      color=kami@border,
      line width=0.45pt,
      line cap=round,
    ] (0,0) -- (\linewidth,0);%
  }}%
  \par\addvspace{0.65mm}%
}
\newcommand{\warmhairline}{%
  \par\addvspace{1.2mm}%
  {\color{kami@headerline}\noindent\rule{\linewidth}{0.5pt}}%
  \par\addvspace{1.5mm}%
}

%% ======================================================================
%% Section title — 2.5pt brand left bar + serif 500 title (12.5pt)
%% Optional right-aligned sub-text in stone (e.g. date span).
%%
%%   \inkumosection{Title}
%%   \inkumosection{Title}[Optional right sub]
%%
%% No section icons by default — Kami uses the bar for editorial restraint.
%% Users wanting a glyph can prepend manually: \inkumosection{\PIcon{...}\,Title}
%%
%% Each call also resets the project/campus "first entry" flags so that any
%% \Project / \Campus that follows draws its leading solid hairline correctly.
%% ======================================================================
\newif\if@inkumo@firstproject
\newif\if@inkumo@firstcampus
\newif\if@inkumo@firstedu
\@inkumo@firstprojecttrue
\@inkumo@firstcampustrue
\@inkumo@firstedutrue

\NewDocumentCommand{\inkumosection}{m o}{%
  \@inkumo@firstprojecttrue
  \@inkumo@firstcampustrue
  \@inkumo@firstedutrue
  \Needspace{22mm}%
  \par\addvspace{4.5mm}%
  \noindent
  \IfValueTF{#2}{%
    \inkumo@flowrow{46mm}{%
      \raisebox{-2.5pt}[12pt][2.5pt]{\textcolor{kami@brand}{\rule{2.5pt}{14pt}}}%
      \hspace{7pt}%
      {\fontsize{12.5pt}{15pt}\selectfont\bfseries\color{kami@nearblack}#1}
    }{%
      {\fontsize{9pt}{11pt}\selectfont\color{kami@stone}#2}
    }%
  }{%
    \hangindent=9.5pt
    \hangafter=1
    \raisebox{-2.5pt}[12pt][2.5pt]{\textcolor{kami@brand}{\rule{2.5pt}{14pt}}}%
    \hspace{7pt}%
    {\fontsize{12.5pt}{15pt}\selectfont\bfseries\color{kami@nearblack}#1}%
  }%
  \par\addvspace{2mm}%
}

%% ======================================================================
%% Brand-tint role pill — used in the Project header.
%% Solid hex background (Kami invariant #8: never rgba; LaTeX has no
%% double-rectangle bug, but we keep solid for parity with the HTML system).
%% ======================================================================
\newcommand{\rolepill}[1]{%
  \tikz[baseline=(t.base)]{%
    \node[
      fill=kami@brandtint,
      draw=kami@brandlight!28!kami@border,
      line width=0.25pt,
      rounded corners=1.6pt,
      inner xsep=4.2pt, inner ysep=1.25pt,
      text=kami@brand,
      font={\fontsize{8.5pt}{10pt}\selectfont\bfseries},
      outer sep=0pt,
    ] (t) {#1};%
  }%
}

%% ======================================================================
%% Header
%%
%%   \inkumoheader{Name}
%%     [English alias]                   ← optional alias next to name
%%     {Contact line composed inline}
%%     [Right-aligned role/title]        ← optional, brand color
%%     [Summary paragraph]                ← optional
%%
%% The contact line is freeform. Use \ContactItem{phone}{...}\contactsep ...
%% inside it; see lib/icons.tex for the full glyph registry.
%% ======================================================================
\NewDocumentCommand{\inkumoheader}{m o m o o}{%
  \gdef\inkumo@author{#1}%
  \hypersetup{pdfauthor={#1}}%
  \par\noindent
  \inkumo@flowrow{54mm}{%
    {\fontsize{26pt}{28pt}\selectfont\bfseries\color{kami@nearblack}#1}%
    \IfValueT{#2}{%
      \hspace{2.6mm}%
      {\fontsize{13pt}{16pt}\selectfont\color{kami@stone}#2}%
    }%
  }{%
    \IfValueT{#4}{%
      {\fontsize{10.5pt}{13pt}\selectfont\bfseries\color{kami@brand}#4}%
    }%
  }%
  \par\vspace{2.2mm}%
  %% Contact line
  \noindent
  {\fontsize{9.2pt}{12.5pt}\selectfont\color{kami@stone}#3}%
  \par\vspace{0.6mm}%
  %% Optional summary
  \IfValueT{#5}{%
    \par\addvspace{1.6mm}%
    \noindent
    {\fontsize{9.2pt}{13.2pt}\selectfont\color{kami@nearblack}#5}%
    \par\addvspace{0.4mm}%
  }%
  \warmhairline
}

%% ======================================================================
%% Metric strip (optional, museum-art touch)
%%   \inkumometrics{
%%     \metric{12+}{years experience}
%%     \metric{40k}{GitHub stars}
%%     \metric{6}{shipped products}
%%     \metric{3}{open-source flagships}
%%   }
%% ======================================================================
\newcommand{\metric}[2]{%
  \begin{minipage}[t]{\dimexpr0.245\linewidth-2mm\relax}\raggedright
    {\fontsize{14.5pt}{16pt}\selectfont\bfseries\color{kami@brand}\tnum{#1}}\par
    \vspace{0.3mm}%
    {\fontsize{8.6pt}{11pt}\selectfont\color{kami@olive}#2}%
  \end{minipage}%
}
\newcommand{\inkumometrics}[1]{%
  \par\addvspace{0.6mm}%
  \noindent #1
  \par\addvspace{1mm}%
}

%% ======================================================================
%% Education
%%   \Edu{2020.09 — 2024.06}{某某大学}{某某学院\sep 某某专业}{GPA 3.9 / 4.0\sep Rank 1\%}
%%
%% Stacked dates can be passed by inserting \\ inside #1.
%% ======================================================================
\NewDocumentCommand{\Edu}{m m m o}{%
  \if@inkumo@firstedu
    \@inkumo@firstedufalse
  \else
    \educationhairline
  \fi
  \par\addvspace{0.6mm}%
  \noindent
  \begin{minipage}[t]{19mm}\raggedright
    {\fontsize{9pt}{12pt}\selectfont\color{kami@stone}\tnum{#1}}%
  \end{minipage}\hspace{2.5mm}%
  \begin{minipage}[t]{\dimexpr\linewidth-21.5mm\relax}\raggedright
    {\fontsize{10.5pt}{13.5pt}\selectfont\bfseries\color{kami@nearblack}#2}%
    {\fontsize{9.5pt}{13pt}\selectfont\color{kami@olive}\sep #3}%
    \IfValueT{#4}{%
      \par\vspace{0.4mm}%
      {\fontsize{9pt}{12pt}\selectfont\color{kami@olive}#4}%
    }%
  \end{minipage}%
  \par\addvspace{0.6mm}%
}

%% ======================================================================
%% Skills — tier label (brand) + body (near-black) + dotted separator
%%   \Skill{掌握}{React, JavaScript, Python}
%% ======================================================================
\NewDocumentCommand{\Skill}{m m}{%
  \par\noindent
  \begin{minipage}[t]{20mm}\raggedright
    {\fontsize{9.5pt}{12pt}\selectfont\bfseries\color{kami@brand}#1}%
  \end{minipage}\hspace{2mm}%
  \begin{minipage}[t]{\dimexpr\linewidth-22mm\relax}\raggedright
    {\fontsize{9.5pt}{13pt}\selectfont\color{kami@nearblack}#2}%
  \end{minipage}%
  \par\addvspace{0.5mm}%
  \dottedhairline
}

%% ======================================================================
%% Awards — title (bold near-black), level (olive), date (stone, right)
%%   \Award{互联网+ 大学生创新创业大赛}{省级金奖}{2022.10}
%% ======================================================================
\NewDocumentCommand{\Award}{m m m}{%
  \par\noindent
  \inkumo@flowrow{22mm}{%
    {\fontsize{10pt}{13pt}\selectfont\bfseries\color{kami@nearblack}#1}%
    {\fontsize{9.5pt}{13pt}\selectfont\color{kami@darkwarm}\sep #2}%
  }{%
    {\fontsize{9pt}{12pt}\selectfont\color{kami@stone}\tnum{#3}}%
  }%
  \par\addvspace{0.5mm}%
  \dottedhairline
}

%% ======================================================================
%% Project entry
%%   \Project{Name}{Type}{Date}            — name + type + right-aligned date
%%   \Project{Name}{Type}[Role]{Date}      — same + role-pill between
%%
%% Use these inside the project block:
%%   \Stack{Golang, Docker, Kubernetes}     — tech stack line, brand color
%%   \Desc{基于 Kubernetes 的容器管理平台...}— description paragraph
%%   \begin{Bullets}\item ... \end{Bullets} — brand-bar bullet list
%%
%% The first \Project after a section draws a full-width blue hairline.
%% (The if@inkumo@firstproject flag is declared once near \inkumosection,
%% along with the matching campus flag; do not redeclare here.)
%% ======================================================================
\NewDocumentCommand{\Project}{m m o m}{%
  \Needspace{46mm}%
  \par
  \if@inkumo@firstproject
    \entryleadline
    \@inkumo@firstprojectfalse
  \else
    \par\addvspace{1.5mm}%
    \dottedhairline
  \fi
  \noindent
  \inkumo@flowrow{34mm}{%
    {\fontsize{11pt}{13.5pt}\selectfont\bfseries\color{kami@nearblack}#1}%
    {\fontsize{10pt}{13.5pt}\selectfont\color{kami@olive}\sep #2}%
    \IfValueT{#3}{\hspace{2mm}\rolepill{#3}}%
  }{%
    {\fontsize{9pt}{12pt}\selectfont\color{kami@stone}\tnum{#4}}%
  }%
  \par\vspace{0.25mm}%
}

\newcommand{\Stack}[1]{%
  \par
  {\fontsize{9pt}{12.5pt}\selectfont\color{kami@brandlight}#1}%
  \par\vspace{0.25mm}%
}

\newcommand{\Desc}[1]{%
  \par
  {\fontsize{9.2pt}{13pt}\selectfont\color{kami@nearblack}#1}%
  \par\vspace{0.25mm}%
}

%% Brand-bar bullet list (8pt × 1.2pt brand bar marker — Kami value-anchors)
\newenvironment{Bullets}{%
  \begin{itemize}[%
    label={\raisebox{0.16ex}{\textcolor{kami@brand}{\fontsize{5pt}{5pt}\selectfont\textbullet}}},%
    leftmargin=13pt,
    itemsep=0.4pt,
    topsep=1.5pt,
    parsep=0pt,
    partopsep=0pt,
    labelsep=6pt,
  ]
  \fontsize{9.2pt}{13pt}\selectfont\color{kami@nearblack}%
}{%
  \end{itemize}%
}

%% ======================================================================
%% Campus / Extracurricular — same shape as Project but a bit lighter
%%   \Campus{Title}{Role}{Date}
%% (firstcampus flag is declared once near \inkumosection.)
%% ======================================================================
\NewDocumentCommand{\Campus}{m m m}{%
  \Needspace{18mm}%
  \par
  \if@inkumo@firstcampus
    \entryleadline
    \@inkumo@firstcampusfalse
  \else
    \par\addvspace{1.2mm}%
    \dottedhairline
  \fi
  \noindent
  \inkumo@flowrow{34mm}{%
    {\fontsize{10.5pt}{13pt}\selectfont\bfseries\color{kami@nearblack}#1}%
    {\fontsize{9.5pt}{13pt}\selectfont\color{kami@olive}\sep #2}%
  }{%
    {\fontsize{9pt}{12pt}\selectfont\color{kami@stone}\tnum{#3}}%
  }%
  \par\vspace{0.25mm}%
}

%% ======================================================================
%% Helpers users may call directly
%%   \Quote{...}     — editorial pull quote, brand left border
%% ======================================================================
\newcommand{\Quote}[1]{%
  \par\addvspace{1.5mm}%
  \noindent
  \begin{minipage}[t]{1.4pt}
    \textcolor{kami@brand}{\rule[-3pt]{1.4pt}{14pt}}%
  \end{minipage}%
  \hspace{6.6pt}%
  \begin{minipage}[t]{\dimexpr\linewidth-8pt\relax}\raggedright
    {\fontsize{9.2pt}{13.2pt}\selectfont\color{kami@olive}#1}%
  \end{minipage}%
  \par\addvspace{1.2mm}%
}

%% ======================================================================
%% Flourish — small brand square as an optional terminal mark.
%% (Avoid names starting with \end... — LaTeX reserves them for environment
%% closers, even when no matching environment exists.)
%% ======================================================================
\newcommand{\flourish}{%
  \par\vspace{2mm}%
  \noindent\hfill\textcolor{kami@brand}{\rule{4pt}{4pt}}%
  \par
}

\endinput
