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

#ifndef _TeXt_Messages_included
#define _TeXt_Messages_included

#include "T_Package.h"
#include "T_TokenP.h"

#include "m_string.h"

namespace TeXt {

class Messages : public Package
{
public:

	enum Mode { Corrigible, Incorrigible };

	static void message(Environment& env, mstl::string const& text);
	static void logmessage(Environment& env, mstl::string const& text);
	static void errmessage(Environment& env, mstl::string const& text, Mode mode);
	static void printTrace(Environment& env, mstl::string const& text);

private:

	void doRegister(Environment& env);
};

} // namespace TeXt

#endif // _TeXt_Messages_included

// vi:set ts=3 sw=3:
