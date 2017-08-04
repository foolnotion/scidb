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

namespace sys {
namespace utf8 {

inline bool Codec::error() const					{ return m_error; }
inline bool Codec::failed() const				{ return m_error || m_unknown > 0; }
inline bool Codec::isUtf8() const				{ return m_type == UTF8; }
inline bool Codec::fromUtf8(mstl::string& s)	{ return fromUtf8(s, s); }
inline bool Codec::toUtf8(mstl::string& s)	{ return toUtf8(s, s); }

inline void Codec::setError(bool flag)				{ m_error = flag; }
inline void Codec::setUnknown(unsigned count)	{ m_unknown = count; }

inline unsigned Codec::unknown() const { return m_unknown; }


inline
void Codec::reset()
{
	m_error = false;
	m_unknown = 0;
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
