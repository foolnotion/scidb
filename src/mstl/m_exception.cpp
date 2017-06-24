// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2009-2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "m_exception.h"
#include "m_sstream.h"
#include "m_string.h"
#include "m_stdio.h"

#include <stdlib.h>
#include <stdarg.h>

using namespace mstl;


bool basic_exception::m_isDisabled = false;

basic_exception::basic_exception() throw() :m_msg(new string) {}
basic_exception::basic_exception(string const& msg) :m_msg(new string(msg)) {}
basic_exception::basic_exception(basic_exception const& exc) :m_msg(new string(*exc.m_msg)) {}

basic_exception::~basic_exception() throw() { delete m_msg; }

char const* basic_exception::what() const throw() { return *m_msg; }


basic_exception::basic_exception(char const* fmt, va_list args)
	:m_msg(new string)
{
	m_msg->vformat(fmt, args);
}


basic_exception::basic_exception(char const* fmt, ...)
	:m_msg(new string)
{
	M_REQUIRE(fmt);

	va_list args;
	va_start(args, fmt);
	m_msg->vformat(fmt, args);
	va_end(args);
}


void
basic_exception::set_message(char const* fmt, va_list args)
{
	m_msg->vformat(fmt, args);
}


void
basic_exception::assign(string const& s)
{
	m_msg->assign(s);
}


exception::exception() throw() :m_report(new string), m_backtrace(isEnabled()) {}


exception::exception(string const& msg)
	:basic_exception(msg)
	,m_report(new string)
	,m_backtrace(isEnabled())
{
}


exception::exception(exception const& exc)
	:basic_exception(exc)
	,m_report(new string(*exc.m_report))
	,m_backtrace(exc.m_backtrace)
{
}


exception::exception(char const* fmt, va_list args)
	:basic_exception(fmt, args)
	,m_report(new string)
	,m_backtrace(isEnabled())
{
}


exception::exception(char const* fmt, ...)
	:m_report(new string)
	,m_backtrace(isEnabled())
{
	M_REQUIRE(fmt);

	va_list args;
	va_start(args, fmt);
	set_message(fmt, args);
	va_end(args);
}


exception::~exception() throw() { delete m_report; }
backtrace const& exception::backtrace() const { return m_backtrace; }
string const& exception::report() const { return *m_report; }
void exception::set_report(string const& report) { m_report->assign(report); }
void exception::set_backtrace(::mstl::backtrace const& backtrace) { m_backtrace = backtrace; }


#ifndef __OPTIMIZE__

#ifdef __GNUC__
# include <cxxabi.h>
#endif


static int
excbreak()
{
	return 0;
}


void
mstl::bits::prepare_msg(mstl::exception& exc,
								char const* file,
								unsigned line,
								char const* func,
								char const* exc_type)
{
	try
	{
		ostringstream strm;
		strm.format(	"(func) %s\n(file) %s:%u\n(what) %s\n(type) %s\n",
							func, file, line, exc.what(), exc_type);

#ifndef NDEBUG
		if (!exc.backtrace().empty())
		{
			strm.write("\n", 1);
			strm.format("=== Backtrace ============================================\n");
			exc.backtrace().text_write(strm, 3);
			strm.format("==========================================================\n");
			::fprintf(stderr, "%s\n", strm.str().c_str());
		}
#endif

		excbreak();
		exc.set_report(strm.str());
	}
	catch (...)
	{
	}
}


void
mstl::bits::prepare_exc(mstl::exception& exc,
								char const* file,
								unsigned line,
								char const* func,
								char const* exc_type_id)
{
#ifdef __GNUC__

	int	status;
	char*	exc_type = ::abi::__cxa_demangle(exc_type_id, 0, 0, &status);

	prepare_msg(exc, file, line, func, status == -1 ? 0 : exc_type);

	if (status != -1)
		::free(exc_type);

#else

	prepare_msg(exc, file, line, func, exc_type_id);

#endif
}

#endif // __OPTIMIZE__

// vi:set ts=3 sw=3:
