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

INCLUDE	= -I.
CXXFLAGS	= $(CXXFLAGS) $(CXX_DEBUG) $(OPTIMIZE) $(PROFILING)

SRC_CXX = \
	m_algorithm.cpp \
	m_assert.cpp \
	m_backtrace.cpp \
	m_bit_functions.cpp \
	m_bitset.cpp \
	m_bitset_iterator.cpp \
	m_byte_buf.cpp \
	m_exception.cpp \
	m_file.cpp \
	m_fstream.cpp \
	m_hash.cpp \
	m_ifstream.cpp \
	m_ios.cpp \
	m_istream.cpp \
	m_ofstream.cpp \
	m_ostream.cpp \
	m_sstream.cpp \
	m_stdio.cpp \
	m_string.cpp \

SRC	= $(SRC_CXX)
OBJS	= $(SRC_CXX:.cpp=.o)
LIB	= libmstl

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
