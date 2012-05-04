// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
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

namespace sys {
namespace utf8 {

inline bool Codec::failed() const				{ return m_failed; }
inline bool Codec::isUtf8() const				{ return m_isUtf8; }
inline bool Codec::fromUtf8(mstl::string& s)	{ return fromUtf8(s, s); }
inline bool Codec::toUtf8(mstl::string& s)	{ return toUtf8(s, s); }
inline void Codec::reset()							{ m_failed = false; }

inline void Codec::setFailed(bool flag)		{ m_failed = flag; }


inline
bool
Codec::is7BitAscii(mstl::string const& s)
{
	return is7BitAscii(s.c_str(), s.size());
}


inline
bool
Codec::hasEncoding() const
{
	return m_codec;
}


inline
mstl::string const&
Codec::encoding() const
{
	return m_encoding;
}

} // namespace utf8
} // namespace sys

// vi:set ts=3 sw=3:
