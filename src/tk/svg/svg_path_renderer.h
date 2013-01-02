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
// Copyright: (C) 2008-2013 Gregor Cramer
// ======================================================================

#ifndef _svg_path_renderer_included
#define _svg_path_renderer_included

#include "svg_path_tokenizer.h"
#include "svg_gradient.h"

#include "agg_path_storage.h"
#include "agg_conv_transform.h"
#include "agg_conv_stroke.h"
#include "agg_conv_contour.h"
#include "agg_conv_curve.h"
#include "agg_color_rgba.h"
#include "agg_bounding_rect.h"

#include <math.h>

namespace svg {

class path_renderer
{
public:

	template<class VertexSource>
	class conv_count
	{
	public:

		conv_count(VertexSource& vs): m_source(&vs), m_count(0) {}

		void count(unsigned n) { m_count = n; }
		unsigned count() const { return m_count; }

		void rewind(unsigned path_id) { m_source->rewind(path_id); }
		unsigned vertex(double* x, double* y)
		{
			++m_count;
			return m_source->vertex(x, y);
		}

	private:

		VertexSource* m_source;
		unsigned m_count;
	};

	struct coordinates
	{
		coordinates();

		double x1, y1;
		double x2, y2;
	};

	struct path_attributes
	{
		unsigned					index;
		agg::rgba8				fill_color;
		agg::rgba8				stroke_color;
		bool						fill_flag;
		bool						stroke_flag;
		agg::filling_rule_e	fill_rule;
		agg::line_join_e		line_join;
		agg::line_cap_e		line_cap;
		double					miter_limit;
		double					stroke_width;
		agg::trans_affine		transform;
		gradient					linearGradient;
		coordinates				coords;

		// constructor
		path_attributes();

		// Copy constructor with new index value
		path_attributes(path_attributes const& attr, unsigned idx);

		// modifiers
		void update_coords(double x, double y);
	};

	typedef agg::pod_bvector<path_attributes>		attr_storage;

	typedef agg::conv_curve<agg::path_storage>	curved;
	typedef conv_count<curved>							curved_count;

	typedef agg::conv_stroke<curved_count>			curved_stroked;
	typedef agg::conv_transform<curved_stroked>	curved_stroked_trans;

	typedef agg::conv_transform<curved_count>		curved_trans;
	typedef agg::conv_contour<curved_trans>		curved_trans_contour;

	path_renderer();
	virtual ~path_renderer() {}

	unsigned operator[](unsigned idx)
	{
		m_transform = m_attr_storage[idx].transform;
		return m_attr_storage[idx].index;
	}

	// Expand all polygons
	void expand(double value) { m_curved_trans_contour.width(value); }

	void bounding_rect(double* x1, double* y1, double* x2, double* y2)
	{
		agg::conv_transform<agg::path_storage> trans(m_storage, m_transform);
		agg::bounding_rect(trans, *this, 0, m_attr_storage.size(), x1, y1, x2, y2);
	}

	virtual bool outline() const														{ return false; }
	virtual bool overrideFillColor() const											{ return false; }
	virtual double get_opacity(double opacity) const							{ return opacity; }
	virtual double get_stroke_width(double width) const						{ return width; }
	virtual agg::rgba8 get_fill_color(agg::rgba8 const& color) const		{ return color; }
	virtual agg::rgba8 get_stroke_color(agg::rgba8 const& color) const	{ return color; }
	virtual gradient const* get_linear_gradient() const						{ return 0; }

	void setBoundingBox(double min_x, double min_y, double max_x, double max_y);

	template<class PixFmt, class ColorType>
	void render(PixFmt& pixf, agg::trans_affine const& mtx, ColorType const& bg);

protected:

	void remove_all();

	// Use these functions as follows:
	// begin_path() when the XML tag <path> comes ("start_element" handler)
	// parse_path() on "d=" tag attribute
	// end_path() when parsing of the entire tag is done.
	void begin_path();
	void parse_path(path_tokenizer& tok);
	void end_path();

	template <class VertexSource> void concat_path(VertexSource& vs);

	// The following functions are essentially a "reflection" of
	// the respective SVG path commands.
	void move_to(double x, double y, bool rel = false);								// M, m
	void line_to(double x,  double y, bool rel = false);								// L, l
	void hline_to(double x, bool rel = false);											// H, h
	void vline_to(double y, bool rel = false);											// V, v
	void curve3(double x1, double y1, double x,  double y, bool rel = false);	// Q, q
	void curve3(double x, double y, bool rel = false);									// T, t
	void curve4(double x1, double y1,														// C, c
					double x2, double y2,
					double x, double y, bool rel = false);
	void curve4(double x2, double y2, double x,  double y, bool rel = false);	// S, s
	void arc(	double rx, double ry,
					double x_axis_rotation,
					bool large_arc_flag, bool sweep_flag,
					double x, double y, bool rel = false);									// A, a
	void close_subpath();																		// Z, z

	unsigned vertex_count() const { return m_curved_count.count(); }

	// Call these functions on <g> tag (start_element, end_element respectively)
	void push_attr();
	void pop_attr();

	// Attribute setting functions.
	void fill(agg::rgba8 const& f);
	void fill(gradient const& linearGradient);
	void stroke(agg::rgba8 const& s);
	void stroke_width(double w);
	void fill_none();
	void stroke_none();
	void fill_opacity(double op);
	void stroke_opacity(double op);
	void line_join(agg::line_join_e join);
	void fill_rule(agg::filling_rule_e rule);
	void line_cap(agg::line_cap_e cap);
	void miter_limit(double ml);
	agg::trans_affine& transform();

	// Make all polygons CCW-oriented
	void arrange_orientations() { m_storage.arrange_orientations_all_paths(agg::path_flags_ccw); }

	friend class parser;

private:

	static void prepare_linear_gradient(gradient const& linearGradient,
													agg::trans_affine& gradient_mtx,
													coordinates const& coords,
													int min_x, int max_x,
													int min_y, int max_y);

	path_attributes& cur_attr();
	void update_coords(double x, double y) { cur_attr().update_coords(x, y); }

	agg::path_storage		m_storage;
	attr_storage 			m_attr_storage;
	attr_storage 			m_attr_stack;
	agg::trans_affine		m_transform;

	curved					m_curved;
	curved_count			m_curved_count;

	curved_stroked			m_curved_stroked;
	curved_stroked_trans	m_curved_stroked_trans;

	curved_trans			m_curved_trans;
	curved_trans_contour	m_curved_trans_contour;
};

} // namespace svg

#include "svg_path_renderer.ipp"

#endif // _svg_path_renderer_included

// vi:set ts=3 sw=3:
