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

#include "T_ListToken.h"
#include "T_Environment.h"
#include "T_Producer.h"

#include "m_assert.h"
#include "m_cast.h"
#include "m_algorithm.h"
#include "m_iterator.h"

using namespace TeXt;


ListToken::TokenProducer::TokenProducer(TokenP const& token)
	:fToken(token)
	,fIter(fToken->m_tokenList.begin())
{
}


bool
ListToken::TokenProducer::finished() const
{
	return fIter == fToken->m_tokenList.end();
}


Producer::Source
ListToken::TokenProducer::source() const
{
	return List;
}


TokenP
ListToken::TokenProducer::next(Environment&)
{
	return (fIter == fToken->m_tokenList.end()) ? TokenP() : *(fIter++);
}


bool
ListToken::TokenProducer::reset()
{
	fIter = fToken->m_tokenList.begin();
	return true;
}


mstl::string
ListToken::TokenProducer::currentDescription() const
{
	if (fIter == fToken->m_tokenList.begin())
		return mstl::string::empty_string;

	return fToken->meaning(fIter - 1);
}


ListToken::ListToken()
{
}


ListToken::ListToken(Environment& env)
{
	while (true)
	{
		TokenP token = env.getUndefinedToken();

		switch (token->type())
		{
			case Token::T_LeftBrace:
				token.reset(new ListToken(env)); // MEMORY
				break;

			case Token::T_RightBrace:
				return;

			default:
				break;
		}

		append(token);
	}
}


ListToken::ListToken(TokenP const& token)
	:m_tokenList(1, token)
{
}


ListToken::ListToken(unsigned n, TokenP const& token)
	:m_tokenList(n, token)
{
}


ListToken::ListToken(Environment& env, mstl::string const& text)
{
	for (mstl::string::const_iterator i = text.begin(), e = text.end(); i != e; ++i)
		m_tokenList.push_back(env.asciiToken(*i));
}


bool
ListToken::isEqualTo(Token const& token) const
{
	M_REQUIRE(dynamic_cast<ListToken const*>(&token));

	if (m_tokenList.size() != static_cast<ListToken const&>(token).m_tokenList.size())
		return false;

	for (unsigned i = 0; i < m_tokenList.size(); ++i)
	{
		Token const* lhs = m_tokenList[i].get();
		Token const* rhs = static_cast<ListToken const&>(token).m_tokenList[i].get();

		if (!(*lhs == *rhs))
			return false;
	}

	return true;
}


Token::Type
ListToken::type() const
{
	return T_List;
}


mstl::string
ListToken::name() const
{
	mstl::string	result;
	bool				space		= false;

	for (TokenList::const_iterator i = m_tokenList.begin(); i != m_tokenList.end(); ++i)
	{
		Type type = (*i)->type();

		if (space)
		{
			result += ' ';
			space = false;
		}

		switch (type)
		{
			case T_List:
				result += '{';
				result += (*i)->name();
				result += '}';
				space = true;
				break;

			case T_Text:
			case T_Ascii:
				result += '\"';
				result += (*i)->name();
				result += '\"';
				space = true;
				break;

			default:
				result += (*i)->name();
				space = type == T_Undefined || type == T_Variable || type == T_Number;
				break;
		}
	}

	return result;
}


mstl::string
ListToken::meaning(TokenList::const_iterator breakPoint) const
{
	mstl::string	result;
	bool				space		= false;

	for (TokenList::const_iterator i = m_tokenList.begin(); i != m_tokenList.end(); ++i)
	{
		Type type = (*i)->type();

		if (space)
		{
			result += ' ';
			space = false;
		}

		if (type == T_List)
		{
			result += "{";
			result += (*i)->name();
			result += "}";
		}
		else
		{
			result += (*i)->name();
			space = type == T_Undefined || type == T_Variable || type == T_Number;
		}

		if (i == breakPoint)
			result += '\n';
	}

	return result;
}


mstl::string
ListToken::meaning() const
{
	mstl::string result;
	result += "list: ";
	result += meaning(m_tokenList.end());
	return result;
}


mstl::string
ListToken::description(Environment& env) const
{
	mstl::string	result;
	bool				space		= false;

	for (TokenList::const_iterator i = m_tokenList.begin(); i != m_tokenList.end(); ++i)
	{
		Type type = (*i)->type();

		if (space)
		{
			result += ' ';
			space = false;
		}

		if (type == T_List)
		{
			result += "{";
			result += (*i)->description(env);
			result += "}";
		}
		else
		{
			result += (*i)->description(env);
			space = type == T_Undefined || type == T_Variable;
		}
	}

	return result;
}


bool
ListToken::isEmpty() const
{
	return length() == 0;
}


Producer*
ListToken::getProducer(TokenP const& self) const
{
	M_REQUIRE(self.get() == this);

	return new TokenProducer(self); // MEMORY
}


TokenP
ListToken::performThe(Environment& env) const
{
	mstl::ref_counted_ptr<ListToken> result(new ListToken); // MEMORY

	for (TokenList::const_iterator i = m_tokenList.begin(), e = m_tokenList.end(); i != e; ++i)
	{
		TokenP token = (*i)->performThe(env);
		result->append(token ? token : *i);
	}

	return result;
}


void
ListToken::perform(Environment& env)
{
	if (!isEmpty())
		env.pushProducer(Environment::ProducerP(getProducer(env.currentToken())));
}


void
ListToken::traceCommand(Environment&) const
{
	// no action
}


TokenP
ListToken::front() const
{
	M_REQUIRE(!isEmpty());
	return *m_tokenList.begin();
}


TokenP
ListToken::back() const
{
	M_REQUIRE(!isEmpty());
	return *(m_tokenList.end() - 1);
}


void
ListToken::append(TokenP const& token)
{
	m_tokenList.push_back(token);
}


void
ListToken::append(Token* token)
{
	append(TokenP(token));
}


void
ListToken::append(Value value1, Value value2)
{
	ListToken* list = new ListToken; // MEMORY
	list->append(value1);
	list->append(value2);
	append(list);
}


void
ListToken::append(Value value1, Value value2, Value value3)
{
	ListToken* list = new ListToken; // MEMORY
	list->append(value1);
	list->append(value2);
	list->append(value3);
	append(list);
}


void
ListToken::append(Value value1, Value value2, Value value3, Value value4)
{
	ListToken* list = new ListToken; // MEMORY
	list->append(value1);
	list->append(value2);
	list->append(value3);
	list->append(value4);
	append(list);
}


void
ListToken::append(Value const* first, Value const* last)
{
	M_REQUIRE(first || last == 0);
	M_REQUIRE(first <= last);

	ListToken* list = new ListToken; // MEMORY

	for ( ; first < last; ++first)
			list->append(*first);

	append(list);
}


void
ListToken::prepend(TokenP const& token)
{
	m_tokenList.push_front(token);
}


void
ListToken::popFront()
{
	M_ASSERT(!isEmpty());
	m_tokenList.pop_front();
}


void
ListToken::popBack()
{
	M_ASSERT(!isEmpty());
	m_tokenList.pop_back();
}


void
ListToken::reverse()
{
	mstl::reverse(m_tokenList.begin(), m_tokenList.end());
}


void
ListToken::rotate(Value n)
{
	mstl::rotate(m_tokenList.begin(), m_tokenList.begin() + (n % length()), m_tokenList.end());
}


void
ListToken::flatten()
{
	TokenList list;
	flatten(m_tokenList.begin(), m_tokenList.end(), list);
	m_tokenList.swap(list);
}


void
ListToken::flatten(TokenList::const_iterator first, TokenList::const_iterator last, TokenList& receiver)
{
	for ( ; first != last; ++first)
	{
		if ((*first)->type() == T_List)
		{
			ListToken const* list = mstl::safe_cast_ptr<ListToken const>(first->get());
			flatten(list->m_tokenList.begin(), list->m_tokenList.end(), receiver);
		}
		else
		{
			receiver.push_back(*first);
		}
	}
}


Value
ListToken::find(TokenP const& token) const
{
	Value n = 0;

	for (TokenList::const_iterator i = m_tokenList.begin(), e = m_tokenList.end(); i != e; ++i, ++n)
	{
		if ((*i)->type() == token->type() && (*i)->name() == token->name())
			return n;
	}

	return -1;
}


TokenP
ListToken::index(Value n) const
{
	if (0 <= n && n < Value(m_tokenList.size()))
		return m_tokenList[n];

	return TokenP();
}


void
ListToken::appendTo(ListToken& list) const
{
	mstl::copy(m_tokenList.begin(), m_tokenList.end(), mstl::back_inserter(list.m_tokenList));
}


void
ListToken::set(Value index, TokenP const& token)
{
	M_REQUIRE(token);
	M_REQUIRE(index <= length());

	if (index == Value(m_tokenList.size()))
		m_tokenList.push_back(token);
	else
		m_tokenList[index] = token;
}


void
ListToken::resize(unsigned n, TokenP value)
{
	m_tokenList.resize(n, value);
}


void
ListToken::set(unsigned at, TokenP value)
{
	M_REQUIRE(at < size());
	m_tokenList[at] = value;
}


void
ListToken::fill(unsigned from, unsigned to, TokenP value)
{
	M_REQUIRE(from <= to);
	M_REQUIRE(to < size());

	mstl::fill(m_tokenList.begin() + from, m_tokenList.begin() + to, value);
}


void
ListToken::bind(Environment& env)
{
	for (unsigned i = 0; i < m_tokenList.size(); ++i)
	{
		TokenP token = m_tokenList[i];

		if (token->type() == T_List)
		{
			mstl::safe_cast_ptr<ListToken>(token.get())->bind(env);
		}
		else if (!token->isFinal())
		{
			if (TokenP t = env.lookupMacro(token->refID()))
				m_tokenList[i] = t;
		}
	}
}

// vi:set ts=3 sw=3:
