// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

//----------------------------------------------------------------------------
// Anti-Grain Geometry - Version 2.3
// Copyright (C) 2002-2005 Maxim Shemanarev (http://www.antigrain.com)
//
// Permission to copy, use, modify, sell and distribute this software
// is granted provided this copyright notice appears in all copies.
// This software is provided "as is" without express or implied
// warranty, and with no claim as to its suitability for any purpose.
//
//----------------------------------------------------------------------------

// ======================================================================
// Copyright (C) 2008-2011 Gregor Cramer
// ======================================================================

#include "svg_path_renderer.h"
#include "svg_exception.h"

#include <math.h>

using namespace svg;


static inline double
length(double x, double y)
{
	return ::sqrt(x*x + y*y);
}

inline static double min(double a, double b) { return a < b ? a : b; }
inline static double max(double a, double b) { return a < b ? b : a; }


path_renderer::coordinates::coordinates() :x1(0), y1(0), x2(-1), y2(-1) {}


path_renderer::path_attributes::path_attributes()
	:index(0)
	,fill_color(agg::rgba(0,0,0))
	,stroke_color(agg::rgba(0,0,0))
	,fill_flag(true)
	,stroke_flag(false)
	,fill_rule(agg::fill_non_zero)
	,line_join(agg::miter_join)
	,line_cap(agg::butt_cap)
	,miter_limit(4.0)
	,stroke_width(1.0)
{
	// no action
}


void
path_renderer::path_attributes::update_coords(double x, double y)
{
	if (coords.x1 > coords.x2)
	{
		coords.x1 = coords.x2 = x;
		coords.y1 = coords.y2 = y;
	}
	else
	{
		coords.x1 = min(coords.x1, x);
		coords.y1 = min(coords.y1, y);
		coords.x2 = max(coords.x2, x);
		coords.y2 = max(coords.y2, y);
	}
}


path_renderer::path_attributes::path_attributes(path_attributes const& attr, unsigned idx)
{
	*this = attr;
	index = idx;
}


path_renderer::path_renderer()
	:m_curved(m_storage)
	,m_curved_count(m_curved)
	,m_curved_stroked(m_curved_count)
	,m_curved_stroked_trans(m_curved_stroked, m_transform)
	,m_curved_trans(m_curved_count, m_transform)
	,m_curved_trans_contour(m_curved_trans)
{
	m_curved_trans_contour.auto_detect_orientation(false);
}


void
path_renderer::remove_all()
{
	m_storage.remove_all();
	m_attr_storage.remove_all();
	m_attr_stack.remove_all();
	m_transform.reset();
}


void
path_renderer::begin_path()
{
	push_attr();
	unsigned idx = m_storage.start_new_path();
	m_attr_storage.add(path_attributes(cur_attr(), idx));
}


void
path_renderer::end_path()
{
	if (__builtin_expect(m_attr_storage.size() == 0, 0))
		SVG_RAISE("end_path: the path was not begun");

	path_attributes attr = cur_attr();
	unsigned idx = m_attr_storage[m_attr_storage.size() - 1].index;
	attr.index = idx;
	m_attr_storage[m_attr_storage.size() - 1] = attr;
	pop_attr();
}


void
path_renderer::move_to(double x, double y, bool rel)
{
	if (rel)
		m_storage.rel_to_abs(&x, &y);

	m_storage.move_to(x, y);
	update_coords(x, y);
}


void
path_renderer::line_to(double x, double y, bool rel)
{
	if (rel)
		m_storage.rel_to_abs(&x, &y);

	m_storage.line_to(x, y);
	update_coords(x, y);
}


void path_renderer::hline_to(double x, bool rel)
{
	if (m_storage.total_vertices())
	{
		double x2 = 0.0;
		double y2 = 0.0;

		m_storage.vertex(m_storage.total_vertices() - 1, &x2, &y2);
		if (rel)
			x += x2;
		m_storage.line_to(x, y2);
		update_coords(x, y2);
	}
}


void
path_renderer::vline_to(double y, bool rel)
{
	if (m_storage.total_vertices())
	{
		double x2 = 0.0;
		double y2 = 0.0;

		m_storage.vertex(m_storage.total_vertices() - 1, &x2, &y2);
		if (rel)
			y += y2;
		m_storage.line_to(x2, y);
		update_coords(x2, y);
	}
}


void
path_renderer::curve3(double x1, double y1, double x, double y, bool rel)
{
	if (rel)
	{
		m_storage.rel_to_abs(&x1, &y1);
		m_storage.rel_to_abs(&x,  &y);
	}
	m_storage.curve3(x1, y1, x, y);

	update_coords(x1, y1);
	update_coords(x, y);
}


void
path_renderer::curve3(double x, double y, bool rel)
{
	if (rel)
	{
		m_storage.rel_to_abs(&x, &y);
		m_storage.curve3(x, y);
	}
	else
	{
		m_storage.curve3(x, y);
	}

	update_coords(x, y);
}


void
path_renderer::curve4(	double x1, double y1,
								double x2, double y2,
								double x,  double y,
								bool rel)
{
	if (rel)
	{
		m_storage.rel_to_abs(&x1, &y1);
		m_storage.rel_to_abs(&x2, &y2);
		m_storage.rel_to_abs(&x,  &y);
	}
	m_storage.curve4(x1, y1, x2, y2, x, y);

	update_coords(x, y);
	update_coords(x1, y1);
	update_coords(x2, y2);
}


void
path_renderer::curve4(double x2, double y2, double x, double y, bool rel)
{
	if (rel)
	{
		m_storage.rel_to_abs(&x2, &y2);
		m_storage.rel_to_abs(&x,  &y);
		m_storage.curve4(x2, y2, x, y);
	}
	else
	{
		m_storage.curve4(x2, y2, x, y);
	}

	update_coords(x, y);
	update_coords(x2, y2);
}


void
path_renderer::arc(	double rx, double ry,
							double x_axis_rotation,
							bool large_arc_flag, bool sweep_flag,
							double x, double y,
							bool rel)
{
	if (rel)
	{
		m_storage.rel_to_abs(&x, &y);
		m_storage.arc_rel(rx, ry,
								x_axis_rotation,
								large_arc_flag,
								sweep_flag,
								x, y);
	}
	else
	{
		m_storage.arc_to(	rx, ry,
								x_axis_rotation,
								large_arc_flag,
								sweep_flag,
								x, y);
	}

	update_coords(x, y);
}


void
path_renderer::close_subpath()
{
	m_storage.end_poly(agg::path_flags_close);
}


path_renderer::path_attributes&
path_renderer::cur_attr()
{
	if (__builtin_expect(m_attr_stack.size() == 0, 0))
		SVG_RAISE("cur_attr: attribute stack is empty");

	return m_attr_stack[m_attr_stack.size() - 1];
}


void
path_renderer::push_attr()
{
	m_attr_stack.add(m_attr_stack.size() ? m_attr_stack[m_attr_stack.size() - 1] : path_attributes());
}


void
path_renderer::pop_attr()
{
	if (__builtin_expect(m_attr_stack.size() == 0, 0))
		SVG_RAISE("pop_attr: attribute stack is empty");

	m_attr_stack.remove_last();
}


void
path_renderer::fill(agg::rgba8 const& f)
{
	path_attributes& attr = cur_attr();
	attr.fill_color = f;
	attr.fill_flag = true;
}


void
path_renderer::fill(gradient const& linearGradient)
{
	path_attributes& attr = cur_attr();
	attr.linearGradient = linearGradient;
	attr.fill_flag = true;
}


void
path_renderer::stroke(agg::rgba8 const& s)
{
	path_attributes& attr = cur_attr();
	attr.stroke_color = s;
	attr.stroke_flag = true;
}


void
path_renderer::stroke_width(double w)
{
	cur_attr().stroke_width = w;
}


void
path_renderer::fill_none()
{
	cur_attr().fill_flag = false;
}


void
path_renderer::stroke_none()
{
  cur_attr().stroke_flag = false;
}


void
path_renderer::fill_opacity(double op)
{
	cur_attr().fill_color.opacity(op);
}

void
path_renderer::stroke_opacity(double op)
{
	cur_attr().stroke_color.opacity(op);
}


void
path_renderer::line_join(agg::line_join_e join)
{
	cur_attr().line_join = join;
}


void
path_renderer::line_cap(agg::line_cap_e cap)
{
	cur_attr().line_cap = cap;
}


void
path_renderer::fill_rule(agg::filling_rule_e rule)
{
	cur_attr().fill_rule = rule;
}


void
path_renderer::miter_limit(double ml)
{
	cur_attr().miter_limit = ml;
}


agg::trans_affine&
path_renderer::transform()
{
	return cur_attr().transform;
}


void
path_renderer::parse_path(path_tokenizer& tok)
{
	while (tok.next())
	{
		double arg[10];
		char cmd = tok.last_command();

		switch (cmd)
		{
			case 'M':
			case 'm':
				arg[0] = tok.last_number();
				arg[1] = tok.next(cmd);
				move_to(arg[0], arg[1], cmd == 'm');
				break;

			case 'L':
			case 'l':
				arg[0] = tok.last_number();
				arg[1] = tok.next(cmd);
				line_to(arg[0], arg[1], cmd == 'l');
				break;

			case 'V':
			case 'v':
				vline_to(tok.last_number(), cmd == 'v');
				break;

			case 'H':
			case 'h':
				hline_to(tok.last_number(), cmd == 'h');
				break;

			case 'Q':
			case 'q':
				arg[0] = tok.last_number();
				for(unsigned i = 1; i < 4; i++)
					arg[i] = tok.next(cmd);
				curve3(arg[0], arg[1], arg[2], arg[3], cmd == 'q');
				break;

			case 'T':
			case 't':
				arg[0] = tok.last_number();
				arg[1] = tok.next(cmd);
				curve3(arg[0], arg[1], cmd == 't');
				break;

			case 'C':
			case 'c':
				arg[0] = tok.last_number();
				for(unsigned i = 1; i < 6; i++)
					arg[i] = tok.next(cmd);
				curve4(arg[0], arg[1], arg[2], arg[3], arg[4], arg[5], cmd == 'c');
				break;

			case 'S':
			case 's':
				arg[0] = tok.last_number();
				for(unsigned i = 1; i < 4; i++)
					arg[i] = tok.next(cmd);
				curve4(arg[0], arg[1], arg[2], arg[3], cmd == 's');
				break;

			case 'A':
			case 'a':
				arg[0] = tok.last_number();
				for(unsigned i = 1; i < 7; i++)
					arg[i] = tok.next(cmd);
				arc(arg[0], arg[1], arg[2], arg[3], arg[4], arg[5], arg[6], cmd == 'a');
				break;

			case 'Z':
			case 'z':
				close_subpath();
				break;

			default:
				SVG_RAISE("parse_path: invalid command %c", cmd);
				// not reached
		}
	}
}


void
path_renderer::prepare_linear_gradient(gradient const& linearGradient,
													agg::trans_affine& gradient_mtx,
													coordinates const&,
													int min_x, int max_x,
													int min_y, int max_y)
{
	enum { NoFlip, FlipX, FlipY, FlipXY };

	int		flip	= NoFlip;
	double	rs		= 1.0;
	double	dx		= linearGradient.x2 - linearGradient.x1;
	double	dy		= linearGradient.y2 - linearGradient.y1;

	gradient_mtx = linearGradient.transform;
	gradient_mtx.rotate(::atan2(dy, dx));

	if (linearGradient.userSpaceOnUse)
	{
		// NOTE: This is a hack! userSpaceOnUse/objectBoundingBox isn't really implemented!
		double tx, ty;
		gradient_mtx.translation(&tx, &ty);
		gradient_mtx.translate(-tx, -ty);
	}

	double rot = gradient_mtx.rotation();

	{
		double deg	= agg::rad2deg(rot);
		double mx	= double(max_x - min_x);
		double my	= double(max_y - min_y);

		if (deg < 0.0)		deg += 360.0;
		if (deg > 180.0)	deg -= 180.0;
		if (deg > 90.0)	deg = 180.0 - deg;

		rs = (my/mx)*::sin(agg::deg2rad(deg)) + ::cos(agg::deg2rad(deg));
	}

	// NOTE: antigrain can draw only the first quadrant accurately
	{
		double deg = agg::rad2deg(rot);

		if (::fabs(deg) < 0.001)
			deg = 0.0;
		else if (deg < 0.0)
			deg += 360.0;

		switch (unsigned(deg/90.0))
		{
			case 0: deg = 0.0; break;
			case 1: flip = FlipX; deg = 2*(90.0 - deg); break;
			case 2: flip = FlipXY; deg = -180.0; break;
			case 3: flip = FlipY; deg = 2*(360.0 - deg); break;
		}

		if (deg != 0.0)
			gradient_mtx.rotate(agg::deg2rad(deg));
	}

	gradient_mtx.scale(rs);

	switch (flip)
	{
		case NoFlip:	gradient_mtx.translate(min_x, min_y); break;
		case FlipX:		gradient_mtx.translate(max_x,-min_y); break;
		case FlipY:		gradient_mtx.translate(min_x,-max_y); break;
		case FlipXY:	gradient_mtx.translate(max_x, max_y); break;
	}

	gradient_mtx.invert();

	switch (flip)
	{
		case FlipX:		gradient_mtx.flip_x(); break;
		case FlipY:		gradient_mtx.flip_y(); break;
		case FlipXY:	gradient_mtx.flip_x(); gradient_mtx.flip_y(); break;
	}
}


void
path_renderer::setBoundingBox(double min_x, double min_y, double max_x, double max_y)
{
	begin_path();
	move_to(min_x, min_y);
	move_to(max_x, max_y);
	end_path();
}

// vi:set ts=3 sw=3:
