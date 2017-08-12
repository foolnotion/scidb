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

#include "m_utility.h"

namespace eco {

inline Path::Path() :m_path(m_bitLengthList) {}

inline auto Path::operator<(Path const& path) const -> bool { return m_path < path.m_path; }

inline auto Path::data() const -> db::TranspositionPath::Bits { return m_path.data(); }
inline auto Path::bits() const -> db::TranspositionPath::Bits const& { return m_path.bits(); }

inline auto Path::length() const -> unsigned { return m_path.length(); }

inline auto Path::bitLengthList() -> BitLenghtList const& { return m_bitLengthList; }

inline void Path::append(uint64_t bits) { m_path.append(bits); }

} // namespace eco

// vi:set ts=3 sw=3:
