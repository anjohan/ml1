all: report.pdf uml.svg
	mkdir -p build && cd build && cmake -DCMAKE_BUILD_TYPE=Debug .. && make

deps = sources.bib figs/franke.pdf

%.pdf: %.tex $(deps) lib/lasso.f90
	latexmk -pdflua -time -shell-escape $*

%.pdf: %.asy
	asy -maxtile "(400,400)" -o $@ $<

%.svg: %.pdf report.pdf
	pdf2svg $< $@

clean:
	latexmk -c
	rm -rf *.run.xml *.bbl build
	find -name "*.mod" -delete
