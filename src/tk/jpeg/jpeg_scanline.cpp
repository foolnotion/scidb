// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2008-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "jpeg_scanline.h"

#include <assert.h>

using namespace JPEG;


Scanline::Scanline()
	:m_length(0)
	,m_channels(0)
	,m_bitsPerPixel(0)
	,m_pitch(0)
	,m_data(0)
	,m_base(0)
{
}


void
Scanline::setup(int length, int channels, int bitsPerPixel, int pitch)
{
	assert(length >= 0);
	assert(pitch >= length);
	assert(1 <= channels && channels <= 4);
	assert(	bitsPerPixel == 8		// gray
			|| bitsPerPixel == 16	// gray + alpha
			|| bitsPerPixel == 24	// 8 bit rgb
			|| bitsPerPixel == 32	// 8 bit rgb + alpha
			|| bitsPerPixel == 48	// 16 bit rgb
			|| bitsPerPixel == 64);	// 16 bit rgb + alpha

	m_length = length;
	m_channels = channels;
	m_bitsPerPixel = bitsPerPixel;
	m_pitch = pitch;
}

// vi:set ts=3 sw=3:
