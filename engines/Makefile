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

all:
	@for dir in $(ENGINES); do           \
		$(MAKE) -C $$dir;                 \
		if [ $$? != 0 ]; then exit 1; fi; \
	done

depend:
	# no action

clean:
	@for dir in $(ENGINES); do \
		$(MAKE) -C $$dir clean; \
	done

install:
	@echo "Install engines"
	@for dir in $(ENGINES); do   \
		$(MAKE) -C $$dir install; \
	done

uninstall:
	@echo "Uninstall engines"
	@for dir in $(ENGINES); do     \
		$(MAKE) -C $$dir uninstall; \
	done

# vi:set ts=3 sw=3:
