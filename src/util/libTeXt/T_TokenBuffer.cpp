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

#include "T_TokenBuffer.h"
#include "T_Token.h"
#include "T_UndefinedToken.h"

#include "m_ostream.h"
#include "m_assert.h"

using namespace TeXt;


namespace {
	namespace idx {

		// domain stack
		static int const ID			= 0;
		static int const Entries	= 1;

		// relation list
		static int const DomainID	= 0;
		static int const Level		= 1;
		static int const Index		= 2;

		// entry list
		static int const RefID		= 0;
		static int const Token		= 1;

	} // namespace idx
} // namespace


inline TokenBuffer::Index::Index() : N(-1) {}
inline bool TokenBuffer::Index::isNull() const { return N == -1; }
inline TokenBuffer::Index::operator RefID () const { return N; }
inline TokenBuffer::Index& TokenBuffer::Index::operator=(RefID n) { N = n; return *this; }


TokenBuffer::TokenGenerator::~TokenGenerator()
{
	// no action
}


TokenBuffer::TokenBuffer()
	:m_domainID(0)
	,m_relIndexMap(512)
{
	m_domainStack.push_back(DomainEntry(m_domainID++, DomainP(new Domain)));
}


void
TokenBuffer::push()
{
	m_domainStack.push_back(DomainEntry(m_domainID++, DomainP()));
}


void
TokenBuffer::setupToken(RefID refID, TokenP const& token)
{
	M_REQUIRE(refID < Token::T_FirstGenericType);

	if (refID >= m_rootEntries.size())
	{
		m_rootEntries.resize(refID + 1, TokenP());
		m_relList.resize(refID + 1, Relations());
	}

	DomainEntry& domain = m_domainStack.front();

	m_rootEntries[refID] = token;
	domain.get<idx::Entries>()->push_back(Entry(refID, token));
	m_relList[refID].push_back(Rel(domain.get<idx::ID>(), 0, domain.get<idx::Entries>()->size() - 1));
}


TokenP
TokenBuffer::setupToken(mstl::string const& name, TokenGenerator const& tokenGenerator)
{
	M_REQUIRE(!name.empty());

	RelIndexMap::reference index = m_relIndexMap.find_or_insert(name, Index());

	if (index.isNull())
	{
		M_ASSERT(!m_domainStack.empty());

		TokenP token(tokenGenerator.newToken(name, m_relList.size()));
		index = token->refID();

		if (size_t(index) >= m_relList.size())
		{
			m_rootEntries.resize(index + 1, TokenP());
			m_relList.resize(index + 1, Relations());
		}

		m_rootEntries[index] = token;
	}

	return m_rootEntries[index];
}


void
TokenBuffer::bindTopLevelToken(RefID refID, TokenP const& token)
{
	M_REQUIRE(!m_domainStack.empty());
	M_REQUIRE(refID < m_relList.size());
	M_REQUIRE(token.get());

	Domain&		domain	= *m_domainStack.front().get<idx::Entries>();
	Relations&	r			= m_relList[refID];

	if (r.empty() || r.front().get<idx::Level>() > 0)
	{
		domain.push_back(Entry(refID, token));
		r.insert(r.begin(), Rel(m_domainStack.front().get<idx::ID>(), 0, domain.size() - 1));
	}
	else
	{
		domain[r.front().get<idx::Index>()].get<idx::Token>() = token;
	}
}


void
TokenBuffer::bindToken(unsigned level, RefID refID, TokenP const& token)
{
	M_REQUIRE(size() > level);
	M_REQUIRE(refID < m_relList.size());
	M_REQUIRE(token.get());

	DomainEntry&	entry		= m_domainStack[level];
	Domain*			domain	= entry.get<idx::Entries>().get();

	if (!domain)
		entry.get<idx::Entries>().reset(domain = new Domain);

	ID				domID	= m_domainStack[level].get<idx::ID>();
	Relations&	r		= m_relList[refID];
	long			k		= mstl::min(long(level), long(r.size()) - 1);

	if (k == -1 || r[k].get<idx::Level>() < level)
	{
		domain->push_back(Entry(refID, token));
		r.push_back(Rel(domID, level, domain->size() - 1));
	}
	else
	{
		while (k > 0 && r[k - 1].get<idx::Level>() >= level)
			--k;

		if (r[k].get<idx::Level>() > level)
		{
			domain->push_back(Entry(refID, token));
			r.insert(r.begin() + k, Rel(domID, level, domain->size() - 1));
		}
		else
		{
			if (r[k].get<idx::DomainID>() == domID)
			{
				(*domain)[r[k].get<idx::Index>()].get<idx::Token>() = token;
			}
			else
			{
				domain->push_back(Entry(refID, token));
				r[k].get<idx::Index>() = domain->size() - 1;
				r[k].get<idx::DomainID>() = domID;
			}
		}
	}
}


void
TokenBuffer::upToken(unsigned level, RefID refID, unsigned nlevels)
{
	M_REQUIRE(size() > level);
	M_REQUIRE(nlevels <= level);

	Entry const* entry = lookup(level, refID);

	if (entry)
		bindToken(level - nlevels, refID, entry->get<idx::Token>());
}


TokenBuffer::Entry const*
TokenBuffer::lookup(unsigned level, RefID refID) const
{
	M_REQUIRE(refID < m_relList.size());

	Relations const& relations = m_relList[refID];

	if (relations.empty())
		return 0;

	Relations::const_iterator b = relations.begin();
	Relations::const_iterator r = b + mstl::min(long(level), long(relations.size()) - 1);

	while (r != b && (r - 1)->get<idx::Level>() >= level)
		--r;
	while (r >= b && r->get<idx::Level>() >= m_domainStack.size())
		--r;
	while (r >= b && r->get<idx::DomainID>() != m_domainStack[r->get<idx::Level>()].get<idx::ID>())
		--r;

	if (r < b)
		return 0;

	M_ASSERT(m_domainStack[r->get<idx::Level>()].get<idx::Entries>());
	M_ASSERT(m_domainStack[r->get<idx::Level>()].get<idx::Entries>()->size() > r->get<idx::Index>());

	return &(*m_domainStack[r->get<idx::Level>()].get<idx::Entries>())[r->get<idx::Index>()];
}


TokenP
TokenBuffer::lookupToken(unsigned level, RefID refID) const
{
	M_REQUIRE(refID < m_relList.size());
	M_REQUIRE(!m_domainStack.empty());

	Entry const* entry = lookup(mstl::min(size_t(level), m_domainStack.size() - 1), refID);
	return entry == 0 ? TokenP() : entry->get<idx::Token>();
}


void
TokenBuffer::dump(mstl::ostream& os) const
{
	for (RefID i = 0; i < countTokens(); ++i)
	{
		TokenP token = getToken(i);

		os.write("RefID ", 6);
		os.format("%5u", unsigned(i));
		os.write(": ", 2);

		if (token)
		{
			switch (token->type())
			{
				case Token::T_Undefined:
				case Token::T_Macro:
				case Token::T_Generic:
				case Token::T_Value:
					os.write(token->name());
					os.write(" = ", 3);
					os.writenl(token->meaning());
					break;

				case Token::T_List:
				case Token::T_Number:
				case Token::T_Text:
					os.writenl(token->meaning());
					break;

				default:
					os.writenl(token->meaning());
					break;
			}
		}
	}
}

// vi:set ts=3 sw=3:
