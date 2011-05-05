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

INCLUDE	= -I. -I../mstl -I../sys -I../util -I../db -I../db/sci -I../db/si3

SRC_CXX = \
	app_application.cpp \
	app_cursor.cpp \
	app_engine.cpp \
	app_exception.cpp \
	app_uci_engine.cpp \
	app_view.cpp \
	app_winboard_engine.cpp \

SRC	= $(SRC_CXX)
OBJS	= $(SRC_CXX:.cpp=.o)
LIB	= libapp

all: $(LIB).a

clean:
	rm -f $(LIB).a $(OBJS)

depend:
	makedepend -fMakefile -Y -- $(INCLUDE) -- -w1 $(SRC) 2>/dev/null

$(LIB).a: $(OBJS)
	$(AR) $(ARFLAGS) $(LIB).a $(OBJS)
	$(RANLIB) $(LIB).a

.cpp.o:
	$(CXX) -c $(CXXFLAGS) $(CXX_DEBUG) $(OPTIMIZE) $(PROFILING) $(INCLUDE) $*.cpp

# vi:set ts=3 sw=3:
# DO NOT DELETE THIS LINE -- make depend depends on it.
