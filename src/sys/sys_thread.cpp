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
#include "sys_info.h"
#include "sys_base.h"

#include "m_assert.h"
#include "m_stdio.h"
#include "m_exception.h"
#include "m_map.h"

#include <tcl.h>

#include <stdlib.h>

#ifndef __WIN32__
# include <time.h>
#endif

using namespace sys;

typedef Thread::atomic_t atomic_t;
typedef Thread::lock_t lock_t;

static int isSMP = -1;


struct Guard
{
	void acquire();
	void release();

	Guard(lock_t& lock) :m_lock(lock) { acquire(); }
	~Guard() { release(); }

	static void initLock(lock_t& lock);
	static void destroy(lock_t& lock);

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


#ifdef  __WIN32__

static void sleep() { Sleep(1); }

#else

static void
sleep()
{
	// Linux will busy loop for delays < 2ms on real time tasks
	struct ::timespec tm;
	tm.tv_sec = 0;
	tm.tv_nsec = 2000000L + 1;
	::nanosleep(&tm, NULL);
}

#endif


#ifdef  __WIN32__
static void yield() { Yield(); } // use Sleep(0) instead?
#else
static void yield() { sched_yield(); }
#endif


#if defined(__i386__) || defined(__x86_64__)
static void pausing() { __asm__ __volatile__("pause"); }
#else
static void pausing() { yield(); }
#endif


static void
spin(unsigned& k)
{
	if (!::isSMP)
		yield();
	else if (++k < 4)
		; // spin
	else if (k < 16)
		pausing();
	else if (k < 32)
		yield();
	else
		sleep();
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

# define atomic_read(v)				(*v)
# define atomic_set(v, i)			(*v = i)
# define atomic_cmpxchg(v, c, i)	InterlockedCompareExchange(v, c, i);

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
	unsigned k = 0;

	while (__sync_fetch_and_add(&m_lock, 1) > 0)
	{
		__sync_sub_and_fetch(&m_lock, 1);
		spin(k);
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


void
Guard::destroy(lock_t& lock)
{
}

#elif defined( __WIN32__) ///////////////////////////////////////////////////////////

void
Guard::acquire()
{
	unsigned k = 0;

	while (InterlockedIncrement(&m_lock) > 1)
	{
		InterlockedDecrement(&m_lock);
		spin(k);
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


void
Guard::destroy(lock_t& lock)
{
}

#elif defined(__i386__) || defined(__x86_64__) || defined(__MacOSX__) ///////////////

void
Guard::acquire()
{
	unsigned k = 0;

	while (!atomic_dec_and_test(&m_lock))
	{
		atomic_inc(&m_lock);
		spin(k);
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


void
Guard::destroy(lock_t& lock)
{
}

#elif defined (__unix__) ////////////////////////////////////////////////////////////

// This is the fallback implementation.

void
Guard::acquire()
{
	if (pthread_spin_lock(&m_lock) != 0)
		M_RAISE("pthread_spin_lock() failed");
}


void
Guard::release()
{
	if (pthread_spin_unlock(&m_lock) != 0)
	{
		// don't throw an exception, release() will be used in a destructor
		::fprintf(stderr, "pthread_spin_unlock() failed\n");
	}
}


void
Guard::initLock(lock_t& lock)
{
	pthread_spin_init(&lock, 0);
}


void
Guard::destroy(lock_t& lock)
{
	pthread_spin_destroy(&lock);
}

#else ///////////////////////////////////////////////////////////////////////////////

# error "Unsupported platform"

#endif //////////////////////////////////////////////////////////////////////////////

#ifdef __WIN32__

# include <winsock2.h>
# include <windows.h>
# include <io.h>

static int
socketpair(SOCKET socks[2])
{
	union
	{
		struct sockaddr_in inaddr;
		struct sockaddr addr;
	}
	addr;

	SOCKET listener = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);

	if (listener == INVALID_SOCKET) 
		return SOCKET_ERROR;

	memset(&addr, 0, sizeof(addr));
	addr.inaddr.sin_family = AF_INET;
	addr.inaddr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
	addr.inaddr.sin_port = 0; 

	socks[0] = socks[1] = INVALID_SOCKET;

	int reuse = 1;
	socklen_t addrlen = sizeof(a.inaddr);

	if (setsockopt(listener,
						SOL_SOCKET,
						SO_REUSEADDR,
						reinterpret_cast<char*>(&reuse),
						sizeof(reuse)) == 0)
	{
		if (	bind(listener, &addr.addr, sizeof(addr.inaddr)) != SOCKET_ERROR
			&& getsockname(listener, &addr.addr, &addrlen) != SOCKET_ERROR
			&& listen(listener, 1) != SOCKET_ERROR)
		{
			if (	(socks[0] = WSASocket(AF_INET, SOCK_STREAM, 0, 0, 0, 0) != INVALID_SOCKET)
				&& connect(socks[0], &addr.addr, sizeof(addr.inaddr)) != SOCKET_ERROR
				&& (socks[1] = accept(listener, 0, 0)) != INVALID_SOCKET)
			{
				closesocket(listener);
				return 0;
			}
		}
	}

	int err = WSAGetLastError();

	closesocket(listener);
	closesocket(socks[0]);
	closesocket(socks[1]);

	WSASetLastError(err);
	return SOCKET_ERROR;
}

#else

# include <unistd.h>
# include <sys/socket.h>

# define SOCKET int

#endif


namespace {

union Serialize
{
	typedef Thread::ThreadId ThreadId;
	Serialize() :id(0) {}
	Serialize(ThreadId threadId) :id(threadId) {}
	char str[sizeof(ThreadId)];
	ThreadId id;
};

} // namespace


struct Thread::Synchonize
{
	Synchonize()
		:m_chan(0)
	{
		Guard::initLock(m_lock);

		if (::socketpair(PF_UNIX, SOCK_STREAM, 0, m_fd) != 0)
			M_RAISE("cannot create sockets");

		m_chan = Tcl_MakeFileChannel(reinterpret_cast<ClientData>(m_fd[0]), TCL_READABLE);

		Tcl_CreateChannelHandler(m_chan, TCL_READABLE, sendSignal, this);
		Tcl_RegisterChannel(tcl::interp(), m_chan);
		Tcl_SetChannelOption(0, m_chan, "-blocking", "yes");
		Tcl_SetChannelOption(0, m_chan, "-encoding", "binary");
		Tcl_SetChannelOption(0, m_chan, "-translation", "binary binary");
	}

	~Synchonize()
	{
		Guard::destroy(m_lock);
		Tcl_DeleteChannelHandler(m_chan, sendSignal, this);
		Tcl_UnregisterChannel(::sys::tcl::interp(), m_chan);
	}

	void addThread(Thread* thread)
	{
		M_ASSERT(thread);
		M_ASSERT(Thread::insideMainThread());
		M_ASSERT(!thread->isMainThread());

		m_map[thread->threadId()] = thread;
	}

	void eraseThread(Thread* thread)
	{
		M_ASSERT(thread);
		M_ASSERT(Thread::insideMainThread());
		M_ASSERT(!thread->isMainThread());

		Map::iterator i = m_map.find(thread->threadId());
		if (i != m_map.end())
			m_map.erase(i);
	}

	void signal(ThreadId threadId, int signal)
	{
		M_ASSERT(!Thread::insideMainThread());

		Guard guard(m_lock);

		if (::write(m_fd[1], ::Serialize(threadId).str, sizeof(::Serialize)))
			; // avoid warning of unused result
		if (::write(m_fd[1], reinterpret_cast<char*>(&signal), sizeof(int)))
			; // avoid warning of unused result
	}

	static void
	sendSignal(ClientData data, int)
	{
		M_ASSERT(Thread::insideMainThread());

		Synchonize* sync = static_cast<Synchonize*>(data);

		Serialize serialize;
		int signal;

		Tcl_Read(sync->m_chan, serialize.str, sizeof(serialize));
		Tcl_Read(sync->m_chan, reinterpret_cast<char*>(&signal), sizeof(int));

		sync->m_map[serialize.id]->sendSignal(signal);
	}

	typedef mstl::map<ThreadId,Thread*> Map;

	Thread::lock_t	m_lock;
	Tcl_Channel		m_chan;
	Map				m_map;
	SOCKET			m_fd[2];
};


Thread::Synchonize* Thread::m_synchronize = 0;

#ifdef __WIN32__ ////////////////////////////////////////////////////////////////////

Thread m_mainThread(GetCurrentThreadId());

bool Thread::insideMainThread() { return GetCurrentThreadId() == m_mainThread.threadId(); }


unsigned
Thread::startThread(void* arg)
{
	startRoutine(static_cast<Thread*>(arg)->m_runnable, static_cast<Thread*>(arg)->m_exception);
	static_cast<Thread*>(arg)->finishThread();
	return 0;
}


bool
Thread::createThread()
{
	M_ASSERT((&m_cancel & 0x1f) == 0);	// must be aligned to 32-bit boundary
	return (m_threadId = CreateThread(0, 0, &startThread, this, 0, 0)) != 0;
}


void
Thread::joinThread()
{
	WaitForSingleObject(m_threadId, INFINITE);
	CloseHandle(m_threadId);
}


void
Thread::doSleep()
{
	InitializeConditionVariable(&m_condition);
	InitializeCriticalSection(&&m_condMutex);
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
	static_cast<Thread*>(arg)->finishThread();
	return 0;
}


bool
Thread::createThread()
{
	pthread_attr_t attr;

	if (pthread_attr_init(&attr) != 0)
		M_RAISE("pthread_attr_init() failed");

#if !defined(__hpux) // requires root privilege under HPUX 11.x
	pthread_attr_setinheritsched(&attr, PTHREAD_EXPLICIT_SCHED);
#endif

	int rc = pthread_create(&m_threadId, &attr, &startThread, this);
	pthread_attr_destroy(&attr);
	return rc == 0;
}


void
Thread::joinThread()
{
	pthread_join(m_threadId, 0);
}


void
Thread::doSleep()
{
	pthread_cond_init(&m_condition, 0);
	pthread_mutex_init(&m_condMutex, 0);
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


void
Thread::initialize()
{
	if (::isSMP == -1)
		::isSMP = info::numberOfProcessors() > 1;
}


Thread::Thread(ThreadId threadId)
	:m_threadId(threadId)
	,m_exception(0)
	,m_wakeUp(false)
{
	initialize();
}


Thread::Thread()
	:m_exception(0)
	,m_wakeUp(false)
{
	initialize();

	Guard::initLock(m_lock);
	atomic_set(&m_cancel, 1);
	atomic_set(&m_running, 0);
}


Thread::~Thread()
{
	if (!isMainThread())
	{
		Guard guard(m_lock);	// really neccessary?
		cancelThread();
	}

	Guard::destroy(m_lock);
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
Thread::doStart(Runnable runnable)
{
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

	// we do not need a memory barrier
	atomic_set(&m_cancel, 0);
	atomic_set(&m_running, 1);

	bool rc = createThread();

	if (!rc)
	{
		atomic_set(&m_cancel, 1);
		atomic_set(&m_running, 0);
	}

	return rc;
}


bool
Thread::start(Runnable runnable)
{
	M_REQUIRE(this != mainThread());

	m_signal = Signal();
	return doStart(runnable);
}


bool
Thread::start(Runnable runnable, Signal signal)
{
	M_REQUIRE(this != mainThread());

	if (m_synchronize == 0)
		m_synchronize = new Synchonize;

	m_signal = signal;
	m_synchronize->addThread(this);

	return doStart(runnable);
}


void
Thread::finishThread()
{
	if (m_signal)
		m_synchronize->signal(m_threadId, -1);
}


bool
Thread::cancelThread()
{
	if (atomic_cmpxchg(&m_running, 1, 0) == 0)
		return false;

	atomic_set(&m_cancel, 1);
	joinThread();

	if (m_synchronize)
		m_synchronize->eraseThread(this);

	return true;
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


void
Thread::join()
{
	cancelThread();
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


bool
Thread::testRunning()
{
	M_REQUIRE(this != mainThread());

#ifndef NDEBUG
	if (::m_noThreads)
		return false;
#endif

	// we do not need synchronization here
	return atomic_read(&m_running);
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


void
Thread::sendSignal(int signal)
{
	m_signal(signal);
}

// vi:set ts=3 sw=3:
