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

#ifndef _sys_file_included
#define _sys_file_included

#include "sys_time.h"

#include "m_string.h"

namespace sys {
namespace file {

enum Mode
{
	Existence	= 0,
	Executable	= 1,
	Writeable	= 2,
	Readable		= 4,
};

enum Type
{
	None,
	RegularFile,
	Directory,
	CharacterDevice,
	BlockDevice,
	NamedPipe,
	SymbolicLink,
	Socket,
	Unknown,
};

class Mapping
{
public:

	Mapping(char const* filename, Mode mode);
	~Mapping();

	bool isOpen() const;
	bool isWriteable() const;
	bool isReadonly() const;

	unsigned size() const;
	unsigned capacity() const;

	unsigned char const* address() const;
	unsigned char* address();

	void resize(unsigned newSize);
	void flush(unsigned size = 0);

private:

	void*		m_address;
	unsigned	m_size;
	unsigned	m_capacity;
	bool		m_writeable;

#ifdef __WIN32__
	HANDLE m_file;
	HANDLE m_mapping;
#else
	int m_fd;
#endif
};


mstl::string internalName(char const* externalName);
mstl::string normalizedName(char const* externalName);
char pathDelim();

bool access(char const* filename, Mode mode);

bool dirIsEmpty(char const* dirname);
long size(char const* filename);
bool changed(char const* filename, uint32_t& time);
bool isHardLinked(char const* filename1, char const* filename2);
Type type(char const* filename);

void rename(char const* oldFilename, char const* newFilename, bool preserveOldAttrs = false);
void deleteIt(char const* filename);
bool setModificationTime(char const* filename, uint32_t time);

bool lock(int fd);
void unlock(int fd);

} // namespace file
} // namespace sys

#include "sys_file.ipp"

#endif // _sys_file_included

// vi:set ts=3 sw=3:
