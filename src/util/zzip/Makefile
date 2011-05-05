# ======================================================================
# Makefile for Scidb for Unix operating systems
# ======================================================================

# ======================================================================
#    _/|            __
#   // o\         /    )           ,        /    /
#   || ._)    ----\---------__----------__-/----/__-
#   //__\          \      /   '  /    /   /    /   )
#   )___(     _(____/____(___ __/____(___/____(___/_
# ======================================================================

include ../../../Makefile.in

.SUFFIXES: .c

INCLUDE	= -I.
OPTIMIZE	= -O2 -fomit-frame-pointer
C_DEBUG	= -DNDEBUG
DEFINES	= -D_USE_MMAP

SRC_C = \
	zzcat.c \
	zzdir.c \
	zzip-dir.c \
	zzip-err.c \
	zzip-file.c \
	zzip-info.c \
	zzip-io.c \
	zzip-stat.c \
	zzip-zip.c \
	zzipwrap-mem.c \
	zzipwrap.c \
	zzxorcat.c \
	zzxorcopy.c \
	zzxordir.c \

SRC	= $(SRC_C)
OBJS	= $(SRC_C:.c=.o)
LIB	= libzzip

all: $(LIB).a

clean:
	rm -f $(LIB).a $(OBJS)

depend:
	makedepend -fMakefile -Y -- $(INCLUDE) -- -w1 $(SRC) 2>/dev/null

$(LIB).a: $(OBJS)
	$(AR) $(ARFLAGS) $(LIB).a $(OBJS)
	$(RANLIB) $(LIB).a

.c.o:
	$(CC) -c $(CFLAGS) $(C_DEBUG) $(OPTIMIZE) $(DEFINES) $(INCLUDE) $*.c

# vi:set ts=3 sw=3:
# DO NOT DELETE THIS LINE -- make depend depends on it.
