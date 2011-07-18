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

#ifndef _TeXt_VariableToken_included
#define _TeXt_VariableToken_included

#include "T_UnboundToken.h"

#include "m_string.h"

namespace TeXt {

class VariableToken : public UnboundToken
{
public:

	VariableToken(mstl::string const& name, RefID id);

	bool isBound() const override;
	bool isResolved() const override;

	Type type() const override;
	Value value() const override;
	mstl::string name() const override;
	mstl::string meaning() const override;

	void setup(TokenP const& macro);

	void bind(Environment& env) override;
	void resolve(Environment& env) override;
	void expand(Environment& env) override;
	void fixLevel(unsigned level);

private:

	TokenP	m_macro;
	int		m_level;
};

} // namespace TeXt

#endif // _TeXt_VariableToken_included

// vi:set ts=3 sw=3:
