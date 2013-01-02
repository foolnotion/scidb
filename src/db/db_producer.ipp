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

#include "db_consumer.h"

#include "m_assert.h"

namespace db {

inline format::Type Producer::format() const					{ return m_format; }
inline variant::Type Producer::variant() const				{ return m_variant; }

inline bool Producer::hasConsumer() const						{ return m_consumer; }
inline void Producer::setVariant(variant::Type variant)	{ m_variant = variant; }


inline
Consumer&
Producer::consumer()
{
	M_REQUIRE(hasConsumer());
	return *m_consumer;
}


inline
Consumer const&
Producer::consumer() const
{
	M_REQUIRE(hasConsumer());
	return *m_consumer;
}


inline
Board&
Producer::board()
{
	M_REQUIRE(hasConsumer());
	return m_consumer->getBoard();
}

inline
Board const&
Producer::board() const
{
	M_REQUIRE(hasConsumer());
	return m_consumer->board();
}


inline
bool
Producer::whiteToMove() const
{
	M_REQUIRE(hasConsumer());
	return color::isWhite(m_consumer->board().sideToMove());
}


inline
bool
Producer::blackToMove() const
{
	M_REQUIRE(hasConsumer());
	return color::isBlack(m_consumer->board().sideToMove());
}

} // namespace db

// vi:set ts=3 sw=3:
