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
// Copyright: (C) 2009-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _db_annotation_included
#define _db_annotation_included

#include "db_common.h"

#include "u_crc.h"

#include "m_bitset.h"

namespace mstl { class string; }

namespace db {

class Annotation
{
public:

	enum { Max_Nags = 7 };

	static unsigned const Flag_Symbolic_Annotation_Style				= 1 << 0;
	static unsigned const Flag_Extended_Symbolic_Annotation_Style	= 1 << 1;

	Annotation();
	explicit Annotation(nag::ID nag);
	Annotation(mstl::string const& str);

	bool operator==(Annotation const& annotation) const;
	bool operator!=(Annotation const& annotation) const;

	nag::ID operator[](unsigned n) const;

	bool isEmpty() const;
	bool hasTrailingAnnotation() const;
	bool contains(nag::ID nag) const;
	bool isDefaultSet() const;
	bool containsUsualNags() const;
	bool containsUnusualNags() const;

	unsigned count() const;
	unsigned countPrefixNags() const;
	unsigned countUsualNags() const;
	unsigned countUnusualNags() const;

	uint8_t const* data() const;
	::util::crc::checksum_t computeChecksum(util::crc::checksum_t crc) const;

	bool add(nag::ID nag);
	bool add(char const* str);
	unsigned add(Annotation const& set);
	void set(nag::ID nag);
	void setUsualNags(Annotation const& set);
	void setUnusualNags(Annotation const& set);
	void remove(nag::ID nag);
	void removeDiagramNags();
	void sort();
	void clear();

	mstl::string& prefix(mstl::string& result) const;
	mstl::string& infix(mstl::string& result) const;
	mstl::string& suffix(mstl::string& result) const;
	mstl::string& all(mstl::string& result) const;
	mstl::string& print(mstl::string& result, unsigned flags = 0) const;
	void dump() const;

	static Annotation const* defaultSet(nag::ID nag);

	static bool unusualNagExists();
	static bool isUnusualNag(nag::ID nag);
	static void setUnusualNag(nag::ID nag);
	static void unsetUnusualNag(nag::ID nag);
	static void unsetUnusualNags();
	static void flipUnusualNags();

	class Default;
	friend class Default;

private:

	uint8_t m_count;
	uint8_t m_annotation[Max_Nags];

	static mstl::bitset m_unusualNags;
};

} // namespace db

#include "db_annotation.ipp"

#endif // _db_annotation_included

// vi:set ts=3 sw=3:
