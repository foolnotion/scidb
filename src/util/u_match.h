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

#ifndef _util_match_included
#define _util_match_included

#include "m_string.h"

namespace util {

class Pattern
{
public:

	Pattern();
	Pattern(mstl::string const& pattern);
	Pattern(char const* s, char const* e);

	bool operator==(Pattern const& pattern) const;
	bool operator!=(Pattern const& pattern) const;

	mstl::string const& content() const;
	mstl::string prefix() const;

	bool empty() const;
	bool isPlain() const;
	bool isPartial() const;
	bool ignoreCase() const;
	bool matchAny() const;
	bool matchNone() const;
	bool includes(Pattern const& pattern) const;
	bool intersects(Pattern const& pattern) const;

	bool match(char const* s, char const* e) const;
	bool match(mstl::string const& s) const;

	char const* search(char const* s, char const* e) const;
	char const* search(mstl::string const& s) const;

	bool join(Pattern const& pattern);
	bool intersect(Pattern const& pattern);

	void clear();
	void assign(mstl::string const& pattern);
	void assign(char const* s, char const* e);

private:

	unsigned normalize(char const* s, char const* e);

	mstl::string	m_pattern;
	unsigned			m_minSize;
	bool				m_isPlain;
	bool				m_isPartial;
	bool				m_ignoreCase;
};

} // namespace util

#include "u_match.ipp"

#endif // _util_match_included

// vi:set ts=3 sw=3:
