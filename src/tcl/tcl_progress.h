// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
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

#ifndef _tcl_progress_included
#define _tcl_progress_included

#include "u_progress.h"

#include "m_string.h"

extern "C" { struct Tcl_Obj; }

namespace tcl {

class Progress : public util::Progress
{
public:

	Progress(Tcl_Obj* cmd, Tcl_Obj* arg);
	~Progress() throw();

	bool interruptable() const;
	bool interrupted() override;
	unsigned ticks() const override;

	void start(unsigned total) override;
	void message(mstl::string const& msg) override;
	void tick(unsigned count) override;
	void update(unsigned progress) override;
	void finish() throw() override;
	void checkInterruption();
	void interrupt(Tcl_Obj* inform);

	static void initialize();

private:

	int sendFinish() throw();

	Tcl_Obj*			m_cmd;
	Tcl_Obj*			m_arg;
	Tcl_Obj*			m_inform;
	unsigned			m_maximum;
	mutable int		m_numTicks;
	bool				m_sendFinish;
	bool				m_sendMessage;
	bool				m_interrupted;
	bool				m_checkInterruption;
	mstl::string	m_msg;
};

} // namespace tcl

#endif // _tcl_progress_included

// vi:set ts=3 sw=3:
