sources = $(shell find -name "*.f90")
SHELL := /usr/bin/bash

all:
	make build
	make report.pdf
	make uml.svg

build: $(sources)
	mkdir -p build && cd build && cmake -DCMAKE_BUILD_TYPE=Debug .. && make

deps = sources.bib figs/franke.pdf data/verification_beta_OLS.dat

%.pdf: %.tex $(deps) lib/lasso.f90
	latexmk -pdflua -time -shell-escape $*

%.pdf: %.asy
	asy -maxtile "(400,400)" -o $@ $<

%.svg: %.pdf report.pdf
	pdf2svg $< $@

data/verification_beta_OLS.dat: build/verification
	./$<


clean:
	latexmk -c
	rm -rf *.run.xml *.bbl build
	find -name "*.mod" -delete
