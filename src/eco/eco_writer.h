// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $HeadURL$
// ======================================================================

// ======================================================================
//    _/|            __
//   // o\         /    )           ,        /    /
//   || ._)    ----\---------__----------__-/----/__-
//   //__\          \      /   '  /    /   /    /   )
//   )___(     _(____/____(___ __/____(___/____(___/_
// ======================================================================

// ======================================================================
// Copyright: (C) 2014-2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _eco_writer_included
#define _eco_writer_included

#include "eco_visitor.h"

namespace mstl { class ostream; }

namespace eco {

class Writer : public Visitor
{
public:

	Writer(mstl::ostream& strm);
	virtual ~Writer() = default;

	virtual void print(Node const* root);

protected:

	mstl::ostream& m_strm;
};

} // namespace eco

#endif // _eco_writer_included

// vi:set ts=3 sw=3:
