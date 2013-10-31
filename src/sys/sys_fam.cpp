// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2012-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "sys_fam.h"
#include "sys_file.h"

#include "m_hash.h"
#include "m_vector.h"
#include "m_exception.h"

#include <tcl.h>

#ifdef __linux__
# include <fcntl.h> // needed to test for F_NOTIFY
#endif

using namespace sys;


namespace {

#ifdef WIN32
# define PathDelim '\\'
#else
# define PathDelim '/'
#endif

struct Request;

struct Monitor
{
	Monitor(FileAlterationMonitor* fam, unsigned states, Request& request)
		:m_fam(fam)
		,m_states(states)
		,m_request(&request)
		,m_lastId(-1)
	{
	}

	bool operator==(FileAlterationMonitor const* fam) { return m_fam == fam; }

	void signalChanged(unsigned id, char const* filename) const;
	void signalDeleted(unsigned id, char const* filename) const;
	void signalCreated(unsigned id, char const* filename) const;
	void signalUnmounted(unsigned id, char const* filename) const;

	void checkId(int id) const;

	static bool isSupported();

	FileAlterationMonitor* m_fam;
	unsigned m_states;
	Request* m_request;
	mutable int m_lastId;
};


struct Request
{
	typedef mstl::vector<Monitor> MonitorList;

	Request() :m_isDir(false), m_data(0), m_id(0) {}

	mstl::string	m_path;
	bool				m_isDir;
	void*				m_data;
	int				m_id;

	MonitorList m_monitorList;
};


void
Monitor::checkId(int id) const
{
	if (m_lastId != id)
	{
		++m_request->m_id;
		m_lastId = id;
		m_fam->signalId(m_request->m_id, m_request->m_path);
	}
}


void
Monitor::signalChanged(unsigned id, char const* filename) const
{
	checkId(id);

	if (m_request->m_isDir && *filename)
		m_fam->signalChanged(m_request->m_id, m_request->m_path + PathDelim + filename);
	else
		m_fam->signalChanged(m_request->m_id, m_request->m_path);
}


void
Monitor::signalDeleted(unsigned id, char const* filename) const
{
	checkId(id);

	if (m_request->m_isDir && *filename)
		m_fam->signalDeleted(m_request->m_id, m_request->m_path + PathDelim + filename);
	else
		m_fam->signalDeleted(m_request->m_id, m_request->m_path);
}


void
Monitor::signalCreated(unsigned id, char const* filename) const
{
	checkId(id);

	if (m_request->m_isDir && *filename)
		m_fam->signalCreated(m_request->m_id, m_request->m_path + PathDelim + filename);
	else
		m_fam->signalCreated(m_request->m_id, m_request->m_path);
}


void
Monitor::signalUnmounted(unsigned id, char const* filename) const
{
	checkId(id);

	if (m_request->m_isDir && *filename)
		m_fam->signalUnmounted(m_request->m_id, m_request->m_path + PathDelim + filename);
	else
		m_fam->signalUnmounted(m_request->m_id, m_request->m_path);
}


bool
Monitor::isSupported()
{
#if defined(HAVE_INOTIFY) || defined(HAVE_LIBFAM) // || (defined(__linux__) && defined(F_NOTIFY))
	return true;
#else
	return false;
#endif
}

} // namespace


#if defined(WIN32) //////////////////////////////////////////////////////

# error "windows not yet implemented"

#elif defined(__MacOSX__) && !defined(HAVE_INOTIFY) /////////////////////

# error "Mac support not yet implemented"

#elif !defined(HAVE_INOTIFY) && defined(HAVE_LIBFAM) ////////////////////

// IMPORTANT NOTE: FAM should not be used because some FAM libraries are broken.

#include <fam.h>
#include <errno.h>

namespace {

struct LibfamRequest
{
	LibfamRequest() : m_ref(0) {}

	FAMRequest	m_req;
	unsigned		m_ref;
};

};

static FAMConnection		libfamConnect;
static FAMConnection*	libfamConnection	= &libfamConnect;
static unsigned			libfamRefCount	= 0;
static unsigned			libfamId = 0;


static void
libfamHandler(ClientData clientData, int)
{
	M_ASSERT(libfamConnection);

	while (FAMPending(libfamConnection))
	{
		FAMEvent event;

		if (FAMNextEvent(libfamConnection, &event) == 1)
		{
			Request const* request(static_cast<Request*>(event.userdata));

			switch (int(event.code))
			{
				case FAMChanged:
					for (unsigned i = 0; i < request->m_monitorList.size(); ++i)
					{
						Monitor const& m = request->m_monitorList[i];

						if (m.m_states & FileAlterationMonitor::StateChanged)
							m.signalChanged(libfamId, event.filename);
					}
					break;

				case FAMDeleted:
					for (unsigned i = 0; i < request->m_monitorList.size(); ++i)
					{
						Monitor const& m = request->m_monitorList[i];

						if (m.m_states & FileAlterationMonitor::StateDeleted)
							m.signalDeleted(libfamId, event.filename);
					}
					break;

				case FAMCreated:
					for (unsigned i = 0; i < request->m_monitorList.size(); ++i)
					{
						Monitor const& m = request->m_monitorList[i];

						if (m.m_states & FileAlterationMonitor::StateCreated)
							m.signalCreated(libfamId, event.filename);
					}
					break;
			}
		}
	}

	++libfamId;
}


static bool
initFAM(mstl::string& error)
{
	if (libfamRefCount == 0)
	{
		if (libfamConnection == 0 || FAMOpen(libfamConnection) == -1)
		{
			libfamConnection = 0;
			error.assign("cannot connect to famd");
			return false;
		}

		++libfamRefCount;
		Tcl_CreateFileHandler(libfamConnect.fd, TCL_READABLE, libfamHandler, 0);
	}

	return true;
}


static void
closeFAM()
{
	if (libfamConnection)
	{
		M_ASSERT(libfamRefCount > 0);

		if (--libfamRefCount == 0)
		{
			Tcl_DeleteFileHandler(libfamConnect.fd);
			FAMClose(libfamConnection);
		}
	}
}


static bool
monitorFAM(mstl::string const& path, Request& req, file::Type type, unsigned states, mstl::string&)
{
	M_ASSERT(libfamConnection);
	M_ASSERT(type == file::RegularFile || type == file::Directory);

	if (req.m_data == 0)
	{
		LibfamRequest* r = new LibfamRequest();

		req.m_data = r;

		switch (int(type))
		{
			case file::RegularFile:
				FAMMonitorFile(libfamConnection, path, &r->m_req, &req);
				break;

			case file::Directory:
				FAMMonitorDirectory(libfamConnection, path, &r->m_req, &req);
				break;
		}
	}

	++static_cast<LibfamRequest*>(req.m_data)->m_ref;
	return true;
}


static void
cancelMonitorFAM(Request& req)
{
	M_ASSERT(libfamConnection);

	if (req.m_data)
	{
		LibfamRequest*	request(static_cast<LibfamRequest*>(req.m_data));

		M_ASSERT(request->m_ref > 0);

		if (--request->m_ref == 0)
		{
			FAMCancelMonitor(libfamConnection, &request->m_req);
			delete request;
			req.m_data = 0;
		}
	}
}

#elif defined(HAVE_INOTIFY) /////////////////////////////////////////////

#include "m_hash.h"

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <sys/ioctl.h>

#ifdef SYS_INOTIFY
# include "sys_inotify.h"
#else
# include <sys/inotify.h>
#endif

namespace {

struct InotifyRequest
{
	InotifyRequest(int wd) :m_wd(wd), m_ref(0) {}

	int		m_wd;
	unsigned	m_ref;
};

union InotifyEvent
{
	InotifyEvent(char* buf) :p(buf) {}

	bool operator<(InotifyEvent const& ev) { return p < ev.p; }

	union
	{
		struct inotify_event* e;
		char* p;
	};

	InotifyEvent next() { return InotifyEvent(p + sizeof(struct inotify_event) + e->len); }
};

} // namespace

typedef mstl::hash<int,Request*> InotifyMap;

static int inotifyFD			= -1;
static int inotifyRefCount	= 0;
static int inotifyId			= 0;

static InotifyMap inotifyMap;


static void
inotifyHandler(ClientData clientData, int)
{
	M_ASSERT(inotifyFD != -1);

	int size = 0;

	if (ioctl(inotifyFD, FIONREAD, &size) == -1)
	{
		fprintf(stderr, "ioctl error(%d): %s\n", errno, strerror(errno));
		return;
	}

	char*	eventBuf	= new char[size];
	int	nbytes	= read(inotifyFD, eventBuf, size);

	if (nbytes == -1 && errno != EINVAL)
	{
		fprintf(stderr, "inotify error(%d): %s\n", errno, strerror(errno));
		return;
	}

	InotifyEvent event(eventBuf);
	InotifyEvent last(eventBuf + nbytes);

	while (event < last)
	{
		Request* const* req = inotifyMap.find(event.e->wd);

		if (req)
		{
			Request::MonitorList const& mlist = (*req)->m_monitorList;

			for (unsigned i = 0; i < mlist.size(); ++i)
			{
				if (!(event.e->mask & IN_IGNORED))
				{
					Monitor const& m = mlist[i];

					mstl::string path(event.e->name, event.e->len);

					if (event.e->mask & IN_UNMOUNT)
					{
						m.signalUnmounted(inotifyId, path);
					}
					else
					{
						if (event.e->mask & (IN_ISDIR & (IN_DELETE_SELF | IN_MOVE_SELF)))
							m.signalDeleted(inotifyId, path);

						if (event.e->mask & (IN_DELETE | IN_MOVED_TO))
							m.signalDeleted(inotifyId, path);
						if (event.e->mask & (IN_CREATE | IN_MOVED_FROM))
							m.signalCreated(inotifyId, path);
						if (event.e->mask & IN_ATTRIB)
							m.signalChanged(inotifyId, path);
					}
				}
			}
		}

		event = event.next();
	}

	delete [] eventBuf;
	++inotifyId;
}


static bool
initFAM(mstl::string& error)
{
	if (inotifyFD == -1)
	{
		inotifyFD = inotify_init1(IN_NONBLOCK);

		if (inotifyFD == -1)
		{
			switch (errno)
			{
				case EINVAL: error.assign("inotify_init1(): invalid value"); break;
				case EMFILE: error.assign("inotify_init1(): user limit exceeded"); break;
				case ENFILE: error.assign("inotify_init1(): system limit exceeded"); break;
				case ENOMEM: error.assign("inotify_init1(): out of memory"); break;
			}

			return false;
		}

		Tcl_CreateFileHandler(inotifyFD, TCL_READABLE, inotifyHandler, 0);
	}

	++inotifyRefCount;
	return true;
}


static void
closeFAM()
{
	if (inotifyFD != -1)
	{
		if (--inotifyRefCount == 0)
		{
			Tcl_DeleteFileHandler(inotifyFD);

			for (InotifyMap::const_iterator i = inotifyMap.begin(); i != inotifyMap.end(); ++i)
			{
				InotifyRequest* r = static_cast<InotifyRequest*>(i->second->m_data);
				inotify_rm_watch(inotifyFD, r->m_wd);
				delete r;
			}

			inotifyMap.clear();
			close(inotifyFD);
			inotifyFD = -1;
		}
	}
}


static bool
monitorFAM(mstl::string const& path, Request& req, file::Type type, unsigned states, mstl::string& error)
{
	M_ASSERT(inotifyFD != -1);

	if (req.m_data == 0)
	{
		unsigned mask = 0;

		switch (int(type))
		{
			case file::Directory:
				if (states & FileAlterationMonitor::StateChanged)
					mask |= IN_CREATE | IN_DELETE | IN_MODIFY | IN_MOVED_FROM | IN_MOVED_TO;
				if (states & FileAlterationMonitor::StateDeleted)
					mask |= IN_DELETE_SELF | IN_MOVE_SELF;
				if (states & FileAlterationMonitor::StateCreated)
					mask |= IN_CREATE;
				break;

			case file::RegularFile:
				if (states & FileAlterationMonitor::StateChanged)
					mask |= IN_ATTRIB | IN_MODIFY;
				if (states & FileAlterationMonitor::StateDeleted)
					mask |= IN_MOVE_SELF | IN_DELETE_SELF;
				break;
		}

		int wd = inotify_add_watch(inotifyFD, path, mask);

		if (wd == -1)
		{
			switch (errno)
			{
				case EACCES:	error.assign("notify_add_watch(): read access not permitted"); break;
				case EBADF:		error.assign("notify_add_watch(): file descriptor not valid"); break;
				case EFAULT:	error.assign("notify_add_watch(): corrupted memory"); break;
				case EINVAL:	error.assign("notify_add_watch(): invalid arguments"); break;
				case ENOENT:	error.assign("notify_add_watch(): path does not exists"); break;
				case ENOMEM:	error.assign("notify_add_watch(): out of memory"); break;
				case ENOSPC:	error.assign("notify_add_watch(): user limit exceeded"); break;
				default:			error.format("notify_add_watch(): unexpected error %d", errno); break;
			}

			return false;
		}

		req.m_data = new InotifyRequest(wd);
		inotifyMap.insert_unique(wd, &req);
	}

	++static_cast<InotifyRequest*>(req.m_data)->m_ref;
	return true;
}


static void
cancelMonitorFAM(Request& req)
{
	if (inotifyFD != -1 && req.m_data)
	{
		InotifyRequest* r = static_cast<InotifyRequest*>(req.m_data);

		M_ASSERT(r->m_ref > 0);

		if (--r->m_ref == 0)
		{
			inotifyMap.remove(r->m_wd);
			inotify_rm_watch(inotifyFD, r->m_wd);
			delete r;
			req.m_data = 0;
		}
	}
}

#elif defined(__linux__) && defined(F_NOTIFY) && 0 // XXX not yet working

#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <signal.h>
#include <sys/ioctl.h>

// the following are legal, implemented events that user-space can watch for
#define IN_ACCESS				0x00000001  // File was accessed
#define IN_MODIFY				0x00000002  // File was modified
#define IN_ATTRIB				0x00000004  // Metadata changed
#define IN_CLOSE_WRITE		0x00000008  // Writtable file was closed
#define IN_CLOSE_NOWRITE	0x00000010  // Unwrittable file closed
#define IN_OPEN				0x00000020  // File was opened
#define IN_MOVED_FROM		0x00000040  // File was moved from X
#define IN_MOVED_TO			0x00000080  // File was moved to Y
#define IN_CREATE				0x00000100  // Subfile was created
#define IN_DELETE				0x00000200  // Subfile was deleted
#define IN_DELETE_SELF		0x00000400  // Self was deleted
#define IN_MOVE_SELF			0x00000800  // Self was moved

// the following are legal events.  they are sent as needed to any watch
#define IN_UNMOUNT			0x00002000  // Backing fs was unmounted
#define IN_Q_OVERFLOW		0x00004000  // Event queued overflowed
#define IN_IGNORED			0x00008000  // File was ignored

// helper events
#define IN_CLOSE				(IN_CLOSE_WRITE | IN_CLOSE_NOWRITE) // close
#define IN_MOVE				(IN_MOVED_FROM | IN_MOVED_TO) // moves

// special flags
#define IN_ONLYDIR			0x01000000  // only watch the path if it is a directory
#define IN_DONT_FOLLOW		0x02000000  // don't follow a sym link
#define IN_MASK_ADD			0x20000000  // add to the mask of an already existing watch
#define IN_ISDIR				0x40000000  // event occurred against dir
#define IN_ONESHOT			0x80000000  // only send event once

namespace {

static int fcntlSignal = -1;

struct FcntlRequest
{
	FcntlRequest(int fd) :m_fd(fd), m_ref(1) {}

	int		m_fd;
	unsigned	m_ref;
};

struct inotify_event
{
   int		wd;					// watch descriptor
   uint32_t	mask;					// watch mask
   uint32_t	cookie;				// cookie to synchronize two events
   uint32_t	len;					// length (including nulls) of name
   char		name __flexarr;   // stub for possible name
};

union InotifyEvent
{
	InotifyEvent(char* buf) :p(buf) {}

	bool operator<=(InotifyEvent const& ev) { return p <= ev.p; }

	union
	{
		struct inotify_event* e;
		char* p;
	};

	InotifyEvent next() { return InotifyEvent(p + sizeof(struct inotify_event) + e->len); }
};

} // namespace

typedef mstl::hash<int,Request*> FcntlMap;

static FcntlMap fcntlMap;
static struct sigaction signalAction;
static unsigned signalRefCount = 0;
static unsigned signalId = 0;


static void
fcntlSignalHandler(int signum, siginfo_t* info, void*)
{
	int size = 0;

	// XXX not working, because info->si_fd is referring a directory.

	if (ioctl(info->si_fd, FIONREAD, &size) == -1)
	{
		fprintf(stderr, "ioctl error(%d): %s\n", errno, strerror(errno));
		return;
	}

	char*	eventBuf	= new char[size];
	int	nbytes	= read(info->si_fd, eventBuf, size);

	if (nbytes == -1 && errno != EINVAL)
	{
		fprintf(stderr, "inotify error(%d): %s\n", errno, strerror(errno));
		return;
	}

	InotifyEvent event(eventBuf);
	InotifyEvent last(eventBuf + nbytes);

	while (event.next() <= last)
	{
		Request* const* req = fcntlMap.find(event.e->wd);

		if (req)
		{
			Request::MonitorList const& mlist = (*req)->m_monitorList;

			for (unsigned i = 0; i < mlist.size(); ++i)
			{
				if (!(event.e->mask & IN_IGNORED))
				{
					Monitor const& m = mlist[i];

					mstl::string path(event.e->name, event.e->len);

					if (event.e->mask & IN_UNMOUNT)
					{
						m.signalUnmounted(inotifyId, path);
					}
					else
					{
						if (event.e->mask & (IN_ISDIR & (IN_DELETE_SELF | IN_MOVE_SELF)))
							m.signalDeleted(inotifyId, path);

						if (event.e->mask & (IN_DELETE | IN_MOVED_TO))
							m.signalDeleted(inotifyId, path);
						if (event.e->mask & (IN_CREATE | IN_MOVED_FROM))
							m.signalCreated(inotifyId, path);
						if (event.e->mask & IN_ATTRIB)
							m.signalChanged(inotifyId, path);
					}
				}
			}
		}

		event = event.next();
	}

	delete [] eventBuf;
	++signalId;
}


static bool
initFAM(mstl::string& error)
{
	if (fcntlSignal == -1)
	{
		fcntlSignal = SIGRTMIN + 4; // LinuxThreads is using the first three

		if (fcntlSignal > SIGRTMAX)
		{
			error.assign("no more real-time signals available");
			return false;
		}
	}

	if (signalRefCount++ == 0)
	{
		struct sigaction action;

		sigemptyset(&action.sa_mask);
		action.sa_sigaction = fcntlSignalHandler;
		action.sa_flags = SA_SIGINFO;
		action.sa_restorer = 0;

		sigaction(fcntlSignal, &action, &signalAction);
	}

	return true;
}


static void
closeFAM()
{
	M_ASSERT(signalRefCount > 0);

	if (--signalRefCount == 0)
	{
		for (FcntlMap::const_iterator i = fcntlMap.begin(); i != fcntlMap.end(); ++i)
		{
			FcntlRequest* r = static_cast<FcntlRequest*>(i->second->m_data);
			close(r->m_fd);
			delete r;
		}

		fcntlMap.clear();
		sigaction(fcntlSignal, &signalAction, 0);
	}
}


static bool
monitorFAM(mstl::string const& path, Request& req, file::Type type, unsigned states, mstl::string& error)
{
	if (type == file::RegularFile)
		return false;

	if (req.m_data == 0)
	{
		int fd = open(path, O_RDONLY | O_NONBLOCK);

		if (fd == -1)
		{
			switch (errno)
			{
				case EACCES:			error.assign("open(): read access not permitted"); break;
				case ELOOP:				error.assign("open(): cannot resolve symbolic link"); break;
				case EMFILE:			error.assign("open(): user limit exceeded"); break;
				case ENFILE:			error.assign("open(): system limit eceeded"); break;
				case ENAMETOOLONG:	error.assign("open(): path name too long"); break;
				case ENOENT:			error.assign("open(): path does not exists"); break;
				case ENOMEM:			error.assign("open(): out of memory"); break;
				case ENOTDIR:			error.assign("open(): invalid directory component"); break;
				case EOVERFLOW:		error.assign("open(): too large to be opened"); break;
				default:					error.format("open(): unexpected error %d", errno); break;
			}

			return false;
		}

		long events = DN_MULTISHOT;

		if (states & FileAlterationMonitor::StateChanged)
			events |= DN_MODIFY | DN_ATTRIB;
		if (states & FileAlterationMonitor::StateDeleted)
			events |= DN_DELETE | DN_CREATE | DN_RENAME;
		if (states & FileAlterationMonitor::StateCreated)
			events |= DN_CREATE;

		if (fcntl(fd, F_SETSIG, long(fcntlSignal)) == -1)
		{
			error.format("fcntl(F_SETSIG): unexpected error %d\n", errno);
			return false;
		}

		if (fcntl(fd, F_NOTIFY, events) == -1)
		{
			error.format("fcntl(F_NOTIFY): unexpected error %d\n", errno);
			return false;
		}

		req.m_data = new FcntlRequest(fd);
		fcntlMap.insert_unique(fd, &req);
	}

	return true;
}


static void
cancelMonitorFAM(Request& req)
{
	if (req.m_data)
	{
		FcntlRequest* r = static_cast<FcntlRequest*>(req.m_data);

		M_ASSERT(r->m_ref > 0);

		if (--r->m_ref == 0)
		{
			fcntlMap.remove(r->m_fd);
			close(r->m_fd);
			delete r;
			req.m_data = 0;
		}
	}
}

#else //////////////////////////////////////////////////////////////////

static bool
initFAM(mstl::string& error)
{
	error.assign("don't have any FAM service");
	return false;
}


static void closeFAM() {}


static bool
monitorFAM(mstl::string const&, Request&, file::Type, unsigned, mstl::string&)
{
	return false;
}


static void cancelMonitorFAM(Request& req) {}

#endif /////////////////////////////////////////////////////////////////

#include "m_algorithm.h"

namespace { typedef mstl::hash<mstl::string, Request> ReqMap; }

static ReqMap reqMap;


FileAlterationMonitor::FileAlterationMonitor()
{
	m_valid = ::initFAM(m_error);
};


FileAlterationMonitor::~FileAlterationMonitor() throw()
{
	if (!m_valid)
		return;

	mstl::vector<mstl::string const*> keyList;

	for (::ReqMap::const_iterator i = ::reqMap.begin(); i != ::reqMap.end(); ++i)
	{
		::Request& req = const_cast< ::Request&>(i->second);
		::Request::MonitorList& mlist = req.m_monitorList;

		::Request::MonitorList::reverse_iterator k = mlist.rbegin();
		::Request::MonitorList::reverse_iterator e = mlist.rend();

		for ( ; k != e; ++k)
		{
			if (k->m_fam == this)
			{
				::cancelMonitorFAM(req);
				mlist.erase(k);
			}
		}

		if (mlist.empty())
			keyList.push_back(&i->second.m_path);
	}

	for (unsigned i = 0; i < keyList.size(); ++i)
		::reqMap.remove(*keyList[i]);

	::closeFAM();
};


bool
FileAlterationMonitor::add(mstl::string const& path, unsigned states)
{
	M_REQUIRE(valid());

	if (states == 0)
		return true;

	file::Type type = file::type(path);

	if (type != file::RegularFile && type != file::Directory)
		return false;

	if (type == file::RegularFile && states == StateCreated)
		return false;

	Request& req = ::reqMap.find_or_insert(path, Request());

	if (mstl::find(req.m_monitorList.begin(), req.m_monitorList.end(), this) != req.m_monitorList.end())
		return true;

	if (!monitorFAM(path, req, type, states, m_error))
	{
		if (req.m_monitorList.empty())
			::reqMap.remove(path);

		return false;
	}

	req.m_monitorList.push_back(::Monitor(this, states, req));
	req.m_path.assign(path);
	req.m_isDir = (type == file::Directory);

	return true;
}


void
FileAlterationMonitor::remove(mstl::string const& path)
{
	M_REQUIRE(valid());

	Request* req = const_cast<Request*>(::reqMap.find(path));

	if (req)
	{
		::Request::MonitorList& mlist(req->m_monitorList);
		::Request::MonitorList::iterator i(mstl::find(mlist.begin(), mlist.end(), this));

		if (i != mlist.end())
		{
			::cancelMonitorFAM(*req);
			mlist.erase(i);

			if (mlist.empty())
				::reqMap.remove(path);
		}
	}
}


bool
FileAlterationMonitor::isSupported()
{
	return Monitor::isSupported();
}

// vi:set ts=3 sw=3:
