sinclude ../../Makeconf
sinclude ../../pkg.mk

PKG_FILES = COPYING DESCRIPTION INDEX $(wildcard devel/*) $(wildcard inst/*) \
	$(wildcard src/*)
