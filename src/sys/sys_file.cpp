// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2009-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "sys_file.h"
#include "sys_base.h"

#include "m_utility.h"
#include "m_assert.h"

#include <tcl.h>
#include <time.h>

#include <sys/stat.h>
#include <sys/types.h>
#include <string.h>

#ifdef __WIN32__
# define stat	_stat
# define chmod	_chmod
#endif

#if !TCL_PREREQ(8,5)
# error  "unsupported TCL version"
#endif


using namespace sys::file;


mstl::string
sys::file::internalName(char const* externalName)
{
	M_REQUIRE(externalName);

	mstl::string result;

	Tcl_Obj* pathObj = Tcl_NewStringObj(externalName, -1);

	if (pathObj)
	{
		Tcl_IncrRefCount(pathObj);
		// Tcl version 8.6 is returning "void const*".
		// Tcl version 8.5 is returning "char const*".
		result.assign(static_cast<char const*>(Tcl_FSGetNativePath(pathObj)));
		Tcl_DecrRefCount(pathObj);
	}
	else
	{
		result.assign(externalName);
	}

	return result;
}


mstl::string
sys::file::normalizedName(char const* externalName)
{
	M_REQUIRE(externalName);

	mstl::string result(externalName);

	Tcl_Obj* pathObj = Tcl_NewStringObj(externalName, -1);

	if (pathObj)
	{
		Tcl_IncrRefCount(pathObj);

		if (Tcl_Obj* resultObj = Tcl_FSGetNormalizedPath(::tcl::interp(), pathObj))
			result.assign(Tcl_GetString(resultObj));

		Tcl_DecrRefCount(pathObj);
	}

	return result;
}


bool
sys::file::access(char const* filename, Mode mode)
{
	M_REQUIRE(filename);
	return Tcl_Access(filename, mode) == 0;
}


long
sys::file::size(char const* filename)
{
	M_REQUIRE(filename);

	Tcl_StatBuf*	buf		= Tcl_AllocStatBuf();
	Tcl_Obj*			pathObj	= Tcl_NewStringObj(filename, -1);
	long				size		= -1;

	Tcl_IncrRefCount(pathObj);
	int ret = Tcl_FSStat(pathObj, buf);
	Tcl_DecrRefCount(pathObj);

	if (ret != -1)
	{
#if !TCL_PREREQ(8,6)
		size = buf->st_size;
#else
		size = long(Tcl_GetSizeFromStat(buf));
#endif
	}

	::ckfree(reinterpret_cast<char*>(buf));
	return size;
}


bool
sys::file::changed(char const* filename, uint32_t& time)
{
	M_REQUIRE(filename);

	Tcl_StatBuf*	buf		= Tcl_AllocStatBuf();
	Tcl_Obj*			pathObj	= Tcl_NewStringObj(filename, -1);

	Tcl_IncrRefCount(pathObj);
	int ret = Tcl_FSStat(pathObj, buf);
	Tcl_DecrRefCount(pathObj);

	if (ret != -1)
	{
#if !TCL_PREREQ(8,6)
		time = buf->st_ctime;
#else
		time = Tcl_GetChangeTimeFromStat(buf);
#endif
	}

	::ckfree(reinterpret_cast<char*>(buf));
	return ret != -1;
}


#ifdef __WIN32__

# include <windows.h>


Mapping::Mapping(char const* filename, Mode mode)
	:m_address(0)
	,m_size(0)
	,m_capacity(0)
	,m_writeable(mode & Writeable)
	,m_file(INVALID_HANDLE_VAlUE)
	,m_mapping(INVALID_HANDLE_VAlUE)
{
	M_REQUIRE(filename);
	M_REQUIRE(!(mode & Executable));
	M_REQUIRE(mode & (Readable | Writeable));

	m_file = CreateFileA(
						filename,
						(mode & Writeable ? GENERIC_WRITE : 0) | (mode & Readable ? GENERIC_READ : 0),
						0,
						0,
						OPEN_EXISTING,
						FILE_ATTRIBUTE_NORMAL | FILE_FLAG_RANDOM_ACCESS,
						0);

	if (m_file == INVALID_HANDLE_VAlUE)
		return;

	m_mapping = CreateFileMappingA(
							m_file,
							0,
							PAGE_READONLY,
							0,
							0,
							filename);

	if (m_mapping == INVALID_HANDLE_VAlUE)
	{
		CloseHandle(m_file);
		return;
	}

	m_address = MapViewOfFile(
						m_mapping,
						(mode & Writeable ? FILE_MAP_WRITE : 0) | (mode & Readable ? FILE_MAP_READ : 0),
						0,
						0,
						0);

	m_capacity = m_size = GetFileSize(m_file, 0);
}


Mapping::~Mapping()
{
	flush();

	if (m_address)
		UnmapViewOfFile(m_address);

	CloseHandle(m_mapping);

	if (m_size != m_capacity)
	{
		SetFilePointer(m_file, m_size, 0, FILE_BEGIN);
		SetEndOfFile(m_file);
	}

	::CloseHandle(m_file);
}


void
Mapping::flush(unsigned size)
{
	if (m_address && m_writeable)
		FlushViewOfFile(m_address, mstl::min(m_size, size));
}


void
Mapping::resize(unsigned newSize)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(isWriteable());

	if (newSize < m_capacity)
	{
		m_size = newSize;
	}
	else if (newSize > m_capacity)
	{
		UnmapViewOfFile(m_address);
		CloseHandle(m_file);
		m_file = CreateFileMapping(m_file, 0, PAGE_READWRITE, 0, newSize, 0);
		m_address = MapViewOfFile(m_file, FILE_MAP_WRITE, 0, 0, 0);
		m_capacity = m_size = newSize;
	}
}


bool
sys::file::setModificationTime(char const* filename, uint32_t time)
{
	M_REQUIRE(filename);

	struct ::_utimbuf ubuf;
	struct ::_stat st;

	if (::_stat(filename, &st) == -1)
		return false;

	ubuf.actime = st.st_atime;
	ubuf.modtime = time;

	if (::_utime(filename, &ubuf) == -1)
		return false;

	return true;
}


bool
sys::file::dirIsEmpty(char const* dirname)
{
	M_REQUIRE(dirname);
	return ::PathIsDirectoryEmpty(dirname);
}

#else

# include <fcntl.h>
# include <unistd.h>
# include <errno.h>

# include <sys/mman.h>
# include <sys/types.h>
# include <utime.h>
# include <dirent.h>


Mapping::Mapping(char const* filename, Mode mode)
	:m_address(0)
	,m_size(0)
	,m_capacity(0)
	,m_writeable(mode & Writeable)
	,m_fd(-1)
{
	M_REQUIRE(filename);
	M_REQUIRE(!(mode & Executable));
	M_REQUIRE(mode & (Readable | Writeable));

	int flags = 0;

	if (mode & (Writeable | Readable))
		flags = O_RDWR;
	else if (!(mode & Writeable))
		flags = O_WRONLY;
	else
		flags = O_RDONLY;

	m_fd = ::open(internalName(filename), flags);

	if (m_fd == -1)
		return;

	struct ::stat st;
	if (::fstat(m_fd, &st) == -1)
	{
		::close(m_fd);
		m_fd = -1;
		return;
	}

	int length = st.st_size;

	flags = 0;
	if (flags & Readable)	flags |= PROT_READ;
	if (flags & Writeable)	flags |= PROT_WRITE;

	m_address = ::mmap(0, length, flags, MAP_PRIVATE, m_fd, 0);

	if (m_address == MAP_FAILED)
	{
		::close(m_fd);
		m_fd = -1;
		m_address = 0;
		return;
	}

	m_capacity = m_size = length;
}


Mapping::~Mapping()
{
	flush();

	if (m_address)
		::munmap(m_address, m_size);

	if (m_fd != -1)
	{
		if (m_size != m_capacity)
			::ftruncate(m_fd, m_size);

		::close(m_fd);
	}
}


void
Mapping::flush(unsigned size)
{
	if (m_address)
		::msync(m_address, size ? mstl::min(size, m_size) : m_size, MS_SYNC);
}


void
Mapping::resize(unsigned newSize)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(isWriteable());

	if (newSize < m_size)
	{
		m_size = newSize;
	}
	else if (m_size < newSize)
	{
		::munmap(m_address, m_size);
		::ftruncate(m_fd, newSize);
		m_address = static_cast<char*>(::mmap(0, newSize, PROT_READ | PROT_WRITE, MAP_SHARED, m_fd, 0));

		if (m_address == MAP_FAILED)
		{
			m_address = 0;
			m_capacity = m_size = 0;
			::close(m_fd);
			m_fd = -1;
		}
		else
		{
			m_capacity = m_size = newSize;
		}
	}
}


bool
sys::file::lock(int fd)
{
	return ::lockf(fd, F_TLOCK, 0) != -1;
}


void
sys::file::unlock(int fd)
{
	::lockf(fd, F_ULOCK, 0);
}


bool
sys::file::setModificationTime(char const* filename, uint32_t time)
{
	M_REQUIRE(filename);

	struct ::utimbuf ubuf;
	struct ::stat st;

	if (::stat(internalName(filename), &st) == -1)
		return false;

	ubuf.actime = st.st_atime;
	ubuf.modtime = time;

	if (::utime(filename, &ubuf) == -1)
		return false;

	return true;
}


bool
sys::file::dirIsEmpty(char const* dirname)
{
	M_REQUIRE(dirname);

	DIR *dir = ::opendir(dirname);

	if (!dir)
		return 1;

	int n = 0;

	for ( ; readdir(dir) && n < 3; ++n)
		;

	closedir(dir);
	return n <= 2;
}

#endif


void
sys::file::rename(char const* oldFilename, char const* newFilename, bool preserveOldAttrs)
{
	M_REQUIRE(oldFilename);
	M_REQUIRE(newFilename);

	if (::strcmp(oldFilename, newFilename) == 0)
		return;

	struct stat st;

	if (preserveOldAttrs)
	{
		if (stat(oldFilename, &st) == -1)
			preserveOldAttrs = false;
	}

	Tcl_Obj* src(Tcl_NewStringObj(oldFilename, -1));
	Tcl_Obj* dst(Tcl_NewStringObj(newFilename, -1));

	Tcl_IncrRefCount(src);
	Tcl_IncrRefCount(dst);
	Tcl_FSRenameFile(src, dst);
	Tcl_DecrRefCount(dst);
	Tcl_DecrRefCount(src);

	if (preserveOldAttrs)
	{
#if defined(__WIN32__)
		st.st_mode &= _S_IREAD | _S_IWRITE;
#else
		st.st_mode &= 0x0fff;
#endif

		chmod(newFilename, st.st_mode);

#if defined(__unix__) || defined(__MacOSX__)
		chown(newFilename, st.st_uid, st.st_gid);
#endif
	}
}


sys::file::Type
sys::file::type(char const* filename)
{
	M_REQUIRE(filename);

	struct stat st;

	if (stat(internalName(filename), &st) == -1)
		return None;

	if (S_ISREG(st.st_mode))
		return RegularFile;
	if (S_ISDIR(st.st_mode))
		return Directory;
	if (S_ISCHR(st.st_mode))
		return CharacterDevice;
	if (S_ISBLK(st.st_mode))
		return BlockDevice;
	if (S_ISFIFO(st.st_mode))
		return NamedPipe;
#ifdef S_ISLNK
	if (S_ISLNK(st.st_mode))
		return SymbolicLink;
#endif
#ifdef S_ISSOCK
	if (S_ISSOCK(st.st_mode))
		return Socket;
#endif

	return Unknown;
}


bool
sys::file::isHardLinked(char const* filename1, char const* filename2)
{
	M_REQUIRE(filename1);
	M_REQUIRE(filename2);

	struct stat st1, st2;

	if (stat(internalName(filename1), &st1) == -1)
		return false;
	if (stat(internalName(filename2), &st2) == -1)
		return false;

	return st1.st_ino == st2.st_ino;
}


void
sys::file::deleteIt(char const* filename)
{
	M_REQUIRE(filename);

	Tcl_Obj* fn(Tcl_NewStringObj(filename, -1));

	Tcl_IncrRefCount(fn);
	Tcl_FSDeleteFile(fn);
	Tcl_DecrRefCount(fn);
}

// vi:set ts=3 sw=3:
