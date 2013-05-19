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
.PRECIOUS:

INCLUDE	= -I. -I../../mstl -I../../util -I../../util/expat -Iagg
CXXFLAGS	+= $(OPTIMIZE) $(CXX_DEBUG) $(PROFILING)

SRC_CXX = \
	svg_exception.cpp \
	svg_gradient.cpp \
	svg_parser.cpp \
	svg_path_renderer.cpp \
	svg_path_tokenizer.cpp \

SRC	= $(SRC_CXX)
OBJS	= $(SRC_CXX:.cpp=.o)
LIB	= libsvg

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

svg_exception.o: svg_exception.h
svg_exception.o: ../../mstl/m_exception.h
svg_exception.o: ../../mstl/m_backtrace.h
svg_exception.o: ../../mstl/m_types.h
svg_exception.o: ../../mstl/m_exception.ipp
svg_exception.o: ../../mstl/m_stdio.h
svg_gradient.o: svg_gradient.h
svg_gradient.o: agg/agg_color_rgba.h
svg_gradient.o: agg/agg_basics.h
svg_gradient.o: agg/agg_config.h
svg_gradient.o: agg/agg_trans_affine.h
svg_gradient.o: agg/agg_span_gradient.h
svg_gradient.o: agg/agg_math.h
svg_gradient.o: agg/agg_array.h
svg_gradient.o: ../../mstl/m_map.h
svg_gradient.o: ../../mstl/m_vector.h
svg_gradient.o: ../../mstl/m_type_traits.h
svg_gradient.o: ../../mstl/m_type_traits.ipp
svg_gradient.o: ../../mstl/m_types.h
svg_gradient.o: ../../mstl/m_memblock.h
svg_gradient.o: ../../mstl/m_memblock.ipp
svg_gradient.o: ../../mstl/m_utility.h
svg_gradient.o: ../../mstl/m_utility.ipp
svg_gradient.o: ../../mstl/m_limits.h
svg_gradient.o: ../../mstl/m_bit_functions.h
svg_gradient.o: ../../mstl/m_bit_functions.ipp
svg_gradient.o: ../../mstl/m_uint128_t.h
svg_gradient.o: ../../mstl/m_uint128.h
svg_gradient.o: ../../mstl/m_assert.h
svg_gradient.o: ../../mstl/m_exception.h
svg_gradient.o: ../../mstl/m_backtrace.h
svg_gradient.o: ../../mstl/m_exception.ipp
svg_gradient.o: ../../mstl/m_pointer_iterator.h
svg_gradient.o: ../../mstl/m_pointer_iterator.ipp
svg_gradient.o: ../../mstl/m_iterator.h
svg_gradient.o: ../../mstl/m_iterator.ipp
svg_gradient.o: ../../mstl/m_vector.ipp
svg_gradient.o: ../../mstl/m_uninitialized.h
svg_gradient.o: ../../mstl/m_uninitialized.ipp
svg_gradient.o: ../../mstl/m_algobase.h
svg_gradient.o: ../../mstl/m_algobase.ipp
svg_gradient.o: ../../mstl/m_construct.h
svg_gradient.o: ../../mstl/m_construct.ipp
svg_gradient.o: ../../mstl/m_pair.h
svg_gradient.o: ../../mstl/m_pair.ipp
svg_gradient.o: ../../mstl/m_map.ipp
svg_gradient.o: ../../mstl/m_string.h
svg_gradient.o: ../../mstl/m_string.ipp
svg_parser.o: svg_parser.h
svg_parser.o: svg_path_tokenizer.h
svg_parser.o: svg_path_renderer.h
svg_parser.o: svg_gradient.h
svg_parser.o: agg/agg_color_rgba.h
svg_parser.o: agg/agg_basics.h
svg_parser.o: agg/agg_config.h
svg_parser.o: agg/agg_trans_affine.h
svg_parser.o: agg/agg_span_gradient.h
svg_parser.o: agg/agg_math.h
svg_parser.o: agg/agg_array.h
svg_parser.o: ../../mstl/m_map.h
svg_parser.o: ../../mstl/m_vector.h
svg_parser.o: ../../mstl/m_type_traits.h
svg_parser.o: ../../mstl/m_type_traits.ipp
svg_parser.o: ../../mstl/m_types.h
svg_parser.o: ../../mstl/m_memblock.h
svg_parser.o: ../../mstl/m_memblock.ipp
svg_parser.o: ../../mstl/m_utility.h
svg_parser.o: ../../mstl/m_utility.ipp
svg_parser.o: ../../mstl/m_limits.h
svg_parser.o: ../../mstl/m_bit_functions.h
svg_parser.o: ../../mstl/m_bit_functions.ipp
svg_parser.o: ../../mstl/m_uint128_t.h
svg_parser.o: ../../mstl/m_uint128.h
svg_parser.o: ../../mstl/m_assert.h
svg_parser.o: ../../mstl/m_exception.h
svg_parser.o: ../../mstl/m_backtrace.h
svg_parser.o: ../../mstl/m_exception.ipp
svg_parser.o: ../../mstl/m_pointer_iterator.h
svg_parser.o: ../../mstl/m_pointer_iterator.ipp
svg_parser.o: ../../mstl/m_iterator.h
svg_parser.o: ../../mstl/m_iterator.ipp
svg_parser.o: ../../mstl/m_vector.ipp
svg_parser.o: ../../mstl/m_uninitialized.h
svg_parser.o: ../../mstl/m_uninitialized.ipp
svg_parser.o: ../../mstl/m_algobase.h
svg_parser.o: ../../mstl/m_algobase.ipp
svg_parser.o: ../../mstl/m_construct.h
svg_parser.o: ../../mstl/m_construct.ipp
svg_parser.o: ../../mstl/m_pair.h
svg_parser.o: ../../mstl/m_pair.ipp
svg_parser.o: ../../mstl/m_map.ipp
svg_parser.o: ../../mstl/m_string.h
svg_parser.o: ../../mstl/m_string.ipp
svg_parser.o: agg/agg_path_storage.h
svg_parser.o: agg/agg_bezier_arc.h
svg_parser.o: agg/agg_conv_transform.h
svg_parser.o: agg/agg_conv_stroke.h
svg_parser.o: agg/agg_vcgen_stroke.h
svg_parser.o: agg/agg_math_stroke.h
svg_parser.o: agg/agg_vertex_sequence.h
svg_parser.o: agg/agg_conv_adaptor_vcgen.h
svg_parser.o: agg/agg_conv_contour.h
svg_parser.o: agg/agg_vcgen_contour.h
svg_parser.o: agg/agg_conv_curve.h
svg_parser.o: agg/agg_curves.h
svg_parser.o: agg/agg_bounding_rect.h
svg_parser.o: svg_path_renderer.ipp
svg_parser.o: agg/agg_renderer_scanline.h
svg_parser.o: agg/agg_renderer_base.h
svg_parser.o: agg/agg_rendering_buffer.h
svg_parser.o: agg/agg_rasterizer_scanline_aa.h
svg_parser.o: agg/agg_rasterizer_cells_aa.h
svg_parser.o: agg/agg_rasterizer_sl_clip.h
svg_parser.o: agg/agg_clip_liang_barsky.h
svg_parser.o: agg/agg_gamma_functions.h
svg_parser.o: agg/agg_scanline_p.h
svg_parser.o: agg/agg_span_allocator.h
svg_parser.o: agg/agg_span_interpolator_linear.h
svg_parser.o: agg/agg_dda_line.h
svg_parser.o: svg_exception.h
svg_parser.o: agg/agg_ellipse.h
svg_parser.o: ../../util/u_base.h
svg_parser.o: ../../mstl/m_stdio.h
svg_parser.o: ../../util/expat/expat.h
svg_parser.o: ../../util/expat/xmlparse.h
svg_path_renderer.o: svg_path_renderer.h
svg_path_renderer.o: svg_path_tokenizer.h
svg_path_renderer.o: svg_gradient.h
svg_path_renderer.o: agg/agg_color_rgba.h
svg_path_renderer.o: agg/agg_basics.h
svg_path_renderer.o: agg/agg_config.h
svg_path_renderer.o: agg/agg_trans_affine.h
svg_path_renderer.o: agg/agg_span_gradient.h
svg_path_renderer.o: agg/agg_math.h
svg_path_renderer.o: agg/agg_array.h
svg_path_renderer.o: ../../mstl/m_map.h
svg_path_renderer.o: ../../mstl/m_vector.h
svg_path_renderer.o: ../../mstl/m_type_traits.h
svg_path_renderer.o: ../../mstl/m_type_traits.ipp
svg_path_renderer.o: ../../mstl/m_types.h
svg_path_renderer.o: ../../mstl/m_memblock.h
svg_path_renderer.o: ../../mstl/m_memblock.ipp
svg_path_renderer.o: ../../mstl/m_utility.h
svg_path_renderer.o: ../../mstl/m_utility.ipp
svg_path_renderer.o: ../../mstl/m_limits.h
svg_path_renderer.o: ../../mstl/m_bit_functions.h
svg_path_renderer.o: ../../mstl/m_bit_functions.ipp
svg_path_renderer.o: ../../mstl/m_uint128_t.h
svg_path_renderer.o: ../../mstl/m_uint128.h
svg_path_renderer.o: ../../mstl/m_assert.h
svg_path_renderer.o: ../../mstl/m_exception.h
svg_path_renderer.o: ../../mstl/m_backtrace.h
svg_path_renderer.o: ../../mstl/m_exception.ipp
svg_path_renderer.o: ../../mstl/m_pointer_iterator.h
svg_path_renderer.o: ../../mstl/m_pointer_iterator.ipp
svg_path_renderer.o: ../../mstl/m_iterator.h
svg_path_renderer.o: ../../mstl/m_iterator.ipp
svg_path_renderer.o: ../../mstl/m_vector.ipp
svg_path_renderer.o: ../../mstl/m_uninitialized.h
svg_path_renderer.o: ../../mstl/m_uninitialized.ipp
svg_path_renderer.o: ../../mstl/m_algobase.h
svg_path_renderer.o: ../../mstl/m_algobase.ipp
svg_path_renderer.o: ../../mstl/m_construct.h
svg_path_renderer.o: ../../mstl/m_construct.ipp
svg_path_renderer.o: ../../mstl/m_pair.h
svg_path_renderer.o: ../../mstl/m_pair.ipp
svg_path_renderer.o: ../../mstl/m_map.ipp
svg_path_renderer.o: ../../mstl/m_string.h
svg_path_renderer.o: ../../mstl/m_string.ipp
svg_path_renderer.o: agg/agg_path_storage.h
svg_path_renderer.o: agg/agg_bezier_arc.h
svg_path_renderer.o: agg/agg_conv_transform.h
svg_path_renderer.o: agg/agg_conv_stroke.h
svg_path_renderer.o: agg/agg_vcgen_stroke.h
svg_path_renderer.o: agg/agg_math_stroke.h
svg_path_renderer.o: agg/agg_vertex_sequence.h
svg_path_renderer.o: agg/agg_conv_adaptor_vcgen.h
svg_path_renderer.o: agg/agg_conv_contour.h
svg_path_renderer.o: agg/agg_vcgen_contour.h
svg_path_renderer.o: agg/agg_conv_curve.h
svg_path_renderer.o: agg/agg_curves.h
svg_path_renderer.o: agg/agg_bounding_rect.h
svg_path_renderer.o: svg_path_renderer.ipp
svg_path_renderer.o: agg/agg_renderer_scanline.h
svg_path_renderer.o: agg/agg_renderer_base.h
svg_path_renderer.o: agg/agg_rendering_buffer.h
svg_path_renderer.o: agg/agg_rasterizer_scanline_aa.h
svg_path_renderer.o: agg/agg_rasterizer_cells_aa.h
svg_path_renderer.o: agg/agg_rasterizer_sl_clip.h
svg_path_renderer.o: agg/agg_clip_liang_barsky.h
svg_path_renderer.o: agg/agg_gamma_functions.h
svg_path_renderer.o: agg/agg_scanline_p.h
svg_path_renderer.o: agg/agg_span_allocator.h
svg_path_renderer.o: agg/agg_span_interpolator_linear.h
svg_path_renderer.o: agg/agg_dda_line.h
svg_path_renderer.o: svg_exception.h
svg_path_tokenizer.o: svg_path_tokenizer.h
svg_path_tokenizer.o: svg_exception.h
svg_path_tokenizer.o: ../../mstl/m_exception.h
svg_path_tokenizer.o: ../../mstl/m_backtrace.h
svg_path_tokenizer.o: ../../mstl/m_types.h
svg_path_tokenizer.o: ../../mstl/m_exception.ipp
