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

all: Makefile.in
#	@$(MAKE) -C engines
#	@if [ $$? != 0 ]; then exit 1; fi
	@$(MAKE) -C src
	@if [ $$? != 0 ]; then exit 1; fi
	@$(MAKE) -C tcl
	@if [ $$? != 0 ]; then exit 1; fi
	@$(MAKE) -C man

depend:
#	@$(MAKE) -C engines depend
	@$(MAKE) -C src depend
	@$(MAKE) -C tcl depend

clean:
#	@$(MAKE) -C engines clean
	@$(MAKE) -C src clean
	@$(MAKE) -C tcl clean
	@$(MAKE) -C man clean

install:
#	@$(MAKE) -C engines install
	@$(MAKE) -C src install
	@$(MAKE) -C tcl install
	@$(MAKE) -C man install

uninstall:
#	@$(MAKE) -C engines uninstall
	@$(MAKE) -C src uninstall
	@$(MAKE) -C tcl uninstall
	@$(MAKE) -C man install

Makefile.in:
	@echo "****** Please use the 'configure' script before building Scidb ******"
	@exit 1

# vi:set ts=3 sw=3:
