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
	typedef pthread_spinlock_t lock_t;
#endif

	typedef mstl::function<void ()> Runnable;
	typedef mstl::function<void (int)> Signal;

	Thread();
	Thread(ThreadId threadId); // should be used only for main thread
	~Thread();

	bool isMainThread() const;

	ThreadId threadId() const;

	bool start(Runnable runnable);
	bool start(Runnable runnable, Signal signal);

	void join();
	void sleep();
	void awake();

	bool stop();
	bool testCancel();
	bool testRunning();

	void sendSignal(int signal);

	mstl::exception const* exception() const;

	static bool insideMainThread();
	static Thread* mainThread();

private:

	typedef mstl::exception Exception;
	class Synchonize;

	bool doStart(Runnable runnable);

	bool createThread();
	bool cancelThread();

	void joinThread();
	void finishThread();

	void doSleep();
	void doAwake();

	void initMutex();

#ifdef __WIN32__
	typedef CRITICAL_SECTION		Mutex;
	typedef PCONDITION_VARIABLE	Condition;

	static unsigned startThread(void*);
#else
	typedef pthread_mutex_t	Mutex;
	typedef pthread_cond_t	Condition;

	static void* startThread(void*);
#endif

	static void initialize();

	Runnable		m_runnable;
	Signal		m_signal;
	ThreadId		m_threadId;
	Exception*	m_exception;
	bool			m_wakeUp;
	Mutex			m_condMutex;
	Condition	m_condition;

	mutable lock_t		m_lock;
	mutable atomic_t	m_cancel;
	mutable atomic_t	m_running;

	static Synchonize* m_synchronize;
};

} // namespace sys

#endif // _sys_thread_included

// vi:set ts=3 sw=3:
