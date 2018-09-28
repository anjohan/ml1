all: report.pdf
	mkdir -p build && cd build && cmake .. && make

deps = sources.bib figs/franke.pdf

%.pdf: %.tex $(deps)
	latexmk -pdflua -time -shell-escape $*

%.pdf: %.asy
	asy -maxtile "(400,400)" -o $@ $<

clean:
	latexmk -c
	rm -rf *.run.xml *.bbl build
