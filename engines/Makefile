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

SUBDIRS = MicroMax TogaII-1.3.1

all:
	@for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir; \
		if [ $$? != 0 ]; then exit 1; fi; \
	done

depend:

clean:
	@for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done

install:
	install -m 755 -d $(SHAREDIR)/engines
	@for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir install; \
	done

uninstall:
	@for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir uninstall; \
	done
	if [ ! -z "`find $(SHAREDIR)/engines -type d -empty`" ]; then \
		rmdir $(SHAREDIR)/engines; \
	fi

# vi:set ts=3 sw=3:
