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

#ifndef _TeXt_Char_included
#define _TeXt_Char_included

#include "T_Package.h"

namespace TeXt {

class Char : public Package
{
	void doRegister(Environment& env) override;
};

} // namespace TeXt

#endif // _TeXt_Char_included

// vi:set ts=3 sw=3:
