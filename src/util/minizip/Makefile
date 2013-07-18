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

INCLUDE	= -I. $(ZLIB_INC)
OPTIMIZE	= -O2 -fomit-frame-pointer
C_DEBUG	= -DNDEBUG
DEFINES	= -D_USE_MMAP # -DNOCRYPT -DNOUNCRYPT
CFLAGS	= $(OPTIMIZE) $(C_DEBUG) $(SYS_CFLAGS) $(DEFINES)

SRC_C = \
	ioapi.c \
	unzip.c \
	zip.c \

SRC	= $(SRC_C)
OBJS	= $(SRC_C:.c=.o)
LIB	= libminizip

all: $(LIB).a

clean:
	@echo "Clean `pwd`"
	@rm -f $(LIB).a $(OBJS)

depend:
	# do nothing

$(LIB).a: $(OBJS)
	@echo "Building $(LIB).a"
	@$(AR) $(ARFLAGS) $(LIB).a $(OBJS)
	@$(RANLIB) $(LIB).a

.c.o:
	@echo "Compiling `awk 'BEGIN { printf "%-30s", "$<" }'`  [$(CFLAGS:  = )]"
	@$(CC) -c $(CFLAGS) $(EXTRA_CFLAGS) $(INCLUDE) $<

# vi:set ts=3 sw=3:
# DO NOT DELETE THIS LINE -- make depend depends on it.
