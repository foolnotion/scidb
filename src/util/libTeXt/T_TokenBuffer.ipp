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

#include "m_assert.h"

namespace TeXt {

inline
unsigned
TokenBuffer::size() const
{
	return m_domainStack.size();
}


inline
unsigned
TokenBuffer::countTokens() const
{
	return m_relList.size();
}


inline
void
TokenBuffer::pop()
{
	M_REQUIRE(size() > 1);
	m_domainStack.pop_back();
}


inline
bool
TokenBuffer::contains(mstl::string const& name) const
{
	return m_relIndexMap.has_key(name);
}


inline
bool
TokenBuffer::contains(RefID refID) const
{
	return size_t(refID) < m_rootEntries.size() && m_rootEntries[refID];
}


inline
TokenP
TokenBuffer::getToken(RefID index) const
{
	M_REQUIRE(contains(index));
	return m_rootEntries[index];
}

} // namespace TeXt

// vi:set ts=3 sw=3:
