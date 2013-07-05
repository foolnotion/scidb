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

INCLUDE	= -I.
CXXFLAGS	+= $(SYS_CXXFLAGS) $(OPTIMIZE) $(CXX_DEBUG)

SRC_CXX = \
	jpeg_base.cpp \
	jpeg_bit_stream.cpp \
	jpeg_color_conv.cpp \
	jpeg_component.cpp \
	jpeg_dct.cpp \
	jpeg_decoder.cpp \
	jpeg_exception.cpp \
	jpeg_huffman.cpp \
	jpeg_image.cpp \
	jpeg_reader.cpp \
	jpeg_scanline.cpp \
	jpeg_stream.cpp \

SRC	= $(SRC_CXX)
OBJS	= $(SRC_CXX:.cpp=.o)
LIB	= libjpegd

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

# vi:set ts=3 sw=3:
# DO NOT DELETE THIS LINE -- make depend depends on it.

jpeg_base.o: jpeg_base.h
jpeg_bit_stream.o: jpeg_bit_stream.h
jpeg_bit_stream.o: jpeg_stream.h
jpeg_bit_stream.o: jpeg_exception.h
jpeg_color_conv.o: jpeg_color_conv.h
jpeg_color_conv.o: jpeg_base.h
jpeg_color_conv.o: jpeg_scanline.h
jpeg_color_conv.o: data/jpeg_ycc_to_rgb_8.dat
jpeg_color_conv.o: data/jpeg_pycc_to_rgb_8.dat
jpeg_component.o: jpeg_component.h
jpeg_component.o: jpeg_base.h
jpeg_component.o: jpeg_dct.h
jpeg_component.o: jpeg_huffman.h
jpeg_component.o: jpeg_bit_stream.h
jpeg_component.o: jpeg_exception.h
jpeg_dct.o: jpeg_dct.h
jpeg_dct.o: jpeg_base.h
jpeg_decoder.o: jpeg_decoder.h
jpeg_decoder.o: jpeg_base.h
jpeg_decoder.o: jpeg_stream.h
jpeg_decoder.o: jpeg_exception.h
jpeg_decoder.o: jpeg_component.h
jpeg_decoder.o: jpeg_dct.h
jpeg_decoder.o: jpeg_image.h
jpeg_decoder.o: jpeg_scanline.h
jpeg_decoder.o: jpeg_bit_stream.h
jpeg_decoder.o: jpeg_color_conv.h
jpeg_decoder.o: jpeg_huffman.h
jpeg_exception.o: jpeg_exception.h
jpeg_huffman.o: jpeg_huffman.h
jpeg_huffman.o: jpeg_bit_stream.h
jpeg_huffman.o: jpeg_exception.h
jpeg_image.o: jpeg_image.h
jpeg_image.o: jpeg_scanline.h
jpeg_image.o: jpeg_decoder.h
jpeg_image.o: jpeg_base.h
jpeg_image.o: jpeg_stream.h
jpeg_image.o: jpeg_exception.h
jpeg_image.o: jpeg_component.h
jpeg_image.o: jpeg_dct.h
jpeg_image.o: jpeg_bit_stream.h
jpeg_reader.o: jpeg_reader.h
jpeg_scanline.o: jpeg_scanline.h
jpeg_stream.o: jpeg_stream.h
jpeg_stream.o: jpeg_exception.h
jpeg_stream.o: jpeg_reader.h
