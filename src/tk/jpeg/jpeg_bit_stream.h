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

#ifndef _jpeg_bit_stream_included
#define _jpeg_bit_stream_included

#include <assert.h>

namespace JPEG {

class Stream;

class BitStream
{
public:

	// constants
	static int const MaxBits = sizeof(int)*8 - 7;

	// structors
	BitStream(Stream& stream);

	// accessors
	int bitsLeft() const		{ return m_bitsLeft; }
	int bytesLeft() const	{ return m_bitsLeft >> 3; }

	int peekBits(int n) const
	{
		assert(bitsLeft() >= n);
		return (m_bits >> (m_bitsLeft - n)) & ((1 << n) - 1);
	}

	int nextBits(int n)
	{
		assert(bitsLeft() >= n);
		return (m_bits >> (m_bitsLeft -= n)) & ((1 << n) - 1);
	}

	// modifiers
	int fetchBits(int n)
	{
		assert(n <= MaxBits);

		if (m_bitsLeft < n)
			readBits();

		return m_bitsLeft;
	}

	void skipBits() { m_bitsLeft = 0; }

	void skipBits(int n)
	{
		assert(bitsLeft() >= n);
		m_bitsLeft -= n;
	}

	void clear();

private:

	// modifiers
	void readBits();

	// attributes
	Stream&	m_stream;
	int		m_bitsLeft;
	int		m_bits;
	bool		m_eos;
};

} // namespace JPEG

#endif // _jpeg_bit_stream_included

// vi:set ts=3 sw=3:
