// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $HeadURL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2014 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _mstl_range_included
#define _mstl_range_included

namespace mstl {

template <typename T = unsigned>
class range
{
public:

	typedef T value_type;

	class iterator
	{
	public:

		iterator(value_type i = 0);

		bool operator==(iterator const& i) const;
		bool operator!=(iterator const& i) const;
		bool operator<=(iterator const& i) const;
		bool operator< (iterator const& i) const;

		iterator& operator++();
		iterator operator++(int);

		value_type const* operator->() const;
		value_type operator*() const;

	private:

		value_type m_i;
	};

	range();
	explicit range(bool flag);
	range(value_type left, value_type right);

	bool operator==(range const& r) const;
	bool operator!=(range const& r) const;

	range& operator|=(range const& r);
	range& operator&=(range const& r);
	range& operator-=(range const& r);

	range operator|(range const& r) const;
	range operator&(range const& r) const;
	range operator-(range const& r) const;

	bool empty() const;
	bool unit() const;
	bool contains(range const& r) const;
	bool contains(value_type i) const;

	bool disjoint(range const& r) const;
	bool adjacent(range const& r) const;
	bool intersects(range const& r) const;

	value_type size() const;
	value_type lower() const;
	value_type upper() const;
	value_type left() const;
	value_type right() const;

	iterator begin() const;
	iterator end() const;

	void clear();
	void swap(range& r);
	void setup();
	void setup(value_type left, value_type right);
	void set_left(value_type left);
	void set_right(value_type right);
	void setup_widest();

private:

	value_type m_left;
	value_type m_right;
};

} // namespace mstl

#include "m_range.ipp"

#endif // _mstl_range_included

// vi:set ts=3 sw=3:
