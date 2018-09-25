all: report.pdf

deps = sources.bib franke.pdf

%.pdf: %.tex $(deps)
	latexmk -pdflua -time -shell-escape $*

%.pdf: %.asy
	asy -maxtile "(400,400)" $<

clean:
	latexmk -c
	rm -rf *.run.xml
