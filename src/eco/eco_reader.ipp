// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $HeadURL$
// ======================================================================

// ======================================================================
//    _/|            __
//   // o\         /    )           ,        /    /
//   || ._)    ----\---------__----------__-/----/__-
//   //__\          \      /   '  /    /   /    /   )
//   )___(     _(____/____(___ __/____(___/____(___/_
// ======================================================================

// ======================================================================
// Copyright: (C) 2014-2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

namespace eco {

inline Reader::Reader(Type type) :m_type(type), m_lineNo(0), m_conflicts(0) {}

inline auto Reader::lineNo() const -> unsigned						{ return m_lineNo; }
inline auto Reader::countConflicts() const -> unsigned			{ return m_conflicts; }
inline auto Reader::epilogue() const ->  mstl::string const&	{ return m_epilogue; }
inline auto Reader::isLineReader() const -> bool					{ return m_type == Line; }

inline void Reader::countConflict() { ++m_conflicts; }

} // namespace eco

// vi:set ts=3 sw=3:
