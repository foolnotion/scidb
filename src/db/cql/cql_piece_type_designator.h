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
// Copyright: (C) 2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _cql_piece_type_designator_defined
#define _cql_piece_type_designator_defined

#include "cql_common.h"

#include "m_bitfield.h"

namespace cql {

class PieceTypeDesignator
{
public:

	typedef mstl::bitfield<unsigned> Pieces;
	typedef error::Type Error;

	bool test(piece::ID piece) const;

	Pieces const& pieces() const;

	char const* parse(char const* s, Error& error);

private:

	Pieces m_pieces;
};

} // namespace cql

#include "cql_piece_type_designator.ipp"

#endif // _cql_piece_type_designator_defined

// vi:set ts=3 sw=3:
