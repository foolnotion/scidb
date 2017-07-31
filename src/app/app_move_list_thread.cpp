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

#include "app_move_list_thread.h"
#include "app_cursor.h"

#include "db_database.h"
#include "db_line.h"
#include "db_exception.h"

#include "u_piped_progress.h"

#include "sys_mutex.h"
#include "sys_lock.h"

#include "m_vector.h"
#include "m_assert.h"

using namespace app;


void
MoveListThread::Result::swap(Result& r)
{
	range.swap(r.range);
	list.swap(r.list);
}


struct MoveListThread::Runnable
{
	typedef MoveListThread::Result Result;
	typedef MoveListThread::ResultList ResultList;
	typedef mstl::range<unsigned> Range;
	typedef mstl::vector<Range> Ranges;

	Runnable(Cursor& cursor,
				db::Database& database,
				ResultList& resultList,
				unsigned view,
				unsigned length,
				mstl::string const* fen,
				db::move::Notation notation,
				Range const& range,
				util::PipedProgress& progress)
		:m_cursor(cursor)
		,m_database(database)
		,m_resultList(resultList)
		,m_progress(progress)
		,m_view(view)
		,m_length(length)
		,m_notation(notation)
		,m_range(range)
		,m_useStartBoard(fen != nullptr)
		,m_stillWorking(true)
		,m_ranges(1, range)
		,m_closed(false)
	{
		M_ASSERT(!range.empty());

		if (fen)
			m_startBoard.setup(*fen, database.variant());
	}

	~Runnable() { close(); }

	void close()
	{
		if (m_closed)
			return;
		m_database.closeAsyncReader(db::thread::MoveList);
		m_closed = true;
	}

	bool stillWorking() const
	{
		sys::Lock lock(&m_mutex);
		return m_stillWorking;
	}

	void addRange(Range range)
	{
		M_ASSERT(!range.empty());

		sys::Lock lock(&m_mutex);

		for (Ranges::const_iterator i = m_ranges.begin(); i != m_ranges.end(); ++i)
			range -= *i;

		if (!range.empty())
			m_ranges.push_back(range);
	}

	void operator() ()
	{
		m_database.openAsyncReader(db::thread::MoveList);

		try
		{
			unsigned	index, last;
			Result	result;

			{
				sys::Lock lock(&m_mutex);

				if (m_ranges.empty())
				{
					m_stillWorking = false;
					return;
				}

				result.range = m_ranges.back();
				index	= result.range.left();
				last	= result.range.right();

				m_progress.start(m_ranges.size());
			}

			while (m_stillWorking)
			{
				for ( ; index < last; ++index)
				{
					if (m_progress.interrupted())
					{
						sys::Lock lock(&m_mutex);
						m_ranges.clear();
						m_stillWorking = false;
						break;
					}

					result.list.push_back();

					db::Board startBoard;
					if (m_useStartBoard)
						startBoard = m_startBoard;

					unsigned			idx(m_view >= 0 ? m_cursor.index(db::table::Games, index, m_view) : index);
					uint16_t			moves[m_length];
					unsigned			length(m_database.loadGame(idx,
																			moves,
																			m_length,
																			startBoard,
																			m_useStartBoard));
					db::Line			line(moves, length);
					mstl::string&	str(result.list.back());

					//M_ASSERT(db::variant::toMainVariant(startBoard.variant()) == m_database.variant());

					line.print(	str,
									startBoard,
									m_database.variant(),
									m_notation,
									db::protocol::Scidb,
									db::encoding::Utf8);

					if (str.empty())
						str.append('*');
				}

				if (m_stillWorking)
				{
					sys::Lock lock(&m_mutex);

					m_resultList.push_back().swap(result);
					m_ranges.pop_back();

					if (m_ranges.empty())
					{
						m_stillWorking = false;
					}
					else
					{
						result.range = m_ranges.back();
						index	= result.range.left();
						last	= result.range.right();
					}
				}
			}

			m_progress.finish();
		}
		catch (...)
		{
			close();
			throw;
		}

		close();
	}

	Cursor&					m_cursor;
	db::Database&			m_database;
	ResultList&				m_resultList;
	util::PipedProgress&	m_progress;
	unsigned					m_view;
	unsigned					m_length;
	db::move::Notation	m_notation;
	db::Board				m_startBoard;
	Range						m_range;
	bool						m_useStartBoard;
	bool						m_stillWorking;
	mutable sys::Mutex	m_mutex;
	Ranges					m_ranges;
	bool						m_closed;
};


MoveListThread::MoveListThread()
	:m_runnable(0)
	,m_databaseId(0)
	,m_viewId(0)
	,m_notation(db::move::Alphabetic)
{
}


MoveListThread::~MoveListThread()
{
	delete m_runnable;
}


void
MoveListThread::retrieve(	Cursor& cursor,
									unsigned view,
									unsigned length,
									mstl::string const* fen,
									db::move::Notation notation,
									Range const& rangeOfView,
									Range rangeOfGames,
									util::PipedProgress& progress)
{
	M_REQUIRE(rangeOfGames.right() <= cursor.view(view).count(db::table::Games));

	db::Database& database(cursor.getDatabase()); // do not call signal(Stop)

	if (	m_databaseId != database.id()
		|| m_viewId != view
		|| m_notation != notation
		|| (fen ? m_fen != *fen : !m_fen.empty()))
	{
		clear();
		m_databaseId = database.id();
		m_viewId = view;
		m_notation = notation;
		m_fen = fen ? *fen : mstl::string::empty_string;
	}
	else
	{
		sys::Lock lock(m_runnable ? &m_runnable->m_mutex : 0);

		if (!m_resultList.empty())
		{
			for (ResultList::iterator i = m_resultList.begin(); i != m_resultList.end(); ++i)
			{
				if (i->range.intersects(rangeOfView))
					rangeOfGames -= i->range;
				else
					i = m_resultList.erase(i);
			}
		}
	}

	if (rangeOfGames.empty())
		return;

	if (m_runnable && m_runnable->stillWorking())
	{
		m_runnable->addRange(rangeOfGames);
	}
	else
	{
		m_runnable = new Runnable(	cursor,
											database,
											m_resultList,
											view,
											length,
											fen,
											notation,
											rangeOfGames,
											progress);

		if (!start(mstl::function<void ()>(&Runnable::operator(), m_runnable)))
		{
			delete m_runnable;
			m_runnable = 0;
			IO_RAISE(Unspecified, Cannot_Create_Thread, "start of move list retrieval failed");
		}
	}
}


void
MoveListThread::signal(Signal signal)
{
	stop();

	if (m_runnable && signal == Stop)
	{
		delete m_runnable;
		m_runnable = 0;
	}
}


mstl::string const&
MoveListThread::moveList(unsigned index) const
{
	sys::Lock lock(m_runnable ? &m_runnable->m_mutex : 0);

	for (ResultList::const_iterator i = m_resultList.begin(); i != m_resultList.end(); ++i)
	{
		if (i->range.contains(index))
			return i->list[index - i->range.left()];
	}

	return mstl::string::empty_string;
}


void
MoveListThread::clear()
{
	delete m_runnable;
	m_runnable = 0;
	m_resultList.clear();
}

// vi:set ts=3 sw=3:
