sinclude Makeconf

ifdef HAVE_JPEG
	JPEG=jpgwrite.oct jpgread.oct
endif

ifdef HAVE_PNG
	PNG=pngread.oct pngwrite.oct
endif

all: __spatial_filtering__.oct __bilateral__.oct __custom_gaussian_smoothing__.oct \
	__imboundary__.oct bwlabel.oct bwfill.oct rotate_scale.oct hough_line.oct \
	graycomatrix.oct deriche.oct __bwdist.oct nonmax_supress.oct \
	$(JPEG) $(PNG)

jpgread.oct: jpgread.cc
	$(MKOCTFILE) $< -ljpeg

jpgwrite.oct: jpgwrite.cc
	$(MKOCTFILE) $< -ljpeg

pngread.oct: pngread.cc
	$(MKOCTFILE) $< -lpng

pngwrite.oct: pngwrite.cc
	$(MKOCTFILE) $< -lpng

clean: ; -$(RM) *.o octave-core core *.oct *~
