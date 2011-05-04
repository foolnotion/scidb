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

#ifndef _TeXt_Conditional_included
#define _TeXt_Conditional_included

#include "T_Base.h"
#include "T_Package.h"

#include "m_stack.h"
#include "m_pair.h"

namespace TeXt {

class Conditional : public Package
{
public:

	Conditional();

	void performIf(Environment& env, Token::Type type);

private:

	typedef mstl::pair<Token::Type,RefID> State;
	typedef mstl::stack<State> CondStack;
	typedef bool (*VerifyFunc)(Environment&, TokenP const&);

	TokenP getFinalToken(Environment& env, VerifyFunc func = 0);

//	void expandIfcase(Environment& env, Value value);
	void expandIfThenElse(Environment& env, bool condition);

	void doRegister(Environment& env);
	void doFinish(Environment& env);

	void performIf(Environment& env);
	void performIfx(Environment& env);
	void performElse(Environment& env);
//	void performOr(Environment& env);
	void performWhen(Environment& env);
	void performFi(Environment& env);
	void performUnless(Environment& env);
	void performIffalse(Environment& env);
	void performIftrue(Environment& env);
	void performIfmacro(Environment& env);
	void performIftext(Environment& env);
	void performIfempty(Environment& env);
	void performIfnum(Environment& env);
	void performIfodd(Environment& env);
	void performIfequal(Environment& env);
	void performIfgreater(Environment& env);
	void performIflower(Environment& env);
	void performIfcase(Environment& env);
	void performIfbound(Environment& env);

	void skipElseBranch(Environment& env);

	Token::Type	m_if;
	Token::Type	m_else;
	Token::Type	m_fi;
//	Token::Type	m_or;
	Token::Type	m_when;
	Token::Type	m_ifCase;
	CondStack	m_condStack;
	bool			m_throw;
	bool			m_unless;

	class ThrowMonitor;
	friend class ThrowMonitor;
};

} // namespace TeXt

#endif // _TeXt_Conditional_included

// vi:set ts=3 sw=3:
