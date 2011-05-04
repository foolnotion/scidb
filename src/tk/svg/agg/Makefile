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

include ../../../../Makefile.in

.SUFFIXES: .cpp
.PRECIOUS:

INCLUDE	= -I.
CFLAGS	= $(CFLAGS) $(OPTIMIZE) $(C_DEBUG)
CXXFLAGS	= $(CXXFLAGS) $(OPTIMIZE) $(CXX_DEBUG)

SRC_CXX=\
	agg_arc.cpp \
	agg_arrowhead.cpp \
	agg_bezier_arc.cpp \
	agg_bspline.cpp \
	agg_curves.cpp \
	agg_vcgen_contour.cpp \
	agg_vcgen_dash.cpp \
	agg_vcgen_markers_term.cpp \
	agg_vcgen_smooth_poly1.cpp \
	agg_vcgen_stroke.cpp \
	agg_vcgen_bspline.cpp \
	agg_gsv_text.cpp \
	agg_image_filters.cpp \
	agg_line_aa_basics.cpp \
	agg_line_profile_aa.cpp \
	agg_rounded_rect.cpp \
	agg_sqrt_tables.cpp \
	agg_embedded_raster_fonts.cpp \
	agg_trans_affine.cpp \
	agg_trans_warp_magnifier.cpp \
	agg_trans_single_path.cpp \
	agg_trans_double_path.cpp \
	agg_vpgen_clip_polygon.cpp \
	agg_vpgen_clip_polyline.cpp \
	agg_vpgen_segmentator.cpp \

SRC_C=\
	gpc.c

SRC	= $(SRC_CXX) $(SRC_C)
OBJS	= $(SRC_CXX:.cpp=.o) $(SRC_C:.c=.o)
LIB	= libagg

all: $(LIB).a

clean:
	rm -f $(LIB).a $(OBJS)

depend:
	makedepend -fMakefile -Y -- $(CFLAGS) $(INCLUDE) -- -w1 $(SRC) 2>/dev/null

$(LIB).a: $(OBJS)
	$(AR) $(ARFLAGS) $(LIB).a $(OBJS)

.c.o:
	$(CC) -c $(CFLAGS) $(INCLUDE) $*.c

.cpp.o:
	$(CXX) -c $(CXXFLAGS) $(INCLUDE) $*.cpp

# vi:set ts=3 sw=3:
# DO NOT DELETE THIS LINE -- make depend depends on it.
