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

all:
	(cd src && make)
	(cd tcl && make)

depend:
	(cd src && make depend)
	(cd tcl && make depend)

clean:
	(cd src && make clean)
	(cd tcl && make clean)

install:
	(cd src && make install)
	(cd tcl && make install)

uninstall:
	(cd src && make install)
	(cd tcl && make install)

# vi:set ts=3 sw=3:
