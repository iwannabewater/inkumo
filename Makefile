# Inkumo build commands
#
#   make            -> compile resume.tex with xelatex (two passes)
#   make setup      -> fetch local fonts and icon fonts
#   make watch      -> live rebuild on file change (needs latexmk)
#   make fonts      -> download TsangerJinKai02 into fonts/
#   make icons      -> download Devicon and Simple Icons into assets/
#   make lint       -> validate source invariants without a TeX runtime
#   make test       -> build and validate the rendered PDF
#   make clean      -> remove LaTeX byproducts
#   make distclean  -> remove byproducts and the rendered PDF; keep local assets

TEX        := xelatex
LATEXMK    := latexmk
MAIN       := resume
SRC        := $(MAIN).tex
PDF        := $(MAIN).pdf
LOG        := $(MAIN).log
SECTIONS   := $(wildcard content/*.tex) $(wildcard lib/*.tex) inkumo.cls

XELATEX_FLAGS := -interaction=nonstopmode -halt-on-error -file-line-error

.PHONY: all setup watch fonts icons lint test clean distclean

all: $(PDF)

$(PDF): $(SRC) $(SECTIONS)
	$(TEX) $(XELATEX_FLAGS) $(SRC)
	$(TEX) $(XELATEX_FLAGS) $(SRC)

watch:
	$(LATEXMK) -xelatex -pvc -interaction=nonstopmode $(SRC)

setup: fonts icons

fonts:
	bash scripts/fetch-fonts.sh

icons:
	bash scripts/fetch-icons.sh

lint:
	bash scripts/check-source.sh

test: lint $(PDF)
	@if [ ! -s "$(LOG)" ]; then \
		echo "rebuild $(PDF): missing $(LOG)"; \
		$(MAKE) --no-print-directory -B "$(PDF)"; \
	fi
	bash scripts/check-pdf.sh

clean:
	rm -f *.aux *.log *.out *.toc *.fls *.fdb_latexmk *.synctex.gz *.xdv

distclean: clean
	rm -f $(PDF)
