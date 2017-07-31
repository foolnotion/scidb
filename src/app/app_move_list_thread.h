// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $HeadURL$
// ======================================================================

// ======================================================================
//    _/|            __
//   // o\         /    )           ,        /    /
//   || ._)    ----\---------__----------__-/----/__-
//   //__\          \      /   '  /    /   /    /   )
//   )___(     _(____/____(___ __/____(___/____(___/_
// ======================================================================

// ======================================================================
// Copyright: (C) 2014-2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _app_move_list_thread_included
#define _app_move_list_thread_included

#include "app_thread.h"

#include "db_common.h"

#include "m_list.h"
#include "m_vector.h"
#include "m_string.h"
#include "m_range.h"

namespace util { class PipedProgress; }
namespace mstl { template <typename T> class range; }

namespace app {

class MoveListThread : public Thread
{
public:

	typedef mstl::vector<mstl::string> StringList;
	typedef mstl::range<unsigned> Range;

	struct Result
	{
		Range			range;
		StringList	list;

		void swap(Result& r);
	};

	typedef mstl::list<Result> ResultList;

	MoveListThread();
	~MoveListThread();

	mstl::string const& moveList(unsigned index) const;

	void retrieve(	Cursor& cursor,
						unsigned view,
						unsigned length,
						mstl::string const* fen,
						db::move::Notation notation,
						Range const& rangeOfView,
						Range rangeOfGames,
						util::PipedProgress& progress);
	void signal(Signal signal) override;
	void clear();

private:

	typedef db::move::Notation Notation;

	struct Runnable;

	Runnable*		m_runnable;
	unsigned			m_databaseId;
	unsigned			m_viewId;
	Notation			m_notation;
	mstl::string	m_fen;
	ResultList		m_resultList;
};

} // namespace app

#endif // _app_move_list_thread_included

// vi:set ts=3 sw=3:
