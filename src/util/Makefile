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

INCLUDE	= -I. -I../mstl -I../sys -Ilibhyphenate -Izlib -Iminizip
CXXFLAGS	+=  $(OPTIMIZE) $(CXX_DEBUG) $(PROFILING)

SRC_CXX = \
	u_base64_decoder.cpp \
	u_block_file.cpp \
	u_bit_stream.cpp \
	u_byte_stream.cpp \
	u_exception.cpp \
	u_html.cpp \
	u_http.cpp \
	u_misc.cpp \
	u_path.cpp \
	u_piped_progress.cpp \
	u_progress.cpp \
	u_zstream.cpp \

SRC	= $(SRC_CXX)
OBJS	= $(SRC_CXX:.cpp=.o)
LIB	= libutil

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
	@$(CXX) -c $(CXXFLAGS) $(EXTRA_CXXFLAGS) $(INCLUDE) $<

# DO NOT DELETE THIS LINE -- make depend depends on it.

u_base64_decoder.o: u_base64_decoder.h
u_base64_decoder.o: ../mstl/m_types.h
u_base64_decoder.o: u_exception.h
u_base64_decoder.o: ../mstl/m_exception.h
u_base64_decoder.o: ../mstl/m_backtrace.h
u_base64_decoder.o: ../mstl/m_exception.ipp
u_block_file.o: u_block_file.h
u_block_file.o: u_byte_stream.h
u_block_file.o: u_base.h
u_block_file.o: ../mstl/m_types.h
u_block_file.o: u_exception.h
u_block_file.o: ../mstl/m_exception.h
u_block_file.o: ../mstl/m_backtrace.h
u_block_file.o: ../mstl/m_exception.ipp
u_block_file.o: u_byte_stream.ipp
u_block_file.o: ../mstl/m_utility.h
u_block_file.o: ../mstl/m_type_traits.h
u_block_file.o: ../mstl/m_type_traits.ipp
u_block_file.o: ../mstl/m_utility.ipp
u_block_file.o: ../mstl/m_limits.h
u_block_file.o: ../mstl/m_bit_functions.h
u_block_file.o: ../mstl/m_bit_functions.ipp
u_block_file.o: ../mstl/m_assert.h
u_block_file.o: ../mstl/m_string.h
u_block_file.o: ../mstl/m_string.ipp
u_block_file.o: ../mstl/m_vector.h
u_block_file.o: ../mstl/m_memblock.h
u_block_file.o: ../mstl/m_memblock.ipp
u_block_file.o: ../mstl/m_vector.ipp
u_block_file.o: ../mstl/m_uninitialized.h
u_block_file.o: ../mstl/m_uninitialized.ipp
u_block_file.o: ../mstl/m_algobase.h
u_block_file.o: ../mstl/m_algobase.ipp
u_block_file.o: ../mstl/m_construct.h
u_block_file.o: ../mstl/m_construct.ipp
u_block_file.o: u_block_file.ipp
u_block_file.o: ../mstl/m_algorithm.h
u_block_file.o: ../mstl/m_algorithm.ipp
u_block_file.o: ../mstl/m_fstream.h
u_block_file.o: ../mstl/m_ifstream.h
u_block_file.o: ../mstl/m_istream.h
u_block_file.o: ../mstl/m_ios.h
u_block_file.o: ../mstl/m_ios.ipp
u_block_file.o: ../mstl/m_istream.ipp
u_block_file.o: ../mstl/m_file.h
u_block_file.o: ../mstl/m_file.ipp
u_block_file.o: ../mstl/m_ifstream.ipp
u_block_file.o: ../mstl/m_ofstream.h
u_block_file.o: ../mstl/m_ostream.h
u_block_file.o: ../mstl/m_ostream.ipp
u_block_file.o: ../mstl/m_ofstream.ipp
u_bit_stream.o: u_bit_stream.h
u_bit_stream.o: u_base.h
u_bit_stream.o: ../mstl/m_types.h
u_bit_stream.o: u_bit_stream.ipp
u_bit_stream.o: ../mstl/m_utility.h
u_bit_stream.o: ../mstl/m_type_traits.h
u_bit_stream.o: ../mstl/m_type_traits.ipp
u_bit_stream.o: ../mstl/m_utility.ipp
u_bit_stream.o: ../mstl/m_limits.h
u_bit_stream.o: ../mstl/m_bit_functions.h
u_bit_stream.o: ../mstl/m_bit_functions.ipp
u_bit_stream.o: ../mstl/m_assert.h
u_bit_stream.o: ../mstl/m_exception.h
u_bit_stream.o: ../mstl/m_backtrace.h
u_bit_stream.o: ../mstl/m_exception.ipp
u_byte_stream.o: u_byte_stream.h
u_byte_stream.o: u_base.h
u_byte_stream.o: ../mstl/m_types.h
u_byte_stream.o: u_exception.h
u_byte_stream.o: ../mstl/m_exception.h
u_byte_stream.o: ../mstl/m_backtrace.h
u_byte_stream.o: ../mstl/m_exception.ipp
u_byte_stream.o: u_byte_stream.ipp
u_byte_stream.o: ../mstl/m_utility.h
u_byte_stream.o: ../mstl/m_type_traits.h
u_byte_stream.o: ../mstl/m_type_traits.ipp
u_byte_stream.o: ../mstl/m_utility.ipp
u_byte_stream.o: ../mstl/m_limits.h
u_byte_stream.o: ../mstl/m_bit_functions.h
u_byte_stream.o: ../mstl/m_bit_functions.ipp
u_byte_stream.o: ../mstl/m_assert.h
u_byte_stream.o: ../mstl/m_string.h
u_byte_stream.o: ../mstl/m_string.ipp
u_exception.o: u_exception.h
u_exception.o: ../mstl/m_exception.h
u_exception.o: ../mstl/m_backtrace.h
u_exception.o: ../mstl/m_types.h
u_exception.o: ../mstl/m_exception.ipp
u_exception.o: ../mstl/m_stdio.h
u_html.o: u_html.h
u_html.o: ../mstl/m_string.h
u_html.o: ../mstl/m_types.h
u_html.o: ../mstl/m_string.ipp
u_html.o: ../mstl/m_utility.h
u_html.o: ../mstl/m_type_traits.h
u_html.o: ../mstl/m_type_traits.ipp
u_html.o: ../mstl/m_utility.ipp
u_html.o: ../mstl/m_limits.h
u_html.o: ../mstl/m_bit_functions.h
u_html.o: ../mstl/m_bit_functions.ipp
u_html.o: ../mstl/m_assert.h
u_html.o: ../mstl/m_exception.h
u_html.o: ../mstl/m_backtrace.h
u_html.o: ../mstl/m_exception.ipp
u_html.o: ../mstl/m_vector.h
u_html.o: ../mstl/m_memblock.h
u_html.o: ../mstl/m_memblock.ipp
u_html.o: ../mstl/m_vector.ipp
u_html.o: ../mstl/m_uninitialized.h
u_html.o: ../mstl/m_uninitialized.ipp
u_html.o: ../mstl/m_algobase.h
u_html.o: ../mstl/m_algobase.ipp
u_html.o: ../mstl/m_construct.h
u_html.o: ../mstl/m_construct.ipp
u_html.o: u_html.ipp
u_html.o: libhyphenate/Hyphenator.h
u_html.o: ../mstl/m_set.h
u_html.o: ../mstl/m_set.ipp
u_html.o: ../mstl/m_algorithm.h
u_html.o: ../mstl/m_algorithm.ipp
u_html.o: ../mstl/m_auto_ptr.h
u_html.o: ../mstl/m_auto_ptr.ipp
u_html.o: ../mstl/m_pair.h
u_html.o: ../mstl/m_pair.ipp
u_html.o: ../sys/sys_utf8.h
u_html.o: ../sys/sys_utf8.ipp
u_html.o: ../mstl/m_map.h
u_html.o: ../mstl/m_map.ipp
u_http.o: u_http.h
u_http.o: ../mstl/m_string.h
u_http.o: ../mstl/m_types.h
u_http.o: ../mstl/m_string.ipp
u_http.o: ../mstl/m_utility.h
u_http.o: ../mstl/m_type_traits.h
u_http.o: ../mstl/m_type_traits.ipp
u_http.o: ../mstl/m_utility.ipp
u_http.o: ../mstl/m_limits.h
u_http.o: ../mstl/m_bit_functions.h
u_http.o: ../mstl/m_bit_functions.ipp
u_http.o: ../mstl/m_assert.h
u_http.o: ../mstl/m_exception.h
u_http.o: ../mstl/m_backtrace.h
u_http.o: ../mstl/m_exception.ipp
u_http.o: u_http.ipp
u_http.o: u_base.h
u_http.o: ../mstl/m_sstream.h
u_http.o: ../mstl/m_ostream.h
u_http.o: ../mstl/m_ios.h
u_http.o: ../mstl/m_ios.ipp
u_http.o: ../mstl/m_ostream.ipp
u_http.o: ../mstl/m_istream.h
u_http.o: ../mstl/m_istream.ipp
u_http.o: ../mstl/m_stdio.h
u_misc.o: u_misc.h
u_misc.o: ../mstl/m_string.h
u_misc.o: ../mstl/m_types.h
u_misc.o: ../mstl/m_string.ipp
u_misc.o: ../mstl/m_utility.h
u_misc.o: ../mstl/m_type_traits.h
u_misc.o: ../mstl/m_type_traits.ipp
u_misc.o: ../mstl/m_utility.ipp
u_misc.o: ../mstl/m_limits.h
u_misc.o: ../mstl/m_bit_functions.h
u_misc.o: ../mstl/m_bit_functions.ipp
u_misc.o: ../mstl/m_assert.h
u_misc.o: ../mstl/m_exception.h
u_misc.o: ../mstl/m_backtrace.h
u_misc.o: ../mstl/m_exception.ipp
u_path.o: u_path.h
u_path.o: ../mstl/m_string.h
u_path.o: ../mstl/m_types.h
u_path.o: ../mstl/m_string.ipp
u_path.o: ../mstl/m_utility.h
u_path.o: ../mstl/m_type_traits.h
u_path.o: ../mstl/m_type_traits.ipp
u_path.o: ../mstl/m_utility.ipp
u_path.o: ../mstl/m_limits.h
u_path.o: ../mstl/m_bit_functions.h
u_path.o: ../mstl/m_bit_functions.ipp
u_path.o: ../mstl/m_assert.h
u_path.o: ../mstl/m_exception.h
u_path.o: ../mstl/m_backtrace.h
u_path.o: ../mstl/m_exception.ipp
u_piped_progress.o: u_piped_progress.h
u_piped_progress.o: u_progress.h
u_piped_progress.o: u_progress.ipp
u_piped_progress.o: ../sys/sys_pipe.h
u_piped_progress.o: ../sys/sys_thread.h
u_piped_progress.o: ../mstl/m_function.h
u_piped_progress.o: ../mstl/m_function_base.h
u_piped_progress.o: ../mstl/m_function_base.ipp
u_piped_progress.o: ../mstl/m_types.h
u_piped_progress.o: ../mstl/m_function.ipp
u_piped_progress.o: ../mstl/m_utility.h
u_piped_progress.o: ../mstl/m_type_traits.h
u_piped_progress.o: ../mstl/m_type_traits.ipp
u_piped_progress.o: ../mstl/m_utility.ipp
u_piped_progress.o: ../mstl/m_limits.h
u_piped_progress.o: ../mstl/m_bit_functions.h
u_piped_progress.o: ../mstl/m_bit_functions.ipp
u_piped_progress.o: ../mstl/m_assert.h
u_piped_progress.o: ../mstl/m_exception.h
u_piped_progress.o: ../mstl/m_backtrace.h
u_piped_progress.o: ../mstl/m_exception.ipp
u_progress.o: u_progress.h
u_progress.o: u_progress.ipp
u_progress.o: ../mstl/m_utility.h
u_progress.o: ../mstl/m_types.h
u_progress.o: ../mstl/m_type_traits.h
u_progress.o: ../mstl/m_type_traits.ipp
u_progress.o: ../mstl/m_utility.ipp
u_progress.o: ../mstl/m_limits.h
u_progress.o: ../mstl/m_bit_functions.h
u_progress.o: ../mstl/m_bit_functions.ipp
u_progress.o: ../mstl/m_assert.h
u_progress.o: ../mstl/m_exception.h
u_progress.o: ../mstl/m_backtrace.h
u_progress.o: ../mstl/m_exception.ipp
u_zstream.o: u_zstream.h
u_zstream.o: ../mstl/m_iostream.h
u_zstream.o: ../mstl/m_istream.h
u_zstream.o: ../mstl/m_ios.h
u_zstream.o: ../mstl/m_exception.h
u_zstream.o: ../mstl/m_backtrace.h
u_zstream.o: ../mstl/m_types.h
u_zstream.o: ../mstl/m_exception.ipp
u_zstream.o: ../mstl/m_ios.ipp
u_zstream.o: ../mstl/m_istream.ipp
u_zstream.o: ../mstl/m_ostream.h
u_zstream.o: ../mstl/m_ostream.ipp
u_zstream.o: ../mstl/m_vector.h
u_zstream.o: ../mstl/m_type_traits.h
u_zstream.o: ../mstl/m_type_traits.ipp
u_zstream.o: ../mstl/m_memblock.h
u_zstream.o: ../mstl/m_memblock.ipp
u_zstream.o: ../mstl/m_utility.h
u_zstream.o: ../mstl/m_utility.ipp
u_zstream.o: ../mstl/m_limits.h
u_zstream.o: ../mstl/m_bit_functions.h
u_zstream.o: ../mstl/m_bit_functions.ipp
u_zstream.o: ../mstl/m_assert.h
u_zstream.o: ../mstl/m_vector.ipp
u_zstream.o: ../mstl/m_uninitialized.h
u_zstream.o: ../mstl/m_uninitialized.ipp
u_zstream.o: ../mstl/m_algobase.h
u_zstream.o: ../mstl/m_algobase.ipp
u_zstream.o: ../mstl/m_construct.h
u_zstream.o: ../mstl/m_construct.ipp
u_zstream.o: ../mstl/m_string.h
u_zstream.o: ../mstl/m_string.ipp
u_zstream.o: u_misc.h
u_zstream.o: ../mstl/m_ifstream.h
u_zstream.o: ../mstl/m_file.h
u_zstream.o: ../mstl/m_file.ipp
u_zstream.o: ../mstl/m_ifstream.ipp
u_zstream.o: ../mstl/m_stdio.h
u_zstream.o: ./zzip/zzip.h
u_zstream.o: ./zzip/plugin.h
u_zstream.o: ./zzip/lib.h
u_zstream.o: ./zzip/conf.h
u_zstream.o: ./zzip/_config.h
u_zstream.o: ./zzip/stdint.h
u_zstream.o: zlib/zlib.h
u_zstream.o: zlib/zconf.h
u_zstream.o: minizip/zip.h
u_zstream.o: minizip/ioapi.h
