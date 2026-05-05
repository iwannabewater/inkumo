$pdf_mode = 5;            # 5 = xelatex
$pdflatex = 'xelatex %O -interaction=nonstopmode -halt-on-error -file-line-error %S';
$bibtex_use = 0;
$clean_ext = 'aux log out toc fls fdb_latexmk synctex.gz xdv bcf run.xml';
@default_files = ('resume.tex');
