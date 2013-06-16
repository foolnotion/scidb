// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2012-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _TeXt_Aho_Corasick_included
#define _TeXt_Aho_Corasick_included

namespace mstl { class string; }

namespace TeXt {

class AhoCorasick
{
public:

	enum Method { LongestMatchOnly, AllMatches, AnyMatch };

	AhoCorasick();
	virtual ~AhoCorasick();

	bool isPrepared() const;

	bool add(mstl::string const& pattern);
	bool add(mstl::string const& pattern, unsigned flag);
	bool search(mstl::string const& text, Method method = LongestMatchOnly);

	char const* findTag(char const* text, unsigned& flag);

	virtual void match(unsigned position, unsigned index, unsigned length);

private:

	class Impl;

	Impl*	m_impl;
	bool	m_isPrepared;
};

} // namespace TeXt

#endif // _TeXt_Aho_Corasick_included

// vi:set ts=3 sw=3:
