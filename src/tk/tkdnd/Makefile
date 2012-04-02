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

SRC	= unix/TkDND_XDND.c
LIB	= libtkDnd

all: $(LIB).a

clean:
	@rm -f $(LIB).a TkDND_XDND.o Makefile.bak

depend:
#	makedepend -fMakefile -Y -- -I../tk$(TCL_VERSION) -- -w1 $(SRC) 2>/dev/null
#	@if [ -h Makefile.bak ]; then \
#		cp Makefile Makefile.bak; \
#		mv Makefile.bak Makefile; \
#	fi

$(LIB).a: TkDND_XDND.o
	@echo "Building $(LIB).a"
	@$(AR) $(ARFLAGS) $(LIB).a TkDND_XDND.o
	@$(RANLIB) $(LIB).a

TkDND_XDND.o: unix/TkDND_XDND.c
	@echo "Compiling `awk 'BEGIN { printf "%-30s", "$<" }'`  [$(CFLAGS:  = )]"
	@$(CC) -c $(CFLAGS) $(EXTRA_CFLAGS) $(INCLUDE) $<

# vi:set ts=3 sw=3:
