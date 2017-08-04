// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $HeadURL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2014 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

namespace util {

inline Pattern::Pattern() :m_minSize(0), m_isPlain(true), m_ignoreCase(true) {}

inline bool Pattern::empty() const			{ return m_pattern.empty(); }
inline bool Pattern::matchNone() const		{ return m_pattern.empty() && !m_isPartial; }
inline bool Pattern::matchAny() const		{ return m_pattern.empty() && m_isPartial; }
inline bool Pattern::ignoreCase() const	{ return m_ignoreCase; }
inline bool Pattern::isPlain() const		{ return m_isPlain; }
inline bool Pattern::isPartial() const		{ return m_isPartial; }

inline mstl::string const& Pattern::content() const { return m_pattern; }


inline
Pattern::Pattern(mstl::string const& pattern)
	:m_minSize(0)
	,m_isPlain(true)
	,m_isPartial(false)
	,m_ignoreCase(true)
{
	assign(pattern);
}


inline
Pattern::Pattern(char const* s, char const* e)
	:m_minSize(0)
	,m_isPlain(true)
	,m_isPartial(false)
	,m_ignoreCase(true)
{
	assign(s, e);
}


inline
bool
Pattern::operator==(Pattern const& pattern) const
{
	return m_pattern == pattern.m_pattern;
}


inline
bool
Pattern::operator!=(Pattern const& pattern) const
{
	return m_pattern != pattern.m_pattern;
}

} // namespace util

// vi:set ts=3 sw=3:
