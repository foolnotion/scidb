# makefile

include ../../../Makefile.in

.SUFFIXES: .cpp
.PRECIOUS:

INCLUDE	= -I.
CXXFLAGS = $(CXXFLAGS) $(OPTIMIZE) $(CXX_DEBUG) $(SIMD)

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
	rm -f $(LIB).a $(OBJS)

depend:
	makedepend -fMakefile -Y -- $(CFLAGS) $(INCLUDE) -- -w1 $(SRC) 2>/dev/null

$(LIB).a: $(OBJS)
	$(AR) $(ARFLAGS) $(LIB).a $(OBJS)
	$(RANLIB) $(LIB).a

.cpp.o:
	$(CXX) -c $(CXXFLAGS) $(INCLUDE) $*.cpp

# vi:set ts=3 sw=3:
# DO NOT DELETE THIS LINE -- make depend depends on it.
