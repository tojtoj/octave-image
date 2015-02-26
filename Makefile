PACKAGE = $(shell grep "^Name: " DESCRIPTION | cut -f2 -d" ")
VERSION = $(shell grep "^Version: " DESCRIPTION | cut -f2 -d" ")

RELEASE_DIR     = $(PACKAGE)-$(VERSION)
RELEASE_TARBALL = $(PACKAGE)-$(VERSION).tar.gz
HTML_DIR        = $(PACKAGE)-html
HTML_TARBALL    = $(PACKAGE)-html.tar.gz

M_SOURCES   = $(wildcard inst/*.m)
CC_SOURCES  = $(wildcard src/*.cc)
OCT_FILES   = $(patsubst %.cc,%.oct,$(CC_SOURCES))
PKG_ADD     = $(shell grep -Pho '(?<=// PKG_ADD: ).*' $(CC_SOURCES) $(M_SOURCES))

OCTAVE ?= octave

.PHONY: help dist html release install all check run clean

help:
	@echo "Targets:"
	@echo "   dist    - Create $(RELEASE_TARBALL) for release"
	@echo "   html    - Create $(HTML_TARBALL) for release"
	@echo "   release - Create both of the above and show md5sums"
	@echo
	@echo "   install - Install the package in GNU Octave"
	@echo "   all     - Build all oct files
	@echo "   check   - Execute package tests (w/o install)"
	@echo "   run     - Run Octave with development in PATH (no install)"
	@echo
	@echo "   clean   - Remove releases, html documentation, and oct files"

$(RELEASE_DIR): .hg/dirstate
	@echo "Creating package version $(VERSION) release ..."
	hg archive --exclude ".hg*" --exclude "Makefile" --type files "$@"
	cd "$@" && rm -rf "devel/" && ./bootstrap && rm -rf "src/autom4te.cache"

$(RELEASE_TARBALL): $(RELEASE_DIR)
	tar -czf "$@" "$<"

$(HTML_TARBALL): install
	@echo "Generating HTML documentation. This may take a while ..."
	$(OCTAVE) --silent --eval 'pkg load generate_html; '\
	'generate_package_html ("${PACKAGE}", "${HTML_DIR}", "octave-forge")'
	tar -czf "$@" "$(PACKAGE)-html"

dist: $(RELEASE_TARBALL)
html: $(HTML_TARBALL)

release: dist html md5
	md5sum $(RELEASE_TARBALL) $(HTML_TARBALL)
	@echo "Upload @ https://sourceforge.net/p/octave/package-releases/new/"
	@echo "Execute: hg tag \"release-$(VERSION)\"" 

install: $(RELEASE_TARBALL)
	@echo "Installing package locally ..."
	$(OCTAVE) --silent --eval 'pkg ("install", make"${RELEASE_TARBALL}")'

all: $(CC_SOURCES)
	cd src/ && ./configure
	$(MAKE) -C src/

check: all
	$(OCTAVE) --no-window-system --silent --eval 'addpath ("inst/"); '\
	'addpath ("src/"); ${PKG_ADD} runtests ("inst/"); runtests ("src/");'

run: all
	$(OCTAVE) --no-window-system --silent --persist --eval \
	'addpath ("inst/"); addpath ("src/"); ${PKG_ADD}'

clean:
	rm -rf $(RELEASE_DIR) $(RELEASE_TARBALL) $(HTML_TARBALL) $(HTML_DIR)
	test -e src/Makefile && $(MAKE) -C src clean

