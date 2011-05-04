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
CFLAGS	= $(CFLAGS) $(C_DEBUG) $(OPTIMIZE) $(PROFILING)

SRC_C	= \
	css.c \
	cssdynamic.c \
	csssearch.c \
	htmldraw.c \
	htmlfloat.c \
	htmlhash.c \
	htmlimage.c \
	htmlinline.c \
	htmllayout.c \
	htmlparse.c \
	htmlprop.c \
	htmlstyle.c \
	htmltagdb.c \
	htmltable.c \
	htmltcl.c \
	htmltree.c \
	swproc.c \
	restrack.c \
	htmldecode.c \
	htmltext.c \
	htmlutil.c \
	cssprop.c \
	cssparse.c \

SRC	= $(SRC_C)
OBJS	= $(SRC_C:.c=.o)
LIB	= libTkhtml3

all: $(LIB).a

clean:
	rm -f $(LIB).a $(OBJS) lempar.c lemon cssparse.out

depend:
	makedepend -fMakefile -Y -- $(CFLAGS) $(INCLUDE) -- -w1 $(SRC) 2>/dev/null

$(LIB).a: $(OBJS)
	$(AR) $(ARFLAGS) $(LIB).a $(OBJS)
	$(RANLIB) $(LIB).a

.c.o:
	$(CC) -c $(CFLAGS) $(INCLUDE) $*.c

#========================================================================

TCLSH	= tclsh$(TCL_VERSION)

htmltokens.c:	tokenlist.txt
	$(TCLSH) $?

htmldefaultstyle.c: tkhtml.tcl html.css mkdefaultstyle.tcl 
	$(TCLSH) mkdefaultstyle.tcl > htmldefaultstyle.c

htmltokens.h: htmltokens.c

cssprop.h: cssprop.tcl
	$(TCLSH) $?

cssprop.c: cssprop.h

LEMON = lemon

$(LEMON): tools/lemon.c
	$(CC) `echo tools/lemon.c` -o $(LEMON)

cssparse.c: cssparse.lem lemon
	ln -sf tools/lempar.c .
	./$(LEMON) cssparse.lem

# vi:set ts=3 sw=3:
# DO NOT DELETE THIS LINE -- make depend depends on it.
