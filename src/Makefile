MKOCTFILE ?= mkoctfile -Wall

all: __spatial_filtering__.oct __bilateral__.oct __custom_gaussian_smoothing__.oct \
	__boundary__.oct bwlabel.oct bwfill.oct rotate_scale.oct hough_line.oct \
	graycomatrix.oct bwdist.oct nonmax_supress.oct bwlabeln.oct

%.oct: %.cc
	$(MKOCTFILE) $<

bwlabeln.oct: bwlabeln.cc union-find.h++
	CXXFLAGS='-g -O2 -std=c++0x -Wall' $(MKOCTFILE) $<

clean:
	rm -f *.o octave-core core *.oct *~
