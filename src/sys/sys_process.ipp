// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2011-2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

namespace sys {

inline bool Process::isRunning() const			{ return m_running; }
inline bool Process::isStopped() const			{ return m_stopped; }
inline bool Process::wasCrashed() const		{ return m_signalCrashed; }
inline bool Process::wasKilled() const			{ return m_signalKilled; }
inline bool Process::pipeWasClosed() const	{ return m_pipeClosed; }
inline int  Process::exitStatus() const		{ return m_exitStatus; }
inline long Process::pid() const					{ return m_pid; }

} // namespace sys

// vi:set ts=3 sw=3:
