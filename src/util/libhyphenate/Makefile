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

.SUFFIXES: .cpp

INCLUDE	= -I. -I../../sys -I../../mstl
CXXFLAGS	+= $(OPTIMIZE) $(CXX_DEBUG) $(SYS_CXXFLAGS) $(TCL_INCLUDE)

SRC	= \
	HyphenationRule.cpp \
	HyphenationTree.cpp \
	Hyphenator.cpp \
	Language.cpp \

OBJS	= $(SRC:.cpp=.o)
LIB	= libhyphenate

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

.cpp.o:
	@echo "Compiling `awk 'BEGIN { printf "%-30s", "$<" }'`  [$(CXXFLAGS:  = )]"
	@$(CXX) -c $(CXXFLAGS) $(EXTRA_CXXFLAGS) `pkg-config --cflags glib-2.0` $(INCLUDE) $<

# vi:set ts=3 sw=3:
# DO NOT DELETE

HyphenationRule.o: HyphenationRule.h
HyphenationRule.o: ../../mstl/m_string.h
HyphenationRule.o: ../../mstl/m_types.h
HyphenationRule.o: ../../mstl/m_string.ipp
HyphenationRule.o: ../../mstl/m_utility.h
HyphenationRule.o: ../../mstl/m_type_traits.h
HyphenationRule.o: ../../mstl/m_type_traits.ipp
HyphenationRule.o: ../../mstl/m_utility.ipp
HyphenationRule.o: ../../mstl/m_limits.h
HyphenationRule.o: ../../mstl/m_bit_functions.h
HyphenationRule.o: ../../mstl/m_bit_functions.ipp
HyphenationRule.o: ../../mstl/m_uint128_t.h
HyphenationRule.o: ../../mstl/m_uint128.h
HyphenationRule.o: ../../mstl/m_assert.h
HyphenationRule.o: ../../mstl/m_exception.h
HyphenationRule.o: ../../mstl/m_backtrace.h
HyphenationRule.o: ../../mstl/m_exception.ipp
HyphenationRule.o: ../../mstl/m_vector.h
HyphenationRule.o: ../../mstl/m_memblock.h
HyphenationRule.o: ../../mstl/m_memblock.ipp
HyphenationRule.o: ../../mstl/m_pointer_iterator.h
HyphenationRule.o: ../../mstl/m_pointer_iterator.ipp
HyphenationRule.o: ../../mstl/m_iterator.h
HyphenationRule.o: ../../mstl/m_iterator.ipp
HyphenationRule.o: ../../mstl/m_vector.ipp
HyphenationRule.o: ../../mstl/m_uninitialized.h
HyphenationRule.o: ../../mstl/m_uninitialized.ipp
HyphenationRule.o: ../../mstl/m_algobase.h
HyphenationRule.o: ../../mstl/m_algobase.ipp
HyphenationRule.o: ../../mstl/m_construct.h
HyphenationRule.o: ../../mstl/m_construct.ipp
HyphenationRule.o: ../../mstl/m_algorithm.h
HyphenationRule.o: ../../mstl/m_algorithm.ipp
HyphenationTree.o: HyphenationTree.h
HyphenationTree.o: HyphenationRule.h
HyphenationTree.o: ../../mstl/m_string.h
HyphenationTree.o: ../../mstl/m_types.h
HyphenationTree.o: ../../mstl/m_string.ipp
HyphenationTree.o: ../../mstl/m_utility.h
HyphenationTree.o: ../../mstl/m_type_traits.h
HyphenationTree.o: ../../mstl/m_type_traits.ipp
HyphenationTree.o: ../../mstl/m_utility.ipp
HyphenationTree.o: ../../mstl/m_limits.h
HyphenationTree.o: ../../mstl/m_bit_functions.h
HyphenationTree.o: ../../mstl/m_bit_functions.ipp
HyphenationTree.o: ../../mstl/m_uint128_t.h
HyphenationTree.o: ../../mstl/m_uint128.h
HyphenationTree.o: ../../mstl/m_assert.h
HyphenationTree.o: ../../mstl/m_exception.h
HyphenationTree.o: ../../mstl/m_backtrace.h
HyphenationTree.o: ../../mstl/m_exception.ipp
HyphenationTree.o: ../../mstl/m_vector.h
HyphenationTree.o: ../../mstl/m_memblock.h
HyphenationTree.o: ../../mstl/m_memblock.ipp
HyphenationTree.o: ../../mstl/m_pointer_iterator.h
HyphenationTree.o: ../../mstl/m_pointer_iterator.ipp
HyphenationTree.o: ../../mstl/m_iterator.h
HyphenationTree.o: ../../mstl/m_iterator.ipp
HyphenationTree.o: ../../mstl/m_vector.ipp
HyphenationTree.o: ../../mstl/m_uninitialized.h
HyphenationTree.o: ../../mstl/m_uninitialized.ipp
HyphenationTree.o: ../../mstl/m_algobase.h
HyphenationTree.o: ../../mstl/m_algobase.ipp
HyphenationTree.o: ../../mstl/m_construct.h
HyphenationTree.o: ../../mstl/m_construct.ipp
HyphenationTree.o: ../../mstl/m_algorithm.h
HyphenationTree.o: ../../mstl/m_algorithm.ipp
HyphenationTree.o: ../../mstl/m_auto_ptr.h
HyphenationTree.o: ../../mstl/m_auto_ptr.ipp
HyphenationTree.o: ../../sys/sys_utf8.h
HyphenationTree.o: ../../sys/sys_utf8.ipp
HyphenationTree.o: ../../mstl/m_istream.h
HyphenationTree.o: ../../mstl/m_ios.h
HyphenationTree.o: ../../mstl/m_ios.ipp
HyphenationTree.o: ../../mstl/m_istream.ipp
HyphenationTree.o: ../../mstl/m_bitfield.h
HyphenationTree.o: ../../mstl/m_bitfield.ipp
HyphenationTree.o: ../../mstl/m_bitfield128.h
Hyphenator.o: Hyphenator.h
Hyphenator.o: ../../mstl/m_string.h
Hyphenator.o: ../../mstl/m_types.h
Hyphenator.o: ../../mstl/m_string.ipp
Hyphenator.o: ../../mstl/m_utility.h
Hyphenator.o: ../../mstl/m_type_traits.h
Hyphenator.o: ../../mstl/m_type_traits.ipp
Hyphenator.o: ../../mstl/m_utility.ipp
Hyphenator.o: ../../mstl/m_limits.h
Hyphenator.o: ../../mstl/m_bit_functions.h
Hyphenator.o: ../../mstl/m_bit_functions.ipp
Hyphenator.o: ../../mstl/m_uint128_t.h
Hyphenator.o: ../../mstl/m_uint128.h
Hyphenator.o: ../../mstl/m_assert.h
Hyphenator.o: ../../mstl/m_exception.h
Hyphenator.o: ../../mstl/m_backtrace.h
Hyphenator.o: ../../mstl/m_exception.ipp
Hyphenator.o: ../../mstl/m_vector.h
Hyphenator.o: ../../mstl/m_memblock.h
Hyphenator.o: ../../mstl/m_memblock.ipp
Hyphenator.o: ../../mstl/m_pointer_iterator.h
Hyphenator.o: ../../mstl/m_pointer_iterator.ipp
Hyphenator.o: ../../mstl/m_iterator.h
Hyphenator.o: ../../mstl/m_iterator.ipp
Hyphenator.o: ../../mstl/m_vector.ipp
Hyphenator.o: ../../mstl/m_uninitialized.h
Hyphenator.o: ../../mstl/m_uninitialized.ipp
Hyphenator.o: ../../mstl/m_algobase.h
Hyphenator.o: ../../mstl/m_algobase.ipp
Hyphenator.o: ../../mstl/m_construct.h
Hyphenator.o: ../../mstl/m_construct.ipp
Hyphenator.o: ../../mstl/m_algorithm.h
Hyphenator.o: ../../mstl/m_algorithm.ipp
Hyphenator.o: ../../mstl/m_set.h
Hyphenator.o: ../../mstl/m_set.ipp
Hyphenator.o: ../../mstl/m_auto_ptr.h
Hyphenator.o: ../../mstl/m_auto_ptr.ipp
Hyphenator.o: ../../mstl/m_pair.h
Hyphenator.o: ../../mstl/m_pair.ipp
Hyphenator.o: HyphenationRule.h
Hyphenator.o: HyphenationTree.h
Hyphenator.o: Language.h
Hyphenator.o: ../../mstl/m_list.h
Hyphenator.o: ../../mstl/m_list_node.h
Hyphenator.o: ../../mstl/m_list_node.ipp
Hyphenator.o: ../../mstl/m_list.ipp
Hyphenator.o: ../../sys/sys_utf8.h
Hyphenator.o: ../../sys/sys_utf8.ipp
Hyphenator.o: ../../mstl/m_fstream.h
Hyphenator.o: ../../mstl/m_ifstream.h
Hyphenator.o: ../../mstl/m_istream.h
Hyphenator.o: ../../mstl/m_ios.h
Hyphenator.o: ../../mstl/m_ios.ipp
Hyphenator.o: ../../mstl/m_istream.ipp
Hyphenator.o: ../../mstl/m_file.h
Hyphenator.o: ../../mstl/m_file.ipp
Hyphenator.o: ../../mstl/m_ofstream.h
Hyphenator.o: ../../mstl/m_ostream.h
Hyphenator.o: ../../mstl/m_ostream.ipp
Language.o: Language.h
Language.o: ../../mstl/m_list.h
Language.o: ../../mstl/m_list_node.h
Language.o: ../../mstl/m_list_node.ipp
Language.o: ../../mstl/m_utility.h
Language.o: ../../mstl/m_types.h
Language.o: ../../mstl/m_type_traits.h
Language.o: ../../mstl/m_type_traits.ipp
Language.o: ../../mstl/m_utility.ipp
Language.o: ../../mstl/m_limits.h
Language.o: ../../mstl/m_bit_functions.h
Language.o: ../../mstl/m_bit_functions.ipp
Language.o: ../../mstl/m_uint128_t.h
Language.o: ../../mstl/m_uint128.h
Language.o: ../../mstl/m_assert.h
Language.o: ../../mstl/m_exception.h
Language.o: ../../mstl/m_backtrace.h
Language.o: ../../mstl/m_exception.ipp
Language.o: ../../mstl/m_iterator.h
Language.o: ../../mstl/m_iterator.ipp
Language.o: ../../mstl/m_list.ipp
Language.o: ../../mstl/m_construct.h
Language.o: ../../mstl/m_construct.ipp
Language.o: ../../mstl/m_string.h
Language.o: ../../mstl/m_string.ipp
