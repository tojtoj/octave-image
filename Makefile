include ../../Makeconf

jpgread.oct: jpgread.cc
	$(MKOCTFILE) $< -ljpeg

jpgwrite.oct: jpgwrite.cc
	$(MKOCTFILE) $< -ljpeg

all: conv2.oct cordflt2.oct jpgwrite.oct jpgread.oct

clean: ; -$(RM) *.o octave-core core *.oct *~
