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

#include "db_var_consumer.h"
#include "db_move_node.h"

#include "m_assert.h"

using namespace db;


VarConsumer::VarConsumer(Board const& startBoard, mstl::string const& encoding)
	:Consumer(format::Pgn, encoding)
	,m_result(new MoveNode)
	,m_current(m_result)
{
	setStartBoard(startBoard);
}


VarConsumer::~VarConsumer() throw()
{
	delete m_result;
}


format::Type VarConsumer::format() const { return format::Pgn; }
bool VarConsumer::beginGame(TagSet const&) { return true; }
save::State VarConsumer::endGame(TagSet const&) { return save::Ok; }
void VarConsumer::start() {}
void VarConsumer::finish() {}
void VarConsumer::beginMoveSection() {}
void VarConsumer::endMoveSection(result::ID) {}


void
VarConsumer::sendComment(Comment const& comment)
{
	m_current->setComment(comment);
}


void
VarConsumer::sendComment(	Comment const& comment,
									Annotation const& annotation,
									MarkSet const& marks)
{
	if (!comment.isEmpty())
		m_current->setComment(comment);
	if (!annotation.isEmpty())
		m_current->setAnnotation(annotation);
	if (!marks.isEmpty())
		m_current->setMarks(marks);
}


bool
VarConsumer::sendMove(Move const& move)
{
	M_REQUIRE(move);

	Board const& board = this->board();

	if (!board.isValidMove(move))
		return false;

	MoveNode* node = new MoveNode(board, move);

	m_current->setNext(node);
	m_current = node;

	return true;
}


bool
VarConsumer::sendMove(	Move const& move,
								Annotation const& annotation,
								MarkSet const& marks,
								Comment const& comment)
{
	if (!sendMove(move))
		return false;

	sendComment(comment, annotation, marks);
	return true;
}


void
VarConsumer::beginVariation()
{
	MoveNode* node = new MoveNode;
	m_current->addVariation(node);
	m_current = node;
}


void
VarConsumer::endVariation()
{
	while (!m_current->atLineStart())
	{
		M_ASSERT(m_current->prev());
		m_current = m_current->prev();
	}

	M_ASSERT(m_current->prev());
	m_current = m_current->prev();
}


MoveNode*
VarConsumer::release()
{
	M_REQUIRE(notReleased());

	MoveNode* result = m_result;
	m_result = 0;
	return result;
}

// vi:set ts=3 sw=3:
