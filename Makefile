sinclude ../../Makeconf
sinclude ../../pkg.mk

PKG_FILES = $(patsubst %,image/%, COPYING DESCRIPTION INDEX \
	$(wildcard devel/*) $(wildcard inst/*) $(wildcard src/*))
