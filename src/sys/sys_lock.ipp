// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $HeadURL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2014 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "sys_mutex.h"

namespace sys {

Lock::Lock(Mutex* mutex) :m_mutex(mutex) { if (m_mutex) m_mutex->lock(); }
Lock::~Lock() { if (m_mutex) m_mutex->release(); }

} // namespace sys

// vi:set ts=3 sw=3:
