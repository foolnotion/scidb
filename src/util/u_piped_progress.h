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

#ifndef _u_piped_progress_included
#define _u_piped_progress_included

#include "u_progress.h"

#include "sys_pipe.h"

namespace sys { class Thread; };

namespace util {

class PipedProgress : public Progress, protected sys::pipe::Pipe
{
public:

	PipedProgress(sys::Thread& thread);

	bool interrupted() override;
	bool interruptReceived() const;

	sys::Thread& thread();

	void start(unsigned total) override;
	void update(unsigned progress) override;
	void refresh(unsigned progress);
	void finish() throw() override;

private:

	sys::Thread&	m_thread;
	double			m_total;
	bool				m_interrupted;
	int				m_prevValue;
};

} // namespace util

#include "u_piped_progress.ipp"

#endif // _u_piped_progress_included

// vi:set ts=3 sw=3:
