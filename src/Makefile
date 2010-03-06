all: __spatial_filtering__.oct __bilateral__.oct __custom_gaussian_smoothing__.oct \
	__imboundary__.oct bwlabel.oct bwfill.oct rotate_scale.oct hough_line.oct \
	graycomatrix.oct deriche.oct __bwdist.oct nonmax_supress.oct

%.oct: %.cc
	mkoctfile -Wall $<

clean:
	rm -f *.o octave-core core *.oct *~
