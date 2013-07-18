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
DEBUG		= -DNDEBUG
OPTIMIZE	= -O2
CFLAGS	+= $(OPTIMIZE) $(DEBUG) $(SYS_CFLAGS) -Wno-unused-result

SRC_C = \
	bucket.c \
	falloc.c \
	findkey.c \
	flatfile.c \
	fullio.c \
	gdbmclose.c \
	gdbmdelete.c \
	gdbmerrno.c \
	gdbmexists.c \
	gdbmfdesc.c \
	gdbmfetch.c \
	gdbmopen.c \
	gdbmreorg.c \
	gdbmseq.c \
	gdbmsetopt.c \
	gdbmstore.c \
	gdbmsync.c \
	hash.c \
	lock.c \
	mmap.c \
	update.c \
	version.c \

SRC	= $(SRC_C)
OBJS	= $(SRC_C:.c=.o)
LIB	= libgdbm

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
