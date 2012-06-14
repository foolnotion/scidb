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

#include "T_TextToken.h"
#include "T_ListToken.h"
#include "T_TextProducer.h"
#include "T_Environment.h"
#include "T_AhoCorasick.h"

#include "m_vector.h"
#include "m_string.h"
#include "m_assert.h"

using namespace TeXt;


TextToken::TextToken()
{
}


TextToken::TextToken(mstl::string const& str)
	:m_str(str)
{
}


bool
TextToken::isEmpty() const
{
	return m_str.empty();
}


bool
TextToken::isEqualTo(Token const& token) const
{
	M_REQUIRE(dynamic_cast<TextToken const*>(&token));
	return m_str == static_cast<TextToken const&>(token).m_str;
}


RefID
TextToken::refID() const
{
	M_RAISE("unexpected invocation");
}


Token::Type
TextToken::type() const
{
	return T_Text;
}


mstl::string
TextToken::name() const
{
	return m_str;
}


mstl::string
TextToken::meaning() const
{
	return "the string \"" + m_str + "\"";
}


mstl::string
TextToken::text() const
{
	return m_str;
}


void
TextToken::perform(Environment& env)
{
	env.filter().put(env, m_str);
}


TokenP
TextToken::performThe(Environment& env) const
{
	return TokenP(new TextToken(m_str)); // MEMORY
}


Producer*
TextToken::getProducer(TokenP const& self) const
{
	M_REQUIRE(self.get() == this);
	return new TextProducer(m_str); // MEMORY
}


TextToken::TextP
TextToken::convert(Environment& env, TokenP token)
{
	switch (Token::Type type = token->type())
	{
		case Token::T_Text:
			// no action
			break;

		case Token::T_Ascii:
			token.reset(new TextToken(token->text())); // MEMORY
			break;

		case Token::T_Number:
			token.reset(new TextToken(token->text())); // MEMORY
			break;

		case Token::T_List:
			token.reset(new TextToken(token->text())); // MEMORY
			break;

		case Token::T_Undefined:
			{
				mstl::string result;
				env.perform(token, result);
				token.reset(new TextToken(result)); // MEMORY
			}
			break;

		default:
			switch (type)
			{
				case Token::T_LeftBrace:
					token.reset(new ListToken(env)); // MEMORY
					break;

				default:
					token.reset(new ListToken(token)); // MEMORY
					break;
			}
			static_cast<ListToken*>(token.get())->flatten();
			token.reset(new TextToken(token->text())); // MEMORY
			break;
	}

	return token;
}


namespace {

struct MultipleSearch : public AhoCorasick
{
	typedef mstl::vector<mstl::string const*> StringList;

	MultipleSearch(mstl::string const& text) :m_text(text), m_offset(0) {}

	void match(unsigned position, unsigned index, unsigned length) override
	{
		M_ASSERT(position >= m_offset);
		M_ASSERT(index < m_stringList.size());
		M_ASSERT(m_offset + length <= m_text.size());

		m_result.append(m_text, m_offset, position - m_offset);
		m_result.append(*m_stringList[index]);
		m_offset = position + length;
	}

	bool map(Environment& env, TextToken::ListP const& mapping)
	{
		mstl::vector<TokenP> tokens;
		unsigned n = mapping->length();

		tokens.reserve(mstl::div2(n));
		m_stringList.reserve(mstl::div2(n));

		for (unsigned i = 0; i < n; i += 2)
		{
			TextToken::TextP from(TextToken::convert(env, mapping->index(i)));
			TextToken::TextP to(TextToken::convert(env, mapping->index(i + 1)));

			tokens.push_back(to);
			m_stringList.push_back(&to->content());
			add(from->content());
		}

		bool rc = search(m_text);

		if (rc)
			m_result.append(m_text, m_offset, m_text.size() - m_offset);

		return rc;
	}

	mstl::string const&	m_text;
	StringList				m_stringList;
	mstl::string			m_result;
	unsigned					m_offset;
};

} // namespace


void
TextToken::map(Environment& env, ListP const& mapping)
{
	MultipleSearch search(m_str);

	if (search.map(env, mapping))
		m_str.swap(search.m_result);
}

// vi:set ts=3 sw=3:
