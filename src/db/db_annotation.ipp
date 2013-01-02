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
// Copyright: (C) 2009-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "m_assert.h"

namespace db {


inline Annotation::Annotation() : m_count(0) {}

inline unsigned Annotation::count() const					{ return m_count; }
inline unsigned Annotation::countUsualNags() const		{ return m_count - countUnusualNags(); }

inline bool Annotation::isEmpty() const					{ return m_count == 0; }
inline bool Annotation::containsUsualNags() const		{ return countUsualNags() > 0; }
inline bool Annotation::containsUnusualNags() const	{ return countUnusualNags() > 0; }

inline bool Annotation::unusualNagExists()				{ return m_unusualNags.any(); }
inline bool Annotation::isUnusualNag(nag::ID nag)		{ return m_unusualNags.test(nag); }
inline void Annotation::setUnusualNag(nag::ID nag)		{ m_unusualNags.set(nag); }
inline void Annotation::unsetUnusualNag(nag::ID nag)	{ m_unusualNags.reset(nag); }
inline void Annotation::unsetUnusualNags()				{ m_unusualNags.reset(); }
inline void Annotation::flipUnusualNags()					{ m_unusualNags.flip(); }

inline uint8_t const* Annotation::Annotation::data() const { return m_annotation; }


inline
void
Annotation::clear()
{
	M_REQUIRE(!isDefaultSet());
	m_count = 0;
}


inline
bool
Annotation::operator!=(Annotation const& annotation) const
{
	return !operator==(annotation);
}


inline
nag::ID
Annotation::operator[](unsigned n) const
{
	M_REQUIRE(n < count());
	return nag::ID(m_annotation[n]);
}

} // namespace db

// vi:set ts=3 sw=3:
