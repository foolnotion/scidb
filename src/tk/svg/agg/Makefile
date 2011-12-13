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
CFLAGS	+= $(OPTIMIZE) $(C_DEBUG)
CXXFLAGS	+= $(OPTIMIZE) $(CXX_DEBUG)

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
	@echo "Clean `pwd`"
	@rm -f $(LIB).a $(OBJS) Makefile.bak

depend:
	makedepend -fMakefile -Y -- $(CFLAGS) $(INCLUDE) -- -w1 $(SRC) 2>/dev/null
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
	@$(CC) -c $(CFLAGS) $(EXTRA_CFLAGS) $(INCLUDE) $<

.cpp.o:
	@echo "Compiling `awk 'BEGIN { printf "%-30s", "$<" }'`  [$(CXXFLAGS:  = )]"
	@$(CXX) -c $(CXXFLAGS) $(EXTRA_CFLAGS) $(INCLUDE) $<

# vi:set ts=3 sw=3:
# DO NOT DELETE THIS LINE -- make depend depends on it.

agg_arc.o: agg_arc.h
agg_arc.o: agg_basics.h
agg_arc.o: agg_config.h
agg_arrowhead.o: agg_arrowhead.h
agg_arrowhead.o: agg_basics.h
agg_arrowhead.o: agg_config.h
agg_bezier_arc.o: agg_bezier_arc.h
agg_bezier_arc.o: agg_conv_transform.h
agg_bezier_arc.o: agg_basics.h
agg_bezier_arc.o: agg_config.h
agg_bezier_arc.o: agg_trans_affine.h
agg_bspline.o: agg_bspline.h
agg_bspline.o: agg_array.h
agg_bspline.o: agg_basics.h
agg_bspline.o: agg_config.h
agg_curves.o: agg_curves.h
agg_curves.o: agg_array.h
agg_curves.o: agg_basics.h
agg_curves.o: agg_config.h
agg_curves.o: agg_math.h
agg_vcgen_contour.o: agg_vcgen_contour.h
agg_vcgen_contour.o: agg_math_stroke.h
agg_vcgen_contour.o: agg_math.h
agg_vcgen_contour.o: agg_basics.h
agg_vcgen_contour.o: agg_config.h
agg_vcgen_contour.o: agg_vertex_sequence.h
agg_vcgen_contour.o: agg_array.h
agg_vcgen_dash.o: agg_vcgen_dash.h
agg_vcgen_dash.o: agg_basics.h
agg_vcgen_dash.o: agg_config.h
agg_vcgen_dash.o: agg_vertex_sequence.h
agg_vcgen_dash.o: agg_array.h
agg_vcgen_dash.o: agg_math.h
agg_vcgen_dash.o: agg_shorten_path.h
agg_vcgen_markers_term.o: agg_vcgen_markers_term.h
agg_vcgen_markers_term.o: agg_basics.h
agg_vcgen_markers_term.o: agg_config.h
agg_vcgen_markers_term.o: agg_vertex_sequence.h
agg_vcgen_markers_term.o: agg_array.h
agg_vcgen_markers_term.o: agg_math.h
agg_vcgen_smooth_poly1.o: agg_vcgen_smooth_poly1.h
agg_vcgen_smooth_poly1.o: agg_basics.h
agg_vcgen_smooth_poly1.o: agg_config.h
agg_vcgen_smooth_poly1.o: agg_vertex_sequence.h
agg_vcgen_smooth_poly1.o: agg_array.h
agg_vcgen_smooth_poly1.o: agg_math.h
agg_vcgen_stroke.o: agg_vcgen_stroke.h
agg_vcgen_stroke.o: agg_math_stroke.h
agg_vcgen_stroke.o: agg_math.h
agg_vcgen_stroke.o: agg_basics.h
agg_vcgen_stroke.o: agg_config.h
agg_vcgen_stroke.o: agg_vertex_sequence.h
agg_vcgen_stroke.o: agg_array.h
agg_vcgen_stroke.o: agg_shorten_path.h
agg_vcgen_bspline.o: agg_vcgen_bspline.h
agg_vcgen_bspline.o: agg_basics.h
agg_vcgen_bspline.o: agg_config.h
agg_vcgen_bspline.o: agg_array.h
agg_vcgen_bspline.o: agg_bspline.h
agg_gsv_text.o: agg_gsv_text.h
agg_gsv_text.o: agg_array.h
agg_gsv_text.o: agg_basics.h
agg_gsv_text.o: agg_config.h
agg_gsv_text.o: agg_conv_stroke.h
agg_gsv_text.o: agg_vcgen_stroke.h
agg_gsv_text.o: agg_math_stroke.h
agg_gsv_text.o: agg_math.h
agg_gsv_text.o: agg_vertex_sequence.h
agg_gsv_text.o: agg_conv_adaptor_vcgen.h
agg_gsv_text.o: agg_conv_transform.h
agg_gsv_text.o: agg_trans_affine.h
agg_gsv_text.o: agg_bounding_rect.h
agg_image_filters.o: agg_image_filters.h
agg_image_filters.o: agg_array.h
agg_image_filters.o: agg_basics.h
agg_image_filters.o: agg_config.h
agg_image_filters.o: agg_math.h
agg_line_aa_basics.o: agg_line_aa_basics.h
agg_line_aa_basics.o: agg_basics.h
agg_line_aa_basics.o: agg_config.h
agg_line_profile_aa.o: agg_renderer_outline_aa.h
agg_line_profile_aa.o: agg_array.h
agg_line_profile_aa.o: agg_basics.h
agg_line_profile_aa.o: agg_config.h
agg_line_profile_aa.o: agg_math.h
agg_line_profile_aa.o: agg_line_aa_basics.h
agg_line_profile_aa.o: agg_dda_line.h
agg_line_profile_aa.o: agg_ellipse_bresenham.h
agg_line_profile_aa.o: agg_renderer_base.h
agg_line_profile_aa.o: agg_rendering_buffer.h
agg_line_profile_aa.o: agg_gamma_functions.h
agg_line_profile_aa.o: agg_clip_liang_barsky.h
agg_rounded_rect.o: agg_rounded_rect.h
agg_rounded_rect.o: agg_basics.h
agg_rounded_rect.o: agg_config.h
agg_rounded_rect.o: agg_arc.h
agg_sqrt_tables.o: agg_basics.h
agg_sqrt_tables.o: agg_config.h
agg_embedded_raster_fonts.o: agg_embedded_raster_fonts.h
agg_embedded_raster_fonts.o: agg_basics.h
agg_embedded_raster_fonts.o: agg_config.h
agg_trans_affine.o: agg_trans_affine.h
agg_trans_affine.o: agg_basics.h
agg_trans_affine.o: agg_config.h
agg_trans_warp_magnifier.o: agg_trans_warp_magnifier.h
agg_trans_single_path.o: agg_math.h
agg_trans_single_path.o: agg_basics.h
agg_trans_single_path.o: agg_config.h
agg_trans_single_path.o: agg_vertex_sequence.h
agg_trans_single_path.o: agg_array.h
agg_trans_single_path.o: agg_trans_single_path.h
agg_trans_double_path.o: agg_math.h
agg_trans_double_path.o: agg_basics.h
agg_trans_double_path.o: agg_config.h
agg_trans_double_path.o: agg_trans_double_path.h
agg_trans_double_path.o: agg_vertex_sequence.h
agg_trans_double_path.o: agg_array.h
agg_vpgen_clip_polygon.o: agg_vpgen_clip_polygon.h
agg_vpgen_clip_polygon.o: agg_basics.h
agg_vpgen_clip_polygon.o: agg_config.h
agg_vpgen_clip_polygon.o: agg_clip_liang_barsky.h
agg_vpgen_clip_polyline.o: agg_vpgen_clip_polyline.h
agg_vpgen_clip_polyline.o: agg_basics.h
agg_vpgen_clip_polyline.o: agg_config.h
agg_vpgen_clip_polyline.o: agg_clip_liang_barsky.h
agg_vpgen_segmentator.o: agg_vpgen_segmentator.h
agg_vpgen_segmentator.o: agg_basics.h
agg_vpgen_segmentator.o: agg_config.h
gpc.o: gpc.h
