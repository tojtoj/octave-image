include ../../Makeconf

all: conv2.oct cordflt2.oct jpgwrite.oct jpgread.oct

jpgread.oct: jpgread.cc
	$(MKOCTFILE) $< -ljpeg

jpgwrite.oct: jpgwrite.cc
	$(MKOCTFILE) $< -ljpeg

clean: ; -$(RM) *.o octave-core core *.oct *~
