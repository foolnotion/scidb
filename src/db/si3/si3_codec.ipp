// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
//    _/|            __
//   // o\         /    )           ,        /    /
//   || ._)    ----\---------__----------__-/----/__-
//   //__\          \      /   '  /    /   /    /   )
//   )___(     _(____/____(___ __/____(___/____(___/_
// ======================================================================

// ======================================================================
// Copyright: (C) 2009-2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "m_assert.h"

namespace db {
namespace si3 {

inline bool Codec::isFormat4() const { return m_customFlags != 0; }
inline bool Codec::isFormat3() const { return m_customFlags == 0; }

inline unsigned Codec::blockSize() const { return m_blockSize; }


inline
sys::utf8::Codec&
Codec::codec()
{
	M_ASSERT(m_codec);
	return *m_codec;
}

} // namespace si3
} // namespace db

// vi:set ts=3 sw=3:
