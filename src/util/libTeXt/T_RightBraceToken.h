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

#ifndef _TeXt_RightBraceToken_included
#define _TeXt_RightBraceToken_included

#include "T_FinalToken.h"

namespace TeXt {

class RightBraceToken : public FinalToken
{
public:

	RightBraceToken();

	Type type() const;
	mstl::string name() const;
	mstl::string meaning() const;

	void perform(Environment& env);
};

} // namespace TeXt

#endif // _TeXt_RightBraceToken_included

// vi:set ts=3 sw=3:
