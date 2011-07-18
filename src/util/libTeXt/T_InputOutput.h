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

#ifndef _TeXt_InputOutput_included
#define _TeXt_InputOutput_included

#include "T_Package.h"

namespace mstl { class string; }

namespace TeXt {

class InputOutput : public Package
{
public:

	static mstl::string const& suffix();
	static bool searchFile(mstl::string const& searchDirs, mstl::string& filename);

private:

	void doRegister(Environment& env) override;
};

} // namespace TeXt

#endif // _TeXt_InputOutput_included

// vi:set ts=3 sw=3:
