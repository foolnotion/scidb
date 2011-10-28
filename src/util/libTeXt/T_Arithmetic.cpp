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

#include "T_Arithmetic.h"
#include "T_Environment.h"
#include "T_GenericAssignmentToken.h"
#include "T_GenericExpandableToken.h"
#include "T_NumberToken.h"
#include "T_Messages.h"
#include "T_Macros.h"
#include "T_Verify.h"

#include "m_assert.h"
#include "m_limits.h"

#include <math.h>


using namespace TeXt;


namespace {

typedef Value (*Operator)(Value, Value);

struct DivisionByZero {};
struct ArithmeticOverflow {};

} // namespace


static inline Value
checkZero(Value a)
{
	if (a == 0)
		throw DivisionByZero();

	return a;
}


static inline Value
checkOverflow(BigValue x)
{
	static BigValue const kMin = mstl::numeric_limits<Value>::min();
	static BigValue const kMax = mstl::numeric_limits<Value>::max();

	if (kMin > x || x > kMax)
		throw ArithmeticOverflow();

	return x;
}


namespace {
namespace Arith {

Value add(Value a, Value b) { return checkOverflow(BigValue(a) + BigValue(b)); }
Value sub(Value a, Value b) { return checkOverflow(BigValue(a) - BigValue(b)); }
Value mul(Value a, Value b) { return checkOverflow(BigValue(a) * BigValue(b)); }
Value div(Value a, Value b) { return a / checkZero(b); }
Value mod(Value a, Value b) { return a % checkZero(b); }
Value rem(Value a, Value b) { return a - b*(a/checkZero(b)); }

} // namespace Arith
} // namespace


static void
performArithmetic(Environment& env, Operator op)
{
	TokenP current	= env.currentToken();
	TokenP cs		= env.getUndefinedToken(Verify::unresolvedToken);

	env.putUnboundToken(cs);

	TokenP token1 = env.getFinalToken(Verify::numberToken);
	TokenP token2 = env.getFinalToken(Verify::numberToken);

	try
	{
		Macros::bindMacro(env, cs, env.numberToken(op(token1->value(), token2->value())));
	}
	catch (DivisionByZero)
	{
		Messages::errmessage(env, "Division by zero", Messages::Incorrigible);
	}
	catch (ArithmeticOverflow)
	{
		Messages::errmessage(env, "Arithmetic overflow", Messages::Incorrigible);
	}
}


static inline void performAdd(Environment& env) { performArithmetic(env, Arith::add); }
static inline void performSub(Environment& env) { performArithmetic(env, Arith::sub); }
static inline void performMul(Environment& env) { performArithmetic(env, Arith::mul); }
static inline void performDiv(Environment& env) { performArithmetic(env, Arith::div); }
static inline void performMod(Environment& env) { performArithmetic(env, Arith::mod); }
static inline void performRem(Environment& env) { performArithmetic(env, Arith::rem); }


static inline void
performLog10(Environment& env)
{
	TokenP token = env.getFinalToken(Verify::numberToken);

	if (token->value() <= 0)
		Messages::errmessage(env, "Logarithm undefined (argument <= 0)", Messages::Incorrigible);

	env.putFinalToken(TokenP(new NumberToken(Value(log10(token->value()))))); // MEMORY
}


static inline void
performPow2(Environment& env)
{
	TokenP token = env.getFinalToken(Verify::numberToken);

	Value exp = token->value();

	if (exp < 0)
		Messages::errmessage(env, "pow undefined (argument < 0)", Messages::Incorrigible);

	if (size_t(exp) >= (sizeof(Value)*8 - 1))
		Messages::errmessage(env, "Arithmetic overflow", Messages::Incorrigible);

	env.putFinalToken(TokenP(new NumberToken(Value(1 << exp)))); // MEMORY
}


void
Arithmetic::doRegister(Environment& env)
{
	env.bindMacro(new GenericAssignmentToken("\\add", ::performAdd));
	env.bindMacro(new GenericAssignmentToken("\\sub", ::performSub));
	env.bindMacro(new GenericAssignmentToken("\\mul", ::performMul));
	env.bindMacro(new GenericAssignmentToken("\\div", ::performDiv));
	env.bindMacro(new GenericAssignmentToken("\\mod", ::performMod));
	env.bindMacro(new GenericAssignmentToken("\\rem", ::performRem));
	env.bindMacro(new GenericExpandableToken("\\pow2", ::performPow2));
	env.bindMacro(new GenericExpandableToken("\\log10", ::performLog10));
}

// vi:set ts=3 sw=3:
