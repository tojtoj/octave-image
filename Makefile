
include ../../Makeconf

PROGS = conv2.oct cordflt2.oct

all: $(PROGS)

clean:
	$(RM) *.o $(PROGS) octave-core core *~
 
