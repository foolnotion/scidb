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

INCLUDE		= -I. -I../util -I../tcl -I../mstl
ALL_INCLUDE	= $(INCLUDE) $(TCL_INCLUDE) $(TK_INCLUDE)
CXXFLAGS		+= $(CXX_DEBUG) $(OPTIMIZE) $(PROFILING) $(THR_SUPPORT)
CXXFLAGS		+= $(HAVE_INOTIFY) $(SYS_INOTIFY) $(HAVE_LIBFAM) $(HAVE_STATVFS)

SRC_CXX = \
	sys_dl.cpp \
	sys_info.cpp \
	sys_fam.cpp \
	sys_file.cpp \
	sys_pipe.cpp \
	sys_process.cpp \
	sys_signal.cpp \
	sys_thread.cpp \
	sys_time.cpp \
	sys_timer.cpp \
	sys_utf8.cpp \
	sys_utf8_codec.cpp \
	sys_vfs.cpp \

SRC	= $(SRC_CXX)
OBJS	= $(SRC_CXX:.cpp=.o)
LIB	= libsys

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
	@$(CXX) -c $(CXXFLAGS) $(EXTRA_CXXFLAGS) $(ALL_INCLUDE) $<

# explciit dependency is required
sys_fam.o: sys_inotify.h

# vi:set ts=3 sw=3:
# DO NOT DELETE THIS LINE -- make depend depends on it.

sys_dl.o: sys_dl.h
sys_dl.o: sys_base.h
sys_dl.o: sys_base.ipp
sys_dl.o: ../tcl/tcl_base.h
sys_dl.o: ../tcl/tcl_base.ipp
sys_dl.o: ../mstl/m_string.h
sys_dl.o: ../mstl/m_types.h
sys_dl.o: ../mstl/m_string.ipp
sys_dl.o: ../mstl/m_utility.h
sys_dl.o: ../mstl/m_type_traits.h
sys_dl.o: ../mstl/m_type_traits.ipp
sys_dl.o: ../mstl/m_utility.ipp
sys_dl.o: ../mstl/m_limits.h
sys_dl.o: ../mstl/m_bit_functions.h
sys_dl.o: ../mstl/m_bit_functions.ipp
sys_dl.o: ../mstl/m_uint128_t.h
sys_dl.o: ../mstl/m_uint128.h
sys_dl.o: ../mstl/m_assert.h
sys_dl.o: ../mstl/m_exception.h
sys_dl.o: ../mstl/m_backtrace.h
sys_dl.o: ../mstl/m_exception.ipp
sys_info.o: sys_info.h
sys_info.o: ../mstl/m_types.h
sys_info.o: ../mstl/m_utility.h
sys_info.o: ../mstl/m_type_traits.h
sys_info.o: ../mstl/m_type_traits.ipp
sys_info.o: ../mstl/m_utility.ipp
sys_info.o: ../mstl/m_limits.h
sys_info.o: ../mstl/m_bit_functions.h
sys_info.o: ../mstl/m_bit_functions.ipp
sys_info.o: ../mstl/m_uint128_t.h
sys_info.o: ../mstl/m_uint128.h
sys_info.o: ../mstl/m_assert.h
sys_info.o: ../mstl/m_exception.h
sys_info.o: ../mstl/m_backtrace.h
sys_info.o: ../mstl/m_exception.ipp
sys_fam.o: sys_fam.h
sys_fam.o: ../mstl/m_string.h
sys_fam.o: ../mstl/m_types.h
sys_fam.o: ../mstl/m_string.ipp
sys_fam.o: ../mstl/m_utility.h
sys_fam.o: ../mstl/m_type_traits.h
sys_fam.o: ../mstl/m_type_traits.ipp
sys_fam.o: ../mstl/m_utility.ipp
sys_fam.o: ../mstl/m_limits.h
sys_fam.o: ../mstl/m_bit_functions.h
sys_fam.o: ../mstl/m_bit_functions.ipp
sys_fam.o: ../mstl/m_uint128_t.h
sys_fam.o: ../mstl/m_uint128.h
sys_fam.o: ../mstl/m_assert.h
sys_fam.o: ../mstl/m_exception.h
sys_fam.o: ../mstl/m_backtrace.h
sys_fam.o: ../mstl/m_exception.ipp
sys_fam.o: sys_fam.ipp
sys_fam.o: sys_file.h
sys_fam.o: sys_time.h
sys_fam.o: ../util/u_base.h
sys_fam.o: ../mstl/m_hash.h
sys_fam.o: ../mstl/m_vector.h
sys_fam.o: ../mstl/m_memblock.h
sys_fam.o: ../mstl/m_memblock.ipp
sys_fam.o: ../mstl/m_iterator.h
sys_fam.o: ../mstl/m_iterator.ipp
sys_fam.o: ../mstl/m_vector.ipp
sys_fam.o: ../mstl/m_uninitialized.h
sys_fam.o: ../mstl/m_uninitialized.ipp
sys_fam.o: ../mstl/m_algobase.h
sys_fam.o: ../mstl/m_algobase.ipp
sys_fam.o: ../mstl/m_construct.h
sys_fam.o: ../mstl/m_construct.ipp
sys_fam.o: ../mstl/m_pair.h
sys_fam.o: ../mstl/m_pair.ipp
sys_fam.o: ../mstl/m_hash.ipp
sys_fam.o: ../mstl/m_algorithm.h
sys_fam.o: ../mstl/m_algorithm.ipp
sys_file.o: sys_file.h
sys_file.o: sys_time.h
sys_file.o: ../util/u_base.h
sys_file.o: ../mstl/m_types.h
sys_file.o: ../mstl/m_string.h
sys_file.o: ../mstl/m_string.ipp
sys_file.o: ../mstl/m_utility.h
sys_file.o: ../mstl/m_type_traits.h
sys_file.o: ../mstl/m_type_traits.ipp
sys_file.o: ../mstl/m_utility.ipp
sys_file.o: ../mstl/m_limits.h
sys_file.o: ../mstl/m_bit_functions.h
sys_file.o: ../mstl/m_bit_functions.ipp
sys_file.o: ../mstl/m_uint128_t.h
sys_file.o: ../mstl/m_uint128.h
sys_file.o: ../mstl/m_assert.h
sys_file.o: ../mstl/m_exception.h
sys_file.o: ../mstl/m_backtrace.h
sys_file.o: ../mstl/m_exception.ipp
sys_file.o: sys_base.h
sys_file.o: sys_base.ipp
sys_file.o: ../tcl/tcl_base.h
sys_file.o: ../tcl/tcl_base.ipp
sys_file.o: ../mstl/m_map.h
sys_file.o: ../mstl/m_vector.h
sys_file.o: ../mstl/m_memblock.h
sys_file.o: ../mstl/m_memblock.ipp
sys_file.o: ../mstl/m_iterator.h
sys_file.o: ../mstl/m_iterator.ipp
sys_file.o: ../mstl/m_vector.ipp
sys_file.o: ../mstl/m_uninitialized.h
sys_file.o: ../mstl/m_uninitialized.ipp
sys_file.o: ../mstl/m_algobase.h
sys_file.o: ../mstl/m_algobase.ipp
sys_file.o: ../mstl/m_construct.h
sys_file.o: ../mstl/m_construct.ipp
sys_file.o: ../mstl/m_pair.h
sys_file.o: ../mstl/m_pair.ipp
sys_file.o: ../mstl/m_map.ipp
sys_pipe.o: sys_pipe.h
sys_pipe.o: ../mstl/m_assert.h
sys_pipe.o: ../mstl/m_exception.h
sys_pipe.o: ../mstl/m_backtrace.h
sys_pipe.o: ../mstl/m_types.h
sys_pipe.o: ../mstl/m_exception.ipp
sys_process.o: sys_process.h
sys_process.o: sys_process.ipp
sys_process.o: sys_base.h
sys_process.o: sys_base.ipp
sys_process.o: ../tcl/tcl_base.h
sys_process.o: ../tcl/tcl_base.ipp
sys_process.o: ../tcl/tcl_exception.h
sys_process.o: ../util/u_exception.h
sys_process.o: ../mstl/m_exception.h
sys_process.o: ../mstl/m_backtrace.h
sys_process.o: ../mstl/m_types.h
sys_process.o: ../mstl/m_exception.ipp
sys_process.o: ../mstl/m_string.h
sys_process.o: ../mstl/m_string.ipp
sys_process.o: ../mstl/m_utility.h
sys_process.o: ../mstl/m_type_traits.h
sys_process.o: ../mstl/m_type_traits.ipp
sys_process.o: ../mstl/m_utility.ipp
sys_process.o: ../mstl/m_limits.h
sys_process.o: ../mstl/m_bit_functions.h
sys_process.o: ../mstl/m_bit_functions.ipp
sys_process.o: ../mstl/m_uint128_t.h
sys_process.o: ../mstl/m_uint128.h
sys_process.o: ../mstl/m_assert.h
sys_process.o: ../mstl/m_map.h
sys_process.o: ../mstl/m_vector.h
sys_process.o: ../mstl/m_memblock.h
sys_process.o: ../mstl/m_memblock.ipp
sys_process.o: ../mstl/m_iterator.h
sys_process.o: ../mstl/m_iterator.ipp
sys_process.o: ../mstl/m_vector.ipp
sys_process.o: ../mstl/m_uninitialized.h
sys_process.o: ../mstl/m_uninitialized.ipp
sys_process.o: ../mstl/m_algobase.h
sys_process.o: ../mstl/m_algobase.ipp
sys_process.o: ../mstl/m_construct.h
sys_process.o: ../mstl/m_construct.ipp
sys_process.o: ../mstl/m_pair.h
sys_process.o: ../mstl/m_pair.ipp
sys_process.o: ../mstl/m_map.ipp
sys_signal.o: sys_signal.h
sys_thread.o: sys_thread.h
sys_thread.o: ../mstl/m_function.h
sys_thread.o: ../mstl/m_function_base.h
sys_thread.o: ../mstl/m_function_base.ipp
sys_thread.o: ../mstl/m_types.h
sys_thread.o: ../mstl/m_function.ipp
sys_thread.o: ../mstl/m_assert.h
sys_thread.o: ../mstl/m_exception.h
sys_thread.o: ../mstl/m_backtrace.h
sys_thread.o: ../mstl/m_exception.ipp
sys_thread.o: ../mstl/m_stdio.h
sys_time.o: sys_time.h
sys_time.o: ../util/u_base.h
sys_time.o: ../mstl/m_types.h
sys_timer.o: sys_timer.h
sys_timer.o: sys_base.h
sys_timer.o: sys_base.ipp
sys_timer.o: ../tcl/tcl_base.h
sys_timer.o: ../tcl/tcl_base.ipp
sys_utf8.o: sys_utf8.h
sys_utf8.o: ../mstl/m_types.h
sys_utf8.o: sys_utf8.ipp
sys_utf8.o: ../mstl/m_string.h
sys_utf8.o: ../mstl/m_string.ipp
sys_utf8.o: ../mstl/m_utility.h
sys_utf8.o: ../mstl/m_type_traits.h
sys_utf8.o: ../mstl/m_type_traits.ipp
sys_utf8.o: ../mstl/m_utility.ipp
sys_utf8.o: ../mstl/m_limits.h
sys_utf8.o: ../mstl/m_bit_functions.h
sys_utf8.o: ../mstl/m_bit_functions.ipp
sys_utf8.o: ../mstl/m_uint128_t.h
sys_utf8.o: ../mstl/m_uint128.h
sys_utf8.o: ../mstl/m_assert.h
sys_utf8.o: ../mstl/m_exception.h
sys_utf8.o: ../mstl/m_backtrace.h
sys_utf8.o: ../mstl/m_exception.ipp
sys_utf8_codec.o: sys_utf8_codec.h
sys_utf8_codec.o: ../mstl/m_string.h
sys_utf8_codec.o: ../mstl/m_types.h
sys_utf8_codec.o: ../mstl/m_string.ipp
sys_utf8_codec.o: ../mstl/m_utility.h
sys_utf8_codec.o: ../mstl/m_type_traits.h
sys_utf8_codec.o: ../mstl/m_type_traits.ipp
sys_utf8_codec.o: ../mstl/m_utility.ipp
sys_utf8_codec.o: ../mstl/m_limits.h
sys_utf8_codec.o: ../mstl/m_bit_functions.h
sys_utf8_codec.o: ../mstl/m_bit_functions.ipp
sys_utf8_codec.o: ../mstl/m_uint128_t.h
sys_utf8_codec.o: ../mstl/m_uint128.h
sys_utf8_codec.o: ../mstl/m_assert.h
sys_utf8_codec.o: ../mstl/m_exception.h
sys_utf8_codec.o: ../mstl/m_backtrace.h
sys_utf8_codec.o: ../mstl/m_exception.ipp
sys_utf8_codec.o: ../mstl/m_list.h
sys_utf8_codec.o: ../mstl/m_vector.h
sys_utf8_codec.o: ../mstl/m_memblock.h
sys_utf8_codec.o: ../mstl/m_memblock.ipp
sys_utf8_codec.o: ../mstl/m_iterator.h
sys_utf8_codec.o: ../mstl/m_iterator.ipp
sys_utf8_codec.o: ../mstl/m_vector.ipp
sys_utf8_codec.o: ../mstl/m_uninitialized.h
sys_utf8_codec.o: ../mstl/m_uninitialized.ipp
sys_utf8_codec.o: ../mstl/m_algobase.h
sys_utf8_codec.o: ../mstl/m_algobase.ipp
sys_utf8_codec.o: ../mstl/m_construct.h
sys_utf8_codec.o: ../mstl/m_construct.ipp
sys_utf8_codec.o: ../mstl/m_list_node.h
sys_utf8_codec.o: ../mstl/m_list_node.ipp
sys_utf8_codec.o: ../mstl/m_list.ipp
sys_utf8_codec.o: sys_utf8_codec.ipp
sys_utf8_codec.o: sys_utf8.h
sys_utf8_codec.o: sys_utf8.ipp
sys_utf8_codec.o: sys_base.h
sys_utf8_codec.o: sys_base.ipp
sys_utf8_codec.o: ../tcl/tcl_base.h
sys_utf8_codec.o: ../tcl/tcl_base.ipp
sys_utf8_codec.o: ../util/u_base.h
sys_vfs.o: sys_vfs.h
sys_vfs.o: ../mstl/m_types.h
sys_vfs.o: ../mstl/m_string.h
sys_vfs.o: ../mstl/m_string.ipp
sys_vfs.o: ../mstl/m_utility.h
sys_vfs.o: ../mstl/m_type_traits.h
sys_vfs.o: ../mstl/m_type_traits.ipp
sys_vfs.o: ../mstl/m_utility.ipp
sys_vfs.o: ../mstl/m_limits.h
sys_vfs.o: ../mstl/m_bit_functions.h
sys_vfs.o: ../mstl/m_bit_functions.ipp
sys_vfs.o: ../mstl/m_uint128_t.h
sys_vfs.o: ../mstl/m_uint128.h
sys_vfs.o: ../mstl/m_assert.h
sys_vfs.o: ../mstl/m_exception.h
sys_vfs.o: ../mstl/m_backtrace.h
sys_vfs.o: ../mstl/m_exception.ipp
