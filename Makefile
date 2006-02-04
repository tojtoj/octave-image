sinclude ../../Makeconf

ifdef HAVE_JPEG
	JPEG=jpgwrite.oct jpgread.oct
endif

ifdef HAVE_PNG
	PNG=pngread.oct pngwrite.oct
endif

ifdef HAVE_MAGICKXX
	IMAGEMAGICK=__imagemagick__.oct __magick_read__$(OCTLINK)
endif

all: conv2.oct cordflt2.oct bwlabel.oct bwfill.oct rotate_scale.oct \
	houghtf.oct graycomatrix.oct \
	$(JPEG) $(PNG) $(IMAGEMAGICK)

jpgread.oct: jpgread.cc
	$(MKOCTFILE) $< -ljpeg

jpgwrite.oct: jpgwrite.cc
	$(MKOCTFILE) $< -ljpeg

pngread.oct: pngread.cc
	$(MKOCTFILE) $< -lpng

pngwrite.oct: pngwrite.cc
	$(MKOCTFILE) $< -lpng
	
__imagemagick__.oct: __imagemagick__.cc
	$(MKOCTFILE) $< -lMagick++ -lMagick
	
__magick_read__$(OCTLINK): __imagemagick__.oct
	$(MKOCTLINK) __imagemagick__.oct $@

clean: ; -$(RM) *.o octave-core core *.oct *~
