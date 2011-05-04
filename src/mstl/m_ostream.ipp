// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2009-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

namespace mstl {

inline
ostream&
ostream::operator<<(char c)
{
	return put(c);
}


inline
ostream&
ostream::write(unsigned char const* buffer, size_t size)
{
	return write(reinterpret_cast<char const*>(buffer), size);
}

} // namespace mstl

// vi:set ts=3 sw=3:
