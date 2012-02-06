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

#include "Hyphenator.h"
#include "HyphenationRule.h"
#include "HyphenationTree.h"
#include "Language.h"

#include "sys_utf8.h"

#include "m_fstream.h"
#include "m_ostream.h"
#include "m_vector.h"
#include "m_auto_ptr.h"
#include "m_assert.h"

#include <stdlib.h>
#include <ctype.h>
#include <locale.h>

#ifdef WIN32
static char const PathDelim = '\\';
#else
static char const PathDelim = '/';
#endif

#ifndef WIN32
# define LIBHYPHENATE_DEFAULT_PATH "/usr/local/share/libhyphenate/"
#endif

static char const* PatternDir = "pattern";
static char const* DictDir = "dict";

using namespace rfc_3066;
using namespace hyphenate;


namespace hyphenate
{
	bool
	operator<(::Hyphenator::String const& lhs, Hyphenator::String const& rhs)
	{
		char const* p = lhs.begin();
		char const* e = lhs.end();
		char const* q = rhs.begin();
		char const* f = rhs.end();

		sys::utf8::uchar c, d;

		while (true)
		{
			if (p == e) return q != f;
			if (q == f) return false;

			if (*p == '-' ) ++p;
			if (*q == '-' ) ++q;

			p = sys::utf8::nextChar(p, c);
			q = sys::utf8::nextChar(q, d);

			if (c != d)
			{
				c = sys::utf8::toLower(c);
				d = sys::utf8::toLower(d);

				if (c != d) return c < d;
			}
		}

		return false; // satisfies the compiler
	}
}


/// The hyphenation table parser.
static void
read_hyphenation_table(mstl::auto_ptr<HyphenationTree>& output, mstl::string const& filename)
{
   mstl::ifstream strm(filename, mstl::ifstream::in);

	if (strm)
	{
		if (!output)
			output.reset(new HyphenationTree());
		output->loadPatterns(strm);
	}
}


/// The hyphenation dictionary parser.
static void
read_dictionary(mstl::auto_ptr<Hyphenator::Lookup>& output, mstl::string const& filename)
{
	mstl::ifstream strm(filename, mstl::ifstream::in);

	if (strm)
	{
		mstl::string line;

		if (!output)
			output.reset(new Hyphenator::Lookup);

		while (strm.getline(line))
		{
			line.unhook();
			line.trim();
			output->push_back(line);
		}
	}
}


/// Build a hyphenator for the given language. The hyphenation
/// patterns for the language will loaded from a file named like
/// the language string or any prefix of it. The file will be
/// located in the directory given by the environment variable
/// LIBHYPHENATE_PATH or, if this is empty, in the compiled-in
/// pattern directory which defaults to
/// /usr/local/share/libhyphenate/patterns .
///
///\param lang The language for which hyphenation patterns will be
///            loaded.
Hyphenator::Hyphenator(Language const& lang)
{
	mstl::string path;

	if (::getenv("LIBHYPHENATE_PATH"))
		path = ::getenv("LIBHYPHENATE_PATH");

#ifdef LIBHYPHENATE_DEFAULT_PATH
	if (path.empty())
		path = LIBHYPHENATE_DEFAULT_PATH;
#endif

	if (path.empty())
		return;

	mstl::string::size_type k = 0;
	mstl::string::size_type n = path.find(';');
	if (n == mstl::string::npos)
		n = path.size();

	while (k != mstl::string::npos)
	{
		mstl::string p(path, k, n - k);

		if (!p.empty())
			try_to_load(lang, p);

		if (n >= path.size() - 1)
		{
			k = mstl::string::npos;
		}
		else
		{
			k = n + 1;

			if ((n = path.find(';', k + 1)) == mstl::string::npos)
				n = path.size();
		}
	}
}


/// Build a hyphenator from the patterns in the file provided.
Hyphenator::Hyphenator(mstl::string const& patternFilename, mstl::string const& dictFilenames)
{
	::read_hyphenation_table(m_dictionary, patternFilename);

	if (!dictFilenames.empty())
	{
		mstl::string::size_type k = 0;
		mstl::string::size_type n = dictFilenames.find(';');
		if (n == mstl::string::npos)
			n = dictFilenames.size();

		while (k != mstl::string::npos)
		{
			mstl::string filename(dictFilenames, k, n - k);

			if (!filename.empty())
				::read_dictionary(m_lookup, filename);

			if (n >= dictFilenames.size() - 1)
			{
				k = mstl::string::npos;
			}
			else
			{
				k = n + 1;

				if ((n = dictFilenames.find(';', k + 1)) == mstl::string::npos)
					n = dictFilenames.size();
			}
		}
	}
}


Hyphenator::~Hyphenator() {}


void
Hyphenator::try_to_load(Language const& lang, mstl::string const& path)
{
	mstl::string pattFilename	= lang.find_suitable_file(path + ::PathDelim + ::PatternDir + ::PathDelim);
	mstl::string dictFilename	= lang.find_suitable_file(path + ::PathDelim + ::DictDir + ::PathDelim);
	mstl::string personalFname	= mstl::string(path + ::PathDelim + ::DictDir + ::PathDelim + "xx.dat");

	if (!pattFilename.empty())
	{
		char* oldLocale = ::setlocale(LC_CTYPE, "");

		try
		{
			::read_hyphenation_table(m_dictionary, pattFilename);
			if (!dictFilename.empty())
				::read_dictionary(m_lookup, dictFilename);
			::read_dictionary(m_lookup, personalFname);
		}
		catch (...)
		{
			::setlocale(LC_CTYPE, oldLocale);
			throw;
		}

		::setlocale(LC_CTYPE, oldLocale);
	}
}


void
Hyphenator::dump_lookup(mstl::ostream& strm) const
{
	if (!m_lookup)
		return;

	for (unsigned i = 0; i < m_lookup->container().size(); ++i)
	{
		strm.write(m_lookup->container()[i].s);
		strm.put('\n');
	}
}


Hyphenator::result
Hyphenator::replace_hyphens(	mstl::string const& word,
 										mstl::string const& lookup,
										mstl::string const& hyphen)
{
	mstl::string result;

	char const* s = lookup.begin();
	char const* e = lookup.end();
	char const* p = word.begin();

	while (s < e)
	{
		if (*s == '-')
		{
			result.append(hyphen);
			++s;
		}
		else if (sys::utf8::isAscii(*s))
		{
			M_ASSERT(p < word.end());
			M_ASSERT(sys::utf8::isAscii(*p));
			M_ASSERT(::toupper(*s) == ::toupper(*p));

			result.append(*p++);
			++s;
		}
		else
		{
			M_ASSERT(p < word.end());
			M_ASSERT(sys::utf8::toUpper(sys::utf8::getChar(s)) ==
						sys::utf8::toUpper(sys::utf8::getChar(p)));

			char const* q = sys::utf8::nextChar(p);
			result.append(p, q);
			p = q;
			s = sys::utf8::nextChar(s);
		}
	}

	return result;
}


Hyphenator::result
Hyphenator::hyphenate(mstl::string const& text, mstl::string const& hyphen)
{
	char const* cur	= text.begin();
	char const* next	= cur;
	char const* end	= text.end();

	mstl::string result;

	while (next < end)
	{
		next = sys::utf8::skipNonAlphas(next, end);
		char const* eow = sys::utf8::skipAlphas(next, end);

		if (eow > next)
		{
			mstl::string s;
			s.hook(const_cast<char*>(next), eow - next);
			result.append(cur, next);
			result.append(hyphenate_word(s, hyphen));
			next = cur = eow;
		}
	}

	result.append(cur, end);
	return result;
}


Hyphenator::result
Hyphenator::hyphenate_word(mstl::string const& word, mstl::string const& hyphen)
{
	M_REQUIRE(has_dictionary());
	M_REQUIRE(sys::utf8::validate(word));

	if (m_lookup)
	{
		Lookup::const_iterator i = m_lookup->find(word);

		if (i != m_lookup->end())
			return replace_hyphens(word, i->s, hyphen);
	}

	mstl::auto_ptr<mstl::vector<HyphenationRule const*> > rules = m_dictionary->applyPatterns(word);

	// Build our result string. Of course, we _could_ insert
	// characters in w, but that would be highly inefficient.
	mstl::string result;

	int acc_skip = 0;

	for (unsigned i = 0; i < word.size(); ++i)
	{
		if ((*rules)[i] != nullptr)
			acc_skip += (*rules)[i]->apply(result, hyphen);

		if (acc_skip > 0)
			--acc_skip;
		else
			result += word[i];
	}

	return result;
}


Hyphenator::result_pair
Hyphenator::hyphenate_at(mstl::string const& src, mstl::string const& hyphen, size_t len)
{
	M_REQUIRE(has_dictionary());
	M_REQUIRE(sys::utf8::validate(src));

	// First of all, find the word which needs to be hyphenated.
	char const* cur	= sys::utf8::atIndex(src.begin(), len);
	char const* next	= sys::utf8::skipNonSpaces(cur, src.end());
	char const* end	= src.end();

	mstl::pair<mstl::string,mstl::string> result;

	if (next < end)
	{
		// We are lucky: There is a space we can hyphenate at.

		// We leave no spaces at the end of a line:
		while (cur > src.begin() && sys::utf8::isSpace(sys::utf8::getChar(cur)))
			cur = sys::utf8::prevChar(cur, src.begin());

		int byteLen = cur - src.begin() + 1;
		result.first.assign(src, 0, byteLen);

		// Neither do we leave spaces at the beginning of the next.
		next = sys::utf8::skipSpaces(cur, end);
		result.second.assign(next, end);
	}
	else
	{
		// We can hyphenate at hyphenation points in words or at spaces, whatever
		// comes earlier. We will check all words here in the loop.
		char const* border = cur;

		while (true)
		{
			// Find the start of a word first.
			bool in_word = sys::utf8::isAlpha(sys::utf8::getChar(cur));
			char const* word_start = nullptr;

			while (cur > src.begin())
			{
				cur = sys::utf8::prevChar(cur, src.begin());
				sys::utf8::uchar ch = sys::utf8::getChar(cur);

				if (in_word && !sys::utf8::isAlpha(ch))
				{
					// If we have a word, try hyphenating it.*/
					word_start = sys::utf8::nextChar(cur);
					break;
				}
				else if (sys::utf8::isSpace(ch))
				{
					break;
				}
				else if (!in_word && sys::utf8::isAlpha(ch))
				{
					in_word = true;
				}

				if (cur == src.begin() && in_word)
					word_start = cur;
			}

			// There are two reasons why we may have left the previous loop with-
			// out result:
			// Either because our word goes all the way to the first character,
			// or because we found whitespace.
			// In the first case, there is nothing really hyphenateable.
			if (word_start != nullptr)
			{
				// We have the start of a word, now look for the character after the end.
				char const* word_end = sys::utf8::skipAlphas(word_start, end);

				// Build the substring consisting of the word.
				mstl::string word(word_start, word_end);

				Lookup::const_iterator except;

				if (m_lookup && (except = m_lookup->find(word)) != m_lookup->end())
				{
					// XXX TODO
					// build result
					// replace all hyphens with "hyphen"
				}
				else
				{
					// Hyphenate the word.
					mstl::auto_ptr<mstl::vector<HyphenationRule const*> >
					rules = m_dictionary->applyPatterns(word);

					// Determine the index of the latest hyphenation that will still fit.
					int latest_possible_hyphenation = -1;
					int earliest_hyphenation = -1;

					for (int i = 0; i < int(rules->size()); ++i)
					{
						if ((*rules)[i])
						{
							if (earliest_hyphenation == -1)
								earliest_hyphenation = i;

							if (word_start + i + (*rules)[i]->spaceNeededPreHyphen() + hyphen.size() > border)
								break;

							if (i > latest_possible_hyphenation)
								latest_possible_hyphenation = i;
						}
					}

					bool have_space = false;

					for (char const* i = src.begin(); i <= word_start; i = sys::utf8::nextChar(i))
					{
						if (sys::utf8::isSpace(sys::utf8::getChar(i)))
						{
							have_space = true;
							break;
						}
					}

					if (latest_possible_hyphenation == -1 && !have_space)
						latest_possible_hyphenation = earliest_hyphenation;

					// Apply the best hyphenation, if any.
					if (latest_possible_hyphenation >= 0)
					{
						int i = latest_possible_hyphenation;
						result.first.assign(src, 0, word_start - src.begin() + i);
						(*rules)[i]->apply_first(result.first, hyphen);
						int skip = (*rules)[i]->apply_second(result.second);
						result.second.append(src, (word_start - src.begin()) + i + skip);
						return result;
					}
				}
			}

			if (cur == src.begin())
			{
				// We cannot hyphenate at all, so leave the first block standing
				// and move to its end.
				char const* eol = sys::utf8::skipNonSpaces(cur, end);

				result.first.assign(src, 0, eol - src.begin() + 1);

				eol = sys::utf8::skipSpaces(cur, end);
				result.second.assign(eol, end);
				return result;
			}
			else if (sys::utf8::isSpace(sys::utf8::getChar(cur)))
			{
				// eol is the end of the previous line, bol the start of the next.
				char const* eol = cur;
				char const* bol = sys::utf8::skipSpaces(cur, end);

				while (eol > src.begin() && sys::utf8::isSpace(sys::utf8::getChar(eol)))
					eol = sys::utf8::prevChar(eol, src.begin());

				result.first.assign(src, 0, eol - src.begin() + 1);
				result.second.assign(bol, end);
				return result;
			}
		}
	}

	return result;
}


mstl::auto_ptr<mstl::vector<HyphenationRule const*> >
Hyphenator::applyHyphenationRules(mstl::string const& word)
{
	M_REQUIRE(has_dictionary());
	M_REQUIRE(sys::utf8::validate(word));

	return m_dictionary->applyPatterns(word);
}

// vi:set ts=3 sw=3:
