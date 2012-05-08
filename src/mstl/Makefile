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
CFLAGS	+= $(C_DEBUG) $(OPTIMIZE) -DIO_NOT_MTSAFE $(PROFILING)
CXXFLAGS	+= $(CXX_DEBUG) $(OPTIMIZE) -DIO_NOT_MTSAFE $(PROFILING)

SRC_CXX = \
	m_algorithm.cpp \
	m_assert.cpp \
	m_backtrace.cpp \
	m_bit_functions.cpp \
	m_bitset.cpp \
	m_bitset_iterator.cpp \
	m_byte_buf.cpp \
	m_equiv_classes.cpp \
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
	m_string.cpp \

SRC_C = m_stdio.c

SRC	= $(SRC_CXX)
OBJS	= $(SRC_CXX:.cpp=.o) $(SRC_C:.c=.o)
LIB	= libmstl

all: $(LIB).a

clean:
	@echo "Clean `pwd`"
	@rm -f $(LIB).a $(OBJS) Makefile.bak

depend:
	makedepend -fMakefile -Y -- $(INCLUDE) -- -w1 $(SRC_CXXa $(SRC_C)) 2>/dev/null
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
	@$(CXX) -c $(CFLAGS) $(EXTRA_CFLAGS) $(INCLUDE) $*.c

.cpp.o:
	@echo "Compiling `awk 'BEGIN { printf "%-30s", "$<" }'`  [$(CXXFLAGS:  = )]"
	@$(CXX) -c $(CXXFLAGS) $(EXTRA_CXXFLAGS) $(INCLUDE) $*.cpp

# vi:set ts=3 sw=3:
# DO NOT DELETE THIS LINE -- make depend depends on it.
