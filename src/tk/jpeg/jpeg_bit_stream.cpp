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

#include "jpeg_bit_stream.h"
#include "jpeg_stream.h"

using namespace JPEG;


BitStream::BitStream(Stream& stream)
	:m_stream(stream)
	,m_bitsLeft(0)
	,m_bits(0)
	,m_eos(false)
{
}


void
BitStream::clear()
{
	skipBits();
	m_eos = false;
}


void
BitStream::readBits()
{
	if (m_eos)
		return;

	do
	{
		int c = m_stream.readByte();

		if (c == -1)
		{
			m_eos = true;
			return;
		}

		m_bits = (m_bits << 8) | c;
		m_bitsLeft += 8;
	}
	while (m_bitsLeft < MaxBits);
}

// vi:set ts=3 sw=3:
