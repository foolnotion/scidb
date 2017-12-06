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
// Copyright: (C) 2009-2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "db_move_list.h"

#include "m_algorithm.h"
#include "m_utility.h"
#include "m_stdio.h"
#include "m_assert.h"

#include <string.h>
#include <ctype.h>

using namespace db;


template <unsigned N>
MoveBuffer<N>::MoveBuffer(Move move)
	:m_size(1)
{
	m_buffer[0] = move;
}


template <unsigned N>
MoveBuffer<N>::MoveBuffer(const_iterator first, const_iterator last)
{
	m_size = mstl::min(ptrdiff_t(Maximum_Moves), mstl::distance(first, last));

	for (unsigned i = 0; i < m_size; ++i)
		m_buffer[i] = *first++;
}


template <unsigned N>
MoveBuffer<N>&
MoveBuffer<N>::operator=(MoveBuffer const& list)
{
	static_assert(mstl::is_pod<Move>::value, "POD required");

	if (&list != this)
		::memcpy(m_buffer, list.m_buffer, (m_size = list.m_size)*sizeof(m_buffer[0]));

	return *this;
}


template <unsigned N>
void
MoveBuffer<N>::copy(Move* destination, unsigned size) const
{
	M_REQUIRE(destination || size == 0);

	static_assert(mstl::is_pod<Move>::value, "POD required");
	::memcpy(destination, m_buffer, size*sizeof(m_buffer[0]));
}


template <unsigned N>
void
MoveBuffer<N>::fill(MoveBuffer const& source, unsigned size)
{
	M_REQUIRE(size <= source.size());

	static_assert(mstl::is_pod<Move>::value, "POD required");
	::memcpy(m_buffer, source.m_buffer, (m_size = size)*sizeof(m_buffer[0]));
}


template <unsigned N>
int
MoveBuffer<N>::find(uint16_t move) const
{
	for (unsigned i = 0; i < m_size; ++i)
	{
		if (m_buffer[i].index() == move)
			return i;
	}

	return -1;
}


template <unsigned N>
unsigned
MoveBuffer<N>::match(MoveBuffer const& list, unsigned length) const
{
	M_REQUIRE(length <= size());
	M_REQUIRE(length <= list.size());

	for (unsigned i = 0; i < length; ++i)
	{
		if (m_buffer[i] != list.m_buffer[i])
			return i;
	}

	return length;
}


template <unsigned N>
void
MoveBuffer<N>::prepend(Move const& m)
{
	M_ASSERT(m_size < U_NUMBER_OF(m_buffer));

	::memmove(m_buffer + 1, m_buffer, m_size*sizeof(m_buffer[0]));
	m_buffer[0] = m;
}


template <unsigned N>
void
MoveBuffer<N>::sort(int scores[])
{
	// require: #scores >= size()

	if (size() <= 1)
		return;

	for (unsigned k = 0, n = m_size - 1; k < n; ++k)
	{
		unsigned index = k;

		int score = scores[index];

		for (unsigned i = k + 1; i < m_size; ++i)
		{
			if (score < scores[i])
				score = scores[index = i];
		}

		if (index > k)
		{
			mstl::swap(scores[k], scores[index]);
			mstl::swap(m_buffer[k], m_buffer[index]);
		}
	}
}


template <unsigned N>
void
MoveBuffer<N>::sort(unsigned startIndex, int scores[])
{
	M_REQUIRE(startIndex < size());
	// require: #scores >= size()

	int score = scores[startIndex];

	unsigned index = startIndex;

	for (unsigned i = startIndex + 1; i < m_size; ++i)
	{
		if (score < scores[i])
			score = scores[index = i];
	}

	if (index > startIndex)
	{
		mstl::swap(scores[startIndex], scores[index]);
		mstl::swap(m_buffer[startIndex], m_buffer[index]);
	}
}


template <unsigned N>
void
MoveBuffer<N>::rotate(unsigned first, unsigned middle, unsigned last)
{
	M_REQUIRE(first <= middle);
	M_REQUIRE(middle <= last);
	M_REQUIRE(last <= size());

	mstl::rotate(m_buffer + first, m_buffer + middle, m_buffer + last);
}


template <unsigned N>
mstl::string&
MoveBuffer<N>::print(mstl::string& result,
							unsigned halfMoveNo,
							unsigned maxMoveNo,
							bool forDisplay) const
{
	if (!isEmpty())
	{
		bool atStart = result.empty();

		if (maxMoveNo > m_size)
			maxMoveNo = m_size;
		else
			maxMoveNo = mstl::min(m_size, maxMoveNo + halfMoveNo);

		if (atStart || mstl::is_even(halfMoveNo))
		{
			result.format("%u", mstl::div2(halfMoveNo) + 1);
			result.append('.');

			if (mstl::is_odd(halfMoveNo))
				result.append("..", 2);
		}
		else if (!atStart && !::isspace(result.back()))
		{
			result.append(' ');
		}

		Move const& move = m_buffer[0];

		if (forDisplay)
			move.printForDisplay(result, move::SAN);
		else
			move.printSAN(result, protocol::Scidb, encoding::Latin1);

		halfMoveNo += 1;

		for (unsigned index = 1; index < maxMoveNo; ++index, ++halfMoveNo)
		{
			Move const& move = m_buffer[index];

			result.append(' ');

			if (mstl::is_even(halfMoveNo))
			{
				result.format("%u", mstl::div2(halfMoveNo) + 1);
				result.append('.');
			}

			if (forDisplay)
				move.printForDisplay(result, move::SAN);
			else
				move.printSAN(result, protocol::Scidb, encoding::Latin1);
		}
	}

	return result;
}


template <unsigned N>
void
MoveBuffer<N>::dump()
{
	::printf("Moves(%u)\n", m_size);
	for (unsigned i = 0; i < m_size; ++i)
	{
		::printf("  %2u: ", i + 1);
		m_buffer[i].dump();
	}
	::fflush(stdout);
}


namespace db {

template class MoveBuffer<position::Maximum_Moves>;
template class MoveBuffer<opening::Max_Line_Length>;

} // namespace db

// vi:set ts=3 sw=3:
