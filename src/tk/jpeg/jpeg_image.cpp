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

#include "jpeg_image.h"
#include "jpeg_decoder.h"
#include "jpeg_stream.h"
#include "jpeg_exception.h"
#include "jpeg_base.h"

#include <assert.h>

using namespace JPEG;


Image::Image(bool fancyUpsampling, bool alignPixel)
	:m_fancyUpsampling(fancyUpsampling)
	,m_alignPixel(alignPixel)
	,m_rows(0)
	,m_bitDepth(0)
	,m_buffer(0)
	,m_stream(0)
	,m_decoder(0)
{
}


Image::~Image()
{
	delete [] m_buffer;
	delete m_decoder;
	delete m_stream;
}


bool
Image::testMagicNumber(Magic const& magic)
{
	return magic[0] == Base::SOB && magic[1] == Base::SOI && magic[2] == Base::SOB;
}


bool
Image::processHeader(Reader& reader)
{
	if (m_decoder)
		throw Exception("misuse of %s: JPEG header already processed", __func__);

	assert(m_stream == 0);

	m_stream = new Stream(reader);
	m_decoder = new Decoder(*m_stream, *this);
	m_decoder->setFancyUpsampling(m_fancyUpsampling);

	return m_decoder->decode(true);
}


void
Image::process(Reader& reader)
{
	if (!m_decoder && !processHeader(reader))
		throw Exception("does not appear to be a JPEG stream");
	if (!m_stream)
		throw Exception("misuse of %s: JPEG stream already processed", __func__);

	setupBuffer();
	m_decoder->decode();

	delete m_stream;
	m_stream = 0;
}


void
Image::getOffsets(Offets& offsets) const
{
	int bytesPerChannel = m_bitDepth/8;

	if (channels() <= 2)
	{
		offsets[0] = 0;
		offsets[1] = 0;
		offsets[2] = 0;
		offsets[3] = channels() == 2 ? bytesPerChannel: 0;
	}
	else
	{
		offsets[0] = Base::R*bytesPerChannel;
		offsets[1] = Base::G*bytesPerChannel;
		offsets[2] = Base::B*bytesPerChannel;
		offsets[3] = channels() == 4 ? Base::A*bytesPerChannel : 0;
	}
}


unsigned char const*
Image::data() const
{
	if (!m_scanline.base())
		throw Exception("misuse of %s: JPEG stream not processed", __func__);

	return m_scanline.base();
}


unsigned char const*
Image::data(int row) const
{
	if (!m_scanline.base())
		throw Exception("misuse of %s: JPEG stream not processed", __func__);

	return m_scanline.data(row);
}


void
Image::setup(int width, int height, int channels, int bitsPerSample)
{
	assert(width >= 0);
	assert(height >= 0);
	assert(bitsPerSample == 8 || bitsPerSample == 12);
	assert(1 <= channels && channels <= 4);

	m_rows = height;
	m_bitDepth = (bitsPerSample == 8 ? 8 : 16);

	int bitsPerPixel = channels*m_bitDepth;

	if (m_alignPixel && channels == 3)
		bitsPerPixel += 8;

	int bytesPerPixel	= bitsPerPixel/8;
	int alignment		= (bytesPerPixel <= 4 ? 3 : 7);
	int pitch			= (width*bytesPerPixel + alignment) & ~alignment;	// 32/64 bit aligned

	m_scanline.setup(width, channels, bitsPerPixel, pitch);
}


void
Image::setupBuffer()
{
	int alignment = (m_scanline.bytesPerPixel() <= 4 ? 3 : 7);

	// need some overhead for image data alignment
	m_buffer = new unsigned char[m_scanline.pitch()*m_rows + alignment];
	m_scanline.setup(reinterpret_cast<unsigned char*>((long(m_buffer) + alignment) & ~alignment));
}

// vi:set ts=3 sw=3:
