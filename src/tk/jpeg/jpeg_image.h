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

#ifndef _jpeg_image_included
#define _jpeg_image_included

#include "jpeg_scanline.h"

namespace JPEG {

class Reader;
class Stream;
class Decoder;

class Image
{
public:

	// types
	typedef int Offets[4];
	typedef unsigned char Magic[3];

	// structors
	Image(bool fancyUpsampling = false, bool alignPixel = false);
	~Image();

	// accessors
	int width() const				{ return m_scanline.length(); }
	int height() const			{ return m_rows; }
	int pitch() const				{ return m_scanline.pitch(); }
	int channels() const			{ return m_scanline.channels(); }
	int bytesPerPixel() const	{ return m_scanline.bytesPerPixel(); }
	int bitDepth() const			{ return m_scanline.bitDepth(); }

	unsigned char const* data() const;
	unsigned char const* data(int row) const;

	void getOffsets(Offets& offsets) const;

	// image processing
	bool processHeader(Reader& reader);
	void process(Reader& reader);

	// helpers
	static bool testMagicNumber(Magic const& magic);

private:

	// accessors
	Scanline& scanline(int row) { return m_scanline[row]; }

	// modifiers
	void setup(int width, int height, int channels, int bitsPerSample);
	void setupBuffer();

	// friends
	friend class Decoder;

	// attributes
	bool				m_fancyUpsampling;
	bool				m_alignPixel;
	int				m_rows;
	int				m_bitDepth;
	Scanline			m_scanline;
	unsigned char*	m_buffer;
	Stream*			m_stream;
	Decoder*			m_decoder;
};

} // namespace JPEG

#endif // _jpeg_image_included

// vi:set ts=3 sw=3:
