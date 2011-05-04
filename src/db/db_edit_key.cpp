// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
//    _/|            __
//   // o\         /    )           ,        /    /
//   || ._)    ----\---------__----------__-/----/__-
//   //__\          \      /   '  /    /   /    /   )
//   )___(     _(____/____(___ __/____(___/____(___/_
// ======================================================================

// ======================================================================
// Copyright: (C) 2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "db_edit_key.h"
#include "db_game.h"
#include "db_board.h"
#include "db_move_node.h"

#include "m_utility.h"
#include "m_stdio.h"
#include "m_assert.h"

#include <ctype.h>

using namespace db::edit;


inline static char const*
skipPrefix(char const* s)
{
	return isalpha(*s) ? s + 2 : s;
}


Key::Key() :m_id("0") {}
Key::Key(unsigned firstPly) :m_id("0") { addPly(firstPly); }
Key::Key(mstl::string const& key) :m_id(key) { M_REQUIRE(isValid(key)); }


Key::Key(Key const& key, char prefix)
{
	M_REQUIRE(::isalpha(prefix));

	m_id.reserve(key.m_id.size() + 2);
	m_id += prefix;
	m_id += '-';
	m_id += key.m_id;
}


bool

Key::isPrefixed() const
{
	return ::isalpha(m_id[0]);
}


char
Key::prefix() const
{
	return ::isalpha(m_id[0]) ? m_id[0] : '\0';
}


bool
Key::isVariationId() const
{
	unsigned level = 0;

	for (char const *s = ::skipPrefix(m_id); *s; ++s)
	{
		if (*s == '.')
			++level;
	}

	return mstl::is_even(level);
}


bool
Key::isMainlineId() const
{
	unsigned level = 0;

	for (char const *s = ::skipPrefix(m_id); *s; ++s)
	{
		if (*s == '.' && ++level == 2)
			return false;
	}

	return true;
}


unsigned
Key::level() const
{
	unsigned level = 0;

	for (char const *s = ::skipPrefix(m_id); *s; ++s)
	{
		if (*s == '.')
			++level;
	}

	return mstl::div2(level);
}


void
Key::addPly(unsigned ply)
{
	M_REQUIRE(isVariationId());

	char buf[32];
	m_id.append(buf, ::sprintf(buf, ".%u", ply));
}


void
Key::exchangePly(unsigned ply)
{
	M_REQUIRE(!isVariationId());

	char buf[32];

	unsigned pos = m_id.find_last_of('.') + 1;
	m_id.replace(pos, m_id.size() - pos, buf, ::sprintf(buf, "%u", ply));
}


void
Key::removePly()
{
	M_REQUIRE(!isVariationId());
	m_id.erase(m_id.find_last_of('.'), mstl::string::npos);
}


void
Key::addVariation(unsigned varno)
{
	M_REQUIRE(!isVariationId());

	char buf[32];
	m_id.append(buf, ::sprintf(buf, ".%u", varno));
}


void
Key::exchangeVariation(unsigned varno)
{
	M_REQUIRE(isVariationId());
	M_REQUIRE(level() > 0);

	char buf[32];

	unsigned pos = m_id.find_last_of('.')  + 1;
	m_id.replace(pos, m_id.size() - pos, buf, ::sprintf(buf, "%u", varno));
}


void
Key::removeVariation()
{
	M_REQUIRE(isVariationId());
	M_REQUIRE(level() > 0);

	m_id.erase(m_id.find_last_of('.'), mstl::string::npos);
}


void
Key::exchangePrefix(char prefix)
{
	M_REQUIRE(isPrefixed());
	m_id[0] = prefix;
}


void
Key::clear()
{
	if (::isalpha(m_id[0]))
	{
		m_id.erase(3);
		m_id[2] = '0';
	}
	else
	{
		m_id.assign("0", 1);
	}
}


void
Key::reset(unsigned firstPly)
{
	if (::isalpha(m_id[0]))
	{
		m_id.erase(4);
		m_id[2] = '0';
		m_id[3] = '.';
	}
	else
	{
		m_id.assign("0.", 2);
	}

	m_id.format("%u", firstPly);
}


bool
Key::isValid(mstl::string const& key)
{
	char const* s = key;

	if (::isalpha(*s))
	{
		if (s[1] != '-')
			return false;

		s += 2;
	}

	if (*s++ != '0')
		return false;

	while (*s)
	{
		if (*s++ != '.')
			return false;

		if (*s == '0')
		{
			++s;
		}
		else
		{
			if (!::isdigit(*s++))
				return false;

			while (::isdigit(*s))
				++s;
		}
	}

	return true;
}


bool
Key::setPosition(Game& game) const
{
	game.moveToMainlineStart();

	char const* s = ::skipPrefix(m_id);

	if (s[1] == '\0')
		return true;

	s += 2;
;
	char* e = 0;

	int plyNumber = game.startBoard().plyNumber();

	while (*s)
	{
		unsigned num = ::strtoul(s, &e, 10) - plyNumber;

		if (game.forward(num) != num)
			return false;

		s = *e == '.' ? e + 1 : e;

		if (*e)
		{
			unsigned varNo = ::strtoul(s, &e, 10);

			if (varNo >= game.variationCount())
				return false;

			game.enterVariation(varNo);
			s = *e == '.' ? e + 1 : e;
		}

		plyNumber = game.board().plyNumber();
	}

	return true;
}


bool
Key::setBoard(MoveNode const* root, Board& board) const
{
	M_REQUIRE(root);

	MoveNode const*	node	= root;
	char const*			s		= ::skipPrefix(m_id);
	char*					e		= 0;

	if (s[1])
	{
		s += 2;

		int plyNumber = board.plyNumber();

		while (*s)
		{
			int num = ::strtoul(s, &e, 10) - plyNumber;

			for ( ; num > 0; --num)
			{
				if (!node->atLineStart())
					board.doMove(node->move());

				if ((node = node->next()) == 0)
					return false;
			}

			s = *e == '.' ? e + 1 : e;

			if (*e)
			{
				unsigned varNo = ::strtoul(s, &e, 10);

				if (varNo >= node->variationCount())
					return false;

				node = node->variation(varNo);
				s = *e == '.' ? e + 1 : e;
			}

			plyNumber = board.plyNumber();
		}
	}

	if (!node->atLineStart())
		board.doMove(node->move());

	return true;
}


unsigned
Key::plyNumber() const
{
	char const* s = m_id.end();
	char const* t = ::skipPrefix(m_id);

	while (s > t && s[-1] != '.')
		--s;
	return ::strtoul(s, 0, 10);
}


int
Key::computeDistance(Key const& key) const
{
	M_REQUIRE(level() == key.level());
	M_REQUIRE(isVariationId() == key.isVariationId());

	return int(plyNumber()) - int(key.plyNumber());
}


Key&
Key::strip()
{
	if (::isalpha(*m_id.c_str()))
		m_id.erase(0u, 2u);

	return *this;
}

// vi:set ts=3 sw=3:
