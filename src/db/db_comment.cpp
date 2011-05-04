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
// Copyright: (C) 2010-2011 Gregor Cramer
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

#include "m_set.h"
#include "m_map.h"
#include "m_utility.h"

#include <expat.h>
#include <string.h>
#include <stdlib.h>

using namespace db;


namespace {

struct Data
{
	enum State { Content, Symbol, Nag };

	Data(Comment::Callback& callback) :cb(callback), state(Content) {}

	Comment::Callback&	cb;
	State						state;
};


struct Collector : public Comment::Callback
{
	Collector(Comment::LanguageSet& set) :m_set(set), m_length(&m_set[mstl::string::empty_string]) {}

	void start()  {}
	void finish() {}

	void startLanguage(mstl::string const& lang)	{ m_length = &m_set[lang]; }
	void endLanguage(mstl::string const& lang)	{ m_length = &m_set[mstl::string::empty_string]; }

	void startAttribute(Attribute attr)				{}
	void endAttribute(Attribute attr)				{}

	void content(mstl::string const& s)				{ *m_length += s.size(); }
	void nag(mstl::string const& s)					{ *m_length += 1; }
	void symbol(char s)									{ *m_length += 1; }

	void invalidXmlContent(mstl::string const& content)
	{
		m_set.clear();
		m_set[mstl::string::empty_string] = content.size();
	}

	Comment::LanguageSet& m_set;
	unsigned* m_length;
};


struct Normalize : public Comment::Callback
{
	struct Content
	{
		Content() :length(0) {}

		mstl::string	str;
		unsigned			length;
	};

	typedef mstl::map<mstl::string,Content> LangMap;

	Normalize(mstl::string& result, mstl::string const* remove = 0)
		:m_result(result)
		,m_remove(remove)
		,m_lang(0)
		,m_isXml(false)
	{
		::memset(m_attr, 0, sizeof(m_attr));
	}

	void start() { endLanguage(mstl::string::empty_string); }

	void finish()
	{
		m_result.clear();

		for (LangMap::const_iterator i = m_map.begin(); i != m_map.end(); ++i)
		{
			if (i->second.length > 0)
			{
				if (m_remove == 0 || i->first != *m_remove)
				{
					if (i->first.empty())
					{
						m_result += i->second.str;
					}
					else
					{
						m_result += '<';
						m_result += ':';
						m_result += i->first;
						m_result += '>';
						m_result += i->second.str;
						m_result += '<';
						m_result += '/';
						m_result += ':';
						m_result += i->first;
						m_result += '>';

						m_isXml = true;
					}
				}
			}
		}

		if (m_isXml)
		{
			m_result.insert(0u, "<xml>");
			m_result += "</xml>";
		}
	}

	void startLanguage(mstl::string const& lang)
	{
		m_lang = &m_map[lang];

		if (!m_lang->str.empty())
		{
			m_lang->str += '\n';
			m_lang->length += 1;
		}
	}

	void endLanguage(mstl::string const& lang)
	{
		m_lang = &m_map[mstl::string::empty_string];
	}

	void startAttribute(Attribute attr)
	{
		if (++m_attr[attr] == 1)
		{
			m_lang->str += '<';
			m_lang->str += attr;
			m_lang->str += '>';
			m_isXml = true;
		}
	}

	void endAttribute(Attribute attr)
	{
		if (--m_attr[attr] == 0)
		{
			m_lang->str += '<';
			m_lang->str += '/';
			m_lang->str += attr;
			m_lang->str += '>';
		}
	}

	void content(mstl::string const& s)
	{
		if (s.size() == 1)
		{
			switch (s[0])
			{
				case '<': m_lang->str.append("&lt;", 4); break;
				case '>': m_lang->str.append("&gt;", 4); break;
				case '&': m_lang->str.append("&amp;", 5); break;
			}
		}
		else
		{
			m_lang->str += s;
		}

		m_lang->length += s.size();
	}

	void symbol(char s)
	{
		m_lang->str += "<sym>";
		m_lang->str += s;
		m_lang->str += "</sym>";
		m_lang->length += 1;
		m_isXml = true;
	}

	void nag(mstl::string const& s)
	{
		m_lang->str += "<nag>";
		m_lang->str += s;
		m_lang->str += "</nag>";
		m_lang->length += 1;
		m_isXml = true;
	}

	void invalidXmlContent(mstl::string const& content)
	{
		m_lang->str += content;
		m_lang->length += content.size();
	}

	mstl::string&			m_result;
	mstl::string const*	m_remove;
	Content*					m_lang;
	LangMap					m_map;
	bool						m_isXml;
	Byte						m_attr[256];
};


struct Flatten : public Comment::Callback
{
	Flatten(mstl::string& result) :m_result(result), m_isAll(true) {}

	void start()	{}
	void finish()	{}

	// TDDO: possibly we should prefix current comment with "{de} ".
	void startLanguage(mstl::string const& lang)
	{
		if (!m_result.empty())
		{
			if (m_isAll)
				m_result += ' ';
			else
				m_result += '\n';
		}

		m_isAll = false;
	}

	void endLanguage(mstl::string const& lang)	{}

	void startAttribute(Attribute attr)				{}
	void endAttribute(Attribute attr)				{}

	void content(mstl::string const& s)				{ m_result += s; }

	// TODO: should take language into account
	void symbol(char s)									{ m_result += s; }

	void nag(mstl::string const& s)
	{
		nag::ID		nag = nag::ID(::strtoul(s, 0, 10));
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

	void invalidXmlContent(mstl::string const& content) { m_result += content; }

	mstl::string&	m_result;
	bool				m_isAll;
};

} // namespace


inline static bool
match(char const* lhs, char const* rhs)
{
	return strcmp(lhs, rhs) == 0;
}


static void
content(void* cbData, XML_Char const* s, int len)
{
	Data* data = static_cast<Data*>(cbData);

	switch (data->state)
	{
		case Data::Symbol:
			data->cb.symbol(*s);
			break;

		case Data::Nag:
			data->cb.nag(mstl::string(s, len));
			break;

		case Data::Content:
			data->cb.content(mstl::string(s, len));
			break;
	}

}


static void
startElement(void* cbData, XML_Char const* elem, char const** attr)
{
	Data* data = static_cast<Data*>(cbData);

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
				data->state = Data::Symbol;
				return;
			}
			break;

		case 'n':
			if (match(elem, "nag"))
			{
				data->state = Data::Nag;
				return;
			}
			break;
	}

	M_ASSERT(!"cannot happen");
//	data->cb.startElement(elem);
}


static void
endElement(void* cbData, XML_Char const* elem)
{
	Data* data = static_cast<Data*>(cbData);

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
				data->state = Data::Content;
				return;
			}
			break;

		case 'n':
			if (match(elem, "nag"))
			{
				data->state = Data::Content;
				return;
			}
			break;
	}

	M_ASSERT(!"cannot happen");
//	data->cb.endElement(elem);
}


Comment::Callback::~Callback() throw() {}

Comment::Comment() {}
Comment::Comment(mstl::string const& content) :m_content(content) {}


void
Comment::parse(Callback& cb) const
{
	if (isXml())
	{
		XML_Parser parser = ::XML_ParserCreate("UTF-8");

		if (parser == 0)
			DB_RAISE("couldn't allocate memory for parser");

		Data data(cb);

		XML_SetUserData(parser, &data);
		XML_SetElementHandler(parser, ::startElement, ::endElement);
		XML_SetCharacterDataHandler(parser, ::content);

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
	if (m_languageSet.empty())
		collect();

	result.insert(m_languageSet.begin(), m_languageSet.end());
}


unsigned
Comment::countLength(LanguageSet const& set) const
{
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
	if (m_languageSet.empty())
		collect();

	LanguageSet::const_iterator k = m_languageSet.find(lang);
	return k == m_languageSet.end() ? 0 : k->second;
}


void
Comment::swap(Comment& comment)
{
	m_content.swap(comment.m_content);
	m_languageSet.swap(comment.m_languageSet);
}


void
Comment::swap(mstl::string& content)
{
	m_content.swap(content);
	m_languageSet.clear();
}


void
Comment::setContent(mstl::string const& s)
{
	m_content = s;
	m_languageSet.clear();
}


void
Comment::clear()
{
	m_content.clear();
	m_languageSet.clear();
}


void
Comment::flatten(mstl::string& result) const
{
	if (isXml())
	{
		Flatten flatten(result);
		result.reserve(result.size() + m_content.size());
		parse(flatten);
	}
	else
	{
		result.append(m_content);
	}
}


void
Comment::normalize()
{
	if (!isXml())
		return;

	Normalize normalize(m_content);
	parse(normalize);
}


void
Comment::remove(mstl::string const& lang)
{
	if (!isXml())
		return;

	Normalize normalize(m_content, &lang);
	parse(normalize);
	m_languageSet.erase(lang);
}

// vi:set ts=3 sw=3:
