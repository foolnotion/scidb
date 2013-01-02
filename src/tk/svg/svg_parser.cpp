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

#include "svg_parser.h"
#include "svg_exception.h"

#include "agg_ellipse.h"

#include "u_base.h"

#include "m_utility.h"
#include "m_stdio.h"

#include "expat.h"

#include <string.h>
#include <ctype.h>

using namespace svg;


struct named_color
{
	char const*	name;
	agg::int8u	r, g, b, a;
};


static named_color const Colors[] =
{
	{ "aliceblue",					240, 248, 255, 255 },
	{ "antiquewhite",				250, 235, 215, 255 },
	{ "aqua",						  0, 255, 255, 255 },
	{ "aquamarine",				127, 255, 212, 255 },
	{ "azure",						240, 255, 255, 255 },
	{ "beige",						245, 245, 220, 255 },
	{ "bisque",						255, 228, 196, 255 },
	{ "black",						  0,   0,   0, 255 },
	{ "blanchedalmond",			255, 235, 205, 255 },
	{ "blue",						  0,   0, 255, 255 },
	{ "blueviolet",				138,  43, 226, 255 },
	{ "brown",						165,  42,  42, 255 },
	{ "burlywood",					222, 184, 135, 255 },
	{ "cadetblue",					 95, 158, 160, 255 },
	{ "chartreuse",				127, 255,   0, 255 },
	{ "chocolate",					210, 105,  30, 255 },
	{ "coral",						255, 127,  80, 255 },
	{ "cornflowerblue",			100, 149, 237, 255 },
	{ "cornsilk",					255, 248, 220, 255 },
	{ "crimson",					220,  20,  60, 255 },
	{ "cyan",						  0, 255, 255, 255 },
	{ "darkblue",					  0,   0, 139, 255 },
	{ "darkcyan",					  0, 139, 139, 255 },
	{ "darkgoldenrod",			184, 134,  11, 255 },
	{ "darkgray",					169, 169, 169, 255 },
	{ "darkgreen",					  0, 100,   0, 255 },
	{ "darkgrey",					169, 169, 169, 255 },
	{ "darkkhaki",					189, 183, 107, 255 },
	{ "darkmagenta",				139,   0, 139, 255 },
	{ "darkolivegreen",			 85, 107,  47, 255 },
	{ "darkorange",				255, 140,   0, 255 },
	{ "darkorchid",				153,  50, 204, 255 },
	{ "darkred",					139,   0,   0, 255 },
	{ "darksalmon",				233, 150, 122, 255 },
	{ "darkseagreen",				143, 188, 143, 255 },
	{ "darkslateblue",			 72,  61, 139, 255 },
	{ "darkslategray",			 47,  79,  79, 255 },
	{ "darkslategrey",			 47,  79,  79, 255 },
	{ "darkturquoise",			  0, 206, 209, 255 },
	{ "darkviolet",				148,   0, 211, 255 },
	{ "deeppink",					255,  20, 147, 255 },
	{ "deepskyblue",				  0, 191, 255, 255 },
	{ "dimgray",					105, 105, 105, 255 },
	{ "dimgrey",					105, 105, 105, 255 },
	{ "dodgerblue",				 30, 144, 255, 255 },
	{ "firebrick",					178,  34,  34, 255 },
	{ "floralwhite",				255, 250, 240, 255 },
	{ "forestgreen",				 34, 139,  34, 255 },
	{ "fuchsia",					255,   0, 255, 255 },
	{ "gainsboro",					220, 220, 220, 255 },
	{ "ghostwhite",				248, 248, 255, 255 },
	{ "gold",						255, 215,   0, 255 },
	{ "goldenrod",					218, 165,  32, 255 },
	{ "gray",						128, 128, 128, 255 },
	{ "green",						  0, 128,   0, 255 },
	{ "greenyellow",				173, 255,  47, 255 },
	{ "grey",						128, 128, 128, 255 },
	{ "honeydew",					240, 255, 240, 255 },
	{ "hotpink",					255, 105, 180, 255 },
	{ "indianred",					205,  92,  92, 255 },
	{ "indigo",						 75,   0, 130, 255 },
	{ "ivory",						255, 255, 240, 255 },
	{ "khaki",						240, 230, 140, 255 },
	{ "lavender",					230, 230, 250, 255 },
	{ "lavenderblush",			255, 240, 245, 255 },
	{ "lawngreen",					124, 252,   0, 255 },
	{ "lemonchiffon",				255, 250, 205, 255 },
	{ "lightblue",					173, 216, 230, 255 },
	{ "lightcoral",				240, 128, 128, 255 },
	{ "lightcyan",					224, 255, 255, 255 },
	{ "lightgoldenrodyellow",	250, 250, 210, 255 },
	{ "lightgray",					211, 211, 211, 255 },
	{ "lightgreen",				144, 238, 144, 255 },
	{ "lightgrey",					211, 211, 211, 255 },
	{ "lightpink",					255, 182, 193, 255 },
	{ "lightsalmon",				255, 160, 122, 255 },
	{ "lightseagreen",			 32, 178, 170, 255 },
	{ "lightskyblue",				135, 206, 250, 255 },
	{ "lightslategray",			119, 136, 153, 255 },
	{ "lightslategrey",			119, 136, 153, 255 },
	{ "lightsteelblue",			176, 196, 222, 255 },
	{ "lightyellow",				255, 255, 224, 255 },
	{ "lime",						  0, 255,   0, 255 },
	{ "limegreen",					 50, 205,  50, 255 },
	{ "linen",						250, 240, 230, 255 },
	{ "magenta",					255,   0, 255, 255 },
	{ "maroon",						128,   0,   0, 255 },
	{ "mediumaquamarine",		102, 205, 170, 255 },
	{ "mediumblue",				  0,   0, 205, 255 },
	{ "mediumorchid",				186,  85, 211, 255 },
	{ "mediumpurple",				147, 112, 219, 255 },
	{ "mediumseagreen",			 60, 179, 113, 255 },
	{ "mediumslateblue",			123, 104, 238, 255 },
	{ "mediumspringgreen",		  0, 250, 154, 255 },
	{ "mediumturquoise",			 72, 209, 204, 255 },
	{ "mediumvioletred",			199,  21, 133, 255 },
	{ "midnightblue",				 25,  25, 112, 255 },
	{ "mintcream",					245, 255, 250, 255 },
	{ "mistyrose",					255, 228, 225, 255 },
	{ "moccasin",					255, 228, 181, 255 },
	{ "navajowhite",				255, 222, 173, 255 },
	{ "navy",						  0,   0, 128, 255 },
	{ "oldlace",					253, 245, 230, 255 },
	{ "olive",						128, 128,   0, 255 },
	{ "olivedrab",					107, 142,  35, 255 },
	{ "orange",						255, 165,   0, 255 },
	{ "orangered",					255,  69,   0, 255 },
	{ "orchid",						218, 112, 214, 255 },
	{ "palegoldenrod",			238, 232, 170, 255 },
	{ "palegreen",					152, 251, 152, 255 },
	{ "paleturquoise",			175, 238, 238, 255 },
	{ "palevioletred",			219, 112, 147, 255 },
	{ "papayawhip",				255, 239, 213, 255 },
	{ "peachpuff",					255, 218, 185, 255 },
	{ "peru",						205, 133,  63, 255 },
	{ "pink",						255, 192, 203, 255 },
	{ "plum",						221, 160, 221, 255 },
	{ "powderblue",				176, 224, 230, 255 },
	{ "purple",						128,   0, 128, 255 },
	{ "red",							255,   0,   0, 255 },
	{ "rosybrown",					188, 143, 143, 255 },
	{ "royalblue",					 65, 105, 225, 255 },
	{ "saddlebrown",				139,  69,  19, 255 },
	{ "salmon",						250, 128, 114, 255 },
	{ "sandybrown",				244, 164,  96, 255 },
	{ "seagreen",					 46, 139,  87, 255 },
	{ "seashell",					255, 245, 238, 255 },
	{ "sienna",						160,  82,  45, 255 },
	{ "silver",						192, 192, 192, 255 },
	{ "skyblue",					135, 206, 235, 255 },
	{ "slateblue",					106,  90, 205, 255 },
	{ "slategray",					112, 128, 144, 255 },
	{ "slategrey",					112, 128, 144, 255 },
	{ "snow",						255, 250, 250, 255 },
	{ "springgreen",				  0, 255, 127, 255 },
	{ "steelblue",					 70, 130, 180, 255 },
	{ "tan",							210, 180, 140, 255 },
	{ "teal",						  0, 128, 128, 255 },
	{ "thistle",					216, 191, 216, 255 },
	{ "tomato",						255,  99,  71, 255 },
	{ "turquoise",					 64, 224, 208, 255 },
	{ "violet",						238, 130, 238, 255 },
	{ "wheat",						245, 222, 179, 255 },
	{ "white",						255, 255, 255, 255 },
	{ "whitesmoke",				245, 245, 245, 255 },
	{ "yellow",						255, 255,   0, 255 },
	{ "yellowgreen",				154, 205,  50, 255 },
};


static bool
is_numeric(char c)
{
	return strchr("0123456789+-.eE", c) != 0;
}


static unsigned
parse_transform_args(char const* str, double* args, unsigned max_na, unsigned* na)
{
	*na = 0;
	char const* ptr = str;

	while (*ptr && *ptr != '(')
		++ptr;

	if (__builtin_expect(*ptr == 0, 0))
		SVG_RAISE("parse_transform_args: invalid syntax");

	char const* end = ptr;
	while (*end && *end != ')')
		++end;
	if (__builtin_expect(*end == 0, 0))
		SVG_RAISE("parse_transform_args: invalid syntax");

	while (ptr < end)
	{
		if (is_numeric(*ptr))
		{
			if (__builtin_expect(*na >= max_na, 0))
				SVG_RAISE("parse_transform_args: too many arguments");

			args[(*na)++] = atof(ptr);

			while (ptr < end && is_numeric(*ptr))
				++ptr;
		}
		else
		{
			++ptr;
		}
	}

	return unsigned(end - str);
}


static bool
match(char const* lhs, char const* rhs)
{
	return strcmp(lhs, rhs) == 0;
}


static bool
match(char const* lhs, char const* rhs, int n)
{
	return strncmp(lhs, rhs, n) == 0;
}


static int
cmp_color(void const* p1, const void* p2)
{
	return strcmp(static_cast<named_color const*>(p1)->name, static_cast<named_color const*>(p2)->name);
}


static int
parse_rgb_component(char const*& str)
{
	int v = strtol(str, const_cast<char**>(&str), 10);

	while (*str && !isdigit(*str))
		++str;

	return v;
}


static double
parse_double(char const* str)
{
	while (isspace(*str))
		++str;

	return atof(str);
}


static double
parse_double(char const* str, double min, double max)
{
	return mstl::max(min, mstl::min(parse_double(str), max));
}


static double
parse_percent(char const* str)
{
	while (isspace(*str))
		++str;

	char* e = 0;
	double num = strtod(str, &e);

	if (!(e && *e == '%'))
		num *= 100.0;

	return mstl::max(0.0, mstl::min(num, 100.0));
}


parser::~parser()
{
	delete [] m_attr_value;
	delete [] m_attr_name;
	delete [] m_title;
}


parser::parser(path_renderer& path)
	:m_path(path)
	,m_tokenizer()
	,m_title(new char[256])
	,m_title_len(0)
	,m_title_flag(false)
	,m_path_flag(false)
	,m_attr_name(new char[128])
	,m_attr_value(new char[1024])
	,m_attr_name_len(127)
	,m_attr_value_len(1023)
	,m_attr_list(0)
{
	m_title[0] = 0;
}


void
parser::parse(char const* svg_data, unsigned len)
{
	::XML_Parser p = ::XML_ParserCreate(NULL);

	if (p == 0)
		SVG_RAISE("couldn't allocate memory for parser");

	::XML_SetUserData(p, this);
	::XML_SetElementHandler(p, start_element, end_element);
	::XML_SetCharacterDataHandler(p, content);

	if (!::XML_Parse(p, svg_data, len, true))
	{
		exception exc(	"%s at line %u\n",
									::XML_ErrorString(::XML_GetErrorCode(p)),
									unsigned(::XML_GetCurrentLineNumber(p)));
		::XML_ParserFree(p);
		M_THROW(exc);
	}

	::XML_ParserFree(p);

	for (char* ts = m_title; *ts; ++ts)
	{
		if (*ts < ' ')
			*ts = ' ';
	}

	m_path.arrange_orientations();
}


void
parser::start_element(void* data, char const* el, char const** attr)
{
	parser& self = *static_cast<parser*>(data);

	if (::match(el, "title"))
	{
		self.m_title_flag = true;
	}
	else if (::match(el, "g"))
	{
		self.m_path.push_attr();
		self.parse_attr(attr);
	}
	else if (::match(el, "path"))
	{
		if (__builtin_expect(self.m_path_flag, 0))
			SVG_RAISE("start_element: nested path");

		self.m_path.begin_path();
		self.parse_path(attr);
		self.m_path.end_path();
		self.m_path_flag = true;
	}
	else if (::match(el, "rect"))
	{
		self.parse_rect(attr);
	}
	else if (::match(el, "circle"))
	{
		self.parse_circle(attr);
	}
	else if (::match(el, "line"))
	{
		self.parse_line(attr);
	}
	else if (::match(el, "polyline"))
	{
		self.parse_poly(attr, false);
	}
	else if (::match(el, "polygon"))
	{
		self.parse_poly(attr, true);
	}
	else if (::match(el, "linearGradient"))
	{
		self.parse_gradient(attr);
	}
	else if (::match(el, "stop"))
	{
		self.parse_stop(attr);
	}
	//else if (::match(el, "<OTHER_ELEMENTS>"))
	//{
	//}
	else if (::match(el, "svg"))
	{
		// nothing to do
	}
	else if (::match(el, "defs"))
	{
		// nothing to do
	}
	else
	{
		printf("SVG parser: cannot handle element '%s'\n", el);
	}
}


void
parser::end_element(void* data, char const* el)
{
	parser& self = *static_cast<parser*>(data);

	if (::match(el, "title"))
	{
		self.m_title_flag = false;
	}
	else if (::match(el, "g"))
	{
		self.m_path.pop_attr();
	}
	else if (::match(el, "path"))
	{
		self.m_path_flag = false;
	}
	else if (::match(el, "linearGradient"))
	{
		if (!self.m_gradient.id.empty())
		{
			self.m_gradient_map.replace(
				gradient_map::value_type(self.m_gradient.id, self.m_gradient));
		}

		self.m_attr_list = 0;
		self.m_gradient = gradient();
	}
	//else if (::match(el, "<OTHER_ELEMENTS>"))
	//{
	//}
}


void
parser::content(void* data, char const* s, int len)
{
	parser& self = *static_cast<parser*>(data);

	// m_title_flag signals that the <title> tag is being parsed now.
	// The following code concatenates the pieces of content of the <title> tag.
	if (self.m_title_flag)
	{
		if (len + self.m_title_len > 255)
			len = 255 - self.m_title_len;

		if (len > 0)
		{
			::memcpy(self.m_title + self.m_title_len, s, len);
			self.m_title_len += len;
			self.m_title[self.m_title_len] = 0;
		}
	}
}


void
parser::parse_attr(char const** attr)
{
	for (int i = 0; attr[i]; i += 2)
	{
		if (::match(attr[i], "style"))
			parse_style(attr[i + 1]);
		else
			parse_attr(attr[i], attr[i + 1]);
	}
}


void
parser::parse_path(char const** attr)
{
	for (int i = 0; attr[i]; i += 2)
	{
		// The <path> tag can consist of the path itself ("d=")
		// as well as of other parameters like "style=", "transform=", etc.
		// In the last case we simply rely on the function of parsing
		// attributes (see 'else' branch).
		if (::match(attr[i], "d"))
		{
			m_tokenizer.set_path_str(attr[i + 1]);
			m_path.parse_path(m_tokenizer);
		}
		else
		{
			// Create a temporary single pair "name-value" in order
			// to avoid multiple calls for the same attribute.
			char const* tmp[4];
			tmp[0] = attr[i];
			tmp[1] = attr[i + 1];
			tmp[2] = 0;
			tmp[3] = 0;
			parse_attr(tmp);
		}
	}
}


bool
parser::parse_attr(char const* name, char const* value)
{
	if (m_attr_list)
	{
		if (::match(name, "stop-color"))
		{
			if (__builtin_expect(m_attr_list->empty(), 0))
				SVG_RAISE("parse_attr: '%s' outside of 'stop' element", name);

			m_attr_list->back().color = parse_color(value);
		}
		else if (::match(name, "stop-opacity"))
		{
			if (__builtin_expect(m_attr_list->empty(), 0))
				SVG_RAISE("parse_attr: '%s' outside of 'stop' element", name);

			m_attr_list->back().opacity = ::parse_double(value, 0, 1);
		}
		else
		{
			return false;
		}
	}
	else
	{
		if (::match(name, "style"))
		{
			parse_style(value);
		}
		else if (::match(name, "fill"))
		{
			if (::match(value, "none"))
				m_path.fill_none();
			else if (match(value, "url(#", 5))
				m_path.fill(lookup_gradient(value + 5));
			else
				m_path.fill(parse_color(value));
		}
		else if (::match(name, "fill-opacity"))
		{
			m_path.fill_opacity(::parse_double(value, 0, 1));
		}
		else if (::match(name, "stroke"))
		{
			if (::match(value, "none"))
				m_path.stroke_none();
			else
				m_path.stroke(parse_color(value));
		}
		else if (::match(name, "stroke-width"))
		{
			m_path.stroke_width(::parse_double(value));
		}
		else if (::match(name, "stroke-linecap"))
		{
			if      (::match(value, "butt"))   m_path.line_cap(agg::butt_cap);
			else if (::match(value, "round"))  m_path.line_cap(agg::round_cap);
			else if (::match(value, "square")) m_path.line_cap(agg::square_cap);
		}
		else if (::match(name, "stroke-linejoin"))
		{
			if      (::match(value, "miter")) m_path.line_join(agg::miter_join);
			else if (::match(value, "round")) m_path.line_join(agg::round_join);
			else if (::match(value, "bevel")) m_path.line_join(agg::bevel_join);
		}
		else if (::match(name, "stroke-miterlimit"))
		{
			m_path.miter_limit(::parse_double(value));
		}
		else if (::match(name, "stroke-opacity"))
		{
			m_path.stroke_opacity(::parse_double(value, 0, 1));
		}
		else if (::match(name, "transform"))
		{
			parse_transform(value, m_path.transform());
		}
		else if (::match(name, "fill-rule"))
		{
			if (::match(value, "nonzero"))
				m_path.fill_rule(agg::fill_non_zero);
			else if (::match(value, "evenodd"))
				m_path.fill_rule(agg::fill_even_odd);
		}
		//else
		//if (::match(el, "<OTHER_ATTRIBUTES>"))
		//{
		//}
		// . . .
		else
		{
			return false;
		}
	}

	return true;
}


void
parser::copy_name(char const* start, char const* end)
{
	unsigned len = unsigned(end - start);

	if (m_attr_name_len == 0 || len > m_attr_name_len)
	{
		delete [] m_attr_name;
		m_attr_name = new char[len + 1];
		m_attr_name_len = len;
	}

	if (len)
		::memcpy(m_attr_name, start, len);

	m_attr_name[len] = 0;
}



void
parser::copy_value(char const* start, char const* end)
{
	unsigned len = unsigned(end - start);

	if (m_attr_value_len == 0 || len > m_attr_value_len)
	{
		delete [] m_attr_value;
		m_attr_value = new char[len + 1];
		m_attr_value_len = len;
	}

	if (len)
		::memcpy(m_attr_value, start, len);

	m_attr_value[len] = 0;
}


bool
parser::parse_name_value(char const* nv_start, char const* nv_end)
{
	char const* str = nv_start;

	while (str < nv_end && *str != ':')
		++str;

	char const* val = str;

	// Right Trim
	while (str > nv_start && (*str == ':' || isspace(*str)))
		--str;
	++str;

	copy_name(nv_start, str);

	while (val < nv_end && (*val == ':' || isspace(*val)))
		++val;

	copy_value(val, nv_end);

	return parse_attr(m_attr_name, m_attr_value);
}



void
parser::parse_style(char const* str)
{
	while (*str)
	{
		// Left Trim
		while (*str && isspace(*str))
			++str;

		char const* nv_start = str;
		while (*str && *str != ';')
			++str;

		char const* nv_end = str;

		// Right Trim
		while (nv_end > nv_start && (*nv_end == ';' || isspace(*nv_end)))
			--nv_end;
		++nv_end;

		parse_name_value(nv_start, nv_end);

		if (*str)
			++str;
	}
}


void
parser::parse_rect(char const** attr)
{
	double x = 0.0;
	double y = 0.0;
	double w = 0.0;
	double h = 0.0;

	m_path.begin_path();

	for (int i = 0; attr[i]; i += 2)
	{
		if (!parse_attr(attr[i], attr[i + 1]))
		{
			if      (::match(attr[i], "x"))			x = ::parse_double(attr[i + 1]);
			else if (::match(attr[i], "y"))			y = ::parse_double(attr[i + 1]);
			else if (::match(attr[i], "width"))		w = ::parse_double(attr[i + 1]);
			else if (::match(attr[i], "height"))	h = ::parse_double(attr[i + 1]);
			else if (::match(attr[i], "rx"))			::fprintf(stderr, "parse_rect: rx not implemented\n");
			else if (::match(attr[i], "ry"))			::fprintf(stderr, "parse_rect: ry not implemented\n");
		}
	}

	if (w != 0.0 && h != 0.0)
	{
		if (__builtin_expect(w < 0.0, 0))
			SVG_RAISE("parse_rect: invalid width: %f", w);
		if (__builtin_expect(h < 0.0, 0))
			SVG_RAISE("parse_rect: invalid height: %f", h);

		m_path.move_to(x,     y);
		m_path.line_to(x + w, y);
		m_path.line_to(x + w, y + h);
		m_path.line_to(x,     y + h);
		m_path.close_subpath();
	}

	m_path.end_path();
}


void
parser::parse_circle(char const** attr)
{
	SVG_RAISE("SVG command 'circle' is not implemented");

	double x = 0.0;
	double y = 0.0;
	double r = 0.0;

	m_path.begin_path();

	for (int i = 0; attr[i]; i += 2)
	{
		if (!parse_attr(attr[i], attr[i + 1]))
		{
			if      (::match(attr[i], "r"))	r = ::parse_double(attr[i + 1]);
			else if (::match(attr[i], "cx"))	x = ::parse_double(attr[i + 1]);
			else if (::match(attr[i], "cy"))	y = ::parse_double(attr[i + 1]);
		}
	}

// this example works
//	m_path.move_to(300, 300);
//	m_path.arc(150, 150, 0, true, false, 300, 299, false);
// in general function arc() is not working!

// XXX not working! why? it should work! the agg library is a mystery.
	m_path.move_to(x, y);
	agg::ellipse ellipse(x, y, r, r, mstl::max(100u, unsigned(r)));
	ellipse.approximation_scale(1);
	m_path.concat_path(ellipse);

	m_path.end_path();
}


void
parser::parse_line(char const** attr)
{
	double x1 = 0.0;
	double y1 = 0.0;
	double x2 = 0.0;
	double y2 = 0.0;

	m_path.begin_path();

	for (int i = 0; attr[i]; i += 2)
	{
		if (!parse_attr(attr[i], attr[i + 1]))
		{
			if      (::match(attr[i], "x1")) x1 = ::parse_double(attr[i + 1]);
			else if (::match(attr[i], "y1")) y1 = ::parse_double(attr[i + 1]);
			else if (::match(attr[i], "x2")) x2 = ::parse_double(attr[i + 1]);
			else if (::match(attr[i], "y2")) y2 = ::parse_double(attr[i + 1]);
		}
	}

	m_path.move_to(x1, y1);
	m_path.line_to(x2, y2);
	m_path.end_path();
}


void
parser::parse_stop(char const** attr)
{
	if (__builtin_expect(!m_attr_list, 0))
		SVG_RAISE("parse_stop: 'stop' outside of 'linearGradient' element");

	m_attr_list->push_back();

	for (int i = 0; attr[i]; i += 2)
	{
		if (::match(attr[i], "style"))
			parse_style(attr[i + 1]);
		else if (::match(attr[i], "offset"))
			m_attr_list->back().offset = ::parse_percent(attr[i + 1]);
		else if (::match(attr[i], "stop-color"))
			m_attr_list->back().color = parse_color(attr[i + 1]);
		else if (::match(attr[i], "stop-opacity"))
			m_attr_list->back().opacity = ::parse_double(attr[i + 1], 0, 1);
	}
}


gradient const&
parser::lookup_gradient(char const* str)
{
	char const* e = str;

	while (*e && *e != ')')
		++e;

	gradient::id_type id(str, e);
	svg::gradient_map::const_iterator gradient = m_gradient_map.find(id);

	if (__builtin_expect(gradient == m_gradient_map.end(), 0))
		SVG_RAISE("lookup_gradient: undefined gradient '%s'", id.c_str());

	return (*gradient).second;
}


void
parser::parse_href(char const* str)
{
	if (*str == '#')
		m_gradient.attr_list = lookup_gradient(str + 1).attr_list;
}


void
parser::parse_gradient(char const** attr)
{
	m_attr_list = &m_gradient.attr_list;

	for (int i = 0; attr[i]; i += 2)
	{
		if (::match(attr[i], "style"))
			parse_style(attr[i + 1]);
		else if (::match(attr[i], "id"))
			m_gradient.id = attr[i + 1];
		else if (::match(attr[i], "gradientUnits"))
			m_gradient.userSpaceOnUse = match(attr[i + 1], "userSpaceOnUse");
		else if (::match(attr[i], "gradientTransform"))
			parse_transform(attr[i + 1], m_gradient.transform);
		else if (::match(attr[i], "x1"))
			m_gradient.x1 = ::parse_double(attr[i + 1]);
		else if (::match(attr[i], "y1"))
			m_gradient.y1 = ::parse_double(attr[i + 1]);
		else if (::match(attr[i], "x2"))
			m_gradient.x2 = ::parse_double(attr[i + 1]);
		else if (::match(attr[i], "y2"))
			m_gradient.y2 = ::parse_double(attr[i + 1]);
		else if (::match(attr[i], "xlink:href"))
			parse_href(attr[i + 1]);
	}
}


void
parser::parse_poly(char const** attr, bool close_flag)
{
	double x = 0.0;
	double y = 0.0;

	m_path.begin_path();

	for (int i = 0; attr[i]; i += 2)
	{
		if (!parse_attr(attr[i], attr[i + 1]) && ::match(attr[i], "points"))
		{
			m_tokenizer.set_path_str(attr[i + 1]);

			if (__builtin_expect(!m_tokenizer.next(), 0))
				SVG_RAISE("parse_poly: too few coordinates");

			x = m_tokenizer.last_number();
			if (!__builtin_expect(m_tokenizer.next(), 0))
				SVG_RAISE("parse_poly: too few coordinates");

			y = m_tokenizer.last_number();
			m_path.move_to(x, y);

			while (m_tokenizer.next())
			{
				x = m_tokenizer.last_number();
				if (__builtin_expect(!m_tokenizer.next(), 0))
					SVG_RAISE("parse_poly: odd number of coordinates");
				y = m_tokenizer.last_number();
				m_path.line_to(x, y);
			}
		}
	}

	if (close_flag)
		m_path.close_subpath();

	m_path.end_path();
}


void
parser::parse_transform(char const* str, agg::trans_affine& mtx)
{
	while (*str)
	{
		if (islower(*str))
		{
			if      (::match(str, "matrix", 6))		str += parse_matrix(str, mtx);
			else if (::match(str, "translate", 9))	str += parse_translate(str, mtx);
			else if (::match(str, "rotate", 6))		str += parse_rotate(str, mtx);
			else if (::match(str, "scale", 5))		str += parse_scale(str, mtx);
			else if (::match(str, "skewX", 5))		str += parse_skew_x(str, mtx);
			else if (::match(str, "skewY", 5))		str += parse_skew_y(str, mtx);
			else												++str;
		}
		else
		{
			++str;
		}
	}
}


unsigned
parser::parse_matrix(char const* str, agg::trans_affine& mtx)
{
	double args[6];
	unsigned na = 0;
	unsigned len = ::parse_transform_args(str, args, 6, &na);

	if (__builtin_expect(na != 6, 0))
		SVG_RAISE("parse_matrix: invalid number of arguments");

	mtx.premultiply(agg::trans_affine(args[0], args[1], args[2], args[3], args[4], args[5]));

	return len;
}


unsigned
parser::parse_translate(char const* str, agg::trans_affine& mtx)
{
	double args[2];
	unsigned na = 0;
	unsigned len = ::parse_transform_args(str, args, 2, &na);

	if (na == 1)
		args[1] = 0.0;

	mtx.premultiply(agg::trans_affine_translation(args[0], args[1]));
	return len;
}


unsigned
parser::parse_rotate(char const* str, agg::trans_affine& mtx)
{
	double args[3];
	unsigned na = 0;
	unsigned len = ::parse_transform_args(str, args, 3, &na);

	if (na == 1)
	{
		mtx.premultiply(agg::trans_affine_rotation(agg::deg2rad(args[0])));
	}
	else if (na == 3)
	{
		agg::trans_affine t = agg::trans_affine_translation(-args[1], -args[2]);
		t *= agg::trans_affine_rotation(agg::deg2rad(args[0]));
		t *= agg::trans_affine_translation(args[1], args[2]);
		mtx.premultiply(t);
	}
	else
	{
		SVG_RAISE("parse_rotate: invalid number of arguments");
	}

	return len;
}


unsigned
parser::parse_scale(char const* str, agg::trans_affine& mtx)
{
	double args[2];
	unsigned na = 0;
	unsigned len = ::parse_transform_args(str, args, 2, &na);

	if (na == 1) args[1] = args[0];
	mtx.premultiply(agg::trans_affine_scaling(args[0], args[1]));

	return len;
}


unsigned
parser::parse_skew_x(char const* str, agg::trans_affine& mtx)
{
	double arg;
	unsigned na = 0;
	unsigned len = ::parse_transform_args(str, &arg, 1, &na);
	mtx.premultiply(agg::trans_affine_skewing(agg::deg2rad(arg), 0.0));
	return len;
}


unsigned
parser::parse_skew_y(char const* str, agg::trans_affine& mtx)
{
	double arg;
	unsigned na = 0;
	unsigned len = ::parse_transform_args(str, &arg, 1, &na);
	mtx.premultiply(agg::trans_affine_skewing(0.0, agg::deg2rad(arg)));
	return len;
}


agg::rgba8
parser::parse_color(char const* str)
{
	while (::isspace(*str))
		++str;

	if (*str == '#')
	{
		unsigned c = 0;
		::sscanf(str + 1, "%x", &c);
		return agg::rgb8_packed(c);
	}
	else if (match(str, "rgb(", 4))
	{
		str += 4;
		int r = parse_rgb_component(str);
		int g = parse_rgb_component(str);
		int b = parse_rgb_component(str);
		return agg::rgba8(r, g, b);
	}
	else
	{
		named_color c;
		c.name = str;

		void const* p = ::bsearch(	&c,
											::Colors,
											U_NUMBER_OF(::Colors),
											sizeof(::Colors[0]),
											cmp_color);
		if (__builtin_expect(!p, 0))
			SVG_RAISE("parse_color: invalid color name '%s'", str);

		named_color const* pc = static_cast<named_color const*>(p);
		return agg::rgba8(pc->r, pc->g, pc->b, pc->a);
	}
}

// vi:set ts=3 sw=3:
