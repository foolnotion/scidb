// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2009-2012 Gregor Cramer
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

#include "m_types.h" // for keyword 'override'

extern "C" { struct Tcl_Obj; }

namespace tcl {

class Progress : public util::Progress
{
public:

	Progress(Tcl_Obj* cmd, Tcl_Obj* arg);
	~Progress() throw();

	bool interrupted() override;
	unsigned ticks() const override;

	void start(unsigned total) override;
	void message(mstl::string const& msg) override;
	void tick(unsigned count) override;
	void update(unsigned progress) override;
	void finish() override;

	static void initialize();

private:

	int sendFinish() throw();

	Tcl_Obj*		m_cmd;
	Tcl_Obj*		m_arg;
	unsigned		m_maximum;
	mutable int	m_numTicks;
	bool			m_sendFinish;
	bool			m_firstStart;

	static Tcl_Obj* m_open;
	static Tcl_Obj* m_close;
	static Tcl_Obj* m_start;
	static Tcl_Obj* m_update;
	static Tcl_Obj* m_tick;
	static Tcl_Obj* m_finish;
	static Tcl_Obj* m_interrupted;
	static Tcl_Obj* m_ticks;
	static Tcl_Obj* m_message;
};

} // namespace tcl

#endif // _tcl_progress_included

// vi:set ts=3 sw=3:
