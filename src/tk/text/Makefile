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

INCL_PRE      = -I.
INCL_POST     = -I../tcl$(TCL_VERSION) -I../tk$(TCL_VERSION)
INCLUDE       = $(INCL_PRE) $(INCL_POST)
ALL_INCLUDE   = $(INCL_PRE) $(TCL_INCLUDE) $(TK_INCLUDE) $(INCL_POST)
CFLAGS       += $(OPTIMIZE) $(PROFILING) $(C_DEBUG) $(SYS_CFLAGS)
CFLAGS       += -std=c99 -Wno-maybe-uninitialized # avoid unnecessary warnings
#CFLAGS      += -DTK_LAYOUT_WITH_BASE_CHUNKS=0 -DTK_DRAW_IN_CONTEXT=0
EXTRA_CFLAGS += -DMODULE_SCOPE="" -O -g

SRC_C	= \
	tkBitField.c \
	tkIntSet.c \
	tkMisc.c \
	tkQTree.c \
	tkRangeList.c \
	tkTextBTree.c \
	tkText.c \
	tkTextDisp.c \
	tkTextImage.c \
	tkTextIndex.c \
	tkTextLineBreak.c \
	tkTextMark.c \
	tkTextTag.c \
	tkTextTagSet.c \
	tkTextUndo.c \
	tkTextWind.c \

SRC	= $(SRC_C)
OBJS	= $(SRC_C:.c=.o)
LIB	= libTkText

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

#========================================================================

LEMON_CFLAGS = $(CFLAGS) $(SYS_LDFLAGS)

# vi:set ts=3 sw=3:
# DO NOT DELETE THIS LINE -- make depend depends on it.

tkBitField.o: tkBitField.h
tkBitField.o: tkBitFieldPriv.h
tkBitField.o: tkIntSet.h
tkBitField.o: tkIntSetPriv.h
tkIntSet.o: tkIntSet.h
tkIntSet.o: tkIntSetPriv.h
tkIntSet.o: tkBitField.h
tkIntSet.o: tkBitFieldPriv.h
tkMisc.o: ../tk8.6/tkInt.h
tkMisc.o: ../tk8.6/tkPort.h
tkMisc.o: ../tk8.6/tkUnixPort.h
tkMisc.o: ../tk8.6/tkIntDecls.h
tkQTree.o: tkQTree.h
tkQTree.o: ../tk8.6/tkInt.h
tkQTree.o: ../tk8.6/tkPort.h
tkQTree.o: ../tk8.6/tkUnixPort.h
tkQTree.o: ../tk8.6/tkIntDecls.h
tkQTree.o: tkQTreePriv.h
tkRangeList.o: tkRangeList.h
tkRangeList.o: tkRangeListPriv.h
tkTextBTree.o: ../tk8.6/tkInt.h
tkTextBTree.o: ../tk8.6/tkPort.h
tkTextBTree.o: ../tk8.6/tkUnixPort.h
tkTextBTree.o: ../tk8.6/tkIntDecls.h
tkTextBTree.o: tkText.h
tkTextBTree.o: tkTextUndo.h
tkTextBTree.o: tkTextUndoPriv.h
tkTextBTree.o: tkQTree.h
tkTextBTree.o: tkQTreePriv.h
tkTextBTree.o: tkTextPriv.h
tkTextBTree.o: tkTextTagSet.h
tkTextBTree.o: tkBitField.h
tkTextBTree.o: tkBitFieldPriv.h
tkTextBTree.o: tkIntSet.h
tkTextBTree.o: tkIntSetPriv.h
tkTextBTree.o: tkTextTagSetPriv.h
tkText.o: ../tk8.6/default.h
tkText.o: ../tk8.6/tkUnixDefault.h
tkText.o: ../tk8.6/tkInt.h
tkText.o: ../tk8.6/tkPort.h
tkText.o: ../tk8.6/tkUnixPort.h
tkText.o: ../tk8.6/tkIntDecls.h
tkText.o: tkText.h
tkText.o: tkTextUndo.h
tkText.o: tkTextUndoPriv.h
tkText.o: tkQTree.h
tkText.o: tkQTreePriv.h
tkText.o: tkTextPriv.h
tkText.o: tkTextTagSet.h
tkText.o: tkBitField.h
tkText.o: tkBitFieldPriv.h
tkText.o: tkIntSet.h
tkText.o: tkIntSetPriv.h
tkText.o: tkTextTagSetPriv.h
tkTextDisp.o: tkText.h
tkTextDisp.o: tkTextUndo.h
tkTextDisp.o: tkTextUndoPriv.h
tkTextDisp.o: tkQTree.h
tkTextDisp.o: ../tk8.6/tkInt.h
tkTextDisp.o: ../tk8.6/tkPort.h
tkTextDisp.o: ../tk8.6/tkUnixPort.h
tkTextDisp.o: ../tk8.6/tkIntDecls.h
tkTextDisp.o: tkQTreePriv.h
tkTextDisp.o: tkTextPriv.h
tkTextDisp.o: tkTextTagSet.h
tkTextDisp.o: tkBitField.h
tkTextDisp.o: tkBitFieldPriv.h
tkTextDisp.o: tkIntSet.h
tkTextDisp.o: tkIntSetPriv.h
tkTextDisp.o: tkTextTagSetPriv.h
tkTextDisp.o: tkRangeList.h
tkTextDisp.o: tkRangeListPriv.h
tkTextImage.o: ../tk8.6/tkPort.h
tkTextImage.o: ../tk8.6/tkUnixPort.h
tkTextImage.o: tkText.h
tkTextImage.o: tkTextUndo.h
tkTextImage.o: tkTextUndoPriv.h
tkTextImage.o: tkQTree.h
tkTextImage.o: ../tk8.6/tkInt.h
tkTextImage.o: ../tk8.6/tkIntDecls.h
tkTextImage.o: tkQTreePriv.h
tkTextImage.o: tkTextPriv.h
tkTextImage.o: tkTextTagSet.h
tkTextImage.o: tkBitField.h
tkTextImage.o: tkBitFieldPriv.h
tkTextImage.o: tkIntSet.h
tkTextImage.o: tkIntSetPriv.h
tkTextImage.o: tkTextTagSetPriv.h
tkTextIndex.o: ../tk8.6/default.h
tkTextIndex.o: ../tk8.6/tkUnixDefault.h
tkTextIndex.o: ../tk8.6/tkInt.h
tkTextIndex.o: ../tk8.6/tkPort.h
tkTextIndex.o: ../tk8.6/tkUnixPort.h
tkTextIndex.o: ../tk8.6/tkIntDecls.h
tkTextIndex.o: tkText.h
tkTextIndex.o: tkTextUndo.h
tkTextIndex.o: tkTextUndoPriv.h
tkTextIndex.o: tkQTree.h
tkTextIndex.o: tkQTreePriv.h
tkTextIndex.o: tkTextPriv.h
tkTextLineBreak.o: tkText.h
tkTextLineBreak.o: tkTextUndo.h
tkTextLineBreak.o: tkTextUndoPriv.h
tkTextLineBreak.o: tkQTree.h
tkTextLineBreak.o: ../tk8.6/tkInt.h
tkTextLineBreak.o: ../tk8.6/tkPort.h
tkTextLineBreak.o: ../tk8.6/tkUnixPort.h
tkTextLineBreak.o: ../tk8.6/tkIntDecls.h
tkTextLineBreak.o: tkQTreePriv.h
tkTextLineBreak.o: tkTextPriv.h
tkTextMark.o: ../tk8.6/tkInt.h
tkTextMark.o: ../tk8.6/tkPort.h
tkTextMark.o: ../tk8.6/tkUnixPort.h
tkTextMark.o: ../tk8.6/tkIntDecls.h
tkTextMark.o: tkText.h
tkTextMark.o: tkTextUndo.h
tkTextMark.o: tkTextUndoPriv.h
tkTextMark.o: tkQTree.h
tkTextMark.o: tkQTreePriv.h
tkTextMark.o: tkTextPriv.h
tkTextMark.o: ../tk8.6/tk3d.h
tkTextTag.o: ../tk8.6/default.h
tkTextTag.o: ../tk8.6/tkUnixDefault.h
tkTextTag.o: ../tk8.6/tkInt.h
tkTextTag.o: ../tk8.6/tkPort.h
tkTextTag.o: ../tk8.6/tkUnixPort.h
tkTextTag.o: ../tk8.6/tkIntDecls.h
tkTextTag.o: tkText.h
tkTextTag.o: tkTextUndo.h
tkTextTag.o: tkTextUndoPriv.h
tkTextTag.o: tkQTree.h
tkTextTag.o: tkQTreePriv.h
tkTextTag.o: tkTextPriv.h
tkTextTag.o: tkTextTagSet.h
tkTextTag.o: tkBitField.h
tkTextTag.o: tkBitFieldPriv.h
tkTextTag.o: tkIntSet.h
tkTextTag.o: tkIntSetPriv.h
tkTextTag.o: tkTextTagSetPriv.h
tkTextTagSet.o: tkTextTagSet.h
tkTextTagSet.o: tkBitField.h
tkTextTagSet.o: tkBitFieldPriv.h
tkTextTagSet.o: tkIntSet.h
tkTextTagSet.o: tkIntSetPriv.h
tkTextTagSet.o: tkTextTagSetPriv.h
tkTextUndo.o: ../tk8.6/tkInt.h
tkTextUndo.o: ../tk8.6/tkPort.h
tkTextUndo.o: ../tk8.6/tkUnixPort.h
tkTextUndo.o: ../tk8.6/tkIntDecls.h
tkTextUndo.o: tkTextUndo.h
tkTextUndo.o: tkTextUndoPriv.h
tkTextWind.o: ../tk8.6/tkPort.h
tkTextWind.o: ../tk8.6/tkUnixPort.h
tkTextWind.o: tkText.h
tkTextWind.o: tkTextUndo.h
tkTextWind.o: tkTextUndoPriv.h
tkTextWind.o: tkQTree.h
tkTextWind.o: ../tk8.6/tkInt.h
tkTextWind.o: ../tk8.6/tkIntDecls.h
tkTextWind.o: tkQTreePriv.h
tkTextWind.o: tkTextPriv.h
tkTextWind.o: tkTextTagSet.h
tkTextWind.o: tkBitField.h
tkTextWind.o: tkBitFieldPriv.h
tkTextWind.o: tkIntSet.h
tkTextWind.o: tkIntSetPriv.h
tkTextWind.o: tkTextTagSetPriv.h
