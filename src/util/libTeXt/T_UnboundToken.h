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

#ifndef _TeXt_UnboundToken_included
#define _TeXt_UnboundToken_included

#include "T_Token.h"

#include "m_string.h"

namespace TeXt {

class Environment;


class UnboundToken : public Token
{
public:

	UnboundToken(mstl::string const& name, RefID refID);

	mstl::string name() const override;
	RefID refID() const override;

	void traceCommand(Environment& env) const override;

	void execute(Environment& env) override;

protected:

	mstl::string	m_name;
	RefID				m_refID;
};

} // namespace TeXt

#endif // _TeXt_UnboundToken_included

// vi:set ts=3 sw=3:
