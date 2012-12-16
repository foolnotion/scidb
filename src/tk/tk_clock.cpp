// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "tk_init.h"

#include "tcl_base.h"

#include "m_assert.h"

#include "agg_path_storage.h"
#include "agg_trans_affine.h"
#include "agg_color_rgba.h"
#include "agg_pixfmt_rgba.h"
#include "agg_ellipse.h"
#include "agg_rendering_buffer.h"
#include "agg_rasterizer_scanline_aa.h"
#include "agg_conv_curve.h"
#include "agg_conv_stroke.h"
#include "agg_scanline_u.h"
#include "agg_renderer_scanline.h"

#include <tcl.h>
#include <tk.h>
#include <time.h>


template <typename T> static T max(T a, T b) { return a < b ? b : a; }


namespace {

struct ColorScheme
{
	ColorScheme(agg::rgba8 const& bg,
					agg::rgba8 const& mm,
					agg::rgba8 const& hh,
					agg::rgba8 const& mh,
					agg::rgba8 const& sh)
		:background(bg)
		,minuteMarkers(mm)
		,hourHand(hh)
		,minuteHand(hh)
		,secondHand(sh)
	{
	}

	agg::rgba8 background;
	agg::rgba8 minuteMarkers;
	agg::rgba8 hourHand;
	agg::rgba8 minuteHand;
	agg::rgba8 secondHand;
};

static ColorScheme const BlueScheme
(
	agg::rgba8(0x46, 0x82, 0xb4), // background
	agg::rgba8(0xff, 0xd7, 0x00), // minute markers
	agg::rgba8(0x19, 0x19, 0x70), // hour hand
	agg::rgba8(0xd5, 0xb4, 0x00), // minute hand
	agg::rgba8(0xff, 0x00, 0x00)  // second hand
);

static ColorScheme const WhiteScheme
(
	agg::rgba8(0xff, 0xff, 0xff), // background
	agg::rgba8(0xff, 0xd7, 0x00), // minute markers
	agg::rgba8(0x19, 0x19, 0x70), // hour hand
	agg::rgba8(0xd5, 0xb4, 0x00), // minute hand
	agg::rgba8(0xff, 0x00, 0x00)  // second hand
);

static ColorScheme const BlackScheme
(
	agg::rgba8(0x00, 0x00, 0x00), // background
	agg::rgba8(0xff, 0xd7, 0x00), // minute markers
	agg::rgba8(0xff, 0xff, 0xff), // hour hand
	agg::rgba8(0x00, 0xff, 0x00), // minute hand
	agg::rgba8(0xff, 0x00, 0x00)  // second hand
);


// ======================================================================
// Th following class is derived from
// http://code.google.com/p/schematrix/downloads/list/agg6explore.tar
// Copyright (C) 2010 by Chris Scaife
// Provided under GNU GENERAL PUBLIC LICENSE version 3
// ======================================================================

class MakeMinuteMarks
{
public:

	MakeMinuteMarks(agg::path_storage& path, double x, double y, double radius);

	void rewind(unsigned min);

	// supply the vertices to draw minute markers
	unsigned vertex(double* x, double* y);

private:

	agg::path_storage& m_markerPath;

	unsigned			m_minute;		// minute marker currently being vertexed
	double const	m_x, m_y;		// center of clock face
	double const	m_radius;		// radius of clock face
};


MakeMinuteMarks::MakeMinuteMarks(agg::path_storage& path, double x, double y, double radius)
	:m_markerPath(path)
	,m_minute(0)
	,m_x(x)
	,m_y(y)
	,m_radius(radius)
{
}


void
MakeMinuteMarks::rewind(unsigned min)
{
	m_minute = min;
}


unsigned
MakeMinuteMarks::vertex(double* x, double* y)
{
	unsigned vertex = m_markerPath.vertex(x, y);

	if (!agg::is_vertex(vertex))
	{
		m_markerPath.rewind(0); // get ready to repeat another one

		if (++m_minute == 60)
			return agg::path_cmd_stop; // finished: that was the last
	}

	double sx = 0.1;
	double sy = 0.1;

	if ((m_minute % 5) == 0)
	{
		// elongate at 15, 30, 45 and 60 minutes
		if ((m_minute % 15) == 0)
		{
			sx *= m_radius/100.0 + 0.7;
			sy *= 1.5 + m_radius/120.0;
		}
		else
		{
			sx *= ::max(1.5, m_radius/170.0);
			sy *= 0.7 + m_radius/120.0;
		}
	}

	if (m_radius < 80.0)
	{
		sx *= m_radius/80.0;

		if (m_radius < 60.0)
			sy *= m_radius/60.0;
	}

	agg::trans_affine minuteMarkerPos = agg::trans_affine_scaling(sx, sy);

	// move it to the circumference
	minuteMarkerPos *= agg::trans_affine_translation(0, m_radius);

	// rotate it to the minute
	minuteMarkerPos *= agg::trans_affine_rotation(m_minute/30.0*agg::pi);
	minuteMarkerPos *= agg::trans_affine_translation(m_x, m_y);
	minuteMarkerPos.transform(x, y);

	return vertex;
}


// ======================================================================
// Th following class is derived from
// http://code.google.com/p/schematrix/downloads/list/agg6explore.tar
// Copyright (C) 2010 by Chris Scaife
// Provided under GNU GENERAL PUBLIC LICENSE version 3
// ======================================================================

class ClockRenderer
{
public:

	ClockRenderer(ColorScheme const& scheme = WhiteScheme);
	~ClockRenderer();

	void changeColorScheme(ColorScheme const& scheme) { m_colorScheme = scheme; }

	agg::int8u const* draw(unsigned hour, unsigned minute, unsigned second);

	// when window resizes, record new dimensions
	// and regenerate the clock face path store with all the minute markers
	// doing it here saves doing all those conversions on every regular draw
	void resize(unsigned width, unsigned height, unsigned pitch);

	// when window resizes, record new dimensions
	// we will make a copy of an already resized renderer
	void resize(ClockRenderer const& renderer);

private:

	void makeHand(agg::path_storage& path, double radius, double length);

	ColorScheme m_colorScheme;

	// a single unpositioned marker for the minutes
	// this is really constant that can be created once
	agg::path_storage m_minuteMark;

	// expanded and scaled set of markers for the clock face
	// these are regenerated when the clock face is rescaled
	agg::path_storage m_minuteMarks;

	// the hands are also rescaled, but again only when window resized
	agg::path_storage m_minuteHand, m_hourHand, m_secondHand;

	unsigned m_width, m_height;	// current window width and height
	unsigned m_pitch;					// pitch of pixel buffer

	agg::int8u* m_pixels; // pixel buffer (m_pitch*m_height bytes)
};


ClockRenderer::ClockRenderer(ColorScheme const& scheme)
	:m_colorScheme(scheme)
	,m_width(0)
	,m_height(0)
	,m_pitch(0)
	,m_pixels(0)
{
	m_minuteMark.move_to(-10, 0);
	m_minuteMark.line_to(+10, 0);
	m_minuteMark.line_to(+10, -100);
	m_minuteMark.line_to(-10, -100);
	m_minuteMark.line_to(-10, 0);
	m_minuteMark.close_polygon();
}


ClockRenderer::~ClockRenderer()
{
	delete [] m_pixels;
}


agg::int8u const*
ClockRenderer::draw(unsigned hour, unsigned minute, unsigned second)
{
	typedef agg::renderer_base<agg::pixfmt_rgba32> Renderer;
	typedef agg::conv_transform<agg::path_storage> Transform;
	typedef agg::conv_curve<Transform> Curve;

	double centerX = m_width/2.0;
	double centerY = m_height/2.0;

	agg::rendering_buffer rbuf(m_pixels, m_width, m_height, m_pitch);

	// pixel access to renderer for the controls and background
	agg::pixfmt_rgba32 pixf(rbuf);
	Renderer renderer(pixf);		// renderer to that pixelformat
	renderer.clear(m_colorScheme.background);	// render solid background color

	// intermediaries to transfer pixel spans from rasterizer to renderer
	// unpacked scanline to transfer from rasterizer to renderer
	agg::scanline_u8 sl;

	// simple polygon rasterizer
	agg::rasterizer_scanline_aa<> rasterizer;
	rasterizer.add_path(m_minuteMarks);

	// render it
	agg::render_scanlines_aa_solid(rasterizer, sl, renderer, m_colorScheme.minuteMarkers);

	// Minute hand rotation: negative is clockwise
	agg::trans_affine transform =
		agg::trans_affine_rotation(minute*(agg::pi/-30.0)); // 30 minutes = pi radians

	// move the hand to clock center
	transform *= agg::trans_affine_translation(centerX, centerY);

	// the first vertex pipe converter transforms coordinates to make
	// the minute hand point in the desired direction
	Transform transPipe(m_minuteHand, transform);

	// the next converter expands curves into many small line segments
	Curve curvPipe(transPipe);

	// and finally a stroke converter to make the lines into surfaces
	// that can be rasterized
	agg::conv_stroke<Curve> strokePipe(curvPipe);

	// set the stroke width for the stroke converter (minute + hour hand)
	strokePipe.width(max(m_height/120.0, 3.5));
	// specify how the line joins should look
	strokePipe.line_join(agg::round_join);
	strokePipe.line_cap(agg::round_cap);

	// connect it to the rasterizer
	rasterizer.add_path(strokePipe); // supply it to the rasterizer
	// rasterize and render the hand, with a solid color
	agg::render_scanlines_aa_solid(rasterizer, sl, renderer, m_colorScheme.minuteHand);

	//... so now you have the minute hand rendered and a vertex pipe set up
	// that we can use again to draw the other clock hands.
	// All we need is to attach the correct vertex store at the input of the
	// pipe and modify the transform affine matrix so that it will point
	// the right way.

	// change the transform matrix to position the hour
	transform = agg::trans_affine_rotation(
		((hour % 12) + minute/60.0)*(agg::pi/-6.0)); // 6 hours for pi radians
	// place center of window
	transform *= agg::trans_affine_translation(centerX, centerY);
	transPipe.attach(m_hourHand);

	strokePipe.width(max(m_height/75.0, 4.0));
	// as before, supply the whole vertex pipe to the rasterizer
	rasterizer.add_path(strokePipe);
	// and render it with a different color
	agg::render_scanlines_aa_solid(rasterizer, sl, renderer, m_colorScheme.hourHand);

	// again leaving the pipe all connected
	// create the rotation for the seconds
	transform = agg::trans_affine_rotation(second*(agg::pi/-30.0)); // 30 seconds for pi radians
	// center on window
	transform *= agg::trans_affine_translation(centerX, centerY);
	// choose the hand outline to rasterize
	transPipe.attach(m_secondHand);

	strokePipe.width(max(m_height/250.0, 2.0)); // draw with thinner lines (second hand)
	rasterizer.add_path(strokePipe); // supply the whole pipe to the rasterizer
	// and render it in another color
	agg::render_scanlines_aa_solid(rasterizer, sl, renderer, m_colorScheme.secondHand);

	return m_pixels;
}


void
ClockRenderer::resize(unsigned width, unsigned height, unsigned pitch)
{
	M_ASSERT(height <= pitch);

	if (m_width == width && m_height == height && m_pitch == pitch)
		return;

	m_width = width; m_height = height; // record new window dimensions
	m_pitch = pitch;

	delete [] m_pixels;
	m_pixels = new agg::int8u[m_pitch*m_height];

	// feed the minute marker to a custom converter that repeats and transforms
	// it for every minute position on the clock face.
	MakeMinuteMarks minuteMarkMaker(m_minuteMark, m_width/2.0, m_height/2.0, m_height*0.4);

	m_minuteMarks.remove_all(); // clear out the old
	m_minuteMarks.concat_path(minuteMarkMaker);

	makeHand(m_hourHand, m_height*0.2, 6.0);		// create the hour hand
	makeHand(m_minuteHand, m_height*0.3, 9.0);		// create the minute hand
	makeHand(m_secondHand, m_height*0.36, 10.0);	// and the second hand
}


void
ClockRenderer::resize(ClockRenderer const& renderer)
{
	m_width = renderer.m_width;
	m_height = renderer.m_height;
	m_pitch = renderer.m_pitch;

	delete [] m_pixels;
	m_pixels = new agg::int8u[m_pitch*m_height];

	m_minuteMarks.remove_all(); // clear out the old
	m_minuteMarks.concat_path(const_cast<agg::path_storage&>(renderer.m_minuteMarks));

	m_hourHand = renderer.m_hourHand;
	m_minuteHand = renderer.m_minuteHand;
	m_secondHand = renderer.m_secondHand;
}


void
ClockRenderer::makeHand(agg::path_storage& path, double radius, double length)
{
	path.remove_all();
	path.move_to(0, -length);
	path.line_to(0, radius);
	path.end_poly(agg::path_flags_none);
}

} // namespace


static int
tkClock(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	// TODO:
	// make a custom widget which provides single or double clock
	// use resize(ClockRenderer const& renderer) for double clock
	//
	// current example: ~/scidb/src/Old_Version/agg/examples/clock.cpp

	return TCL_OK;
}


void
tk::clockInit(Tcl_Interp* ti)
{
	tcl::createCommand(ti, "::scidb::tk::clock", tkClock);
}

// vi:set ts=3 sw=3:
