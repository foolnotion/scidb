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
// libhyphenate: A TeX-like hyphenation algorithm.
// Copyright (C) 2007 Steve Wolter
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
//
// If you have any questions, feel free to contact me:
// http://swolter.sdf1.org
// ======================================================================

#ifndef _rfc_3066_language_h
#define _rfc_3066_language_h

#include "m_list.h"
#include "m_string.h"

namespace rfc_3066
{
	/// This class implements a parser for RFC 3066-compliant language codes.
	class Language
	{
	private:

		// This is a list of the components, all in lowercase; for example,
		// for de-AT the list would have the two elements "de" and "at".
		mstl::list<mstl::string> m_components;

	public:

		/// Construct from an RFC-3066-compliant string.
		Language(mstl::string const& rfc_3066);

		/// Compare languages. The <-operator works lexicographically.
		bool operator==(Language const& lang) const;
		bool operator<(Language const& lang) const;

		/// Re-string to a RFC-3066-compliant string.
		operator mstl::string() const;

		/// Check whether it's the German language (may use eszet)
		bool is_german() const;

		/// Concat only the first 'elements' elements of the language 
		/// identifier and seperate them with the separator.
		mstl::string concat(int elements, mstl::string const& separator = "-") const;

		/// Find the longest prefix match in the given directory for the given
		/// language. For example, for de-AT-Vienna, de-AT-Vienna is checked
		/// first, then de-AT, then de. The directory should be /-postfixed.
		mstl::string find_suitable_file(mstl::string const& dir) const;
	};
}

#endif // _rfc_3066_language_h

// vi:set ts=3 sw=3:
