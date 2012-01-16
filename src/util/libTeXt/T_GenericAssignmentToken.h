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

#ifndef _TeXt_GenericAssignmentToken_included
#define _TeXt_GenericAssignmentToken_included

#include "T_GenericFinalToken.h"

namespace TeXt {

class GenericAssignmentToken : public GenericFinalToken
{
public:

	GenericAssignmentToken(mstl::string const& name, Func func, Type type = T_Generic);

	int uplevel() const;

	bool setUplevel(int level);

private:

	int m_uplevel;
};

} // namespace TeXt

#endif // _TeXt_GenericAssignmentToken_included

// vi:set ts=3 sw=3:
