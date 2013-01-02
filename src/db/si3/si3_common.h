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

#ifndef _si3_common_included
#define _si3_common_included

namespace db {
namespace si3 {

namespace flags
{
	enum
	{
		Non_Standard_Start	= 1,
		Promotion				= 2,
		Under_Promotion		= 4,
	};
}

namespace token
{
	// Special-move tokens:
	// Since king-move values 0-9 are taken for actual King moves, only
	// 10-15 (and zero) are available for non-move information.
	enum
	{
		Nag				= 11,	First = Nag,
		Comment			= 12,
		Start_Marker	= 13,
		End_Marker		= 14,
		End_Game			= 15,	Last = End_Game,
	};
}

} // namespace si3
} // namespace db

#endif // _si3_common_included

// vi:set ts=3 sw=3:
