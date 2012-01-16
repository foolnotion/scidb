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

#include "T_Input.h"

using namespace TeXt;


Input::Input()
	:m_lineNo(0)
{
}


Input::~Input()
{
	// no action
}


bool
Input::nextLine(mstl::string& result)
{
	bool rc = readNextLine(result);

	if (rc)
		++m_lineNo;

	return rc;
}

// vi:set ts=3 sw=3:
