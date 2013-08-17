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

INCL_PRE		= -I.
INCL_POST	= -I../tcl$(TCL_VERSION) -I../tk$(TCL_VERSION)
INCLUDE		= $(INCL_PRE) $(INCL_POST)
ALL_INCLUDE	= $(INCL_PRE) $(TCL_INCLUDE) $(TK_INCLUDE) $(INCL_POST)
DEFINES		= -DHAVE_UNISTD_H=1 -DSTDC_HEADERS=1
CFLAGS		+= $(OPTIMIZE) $(C_DEBUG) $(SYS_CFLAGS) $(DEFINES)

SRC_C = \
	qebind.c \
	tkTreeColumn.c \
	tkTreeCtrl.c \
	tkTreeDisplay.c \
	tkTreeDrag.c \
	tkTreeElem.c \
	tkTreeItem.c \
	tkTreeMarquee.c \
	tkTreeNotify.c \
	tkTreeStyle.c \
	tkTreeTheme.c \
	tkTreeUtils.c \

SRC	= $(SRC_C)
OBJS	= $(SRC_C:.c=.o)
LIB	= libtreectrl

all: $(LIB).a

clean:
	@echo "Clean `pwd`"
	@rm -f $(LIB).a $(OBJS) Makefile.bak

depend:
	makedepend -fMakefile -Y -- $(INCLUDE) -- -w1 $(SRC) 2>/dev/null
	@if [ -h Makefile.bak ]; then \
		cp Makefile Makefile.bak; \
		mv Makefile.bak Makefile; \
	fi

$(LIB).a: $(OBJS)
	@echo "Building $(LIB).a"
	@$(AR) $(ARFLAGS) $(LIB).a $(OBJS)
	@$(RANLIB) $(LIB).a

.c.o:
	@echo "Compiling `awk 'BEGIN { printf "%-30s", "$<" }'`  [$(CFLAGS:  = )]"
	@$(CC) -c $(CFLAGS) $(EXTRA_CFLAGS) $(ALL_INCLUDE) $<

# vi:set ts=3 sw=3:
# DO NOT DELETE THIS LINE -- make depend depends on it.

qebind.o: qebind.h
tkTreeColumn.o: tkTreeCtrl.h
tkTreeColumn.o: ../tk8.6/tkPort.h
tkTreeColumn.o: ../tk8.6/tkUnixPort.h
tkTreeColumn.o: ../tk8.6/default.h
tkTreeColumn.o: ../tk8.6/tkUnixDefault.h
tkTreeColumn.o: ../tcl8.6/tclInt.h
tkTreeColumn.o: ../tcl8.6/tclPort.h
tkTreeColumn.o: ../tcl8.6/tclUnixPort.h
tkTreeColumn.o: ../tcl8.6/tclIntDecls.h
tkTreeColumn.o: ../tcl8.6/tclIntPlatDecls.h
tkTreeColumn.o: ../tk8.6/tkInt.h
tkTreeColumn.o: ../tk8.6/tkIntDecls.h
tkTreeColumn.o: qebind.h
tkTreeCtrl.o: tkTreeCtrl.h
tkTreeCtrl.o: ../tk8.6/tkPort.h
tkTreeCtrl.o: ../tk8.6/tkUnixPort.h
tkTreeCtrl.o: ../tk8.6/default.h
tkTreeCtrl.o: ../tk8.6/tkUnixDefault.h
tkTreeCtrl.o: ../tcl8.6/tclInt.h
tkTreeCtrl.o: ../tcl8.6/tclPort.h
tkTreeCtrl.o: ../tcl8.6/tclUnixPort.h
tkTreeCtrl.o: ../tcl8.6/tclIntDecls.h
tkTreeCtrl.o: ../tcl8.6/tclIntPlatDecls.h
tkTreeCtrl.o: ../tk8.6/tkInt.h
tkTreeCtrl.o: ../tk8.6/tkIntDecls.h
tkTreeCtrl.o: qebind.h
tkTreeDisplay.o: tkTreeCtrl.h
tkTreeDisplay.o: ../tk8.6/tkPort.h
tkTreeDisplay.o: ../tk8.6/tkUnixPort.h
tkTreeDisplay.o: ../tk8.6/default.h
tkTreeDisplay.o: ../tk8.6/tkUnixDefault.h
tkTreeDisplay.o: ../tcl8.6/tclInt.h
tkTreeDisplay.o: ../tcl8.6/tclPort.h
tkTreeDisplay.o: ../tcl8.6/tclUnixPort.h
tkTreeDisplay.o: ../tcl8.6/tclIntDecls.h
tkTreeDisplay.o: ../tcl8.6/tclIntPlatDecls.h
tkTreeDisplay.o: ../tk8.6/tkInt.h
tkTreeDisplay.o: ../tk8.6/tkIntDecls.h
tkTreeDisplay.o: qebind.h
tkTreeDrag.o: tkTreeCtrl.h
tkTreeDrag.o: ../tk8.6/tkPort.h
tkTreeDrag.o: ../tk8.6/tkUnixPort.h
tkTreeDrag.o: ../tk8.6/default.h
tkTreeDrag.o: ../tk8.6/tkUnixDefault.h
tkTreeDrag.o: ../tcl8.6/tclInt.h
tkTreeDrag.o: ../tcl8.6/tclPort.h
tkTreeDrag.o: ../tcl8.6/tclUnixPort.h
tkTreeDrag.o: ../tcl8.6/tclIntDecls.h
tkTreeDrag.o: ../tcl8.6/tclIntPlatDecls.h
tkTreeDrag.o: ../tk8.6/tkInt.h
tkTreeDrag.o: ../tk8.6/tkIntDecls.h
tkTreeDrag.o: qebind.h
tkTreeElem.o: tkTreeCtrl.h
tkTreeElem.o: ../tk8.6/tkPort.h
tkTreeElem.o: ../tk8.6/tkUnixPort.h
tkTreeElem.o: ../tk8.6/default.h
tkTreeElem.o: ../tk8.6/tkUnixDefault.h
tkTreeElem.o: ../tcl8.6/tclInt.h
tkTreeElem.o: ../tcl8.6/tclPort.h
tkTreeElem.o: ../tcl8.6/tclUnixPort.h
tkTreeElem.o: ../tcl8.6/tclIntDecls.h
tkTreeElem.o: ../tcl8.6/tclIntPlatDecls.h
tkTreeElem.o: ../tk8.6/tkInt.h
tkTreeElem.o: ../tk8.6/tkIntDecls.h
tkTreeElem.o: qebind.h
tkTreeElem.o: tkTreeElem.h
tkTreeItem.o: tkTreeCtrl.h
tkTreeItem.o: ../tk8.6/tkPort.h
tkTreeItem.o: ../tk8.6/tkUnixPort.h
tkTreeItem.o: ../tk8.6/default.h
tkTreeItem.o: ../tk8.6/tkUnixDefault.h
tkTreeItem.o: ../tcl8.6/tclInt.h
tkTreeItem.o: ../tcl8.6/tclPort.h
tkTreeItem.o: ../tcl8.6/tclUnixPort.h
tkTreeItem.o: ../tcl8.6/tclIntDecls.h
tkTreeItem.o: ../tcl8.6/tclIntPlatDecls.h
tkTreeItem.o: ../tk8.6/tkInt.h
tkTreeItem.o: ../tk8.6/tkIntDecls.h
tkTreeItem.o: qebind.h
tkTreeMarquee.o: tkTreeCtrl.h
tkTreeMarquee.o: ../tk8.6/tkPort.h
tkTreeMarquee.o: ../tk8.6/tkUnixPort.h
tkTreeMarquee.o: ../tk8.6/default.h
tkTreeMarquee.o: ../tk8.6/tkUnixDefault.h
tkTreeMarquee.o: ../tcl8.6/tclInt.h
tkTreeMarquee.o: ../tcl8.6/tclPort.h
tkTreeMarquee.o: ../tcl8.6/tclUnixPort.h
tkTreeMarquee.o: ../tcl8.6/tclIntDecls.h
tkTreeMarquee.o: ../tcl8.6/tclIntPlatDecls.h
tkTreeMarquee.o: ../tk8.6/tkInt.h
tkTreeMarquee.o: ../tk8.6/tkIntDecls.h
tkTreeMarquee.o: qebind.h
tkTreeNotify.o: tkTreeCtrl.h
tkTreeNotify.o: ../tk8.6/tkPort.h
tkTreeNotify.o: ../tk8.6/tkUnixPort.h
tkTreeNotify.o: ../tk8.6/default.h
tkTreeNotify.o: ../tk8.6/tkUnixDefault.h
tkTreeNotify.o: ../tcl8.6/tclInt.h
tkTreeNotify.o: ../tcl8.6/tclPort.h
tkTreeNotify.o: ../tcl8.6/tclUnixPort.h
tkTreeNotify.o: ../tcl8.6/tclIntDecls.h
tkTreeNotify.o: ../tcl8.6/tclIntPlatDecls.h
tkTreeNotify.o: ../tk8.6/tkInt.h
tkTreeNotify.o: ../tk8.6/tkIntDecls.h
tkTreeNotify.o: qebind.h
tkTreeStyle.o: tkTreeCtrl.h
tkTreeStyle.o: ../tk8.6/tkPort.h
tkTreeStyle.o: ../tk8.6/tkUnixPort.h
tkTreeStyle.o: ../tk8.6/default.h
tkTreeStyle.o: ../tk8.6/tkUnixDefault.h
tkTreeStyle.o: ../tcl8.6/tclInt.h
tkTreeStyle.o: ../tcl8.6/tclPort.h
tkTreeStyle.o: ../tcl8.6/tclUnixPort.h
tkTreeStyle.o: ../tcl8.6/tclIntDecls.h
tkTreeStyle.o: ../tcl8.6/tclIntPlatDecls.h
tkTreeStyle.o: ../tk8.6/tkInt.h
tkTreeStyle.o: ../tk8.6/tkIntDecls.h
tkTreeStyle.o: qebind.h
tkTreeStyle.o: tkTreeElem.h
tkTreeTheme.o: tkTreeCtrl.h
tkTreeTheme.o: ../tk8.6/tkPort.h
tkTreeTheme.o: ../tk8.6/tkUnixPort.h
tkTreeTheme.o: ../tk8.6/default.h
tkTreeTheme.o: ../tk8.6/tkUnixDefault.h
tkTreeTheme.o: ../tcl8.6/tclInt.h
tkTreeTheme.o: ../tcl8.6/tclPort.h
tkTreeTheme.o: ../tcl8.6/tclUnixPort.h
tkTreeTheme.o: ../tcl8.6/tclIntDecls.h
tkTreeTheme.o: ../tcl8.6/tclIntPlatDecls.h
tkTreeTheme.o: ../tk8.6/tkInt.h
tkTreeTheme.o: ../tk8.6/tkIntDecls.h
tkTreeTheme.o: qebind.h
tkTreeUtils.o: tkTreeCtrl.h
tkTreeUtils.o: ../tk8.6/tkPort.h
tkTreeUtils.o: ../tk8.6/tkUnixPort.h
tkTreeUtils.o: ../tk8.6/default.h
tkTreeUtils.o: ../tk8.6/tkUnixDefault.h
tkTreeUtils.o: ../tcl8.6/tclInt.h
tkTreeUtils.o: ../tcl8.6/tclPort.h
tkTreeUtils.o: ../tcl8.6/tclUnixPort.h
tkTreeUtils.o: ../tcl8.6/tclIntDecls.h
tkTreeUtils.o: ../tcl8.6/tclIntPlatDecls.h
tkTreeUtils.o: ../tk8.6/tkInt.h
tkTreeUtils.o: ../tk8.6/tkIntDecls.h
tkTreeUtils.o: qebind.h
