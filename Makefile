DUNE   ?= jbuilder
PANDOC ?= pandoc

PACKAGE :=
VERSION := $(shell cat VERSION)

SOURCES :=

TARGETS := bin/describe bin/export

%.html: %.rst
	$(PANDOC) -o $@ -t html5 -s $<

all: build

_build/default/bin/describe.exe:
	$(DUNE) build bin/describe.exe

_build/default/bin/export.exe:
	$(DUNE) build bin/export.exe

bin/describe: _build/default/bin/describe.exe
	ln $< $@

bin/export: _build/default/bin/export.exe
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
