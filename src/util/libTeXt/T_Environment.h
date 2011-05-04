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

#ifndef _TeXt_Environment_included
#define _TeXt_Environment_included

#include "T_GenericFinalToken.h"
#include "T_Tokenizer.h"
#include "T_TokenP.h"
#include "T_OutputFilter.h"
#include "T_ActiveToken.h"
#include "T_Base.h"

#include "m_ref_counted_ptr.h"
#include "m_scoped_ptr.h"
#include "m_string.h"
#include "m_utility.h"

namespace TeXt {

class Producer;
class Consumer;
class Package;
class ParameterToken;


class Environment : private mstl::noncopyable
{
public:

	enum ErrorMode		{ ErrorStopMode, ScrollMode, NonStopMode, AbortMode, BatchMode, };
	enum Nullability	{ AllowNull, ExcludeNull, };

	typedef mstl::ref_counted_ptr<Consumer>		ConsumerP;
	typedef mstl::ref_counted_ptr<Producer>		ProducerP;
	typedef mstl::ref_counted_ptr<OutputFilter>	FilterP;
	typedef mstl::ref_counted_ptr<Package>			PackageP;

	typedef Tokenizer::InputP			InputP;
	typedef Token::Type					TokenType;
	typedef GenericFinalToken::Func	Func;

	typedef ActiveToken::Func ActivateFunc;
	typedef bool (*VerifyFunc)(Environment&, TokenP const&);

	struct Input
	{
		virtual ~Input() = 0;

		virtual mstl::string getInput() = 0;
	};

	Environment(mstl::string const& searchDirs, ErrorMode errorMode, Input* input = 0);
	~Environment();

	bool containsToken(mstl::string const& name) const;
	bool containsToken(TokenType type) const;
	bool hasInput() const;
	bool containsPackage(mstl::string const& packageName) const;

	ErrorMode errorMode() const;
	unsigned groupLevel() const;
	TokenP const& contextMacro() const;
	unsigned nestingLevel() const;
	unsigned contextLevel() const;
	Producer& producer(int index = -1);
	Producer const& producer(int index = -1) const;
	Consumer& consumer();
	unsigned lineno() const;
	unsigned countProducers() const;
	mstl::string getInput();
	TokenP currentToken() const;
	TokenP getToken(TokenType type) const;
	TokenP asciiToken(unsigned char c) const;
	TokenP numberToken(Value value) const;
	OutputFilter& filter();
	mstl::string backtrace() const;
	Package* getPackage(mstl::string const& name);
	ConsumerP getConsumer() const;
	mstl::string const& searchDirs() const;

	TokenP newUndefinedToken(mstl::string const& name);
	TokenP newParameterToken(mstl::string const& name);
	TokenP newVariableToken(mstl::string const& name);
	TokenP newVariableToken(mstl::string const& name, TokenP const& macro);

	TokenType bindMacro(Token* token, Value defaultValue = 0);
	TokenType bindMacro(TokenP const& token, Value defaultValue = 0);
	TokenType bindMacro(mstl::string const& name, Token* token, Value defaultValue = 0);
	TokenType bindMacro(mstl::string const& name, TokenP const& token, Value defaultValue = 0);

	void bindMacro(RefID refID, TokenP const& token, int uplevel = 0);
	void bindVariable(RefID refID, TokenP const& token, unsigned nestingLevel, int uplevel = 0);
	void bindParameter(RefID refID, TokenP const& token);
	void upToken(RefID refID, unsigned nlevels);

	TokenP lookupMacro(RefID refID) const;
	TokenP lookupParameter(RefID refID) const;
	TokenP lookupVariable(RefID refID, unsigned nestingLevel) const;

	void pushProducer(ProducerP const& producer);
	void pushProducer(ProducerP const& producer, TokenP const& macro, unsigned nestingLevel);
	void popProducer();
	void pushInput(InputP const& input);
	void popInput();
	void pushFilter(FilterP filter);
	void addPackage(PackageP package);
	void finishPackages();
	bool usePackage(mstl::string const& name);
	void setConsumer(ConsumerP const& consumer);

	void pushGroup();
	void popGroup();
	void associate(TokenType type, Value value);
	Value associatedValue(TokenType type) const;

	TokenP getPendingToken();
	TokenP getUnboundToken(Nullability nullability = ExcludeNull);
	TokenP getUndefinedToken(Nullability nullability = ExcludeNull);
	TokenP getExpandableToken(Nullability nullability = ExcludeNull);
	TokenP getFinalToken(Nullability nullability = ExcludeNull);
	TokenP getUndefinedToken(VerifyFunc verify);
	TokenP getExpandableToken(VerifyFunc verify);
	TokenP getFinalToken(VerifyFunc verify);

	void putUnboundToken(TokenP const& token);
	void putExpandableToken(TokenP const& token);
	void putFinalToken(TokenP const& token);

	void setErrorMode(ErrorMode newErrorMode);
	void terminateProduction();

	void execute(TokenP const& token);
	void expand(TokenP const& token);
	void bind(TokenP const& token);
	void resolve(TokenP const& token);
	void performMacro(TokenP token);
	void perform(TokenP const& token);
	void perform(TokenP const& token, mstl::string& result);

private:

	class Impl;
	typedef mstl::scoped_ptr<Impl> ImplP;

	class MyProducer;
	friend class MyProducer;

	TokenP			m_current;
	Input*			m_input;
	ConsumerP		m_consumer;
	FilterP			m_filter;
	ImplP				m_impl;
	mstl::string	m_searchDirs;
};

} // namespace TeXt

#include "T_Environment.ipp"

#endif // _TeXt_Environment_included

// vi:set ts=3 sw=3:
