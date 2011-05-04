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
// Copyright: (C) 2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _db_var_consumer_included
#define _db_var_consumer_included

#include "db_consumer.h"

#include "m_vector.h"

namespace db {

class Board;
class MoveNode;

class VarConsumer : public Consumer
{
public:

	VarConsumer(Board const& startBoard, mstl::string const& encoding = mstl::string::empty_string);
	~VarConsumer() throw();

	bool notReleased() const;

	MoveNode const* result() const;
	MoveNode* release();

	format::Type format() const;

	void start();
	void finish();

protected:

	bool beginGame(TagSet const& tags);
	save::State endGame(TagSet const& tags);

	void sendComment(Comment const& comment, Annotation const& annotation, MarkSet const& marks);
	bool sendMove(Move const& move);
	bool sendMove(	Move const& move,
						Annotation const& annotation,
						MarkSet const& marks,
						Comment const& comment);

	void beginMoveSection();
	void endMoveSection(result::ID result);

	void beginVariation();
	void endVariation();

private:

	MoveNode* m_result;
	MoveNode* m_current;
};

} // namespace db

#include "db_var_consumer.ipp"

#endif // _db_move_consumer_included

// vi:set ts=3 sw=3:
