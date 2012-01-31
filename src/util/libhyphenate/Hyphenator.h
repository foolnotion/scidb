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

#ifndef _hyphenate_hyphenator_h
#define _hyphenate_hyphenator_h

#include "Language.h"

#include "m_string.h"
#include "m_vector.h"
#include "m_auto_ptr.h"
#include "m_pair.h"

#include <iconv.h>

namespace Hyphenate
{
	class HyphenationTree;
	class HyphenationRule;

	class Hyphenator
	{
	private:

		mstl::auto_ptr<HyphenationTree> dictionary;

		mstl::string hyphenate_word(mstl::string const& word, mstl::string const& hyphen);

	public:

		////Build a hyphenator for the given language. The hyphenation
		/// patterns for the language will loaded from a file named like
		/// the language string or any prefix of it. The file will be
		/// located in the directory given by the environment variable
		/// LIBHYPHENATE_PATH or, if this is empty, in the compiled-in
		/// pattern directory which defaults to 
		/// /usr/local/share/libhyphenate/patterns .
		///
		///\param lang The language for which hyphenation patterns will be
		///            loaded.
		Hyphenator(RFC_3066::Language const& lang); 

		/// Build a hyphenator from the patterns in the file provided.
		Hyphenator(mstl::string const& filename); 

		/// The actual workhorse. You'll want to call this function once
		/// for each word (NEW: or complete string, not only word. The library
		/// will do the word-splitting for you) you want hyphenated.  
		/// 
		/// Usage example: 
		/// 	Hyphenate::Hyphenator hyphenator(Language("de-DE"));
		/// 	hyphenator.hyphenate("Schifffahrt");
		///
		/// 	yields "Schiff-fahrt", while 
		///
		/// 	Hyphenate::Hyphenator hyphenator(Language("en"));
		/// 	hyphenator.hyphenate("example", "&shy;");
		///
		/// 	yields "ex&shy;am&shy;ple".
		///
		/// \param word A single UTF-8 encoded word to be hyphenated.
		/// \param hyphen The string to put at each possible
		///               hyphenation point. The default is an ASCII dash.
		mstl::string hyphenate(mstl::string const& word, mstl::string const& hyphen = "-");

		/// Find a single hyphenation point in the string so that the first
		/// part (including a hyphen) will be shorter or equal in length
		/// to the parameter len. If this is not possible, choose the shortest
		/// possible string.
		///
		/// The first element is the result, the second element the rest of
		/// the string.
		///
		/// Example: To format a piece of text to width 60, use the following
		/// loop:
		/// string rest = text;
		/// string result = "";
		/// while ( ! rest.empty() ) {
		///    pair<string,string> p = your_hyphenator.hyphenate_at(rest);
		///    result += p.first + "\n"
		///    rest = p.second;
		/// }
		mstl::pair<mstl::string,mstl::string> hyphenate_at(
			mstl::string const& word,
			mstl::string const& hyphen = "-",
			size_t len = mstl::string::npos);

		/// Just apply the hyphenation patterns to the word, but don't 
		/// hyphenate anything.
		///
		/// \returns A vector with the same size as the word with a non-NULL
		///          entry for every hyphenation point.
		mstl::auto_ptr<mstl::vector<const HyphenationRule*> > 
		applyHyphenationRules(mstl::string const& word);
	};
}

#endif // _hyphenate_hyphenator_h

// vi:set ts=3 sw=3:
