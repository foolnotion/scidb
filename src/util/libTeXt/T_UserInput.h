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

#ifndef _TeXt_UserInput_included
#define _TeXt_UserInput_included

#include "T_Input.h"

#include "m_string.h"

namespace TeXt {

class Environment;

class UserInput : public Input
{
public:

	UserInput(mstl::string const& text);

	Source source() const override;

	bool readNextLine(mstl::string& result) override;

private:

	mstl::string m_text;
};

} // namespace TeXt

#endif // _TeXt_UserInput_included

// vi:set ts=3 sw=3:
