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

#ifndef _TeXt_FinalToken_included
#define _TeXt_FinalToken_included

#include "T_Token.h"

namespace TeXt {

class FinalToken : public Token
{
public:

	bool isFinal() const;

	void bind(Environment& env);
	void resolve(Environment& env);
	void expand(Environment& env);
	void execute(Environment& env);

protected:

	virtual void perform(Environment& env) = 0;
};

} // namespace TeXt

#endif // _TeXt_FinalToken_included

// vi:set ts=3 sw=3:
