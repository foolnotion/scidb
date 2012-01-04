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

.SUFFIXES: .txt .html

SOURCES = \
	Clipbase.txt \
	Database-Formats.txt \
	Database-Switcher.txt \
	Game-Flags.txt \
	Overview.txt \

TARGETS = $(SOURCES:.txt=.html)

all: $(TARGETS)

.txt.html:
	@echo "Generating $@"
	@tclsh$(TCL_VERSION) ../make_html.tcl $<

# vi:set ts=3 sw=3:
