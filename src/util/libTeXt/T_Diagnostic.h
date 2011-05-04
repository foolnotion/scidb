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

#ifndef _TeXt_Diagnostic_included
#define _TeXt_Diagnostic_included

#include "T_Package.h"

namespace TeXt {

class Diagnostic : public Package
{
	void doRegister(Environment& env);
};

} // namespace TeXt

#endif // _TeXt_Diagnostic_included

// vi:set ts=3 sw=3:
