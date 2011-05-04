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

#include "T_Messages.h"
#include "T_GenericFinalToken.h"
#include "T_GenericValueToken.h"
#include "T_Environment.h"
#include "T_UserInput.h"
#include "T_Consumer.h"
#include "T_Errormode.h"

using namespace TeXt;


static bool
readUserInput(Environment& env)
{
	M_ASSERT(env.hasInput());

	while (true)
	{
		Messages::message(env, "? ");

		mstl::string input = env.getInput();

		if (input.empty())
			return false;

		env.consumer().log(input, false);
		env.consumer().log("\n", false);

		switch (input[0])
		{
			case 'r':
			case 'R':
				Messages::message(env, "OK, entering " + Errormode::setNonstopmode(env));
				return false;
				// NOTREACHED

			case 's':
			case 'S':
				Messages::message(env, "OK, entering " + Errormode::setScrollmode(env));
				return false;
				// NOTREACHED

			case 'q':
			case 'Q':
				Messages::message(env, "OK, entering " + Errormode::setBatchmode(env));
				return false;
				// NOTREACHED

			case 'i':
			case 'I':
				{
					Messages::message(env, "insert> ");
					if ((input = env.getInput()).empty())
						return false;
					env.pushInput(Environment::InputP(new UserInput(input)));
					return true;
				}
				// NOTREACHED

			case 'x':
			case 'X':
				throw Token::AbortException();
				// NOTREACHED

			case '\n':
				return false;
				// NOTREACHED

			case '1' ... '9':
				for (int i = '0'; i < input[0]; ++i)
					env.getUndefinedToken(Environment::AllowNull);
				Messages::message(env, env.backtrace());
				return false;
				// NOTREACHED

			default:
				env.consumer().out(
					"Type <return> to proceed, S to scroll future error messages,\n"
					"R to run without stopping, Q to run quietly,\n"
					"I to insert something, E to edit your file,\n"
					"1 or ... or 9 to ignore the next 1 to 9 tokens of input,\n"
					"H for help, X to quit.\n");
				break;
		}
	}
}


static mstl::string
getText(Environment& env)
{
	mstl::string	msg;
	unsigned			level	= 0;

	do
	{
		TokenP token = env.getFinalToken();

		switch (token->type())
		{
			case Token::T_LeftBrace:
				if (level++ > 0)
					msg += token->name();
				break;

			case Token::T_RightBrace:
				if (--level > 0)
					msg += token->name();
				break;

			default:
				msg += token->name();
				break;
		}
	}
	while (level > 0);

	return msg;
}


static void
performMessage(Environment& env)
{
	Messages::message(env, getText(env));
}


static void
performErrmessage(Environment& env)
{
	Messages::errmessage(env, getText(env), Messages::Corrigible);
}


void
Messages::message(Environment& env, mstl::string const& text)
{
	env.consumer().log(text, true);
}


void
Messages::logmessage(Environment& env, mstl::string const& text)
{
	env.consumer().log(text, env.associatedValue(Token::T_Tracingonline) > 0);
}


void
Messages::errmessage(Environment& env, mstl::string const& text, Mode mode)
{
	printTrace(env, text);

	if (env.errorMode() == Environment::AbortMode)
		throw Token::EmergencyStopException();

	if (	env.errorMode() != Environment::ErrorStopMode
		|| mode == Incorrigible
		|| !env.hasInput()
		|| !readUserInput(env))
	{
		throw Token::BreakExecutionException();
	}
}


void
Messages::printTrace(Environment& env, mstl::string const& text)
{
	mstl::string s;

	s += "! ";
	s += text;
	s += ".\n";
	s += env.backtrace();

	env.consumer().log(s, env.errorMode() != Environment::BatchMode);
}


void
Messages::doRegister(Environment& env)
{
	env.bindMacro(new GenericFinalToken("\\message",		::performMessage));
	env.bindMacro(new GenericFinalToken("\\errmessage",	::performErrmessage));

	env.bindMacro(new GenericValueToken("\\errorcontextlines", Token::T_Errorcontextlines), 5);
}

// vi:set ts=3 sw=3:
