all: __spatial_filtering__.oct __bilateral__.oct __custom_gaussian_smoothing__.oct \
	__boundary__.oct bwlabel.oct bwfill.oct rotate_scale.oct hough_line.oct \
	graycomatrix.oct deriche.oct __bwdist.oct nonmax_supress.oct bwlabeln.oct

%.oct: %.cc
	mkoctfile -Wall $<

bwlabeln.oct: bwlabeln.cc
	CXXFLAGS='-g -O2 -std=c++0x -Wall' mkoctfile $<

clean:
	rm -f *.o octave-core core *.oct *~
