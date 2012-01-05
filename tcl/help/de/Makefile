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

.SUFFIXES: .txt .html .dat

SOURCES = \
	Clipbase.txt \
	Database-Formats.txt \
	Database-Switcher.txt \
	Game-Flags.txt \
	NAG-Comments.txt \
	Overview.txt \

TARGETS = $(SOURCES:.txt=.html)
INDEX   = Index.dat

all: $(TARGETS) $(INDEX)

.txt.html:
	@echo "Generating $@"
	@tclsh$(TCL_VERSION) ../make_html.tcl $<

$(INDEX): $(SOURCES) ../make_index.tcl
	@echo "Generating $@"
	@tclsh$(TCL_VERSION) ../make_index.tcl > $@


Clipbase.html: Clipbase.txt ../make_html.tcl ../styles/help.css
Database-Formats.html: Clipbase.txt ../make_html.tcl ../styles/help.css
Database-Switcher.html: Clipbase.txt ../make_html.tcl ../styles/help.css
Game-Flags.html: Clipbase.txt ../make_html.tcl ../styles/help.css
NAG-Comments.html: Clipbase.txt ../make_html.tcl ../styles/help.css
Overview.html: Clipbase.txt ../make_html.tcl ../styles/help.css

# vi:set ts=3 sw=3:
