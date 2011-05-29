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
// Copyright: (C) 2009-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "tk_init.h"
#include "tcl_base.h"

#include "db_annotation.h"

#include "u_zstream.h"

#include "m_exception.h"

#include <tcl.h>
#include <tk.h>
#include <stdlib.h>


static int
init(Tcl_Interp* ti)
{
	db::Annotation::initialize();	// initializing before main() is not working for any reason

	try
	{
		util::ZStream::setZipFileSuffixes(util::ZStream::Strings(1, "pgn"));

		if (Tcl_Init(ti) == TCL_ERROR || Tk_Init(ti) == TCL_ERROR)
			return TCL_ERROR;

		Tcl_PkgProvide(ti, "tkscidb", "1.0");

		tcl::init(ti);
		tk::init(ti);
	}
	catch (mstl::exception const& exc)
	{
		fprintf(stderr, "exception catched: %s\n", exc.what());
	}

	return TCL_OK;	// satisfies the compiler
}


int
main(int argc, char* argv[])
{
	Tk_Main(argc, argv, init);
	return 0;
}

// vi:set ts=3 sw=3:
