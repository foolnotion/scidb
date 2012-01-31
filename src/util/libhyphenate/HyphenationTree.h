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

#ifndef _hyphenate_hyphenation_tree_h
#define _hyphenate_hyphenation_tree_h

#include "HyphenationRule.h"

#include "m_vector.h"
#include "m_auto_ptr.h"

namespace mstl { class istream; }

namespace Hyphenate
{
	class HyphenationNode;

	/// \class HyphenationTree
	/// \brief The root for a tree of HyphenationNodes.

	class HyphenationTree
	{
	private:

		HyphenationNode* root;
		unsigned start_safe, end_safe;

	public:

		/// The constructor constructs an empty tree, which can be filled
		/// either by reading a whole file of patterns with 
		/// <code>loadPatterns</code> or by <code>insert</code>.
		HyphenationTree();
		~HyphenationTree();

		/// Read the istream while it is not empty, cutting it into words
		/// and constructing patterns from it. The first lone number 
		/// encountered will be the safe start, the second the safe end.
		void loadPatterns(mstl::istream& source);

		/// Insert a particular hyphenation pattern into the hyphenation tree.
		/// \param pattern The character pattern to match in the input word.
		void insert(mstl::auto_ptr<HyphenationRule> pattern);

		/// Apply all patterns for that hyphenation tree to the supplied
		/// string. Return an array with Hyphenation rules that should be
		/// applied before the addition of the next letter of the string.
		/// The pointers in that vector point into this tree.
		mstl::auto_ptr<mstl::vector<const HyphenationRule*> >
		applyPatterns(const mstl::string& word) const; 

		/// Like applyPattern, but will only hyphenate up to the letter end_at.
		mstl::auto_ptr<mstl::vector<const HyphenationRule*> >
		applyPatterns(const mstl::string& word, size_t end_at) const; 
	};
}

#endif // _hyphenate_hyphenation_tree_h

// vi:set ts=3 sw=3:
