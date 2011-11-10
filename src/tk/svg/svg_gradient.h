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

#ifndef _svg_gradient_included
#define _svg_gradient_included

#include "agg_color_rgba.h"
#include "agg_trans_affine.h"
#include "agg_span_gradient.h"

#include "m_map.h"
#include "m_utility.h"
#include "m_vector.h"
#include "m_string.h"

namespace svg {

struct gradient
{
	struct attr
	{
		attr();

		double		offset;
		double		opacity;
		agg::rgba8	color;
	};

	typedef mstl::vector<attr>	attr_vec;
	typedef mstl::string			id_type;
	typedef agg::trans_affine	matrix;

	gradient();

	id_type		id;
	double		x1, y1, x2, y2;
	bool			userSpaceOnUse;
	matrix		transform;
	attr_vec		attr_list;
};

typedef ::mstl::map<gradient::id_type,gradient> gradient_map;


template<class ColorT>
class gradient_linear_color
{
public:

	typedef ColorT color_type;

	typedef mstl::vector<color_type> color_list;

	gradient_linear_color(gradient::attr_vec const& attr_list, double opacity = 1.0);

	unsigned size() const { return m_color_list.size(); }
	color_type c1() const { return m_color_list[0]; }
	color_type c2() const { return m_color_list.back(); }

	color_type operator[] (unsigned v) const
	{
		return m_color_list[mstl::min((typename color_list::size_type)(v), m_color_list.size() - 1)];
	}

private:

	color_list m_color_list;
};


template<class ColorT>
gradient_linear_color<ColorT>::gradient_linear_color(gradient::attr_vec const& attr_list, double opacity)
{
	if (attr_list.empty())
	{
		m_color_list.push_back(color_type());
		m_color_list.back().opacity(opacity);
	}
	else
	{
		double expand = 1.0;

		{
			double min_diff 	= 256.0;
			double offs1		= attr_list[0].offset;

			for (unsigned i = 1; i < attr_list.size(); ++i)
			{
				double offs2	= mstl::min(100.0, mstl::max(offs1, attr_list[i].offset));
				double diff		= offs2 - offs1;

				if (diff < min_diff)
					min_diff = diff;

				offs1 = offs2;
			}

			expand = (min_diff == 0.0 ? 1.0 : 256.0/min_diff);
		}

		double		offs1	= 0.0;
		double		offs2	= mstl::max(0.0, mstl::min(100.0, attr_list[0].offset));
		color_type	c1;
		color_type	c2;

		c2 = attr_list[0].color;
		c2.opacity(opacity*attr_list[0].opacity);
		m_color_list.insert(m_color_list.end(), agg::iround(offs2*expand), c2);

		for (unsigned idx = 1; idx < attr_list.size(); ++idx)
		{
			offs1 = offs2;
			offs2 = mstl::max(offs1, mstl::min(100.0, attr_list[idx].offset));

			c1 = c2;
			c2 = attr_list[idx].color;
			c2.opacity(opacity*attr_list[idx].opacity);

			unsigned num = agg::uround(expand*(offs2 - offs1));

			if (num > 0)
			{
				double step	= (255.0/256.0)/num;
				double v		= 0.0;

				for (unsigned i = 0; i < num; ++i, v += step)
					m_color_list.push_back(c1.gradient(c2, v));
			}
		}

		m_color_list.insert(m_color_list.end(), agg::iround((100.0 - offs2)*expand), c2);
	}
}


template<class ColorT, class Interpolator, class GradientF, class ColorF>
class span_gradient
{
public:

	typedef Interpolator	interpolator_type;
	typedef ColorT			color_type;

	enum
	{
		downscale_shift = interpolator_type::subpixel_shift - agg::gradient_subpixel_shift
	};

	span_gradient(	interpolator_type& inter,
						GradientF const& gradient_function,
						ColorF const& color_function,
						double d1, double d2)
		:m_interpolator(inter)
		,m_gradient_function(gradient_function)
		,m_color_function(color_function)
		,m_d1(agg::iround(d1*agg::gradient_subpixel_scale))
		,m_d2(agg::iround(d2*agg::gradient_subpixel_scale))
	{
	}

	void prepare() {}

	void generate(color_type* span, int x, int y, unsigned len)
	{
		int dd	= mstl::max(1, m_d2 - m_d1);
		int size	= m_color_function.size();

		m_interpolator.begin(x+0.5, y+0.5, len);

		do
		{
			m_interpolator.coordinates(&x, &y);
			int d = m_gradient_function.calculate(x >> downscale_shift, y >> downscale_shift, m_d2);
			d = mstl::min(mstl::max(0, ((d - m_d1)*size)/dd), size - 1);
			*span++ = m_color_function[d];
			++m_interpolator;
		}
		while (--len);
	}

private:

	interpolator_type&	m_interpolator;
	GradientF const&		m_gradient_function;
	ColorF const&			m_color_function;
	int						m_d1;
	int						m_d2;
};

} // namespace svg

namespace mstl {

template <typename> struct is_pod;
template <> struct is_pod< ::svg::gradient::attr > { enum { value = 1 }; };

}

#endif // _svg_gradient_included

// vi:set ts=3 sw=3:
