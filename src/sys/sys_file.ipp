// ======================================================================
// Author : $Author$
// Version: $Revision: 609 $
// Date   : $Date: 2013-01-02 18:35:19 +0100 (Wed, 02 Jan 2013) $
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

#include "m_assert.h"

inline
char
sys::file::pathDelim()
{
#if defined(__WIN32__)
	return '\\';
#else
	return '/';
#endif
}


namespace sys {
namespace file {

inline bool Mapping::isOpen() const			{ return m_address; }
inline bool Mapping::isWriteable() const	{ return m_writeable; }
inline bool Mapping::isReadonly() const	{ return !m_writeable; }

inline unsigned Mapping::size() const		{ return m_size; }
inline unsigned Mapping::capacity() const	{ return m_capacity; }


inline
unsigned char const*
Mapping::address() const
{
	M_REQUIRE(isOpen());
	return static_cast<unsigned char const*>(m_address);
}


inline
unsigned char*
Mapping::address()
{
	M_REQUIRE(isOpen());
	M_REQUIRE(isWriteable());

	return static_cast<unsigned char*>(m_address);
}

} // namespace file
} // namespace sys

// vi:set ts=3 sw=3:
