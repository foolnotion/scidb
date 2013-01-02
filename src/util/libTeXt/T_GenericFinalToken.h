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

#ifndef _TeXt_GenericFinalToken_included
#define _TeXt_GenericFinalToken_included

#include "T_FinalToken.h"
#include "T_Generic.h"

namespace TeXt {

class GenericFinalToken : public FinalToken, public Generic
{
public:

	typedef Token::Type Type;

	GenericFinalToken(mstl::string const& name, Func func, Type type = T_Generic);

	Type type() const override;
	bool isFinal() const override;
	mstl::string name() const override;
	void perform(Environment& env) override;
};

} // namespace TeXt

#endif // _TeXt_GenericFinalToken_included

// vi:set ts=3 sw=3:
