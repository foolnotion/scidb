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

#include "sys_thread.h"

#include "m_assert.h"
#include "m_stdio.h"
#include "m_exception.h"

#include <tcl.h>

#include <stdlib.h>

using namespace sys;

typedef Thread::atomic_t atomic_t;
typedef Thread::lock_t lock_t;


struct Guard
{
	void acquire();
	void release();

	Guard(lock_t& lock) :m_lock(lock) { acquire(); }
	~Guard() { release(); }

	static void initLock(lock_t& lock);

	lock_t& m_lock;
};


static void
startRoutine(Thread::Runnable& runnable, mstl::exception*& exception)
{
	try
	{
		runnable();
	}
	catch (mstl::exception& exc)
	{
		fprintf(stderr, "*** exception catched in worker thread ***\n");
		fprintf(stderr, "%s\n", exc.what());
		exception = new mstl::exception(exc);
	}
	catch (...)
	{
		fprintf(stderr, "*** unhandled exception catched in worker thread ***\n");
	}
}


// Atomic functions /////////////////////////////////////////////////////////////////

#if __GNUC_PREREQ(4,1) && !defined(DONT_USE_SYNC_BUILTIN) ///////////////////////////

# define atomic_read(v)		*v
# define atomic_set(v, i)	(*v = i)

inline static int
atomic_cmpxchg(atomic_t* v, int oldval, int newval)
{
	return __sync_val_compare_and_swap(v, oldval, newval);
}

#elif defined( __WIN32__) ///////////////////////////////////////////////////////////

# define atomic_read(v)		(*v)
# define atomic_set(v, i)	(*v = i)

#elif defined(__MacOSX__) ///////////////////////////////////////////////////////////

#include <libkern/OSAtomic.h>

# define atomic_set(v, i)	(((v)->counter) = i)
# define atomic_read(v)		((v)->counter)

static inline void
atomic_inc(atomic_t* v)
{
	OSAtomicIncrement32Barrier(&v->counter);
}

static inline int
atomic_dec_and_test(atomic_t* v)
{
	return OSAtomicDecrement32Barrier(&v->counter) != 0;
}

static inline int
atomic_cmpxchg(atomic_t* v, int oldval, int newval)
{
	return OSAtomicCompareAndSwapIntBarrier(oldval, newval, &v->counter);
}

#elif defined(__i386__) || defined(__x86_64__) //////////////////////////////////////

# define atomic_read(v)		(v)->counter
# define atomic_set(v, i)	(((v)->counter) = i)

static inline int
atomic_dec_and_test(atomic_t* v)
{
	unsigned char c;

	asm volatile(
		"lock;"
		"decl %0; sete %1"
		:"=m" (v->counter), "=qm" (c)
		:"m" (v->counter) : "memory");

	return c != 0;
}

static inline void
atomic_inc(atomic_t* v)
{
	asm volatile(
		"lock;"
		"incl %0" :"+m" (v->counter));
}

static inline int
atomic_cmpxchg(atomic_t* v, int oldval, int newval)
{
	int prev;

	asm volatile(
		"lock;"
		"cmpxchgl %1,%2"
		: "=a"(prev)
		: "r"(newval), "m"(v->counter), "0"(oldval)
		: "memory");

	return prev;
}

#elif defined (__unix__) ////////////////////////////////////////////////////////////

// This is the fallback implementation.

# define atomic_set(v, i)	(*v = i)
# define atomic_read(v)		(*v)

static pthread_mutex_t m_mutex = PTHREAD_MUTEX_INITIALIZER;

static inline int
atomic_cmpxchg(atomic_t* v, int oldval, int newval)
{
	Guard guard(m_mutex);

	if (*v != oldval)
		return *v;

	*v = newval;
	return oldval;
}

#endif //////////////////////////////////////////////////////////////////////////////


// Guard implementation /////////////////////////////////////////////////////////////

#if __GNUC_PREREQ(4,1) && !defined(DONT_USE_SYNC_BUILTIN) ///////////////////////////

void
Guard::acquire()
{
	while (__sync_fetch_and_add(&m_lock, 1) > 0)
	{
		__sync_sub_and_fetch(&m_lock, 1);
		sched_yield();
	}
}

void
Guard::release()
{
	__sync_sub_and_fetch(&m_lock, 1);
}


void
Guard::initLock(lock_t& lock)
{
	lock = 0;
}

#elif defined( __WIN32__) ///////////////////////////////////////////////////////////

void
Guard::acquire()
{
	while (InterlockedIncrement(&m_lock) > 1)
	{
		InterlockedDecrement(&m_lock);
		Yield();
	}
}

void
Guard::release()
{
	InterlockedDecrement(&m_lock);
}


void
Guard::initLock(lock_t& lock)
{
	lock = 0;
}

#elif defined(__i386__) || defined(__x86_64__) || defined(__MacOSX__) ///////////////

void
Guard::acquire()
{
	while (!atomic_dec_and_test(&m_lock))
	{
		atomic_inc(&m_lock);
		sched_yield();
	}
}

void
Guard::release()
{
	atomic_inc(&m_lock);
}


void
Guard::initLock(lock_t& lock)
{
	lock.counter = 1;
}

#elif defined (__unix__) ////////////////////////////////////////////////////////////

// This is the fallback implementation.

void
Guard::acquire()
{
	if (pthread_mutex_lock(&m_lock) != 0)
		M_RAISE("pthread_mutex_lock() failed");
}

void
Guard::release()
{
	if (pthread_mutex_unlock(&m_lock) != 0)
	{
		// don't throw an exception, release() will be used in a destructor
		::fprintf(stderr, "pthread_mutex_unlock() failed\n");
	}
}


void
Guard::initLock(lock_t& lock)
{
	lock = 1;
}

#else ///////////////////////////////////////////////////////////////////////////////

# error "Unsupported platform"

#endif //////////////////////////////////////////////////////////////////////////////


#ifdef __WIN32__ ////////////////////////////////////////////////////////////////////

Thread m_mainThread(GetCurrentThreadId());

bool Thread::insideMainThread() { return GetCurrentThreadId() == m_mainThread.threadId(); }


unsigned
Thread::startThread(void* arg)
{
	startRoutine(static_cast<Thread*>(arg)->m_runnable, static_cast<Thread*>(arg)->m_exception);
	return 0;
}


bool
Thread::createThread()
{
	M_ASSERT((&m_cancel & 0x1f) == 0);	// must be aligned to 32-bit boundary

	m_cancel = 0;	// we do not need a memory barrier
	m_threadId = CreateThread(0, 0, &startThread, this, 0, 0);

	if (m_threadId == 0)
	{
		m_cancel = 1;
		return false;
	}

	return true;
}


bool
Thread::cancelThread()
{
	if (InterlockedCompareExchange(&m_cancel, 0, 1) == 1)
		return false;

	WaitForSingleObject(m_threadId, INFINITE);
	CloseHandle(m_threadId);
	return true;
}


void
Thread::doSleep()
{
	InitializeConditionVariable(&m_condition);
	EnterCriticalSection(&m_condMutex);
	m_wakeUp = false;
	while (!m_wakeUp)
		SleepConditionVariableCS(&m_condition, &m_condMutext);
	LeaveCriticalSection(&m_condMutex);
}


void
Thread::doAwake()
{
	m_wakeUp = true;
	WakeConditionVariable(&m_condition);
}

#elif defined(__unix__) || defined(__MacOSX__) //////////////////////////////////////

Thread m_mainThread(pthread_self());

bool Thread::insideMainThread() { return pthread_self() == m_mainThread.threadId(); }


void*
Thread::startThread(void* arg)
{
	startRoutine(static_cast<Thread*>(arg)->m_runnable, static_cast<Thread*>(arg)->m_exception);
	return 0;
}


bool
Thread::createThread()
{
	pthread_attr_t attr;

	if (pthread_attr_init(&attr) != 0)
		M_RAISE("pthread_attr_init() failed");

	atomic_set(&m_cancel, 0);	// we do not need a memory barrier

#if !defined(__hpux) // requires root privilege under HPUX 11.x
	pthread_attr_setinheritsched(&attr, PTHREAD_EXPLICIT_SCHED);
#endif

	pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);

#ifndef NDEBUG
	if (++m_count > 1)
		fprintf(stderr, "CRITICAL: more than one thread open\n");
#endif

	int rc = pthread_create(&m_threadId, &attr, &startThread, this);
	pthread_attr_destroy(&attr);

	if (rc != 0)
	{
		atomic_set(&m_cancel, 1);
		return false;
	}

	return true;
}


bool
Thread::cancelThread()
{
	if (atomic_cmpxchg(&m_cancel, 0, 1) == 1)
		return false;

	pthread_join(m_threadId, 0);

#ifndef NDEBUG
	--m_count;
#endif

	return true;
}


void
Thread::doSleep()
{
	pthread_cond_init(&m_condition, 0);
	pthread_mutex_lock(&m_condMutex);
	m_wakeUp = false;
	while (!m_wakeUp)
		pthread_cond_wait(&m_condition, &m_condMutex);
	pthread_mutex_unlock(&m_condMutex);
}


void
Thread::doAwake()
{
	m_wakeUp = true;
	pthread_cond_signal(&m_condition);
}

#else ///////////////////////////////////////////////////////////////////////////////

# error "Unsupported platform"

#endif //////////////////////////////////////////////////////////////////////////////

#ifndef NDEBUG
static bool m_noThreads = getenv("SCIDB_NO_THREADS") != 0;
#endif

static int wakeUp(Tcl_Event*, int) { return 1; }


Thread::Thread(ThreadId threadId)
	:m_threadId(threadId)
	,m_exception(0)
	,m_wakeUp(false)
#ifndef NDEBUG
	,m_count(0)
#endif
{
}


Thread::Thread()
	:m_exception(0)
	,m_wakeUp(false)
#ifndef NDEBUG
	,m_count(0)
#endif
{
	Guard::initLock(m_lock);
	atomic_set(&m_cancel, 1);
}


Thread::~Thread()
{
	if (!isMainThread())
	{
		Guard guard(m_lock);	// really neccessary?
		cancelThread();
	}
}


Thread::ThreadId
Thread::threadId() const
{
	return m_threadId;
}


bool
Thread::isMainThread() const
{
	return m_threadId == ::m_mainThread.threadId();
}


mstl::exception const*
Thread::exception() const
{
	Guard guard(m_lock);
	return m_exception;
}


Thread*
Thread::mainThread()
{
	return &m_mainThread;
}


bool
Thread::start(Runnable runnable)
{
	M_REQUIRE(this != mainThread());

	m_runnable = runnable;

#ifndef NDEBUG
	if (::m_noThreads)
	{
		m_runnable();
		return true;
	}
#endif

	Guard guard(m_lock);	// really neccessary?
	cancelThread();
	return createThread();
}


bool
Thread::stop()
{
	M_REQUIRE(this != mainThread());

#ifndef NDEBUG
	if (::m_noThreads)
		return true;
#endif

	Guard guard(m_lock);
	return cancelThread();
}


bool
Thread::testCancel()
{
	M_REQUIRE(this != mainThread());

#ifndef NDEBUG
	if (::m_noThreads)
		return false;
#endif

	// we do not need synchronization here
	return atomic_read(&m_cancel);
}


void
Thread::sleep()
{
	if (isMainThread())
	{
		m_wakeUp = false;
		while (!m_wakeUp)
			Tcl_DoOneEvent(TCL_ALL_EVENTS);
	}
	else
	{
		doSleep();
	}
}


void
Thread::awake()
{
	if (isMainThread())
	{
		m_wakeUp = true;
		Tcl_Event* ev = reinterpret_cast<Tcl_Event*>(ckalloc(sizeof(Tcl_Event)));
		ev->proc = ::wakeUp;
		Tcl_QueueEvent(ev, TCL_QUEUE_HEAD);
	}
	else
	{
		doAwake();
	}
}

// vi:set ts=3 sw=3:
