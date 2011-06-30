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
// Copyright: (C) 2009-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _db_consumer_included
#define _db_consumer_included

#include "db_provider.h"
#include "db_board.h"
#include "db_line.h"
#include "db_home_pawns.h"
#include "db_common.h"

#include "m_stack.h"
#include "m_string.h"

namespace sys { namespace utf8 { class Codec; } }

namespace db {

class Comment;
class TagSet;
class MarkSet;
class Annotation;
class Move;
class Producer;

class Consumer : public Provider
{
public:

	Consumer(format::Type srcFormat, mstl::string const& encoding);
	~Consumer() throw();

	bool isMainline() const;
	bool variationIsEmpty() const;
	bool terminated() const;
	bool commentEngFlag() const;
	bool commentOthFlag() const;

	format::Type sourceFormat() const;
	virtual format::Type format() const = 0;

	unsigned variationLevel() const;
	unsigned countVariations() const;
	unsigned countComments() const;
	unsigned countAnnotations() const;
	unsigned countMarks() const;
	unsigned plyCount() const;
	uint32_t flags() const;

	Board const& board() const;
	Board const& startBoard() const;
	Line const& openingLine() const;
	mstl::string const& encoding() const;
	sys::utf8::Codec& codec() const;

	Board const& getFinalBoard() const;
	Board const& getStartBoard() const;

	virtual void start() = 0;
	virtual void finish() = 0;

	bool startGame(TagSet const& tags);
	bool startGame(TagSet const& tags, Board const& board);
	save::State finishGame(TagSet const& tags);

	void putPrecedingComment(Comment const& comment, Annotation const& annotation, MarkSet const& marks);
	void putTrailingComment(Comment const& comment);
	void putMove(Move const& move);
	void putMove(	Move const& move,
						Annotation const& annotation,
						Comment const& preComment,
						Comment const& comment,
						MarkSet const& marks);
	void setFlags(uint32_t flags);

	void startMoveSection();
	void finishMoveSection(result::ID result);

	void startVariation();
	void finishVariation();

	// data for receiver

	Consumer* consumer() const;
	void setConsumer(Consumer* consumer);

#ifdef DEBUG_SI4
	uint32_t m_index;
#endif

protected:

	virtual bool beginGame(TagSet const& tags) = 0;
	virtual save::State endGame(TagSet const& tags) = 0;

	virtual void sendPrecedingComment(Comment const& comment,
												Annotation const& annotation,
												MarkSet const& marks) = 0;
	virtual void sendTrailingComment(Comment const& comment, bool variationIsEmpty) = 0;
	virtual bool sendMove(	Move const& move) = 0;
	virtual bool sendMove(	Move const& move,
									Annotation const& annotation,
									MarkSet const& marks,
									Comment const& preComment,
									Comment const& comment) = 0;

	virtual void beginMoveSection() = 0;
	virtual void endMoveSection(result::ID result) = 0;

	virtual void beginVariation() = 0;
	virtual void endVariation(bool isEmpty) = 0;

	Board& getBoard();
	void setStartBoard(Board const& board);

private:

	struct Entry
	{
		Board	board;
		Move	move;
		bool	empty;
	};

	typedef mstl::stack<Entry> Stack;

	bool startGame(TagSet const& tags, Board const* board);
	void setup(Board const& startPosition);
	void setup(mstl::string const& fen);
	void setup(unsigned idn);

	friend class Producer;

	format::Type		m_format;
	Stack					m_stack;
	unsigned				m_variationCount;
	unsigned				m_commentCount;
	unsigned				m_annotationCount;
	unsigned				m_markCount;
	bool					m_terminated;
	uint32_t				m_flags;
	Line					m_line;
	HomePawns			m_homePawns;
	uint16_t				m_moveBuffer[opening::Max_Line_Length];
	mstl::string		m_encoding;
	sys::utf8::Codec*	m_codec;
	Consumer*			m_consumer;
	bool					m_setupBoard;
	bool					m_commentEngFlag;
	bool					m_commentOthFlag;
};

} // namespace db

#include "db_consumer.ipp"

#endif // _db_consumer_included

// vi:set ts=3 sw=3:
