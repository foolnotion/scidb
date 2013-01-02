// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2009-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "m_string.h"

inline bool sys::utf8::isFirst(char c)	{ return (c & 0xc0) != 0x80; }
inline bool sys::utf8::isTail(char c)	{ return (c & 0xc0) == 0x80; }
inline bool sys::utf8::isAscii(char c)	{ return (c & 0x80) == 0x00; }

inline bool sys::utf8::validate(mstl::string const& str) { return validate(str, str.size()); }


inline
bool
sys::utf8::isSimilar(mstl::string const& lhs, mstl::string const& rhs, unsigned threshold)
{
	return levenstein(lhs, rhs) < threshold;
}

// vi:set ts=3 sw=3:
