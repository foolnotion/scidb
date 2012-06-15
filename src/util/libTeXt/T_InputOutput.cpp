// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2009-2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "T_InputOutput.h"
#include "T_GenericFinalToken.h"
#include "T_GenericExpandableToken.h"
#include "T_Environment.h"
#include "T_TokenP.h"
#include "T_FileInput.h"
#include "T_Messages.h"

#include "m_auto_ptr.h"
#include "m_string.h"
#include "m_ifstream.h"

#if defined(__WIN32__)
#elif defined(__unix__) || defined(__MacOSX__)
# include <unistd.h>
#endif


using namespace TeXt;


mstl::string const&
InputOutput::suffix()
{
	static mstl::string const kSuffix(".eXt");
	return kSuffix;
}


static bool
fileExists(mstl::string const& name)
{
#if defined(__WIN32__)

	DWORD fileAttr = GetFileAttributes(name);
	return fileAttr != 0xffffffff;

#elif defined(__unix__) || defined(__MacOSX__)

	return ::access(name, R_OK) == 0;

#endif
}


bool
InputOutput::searchFile(mstl::string const& searchDirs, mstl::string& filename)
{
	if (fileExists(filename))
		return true;

	mstl::string::size_type start	= 0;
	mstl::string::size_type end	= searchDirs.find(':');

	if (end == mstl::string::npos)
		end = searchDirs.size();

	while (end > start)
	{
		mstl::string fullPathname(searchDirs.substr(start, end));

#if defined(__WIN32__)
		fullPathname += '\\';
#else
		fullPathname += '/';
#endif

		fullPathname += filename;

		if (fileExists(fullPathname))
		{
			filename.swap(fullPathname);
			return true;
		}

		if ((start = end + 1) >= searchDirs.size())
			return false;

		end = searchDirs.find(':', start);

		if (end == mstl::string::npos)
			end = searchDirs.size();
	}

	return false;
}


static FileInput*
createInput(Environment& env, mstl::string const& filename)
{
	mstl::string const& suffix(InputOutput::suffix());

	mstl::auto_ptr<mstl::ifstream> stream;

	if (	filename.size() <= suffix.size()
		|| filename.substr(filename.size() - suffix.size()) != suffix)
	{
		mstl::string pathname(filename);
		pathname += suffix;

		if (!InputOutput::searchFile(env.searchDirs(), pathname))
			return 0;

		stream.reset(new mstl::ifstream(pathname));
	}
	else
	{
		mstl::string pathname(filename);

		if (!InputOutput::searchFile(env.searchDirs(), pathname))
			return 0;

		stream->clear();
		stream->open(pathname);
	}

	if (!*stream)
		return 0;

	return new FileInput(stream.release(), true);
}


static void
performInput(Environment& env)
{
	mstl::string filename;

	TokenP token = env.getUndefinedToken();

	if (token->type() == Token::T_Undefined)
	{
		filename = token->name();

		if (!filename.empty() && filename[0] == Token::EscapeChar)
			filename.erase(filename.begin());
	}
	else
	{
		env.putUnboundToken(token);
		env.perform(env.getExpandableToken(), filename);
	}

	Environment::InputP input(createInput(env, filename));

	if (input == 0)
		return Messages::errmessage(env, "I can't find file '" + filename + "'", Messages::Incorrigible);

	env.pushInput(input);
}


static void
performEndinput(Environment& env)
{
	env.popInput();
}


static void
performInputlineno(Environment& env)
{
	env.putUnboundToken(env.numberToken(env.lineno()));
}


void
InputOutput::doRegister(Environment& env)
{
	env.bindMacro(new GenericFinalToken("\\input", ::performInput));
	env.bindMacro(new GenericFinalToken("\\endinput", ::performEndinput));
	env.bindMacro(new GenericExpandableToken("\\inputlineno", ::performInputlineno));
}

// vi:set ts=3 sw=3:
