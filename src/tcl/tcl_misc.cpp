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
// Copyright: (C) 2010-2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "tcl_base.h"
#include "tcl_exception.h"
#include "tcl_database.h"
#include "tcl_file.h"

#include "db_comment.h"
#include "db_player.h"
#include "db_database_codec.h"

#include "si3_codec.h"
#include "sci_codec.h"

#include "nsUniversalDetector.h"

#include "sys_utf8_codec.h"
#include "sys_file.h"

#include "u_crc.h"
#include "u_html.h"

#include "m_backtrace.h"
#include "m_string.h"
#include "m_assert.h"

#include <tcl.h>
#include <tk.h>
#include <string.h>

using namespace tcl;

static char const* ScidbVersion	= "1.0 BETA";
static char const* ScidbRevision	= "96";

static char const* CmdAttributes			= "::scidb::misc::attributes";
static char const* CmdCrc32				= "::scidb::misc::crc32";
static char const* CmdDebug				= "::scidb::misc::debug?";
static char const* CmdEncoding			= "::scidb::misc::encoding";
static char const* CmdExtraTags			= "::scidb::misc::extraTags";
static char const* CmdFitsRegion			= "::scidb::misc::fitsRegion?";
static char const* CmdGeometryRequest	= "::scidb::misc::geometryRequest";
static char const* CmdHardLinked			= "::scidb::misc::hardLinked?";
static char const* CmdHtml					= "::scidb::misc::html";
static char const* CmdIsAscii				= "::scidb::misc::isAscii?";
static char const* CmdLookup				= "::scidb::misc::lookup";
static char const* CmdMapExtension		= "::scidb::misc::mapExtension";
static char const* CmdRevision			= "::scidb::misc::revision";
static char const* CmdSetModTime			= "::scidb::misc::setModTime";
static char const* CmdSize					= "::scidb::misc::size";
static char const* CmdSuffixes			= "::scidb::misc::suffixes";
static char const* CmdToAscii				= "::scidb::misc::toAscii";
static char const* CmdVersion				= "::scidb::misc::version";
static char const* CmdXml					= "::scidb::misc::xml";

static unsigned cacheCount = 0;


static void
append(mstl::string& result, char const* s, unsigned len)
{
	char const* e = s + len;

	result.reserve(result.size() + len);

	while (s < e)
	{
		switch (*s)
		{
			case '{':
				result += "<brace/>";
				++s;
				break;

			case '&':
				if (strncmp("&lt;", s, 4) == 0)
				{
					result += '<';
					s += 4;
				}
				else if (strncmp("&gt;", s, 4) == 0)
				{
					result += '>';
					s += 4;
				}
				else if (strncmp("&amp;", s, 4) == 0)
				{
					result += '&';
					s += 5;
				}
				else if (strncmp("&apos;", s, 6) == 0)
				{
					result += '\'';
					s += 6;
				}
				else if (strncmp("&quot;", s, 4) == 0)
				{
					result += '"';
					s += 6;
				}
				else
				{
					result += *s++;
				}
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

	ToList();
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

	void invalidXmlContent(mstl::string const& content) override;

private:

	typedef mstl::stack<Tcl_Obj*> Stack;

	void putContent();
	void putTag(char const* tag);
	void putTag(char const* tag, mstl::string const& content);

	Tcl_Obj*			m_result;
	mstl::string	m_tag;
	mstl::string	m_content;
	Stack				m_stack;
};


Tcl_Obj* ToList::result() { return m_result; }


ToList::ToList()
	:m_result(Tcl_NewListObj(0, 0))
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
ToList::putTag(char const* tag, mstl::string const& content)
{
	M_ASSERT(!m_stack.empty());

	if (!content.empty())
	{
		Tcl_Obj* objv[2];
		objv[0] = Tcl_NewStringObj(tag, -1);
		objv[1] = Tcl_NewStringObj(content, content.size());
		Tcl_ListObjAppendElement(0, m_stack.top(), Tcl_NewListObj(2, objv));
	}
}


void
ToList::putContent()
{
	if (!m_content.empty())
	{
		putTag("str", m_content);
		m_content.clear();
	}
}


void
ToList::putTag(char const* tag)
{
	M_ASSERT(!m_stack.empty());

	Tcl_Obj* objv[1] = { Tcl_NewStringObj(tag, -1) };
	Tcl_ListObjAppendElement(0, m_stack.top(), Tcl_NewListObj(1, objv));
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
	::append(m_content, s, s.size());
}


void
ToList::nag(mstl::string const& s)
{
	putContent();
	putTag("nag", s);
}


void
ToList::symbol(char s)
{
	putContent();
	putTag("sym", mstl::string(1, s));
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
	Tcl_ListObjLength(0, m_stack.top(), &length);

	putContent();

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

	Parser(Tcl_Obj* obj);

	mstl::string const& parse();

private:

	enum Mode { Bold = 0, Italic = 1, Underline = 2 };

	void processModes();

	Tcl_Obj*			m_obj;
	mstl::string	m_xml;
	unsigned			m_attr[3];
	bool				m_mode[3];
};


Parser::Parser(Tcl_Obj* obj)
	:m_obj(obj)
{
	M_ASSERT(m_obj);

	m_attr[0] = m_attr[1] = m_attr[2] = 0;
	m_mode[0] = m_mode[1] = m_mode[2] = 0;
	m_xml.reserve(512);
}


void
Parser::processModes()
{
	static char const Token[3] = { 'b', 'i', 'u' };

	for (unsigned i = 0; i < 3; ++i)
	{
		if (m_attr[i])
		{
			if (!m_mode[i])
			{
				m_xml += '<';
				m_xml += Token[i];
				m_xml += '>';
				m_mode[i] = true;
			}
		}
		else
		{
			if (m_mode[i])
			{
				m_xml += '<';
				m_xml += '/';
				m_xml += Token[i];
				m_xml += '>';
				m_mode[i] = false;
			}
		}
	}
}


mstl::string const&
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

			if (objn == 0)
				M_RAISE("invalid xml list");

			char const* token = Tcl_GetStringFromObj(objs[0], nullptr);

			switch (*token)
			{
				case 's':	// "str" | "sym"
					if (objn != 2)
						M_RAISE("invalid xml list");

					switch (token[1])
					{
						case 't':	// "str"
							{
								int len;
								char const* str = Tcl_GetStringFromObj(objs[1], &len);

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
					break;

				case 'n':	// nag
					if (objn != 2)
						M_RAISE("invalid xml list");

					processModes();
					m_xml.append("<nag>", 5);
					m_xml += Tcl_GetString(objs[1]);
					m_xml.append("</nag>", 6);
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

	return m_xml;
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
	::db::Comment comment(stringFromObj(objc, objv, 1), false, false); // language flags not needed
	ToList callback;

	comment.parse(callback);
	setResult(callback.result());

	return TCL_OK;
}


static int
cmdXmlFromList(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Parser parser(objectFromObj(objc, objv, 1));
	setResult(parser.parse());
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

	return error(CmdXml, 0, 0, "unknown command '%s'", command);
}


static int
cmdCrc32(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const* s = stringFromObj(objc, objv, 1);
	setResult(util::crc::compute(0, s, ::strlen(s)));
	return TCL_OK;
}


static int
cmdVersion(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(::ScidbVersion);
	return TCL_OK;
}


static int
cmdRevision(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(::ScidbRevision);
	return TCL_OK;
}


static int
cmdDebug(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(int(mstl::backtrace::is_debug_mode()));
	return TCL_OK;
}


static int
cmdLookup(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	::db::Player const* player = ::db::Player::findPlayer(unsignedFromObj(objc, objv, 1));
	bool unicodeFlag = false;

	if (objc > 2)
	{
		if (strcmp(stringFromObj(objc, objv, 2), "-unicode") != 0)
			return error(CmdLookup, 0, 0, "unknown option '%s'", stringFromObj(objc, objv, 2));

		unicodeFlag = boolFromObj(objc, objv, 3);
	}

	if (!player)
		setResult("");
	else if (unicodeFlag)
		setResult(player->name());
	else
		setResult(player->asciiName());

	return TCL_OK;
}


static int
cmdSize(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	int				numGames;
	uint32_t			creationTime;
	::db::type::ID	type;

	::db::DatabaseCodec::getAttributes(	stringFromObj(objc, objv, 1),
													numGames,
													type,
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
	::db::type::ID	type;

	::db::DatabaseCodec::getAttributes(	stringFromObj(objc, objv, 1),
													numGames,
													type,
													creationTime,
													&description);

	Tcl_Obj* objs[4];

	mstl::string created;

	if (creationTime)
		created = ::db::Time(creationTime).asString();

	objs[0] = Tcl_NewIntObj(numGames);
	objs[1] = Tcl_NewStringObj(tcl::db::lookupType(type), -1);
	objs[2] = Tcl_NewStringObj(created, created.size());
	objs[3] = Tcl_NewStringObj(description, description.size());

	setResult(4, objs);
	return TCL_OK;
}


static int
cmdSuffixes(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	::db::DatabaseCodec::StringList result;
	::db::DatabaseCodec::getSuffixes(stringFromObj(objc, objv, 1), result);

	Tcl_Obj* objs[result.size()];

	for (unsigned i = 0; i < result.size(); ++i)
		objs[i] = Tcl_NewStringObj(result[i], -1);

	setResult(result.size(), objs);
	return TCL_OK;
}


static int
cmdMapExtension(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* Extensions[] = { "sci", "si3", "si4", "cbh" };

	mstl::string extension(stringFromObj(objc, objv, 1));

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

	Tcl_Obj* objs[::db::tag::ExtraTag];
	unsigned count = 0;

	for (unsigned i = 0; i < ::db::tag::ExtraTag; ++i)
	{
		if (isExtraTagFunc(::db::tag::ID(i)))
			objs[count++] = Tcl_NewStringObj(::db::tag::toName(::db::tag::ID(i)), -1);
	}

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
		Tcl_WrongNumArgs(	ti, 1, objv, "<patternFile> <dictFiles> <document>");
		return TCL_ERROR;
	}

	int length;
	char const* document = Tcl_GetStringFromObj(objv[3], &length);

	util::html::Hyphenate hyphenate(
		stringFromObj(objc, objv, 1),
		stringFromObj(objc, objv, 2),
		util::html::Hyphenate::KeepInCache);

	hyphenate.parse(document, length);
	setResult(hyphenate.result());

	return TCL_OK;
}


static int
cmdHtmlLigatures(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 2)
	{
		Tcl_WrongNumArgs(	ti, 1, objv, "<document>");
		return TCL_ERROR;
	}

	int length;
	char const* document = Tcl_GetStringFromObj(objv[1], &length);

	util::html::BuildLigatures ligatures;
	ligatures.parse(document, length);
	setResult(ligatures.result());

	return TCL_OK;
}


static int
cmdHtmlSearch(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc < 3)
	{
		Tcl_WrongNumArgs(	ti, 1, objv,
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

	util::html::Search search(noCase, entireWord, titleOnly, maxMatches);

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
		util::html::Hyphenate::clearCache();

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


namespace tcl {
namespace misc {

void
init(Tcl_Interp* ti)
{
	createCommand(ti, CmdAttributes,			cmdAttributes);
	createCommand(ti, CmdCrc32,					cmdCrc32);
	createCommand(ti, CmdDebug,					cmdDebug);
	createCommand(ti, CmdEncoding,				cmdEncoding);
	createCommand(ti, CmdExtraTags,			cmdExtraTags);
	createCommand(ti, CmdFitsRegion,			cmdFitsRegion);
	createCommand(ti, CmdGeometryRequest,	cmdGeometryRequest);
	createCommand(ti, CmdHardLinked,			cmdHardLinked);
	createCommand(ti, CmdHtml,					cmdHtml);
	createCommand(ti, CmdIsAscii,				cmdIsAscii);
	createCommand(ti, CmdLookup,				cmdLookup);
	createCommand(ti, CmdMapExtension,		cmdMapExtension);
	createCommand(ti, CmdRevision,				cmdRevision);
	createCommand(ti, CmdSetModTime,			cmdSetModTime);
	createCommand(ti, CmdSize,					cmdSize);
	createCommand(ti, CmdSuffixes,				cmdSuffixes);
	createCommand(ti, CmdToAscii,				cmdToAscii);
	createCommand(ti, CmdVersion,				cmdVersion);
	createCommand(ti, CmdXml,					cmdXml);
}

} // namespace misc
} // namespace tcl

// vi:set ts=3 sw=3:
