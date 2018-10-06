sources = $(shell find -name "*.f90")
SHELL := /usr/bin/bash
methods = OLS Ridge LASSO
verification_figs = $(foreach method,$(methods),figs/verification_$(method).pdf)

all:
	make build
	make report.pdf
	make uml.svg

build: $(sources)
	mkdir -p build && cd build && cmake -DCMAKE_BUILD_TYPE=Release .. && make

.PRECIOUS: $(verification_figs)

deps = sources.bib figs/franke.pdf data/verification_beta_OLS.dat data/verification_mean_beta_sklearn.dat $(verification_figs)

%.pdf: %.tex $(deps) lib/lasso.f90
	latexmk -pdflua -time -shell-escape $*

%.pdf: %.asy
	asy -maxtile "(400,400)" -o $@ $<

%.svg: %.pdf report.pdf
	pdf2svg $< $@

figs/verification_%.pdf: figs/verification.asy data/verification_beta_OLS.dat
	asy -maxtile "(400,400)" -o $@ - <<< $$(echo 'string method = "$*";'; cat $<)

data/verification_beta_OLS.dat: build/verification
	./$<

data/verification_mean_beta_sklearn.dat: programs/lasso.py
	python $<


clean:
	latexmk -c
	rm -rf *.run.xml *.bbl build
	find -name "*.mod" -delete
