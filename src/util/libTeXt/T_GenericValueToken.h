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

#ifndef _TeXt_GenericValueToken_included
#define _TeXt_GenericValueToken_included

#include "T_FinalToken.h"
#include "T_Generic.h"

namespace TeXt {

class GenericValueToken : public FinalToken, public Generic
{
public:

	typedef Token::Type Type;

	GenericValueToken(mstl::string const& name, Type type = T_Value);

	mstl::string description(Environment& env) const override;
	TokenP performThe(Environment& env) const override;

	Type type() const override;
	mstl::string name() const override;
	void perform(Environment& env) override;
};

} // namespace TeXt

#endif // _TeXt_GenericValueToken_included

// vi:set ts=3 sw=3:
