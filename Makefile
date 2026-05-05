# Inkumo — build commands
#
#   make            -> compile resume.tex with xelatex (two passes)
#   make watch      -> live rebuild on file change (needs latexmk)
#   make fonts      -> download TsangerJinKai02 into fonts/ (needs curl or wget)
#   make test       -> build and validate the rendered PDF
#   make clean      -> remove LaTeX byproducts
#   make distclean  -> remove byproducts and the rendered PDF

TEX        := xelatex
LATEXMK    := latexmk
MAIN       := resume
SRC        := $(MAIN).tex
PDF        := $(MAIN).pdf
SECTIONS   := $(wildcard content/*.tex) $(wildcard lib/*.tex) inkumo.cls

XELATEX_FLAGS := -interaction=nonstopmode -halt-on-error -file-line-error

.PHONY: all watch fonts test clean distclean

all: $(PDF)

$(PDF): $(SRC) $(SECTIONS)
	$(TEX) $(XELATEX_FLAGS) $(SRC)
	$(TEX) $(XELATEX_FLAGS) $(SRC)

watch:
	$(LATEXMK) -xelatex -pvc -interaction=nonstopmode $(SRC)

fonts:
	bash fonts/fetch.sh

test: $(PDF)
	bash scripts/check-pdf.sh

clean:
	rm -f *.aux *.log *.out *.toc *.fls *.fdb_latexmk *.synctex.gz *.xdv

distclean: clean
	rm -f $(PDF)
