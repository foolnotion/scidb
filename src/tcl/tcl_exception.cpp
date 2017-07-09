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

#include "tcl_exception.h"
#include "tcl_base.h"

#include <tcl.h>

#include <stdarg.h>

using namespace tcl;


Exception::Exception(char const* fmt, ...)
	:util::Exception()
{
	va_list args;
	va_start(args, fmt);
	set_message(fmt, args);
	va_end(args);
}


Exception::Exception(unsigned numArgs, Tcl_Obj* const objv[], char const* usage)
{
	Tcl_WrongNumArgs(tcl::interp(), numArgs, objv, usage);
	assign(tcl::asString(tcl::result()));
}


Exception::Exception(util::Exception& exc) :util::Exception(exc) {}
Exception::~Exception() throw() {}


Error::Error() :util::Exception() { assign(tcl::asString(tcl::result())); }
Error::Error(util::Exception& exc) :util::Exception(exc) {}
Error::~Error() throw() {}


InterruptException::InterruptException() :m_count(-1) {}
InterruptException::InterruptException(unsigned count) :m_count(count) {}

int InterruptException::count() const { return m_count; }

// vi:set ts=3 sw=3:
