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

INCLUDE	= -I. -I../util -I../tcl -I../mstl
CXXFLAGS	= $(CXXFLAGS) $(CXX_DEBUG) $(OPTIMIZE) $(PROFILING)
LIBS		= mstl/libmstl.a

SRC_CXX = \
	sys_dl.cpp \
	sys_file.cpp \
	sys_pipe.cpp \
	sys_process.cpp \
	sys_signal.cpp \
	sys_thread.cpp \
	sys_time.cpp \
	sys_timer.cpp \
	sys_utf8_codec.cpp \

SRC	= $(SRC_CXX)
OBJS	= $(SRC_CXX:.cpp=.o)
LIB	= libsys

all: $(LIB).a

clean:
	rm -f $(LIB).a $(OBJS)

depend:
	makedepend -fMakefile -Y -- $(INCLUDE) -- -w1 $(SRC) 2>/dev/null

$(LIB).a: $(OBJS)
	$(AR) $(ARFLAGS) $(LIB).a $(OBJS)
	$(RANLIB) $(LIB).a

.cpp.o:
	$(CXX) -c $(CXXFLAGS) $(INCLUDE) $*.cpp

# vi:set ts=3 sw=3:
# DO NOT DELETE THIS LINE -- make depend depends on it.
