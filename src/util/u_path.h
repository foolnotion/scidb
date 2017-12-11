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

#ifndef _util_path_included
#define _util_path_included

#include "m_string.h"

namespace util {

class Path
{
public:

	enum Mode
	{
		Existence	= 0,
		Executable	= 1,
		Writable		= 2,
		Readable		= 4,
	};

	Path(mstl::string const& name);
	explicit Path(char const* name);

#if HAVE_C11_MOVE_CONSTRCUTOR_AND_ASSIGMENT_OPERATOR
	Path(Path&& p);
	Path& operator=(Path&& p);
#endif

	bool isRelative() const;	// Tcl_GetPathType
	bool isAbsolute() const;	// Tcl_GetPathType

	bool access(Mode mode);

	mstl::string suffix() const;	// Tcl_SplitPath
	mstl::string basename() const;

	void addSuffix(char const* suffix);	// Tcl_JoinPath
	void removeSuffix();						// Tcl_SplitPath

private:

	mstl::string m_name;
};

} // namespace util

#endif // _util_path_included

// vi:set ts=3 sw=3:
