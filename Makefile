include ../../Makeconf

ifdef HAVE_JPEG
	JPEG=jpgwrite.oct jpgread.oct
endif

all: conv2.oct cordflt2.oct bwlabel.oct bwfill.oct rotate_scale.oct $(JPEG)

jpgread.oct: jpgread.cc
	$(MKOCTFILE) $< -ljpeg

jpgwrite.oct: jpgwrite.cc
	$(MKOCTFILE) $< -ljpeg

clean: ; -$(RM) *.o octave-core core *.oct *~
