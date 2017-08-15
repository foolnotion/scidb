// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
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

namespace std { bool uncaught_exception() throw(); }

namespace mstl {

inline bool basic_exception::isEnabled()					{ return !m_isDisabled; }
inline void basic_exception::setDisabled(bool flag)	{ m_isDisabled = flag; }

}

#ifndef __OPTIMIZE__

#ifdef __clang__
class type_info; // because of a cyclic bug in gcc headers
#endif
#include <typeinfo>

namespace mstl {
namespace bits {

void
prepare_exc(exception& exc, char const* file, unsigned line, char const* func, char const* exc_type_id);

template <class Exc>
__attribute__((noreturn))
inline
static void
throw_exc(Exc const& exc, char const* file, int line, char const* func)
{
	if (basic_exception::isEnabled())
		prepare_exc(const_cast<Exc&>(exc), file, line, func, typeid(Exc).name());
	throw exc;
}

} // namespace bits
} // namespace mstl

#endif // __OPTIMIZE__

namespace mstl { inline bool uncaught_exception() throw() { return ::std::uncaught_exception(); } }

// vi:set ts=3 sw=3:
