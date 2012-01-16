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

#include "T_List.h"
#include "T_ListToken.h"
#include "T_GenericFinalToken.h"
#include "T_GenericExpandableToken.h"
#include "T_GenericAssignmentToken.h"
#include "T_GenericConditionalToken.h"
#include "T_ActiveToken.h"
#include "T_Environment.h"
#include "T_TokenP.h"
#include "T_Messages.h"
#include "T_Conditional.h"
#include "T_Macros.h"
#include "T_Verify.h"

#include "m_assert.h"
#include "m_cast.h"
#include "m_utility.h"


using namespace TeXt;


namespace { typedef mstl::ref_counted_ptr<ListToken> ListP; }


Conditional* m_conditional = 0;


static bool
verifyListToken(Environment& env, TokenP const& token)
{
	if (token->type() == Token::T_List)
		return true;

	Messages::errmessage(
			env,
			"You can't use `" + token->meaning() + "' after " + env.currentToken()->name(),
			Messages::Corrigible);

	return false;
}


static TokenP
getList(Environment& env, char const* msg)
{
	TokenP token = env.getUndefinedToken(Environment::AllowNull);

	if (!token)
		Messages::errmessage(env, msg, Messages::Incorrigible);

	switch (token->type())
	{
		case Token::T_LeftBrace:
			token.reset(new ListToken(env)); // MEMORY
			break;

		case Token::T_List:
			break;

		case Token::T_Text:
			token.reset(new ListToken(env, token->name())); // MEMORY
			break;

		default:
			token.reset(new ListToken(token)); // MEMORY
			break;
	}

	return token;
}


inline
static ListP
getListToken(Environment& env)
{
	return env.getFinalToken(::verifyListToken);
}


static void
performAppend(Environment& env)
{
	// NOTE: getListToken(env)->append(env.getUndefinedToken()) isn't working due to a gcc-3.x bug!
	ListP token = getListToken(env);
	token->append(env.getUndefinedToken());
}


static void
performPrepend(Environment& env)
{
	// NOTE: getListToken(env)->prepend(env.getUndefinedToken()) isn't working due to a gcc-3.x bug!
	ListP token = getListToken(env);
	token->prepend(env.getUndefinedToken());
}


static void
performFront(Environment& env)
{
	ListP list = getListToken(env);
	env.putUnboundToken(list->isEmpty() ? env.getToken(Token::T_Empty) : list->front());
}


static void
performBack(Environment& env)
{
	ListP list = getListToken(env);
	env.putUnboundToken(list->isEmpty() ? env.getToken(Token::T_Empty) : list->back());
}


static void
performPopfront(Environment& env)
{
	ListP list = getListToken(env);

	if (!list->isEmpty())
		list->popFront();
}


static void
performPopback(Environment& env)
{
	ListP list = getListToken(env);

	if (!list->isEmpty())
		list->popBack();
}


static void
performReverse(Environment& env)
{
	getListToken(env)->reverse();
}


static void
performRotate(Environment& env)
{
	// NOTE: getListToken(env)->rotate(env.getFinalToken(::verifyNumberToken)->value()) isn't working
	// due to a gcc-3.x bug!
	ListP token = getListToken(env);
	token->rotate(env.getFinalToken(Verify::numberToken)->value());
}


static void
performLength(Environment& env)
{
	env.putUnboundToken(env.numberToken(getListToken(env)->length()));
}


static void
performFlatten(Environment& env)
{
	getListToken(env)->flatten();
}


static void
performFind(Environment& env)
{
	ListP list = getListToken(env);
	env.putUnboundToken(env.numberToken(list->find(env.getExpandableToken())));
}


static void
performIndex(Environment& env)
{
	// NOTE: getListToken(env)->index(env.getFinalToken(::verifyNumberToken)->value()) isn't working
	// due to a gcc-3.x bug!
	ListP 	list	= getListToken(env);
	TokenP	token	= list->index(env.getFinalToken(Verify::numberToken)->value());

	if (!token)
		token = env.newUndefinedToken("\\undefined");

	env.putUnboundToken(token);
}


static void
performIflist(Environment& env)
{
	M_ASSERT(::m_conditional);
	::m_conditional->performIf(env, Token::T_List);
}


static void
performList(Environment& env)
{
	env.putFinalToken(getList(env, "unterminated list definition"));
}


static void
performLet(Environment& env)
{
	TokenP	cs		= env.getUndefinedToken(Verify::controlSequenceToken);
	ListP		list	= getListToken(env);
	TokenP	index	= env.getFinalToken(Verify::numberToken);
	TokenP	token	= list->index(index->value());

	if (!token)
		token = env.newUndefinedToken("\\undefined");

	env.bindMacro(cs->refID(), token);
}


static void
performSet(Environment& env)
{
	ListP		list	= getListToken(env);
	Value		index	= env.getFinalToken(Verify::numberToken)->value();
	TokenP	cs		= env.getExpandableToken();

	if (list->length() < index)
		list->resize(index + 1, env.newUndefinedToken("\\undefined"));

	list->set(index, cs);
}


static void
performBind(Environment& env)
{
	getListToken(env)->bind(env);
}


static void
performAssign(Environment& env)
{
	ListP value = getListToken(env);
	ListP vars	= getList(env, "unexpected end of file");

	for (unsigned i = 0, length = mstl::min(value->length(), vars->length()); i < length; ++i)
	{
		TokenP	cs = vars->index(i);
		bool		isOk;

		switch (cs->type())
		{
			case Token::T_Undefined:	isOk = true; break;
			case Token::T_Variable:		isOk = bool(env.contextMacro()); break;
			default:							isOk = false;
		}

		if (isOk)
			env.bindMacro(cs->refID(), value->index(i));
		else
			Messages::errmessage(env, "only control sequences are expected", Messages::Corrigible);
	}
}


List::List() :Package("list", Mandatory) {}


void
List::doRegister(Environment& env)
{
	env.bindMacro(new GenericExpandableToken("\\list",		::performList));
	env.bindMacro(new GenericExpandableToken("\\lfront",	::performFront));
	env.bindMacro(new GenericExpandableToken("\\lback",	::performBack));
	env.bindMacro(new GenericExpandableToken("\\lindex",	::performIndex));
	env.bindMacro(new GenericExpandableToken("\\llength",	::performLength));
	env.bindMacro(new GenericExpandableToken("\\lfind",	::performFind));

	env.bindMacro(new GenericFinalToken("\\lappend",	::performAppend));
	env.bindMacro(new GenericFinalToken("\\lprepend",	::performPrepend));
	env.bindMacro(new GenericFinalToken("\\lpopfront",	::performPopfront));
	env.bindMacro(new GenericFinalToken("\\lpopback",	::performPopback));
	env.bindMacro(new GenericFinalToken("\\lreverse",	::performReverse));
	env.bindMacro(new GenericFinalToken("\\lrotate",	::performRotate));
	env.bindMacro(new GenericFinalToken("\\lflatten",	::performFlatten));
	env.bindMacro(new GenericFinalToken("\\lassign",	::performAssign));
	env.bindMacro(new GenericFinalToken("\\lset",		::performSet));
	env.bindMacro(new GenericFinalToken("\\lbind",		::performBind));

	env.bindMacro(new GenericAssignmentToken("\\llet",	::performLet));

	env.bindMacro(new GenericConditionalToken("\\iflist", Func(::performIflist)));

	env.bindMacro(Token::ListChar, TokenP(new ActiveToken(Token::ListChar, ::performList)));

	::m_conditional = mstl::safe_cast_ptr<Conditional>(env.getPackage("conditional"));
}

// vi:set ts=3 sw=3:
