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

INCLUDE	= -I. -I../tcl$(TCL_VERSION) -I../tk$(TCL_VERSION)
DEFINES	= -DHAVE_UNISTD_H=1

SRC_C = \
	qebind.c \
	tkTreeColumn.c \
	tkTreeCtrl.c \
	tkTreeDisplay.c \
	tkTreeDrag.c \
	tkTreeElem.c \
	tkTreeItem.c \
	tkTreeMarquee.c \
	tkTreeNotify.c \
	tkTreeStyle.c \
	tkTreeTheme.c \
	tkTreeUtils.c \

SRC	= $(SRC_C)
OBJS	= $(SRC_C:.c=.o)
LIB	= libtreectrl

all: $(LIB).a

clean:
	rm -f $(LIB).a $(OBJS)

depend:
	makedepend -fMakefile -Y -- $(INCLUDE) -- -w1 $(SRC) 2>/dev/null

$(LIB).a: $(OBJS)
	$(AR) $(ARFLAGS) $(LIB).a $(OBJS)
	$(RANLIB) $(LIB).a

.c.o:
	$(CC) -c $(CFLAGS) $(C_DEBUG) $(OPTIMIZE) $(INCLUDE) $(OPT_C) $(DEFINES) $*.c

# vi:set ts=3 sw=3:
# DO NOT DELETE THIS LINE -- make depend depends on it.
