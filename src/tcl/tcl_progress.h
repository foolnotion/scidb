// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
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

#ifndef _tcl_progress_included
#define _tcl_progress_included

#include "u_progress.h"

extern "C" { struct Tcl_Obj; }

namespace tcl {

class Progress : public util::Progress
{
public:

	Progress(Tcl_Obj* cmd, Tcl_Obj* arg);
	~Progress() throw();

	bool interrupted();
	unsigned ticks() const;

	void start(unsigned total);
	void update(unsigned progress);
	void finish();

private:

	struct Initializer { Initializer(); };

	int sendFinish() throw();

	Tcl_Obj*		m_cmd;
	Tcl_Obj*		m_arg;
	unsigned		m_maximum;
	mutable int	m_numTicks;
	bool			m_sendFinish;
	bool			m_firstStart;

	static Initializer	m_initializer;
	static Tcl_Obj*		m_open;
	static Tcl_Obj*		m_close;
	static Tcl_Obj*		m_start;
	static Tcl_Obj*		m_update;
	static Tcl_Obj*		m_finish;
	static Tcl_Obj*		m_interrupted;
	static Tcl_Obj*		m_ticks;
};

} // namespace tcl

#endif // _tcl_progress_included

// vi:set ts=3 sw=3:
