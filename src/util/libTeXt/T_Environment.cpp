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

#include "T_Environment.h"
#include "T_UndefinedToken.h"
#include "T_ParameterToken.h"
#include "T_VariableToken.h"
#include "T_LeftBraceToken.h"
#include "T_RightBraceToken.h"
#include "T_AsciiToken.h"
#include "T_InvalidToken.h"
#include "T_ListToken.h"
#include "T_NumberToken.h"
#include "T_MacroToken.h"
#include "T_Producer.h"
#include "T_Consumer.h"
#include "T_TokenBuffer.h"
#include "T_ValueBuffer.h"
#include "T_Generic.h"
#include "T_UserInput.h"
#include "T_Messages.h"
#include "T_ReadAgainProducer.h"
#include "T_TextConsumer.h"

#include "m_assert.h"
#include "m_cast.h"
#include "m_limits.h"
#include "m_tuple.h"
#include "m_string.h"
#include "m_map.h"
#include "m_stack.h"

#include <stdlib.h>

using namespace TeXt;


class Environment::Impl
{
public:

	static int const kMacro		= 0;
	static int const kNesting	= 1;
	static int const kGroup		= 2;

	static int const kProducer	= 0;
	static int const kMacroCxt	= 1;

	typedef Environment::ErrorMode			ErrorMode;
	typedef Environment::ProducerP			ProducerP;
	typedef Environment::Nullability			Nullability;
	typedef Environment::ActivateFunc		ActivateFunc;
	typedef Environment::PackageP				PackageP;

	typedef mstl::tuple<TokenP,unsigned,unsigned>	Context;
	typedef mstl::tuple<ProducerP,bool>					ProducerCxt;

	typedef mstl::stack<Context>					ContextStack;
	typedef mstl::stack<ProducerCxt>				ProducerStack;
	typedef mstl::map<mstl::string,PackageP>	PackageMap;

	enum State { kUnbound, kExpandable, kFinal, };

	struct SToken
	{
		SToken() :m_state(kUnbound) {}

		TokenP get()
		{
			TokenP token = m_token;
			m_token.reset();
			return token;
		}

		void set(TokenP const& token, State state)
		{
			m_token = token;
			m_state = state;
		}

		void reset()					{ m_token.reset(); }

		bool operator!() const		{ return !m_token; }
		bool isFinal() const			{ return m_token && m_state == kFinal; }
		bool isExpandable() const	{ return m_token && m_state >= kExpandable; }

		State		m_state;
		TokenP	m_token;
	};

	Impl(Environment& env, ErrorMode errorMode);

	bool containsToken(mstl::string const& name) const;
	bool containsToken(Token::Type type) const;
	bool containsPackage(mstl::string const& packageName) const;

	ErrorMode errorMode() const;
	unsigned groupLevel() const;
	TokenP const& contextMacro() const;
	unsigned nestingLevel() const;
	unsigned contextLevel() const;
	Producer& producer(int index = -1);
	Producer const& producer(int index = -1) const;
	unsigned lineno() const;
	unsigned countProducers() const;
	TokenP getToken(TokenType type) const;
	mstl::string backtrace() const;
	Environment& env() const;
	Package* getPackage(mstl::string const& name);
	unsigned varContextLevel(unsigned nestingLevel, int uplevel) const;

	TokenP newUndefinedToken(mstl::string const& name);
	TokenP newParameterToken(mstl::string const& name);
	TokenP newVariableToken(mstl::string const& name);
	TokenP newVariableToken(mstl::string const& name, TokenP const& macro);

	void bindMacro(TokenP const& token, Value defaultValue);
	TokenType bindMacro(mstl::string const& name, TokenP token, Value defaultValue);
	void bindMacro(RefID refID, TokenP token, int uplevel);
	void bindMacro(TokenP const& token, mstl::string const& value);
	void bindVariable(RefID refID, TokenP const& token, unsigned nestingLevel, int uplevel);
	void bindParameter(RefID refID, TokenP const& token);
	void setupValue(RefID refID, Value value);
	void upToken(RefID refID, unsigned nlevels);

	TokenP lookupMacro(RefID refID) const;
	TokenP lookupParameter(RefID refID) const;
	TokenP lookupVariable(RefID refID, unsigned nestingLevel) const;

	void associate(TokenType type, Value value);
	Value associatedValue(TokenType type) const;

	void pushProducer(ProducerP const& producer);
	void pushProducer(ProducerP const& producer, TokenP const& macro, unsigned nestingLevel);
	void popProducer();
	void pushInput(InputP const& input);
	void popInput();
	void pushGroup();
	void popGroup();
	void addPackage(PackageP package);
	void finishPackages();
	bool usePackage(mstl::string const& name);

	TokenP getPendingToken();
	TokenP getUnboundToken(Nullability nullability);
	TokenP getUndefinedToken(Environment& env, Nullability nullability);
	TokenP getExpandableToken(Environment& env, Nullability nullability);
	TokenP getFinalToken(Environment& env, Nullability nullability);

	void putUnboundToken(TokenP const& token);
	void putExpandableToken(TokenP const& token);
	void putFinalToken(TokenP const& token);

	void setErrorMode(ErrorMode newErrorMode);
	void terminateProduction();

	TokenP const& asciiToken(unsigned char c) const		{ return m_asciiToken[c]; }
	TokenP const& invalidToken(unsigned char c) const	{ return m_invalidToken[c]; }
	TokenP const& leftBraceToken() const					{ return m_leftBraceToken; }
	TokenP const& rightBraceToken() const					{ return m_rightBraceToken; }

	TokenP numberToken(Value value) const
	{
		if (0 <= value && value < Value(kNumNumberTokens))
			return m_numberToken[value];

		return TokenP(new NumberToken(value)); // MEMORY
	}

private:

	typedef mstl::vector<PackageP> Packages;

	static size_t const kNumAsciiTokens		= 256;
	static size_t const kNumInvalidTokens	= 256;
	static size_t const kNumNumberTokens	= 256;

	Producer& producer_(int index) const { return const_cast<Producer&>(producer(index)); }

	Environment&	m_env;
	ErrorMode		m_errorMode;
	ProducerP		m_producer;
	ContextStack	m_contextStack;
	ProducerStack	m_producerStack;
	TokenBuffer		m_paramBuffer;
	TokenBuffer		m_macroBuffer;
	ValueBuffer		m_valueBuffer;
	TokenBuffer		m_varBuffer;
	SToken			m_token;
	Tokenizer		m_tokenizer;
	TokenP			m_asciiToken[kNumAsciiTokens];
	TokenP			m_invalidToken[kNumInvalidTokens];
	TokenP			m_numberToken[kNumNumberTokens];
	TokenP			m_leftBraceToken;
	TokenP			m_rightBraceToken;
	Packages			m_packages;
	PackageMap		m_packageMap;
};


namespace {

class EmptyProducer : public Producer
{
public:

	unsigned lineno() const override
	{
		return 0;
	}

	Source source() const override
	{
		return File;	// it doesn't matter
	}

	TokenP next(Environment&) override
	{
		return TokenP();
	}

	mstl::string currentDescription() const override
	{
		return mstl::string::empty_string;
	}
};


class EndOfExecutionProducer : public Producer
{
public:

	struct Exception {};

	unsigned lineno() const override
	{
		return 0;
	}

	Source source() const override
	{
		return File;	// it doesn't matter
	}

	TokenP next(Environment&) override
	{
		throw Exception();
		return TokenP();
	}

	mstl::string currentDescription() const override
	{
		return mstl::string::empty_string;
	}
};


struct MyConsumer : public Consumer
{
	void put(unsigned char) override					{ M_RAISE("no consumer"); }
	void put(mstl::string const&) override			{ M_RAISE("no consumer"); }

	void out(mstl::string const&) override			{ M_RAISE("no consumer"); }
	void log(mstl::string const&, bool) override	{ M_RAISE("no consumer"); }
};


class MyFilter : public OutputFilter
{
public:

	typedef Environment::ConsumerP ConsumerP;

	MyFilter(ConsumerP& consumer) :OutputFilter(0), m_consumer(consumer) {}

	void put(Environment&, unsigned char c) override
	{
		m_consumer->put(c);
	}

	void put(Environment&, mstl::string const& s) override
	{
		m_consumer->put(s);
	}

	void put(Environment&, Value number) override
	{
		m_consumer->put(mstl::string::cast(number));
	}

private:

	ConsumerP& m_consumer;
};


struct PrimitiveTokenGenerator : public TokenBuffer::TokenGenerator
{
	PrimitiveTokenGenerator(RefID id) :m_id(id) {}
	RefID m_id;

	Token* newToken(mstl::string const& name, RefID) const override
	{
		return new UndefinedToken(name, m_id); // MEMORY
	}
};


struct UndefinedTokenGenerator : public TokenBuffer::TokenGenerator
{
	Token* newToken(mstl::string const& name, RefID refID) const override
	{
		return new UndefinedToken(name, mstl::max(refID, RefID(Token::T_FirstGenericType))); // MEMORY
	}
};


struct ParameterTokenGenerator : public TokenBuffer::TokenGenerator
{
	Token* newToken(mstl::string const& name, RefID refID) const override
	{
		return new ParameterToken(name, refID); // MEMORY
	}
};


struct VariableTokenGenerator : public TokenBuffer::TokenGenerator
{
	Token* newToken(mstl::string const& name, RefID refID) const override
	{
		return new VariableToken(name, refID); // MEMORY
	}
};

} // namespace


Environment::Impl::Impl(Environment& env, ErrorMode errorMode)
	:m_env(env)
	,m_errorMode(errorMode)
	,m_leftBraceToken(new LeftBraceToken) // MEMORY
	,m_rightBraceToken(new RightBraceToken) // MEMORY
{
	m_contextStack.push(Context(TokenP(), 0, 0));
	m_producerStack.push(
		ProducerStack::value_type(ProducerP(new TokenProducer(*this, m_tokenizer)), false)); // MEMORY

	for (size_t i = 0; i < kNumAsciiTokens; ++i)
		m_asciiToken[i].reset(new AsciiToken(i)); // MEMORY
	for (size_t i = 0; i < kNumInvalidTokens; ++i)
		m_invalidToken[i].reset(new InvalidToken(i)); // MEMORY
	for (size_t i = 0; i < kNumNumberTokens; ++i)
		m_numberToken[i].reset(new NumberToken(i)); // MEMORY

	for (size_t i = 0; i < kNumAsciiTokens; ++i)
	{
		m_macroBuffer.setupToken(i, m_asciiToken[i]);
		m_valueBuffer.setupValue(i, i);
	}

	m_macroBuffer.setupToken(Token::T_LeftBrace, m_leftBraceToken);
	m_macroBuffer.setupToken(Token::T_RightBrace, m_rightBraceToken);
}


inline
void
Environment::Impl::setupValue(RefID refID, Value value)
{
	m_valueBuffer.setupValue(refID, value);
}


inline
Environment::Impl::ErrorMode
Environment::Impl::errorMode() const
{
	return m_errorMode;
}


inline
void
Environment::Impl::setErrorMode(ErrorMode newErrorMode)
{
	m_errorMode = newErrorMode;
}


inline
unsigned
Environment::Impl::groupLevel() const
{
	return m_macroBuffer.size() - 1;
}


inline
unsigned
Environment::Impl::contextLevel() const
{
	return m_contextStack.size() - 1;
}


inline
TokenP const&
Environment::Impl::contextMacro() const
{
	return m_contextStack.top().get<kMacro>();
}


inline
unsigned
Environment::Impl::nestingLevel() const
{
	return m_contextStack.top().get<kNesting>();
}


unsigned
Environment::Impl::varContextLevel(unsigned nestingLevel, int uplevel) const
{
	M_ASSERT(contextLevel() > 0);
	M_ASSERT(nestingLevel <= m_contextStack.top().get<kNesting>());
	M_ASSERT(nestingLevel > 0);

	unsigned skipBackward = this->nestingLevel() - nestingLevel;

	if (uplevel < 0 || groupLevel() < unsigned(uplevel))
		return (m_contextStack.end() - skipBackward - 1)->get<kGroup>();

	return groupLevel() - uplevel + contextLevel() - skipBackward;
}


inline
unsigned
Environment::Impl::lineno() const
{
	return m_tokenizer.lineno();
}


inline
unsigned
Environment::Impl::countProducers() const
{
	return m_producerStack.size();
}


Producer const&
Environment::Impl::producer(int index) const
{
	M_REQUIRE(!m_producerStack.empty());
	M_REQUIRE(index >= -1);
	M_REQUIRE(index < int(countProducers()));

	if (index == -1)
		return *m_producerStack.top().get<kProducer>();

	return *m_producerStack[index].get<kProducer>();
}


Producer&
Environment::Impl::producer(int index)
{
	return producer_(index);
}


inline
TokenP
Environment::Impl::lookupMacro(RefID refID) const
{
	return m_macroBuffer.lookupToken(groupLevel(), refID);
}


TokenP
Environment::Impl::lookupParameter(RefID refID) const
{
	M_REQUIRE(contextLevel() > 0);

	TokenP result = m_paramBuffer.lookupToken(contextLevel() - 1, refID);

	M_ASSERT(!result || dynamic_cast<ListToken*>(result.get()));

	return result;
}


inline
TokenP
Environment::Impl::lookupVariable(RefID refID, unsigned nestingLevel) const
{
	M_REQUIRE(contextLevel() > 0);

	return m_varBuffer.lookupToken(varContextLevel(nestingLevel, 0), refID);
}


void
Environment::Impl::terminateProduction()
{
	m_producerStack.clear();
	m_producerStack.push(ProducerStack::value_type(ProducerP(new EmptyProducer), false)); // MEMORY
	m_token.reset();
}


void
Environment::Impl::pushProducer(ProducerP const& producer)
{
	M_REQUIRE(producer);
	m_producerStack.push(ProducerCxt(producer, false));
}


void
Environment::Impl::pushProducer(ProducerP const& producer, TokenP const& macro, unsigned nestingLevel)
{
	static size_t const Stack_Size = 8192;

	M_REQUIRE(producer);
	M_REQUIRE(macro);

	if (m_producerStack.size() == Stack_Size)
	{
		m_errorMode = Environment::AbortMode;
		Messages::errmessage(
			m_env,
			"Macro stack size exceeded (stack size=" + mstl::string::cast(Stack_Size),
			Messages::Incorrigible);
	}

	M_ASSERT(!m_contextStack.empty());

	m_producerStack.push(ProducerCxt(producer, true));
	m_contextStack.push(Context(macro, nestingLevel, m_contextStack.size() + groupLevel()));
	m_paramBuffer.push();
	m_varBuffer.push();
}


void
Environment::Impl::popProducer()
{
	M_REQUIRE(m_producerStack.size() > 1);

	if (m_producerStack.top().get<kMacroCxt>())
	{
		M_ASSERT(m_varBuffer.size() > 1);
		M_ASSERT(m_paramBuffer.size() > 1);
		M_ASSERT(m_contextStack.size() > 1);

		m_varBuffer.pop();
		m_paramBuffer.pop();
		m_contextStack.pop();
	}

	m_producerStack.pop();
}


void
Environment::Impl::pushGroup()
{
	static size_t const Stack_Size = 4096;

	if (m_macroBuffer.size() == Stack_Size)
	{
		m_errorMode = Environment::AbortMode;
		Messages::errmessage(
			m_env,
			"Grouping level exceeded (grouping level=" + mstl::string::cast(Stack_Size),
			Messages::Incorrigible);
	}

	m_macroBuffer.push();
	m_valueBuffer.push();
	m_varBuffer.push();
}


void
Environment::Impl::popGroup()
{
	M_REQUIRE(m_macroBuffer.size() > 1);
	M_REQUIRE(m_valueBuffer.size() > 1);
	M_REQUIRE(m_varBuffer.size() > 1);

	m_macroBuffer.pop();
	m_valueBuffer.pop();
	m_varBuffer.pop();
}


inline
void
Environment::Impl::pushInput(InputP const& input)
{
	static size_t const Stack_Size = 256;

	M_REQUIRE(input);

	if (m_macroBuffer.size() == Stack_Size)
	{
		m_errorMode = Environment::AbortMode;
		Messages::errmessage(
			m_env,
			"Input stack size exceeded (stack size=" + mstl::string::cast(Stack_Size),
			Messages::Incorrigible);
	}

	m_tokenizer.pushInput(input);
}


inline
void
Environment::Impl::popInput()
{
	m_tokenizer.popInput();
}


void
Environment::Impl::upToken(RefID refID, unsigned nlevels)
{
	m_macroBuffer.upToken(groupLevel(), refID, nlevels);
}


void
Environment::Impl::bindMacro(RefID refID, TokenP token, int uplevel)
{
	unsigned level;

	if (uplevel < 0 || groupLevel() <= unsigned(uplevel))
		level = 0;
	else
		level = groupLevel() - uplevel;;

	m_macroBuffer.bindToken(level, refID, token);
}


Token::Type
Environment::Impl::bindMacro(mstl::string const& name, TokenP token, Value defaultValue)
{
	M_REQUIRE(token);

	TokenType	type = token->type();
	TokenP		undefinedToken;

	if (type == Token::T_Generic || type == Token::T_Value)
		undefinedToken = m_macroBuffer.setupToken(name, UndefinedTokenGenerator());
	else
		undefinedToken = m_macroBuffer.setupToken(name, PrimitiveTokenGenerator(type));

	RefID refID = undefinedToken->refID();

	m_macroBuffer.bindToken(0, refID, token);

	if (type == Token::T_Generic || type == Token::T_Value)
	{
		static_assert(sizeof(TokenType) >= sizeof(RefID), "possible overflow");
		dynamic_cast<Generic*>(token.get())->setType(type = TokenType(refID));
	}

	m_valueBuffer.setupValue(refID, defaultValue);

	return type;
}


inline
void
Environment::Impl::bindMacro(TokenP const& token, Value defaultValue)
{
	M_REQUIRE(token);
	bindMacro(token->name(), token, defaultValue);
}


inline
void
Environment::Impl::bindMacro(TokenP const& token, mstl::string const& value)
{
	bindMacro(token->refID(), TokenP(new TextToken(value)), 0);
}


inline
void
Environment::Impl::bindParameter(RefID refID, TokenP const& token)
{
	M_REQUIRE(token);
	M_REQUIRE(contextLevel() > 0);

	m_paramBuffer.bindToken(contextLevel() - 1, refID, token);
}


inline
void
Environment::Impl::bindVariable(RefID refID, TokenP const& token, unsigned nestingLevel, int uplevel)
{
	M_REQUIRE(token);
	M_REQUIRE(contextLevel() > 0);

	m_varBuffer.bindToken(varContextLevel(nestingLevel, uplevel), refID, token);
}


inline
TokenP
Environment::Impl::newUndefinedToken(mstl::string const& name)
{
	M_REQUIRE(name.size() > 1);
	return m_macroBuffer.setupToken(name, UndefinedTokenGenerator());
}


inline
TokenP
Environment::Impl::newParameterToken(mstl::string const& name)
{
	M_REQUIRE(name.size() > 1);
	M_REQUIRE(name[0] == Token::ParamChar);

	return m_paramBuffer.setupToken(name, ParameterTokenGenerator());
}


TokenP
Environment::Impl::newVariableToken(mstl::string const& name)
{
	M_REQUIRE(name.size() > 1);
	M_REQUIRE(name[0] == Token::VarChar);

	return m_varBuffer.setupToken(name, VariableTokenGenerator());
}


TokenP
Environment::Impl::newVariableToken(mstl::string const& name, TokenP const& macro)
{
	M_REQUIRE(name.size() > 1);
	M_REQUIRE(name[0] == Token::VarChar);

	TokenP token = m_varBuffer.setupToken(name, VariableTokenGenerator());

	if (macro)
		mstl::safe_cast_ref<VariableToken>(*token).setup(macro);

	return token;
}


TokenP
Environment::Impl::getUnboundToken(Nullability nullability)
{
	TokenP token = m_token.get();

	if (!token)
	{
		do
		{
			token = producer().next(m_env);

			if (!token)
			{
				if (m_producerStack.size() > 1)
				{
					popProducer();
				}
				else
				{
					if (nullability == AllowNull)
						return TokenP();

					throw Token::UnexpectedEndOfInputException();
				}
			}
		}
		while (!token);
	}

	return token;
}


TokenP
Environment::Impl::getUndefinedToken(Environment& env, Nullability nullability)
{
	TokenP token = getUnboundToken(nullability);

	while (token && !token->isBound())
	{
		env.bind(token);

		TokenP t = getUnboundToken(nullability);

		if (*t == *token)
			return token;

		token = t;
	}

	return token;
}


TokenP
Environment::Impl::getExpandableToken(Environment& env, Nullability nullability)
{
	if (m_token.isExpandable())
		return m_token.get();

	TokenP token = getUndefinedToken(env, nullability);

	while (token && !token->isResolved())
	{
		env.resolve(token);

		if (m_token.isExpandable())
			return m_token.get();

		TokenP t = getUndefinedToken(env, nullability);

		if (*t == *token)
			return token;	// XXX throw error!?

		token = t;
	}

	return token;
}


TokenP
Environment::Impl::getFinalToken(Environment& env, Nullability nullability)
{
	while (true)
	{
		if (m_token.isFinal())
			return m_token.get();

		TokenP token = getExpandableToken(env, nullability);

		if (!token)
			return token;

		env.expand(token);
	}

	return TokenP();	// satisfies the compiler
}


inline
TokenP
Environment::Impl::getPendingToken()
{
	return m_token.get();
}


inline
void
Environment::Impl::putUnboundToken(TokenP const& token)
{
	m_token.set(token, kUnbound);
}


inline
void
Environment::Impl::putExpandableToken(TokenP const& token)
{
	m_token.set(token, kExpandable);
}


inline
void
Environment::Impl::putFinalToken(TokenP const& token)
{
	m_token.set(token, kFinal);
}


inline
void
Environment::Impl::associate(TokenType type, Value value)
{
	m_valueBuffer.set(groupLevel(), RefID(type), value);
}


inline
Value
Environment::Impl::associatedValue(TokenType type) const
{
	return m_valueBuffer.get(groupLevel(), RefID(type));
}


inline
bool
Environment::Impl::containsToken(mstl::string const& name) const
{
	return m_macroBuffer.contains(name);
}


inline
bool
Environment::Impl::containsToken(Token::Type type) const
{
	return m_macroBuffer.contains(RefID(type));
}


inline
TokenP
Environment::Impl::getToken(TokenType type) const
{
	M_REQUIRE(containsToken(type));
	return lookupMacro(RefID(type));
}


inline
Environment&
Environment::Impl::env() const
{
	return m_env;
}


mstl::string
Environment::Impl::backtrace() const
{
	mstl::string result;

	Value n = mstl::max(0, associatedValue(Token::T_Errorcontextlines));

	for (int i = int(countProducers()) - 1; i >= 0; --i)
	{
		if (i == 0 || n >= 0)
		{
			mstl::string descr = producer(i).currentDescription();

			if (!descr.empty())
			{
				mstl::string prefix;

				switch (producer(i).source())
				{
					case Producer::File:
						prefix += "l.";
						prefix += mstl::string::cast(lineno());
						prefix += " ";
						break;

					case Producer::Macro:
					case Producer::List:
						break;

					case Producer::Parameter:
						prefix += "<argument> ";
						break;

					case Producer::Insert:
						prefix += "<insert> ";
						break;

					case Producer::InsertedText:
						prefix += "<inserted text> ";
						break;

					case Producer::ReadAgain:
						if (producer(i).finished())
							prefix += "<recently read> ";
						else
							prefix += "<to be read again> ";
						break;

					case Producer::Text:
						prefix += "<text>";
						break;
				}

				mstl::string::size_type pos = descr.find('\n');

				result += prefix;

				if (pos == mstl::string::npos)
				{
					result += descr;
					result += "\n\n";
				}
				else if (pos == descr.size() - 1)
				{
					result += descr;
					result += "\n";
				}
				else
				{
					result += descr.substr(0, pos);
					result += "\n";
					result += mstl::string(pos + prefix.size(), ' ');
					result += descr.substr(pos + 1);
					result += "\n";
				}

				--n;
			}
		}
		else if (n == -1)
		{
			result += "...\n";
			--n;	// prevents further lines
		}
	}

	return result;
}


void
Environment::Impl::addPackage(PackageP package)
{
	m_packages.push_back(package);

	if (package->hasName())
		m_packageMap[package->name()] = package;

	if (package->isMandatory())
		package->registerTokens(m_env);
}


void
Environment::Impl::finishPackages()
{
	for (Packages::iterator i = m_packages.begin(); i != m_packages.end(); ++i)
		(*i)->finish(m_env);
}


bool
Environment::Impl::usePackage(mstl::string const& name)
{
	PackageMap::iterator i = m_packageMap.find(name);

	if (i == m_packageMap.end())
		return false;

	i->second->registerTokens(m_env);

	return true;
}


bool
Environment::Impl::containsPackage(mstl::string const& packageName) const
{
	PackageMap::const_iterator i = m_packageMap.find(packageName);
	return i != m_packageMap.end() && i->second->isRegistered();
}


Package*
Environment::Impl::getPackage(mstl::string const& name)
{
	M_REQUIRE(containsPackage(name));
	return m_packageMap.find(name)->second.get();
}



Environment::TokenProducer::TokenProducer(Environment::Impl& impl, Tokenizer& tokenizer)
	:m_impl(impl)
	,m_tokenizer(tokenizer)
{
}


Producer::Source
Environment::TokenProducer::source() const
{
	return m_tokenizer.source();
}


mstl::string
Environment::TokenProducer::currentDescription() const
{
	return m_tokenizer.currentDescription();
}


unsigned
Environment::TokenProducer::lineno() const
{
	return m_tokenizer.lineno();
}


TokenP
Environment::TokenProducer::next(Environment&)
{
	m_name.clear();

	switch (m_tokenizer.parseToken(m_name))
	{
		case Tokenizer::Undefined:
			M_ASSERT(m_name.size() > 1);
			return m_impl.newUndefinedToken(m_name);

		case Tokenizer::Number:
				BigValue v;

				if (sizeof(BigValue) == sizeof(long))
					v = ::strtol(m_name, 0, 10);
				else // sizeof(BigValue) == sizeof(long long)
					v = ::strtoll(m_name, 0, 10);

				if (mstl::numeric_limits<Value>::min() > v || v > mstl::numeric_limits<Value>::max())
				{
					// XXX not a good idea! wrong place!
					Messages::errmessage(m_impl.env(), "Number too big", Messages::Corrigible);
				}

				return m_impl.numberToken(v);

		case Tokenizer::Invalid:
			M_ASSERT(m_name.size() == 1);
			return m_impl.invalidToken(m_name[0]);

		case Tokenizer::Parameter:
			M_ASSERT(m_name.size() > 1);
			return m_impl.newParameterToken(m_name);

		case Tokenizer::Variable:
			M_ASSERT(m_name.size() > 1);
			return m_impl.newVariableToken(m_name);

		case Tokenizer::LeftBrace:
			return m_impl.leftBraceToken();

		case Tokenizer::RightBrace:
			return m_impl.rightBraceToken();

		case Tokenizer::EscapedChar:
			M_ASSERT(m_name.size() == 1);
			return m_impl.asciiToken(m_name[0]);

		case Tokenizer::Char:
			M_ASSERT(m_name.size() == 1);
			M_ASSERT((m_name[0] & 0x80) == 0);
			return m_impl.lookupMacro(RefID(static_cast<unsigned char>(m_name[0])));

		case Tokenizer::Unicode:
			return TokenP(new TextToken(m_name)); // MEMORY

		case Tokenizer::Empty:
			return TokenP();
	}

	return TokenP(); // satisfies the compiler
}


Environment::Input::~Input()
{
	// no action
}


Environment::Environment(mstl::string const& searchDirs, ErrorMode errorMode, Input* input)
	:m_input(input)
	,m_consumer(new MyConsumer)
	,m_filter(new MyFilter(m_consumer))
	,m_impl(new Impl(*this, errorMode))
	,m_searchDirs(searchDirs)
{
}


Environment::~Environment()
{
	// no action
}


TokenP
Environment::currentToken() const
{
	M_REQUIRE(m_current);

	return m_current;
}


bool
Environment::hasInput() const
{
	return m_input;
}


mstl::string
Environment::getInput()
{
	M_REQUIRE(hasInput());
	return m_input->getInput();
}


TokenP const&
Environment::contextMacro() const
{
	return m_impl->contextMacro();
}


unsigned
Environment::nestingLevel() const
{
	return m_impl->nestingLevel();
}


unsigned
Environment::contextLevel() const
{
	return m_impl->contextLevel();
}


Environment::ErrorMode
Environment::errorMode() const
{
	return m_impl->errorMode();
}


unsigned
Environment::groupLevel() const
{
	return m_impl->groupLevel();
}


TokenP
Environment::lookupParameter(RefID refID) const
{
	return m_impl->lookupParameter(refID);
}


TokenP
Environment::lookupVariable(RefID refID, unsigned nestingLevel) const
{
	return m_impl->lookupVariable(refID, nestingLevel);
}


TokenP
Environment::lookupMacro(RefID refID) const
{
	return m_impl->lookupMacro(refID);
}


void
Environment::setErrorMode(ErrorMode newErrorMode)
{
	m_impl->setErrorMode(newErrorMode);
}


Producer&
Environment::producer(int index)
{
	return m_impl->producer(index);
}


Producer const&
Environment::producer(int index) const
{
	return m_impl->producer(index);
}


unsigned
Environment::countProducers() const
{
	return m_impl->countProducers();
}


unsigned
Environment::lineno() const
{
	return m_impl->lineno();
}


void
Environment::terminateProduction()
{
	m_impl->terminateProduction();
}


void
Environment::pushProducer(ProducerP const& producer)
{
	m_impl->pushProducer(producer);
}


void
Environment::pushProducer(ProducerP const& producer, TokenP const& macro, unsigned nestingLevel)
{
	return m_impl->pushProducer(producer, macro, nestingLevel);
}


void
Environment::popProducer()
{
	m_impl->popProducer();
}


void
Environment::pushInput(InputP const& input)
{
	m_impl->pushInput(input);
}


void
Environment::popInput()
{
	m_impl->popInput();
}


void
Environment::pushFilter(FilterP filter)
{
	M_REQUIRE(filter);

	FilterP& f = m_filter;

	while (f && f->m_priority > filter->m_priority)
		f = f->m_next;

	filter->m_next = f;
	f = filter;
}


void
Environment::setConsumer(ConsumerP const& consumer)
{
	M_REQUIRE(consumer);
	m_consumer = consumer;
}


Environment::ConsumerP
Environment::getConsumer() const
{
	return m_consumer;
}


Consumer&
Environment::consumer()
{
	return *m_consumer;
}


void
Environment::pushGroup()
{
	m_impl->pushGroup();
}


void
Environment::popGroup()
{
	m_impl->popGroup();
}


TokenP
Environment::newUndefinedToken(mstl::string const& name)
{
	return m_impl->newUndefinedToken(name);
}


TokenP
Environment::newParameterToken(mstl::string const& name)
{
	return m_impl->newParameterToken(name);
}


TokenP
Environment::newVariableToken(mstl::string const& name)
{
	return m_impl->newVariableToken(name);
}


TokenP
Environment::newVariableToken(mstl::string const& name, TokenP const& macro)
{
	return m_impl->newVariableToken(name, macro);
}


void
Environment::upToken(RefID refID, unsigned nlevels)
{
	M_REQUIRE(nlevels <= groupLevel());
	m_impl->upToken(refID, nlevels);
}


void
Environment::bindMacro(TokenP const& token, Value defaultValue)
{
	M_REQUIRE(token);
	M_REQUIRE(token->name().size() > 1);
	M_REQUIRE(token->name()[0] == Token::EscapeChar);
	M_REQUIRE(!containsToken(token->name()));
	M_REQUIRE(!containsToken(token->type()));

	m_impl->bindMacro(token, defaultValue);
}


void
Environment::bindMacro(Token* token, Value defaultValue)
{
	bindMacro(TokenP(token), defaultValue);
}


Token::Type
Environment::bindMacro(mstl::string const& name, TokenP const& token, Value defaultValue)
{
	M_REQUIRE(token);
//	M_REQUIRE(token->name().size() > 1);
//	M_REQUIRE(token->name()[0] == Token::T_EscapeChar);
	M_REQUIRE(!containsToken(name));
	M_REQUIRE(token->type() != Token::T_Generic && token->type() != Token::T_Value);

	TokenP macro = newUndefinedToken(name);

	m_impl->setupValue(macro->refID(), defaultValue);
	m_impl->bindMacro(macro->refID(), token, false);

	return Token::Type(macro->refID());
}


Token::Type
Environment::bindMacro(mstl::string const& name, Token* token, Value defaultValue)
{
	return bindMacro(name, TokenP(token), defaultValue);
}


void
Environment::bindMacro(RefID refID, TokenP const& token, int uplevel)
{
	M_REQUIRE(token);
//	M_REQUIRE(token->name().size() > 1);
//	M_REQUIRE(token->name()[0] == Token::kEscapeChar);

	m_impl->bindMacro(refID, token, uplevel);
}


void
Environment::bindMacro(TokenP const& token, mstl::string const& value)
{
	M_REQUIRE(token->isBound());
	return m_impl->bindMacro(token, value);
}


void
Environment::bindParameter(RefID refID, TokenP const& token)
{
	return m_impl->bindParameter(refID, token);
}


void
Environment::bindVariable(RefID refID, TokenP const& token, unsigned nestingLevel, int uplevel)
{
	return m_impl->bindVariable(refID, token, nestingLevel, uplevel);
}


TokenP
Environment::getPendingToken()
{
	return m_impl->getPendingToken();
}


TokenP
Environment::getUnboundToken(Nullability nullability)
{
	return m_impl->getUnboundToken(nullability);
}


TokenP
Environment::getUndefinedToken(Nullability nullability)
{
	return m_impl->getUndefinedToken(*this, nullability);
}


TokenP
Environment::getExpandableToken(Nullability nullability)
{
	return m_impl->getExpandableToken(*this, nullability);
}


TokenP
Environment::getFinalToken(Nullability nullability)
{
	return m_impl->getFinalToken(*this, nullability);
}


TokenP
Environment::getUndefinedToken(VerifyFunc verify)
{
	M_REQUIRE(verify);

	while (true)
	{
		TokenP result = m_impl->getUndefinedToken(*this, ExcludeNull);

		if (verify(*this, result))
			return result;
	}

	return TokenP();	// never reached
}


TokenP
Environment::getExpandableToken(VerifyFunc verify)
{
	M_REQUIRE(verify);

	while (true)
	{
		TokenP result = m_impl->getExpandableToken(*this, ExcludeNull);

		if (verify(*this, result))
			return result;
	}

	return TokenP();	// never reached
}


TokenP
Environment::getFinalToken(VerifyFunc verify)
{
	M_REQUIRE(verify);

	while (true)
	{
		TokenP result = m_impl->getFinalToken(*this, ExcludeNull);

		if (verify(*this, result))
			return result;
	}

	return TokenP();	// never reached
}


void
Environment::putUnboundToken(TokenP const& token)
{
	M_REQUIRE(token);
	m_impl->putUnboundToken(token);
}


void
Environment::putExpandableToken(TokenP const& token)
{
	M_REQUIRE(token);
	m_impl->putExpandableToken(token);
}


void
Environment::putFinalToken(TokenP const& token)
{
	M_REQUIRE(token);

	m_impl->putFinalToken(token);
}


void
Environment::associate(TokenType type, Value value)
{
	m_impl->associate(type, value);
}


Value
Environment::associatedValue(TokenType type) const
{
	return m_impl->associatedValue(type);
}


bool
Environment::containsToken(mstl::string const& name) const
{
	return m_impl->containsToken(name);
}


bool
Environment::containsToken(TokenType type) const
{
	return m_impl->containsToken(type);
}


TokenP
Environment::getToken(TokenType type) const
{
	M_REQUIRE(containsToken(type));
	return m_impl->getToken(type);
}


TokenP
Environment::asciiToken(unsigned char c) const
{
	return m_impl->asciiToken(c);
}


TokenP
Environment::numberToken(Value value) const
{
	return m_impl->numberToken(value);
}


void
Environment::bind(TokenP const& token)
{
	M_REQUIRE(token);

	TokenP t = m_current;
	(m_current = token)->bind(*this);
	m_current = t;
}


void
Environment::resolve(TokenP const& token)
{
	M_REQUIRE(token);

	TokenP t = m_current;
	(m_current = token)->resolve(*this);
	m_current = t;
}


mstl::string
Environment::backtrace() const
{
	return m_impl->backtrace();
}


void
Environment::execute(TokenP const& token)
{
	M_REQUIRE(token);

	TokenP t = m_current;
	(m_current = token)->execute(*this);
	m_current = t;
}


void
Environment::expand(TokenP const& token)
{
	M_REQUIRE(token);

	TokenP t = m_current;
	(m_current = token)->expand(*this);
	m_current = t;
}


void
Environment::performMacro(TokenP token)
{
	M_REQUIRE(token->type() == Token::T_Macro);
	M_ASSERT(dynamic_cast<MacroToken*>(token.get()));

	TokenP t(m_current);
	m_current = token;
	static_cast<MacroToken*>(token.get())->perform(*this);
	m_current = t;
}


void
Environment::perform(TokenP const& token)
{
	M_REQUIRE(token);

	ProducerP producer(new EndOfExecutionProducer()); // MEMORY
	m_impl->pushProducer(producer);

	try
	{
		expand(token);

		while (TokenP t = m_impl->getFinalToken(*this, AllowNull))
			execute(t);
	}
	catch (EndOfExecutionProducer::Exception)
	{
		m_impl->popProducer();
	}
	catch (...)
	{
		m_impl->popProducer();
		throw;
	}
}


void
Environment::perform(TokenP const& token, mstl::string& result)
{
	M_REQUIRE(token);

	ConsumerP oldConsumer = m_consumer;
	ConsumerP newConsumer(new TextConsumer(result)); // MEMORY
	m_consumer = newConsumer;

	ProducerP producer(new EndOfExecutionProducer()); // MEMORY
	m_impl->pushProducer(producer);

	try
	{
		putUnboundToken(token);

		while (TokenP t = m_impl->getFinalToken(*this, AllowNull))
			result += t->name();
	}
	catch (EndOfExecutionProducer::Exception)
	{
		m_consumer = oldConsumer;
		m_impl->popProducer();
	}
	catch (...)
	{
		m_consumer = oldConsumer;
		m_impl->popProducer();
		throw;
	}
}


void
Environment::addPackage(PackageP package)
{
	M_REQUIRE(package);
	m_impl->addPackage(package);
}


void
Environment::finishPackages()
{
	m_impl->finishPackages();
}


bool
Environment::containsPackage(mstl::string const& packageName) const
{
	return m_impl->containsPackage(packageName);
}


bool
Environment::usePackage(mstl::string const& name)
{
	return m_impl->usePackage(name);
}


Package*
Environment::getPackage(mstl::string const& name)
{
	return m_impl->getPackage(name);
}

// vi:set ts=3 sw=3:
