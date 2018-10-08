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

deps = sources.bib figs/franke.pdf data/verification_beta_OLS.dat data/verification_mean_beta_sklearn.dat $(verification_figs) data/complexity.dat data/verification_bias_variance.dat data/verification_mse_r2.dat data/noise.dat data/r2_lambda.dat figs/geography.pdf data/geography_mse.dat figs/geography_approx.pdf

%.pdf: %.tex $(deps) lib/lasso.f90 lib/bootstrap.f90
	latexmk -pdflua -time -shell-escape $*

%.pdf: %.asy
	asy -maxtile "(400,400)" -o $@ $<


%.svg: %.pdf report.pdf
	pdf2svg $< $@

figs/verification_%.pdf: figs/verification.asy data/verification_beta_OLS.dat
	asy -maxtile "(400,400)" -o $@ - <<< $$(echo 'string method = "$*";'; cat $<)

figs/geography.pdf: figs/geography.asy data/geography.txt
	asy -maxtile "(400,400)" -o $@ $<

figs/geography_approx.pdf: figs/geography_approx.asy data/geography_mse.dat
	asy -maxtile "(400,400)" -o $@ $<

data/verification_beta_OLS.dat: build/verification
	./$<

data/verification_mean_beta_sklearn.dat: programs/lasso.py
	python $<

data/%.dat: build/%
	./$<

data/verification_bias_variance.dat: data/verification_mean_beta_sklearn.dat data/verification_beta_OLS.dat
	cp data/verification_bias_variance_ols_ridge.dat $@
	cat data/verification_bias_variance_lasso.dat >> $@

data/verification_mse_r2.dat: data/verification_mean_beta_sklearn.dat data/verification_beta_OLS.dat
	cp data/verification_mse_r2_ols_ridge.dat $@
	cat data/verification_mse_r2_lasso.dat >> $@

data/r2_lambda.dat: build/regularisation
	./$<

data/geography_mse.dat: build/geography data/geography.txt
	./$< < data/geography.txt

%.txt: %.tif tif2txt.py
	python tif2txt.py $< 0.01
data/geography.tif:
	wget -O data/geography.tif https://github.com/CompPhysics/MachineLearning/raw/master/doc/Projects/2018/Project1/DataFiles/SRTM_data_Norway_1.tif

clean:
	latexmk -c
	rm -rf *.run.xml *.bbl build
	find -name "*.mod" -delete
