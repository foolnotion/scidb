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

#include "sys_utf8_codec.h"

#include "m_set.h"
#include "m_map.h"
#include "m_utility.h"

#include <expat.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

using namespace db;


static mstl::string const prefix("<xml>");
static mstl::string const suffix("</xml>");


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
	return c == '\0' || ::strchr(" \t\n/.,;:!?", c);
}


static void
append(mstl::string& dst, mstl::string const& src, bool isXml)
{
	if (isXml)
	{
		dst.append(src, prefix.size(), src.size() - prefix.size() - suffix.size());
	}
	else
	{
		dst.append("<:>", 3);
		dst.append(src);
		dst.append("</:>", 4);
	}
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


namespace {

struct XmlData
{
	enum State { Content, Symbol, Nag };

	XmlData(Comment::Callback& callback) :cb(callback), state(Content) {}

	Comment::Callback&	cb;
	State						state;
};


struct HtmlData
{
	HtmlData(mstl::string& s, bool &engFlag, bool& othFlag)
		:result(s)
		,skipLang(0)
		,putLang(1)
		,engFlag(engFlag)
		,othFlag(othFlag)
		,isXml(false)
		,isHtml(false)
		,insideNag(false)
	{
	}

	bool success() const { return isHtml && putLang != 2 && !insideNag && lang.empty(); }

	mstl::string& result;
	mstl::string  lang;

	unsigned skipLang;
	unsigned putLang;

	bool& engFlag;
	bool& othFlag;

	bool isXml;
	bool isHtml;
	bool insideNag;
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
	typedef Comment::LanguageSet LanguageSet;

	Normalize(mstl::string& result, bool& engFlag, bool& othFlag, char delim, LanguageSet const* wanted = 0)
		:m_result(result)
		,m_delim(delim)
		,m_wanted(wanted)
		,m_lang(0)
		,m_engFlag(engFlag)
		,m_othFlag(othFlag)
		,m_isXml(false)
	{
		::memset(m_attr, 0, sizeof(m_attr));
		m_engFlag = m_othFlag = false;
	}

	void start() { endLanguage(mstl::string::empty_string); }

	void finish()
	{
		m_result.clear();

		if (!m_map.empty())
		{
			for (LangMap::const_iterator i = m_map.begin(); i != m_map.end(); ++i)
			{
				if (!i->first.empty() && i->second.length > 0)
					m_isXml = true;
			}

			if (!m_isXml)
			{
				M_ASSERT(m_map.find(mstl::string::empty_string) != m_map.end());
				m_result = m_map.find(mstl::string::empty_string)->second.str;
			}
			else
			{
				m_result += ::prefix;

				for (LangMap::const_iterator i = m_map.begin(); i != m_map.end(); ++i)
				{
					if (i->second.length > 0)
					{
						M_ASSERT(m_wanted == 0 || m_wanted->find(i->first) != m_wanted->end());

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
					}
				}

				m_result += suffix;
			}
		}
	}

	void startLanguage(mstl::string const& lang)
	{
		if (m_wanted == 0 || m_wanted->find(lang) != m_wanted->end())
		{
			m_lang = &m_map[lang];
			m_lang->length += ::appendDelim(m_lang->str, m_delim);

			if (!lang.empty())
			{
				if (lang == "en")
					m_engFlag = true;
				else
					m_othFlag = true;
			}
		}
		else
		{
			m_lang = 0;
		}
	}

	void endLanguage(mstl::string const& lang)
	{
		if (m_wanted == 0 || m_wanted->find(mstl::string::empty_string) != m_wanted->end())
			m_lang = &m_map[mstl::string::empty_string];
		else
			m_lang = 0;
	}

	void startAttribute(Attribute attr)
	{
		if (m_lang && ++m_attr[attr] == 1)
		{
			m_lang->str += '<';
			m_lang->str += attr;
			m_lang->str += '>';
			m_isXml = true;
		}
	}

	void endAttribute(Attribute attr)
	{
		if (m_lang && --m_attr[attr] == 0)
		{
			m_lang->str += '<';
			m_lang->str += '/';
			m_lang->str += attr;
			m_lang->str += '>';
		}
	}

	void content(mstl::string const& s)
	{
		if (m_lang)
		{
			if (s.size() == 1)
			{
				switch (s[0])
				{
					case '<':	m_lang->str.append("&lt;", 4); break;
					case '>':	m_lang->str.append("&gt;", 4); break;
					case '&':	m_lang->str.append("&amp;", 5); break;
					default:		m_lang->str.append(s[0]); break;
				}
			}
			else
			{
				m_lang->str += s;
			}

			m_lang->length += s.size();
		}
	}

	void symbol(char s)
	{
		if (m_lang)
		{
			m_lang->str.append("<sym>", 5);
			m_lang->str.append(s);
			m_lang->str.append("</sym>", 6);
			m_lang->length += 1;
			m_isXml = true;
		}
	}

	void nag(mstl::string const& s)
	{
		if (m_lang)
		{
			m_lang->str.append("<nag>", 5);
			m_lang->str.append(s);
			m_lang->str.append("</nag>", 6);
			m_lang->length += 1;
			m_isXml = true;
		}
	}

	void invalidXmlContent(mstl::string const& content)
	{
		if (m_lang)
		{
			m_lang->str = content;
			m_lang->length = content.size();
		}
	}

	mstl::string&			m_result;
	char						m_delim;
	LanguageSet const*	m_wanted;
	Content*					m_lang;
	LangMap					m_map;
	bool&						m_engFlag;
	bool&						m_othFlag;
	bool						m_isXml;
	Byte						m_attr[256];
};


struct Flatten : public Comment::Callback
{
	Flatten(mstl::string& result, encoding::CharSet encoding) :m_result(result), m_encoding(encoding) {}

	void start()	{}
	void finish()	{}

	void startLanguage(mstl::string const& lang)
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

	void endLanguage(mstl::string const& lang)	{}

	void startAttribute(Attribute attr)				{}
	void endAttribute(Attribute attr)				{}

	void content(mstl::string const& s)				{ m_result += s; }

	void symbol(char s)
	{
		if (m_encoding == encoding::Utf8)
			m_result += piece::utf8::asString(piece::fromLetter(s));
		else
			m_result += s;
	}

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

	void invalidXmlContent(mstl::string const& content) { m_result = content; }

	mstl::string&		m_result;
	encoding::CharSet	m_encoding;
};


struct HtmlConv : public Comment::Callback
{
	HtmlConv(mstl::string& result) :m_result(result) {}

	void start()	{}
	void finish()	{}

	void startLanguage(mstl::string const& lang)
	{
		if (!lang.empty())
		{
			m_result.append("<lang id=\"", 10);
			m_result.append(lang);
			m_result.append("\">", 2);
		}
	}

	void endLanguage(mstl::string const& lang)
	{
		if (!lang.empty())
			m_result.append("</lang>", 7);
	}

	void startAttribute(Attribute attr)
	{
		switch (attr)
		{
			case Bold:			m_result.append("<b>", 3); break;
			case Italic:		m_result.append("<i>", 3); break;
			case Underline:	m_result.append("<u>", 3); break;
		}
	}

	void endAttribute(Attribute attr)
	{
		switch (attr)
		{
			case Bold:			m_result.append("</b>", 4); break;
			case Italic:		m_result.append("</i>", 4); break;
			case Underline:	m_result.append("</u>", 4); break;
		}
	}

	void content(mstl::string const& str)
	{
		char const* s = str.begin();
		char const* e = str.end();

		while (s < e)
		{
			uint16_t code;

			s = sys::utf8::Codec::utfNextChar(s, code);

			if (code < 128)
				m_result += char(code);
			else
				m_result.format("&#x%04x;", code);
		}
	}

	void symbol(char s)
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

	void nag(mstl::string const& s)
	{
		m_result.append("<nag>", 5);
		m_result.append(s);
		m_result.append("</nag>", 6);
	}

	void invalidXmlContent(mstl::string const& content) { m_result = content; }

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

		case XmlData::Nag:
			data->cb.nag(mstl::string(s, len));
			break;

		case XmlData::Content:
			data->cb.content(mstl::string(s, len));
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

		if (data->putLang == 1)
		{
			data->result.append("<:>", 3);
			data->putLang = 2;
		}

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
					s += 3;
				}
				else if ((p = sys::utf8::Codec::utfNextChar(s)) - s > 1)
				{
					data->result.append(s, p - s);
					data->isHtml = true;
					s = p;
				}
				else
				{
					data->result += '?';
					++s;
				}
			}
			else if (isprint(*s))
			{
#ifdef FOREIGN_SOURCE
				if (isDelimChar(*s))
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
				data->result += *s++;
#endif
			}
			else if (isspace(*s++))
			{
				data->result += '\n';
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
				data->result.append("<b>", 3);
				data->isXml = true;
			}
			else if (elem[1] == 'r' && elem[2] == '0')
			{
				data->result += '\n';
			}
			break;

		case 'i':
			if (elem[1] == '\0')
			{
				data->result.append("<i>", 3);
				data->isXml = true;
			}
			break;

		case 'h':
			if (strcmp(elem, "html") == 0)
				data->result.append("<xml>", 5);
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

					data->putLang = 0;
					data->result.append("<:", 2);
					data->result.append(attr[1]);
					data->result.append(">", 1);
					data->lang.assign(attr[1], 2);
					data->isXml = true;

					if (attr[1][0] == 'e' && attr[1][1] == 'n')
						data->engFlag = true;
					else
						data->othFlag = true;
				}
				else
				{
					++data->skipLang;
				}
			}
			break;

		case 'n':
			if (strcmp(elem, "nag") == 0)
			{
				data->result.append("<nag>", 5);
				data->insideNag = true;
				data->isXml = true;
			}
			break;

		case 'u':
			if (elem[1] == '\0')
			{
				data->result.append("<u>", 3);
				data->isXml = true;
			}
			break;
	}

	if (::strcmp(elem, "xml") != 0)
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
					data->lang.clear();
				}
			}
			break;

		case 'h':
			if (strcmp(elem, "html") == 0)
			{
				if (data->putLang == 2)
				{
					data->result.append("</:>", 4);
					data->putLang = 0;
				}
				data->result.append("</xml>", 6);
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

Comment::Comment() :m_engFlag(false), m_othFlag(false) {}


Comment::Comment(mstl::string const& content, bool engFlag, bool othFlag)
	:m_content(content)
	,m_engFlag(engFlag)
	,m_othFlag(othFlag)
{
}


void
Comment::append(Comment const& comment, char delim)
{
	if (m_content.empty())
	{
		m_content = comment;
		m_engFlag = comment.m_engFlag;
		m_othFlag = comment.m_othFlag;
		m_languageSet.clear();
	}
	else
	{
		bool thisIsXml = isXml();
		bool thatIsXml = comment.isXml();

		if (thisIsXml != thatIsXml)
		{
			mstl::string content;
			content.reserve(
				m_content.size() + comment.m_content.size() + ::prefix.size() + ::suffix.size());
			content.append(::prefix);
			::append(content, m_content, thisIsXml);
			::append(content, comment.m_content, thatIsXml);
			content.append(::suffix);
			m_content.swap(content);
			normalize(delim); // updates m_engFlag, m_othFlag
		}
		else if (thisIsXml) // && thatIsXml
		{
			m_content.erase(m_content.end() - ::suffix.size(), m_content.end());
			m_content.append(comment.content(), ::prefix.size());
			normalize(delim); // updates m_engFlag, m_othFlag
			m_languageSet.clear();
		}
		else // if (!thisIsXml && !thatIsXml)
		{
			::appendDelim(m_content, delim);
			m_content.append(comment);
		}
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
		return 0;

	if (m_languageSet.empty())
		collect();

	return m_languageSet.find(lang) != m_languageSet.end();
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


void
Comment::swap(Comment& comment)
{
	m_content.swap(comment.m_content);
	mstl::swap(m_engFlag, comment.m_engFlag);
	mstl::swap(m_othFlag, comment.m_othFlag);
	m_languageSet.swap(comment.m_languageSet);
}


void
Comment::swap(mstl::string& content, bool engFlag, bool othFlag)
{
	m_content.swap(content);
	m_languageSet.clear();
	m_engFlag = engFlag;
	m_othFlag = othFlag;
}


void
Comment::clear()
{
	m_content.clear();
	m_languageSet.clear();
	m_engFlag = m_othFlag = false;
}


void
Comment::flatten(mstl::string& result, encoding::CharSet encoding) const
{
	if (m_content.empty())
		return;

	if (isXml())
	{
		Flatten flatten(result, encoding);
		result.reserve(result.size() + m_content.size() + 100);
		parse(flatten);
	}
	else
	{
		result.append(m_content);
	}
}


void
Comment::toHtml(mstl::string& result) const
{
	if (m_content.empty())
		return;

	result.reserve(result.size() + m_content.size() + 100);

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
				case '<':	++s; result += "&lt;"; break;
				case '>':	++s; result += "&gt;"; break;
				case '&':	++s; result += "&amp;"; break;
				case '\n':	++s; result += "<br/>"; break;

				default:
					{
						uint16_t code;

						s = sys::utf8::Codec::utfNextChar(s, code);

						if (code < 0x80)
							result += char(code);
						else
							result.format("&#x%04x;", code);
					}
					break;
			}
		}
	}
}


void
Comment::normalize(char delim)
{
	if (m_content.empty())
		return;

	if (!isXml())
		return;

	Normalize normalize(m_content, m_engFlag, m_othFlag, delim);
	parse(normalize);
}


void
Comment::remove(mstl::string const& lang)
{
	if (m_content.empty())
		return;

	if (isXml())
	{
		LanguageSet set;
		collectLanguages(set);
		set.erase(lang);
		strip(set);
	}
	else if (lang.empty())
	{
		m_content.clear();
	}

	m_languageSet.erase(lang);
}


void
Comment::strip(LanguageSet const& set)
{
	if (m_content.empty())
		return;

	if (set.empty())
	{
		m_content.clear();
		m_engFlag = m_othFlag = false;
	}
	else if (isXml())
	{
		Normalize normalize(m_content, m_engFlag, m_othFlag, '\0', &set);
		parse(normalize);
	}
	else if (set.find(mstl::string::empty_string) == set.end())
	{
		m_content.clear();
		m_engFlag = m_othFlag = false;
	}

	m_languageSet.clear();
}


bool
Comment::fromHtml(mstl::string const& s)
{
	XML_Parser parser = ::XML_ParserCreate("ISO-8859-1");

	if (parser == 0)
		DB_RAISE("couldn't allocate memory for parser");

	bool sucesss = false;

	HtmlData data(m_content, m_engFlag, m_othFlag);
	m_content.reserve(s.size());

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
				m_content.insert(m_content.begin(), ::prefix);
				m_content.append(::suffix);
			}
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


bool
Comment::convertCommentToXml(	mstl::string const& comment,
										Comment& result,
										encoding::CharSet encoding)
{
	M_REQUIRE(&comment != &result.content());

	char const* s		= comment.c_str();
	bool hasDiagram	= false;

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

	bool specialExpected = true;
	bool isXml = false;

	while (*s)
	{
		if (*s & 0x80)
		{
			if (encoding == encoding::Utf8)
			{
				char const* e = sys::utf8::Codec::utfNextChar(s);

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
			else if (::isprint(*s))
			{
				result.m_content += *s++;
			}
		}
		else
		{
			if (::isprint(*s))
			{
				switch (*s)
				{
					case '&': result.m_content += '\x01'; ++s; break;
					case '>': result.m_content += '\x03'; ++s; break;

					case '<':
						if (	::islower(s[1])
							&& ::islower(s[2])
							&& s[3] == '>'
							&& s[4] == ' ')
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
						result.m_content += '\x02';
						++s;
					}
					break;

					default:
						if (::isDelimChar(*s))
						{
							result.m_content += *s++;
							specialExpected = true;
						}
						else if (specialExpected)
						{
							switch (s[0])
							{
								case '$':
									if (::isdigit(*s))
									{
										char* e = const_cast<char*>(s);
										unsigned nag = ::strtoul(s, &e, 10);

										if (0 <= nag && nag < nag::Scidb_Last)
										{
											result.m_content.append("<nag>", 5);
											result.m_content.append(s, e - s);
											result.m_content.append("</nag>", 6);
											isXml = true;
										}

										s = e + 1;
									}
									break;

//								not working, e.g. "Ponomariov, R (2718)-Leko, P (2741)"
//								case 'K': case 'Q': case 'R': case 'B': case 'N': case 'P':
//									if (s[1] == '\0' || ::isDelimChar(s[1]))
//									{
//										result.m_content.append("<sym>", 5);
//										result.m_content += *s++;
//										result.m_content.append("</sym>", 6);
//										isXml = true;
//									}
//									else
//									{
//										result.m_content += *s++;
//									}
//									break;

								default:
									{
										unsigned	len = 1;
										nag::ID	nag;

										while (!::isDelimChar(s[len]))
											++len;

										if (len <= 5 && (nag = nag::fromSymbol(s, len)) != nag::Null)
										{
											result.m_content.format("<nag>%u</nag>", unsigned(nag));
											isXml = true;
										}
										else
										{
											result.m_content.append(s, len);
										}

										s += len;
									}
									break;
							}

							specialExpected = false;
						}
						else
						{
							result.m_content += *s++;
						}
						break;
				}
			}
			else if (::isspace(*s++))
			{
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
					isXml = true;
					s += 5;

					if (s[1] == 'e' && s[2] == 'n')
						result.m_engFlag = true;
					else
						result.m_othFlag = true;
				}
				else
				{
					result.m_content += '\n';
				}
			}
			else
			{
				result.m_content += '?';
			}
		}
	}

	if (isXml)
	{
		mstl::string str;
		str.swap(result.m_content);

		result.m_content.append(::prefix);
		result.m_content.append("<:>", 3);

		for (unsigned i = 0; i < str.size(); ++i)
		{
			switch (char c = str[i])
			{
				case '\x01': result.m_content += "&amp;";  break;
				case '\x02': result.m_content += "&lt;";   break;
				case '\x03': result.m_content += "&gt;";   break;

				default: result.m_content += c;
			}
		}

		while (result.m_content.back() == ' ')
			result.m_content.set_size(result.m_content.size() - 1);

		result.m_content.append("</:", 3);
		result.m_content.append(lang);
		result.m_content.append(">", 1);
		result.m_content += ::suffix;
		result.normalize('\0');
	}
	else
	{
		for (unsigned i = 0; i < result.m_content.size(); ++i)
		{
			switch (result.m_content[i])
			{
				case '\x01': result.m_content[i] = '&'; break;
				case '\x02': result.m_content[i] = '<'; break;
				case '\x03': result.m_content[i] = '>'; break;
			}
		}
	}

	return hasDiagram;
}

// vi:set ts=3 sw=3:
