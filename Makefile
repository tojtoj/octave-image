sinclude ../../Makeconf

ifdef HAVE_JPEG
	JPEG=jpgwrite.oct jpgread.oct
endif

ifdef HAVE_PNG
	PNG=pngread.oct pngwrite.oct
endif

all: conv2.oct cordflt2.oct bwlabel.oct bwfill.oct rotate_scale.oct \
	$(JPEG) $(PNG)

jpgread.oct: jpgread.cc
	$(MKOCTFILE) $< -ljpeg

jpgwrite.oct: jpgwrite.cc
	$(MKOCTFILE) $< -ljpeg

pngread.oct: pngread.cc
	$(MKOCTFILE) $< -lpng

pngwrite.oct:
	$(LN_S) pngread.oct $@

clean: ; -$(RM) *.o octave-core core *.oct *~
