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
.PRECIOUS:

INCLUDE	= -I.
OPTIMIZE	= -O2 -fomit-frame-pointer
C_DEBUG	= -DNDEBUG
DEFINES	= -D_USE_MMAP
CFLAGS	= $(CFLAGS) $(C_DEBUG) $(OPTIMIZE) $(DEFINES)

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

$(LIB).a: $(OBJS)
	$(AR) $(ARFLAGS) $(LIB).a $(OBJS)
	$(RANLIB) $(LIB).a

.c.o:
	$(CC) -c $(CFLAGS) $(INCLUDE) $*.c

# vi:set ts=3 sw=3:
# DO NOT DELETE THIS LINE -- make depend depends on it.
