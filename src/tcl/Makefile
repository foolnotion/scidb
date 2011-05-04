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

include ../../Makefile.in

.SUFFIXES: .cpp
.PRECIOUS:

INCLUDE	= -I. -I../util/libTeXt -I../mstl -I../sys -I../util -I../util/expat -I../app -I../db -I../db/si3
CXXFLAGS	= $(CXXFLAGS) $(CXX_DEBUG) $(OPTIMIZE) $(PROFILING)

SRC_CXX = \
	tcl_application.cpp \
	tcl_base.cpp \
	tcl_board.cpp \
	tcl_crosstable.cpp \
	tcl_database.cpp \
	tcl_exception.cpp \
	tcl_game.cpp \
	tcl_http.cpp \
	tcl_log.cpp \
	tcl_misc.cpp \
	tcl_pgn_reader.cpp \
	tcl_position.cpp \
	tcl_progress.cpp \
	tcl_tree.cpp \
	tcl_view.cpp \

SRC	= $(SRC_CXX)
OBJS	= $(SRC_CXX:.cpp=.o)
LIB	= libtcl

all: $(LIB).a

clean:
	rm -f $(LIB).a $(OBJS)

depend:
	makedepend -fMakefile -Y -- $(INCLUDE) -- -w1 $(SRC) 2>/dev/null

$(LIB).a: $(OBJS)
	$(AR) $(ARFLAGS) $(LIB).a $(OBJS)
	$(RANLIB) $(LIB).a

.cpp.o:
	$(CXX) -c $(CXXFLAGS) $(INCLUDE) -DSHAREDIR=$(SHAREDIR) $*.cpp

# vi:set ts=3 sw=3:
# DO NOT DELETE THIS LINE -- make depend depends on it.
