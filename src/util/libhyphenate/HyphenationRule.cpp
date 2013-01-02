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

// This source file provides code for the HyphenationRule class which
// is documented in HyphenationRule.h

#include "HyphenationRule.h"

#include "m_utility.h"

#include <string.h>
#include <ctype.h>

using namespace hyphenate;


HyphenationRule::HyphenationRule(mstl::string const& dpattern)
	:del_pre(0)
	,skip_post(0)
{
	int priority = 0;
	unsigned i;

	for (i = 0; i < dpattern.size() && dpattern[i] != '/'; i++)
	{
		if (::isdigit(dpattern[i]))
		{
			priority = 10*priority + dpattern[i] - '0';
		}
		else
		{
			key += dpattern[i];
			priorities.push_back(priority);
			priority = 0;
		}
	}

	// Complete and simplify the array.
	priorities.push_back(priority);
	while (priorities.back() == 0)
		priorities.pop_back();

	// Now check for nonstandard hyphenation. First, parse it.
	if (i < dpattern.size() && dpattern[i] == '/')
	{
		int field = 1;
		unsigned start = 0, cut = 0;

		for (i++ /* Ignore the /. */; i < dpattern.size(); i++)
		{
			if (field == 1 && dpattern[i] == '=')
				field++;
			else if (field >= 2 && field <= 3 && dpattern[i] == ',')
				field++;
			else if (field == 4 && (dpattern[i] < '0' || dpattern[i] > '9'))
				break;
			else if (field == 1)
				insert_pre += dpattern[i];
			else if (field == 2)
				insert_post += dpattern[i];
			else if (field == 3)
				start = start * 10 + dpattern[i] - '0';
			else if (field == 4)
				cut = cut*10 + dpattern[i] - '0';
		}

		if (field < 4) // There was no fourth field
			cut = key.size() - start;
		if (field < 3)
			start = 1;

		skip_post = cut;

		for (unsigned j = start; j < start+cut && j < priorities.size(); j++)
		{
			if (mstl::is_odd(priorities[j-1]))
				break;

			del_pre++;
			skip_post--;
		}
	}
}


int
HyphenationRule::apply(mstl::string& word, mstl::string const& hyph) const
{
	apply_first(word, hyph);
	return apply_second(word);
}


void
HyphenationRule::apply_first(mstl::string& word, mstl::string const& hyph) const
{
	if (del_pre > 0)
		word.erase(word.size() - del_pre);

	word += insert_pre;
	word += hyph;
}


int
HyphenationRule::apply_second(mstl::string& word) const
{
   if (del_pre > 0)
		word.erase(word.size() - del_pre);

	word += insert_post;
	return skip_post;
}

// vi:set ts=3 sw=3:
