// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2009-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "T_DateTime.h"
#include "T_GenericExpandableToken.h"
#include "T_Messages.h"
#include "T_Environment.h"

#if defined(__unix__) || defined(__MaxOSX__)
# include <time.h>
#elif defined(__WIN32__)
# include <windows.h>
#endif


using namespace TeXt;



static void
perform(Environment& env)
{
	env.putUnboundToken(env.numberToken(env.associatedValue(env.currentToken()->type())));
}


//static void
//performFormatDate(Environment& env)
//{
//	TokenP year		= env.getFinalToken(Verify::numberToken);
//	TokenP month	= env.getFinalToken(Verify::numberToken);
//	TokenP day		= env.getFinalToken(Verify::numberToken);
//
//	mstl::string date;
//	date.format("%02u.%02u.%u", day->value(), month->value(), year->value());	// TODO
//	env.pushProducer(Environment::ProducerP(new TextProducer(date))); // MEMORY
//}


void
DateTime::doRegister(Environment& env)
{
	Value sec, min, hour, day, mon, year;

#if defined(__unix__) || defined(__MaxOSX__)

	time_t t			= time(0);
	struct tm* lt	= ::localtime(&t);

	year	= lt->tm_year;
	mon	= lt->tm_mon;
	day	= lt->tm_mday;
	hour	= lt->tm_hour;
	min	= lt->tm_min;
	sec	= lt->tm_sec;

#elif defined(__WIN32__)

	SYSTEMTIME lt;
	GetLocalTime(&lt);

	year	= lt.wYear;
	mon	= lt.wMon;
	day	= lt.wDay;
	hour	= lt.wHour;
	min	= lt.wMinute;
	sec	= lt.wSecond;

#else

# error "unsupported platform"


#endif

	env.bindMacro(new GenericExpandableToken("\\second",	::perform), sec);
	env.bindMacro(new GenericExpandableToken("\\minute",	::perform), min);
	env.bindMacro(new GenericExpandableToken("\\hour",		::perform), hour);
	env.bindMacro(new GenericExpandableToken("\\day",		::perform), day);
	env.bindMacro(new GenericExpandableToken("\\month",	::perform), mon);
	env.bindMacro(new GenericExpandableToken("\\year",		::perform), year);
}

// vi:set ts=3 sw=3:
