MKOCTFILE ?= mkoctfile -Wall
OCTAVE ?= octave

## We can't link oct files, and Octave's package system does not handle
## shared libraries. Because of this, we need to create object files for
## our "shared" libraries and statically link to selected oct files.

conn_dependent = conndef.oct bwlabeln.oct imreconstruct.oct
strel_dependent = imerode.oct
libs = connectivity.o strel.o

OCT_FILES = __spatial_filtering__.oct __bilateral__.oct \
            __custom_gaussian_smoothing__.oct __boundary__.oct bwfill.oct \
            rotate_scale.oct hough_line.oct graycomatrix.oct bwdist.oct \
            nonmax_supress.oct $(strel_dependent) $(conn_dependent)

CC_FILES = $(patsubst %.oct, %.cc, ${OCT_FILES})

all: ${OCT_FILES}

%.o: %.cc
	$(MKOCTFILE) -c $<

$(conn_dependent): %.oct: %.cc connectivity.o
	CXXFLAGS=$$($(MKOCTFILE) -p CXXFLAGS)' -std=c++0x' $(MKOCTFILE) $^

$(strel_dependent): %.oct: %.cc strel.o
	$(MKOCTFILE) $^

%.oct: %.cc
	$(MKOCTFILE) $<

test: ${OCT_FILES}
	$(eval PKG_ADD = $(shell grep -Pho '(?<=// PKG_ADD: ).*' ${CC_FILES}))
	for FILE in $(CC_FILES); do \
		echo "Running tests from $${FILE}"; \
		$(OCTAVE) --no-window-system --silent --eval '${PKG_ADD} test '$${FILE}; \
	done

clean:
	rm -f *.o octave-core core *.oct *~

