MKOCTFILE ?= mkoctfile -Wall

all: __spatial_filtering__.oct __bilateral__.oct __custom_gaussian_smoothing__.oct \
	__boundary__.oct bwfill.oct rotate_scale.oct hough_line.oct \
	graycomatrix.oct bwdist.oct nonmax_supress.oct bwlabeln.oct imerode.oct

%.oct: %.cc
	$(MKOCTFILE) $<

bwlabeln.oct: bwlabeln.cc union-find.h++
	CXXFLAGS='-g -O2 -std=c++0x -Wall' $(MKOCTFILE) $<

imerode.oct: imerode.cc strel.cc
	$(MKOCTFILE) $^ -o $@

clean:
	rm -f *.o octave-core core *.oct *~
