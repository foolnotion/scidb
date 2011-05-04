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

#ifndef _TeXt_AsciiToken_included
#define _TeXt_AsciiToken_included

#include "T_FinalToken.h"

namespace TeXt {

class AsciiToken : public FinalToken
{
public:

	AsciiToken(unsigned char c);

	Type type() const;
	RefID refID() const;
	mstl::string name() const;
	mstl::string meaning() const;
	Value value() const;

	void traceCommand(Environment& env) const;
	TokenP performThe(Environment& env);
	void perform(Environment& env);

private:

	typedef FinalToken Super;

	unsigned char m_value;
};

} // namespace TeXt

#endif // _TeXt_AsciiToken_included

// vi:set ts=3 sw=3:
