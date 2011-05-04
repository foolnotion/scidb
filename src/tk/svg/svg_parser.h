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
// Copyright: (C) 2008-2011 Gregor Cramer
// ======================================================================

#ifndef _svg_parser_included
#define _svg_parser_included

#include "svg_path_tokenizer.h"
#include "svg_path_renderer.h"
#include "svg_gradient.h"

#include "agg_color_rgba.h"

namespace agg { class trans_affine; }

namespace svg {

class parser
{
public:

	parser(path_renderer& path);
	~parser();

	void parse(char const* svg_data, unsigned len);
	char const* title() const { return m_title; }

	static agg::rgba8 parse_color(char const* str);

private:

	static void start_element(void* data, char const* el, const char** attr);
	static void end_element(void* data, char const* el);
	static void content(void* data, char const* s, int len);

	void parse_attr(char const** attr);
	void parse_path(char const** attr);
	void parse_poly(char const** attr, bool close_flag);
	void parse_rect(char const** attr);
	void parse_circle(char const** attr);
	void parse_line(char const** attr);
	void parse_gradient(char const** attr);
	void parse_stop(char const** attr);
	void parse_style(char const* str);
	void parse_href(char const* str);

	void parse_transform(char const* str, ::agg::trans_affine& mtx);

	unsigned parse_matrix(char const* str, ::agg::trans_affine& mtx);
	unsigned parse_translate(char const* str, ::agg::trans_affine& mtx);
	unsigned parse_rotate(char const* str, ::agg::trans_affine& mtx);
	unsigned parse_scale(char const* str, ::agg::trans_affine& mtx);
	unsigned parse_skew_x(char const* str, ::agg::trans_affine& mtx);
	unsigned parse_skew_y(char const* str, ::agg::trans_affine& mtx);

	bool parse_attr(char const* name, const char* value);
	bool parse_name_value(char const* nv_start, const char* nv_end);

	void copy_name(char const* start, const char* end);
	void copy_value(char const* start, const char* end);

	gradient const& lookup_gradient(char const* str);

	path_renderer&			m_path;
	path_tokenizer			m_tokenizer;
	char*						m_title;
	unsigned					m_title_len;
	bool						m_title_flag;
	bool						m_path_flag;
	char*						m_attr_name;
	char*						m_attr_value;
	unsigned					m_attr_name_len;
	unsigned					m_attr_value_len;
	gradient					m_gradient;
	gradient::attr_vec*	m_attr_list;
	gradient_map			m_gradient_map;
};

} // namespace svg

#endif // _svg_parser_included

// vi:set ts=3 sw=3:
