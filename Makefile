include ../../Makeconf

all: conv2.oct cordflt2.oct

clean: ; -$(RM) *.o octave-core core *.oct *~
