// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2008-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "tk_init.h"

#include "svg_path_renderer.h"
#include "svg_parser.h"
#include "svg_gradient.h"
#include "svg_exception.h"

#include "tcl_base.h"

#include "m_assert.h"

#include "agg_pixfmt_rgb.h"
#include "agg_pixfmt_rgba.h"
#include "agg_scanline_p.h"
#include "agg_renderer_base.h"
#include "agg_trans_affine.h"
#include "agg_image_accessors.h"
#include "agg_rasterizer_scanline_aa.h"
#include "agg_scanline_u.h"
#include "agg_span_allocator.h"
#include "agg_renderer_scanline.h"
#include "agg_span_image_filter_rgb.h"
#include "agg_span_image_filter_rgba.h"
#include "agg_blur.h"

#include <tcl.h>
#include <tk.h>

#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

using namespace tcl;

//#define DEBUG(expr) expr

#ifndef DEBUG
# define DEBUG(expr)
#endif

//#define NEED_BGR

#define RGB		0,1,2,0
#define BGR		2,1,0,0
#define RGBA	0,1,2,3
#define BGRA	2,1,0,3


namespace {

typedef agg::span_interpolator_linear<> agg_interpolator_type;

template<int R, int G, int B, int A> struct agg_types;

template<> struct agg_types<RGB>
{
	typedef agg::pixfmt_rgb24 pixfmt;
	typedef agg::image_accessor_clone<pixfmt> image_accessor_clone;
	typedef agg::span_image_filter_rgb_2x2<image_accessor_clone, agg_interpolator_type> span_gen_type;
};
template<> struct agg_types<BGR>
{
	typedef agg::pixfmt_bgr24  pixfmt;
	typedef agg::image_accessor_clone<pixfmt> image_accessor_clone;
	typedef agg::span_image_filter_rgb_2x2<image_accessor_clone, agg_interpolator_type> span_gen_type;
};
template <> struct agg_types<RGBA>
{
	typedef agg::pixfmt_rgba32 pixfmt;
	typedef agg::image_accessor_clone<pixfmt> image_accessor_clone;
	typedef agg::span_image_filter_rgba_2x2<image_accessor_clone, agg_interpolator_type> span_gen_type;
};
template <> struct agg_types<BGRA>
{
	typedef agg::pixfmt_bgra32 pixfmt;
	typedef agg::image_accessor_clone<pixfmt> image_accessor_clone;
	typedef agg::span_image_filter_rgba_2x2<image_accessor_clone, agg_interpolator_type> span_gen_type;
};


struct rasterizer
{
	rasterizer(int x, int y, int w, int h) :m_x(x), m_y(y), m_w(w), m_h(h), m_curr(0) {}

	int m_x, m_y, m_w, m_h;
	int m_curr;

	int min_x() const { return m_x; }
	int max_x() const { return m_x + m_w - 1; }

	bool rewind_scanlines()
	{
		m_curr = m_x;
		return true;
	}

	template<class Scanline>
	bool sweep_scanline(Scanline& sl)
	{
		if (m_curr + 1 > m_h)
			return false;

		sl.reset_spans();
		sl.add_span(m_x, m_w, 255);
		sl.finalize(m_curr);
		m_curr++;

		return true;
	}
};


inline int mul4(int x)							{ return x << 2; }
inline int clip(int v, int min, int max)	{ return v < min ? min : (max < v ? max : v); }


inline
int
colorize(int channel, int value, double brighten)
{
	static double const Table[256] =
	{
		0.00000000, 0.01562476, 0.03112649, 0.04650519, 0.06176086, 0.07689350, 0.09190311, 0.10678970,
		0.12155325, 0.13619377, 0.15071126, 0.16510573, 0.17937716, 0.19352557, 0.20755094, 0.22145329,
		0.23523260, 0.24888889, 0.26242215, 0.27583237, 0.28911957, 0.30228374, 0.31532488, 0.32824298,
		0.34103806, 0.35371011, 0.36625913, 0.37868512, 0.39098808, 0.40316801, 0.41522491, 0.42715879,
		0.43896963, 0.45065744, 0.46222222, 0.47366398, 0.48498270, 0.49617839, 0.50725106, 0.51820069,
		0.52902730, 0.53973087, 0.55031142, 0.56076894, 0.57110342, 0.58131488, 0.59140331, 0.60136870,
		0.61121107, 0.62093041, 0.63052672, 0.64000000, 0.64935025, 0.65857747, 0.66768166, 0.67666282,
		0.68552095, 0.69425606, 0.70286813, 0.71135717, 0.71972318, 0.72796617, 0.73608612, 0.74408304,
		0.75195694, 0.75970780, 0.76733564, 0.77484045, 0.78222222, 0.78948097, 0.79661669, 0.80362937,
		0.81051903, 0.81728566, 0.82392926, 0.83044983, 0.83684737, 0.84312188, 0.84927336, 0.85530181,
		0.86120723, 0.86698962, 0.87264898, 0.87818531, 0.88359862, 0.88888889, 0.89405613, 0.89910035,
		0.90402153, 0.90881968, 0.91349481, 0.91804691, 0.92247597, 0.92678201, 0.93096501, 0.93502499,
		0.93896194, 0.94277586, 0.94646674, 0.95003460, 0.95347943, 0.95680123, 0.96000000, 0.96307574,
		0.96602845, 0.96885813, 0.97156478, 0.97414840, 0.97660900, 0.97894656, 0.98116109, 0.98325260,
		0.98522107, 0.98706651, 0.98878893, 0.99038831, 0.99186467, 0.99321799, 0.99444829, 0.99555556,
		0.99653979, 0.99740100, 0.99813918, 0.99875433, 0.99924644, 0.99961553, 0.99986159, 0.99998462,
		0.99998462, 0.99986159, 0.99961553, 0.99924644, 0.99875433, 0.99813918, 0.99740100, 0.99653979,
		0.99555556, 0.99444829, 0.99321799, 0.99186467, 0.99038831, 0.98878893, 0.98706651, 0.98522107,
		0.98325260, 0.98116109, 0.97894656, 0.97660900, 0.97414840, 0.97156478, 0.96885813, 0.96602845,
		0.96307574, 0.96000000, 0.95680123, 0.95347943, 0.95003460, 0.94646674, 0.94277586, 0.93896194,
		0.93502499, 0.93096501, 0.92678201, 0.92247597, 0.91804691, 0.91349481, 0.90881968, 0.90402153,
		0.89910035, 0.89405613, 0.88888889, 0.88359862, 0.87818531, 0.87264898, 0.86698962, 0.86120723,
		0.85530181, 0.84927336, 0.84312188, 0.83684737, 0.83044983, 0.82392926, 0.81728566, 0.81051903,
		0.80362937, 0.79661669, 0.78948097, 0.78222222, 0.77484045, 0.76733564, 0.75970780, 0.75195694,
		0.74408304, 0.73608612, 0.72796617, 0.71972318, 0.71135717, 0.70286813, 0.69425606, 0.68552095,
		0.67666282, 0.66768166, 0.65857747, 0.64935025, 0.64000000, 0.63052672, 0.62093041, 0.61121107,
		0.60136870, 0.59140331, 0.58131488, 0.57110342, 0.56076894, 0.55031142, 0.53973087, 0.52902730,
		0.51820069, 0.50725106, 0.49617839, 0.48498270, 0.47366398, 0.46222222, 0.45065744, 0.43896963,
		0.42715879, 0.41522491, 0.40316801, 0.39098808, 0.37868512, 0.36625913, 0.35371011, 0.34103806,
		0.32824298, 0.31532488, 0.30228374, 0.28911957, 0.27583237, 0.26242215, 0.24888889, 0.23523260,
		0.22145329, 0.20755094, 0.19352557, 0.17937716, 0.16510573, 0.15071126, 0.13619377, 0.12155325,
		0.10678970, 0.09190311, 0.07689350, 0.06176086, 0.04650519, 0.03112649, 0.01562476, 0.00000000,
	};

	return mstl::min(255, agg::iround(brighten*(channel + agg::iround(value*Table[channel]))));
}


template <int Alpha>
struct pixel
{
	pixel() :m_r(0.0), m_g(0.0), m_b(0.0), m_a(0.0) {}
	pixel(double r, double g, double b, double a) :m_r(r), m_g(g), m_b(b), m_a(a) {}

	pixel& operator+=(pixel const& pix)
	{
		m_r += pix.m_r;
		m_g += pix.m_g;
		m_b += pix.m_b;
		if (Alpha)
			m_a += pix.m_a;
		return *this;
	}

	pixel operator*(double s) const
	{
		return pixel(m_r*s, m_g*s, m_b*s, Alpha ? m_a*s : 0.0);
	}

	pixel operator+(pixel const& pix) const
	{
		return pixel(m_r + pix.m_r, m_g + pix.m_g, m_b + pix.m_b, Alpha ? m_a + pix.m_a : 0.0);
	}

	double m_r, m_g, m_b, m_a;
};


template <int R, int G, int B, int A>
struct pixbuf
{
	enum { N = (R == A || B == A ? 3 : 4) };
	enum { Alpha = (N == 4) };

	typedef pixel<Alpha> pixelA;
	typedef typename agg_types<R,G,B,A>::pixfmt agg_pixfmt;
	typedef typename agg_types<R,G,B,A>::span_gen_type agg_span_gen_type;
	typedef typename agg_types<R,G,B,A>::image_accessor_clone image_accessor_clone;

	pixbuf(Tk_PhotoImageBlock const& block)
		:m_buf(block.pixelPtr), m_rows(block.height), m_cols(block.width), m_pitch(block.pitch)
	{
	}

	unsigned char* buf()					{ return m_buf; }
	unsigned char const* buf() const	{ return m_buf; }

	unsigned char* scanline(int n) 					{ return m_buf + n*m_pitch; }
	unsigned char const* scanline(int n) const 	{ return m_buf + n*m_pitch; }

	int rows() const	{ return m_rows; }
	int cols() const	{ return m_cols; }
	int pitch() const	{ return m_pitch; }

	static int pixelSize() { return N; }

	void clear() const { memset(m_buf, 0, m_rows*m_pitch); }

	void next_scanline(pixelA* buf) const
	{
		unsigned char const* e = m_buf + N*m_cols;

		for (unsigned char const* p = m_buf; p < e; ++buf, p += N)
		{
			buf->m_r = p[R];
			buf->m_g = p[G];
			buf->m_b = p[B];
			if (Alpha)
				buf->m_a = p[A];
		}

		m_buf += m_pitch;
	}

	void set_scanline(pixelA const* buf)
	{
		unsigned char const* e = m_buf + N*m_cols;

		for (unsigned char* p = m_buf; p < e; p += N, ++buf)
		{
			p[R] = clip(int(buf->m_r + 0.5), 0, 255);
			p[G] = clip(int(buf->m_g + 0.5), 0, 255);
			p[B] = clip(int(buf->m_b + 0.5), 0, 255);
			if (Alpha)
				p[A] = clip(int(buf->m_a + 0.5), 0, 255);
		}

		m_buf += m_pitch;
	}

	void recolor(agg::rgba8 const& color, bool overlay)
	{
		unsigned char alphaTbl[256];

		if (Alpha)
		{
			if (overlay)
			{
				for (int i = 0; i < 256; ++i)
					alphaTbl[i] = agg::iround(i*(color.a/255.0));
			}
			else
			{
				memset(alphaTbl, 255, sizeof(alphaTbl));
			}
		}

		for (int r = 0; r < m_rows; ++r)
		{
			unsigned char* p = scanline(r);
			unsigned char* e = p + N*m_cols;

			for ( ; p < e; p += N)
			{
				p[R] = color.r;
				p[G] = color.g;
				p[B] = color.b;
				if (Alpha)
					p[A] = alphaTbl[p[A]];
			}
		}
	}

	void colorize(agg::rgba8 const& color, double brighten = 1.0)
	{
		for (int r = 0; r < m_rows; ++r)
		{
			unsigned char* p = scanline(r);
			unsigned char* e = p + N*m_cols;

			for ( ; p < e; p += N)
			{
				p[R] = ::colorize(p[R], color.r, brighten);
				p[G] = ::colorize(p[G], color.g, brighten);
				p[B] = ::colorize(p[B], color.b, brighten);
			}
		}
	}

	void blend(pixbuf const& src)
	{
		M_ASSERT(src.rows() == rows());
		M_ASSERT(src.cols() == cols());
		M_ASSERT(N == 4);

		for (int y = 0; y < m_rows; ++y)
		{
			uint32_t const*	p = reinterpret_cast<uint32_t const*>(src.scanline(y));
			uint32_t const*	e = p + m_cols;
			uint32_t*			q = reinterpret_cast<uint32_t*>(scanline(y));

			for ( ; p < e; ++p, ++q)
			{
				int alpha = reinterpret_cast<unsigned char*>(q)[A];
				*q = *p;
				reinterpret_cast<unsigned char*>(q)[A] = alpha;
			}
		}
	}

	void set_alpha(double alpha, bool overlay)
	{
		if (overlay)
		{
			for (int r = 0; r < m_rows; ++r)
			{
				unsigned char* p = scanline(r);
				unsigned char* e = p + N*m_cols;

				for ( ; p < e; p += N)
					p[A] = agg::iround(p[A]*alpha);
			}
		}
		else
		{
			unsigned char a = agg::iround(255*alpha);

			for (int r = 0; r < m_rows; ++r)
			{
				unsigned char* p = scanline(r);
				unsigned char* e = p + N*m_cols;

				for ( ; p < e; p += N)
					p[A] = a;
			}
		}
	}

	void diffuse_alpha(double max)
	{
		unsigned char map[256];

		if (max == 0.0)
			return;

		unsigned maxima = agg::iround(255.0*max);

		double f = 1.0/(max*255.0);
		double s = 1.0/f;

		for (unsigned i = 0; i < maxima; ++i)
			map[i] = mstl::min(255, agg::iround(mstl::sqr(f*i)*s));
		for (unsigned i = maxima; i < 256; ++i)
			map[i] = maxima;

		for (int r = 0; r < m_rows; ++r)
		{
			unsigned char* p = scanline(r);
			unsigned char* e = p + N*m_cols;

			for ( ; p < e; p += N)
				p[A] = map[p[A]];
		}
	}

	void boost_alpha(double min, double max)
	{
		if (min >= max)
			return;

		unsigned char minima = agg::iround(255.0*min);
		unsigned char maxima = agg::iround(255.0*max);
		unsigned char maxval = 0;

		for (int r = 0; r < m_rows; ++r)
		{
			unsigned char* p = scanline(r);
			unsigned char* e = p + N*m_cols;

			for ( ; p < e; p += N)
				maxval = mstl::max(maxval, p[A]);
		}

		if (maxval >= maxima)
			return;

		char map[256] = { 0 };

		double f = double(maxima)/double(maxval);
		double s = max/(max - min);

		for (unsigned i = 1; i < 256; ++i)
			map[i] = mstl::min(255, mstl::max(0, agg::iround(f*s*(i - minima))));

		for (int r = 0; r < m_rows; ++r)
		{
			unsigned char* p = scanline(r);
			unsigned char* e = p + N*m_cols;

			for ( ; p < e; p += N)
				p[A] = map[p[A]];
		}
	}

	static void set_alpha(unsigned char* p, int alpha) { p[A] = alpha; }

	static void set_pixel(unsigned char* p, int r, int g, int b, int a)
	{
		p[R] = r; p[G] = g; p[B] = b; p[A] = a;
	}

	mutable unsigned char* m_buf;
	int m_rows;
	int m_cols;
	int m_pitch;
};


template <int Alpha>
inline
pixel<Alpha>
operator*(double s, pixel<Alpha> const& pix)
{
	return pix.operator*(s);
}


bool
match(agg::rgba8 const& lhs, agg::rgba8 const& rhs)
{
	return lhs.r == rhs.r && lhs.g == rhs.g && lhs.b == rhs.b;
}


struct renderer : public svg::path_renderer
{
	renderer()
		:m_outline(false)
		,m_stroke_width(0)
		,m_fillcolor(0)
		,m_strokecolor(0)
		,m_linearGradient(0)
	{
	}

	bool outline() const					{ return m_outline; }
	bool overrideFillColor() const	{ return m_fillcolor != 0; }

	double get_stroke_width(double width) const
	{
		if (!m_stroke_width)
			return width;

		// NOTE:
		// this hack makes it possible to fix one of the odds in the antigrain library;
		// especially used in
		//		tcl/pieces/eyes.tcl:		white king mask
		//		tcl/pieces/fantasy.tcl:	white pawn mask
		//		tcl/pieces/spatial.tcl:	white pawn mask
		if (width < 0.0)
			return (*m_stroke_width)*(-width);

		return *m_stroke_width;
	}

	agg::rgba8 get_stroke_color(agg::rgba8 const& color) const
	{
		return m_strokecolor ? *m_strokecolor : color;
	}

	agg::rgba8 get_fill_color(agg::rgba8 const& color) const
	{
		return m_fillcolor ? *m_fillcolor : color;
	}

	svg::gradient const* get_linear_gradient() const	{ return m_linearGradient; }

	void set_outline(bool flag)								{ m_outline = flag; }
	void set_stroke_width(double const* width)			{ m_stroke_width = width; }
	void set_fill_color(agg::rgba8 const* color)			{ m_fillcolor = color; }
	void set_stroke_color(agg::rgba8 const* color)		{ m_strokecolor = color; }
	void set_gradient(svg::gradient const* gradient)	{ m_linearGradient = gradient; }

	bool						m_outline;
	double const*			m_stroke_width;
	agg::rgba8 const*		m_fillcolor;
	agg::rgba8 const*		m_strokecolor;
	svg::gradient const*	m_linearGradient;
};


struct Diffuse
{
	double m_max;
	explicit Diffuse(double max) :m_max(max) {}
	template <typename PixBuf> void operator()(PixBuf& pixbuf) { pixbuf.diffuse_alpha(m_max); }
};


struct Boost
{
	double m_min, m_max;
	explicit Boost(double min, double max) :m_min(min), m_max(max) {}
	template <typename PixBuf> void operator()(PixBuf& pixbuf) { pixbuf.boost_alpha(m_min, m_max); }
};


struct SetAlpha
{
	double m_alpha;
	bool m_overlay;
	explicit SetAlpha(int alpha, bool overlay = true) : m_alpha(alpha/255.0), m_overlay(overlay) {}
	explicit SetAlpha(double alpha, bool overlay = true) : m_alpha(alpha), m_overlay(overlay) {}
	template <typename PixBuf> void operator()(PixBuf& pixbuf) { pixbuf.set_alpha(m_alpha, m_overlay); }
};


struct Recolor
{
	Recolor(agg::rgba8 const& fillcolor, bool overlay) :m_fillcolor(fillcolor), m_overlay(overlay) {}
	agg::rgba8 m_fillcolor;
	bool m_overlay;

	template <typename PixBuf>
	void operator()(PixBuf& pixbuf) { pixbuf.recolor(m_fillcolor, m_overlay); }
};


struct Colorize
{
	Colorize(agg::rgba8 const& fillcolor, double brighten) :m_color(fillcolor), m_brighten(brighten) {}
	agg::rgba8 m_color;
	double m_brighten;

	template <typename PixBuf>
	void operator()(PixBuf& pixbuf) { pixbuf.colorize(m_color, m_brighten); }
};


struct Blur
{
	Blur(double radius) :m_radius(radius) {}
	double m_radius;

	template <typename PixBuf>
	void operator()(PixBuf const& src_buf, PixBuf& dst_buf) { blur_image(src_buf, dst_buf, m_radius); }
};


struct ScaleImage
{
	ScaleImage(double sx, double sy) :m_sx(sx), m_sy(sy) {}
	double m_sx, m_sy;

	template <typename PixBuf>
	void operator()(PixBuf const& src_buf, PixBuf& dst_buf) { scale_image(src_buf, dst_buf, m_sx, m_sy); }
};


struct Rotate
{
	Rotate(int rot) :m_rot(rot) {}
	int m_rot;

	template <typename PixBuf>
	void operator()(PixBuf const& src_buf, PixBuf& dst_buf)
	{
		M_ASSERT(src_buf.pixelSize() == 3 || src_buf.pixelSize() == 4);

		switch (m_rot)
		{
			case 1: rot_90_image(src_buf, dst_buf); break;
			case 2: rot180_image(src_buf, dst_buf); break;
			case 3: rot270_image(src_buf, dst_buf); break;
		}
	}
};


bool
parse_color(char const* name, agg::rgba8& color)
{
	try
	{
		if (*name == '#' && strlen(name + 1) == 8)
		{
			unsigned r = 0, g = 0, b = 0, a = 0;
			::sscanf(name + 1, "%02x%02x%02x%02x", &r, &g, &b, &a);
			color = agg::rgba8(r, g, b, a);
		}
		else
		{
			color = svg::parser::parse_color(name);
		}
	}
	catch (svg::exception const&)
	{
		return false;
	}

	return true;
}


template <class ImageFunc>
void
processImage(Tk_PhotoImageBlock& block, ImageFunc func)
{
	if (block.pixelSize == 3)
	{
#ifdef NEED_BGR
		if (block.offset[0] != 0)
		{
			typedef pixbuf<BGR> pixbuf;
			pixbuf pixb(block);
			func(pixb);
		}
		else
#endif
		{
			typedef pixbuf<RGB> pixbuf;
			pixbuf pixb(block);
			func(pixb);
		}
	}
	else
	{
#ifdef NEED_BGR
		if (block.offset[0] != 0)
		{
			typedef pixbuf<BGRA> pixbuf;
			pixbuf pixb(block);
			func(pixb);
		}
		else
#endif
		{
			typedef pixbuf<RGBA> pixbuf;
			pixbuf pixb(block);
			func(pixb);
		}
	}
}


template <class ImageFunc>
void
processImage(Tk_PhotoImageBlock const& srcBlock, Tk_PhotoImageBlock& dstBlock, ImageFunc func)
{
	if (dstBlock.pixelSize == 3)
	{
#ifdef NEED_BGR
		if (dstBlock.offset[0] != 0)
		{
			typedef pixbuf<BGR> pixbuf;
			pixbuf src_pixb(srcBlock);
			pixbuf dst_pixb(dstBlock);
			func(src_pixb, dst_pixb);
		}
		else
#endif
		{
			typedef pixbuf<RGB> pixbuf;
			pixbuf src_pixb(srcBlock);
			pixbuf dst_pixb(dstBlock);
			func(src_pixb, dst_pixb);
		}
	}
	else
	{
#ifdef NEED_BGR
		if (dstBlock.offset[0] != 0)
		{
			typedef pixbuf<BGRA> pixbuf;
			pixbuf src_pixb(srcBlock);
			pixbuf dst_pixb(dstBlock);
			func(src_pixb, dst_pixb);
		}
		else
#endif
		{
			typedef pixbuf<RGBA> pixbuf;
			pixbuf src_pixb(srcBlock);
			pixbuf dst_pixb(dstBlock);
			func(src_pixb, dst_pixb);
		}
	}
}


int align_pitch(int width) { return (width + 31) & ~31; }	// 32 bit alignment

} // namespace


static Tcl_Command tk_cmd_image = 0;


// adopted from ImageMagick-6.4.2/magick/resize.c:ScaleImage()
template <typename PixBuf>
static void
shrink_image(PixBuf const& src, PixBuf& dst)
{
	typedef typename PixBuf::pixelA pixel;

	double x_scale = double(dst.cols())/double(src.cols());
	double y_scale = double(dst.rows())/double(src.rows());

	pixel* x_vector		= new pixel[src.cols()];
	pixel* y_vector		= new pixel[src.cols()];
	pixel* dst_scanline	= new pixel[dst.cols()];
	pixel* src_scanline	= new pixel[src.cols()];

	pixel const* x_vend = x_vector + src.cols();

	int		nrows		= 0;
	bool		next_row	= true;
	double	span_y	= 1.0;
	double	sy			= y_scale;

	for (int y = 0; y < dst.rows(); ++y)
	{
		if (dst.rows() == src.rows())
		{
			src.next_scanline(x_vector);
		}
		else
		{
			while (sy < span_y)
			{
				if (next_row && nrows < src.rows())
				{
					src.next_scanline(x_vector);
					nrows++;
				}

				for (int x = 0; x < src.cols(); ++x)
					y_vector[x] += sy*x_vector[x];

				span_y -= sy;
				sy = y_scale;
				next_row = true;
			}

			if (next_row && nrows < src.rows())
			{
				src.next_scanline(x_vector);
				nrows++;
				next_row = false;
			}

			pixel* s			= src_scanline;
			pixel* y_vec	= y_vector;

			for (pixel const* x_vec = x_vector; x_vec < x_vend; ++x_vec, ++y_vec, ++s)
			{
				*s = *y_vec + span_y*(*x_vec);
				*y_vec = pixel();
			}

			if ((sy -= span_y) <= 0)
			{
				sy = y_scale;
				next_row = true;
			}

			span_y = 1.0;
		}

		if (dst.cols() == src.cols())
		{
			dst.set_scanline(src_scanline);
		}
		else
		{
			bool		next_column	= false;
			double	span_x		= 1.0;
			pixel		pix;

			pixel const*	s = src_scanline;
			pixel*			t = dst_scanline;

			for (int x = 0; x < src.cols(); ++x, ++s)
			{
				double sx = x_scale;

				while (sx >= span_x)
				{
					if (next_column)
					{
						pix = pixel();
						++t;
					}

					pix += span_x*(*s);
					*t = pix;
					sx -= span_x;
					span_x = 1.0;
					next_column = true;
				}

				if (sx > 0.0)
				{
					if (next_column)
					{
						pix = pixel();
						next_column = false;
						++t;
					}

					pix += sx*(*s);
					span_x -= sx;
				}
			}

			if (span_x > 0.0)
			{
				--s;
				pix += span_x*(*s);
			}

			if (!next_column && (t - dst_scanline) < dst.cols())
				*t = pix;

			dst.set_scanline(dst_scanline);
		}
	}

	delete [] x_vector;
	delete [] y_vector;
	delete [] dst_scanline;
	delete [] src_scanline;
}


template <typename PixBuf>
static void
zoom_image(PixBuf const& src, PixBuf& dst)
{
	typedef typename PixBuf::agg_pixfmt pixfmt;
	typedef agg::renderer_base<pixfmt> renderer_base;

	agg::rendering_buffer rbuf(dst.buf(),
										dst.cols(),
										dst.rows(),
										dst.pitch());
	agg::rendering_buffer rbuf_pre(	const_cast<unsigned char*>(src.buf()),
												src.cols(),
												src.rows(),
												src.pitch());

	pixfmt			pixf(rbuf);
  	pixfmt			pixf_pre(rbuf_pre);
	renderer_base	rb(pixf);
	renderer_base	rb_pre(pixf_pre);

	double scale_x = double(dst.cols())/double(src.cols());
	double scale_y = double(dst.rows())/double(src.rows());

	agg::trans_affine mtx = agg::trans_affine_scaling(scale_x, scale_y);
	mtx.invert();

	agg_interpolator_type interpolator(mtx);

	typedef typename PixBuf::image_accessor_clone img_source_type;
	img_source_type src_img(pixf_pre);

	typedef typename PixBuf::agg_span_gen_type span_gen_type;
	agg::image_filter<agg::image_filter_hermite> filter;
	span_gen_type sg(src_img, interpolator, static_cast<agg::image_filter_lut const&>(filter));

	agg::scanline_u8 sl;
	agg::span_allocator<agg::rgba8> sa;
	::rasterizer ras(0, 0, dst.cols(), dst.rows());
	agg::render_scanlines_aa(ras, sl, rb, sa, sg);
}


template <typename PixBuf>
static void
blur_image(PixBuf const& src, PixBuf& dst, double radius)
{
	typedef typename PixBuf::agg_pixfmt pixfmt;
	typedef agg::renderer_base<pixfmt> renderer_base;

	agg::rendering_buffer rbuf(dst.buf(), dst.cols(), dst.rows(), dst.pitch());
	agg::rendering_buffer rbuf_pre(	const_cast<unsigned char*>(src.buf()),
												src.cols(),
												src.rows(),
												src.pitch());

	pixfmt pixf(rbuf);
	pixfmt pixf_pre(rbuf_pre);
	int x1 = 0;
	int x2 = dst.cols();
	int y1 = 0;
	int y2 = dst.rows();

#if 1	// stack blur

	typedef agg::stack_blur<agg::rgba8, agg::stack_blur_calc_rgb<> > stack_blur;

	if (pixf_pre.attach(pixf, x1, y1, x2, y2))
		stack_blur().blur(pixf_pre, agg::uround(radius/2.0));

#else // recursive blur

	typedef agg::recursive_blur<agg::rgba8, agg::recursive_blur_calc_rgb<> > recursive_blur;

	if (pixf_pre.attach(pixf, x1, y1, x2, y2))
		recursive_blur().blur(pixf_pre, radius/2.0);

#endif
}


template <typename PixBuf>
static void
rot_90_image(PixBuf const& src, PixBuf& dst)
{
	M_ASSERT(src.cols() == dst.rows());
	M_ASSERT(src.rows() == dst.cols());

	if (src.pixelSize() == 4)
	{
		for (int y = 0; y < src.rows(); ++y)
		{
			uint32_t const*	p = reinterpret_cast<uint32_t const*>(src.scanline(y));
			uint32_t const*	e = p + src.cols();
			unsigned char*		q = dst.buf() + mul4(src.rows() - y - 1);

			for ( ; p < e; ++p, q += dst.pitch())
				*reinterpret_cast<uint32_t*>(q) = *p;
		}
	}
	else
	{
		for (int y = 0; y < src.rows(); ++y)
		{
			unsigned char const*	p = src.scanline(y);
			unsigned char const*	e = p + 3*src.cols();
			unsigned char*			q = dst.buf() + 3*(src.rows() - y - 1);

			for ( ; p < e; p += 3, q += dst.pitch())
				memcpy(q, p, 3);
		}
	}
}


template <typename PixBuf>
static void
rot180_image(PixBuf const& src, PixBuf& dst)
{
	M_ASSERT(src.cols() == dst.cols());
	M_ASSERT(src.rows() == dst.rows());

	if (src.pixelSize() == 4)
	{
		for (int y = 0; y < src.rows(); ++y)
		{
			uint32_t const*	p = reinterpret_cast<uint32_t const*>(src.scanline(y));
			uint32_t const*	e = p + src.cols();
			uint32_t*			q = reinterpret_cast<uint32_t*>(dst.scanline(dst.rows() - y - 1));

			for (q += dst.cols() - 1; p < e; ++p, --q)
				*q = *p;
		}
	}
	else
	{
		for (int y = 0; y < src.rows(); ++y)
		{
			unsigned char const*	p = src.scanline(y);
			unsigned char const*	e = p + 3*src.cols();
			unsigned char*			q = dst.scanline(dst.rows() - y - 1);

			for (q += 3*(dst.cols() - 1); p < e; p += 3, q -= 3);
				memcpy(q, p, 3);
		}
	}
}


template <typename PixBuf>
static void
rot270_image(PixBuf const& src, PixBuf& dst)
{
	M_ASSERT(src.cols() == dst.rows());
	M_ASSERT(src.rows() == dst.cols());

	unsigned char* last = dst.scanline(dst.rows() - 1);

	if (src.pixelSize() == 4)
	{
		for (int y = 0; y < src.rows(); ++y)
		{
			uint32_t const*	p = reinterpret_cast<uint32_t const*>(src.scanline(y));
			uint32_t const*	e = p + src.cols();
			unsigned char*		q = last + mul4(y);

			for ( ; p < e; ++p, q -= dst.pitch())
				*reinterpret_cast<uint32_t*>(q) = *p;
		}
	}
	else
	{
		for (int y = 0; y < src.rows(); ++y)
		{
			unsigned char const*	p = src.scanline(y);
			unsigned char const*	e = p + 3*src.cols();
			unsigned char*			q = last + 3*y;

			for ( ; p < e; p += 3, q -= dst.pitch())
				memcpy(q, p, 3);
		}
	}
}


static void
make_border(pixbuf<RGBA>& buf, int gap, int width, double opacity, bool lite)
{
	M_ASSERT(width >= 0);
	M_ASSERT(gap >= 0);
	M_ASSERT(buf.pixelSize() == 4);
	M_ASSERT(width == 0 || width + gap < buf.rows());
	M_ASSERT(width == 0 || width + gap < buf.cols());

	buf.clear();

	for (int i = 0; i < gap; ++i)
	{
		uint32_t* p = reinterpret_cast<uint32_t*>(buf.scanline(i));
		uint32_t* e = p + buf.cols();

		for ( ; p < e; ++p)
			buf.set_alpha(reinterpret_cast<unsigned char*>(p), 255);

		for (int r = gap; r < buf.rows(); ++r)
		{
			uint32_t* p = reinterpret_cast<uint32_t*>(buf.scanline(r)) + i;
			uint32_t* e = reinterpret_cast<uint32_t*>(buf.scanline(buf.rows() - 1)) + i;

			for ( ; p <= e; p += buf.pitch())
				buf.set_alpha(reinterpret_cast<unsigned char*>(p), 255);
		}
	}

	if (width == 0 || opacity == 0.0)
		return;

	double step = opacity/width;

	for (int i = 0; i < width; ++i, opacity -= step)
	{
		int k				= i + gap;
		int last_row	= buf.rows() - i - 1;
		int last_col	= buf.cols() - i - 1;
		int alpha		= agg::iround(opacity*255.0);

		{
			uint32_t* p = reinterpret_cast<uint32_t*>(buf.scanline(k)) + k;
			uint32_t* e = reinterpret_cast<uint32_t*>(buf.scanline(k)) + last_col - gap + (gap ? 1 : 0);

			if (lite)
			{
				for ( ; p < e; ++p)
					buf.set_pixel(reinterpret_cast<unsigned char*>(p), 255, 255, 255, alpha);
			}
			else
			{
				for ( ; p < e; ++p)
					buf.set_alpha(reinterpret_cast<unsigned char*>(p), alpha);
			}
		}

		{
			uint32_t* p = reinterpret_cast<uint32_t*>(buf.scanline(last_row)) + k;
			uint32_t* e = reinterpret_cast<uint32_t*>(buf.scanline(last_row)) + last_col - gap + 1;

			if (gap)
				++e;

			for ( ; p < e; ++p)
				buf.set_alpha(reinterpret_cast<unsigned char*>(p), alpha);
		}

		{
			unsigned char* p = buf.scanline(k + 1) + k*buf.pixelSize();
			unsigned char* e = buf.scanline(last_row - 1) + k*buf.pixelSize();

			if (lite)
			{
				for ( ; p <= e; p += buf.pitch())
					buf.set_pixel(p, 255, 255, 255, alpha);
			}
			else
			{
				for ( ; p <= e; p += buf.pitch())
					buf.set_alpha(p, alpha);
			}
		}

		{
			unsigned char* p = buf.scanline(gap ? k : i) + last_col*buf.pixelSize();
			unsigned char* e = buf.scanline(last_row - 1) + last_col*buf.pixelSize();

			for ( ; p <= e; p += buf.pitch())
				buf.set_alpha(p, alpha);
		}
	}
}


static void
sharpen_image(pixbuf<RGBA>& buf, agg::rgba8 const& stroke, agg::rgba8 const& fill)
{
	for (int r = 0; r < buf.rows(); ++r)
	{
		agg::rgba8* p = reinterpret_cast<agg::rgba8*>(buf.scanline(r));
		agg::rgba8* e = p + buf.cols();

		for ( ; p < e; ++p)
		{
			if (p->r != fill.r || p->g != fill.g || p->b != fill.b)
			{
				p->r = stroke.r;
				p->g = stroke.g;
				p->b = stroke.b;
			}
		}
	}
}


template <typename PixBuf>
static void
scale_image(PixBuf const& src, PixBuf& dst, double scale_x, double scale_y)
{
	if (scale_x*scale_y < 1.0)
		shrink_image(src, dst);
	else
		zoom_image(src, dst);
}


static int
__attribute__((__format__(__printf__, 2, 3)))
tcl_error(char const* subcmd, char const* format, ...)
{
	va_list args;
	va_start(args, format);
	int rc = tcl::error(Tcl_GetCommandName(interp(), tk_cmd_image), subcmd, 0, format, args);
	va_end(args);
	return rc;
}


static int
tcl_usage(char const* subcmd, char const** options, char const** args)
{
	return ::tcl::usage(Tcl_GetCommandName(interp(), tk_cmd_image), subcmd, 0, options, args);
}


inline
static bool
match(int const lhs[4], int const rhs[4])
{
	return memcmp(lhs, rhs, sizeof(lhs)) == 0;
}


static int
check_image_format(char const* subcmd, Tcl_Interp* ti, Tk_PhotoImageBlock const& block)
{
	static int const offsRGB [4] = { RGB  };
	static int const offsRGBA[4] = { RGBA };

	if (match(offsRGB, block.offset) && match(offsRGBA, block.offset))
		return TCL_OK;

#ifdef NEED_BGR
	static int const offsBGR [4] = { BGR  };
	static int const offsBGRA[4] = { BGRA };

	if (match(offsBGR,  block.offset) && match(offsBGRA, block.offset))
		return TCL_OK;
#endif

	return tcl_error(	subcmd,
							"unsupported image format (pixelSize=%d, offset=[%d,%d,%d,%d])",
							block.pixelSize,
							block.offset[0],
							block.offset[1],
							block.offset[2],
							block.offset[3]);
}


static int
tk_make_border(char const* subcmd,
					Tcl_Interp* ti,
					char const* dstName,
					int objc, Tcl_Obj* const objv[])
{
	enum { Opt_Gap, Opt_Width, Opt_Opacity, Opt_Type };
	static char const* options[] = { "-gap", "-width", "-opacity", "-type", 0 };
	static char const* args[] = { "<integer>", "<integer>", "<double>", "lite|dark" };

	double		opacity			= 1.0;
	int			borderWidth		= 2;
	int			gap				= 0;
	char const*	type				= "lite";

	for (int i = 0; i < objc; i++)
	{
		switch (::tcl::uniqueMatchObj(objv[i], options))
		{
			case Opt_Gap:
				if (++i == objc || Tcl_GetIntFromObj(ti, objv[i], &gap) != TCL_OK)
					return tcl_usage(subcmd, options, args);
				if (gap < 0)
					return tcl_error(subcmd, "invalid argument: negative gap");
				break;

			case Opt_Width:
				if (++i == objc || Tcl_GetIntFromObj(ti, objv[i], &borderWidth) != TCL_OK)
					return tcl_usage(subcmd, options, args);
				if (borderWidth < 0)
					return tcl_error(subcmd, "invalid argument: negative width");
				break;

			case Opt_Opacity:
				if (++i == objc || Tcl_GetDoubleFromObj(ti, objv[i], &opacity) != TCL_OK)
					return tcl_usage(subcmd, options, args);
				if (opacity < 0.0)
					return tcl_error(subcmd, "invalid argument: negative opacity");
				if (opacity > 1.0)
					return tcl_error(subcmd, "invalid argument: opacity larger than 1.0");
				break;

			case Opt_Type:
				if (++i == objc)
					return tcl_usage(subcmd, options, args);
				type = Tcl_GetStringFromObj(objv[i], 0);
				if (strcmp(type, "lite") && strcmp(type, "dark"))
					return tcl_error(subcmd, "invalid argument: type should be either 'lite' or 'dark'");
				break;

			default:
				return tcl_usage(subcmd, options, args);
		}
	}

	Tk_PhotoHandle handle = Tk_FindPhoto(ti, dstName);

	if (!handle)
		return tcl_error(subcmd, "invalid argument: '%s' is not a photo image", dstName);

	int width, height;
	Tk_PhotoGetSize(handle, &width, &height);

	if (gap > width)							gap = width;
	if (gap > height)							gap = height;
	if (borderWidth > (width - gap)/2)	borderWidth = (width - gap)/2;
	if (borderWidth > (height - gap)/2)	borderWidth = (height - gap)/2;

	static int const Offets[4] = { RGBA };

	Tk_PhotoImageBlock block;
	block.pixelSize = 4;
	block.pitch = align_pitch(width*4);
	block.pixelPtr = new unsigned char[block.pitch*height];
	block.width = width;
	block.height = height;
	block.offset[0] = Offets[0];
	block.offset[1] = Offets[1];
	block.offset[2] = Offets[2];
	block.offset[3] = Offets[3];

	pixbuf<RGBA> pixbuf(block);
	make_border(pixbuf, gap, borderWidth, opacity, strcmp(type, "lite") == 0);
	Tk_PhotoPutBlock(ti, handle, &block, 0, 0, width, height, TK_PHOTO_COMPOSITE_SET);
	delete [] block.pixelPtr;

	return TCL_OK;
}


static int
tk_disable_image(	char const* subcmd,
						Tcl_Interp* ti,
						char const* srcName,
						char const* dstName,
						int objc, Tcl_Obj* const[])
{
	if (objc > 0)
	{
		Tcl_WrongNumArgs(ti, 0, 0, "subcommand");
		return TCL_ERROR;
	}

	Tk_PhotoHandle srcHandle = Tk_FindPhoto(ti, srcName);
	Tk_PhotoHandle dstHandle = Tk_FindPhoto(ti, dstName);

	if (!srcHandle)
		return tcl_error(subcmd, "invalid argument: '%s' is not a photo image", srcName);
	if (!dstHandle)
		return tcl_error(subcmd, "invalid argument: '%s' is not a photo image", dstName);

	Tk_PhotoImageBlock srcBlock;
	Tk_PhotoImageBlock dstBlock;

	Tk_PhotoGetImage(srcHandle, &srcBlock);
	Tk_PhotoSetSize(ti, dstHandle, 0, 0);

	memcpy(&dstBlock, &srcBlock, sizeof(srcBlock));
	dstBlock.pixelPtr = new unsigned char[dstBlock.pitch*dstBlock.height];
	memcpy(dstBlock.pixelPtr, srcBlock.pixelPtr, srcBlock.pitch*srcBlock.height);
	processImage(dstBlock, SetAlpha(100));
	Tk_PhotoPutBlock(	ti,
							dstHandle,
							&dstBlock,
							0, 0,
							srcBlock.width, srcBlock.height,
							TK_PHOTO_COMPOSITE_SET);
	delete [] dstBlock.pixelPtr;

	return TCL_OK;
}


static int
tk_set_alpha(	char const* subcmd,
					Tcl_Interp* ti,
					double value,
					char const* photo,
					int objc, Tcl_Obj* const objv[])
{
	static char const* options[] = { "-composite", "-area", 0 };
	static char const* args[] = { "set|overlay", "x0 y0 x1 y1" };

	if (0.0 > value || value > 1.0)
		return tcl_error(subcmd, "invalid argument: alpha value is out of range");

	char const* composite = "set";

	int arg	= 0;
	int x0	= 0;
	int y0	= 0;
	int x1	= -1;
	int y1	= -1;

	while (arg < objc)
	{
		if (arg == objc)
			return tcl_usage(subcmd, options, args);

		char const* option = Tcl_GetStringFromObj(objv[arg++], 0);

		if (strcmp(option, "-composite") == 0)
		{
			composite = Tcl_GetStringFromObj(objv[arg++], 0);

			if (strcmp(composite, "set") != 0 && strcmp(composite, "overlay") != 0)
				return tcl_usage(subcmd, options, args);
		}
		else if (strcmp(option, "-area") == 0)
		{
			if (	objc < arg + 4
				|| Tcl_GetIntFromObj(ti, objv[arg++], &x0) != TCL_OK
				|| Tcl_GetIntFromObj(ti, objv[arg++], &y0) != TCL_OK
				|| Tcl_GetIntFromObj(ti, objv[arg++], &x1) != TCL_OK
				|| Tcl_GetIntFromObj(ti, objv[arg++], &y1) != TCL_OK)
			{
				return tcl_usage(subcmd, options, args);
			}

			if (x0 < 0 || y0 < 0 || x1 < 0 || y1 < 0)
				return tcl_error(subcmd, "invalid (negative) coordinates for -area option");

			if (x1 <= x0 || y1 <= y0)
				return TCL_OK;
		}
		else
		{
			return tcl_usage(subcmd, options, args);
		}
	}

	Tk_PhotoHandle handle = Tk_FindPhoto(ti, photo);

	if (!handle)
		return tcl_error(subcmd, "invalid argument: '%s' is not a photo image", photo);

	Tk_PhotoImageBlock block;
	Tk_PhotoGetImage(handle, &block);
	Tk_PhotoImageBlock dstBlock = block;

	if (x1 >= 0)
	{
		if (x0 > dstBlock.width || y0 > dstBlock.height)
			return tcl_error(subcmd, "coordinates for -area option extend outside source image");

		if (x1 > dstBlock.width)  x1 = dstBlock.width;
		if (y1 > dstBlock.height) y1 = dstBlock.height;

		dstBlock.pixelPtr += y0*dstBlock.pitch + x0*dstBlock.pixelSize;
		dstBlock.width = x1 - x0;
		dstBlock.height = y1 - y0;
	}

	int rc = check_image_format(subcmd, ti, dstBlock);
	if (rc != TCL_OK)
		return rc;

	processImage(dstBlock, SetAlpha(value, strcmp(composite, "set") != 0));
	return Tk_PhotoPutBlock(ti, handle, &block, 0, 0, block.width, block.height, TK_PHOTO_COMPOSITE_SET);
}


static int
tk_blur(	char const* subcmd,
			Tcl_Interp* ti,
			char const* srcName,
			char const* dstName,
			double radius,
			int objc, Tcl_Obj* const objv[])
{
	Tk_PhotoHandle srcHandle = Tk_FindPhoto(ti, srcName);

	if (!srcHandle)
		return tcl_error(subcmd, "invalid argument: '%s' is not a photo image", srcName);

	Tk_PhotoHandle dstHandle = Tk_FindPhoto(ti, dstName);

	if (!dstHandle)
		return tcl_error(subcmd, "invalid argument: '%s' is not a photo image", dstName);

	Tk_PhotoImageBlock srcBlock;
	Tk_PhotoImageBlock dstBlock;

	Tk_PhotoGetImage(srcHandle, &srcBlock);
	Tk_PhotoGetImage(dstHandle, &dstBlock);

	int rc = check_image_format(subcmd, ti, srcBlock);
	if (rc == TCL_OK)
		rc = check_image_format(subcmd, ti, dstBlock);
	if (rc != TCL_OK)
		return rc;

	if (srcBlock.width != dstBlock.width || srcBlock.height != dstBlock.height)
		return tcl_error("'%s' and '%s' should have same dimensions", srcName, dstName);

	processImage(srcBlock, dstBlock, Blur(radius));

	return TCL_OK;
}


static int
tk_diffuse(	char const* subcmd,
				Tcl_Interp* ti,
				double value,
				char const* photo,
				int objc, Tcl_Obj* const objv[])
{
	if (0.0 > value || value > 1.0)
		return tcl_error(subcmd, "invalid argument: alpha value is out of range");

	Tk_PhotoHandle handle = Tk_FindPhoto(ti, photo);

	if (!handle)
		return tcl_error(subcmd, "invalid argument: '%s' is not a photo image", photo);

	Tk_PhotoImageBlock block;
	Tk_PhotoGetImage(handle, &block);
	Tk_PhotoImageBlock dstBlock = block;

	if (block.offset[3] == 0)
		return TCL_OK;

	int rc = check_image_format(subcmd, ti, dstBlock);
	if (rc != TCL_OK)
		return rc;

	processImage(dstBlock, Diffuse(value));
	return Tk_PhotoPutBlock(ti, handle, &block, 0, 0, block.width, block.height, TK_PHOTO_COMPOSITE_SET);
}


static int
tk_boost(	char const* subcmd,
				Tcl_Interp* ti,
				double min, double max,
				char const* photo,
				int objc, Tcl_Obj* const objv[])
{
	if (0.0 > min || min > 1.0 || 0.0 > max || max > 1.0)
		return tcl_error(subcmd, "invalid argument: alpha value is out of range");

	Tk_PhotoHandle handle = Tk_FindPhoto(ti, photo);

	if (!handle)
		return tcl_error(subcmd, "invalid argument: '%s' is not a photo image", photo);

	Tk_PhotoImageBlock block;
	Tk_PhotoGetImage(handle, &block);
	Tk_PhotoImageBlock dstBlock = block;

	if (block.offset[3] == 0)
		return TCL_OK;

	int rc = check_image_format(subcmd, ti, dstBlock);
	if (rc != TCL_OK)
		return rc;

	processImage(dstBlock, Boost(min, max));
	return Tk_PhotoPutBlock(ti, handle, &block, 0, 0, block.width, block.height, TK_PHOTO_COMPOSITE_SET);
}


static int
tk_copy_image(	char const* subcmd,
					Tcl_Interp* ti,
					char const* srcName,
					char const* dstName,
					int objc, Tcl_Obj* const objv[])
{
	Tk_PhotoHandle srcHandle = Tk_FindPhoto(ti, srcName);
	Tk_PhotoHandle dstHandle = Tk_FindPhoto(ti, dstName);

	if (!srcHandle)
		return tcl_error(subcmd, "invalid argument: '%s' is not a photo image", srcName);
	if (!dstHandle)
		return tcl_error(subcmd, "invalid argument: '%s' is not a photo image", dstName);

	int width;
	int height;

	Tk_PhotoImageBlock srcBlock;

	Tk_PhotoGetSize(dstHandle, &width, &height);
	Tk_PhotoGetImage(srcHandle, &srcBlock);

	enum { Opt_From, Opt_Scale, Opt_Rotate, Opt_AlphaMask };
	static char const* options[] = { "-from", "-scale", "-rotate", "-alphamask", 0 };
	static char const* args[] = { "<x1> <y1> <x2> <y2>", "<double>", "0-3", "", 0 };

	double scale = 1.0;
	int rotate = 0;
	int x1 = 0;
	int y1 = 0;
	int x2 = -1;
	int y2 = -1;
	bool blend = false;

	for (int i = 0; i < objc; i++)
	{
		char const* option = Tcl_GetStringFromObj(objv[i], 0);

		switch (::tcl::uniqueMatch(option, options))
		{
			case Opt_From:
				if (	i + 4 >= objc
					|| Tcl_GetIntFromObj(ti, objv[++i], &x1) != TCL_OK
					|| Tcl_GetIntFromObj(ti, objv[++i], &y1) != TCL_OK
					|| Tcl_GetIntFromObj(ti, objv[++i], &x2) != TCL_OK
					|| Tcl_GetIntFromObj(ti, objv[++i], &y2) != TCL_OK)
				{
					return tcl_usage(subcmd, options, args);
				}
				if (x1 < 0 || x2 < 0 || y1 < 0 || y2 < 0)
					return tcl_error(subcmd, "value(s) for the %s option must be non-negative", option);
				if (	x1 > srcBlock.width
					|| y1 > srcBlock.height
					|| x2 > srcBlock.width
					|| y2 > srcBlock.height)
				{
					return tcl_error(subcmd, "coordinates for %s option extend outside source image", option);
				}
				break;

			case Opt_Scale:
				if (++i == objc || Tcl_GetDoubleFromObj(ti, objv[i], &scale) != TCL_OK)
					return tcl_usage(subcmd, options, args);
				scale = fabs(scale);
				break;

			case Opt_Rotate:
				if (++i == objc || Tcl_GetIntFromObj(ti, objv[i], &rotate) != TCL_OK)
					return tcl_usage(subcmd, options, args);
				if (rotate < 0 || rotate > 3)
					return tcl_usage(subcmd, options, args);
				break;

			case Opt_AlphaMask:
				blend = true;
				break;

			default:
				return tcl_usage(subcmd, options, args);
		}
	}

	if (x2 >= 0)
	{
		srcBlock.pixelPtr += y1*srcBlock.pitch + x1*srcBlock.pixelSize;
		srcBlock.width = x2 - x1;
		srcBlock.height = y2 - y1;
	}

	if (width <= 0 || height <= 0 || srcBlock.width <= 0 || srcBlock.height <= 0)
		return TCL_OK;

	if (srcBlock.width == width && srcBlock.height == height && rotate == 0 && !blend)
		return Tk_PhotoPutBlock(ti, dstHandle, &srcBlock, 0, 0, width, height, TK_PHOTO_COMPOSITE_SET);

	int rc = check_image_format(subcmd, ti, srcBlock);
	if (rc != TCL_OK)
		return rc;

	Tk_PhotoImageBlock dstBlock;

	int wd = (rotate & 1 ? height : width);
	int ht = (rotate & 1 ? width : height);

	if (srcBlock.width != wd || srcBlock.height != ht)
	{
		dstBlock.width = wd;
		dstBlock.height = ht;
		dstBlock.pixelSize = srcBlock.pixelSize;
		dstBlock.pitch = align_pitch(dstBlock.width*dstBlock.pixelSize);
		dstBlock.pixelPtr = new unsigned char[dstBlock.pitch*dstBlock.height];
		memcpy(&dstBlock.offset, &srcBlock.offset, sizeof(dstBlock.offset));

		double scale_x = scale*(double(dstBlock.width)/double(srcBlock.width));
		double scale_y = scale*(double(dstBlock.height)/double(srcBlock.height));
		processImage(srcBlock, dstBlock, ScaleImage(scale_x, scale_y));
	}

	if (rotate)
	{
		if (srcBlock.width != wd || srcBlock.height != ht)
			srcBlock = dstBlock;

		dstBlock.width = width;
		dstBlock.height = height;
		dstBlock.pixelSize = srcBlock.pixelSize;
		if (srcBlock.width == dstBlock.width && srcBlock.height == dstBlock.height)
			dstBlock.pitch = srcBlock.pitch;
		else
			dstBlock.pitch = align_pitch(dstBlock.width*dstBlock.pixelSize);
		dstBlock.pixelPtr = new unsigned char[dstBlock.pitch*dstBlock.height];
		memcpy(&dstBlock.offset, &srcBlock.offset, sizeof(dstBlock.offset));

		processImage(srcBlock, dstBlock, Rotate(rotate));

		if (srcBlock.width != wd || srcBlock.height != ht)
			delete [] srcBlock.pixelPtr;
	}

	if (!blend)
	{
		M_ASSERT(rotate || srcBlock.width != wd || srcBlock.height != ht);
		rc = Tk_PhotoPutBlock(ti, dstHandle, &dstBlock, 0, 0, width, height, TK_PHOTO_COMPOSITE_SET);
		delete [] dstBlock.pixelPtr;
		return rc;
	}

	typedef pixbuf<RGBA> pixbuf;

	if (rotate || srcBlock.width != wd || srcBlock.height != ht)
		srcBlock = dstBlock;

	Tk_PhotoGetImage(dstHandle, &dstBlock);

	if (srcBlock.pixelSize != 4 || dstBlock.pixelSize != 4)
		return tcl_error(subcmd, "both images should have an alpha channel");

	pixbuf dst_pixb(dstBlock);
	dst_pixb.blend(pixbuf(srcBlock));

	rc = Tk_PhotoPutBlock(ti, dstHandle, &dstBlock, 0, 0, width, height, TK_PHOTO_COMPOSITE_SET);

	if (rotate || srcBlock.width != wd || srcBlock.height != ht)
		delete [] srcBlock.pixelPtr;

	return rc;
}


static int
tk_create_image(	char const* subcmd,
						Tcl_Interp* ti,
						char const* svg_data, int data_len,
						char const* photo,
						int objc, Tcl_Obj* const objv[])
{
	enum
	{
		Opt_Flip, Opt_Outline, Opt_Sharpen, Opt_Fill, Opt_Stroke,
		Opt_Stroke_Width, Opt_Scale, Opt_Translate, Opt_BBox,
		Opt_Gradient, Opt_Rotate,
	};
	static char const* options[] =
	{
		"-flip", "-outline", "-sharpen", "-fill", "-stroke",
		"-stroke-width", "-scale", "-translate", "-bbox",
		"-gradient", "-rotate",
		0
	};
	static char const* args[] =
	{
		"<bool>", "<bool>", "<bool>", "<color>", "<color>",
		"<double>", "<double>", "<x> <y>", "<min-x> <min-y> <max-x> <max-y>",
		"<empty> | { <start-color> <stop-color> <start-offset> <stop-offset> <x1> <y1> <x2> <y2> [<tx> <ty>]}",
		"<double>",
	};

	renderer			path;
	double			scale(1.0);
	double			stroke_width(1.0);
	double			move_x(0.0);
	double			move_y(0.0);
	double			rotation(0.0);
	agg::rgba8		fillcolor(255, 255, 255);
	agg::rgba8		strokecolor(0, 0, 0);
	int				sharpen(0);
	int				flip(1);
	svg::gradient	gradient;
	bool				useGradient(false);

	for (int i = 0; i < objc; i++)
	{
		switch (::tcl::uniqueMatchObj(objv[i], options))
		{
			case Opt_Flip:
				{
					int flag;
					if (++i == objc || Tcl_GetBooleanFromObj(ti, objv[i], &flag) != TCL_OK)
						return tcl_usage(subcmd, options, args);
					flip = flag ? -1 : 1;
				}
				break;

			case Opt_Outline:
				{
					int flag;
					if (++i == objc || Tcl_GetBooleanFromObj(ti, objv[i], &flag) != TCL_OK)
						return tcl_usage(subcmd, options, args);
					path.set_outline(flag);
				}
				break;

			case Opt_Sharpen:
				if (++i == objc || Tcl_GetBooleanFromObj(ti, objv[i], &sharpen) != TCL_OK)
					return tcl_usage(subcmd, options, args);
				break;

			case Opt_Fill:
				if (++i == objc)
					return tcl_usage(subcmd, options, args);
				{
					char const* color = Tcl_GetStringFromObj(objv[i], 0);

					if (*color)
					{
						if (!parse_color(color, fillcolor))
							return tcl_error(subcmd, "invalid color name '%s'", color);

						path.set_fill_color(&fillcolor);
					}
				}
				break;

			case Opt_Stroke:
				if (++i == objc)
					return tcl_usage(subcmd, options, args);
				{
					char const* color = Tcl_GetStringFromObj(objv[i], 0);

					if (*color)
					{
						if (!parse_color(color, strokecolor))
							return tcl_error(subcmd, "invalid color name '%s'", color);

						path.set_stroke_color(&strokecolor);
					}
				}
				break;

			case Opt_Stroke_Width:
				if (++i == objc || Tcl_GetDoubleFromObj(ti, objv[i], &stroke_width) != TCL_OK)
					return tcl_usage(subcmd, options, args);
				if (stroke_width >= 0.0)
					path.set_stroke_width(&stroke_width);
				break;

			case Opt_Scale:
				if (++i == objc || Tcl_GetDoubleFromObj(ti, objv[i], &scale) != TCL_OK)
					return tcl_usage(subcmd, options, args);
				break;

			case Opt_Rotate:
				if (++i == objc || Tcl_GetDoubleFromObj(ti, objv[i], &rotation) != TCL_OK)
					return tcl_usage(subcmd, options, args);
				break;

			case Opt_Translate:
				{
					double tx, ty;

					if (	i + 2 >= objc
						|| Tcl_GetDoubleFromObj(ti, objv[++i], &tx) != TCL_OK
						|| Tcl_GetDoubleFromObj(ti, objv[++i], &ty) != TCL_OK)
					{
						return tcl_usage(subcmd, options, args);
					}

					move_x += tx;
					move_y += ty;
				}
				break;

			case Opt_BBox:
				{
					double min_x, min_y, max_x, max_y;

					if (i + 4 >= objc)
						return tcl_usage(subcmd, options, args);

					if (	Tcl_GetDoubleFromObj(ti, objv[++i], &min_x) != TCL_OK
						||	Tcl_GetDoubleFromObj(ti, objv[++i], &min_y) != TCL_OK
						||	Tcl_GetDoubleFromObj(ti, objv[++i], &max_x) != TCL_OK
						||	Tcl_GetDoubleFromObj(ti, objv[++i], &max_y) != TCL_OK)
					{
						return tcl_usage(subcmd, options, args);
					}

					path.setBoundingBox(min_x, min_y, max_x, max_y);
				}
				break;

			case Opt_Gradient:
				{
					if (i + 1 >= objc)
						return tcl_usage(subcmd, options, args);

					Tcl_Obj** objs;
					int len;

					if (Tcl_ListObjGetElements(ti, objv[++i], &len, &objs) == TCL_ERROR)
						return TCL_ERROR;

					if (len > 0)
					{
						if (len != 8 && len != 10)
							return tcl_usage(subcmd, options, args);

						svg::gradient::attr start;
						svg::gradient::attr stop;

						char const* startcolor	= Tcl_GetStringFromObj(objs[0], 0);
						char const* stopcolor	= Tcl_GetStringFromObj(objs[1], 0);

						if (!parse_color(startcolor, start.color))
							return tcl_error(subcmd, "invalid color name '%s'", startcolor);
						if (!parse_color(stopcolor, stop.color))
							return tcl_error(subcmd, "invalid color name '%s'", stopcolor);
						if (	Tcl_GetDoubleFromObj(ti, objs[2], &start.offset) != TCL_OK
							|| Tcl_GetDoubleFromObj(ti, objs[3], &stop.offset) != TCL_OK
							|| Tcl_GetDoubleFromObj(ti, objs[4], &gradient.x1) != TCL_OK
							|| Tcl_GetDoubleFromObj(ti, objs[5], &gradient.y1) != TCL_OK
							|| Tcl_GetDoubleFromObj(ti, objs[6], &gradient.x2) != TCL_OK
							|| Tcl_GetDoubleFromObj(ti, objs[7], &gradient.y2) != TCL_OK)
						{
							return tcl_usage(subcmd, options, args);
						}
						if (start.offset < 0 || stop.offset < 0)
							return tcl_error(subcmd, "negative offset in gradient");
						if (start.offset > 100 || stop.offset > 100)
							return tcl_error(subcmd, "offset in gradient extent 100 percent");

						if (len == 10)
						{
							double tx, ty;

							if (	Tcl_GetDoubleFromObj(ti, objs[8], &tx) != TCL_OK
								|| Tcl_GetDoubleFromObj(ti, objs[9], &ty) != TCL_OK)
							{
								return tcl_usage(subcmd, options, args);
							}

							move_x += tx;
							move_y += ty;
						}

						start.opacity = 1.0;
						stop.opacity = 1.0;

						gradient.id = "tk_image";
						gradient.userSpaceOnUse = false;
						gradient.attr_list.push_back(start);
						gradient.attr_list.push_back(stop);

						path.set_gradient(&gradient);
						useGradient = true;
					}
				}
				break;

			default:
				return tcl_usage(subcmd, options, args);
		}
	}

	if (useGradient)
		path.set_fill_color(0);

	Tk_PhotoHandle handle = Tk_FindPhoto(ti, photo);

	if (!handle)
		return tcl_error(subcmd, "invalid argument: '%s' is not a photo image", photo);

	int width;
	int height;

	Tk_PhotoGetSize(handle, &width, &height);

	Tk_PhotoImageBlock block;

	block.pixelPtr = 0;
	block.pixelSize = 4;
	block.pitch = align_pitch(width*block.pixelSize);
	block.width = width;
	block.height = height;
	block.offset[0] = 0;
	block.offset[1] = 1;
	block.offset[2] = 2;
	block.offset[3] = 3;

	typedef agg::pixfmt_rgba32 pixfmt;

	try
	{
		svg::parser parser(path);
		parser.parse(svg_data, data_len);
	}
	catch (svg::exception& exc)
	{
		return tcl_error(subcmd, "SVG parser error: %s", exc.what());
	}

	double min_x, min_y, max_x, max_y;
	path.bounding_rect(&min_x, &min_y, &max_x, &max_y);
	DEBUG(::printf("bounding rect: min = (%f, %f), max = (%f, %f)\n", min_x, min_y, max_x, max_y));
	double mx = 0.5*(min_x + max_x);
	double my = 0.5*(min_y + max_y);

	width = int(max_x + min_x + 0.5);
	height = int(max_y + min_y + 0.5);
	scale *= double(block.height)/double(height);

	block.pixelPtr = new unsigned char[block.pitch*block.height];
	agg::rendering_buffer rbuf(block.pixelPtr, block.width, block.height, block.pitch*flip);

	pixfmt pixf(rbuf);

	agg::trans_affine mtx;
	mtx *= agg::trans_affine_translation(-mx, -my);
	mtx *= agg::trans_affine_scaling(scale);
	mtx *= agg::trans_affine_rotation(agg::deg2rad(rotation));
	mtx *= agg::trans_affine_translation(mx, my);
	mtx *= agg::trans_affine_translation(	-0.5*(max_x + min_x - block.width),
														-0.5*(min_y + max_y - block.height));
	mtx *= agg::trans_affine_translation(scale*move_x, scale*flip*move_y);

	path.render(pixf, mtx, agg::rgba8(255, 255, 255, 0));

	if (sharpen && !useGradient)
	{
		pixbuf<RGBA> pixb(block);
		sharpen_image(pixb, strokecolor, fillcolor);
	}

	int rc = Tk_PhotoPutBlock(	ti,
										handle,
										&block,
										0, 0,
										block.width, block.height,
										TK_PHOTO_COMPOSITE_SET);

	delete [] block.pixelPtr;
	return rc;
}


static int
tk_colorize(char const* subcmd,
				Tcl_Interp* ti,
				char const* color,
				char const* photo,
				double brighten,
				int objc, Tcl_Obj* const objv[])
{
	Tk_PhotoHandle handle = Tk_FindPhoto(ti, photo);

	if (!handle)
		return tcl_error(subcmd, "invalid argument: '%s' is not a photo image", photo);

	agg::rgba8 fillcolor;

	if (!parse_color(color, fillcolor))
		return tcl_error(subcmd, "invalid color name '%s'", color);

	Tk_PhotoImageBlock block;
	Tk_PhotoGetImage(handle, &block);
	Tk_PhotoImageBlock dstBlock = block;

	int rc = check_image_format(subcmd, ti, dstBlock);
	if (rc != TCL_OK)
		return rc;

	processImage(dstBlock, Colorize(fillcolor, brighten));
	return Tk_PhotoPutBlock(ti, handle, &block, 0, 0, block.width, block.height, TK_PHOTO_COMPOSITE_SET);
}


static int
tk_recolor_image(	char const* subcmd,
						Tcl_Interp* ti,
						char const* color,
						char const* photo,
						int objc, Tcl_Obj* const objv[])
{
	static char const* options[] = { "-composite", "-area", 0 };
	static char const* args[] = { "set|overlay", "x0 y0 x1 y1" };

	char const* composite = "overlay";

	int arg	= 0;
	int x0	= 0;
	int y0	= 0;
	int x1	= -1;
	int y1	= -1;

	while (arg < objc)
	{
		char const* option = Tcl_GetStringFromObj(objv[arg++], 0);

		if (arg == objc)
			return tcl_usage(subcmd, options, args);

		if (strcmp(option, "-composite") == 0)
		{
			composite = Tcl_GetStringFromObj(objv[arg++], 0);

			if (strcmp(composite, "set") != 0 && strcmp(composite, "overlay") != 0)
				return tcl_usage(subcmd, options, args);
		}
		else if (strcmp(option, "-area") == 0)
		{
			if (	objc < arg + 4
				|| Tcl_GetIntFromObj(ti, objv[arg++], &x0) != TCL_OK
				|| Tcl_GetIntFromObj(ti, objv[arg++], &y0) != TCL_OK
				|| Tcl_GetIntFromObj(ti, objv[arg++], &x1) != TCL_OK
				|| Tcl_GetIntFromObj(ti, objv[arg++], &y1) != TCL_OK)
			{
				return tcl_usage(subcmd, options, args);
			}

			if (x0 < 0 || y0 < 0 || x1 < 0 || y1 < 0)
				return tcl_error(subcmd, "invalid (negative) coordinates for -area option");

			if (x1 <= x0 || y1 <= y0)
				return TCL_OK;
		}
		else
		{
			return tcl_usage(subcmd, options, args);
		}
	}

	agg::rgba8 fillcolor;

	if (!parse_color(color, fillcolor))
		return tcl_error(subcmd, "invalid color name '%s'", color);

	Tk_PhotoHandle handle = Tk_FindPhoto(ti, photo);

	if (!handle)
		return tcl_error(subcmd, "invalid argument: '%s' is not a photo image", photo);

	Tk_PhotoImageBlock block;
	Tk_PhotoGetImage(handle, &block);
	Tk_PhotoImageBlock dstBlock = block;

	if (x1 >= 0)
	{
		if (x0 > dstBlock.width || y0 > dstBlock.height)
			return tcl_error(subcmd, "coordinates for -area option extend outside source image");

		if (x1 > dstBlock.width)  x1 = dstBlock.width;
		if (y1 > dstBlock.height) y1 = dstBlock.height;

		dstBlock.pixelPtr += y0*dstBlock.pitch + x0*dstBlock.pixelSize;
		dstBlock.width = x1 - x0;
		dstBlock.height = y1 - y0;
	}

	int rc = check_image_format(subcmd, ti, dstBlock);
	if (rc != TCL_OK)
		return rc;

	processImage(dstBlock, Recolor(fillcolor, strcmp(composite, "overlay") == 0));
	return Tk_PhotoPutBlock(ti, handle, &block, 0, 0, block.width, block.height, TK_PHOTO_COMPOSITE_SET);
}


static int
tk_image(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] =
	{
		"border", "copy", "create", "recolor", "disable",
		"alpha", "diffuse", "boost", "colorize", "blur",
		0
	};
	struct { char const* usage; int min_args; } const definitions[] =
	{
		{ "border <photo>", 2 },
		{ "copy <in-photo> <out-photo>", 3 },
		{ "create <svg-data> <out-photo>", 3 },
		{ "recolor <color> <photo>", 3 },
		{ "disable <in-photo> <out-photo>", 3 },
		{ "alpha <value> <photo>", 3 },
		{ "diffuse <value> <photo>", 3 },
		{ "boost <min> <max> <photo>", 4 },
		{ "colorize <color> <brighten> <photo>", 4 },
		{ "blur <radius> <photo> <out-photo>", 4 },
	};
	enum
	{
		Cmd_Border, Cmd_Copy, Cmd_Create, Cmd_Recolor, Cmd_Disable,
		Cmd_Alpha, Cmd_Diffuse, Cmd_Boost, Cmd_Colorize, Cmd_Blur,
	};

	if (objc < 2)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "subcommand ?options?");
		return TCL_ERROR;
	}

	int index;
	int result = Tcl_GetIndexFromObj(ti, objv[1], subcommands, "subcommand", TCL_EXACT, &index);

	if (result != TCL_OK)
		return TCL_ERROR;

	if (objc < definitions[index].min_args)
	{
		Tcl_WrongNumArgs(ti, 1, objv, definitions[index].usage);
		return TCL_ERROR;
	}

	objv += 2;
	objc -= 2;

	switch (index)
	{
		case Cmd_Border:
			{
				char const* str = Tcl_GetStringFromObj(objv[0], 0);
				return tk_make_border(subcommands[index], ti, str, objc - 1, objv + 1);
			}

		case Cmd_Copy:
			{
				char const* str0 = Tcl_GetStringFromObj(objv[0], 0);
				char const* str1 = Tcl_GetStringFromObj(objv[1], 0);
				return tk_copy_image(subcommands[index], ti, str0, str1, objc - 2, objv + 2);
			}

		case Cmd_Create:
			{
				Tcl_Obj* svg_obj = Tcl_ObjGetVar2(ti, objv[0], 0, 0);

				if (!svg_obj)
				{
					return tcl_error(	subcommands[index],
											"invalid argument: cannot find '%s'",
											Tcl_GetStringFromObj(objv[0], 0));
				}

				int svg_len;
				char const* svg_data = Tcl_GetStringFromObj(svg_obj, &svg_len);
				char const* str1 = Tcl_GetStringFromObj(objv[1], 0);
				return tk_create_image(subcommands[index], ti, svg_data, svg_len, str1, objc - 2, objv + 2);
			}

		case Cmd_Recolor:
			{
				char const* str0 = Tcl_GetStringFromObj(objv[0], 0);
				char const* str1 = Tcl_GetStringFromObj(objv[1], 0);
				return tk_recolor_image(subcommands[index], ti, str0, str1, objc - 2, objv + 2);
			}

		case Cmd_Disable:
			{
				char const* str0 = Tcl_GetStringFromObj(objv[0], 0);
				char const* str1 = Tcl_GetStringFromObj(objv[1], 0);
				return tk_disable_image(subcommands[index], ti, str0, str1, objc - 2, objv + 2);
			}

		case Cmd_Alpha:
			{
				double value;
				if (Tcl_GetDoubleFromObj(ti, objv[0], &value) != TCL_OK)
				{
					return tcl_error(	subcommands[index],
											"invalid argument: type 'double' for alpha value expected");
				}
				char const* str0 = Tcl_GetStringFromObj(objv[1], 0);
				return tk_set_alpha(subcommands[index], ti, value, str0, objc - 2, objv + 2);
			}

		case Cmd_Diffuse:
			{
				double value;
				if (Tcl_GetDoubleFromObj(ti, objv[0], &value) != TCL_OK)
				{
					return tcl_error(	subcommands[index],
											"invalid argument: type 'double' for alpha value expected");
				}
				char const* str0 = Tcl_GetStringFromObj(objv[1], 0);
				return tk_diffuse(subcommands[index], ti, value, str0, objc - 2, objv + 2);
			}

		case Cmd_Boost:
			{
				double min, max;
				if (Tcl_GetDoubleFromObj(ti, objv[0], &min) != TCL_OK)
				{
					return tcl_error(	subcommands[index],
											"invalid argument: type 'double' for alpha value expected");
				}
				if (Tcl_GetDoubleFromObj(ti, objv[1], &max) != TCL_OK)
				{
					return tcl_error(	subcommands[index],
											"invalid argument: type 'double' for alpha value expected");
				}
				char const* str0 = Tcl_GetStringFromObj(objv[2], 0);
				return tk_boost(subcommands[index], ti, min, max, str0, objc - 2, objv + 2);
			}

		case Cmd_Colorize:
			{
				double brighten;
				char const* str0 = Tcl_GetStringFromObj(objv[0], 0);
				char const* str1 = Tcl_GetStringFromObj(objv[2], 0);
				if (Tcl_GetDoubleFromObj(ti, objv[1], &brighten) != TCL_OK)
				{
					return tcl_error(	subcommands[index],
											"invalid argument: type 'double' for brighten value expected");
				}
				return tk_colorize(subcommands[index], ti, str0, str1, brighten, objc - 2, objv + 2);
			}


		case Cmd_Blur:
			{
				double radius;
				if (Tcl_GetDoubleFromObj(ti, objv[1], &radius) != TCL_OK)
					return tcl_error(	subcommands[index], "invalid argument: type 'int' for radius expected");
				if (radius < 0.0)
					return tcl_error(	subcommands[index], "invalid argument: radius is negative");
				char const* str0 = Tcl_GetStringFromObj(objv[2], 0);
				char const* str1 = Tcl_GetStringFromObj(objv[3], 0);
				return tk_blur(subcommands[index], ti, str0, str1, radius, objc - 2, objv + 2);
			}
	}

	return TCL_OK;	// not reached
}


void
tk::image_init(Tcl_Interp* ti)
{
	tk_cmd_image = tcl::createCommand(ti, "::scidb::tk::image", tk_image);
}

// vi:set ts=3 sw=3:
