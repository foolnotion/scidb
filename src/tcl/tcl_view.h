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
// Copyright: (C) 2012-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "db_common.h"

extern "C" { struct Tcl_Interp; }
extern "C" { struct Tcl_Obj; }

namespace mstl { template <typename T> class vector; }

namespace tcl {
namespace view {

bool buildTagSet(Tcl_Interp* ti, char const* cmd, Tcl_Obj* allowedTags, ::db::tag::TagSet& tagBits);

unsigned makeLangList(	Tcl_Interp* ti,
								char const* cmd,
								Tcl_Obj* languageList,
								mstl::vector<mstl::string>& langs);

} // namespace view
} // namespace tcl

// vi:set ts=3 sw=3:
