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

#include "jpeg_huffman.h"
#include "jpeg_bit_stream.h"
#include "jpeg_exception.h"

#include <assert.h>
#include <string.h>

using namespace JPEG;


HuffmanDecoder::HuffmanDecoder(unsigned char const* bits, unsigned char const* codes, size_t ncodes)
{
	assert(ncodes <= size_t(MaxCodes));

	int huffCodes[MaxCodes];
	int huffSizes[MaxCodes + 1];
	int i,j, k, l;
	int si;
	int code;

	for (i = 0; i < int(ncodes); ++i)	m_huffCodes[i] = codes[i];
	for ( ; i < MaxCodes; ++i)				m_huffCodes[i] = -1;

	for (i = 0, k = 0; i < MaxCodeLength; ++i)
	{
		int hb = bits[i];

		if (hb < 0 || hb + k > MaxCodes)
			throw Exception("bad Huffman table");

		while (hb--)
			huffSizes[k++] = i + 1;
	}

	huffSizes[k] = 0;

	for (k = 0, code = 0, si = huffSizes[0]; huffSizes[k]; ++si, code <<= 1)
	{
		while (huffSizes[k] == si)
			huffCodes[k++] = code++;

		if (code >= (1 << si))
			throw Exception("bad Huffman table");
	}

	for (i = 1, k = 0; i <= MaxCodeLength; ++i)
	{
		if (bits[i - 1])
		{
			m_codeOffset[i] = k - huffCodes[k];
			k += bits[i - 1];
			m_maxCode[i] = huffCodes[k - 1];
		}
		else
		{
			m_codeOffset[i] = 0;
			m_maxCode[i] = -1;
		}
	}

	m_maxCode[i] = 0xfffff;

	::memset(m_lookNumBits, 0, sizeof(m_lookNumBits));

	for (j = 1, k = 0; j <= LookAhead; j++)
	{
		for (i = 1; i <= bits[j - 1]; i++, k++)
		{
			int lookBits = huffCodes[k] << (LookAhead - j);

			for (l = 1 << (LookAhead - j); l > 0; l--, lookBits++)
			{
				m_lookNumBits[lookBits] = j;
				m_lookSymbol[lookBits] = m_huffCodes[k];
			}
		}
	}
}


int
HuffmanDecoder::nextCode(BitStream& bitStream, int n) const
{
	if (bitStream.fetchBits(n) < n)
		return UnexpectedEndOfStream;

	int code = bitStream.nextBits(n);

	for ( ; code > m_maxCode[n]; ++n)
	{
		if (bitStream.fetchBits(1) == 0)
			return UnexpectedEndOfStream;

		code = (code << 1) | bitStream.nextBits(1);
	}

	if (n > MaxCodeLength)
		return BadCodeLength;

	int index = code + m_codeOffset[n];

	if (index >= MaxCodes)
		return BadCode;

	return m_huffCodes[index];
}


int
HuffmanDecoder::nextCode(BitStream& bitStream) const
{
	if (bitStream.fetchBits(LookAhead) < LookAhead)
		return nextCode(bitStream, 1);

	int look	= bitStream.peekBits(LookAhead);
	int n		= m_lookNumBits[look];

	if (n == 0)
		return nextCode(bitStream, LookAhead + 1);

	assert(n <= LookAhead);

	bitStream.skipBits(n);

	return m_lookSymbol[look];
}

// vi:set ts=3 sw=3:
