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

#include "app_application.h"
#include "db_board.h"

#include "tk_init.h"
#include "tcl_base.h"
#include "tcl_application.h"

#include "u_zstream.h"

#include <tcl.h>
#include <tk.h>
#include <stdlib.h>
#include <stdio.h>

//#ifndef BROKEN_LINKER_HACK
//# define BROKEN_LINKER_HACK
//#endif

#ifdef BROKEN_LINKER_HACK
# include "db_board.h"
# include "db_home_pawns.h"
# include "db_signature.h"
# include "db_probe.h"
# include "sci_encoder.h"
# include "si3_encoder.h"
# include "tcl_progress.h"
#endif


static app::Application *m_app = nullptr;


static int
init(Tcl_Interp* ti)
{
	try
	{
		util::ZStream::setZipFileSuffixes(util::ZStream::Strings(1, "pgn"));

		if (Tcl_Init(ti) == TCL_ERROR || Tk_Init(ti) == TCL_ERROR)
			return TCL_ERROR;

		tcl::init(ti);
		tk::init(ti);

		Tcl_PkgProvide(ti, "tkscidb", "1.0");

#ifdef BROKEN_LINKER_HACK

		// HACK!
		// This hack is required for insane systems like Debian Wheezy,
		// and Ubuntu Oneiric. The static object initialization is not
		// properly working on these systems (among other problems).
		db::tag::initialize();
		db::castling::initialize();
		db::Board::initialize();
		db::HomePawns::initialize();
		db::Signature::initialize();
		db::Probe::initialize();
		db::sci::Encoder::initialize();
		db::si3::Encoder::initialize();
		tcl::Progress::initialize();

#endif

		tcl::app::setup(m_app = new app::Application);

#ifdef __WIN32__
		return Tcl_FSEvalFileEx(tcl::interp(), "scidb.gui", 0);
#endif
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
