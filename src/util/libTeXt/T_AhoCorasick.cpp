// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2012-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "T_AhoCorasick.h"

#include "m_string.h"
#include "m_vector.h"
#include "m_chunk_allocator.h"
#include "m_algorithm.h"
#include "m_utility.h"
#include "m_assert.h"

#include <stdlib.h>

using namespace TeXt;


namespace {

typedef mstl::string::value_type Alpha;

class Node;


struct Edge
{
	Edge(Alpha alpha, Node* next) :m_alpha(alpha), m_next(next) {}

	Alpha m_alpha;
	Node* m_next;

	bool operator==(Alpha alpha) const { return m_alpha == alpha; }
	bool operator< (Alpha alpha) const { return m_alpha < alpha; }

	static int compare(void const* lhs, void const* rhs);
};


static inline bool
operator<(Alpha alpha, Edge const& edge)
{
	return alpha < edge.m_alpha;
}


int
Edge::compare(void const* lhs, void const* rhs)
{
	return int(static_cast<Edge const*>(lhs)->m_alpha) - int(static_cast<Edge const*>(rhs)->m_alpha);
}


struct Match
{
	Match() :m_index(0), m_length(0) {}
	Match(unsigned index, unsigned length) :m_index(index), m_length(length) {}

	unsigned m_index;
	unsigned m_length;
};


struct Node
{
	typedef mstl::vector<Edge>		Edges;
	typedef mstl::vector<Match>	Indices;
	typedef mstl::vector<Alpha>	Alphas;
	typedef mstl::vector<Node*>	Pool;

	typedef mstl::chunk_allocator<Node> Allocator;

	Node();

	Node* createNext(Allocator& allocator, Pool& pool, Alpha alpha);

	void unionMatches();
	void sortEdges();
	void traverse();
	void traverse(Node* root, Alphas& alphas);
	void setFailure(Node* root, Alphas const& alphas);

	Node* findNext(Alpha alpha);
	Node* findNextFast(Alpha alpha);

	bool		m_isFinal;
	Node*		m_failureNode;
	unsigned	m_depth;
	Edges		m_outgoing;
	Indices	m_indices;
};


Node::Node()
	:m_isFinal(false)
	,m_failureNode(0)
	,m_depth(0)
{
}


Node*
Node::findNext(Alpha alpha)
{
	M_ASSERT(alpha);
	Edges::iterator i = mstl::find(m_outgoing.begin(), m_outgoing.end(), alpha);
	return i == m_outgoing.end() ? 0 : i->m_next;
}


Node*
Node::findNextFast(Alpha alpha)
{
	M_ASSERT(alpha);
	Edges::iterator i = mstl::binary_search(m_outgoing.begin(), m_outgoing.end(), alpha);
	return i == m_outgoing.end() ? 0 : i->m_next;
}


Node*
Node::createNext(Allocator& allocator, Pool& pool, Alpha alpha)
{
	M_ASSERT(alpha);

	Node* next = findNext(alpha);

	if (next == 0)
	{
		pool.push_back(next = allocator.alloc());
		next->m_depth = m_depth + 1;
		m_outgoing.push_back(Edge(alpha, next));
	}

	return next;
}


void
Node::sortEdges()
{
	::qsort(m_outgoing.begin(), m_outgoing.size(), sizeof(Edges::value_type), Edge::compare);
}


void
Node::unionMatches()
{
	Node* node = this;

	while ((node = node->m_failureNode))
	{
		m_indices.insert(m_indices.end(), node->m_indices.begin(), node->m_indices.end());

		if (node->m_isFinal)
			m_isFinal = true;
	}
}


void
Node::setFailure(Node* root, Alphas const& alphas)
{
	M_ASSERT(alphas.size() > m_depth);

	m_failureNode = root;

	for (unsigned i = 1; i < m_depth; ++i)
	{
		Node* node = root;

		for (unsigned j = i; j < m_depth && node; ++j)
			node = node->findNext(alphas[j]);

		if (node)
		{
			m_failureNode = node;
			return;
		}
	}
}


void
Node::traverse(Node* root, Alphas& alphas)
{
	if (alphas.size() <= m_depth)
		alphas.resize(mstl::mul2(alphas.size()));

	for (unsigned i = 0; i < m_outgoing.size(); ++i)
	{
		Node* next = m_outgoing[i].m_next;

		alphas[m_depth] = m_outgoing[i].m_alpha;
		next->setFailure(root, alphas);
		next->traverse(root, alphas);
	}
}


void
Node::traverse()
{
	Alphas alphas;
	alphas.resize(100);
	traverse(this, alphas);
}

} // namespace


class AhoCorasick::Impl
{
public:

	Impl();

	bool add(mstl::string const& pattern);
	void prepareSearch();
	bool search(AhoCorasick& base, mstl::string const& text, Method method);

private:

	typedef mstl::vector<Match> Matches;
	typedef Node::Allocator Allocator;
	typedef Node::Pool Pool;

	Node*			m_root;
	Node*			m_current;
	unsigned		m_basePosition;
	unsigned		m_countPatterns;
	Allocator	m_allocator;
	Pool			m_pool;
};


AhoCorasick::Impl::Impl()
	:m_root(0)
	,m_current(0)
	,m_basePosition(0)
	,m_countPatterns(0)
	,m_allocator(65536)
{
	m_pool.push_back(m_current = m_root = m_allocator.alloc());
}


bool
AhoCorasick::Impl::add(mstl::string const& pattern)
{
	bool multipleMatches = false;

	if (!pattern.empty())
	{
		Node* node = m_root;

		for (unsigned i = 0; i < pattern.size(); i++)
			node = node->createNext(m_allocator, m_pool, pattern[i]);

		node->m_isFinal = true;
		node->m_indices.push_back(Match(m_countPatterns, pattern.size()));

		if (node->m_indices.size() > 1)
			multipleMatches = true;
	}

	++m_countPatterns;
	return multipleMatches;
}


void
AhoCorasick::Impl::prepareSearch()
{
	m_root->traverse();

	for (unsigned i = 0; i < m_pool.size(); ++i)
	{
		Node* node = m_pool[i];
		node->unionMatches();
		node->sortEdges();
	}
}


bool
AhoCorasick::Impl::search(AhoCorasick& base, mstl::string const& text, Method method)
{
	unsigned position = 0;
	bool matchFound = false;

	while (position < text.size())
	{
		Node* next = m_current->findNextFast(text[position]);

		if (next)
		{
			m_current = next;

			if (m_current->m_isFinal)
			{
				M_ASSERT(!m_current->m_indices.empty());

				matchFound = true;

				if (method == LongestMatchOnly)
				{
					Match match(0, 0);

					for (unsigned i = 0; i < m_current->m_indices.size(); ++i)
					{
						Match const& m = m_current->m_indices[i];

						if (m.m_length > match.m_length)
							match = m;
					}

					base.match(position + m_basePosition, match.m_index, match.m_length);
				}
				else
				{
					for (unsigned i = 0; i < m_current->m_indices.size(); ++i)
					{
						Match const& match = m_current->m_indices[i];
						base.match(position + m_basePosition, match.m_index, match.m_length);
					}
				}
			}

			++position;
		}
		else if (m_current->m_failureNode)
		{
			m_current = m_current->m_failureNode;
		}
		else
		{
			++position;
		}
	}

	m_basePosition += position;
	return matchFound;
}


AhoCorasick::AhoCorasick() :m_impl(new Impl), m_isPrepared(false) {}
AhoCorasick::~AhoCorasick() { delete m_impl; }

bool AhoCorasick::isPrepared() const { return m_isPrepared; }


bool
AhoCorasick::add(mstl::string const& pattern)
{
	M_REQUIRE(!isPrepared());
	return m_impl->add(pattern);
}


bool
AhoCorasick::search(mstl::string const& text, Method method)
{
	if (!m_isPrepared)
	{
		m_isPrepared = true;
		m_impl->prepareSearch();
	}

	return m_impl->search(*this, text, method);
}

// vi:set ts=3 sw=3:
