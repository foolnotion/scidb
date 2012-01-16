// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2008-2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "agg_renderer_scanline.h"
#include "agg_rasterizer_scanline_aa.h"
#include "agg_scanline_p.h"
#include "agg_span_allocator.h"
#include "agg_span_interpolator_linear.h"
#include "agg_span_gradient.h"
#include "agg_trans_affine.h"

namespace svg {

template<class PixFmt, class ColorType>
void path_renderer::render(PixFmt& pixf, agg::trans_affine const& mtx, ColorType const& bg)
{
	typedef agg::renderer_base<PixFmt> renderer_base;
	typedef agg::renderer_scanline_aa_solid<renderer_base> renderer_type;
	typedef agg::rasterizer_scanline_aa<> rasterizer;
	typedef agg::scanline_p8 scanline;

	bool hasGradients = false;

	for (unsigned i = 0; i < m_attr_storage.size(); i++)
	{
		if (!m_attr_storage[i].linearGradient.id.empty())
			hasGradients = true;
	}

	renderer_base	rb(pixf);
	renderer_type	ren(rb);
	agg::rect_i		cb(rb.clip_box());
	rasterizer		ras;
	scanline			sl;

	rb.clear(bg);
	ras.clip_box(cb.x1, cb.y1, cb.x2, cb.y2);
	m_curved_count.count(0);

	for (unsigned i = 0; i < m_attr_storage.size(); i++)
	{
		path_attributes const& attr = m_attr_storage[i];
		m_transform = attr.transform;
		m_transform *= mtx;

		double scl = m_transform.scale();

//		m_curved.approximation_method(curve_inc);
		m_curved.approximation_scale(scl);
		m_curved.angle_tolerance(0.0);

		agg::rgba8 color;

		if (attr.fill_flag)
		{
			ras.reset();

			gradient const* gradient = 0;

			if (attr.linearGradient.id.empty())
			{
				if (!hasGradients)
					gradient = get_linear_gradient();
			}
			else if (get_linear_gradient() == 0)
			{
				gradient = &attr.linearGradient;
			}
			else
			{
				gradient = get_linear_gradient();
			}

			if (!gradient || overrideFillColor())
			{
				if (fabs(m_curved_trans_contour.width()) < 0.0001)
				{
					ras.add_path(m_curved_trans, attr.index);
				}
				else
				{
					m_curved_trans_contour.miter_limit(attr.miter_limit);
					ras.add_path(m_curved_trans_contour, attr.index);
				}

				ras.filling_rule(attr.fill_rule);
				color = attr.fill_color;
				if (!hasGradients || !attr.linearGradient.id.empty())
					color = get_fill_color(color);
				color.opacity(get_opacity(color.opacity()));
				ren.color(color);
				agg::render_scanlines(ras, sl, ren);
			}
			else
			{
				typedef agg::span_allocator<ColorType> span_allocator_type;
				typedef agg::span_interpolator_linear<> interpolator_type;
				typedef agg::gradient_x gradient_func_type;
				typedef svg::gradient_linear_color<ColorType> color_func_type;
				typedef svg::span_gradient<ColorType,
													interpolator_type,
													gradient_func_type,
													color_func_type> span_gradient_type;
				typedef agg::renderer_scanline_aa<	renderer_base,
																span_allocator_type,
																span_gradient_type> renderer_gradient;

				ras.add_path(m_curved_trans, attr.index);
				ras.filling_rule(attr.fill_rule);

				agg::trans_affine gradient_mtx;
				prepare_linear_gradient(*gradient,
												gradient_mtx,
												attr.coords,
												ras.min_x(), ras.max_x(),
												ras.min_y(), ras.max_y());

				gradient_func_type gradient_func;
				span_allocator_type span_allocator;
				color_func_type color_func(gradient->attr_list, get_opacity(1.0));
				interpolator_type span_interpolator(gradient_mtx);
				span_gradient_type span_gradient(span_interpolator,
															gradient_func,
															color_func,
															0, ras.max_x() - ras.min_x());
				renderer_gradient ren(rb, span_allocator, span_gradient);
				agg::render_scanlines(ras, sl, ren);
			}
		}

		if (attr.stroke_flag || outline())
		{
			double stroke_width = get_stroke_width(attr.stroke_width);

			if (stroke_width > 0.0)
			{
				m_curved_stroked.width(stroke_width);
				m_curved_stroked.line_join(attr.line_join);
				m_curved_stroked.line_cap(attr.line_cap);
				m_curved_stroked.miter_limit(attr.miter_limit);
				m_curved_stroked.inner_join(agg::inner_round);
				m_curved_stroked.approximation_scale(scl);

//				if (attr.line_join == miter_join)
//					m_curved_stroked.line_join(miter_join_round);

				// If the *visual* line width is considerable we turn on processing of curve cusps.
				if (attr.stroke_width*scl > 1.0)
					m_curved.angle_tolerance(0.2);

				ras.reset();
				ras.filling_rule(agg::fill_non_zero);
				ras.add_path(m_curved_stroked_trans, attr.index);
				color = get_stroke_color(attr.stroke_color);
				color.opacity(get_opacity(color.opacity()));
				ren.color(color);
				agg::render_scanlines(ras, sl, ren);
			}
		}
	}
}


template <class VertexSource>
inline
void
path_renderer::concat_path(VertexSource& vs)
{
	m_storage.concat_path(vs);
}

} // namespace svg

// vi:set ts=3 sw=3:
