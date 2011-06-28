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

#include "tcl_base.h"
#include "tcl_exception.h"

#include "db_comment.h"
#include "db_player.h"

#include "sys_utf8_codec.h"

#include "u_crc.h"

#include "m_backtrace.h"
#include "m_string.h"
#include "m_stack.h"
#include "m_assert.h"

#include <tcl.h>
#include <string.h>

using namespace tcl;

static char const* ScidbVersion = "1.0 BETA";

static char const* CmdCrc32		= "::scidb::misc::crc32";
static char const* CmdDebug		= "::scidb::misc::debug?";
static char const* CmdFitsRegion	= "::scidb::misc::fitsRegion?";
static char const* CmdIsAscii		= "::scidb::misc::isAscii?";
static char const* CmdLookup		= "::scidb::misc::lookup";
static char const* CmdToAscii		= "::scidb::misc::toAscii";
static char const* CmdVersion		= "::scidb::misc::version";
static char const* CmdXmlFromList	= "::scidb::misc::xmlFromList";
static char const* CmdXmlToList	= "::scidb::misc::xmlToList";


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

class ToList : public db::Comment::Callback
{
public:

	ToList();
	~ToList() throw();

	Tcl_Obj* result();

	void start();
	void finish();

	void startLanguage(mstl::string const& lang);
	void endLanguage(mstl::string const& lang);

	void startAttribute(Attribute attr);
	void endAttribute(Attribute attr);

	void content(mstl::string const& s);
	void nag(mstl::string const& s);
	void symbol(char s);

	void invalidXmlContent(mstl::string const& content);

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

		char const* lang = Tcl_GetStringFromObj(argv[0], 0);

		m_xml.format("<:%s>", lang);
		Tcl_ListObjGetElements(0, argv[1], &argc, &argv);

		for (int k = 0; k < argc; ++k)
		{
			int objn;
			Tcl_Obj** objs;

			Tcl_ListObjGetElements(0, argv[k], &objn, &objs);

			if (objn == 0)
				M_RAISE("invalid xml list");

			char const* token = Tcl_GetStringFromObj(objs[0], 0);

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
											case '<': m_xml.append("&lt;", 4); break;
											case '>': m_xml.append("&gt;", 4); break;
											case '&': m_xml.append("&amp;", 5); break;
											default:  m_xml += str[j]; break;
										}
									}
								}
							}
							break;

						case 'y':	// "sym"
							processModes();
							m_xml.append("<sym>", 5);
							m_xml += *Tcl_GetStringFromObj(objs[1], 0);
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
					m_xml += Tcl_GetStringFromObj(objs[1], 0);
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
	db::Comment comment(stringFromObj(objc, objv, 1), false, false); // language flags not needed
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
cmdDebug(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(int(mstl::backtrace::is_debug_mode()));
	return TCL_OK;
}


static int
cmdLookup(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	db::Player const* player = db::Player::findPlayer(unsignedFromObj(objc, objv, 1));

	if (player)
		setResult(player->name());
	else
		setResult("");
	return TCL_OK;
}


namespace tcl {
namespace misc {

void
init(Tcl_Interp* ti)
{
	createCommand(ti, CmdDebug,			cmdDebug);
	createCommand(ti, CmdFitsRegion,	cmdFitsRegion);
	createCommand(ti, CmdIsAscii,		cmdIsAscii);
	createCommand(ti, CmdLookup,		cmdLookup);
	createCommand(ti, CmdToAscii,		cmdToAscii);
	createCommand(ti, CmdVersion,		cmdVersion);
	createCommand(ti, CmdXmlFromList,	cmdXmlFromList);
	createCommand(ti, CmdXmlToList,	cmdXmlToList);
	createCommand(ti, CmdCrc32,			cmdCrc32);
}

} // namespace misc
} // namespace tcl

// vi:set ts=3 sw=3:
