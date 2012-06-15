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

#ifndef _TeXt_AsciiToken_included
#define _TeXt_AsciiToken_included

#include "T_FinalToken.h"

namespace TeXt {

class AsciiToken : public FinalToken
{
public:

	AsciiToken(unsigned char c);

	Type type() const override;
	RefID refID() const override;
	mstl::string name() const override;
	mstl::string meaning() const override;
	mstl::string text() const override;
	Value value() const override;

	void traceCommand(Environment& env) const override;
	TokenP performThe(Environment& env) const override;
	void perform(Environment& env) override;

private:

	typedef FinalToken Super;

	unsigned char m_value;
};

} // namespace TeXt

#endif // _TeXt_AsciiToken_included

// vi:set ts=3 sw=3:
