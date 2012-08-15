// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2012 Gregor Cramer
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
	{
	}

	bool operator==(FileAlterationMonitor const* fam) { return m_fam == fam; }

	void signalChanged(char const* filename) const;
	void signalDeleted(char const* filename) const;
	void signalCreated(char const* filename) const;

	static bool isSupported();

	FileAlterationMonitor* m_fam;
	unsigned m_states;
	Request* m_request;
};


struct Request
{
	typedef mstl::vector<Monitor> MonitorList;

	Request() :m_isDir(false), m_data(0) {}

	mstl::string	m_path;
	bool				m_isDir;
	void*				m_data;

	MonitorList m_monitorList;
};


void
Monitor::signalChanged(char const* filename) const
{
	if (m_request->m_isDir)
		m_fam->signalChanged(m_request->m_path + PathDelim + filename);
	else
		m_fam->signalChanged(m_request->m_path);
}


void
Monitor::signalDeleted(char const* filename) const
{
	if (m_request->m_isDir)
		m_fam->signalDeleted(m_request->m_path + PathDelim + filename);
	else
		m_fam->signalDeleted(m_request->m_path);
}


void
Monitor::signalCreated(char const* filename) const
{
	if (m_request->m_isDir)
		m_fam->signalCreated(m_request->m_path + PathDelim + filename);
	else
		m_fam->signalCreated(m_request->m_path);
}


bool
Monitor::isSupported()
{
#if defined(HAVE_INOTIFY) || defined(HAVE_LIBFAM)
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
							m.signalChanged(event.filename);
					}
					break;

				case FAMDeleted:
					for (unsigned i = 0; i < request->m_monitorList.size(); ++i)
					{
						Monitor const& m = request->m_monitorList[i];

						if (m.m_states & FileAlterationMonitor::StateDeleted)
							m.signalDeleted(event.filename);
					}
					break;

				case FAMCreated:
					for (unsigned i = 0; i < request->m_monitorList.size(); ++i)
					{
						Monitor const& m = request->m_monitorList[i];

						if (m.m_states & FileAlterationMonitor::StateCreated)
							m.signalCreated(event.filename);
					}
					break;
			}
		}
	}
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
	M_ASSERT(req.m_data == 0);
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

} // namespace

typedef mstl::hash<int,Request*> InotifyMap;

static int inotifyFD			= -1;
static int inotifyRefCount	= 0;

static InotifyMap inotifyMap;


static void
inotifyHandler(ClientData clientData, int)
{
	typedef struct inotify_event Event;

	M_ASSERT(inotifyFD != -1);

	while (1)
	{
		char eventBuf[sizeof(Event)];

		int nbytes = read(inotifyFD, eventBuf, sizeof(eventBuf));

		if (nbytes < int(sizeof(eventBuf)))
			return;

		Event*	event(reinterpret_cast<Event*>(&eventBuf));
		char*		eventBuf2(new char[sizeof(Event) + event->len]);

		memcpy(eventBuf2, eventBuf, sizeof(eventBuf));
		nbytes = read(inotifyFD, eventBuf2 + sizeof(eventBuf), event->len);

		if (nbytes != int(sizeof(eventBuf) + event->len))
		{
			Request* const* req = inotifyMap.find(event->wd);

			if (req)
			{
				Request::MonitorList const& mlist = (*req)->m_monitorList;

				for (unsigned i = 0; i < mlist.size(); ++i)
				{
					Monitor const& m = mlist[i];

					if (event->mask & (IN_IGNORED | IN_UNMOUNT))
					{
						m.m_fam->signalDeleted(event->name);
					}
					else if (event->mask & IN_ISDIR)
					{
						if (event->mask & (IN_DELETE_SELF | IN_MOVE_SELF))
							m.m_fam->signalDeleted(event->name);
						if (event->mask & (IN_ATTRIB | IN_CREATE | IN_DELETE | IN_MOVED_FROM | IN_MOVED_TO))
							m.m_fam->signalChanged(event->name);
						if (event->mask & IN_CREATE)
							m.m_fam->signalCreated(event->name);
					}
					else
					{
						if (event->mask & (IN_DELETE_SELF | IN_MOVE_SELF))
							m.m_fam->signalDeleted(event->name);
						if (event->mask & IN_ATTRIB)
							m.m_fam->signalChanged(event->name);
					}
				}
			}
		}

		delete eventBuf2;
	}
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
				case EINVAL:	error.assign("inotify_init1(): invalid value"); break;
				case EMFILE:	error.assign("inotify_init1(): user limit exceeded"); break;
				case ENFILE:	error.assign("inotify_init1(): system limit exceeded"); break;
				case ENOMEM:	error.assign("inotify_init1(): out of memory"); break;
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
	M_ASSERT(inotifyFD != -1);

	if (req.m_data)
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

#else //////////////////////////////////////////////////////////////////

static bool
initFAM(mstl::string& error)
{
	error.assign("dont't have any FAM service");
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
