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

#ifndef _db_move_list_included
#define _db_move_list_included

#include "db_move.h"

#include "m_pointer_iterator.h"
#include "m_iterator.h"

namespace db {

template <unsigned N>
class MoveBuffer
{
public:

	enum { Maximum_Moves = position::Maximum_Moves };

	typedef mstl::pointer_iterator<Move>			iterator;
	typedef mstl::pointer_const_iterator<Move>	const_iterator;

	typedef mstl::reverse_iterator<iterator>					reverse_iterator;
	typedef mstl::const_reverse_iterator<const_iterator>	const_reverse_iterator;

	typedef const_iterator Iterator;

	MoveBuffer();
	MoveBuffer(Move move);
	MoveBuffer(const_iterator first, const_iterator last);

	MoveBuffer& operator=(MoveBuffer const& list);

	bool operator==(MoveBuffer const& list) const;
	bool operator!=(MoveBuffer const& list) const;

	Move const& operator[](unsigned n) const;
	Move& operator[](unsigned n);

	Move const& front() const;
	Move const& back() const;

	bool isEmpty() const;
	bool isFull() const;
	bool notFull() const;

	unsigned size() const;
	int find(uint16_t move) const;
	unsigned match(MoveBuffer const& list) const;
	unsigned match(MoveBuffer const& list, unsigned length) const;

	const_iterator begin() const;
	const_iterator end() const;
	iterator begin();
	iterator end();

	const_reverse_iterator rbegin() const;
	const_reverse_iterator rend() const;
	reverse_iterator rbegin();
	reverse_iterator rend();

	void append(Move const& m);
	void prepend(Move const& m);
	void push(Move const& m);
	Move& pop();
	void cut(unsigned size);
	void clear();

	void sort(int scores[]);
	void sort(unsigned startIndex, int scores[]);
	void rotate(unsigned first, unsigned middle, unsigned last);
	void swap(unsigned index1, unsigned index2);

	void copy(Move* destination, unsigned size) const;
	void fill(MoveBuffer const& source, unsigned size);

	mstl::string& print(	mstl::string& result,
								unsigned halfMoveNo = 0,
								unsigned maxMoveNo = unsigned(-1)) const;
	mstl::string& dump(	mstl::string& result,
								unsigned halfMoveNo = 0,
								unsigned maxMoveNo = unsigned(-1)) const;
	void dump();

private:

	friend class Permutator;

	mstl::string& print(	mstl::string& result,
								unsigned halfMoveNo,
								unsigned maxMoveNo,
								bool forDisplay) const;

	unsigned	m_size;
	Move		m_buffer[Maximum_Moves];
};

typedef MoveBuffer<position::Maximum_Moves>	MoveList;
typedef MoveBuffer<opening::Max_Line_Length>	MoveLine;

} // namespace db

namespace mstl {

template <typename T> struct is_pod;
template <> struct is_pod<db::MoveList> { enum { value = is_pod<db::Move>::value }; };
template <> struct is_pod<db::MoveLine> { enum { value = is_pod<db::Move>::value }; };

} // namespace mstl

#include "db_move_list.ipp"

#endif // _db_move_buffer_included

// vi:set ts=3 sw=3:
