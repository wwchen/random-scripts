# template makefile for latex
TEXS := $(wildcard *.tex)
PDFS := $(patsubst %.tex,%.pdf,$(TEXS))
LOGS := $(patsubst %.tex,%.log,$(TEXS))
AUXS := $(patsubst %.tex,%.aux,$(TEXS))


all: $(PDFS)
  
%.pdf: %.tex
	pdflatex $<
	pdflatex $<

clean:
	rm -f $(LOGS) $(AUXS)

clean-pdf:
	rm -f $(PDFS)

.PHONY: clean all
