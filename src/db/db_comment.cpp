// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
//    _/|            __
//   // o\         /    )           ,        /    /
//   || ._)    ----\---------__----------__-/----/__-
//   //__\          \      /   '  /    /   /    /   )
//   )___(     _(____/____(___ __/____(___/____(___/_
// ======================================================================

// ======================================================================
// Copyright: (C) 2010-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "db_comment.h"
#include "db_common.h"
#include "db_exception.h"

#include "sys_utf8.h"
#include "sys_utf8_codec.h"

#include "u_emoticons.h"

#include "m_stack.h"
#include "m_set.h"
#include "m_map.h"
#include "m_bitfield.h"
#include "m_utility.h"

#include <expat.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

using namespace db;


static mstl::string const Prefix("<xml>");
static mstl::string const Suffix("</xml>");

static char const AttrMap[3] = { 'b', 'i', 'u' };


static char const*
skipSpaces(char const* s)
{
	while (isspace(*s))
		++s;
	return s;
}


static bool
isDelimChar(char c)
{
	return c == '\0' || ::strchr(" \t\n/.,;:!?<>&", c);
}


static unsigned
appendDelim(mstl::string& str, char delim)
{
	if (delim && !str.empty() && (!::isspace(delim) || !::isspace(str.back())))
	{
		str += delim;
		return 1;
	}

	return 0;
}


static void
flatten(mstl::string const& src, mstl::string& dst)
{
	char const* s = src.begin();
	char const* e = src.end();

	while (s < e)
	{
		if (*s != '&')
		{
			dst.append(*s++);
		}
		else if (::strncmp("&lt;", s, 4) == 0)
		{
			dst.append('<');
			s += 4;
		}
		else if (::strncmp("&gt;", s, 4) == 0)
		{
			dst.append('>');
			s += 4;
		}
		else if (::strncmp("&amp;", s, 5) == 0)
		{
			dst.append('&');
			s += 5;
		}
		else if (::strncmp("&apos;", s, 6) == 0)
		{
			dst.append('\'');
			s += 6;
		}
		else if (::strncmp("&quot;", s, 6) == 0)
		{
			dst.append('"');
			s += 6;
		}
		else
		{
			dst.append(*s++);
		}
	}
}


static void
appendChar(char c, mstl::string& result)
{
	switch (c)
	{
		case '<':	result.append("&lt;",   4); break;
		case '>':	result.append("&gt;",   4); break;
		case '&':	result.append("&amp;",  5); break;
		case '\'':	result.append("&apos;", 6); break;
		case '"':	result.append("&quot;", 6); break;
		default:		result.append(c); break;
	}
}


static bool
detectEmoticons(mstl::string const& str, mstl::string& result)
{
	bool detected = false;

	char const* s = str.begin();
	char const* e = str.end();

	while (s < e)
	{
		util::emoticons::Emotion emotion;

		char const* q = s;
		char const* p = util::emoticons::parseEmotion(q, e, emotion);

		mstl::string tmp;
		mstl::string content;

		tmp.hook(const_cast<char*>(s), p - s);
		Comment::escapeString(tmp, content);
		result.append(content);

		if (p < e)
		{
			result.append("<emo>", 5);

			mstl::string code;
			Comment::escapeString(util::emoticons::toAscii(emotion), code);
			result.append(code);
			detected = true;

			result.append("</emo>", 6);
		}

		s = q;
	}

	return detected;
}


namespace {

struct XmlData
{
	enum State { Content, Symbol, Emoticon, Nag };

	XmlData(Comment::Callback& callback) :cb(callback), state(Content) {}

	Comment::Callback&	cb;
	State						state;
};


struct HtmlData
{
	HtmlData(mstl::string& s, unsigned& langFlags)
		:result(s)
		,skipLang(0)
		,putLang(1)
		,langFlags(langFlags)
		,isXml(false)
		,isHtml(false)
		,insideNag(false)
	{
	}

	bool success() const { return isHtml && putLang != 2 && !insideNag; }

	mstl::string& result;
	mstl::string  lang;
	mstl::string  othLang;

	unsigned  skipLang;
	unsigned  putLang;
	unsigned& langFlags;

	bool isXml;
	bool isHtml;
	bool insideNag;
};


struct Collector : public Comment::Callback
{
	Collector(Comment::LanguageSet& set) :m_set(set), m_length(&m_langAll), m_langAll(0) {}

	void start() {}

	void finish() override
	{
		if (m_set.empty() || m_langAll > 0)
			m_set[mstl::string::empty_string] = m_langAll;
	}

	void startLanguage(mstl::string const& lang) override
	{
		m_length = &m_set[lang];
	}

	void endLanguage(mstl::string const& lang) override
	{
		m_length = &m_langAll;
	}

	void startAttribute(Attribute attr) override	{}
	void endAttribute(Attribute attr) override	{}

	void content(mstl::string const& s) override		{ *m_length += s.size(); }
	void nag(mstl::string const& s) override			{ *m_length += 1; }
	void symbol(char s) override							{ *m_length += 1; }
	void emoticon(mstl::string const& s) override	{ *m_length += s.size(); }

	void invalidXmlContent(mstl::string const& content) override
	{
		m_set.clear();
		m_set[mstl::string::empty_string] = content.size();
	}

	Comment::LanguageSet& m_set;

	unsigned*	m_length;
	unsigned		m_langAll;
};


struct Split : public Comment::Callback
{
	typedef mstl::map<mstl::string, mstl::string> LangMap;
	typedef Comment::LanguageSet LanguageSet;

	Split() :m_current(nullptr) {}

	mstl::string* current()
	{
		return m_current ? m_current : (m_current = &m_result[mstl::string::empty_string]);
	}

	void start()  override {}
	void finish() override {}

	void startLanguage(mstl::string const& lang) override	{ m_current = &m_result[lang]; }
	void endLanguage(mstl::string const& lang) override	{ m_current = nullptr; }

	void startAttribute(Attribute attr) override
	{
		M_ASSERT(size_t(attr) < U_NUMBER_OF(::AttrMap));

		mstl::string* str = current();

		str->append('<');
		str->append(::AttrMap[attr]);
		str->append('>');
	}

	void endAttribute(Attribute attr) override
	{
		M_ASSERT(size_t(attr) < U_NUMBER_OF(::AttrMap));

		mstl::string* str = current();

		str->append('<');
		str->append('/');
		str->append(::AttrMap[attr]);
		str->append('>');
	}

	void content(mstl::string const& s) override
	{
		mstl::string* str = current();

		if (s.size() == 1)
			::appendChar(s[0], *str);
		else
			str->append(s);
	}

	void symbol(char s) override
	{
		mstl::string* str = current();

		str->append("<sym>", 5);
		str->append(s);
		str->append("</sym>", 6);
	}

	void emoticon(mstl::string const& s) override
	{
		mstl::string* str = current();

		str->append("<emo>", 5);
		str->append(s);
		str->append("</emo>", 6);
	}

	void nag(mstl::string const& s) override
	{
		mstl::string* str = current();

		str->append("<nag>", 5);
		str->append(s);
		str->append("</nag>", 6);
	}

	void invalidXmlContent(mstl::string const& content) override {}

	static void join(mstl::string& result, LangMap const& lhs, LangMap const& rhs, char delim)
	{
		result.assign(::Prefix);

		for (unsigned i = 0; i < lhs.container().size(); ++i)
		{
			mstl::string const& lang = lhs.container()[i].first;
			mstl::string const& content = lhs.container()[i].second;
			LangMap::const_iterator	k = rhs.find(lang);

			if (!content.empty() || (k != rhs.end() && !k->second.empty()))
			{
				result.append("<:", 2);
				result.append(lang);
				result.append(">", 1);

				if (!content.empty())
				{
					result.append(content);
					if (k != rhs.end() && !k->second.empty())
						result.append(delim);
				}

				if (k != rhs.end())
					result.append(k->second);

				result.append("</:", 3);
				result.append(lang);
				result.append(">", 1);
			}
		}

		for (unsigned i = 0; i < rhs.container().size(); ++i)
		{
			mstl::string const& lang = rhs.container()[i].first;
			mstl::string const& content = rhs.container()[i].second;

			if (!content.empty() && lhs.find(lang) == lhs.end())
			{
				result.append("<:", 2);
				result.append(lang);
				result.append(">", 1);
				result.append(content);
				result.append("</:", 3);
				result.append(lang);
				result.append(">", 1);
			}
		}

		result.append(::Suffix);
	}

	static void
	merge(mstl::string& result,
			LangMap const& lhs,
			LangMap const& rhs,
			LanguageSet const& leadingLanguageSet)
	{
		LanguageSet langSet;

		result.append(::Prefix);

		for (LangMap::const_iterator i = lhs.begin(); i != lhs.end(); ++i)
			langSet[i->first] = 1;
		for (LangMap::const_iterator i = rhs.begin(); i != rhs.end(); ++i)
			langSet[i->first] = 1;

		for (unsigned i = 0; i < langSet.container().size(); ++i)
		{
			mstl::string const& lang = langSet.container()[i].first;

			LangMap::const_iterator	p = lhs.find(lang);

			result.append("<:", 2);
			result.append(lang);
			result.append('>');

			if (p != lhs.end())
			{
				result.append(p->second);
			}
			else if (leadingLanguageSet.find(lang) == leadingLanguageSet.end())
			{
				LangMap::const_iterator	q = rhs.find(lang);

				if (q != rhs.end())
					result.append(q->second);
			}

			result.append("</:", 3);
			result.append(lang);
			result.append('>');
		}

		result.append(::Suffix);
	}

	static void append(mstl::string& result, LangMap const& map, mstl::string const& suffix)
	{
		result.assign(::Prefix);

		for (unsigned i = 0; i < map.container().size(); ++i)
		{
			LangMap::value_type const& entry = map.container()[i];

			result.append("<:", 2);
			result.append(entry.first);
			result.append('>');
			result.append(entry.second);
			if (!entry.first.empty())
				result.append(suffix);
			result.append("</:", 3);
			result.append(entry.first);
			result.append('>');
		}

		result.append(::Suffix);
	}

	LangMap m_result;
	mstl::string* m_current;
};


struct Normalize : public Comment::Callback
{
	enum { Delim = 3 };

	typedef mstl::bitfield<unsigned> Flags;

	struct Item
	{
		Item() {}
		Item(Flags const& f) :flags(f) {}

		Flags				flags;
		mstl::string	text;
	};

	struct Content
	{
		typedef mstl::list<Item> Items;

		Content() :count(0), prevCount(0) {}

		Items		items;
		unsigned	count;
		unsigned	prevCount;
	};

	typedef mstl::map<mstl::string,Content*> LangMap;
	typedef mstl::stack<Attribute> AttrStack;
	typedef Comment::LanguageSet LanguageSet;
	typedef Comment::Mode Mode;

	Normalize(	mstl::string& result,
					unsigned& langFlags,
					Mode mode,
					char delim,
					LanguageSet const* wanted = 0,
					mstl::string const* fromLang = 0,
					mstl::string const* toLang = 0)
		:m_result(result)
		,m_mode(mode)
		,m_delim(delim)
		,m_wanted(wanted)
		,m_fromLang(fromLang)
		,m_toLang(toLang)
		,m_lang(0)
		,m_langFlags(langFlags)
		,m_isXml(false)
		,m_containsAll(	m_wanted == 0
							|| m_wanted->find(mstl::string::empty_string) != m_wanted->end()
							|| (m_toLang && m_toLang->empty()))
	{
		static_assert(	((1 << Delim) & ((1 << Bold) | (1 << Italic) | (1 << Underline))) == 0,
							"invalid constant");
		static_assert(sizeof(m_attr) >= (Bold | Italic | Underline), "array too small");

		M_ASSERT(fromLang == 0 || toLang != 0);
		M_ASSERT(fromLang == 0 || *fromLang != *toLang);

		m_langFlags = 0;
	}

	~Normalize() throw() {
		for (LangMap::iterator i = m_map.begin(); i != m_map.end(); ++i)
			delete i->second;
	}

	void start() override {}

	void appendFlag(Attribute attr, char delim = '\0')
	{
		m_result.append('<');

		if (delim)
		{
			m_result.append(delim);
			m_flags.reset(attr);
		}
		else
		{
			m_flags.set(attr);
			m_stack.push(attr);
		}

		m_result.append(::AttrMap[attr]);
		m_result.append('>');
	}

	void setFlags(Flags flags)
	{
		if (flags.test(Underline))
			appendFlag(Underline);
		if (flags.test(Bold))
			appendFlag(Bold);
		if (flags.test(Italic))
			appendFlag(Italic);
	}

	Flags unsetFlags(Flags flags)
	{
		Flags reset;

		if (flags.any())
		{
			while (!m_stack.empty() && !flags.test(m_stack.top()))
			{
				appendFlag(m_stack.top(), '/');
				reset.set(m_stack.top());
				m_stack.pop();
			}

#ifndef NREQ
			unsigned count = 0;
#endif

			Attribute flag = Attribute(flags.find_first());

			do
			{
#ifndef NREQ
				if (count++ == 20)
					M_RAISE("internal error in comment class");
#endif

				if (m_stack.top() == flag)
				{
					appendFlag(flag, '/');
					m_stack.pop();
					flags.reset(flag);
					flag = Attribute(flags.find_first());
				}
				else
				{
					flag = Attribute(flags.find_next(flag));
				}
			}
			while (flags.any());
		}

		return reset;
	}

	Content *makeLangEntry(mstl::string const& lang)
	{
		Content*& content = m_map[lang];

		if (!content)
			content = new Content;

		return content;
	}

	void finish() override
	{
		m_result.clear();

		if (m_map.empty())
			return;

		bool empty = true;
		unsigned countLangs = 0;

		for (LangMap::const_iterator i = m_map.begin(); i != m_map.end(); ++i)
		{
			if (i->second->count > 0)
			{
				empty = false;

				if (!i->first.empty())
				{
					m_langFlags |= (i->first == "en") ? i18n::English : i18n::Other_Lang;
					m_isXml = true;
					countLangs += 1;
				}
			}
		}

		if (empty)
			return;

		if (m_fromLang)
		{
			M_ASSERT(m_toLang);

			LangMap::const_iterator i = m_map.find(*m_fromLang);

			if (i != m_map.end())
			{
				const Content* otherContent = i->second;
				Content*& content = m_map[*m_toLang];

				if (!content)
					content = new Content;
				else if (content->count > 0)
					content->items.push_back().flags.set(Delim);

				content->items += otherContent->items;
				content->count += otherContent->count;

				if (!m_toLang->empty())
				{
					m_langFlags |= (*m_toLang == "en") ? i18n::English : i18n::Other_Lang;
					m_isXml = true;
					countLangs += 1;
				}
			}
		}

		if (countLangs > 1)
			m_langFlags |= i18n::Multilingual;

		if (!m_isXml)
		{
			Content::Items const& items = m_map[mstl::string::empty_string]->items;

			if (!items.empty())
			{
				M_ASSERT(items.size() == 1);
				::flatten(items.front().text, m_result);
			}
		}
		else
		{
			m_result += ::Prefix;

			for (LangMap::const_iterator i = m_map.begin(); i != m_map.end(); ++i)
			{
				if (i->second->count > 0)
				{
					M_ASSERT(	m_wanted == 0
								|| m_wanted->find(i->first) != m_wanted->end()
								|| (m_toLang && *m_toLang == i->first));

					m_result.append("<:", 2);
					m_result.append(i->first);
					m_result.append('>');

					Content::Items::const_iterator k = i->second->items.begin();
					Content::Items::const_iterator e = i->second->items.end();

					bool pendingDelim = false;

					m_flags.reset();
					m_stack.clear();

					for ( ; k != e; ++k)
					{
						if (k->flags.test(Delim))
						{
							pendingDelim = true;
						}
						else
						{
							M_ASSERT(!k->text.empty());

							if (pendingDelim)
							{
								m_result.append(m_delim);
								pendingDelim = false;
							}

							Flags flags = k->flags - m_flags;

							if (m_flags.any())
								flags |= unsetFlags(m_flags - k->flags);

							if (flags.any())
							{
								Content::Items::const_iterator j(k + 1);

								while (j != e && (j->flags & flags).any())
									++j;

								while (--j != k && flags.any())
								{
									setFlags(flags & j->flags);
									flags -= j->flags;
								}

								setFlags(flags);
							}

							m_result += k->text;
						}
					}

					unsetFlags(m_flags);

					m_result.append("</:", 3);
					m_result.append(i->first);
					m_result.append('>');
				}
			}

			m_result += Suffix;
		}
	}

	mstl::string& text()
	{
		M_ASSERT(m_lang);

		if (m_lang->items.empty() || m_flags != m_lang->items.back().flags)
			m_lang->items.push_back(Item(m_flags));

		return m_lang->items.back().text;
	}

	void startLanguage(mstl::string const& lang) override
	{
		::memset(m_attr, 0, sizeof(m_attr));
		m_flags.reset();

		if (m_wanted == 0 || m_wanted->find(lang) != m_wanted->end())
			m_lang = makeLangEntry(lang);
		else if (m_fromLang && lang == *m_fromLang)
			m_lang = makeLangEntry(*m_toLang);
		else
			m_lang = nullptr;

		if (m_lang && m_lang->count > 0)
			m_lang->items.push_back().flags.set(Delim);
	}

	void endLanguage(mstl::string const&) override
	{
		if (m_containsAll)
			m_lang = makeLangEntry(mstl::string::empty_string);
		else
			m_lang = nullptr;
	}

	void startAttribute(Attribute attr) override
	{
		if (m_lang && ++m_attr[attr] == 1)
		{
			m_flags.set(attr);
			m_isXml = true;
		}
	}

	void endAttribute(Attribute attr) override
	{
		if (m_lang && --m_attr[attr] == 0)
		{
			m_flags.reset(attr);
			m_isXml = true;
		}
	}

	void content(mstl::string const& s) override
	{
		if (m_lang && !s.empty())
		{
			mstl::string& str = text();

			if (s.size() == 1)
				::appendChar(s[0], str);
			else
				str += s;

			m_lang->count++;
		}
	}

	void symbol(char s) override
	{
		if (m_lang)
		{
			mstl::string& str = text();

			str.append("<sym>", 5);
			str.append(s);
			str.append("</sym>", 6);
			m_lang->count++;
			m_isXml = true;
		}
	}

	void emoticon(mstl::string const& s) override
	{
		if (m_lang)
		{
			if (Comment::PreserveEmoticons)
			{
				mstl::string& str = text();

				str.append("<emo>", 5);
				str.append(s);
				str.append("</emo>", 6);
				m_isXml = true;
			}
			else
			{
				Comment::escapeString(s, text());
			}

			m_lang->count++;
		}
	}

	void nag(mstl::string const& s) override
	{
		if (m_lang)
		{
			mstl::string& str = text();

			str.append("<nag>", 5);
			str.append(s);
			str.append("</nag>", 6);
			m_lang->count++;
			m_isXml = true;
		}
	}

	void invalidXmlContent(mstl::string const& content) override
	{
		if (m_lang && !content.empty())
		{
			text().append(content);
			m_lang->count++;
		}
	}

	mstl::string&			m_result;
	Mode						m_mode;
	char						m_delim;
	LanguageSet const*	m_wanted;
	mstl::string const*	m_fromLang;
	mstl::string const*	m_toLang;
	Content*					m_lang;
	LangMap					m_map;
	unsigned&				m_langFlags;
	bool						m_isXml;
	bool						m_containsAll;
	Byte						m_attr[3];
	Flags						m_flags;
	AttrStack				m_stack;
};


struct DetectEmoticons : public Comment::Callback
{
	DetectEmoticons(mstl::string& result) :m_result(result), m_detected(false) {}

	bool detected() const { return m_detected; }

	void start()  override { m_result.append("<xml>"); }
	void finish() override { m_result.append("</xml>"); }

	void startLanguage(mstl::string const& lang) override
	{
		m_result += '<';
		m_result += ':';
		m_result += lang;
		m_result += '>';
	}

	void endLanguage(mstl::string const& lang) override
	{
		m_result += '<';
		m_result += '/';
		m_result += ':';
		m_result += lang;
		m_result += '>';
	}

	void startAttribute(Attribute attr) override
	{
		M_ASSERT(size_t(attr) < U_NUMBER_OF(::AttrMap));

		m_result += '<';
		m_result += ::AttrMap[attr];
		m_result += '>';
	}

	void endAttribute(Attribute attr) override
	{
		M_ASSERT(size_t(attr) < U_NUMBER_OF(::AttrMap));

		m_result += '<';
		m_result += '/';
		m_result += ::AttrMap[attr];
		m_result += '>';
	}

	void content(mstl::string const& str) override
	{
		if (::detectEmoticons(str, m_result))
			m_detected = true;
	}

	void symbol(char s) override
	{
		m_result.append("<sym>", 5);
		m_result.append(s);
		m_result.append("</sym>", 6);
	}

	void emoticon(mstl::string const& s) override
	{
		m_result.append("<emo>", 5);
		m_result.append(s);
		m_result.append("</emo>", 6);
	}

	void nag(mstl::string const& s) override
	{
		m_result.append("<nag>", 5);
		m_result.append(s);
		m_result.append("</nag>", 6);
	}

	void invalidXmlContent(mstl::string const& content) override
	{
		m_result = content;
	}

	mstl::string&	m_result;
	bool				m_detected;
};


struct CountLanguages : public Comment::Callback
{
	CountLanguages() :m_count(0) {}

	unsigned result() const { return m_count; }

	void start()  override {}
	void finish() override {}

	void startLanguage(mstl::string const& lang) override
	{
		if (!lang.empty())
			++m_count;
	}

	void endLanguage(mstl::string const& lang) override	{}
	void startAttribute(Attribute attr) override				{}
	void endAttribute(Attribute attr) override				{}
	void content(mstl::string const& s) override				{}
	void symbol(char s) override									{}
	void emoticon(mstl::string const& s) override			{}
	void nag(mstl::string const& s) override					{}

	void invalidXmlContent(mstl::string const& content) override {}

	unsigned m_count;
};


struct Flatten : public Comment::Callback
{
	static unsigned const Multilingual = i18n::English | i18n::Other_Lang;

	Flatten(mstl::string& result, encoding::CharSet encoding, unsigned langFlags)
		:m_result(result)
		,m_encoding(encoding)
		,m_langFlags(langFlags)
	{
	}

	void start()  override {}
	void finish() override {}

	void startLanguage(mstl::string const& lang) override
	{
		if ((m_langFlags & Multilingual) == Multilingual)
		{
			if (!m_result.empty())
				m_result += ' ';

			if (!lang.empty())
			{
				m_result += '<';
				m_result += lang;
				m_result += '>';
				m_result += ' ';
			}
		}
		else if (!m_result.empty())
		{
			m_result += ' ';
		}
	}

	void endLanguage(mstl::string const& lang) override	{}

	void startAttribute(Attribute attr) override				{}
	void endAttribute(Attribute attr) override				{}

	void content(mstl::string const& s) override
	{
		if (m_encoding == encoding::Utf8)
		{
			m_result.append(s);
		}
		else
		{
			char const* p = s.begin();
			char const* e = s.end();

			for ( ; p < e; p = sys::utf8::nextChar(p))
			{
				switch (sys::utf8::getChar(p))
				{
					case 0x2212: m_result.append('-'); break;		// Minus Sign
					case 0x223c: m_result.append('~'); break;		// Tilde operator
					case 0x2026: m_result.append("..."); break;	// Ellipsis
					case 0x2022: m_result.append('*'); break;		// Bullet
					case 0x2139: m_result.append('i'); break;		// Information Source
					case 0x20ac: m_result.append("Euro"); break;	// Euro Sign
					case 0x2605: m_result.append('*'); break;		// Black Star
					case 0x25cf: m_result.append('*'); break;		// Black Circle

					case 0x270e: // Lower Right Pencil
						m_result.append(m_encoding == encoding::Latin1 ? "\xc2\xbb" : "->");
						break;
#if 0
					case 0x203c: ::appendNag(m_result, nag::VeryGoodMove); break;
					case 0x2047: ::appendNag(m_result, nag::VeryPoorMove); break;
					case 0x2048: ::appendNag(m_result, nag::QuestionableMove); break;
					case 0x2049: ::appendNag(m_result, nag::SpeculativeMove); break;
					case 0x25a0: ::appendNag(m_result, nag::SingularMove); break;
					case 0x25a1: ::appendNag(m_result, nag::SingularMove); break;
					case 0x221e: ::appendNag(m_result, nag::UnclearPosition); break;
					case 0x2a72: ::appendNag(m_result, nag::WhiteHasASlightAdvantage); break;
					case 0x2a71: ::appendNag(m_result, nag::BlackHasASlightAdvantage); break;
					case 0x00b1: ::appendNag(m_result, nag::WhiteHasAModerateAdvantage); break;
					case 0x2213: ::appendNag(m_result, nag::BlackHasAModerateAdvantage); break;
					case 0x21d1: ::appendNag(m_result, nag::WhiteHasALastingInitiative); break;
					case 0x21d3: ::appendNag(m_result, nag::BlackHasALastingInitiative); break;
					case 0x21c8: ::appendNag(m_result, nag::WhiteHasGoodRookPlacement); break;
					case 0x21ca: ::appendNag(m_result, nag::BlackHasGoodRookPlacement); break;
					case 0x25b3: // fallthru
					case 0x2206: // fallthru
					case 0x20e4: ::appendNag(m_result, nag::WithTheIdea); break;
					case 0x22c1: // fallthru
					case 0x2228: ::appendNag(m_result, nag::AimedAgainst); break;
					case 0x2313: ::appendNag(m_result, nag::BetterMove); break;
					case 0x2264: ::appendNag(m_result, nag::WorseMove); break;
					case 0x2715: ::appendNag(m_result, nag::WeakPoint); break;
					case 0x22a5: ::appendNag(m_result, nag::Endgame); break;
					case 0x27fa: // fallthru
					case 0x21d4: ::appendNag(m_result, nag::Line); break;
					case 0x21d7: ::appendNag(m_result, nag::Diagonal); break;
					case 0x25e8: ::appendNag(m_result, nag::BishopsOfOppositeColor); break;
					case 0x2b12: ::appendNag(m_result, nag::Diagram); break;
					case 0x2b13: ::appendNag(m_result, nag::DiagramFromBlack); break;
					case 0x26af: ::appendNag(m_result, nag::SeparatedPawns); break;
					case 0x26ae: ::appendNag(m_result, nag::UnitedPawns); break;
					case 0x26a8: ::appendNag(m_result, nag::PassedPawn); break;
					case 0x230a: ::appendNag(m_result, nag::With); break;
					case 0x230b: ::appendNag(m_result, nag::Without); break;
					case 0x229e: ::appendNag(m_result, nag::Center); break;
					case 0x2014: ::appendNag(m_result, nag::See); break;
					case 0x25dd: // fallthru
					case 0x25ef: // fallthru
					case 0x3007: ::appendNag(m_result, nag::Space); break;
					case 0x2295: ::appendNag(m_result, nag::Zeitnot); break;
					case 0x21bb: ::appendNag(m_result, nag::Development); break;
					case 0x2299: ::appendNag(m_result, nag::Zugzwang); break;
					case 0x2192: ::appendNag(m_result, nag::Attack); break;
					case 0x2191: ::appendNag(m_result, nag::Initiative); break;
					case 0x21c6: ::appendNag(m_result, nag::Counterplay); break;
					case 0x25eb: ::appendNag(m_result, nag::PairOfBishops); break;
					case 0x00bb: // fallthru
					case 0x27eb: // fallthru
					case 0x226b: // fallthru
					case 0x300b: ::appendNag(m_result, nag::Kingside); break;
					case 0x00ab: // fallthru
					case 0x27ea: // fallthru
					case 0x226a: // fallthru
					case 0x300a: ::appendNag(m_result, nag::Queenside); break;
#endif
					default: m_result.append(p, sys::utf8::charLength(p)); break;
				}
			}
		}
	}

	void symbol(char s) override
	{
		if (m_encoding == encoding::Utf8)
			m_result += piece::utf8::asString(piece::fromLetter(s));
		else
			m_result += s;
	}

	void emoticon(mstl::string const& s) override
	{
		m_result += s;
	}

	void nag(mstl::string const& s) override
	{
		nag::ID		nag = nag::ID(::strtoul(s, nullptr, 10));
		char const*	sym = nag::toSymbol(nag);

		if (sym)
		{
			m_result += sym;
		}
		else
		{
			m_result += '$';
			m_result += s;
		}
	}

	void invalidXmlContent(mstl::string const& content) override { m_result = content; }

	mstl::string&		m_result;
	encoding::CharSet	m_encoding;
	unsigned				m_langFlags;
};


struct HtmlConv : public Comment::Callback
{
	HtmlConv(mstl::string& result) :m_result(result) {}

	void start()  override {}
	void finish() override {}

	void startLanguage(mstl::string const& lang) override
	{
		if (!lang.empty())
		{
			m_result.append("<lang id=\"", 10);
			m_result.append(lang);
			m_result.append("\">", 2);
		}
	}

	void endLanguage(mstl::string const& lang) override
	{
		if (!lang.empty())
			m_result.append("</lang>", 7);
	}

	void startAttribute(Attribute attr) override
	{
		switch (attr)
		{
			case Bold:			m_result.append("<b>", 3); break;
			case Italic:		m_result.append("<i>", 3); break;
			case Underline:	m_result.append("<u>", 3); break;
		}
	}

	void endAttribute(Attribute attr) override
	{
		switch (attr)
		{
			case Bold:			m_result.append("</b>", 4); break;
			case Italic:		m_result.append("</i>", 4); break;
			case Underline:	m_result.append("</u>", 4); break;
		}
	}

	void content(mstl::string const& str) override
	{
		char const* s = str.begin();
		char const* e = str.end();

		while (s < e)
		{
			sys::utf8::uchar code;

			s = sys::utf8::nextChar(s, code);

			if (code >= 128)
				m_result.format("&#x%04x;", code);
			else if (code == '\n')
				m_result.append("<br/>", 5);
			else
				::appendChar(code, m_result);
		}
	}

	void symbol(char s) override
	{
		char const* code = 0; // satisfies the compiler

		switch (s)
		{
			case 'K': code = "&#x2654;"; break;
			case 'Q': code = "&#x2655;"; break;
			case 'R': code = "&#x2656;"; break;
			case 'B': code = "&#x2657;"; break;
			case 'N': code = "&#x2658;"; break;
			case 'P': code = "&#x2659;"; break;
		}

		m_result.append(code, 8);
	}

	void emoticon(mstl::string const& s) override
	{
		m_result.append(s);
	}

	void nag(mstl::string const& s) override
	{
		m_result.append("<nag>", 5);
		m_result.append(s);
		m_result.append("</nag>", 6);
	}

	void invalidXmlContent(mstl::string const& content) override { m_result = content; }

	mstl::string& m_result;
};

} // namespace


inline static bool
match(char const* lhs, char const* rhs)
{
	return strcmp(lhs, rhs) == 0;
}


static void
xmlContent(void* cbData, XML_Char const* s, int len)
{
	XmlData* data = static_cast<XmlData*>(cbData);

	switch (data->state)
	{
		case XmlData::Symbol:
			data->cb.symbol(*s);
			break;

		case XmlData::Emoticon:
			{
				mstl::string str;
				str.hook(const_cast<char*>(s), len);
				data->cb.emoticon(str);
			}
			break;

		case XmlData::Nag:
			{
				mstl::string str;
				str.hook(const_cast<char*>(s), len);
				data->cb.nag(str);
			}
			break;

		case XmlData::Content:
			{
				mstl::string str;
				str.hook(const_cast<char*>(s), len);
				data->cb.content(str);
			}
			break;
	}
}


static void
startXmlElement(void* cbData, XML_Char const* elem, char const** attr)
{
	XmlData* data = static_cast<XmlData*>(cbData);

	switch (*elem)
	{
		case ':':
			return data->cb.startLanguage(elem + 1);

		case 'x':
			if (match(elem, "xml"))
				return;
			break;

		case 'b':
			if (match(elem, "b"))
				return data->cb.startAttribute(Comment::Callback::Bold);
			break;

		case 'i':
			if (match(elem, "i"))
				return data->cb.startAttribute(Comment::Callback::Italic);
			break;

		case 'u':
			if (match(elem, "u"))
				return data->cb.startAttribute(Comment::Callback::Underline);
			break;

		case 's':
			if (match(elem, "sym"))
			{
				data->state = XmlData::Symbol;
				return;
			}
			break;

		case 'e':
			if (match(elem, "emo"))
			{
				data->state = XmlData::Emoticon;
				return;
			}
			break;

		case 'n':
			if (match(elem, "nag"))
			{
				data->state = XmlData::Nag;
				return;
			}
			break;
	}

	M_ASSERT(!"cannot happen");
}


static void
endXmlElement(void* cbData, XML_Char const* elem)
{
	XmlData* data = static_cast<XmlData*>(cbData);

	switch (*elem)
	{
		case ':':
			return data->cb.endLanguage(elem + 1);

		case 'x':
			if (match(elem, "xml"))
				return;
			break;

		case 'b':
			if (match(elem, "b"))
				return data->cb.endAttribute(Comment::Callback::Bold);
			break;

		case 'i':
			if (match(elem, "i"))
				return data->cb.endAttribute(Comment::Callback::Italic);
			break;

		case 'u':
			if (match(elem, "u"))
				return data->cb.endAttribute(Comment::Callback::Underline);
			break;

		case 's':
			if (match(elem, "sym"))
			{
				data->state = XmlData::Content;
				return;
			}
			break;

		case 'e':
			if (match(elem, "emo"))
			{
				data->state = XmlData::Content;
				return;
			}
			break;

		case 'n':
			if (match(elem, "nag"))
			{
				data->state = XmlData::Content;
				return;
			}
			break;
	}

	M_ASSERT(!"cannot happen");
}


static void
checkLang(HtmlData* data)
{
	if (data->putLang == 1)
	{
		data->result.append("<:>", 3);
		data->putLang = 2;
	}
}


static void
htmlContent(void* cbData, XML_Char const* s, int len)
{
	HtmlData* data = static_cast<HtmlData*>(cbData);

	if (data->insideNag)
	{
		data->result.append(s, len);
	}
	else
	{
		char const* e = s + len;
		char const* p;

#ifdef FOREIGN_SOURCE
		bool specialExpected = true;
#endif

		checkLang(data);

		while (s < e)
		{
			if (s[0] & 0x80)
			{
				if (s[0] == '\xe2' && s[1] == '\x99' && ('\x94' <= s[2] && s[2] <= '\x99'))
				{
					switch (s[2])
					{
						case '\x94': data->result.append("<sym>K</sym>", 12); break;
						case '\x95': data->result.append("<sym>Q</sym>", 12); break;
						case '\x96': data->result.append("<sym>R</sym>", 12); break;
						case '\x97': data->result.append("<sym>B</sym>", 12); break;
						case '\x98': data->result.append("<sym>N</sym>", 12); break;
						case '\x99': data->result.append("<sym>P</sym>", 12); break;
					}

					data->isXml = true;
					data->isHtml = true;
#ifdef FOREIGN_SOURCE
					specialExpected = true;
#endif
					s += 3;
				}
				else if ((p = sys::utf8::nextChar(s)) - s > 1)
				{
					data->result.append(s, p - s);
					data->isHtml = true;
#ifdef FOREIGN_SOURCE
					specialExpected = false;
#endif
					s = p;
				}
				else
				{
					data->result += '?';
#ifdef FOREIGN_SOURCE
					specialExpected = false;
#endif
					++s;
				}
			}
			else if (isprint(*s))
			{
				if (*s == '\n')
				{
					data->result.append("<br/>", 5);
					s += 1;
				}
#ifdef FOREIGN_SOURCE
				else if (isDelimChar(*s))
				{
					data->result += *s++;
					specialExpected = true;
				}
				else if (specialExpected)
				{
					switch (*s)
					{
						case '$':
							if (isdigit(s[1]))
							{
								char const* p = s + 1;

								unsigned nag = 0;

								do
									nag = nag*10 + (*p - '0');
								while (++p < e && isdigit(*p));

								if (nag < nag::Scidb_Specific)
								{
									data->result.append("<nag>", 5);
									data->result.append(s + 1, p - s - 1);
									data->result.append("</nag>", 6);
									data->isXml = true;
									s = p;
								}
								else
								{
									data->result += *s++;
								}
							}
							else
							{
								data->result += *s++;
							}
							specialExpected = false;
							break;

							case 'K': case 'Q': case 'R': case 'B': case 'N': case 'P':
								if (s[1] == '\0' || isDelimChar(s[1]))
								{
									data->result.append("<sym>", 5);
									data->result += *s++;
									data->result.append("</sym>", 6);
									data->isXml = true;
								}
								else
								{
									data->result += *s++;
								}
								specialExpected = false;
								break;

							default:
								{
									char const* p = s + 1;

									nag::ID nag;

									while (p < s && !isDelimChar(*p))
										++p;

									if (p - s <= 5 && (nag = nag::fromSymbol(s, p - s)) != nag::Null)
									{
										data->result.format("<nag>%u</nag>", unsigned(nag));
										data->isXml = true;
									}
									else
									{
										data->result.append(s, p - s);
									}

									s = p;
								}
								break;
					}
				}
#else
				::appendChar(*s, data->result);
				++s;
#endif
			}
			else if (isspace(*s++))
			{
				data->result += '\n';
#ifdef FOREIGN_SOURCE
				specialExpected = true;
#endif
			}
			else
			{
				data->result += '?';
			}
		}
	}
}


static void
startHtmlElement(void* cbData, XML_Char const* elem, char const** attr)
{
	HtmlData* data = static_cast<HtmlData*>(cbData);

	switch (elem[0])
	{
		case 'b':
			if (elem[1] == '\0')
			{
				checkLang(data);
				data->result.append("<b>", 3);
				data->isXml = true;
			}
			else if (elem[1] == 'r' && elem[2] == '\0')
			{
				checkLang(data);
				data->result += '\n';
			}
			break;

		case 'i':
			if (elem[1] == '\0')
			{
				checkLang(data);
				data->result.append("<i>", 3);
				data->isXml = true;
			}
			break;

		case 'l':
			if (strcmp(elem, "lang") == 0)
			{
				if (	attr[0]
					&& strcmp(attr[0], "id") == 0
					&& attr[1]
					&& islower(attr[1][0])
					&& islower(attr[1][1])
					&& attr[1][2] == '\0')
				{
					if (data->putLang == 2)
						data->result.append("</:>", 4);

					data->result.append("<:", 2);
					data->result.append(attr[1]);
					data->result.append(">", 1);
					data->lang.assign(attr[1]);
					data->putLang = 0;
					data->isXml = true;

					if (attr[1][0] == 'e' && attr[1][1] == 'n')
					{
						data->langFlags |= i18n::English;

						if (data->langFlags & i18n::Other_Lang)
							data->langFlags |= i18n::Multilingual;
					}
					else
					{
						data->langFlags |= i18n::Other_Lang;

						if (data->langFlags & i18n::English)
							data->langFlags |= i18n::Multilingual;
						else if (data->othLang.empty())
							data->othLang.assign(elem);
						else if (data->othLang != elem)
							data->langFlags |= i18n::Multilingual;
					}
				}
				else
				{
					++data->skipLang;
				}
				return;
			}
			break;

		case 'n':
			if (strcmp(elem, "nag") == 0)
			{
				checkLang(data);
				data->result.append("<nag>", 5);
				data->insideNag = true;
				data->isXml = true;
			}
			break;

		case 'u':
			if (elem[1] == '\0')
			{
				checkLang(data);
				data->result.append("<u>", 3);
				data->isXml = true;
			}
			break;

		case 'x':
			if (::strcmp(elem, "xml") == 0)
				return;
			break;
	}

	data->isHtml = true;
}


static void
endHtmlElement(void* cbData, XML_Char const* elem)
{
	HtmlData* data = static_cast<HtmlData*>(cbData);

	switch (elem[0])
	{
		case 'b':
		case 'i':
		case 'u':
			if (elem[1] == '\0')
			{
				data->result.append("</", 2);
				data->result.append(elem[0]);
				data->result.append(">", 1);
			}
			break;

		case 'l':
			if (strcmp(elem, "lang") == 0)
			{
				if (data->skipLang)
				{
					--data->skipLang;
				}
				else
				{
					data->result.append("</:", 3);
					data->result.append(data->lang);
					data->result.append(">", 1);
					data->putLang = 1;
				}
			}
			break;

		case 'h':
			if (data->putLang == 2 && strcmp(elem, "html") == 0)
			{
				data->result.append("</:>", 4);
				data->putLang = 0;
			}
			break;

		case 'n':
			if (strcmp(elem, "nag") == 0)
			{
				data->result.append("</nag>", 6);
				data->insideNag = false;
			}
			break;
	}
}


Comment::Callback::~Callback() throw() {}

Comment::Comment() :m_langFlags(0) {}


Comment::Comment(mstl::string const& content, unsigned langFlags)
	:m_content(content)
	,m_langFlags(0)
{
}


Comment::LanguageSet const&
Comment::languageSet() const
{
	if (m_languageSet.empty() && !m_content.empty())
		collect();
	
	return m_languageSet;
}


void
Comment::append(Comment const& comment, char delim)
{
	M_REQUIRE(this != &comment);

	if (comment.isEmpty())
		return;

	if (m_content.empty())
	{
		*this = comment;
	}
	else
	{
		bool thisIsXml = isXml();
		bool thatIsXml = comment.isXml();

		if (thisIsXml && thatIsXml)
		{
			Split thisSplit;
			Split thatSplit;

			parse(thisSplit);
			comment.parse(thatSplit);
			Split::join(m_content, thisSplit.m_result, thatSplit.m_result, delim);
			m_languageSet.clear();
		}
		else if (thisIsXml)
		{
			Split thisSplit;
			Split::LangMap thatMap;

			parse(thisSplit);
			if (!comment.m_content.empty())
			{
				mstl::string content;
				escapeString(comment.m_content, content);
				thatMap[mstl::string::empty_string].swap(content);
			}
			Split::join(m_content, thisSplit.m_result, thatMap, delim);
			m_languageSet.clear();
		}
		else if (thatIsXml)
		{
			Split thatSplit;
			Split::LangMap thisMap;

			comment.parse(thatSplit);
			if (!m_content.empty())
			{
				mstl::string content;
				escapeString(m_content, content);
				thisMap[mstl::string::empty_string].swap(content);
			}
			Split::join(m_content, thisMap, thatSplit.m_result, delim);
			m_languageSet.clear();
		}
		else // if (!thisIsXml && !thatIsXml)
		{
			::appendDelim(m_content, delim);
			m_content.append(comment);
		}
	}

	m_langFlags |= comment.m_langFlags;
}


void
Comment::appendCommonSuffix(mstl::string const& suffix)
{
	if (isXml())
	{
		Split split;
		parse(split);
		Split::append(m_content, split.m_result, suffix);
	}
	else
	{
		m_content.append(suffix);
	}
}


void
Comment::merge(Comment const& comment, LanguageSet const& leadingLanguageSet)
{
	if (this == &comment || comment.isEmpty())
		return;

	bool thisIsXml = isXml();
	bool thatIsXml = comment.isXml();

	if (thisIsXml && thatIsXml)
	{
		Split thisSplit;
		Split thatSplit;

		parse(thisSplit);
		comment.parse(thatSplit);
		Split::merge(m_content, thisSplit.m_result, thatSplit.m_result, leadingLanguageSet);
		m_languageSet.clear();
	}
	else if (thisIsXml)
	{
		Split thisSplit;
		Split::LangMap thatMap;

		parse(thisSplit);
		if (!comment.m_content.empty())
		{
			mstl::string content;
			escapeString(comment.m_content, content);
			thatMap[mstl::string::empty_string].swap(content);
		}
		Split::merge(m_content, thisSplit.m_result, thatMap, leadingLanguageSet);
		m_languageSet.clear();
	}
	else if (thatIsXml)
	{
		Split thatSplit;
		Split::LangMap thisMap;

		comment.parse(thatSplit);
		if (!m_content.empty())
		{
			mstl::string content;
			escapeString(m_content, content);
			thisMap[mstl::string::empty_string].swap(content);
		}
		Split::merge(m_content, thisMap, thatSplit.m_result, leadingLanguageSet);
		m_languageSet.clear();
	}
	else if (leadingLanguageSet.find(mstl::string::empty_string) == leadingLanguageSet.end())
	{
		*this = comment;
	}
}


void
Comment::parse(Callback& cb) const
{
	if (isXml())
	{
		XML_Parser parser = ::XML_ParserCreate("UTF-8");

		if (parser == 0)
			DB_RAISE("couldn't allocate memory for parser");

		XmlData data(cb);

		XML_SetUserData(parser, &data);
		XML_SetElementHandler(parser, ::startXmlElement, ::endXmlElement);
		XML_SetCharacterDataHandler(parser, ::xmlContent);

		try
		{
			cb.start();

			if (!XML_Parse(parser, m_content, m_content.size(), true))
				cb.invalidXmlContent(m_content);

			cb.finish();
		}
		catch (...)
		{
			XML_ParserFree(parser);
			throw;
		}

		XML_ParserFree(parser);
	}
	else if (!m_content.empty())
	{
		cb.start();
		cb.startLanguage(mstl::string::empty_string);
		cb.content(m_content);
		cb.endLanguage(mstl::string::empty_string);
		cb.finish();
	}
}


void
Comment::collect() const
{
	M_ASSERT(m_languageSet.empty());

	Collector collector(m_languageSet);
	parse(collector);
}


void
Comment::collectLanguages(LanguageSet& result) const
{
	if (m_languageSet.empty() && !m_content.empty())
		collect();

	result.insert(m_languageSet.begin(), m_languageSet.end());
}


bool
Comment::containsLanguage(mstl::string const& lang) const
{
	if (m_content.empty())
		return false;

	if (m_languageSet.empty())
		collect();

	return m_languageSet.find(lang) != m_languageSet.end();
}


bool
Comment::containsAnyLanguageOf(LanguageSet const& langSet) const
{
	M_REQUIRE(!langSet.empty());

	if (m_content.empty())
		return false;

	if (m_languageSet.empty())
	{
		collect();

		if (m_languageSet.empty())
			return false;
	}

	LanguageSet::const_iterator i = langSet.begin();
	LanguageSet::const_iterator k = m_languageSet.begin();

	while (i->first < k->first)
	{
		if (++i == langSet.end())
			return false;
	}

	while (k->first < i->first)
	{
		if (++k == m_languageSet.end())
			return false;
	}

	return true;
}


unsigned
Comment::countLength(LanguageSet const& set) const
{
	if (m_content.empty())
		return 0;

	if (m_languageSet.empty())
		collect();

	unsigned length = 0;

	for (LanguageSet::const_iterator i = set.begin(); i != set.end(); ++i)
	{
		LanguageSet::const_iterator k = m_languageSet.find(i->first);

		if (k != m_languageSet.end())
			length += k->second;
	}

	return length;
}


unsigned
Comment::countLength(mstl::string const& lang) const
{
	if (m_content.empty())
		return 0;

	if (m_languageSet.empty())
		collect();

	LanguageSet::const_iterator k = m_languageSet.find(lang);
	return k == m_languageSet.end() ? 0 : k->second;
}


unsigned
Comment::length() const
{
	if (m_content.empty())
		return 0;

	if (m_languageSet.empty())
		collect();

	unsigned length = 0;

	for (LanguageSet::const_iterator i = m_languageSet.begin(); i != m_languageSet.end(); ++i)
		length += i->second;

	return length;
}


util::crc::checksum_t
Comment::computeChecksum(util::crc::checksum_t crc) const
{
	return util::crc::compute(crc, m_content, m_content.size());
}


void
Comment::swap(Comment& comment)
{
	m_content.swap(comment.m_content);
	mstl::swap(m_langFlags, comment.m_langFlags);
	m_languageSet.swap(comment.m_languageSet);
}


void
Comment::swap(mstl::string& content, unsigned langFlags)
{
	m_content.swap(content);
	m_languageSet.clear();
	m_langFlags = langFlags;
}


void
Comment::clear()
{
	m_content.clear();
	m_languageSet.clear();
	m_langFlags = 0;
}


void
Comment::flatten(mstl::string& result, encoding::CharSet encoding, unsigned langFlags) const
{
	if (m_content.empty())
		return;

	if (isXml())
	{
		CountLanguages count;
		parse(count);
		Flatten flatten(result, encoding, langFlags);
		result.reserve(result.size() + m_content.size() + 100);
		parse(flatten);
	}
	else
	{
		::flatten(m_content, result);
	}
}


void
Comment::detectEmoticons()
{
	mstl::string content;
	DetectEmoticons detector(content);

	if (isXml())
	{
		parse(detector);
	}
	else
	{
		mstl::string newContent;

		newContent.append("<xml>");
		escapeString(m_content, newContent);
		newContent.append("</xml>");
		m_content.swap(newContent);

		parse(detector);

		if (!detector.detected())
			m_content.swap(newContent);
	}

	if (detector.detected())
		content.swap(m_content);
}


void
Comment::toHtml(mstl::string& result) const
{
	if (m_content.empty())
		return;

	result.reserve(result.size() + m_content.size() + 100);
	result.append("<html>");

	if (isXml())
	{
		HtmlConv conv(result);
		parse(conv);
	}
	else
	{
		char const* s = m_content.begin();
		char const* e = m_content.end();

		while (s < e)
		{
			switch (*s)
			{
				case '<':	++s; result.append("&lt;",   4); break;
				case '>':	++s; result.append("&gt;",   4); break;
				case '&':	++s; result.append("&amp;",  5); break;
				case '\'':	++s; result.append("&apos;", 6); break;
				case '"':	++s; result.append("&quot;", 6); break;
				case '\n':	++s; result += "<br/>"; break;

				default:
					{
						sys::utf8::uchar code;

						s = sys::utf8::nextChar(s, code);

						if (code < 0x80)
							result += char(code);
						else
							result.format("&#x%04x;", code);
					}
					break;
			}
		}
	}

	result.append("</html>");
}


void
Comment::normalize(Mode mode, char delim)
{
	if (m_content.empty())
		return;

	if (!isXml())
		return;

	Normalize normalize(m_content, m_langFlags, mode, delim);
	parse(normalize);
}


void
Comment::remove(mstl::string const& lang)
{
	if (m_content.empty())
		return;

	if (isXml())
	{
		if (m_languageSet.empty())
			collect();
		m_languageSet.erase(lang);
		strip(m_languageSet);
	}
	else if (lang.empty())
	{
		m_content.clear();
		m_languageSet.clear();
	}
}


void
Comment::remove(LanguageSet const& languageSet)
{
	if (m_content.empty())
		return;

	if (isXml())
	{
		if (m_languageSet.empty())
			collect();
		for (LanguageSet::const_iterator i = languageSet.begin(); i != languageSet.end(); ++i)
			m_languageSet.erase(i->first);
		strip(m_languageSet);
	}
	else if (languageSet.find(mstl::string::empty_string) != languageSet.end())
	{
		m_content.clear();
		m_langFlags = 0;
		m_languageSet.clear();
	}
}


void
Comment::strip(LanguageSet const& set)
{
	if (m_content.empty())
		return;

	if (set.empty())
	{
		m_content.clear();
		m_langFlags = 0;
	}
	else if (isXml())
	{
		Normalize normalize(m_content, m_langFlags, PreserveEmoticons, '\0', &set);
		parse(normalize);
	}
	else if (set.find(mstl::string::empty_string) == set.end())
	{
		m_content.clear();
		m_langFlags = 0;
	}

	m_languageSet.clear();
}


void
Comment::strip(mstl::string const& lang, unsigned langFlags)
{
	if (m_content.empty())
		return;

	if (isXml())
	{
		LanguageSet set;
		Normalize normalize(m_content, m_langFlags, PreserveEmoticons, '\0', &set);

		set[lang] = 0;
		parse(normalize);

		if (!m_content.empty() && langFlags == i18n::None)
		{
			mstl::string result;
			flatten(result, encoding::Utf8, i18n::None);
			m_content.swap(result);
			m_langFlags = i18n::None;
		}
	}
	else if (!lang.empty())
	{
		m_content.clear();
		m_langFlags = 0;
	}

	m_languageSet.clear();
}


void
Comment::copy(mstl::string const& fromLang, mstl::string const& toLang, bool stripOriginal)
{
	if (fromLang == toLang)
		return;

	if (stripOriginal)
	{
		if (m_languageSet.empty())
			collect();
		m_languageSet.erase(fromLang);

		Normalize normalize(	m_content,
									m_langFlags,
									PreserveEmoticons,
									'\n',
									&m_languageSet,
									&fromLang,
									&toLang);

		parse(normalize);
		m_languageSet.clear();
	}
	else
	{
		Normalize normalize(	m_content,
									m_langFlags,
									PreserveEmoticons,
									'\n',
									nullptr,
									&fromLang,
									&toLang);

		parse(normalize);
		m_languageSet.clear();
	}
}


bool
Comment::fromHtml(mstl::string const& s)
{
	if (s.empty())
	{
		clear();
		return true;
	}

	if (::strncmp(s, "<xml>", 5) == 0)
		return false;

	XML_Parser parser = ::XML_ParserCreate("ISO-8859-1");

	if (parser == 0)
		DB_RAISE("couldn't allocate memory for parser");

	bool sucesss = false;

	HtmlData data(m_content, m_langFlags);
	m_content.reserve(s.size() + 20);

	XML_SetUserData(parser, &data);
	XML_SetElementHandler(parser, ::startHtmlElement, ::endHtmlElement);
	XML_SetCharacterDataHandler(parser, ::htmlContent);

	try
	{
		mstl::string buf;
		mstl::string const* str;

		if (::strncmp(s, "<html>", 6) == 0)
		{
			str = &s;
		}
		else
		{
			buf.reserve(s.size() + 20);
			buf.append("<html>", 6);
			buf.append(s);
			buf.append("</html>", 7);
			str = &buf;
		}

		if (XML_Parse(parser, str->c_str(), str->size(), true))
		{
			sucesss = data.success();

			if (data.isXml)
			{
				m_content.insert(m_content.begin(), ::Prefix);
				m_content.append(::Suffix);
			}
			else if (!m_content.empty())
			{
				M_ASSERT(::strncmp(m_content, "<:>", 3) == 0);

				mstl::string str;

				m_content.erase(mstl::string::size_type(0), mstl::string::size_type(3));
				m_content.erase(m_content.size() - 4, size_t(4));

				::flatten(m_content, str);
				m_content.swap(str);
			}

			detectEmoticons();
		}
	}
	catch (...)
	{
		XML_ParserFree(parser);
		throw;
	}

	XML_ParserFree(parser);
	return sucesss;
}


void
Comment::escapeString(mstl::string const& src, mstl::string& dst)
{
	dst.reserve(dst.size() + 2*src.size());

	for (mstl::string::const_iterator i = src.begin(); i != src.end(); ++i)
		::appendChar(*i, dst);
}


bool
Comment::convertCommentToXml(	mstl::string const& comment,
										Comment& result,
										encoding::CharSet encoding)
{
	M_REQUIRE(&comment != &result.content());

	if (	comment.size() >= 13
		&& strncmp(comment.begin(), "<html>", 6) == 0
		&& strncmp(comment.end() - 7, "</html>", 7) == 0)
	{
		return result.fromHtml(comment); // NOTE: encoding is ignored
	}

	char const* s = comment.c_str();
	bool hasDiagram = false;

	result.m_content.reserve(comment.size() + 100);

	if (s[0] == '#' && (s[1] == '\0' || ::isspace(s[1])))
	{
		hasDiagram = true;
		s = ::skipSpaces(s + 1);
	}
	else
	{
		char const* t = s;

		while (::isalpha(*t))
			++t;
		while (*t == ' ' || *t == '\t')
			++t;

		if (::strncmp(t, "{#}", 3) == 0)
		{
			hasDiagram = true;
			s = ::skipSpaces(t + 3);
		}
	}

	mstl::string lang;
	mstl::string othLang;

	bool specialExpected = true;
	bool isXml = false;

	while (*s)
	{
		if (*s & 0x80)
		{
			if (encoding == encoding::Utf8)
			{
				char const* e = sys::utf8::nextChar(s);

				if (s[0] == '\xe2' && s[1] == '\x99' && ('\x94' <= s[2] && s[2] <= '\x99'))
				{
					switch (s[2])
					{
						case '\x94': result.m_content.append("<sym>K</sym>", 12); isXml = true; break;
						case '\x95': result.m_content.append("<sym>Q</sym>", 12); isXml = true; break;
						case '\x96': result.m_content.append("<sym>R</sym>", 12); isXml = true; break;
						case '\x97': result.m_content.append("<sym>B</sym>", 12); isXml = true; break;
						case '\x98': result.m_content.append("<sym>N</sym>", 12); isXml = true; break;
						case '\x99': result.m_content.append("<sym>P</sym>", 12); isXml = true; break;
					}
				}
				else
				{
					result.m_content.append(s, e - s);
				}

				s = e;
			}
			else if (::isgraph(*s))
			{
				result.m_content += *s++;
			}
			else
			{
				result.m_content += '?';
				++s;
			}

			specialExpected = true;
		}
		else if (::isalnum(*s) && !specialExpected)
		{
			do
				result.m_content.append(*s++);
			while (::isalnum(*s));

			specialExpected = isDelimChar(*s);
		}
		else if (::isspace(*s))
		{
			++s;

			if (	s[0] == '<'
				&& ::islower(s[1])
				&& ::islower(s[2])
				&& s[3] == '>'
				&& s[4] == ' ')
			{
				if (!lang.empty())
				{
					result.m_content.append("</:", 3);
					result.m_content.append(lang);
					result.m_content.append(">", 1);
				}

				lang.assign(s + 1, 2);
				result.m_content.append("<:", 2);
				result.m_content.append(lang);
				result.m_content.append(">", 1);

				if (s[1] == 'e' && s[2] == 'n')
				{
					result.m_langFlags |= i18n::English;
					
					if (result.m_langFlags & i18n::Other_Lang)
						result.m_langFlags |= i18n::Multilingual;
				}
				else
				{
					result.m_langFlags |= i18n::Other_Lang;

					if (result.m_langFlags & i18n::English)
						result.m_langFlags |= i18n::Multilingual;
					else if (othLang.empty())
						othLang = lang;
					else if (othLang != lang)
						result.m_langFlags |= i18n::Multilingual;
				}

				isXml = true;
				s += 5;
			}
			else
			{
				result.m_content += ' ';
			}

			specialExpected = true;
		}
		else if (::isprint(*s))
		{
			unsigned	len;
			nag::ID	nag = specialExpected ? nag::parseSymbol(s, len) : nag::Null;

			if (nag != nag::Null && isDelimChar(s[len]))
			{
				result.m_content.format("<nag>%u</nag>", unsigned(nag));
				s += len;
				isXml = true;
			}
			else
			{
				specialExpected = true;

				switch (*s)
				{
					case '&':	result.m_content.append("&amp;",  5); ++s; break;
					case '>':	result.m_content.append("&gt;",   4); ++s; break;
					case '\'':	result.m_content.append("&apos;", 6); ++s; break;
					case '"':	result.m_content.append("&quot;", 6); ++s; break;

					case '<':
						if (::tolower(s[1]) == 'b' && ::tolower(s[2]) == 'r' && s[3] != '>')
						{
							char const* t = s + 3;

							while (::isspace(*t))
								++t;

							if (*t == '>')
							{
								result.m_content.append('\n');
								s = t + 1;
							}
							else
							{
								result.m_content.append("&lt;", 4);
								++s;
							}
						}
						else if (::islower(s[1]) && ::islower(s[2]) && s[3] == '>' && s[4] == ' ')
						{
							while (!result.m_content.empty() && result.m_content.back() == ' ')
								result.m_content.set_size(result.m_content.size() - 1);
							result.m_content.append("</:", 3);
							result.m_content.append(lang);
							result.m_content.append(">", 1);
							lang.assign(s + 1, 2);
							result.m_content.append("<:", 2);
							result.m_content.append(lang);
							result.m_content.append(">", 1);
							isXml = true;
							s += 5;
						}
						else
						{
							result.m_content.append("&lt;", 4);
							++s;
						}
						break;

					default:
						if (*s == '$')
						{
							if (::isdigit(*++s))
							{
								char* e = const_cast<char*>(s);
								unsigned nag = ::strtoul(s, &e, 10);

								if (nag < nag::Scidb_Last)
								{
									result.m_content.append("<nag>", 5);
									result.m_content.append(s, e - s);
									result.m_content.append("</nag>", 6);
									isXml = true;
								}

								s = e;
							}
							specialExpected = false;
						}
						else if (::isDelimChar(*s))
						{
							result.m_content += *s++;
							specialExpected = true;
						}
						else
						{
							result.m_content += *s++;
							specialExpected = isDelimChar(*s);
						}
						break;
				}
			}
		}
		else
		{
			result.m_content += '?';
			specialExpected = false;
			++s;
		}
	}

	if (isXml)
	{
		mstl::string str;
		str.swap(result.m_content);
		str.rtrim();

		result.m_content.append(::Prefix);
		result.m_content.append("<:>", 3);
		result.m_content.append(str);
		result.m_content.append("</:", 3);
		result.m_content.append(lang);
		result.m_content.append(">", 1);
		result.m_content += ::Suffix;
		result.normalize(ExpandEmoticons, '\0');
	}

	return hasDiagram;
}

// vi:set ts=3 sw=3:
