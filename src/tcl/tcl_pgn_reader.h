// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2009-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _tcl_pgn_reader_included
#define _tcl_pgn_reader_included

#include "db_pgn_reader.h"

extern "C" { struct Tcl_Interp; }
extern "C" { struct Tcl_Obj; }

namespace db   { class GameInfo; }
namespace sys  { namespace utf8 { class Codec; } }
namespace mstl { class istream; }
namespace mstl { class string; }

namespace tcl
{

class PgnReader : public ::db::PgnReader
{
public:

	struct Encoder
	{
		Encoder(char const* encoding);
		~Encoder() throw();

		sys::utf8::Codec* codec;
	};

	PgnReader(	mstl::istream& strm,
					Encoder& encoder,
					Tcl_Obj* cmd,
					Tcl_Obj* arg,
					Modification modification,
					int firstGameNumber = 0,
					unsigned lineOffset = 0,
					bool trialMode = false);
	~PgnReader() throw();

	unsigned countErrors() const;
	unsigned countWarnings() const;
	Error lastErrorCode() const;

	void warning(	Warning code,
						unsigned lineNo,
						unsigned column,
						unsigned gameNo,
						mstl::string const& info,
						mstl::string const& item) override;
	void error(		Error code,
						unsigned lineNo,
						unsigned column,
						int gameNo,
						mstl::string const& message,
						mstl::string const& info,
						mstl::string const& item) override;

private:

	Tcl_Obj*	m_cmd;
	Tcl_Obj*	m_arg;
	Tcl_Obj*	m_warning;
	Tcl_Obj*	m_error;
	unsigned	m_lineOffset;
	unsigned	m_countErrors;
	unsigned	m_countWarnings;
	bool		m_trialModeFlag;
	Error		m_lastError;
};

} // namespace tcl

#endif // _tcl_pgn_reader_included

// vi:set ts=3 sw=3:
