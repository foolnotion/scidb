// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2009-2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "u_zstream.h"
#include "u_misc.h"

#include "m_ifstream.h"
#include "m_stdio.h"
#include "m_assert.h"

#include <zzip/zzip.h>
#include <zlib.h>
#include <zip.h>

#include <string.h>

#ifndef MAX
# define MAX(a,b) ((a) < (b) ? b : a)
#endif

using namespace util;


#define ZFILE	static_cast<ZStream::Handle*>(cookie)->file
#define ZDIR	static_cast<ZStream::Handle*>(cookie)->dir
#define HANDLE	static_cast<ZStream::Handle*>(cookie)->handle

#define IS_READABLE	(static_cast<ZStream::Handle*>(cookie)->mode & mstl::ios_base::in)
#define IS_WRITEABLE	(static_cast<ZStream::Handle*>(cookie)->mode & mstl::ios_base::out)


static unsigned char const gzipMagic[2] = { '\037', '\213' };
static unsigned char const zzipMagic[4] = { 'P', 'K', '\003', '\004' };

static double const DecompressionFactor = 3.365;


namespace zstream {

static bool
zzipMatch(ZStream::Strings const& suffixes, char const* name)
{
	if (suffixes.empty())
		return true;

	unsigned len = strlen(name);

	for (unsigned i = 0; i < suffixes.size(); ++i)
	{
		unsigned n = suffixes[i].size();

		if (n < len && strncasecmp(name + len - n, suffixes[i], n) == 0)
			return true;
	}

	return false;
}


static struct zzip_file*
zzipFileOpen(void* cookie)
{
	ZZIP_DIRENT entry;

	while (true)
	{
		if (!zzip_dir_read(ZDIR, &entry))
			return 0;

		M_ASSERT(static_cast<ZStream::Handle*>(cookie)->suffixes);

		if (zzipMatch(*static_cast<ZStream::Handle*>(cookie)->suffixes, entry.d_name))
			return ::zzip_file_open(ZDIR, entry.d_name, 0);
	}

	return 0;	// satisfies the compiler
}


static __ssize_t
zzipRead(void* cookie, char* buf, size_t len)
{
	M_ASSERT(IS_READABLE);

	long n = ZFILE ? zzip_file_read(ZFILE, buf, len) : 0;

	while (n <= 0)
	{
		if (ZFILE)
			::zzip_fclose(ZFILE);

		if (!(ZFILE = zzipFileOpen(cookie)))
			return 0;

		n = ::zzip_file_read(ZFILE, buf, len);
	}

	return n;
}


static int
zzipSeek(void* cookie, __off64_t* pos, int whence)
{
	M_ASSERT(IS_READABLE);

	*pos = ::zzip_seek(ZFILE, *pos, whence);
	return *pos < 0 ? -1 : 0;
}


static int
zzipClose(void* cookie)
{
	M_ASSERT(ZDIR);

	if (ZFILE)
	{
		::zzip_fclose(ZFILE);
		ZFILE = 0;
	}

	::zzip_dir_close(ZDIR);
	ZDIR = 0;

	return 0;
}


static __ssize_t
zzipWrite(void*, char const*, size_t)
{
	M_RAISE("unexpected call of zzipWrite()");
	return 0;
}


static int64_t
zzipSize(ZStream::Strings const& suffixes, ZZIP_DIR* dir)
{
	ZZIP_DIRENT entry;
	int64_t		size	= 0;
	unsigned		count	= 0;

	while (::zzip_dir_read(dir, &entry))
	{
		if (zzipMatch(suffixes, entry.d_name))
		{
			size += entry.st_size;
			++count;
		}
	}

	::zzip_rewinddir(dir);

	return count ? size : int64_t(-1);
}


static bool
zzipFind(ZZIP_DIR* dir, mstl::string const& name)
{
	ZZIP_DIRENT entry;

	while (::zzip_dir_read(dir, &entry))
	{
		if (name == entry.d_name)
		{
			::zzip_rewinddir(dir);
			return true;
		}
	}

	::zzip_rewinddir(dir);
	return false;
}


bool
zipOpenNewFileInZip(void* cookie, char const* filename, mstl::ios_base::openmode mode)
{
	mstl::string basename(::util::misc::file::rootname(::util::misc::file::basename(filename)));
	mstl::string fname(basename);

	mstl::string const& suffix = ZStream::zipFileSuffixes().empty()
											? mstl::string::empty_string
											: ZStream::zipFileSuffixes().front();

	fname += suffix;

	if (mode & mstl::ios_base::app)
	{
		ZZIP_DIR* dir = ::zzip_dir_open(filename, 0);

		if (dir)
		{
			unsigned count = 2;

			while (zzipFind(dir, fname))
			{
				char buf[100];
				sprintf(buf, "-%d", count++);
				fname = basename;
				fname += buf;
				fname += suffix;
			}

			::zzip_dir_close(dir);
		}
	}

	::zip_fileinfo info;
	info.dosDate = 0;
	util::misc::time::tm tm;
	getCurrentTime(tm);
	info.tmz_date.tm_sec  = tm.sec;
	info.tmz_date.tm_min  = tm.min;
	info.tmz_date.tm_hour = tm.hour;
	info.tmz_date.tm_mday = tm.mday;
	info.tmz_date.tm_mon  = tm.mon;
	info.tmz_date.tm_year = tm.year;

	int rc = ::zipOpenNewFileInZip(	HANDLE,
												fname,
												&info,
												0, 0, 0, 0, 0,
												Z_DEFLATED,
												Z_DEFAULT_COMPRESSION);

	return rc == ZIP_OK;
}


static __ssize_t
zipRead(void*, char*, size_t)
{
	M_RAISE("unexpected call of zipRead()");
	return 0;
}


static int
zipSeek(void*, __off64_t*, int)
{
	M_RAISE("unexpected call of zipSeek()");
	return 0;
}


static int
zipClose(void* cookie)
{
	M_ASSERT(HANDLE);

	::zipCloseFileInZip(HANDLE);
	int rc = ::zipClose(HANDLE, 0) == ZIP_OK ? 0 : -1;
	HANDLE = 0;
	return rc;
}


static __ssize_t
zipWrite(void* cookie, char const* buf, size_t len)
{
	M_ASSERT(IS_WRITEABLE);
	return ::zipWriteInFileInZip(HANDLE, buf, len) == ZIP_OK ? len : 0;
}


static __ssize_t
gzipRead(void* cookie, char* buf, size_t len)
{
	M_ASSERT(IS_READABLE);

	int bytesRead = ::gzread(HANDLE, buf, len);
	return bytesRead <= 0 ? 0 : bytesRead;
}


static int
gzipSeek(void* cookie, __off64_t* pos, int whence)
{
	M_ASSERT(IS_READABLE);

	*pos = ::gzseek(HANDLE, *pos, whence);
	return *pos == -1 ? -1 : 0;
}


static int
gzipClose(void* cookie)
{
	return ::gzclose(HANDLE);
}


static __ssize_t
gzipWrite(void* cookie, char const* buf, size_t len)
{
	M_ASSERT(IS_WRITEABLE);
	return ::gzwrite(HANDLE, buf, len);
}

} // namespace zstream


static cookie_io_functions_t m_gzip =
	{ zstream::gzipRead, zstream::gzipWrite, zstream::gzipSeek, zstream::gzipClose };
static cookie_io_functions_t m_zzip =
	{ zstream::zzipRead, zstream::zzipWrite, zstream::zzipSeek, zstream::zzipClose };
static cookie_io_functions_t m_zip  =
	{  zstream::zipRead,  zstream::zipWrite,  zstream::zipSeek,  zstream::zipClose };


ZStream::Handle::Handle() : dir(0), file(0), suffixes(0) {}

ZStream::Strings ZStream::m_suffixes;

ZStream::~ZStream() throw()			{ if (m_fp) ::fclose(m_fp); }
bool ZStream::is_open() const			{ return m_fp != 0; }
ZStream::Type ZStream::type() const	{ return m_type; }
int64_t ZStream::size() const			{ return m_size; }


ZStream::ZStream(char const* filename, Mode mode)
	:m_size(-1)
	,m_type(None)
{
	open(filename, mode);
}


ZStream::ZStream(char const* filename, Type type, Mode mode)
	:m_size(-1)
	,m_type(type)
{
	open(filename, type, mode);
}


void
ZStream::setZipFileSuffixes(Strings const& suffixes)
{
	m_suffixes.clear();
	m_suffixes.reserve(suffixes.size());

	for (unsigned i = 0; i < suffixes.size(); ++i)
		m_suffixes.push_back(suffixes[i].front() == '.' ? suffixes[i] : '.' + suffixes[i]);
}


ZStream::Strings const&
ZStream::zipFileSuffixes()
{
	return m_suffixes;
}


void
ZStream::open(char const* filename, Mode mode)
{
	M_REQUIRE(!is_open());
	M_REQUIRE(mode & mstl::ios_base::in);
	M_REQUIRE(!(mode & mstl::ios_base::out));

	mstl::ifstream strm(filename, mode | mstl::ios_base::binary);

	if (!strm)
		return setstate(failbit);

	unsigned char buffer[MAX(sizeof(gzipMagic), sizeof(zzipMagic))];
	::memset(buffer, 0, sizeof(buffer));

	strm.read(buffer, sizeof(buffer));

	Handle* cookie = &m_handle;
	char fmode[3] = { 'r', '\0', '\0' };

	cookie->mode = mode;

	if (::memcmp(buffer, gzipMagic, sizeof(gzipMagic)) == 0)
	{
		fmode[1] = 'b';
		HANDLE = static_cast<ZZIP_FILE*>(::gzopen(filename, fmode));

		if (!HANDLE)
			return setstate(failbit);

		m_fp = ::fopencookie(cookie, fmode, ::m_gzip);

		if (!m_fp)
			::gzclose(HANDLE);

		m_size = uint64_t(strm.size()*::DecompressionFactor);	// it's an estimation
		m_type = GZip;
	}
	else if (::memcmp(buffer, zzipMagic, sizeof(zzipMagic)) == 0)
	{
		fmode[1] = 'b';
		ZDIR = ::zzip_dir_open(filename, 0);

		if (!ZDIR)
			return setstate(failbit);

		cookie->suffixes = &m_suffixes;
		m_size = zstream::zzipSize(m_suffixes, ZDIR);
		m_fp = ::fopencookie(cookie, fmode, ::m_zzip);

		if (!m_fp)
			zzip_dir_close(ZDIR);

		m_type = Zip;
	}
	else
	{
		m_fp = ::fopen(filename, fmode);
		m_size = strm.size();
		m_type = Text;
	}

	strm.close();

	if (!m_fp)
	{
		m_handle.dir = 0;
		m_handle.file = 0;
		m_size = -1;
		m_type = None;
		setstate(failbit);
	}
}


void
ZStream::open(char const* filename, Type type, Mode mode)
{
	M_REQUIRE(!is_open());
	M_REQUIRE(mode & mstl::ios_base::out);
	M_REQUIRE(!(mode & mstl::ios_base::in));

	char		fmode[3]	= { '\0', '\0', '\0' };
	Handle*	cookie	= &m_handle;

	fmode[0] = (mode & mstl::ios_base::app ? 'a' : 'w');
	cookie->mode = mode;

	switch (type)
	{
		case None:
			m_type = Text;
			// fallthru

		case Text:
			m_fp = ::fopen(filename, fmode);
			break;

		case GZip:
			fmode[1] = 'b';
			HANDLE = ::gzopen(filename, fmode);

			if (!HANDLE)
				return setstate(failbit);

			m_fp = ::fopencookie(cookie, fmode, ::m_gzip);

			if (!m_fp)
				::gzclose(HANDLE);
			break;

		case Zip:
			HANDLE = ::zipOpen(
								filename,
								mode & mstl::ios_base::app ? APPEND_STATUS_ADDINZIP : APPEND_STATUS_CREATE);

			if (!HANDLE)
				return setstate(failbit);

			if (!zstream::zipOpenNewFileInZip(cookie, filename, mode))
			{
				::zipClose(HANDLE, 0);
				return setstate(failbit);
			}

			fmode[1] = 'b';
			m_fp = ::fopencookie(cookie, fmode, ::m_zip);

			if (!m_fp)
				::zipClose(HANDLE, 0);
			break;
	}

	if (!m_fp)
	{
		HANDLE = 0;
		m_type = None;
		setstate(failbit);
	}
	else
	{
		m_size = 0;
	}
}


void
ZStream::close()
{
	int rc = 0;

	if (m_fp)
	{
		rc = ::fclose(m_fp);
		m_fp = 0;
	}

	if (rc != 0)
		setstate(failbit);
}


bool
ZStream::size(char const* filename, int64_t& size, Type* type)
{
	mstl::ifstream strm(filename, mstl::ios_base::in | mstl::ios_base::binary);

	if (!strm)
		return false;

	unsigned char buffer[MAX(sizeof(gzipMagic), sizeof(zzipMagic))];
	::memset(buffer, 0, sizeof(buffer));

	strm.read(buffer, sizeof(buffer));

	if (::memcmp(buffer, gzipMagic, sizeof(gzipMagic)) == 0)
	{
		size = int64_t(strm.size()*::DecompressionFactor);	// it's an estimation
		if (type) *type = GZip;
	}
	else if (::memcmp(buffer, zzipMagic, sizeof(zzipMagic)) == 0)
	{
		Handle	handle;
		void*		cookie = &handle;

		ZDIR = ::zzip_dir_open(filename, 0);

		if (!ZDIR )
			return false;

		size = zstream::zzipSize(m_suffixes, ZDIR);
		::zzip_dir_close(ZDIR);
		if (type) *type = Zip;
	}
	else
	{
		size = strm.size();
		if (type) *type = Text;
	}

	return true;
}

// vi:set ts=3 sw=3:
