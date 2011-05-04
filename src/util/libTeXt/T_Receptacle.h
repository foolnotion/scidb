// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2009-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _TeXt_Receptacle_included
#define _TeXt_Receptacle_included

#include "T_TokenP.h"

#include "m_string.h"

namespace TeXt {

class Environment;

class Receptacle
{
public:

	Receptacle(Environment& env);
	virtual ~Receptacle() = 0;

	Environment& env();

	void add(mstl::string const& name, Token* token);
	virtual void add(mstl::string const& name, TokenP const& token) = 0;

private:

	Environment& m_env;
};

} // namespace TeXt

#include "T_Receptacle.ipp"

#endif // _TeXt_Receptacle_included

// vi:set ts=3 sw=3:
