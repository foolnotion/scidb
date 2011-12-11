# ======================================================================
# Makefile for Scidb for Unix operating systems
# ======================================================================

include ../../Makefile.in

.SUFFIXES: .cpp
.PRECIOUS:

EXE		= micromax
CFLAGS	= -O3 -fomit-frame-pointer
LDFLAGS	= -s

.SUFFIXES: .c
.PRECIOUS:

all: $(EXE)

clean:
	rm -f *.o $(EXE)

install:
	@install -m 755 -d $(ENGINESDIR)
	@install -m 755 -p $(EXE) $(ENGINESDIR)

uninstall:
	rm -f $(ENGINESDIR)/$(EXE)

.c.o:
	@echo "Compiling `awk 'BEGIN { printf "%-16s", "$<" }'`  [$(CFLAGS:  = )]"
	@$(CC) -c -o $@ $(CFLAGS) $(EXTRA_CFLAGS) $<

$(EXE): umax4_8w.o
	@echo "Building $(EXE)"
	@$(CC) $(LDFLAGS) -o $@ umax4_8w.o

# vi:set ts=3 sw=3:
