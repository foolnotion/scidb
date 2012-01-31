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

#include "sys_utf8.h"

#include "m_fstream.h"
#include "m_vector.h"
#include "m_auto_ptr.h"
#include "m_assert.h"

#include <stdlib.h>
#include <locale.h>

#define UTF8_MAX 6

using namespace RFC_3066;
using namespace Hyphenate;


/// The hyphenation table parser.
static mstl::auto_ptr<HyphenationTree>
read_hyphenation_table(mstl::string const& filename)
{
   mstl::ifstream i(filename, mstl::ifstream::in);
   mstl::auto_ptr<HyphenationTree> output(new HyphenationTree());
   output->loadPatterns(i);
   return output;
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
Hyphenate::Hyphenator::Hyphenator(RFC_3066::Language const& lang)
{
	char* oldLocale = ::setlocale(LC_CTYPE, "");

	try
	{
		mstl::string path;

		if (::getenv("LIBHYPHENATE_PATH"))
			path = ::getenv("LIBHYPHENATE_PATH");

#ifdef LIBHYPHENATE_DEFAULT_PATH
		if (path.empty())
			path = LIBHYPHENATE_DEFAULT_PATH;
#endif

		path += "/";

		mstl::string filename = lang.find_suitable_file(path);
		dictionary = ::read_hyphenation_table(filename);
		::setlocale(LC_CTYPE, oldLocale);
	}
	catch (...)
	{
		::setlocale(LC_CTYPE, oldLocale);
		throw;
	}
}


/// Build a hyphenator from the patterns in the file provided.
Hyphenate::Hyphenator::Hyphenator(mstl::string const& filename)
{
	dictionary = ::read_hyphenation_table(filename);
}


mstl::string
Hyphenator::hyphenate(mstl::string const& word, mstl::string const& hyphen)
{
	M_REQUIRE(sys::utf8::validate(word));

	mstl::string result;
	unsigned word_start = unsigned(-1);

	char const* w = word.c_str();

	// Go through the input. All non-alpha characters are added to the
	// output immediately, and words are hyphenated and then added.

	for (unsigned i = 0; i < word.size(); ++i)
	{
		// Skip UTF-8 tail bytes.
		if (sys::utf8::isFirst(word[i]))
		{
			if (sys::utf8::isAlpha(sys::utf8::getChar(w)))
			{
				if (word_start == mstl::string::npos)
					word_start = i;
			}
			else if (word_start != mstl::string::npos)
			{
				result += hyphenate_word(word.substr(word_start, i - word_start), hyphen);
				word_start = mstl::string::npos;
			}
		}

		if (word_start == mstl::string::npos)
			result += word[i];
	}

	if (word_start != mstl::string::npos)
		result += hyphenate_word(word.substr(word_start), hyphen);

	return result;
}


mstl::string Hyphenator::hyphenate_word(mstl::string const& word, mstl::string const& hyphen)
{
	M_REQUIRE(sys::utf8::validate(word));

	mstl::auto_ptr<mstl::vector<const HyphenationRule*> > rules = dictionary->applyPatterns(word);

	// Build our result string. Of course, we _could_ insert characters in
	// w, but that would be highly inefficient.
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


mstl::pair<mstl::string,mstl::string>
Hyphenator::hyphenate_at(mstl::string const& src, mstl::string const& hyphen, size_t len)
{
	M_REQUIRE(sys::utf8::validate(src));

	// First of all, find the word which needs to be hyphenated.
	char const* cur	= sys::utf8::atIndex(src.begin(), len);
	char const* next	= sys::utf8::skipNonSpaces(cur, src.end());

	mstl::pair<mstl::string,mstl::string> result;

	if (next < src.end())
	{
		// We are lucky: There is a space we can hyphenate at.

		// We leave no spaces at the end of a line:
		while (cur > src.begin() && sys::utf8::isSpace(sys::utf8::getChar(cur)))
			cur = sys::utf8::prevChar(cur, src.begin());

		int byteLen = cur - src.begin() + 1;
		result.first = src.substr(0, byteLen);

		// Neither do we leave spaces at the beginning of the next.
		next = sys::utf8::skipSpaces(cur, src.end());
		result.second = src.substr(next - src.begin());
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
				// We have the start of a word, now look for the character after
				// the end.
				char const* word_end = sys::utf8::skipAlphas(word_start, src.end());

				// Build the substring consisting of the word.
				mstl::string word;

				for (char const* i = word_start; i < word_end; ++i)
					word += *i;

				// Hyphenate the word.
				mstl::auto_ptr<mstl::vector<const HyphenationRule*> >
				rules = dictionary->applyPatterns(word);

				// Determine the index of the latest hyphenation that will still fit.
				int latest_possible_hyphenation = -1;
				int earliest_hyphenation = -1;

				for (int i = 0; i < int(rules->size()); ++i)
				{
					if ((*rules)[i])
					{
						if (earliest_hyphenation == -1)
							earliest_hyphenation = i;

						if (word_start + i + (*rules)[i]->spaceNeededPreHyphen() + hyphen.size() <= border) 
						{
							if (i > latest_possible_hyphenation)
								latest_possible_hyphenation = i;
						}
						else
						{
							break;
						}
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
					result.first = src.substr(0, word_start - src.begin() + i);
					(*rules)[i]->apply_first(result.first, hyphen);
					int skip = (*rules)[i]->apply_second(result.second);
					result.second += mstl::string(word_start + i + skip);
					break;
				}
			}

			if (cur == src.begin())
			{
				// We cannot hyphenate at all, so leave the first block standing
				// and move to its end.
				char const* eol = sys::utf8::skipNonSpaces(cur, src.end());

				result.first = src.substr(0, eol - src.begin() + 1);

				eol = sys::utf8::skipSpaces(cur, src.end());
				result.second = mstl::string(eol);
				break;
			}
			else if (sys::utf8::isSpace(sys::utf8::getChar(cur)))
			{
				// eol is the end of the previous line, bol the start of the next.
				char const* eol = cur;
				char const* bol = sys::utf8::skipSpaces(cur, src.end());

				while (eol > src.begin() && sys::utf8::isSpace(sys::utf8::getChar(eol)))
					eol = sys::utf8::prevChar(eol, src.begin());

				result.first  = src.substr(0, eol - src.begin() + 1);
				result.second = mstl::string(bol);
				break;
			}
		}
	}

	return result;
}


mstl::auto_ptr<mstl::vector<const HyphenationRule*> > 
Hyphenate::Hyphenator::applyHyphenationRules(mstl::string const& word)
{
	M_REQUIRE(sys::utf8::validate(word));
	return dictionary->applyPatterns(word);
}

// vi:set ts=3 sw=3:
