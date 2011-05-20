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

MAKEFLAGS += --no-print-directory

all:
	@$(MAKE) -C src
	@if [ $$? != 0 ]; then exit 1; fi
	@$(MAKE) -C tcl

depend:
	@$(MAKE) -C src depend
	@$(MAKE) -C tcl depend

clean:
	@$(MAKE) -C src clean
	@$(MAKE) -C tcl clean

install:
	@$(MAKE) -C src install
	@$(MAKE) -C tcl install

uninstall:
	@$(MAKE) -C src install
	@$(MAKE) -C tcl install

# vi:set ts=3 sw=3:
