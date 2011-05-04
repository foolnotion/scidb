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
DEFINES	= -DNDEBUG
CFLAGS	= $(CFLAGS) $(OPTIMIZE) $(DEFINES)

SRC_C = \
	adler32.c \
	compress.c \
	crc32.c \
	deflate.c \
	gzio.c \
	infback.c \
	inffast.c \
	inflate.c \
	inftrees.c \
	trees.c \
	uncompr.c \
	zutil.c \

SRC	= $(SRC_C)
OBJS	= $(SRC_C:.c=.o)
LIB	= libz

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
