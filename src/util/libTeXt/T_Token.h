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

#ifndef _TeXt_Token_included
#define _TeXt_Token_included

#include "T_Base.h"
#include "T_TokenP.h"

#include "m_ref_counter.h"
#include "m_string.h"

namespace TeXt {

class Environment;


class Token : public mstl::ref_counter
{
public:

	enum Type
	{
		T_Ascii = 256,		// 0-255 reserved for ASCII
		T_Active,
		T_Text,
		T_Undefined,
		T_Relax,
		T_Empty,
		T_Invalid,
		T_LeftBrace,
		T_List,
		T_Macro,
		T_Number,
		T_Parameter,
		T_Variable,
		T_RightBrace,

		// generic types
		T_Generic,
		T_Value,
		T_Errorcontextlines,
		T_Escapechar,
		T_Tracingcommands,
		T_Tracingmacros,
		T_Tracingonline,
		T_Utf8,

		// must be defined at least
		T_FirstGenericType,
		T_MaxGenericType = (1 << 16) - 1,	// = numeric_limits<RefID>::max()
	};

	struct Exception {};
	struct AbortException : public Exception {};
	struct EmergencyStopException : public Exception {};
	struct UnexpectedEndOfInputException : public Exception {};
	struct BreakExecutionException : public Exception {};

	static char const EscapeChar	= '\\';
	static char const ParamChar	= '#';
	static char const VarChar		= '@';
	static char const LBraceChar	= '{';
	static char const RBraceChar	= '}';
	static char const ListChar		= '$';

	virtual ~Token() = 0;

	bool operator==(Token const& token) const;

	virtual bool isBound() const;
	virtual bool isResolved() const;
	virtual bool isNumber() const;
	virtual bool isConditional() const;
	virtual bool isFinal() const;
	virtual bool isEqualTo(Token const& token) const;

	virtual Type type() const = 0;
	virtual mstl::string name() const = 0;
	mstl::string name(Environment& env) const;
	virtual mstl::string meaning() const;
	virtual mstl::string description(Environment& env) const;
	virtual Value value() const;
	virtual bool isEmpty() const;
	virtual RefID refID() const;
	virtual TokenP performThe(Environment& env) const;

	virtual void traceCommand(Environment& env) const;

	virtual void bind(Environment& env) = 0;
	virtual void resolve(Environment& env) = 0;
	virtual void expand(Environment& env) = 0;
	virtual void execute(Environment& env) = 0;
	virtual bool setUplevel(int level);

	static void traceCommand(Environment& env, mstl::string const& meaning);
};

} // namespace TeXt

#endif // _TeXt_Token_included

// vi:set ts=3 sw=3:
