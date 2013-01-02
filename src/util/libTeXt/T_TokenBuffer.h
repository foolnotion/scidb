// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2009-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _TeXt_TokenBuffer_included
#define _TeXt_TokenBuffer_included

#include "T_Base.h"
#include "T_TokenP.h"

#include "m_shared_ptr.h"
#include "m_tuple.h"
#include "m_string.h"
#include "m_vector.h"
#include "m_pvector.h"
#include "m_hash.h"

namespace mstl { class ostream; }

namespace TeXt {

class Token;

class TokenBuffer
{
public:

	struct TokenGenerator
	{
		virtual ~TokenGenerator();
		virtual Token* newToken(mstl::string const& name, RefID refID) const = 0;
	};

	TokenBuffer();

	bool contains(mstl::string const& name) const;
	bool contains(RefID refID) const;

	unsigned size() const;
	unsigned countTokens() const;

	TokenP lookupToken(unsigned level, RefID refID) const;
	TokenP getToken(RefID index) const;

	void setupToken(RefID refID, TokenP const& token);
	TokenP setupToken(mstl::string const& name, TokenGenerator const& tokenGenerator);
	void bindTopLevelToken(RefID refID, TokenP const& token);
	void bindToken(unsigned level, RefID refID, TokenP const& token);
	void upToken(unsigned level, RefID refID, unsigned nlevels);

	void push();
	void pop();

	void dump(mstl::ostream& os) const;

private:

	class Index
	{
	public:

		Index();
		bool isNull() const;
		operator RefID () const;
		Index& operator=(RefID n);

	private:

		Value N;
	};

	typedef uint32_t ID;

	typedef mstl::tuple<RefID,TokenP>			Entry;
	typedef mstl::tuple<ID,unsigned,unsigned>	Rel;
	typedef mstl::vector<Rel>						Relations;
	typedef mstl::vector<Entry>					Domain;
	typedef mstl::shared_ptr<Domain>				DomainP;
	typedef mstl::tuple<ID,DomainP>				DomainEntry;
	typedef mstl::vector<DomainEntry>			DomainStack;
	typedef mstl::pvector<Relations>				RelList;
	typedef mstl::hash<mstl::string,Index>		RelIndexMap;
	typedef mstl::vector<TokenP>					RootEntries;

	Entry const* lookup(unsigned level, RefID refID) const;

	ID				m_domainID;
	DomainStack	m_domainStack;
	RelIndexMap	m_relIndexMap;
	RelList		m_relList;
	RootEntries	m_rootEntries;
};

} // namespace TeXt

#include "T_TokenBuffer.ipp"

#endif // _TeXt_TokenBuffer_included

// vi:set ts=3 sw=3:
