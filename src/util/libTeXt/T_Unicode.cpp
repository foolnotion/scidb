// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2011-2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "T_Unicode.h"
#include "T_OutputFilter.h"
#include "T_TextToken.h"
#include "T_AsciiToken.h"
#include "T_GenericFinalToken.h"
#include "T_GenericValueToken.h"
#include "T_Messages.h"
#include "T_Miscellaneous.h"
#include "T_Verify.h"
#include "T_Environment.h"

#include "m_map.h"
#include "m_string.h"
#include "m_utility.h"
#include "m_assert.h"

using namespace TeXt;


inline static bool isFstByte(unsigned char c) { return (c & 0xc0) != 0x80; }
inline static bool isNthByte(unsigned char c) { return (c & 0xc0) == 0x80; }

inline static bool isSingleByte(unsigned char c) { return (c & 0x80) == 0; }
inline static bool isMultiByte (unsigned char c) { return (c & 0x80) != 0; }

inline static unsigned asUtf32(unsigned char c) { return c; }

inline static bool
isEncodable(unsigned u)
{
	return u < (1u << 16) && (!(0xd800 <= u && u <= 0xDfff) && ((u & 0xfffe) != 0xfffe));
}


namespace {

template <int N>
struct UtfConverter
{
	static uint32_t __toUtf32(unsigned u, char const* s)
	{
		if (!::isNthByte(*s))
			return 0;
		return UtfConverter<N - 1>::__toUtf32((u << 6) | (::asUtf32(*s) & 0x003f), s + 1);
	}

	static unsigned toUtf32(char const*& s)
	{
		M_ASSERT(isFstByte(*s));

		unsigned result = UtfConverter<N>::__toUtf32(::asUtf32(*s) & (0x007f >> (N + 1)), s + 1);
		s += N;
		return result;
	}
};

template <>
struct UtfConverter<1>
{
	static unsigned __toUtf32(unsigned u, char const*) { return isEncodable(u) ? u : 0; }
};

} // namespace


static bool
isAscii(char const* s)
{
	for ( ; *s; ++s)
	{
		if (isMultiByte(*s))
			return false;
	}

	return true;
}


struct Unicode::UnicodeFilter : public OutputFilter
{
	typedef Miscellaneous::TextTokenP TextTokenP;
	typedef mstl::map<uint32_t,mstl::string> Map;

	UnicodeFilter()
		:OutputFilter(10000)
		,m_pref(new TextToken("x"))
		,m_suff(new TextToken)
	{}

	void put(Environment& env, mstl::string const& s)
	{
		if (env.associatedValue(Token::T_Utf8) <= 0 || ::isAscii(s))
		{
			next().put(env, s);
		}
		else
		{
			mstl::string result;
			result.reserve(mstl::mul2(s.size()));

			char const* p = s.begin();
			char const* e = s.end();

			while (p < e)
			{
				if (::isSingleByte(*p))
				{
					result += *p++;
				}
				else
				{
					unsigned cp = 0;
					unsigned char c = *p;

						  if ((c & 0xe0) == 0xc0) cp = UtfConverter<2>::toUtf32(p);
					else if ((c & 0xf0) == 0xe0) cp = UtfConverter<3>::toUtf32(p);
					else if ((c & 0xf8) == 0xf0) cp = UtfConverter<4>::toUtf32(p);

					if (cp == 0)
					{
						Messages::errmessage(env, "Invalid UTF-8 sequence", Messages::Incorrigible);
					}
					else if (env.associatedValue(m_useMap))
					{
						Map::const_iterator i = m_map.find(cp);

						if (i == m_map.end())
						{
							result.append(m_pref->content());
							result.format("x%04x", cp);
							result.append(m_suff->content());
						}
						else
						{
							result.append(i->second);
						}
					}
					else
					{
						result.append(m_pref->content());
						result.format("x%04x", cp);
						result.append(m_suff->content());
					}
				}
			}

			next().put(env, result);
		}
	}

	void add(uint32_t codePoint, mstl::string const& subst)
	{
		m_map[codePoint] = subst;
	}

	TextTokenP	m_pref;
	TextTokenP	m_suff;
	Token::Type m_useMap;
	Map			m_map;
};


namespace {

struct UcPrefToken : public GenericFinalToken
{
	typedef mstl::ref_counted_ptr<Unicode::UnicodeFilter> FilterP;

	UcPrefToken(mstl::string const& name, Func func, FilterP filter)
		:GenericFinalToken(name, func)
		,m_filter(filter)
	{
	}

	TokenP performThe(Environment& env) const
	{
		return m_filter->m_pref;
	}

	FilterP m_filter;
};


struct UcSuffToken : public GenericFinalToken
{
	typedef mstl::ref_counted_ptr<Unicode::UnicodeFilter> FilterP;

	UcSuffToken(mstl::string const& name, Func func, FilterP filter)
		:GenericFinalToken(name, func)
		,m_filter(filter)
	{
	}

	TokenP performThe(Environment& env) const
	{
		return m_filter->m_suff;
	}

	FilterP m_filter;
};

} // namespace


Unicode::Unicode()
	:m_filter(new UnicodeFilter)
{
}


Unicode::~Unicode()
{
	// needed for ~UnicodeFilter
}


void
Unicode::performUcPref(Environment& env)
{
	m_filter->m_pref = Miscellaneous::getTextToken(env);
}


void
Unicode::performUcSuff(Environment& env)
{
	m_filter->m_suff = Miscellaneous::getTextToken(env);
}


void
Unicode::performUcMap(Environment& env)
{
	TokenP codePoint(env.getFinalToken(Verify::numberToken));
	TokenP subst(env.getFinalToken());

	m_filter->add(codePoint->value(), subst->text());
}


void
Unicode::doRegister(Environment& env)
{
	env.pushFilter(m_filter);

	env.bindMacro(new UcPrefToken("\\ucpref", Func(&Unicode::performUcPref, this), m_filter));
	env.bindMacro(new UcSuffToken("\\ucsuff", Func(&Unicode::performUcSuff, this), m_filter));
	m_filter->m_useMap = bindMacro(env, new GenericValueToken("\\ucusemap"));
	env.bindMacro(new GenericFinalToken("\\ucmap", Func(&Unicode::performUcMap, this)));
	env.bindMacro(new GenericValueToken("\\utf-8",	Token::T_Utf8));

	env.associate(m_filter->m_useMap, 1);
}

// vi:set ts=3 sw=3:
