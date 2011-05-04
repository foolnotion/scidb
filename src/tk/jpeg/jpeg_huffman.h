// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2008-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _jpeg_huffman_included
#define _jpeg_huffman_included

#include <stddef.h>

namespace JPEG {

class BitStream;

class HuffmanDecoder
{
public:

	// constants
	static int const MaxCodes			= 256;
	static int const MaxCodeLength	= 16;
	static int const LookAhead			= 8;

	static int const InternalError			= -1;
	static int const UnexpectedEndOfStream	= -2;
	static int const BadCodeLength			= -3;
	static int const BadCode					= -4;

	// structors
	HuffmanDecoder(unsigned char const* bits, unsigned char const* codes, size_t ncodes);

	// accessors
	int nextCode(BitStream& bitStream) const;

private:

	// accessors
	int nextCode(BitStream& bitStream, int n) const;

	// attributes
   int m_huffCodes[MaxCodes];
   int m_maxCode[MaxCodeLength + 2];
   int m_codeOffset[MaxCodeLength + 1];
   int m_lookNumBits[1 << LookAhead];
   int m_lookSymbol[1 << LookAhead];
};

} // namespace JPEG

#endif // _jpeg_huffman_included

// vi:set ts=3 sw=3:
