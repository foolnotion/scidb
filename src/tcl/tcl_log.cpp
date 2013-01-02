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

#include "tcl_log.h"
#include "tcl_base.h"

#include "u_base.h"

#include <tcl.h>

using namespace tcl;


Log::Log(Tcl_Obj* cmd, Tcl_Obj* arg)
	:m_cmd(cmd)
	,m_arg(arg)
	,m_tooManyRounds(false)
{
	Tcl_IncrRefCount(m_cmd);
	Tcl_IncrRefCount(m_arg);
}


Log::~Log() throw()
{
	Tcl_DecrRefCount(m_cmd);
	Tcl_DecrRefCount(m_arg);
}


bool
Log::error(db::save::State code, unsigned gameNumber)
{
	char const* msg = 0;

	switch (code)
	{
		case db::save::Ok:							return true;
		case db::save::UnsupportedVariant:		msg = "UnsupportedVariant"; break;
		case db::save::DecodingFailed:			msg = "DecodingFailed"; break;
		case db::save::GameTooLong:				msg = "GameTooLong"; break;
		case db::save::FileSizeExeeded:			msg = "FileSizeExeeded"; break;
		case db::save::TooManyGames:				msg = "TooManyGames"; break;
		case db::save::TooManyPlayerNames:		msg = "TooManyPlayerNames"; break;
		case db::save::TooManyEventNames:		msg = "TooManyEventNames"; break;
		case db::save::TooManySiteNames:			msg = "TooManySiteNames"; break;
		case db::save::TooManyAnnotatorNames:	msg = "TooManyAnnotatorNames"; break;

		case db::save::TooManyRoundNames:
			if (m_tooManyRounds)
				return true;
			m_tooManyRounds = true;
			msg = "TooManyRoundNames";
			break;
	}

	Tcl_Obj* objv[3];

	objv[0] = Tcl_NewStringObj(code == db::save::GameTooLong ? "warning" : "error", -1);
	objv[1] = Tcl_NewStringObj(msg, -1);
	objv[2] = Tcl_NewIntObj(gameNumber + 1);

	invoke(__func__, m_cmd, m_arg, 0, U_NUMBER_OF(objv), objv);

	switch (int(code))
	{
		case db::save::GameTooLong:
		case db::save::TooManyRoundNames:
		case db::save::UnsupportedVariant:
		case db::save::DecodingFailed:
			return true;
	}

	return false;
}


void
Log::warning(Warning code, unsigned gameNumber)
{
	char const* msg = 0;

	switch (code)
	{
		case InvalidRoundTag:					msg = "InvalidRoundTag"; break;
		case MaximalWarningCountExceeded:	msg = "MaximalWarningCountExceeded"; break;
	}

	Tcl_Obj* objv[3];

	objv[0] = Tcl_NewStringObj("warning", -1);
	objv[1] = Tcl_NewStringObj(msg, -1);
	objv[2] = Tcl_NewIntObj(gameNumber + 1);

	invoke(__func__, m_cmd, m_arg, 0, U_NUMBER_OF(objv), objv);
}

// vi:set ts=3 sw=3:
