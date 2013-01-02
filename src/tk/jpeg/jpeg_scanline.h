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

#ifndef _jpeg_scanline_included
#define _jpeg_scanline_included

namespace JPEG {

class Scanline
{
public:

	// structors
	Scanline();

	// accessors
	int length() const			{ return m_length; }
	int channels() const			{ return m_channels; }
	int bytesPerPixel() const 	{ return m_bitsPerPixel/8; }
	int bitsPerPixel() const 	{ return m_bitsPerPixel; }
	int bitDepth() const			{ return m_bitsPerPixel/m_channels; }
	int pitch() const				{ return m_pitch; }

	unsigned char* data()							{ return m_data; }
	unsigned char const* data() const			{ return m_data; }
	unsigned char const* data(int row) const	{ return m_base + m_pitch*row; }
	unsigned char const* base() const			{ return m_base; }

	Scanline& operator[](int row)
	{
		m_data = m_base + m_pitch*row;
		return *this;
	}

	// modifiers
	void setup(int length, int channels, int bitsPerPixel, int pitch);
	void setup(unsigned char* base) { m_base = base; }

private:

	// attributes
	int m_length;
	int m_channels;
	int m_bitsPerPixel;
	int m_pitch;

	mutable unsigned char* m_data;
	unsigned char* m_base;
};

} // namespace JPEG

#endif // _jpeg_scanline_included

// vi:set ts=3 sw=3:
