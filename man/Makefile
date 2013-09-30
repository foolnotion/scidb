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

include ../Makefile.in

.SUFFIXES: .n

SCRIPT = scidb$(SUFFIX)
PROGRAM = tkscidb$(SUFFIX)

$(SCRIPT).1.gz: scidb.n cbh2si4.n cdb2sci.n
	@echo "Make user manuals"
	@cat scidb.n | sed -e 's#%SCRIPT%#$(SCRIPT)#' -e 's#%PROGRAM%#$(PROGRAM)#' -e 's#%BINDIR%#$(BINDIR)#' -e 's#%SHAREDIR%#$(SHAREDIR)#' | gzip -c > $(SCRIPT).1.gz
	@cat cbh2si4.n | sed -e 's#%BINDIR%#$(BINDIR)#' -e 's#%SHAREDIR%#$(SHAREDIR)#' | gzip -c > cbh2si4.1.gz
	@cat cdb2sci.n | sed -e "s#%BINDIR%#$(BINDIR)#" -e 's#%SHAREDIR%#$(SHAREDIR)#' | gzip -c > cdb2sci.1.gz

all: $(SCRIPT).1.gz

install: $(SCRIPT).1.gz
	@echo "Install man pages"
	@install -m 755 -d $(MANDIR)/man1
	@install -m 755 -p $(SCRIPT).1.gz $(MANDIR)/man1
	@install -m 755 -p cbh2si4.1.gz $(MANDIR)/man1
	@install -m 755 -p cdb2sci.1.gz $(MANDIR)/man1

uninstall:
	@echo "Uninstall man pages"
	@rm -f $(MANDIR)/man1/$(SCRIPT).1.gz
	@rm -f $(MANDIR)/man1/cbh2si4.1.gz
	@rm -f $(MANDIR)/man1/cdb2sci.1.gz

clean:
	@# nothing to do

clean-man:
	@echo "Clean `pwd`"
	@rm -f $(SCRIPT).1.gz cbh2si4.1.gz cdb2sci.1.gz

clean-properly: clean-man

# vi:set ts=3 sw=3:
