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

#include "sys_vfs.h"

#include "m_string.h"


#if defined(__WIN32__)

int64_t
sys::vfs::freeSize(mstl::string const& path)
{
	int64_t availableForUser;
	int64_t total;
	int64_t free;

	BOOL result = GetDiskFreeSpaceExW(path, &availableForUser, &total, &free);

	return result ? availableForUser : int64_t(-1);
}

#elif defined(__unix__) || defined(__MacOSX__)

# if defined(HAVE_STATVFS)

#include <unistd.h>
#include <sys/statvfs.h>

int64_t
sys::vfs::freeSize(mstl::string const& path)
{
	struct ::statvfs vfs;

	if (::statvfs(path, &vfs) == -1)
		return -1;

	return vfs.f_bsize*(::geteuid() == 0 ? vfs.f_bfree : vfs.f_bavail);
}

# else

int64_t sys::vfs::freeSize(mstl::string const&) { return -1; }

# endif
#endif

// vi:se ts=3 sw=3:
