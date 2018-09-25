all: report.pdf

deps = sources.bib

%.pdf: %.tex $(deps)
	latexmk -pdflua -time -shell-escape $*
