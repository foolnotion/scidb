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
// Copyright: (C) 2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _db_bpgn_reader_included
#define _db_bpgn_reader_included

#include "db_reader.h"
#include "db_annotation.h"
#include "db_tag_set.h"
#include "db_move.h"
#include "db_move_list.h"
#include "db_comment.h"

#include "m_string.h"
#include "m_vector.h"
#include "m_map.h"

namespace mstl { class istream; }
namespace util { class Progress; }
namespace sys { namespace utf8 { class Codec; } }

namespace db {

class BpgnReader : public Reader
{
public:

	BpgnReader(	mstl::istream& stream,
					variant::Type variant,
					mstl::string const& encoding,
					ReadMode readMode,
					Modification modification = Normalize,
					ResultMode resultMode = UseResultTag);
	virtual ~BpgnReader() throw();

	unsigned process(util::Progress& progress);

	unsigned estimateNumberOfGames() override;
	static unsigned estimateNumberOfGames(unsigned fileSize);

private:

	mstl::istream& m_stream;
};

} // namespace db

#endif // _db_bpgn_reader_included

// vi:set ts=3 sw=3:
