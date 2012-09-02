// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _sys_fam_included
#define _sys_fam_included

#include "m_string.h"

namespace sys {

class FileAlterationMonitor
{
public:

	static unsigned const StateChanged	= 1 << 0;
	static unsigned const StateDeleted	= 1 << 1;
	static unsigned const StateCreated	= 1 << 2;
	static unsigned const StateAll		= StateChanged | StateDeleted | StateCreated;

	FileAlterationMonitor();
	virtual ~FileAlterationMonitor() throw();

	bool valid() const;

	mstl::string const& error() const;

	bool add(mstl::string const& path, unsigned states = StateAll);
	void remove(mstl::string const& path);

	virtual void signalId(unsigned id, mstl::string const& path) = 0;
	virtual void signalChanged(unsigned id, mstl::string const& path) = 0;
	virtual void signalDeleted(unsigned id, mstl::string const& path) = 0;
	virtual void signalCreated(unsigned id, mstl::string const& path) = 0;

	static bool isSupported();

private:

	bool				m_valid;
	mstl::string	m_error;
};

} // namespace sys

#include "sys_fam.ipp"

#endif // _sys_fam_included

// vi:set ts=3 sw=3:
