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

INCLUDE	= $(TCL_INCLUDE) $(TK_INCLUDE) $(X_INCLUDE) -I../tk$(TCL_VERSION)
CFLAGS	+= $(OPTIMIZE) $(C_DEBUG) $(PROFILING) -DUSE_TKINT_H

SRC	= unix/TkDND_XDND.c #unix/Motif.c
OBJS	= $(SRC:.c=.o)
LIB	= libtkDnd

all: $(LIB).a

clean:
	@rm -f $(LIB).a $(OBJS) Makefile.bak

depend:
	makedepend -fMakefile -Y -- $(INCLUDE) -- -w1 $(SRC) 2>/dev/null
	@if [ -h Makefile.bak ]; then \
		cp Makefile Makefile.bak; \
		mv Makefile.bak Makefile; \
	fi

$(LIB).a: $(OBJS)
	@echo "Building $(LIB).a"
	@$(AR) $(ARFLAGS) $(LIB).a TkDND_XDND.o #Motif.o
	@$(RANLIB) $(LIB).a

.c.o:
	@echo "Compiling `awk 'BEGIN { printf "%-30s", "$<" }'`  [$(CFLAGS:  = )]"
	@$(CC) -c $(CFLAGS) $(EXTRA_CFLAGS) $(INCLUDE) $<

# vi:set ts=3 sw=3:
# DO NOT DELETE

unix/TkDND_XDND.o: /usr/local/include/tcl.h
unix/TkDND_XDND.o: /usr/local/include/tclDecls.h
unix/TkDND_XDND.o: /usr/local/include/tclPlatDecls.h
unix/TkDND_XDND.o: /usr/local/include/tk.h
unix/TkDND_XDND.o: /usr/local/include/tkDecls.h
unix/TkDND_XDND.o: ../tk8.5/tkInt.h
unix/TkDND_XDND.o: ../tk8.5/tkPort.h
unix/TkDND_XDND.o: ../tk8.5/tkUnixPort.h
unix/TkDND_XDND.o: ../tk8.5/tkIntDecls.h
