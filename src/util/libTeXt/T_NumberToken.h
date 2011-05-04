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

#ifndef _TeXt_NumberToken_included
#define _TeXt_NumberToken_included

#include "T_FinalToken.h"

namespace TeXt {

class NumberToken : public FinalToken
{
public:

	NumberToken(Value value);

	bool operator==(Token const& token) const;

	bool isNumber() const;

	Type type() const;
	mstl::string name() const;
	mstl::string name(Environment& env) const;
	mstl::string meaning() const;
	mstl::string description(Environment& env) const;
	Value value() const;
	RefID refID() const;
	TokenP performThe(Environment& env) const;

	void perform(Environment& env);

	void setup(Value value);
	void increment();

private:

	Value m_value;
};

} // namespace TeXt

#include "T_NumberToken.ipp"

#endif // _TeXt_NumberToken_included

// vi:set ts=3 sw=3:
