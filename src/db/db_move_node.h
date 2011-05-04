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

#ifndef _db_move_node_included
#define _db_move_node_included

#include "db_comment.h"
#include "db_move.h"
#include "db_common.h"

#include "m_set.h"
#include "m_vector.h"
#include "m_string.h"

// +---+----+---+   +---+----+---+   +---+----+---+   +---+----+---+
// |   |    |   |<--|-+ |e2e4|   |<--|-+ |e7e5|   |<--|-+ |d2d4|   |
// +---+----+---+   +---+----+---+   +---+----+---+   +---+----+---+
// |   |    | +-|-->|   |    | +-|-->|   | V  | +-|-->|   |    |   |
// +---+----+---+   +---+----+---+   +---+----+---+   +---+----+---+
//                                         |    ^
//                        +----------------+    |
//                        |                     |
//                        |    +----------------+
//                        V    |
//                  +---+----+---+   +---+----+---+   +---+----+---+
//                  |   |    | + |<--|-+ |e7e6|   |<--|-+ |d2d4| + |
//                  +---+----+---+   +---+----+---+   +---+----+---+
//                  |   | 0  | +-|-->|   |    | +-|-->|   |    |   |
//                  +---+----+---+   +---+----+---+   +---+----+---+
//                        |    |
//                        |    |
//                        V    |
//                  +- -+----+---+   +---+----+---+   +---+----+---+
//                  |   |    | + |<--|-+ |c7c5|   |<--|-+ |d2d4| + |
//                  +---+----+---+   +---+----+---+   +---+----+---+
//                  |   | 1  | +-|-->|   |    | +-|-->|   | V  |   |
//                  +---+----+---+   +---+----+---+   +---+----+---+
//                                                          |    ^
//                                         +----------------+    |
//                                         |                     |
//                                         |    +----------------+
//                                         V    |
//                                   +---+----+---+   +---+----+---+
//                                   |   |    | + |<--|-+ |f2f4|   |
//                                   +---+----+---+   +---+----+---+
//                                   |   | 0  | +-|-->|   |    |   |
//                                   +---+----+---+   +---+----+---+

namespace db {

class Board;
class Annotation;
class MarkSet;
class Mark;

struct MoveNode
{
public:

	typedef mstl::vector<MoveNode*> Nodes;
	typedef Comment::LanguageSet LanguageSet;

	MoveNode(Move const& move);
	MoveNode(Board const& board, Move const& move);
	explicit MoveNode(MoveNode* node);
	explicit MoveNode(Annotation* set = 0);
	~MoveNode();

	bool atLineStart() const;
	bool atLineEnd() const;

	bool hasComment() const;
	bool hasVariation() const;
	bool hasAnnotation() const;
	bool hasMark() const;
	bool hasNote() const;
	bool hasSupplement() const;
	bool shouldHaveComment() const;
	bool shouldHaveNote() const;
	bool containsIllegalMoves() const;

	unsigned variationCount() const;
	unsigned variationNumber(MoveNode const* node) const;
	unsigned countHalfMoves() const;
	unsigned countNodes() const;
	unsigned countAnnotations() const;
	unsigned countMarks() const;
	unsigned countComments() const;
	unsigned countComments(mstl::string const& lang) const;
	unsigned countVariations() const;
	unsigned countSequence() const;

	Move& move();
	Move const& move() const;
	MoveNode* next() const;
	MoveNode* prev() const;
	MoveNode* variation(unsigned i) const;
	Nodes const& variations() const;
	Annotation const& annotation() const;
	MarkSet const& marks() const;
	Comment const& comment() const;
	move::Constraint constraint() const;

	void setComment();
	void setMark();

	void setMove(Board const& board, Move const& move);
	void setNext(MoveNode* next);
	void addVariation(MoveNode* variation);
	void addAnnotation(nag::ID nag);
	void addMark(Mark const& mark);
	void setAnnotation(Annotation const& annotation);
	void swapMarks(MarkSet& marks);
	void setMarks(MarkSet const& marks);
	void replaceMarks(MarkSet const& marks);
	void swapComment(Comment& comment);
	void swapComment(mstl::string& str);
	void setComment(mstl::string const& str);
	void swapVariations(unsigned varNo1, unsigned varNo2);
	void prepareForSan(Board const& board);
	void transpose();
	void finish(Board const& board);

	void deleteNext();
	void deleteVariation(unsigned varNo);
	void clearAnnotation();
	void swapData(MoveNode* node);

	void stripAnnotations();
	void stripMarks();
	void stripComments();
	void stripComments(mstl::string const& lang);
	void stripVariations();

	uint64_t computeChecksum(uint64_t crc = 0) const;
	void collectLanguages(LanguageSet& langSet) const;

	MoveNode* removeNext();
	MoveNode* removeVariation(unsigned varNo);
	MoveNode* replaceVariation(unsigned varNo, MoveNode* node);

	MoveNode* clone() const;

private:

	enum
	{
		HasComment		= 1 << 0,
		HasMark			= 1 << 1,
		HasAnnotation	= 1 << 2,
		HasVariation	= 1 << 3,
		IsPrepared		= 1 << 4,
		HasNote			= HasComment | HasMark | HasAnnotation,
		HasSupplement	= HasNote | HasVariation,
	};

	MoveNode(MoveNode const&);
	MoveNode& operator=(MoveNode const&);

	MoveNode* clone(MoveNode* prev) const;

	void setupAnnotation(Annotation const& annotation);

	bool checkHasMark() const;
	bool checkHasAnnotation() const;

	unsigned			m_flags;
	MoveNode*		m_next;
	MoveNode*		m_prev;
	Nodes				m_variations;
	Annotation*		m_annotation;
	MarkSet*			m_marks;
	Move				m_move;
	Comment			m_comment;
};

} // namespace db

#include "db_move_node.ipp"

#endif // _db_move_node_included

// vi:set ts=3 sw=3:
