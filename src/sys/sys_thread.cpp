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

#if defined(__i386__) || defined(__x86_64__)
# define CONFIG_SMP
#endif

using namespace sys::thread;

#ifdef __WIN32__

# include <windows.h>
typedef HANDLE Id;

#else

# include <pthread.h>
typedef pthread_t Id;

#endif


static Id m_id = 0;
static Runnable m_runnable;


template <int N>
struct Guard
{
	void acquire();
	void release();

	Guard()	{ acquire(); }
	~Guard()	{ release(); }
};


static void
startRoutine(Runnable* runnable)
{
	try
	{
		(*runnable)();
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

// Mutex ////////////////////////////////////////////////////////////////

#ifndef CONFIG_SMP

// This is the implementation of Dekker's algorithm, which won't work on SMP machines.

# define ATOMIC_INIT(x) x

typedef volatile int atomic_t;

static volatile int flag[2]	= { 0, 0 };
static volatile int turn		= 0;

# define atomic_read(v)		(*v)
# define atomic_set(v, i)	(*v = i)

template <int N>
void
Guard<N>::acquire()
{
	flag[N] = 1;
	turn = 1 - N;

	while (flag[1 - N] == 1 && turn == 1 - N)
		yield();
}

template <int N>
void
Guard<N>::release()
{
	flag[N] = 0;
}

inline static int
atomic_cmpxchg(atomic_t* v, int oldval, int newval)
{
	Guard<0> guard;

	if (*v != oldval)
		return *v;

	*v = newval;
	return oldval;
}

inline static bool
atomic_test(atomic_t* v)
{
	Guard<1> guard;
	return *v == 1;
}

#elif __GNUC_PREREQ(4,1) && !defined(DONT_USE_SYNC_BUILTIN)

# define ATOMIC_INIT(x) { x }

# define atomic_read(v)		*v
# define atomic_set(v, i)	(*v = i)

typedef volatile int atomic_t;

static atomic_t m_lock = 0;

template <int N>
void
Guard<N>::acquire()
{
	while (__sync_fetch_and_add(&m_lock, 1) > 0)
	{
		__sync_sub_and_fetch(&m_lock, 1);
		yield();
	}
}

template <int N>
void
Guard<N>::release()
{
	__sync_sub_and_fetch(&m_lock, 1);
}

inline static int
atomic_cmpxchg(atomic_t* v, int oldval, int newval)
{
	return __sync_val_compare_and_swap(v, oldval, newval);
}

inline static bool
atomic_test(atomic_t* v)
{
	Guard<1> guard;
	return *v == 1;
}

#elif defined(__WIN32__)

static volatile LONG m_lock = 0;

# define atomic_read(v) (*v)

inline static bool
atomic_test(volatile LONG* v)
{
	if (InterlockedDecrement(v) == 0)
		return true;

	InterlockedIncrement(v);
	return false;
}

template <int N>
void
Guard<N>::acquire()
{
	while (InterlockedIncrement(&m_lock) > 1)
	{
		InterlockedDecrement(&m_lock);
		yield();
	}
}

template <int N>
void
Guard<N>::release()
{
	InterlockedDecrement(&m_lock);
}

#elif defined(__i386__) || defined(__x86_64__)

# define ATOMIC_INIT(x) { x }

typedef struct { volatile int counter; } atomic_t;

static atomic_t m_lock = ATOMIC_INIT(1);

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

static inline bool
atomic_test(atomic_t* v)
{
	if (atomic_dec_and_test(v))
		return true;

	atomic_inc(v);
	return false;
}

template <int N>
void
Guard<N>::acquire()
{
	while (!atomic_dec_and_test(&m_lock))
	{
		atomic_inc(&m_lock);
		yield();
	}
}

template <int N>
void
Guard<N>::release()
{
	atomic_inc(&m_lock);
}

#elif defined(__MacOSX__)

#include <libkern/OSAtomic.h>

typedef struct { volatile int32_t counter; } atomic_t;

# define ATOMIC_INIT(x) { x }

static atomic_t m_lock = ATOMIC_INIT(1);

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

static inline bool
atomic_test(atomic_t* v)
{
	if (atomic_dec_and_test(v))
		return true;

	atomic_inc(v);
	return false;
}

static inline int
atomic_cmpxchg(atomic_t* v, int oldval, int newval)
{
	return OSAtomicCompareAndSwapIntBarrier(oldval, newval, &v->counter);
}

template <int N>
void
Guard<N>::acquire()
{
	while (!atomic_dec_and_test(&m_lock))
	{
		atomic_inc(&m_lock);
		yield();
	}
}

template <int N>
void
Guard<N>::release()
{
	atomic_inc(&m_lock);
}

#elif defined (__unix__)

// This is the fallback implementation.

pthread_mutex_t m_lock = PTHREAD_MUTEX_INITIALIZER;

template <int N>
void
Guard<N>::acquire()
{
	if (pthread_mutex_lock(&m_lock) != 0)
		M_RAISE("pthread_mutex_lock() failed");
}

template <int N>
void
Guard<N>::release()
{
	if (pthread_mutex_unlock(&m_lock) != 0)
	{
		// don't throw an exception, release() will be used in a destructor
		::fprintf(stderr, "pthread_mutex_unlock() failed\n");
	}
}

typedef int atomic_t;

# define ATOMIC_INIT(i)		(i)

# define atomic_set(v, i)	(*v = i)
# define atomic_read(v)		(*v)

static inline int
atomic_cmpxchg(atomic_t* v, int oldval, int newval)
{
	Guard<0> guard;

	if (*v != oldval)
		return *v;

	*v = newval;
	return oldval;
}

inline static bool
atomic_test(atomic_t* v)
{
	Guard<0> guard;
	return *v == 1;
}

#else

# error "Unsupported platform"

#endif

// End of Mutex /////////////////////////////////////////////////////////

#ifdef __WIN32__

static volatile LONG m_cancel = 1;


static unsigned
startRoutine(void* arg)
{
	startRoutine(static_cast<Arg*>(arg));
	InterlockedExchange(&m_cancel, 1);
	return 0;
}


static Id
createThread()
{
	M_ASSERT((&m_cancel & 0x1f) == 0);	// must be aligned to 32-bit boundary

	m_cancel = 0;	// we do not need a memory barrier

	Id id = CreateThread(0, 0, startRoutine, &m_runnable, 0, 0);

	if (id == 0)
		M_RAISE("CreateThread() failed");

	return id;
}


static void
cancelThread(Id id)
{
	if (InterlockedCompareExchange(&m_cancel, 0, 1) != 0)
		return false;

	WaitForSingleObject(id, INFINITE);
	CloseHandle(id);

	return true;
}


void
sys::thread::yield()
{
	Yield();
}

#elif defined(__unix__) || defined(__MacOSX__)

static atomic_t m_cancel = ATOMIC_INIT(1);


static void*
startRoutine(void* arg)
{
	startRoutine(static_cast<Runnable*>(arg));
	atomic_cmpxchg(&m_cancel, 0, 1);
	return 0;
}


static Id
createThread()
{
	pthread_attr_t attr;
	pthread_t id;

	if (pthread_attr_init(&attr) != 0)
		M_RAISE("pthread_attr_init() failed");

	atomic_set(&m_cancel, 0);	// we do not need a memory barrier

#if !defined(__hpux) // requires root privilege under HPUX 11.x
	pthread_attr_setinheritsched(&attr, PTHREAD_EXPLICIT_SCHED);
#endif

	pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);

	int rc = pthread_create(&id, &attr, startRoutine, &m_runnable);
	pthread_attr_destroy(&attr);

	if (rc != 0)
		M_RAISE("pthread_create() failed");

	return id;
}


static bool
cancelThread(Id id)
{
	if (atomic_cmpxchg(&m_cancel, 0, 1) != 0)
		return false;

	pthread_join(id, 0);
	return true;
}


void
sys::thread::yield()
{
	sched_yield();
}

#else

# error "Unsupported platform"

#endif

#include <stdlib.h>

#ifndef NDEBUG
static bool noThreads = getenv("SCIDB_NO_THREADS") != 0;
#endif


void
sys::thread::start(Runnable runnable)
{
#ifndef NDEBUG

	if (::noThreads)
		return runnable();

#endif

	Guard<0> guard;	// really neccessary?
	cancelThread(m_id);
	m_runnable = runnable;
	m_id = createThread();
}


bool
sys::thread::stop()
{
#ifndef NDEBUG

	if (::noThreads)
		return true;

#endif

	Guard<0> guard;
	return cancelThread(m_id);
}


bool
sys::thread::testCancel()
{
#ifndef NDEBUG

	if (::noThreads)
		return false;

#endif

#if 0

 	return atomic_test(&m_cancel);

#else

	// we do not need synchronization here
	return atomic_read(&m_cancel);

#endif
}

// vi:set ts=3 sw=3:
