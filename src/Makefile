MKOCTFILE ?= mkoctfile -Wall

## We can't link oct files, and Octave's package system does not handle
## shared libraries. Because of this, we need to create object files for
## our "shared" libraries and statically link to selected oct files.

conn_dependent = conndef.oct bwlabeln.oct
strel_dependent = imerode.oct
libs = connectivity.o strel.o

all: __spatial_filtering__.oct __bilateral__.oct __custom_gaussian_smoothing__.oct \
	__boundary__.oct bwfill.oct rotate_scale.oct hough_line.oct \
	graycomatrix.oct bwdist.oct nonmax_supress.oct \
	$(strel_dependent) $(conn_dependent)

%.o: %.cc
	$(MKOCTFILE) -c $<

## Actually, only bwlabeln needs c++0x
$(conn_dependent): %.oct: %.cc connectivity.o
	CXXFLAGS=$$($(MKOCTFILE) -p CXXFLAGS)' -std=c++0x' $(MKOCTFILE) $^

$(strel_dependent): %.oct: %.cc strel.o
	$(MKOCTFILE) $^

%.oct: %.cc
	$(MKOCTFILE) $<

clean:
	rm -f *.o octave-core core *.oct *~

