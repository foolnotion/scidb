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

#ifndef _hyphenate_hyphenator_h
#define _hyphenate_hyphenator_h

#include "m_string.h"
#include "m_vector.h"
#include "m_set.h"
#include "m_auto_ptr.h"
#include "m_pair.h"

#include <iconv.h>

namespace rfc_3066 { class Language; }
namespace mstl { class ostream; }

namespace hyphenate
{
	class HyphenationTree;
	class HyphenationRule;

	class Hyphenator
	{
	public:

		struct String
		{
			mstl::string s;

			String() {}
			String(mstl::string const& t) :s(t) {}

			char const* begin() const	{ return s.begin(); }
			char const* end() const		{ return s.end(); }
		};

		typedef mstl::set<String> Lookup;
		typedef mstl::string result;
		typedef mstl::pair<mstl::string, mstl::string> result_pair;

	private:

		mstl::auto_ptr<HyphenationTree> m_dictionary;
		mstl::auto_ptr<Lookup> m_lookup;

		result hyphenate_word(mstl::string const& word, mstl::string const& hyphen);
		void try_to_load(rfc_3066::Language const& lang, mstl::string const& path);
		void read_hyphenation_table(mstl::string const& filename);
		void read_exception_dict(mstl::string const& filename);
		result replace_hyphens(	mstl::string const& word,
										mstl::string const& lookup,
										mstl::string const& hyphen);

	public:

		/// Build a hyphenator for the given language. The hyphenation
		/// patterns for the language will loaded from a file named like
		/// the language string or any prefix of it. The file will be
		/// located in the directory given by the environment variable
		/// LIBHYPHENATE_PATH or, if this is empty, in the compiled-in
		/// pattern directory which defaults to
		/// /usr/local/share/libhyphenate/pattern .
		///
		///\param lang The language for which hyphenation patterns will be
		///            loaded.
		Hyphenator(rfc_3066::Language const& lang);

		/// Build a hyphenator from the patterns in the file provided.
		Hyphenator(mstl::string const& patternFilename, mstl::string const& dictFilenames = "");

		// Destroy Hyphenator.
		~Hyphenator();

		/// Return whether a pattern directory was found.
		bool has_dictionary() const	{ return m_dictionary; }
		bool has_lookup() const			{ return m_lookup; }

		// Dump the content.
		void dump_dictionary(mstl::ostream& strm) const;
		void dump_lookup(mstl::ostream& strm) const;

		/// The actual workhorse. You'll want to call this function once
		/// for each word (NEW: or complete string, not only word. The library
		/// will do the word-splitting for you) you want hyphenated.
		///
		/// Usage example:
		/// 	hyphenate::Hyphenator hyphenator(Language("de-DE"));
		/// 	hyphenator.hyphenate("Schifffahrt");
		///
		/// 	yields "Schiff-fahrt", while
		///
		/// 	hyphenate::Hyphenator hyphenator(Language("en"));
		/// 	hyphenator.hyphenate("example", "&shy;");
		///
		/// 	yields "ex&shy;am&shy;ple".
		///
		/// \param text A UTF-8 encoded text to be hyphenated.
		/// \param hyphen The string to put at each possible
		///               hyphenation point. The default is an ASCII dash.
		result hyphenate(mstl::string const& text, mstl::string const& hyphen = "-");

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
		result_pair hyphenate_at(
			mstl::string const& word,
			mstl::string const& hyphen = "-",
			size_t len = mstl::string::npos);

		/// Just apply the hyphenation patterns to the word, but don't
		/// hyphenate anything.
		///
		/// \returns A vector with the same size as the word with a non-NULL
		///          entry for every hyphenation point.
		mstl::auto_ptr<mstl::vector<HyphenationRule const*> >
		applyHyphenationRules(mstl::string const& word);
	};
}

#endif // _hyphenate_hyphenator_h

// vi:set ts=3 sw=3:
