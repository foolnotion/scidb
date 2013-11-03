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

#include "sys_info.h"

#include "m_utility.h"

#if defined(__unix__)

# include <string.h>
# include <stdio.h>
# include <stdlib.h>
# include <unistd.h>
# include <sys/types.h>
# include <sys/sysctl.h>

#ifdef __hpux
# include <sys/pstat.h>
#endif


unsigned
sys::info::numberOfProcessors()
{
#if defined(_SC_NPROCESSORS_ONLN)

	return ::sysconf(_SC_NPROCESSORS_ONLN);

#elif defined(_SC_NPROC_ONLN) // IRIX

	return ::sysconf(_SC_NPROC_ONLN);

#elif defined (__hpux)

	struct ::pst_dynamic psd;
	if (::pstat_getdynamic(&psd, sizeof(psd), 1, 0) == -1)
		return 1;
	return psd.psd_proc_cnt;

#else

	int mib[2] = { CTL_HW, HW_AVAILCPU };

	uint32_t	numCPU	= 0;
	size_t	len		= sizeof(numCPU);

	if (::sysctl(mib, 2, &numCPU, &len, 0, 0) < 0 || numCPU < 1)
	{
		mib[1] = HW_NCPU;

		if (::sysctl(mib, 2, &numCPU, &len, 0, 0) < 0 || numCPU < 1)
			numCPU = 1;
	}

	return numCPU;

#endif
}


int64_t
readProcInfo(char const* attr)
{
	FILE* proc = ::fopen("/proc/meminfo", "r");

	if (proc == 0)
		return -1;

	char buf[1024];
	buf[0] = '\0';
	::fread(buf, 1, sizeof(buf), proc);

	char const* s = ::strstr(buf, attr);

	if (!s)
		return -1;

	s = ::strchr(s + 1, ' ');
	while (*s == ' ')
		++s;

	unsigned long value = ::strtoul(s, 0, 10);

	if (value == 0)
		return -1;

	return int64_t(value)*1024;
}


int64_t
sys::info::memFree()
{
	return ::readProcInfo("MemFree:");
}


int64_t
sys::info::memAvail()
{
	// TODO: probably use better MemFree + Buffers + Inactive

	int64_t free		= ::readProcInfo("MemFree:");
	int64_t cached		= ::readProcInfo("Cached:");
	int64_t buffers	= ::readProcInfo("Buffers:");

	if (free <= 0 || cached <= 0 || buffers <= 0)
		return -1;

	int64_t limit		= ::readProcInfo("CommitLimit:");

	if (limit <= 0)
		return free + cached + buffers;

	return mstl::min(limit, free + cached + buffers);
}


int64_t
sys::info::memTotal()
{
	long numPages = ::sysconf(_SC_PHYS_PAGES);
	long pageSize = ::sysconf(_SC_PAGE_SIZE);

	return int64_t(numPages)*int64_t(pageSize);
}

#elif defined(__WIN32__)

# include <windows.h>


unsigned
sys::info::numberOfProcessors()
{
	SYSTEM_INFO s;
	GetSystemInfo(&s);
	return s.dwNumberOfProcessors;
}


int64_t
sys::info::memFree()
{
	MEMORYSTATUSEX status;

	status.dwLength = sizeof(status);
	GlobalMemoryStatusEx(&status);
	return status.ullAvailPhys;
}


int64_t
sys::info::memAvail()
{
	// TODO
	return memFree();
}


int64_t
sys::info::memTotal()
{
	MEMORYSTATUSEX status;

	status.dwLength = sizeof(status);
	GlobalMemoryStatusEx(&status);
	return status.ullTotalPhys;
}

#elif defined(__MacOSX__)

# include <sys/types.h>
# include <sys/sysctl.h>

#include <mach/vm_statistics.h>
#include <mach/mach_types.h>
#include <mach/mach_init.h>
#include <mach/mach_host.h>


unsigned
sys::info::numberOfProcessors()
{
	int mib[2] = { CTL_HW, HW_AVAILCPU };

	uint32_t	numCPU	= 0;
	size_t	len		= sizeof(numCPU);

	if (::sysctl(mib, 2, &numCPU, &len, 0, 0) < 0 || numCPU < 1)
	{
		mib[1] = HW_NCPU;

		if (::sysctl(mib, 2, &numCPU, &len, 0, 0) < 0 || numCPU < 1)
			numCPU = 1;
	}

	return numCPU;
}


int64_t
sys::info::memFree()
{
	::vm_size_t		pageSize;
	::mach_port_t	machPort = mach_host_self();;

	::mach_msg_type_number_t	count		= sizeof(vmStats)/sizeof(natural_t);
	::vm_statistics_data_t	vmStats;

	if (	::host_page_size(machPort, &pageSize) != KERN_SUCCESS
		|| ::host_statistics(machPort, HOST_VM_INFO, host_info_t(&vmStats), &count) != KERN_SUCCESS)
	{
		return -1;
	}

	return int64_t(vmStats.free_count)*int64_t(pageSize);
}


int64_t
sys::info::memAvail()
{
	// TODO
	return memFree();
}


int64_t
sys::info::memTotal()
{
	int mib[2] = { CTL_HW, HW_MEMSIZE };

	unsigned	namelen	= sizeof(mib)/sizeof(mib[0]);
	size_t	len		= sizeof(size);
	uint64_t	size;

	if (::sysctl(mib, namelen, &size, &len, 0, 0) < 0)
		return -1;

	return size;
}

#endif


bool
sys::info::isWindows()
{
#if defined(WIN32) || defined(WIN64)
	return true;
#else
	return false;
#endif
}

// vi:set ts=3 sw=3:
