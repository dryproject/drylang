DUNE   ?= jbuilder
PANDOC ?= pandoc

PACKAGE :=
VERSION := $(shell cat VERSION)

SOURCES :=

TARGETS := bin/dry

%.html: %.rst
	$(PANDOC) -o $@ -t html5 -s $<

all: build

_build/default/bin/dry.exe:
	$(DUNE) build bin/dry.exe

bin/dry: _build/default/bin/dry.exe
	ln $< $@

build: $(TARGETS)

check:
	$(DUNE) runtest

dist:
	@echo "not implemented"; exit 2 # TODO

install:
	@echo "not implemented"; exit 2 # TODO

uninstall:
	@echo "not implemented"; exit 2 # TODO

clean:
	@rm -f *~ $(TARGETS)
	$(DUNE) clean

distclean: clean

mostlyclean: clean

.PHONY: check dist install clean distclean mostlyclean
.SECONDARY:
.SUFFIXES:
