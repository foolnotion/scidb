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

#include "tcl_sort.h"
#include "tcl_base.h"
#include "tcl_exception.h"
#include "tcl_database.h"
#include "tcl_file.h"
#include "tcl_game.h"

#include "db_comment.h"
#include "db_database_codec.h"
#include "db_eco_table.h"
#include "db_date.h"

#include "si3_codec.h"
#include "sci_codec.h"

#include "nsUniversalDetector.h"

#include "sys_utf8_codec.h"
#include "sys_utf8.h"
#include "sys_file.h"
#include "sys_info.h"
#include "sys_vfs.h"

#include "u_crc.h"
#include "u_html.h"
#include "u_zstream.h"
#include "u_emoticons.h"

#include "m_backtrace.h"
#include "m_string.h"
#include "m_bit_functions.h"
#include "m_stack.h"
#include "m_assert.h"

#include <tcl.h>
#include <tk.h>
#include <expat.h>
#include <string.h>
#include <ctype.h>

#ifdef CODEBLOCKS
# define SCIDB_VERSION	"1.0 BETA"
# define SCIDB_REVISION	"978"
#endif

using namespace tcl;
using namespace util;

static char const* CmdAttributes				= "::scidb::misc::attributes";
static char const* CmdContainsUnicodeChar	= "::scidb::misc::containsUnicodeChar";
static char const* CmdCrc32					= "::scidb::misc::crc32";
static char const* CmdDebug					= "::scidb::misc::debug?";
static char const* CmdDirEmpty				= "::scidb::misc::dirEmpty?";
static char const* CmdEmoticons				= "::scidb::misc::emoticons";
static char const* CmdEncoding				= "::scidb::misc::encoding";
static char const* CmdExtraTags				= "::scidb::misc::extraTags";
static char const* CmdFitsRegion				= "::scidb::misc::fitsRegion?";
static char const* CmdGeometryRequest		= "::scidb::misc::geometryRequest";
static char const* CmdHardLinked				= "::scidb::misc::hardLinked?";
static char const* CmdHtml						= "::scidb::misc::html";
static char const* CmdIsAscii					= "::scidb::misc::isAscii?";
static char const* CmdJulianDay				= "::scidb::misc::julianDay";
static char const* CmdLookup					= "::scidb::misc::lookup";
static char const* CmdMapCodeToNag			= "::scidb::misc::mapCodeToNag";
static char const* CmdMapExtension			= "::scidb::misc::mapExtension";
static char const* CmdMapWindow				= "::scidb::misc::mapWindow";
static char const* CmdMaxYear					= "::scidb::misc::maxYear";
static char const* CmdMemAvail				= "::scidb::misc::memAvail";
static char const* CmdMemFree					= "::scidb::misc::memFree";
static char const* CmdMemTotal				= "::scidb::misc::memTotal";
static char const* CmdMinYear					= "::scidb::misc::minYear";
static char const* CmdNumberOfProcessors	= "::scidb::misc::numberOfProcessors";
static char const* CmdPredPow2				= "::scidb::misc::predPow2";
static char const* CmdRevision				= "::scidb::misc::revision";
static char const* CmdSetModTime				= "::scidb::misc::setModTime";
static char const* CmdSize						= "::scidb::misc::size";
static char const* CmdSort						= "::scidb::misc::sort";
static char const* CmdSuccPow2				= "::scidb::misc::succPow2";
static char const* CmdSuffixes				= "::scidb::misc::suffixes";
static char const* CmdToAscii					= "::scidb::misc::toAscii";
static char const* CmdUrl						= "::scidb::misc::url";
static char const* CmdVersion					= "::scidb::misc::version";
static char const* CmdXml						= "::scidb::misc::xml";
static char const* CmdZipContent				= "::scidb::misc::zipContent";

static unsigned cacheCount = 0;


struct XmlData
{
	XmlData(Tcl_Obj* obj) :resultList(obj), size(0) {}

	Tcl_Obj*			resultList;
	mstl::string	attribute;
	mstl::string	prevAttr;
	unsigned			size;
};


static void
startXmlElement(void* clData, XML_Char const* elem, char const** attr)
{
	XmlData* data = static_cast<XmlData*>(clData);

	if (strcmp(elem, "xml") != 0)
	{
		if (!data->attribute.empty())
			data->attribute.append('-');
		data->attribute.append(elem);
	}
}


static void
endXmlElement(void* clData, XML_Char const* elem)
{
	XmlData* data = static_cast<XmlData*>(clData);

	if (strcmp(elem, "xml") != 0)
	{
		M_ASSERT(!data->attribute.empty());

		mstl::string::size_type n = data->attribute.rfind('-');

		if (n == mstl::string::npos)
			n = 0;

		data->attribute.erase(n, mstl::string::npos);
	}
}


static void
xmlContent(void* clData, XML_Char const* s, int len)
{
	XmlData* data = static_cast<XmlData*>(clData);

	if (data->prevAttr == data->attribute && data->size > 0)
	{
		Tcl_Obj* str;
		Tcl_ListObjIndex(nullptr, data->resultList, data->size - 1, &str);
		Tcl_AppendToObj(str, s, len);
	}
	else
	{
		Tcl_ListObjAppendElement(	nullptr,
											data->resultList,
											Tcl_NewStringObj(data->attribute, data->attribute.size()));
		Tcl_ListObjAppendElement(	nullptr,
											data->resultList,
											Tcl_NewStringObj(s, len));
		data->prevAttr = data->attribute;
		data->size += 2;
	}
}


inline bool
doNotEscape(char c)
{
	if (isalnum(c))
		return true;

	static char const* Marks = "-_.!~*'():%/?=";
	return bool(strchr(Marks, c));
}


inline char
valToXDigit(unsigned char v)
{
	return char(v + (v < 10 ? '0' : 'A' - 10));
}


inline sys::utf8::uchar
xdigitToVal(unsigned char c)
{
	return isdigit(c) ? c - '0' : toupper(c) - 'A' + 10;
}


static void
append(mstl::string& result, char const* s, unsigned len)
{
	char const* e = s + len;

	result.reserve(result.size() + len);

	while (s < e)
	{
		switch (*s)
		{
			case '&':
				switch (s[1])
				{
					case 'a':
						if (len >= 5 && strncmp("&amp;", s, 5) == 0)
						{
							result += '&';
							s += 5;
							continue;
						}
						if (len >= 6 && strncmp("&apos;", s, 6) == 0)
						{
							result += '\'';
							s += 6;
							continue;
						}
						// fallthru
					case 'g':
						if (len >= 4 && strncmp("&gt;", s, 4) == 0)
						{
							result += '>';
							s += 4;
							continue;
						}
						// fallthru
					case 'l':
						if (len >= 4 && strncmp("&lt;", s, 4) == 0)
						{
							result += '<';
							s += 4;
							continue;
						}
						// fallthru
					case 'q':
						if (len >= 6 && strncmp("&quot;", s, 6) == 0)
						{
							result += '"';
							s += 6;
							continue;
						}
						// fallthru
					default:
						result += *s++;
						break;
				}
				break;

			case '{':
				result += "<brace/>";
				++s;
				break;

			default:
				result += *s++;
				break;
		}
	}
}


namespace {

struct CharsetDetector : public nsUniversalDetector
{
	void Report(char const* charset) { encoding.assign(charset); }
	mstl::string encoding;
};


class ToList : public ::db::Comment::Callback
{
public:

	ToList(mstl::string const& space, bool detectEmoticons, bool expandEmoticons);
	~ToList() throw();

	Tcl_Obj* result();

	void start() override;
	void finish() override;

	void startLanguage(mstl::string const& lang) override;
	void endLanguage(mstl::string const& lang) override;

	void startAttribute(Attribute attr) override;
	void endAttribute(Attribute attr) override;

	void content(mstl::string const& s) override;
	void nag(mstl::string const& s) override;
	void symbol(char s) override;
	void emoticon(mstl::string const& s) override;

	void invalidXmlContent(mstl::string const& content) override;

private:

	typedef mstl::stack<Tcl_Obj*> Stack;

	void putContent();
	void putTag(char const* tag);
	void appendTag(mstl::string const& tag, mstl::string const& content);
	void resolveSpaces();

	Tcl_Obj*			m_result;
	mstl::string	m_tag;
	mstl::string	m_content;
	Stack				m_stack;
	mstl::string	m_space;
	bool				m_detectEmoticons;
	bool				m_expandEmoticons;
	Tcl_Obj*			m_first;
	Tcl_Obj*			m_last;
};


Tcl_Obj* ToList::result() { return m_result; }


ToList::ToList(mstl::string const& space, bool detectEmoticons, bool expandEmoticons)
	:m_result(Tcl_NewListObj(0, 0))
	,m_space(space)
	,m_detectEmoticons(detectEmoticons)
	,m_expandEmoticons(expandEmoticons)
	,m_first(0)
	,m_last(0)
{
	Tcl_IncrRefCount(m_result);
	m_stack.push(Tcl_NewListObj(0, 0));
	Tcl_IncrRefCount(m_stack.top());
}


ToList::~ToList() throw()
{
	Tcl_DecrRefCount(m_result);

	if (m_stack.size() == 1)
		Tcl_DecrRefCount(m_stack.top());
}


void
ToList::resolveSpaces()
{
	if (m_first)
	{
		int objc;
		Tcl_Obj** objv;

		Tcl_ListObjGetElements(0, m_first, &objc, &objv);
		M_ASSERT(objc == 2);

		mstl::string str(Tcl_GetString(objv[1]));
		mstl::string res;

		char const* s = str.begin();
		char const* e = str.end();

		for ( ; s < e && *s == ' '; ++s)
			res.append(m_space);

		if (!res.empty())
		{
			res.append(s, e);

			Tcl_Obj* objs[1] = { Tcl_NewStringObj(res, res.size()) };
			Tcl_ListObjReplace(0, m_first, 1, 1, 1, objs);
		}

		m_first = 0;
	}

	if (m_last)
	{
		int objc;
		Tcl_Obj** objv;

		Tcl_ListObjGetElements(0, m_last, &objc, &objv);
		M_ASSERT(objc == 2);

		mstl::string str(Tcl_GetString(objv[1]));
		mstl::string res;

		char const* s = str.begin();
		char const* e = str.end();
		char const* t = str.end();

		while (t > s && t[-1] == ' ')
			--t;

		if (t < e && (t > s || m_last != m_first))
		{
			res.append(s, t);
			while (t++ < e)
			res.append(m_space);

			Tcl_Obj* objs[1] = { Tcl_NewStringObj(res, res.size()) };
			Tcl_ListObjReplace(0, m_last, 1, 1, 1, objs);
		}

		m_last = 0;
	}
}


void
ToList::appendTag(mstl::string const& tag, mstl::string const& content)
{
	M_ASSERT(!m_stack.empty());

	Tcl_Obj* objv[2];
	objv[0] = Tcl_NewStringObj(tag, tag.size());
	objv[1] = Tcl_NewStringObj(content, content.size());

	Tcl_Obj* list = Tcl_NewListObj(2, objv);

	if (!m_space.empty())
	{
		if (m_first == 0)
			m_first = list;
		m_last = list;
	}

	Tcl_ListObjAppendElement(0, m_stack.top(), list);
}


void
ToList::putTag(char const* tag)
{
	M_ASSERT(!m_stack.empty());

	Tcl_Obj* objv[1] = { Tcl_NewStringObj(tag, -1) };
	Tcl_ListObjAppendElement(0, m_stack.top(), Tcl_NewListObj(1, objv));
}


void
ToList::putContent()
{
	if (!m_tag.empty())
	{
		appendTag(m_tag, m_content);
		m_tag.clear();
		m_content.clear();
	}
	else if (!m_content.empty())
	{
		if (m_detectEmoticons)
		{
			char const* s = m_content.begin();
			char const* e = m_content.end();

			while (s < e)
			{
				util::emoticons::Emotion emotion;

				char const* q = s;
				char const* p = util::emoticons::parseEmotion(q, e, emotion);

				mstl::string str;
				str.hook(const_cast<char*>(s), p - s);

				if (!str.empty())
					appendTag("str", str);

				if (p < e)
					appendTag("emo", util::emoticons::toAscii(emotion));

				s = q;
			}
		}
		else
		{
			appendTag("str", m_content);
		}

		m_content.clear();
	}
}


void
ToList::startLanguage(mstl::string const& lang)
{
	putContent();

	Tcl_Obj* objv[2];

	objv[0] = Tcl_NewStringObj(lang, lang.size());
	objv[1] = Tcl_NewListObj(0, 0);

	Tcl_ListObjAppendElement(0, m_result, Tcl_NewListObj(2, objv));
	m_stack.push(objv[1]);
}


void
ToList::endLanguage(mstl::string const&)
{
	M_ASSERT(!m_stack.empty());

	putContent();
	resolveSpaces();
	m_stack.pop();
}


void
ToList::startAttribute(Attribute attr)
{
	char const* tag = 0;

	putContent();

	switch (attr)
	{
		case Bold:			tag = "+bold"; break;
		case Italic:		tag = "+italic"; break;
		case Underline:	tag = "+underline"; break;
	}

	putTag(tag);
}


void
ToList::endAttribute(Attribute attr)
{
	char const* tag = 0;

	putContent();

	switch (attr)
	{
		case Bold:			tag = "-bold"; break;
		case Italic:		tag = "-italic"; break;
		case Underline:	tag = "-underline"; break;
	}

	putTag(tag);
}


void
ToList::content(mstl::string const& s)
{
	if (!m_tag.empty())
		putContent();
	::append(m_content, s, s.size());
}


void
ToList::nag(mstl::string const& s)
{
	if (m_tag != "nag")
		putContent();
	appendTag("nag", s);
}


void
ToList::emoticon(mstl::string const& s)
{
	if (m_expandEmoticons)
	{
		content(s);
	}
	else
	{
		if (m_tag != "emo")
			putContent();
		appendTag("emo", s);
	}
}


void
ToList::symbol(char s)
{
	if (m_tag != "sym")
		putContent();
	appendTag("sym", mstl::string(1, s));
}


void
ToList::invalidXmlContent(mstl::string const& content)
{
	m_content.clear();
	this->content(content);
}


void
ToList::start()
{
	// no action
}


void
ToList::finish()
{
	M_ASSERT(!m_stack.empty());

	int length = 0;

	putContent();
	Tcl_ListObjLength(0, m_stack.top(), &length);

	if (length)
	{
		Tcl_Obj* objv[2] = { Tcl_NewStringObj(0, 0), m_stack.top() };
		Tcl_Obj* args[1] = { Tcl_NewListObj(2, objv) };
		Tcl_ListObjReplace(0, m_result, 0, 0, 1, args);
	}
}


class Parser
{
public:

	Parser(Tcl_Obj* obj, mstl::string const& space);

	mstl::string parse();

private:

	enum { Bold = 0, Italic = 1, Underline = 2 };

	typedef mstl::stack<unsigned> ModeStack;

	void processModes();

	Tcl_Obj*			m_obj;
	mstl::string	m_xml;
	unsigned			m_attr[3];
	bool				m_mode[3];
	ModeStack		m_stack;
	mstl::string	m_space;
};


Parser::Parser(Tcl_Obj* obj, mstl::string const& space)
	:m_obj(obj)
	,m_space(space)
{
	M_ASSERT(m_obj);

	m_attr[0] = m_attr[1] = m_attr[2] = 0;
	m_mode[0] = m_mode[1] = m_mode[2] = false;
	m_xml.reserve(512);
}


void
Parser::processModes()
{
	static char const Token[3] = { 'b', 'i', 'u' };

	for (unsigned i = 0; i < 3; ++i)
	{
		if (!m_attr[i] && m_mode[i])
		{
			while (!m_stack.empty() && m_stack.top() != i)
			{
				m_xml += '<';
				m_xml += '/';
				m_xml += Token[m_stack.top()];
				m_xml += '>';
				m_mode[m_stack.top()] = false;
				m_stack.pop();
			}

			m_xml += '<';
			m_xml += '/';
			m_xml += Token[i];
			m_xml += '>';
			m_mode[i] = false;

			if (!m_stack.empty())
				m_stack.pop();
		}
	}

	for (unsigned i = 0; i < 3; ++i)
	{
		if (m_attr[i] && !m_mode[i])
		{
			m_xml += '<';
			m_xml += Token[i];
			m_xml += '>';
			m_mode[i] = true;
			m_stack.push(i);
		}
	}
}


mstl::string
Parser::parse()
{
	int objc;
	Tcl_Obj** objv;

	Tcl_ListObjGetElements(0, m_obj, &objc, &objv);

	m_xml.append("<xml>", 5);

	for (int i = 0; i < objc; ++i)
	{
		int argc;
		Tcl_Obj** argv;

		Tcl_ListObjGetElements(0, objv[i], &argc, &argv);

		if (argc != 2)
			M_RAISE("invalid xml list");

		char const* lang = Tcl_GetString(argv[0]);

		m_xml.format("<:%s>", lang);
		Tcl_ListObjGetElements(0, argv[1], &argc, &argv);

		for (int k = 0; k < argc; ++k)
		{
			int objn;
			Tcl_Obj** objs;

			Tcl_ListObjGetElements(0, argv[k], &objn, &objs);

			char const* token = Tcl_GetStringFromObj(objs[0], nullptr);

			switch (*token)
			{
				case 's':	// "str" | "sym"
					if (objn == 2) // tokens like "{str }" may happen
					{
						switch (token[1])
						{
							case 't':	// "str"
								{
									int len;
									char const* str = Tcl_GetStringFromObj(objs[1], &len);
									mstl::string::size_type appendSpaces = 0;

									if (k == 0)
									{
										for ( ; len > 0 && *str == ' '; ++str)
											--len;

										if (!m_space.empty())
										{
											while (	len >= int(m_space.size())
													&& ::strncmp(str, m_space, m_space.size()) == 0)
											{
												str += m_space.size();
												len -= m_space.size();
												m_xml.append(' ');
											}
										}
									}

									if (k == argc - 1)
									{
										char const* s = str + len;

										for ( ; len > 0 && s[-1] == ' '; --s)
											--len;

										if (!m_space.empty() && (s > str || argc > 1))
										{
											while (	len >= int(m_space.size())
													&& ::strncmp(s - m_space.size(), m_space, m_space.size()) == 0)
											{
												s -= m_space.size();
												len -= m_space.size();
												appendSpaces++;
											}
										}
									}

									if (len > 0)
									{
										processModes();

										for (int j = 0; j < len; ++j)
										{
											switch (str[j])
											{
												case '<':	m_xml.append("&lt;",   4); break;
												case '>':	m_xml.append("&gt;",   4); break;
												case '&':	m_xml.append("&amp;",  5); break;
												case '\'':	m_xml.append("&apos;", 6); break;
												case '"':	m_xml.append("&quot;", 6); break;
												default:		m_xml += str[j]; break;
											}
										}
									}

									m_xml.append(appendSpaces, ' ');
								}
								break;

							case 'y':	// "sym"
								processModes();
								m_xml.append("<sym>", 5);
								m_xml += *Tcl_GetString(objs[1]);
								m_xml.append("</sym>", 6);
								break;

							default:
								M_RAISE("invalid xml list");
						}
					}
					break;

				case 'n':	// nag
					if (objn != 2)
						M_RAISE("invalid xml list");

					processModes();
					m_xml.append("<nag>", 5);
					m_xml += Tcl_GetString(objs[1]);
					m_xml.append("</nag>", 6);
					break;

				case 'e':	// emoticon
					processModes();
					m_xml.append("<emo>", 5);
					m_xml += Tcl_GetString(objs[1]);
					m_xml.append("</emo>", 6);
					break;

				case '+':
					switch (token[1])
					{
						case 'b': ++m_attr[Bold]; break;
						case 'i': ++m_attr[Italic]; break;
						case 'u': ++m_attr[Underline]; break;

						default: M_RAISE("invalid xml list");
					}
					break;

				case '-':
					switch (token[1])
					{
						case 'b': --m_attr[Bold]; break;
						case 'i': --m_attr[Italic]; break;
						case 'u': --m_attr[Underline]; break;

						default: M_RAISE("invalid xml list");
					}
					break;

				default:
					M_RAISE("invalid xml list");
			}
		}

		processModes();
		m_xml.format("</:%s>", lang);
	}

	m_xml.append("</xml>", 6);

	// cannot use ::db::i18n::None due to a g++ bug
	::db::Comment comment(m_xml, 0);
	comment.normalize(::db::Comment::PreserveEmoticons);

	return comment.content();
}

} // namespace


static int
cmdFitsRegion(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(sys::utf8::Codec::fitsRegion(stringFromObj(objc, objv, 2),
														unsignedFromObj(objc, objv, 1)));
	return TCL_OK;
}


static int
cmdIsAscii(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(sys::utf8::Codec::is7BitAscii(stringFromObj(objc, objv, 1)));
	return TCL_OK;
}


static int
cmdToAscii(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	mstl::string buffer;
	setResult(sys::utf8::Codec::convertToNonDiacritics(unsignedFromObj(objc, objv, 1),
																		stringFromObj(objc, objv, 2),
																		buffer));
	return TCL_OK;
}


static int
cmdXmlToList(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	// cannot use ::db::i18n::None due to a g++ bug
	::db::Comment comment(stringFromObj(objc, objv, 1), 0);

	bool detectEmoticons = false;
	bool expandEmoticons = false;

	mstl::string space;

	int offs = 0;

	while (objc - offs > 3)
	{
		char const* option = Tcl_GetString(objv[2 + offs]);

		if (::strcmp(option, "-detectemoticons") == 0)
			detectEmoticons = boolFromObj(objc, objv, 3 + offs);
		else if (::strcmp(option, "-expandemoticons") == 0)
			expandEmoticons = boolFromObj(objc, objv, 3 + offs);
		else if (::strcmp(option, "-replacespaces") == 0)
			space.assign(stringFromObj(objc, objv, 3 + offs));
		else
			return error(CmdXml, "toList", 0, "unknown option '%s'", Tcl_GetString(objv[2 + offs]));

		offs += 2;
	}

	ToList callback(space, detectEmoticons, expandEmoticons);
	comment.parse(callback);
	setResult(callback.result());

	return TCL_OK;
}


static int
cmdXmlFromList(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	mstl::string space;

	int offs = 0;

	while (objc - offs > 3)
	{
		char const* option = Tcl_GetString(objv[2 + offs]);

		if (::strcmp(option, "-replacewithspace") == 0)
			space.assign(stringFromObj(objc, objv, 3 + offs));
		else
			return error(CmdXml, "fromList", 0, "unknown option '%s'", Tcl_GetString(objv[2 + offs]));

		offs += 2;
	}

	Parser parser(objectFromObj(objc, objv, 1), space);
	setResult(parser.parse());
	return TCL_OK;
}


static int
cmdXmlTokenize(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const* str = stringFromObj(objc, objv, 1);

	XML_Parser parser = ::XML_ParserCreate("UTF-8");

	if (parser == 0)
		return error(CmdXml, "tokenize", 0, "couldn't allocate memory for parser");
	
	XmlData data(Tcl_NewListObj(0, nullptr));
	XML_SetUserData(parser, &data);
	XML_SetElementHandler(parser, ::startXmlElement, ::endXmlElement);
	XML_SetCharacterDataHandler(parser, ::xmlContent);

	try
	{
		if (!XML_Parse(parser, str, strlen(str), true))
			throw 0;
	}
	catch (...)
	{
		XML_ParserFree(parser);
		return error(CmdXml, "tokenize", 0, "syntax error in XML string");
	}

	XML_ParserFree(parser);
	setResult(data.resultList);

	return TCL_OK;
}


static int
cmdXml(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const* command = stringFromObj(objc, objv, 1);

	if (strcmp(command, "toList") == 0)
		return cmdXmlToList(clientData, ti, objc - 1, objv + 1);

	if (strcmp(command, "fromList") == 0)
		return cmdXmlFromList(clientData, ti, objc - 1, objv + 1);

	if (strcmp(command, "tokenize") == 0)
		return cmdXmlTokenize(clientData, ti, objc - 1, objv + 1);

	return error(CmdXml, 0, 0, "unknown command '%s'", command);
}


static int
cmdCrc32(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const* s = stringFromObj(objc, objv, 1);
	setResult(crc::compute(0, s, ::strlen(s)));
	return TCL_OK;
}


static int
cmdVersion(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(SCIDB_VERSION);
	return TCL_OK;
}


static int
cmdRevision(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(SCIDB_REVISION);
	return TCL_OK;
}


static int
cmdDebug(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(int(mstl::backtrace::is_debug_mode()));
	return TCL_OK;
}


static int
cmdDirEmpty(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(::sys::file::dirIsEmpty(stringFromObj(objc, objv, 1)));
	return TCL_OK;
}


static int
cmdLookup(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const* which = stringFromObj(objc, objv, 1);

	if (::strcmp(which, "player") == 0)
	{
		::db::Player const* player = ::db::Player::findFidePlayer(unsignedFromObj(objc, objv, 2));
		bool unicodeFlag = false;

		if (objc > 3)
		{
			if (strcmp(stringFromObj(objc, objv, 3), "-unicode") != 0)
				return error(CmdLookup, 0, 0, "unknown option '%s'", stringFromObj(objc, objv, 3));

			unicodeFlag = boolFromObj(objc, objv, 4);
		}

		if (!player)
			setResult("");
		else if (unicodeFlag)
			setResult(player->name());
		else
			setResult(player->asciiName());
	}
	else if (::strcmp(which, "countryCode") == 0)
	{
		setResult(::db::country::toString(::db::country::fromString(stringFromObj(objc, objv, 2))));
	}
	else if (::strcmp(which, "opening") == 0)
	{
		::db::Eco eco(stringFromObj(objc, objv, 2));
		::db::variant::Type variant = tcl::game::variantFromObj(objectFromObj(objc, objv, 3));
		::db::EcoTable::Opening const& opening = ::db::EcoTable::specimen(variant).getOpening(eco);
		Tcl_Obj* objs[::db::EcoTable::Num_Name_Parts];
		unsigned objc = 0;

		objs[objc++] = Tcl_NewStringObj(opening.part[0], opening.part[0].size());
		objs[objc++] = Tcl_NewStringObj(opening.part[1], opening.part[1].size());

		for ( ; objc < ::db::EcoTable::Num_Name_Parts; ++objc)
			objs[objc] = Tcl_NewStringObj(opening.part[objc], opening.part[objc].size());
		setResult(objc, objs);
	}

	return TCL_OK;
}


static int
cmdSize(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	int		numGames;
	uint32_t	creationTime;

	::db::type::ID			type;
	::db::variant::Type	variant;

	::db::DatabaseCodec::getAttributes(	stringFromObj(objc, objv, 1),
													numGames,
													type,
													variant,
													creationTime);

	setResult(numGames);
	return TCL_OK;
}


static int
cmdAttributes(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	mstl::string	description;
	int				numGames;
	uint32_t			creationTime;

	::db::type::ID			type;
	::db::variant::Type	variant;

	::db::DatabaseCodec::getAttributes(	stringFromObj(objc, objv, 1),
													numGames,
													type,
													variant,
													creationTime,
													&description);

	Tcl_Obj* objs[5];

	mstl::string created;

	if (creationTime)
		created = ::db::Time(creationTime).asString();

	objs[0] = Tcl_NewIntObj(numGames);
	objs[1] = Tcl_NewStringObj(tcl::db::lookupType(type), -1);
	objs[2] = game::objFromVariant(variant);
	objs[3] = Tcl_NewStringObj(created, created.size());
	objs[4] = Tcl_NewStringObj(description, description.size());

	setResult(U_NUMBER_OF(objs), objs);
	return TCL_OK;
}


static int
cmdZipContent(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	ZStream::Strings result = ZStream::zipContent(stringFromObj(objc, objv, 1));

	Tcl_Obj* objs[result.size()];

	for (unsigned i = 0; i < result.size(); ++i)
	{
		mstl::string const& file = result[i];
		objs[i] = Tcl_NewStringObj(file, file.size());
	}

	setResult(result.size(), objs);
	return TCL_OK;
}


static int
cmdSuffixes(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	::db::DatabaseCodec::StringList result;
	::db::DatabaseCodec::getSuffixes(stringFromObj(objc, objv, 1), result);

	Tcl_Obj* objs[result.size()];

	for (unsigned i = 0; i < result.size(); ++i)
	{
		mstl::string ext(result[i]);
		if (ext == "gz")
			ext.assign("pgn.gz");
		objs[i] = Tcl_NewStringObj(ext, -1);
	}

	setResult(result.size(), objs);
	return TCL_OK;
}


static int
cmdMapExtension(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* Extensions[] = { "sci", "si3", "si4", "cbh", "cbf", "CBF" };

	char const* extension = stringFromObj(objc, objv, 1);

	if (*extension == '.')
		++extension;

	for (unsigned i = 0; i < U_NUMBER_OF(Extensions); ++i)
	{
		::db::DatabaseCodec::StringList result;
		::db::DatabaseCodec::getSuffixes(Extensions[i], result);

		for (unsigned k = 0; k < result.size(); ++k)
		{
			if (result[k] == extension)
			{
				setResult(Extensions[i]);
				return TCL_OK;
			}
		}
	}

	setResult(extension);
	return TCL_OK;
}


static int
cmdExtraTags(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	bool (*isExtraTagFunc)(::db::tag::ID);

	if (strcmp(stringFromObj(objc, objv, 1), "si3") == 0)
		isExtraTagFunc = ::db::si3::Codec::isExtraTag;
	else
		isExtraTagFunc = ::db::sci::Codec::isExtraTag;

	Tcl_Obj* objs[::db::tag::BughouseTag];
	unsigned count = 0;

	for (unsigned i = 0; i < ::db::tag::BughouseTag; ++i)
	{
		if (isExtraTagFunc(::db::tag::ID(i)))
			objs[count++] = Tcl_NewStringObj(::db::tag::toName(::db::tag::ID(i)), -1);
	}

	// XXX we have to add Bughouse tags if variant is Bughouse

	setResult(count, objs);
	return TCL_OK;
}


static int
cmdEncoding(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const* text = stringFromObj(objc, objv, 1);

	CharsetDetector detector;
	detector.HandleData(text, strlen(text));
	detector.DataEnd();
	setResult(detector.encoding);

	return TCL_OK;
}


static int
cmdHardLinked(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(::sys::file::isHardLinked(stringFromObj(objc, objv, 1), stringFromObj(objc, objv, 2)));
	return TCL_OK;
}


static int
cmdHtmlHyphenate(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
	{
		Tcl_WrongNumArgs(ti, objc, objv, "<patternFile> <dictFiles> <document>");
		return TCL_ERROR;
	}

	int length;
	char const* document = Tcl_GetStringFromObj(objv[3], &length);

	html::Hyphenate hyphenate(
		stringFromObj(objc, objv, 1),
		stringFromObj(objc, objv, 2),
		::cacheCount ? html::Hyphenate::KeepInCache : html::Hyphenate::DontKeepInCache);

	hyphenate.parse(document, length);
	setResult(hyphenate.result());

	return TCL_OK;
}


static int
cmdHtmlLigatures(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 2)
	{
		Tcl_WrongNumArgs(ti, objc, objv, "<document>");
		return TCL_ERROR;
	}

	int length;
	char const* document = Tcl_GetStringFromObj(objv[1], &length);

	html::BuildLigatures ligatures;
	ligatures.parse(document, length);
	setResult(ligatures.result());

	return TCL_OK;
}


static int
cmdHtmlSearch(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc < 3)
	{
		Tcl_WrongNumArgs(	ti, objc, objv,
								"?-nocase? ?-entireword? ?-titleonly? "
								"?-max N? <needle> <haystack>");
		return TCL_ERROR;
	}

	bool noCase			= false;
	bool entireWord	= false;
	bool titleOnly		= false;

	unsigned maxMatches = unsigned(-1);

	for (int i = 1; i < objc - 2; ++i)
	{
		char const* option = Tcl_GetString(objv[i]);

		if (strcasecmp(option, "-nocase") == 0)
		{
			noCase = true;
		}
		else if (strcasecmp(option, "-entireword") == 0)
		{
			entireWord = true;
		}
		else if (strcasecmp(option, "-titleonly") == 0)
		{
			titleOnly = true;
		}
		else if (strcasecmp(option, "-max") == 0)
		{
			option = Tcl_GetString(objv[++i]);
			maxMatches = ::strtoul(option, 0, 10);

			if (i > objc - 2)
				return error("html search", 0, 0, "missing haystack argument");

			if (maxMatches == 0)
				return error("html search", 0, 0, "invalid -max argument '%s'", option);
		}
		else
		{
			return error("html search", 0, 0, "unknown option '%s'", option);
		}
	}

	html::Search search(noCase, entireWord, titleOnly, maxMatches);

	int lengthHaystack;
	int lengthNeedle;

	char const*	haystack	= Tcl_GetStringFromObj(objv[objc - 1], &lengthHaystack);
	char const*	needle	= Tcl_GetStringFromObj(objv[objc - 2], &lengthNeedle);
	Tcl_Obj*		result	= Tcl_NewListObj(0, 0);

	bool rc = search.parse(haystack, lengthHaystack, needle, lengthNeedle);

	for (unsigned i = 0; i < search.countMatches(); ++i)
		Tcl_ListObjAppendElement(ti, result, Tcl_NewIntObj(search.matchPosition(i)));

	Tcl_Obj* objs[4] =
	{
		Tcl_NewBooleanObj(rc),
		Tcl_NewBooleanObj(search.tooManyMatches()),
		Tcl_NewStringObj(search.title(), search.title().size()),
		result,
	};
	setResult(U_NUMBER_OF(objs), objs);

	return TCL_OK;
}


static int
cmdHtmlCache(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	bool flag = boolFromObj(objc, objv, 1);

	if (flag)
		++::cacheCount;
	else if (--::cacheCount == 0)
		html::Hyphenate::clearCache();

	return TCL_OK;
}


static int
cmdHtml(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const* command = stringFromObj(objc, objv, 1);

	if (strcmp(command, "search") == 0)
		return cmdHtmlSearch(clientData, ti, objc - 1, objv + 1);

	if (strcmp(command, "hyphenate") == 0)
		return cmdHtmlHyphenate(clientData, ti, objc - 1, objv + 1);

	if (strcmp(command, "ligatures") == 0)
		return cmdHtmlLigatures(clientData, ti, objc - 1, objv + 1);

	if (strcmp(command, "cache") == 0)
		return cmdHtmlCache(clientData, ti, objc - 1, objv + 1);

	return error(CmdHtml, 0, 0, "unknown command '%s'", command);
}


static int
cmdUrlEscape(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	typedef sys::utf8::uchar uchar;
	typedef sys::utf8::uchar byte;

	char const* p = stringFromObj(objc, objv, 1);
	char const* e = p + ::strlen(p);

	mstl::string url;

	while (p < e)
	{
		uchar code;
		char const* q = sys::utf8::nextChar(p, code);

		if (code < 128 && doNotEscape(code))
		{
			url += char(code);
			p = q;
		}
		else
		{
			for ( ; p < q; ++p)
			{
				url += '%';
				url += valToXDigit(byte(*p & 0xf0) >> 4);
				url += valToXDigit(byte(*p) & 0x0f);
			}
		}
	}

	setResult(url);
	return TCL_OK;
}


static int
cmdUrlUnescape(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const* p = stringFromObj(objc, objv, 1);
	char const* e = p + ::strlen(p);

	mstl::string url;

	while (p < e)
	{
		if (*p != '%')
		{
			url += *p++;
		}
		else if (isxdigit(p[1]) && isxdigit(p[2]))
		{
			url += char((xdigitToVal(p[1]) << 4) + xdigitToVal(p[2]));
			p += 3;
		}
		else
		{
			// Ooops, this shouldn't happen.
			url += *p++;
		}
	}

	setResult(url);
	return TCL_OK;
}


static int
cmdUrl(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const* command = stringFromObj(objc, objv, 1);

	if (strcmp(command, "escape") == 0)
		return cmdUrlEscape(clientData, ti, objc - 1, objv + 1);

	if (strcmp(command, "unescape") == 0)
		return cmdUrlUnescape(clientData, ti, objc - 1, objv + 1);

	return error(CmdHtml, 0, 0, "unknown command '%s'", command);
}


static int
cmdSetModTime(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const* filename = stringFromObj(objc, objv, 1);
	long time = longFromObj(objc, objv, 2);

	sys::file::setModificationTime(filename, time);
	return TCL_OK;
}


static int
cmdGeometryRequest(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Tk_Window tkwin = Tk_NameToWindow(ti, stringFromObj(objc, objv, 1), Tk_MainWindow(ti));

	if (!tkwin)
		return error(CmdGeometryRequest, 0, 0, "unknown window '%s'", stringFromObj(objc, objv, 1));

	Tk_GeometryRequest(tkwin, unsignedFromObj(objc, objv, 2), unsignedFromObj(objc, objv, 3));
	return TCL_OK;
}



static int
cmdMapWindow(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Tk_Window tkwin = Tk_NameToWindow(ti, stringFromObj(objc, objv, 1), Tk_MainWindow(ti));

	if (!tkwin)
		return error(CmdMapWindow, 0, 0, "unknown window '%s'", stringFromObj(objc, objv, 1));

	Tk_MapWindow(tkwin);
	return TCL_OK;
}


static int
cmdPredPow2(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned x = unsignedFromObj(objc, objv, 1);

	if (x >= 2 && mstl::is_not_pow_2(x))
		x = 1u << mstl::bf::msb_index(x);

	setResult(x);
	return TCL_OK;
}


static int
cmdSuccPow2(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned x = unsignedFromObj(objc, objv, 1);

	if (x == 0)
		x = 2;
	else if (mstl::is_not_pow_2(x))
		x = 1u << (mstl::bf::msb_index(x) + 1);

	setResult(x);
	return TCL_OK;
}


static int
cmdNumberOfProcessors(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(::sys::info::numberOfProcessors());
	return TCL_OK;
}


static int
cmdMinYear(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(::db::Date::MinYear);
	return TCL_OK;
}


static int
cmdMaxYear(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(::db::Date::MaxYear);
	return TCL_OK;
}


static int
cmdMapCodeToNag(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(int(::db::nag::fromSymbol(stringFromObj(objc, objv, 1))));
	return TCL_OK;
}


static int
cmdContainsUnicodeChar(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const* s = stringFromObj(objc, objv, 1);

	for ( ; *s; ++s)
	{
		if (static_cast<unsigned char>(*s) >= 0x80)
		{
			setResult(true);
			return TCL_OK;
		}
	}

	setResult(false);
	return TCL_OK;
}


static int
cmdMemAvail(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(Tcl_NewWideIntObj(::sys::info::memAvail()));
	return TCL_OK;
}


static int
cmdMemFree(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(Tcl_NewWideIntObj(::sys::info::memFree()));
	return TCL_OK;
}


static int
cmdMemTotal(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(Tcl_NewWideIntObj(::sys::info::memTotal()));
	return TCL_OK;
}


static int
cmdEmoticons(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* Emoticons[] =
	{
		"smile",		"frown",		"neutral",	"grin",
		"gleeful",	"wink",		"confuse",	"shock",
		"grumpy",	"upset",		"cry",		"surprise",
		"red",		"eek",		"yell",		"roll",
		"blink",		"sweat",		"razz",		"sleep",
		"saint",		"evil",		"cool",		"glasses",
		"kiss",		"kitty",		0
	};

	static_assert(U_NUMBER_OF(Emoticons) - 2 == util::emoticons::LAST, "table expired");

	if (::strcmp(stringFromObj(objc, objv, 1), "code") == 0)
	{
		int index = ::tcl::uniqueMatchObj(objectFromObj(objc, objv, 2), Emoticons);

		if (index == -1)
			return error(CmdEmoticons, 0, 0, "unknown emotion '%s'", stringFromObj(objc, objv, 2));

		setResult(util::emoticons::toAscii(util::emoticons::Emotion(index)));
	}
	else if (::strcmp(Tcl_GetString(objv[1]), "parse") == 0)
	{
		util::emoticons::Emotion emotion;
		char const* s = stringFromObj(objc, objv, 2);
		bool rc = util::emoticons::lookupEmotion(s, s + ::strlen(s), emotion);

		if (rc && size_t(emotion) >= U_NUMBER_OF(Emoticons))
			return error(CmdEmoticons, 0, 0, "internal lookup error: table is expired");

		setResult(rc ? Emoticons[emotion] : "");
	}
	else if (::strcmp(Tcl_GetString(objv[1]), "list") == 0)
	{
		Tcl_Obj* objs[U_NUMBER_OF(Emoticons) - 1];

		for (unsigned i = 0; i < U_NUMBER_OF(Emoticons) - 1; ++i)
			objs[i] = Tcl_NewStringObj(Emoticons[i], -1);

		setResult(U_NUMBER_OF(Emoticons) - 1, objs);
	}
	else
	{
		return error(CmdEmoticons, 0, 0, "unknown command '%s'", Tcl_GetString(objv[1]));
	}

	return TCL_OK;
}


static int
cmdJulianDay(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	sys::time::Time tm;
	sys::time::localtime(sys::time::time(), tm);
	setResult(::db::Date::julianDay(tm.year, tm.month, tm.day));
	return TCL_OK;
}


namespace tcl {
namespace misc {

void
init(Tcl_Interp* ti)
{
	createCommand(ti, CmdAttributes,				cmdAttributes);
	createCommand(ti, CmdContainsUnicodeChar,	cmdContainsUnicodeChar);
	createCommand(ti, CmdCrc32,					cmdCrc32);
	createCommand(ti, CmdDebug,					cmdDebug);
	createCommand(ti, CmdDirEmpty,				cmdDirEmpty);
	createCommand(ti, CmdEncoding,				cmdEncoding);
	createCommand(ti, CmdEmoticons,				cmdEmoticons);
	createCommand(ti, CmdExtraTags,				cmdExtraTags);
	createCommand(ti, CmdFitsRegion,				cmdFitsRegion);
	createCommand(ti, CmdGeometryRequest,		cmdGeometryRequest);
	createCommand(ti, CmdHardLinked,				cmdHardLinked);
	createCommand(ti, CmdHtml,						cmdHtml);
	createCommand(ti, CmdIsAscii,					cmdIsAscii);
	createCommand(ti, CmdLookup,					cmdLookup);
	createCommand(ti, CmdMapCodeToNag,			cmdMapCodeToNag);
	createCommand(ti, CmdMapExtension,			cmdMapExtension);
	createCommand(ti, CmdMapWindow,				cmdMapWindow);
	createCommand(ti, CmdMaxYear,					cmdMaxYear);
	createCommand(ti, CmdMemAvail,				cmdMemAvail);
	createCommand(ti, CmdMemFree,					cmdMemFree);
	createCommand(ti, CmdMemTotal,				cmdMemTotal);
	createCommand(ti, CmdMinYear,					cmdMinYear);
	createCommand(ti, CmdNumberOfProcessors,	cmdNumberOfProcessors);
	createCommand(ti, CmdPredPow2,				cmdPredPow2);
	createCommand(ti, CmdRevision,				cmdRevision);
	createCommand(ti, CmdSetModTime,				cmdSetModTime);
	createCommand(ti, CmdSize,						cmdSize);
	createCommand(ti, CmdSort,						tcl::misc::sort);
	createCommand(ti, CmdSuccPow2,				cmdSuccPow2);
	createCommand(ti, CmdSuffixes,				cmdSuffixes);
	createCommand(ti, CmdToAscii,					cmdToAscii);
	createCommand(ti, CmdJulianDay,				cmdJulianDay);
	createCommand(ti, CmdUrl,						cmdUrl);
	createCommand(ti, CmdVersion,					cmdVersion);
	createCommand(ti, CmdXml,						cmdXml);
	createCommand(ti, CmdZipContent,				cmdZipContent);
}

} // namespace misc
} // namespace tcl

// vi:set ts=3 sw=3:
