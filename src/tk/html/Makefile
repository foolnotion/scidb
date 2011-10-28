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

INCLUDE		= -I. -I../tcl$(TCL_VERSION) -I../tk$(TCL_VERSION)
ALL_INCLUDE	= $(INCLUDE) $(TCL_INCLUDE) $(TK_INCLUDE)
CFLAGS		+= $(C_DEBUG) $(OPTIMIZE) $(PROFILING) -DUSE_DOUBLE_BUFFERING

SRC_C	= \
	css.c \
	cssdynamic.c \
	csssearch.c \
	htmldraw.c \
	htmlfloat.c \
	htmlhash.c \
	htmlimage.c \
	htmlinline.c \
	htmllayout.c \
	htmlparse.c \
	htmlprop.c \
	htmlstyle.c \
	htmltagdb.c \
	htmltable.c \
	htmltcl.c \
	htmltree.c \
	swproc.c \
	restrack.c \
	htmldecode.c \
	htmltext.c \
	htmlutil.c \
	cssprop.c \
	cssparse.c \

SRC	= $(SRC_C)
OBJS	= $(SRC_C:.c=.o)
LIB	= libTkhtml3

all: $(LIB).a

clean:
	rm -f $(LIB).a $(OBJS) lempar.c lemon cssparse.out Makefile.bak

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

#========================================================================

LEMON_CFLAGS = $(CFLAGS) -Wno-uninitialized -fno-strict-aliasing

TCLSH	= tclsh$(TCL_VERSION)

htmltokens.c:	tokenlist.txt
	$(TCLSH) $?

htmldefaultstyle.c: tkhtml.tcl html.css mkdefaultstyle.tcl 
	$(TCLSH) mkdefaultstyle.tcl > htmldefaultstyle.c

htmltokens.h: htmltokens.c

cssprop.h: cssprop.tcl
	$(TCLSH) $?

cssprop.c: cssprop.h

LEMON = lemon

$(LEMON): tools/lemon.c
	@echo "Compiling `awk 'BEGIN { printf "%-30s", "$<" }'`  [$(LEMON_CFLAGS:  = )]"
	@$(CC) $(LEMON_CFLAGS) $(EXTRA_CFLAGS) $< -o $(LEMON)

cssparse.c: cssparse.lem lemon
	@ln -sf tools/lempar.c .
	./$(LEMON) cssparse.lem

# vi:set ts=3 sw=3:
# DO NOT DELETE THIS LINE -- make depend depends on it.

css.o: css.h
css.o: cssprop.h
css.o: html.h
css.o: htmltokens.h
css.o: htmlmacros.h
css.o: htmlprop.h
css.o: cssInt.h
css.o: cssparse.h
cssdynamic.o: html.h
cssdynamic.o: htmltokens.h
cssdynamic.o: htmlmacros.h
cssdynamic.o: css.h
cssdynamic.o: cssprop.h
cssdynamic.o: htmlprop.h
cssdynamic.o: cssInt.h
cssdynamic.o: cssparse.h
csssearch.o: html.h
csssearch.o: htmltokens.h
csssearch.o: htmlmacros.h
csssearch.o: css.h
csssearch.o: cssprop.h
csssearch.o: htmlprop.h
csssearch.o: cssInt.h
csssearch.o: cssparse.h
htmldraw.o: html.h
htmldraw.o: htmltokens.h
htmldraw.o: htmlmacros.h
htmldraw.o: css.h
htmldraw.o: cssprop.h
htmldraw.o: htmlprop.h
htmlfloat.o: html.h
htmlfloat.o: htmltokens.h
htmlfloat.o: htmlmacros.h
htmlfloat.o: css.h
htmlfloat.o: cssprop.h
htmlfloat.o: htmlprop.h
htmlhash.o: html.h
htmlhash.o: htmltokens.h
htmlhash.o: htmlmacros.h
htmlhash.o: css.h
htmlhash.o: cssprop.h
htmlhash.o: htmlprop.h
htmlimage.o: html.h
htmlimage.o: htmltokens.h
htmlimage.o: htmlmacros.h
htmlimage.o: css.h
htmlimage.o: cssprop.h
htmlimage.o: htmlprop.h
htmlimage.o: htmllayout.h
htmlinline.o: htmllayout.h
htmlinline.o: html.h
htmlinline.o: htmltokens.h
htmlinline.o: htmlmacros.h
htmlinline.o: css.h
htmlinline.o: cssprop.h
htmlinline.o: htmlprop.h
htmllayout.o: htmllayout.h
htmllayout.o: html.h
htmllayout.o: htmltokens.h
htmllayout.o: htmlmacros.h
htmllayout.o: css.h
htmllayout.o: cssprop.h
htmllayout.o: htmlprop.h
htmlparse.o: html.h
htmlparse.o: htmltokens.h
htmlparse.o: htmlmacros.h
htmlparse.o: css.h
htmlparse.o: cssprop.h
htmlparse.o: htmlprop.h
htmlparse.o: htmltokens.c
htmlprop.o: html.h
htmlprop.o: htmltokens.h
htmlprop.o: htmlmacros.h
htmlprop.o: css.h
htmlprop.o: cssprop.h
htmlprop.o: htmlprop.h
htmlstyle.o: html.h
htmlstyle.o: htmltokens.h
htmlstyle.o: htmlmacros.h
htmlstyle.o: css.h
htmlstyle.o: cssprop.h
htmlstyle.o: htmlprop.h
htmltagdb.o: html.h
htmltagdb.o: htmltokens.h
htmltagdb.o: htmlmacros.h
htmltagdb.o: css.h
htmltagdb.o: cssprop.h
htmltagdb.o: htmlprop.h
htmltable.o: htmllayout.h
htmltable.o: html.h
htmltable.o: htmltokens.h
htmltable.o: htmlmacros.h
htmltable.o: css.h
htmltable.o: cssprop.h
htmltable.o: htmlprop.h
htmltcl.o: html.h
htmltcl.o: htmltokens.h
htmltcl.o: htmlmacros.h
htmltcl.o: css.h
htmltcl.o: cssprop.h
htmltcl.o: htmlprop.h
htmltcl.o: restrack.h
htmltcl.o: swproc.h
htmltcl.o: htmldefaultstyle.c
htmltree.o: html.h
htmltree.o: htmltokens.h
htmltree.o: htmlmacros.h
htmltree.o: css.h
htmltree.o: cssprop.h
htmltree.o: htmlprop.h
htmltree.o: swproc.h
swproc.o: swproc.h
htmldecode.o: html.h
htmldecode.o: htmltokens.h
htmldecode.o: htmlmacros.h
htmldecode.o: css.h
htmldecode.o: cssprop.h
htmldecode.o: htmlprop.h
htmltext.o: html.h
htmltext.o: htmltokens.h
htmltext.o: htmlmacros.h
htmltext.o: css.h
htmltext.o: cssprop.h
htmltext.o: htmlprop.h
cssprop.o: cssprop.h
cssprop.o: html.h
cssprop.o: htmltokens.h
cssprop.o: htmlmacros.h
cssprop.o: css.h
cssprop.o: htmlprop.h
cssparse.o: cssInt.h
cssparse.o: css.h
cssparse.o: cssprop.h
cssparse.o: html.h
cssparse.o: htmltokens.h
cssparse.o: htmlmacros.h
cssparse.o: htmlprop.h
cssparse.o: cssparse.h
