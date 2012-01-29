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

INCLUDE	= -I. -I../mstl -I../sys -I../util -I../util/zlib -Itcl$(TCL_VERSION) -Itk$(TCL_VERSION) -I../tcl -Isvg -Isvg/agg -Ijpeg
ALL_INCLUDE	= $(INCLUDE) $(TCL_INCLUDE) $(TK_INCLUDE)
CFLAGS	+= $(OPTIMIZE) $(C_DEBUG) $(PROFILING)
CXXFLAGS	+= $(OPTIMIZE) $(CXX_DEBUG) $(PROFILING)

SRC_CXX = \
	tk_busy.cpp \
	tk_image.cpp \
	tk_init.cpp \
	tk_jpeg.cpp \
	tk_multiwindow.cpp \
	tk_png.cpp \
	tk_twm.cpp \
	tk_window_manager.cpp \
	tk_x11.cpp \
	tk_xcursor.cpp \

SRC	= $(SRC_CXX)
OBJS	= $(SRC_CXX:.cpp=.o)
LIB	= libtk

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
	@$(CXX) -c $(CXXFLAGS) $(EXTRA_CXXFLAGS) $(EXTRA_CFLAGS) $(ALL_INCLUDE) $<

# vi:set ts=3 sw=3:
# DO NOT DELETE THIS LINE -- make depend depends on it.

tk_busy.o: tk_init.h
tk_busy.o: ../tcl/tcl_base.h
tk_busy.o: ../tcl/tcl_base.ipp
tk_busy.o: tk8.5/tkInt.h
tk_busy.o: tk8.5/tkPort.h
tk_busy.o: tk8.5/tkUnixPort.h
tk_busy.o: tk8.5/tkIntDecls.h
tk_busy.o: ../mstl/m_types.h
tk_image.o: tk_init.h
tk_image.o: svg/svg_path_renderer.h
tk_image.o: svg/svg_path_tokenizer.h
tk_image.o: svg/svg_gradient.h
tk_image.o: svg/agg/agg_color_rgba.h
tk_image.o: svg/agg/agg_basics.h
tk_image.o: svg/agg/agg_config.h
tk_image.o: svg/agg/agg_trans_affine.h
tk_image.o: svg/agg/agg_span_gradient.h
tk_image.o: svg/agg/agg_math.h
tk_image.o: svg/agg/agg_array.h
tk_image.o: ../mstl/m_map.h
tk_image.o: ../mstl/m_vector.h
tk_image.o: ../mstl/m_type_traits.h
tk_image.o: ../mstl/m_type_traits.ipp
tk_image.o: ../mstl/m_types.h
tk_image.o: ../mstl/m_memblock.h
tk_image.o: ../mstl/m_memblock.ipp
tk_image.o: ../mstl/m_utility.h
tk_image.o: ../mstl/m_utility.ipp
tk_image.o: ../mstl/m_limits.h
tk_image.o: ../mstl/m_bit_functions.h
tk_image.o: ../mstl/m_bit_functions.ipp
tk_image.o: ../mstl/m_assert.h
tk_image.o: ../mstl/m_exception.h
tk_image.o: ../mstl/m_backtrace.h
tk_image.o: ../mstl/m_exception.ipp
tk_image.o: ../mstl/m_vector.ipp
tk_image.o: ../mstl/m_uninitialized.h
tk_image.o: ../mstl/m_uninitialized.ipp
tk_image.o: ../mstl/m_algobase.h
tk_image.o: ../mstl/m_algobase.ipp
tk_image.o: ../mstl/m_construct.h
tk_image.o: ../mstl/m_construct.ipp
tk_image.o: ../mstl/m_pair.h
tk_image.o: ../mstl/m_pair.ipp
tk_image.o: ../mstl/m_map.ipp
tk_image.o: ../mstl/m_string.h
tk_image.o: ../mstl/m_string.ipp
tk_image.o: svg/agg/agg_path_storage.h
tk_image.o: svg/agg/agg_bezier_arc.h
tk_image.o: svg/agg/agg_conv_transform.h
tk_image.o: svg/agg/agg_conv_stroke.h
tk_image.o: svg/agg/agg_vcgen_stroke.h
tk_image.o: svg/agg/agg_math_stroke.h
tk_image.o: svg/agg/agg_vertex_sequence.h
tk_image.o: svg/agg/agg_conv_adaptor_vcgen.h
tk_image.o: svg/agg/agg_conv_contour.h
tk_image.o: svg/agg/agg_vcgen_contour.h
tk_image.o: svg/agg/agg_conv_curve.h
tk_image.o: svg/agg/agg_curves.h
tk_image.o: svg/agg/agg_bounding_rect.h
tk_image.o: svg/svg_path_renderer.ipp
tk_image.o: svg/agg/agg_renderer_scanline.h
tk_image.o: svg/agg/agg_renderer_base.h
tk_image.o: svg/agg/agg_rendering_buffer.h
tk_image.o: svg/agg/agg_rasterizer_scanline_aa.h
tk_image.o: svg/agg/agg_rasterizer_cells_aa.h
tk_image.o: svg/agg/agg_rasterizer_sl_clip.h
tk_image.o: svg/agg/agg_clip_liang_barsky.h
tk_image.o: svg/agg/agg_gamma_functions.h
tk_image.o: svg/agg/agg_scanline_p.h
tk_image.o: svg/agg/agg_span_allocator.h
tk_image.o: svg/agg/agg_span_interpolator_linear.h
tk_image.o: svg/agg/agg_dda_line.h
tk_image.o: svg/svg_parser.h
tk_image.o: svg/svg_exception.h
tk_image.o: ../tcl/tcl_base.h
tk_image.o: ../tcl/tcl_base.ipp
tk_image.o: ../util/u_base.h
tk_image.o: svg/agg/agg_pixfmt_rgb.h
tk_image.o: svg/agg/agg_pixfmt_rgba.h
tk_image.o: svg/agg/agg_image_accessors.h
tk_image.o: svg/agg/agg_scanline_u.h
tk_image.o: svg/agg/agg_span_image_filter_rgb.h
tk_image.o: svg/agg/agg_span_image_filter.h
tk_image.o: svg/agg/agg_image_filters.h
tk_image.o: svg/agg/agg_span_image_filter_rgba.h
tk_image.o: svg/agg/agg_blur.h
tk_image.o: svg/agg/agg_pixfmt_transposer.h
tk_init.o: tk_init.h
tk_jpeg.o: tk_init.h
tk_jpeg.o: jpeg/jpeg_image.h
tk_jpeg.o: jpeg/jpeg_scanline.h
tk_jpeg.o: jpeg/jpeg_reader.h
tk_jpeg.o: jpeg/jpeg_exception.h
tk_jpeg.o: ../util/u_base64_decoder.h
tk_jpeg.o: ../mstl/m_types.h
tk_multiwindow.o: tk_init.h
tk_multiwindow.o: ../tcl/tcl_base.h
tk_multiwindow.o: ../tcl/tcl_base.ipp
tk_multiwindow.o: tk8.5/tkInt.h
tk_multiwindow.o: tk8.5/tkPort.h
tk_multiwindow.o: tk8.5/tkUnixPort.h
tk_multiwindow.o: tk8.5/tkIntDecls.h
tk_multiwindow.o: ../mstl/m_types.h
tk_png.o: ../util/zlib/zlib.h
tk_png.o: ../util/zlib/zconf.h
tk_png.o: tk_init.h
tk_twm.o: tk_init.h
tk_twm.o: tk8.5/tkInt.h
tk_twm.o: tk8.5/tkPort.h
tk_twm.o: tk8.5/tkUnixPort.h
tk_twm.o: tk8.5/tkIntDecls.h
tk_twm.o: ../tcl/tcl_exception.h
tk_twm.o: ../util/u_exception.h
tk_twm.o: ../mstl/m_exception.h
tk_twm.o: ../mstl/m_backtrace.h
tk_twm.o: ../mstl/m_types.h
tk_twm.o: ../mstl/m_exception.ipp
tk_twm.o: ../tcl/tcl_base.h
tk_twm.o: ../tcl/tcl_base.ipp
tk_twm.o: ../mstl/m_vector.h
tk_twm.o: ../mstl/m_type_traits.h
tk_twm.o: ../mstl/m_type_traits.ipp
tk_twm.o: ../mstl/m_memblock.h
tk_twm.o: ../mstl/m_memblock.ipp
tk_twm.o: ../mstl/m_utility.h
tk_twm.o: ../mstl/m_utility.ipp
tk_twm.o: ../mstl/m_limits.h
tk_twm.o: ../mstl/m_bit_functions.h
tk_twm.o: ../mstl/m_bit_functions.ipp
tk_twm.o: ../mstl/m_assert.h
tk_twm.o: ../mstl/m_vector.ipp
tk_twm.o: ../mstl/m_uninitialized.h
tk_twm.o: ../mstl/m_uninitialized.ipp
tk_twm.o: ../mstl/m_algobase.h
tk_twm.o: ../mstl/m_algobase.ipp
tk_twm.o: ../mstl/m_construct.h
tk_twm.o: ../mstl/m_construct.ipp
tk_twm.o: ../mstl/m_list.h
tk_twm.o: ../mstl/m_pointer_iterator.h
tk_twm.o: ../mstl/m_pointer_iterator.ipp
tk_twm.o: ../mstl/m_list.ipp
tk_twm.o: ../mstl/m_string.h
tk_twm.o: ../mstl/m_string.ipp
tk_twm.o: ../mstl/m_algorithm.h
tk_twm.o: ../mstl/m_algorithm.ipp
tk_twm.o: ../mstl/m_map.h
tk_twm.o: ../mstl/m_pair.h
tk_twm.o: ../mstl/m_pair.ipp
tk_twm.o: ../mstl/m_map.ipp
tk_window_manager.o: tk_init.h
tk_window_manager.o: ../util/u_base.h
tk_window_manager.o: ../mstl/m_types.h
tk_window_manager.o: ../mstl/m_stdio.h
tk_window_manager.o: ../mstl/m_assert.h
tk_window_manager.o: ../mstl/m_exception.h
tk_window_manager.o: ../mstl/m_backtrace.h
tk_window_manager.o: ../mstl/m_exception.ipp
tk_x11.o: tk_init.h
tk_x11.o: ../tcl/tcl_base.h
tk_x11.o: ../tcl/tcl_base.ipp
tk_x11.o: ../mstl/m_utility.h
tk_x11.o: ../mstl/m_types.h
tk_x11.o: ../mstl/m_type_traits.h
tk_x11.o: ../mstl/m_type_traits.ipp
tk_x11.o: ../mstl/m_utility.ipp
tk_x11.o: ../mstl/m_limits.h
tk_x11.o: ../mstl/m_bit_functions.h
tk_x11.o: ../mstl/m_bit_functions.ipp
tk_x11.o: ../mstl/m_assert.h
tk_x11.o: ../mstl/m_exception.h
tk_x11.o: ../mstl/m_backtrace.h
tk_x11.o: ../mstl/m_exception.ipp
tk_xcursor.o: ./X11/Xcursor/Xcursor.h
