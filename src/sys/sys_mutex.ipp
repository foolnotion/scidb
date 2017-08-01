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

namespace sys {

inline bool Mutex::isLocked() const { return m_isLocked; }

#ifdef __WIN32__

inline Mutex::Mutex() :m_isLocked(false) { InitializeCriticalSection(&m_lock); }

inline void Mutex::lock()		{ EnterCriticalSection(&m_lock); m_isLocked = true; }
inline void Mutex::release()	{ m_isLocked = false; LeaveCriticalSection(&m_lock); }

#else // !__WIN32__

inline Mutex::Mutex() :m_isLocked(false) { pthread_mutex_init(&m_lock, 0); }

inline void Mutex::lock()		{ pthread_mutex_lock(&m_lock); m_isLocked = true; }
inline void Mutex::release()	{ m_isLocked = false; pthread_mutex_unlock(&m_lock); }

#endif // __WIN32__

} // namespace sys

// vi:set ts=3 sw=3:
