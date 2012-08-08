// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

namespace sys {

inline bool FileAlterationMonitor::valid() const						{ return m_valid; }
inline mstl::string const& FileAlterationMonitor::error() const	{ return m_error; }

} // namespace sys

// vi:set ts=3 sw=3:
