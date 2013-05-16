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
startRoutine(Thread::Runnable& runnable)
{
	try
	{
		runnable();
	}
	catch (mstl::exception& exc)
	{
		fprintf(stderr, "*** exception catched in worker thread ***\n");
		fprintf(stderr, "%s\n", exc.what());
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

unsigned
Thread::startThread(void* arg)
{
	startRoutine(static_cast<Thread*>(arg)->m_runnable);
	InterlockedExchange(&(static_cast<Thread*>(arg)->m_cancel), 1);
	return 0;
}


void
Thread::createThread()
{
	M_ASSERT((&m_cancel & 0x1f) == 0);	// must be aligned to 32-bit boundary

	m_cancel = 0;	// we do not need a memory barrier
	m_threadId = CreateThread(0, 0, &startThread, this, 0, 0);

	if (m_threadId == 0)
		M_RAISE("CreateThread() failed");
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

#elif defined(__unix__) || defined(__MacOSX__) //////////////////////////////////////

void*
Thread::startThread(void* arg)
{
	startRoutine(static_cast<Thread*>(arg)->m_runnable);
	atomic_cmpxchg(&(static_cast<Thread*>(arg))->m_cancel, 0, 1);
	pthread_exit(0); // never returns
}


void
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

	int rc = pthread_create(&m_threadId, &attr, &startThread, this);
	pthread_attr_destroy(&attr);

	if (rc != 0)
	{
		atomic_set(&m_cancel, 1);
		M_RAISE("pthread_create() failed");
	}
}


bool
Thread::cancelThread()
{
	if (atomic_cmpxchg(&m_cancel, 0, 1) == 1)
		return false;

	pthread_join(m_threadId, 0);
	return true;
}

#else ///////////////////////////////////////////////////////////////////////////////

# error "Unsupported platform"

#endif //////////////////////////////////////////////////////////////////////////////


#ifndef NDEBUG
static bool m_noThreads = getenv("SCIDB_NO_THREADS") != 0;
#endif


Thread::Thread()
{
	Guard::initLock(m_lock);
	atomic_set(&m_cancel, 1);
}


Thread::~Thread()
{
	Guard guard(m_lock);	// really neccessary?
	cancelThread();
}


void
Thread::start(Runnable runnable)
{
	m_runnable = runnable;

#ifndef NDEBUG
	if (::m_noThreads)
		return m_runnable();
#endif

	Guard guard(m_lock);	// really neccessary?
	cancelThread();
	createThread();
}


bool
Thread::stop()
{
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
#ifndef NDEBUG
	if (::m_noThreads)
		return false;
#endif

	// we do not need synchronization here
	return atomic_read(&m_cancel);
}

// vi:set ts=3 sw=3:
