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
	$(MAKE) -w -C src
	$(MAKE) -w -C tcl

depend:
	$(MAKE) -w -C src depend
	$(MAKE) -w -C tcl depend

clean:
	$(MAKE) -w -C src clean
	$(MAKE) -w -C tcl clean

install:
	$(MAKE) -w -C src install
	$(MAKE) -w -C tcl install

uninstall:
	$(MAKE) -w -C src install
	$(MAKE) -w -C tcl install

# vi:set ts=3 sw=3:
