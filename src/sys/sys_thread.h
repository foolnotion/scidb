// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2010-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _sys_thread_included
#define _sys_thread_included

#include "m_function.h"
#include "m_exception.h"
#include "m_types.h"

#ifdef __WIN32__
# include <windows.h>
#else
# include <pthread.h>
#endif

namespace sys {

class Thread
{
public:

#ifdef __WIN32__
	typedef HANDLE ThreadId;
#else
	typedef pthread_t ThreadId;
#endif

#if __GNUC_PREREQ(4,1) && !defined(DONT_USE_SYNC_BUILTIN)
	typedef int atomic_t;
	typedef atomic_t lock_t;
#elif defined( __WIN32__)
	typedef LONG atomic_t;
	typedef atomic_t lock_t;
#elif defined(__MacOSX__)
	typedef struct { volatile int32_t counter; } atomic_t;
	typedef atomic_t lock_t;
#elif defined(__i386__) || defined(__x86_64__)
	typedef struct { volatile int counter; } atomic_t;
	typedef atomic_t lock_t;
#elif defined (__unix__)
	typedef int atomic_t;
	typedef pthread_mutex_t lock_t;
#endif

	typedef mstl::function<void ()> Runnable;

	Thread();
	Thread(ThreadId threadId);
	~Thread();

	bool isMainThread() const;

	ThreadId threadId() const;

	bool start(Runnable runnable);

	void sleep();
	void awake();

	bool stop();
	bool testCancel();

	mstl::exception const* exception() const;

	static bool insideMainThread();
	static Thread* mainThread();

private:

	typedef mstl::exception Exception;

	bool createThread();
	bool cancelThread();

	void doSleep();
	void doAwake();

#ifdef __WIN32__
	static unsigned startThread(void*);
#else
	static void* startThread(void*);
#endif

	Runnable		m_runnable;
	ThreadId		m_threadId;
	Exception*	m_exception;
	bool			m_wakeUp;
#ifdef __WIN32__
	CRITICAL_SECTION		m_condMutex;
	PCONDITION_VARIABLE	m_condition;
#else
	pthread_mutex_t	m_condMutex;
	pthread_cond_t		m_condition;
#endif

	mutable lock_t		m_lock;
	mutable atomic_t	m_cancel;

#ifndef NDEBUG
	mutable unsigned m_count;
#endif
};

} // namespace sys

#endif // _sys_thread_included

// vi:set ts=3 sw=3:
