// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
//    _/|            __
//   // o\         /    )           ,        /    /
//   || ._)    ----\---------__----------__-/----/__-
//   //__\          \      /   '  /    /   /    /   )
//   )___(     _(____/____(___ __/____(___/____(___/_
// ======================================================================

// ======================================================================
// Copyright: (C) 2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _app_fam_service_included
#define _app_fam_service_included

namespace mstl { class string; }

namespace app {

class FAMService
{
public:

	struct Callback
	{
		virtual ~Callback() = 0;

		virtual void signalId(unsigned id, mstl::string const& path);

		virtual void signalChanged(unsigned id, mstl::string const& path);
		virtual void signalDeleted(unsigned id, mstl::string const& path);
		virtual void signalCreated(unsigned id, mstl::string const& path);
	};

	void hook(mstl::string const& path, Callback& callback);
	void unhook(mstl::string const& path);

private:

	class FileAlterationMonitor;

	static FileAlterationMonitor* m_fam;
};

} // namespace app

#endif // _app_fam_service_included

// vi:set ts=3 sw=3:
