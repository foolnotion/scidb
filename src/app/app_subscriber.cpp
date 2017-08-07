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
// Copyright: (C) 2014-2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "app_subscriber.h"

using namespace app;
using namespace db;


Subscriber::~Subscriber() {}


void
Subscriber::updateList(unsigned id, mstl::string const& name, variant::Type variant)
{
	for (unsigned i = 0; i < table::LAST; ++i)
		updateList(table::Type(i), id, name, variant);
}


void
Subscriber::updateList(	unsigned id,
								mstl::string const& name,
								variant::Type variant,
								unsigned view)
{
	for (unsigned i = 0; i < table::LAST; ++i)
		updateList(table::Type(i), id, name, variant, view);
}

// vi:set ts=3 sw=3:
