OCTAVE ?= octave

CC_SOURCES = $(wildcard src/*.cc)
SUBDIRS = src

all: $(SUBDIRS)
	$(MAKE) -C $<

clean: $(SUBDIRS)
	$(MAKE) -C $< clean

check: all
	$(eval PKG_ADD = $(shell grep -Pho '(?<=// PKG_ADD: ).*' ${CC_SOURCES}))
	$(OCTAVE) --no-window-system --silent --eval 'addpath ("inst/"); '\
	'addpath ("src/"); ${PKG_ADD} runtests ("inst/"); runtests ("src/");'
