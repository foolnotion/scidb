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
// Copyright: (C) 2009-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "db_game.h"
#include "db_game_info.h"
#include "db_move_node.h"
#include "db_move_list.h"
#include "db_annotation.h"
#include "db_mark_set.h"
#include "db_eco_table.h"
#include "db_home_pawns.h"
#include "db_edit_node.h"
#include "db_exception.h"

#include "sys_utf8_codec.h"

#include "u_crc.h"

#include "m_string.h"
#include "m_vector.h"
#include "m_list.h"
#include "m_stack.h"
#include "m_hash.h"
#include "m_utility.h"
#include "m_limits.h"
#include "m_auto_ptr.h"
#include "m_stdio.h"
#include "m_assert.h"

#include <string.h>
#include <stdlib.h>
#include <ctype.h>

using namespace db;


#ifdef DB_DEBUG_GAME
# define BEGIN_BACKUP	beginBackup();
# define END_BACKUP		endBackup();
#else
# define BEGIN_BACKUP
# define END_BACKUP
#endif


namespace {

struct Position
{
	Position() :m_count(1) {}
	Position(board::ExactZHPosition const& board) :m_board(board), m_count(1) {}

	board::ExactZHPosition m_board;
	unsigned m_count;
};

typedef mstl::list<Position> PositionBucket;
typedef mstl::hash<uint64_t,PositionBucket> RepetitionMap;
typedef mstl::vector<MoveNode*> Variant;
typedef mstl::list<Variant> Variants;
typedef mstl::vector<int16_t> Moves;

}


static void
checkThreefoldRepetitions(	Board board,
									RepetitionMap map,
									variant::Type variant,
									MoveNode* node,
#ifdef CASTLING_RIGHTS_CHANGED_TEMPORARILY
									castling::Rights currentCastlingRights,
#endif
									bool haveRepetition)
{
	while (true)
	{
		M_ASSERT(node);

		if (node->atLineEnd())
			return;

		if (!node->atLineStart())
		{
			board.doMove(node->move(), variant);

			PositionBucket& bucket = map[board.hash()];
			bool flag = false;

			PositionBucket::iterator i = bucket.begin();
			PositionBucket::iterator e = bucket.end();

			while (i != e && i->m_board != board.exactZHPosition())
				++i;

			if (i == e)
				bucket.push_back(board.exactZHPosition());
			else if (++i->m_count == 3)
				flag = true;

#ifdef CASTLING_RIGHTS_CHANGED_TEMPORARILY
			// Positions ... are considered the same, if the same player has the
			// move, pieces of the same kind and colour occupy the same squares,
			// and the possible moves of all the pieces of both players are the
			// same.
			//
			// Positions are not the same if a pawn that could have been captured
			// en passant can no longer be captured in this manner. When a king or
			// a rook is forced to move, it will lose its castling rights, if any,
			// only after it is moved.
			//
			// (FIDE 2008, Article 9.2)
			if (currentCastlingRights != board.currentCastlingRights())
			{
				for (i = bucket.begin(), e = bucket.end(); i != e; ++i)
					i->m_count = 1;

				flag = false;
			}
#endif

			node->setThreefoldRepetition(flag && !haveRepetition);
			node->setFiftyMoveRule(board.halfMoveClock() == 100);

			if (flag)
				haveRepetition = true;
		}

		node = node->next();
	}
}


static void
checkThreefoldRepetitions(Board const& startBoard, variant::Type variant, MoveNode* node)
{
	checkThreefoldRepetitions(	startBoard,
										RepetitionMap(),
										variant,
										node,
#ifdef CASTLING_RIGHTS_CHANGED_TEMPORARILY
										startBoard.currentCastlingRights(),
#endif
										false);
}


static void
updateMoveNumbers(MoveNode* node, unsigned moveNumber)
{
	if (node->atLineStart())
		node = node->next();

	for ( ; !node->atLineEnd(); node = node->next())
	{
		if (node->hasVariation())
		{
			for (unsigned i = 0; i < node->variationCount(); ++i)
				updateMoveNumbers(node->variation(i)->next(), moveNumber);
		}

		node->setMoveNumber(moveNumber);

		if (color::isBlack(node->move().color()))
			++moveNumber;
	}
}


static void
collectMergeResults(	MoveNode* node,
							Board board,
							variant::Type variant,
							edit::Key& key,
							Game::MergeResults& mergeResults)
{
	M_ASSERT(node->atLineStart());

	edit::Key startKey;
	bool newMoves(false);

	key.exchangePly(board.plyNumber());

	for (node = node->next(); !node->atLineEnd(); node = node->next())
	{
		key.incrementPly();

		if (node->testFlag(MoveNode::MoveHasChanged))
		{
			mergeResults.push_back(Game::MergeResult(key.id(), key.id()));
		}
		else if (node->testFlag(MoveNode::NewMoves))
		{
			startKey = key;
			newMoves = true;
		}

		if (node->hasVariation())
		{
			for (unsigned i = 0; i < node->variationCount(); ++i)
			{
				key.addVariation(i);
				key.addPly(board.plyNumber());

				MoveNode* var = node->variation(i);

				if (var->testFlag(MoveNode::NewVariation))
				{
					edit::Key lastKey(key);
					lastKey.incrementPly(var->countHalfMoves() + 1);
					mergeResults.push_back(Game::MergeResult(key.id(), lastKey.id()));
				}
				else
				{
					collectMergeResults(var, board, variant, key, mergeResults);
				}

				key.removePly();
				key.removeVariation();
			}
		}

		board.doMove(node->move(), variant);
	}

	if (newMoves)
	{
		key.incrementPly();
		mergeResults.push_back(Game::MergeResult(startKey.id(), key.id()));
	}
}


static void
splitForMerge(	Variants& variants,
					MoveNode* startNode,
					variant::Type variant,
					unsigned variationDepth,
					Variant const* prev = 0)
{
	M_ASSERT(startNode);

	if (startNode->atLineStart())
		startNode = startNode->next();

	if (prev)
		variants.push_back(*prev);
	else
		variants.push_back();

	Variant& v = variants.back();

	for ( ; !startNode->atLineEnd(); startNode = startNode->next())
	{
		if (variationDepth > 0)
		{
			for (unsigned i = 0; i < startNode->variationCount(); ++i)
			{
				splitForMerge(	variants,
									startNode->variation(i)->next(),
									variant,
									variationDepth - 1,
									&v);
			}
		}

		v.push_back(startNode);
	}
}


static bool
mergeComments(MoveNode* dst, MoveNode const* src, MoveNode::LanguageSet const& leadingLanguageSet)
{
	M_ASSERT(dst);
	M_ASSERT(src);

	bool changed = false;

	for (unsigned i = 0; i < 2; ++i)
	{
		move::Position pos = i ? move::Post : move::Ante;

		Comment srcComment(src->comment(pos));

		if (!srcComment.isEmpty())
		{
			Comment dstComment(dst->comment(pos));
			dstComment.merge(srcComment, leadingLanguageSet);

			if (dstComment.content() != dst->comment(pos).content())
			{
				dst->setComment(dstComment, pos);
				dst->setFlag(MoveNode::ChangedComment);
				changed = true;
			}
		}
	}

	return changed;
}


static void
stripComments(MoveNode* node, MoveNode::LanguageSet const& languageSet)
{
	M_ASSERT(node);

	if (!languageSet.empty())
	{
		for (unsigned i = 0; i < 2; ++i)
		{
			move::Position pos = i ? move::Post : move::Ante;
			Comment comment(node->comment(pos));

			if (!comment.isEmpty())
			{
				comment.remove(languageSet);

				if (comment.content() != node->comment(pos).content())
				{
					node->setComment(comment, pos);
					node->setFlag(MoveNode::ChangedComment);
				}
			}
		}
	}
}


static MoveNode*
makeVariation(	MoveNode* const* first,
					MoveNode* const* last,
					MoveNode::LanguageSet const* leadingLanguageSet,
					TagSet const& tags,
					mstl::string const& delim,
					unsigned maximalLength)
{
	M_ASSERT(first < last);

	MoveNode* r = new MoveNode;
	MoveNode* n = r;

	for (unsigned count = 0; first != last && count < maximalLength; ++first, n = n->next(), ++count)
	{
		n->setNext((*first)->cloneThis());

		if (leadingLanguageSet)
			stripComments(n->next(), *leadingLanguageSet);
	}

	M_ASSERT((*(last - 1))->next());
	n->setNext((*(last - 1))->next()->cloneThis());

	if (	!delim.empty()
		&& !tags.isEmpty()
		&& (tags.value(tag::White).size() > 1 || tags.value(tag::Black).size() > 1))
	{
		mstl::string s;

		s.append(tags.value(tag::White));

		if (tags.contains(tag::WhiteElo))
			s.format(" (%u)", unsigned(tags.asInt(tag::WhiteElo)));

		s.append(" - ", 3);
		s.append(tags.value(tag::Black));

		if (tags.contains(tag::BlackElo))
			s.format(" (%u)", unsigned(tags.asInt(tag::BlackElo)));

		if (tags.value(tag::Event).size() > 1)
		{
			s.append(delim);
			s.append(tags.value(tag::Event));

			if (tags.contains(tag::Round))
			{
				s.append(" (");
				s.append(tags.value(tag::Round));
				s.append(')');
			}
		}

		if (tags.value(tag::Site).size() > 1)
		{
			s.append(delim);
			s.append(tags.value(tag::Site));
		}

		Date date(tags.value(tag::Date));
		if (date)
			s.format(" %u", date.year());

		if (tags.value(tag::Result) != "*")
		{
			s.append(delim);
			s.append(tags.value(tag::Result));

			if (first != last)
				s.format(" (%u)", (*(last - 1))->moveNumber());
		}

		Comment c1(n->comment(move::Post));
		Comment c2(s, false, false);

		c1.append(c2, '\n');
		c1.normalize();
		n->setComment(c1, move::Post);
	}

	return r;
}


static bool
merge(MoveNode* node,
		MoveNode* const* first,
		MoveNode* const* last,
		MoveNode::LanguageSet const* leadingLanguageSet,
		TagSet const& tags,
		mstl::string const& delim,
		unsigned maximalVariationLength,
		bool append)
{
	M_ASSERT(node);
	M_ASSERT(first);
	M_ASSERT(last);

	bool changed = false;

	if (node->atLineStart())
	{
		MoveNode* n = (*first)->prev();

		if (n && n->atLineStart())
		{
			if (leadingLanguageSet)
			{
				if (mergeComments(node, n, *leadingLanguageSet))
					changed = true;
			}
			else if (*node != *n)
			{
				node->copyData(n);
				changed = true;
			}
		}

		node = node->next();
	}

	while (node->move() == (*first)->move())
	{
		if (leadingLanguageSet && mergeComments(node, *first, *leadingLanguageSet))
			changed = true;

		if ((node = node->next())->atLineEnd())
		{
			if (last - first > 1)
			{
				MoveNode* prev = node->prev();

				for (unsigned i = 0; i < prev->variationCount(); ++i)
				{
					if (prev->variation(i)->next()->move() == (*first)->move())
					{
						return merge(	prev->variation(i),
											first,
											last,
											leadingLanguageSet,
											tags,
											delim,
											maximalVariationLength,
											append);
					}
				}

				if (append)
				{
					MoveNode* end			= prev->removeNext();
					MoveNode* variation	= makeVariation(	first + 1,
																		last,
																		leadingLanguageSet,
																		tags,
																		delim,
																		maximalVariationLength);

					prev->setNext(variation->removeNext());
					prev->next()->setFlag(MoveNode::NewMoves);
					prev = prev->getLineEnd()->prev();

					if (leadingLanguageSet && mergeComments(end, prev->next(), *leadingLanguageSet))
						changed = true;

					prev->deleteNext();
					prev->setNext(end);
					delete variation;
				}
				else
				{
					MoveNode* variation = makeVariation(first,
																	last,
																	leadingLanguageSet,
																	tags,
																	delim,
																	maximalVariationLength);
					prev->addVariation(variation);
					variation->setFlag(MoveNode::NewVariation);
				}

				changed = true;
			}

			return changed;
		}

		if (++first == last)
			return changed;
	}

	for (unsigned i = 0; i < node->variationCount(); ++i)
	{
		MoveNode* n = node->variation(i);

		if (n->next()->move() == (*first)->move())
			return merge(n, first, last, leadingLanguageSet, tags, delim, maximalVariationLength, append);
	}

	if (first < last)
	{
		MoveNode* prev = node->prev();

		MoveNode* variation = makeVariation(first,
														last,
														leadingLanguageSet,
														tags,
														delim,
														maximalVariationLength);

		if (node->atLineEnd())
		{
			prev->deleteNext();
			prev->setNext(variation->removeNext());
			prev->next()->setFlag(MoveNode::NewMoves);
			delete variation;
		}
		else
		{
			node->addVariation(variation);
			variation->setFlag(MoveNode::NewVariation);
		}

		changed = true;
	}

	return changed;
}


static int
compMoveIndex(void const* lhs, void const* rhs)
{
	return *static_cast<Moves::value_type const*>(lhs) - *static_cast<Moves::value_type const*>(rhs);
}


static bool
matchTransposition(Variant& v, Variant const& source, unsigned first, unsigned last)
{
	Moves m1;
	Moves m2;

	m1.reserve(mstl::div2(last - first + 1));
	m2.reserve(m1.size());

	for (unsigned i = first; i < last; i += 2)
	{
		m1.push_back(v[i]->move().index());
		m2.push_back(source[i]->move().index());
	}

	qsort(m1.begin(), m1.size(), sizeof(Moves::value_type), compMoveIndex);
	qsort(m2.begin(), m2.size(), sizeof(Moves::value_type), compMoveIndex);

	if (memcmp(m1.begin(), m2.begin(), m1.size()*sizeof(Moves::value_type)) != 0)
		return false;

	m1.clear();
	m2.clear();

	for (unsigned i = first + 1; i < last; i += 2)
	{
		m1.push_back(v[i]->move().index());
		m2.push_back(source[i]->move().index());
	}

	qsort(m1.begin(), m1.size(), sizeof(Moves::value_type), compMoveIndex);
	qsort(m2.begin(), m2.size(), sizeof(Moves::value_type), compMoveIndex);

	return memcmp(m1.begin(), m2.begin(), m1.size()*sizeof(Moves::value_type)) == 0;
}


static unsigned
transpose(Variant& v, Variant const& source)
{
	unsigned i = 0;
	unsigned max = mstl::min(v.size(), source.size());

	while (i < max)
	{
		while (i < max && v[i]->move().index() == source[i]->move().index())
			++i;

		if (i < max)
		{
			unsigned k = i;
			unsigned hash1 = 0;
			unsigned hash2 = 0;
			unsigned h1;
			unsigned h2;

			while (k < max && (h1 = v[k]->move().index()) != (h2 = source[k]->move().index()))
			{
				hash1 ^= h1;
				hash2 ^= h2;
				++k;
			}

			if (	hash1 != hash2
				|| (k < max && (v[k]->move().isEnPassant() || source[k]->move().isEnPassant()))
				|| !::matchTransposition(v, source, i, k))
			{
				return i;
			}

			for ( ; i < k; ++i)
				v[i] = source[i];
		}
	}

	return i;
}


static void
transpose(Variant& variant, Variants const& source)
{
	Variants::const_iterator bestVariant;
	unsigned maxlen = 0;

	for (Variants::const_iterator i = source.begin(); i != source.end(); ++i)
	{
		Variant	v(variant);
		unsigned	len(transpose(v, *i));

		if (len > maxlen)
		{
			bestVariant = i;
			maxlen = len;
		}
	}

	if (maxlen > 0)
		transpose(variant, *bestVariant);
}


namespace {

struct UndoApplyWatcher
{
	typedef Game::Command Command;

	Command& m_var;

	UndoApplyWatcher(Command& var, Command command)
		:m_var(var)
	{
		M_ASSERT(var == Game::None);
		m_var = command;
	}

	~UndoApplyWatcher()
	{
		m_var = Game::None;
	}
};

} // namespace


Game::EditorOptions::EditorOptions()
	:m_linebreakThreshold(0)
	,m_linebreakMaxLineLengthMain(0)
	,m_linebreakMaxLineLengthVar(0)
	,m_linebreakMinCommentLength(0)
	,m_displayStyle(display::CompactStyle)
	,m_moveInfoTypes(unsigned(-1))
	,m_moveStyle(move::ShortAlgebraic)
{
}


unsigned Game::m_gameId = 0;
mstl::string Game::m_delim(" / ", 3);


Game::Subscriber::~Subscriber() throw() {}
bool Game::Subscriber::mainlineOnly() { return false; }


struct Game::Undo
{
	typedef UndoAction Action;
	typedef mstl::auto_ptr<MoveNode> Node;

	Undo();
	~Undo();

	void apply(Game& game);
	void clear();

	Action			action;
	Command			command;
	edit::Key		key;
	Node				node;
	Comment*			comment;
	move::Position	position;
	MarkSet*			marks;
	Annotation*		annotation;
	unsigned			varNo;
	unsigned			varNo2;
	Board				board;
};


Game::Undo::Undo()
	:command(None)
	,comment(0)
	,position(move::Post)
	,marks(0)
	,annotation(0)
	,varNo(0)
	,varNo2(0)
	,board(Board::emptyBoard())
{
}


Game::Undo::~Undo()
{
	delete comment;
	delete marks;
	delete annotation;
}


void
Game::Undo::clear()
{
	node.reset();
	key.clear();
	command = None;
	board = Board::emptyBoard();

	delete comment;
	delete marks;
	delete annotation;

	comment = 0;
	marks = 0;
	annotation = 0;
}


Game::Game()
	:Provider(format::Scidb)
	,GameData()
	,m_id(m_gameId++)
	,m_currentNode(m_startNode)
	,m_editNode(0)
	,m_currentBoard(m_startBoard)
	,m_undoIndex(0)
	,m_maxUndoLevel(0)
	,m_combinePredecessingMoves(0)
	,m_undoCommand(None)
	,m_redoCommand(None)
	,m_rollbackCommand(None)
	,m_flags(0)
	,m_isIrreversible(false)
	,m_isModified(false)
	,m_wasModified(false)
	,m_threefoldRepetionDetected(false)
	,m_termination(termination::None)
	,m_line(m_lineBuf[0])
	,m_changed(false)
#ifdef DB_DEBUG_GAME
	,m_backupNode(0)
#endif
{
}


Game::Game(Game const& game)
	:Provider(format::Scidb)
	,GameData()
	,m_editNode(0)
	,m_line(m_lineBuf[0])
#ifdef DB_DEBUG_GAME
	,m_backupNode(0)
#endif
{
	*this = game;
	m_tags = game.m_tags;
	m_engines = game.m_engines;
}


Game::~Game() throw()
{
	delete m_editNode;

#ifdef DB_DEBUG_GAME
	delete m_backupNode;
#endif

	for (unsigned i = 0; i < m_undoList.size(); ++i)
		delete m_undoList[i];
}


Game&
Game::operator=(Game const& game)
{
	if (this != &game)
	{
		delete m_startNode;
		delete m_editNode;

		m_startNode							= game.m_startNode ? game.m_startNode->clone() : 0;
		m_startBoard						= game.m_startBoard;
		m_currentBoard						= game.m_startBoard;
		m_finalBoard						= game.m_finalBoard;
		m_currentNode						= m_startNode;
		m_editNode							= 0;
		m_currentKey						= edit::Key(game.m_startBoard.plyNumber());
		m_previousKey						= edit::Key();
		m_variant							= game.m_variant;
		m_tags								= game.m_tags;
		m_idn									= game.m_idn;
		m_eco									= game.m_eco;
		m_engines							= game.m_engines;
		m_languageSet						= game.m_languageSet;
		m_wantedLanguages					= game.m_wantedLanguages;
		m_isIrreversible					= false;
		m_isModified						= false;
		m_wasModified						= false;
		m_threefoldRepetionDetected	= game.m_threefoldRepetionDetected;
		m_termination						= game.m_termination;
		m_changed							= game.m_changed;
		m_undoIndex							= 0;
		m_maxUndoLevel						= game.m_maxUndoLevel;
		m_combinePredecessingMoves		= game.m_combinePredecessingMoves;
		m_undoCommand						= None;
		m_redoCommand						= None;
		m_rollbackCommand					= None;
		m_flags								= game.m_flags;
		m_editorOptions					= game.m_editorOptions;

#ifdef DB_DEBUG_GAME
		delete m_backupNode;
		m_backupNode = 0;
#endif

		m_line.copy(game.m_line);
		m_timeTable = game.m_timeTable;
		m_mergeResults.clear();

		if (m_subscriber && game.m_editNode)
			m_editNode = buildEditNodes();

		for (unsigned i = 0; i < m_undoList.size(); ++i)
			delete m_undoList[i];

		m_undoList.clear();
	}

	return *this;
}


Game::Undo&
Game::newUndo(UndoAction action, Command command)
{
	M_ASSERT(m_maxUndoLevel > 0);

	if (m_redoCommand != None)
	{
		M_ASSERT(m_undoIndex < m_undoList.size());
		++m_undoIndex;
	}
	else if (m_undoCommand == None)
	{
		if (m_undoIndex < m_undoList.size())
		{
			m_undoList.resize(++m_undoIndex);
		}
		else if (m_undoList.size() == m_maxUndoLevel)
		{
			Undo* undo = m_undoList.front();
			m_undoList.pop_front();
			m_undoList.push_back(undo);
			undo->clear();
			m_isIrreversible = true;
		}
		else
		{
			m_undoList.push_back(new Undo);
			++m_undoIndex;
		}
	}

	M_ASSERT(m_undoIndex > 0);
	M_ASSERT(m_undoList[m_undoIndex - 1]);

	Undo& undo = *m_undoList[m_undoIndex - 1];
	undo.action = action;
	undo.key = m_currentKey;

	if (m_undoCommand != None)
	{
		if (--m_undoIndex == 0 && !m_isIrreversible)
			m_isModified = false;
	}
	else if (m_redoCommand == None)
	{
		undo.command = command;
		m_isModified = true;
	}

	return undo;
}


Game::Undo*
Game::prevUndo(unsigned back)
{
	M_ASSERT(m_maxUndoLevel > 0);
	M_ASSERT(back > 0);

	if (m_undoCommand != None)
		return m_undoIndex + 1 - back < m_undoList.size() ? m_undoList[m_undoIndex - back] : 0;

	if (m_undoIndex < back)
		return 0;

	return m_undoList[m_undoIndex - back];
}


void
Game::insertUndo(UndoAction action, Command command)
{
	M_ASSERT(action == Unstrip_Moves || action == Truncate_Variation || action == Remove_Mainline);

	m_mergeResults.clear();

	if (m_rollbackCommand != None)
		return;

	if (m_maxUndoLevel)
	{
		Undo* prev = prevUndo();

		if (prev && prev->command == AddMove)
		{
			// Combine precedent AddMove's, in this way
			// we prevent a quick fill of the undo slots.

			Undo* pprev = prevUndo(2);

			if (	pprev
				&& (pprev->command == AddMove || pprev->command == AddMoves)
				&& pprev->key.level() == m_currentKey.level()
				&& unsigned(m_currentKey.computeDistance(pprev->key)) <= m_combinePredecessingMoves)
			{
				prev->key = m_currentKey;
				pprev->command = AddMoves;
				return;
			}
		}

		newUndo(action, command);
	}
	else
	{
		m_isIrreversible = true;
	}
}


void
Game::insertUndo(	UndoAction action,
						Command command,
						Comment const& oldComment,
						Comment const& newComment,
						move::Position position)
{
	M_ASSERT(action == Set_Annotation);

	m_mergeResults.clear();

	if (m_rollbackCommand != None)
		return;

	if (m_maxUndoLevel)
	{
		Undo* prev = prevUndo();

		if (	prev == 0
			|| prev->action != action
			|| prev->key != m_currentKey
			|| prev->position != position)
		{
			Undo& undo = newUndo(action, command);
			undo.comment = new Comment(oldComment);
			undo.position = position;
		}
		else if (prev->comment == 0)
		{
			prev->comment = new Comment(oldComment);
			prev->position = position;
		}
		else if (m_undoCommand != None)
		{
			Undo& undo = newUndo(action, command);
			undo.comment = new Comment(oldComment);
			undo.position = position;
		}
		else if (	prev->position == position
					&& *prev->comment == newComment
					&& (prev->annotation == 0 || *prev->annotation == m_currentNode->annotation())
					&& (prev->marks == 0 || *prev->marks == m_currentNode->marks()))
		{
			prev->clear();

			if (--m_undoIndex == 0 && !m_isIrreversible)
				m_isModified = false;
		}
	}
	else
	{
		m_isIrreversible = true;
	}
}


void
Game::insertUndo(	UndoAction action,
						Command command,
						Comment const& oldComment,
						Comment const& newComment)
{
	M_ASSERT(action == Set_Trailing_Comment);

	m_mergeResults.clear();

	if (m_rollbackCommand != None)
		return;

	if (m_maxUndoLevel)
	{
		Undo* prev = prevUndo();

		if (prev == 0 || prev->action != action)
		{
			Undo& undo = newUndo(action, command);
			undo.comment = new Comment(oldComment);
		}
		else if (prev->comment == 0)
		{
			prev->comment = new Comment(oldComment);
		}
		else if (m_undoCommand != None)
		{
			Undo& undo = newUndo(action, command);
			undo.comment = new Comment(oldComment);
		}
		else if (*prev->comment == newComment)
		{
			prev->clear();

			if (--m_undoIndex == 0 && !m_isIrreversible)
				m_isModified = false;
		}
	}
	else
	{
		m_isIrreversible = true;
	}
}


void
Game::insertUndo(UndoAction action, Command command, MarkSet const& oldMarks, MarkSet const& newMarks)
{
	M_ASSERT(action == Set_Annotation);

	m_mergeResults.clear();

	if (m_rollbackCommand != None)
		return;

	if (m_maxUndoLevel)
	{
		Undo* prev = prevUndo();

		if (prev == 0 || prev->action != action || prev->key != m_currentKey)
		{
			newUndo(action, command).marks = new MarkSet(oldMarks);
		}
		else if (prev->marks == 0)
		{
			prev->marks = new MarkSet(oldMarks);
		}
		else if (m_undoCommand != None)
		{
			newUndo(action, command).marks = new MarkSet(oldMarks);
		}
		else if (	*prev->marks == newMarks
					&& (prev->comment == 0 || *prev->comment == m_currentNode->comment(prev->position))
					&& (prev->annotation == 0 || *prev->annotation == m_currentNode->annotation()))
		{
			prev->clear();

			if (--m_undoIndex == 0 && !m_isIrreversible)
				m_isModified = false;
		}
	}
	else
	{
		m_isIrreversible = true;
	}
}


void
Game::insertUndo(	UndoAction action,
						Command command,
						Annotation const& oldAnnotation,
						Annotation const& newAnnotation)
{
	M_ASSERT(action == Set_Annotation);

	m_mergeResults.clear();

	if (m_rollbackCommand != None)
		return;

	if (m_maxUndoLevel)
	{
		Undo* prev = prevUndo();

		if (prev == 0 || prev->action != action || prev->key != m_currentKey)
		{
			newUndo(action, command).annotation = new Annotation(oldAnnotation);
		}
		else if (prev->annotation == 0)
		{
			prev->annotation = new Annotation(oldAnnotation);
		}
		else if (m_undoCommand != None)
		{
			newUndo(action, command).annotation = new Annotation(oldAnnotation);
		}
		else if (	*prev->annotation == newAnnotation
					&& (prev->comment == 0 || *prev->comment == m_currentNode->comment(prev->position))
					&& (prev->marks == 0 || *prev->marks == m_currentNode->marks()))
		{
			prev->clear();

			if (--m_undoIndex == 0 && !m_isIrreversible)
				m_isModified = false;
		}
	}
	else
	{
		m_isIrreversible = true;
	}
}


void
Game::insertUndo(UndoAction action, Command command, MoveNode* node)
{
	M_ASSERT(action == Replace_Node || action == Revert_Game);

	m_mergeResults.clear();

	if (m_rollbackCommand != None)
		return;

	if (m_maxUndoLevel)
	{
		Undo* prev = prevUndo();

		if (prev == 0 || prev->command != command || command != StripComments)
			newUndo(action, command).node = node;
		else
			prev->node.reset(node);
	}
	else
	{
		m_isIrreversible = true;
		delete node;
	}
}


void
Game::insertUndo(UndoAction action, Command command, MoveNode* node, unsigned varNo)
{
	M_ASSERT(action == Insert_Variation || action == New_Mainline);

	m_mergeResults.clear();

	if (m_rollbackCommand != None)
		return;

	if (m_maxUndoLevel)
	{
		Undo& undo = newUndo(action, command);
		undo.node = node;
		undo.varNo = varNo;
	}
	else
	{
		m_isIrreversible = true;
		delete node;
	}
}


void
Game::insertUndo(UndoAction action, Command command, unsigned varNo)
{
	M_ASSERT(action == Remove_Variation);

	m_mergeResults.clear();

	if (m_rollbackCommand != None)
		return;

	if (m_maxUndoLevel)
		newUndo(action, command).varNo = varNo;
	else
		m_isIrreversible = true;
}


void
Game::insertUndo(UndoAction action, Command command, unsigned varNo1, unsigned varNo2)
{
	M_ASSERT(action == Swap_Variations || action == Promote_Variation);
	m_mergeResults.clear();


	if (m_rollbackCommand != None)
		return;

	if (m_maxUndoLevel)
	{
		Undo& undo = newUndo(action, command);
		undo.varNo = varNo1;
		undo.varNo2 = varNo2;
	}
	else
	{
		m_isIrreversible = true;
	}
}


void
Game::insertUndo(UndoAction action, Command command, MoveNode* node, Board const& board)
{
	M_ASSERT(action == Strip_Moves || action == Set_Start_Position);

	m_mergeResults.clear();

	if (m_rollbackCommand != None)
		return;

	if (m_maxUndoLevel)
	{
		Undo& undo = newUndo(action, command);
		undo.node = node;
		undo.board = board;
	}
	else
	{
		m_isIrreversible = true;
	}
}


Game::Command
Game::undoCommand() const
{
	return m_undoIndex == 0 ? None : m_undoList[m_undoIndex - 1]->command;
}


Game::Command
Game::redoCommand() const
{
	return m_undoIndex < m_undoList.size() ? m_undoList[m_undoIndex]->command : None;
}


void
Game::startUndoPoint(Command command)
{
	M_REQUIRE(rollbackCommand() == None);
	M_REQUIRE(command != None);

	if (m_maxUndoLevel)
		insertUndo(Revert_Game, command, m_startNode->clone());
	else
		m_isIrreversible = true;

	m_rollbackCommand = command;
}


void
Game::endUndoPoint(unsigned action)
{
	M_REQUIRE(rollbackCommand() != None);

	m_rollbackCommand = None;
	updateSubscriber(action);
}


void
Game::clearUndo()
{
	m_undoList.clear();
	m_undoIndex = 0;
	m_mergeResults.clear();
}


void
Game::applyUndo(Undo& undo, bool redo)
{
	m_mergeResults.clear();

	if (redo || undo.action != Set_Start_Position)
		tryMoveTo(undo.key);

	switch (undo.action)
	{
		case Replace_Node:			replaceNode(undo.node.release(), undo.command); break;
		case Truncate_Variation:	truncateVariation(move::Post); break;
		case Swap_Variations:		moveVariation(undo.varNo, undo.varNo2, undo.command); break;
		case Insert_Variation:		insertVariation(undo.node.release(), undo.varNo); break;
		case Promote_Variation:		promoteVariation(undo.varNo, undo.varNo2); break;
		case Remove_Variation:		removeVariation(undo.varNo); break;
		case Remove_Mainline:		removeMainline(); break;
		case New_Mainline:			newMainline(undo.node.release()); break;
		case Strip_Moves:				unstripMoves(undo.node.release(), undo.board, undo.key); break;
		case Unstrip_Moves:			stripMoves(move::Post); break;
		case Revert_Game:				revertGame(undo.node.release(), undo.command); break;
		case Set_Start_Position:	resetGame(undo.node.release(), undo.board, undo.key.id()); break;

		case Set_Annotation:
			{
				unsigned flags = UpdatePgn;

				if (undo.annotation)
				{
					Annotation annotation(*undo.annotation);
					insertUndo(Set_Annotation, SetAnnotation, m_currentNode->annotation(), annotation);
					m_currentNode->replaceAnnotation(annotation);
				}
				if (undo.comment)
				{
					Comment comment(*undo.comment);
					insertUndo(	Set_Annotation,
									SetAnnotation,
									m_currentNode->comment(undo.position),
									comment,
									undo.position);
					m_currentNode->swapComment(comment, undo.position);
					if (updateLanguageSet())
						flags |= UpdateLanguageSet;
				}
				if (undo.marks)
				{
					MarkSet marks(*undo.marks);
					insertUndo(Set_Annotation, SetAnnotation, m_currentNode->marks(), marks);
					m_currentNode->replaceMarks(marks);
				}

				updateSubscriber(flags);
			}
			break;

		case Set_Trailing_Comment:
			{
				unsigned flags = UpdatePgn;
				Comment comment(*undo.comment);
				insertUndo(	Set_Trailing_Comment,
								SetAnnotation,
								m_currentNode->getLineEnd()->comment(undo.position),
								comment);
				m_currentNode->getLineEnd()->swapComment(comment, undo.position);
				if (updateLanguageSet())
					flags |= UpdateLanguageSet;
				updateSubscriber(flags);
			}
			break;
	}

	if (!redo || undo.action != Set_Start_Position)
		tryMoveTo(undo.key);

	switch (int(undo.action))
	{
		case Promote_Variation:
		case Remove_Variation:
		case Insert_Variation:
			backward();
			break;
	}

	if (redo)
	{
		switch (int(undo.command))
		{
			case AddMove:
			case AddMoves:
			case ReplaceVariation:
				forward();
				break;
		}
	}

	goToCurrentMove();
}


void
Game::undo()
{
	M_REQUIRE(hasUndo());

	Undo& undo = *m_undoList[m_undoIndex - 1];
	UndoApplyWatcher watcher(m_undoCommand, undo.command);
	applyUndo(undo, false);
}


void
Game::redo()
{
	M_REQUIRE(hasRedo());

	Undo& redo = *m_undoList[m_undoIndex];
	UndoApplyWatcher watcher(m_redoCommand, redo.command);
	m_isModified = true;
	applyUndo(redo, true);
}


void Game::setGameFlags(unsigned flags)
{
	m_flags = flags & ~GameInfo::Flag_Special;
}


bool
Game::containsIllegalMoves() const
{
	return m_flags & GameInfo::Flag_Illegal_Move;
}


bool
Game::containsIllegalCastlings() const
{
	return m_flags & GameInfo::Flag_Illegal_Castling;
}


bool
Game::isEmpty() const
{
	return m_startNode->isEmptyLine();
}


variant::Type
Game::variant() const
{
	return m_variant;
}


uint16_t
Game::idn() const
{
	return m_idn;
}


bool
Game::atMainlineEnd() const
{
	return isMainline() && m_currentNode->isOneBeforeLineEnd();
}


bool
Game::atLineStart() const
{
	return m_currentNode->atLineStart();
}


bool
Game::atLineEnd() const
{
	return m_currentNode->isOneBeforeLineEnd();
}


bool
Game::isBeforeLineEnd() const
{
	return m_currentNode->next() && m_currentNode->next()->isBeforeLineEnd();
}


bool
Game::isFirstVariation() const
{
	if (m_currentKey.level() == 0)
		return false;

	MoveNode* node = m_currentNode;

	while (!node->atLineStart())
		node = node->prev();

	MoveNode*	prev	= node->prev();
	unsigned		n		= prev->variationNumber(node);

	while (n > 0 && prev->variation(n - 1)->isEmptyLine())
		--n;

	return n == 0;
}


bool
Game::isLastVariation() const
{
	if (m_currentKey.level() == 0)
		return true;

	MoveNode* node = m_currentNode;

	while (!node->atLineStart())
		node = node->prev();

	MoveNode*	prev	= node->prev();
	unsigned		n		= prev->variationNumber(node) + 1;

	while (n < prev->variationCount() && prev->variation(n)->isEmptyLine())
		++n;

	return n == prev->variationCount();
}


void
Game::updateFinalBoard()
{
	M_ASSERT(m_startNode->next());

	HomePawns hp;

	m_finalBoard = m_startBoard;
	m_threefoldRepetionDetected = false;

	for (MoveNode const* node = m_startNode->next(); node->isBeforeLineEnd(); node = node->next())
	{
		m_threefoldRepetionDetected = node->threefoldRepetition();
		m_finalBoard.doMove(node->move(), m_variant);
		hp.move(node->move());
	}

	m_finalBoard.signature().setHomePawns(hp.used(), hp.data());
}


Board const&
Game::getStartBoard() const
{
	return startBoard();
}


Board const&
Game::getFinalBoard() const
{
	return m_finalBoard;
}


Move const&
Game::currentMove() const
{
	return m_currentNode->move();
}


Move const&
Game::nextMove() const
{
	return isBeforeLineEnd() ? m_currentNode->next()->move() : Move::empty();
}


Move const&
Game::nextMove(unsigned varno) const
{
	if (!isBeforeLineEnd() || varno >= m_currentNode->next()->variationCount())
		return Move::empty();

	return m_currentNode->next()->variation(varno)->next()->move();
}


mstl::string
Game::startKey() const
{
	return edit::Key(m_startBoard.plyNumber()).id();
}


mstl::string
Game::successorKey() const
{
	return m_currentKey.successorKey(m_currentNode).id();
}


mstl::string
Game::nextKey(mstl::string const& key) const
{
	edit::Key k(key);
	return k.nextKey(k.findPosition(m_startNode, m_startBoard.plyNumber())).id();
}


Comment const&
Game::comment(move::Position position) const
{
	return m_currentNode->comment(position);
}


Comment const&
Game::trailingComment() const
{
	return m_currentNode->getLineEnd()->comment(move::Post);
}


mstl::string&
Game::infix(mstl::string& result) const
{
	return m_currentNode->annotation().infix(result);
}


mstl::string&
Game::prefix(mstl::string& result) const
{
	return m_currentNode->annotation().prefix(result);
}


mstl::string&
Game::suffix(mstl::string& result) const
{
	return m_currentNode->annotation().suffix(result);
}


MarkSet const&
Game::marks() const
{
	return m_currentNode->marks();
}


MarkSet const&
Game::marks(edit::Key const& key) const
{
	M_REQUIRE(isValidKey(key));

	MoveNode* node = key.findPosition(m_startNode, m_startBoard.plyNumber());

	M_ASSERT(node);
	return node->marks();
}


void
Game::printMove(	Board const& board,
						Move const& move,
						mstl::string& result,
						move::Notation form,
						unsigned flags)
{
	M_REQUIRE(move.isPrintable());

	if (!move)
		return;

	// move number
	if (board.blackToMove())
	{
		if (flags & BlackNumbers)
		{
			result.format("%u", board.moveNumber());
			result.append("...", 3);

			if (flags & ExportFormat)
				result += ' ';
			else if (flags & UseZeroWidthSpace)
				result.append("\xe2\x80\x8B", 3);
			else if (!(flags & SuppressSpace))
				result += ' ';
		}
	}
	else
	{
		if (flags & WhiteNumbers)
		{
			result.format("%u", board.moveNumber());
			result += '.';

			if (flags & ExportFormat)
				result += ' ';
			else if (flags & UseZeroWidthSpace)
				result.append("\xe2\x80\x8B", 3);
			else if (!(flags & SuppressSpace))
				result += ' ';
		}
	}

	// move
	if (flags & ExportFormat)
		move.print(result, form, protocol::Standard, encoding::Latin1);
	else
		move.printForDisplay(result, form);
}


mstl::string&
Game::printMove(mstl::string& result, unsigned flags, move::Notation style) const
{
	printMove(m_currentBoard, m_currentNode->move(), result, style, flags);

	// annotation
	if (flags & IncludeAnnotation)
	{
		m_currentNode->annotation().print(
			result,
			flags & ExportFormat ? 0 : Annotation::Flag_Extended_Symbolic_Annotation_Style);
	}

	return result;
}


mstl::string
Game::getNextMove(unsigned flags)
{
	M_ASSERT(isBeforeLineEnd());

	mstl::string san;

	m_currentNode = m_currentNode->next();
	doMove();
	printMove(san, flags);
	undoMove();
	m_currentNode = m_currentNode->prev();

	return san;
}


void
Game::setComment(mstl::string const& comment, move::Position position)
{
	M_REQUIRE(position == move::Post || !atLineStart());

	Comment comm(comment, false, false);
	comm.normalize();

	if (comm != m_currentNode->comment(position))
	{
		insertUndo(Set_Annotation, SetAnnotation, m_currentNode->comment(position), comm, position);
		m_currentNode->setComment(comm, position);

		unsigned flags = UpdatePgn | UpdateBoard;

		if (updateLanguageSet())
			flags |= UpdateLanguageSet;

		updateSubscriber(flags);
	}
}


void
Game::setTrailingComment(mstl::string const& comment)
{
	Comment comm(comment, false, false);
	comm.normalize();

	MoveNode* node = m_currentNode->getLineEnd();

	if (comm != node->comment(move::Post))
	{
		insertUndo(Set_Trailing_Comment, SetAnnotation, node->comment(move::Post), comm);
		node->setComment(comm, move::Post);

		unsigned flags = UpdatePgn | UpdateBoard;

		if (updateLanguageSet())
			flags |= UpdateLanguageSet;

		updateSubscriber(flags);
	}
}


void
Game::setMarks(MarkSet const& marks)
{
	if (marks != m_currentNode->marks())
	{
		insertUndo(Set_Annotation, SetAnnotation, m_currentNode->marks(), marks);
		m_currentNode->replaceMarks(marks);

		if (m_subscriber)
		{
			mstl::string s;
			m_subscriber->updateMarks(m_currentNode->marks().print(s));
			updateSubscriber(UpdatePgn);
		}
	}
}


void
Game::setAnnotation(Annotation const& annotation)
{
	if (annotation == m_currentNode->annotation())
		return;

	insertUndo(Set_Annotation, SetAnnotation, m_currentNode->annotation(), annotation);
	m_currentNode->replaceAnnotation(annotation);
	updateSubscriber(UpdatePgn | UpdateBoard);
}


void
Game::doMove()
{
	m_currentBoard.doMove(m_currentNode->move(), m_variant);
	m_currentKey.exchangePly(m_currentBoard.plyNumber());
}


void
Game::undoMove()
{
	m_currentBoard.undoMove(m_currentNode->move(), m_variant);
	m_currentKey.exchangePly(m_currentBoard.plyNumber());
}


void
Game::tryMoveTo(edit::Key const& key)
{
	M_REQUIRE(isValidKey(key));

	edit::Key wantedKey(key);
	edit::Key currentKey(m_currentKey);

	moveToMainlineStart();

	if (!wantedKey.setPosition(*this))
		currentKey.setPosition(*this);
}


bool
Game::forward()
{
	if (atLineEnd())
		return false;

	M_ASSERT(isBeforeLineEnd());

	m_currentNode = m_currentNode->next();
	doMove();
	return true;
}


bool
Game::backward()
{
	if (atLineStart())
		return false;

	undoMove();
	m_currentNode = m_currentNode->prev();

	M_ASSERT(m_currentNode);

	return true;
}


unsigned
Game::forward(unsigned count)
{
	unsigned n = 0;

	while (n < count && forward())
		++n;

	return n;
}


unsigned
Game::backward(unsigned count)
{
	unsigned n = 0;

	while (n < count && backward())
		++n;

	return n;
}


void
Game::moveToStart()
{
	while (backward())
		;
}


void
Game::moveToEnd()
{
	while (forward())
		;
}


void
Game::moveToMainlineStart()
{
	m_currentKey.reset(m_startBoard.plyNumber());
	m_currentNode = m_startNode;
	m_currentBoard = m_startBoard;
}


void
Game::moveToMainlineEnd()
{
	if (!isMainline())
		moveToMainlineStart();

	moveToEnd();
}


void
Game::exitToMainline()
{
	while (isVariation())
		exitVariation();
}


void
Game::goToCurrentMove() const
{
	if (m_subscriber && m_previousKey != m_currentKey)
	{
		m_subscriber->boardSetup(m_currentBoard);
		m_subscriber->gotoMove(m_currentKey.id(), successorKey());
		m_previousKey = m_currentKey;
	}
}


void
Game::goToCurrentMove(bool forward) const
{
	M_ASSERT(forward || isBeforeLineEnd());

	if (m_subscriber)
	{
		Move move = forward ? m_currentNode->move() : m_currentNode->next()->move();

		m_subscriber->boardMove(m_currentBoard, move, forward);
		m_subscriber->gotoMove(m_currentKey.id(), successorKey());
		m_previousKey = m_currentKey;
	}
}


void
Game::goToPosition(mstl::string const& fen)
{
	Board position;
	position.setup(fen, m_variant);

	moveToMainlineStart();

	// TODO: also search in variations
	while (!atMainlineEnd() && !position.isEqualZHPosition(m_currentBoard))
		forward();

	goToCurrentMove();
}


void
Game::moveTo(edit::Key const& key)
{
	M_REQUIRE(isValidKey(key));

	edit::Key wantedKey(key);
	edit::Key currentKey(m_currentKey);

	moveToMainlineStart();

	if (!wantedKey.setPosition(*this))
	{
		currentKey.setPosition(*this);
		DB_RAISE("invalid key '%s'", key.id().c_str());
	}
}


void
Game::moveTo(mstl::string const& key)
{
	M_REQUIRE(edit::Key::isValid(key));
	moveTo(edit::Key(key));
}


void
Game::getMoves(StringList& result, unsigned flags, move::Notation form)
{
	result.clear();

	if (atLineEnd())
		return;

	forward();
	result.push_back();
	printMove(result.back(), flags, form);

	for (unsigned i = 0; i < m_currentNode->variationCount(); ++i)
	{
		enterVariation(i);

		if (isBeforeLineEnd())
		{
			forward();
			result.push_back();
			printMove(result.back(), flags);
		}

		exitVariation();
	}

	backward();
}


void
Game::getKeys(StringList& result)
{
	result.clear();

	if (atLineEnd())
		return;

	forward();
	result.push_back(m_currentKey.id());

	for (unsigned i = 0; i < m_currentNode->variationCount(); ++i)
	{
		enterVariation(i);

		if (isBeforeLineEnd())
		{
			forward();
			result.push_back(m_currentKey.id());
		}

		exitVariation();
	}

	backward();
}


unsigned
Game::variationCount() const
{
	return m_currentNode->variationCount();
}


unsigned
Game::subVariationCount() const
{
	return isBeforeLineEnd() ? m_currentNode->next()->variationCount() : 0;
}


unsigned
Game::countLength() const
{
	return m_startNode->countHalfMoves();
}


unsigned
Game::countHalfMoves() const
{
	return m_currentNode->countHalfMoves();
}


unsigned
Game::countHalfMoves(unsigned varNo) const
{
	M_REQUIRE(varNo < variationCount());
	return m_currentNode->variation(varNo)->countHalfMoves();
}


unsigned
Game::lengthOfCurrentLine() const
{
	return m_currentNode->getLineStart()->countHalfMoves();
}


unsigned
Game::countAnnotations() const
{
	return m_startNode->countAnnotations();
}


unsigned
Game::countMoveInfo() const
{
	return m_startNode->countMoveInfo();
}


unsigned
Game::countMoveInfo(unsigned moveInfoTypes) const
{
	return m_startNode->countMoveInfo(moveInfoTypes);
}


unsigned
Game::countMarks() const
{
	return m_startNode->countMarks();
}


unsigned
Game::countComments() const
{
	return m_startNode->countComments();
}


unsigned
Game::countVariations() const
{
	return m_startNode->countVariations();
}


unsigned
Game::variationNumber() const
{
	M_REQUIRE(isVariation());

	if (m_currentKey.level() == 0)
		return 0;

	MoveNode* node = m_currentNode->getLineStart();
	MoveNode* prev = node->prev();
	return prev->variationNumber(node);
}


unsigned
Game::plyCount() const
{
	return getFinalBoard().plyNumber() - m_startBoard.plyNumber();
}


unsigned
Game::plyNumber() const
{
	return m_currentBoard.plyNumber();
}


unsigned
Game::moveNumber() const
{
	return m_currentBoard.moveNumber();
}


void
Game::enterVariation(unsigned variationNumber)
{
	M_REQUIRE(variationNumber < variationCount());

	m_currentKey.addVariation(variationNumber);
	m_currentKey.addPly(m_currentBoard.plyNumber());
	undoMove();
	m_currentNode = m_currentNode->variation(variationNumber);
}


void
Game::exitVariation()
{
	M_REQUIRE(isVariation());

	moveToStart();
	m_currentNode = m_currentNode->prev();
	m_currentKey.removePly();
	m_currentKey.removeVariation();
	doMove();

	M_ASSERT(m_currentNode);
}


void
Game::goToMainlineStart()
{
	if (!atMainlineStart())
	{
		moveToMainlineStart();
		goToCurrentMove();
	}
}


void
Game::goToMainlineEnd()
{
	if (!atMainlineEnd())
	{
		moveToMainlineEnd();
		goToCurrentMove();
	}
}


void
Game::goToFirst()
{
	backward(mstl::numeric_limits<unsigned>::max());
	forward();
	goToCurrentMove();
}


void
Game::goToStart()
{
	backward(mstl::numeric_limits<unsigned>::max());
	goToCurrentMove();
}


void
Game::goToEnd()
{
	if (forward(mstl::numeric_limits<unsigned>::max()))
		goToCurrentMove();
}


void
Game::goTo(mstl::string const& key)
{
	moveTo(key);
	goToCurrentMove();
}


void
Game::goTo(edit::Key const& key)
{
	M_REQUIRE(isValidKey(key));

	moveTo(key);
	goToCurrentMove();
}


void
Game::goForward(unsigned count)
{
	if (forward(count))
	{
		if (count == 1)
			goToCurrentMove(true);
		else
			goToCurrentMove();
	}
}


void
Game::goBackward(unsigned count)
{
	if (count == 1)
	{
		if (backward(1))
			goToCurrentMove(false);
	}
	else if (backward(count))
	{
		goToCurrentMove();
	}
}


void
Game::goIntoVariation(unsigned variationNumber)
{
	M_REQUIRE(isBeforeLineEnd());

	forward();
	enterVariation(variationNumber);
	goToCurrentMove();
}


void
Game::goOutOfVariation()
{
	exitVariation();
	goToCurrentMove();
}


void
Game::goIntoNextVariation()
{
	if (m_currentKey.level() == 0 && atLineEnd())
		return;

	if (m_currentKey.level() == 0 && m_currentNode->next()->variationCount() == 0)
	{
		goForward();
	}
	else
	{
		unsigned n = 0;

		if (m_currentNode->isOneBeforeLineEnd())
		{
			if (m_currentKey.level() > 0)
			{
				MoveNode* node = m_currentNode;

				exitVariation();

				node = node->getLineStart();

				if (node->getLineStart()->prev() == m_currentNode)
					n = m_currentNode->variationNumber(node) + 1;
			}
		}
		else
		{
			forward();

			MoveNode* node = m_currentNode;

			if (node->variationCount() == 0)
			{
				if (m_currentKey.level() > 0)
					exitVariation();

				node = node->getLineStart();

				if (node->prev() == m_currentNode)
					n = m_currentNode->variationNumber(node) + 1;
			}
		}

		if (n < m_currentNode->variationCount())
		{
			enterVariation(n);
			forward();
		}

		goToCurrentMove();
	}
}


void
Game::goIntoPrevVariation()
{
	if (m_currentKey.level() == 0 && m_currentNode->atLineStart())
		return;

	if (m_currentKey.level() == 0)
	{
		goBackward();
	}
	else
	{
		backward();

		MoveNode*	node	= m_currentNode->getLineStart();
		unsigned		n		= 0;

		exitVariation();

		if (node->prev() == m_currentNode)
			n = m_currentNode->variationNumber(node);

		if (n > 0)
		{
			enterVariation(n - 1);
			forward();
		}

		goToCurrentMove();
	}
}


void
Game::goToMainline()
{
	MoveNode* node = m_currentNode;

	exitToMainline();

	if (node != m_currentNode)
		goToCurrentMove();
}


bool
Game::updateLanguageSet()
{
	LanguageSet set;
	m_startNode->collectLanguages(set);

	if (set == m_languageSet)
		return false;

	set.swap(m_languageSet);
	return true;
}


Move
Game::parseMove(mstl::string const& san) const
{
	Move move = m_currentBoard.parseMove(san, m_variant, move::AllowIllegalMove);

	if (!move)
	{
		Board			board	= m_currentBoard;
		color::ID	side	= board.sideToMove();

		board.tryCastleShort(side);
		board.tryCastleLong(side);

		move = board.parseMove(san, m_variant, move::AllowIllegalMove);
		move.setIllegalMove();
	}

	return move;
}


void
Game::replaceNode(MoveNode* newNode, Command command)
{
	M_ASSERT(newNode);

	BEGIN_BACKUP;

	bool truncate = m_currentNode->next()->isEmptyLine();

	if (truncate)
		insertUndo(Truncate_Variation, command);
	else
		insertUndo(Replace_Node, command, m_currentNode->removeNext());

	m_currentNode->setNext(newNode);

	END_BACKUP;

	unsigned flags = UpdatePgn | UpdateIllegalMoves | UpdateBoard;

	if (isMainline())
		flags |= UpdateOpening;

	updateSubscriber(flags);
}


void
Game::insertVariation(MoveNode* variation, unsigned number)
{
	M_ASSERT(variation);
	M_ASSERT(!atLineStart());
//	M_ASSERT(isBeforeLineEnd());

	BEGIN_BACKUP;

	mstl::auto_ptr<MoveNode> node(variation);

	insertUndo(Remove_Variation, RemoveVariation, number);

	node->fold(false);
	m_currentNode->addVariation(node.release());
	m_currentNode->swapVariations(number, m_currentNode->variationCount() - 1);

	END_BACKUP;

	unsigned flags = UpdatePgn | UpdateIllegalMoves | UpdateLanguageSet | UpdateBoard;

	if (isMainline())
		flags |= UpdateOpening;

	updateSubscriber(flags);
}


bool
Game::exchangeMove(Move move, Force flag)
{
	M_REQUIRE(isBeforeLineEnd());
	M_REQUIRE(currentBoard().checkMove(move, m_variant));

	if (move == m_currentNode->next()->move())
		return true;

	Board board(m_currentBoard);

	mstl::auto_ptr<MoveNode> node(m_currentNode->next()->clone());
	node->setMove(m_currentBoard, move, m_variant);

	if (!checkConsistency(node.get(), board, flag))
		return false;

	replaceNode(node.release(), ExchangeMove);

	return true;
}


bool
Game::exchangeMove(mstl::string const& san, Force flag)
{
	return exchangeMove(parseMove(san), flag);
}


void
Game::addMove(Move const& move)
{
	M_REQUIRE(atLineEnd());
	M_REQUIRE(m_currentBoard.checkMove(move, m_variant));

	insertUndo(Truncate_Variation, AddMove);

	MoveNode* node = new MoveNode(m_currentBoard, move, m_variant);
	node->setNext(m_currentNode->removeNext());
	m_currentNode->setNext(node);

	unsigned flags = UpdatePgn | UpdateBoard | UpdateIllegalMoves;

	if (isMainline())
		flags |= UpdateOpening;

	updateSubscriber(flags);
}


void
Game::addMove(mstl::string const& san)
{
	addMove(parseMove(san));
}


void
Game::addMoves(MoveNodeP node)
{
	M_REQUIRE(atLineEnd());
	M_REQUIRE(isValidVariation(node.get()));
	M_REQUIRE(node->atLineStart());
	M_REQUIRE(node->getLineEnd());

	if (node->countHalfMoves() == 0)
		return;

	BEGIN_BACKUP;

	insertUndo(Truncate_Variation, AddMoves);
	m_currentNode->setNext(node->removeNext());

	END_BACKUP;

	unsigned flags = UpdatePgn | UpdateBoard | UpdateIllegalMoves;

	if (isMainline())
		flags |= UpdateOpening;

	updateSubscriber(flags);
}


bool
Game::isValidKey(edit::Key const& key) const
{
	return key.findPosition(m_startNode, m_startBoard.plyNumber()) != 0;
}


bool
Game::isValidVariation(MoveNode const* node) const
{
	M_REQUIRE(node);
	M_REQUIRE(node->atLineStart());

	Board board(m_currentBoard);

	for (node = node->next(); node->isBeforeLineEnd(); node = node->next())
	{
		if (!board.isValidMove(node->move(), m_variant))
			return false;

		board.doMove(node->move(), m_variant);
	}

	return true;
}


bool
Game::isValidVariation(MoveList const& moves) const
{
	Board board(m_currentBoard);

	for (unsigned i = 0; i < moves.size(); ++i)
	{
		Move move = moves[i];

		if (!board.isValidMove(move, m_variant))
			return false;

		board.doMove(move, m_variant);
	}

	return true;
}


unsigned
Game::addVariation(MoveNodeP node)
{
	M_REQUIRE(node);
	M_REQUIRE(isBeforeLineEnd());
	M_REQUIRE(node->atLineStart());
	M_REQUIRE(node->getLineEnd());
	M_REQUIRE(node->countHalfMoves() > 0);
	M_REQUIRE(isValidVariation(node.get()));

	BEGIN_BACKUP;

	forward();
	insertUndo(Remove_Variation, AddVariation, m_currentNode->variationCount());
	backward();

	Board board(m_currentBoard);

	for (MoveNode* n = node->next(); n->isBeforeLineEnd(); n = n->next())
	{
		board.prepareUndo(n->move());
		board.prepareForPrint(n->move(), m_variant, Board::InternalRepresentation);
		board.doMove(n->move(), m_variant);
	}

	MoveNode* varNode = node.release();
	varNode->setFolded(false);
	m_currentNode->next()->addVariation(varNode);

	END_BACKUP;

	updateSubscriber(UpdatePgn | UpdateBoard);

	return m_currentNode->next()->variationCount() - 1;
}


unsigned
Game::addVariation(MoveList const& moves)
{
	M_REQUIRE(!moves.isEmpty());
	M_REQUIRE(isBeforeLineEnd());
	M_REQUIRE(isValidVariation(moves));

	Board			board(m_currentBoard);
	MoveNodeP	node(new MoveNode);
	MoveNode*	n(node.get());

	for (unsigned i = 0; i < moves.size(); ++i)
	{
		Move move = moves[i];

		n->setNext(new MoveNode(board, move, m_variant));
		board.doMove(move, m_variant);
		n = n->next();
	}

	n->setNext(new MoveNode);
	return addVariation(node);
}


unsigned
Game::addVariation(Move const& move)
{
	M_REQUIRE(isBeforeLineEnd());
	M_REQUIRE(currentBoard().checkMove(move, m_variant));

	MoveNode* node = new MoveNode(m_currentBoard, move, m_variant);
	node->setNext(new MoveNode);
	MoveNodeP var(new MoveNode(node));

	return addVariation(var);
}


unsigned
Game::addVariation(mstl::string const& san)
{
	return addVariation(parseMove(san));
}


void
Game::mergeVariation(Variation const& moves)
{
	BEGIN_BACKUP;

	mstl::auto_ptr<MoveNode> clone(m_startNode->clone());
	Board board(m_currentBoard);

	for (MoveNode* const* n = moves.begin(); n != moves.end(); ++n)
	{
		board.prepareUndo((*n)->move());
		board.prepareForPrint((*n)->move(), m_variant, Board::InternalRepresentation);
		board.doMove((*n)->move(), m_variant);
	}

	if (::merge(m_currentNode->next(),
					moves.begin(),
					moves.end(),
					nullptr,
					TagSet(),
					mstl::string::empty_string,
					unsigned(-1),
					false))
	{
		insertUndo(Revert_Game, Merge, clone.release());
	}

	END_BACKUP;

	updateSubscriber(UpdatePgn | UpdateBoard);
}


void
Game::mergeVariation(MoveNodeP node)
{
	M_REQUIRE(node);
	M_REQUIRE(isBeforeLineEnd());
	M_REQUIRE(node->atLineStart());
	M_REQUIRE(node->getLineEnd());
	M_REQUIRE(node->countHalfMoves() > 0);
	M_REQUIRE(isValidVariation(node.get()));

	mstl::vector<MoveNode*> nodes;
	nodes.reserve(node->countHalfMoves());

	for (MoveNode* n = node->next(); n->isBeforeLineEnd(); n = n->next())
		nodes.push_back(n);

	mergeVariation(nodes);
}


void
Game::mergeVariation(MoveList const& moves)
{
	M_REQUIRE(!moves.isEmpty());
	M_REQUIRE(isBeforeLineEnd());
	M_REQUIRE(isValidVariation(moves));

	Board board(m_currentBoard);
	mstl::vector<MoveNode*> nodes;
	MoveNodeP node(new MoveNode);
	MoveNode* n = node.get();

	nodes.reserve(moves.size());

	for (unsigned i = 0; i < moves.size(); ++i)
	{
		Move			move = moves[i];
		MoveNode*	node = new MoveNode(board, move, m_variant);

		n->setNext(node);
		n = n->next();
		nodes.push_back(node);
		board.doMove(move, m_variant);
	}

	n->setNext(new MoveNode);
	mergeVariation(nodes);
}


void
Game::mergeVariation(Move const& move)
{
	M_REQUIRE(isBeforeLineEnd());
	M_REQUIRE(currentBoard().checkMove(move, m_variant));

	MoveNodeP node(new MoveNode);
	node->setNext(new MoveNode(m_currentBoard, move, m_variant));
	node->next()->setNext(new MoveNode);
	mstl::vector<MoveNode*> nodes(1, node->next());
	return mergeVariation(nodes);
}


void
Game::mergeVariation(mstl::string const& san)
{
	return mergeVariation(parseMove(san));
}


void
Game::newMainline(MoveNode* node)
{
	M_REQUIRE(isBeforeLineEnd());

	BEGIN_BACKUP;

	edit::Key currentKey = m_currentKey;

	forward();
	insertUndo(Remove_Mainline, NewMainline);
	node->setFolded(false);
	m_currentNode->addVariation(node);
	unsigned varNo = m_currentNode->variationCount() - 1;
	promoteVariation(varNo, varNo, false);
	moveTo(currentKey);

	END_BACKUP;

	updateSubscriber(UpdateAll);
}


void
Game::newMainline(Move const& move)
{
	M_REQUIRE(isBeforeLineEnd());
	M_REQUIRE(currentBoard().checkMove(move, m_variant));

	MoveNode* node = new MoveNode(m_currentBoard, move, m_variant);
	node->setNext(new MoveNode);
	newMainline(new MoveNode(node));
}


void
Game::newMainline(mstl::string const& san)
{
	newMainline(parseMove(san));
}


void
Game::removeMainline()
{
	M_ASSERT(!atLineStart());
	M_ASSERT(m_currentNode->variationCount());

	BEGIN_BACKUP;

	unsigned varNo = m_currentNode->variationCount() - 1;
	promoteVariation(varNo, varNo, false);
	MoveNode* node = m_currentNode->removeVariation(varNo);

	backward();
	insertUndo(New_Mainline, NewMainline, node, varNo);
	forward();

	END_BACKUP;

	updateSubscriber(UpdateAll);
}


bool
Game::checkConsistency(MoveNode* node, Board& board, Force flag) const
{
	M_ASSERT(node);

	while (1)
	{
		if (node->atLineEnd())
			return true;

		M_ASSERT(node->move());

		node->move().setLegalMove(board.isValidMove(node->move(), m_variant, move::DontAllowIllegalMove));

		if (!board.isValidMove(node->move(), m_variant, node->constraint()))
		{
			if (flag == OnlyIfRemainsConsistent)
				return false;

			bool truncate = true;

			if (truncate)
			{
				MoveNode* last = node->getLineEnd();

				node = node->prev();
				node->deleteNext();
				node->setNext(new MoveNode);
				node->next()->setComment(last->comment(move::Post), move::Post);

				return true;
			}
		}

		for (unsigned i = 0; i < node->variationCount(); ++i)
		{
			M_ASSERT(node->variation(i)->next());

			if (node->variation(i)->isEmptyLine())
			{
				if (i-- > 0)
					node->swapVariations(i, node->variationCount() - 1);
				node->deleteVariation(node->variationCount() - 1);
			}
			else
			{
				Board b(board);

				if (!checkConsistency(node->variation(i)->next(), b, flag))
					return false;
			}
		}

		board.doMove(node->move(), m_variant);
		node = node->next();
	}

	return true; // shut up the compiler
}


void
Game::moveVariation(unsigned from, unsigned to, Command command)
{
	M_REQUIRE(from < variationCount());
	M_REQUIRE(to < variationCount());

	if (from == to)
		return;

	BEGIN_BACKUP;

	insertUndo(Swap_Variations, command, to, from);

	if (from < to)
	{
		for (unsigned i = from; i < to; ++i)
			m_currentNode->swapVariations(i, i + 1);
	}
	else
	{
		for (unsigned i = from; i > to; --i)
			m_currentNode->swapVariations(i, i - 1);
	}

	END_BACKUP;

	updateSubscriber(UpdatePgn | UpdateBoard);
}


void
Game::firstVariation(unsigned variationNumber)
{
	M_REQUIRE(variationNumber < variationCount());

	if (variationNumber > 0)
		moveVariation(variationNumber, 0, FirstVariation);
}


void
Game::promoteVariation(unsigned oldVariationNumber, unsigned newVariationNumber, bool update)
{
	M_ASSERT(oldVariationNumber < variationCount());
	M_ASSERT(newVariationNumber < variationCount());
	M_ASSERT(!m_currentNode->variation(oldVariationNumber)->isOneBeforeLineEnd());

	BEGIN_BACKUP;

	MoveNode* variation	= m_currentNode->removeVariation(oldVariationNumber);
	MoveNode* parent		= m_currentNode->prev();
	MoveNode* next			= variation->removeNext();

	M_ASSERT(parent);
	M_ASSERT(next);

	variation->setFolded(false);
	parent->removeNext();	// = m_currentNode
	parent->setNext(next);
	variation->setNext(m_currentNode);
	next->addVariation(variation);

	Comment comment;
	variation->swapComment(comment, move::Post);
	parent->getLineStart()->swapComment(comment, move::Post);
	variation->swapComment(comment, move::Post);

	while (m_currentNode->hasVariation())
		next->addVariation(m_currentNode->removeVariation(0));

	for (unsigned i = 1; i <= newVariationNumber; ++i)
		next->swapVariations(i - 1, i);

	moveTo(m_currentKey);

	END_BACKUP;

	if (update)
	{
		insertUndo(Promote_Variation, PromoteVariation, newVariationNumber, oldVariationNumber);

		unsigned flags = UpdatePgn | UpdateBoard;

		if (isMainline())
			flags |= UpdateOpening;

		updateSubscriber(flags);
	}
}


void
Game::promoteVariation(unsigned oldVariationNumber, unsigned newVariationNumber)
{
	M_REQUIRE(oldVariationNumber < variationCount());
	M_REQUIRE(newVariationNumber < variationCount());

	promoteVariation(oldVariationNumber, newVariationNumber, true);
}


void
Game::removeVariation(unsigned variationNumber)
{
	M_REQUIRE(variationNumber < variationCount());

	BEGIN_BACKUP;

	MoveNode* node = m_currentNode->removeVariation(variationNumber);
	node->setFolded(false);
	insertUndo(Insert_Variation, RemoveVariation, node, variationNumber);

	END_BACKUP;

	updateSubscriber(UpdatePgn | UpdateBoard | UpdateLanguageSet | UpdateIllegalMoves);
}


bool
Game::insertMoves(unsigned variationNumber, Force flag)
{
	M_REQUIRE(variationNumber < variationCount());
	M_ASSERT(!atLineStart());

	if (m_currentNode->variation(variationNumber)->countHalfMoves() == 0)
		return true;

	BEGIN_BACKUP;

	Board board(m_currentBoard);
	board.undoMove(m_currentNode->move(), m_variant);

	m_currentNode->variation(variationNumber)->setFolded(false);

	MoveNode* curr = m_currentNode->clone();
	MoveNode* root = curr->removeVariation(variationNumber);
	MoveNode* node = root->removeNext();

	delete root;
	node->getOneBeforeLineEnd()->setNext(curr);

	board = m_currentBoard;
	board.undoMove(m_currentNode->move(), m_variant);

	if (!checkConsistency(node, board, flag))
		return false;

	backward();
	insertUndo(Replace_Node, InsertMoves, m_currentNode->removeNext());
	m_currentNode->setNext(node);
	moveTo(m_currentKey);

	END_BACKUP;

	unsigned flags = UpdatePgn | UpdateBoard | UpdateIllegalMoves;

	if (isMainline())
		flags |= UpdateOpening;

	updateSubscriber(flags);
	return true;
}


bool
Game::exchangeMoves(unsigned variationNumber, unsigned movesToExchange, Force flag)
{
	M_REQUIRE(variationNumber < variationCount());
	M_ASSERT(!atLineStart());

	if (m_currentNode->variation(variationNumber)->countHalfMoves() == 0)
		return true;

	if (movesToExchange == 0)
		return insertMoves(variationNumber);

	BEGIN_BACKUP;

	Board board(m_currentBoard);
	board.undoMove(m_currentNode->move(), m_variant);

	MoveNode* curr = m_currentNode->clone();
	MoveNode* node = curr->removeVariation(variationNumber);
	MoveNode* last = node->getOneBeforeLineEnd();

	node->setFolded(false);

	MoveNode* tail = curr;

	for (unsigned i = 0, n = mstl::min(movesToExchange - 1, tail->countHalfMoves()); i < n; ++i)
		tail = tail->next();

	MoveNode* line = node->removeNext();

	last->setNext(tail->removeNext());
	tail->setNext(new MoveNode);
	node->setNext(curr);
	line->addVariation(node);

	board = m_currentBoard;
	board.undoMove(node->next()->move(), m_variant);

	if (!checkConsistency(line, board, flag))
		return false;

	backward();
	insertUndo(Replace_Node, ExchangeMoves, m_currentNode->removeNext());
	m_currentNode->setNext(line);
	moveTo(m_currentKey);

	END_BACKUP;

	unsigned flags = UpdatePgn | UpdateBoard | UpdateIllegalMoves;

	if (isMainline())
		flags |= UpdateOpening;

	updateSubscriber(flags);
	return true;
}


void
Game::truncateVariation(move::Position position)
{
	if (position == move::Ante)
		backward();

	if (atLineEnd())
		return;

	BEGIN_BACKUP;

	unsigned flags = UpdatePgn | UpdateIllegalMoves | UpdateLanguageSet;

	if (isMainline())
		flags |= UpdateOpening;
	if (position == move::Ante)
		flags |= UpdateBoard;

	if (atLineStart() && !isMainline())
	{
		MoveNode*	prev	= m_currentNode->prev();
		unsigned		n		= prev->variationNumber(m_currentNode);

		exitVariation();
		removeVariation(n);
		flags |= UpdateBoard;
	}
	else
	{
		MoveNode* node = m_currentNode->removeNext();
		insertUndo(Replace_Node, TruncateVariation, node);
		m_currentNode->setNext(node->getLineEnd()->clone());
	}

	END_BACKUP;

	updateSubscriber(flags);
}


void
Game::changeVariation(MoveNodeP node, unsigned variationNumber)
{
	M_REQUIRE(node);
	M_REQUIRE(isBeforeLineEnd());
	M_REQUIRE(isValidVariation(node.get()));
	M_REQUIRE(variationNumber < subVariationCount());

	Board board(m_currentBoard);

	BEGIN_BACKUP;

	for (MoveNode* n = node->next(); n->isBeforeLineEnd(); n = n->next())
	{
		board.prepareUndo(n->move());
		board.prepareForPrint(n->move(), m_variant, Board::InternalRepresentation);
		board.doMove(n->move(), m_variant);
	}

	MoveNode* varNode = node.release();
	varNode->setFolded(false);
	delete m_currentNode->next()->replaceVariation(variationNumber, varNode);

	END_BACKUP;

	updateSubscriber(UpdatePgn | UpdateBoard | UpdateIllegalMoves | UpdateLanguageSet);
}


void
Game::replaceVariation(Move const& move)
{
	M_REQUIRE(currentBoard().checkMove(move, m_variant));

	if (atLineEnd())
	{
		addMove(move);
	}
	else
	{
		MoveNode* node = new MoveNode(m_currentBoard, move, m_variant);
		node->setNext(new MoveNode);
		replaceNode(node, ReplaceVariation);
	}
}


void
Game::replaceVariation(mstl::string const& san)
{
	replaceVariation(parseMove(san));
}


bool
Game::stripMoves(move::Position position)
{
	M_REQUIRE(isMainline());

	if (position == move::Ante)
		backward();

	if (atLineStart())
		return false;

	BEGIN_BACKUP;

	insertUndo(Strip_Moves, StripMoves, m_startNode->removeNext(), m_startBoard);
	m_startNode->setNext(m_currentNode->removeNext());
	m_startBoard = m_currentBoard;
	moveTo(m_currentKey);

	END_BACKUP;

	unsigned flags = UpdatePgn | UpdateBoard | UpdateLanguageSet | UpdateIllegalMoves;

	if (isMainline())
		flags |= UpdateOpening;

	updateSubscriber(flags);
	return true;
}


void
Game::unstripMoves(MoveNode* startNode, Board const& startBoard, edit::Key const& key)
{
	BEGIN_BACKUP;

	MoveNode* last = startNode->getLineEnd();

	startNode->setFolded(false);
	last->setNext(m_startNode->removeNext());
	m_startNode->setNext(startNode);
	m_startBoard = startBoard;
	moveTo(key);
	insertUndo(Unstrip_Moves, StripMoves);

	END_BACKUP;

	unsigned flags = UpdatePgn | UpdateBoard | UpdateLanguageSet | UpdateIllegalMoves;

	if (key.isMainlineId())
		flags |= UpdateOpening;

	updateSubscriber(flags);
}


bool
Game::stripAnnotations()
{
	if (m_startNode->countAnnotations() == 0)
		return false;

	insertUndo(Revert_Game, StripAnnotations, m_startNode->clone());
	m_startNode->stripAnnotations();
	moveTo(m_currentKey);
	updateSubscriber(UpdatePgn | UpdateBoard);

	return true;
}


bool
Game::stripComments()
{
	if (m_startNode->countComments() == 0)
		return false;

	insertUndo(Revert_Game, StripComments, m_startNode->clone());
	m_startNode->stripComments();
	moveTo(m_currentKey);

	unsigned flags = UpdatePgn | UpdateBoard;

	if (updateLanguageSet())
		flags |= UpdateLanguageSet;

	updateSubscriber(flags);

	return true;
}


bool
Game::stripComments(mstl::string const& lang)
{
	if (m_startNode->countComments(lang) == 0)
		return false;

	insertUndo(Revert_Game, StripComments, m_startNode->clone());
	m_startNode->stripComments(lang);
	moveTo(m_currentKey);

	unsigned flags = UpdatePgn | UpdateBoard;

	if (updateLanguageSet())
		flags |= UpdateLanguageSet;

	updateSubscriber(flags);

	return true;
}


bool
Game::copyComments(mstl::string const& fromLang, mstl::string const& toLang, bool stripOriginal)
{
	if (m_startNode->countComments(fromLang) == 0)
		return false;

	insertUndo(Revert_Game, stripOriginal ? MoveComments : CopyComments, m_startNode->clone());
	m_startNode->copyComments(fromLang, toLang, stripOriginal);
	moveTo(m_currentKey);

	unsigned flags = UpdatePgn | UpdateBoard;

	if (updateLanguageSet())
		flags |= UpdateLanguageSet;

	updateSubscriber(flags);

	return true;
}


bool
Game::stripMoveInfo()
{
	if (m_startNode->countMoveInfo() == 0)
		return false;

	insertUndo(Revert_Game, StripMoveInfo, m_startNode->clone());
	m_startNode->stripMoveInfo();
	moveTo(m_currentKey);
	updateSubscriber(UpdatePgn);

	return true;
}


bool
Game::stripMarks()
{
	if (m_startNode->countMarks() == 0)
		return false;

	insertUndo(Revert_Game, StripMarks, m_startNode->clone());
	m_startNode->stripMarks();
	moveTo(m_currentKey);

	if (m_subscriber)
		m_subscriber->updateMarks(mstl::string::empty_string);

	updateSubscriber(UpdatePgn);
	return true;
}


bool
Game::stripVariations()
{
	M_REQUIRE(isMainline());

	if (m_startNode->countVariations() == 0)
		return false;

	BEGIN_BACKUP;

	insertUndo(Revert_Game, StripVariations, m_startNode->clone());
	m_startNode->stripVariations();
	moveTo(m_currentKey);

	END_BACKUP;

	updateSubscriber(UpdatePgn | UpdateBoard | UpdateLanguageSet | UpdateIllegalMoves);

	return true;
}


void
Game::revertGame(MoveNode* startNode, Command command)
{
	BEGIN_BACKUP;

	insertUndo(Revert_Game, command, m_startNode);
	m_startNode = startNode;
	startNode->setFolded(false);

	if (command == Transpose)
	{
		if (variant::isChess960(m_idn))
			m_idn = chess960::twin(m_idn);

		m_startBoard.transpose(m_variant);
	}

	moveTo(m_currentKey);

	END_BACKUP;

	updateLanguageSet();
	updateSubscriber(UpdateAll);
}


void
Game::resetGame(MoveNode* startNode, Board const& startBoard, edit::Key const&)
{
	Board board(m_startBoard);
	MoveNode* node(m_startNode);

	moveToMainlineStart();
	startNode->setFolded(false);
	m_startNode = startNode;
	m_startBoard = startBoard;
	m_previousKey.clear();
	insertUndo(Set_Start_Position, Clear, node, board);
	moveToMainlineStart();
	updateSubscriber(UpdateAll);
}


void
Game::clear(Board const* startPosition)
{
	moveToMainlineStart();

	if (!m_startNode->isEmptyLine())
	{
		insertUndo(Set_Start_Position, Clear, m_startNode, m_startBoard);
		m_startNode = m_currentNode = new MoveNode();
		m_startNode->setNext(new MoveNode);
	}

	if (startPosition)
		setup(*startPosition);

	m_previousKey.clear();
	updateSubscriber(UpdateAll);
}


void
Game::setup(Board const& startPosition)
{
	M_REQUIRE(isEmpty());

	m_startBoard = startPosition;

	if (variant::isAntichessExceptLosers(m_variant))
		m_startBoard.removeCastlingRights();

	m_currentBoard = m_startBoard;
	m_previousKey.clear();
}


void
Game::resetForNextLoad(variant::Type variant)
{
	delete m_startNode;
	delete m_editNode;

	m_variant = variant;
	m_startNode = m_currentNode = new MoveNode;
	m_startNode->setNext(new MoveNode);
	m_editNode = 0;
	m_currentKey.clear();
	m_previousKey.clear();
	m_undoList.clear();
	m_languageSet.clear();
	m_undoIndex = 0;
	m_idn = variant::Standard;
	m_isIrreversible = false;
	m_isModified = false;
	m_wasModified = false;
	m_startBoard = Board::standardBoard(m_variant);
	m_currentBoard = m_startBoard;
	m_finalBoard.clear();
	m_tags.clear();
	m_flags = 0;
	m_eco = Eco();
	m_line.length = 0;
	m_undoCommand = None;
	m_redoCommand = None;
}


util::crc::checksum_t
Game::computeChecksum(util::crc::checksum_t crc) const
{
	crc = util::crc::compute(
				crc,
				reinterpret_cast<unsigned char const*>(&m_startBoard.uniquePosition()),
				sizeof(board::UniquePosition));
	crc = m_startNode->computeChecksum(m_engines, crc);

	return crc;
}


util::crc::checksum_t
Game::computeChecksumOfMainline(util::crc::checksum_t crc) const
{
	crc = util::crc::compute(
				crc,
				reinterpret_cast<unsigned char const*>(&m_startBoard.uniquePosition()),
				sizeof(board::UniquePosition));
	crc = m_startNode->computeChecksumOfMainline(crc);

	return crc;
}


void
Game::setStartPosition(mstl::string const& fen)
{
	M_REQUIRE(isEmpty());

	Board board;

	if (!board.setup(fen, m_variant))
		DB_RAISE("invalid FEN");

	setup(board);
	moveToMainlineStart();

	M_DEBUG(m_startBoard.validate(m_variant, castling::AllowHandicap) == Board::Valid);
}


void
Game::setStartPosition(unsigned idn)
{
	M_REQUIRE(isEmpty());
	M_REQUIRE(idn <= 4*960);

	Board board;
	board.setup(idn, m_variant);
	setup(board);
	moveToMainlineStart();

	M_DEBUG(m_startBoard.validate(m_variant) == Board::Valid);
}


unsigned
Game::dumpMoves(mstl::string& result, unsigned length, unsigned flags)
{
	if (atLineEnd())
		return 0;

	unsigned n = 0;

	result.clear();

	while (length--)
	{
		if (m_currentNode->next()->atLineEnd())
			return n;

		m_currentNode = m_currentNode->next();
		printMove(result, flags | (result.empty() ? BlackNumbers : 0));
		m_currentNode = m_currentNode->prev();
		forward();
		result += ' ';
		++n;
	}

	result.rtrim();
	return n;
}


bool
Game::historyIsLegal(Constraint constraint) const
{
	Board board(m_currentBoard);

	MoveNode const* succ = m_currentNode->next();

	for (MoveNode const* node = m_currentNode; node; succ = node, node = node->prev())
	{
		if (!node->atLineStart() && !node->atLineEnd() && node->next() == succ)
		{
			if (!node->move().isLegal())
				return false;

			if (node->move().isNull() && constraint == DontAllowNullMoves)
				return false;

			board.undoMove(node->move(), m_variant);

			if (node->move().isCastling() && board.piece(node->move().castlingRookFrom()) != piece::Rook)
				return false; // handicap game - castling w/o rook
		}
	}

	return true;
}


unsigned
Game::dumpMoves(mstl::string& result, unsigned flags)
{
	return dumpMoves(result, mstl::numeric_limits<unsigned>::max(), flags);
}


void
Game::getHistory(History& result) const
{
	result.clear();
	result.reserve(100);

	MoveNode* succ = m_currentNode->next();

	for (MoveNode* node = m_currentNode; node; succ = node, node = node->prev())
	{
		if (!node->atLineStart() && !node->atLineEnd() && node->next() == succ)
			result.push_back(node->move());
	}
}


unsigned
Game::dumpHistory(mstl::string& result, protocol::ID protocol) const
{
	History hist;
	getHistory(hist);

	result.reserve(result.size() + hist.size()*6);

	for (int i = hist.size() - 1; i >= 0; i--)
	{
		if (!result.empty())
			result.append(' ');

		hist[i].printAlgebraic(result, protocol, encoding::Latin1);
	}

	return hist.size();
}


bool
Game::finishLoad(variant::Type variant, mstl::string const* fen)
{
	M_REQUIRE(atMainlineStart());
	M_REQUIRE(variant != variant::Undetermined);
	M_REQUIRE(variant != variant::Antichess);

	bool ok = true;

	m_variant = variant;
	m_idn = 0;

	if (fen)
		m_startBoard.setup(*fen, variant);

	if (variant::isAntichessExceptLosers(variant))
		m_startBoard.removeCastlingRights();

	Board	board(m_startBoard);

	if (!(ok = checkConsistency(m_startNode->next(), board, OnlyIfRemainsConsistent)))
		checkConsistency(m_startNode->next(), board, TruncateIfNeccessary);

	m_startNode->finish(m_startBoard, m_variant);
	m_currentBoard = m_startBoard;

	moveToMainlineStart();
	::checkThreefoldRepetitions(m_startBoard, m_variant, m_startNode);
	updateLine();
	updateLanguageSet();
//	m_wantedLanguages = m_languageSet;
	m_startNode->updateFromTimeTable(m_timeTable);
	m_previousKey.clear();

	return ok;
}


uint16_t
Game::currentLine(Line& result)
{
	// require: #result.moves >= opening::Max_Line_Length

	typedef mstl::vector<MoveNode const*> Path;

	Path path;
	path.reserve(100);

	if (!m_currentNode->atLineStart())
		path.push_back(m_currentNode);

	MoveNode const* prev = m_currentNode->prev();

	for (MoveNode const* next = m_currentNode; prev; next = prev, prev = prev->prev())
	{
		if (prev->next() == next && !prev->atLineStart())
			path.push_back(prev);
	}

	mstl::reverse(path.begin(), path.end());

	HomePawns	hp;
	unsigned		length = 0;

	for (Path::const_iterator i = path.begin(); i != path.end(); ++i)
	{
		MoveNode const* node = *i;

		if (length < opening::Max_Line_Length)
			const_cast<uint16_t*>(result.moves)[length++] = node->move().index();

		hp.move(node->move());
	}

	result.length = length;

	uint16_t hpsig;

	if (m_startBoard.isStartPosition())
	{
		m_currentBoard.signature().setHomePawns(hp.used(), hp.data());
		hpsig = hp.signature();
	}
	else
	{
		m_currentBoard.signature().setHomePawns(0, hp::Pawns());
		hpsig = 0;
	}

	return hpsig;
}


bool
Game::updateLine()
{
	if (!isMainline())
		return false;

	unsigned length = m_startNode->countHalfMoves();

	if (m_timeTable.size() > length)
		m_timeTable.cut(length);

	unsigned idn = m_startBoard.computeIdn(m_variant);

	bool update = m_idn != idn;

	if (idn && m_startBoard.isStartPosition())
	{
		uint16_t* lineBuf = m_line.moves == m_lineBuf[0] ? m_lineBuf[1] : m_lineBuf[0];

		unsigned	i = 0;

		for (	MoveNode const* node = m_startNode->next();
				node->isBeforeLineEnd() && !node->move().isNull() && i < opening::Max_Line_Length;
				node = node->next(), ++i)
		{
			lineBuf[i] = node->move().index();
		}

		Line line(lineBuf, i);

		if (m_variant == variant::Normal && idn == variant::Standard)
		{
			if (line != m_line || !m_eco)
			{
				EcoTable const& ecoTable = EcoTable::specimen(m_variant);
				Eco eco(m_eco);

				m_line = line;
				m_eco = ecoTable.getEco(m_line);

				ecoTable.lookup(m_line);

				if (m_eco != eco)
					update = true;
			}
		}
		else
		{
			m_eco = 0;
			m_line.length = 0;
		}
	}
	else
	{
		m_eco = 0;
		m_line.length = 0;
	}

	m_idn = idn;
	updateFinalBoard();

	unsigned state = m_finalBoard.checkState(m_variant);

	if (state & Board::Checkmate)
	{
		m_termination = termination::Checkmate;
	}
	else if (state & Board::Stalemate)
	{
		if (m_variant == variant::Suicide)
		{
			int totw = m_finalBoard.materialCount(color::White).total();
			int totb = m_finalBoard.materialCount(color::Black).total();

			m_termination = totw == totb ? termination::DrawnByStalemate : termination::HavingLessMaterial;
		}
		else
		{
			m_termination = termination::Stalemate;
		}
	}
	else if (state & Board::ThreeChecks)
	{
		m_termination = termination::GotThreeChecks;
	}
	else if (state & Board::Losing)
	{
		m_termination = termination::LostAllMaterial;
	}
	else if (m_threefoldRepetionDetected)
	{
		m_termination = termination::ThreefoldRepetition;
	}
	else if (m_finalBoard.halfMoveClock() >= 100)
	{
		m_termination = termination::FiftyMoveRuleExceeded;
	}
	else if (m_finalBoard.drawnDueToBishopsOfOppositeColors(m_variant))
	{
		m_termination = termination::BishopsOfOppositeColor;
	}
	else if (m_finalBoard.neitherPlayerHasMatingMaterial(m_variant))
	{
		m_termination = termination::NeitherPlayerHasMatingMaterial;
	}
	else if (m_finalBoard.cannotWin(color::White, m_variant))
	{
		m_termination = termination::WhiteCannotWin;
	}
	else if (m_finalBoard.cannotWin(color::Black, m_variant))
	{
		m_termination = termination::BlackCannotWin;
	}
	else
	{
		m_termination = termination::None;
	}

	return update;
}


Eco
Game::computeEcoCode() const
{
	if (m_idn != variant::Standard || m_variant != variant::Normal)
		return Eco();

	uint16_t lineBuf[opening::Max_Line_Length];

	unsigned	i = 0;

	for (	MoveNode const* node = m_startNode->next();
			node->isBeforeLineEnd() && i < opening::Max_Line_Length;
			node = node->next(), ++i)
	{
		lineBuf[i] = node->move().index();
	}

	Line line(lineBuf, i);
	return EcoTable::specimen(m_variant).getEco(m_line);
}


void
Game::setUndoLevel(unsigned level, unsigned combinePredecessingMoves)
{
	m_maxUndoLevel = level;
	m_combinePredecessingMoves = combinePredecessingMoves;

	if (m_undoList.size() > m_maxUndoLevel)
	{
		size_t n = m_undoList.size() - m_maxUndoLevel;
		size_t r = mstl::min(size_t(m_undoList.size() - m_undoIndex), n);
		size_t k = m_undoList.size() - r;

		// firstly erase redo's
		for (size_t i = k; i < m_undoList.size(); ++i)
			delete m_undoList[i];

		m_undoList.resize(k);
		n -= r;

		// secondly erase undo's
		for (size_t i = 0; i < n; ++i)
			delete m_undoList[i];

		m_undoList.erase(m_undoList.begin(), m_undoList.begin() + n);
		m_undoIndex = mstl::min(m_undoIndex, m_maxUndoLevel);
	}
}


bool
Game::transpose(Force flag)
{
	mstl::auto_ptr<MoveNode> root(m_startNode->clone());
	Board board(m_startBoard);

	root->transpose();
	board.transpose(m_variant);

	if (!checkConsistency(root.get()->next(), board, flag))
		return false;

	insertUndo(Revert_Game, Transpose, m_startNode);

	m_previousKey.clear();
	m_startNode = root.release();
	m_idn = chess960::twin(m_idn);
	m_startBoard.transpose(m_variant);
	moveToMainlineStart();
	updateSubscriber(UpdateBoard | UpdatePgn | UpdateOpening | UpdateIllegalMoves);

	return true;
}


void
Game::unfold()
{
	MoveNode*	node		= m_currentNode;
	unsigned		level		= 0;
	bool			unfolded	= false;

	do
	{
		if (!node->atLineStart())
			node = node->prev();

		if (level == 0 && node->atLineStart())
		{
			node = node->prev();
			++level;
		}
		else
		{
			while (!node->atLineStart())
				node = node->prev();

			if (node->isFolded())
			{
				node->setFolded(false);
				unfolded = true;
			}

			node = node->prev();
			++level;
		}
	}
	while (node);

	if (unfolded)
		updateSubscriber(UpdatePgn);
}


bool
Game::isFolded(edit::Key const& key) const
{
	M_REQUIRE(isValidKey(key));
	return key.findPosition(m_startNode, m_startBoard.plyNumber())->getLineStart()->isFolded();
}


void
Game::setFolded(edit::Key const& key, bool flag)
{
	M_REQUIRE(isValidKey(key));

	if (key.level() == 0)
		return;

	MoveNode*	node		= key.findPosition(m_startNode, m_startBoard.plyNumber())->getLineStart();
	unsigned		update	= UpdatePgn;

	if (flag && node->contains(m_currentNode))
	{
		goToFirst();
		update |= UpdateBoard;
	}

	node->setFolded(flag);
	updateSubscriber(update);
}


void
Game::toggleFolded(edit::Key const& key)
{
	M_REQUIRE(isValidKey(key));
	M_REQUIRE(key.level() > 0);

	MoveNode*	node		= key.findPosition(m_startNode, m_startBoard.plyNumber())->getLineStart();
	bool			flag		= !node->isFolded();
	unsigned		update	= UpdatePgn;

	if (flag && node->contains(m_currentNode))
	{
		goToFirst();
		update |= UpdateBoard;
	}

	node->setFolded(flag);
	updateSubscriber(update);
}


void
Game::setFolded(bool flag)
{
	if (flag && isVariation())
		goToFirst();

	m_startNode->fold(flag);
	updateSubscriber(UpdatePgn | UpdateBoard);
}


void
Game::setSubscriber(SubscriberP subscriber)
{
	m_subscriber = subscriber;
}


Game::SubscriberP
Game::releaseSubscriber()
{
	SubscriberP subscriber = m_subscriber;
	m_subscriber.release();
	return subscriber;
}


void
Game::setLanguages(LanguageSet const& set)
{
	if (m_wantedLanguages != set)
	{
		m_wantedLanguages = set;
		updateSubscriber(UpdatePgn | UpdateBoard | UpdateLanguageSet);
	}
}


void
Game::setAllLanguages()
{
	updateLanguageSet();
	setLanguages(m_languageSet);
}


bool
Game::containsLanguage(edit::Key const& key, move::Position position, mstl::string const& lang) const
{
	M_REQUIRE(isValidKey(key));

	MoveNode* node = key.findPosition(m_startNode, m_startBoard.plyNumber());
	return node->comment(position).containsLanguage(lang);
}


bool
Game::commentEngFlag() const
{
	return m_startNode->containsEnglishLang();
}


bool
Game::commentOthFlag() const
{
	return m_startNode->containsOtherLang();
}


void
Game::refreshSubscriber(unsigned actions)
{
	delete m_editNode;
	m_editNode = 0;
	updateSubscriber(actions);
}


#ifdef DB_DEBUG_GAME
void
Game::beginBackup()
{
	delete m_backupNode;
	m_backupNode = m_startNode->clone();
	m_backupKey = m_currentKey;
}


void
Game::endBackup()
{
	if (m_backupNode == 0)
		return;

	Board board(m_startBoard);

	if (!checkConsistency(m_startNode->next(), board, OnlyIfRemainsConsistent))
	{
		delete m_startNode;
		m_startNode = m_backupNode;
		m_backupNode = 0;
		moveTo(m_backupKey);

		M_RAISE("error in edit action occurred; last action ignored");
	}
}
#endif


void
Game::updateSubscriber(unsigned action)
{
	if (!m_subscriber || m_rollbackCommand != None)
		return;

	if (action & UpdateIllegalMoves)
	{
		bool inCheck = variant::isAntichessExceptLosers(m_variant) ? false : m_startBoard.isInCheck();

		if (m_startNode->containsIllegalMoves(inCheck))
			m_flags |= GameInfo::Flag_Illegal_Move;
		else
			m_flags &= ~GameInfo::Flag_Illegal_Move;

		if (!variant::isAntichessExceptLosers(m_variant))
		{
			if (m_startNode->containsIllegalCastlings(inCheck))
				m_flags |= GameInfo::Flag_Illegal_Castling;
			else
				m_flags &= ~GameInfo::Flag_Illegal_Castling;
		}

		::checkThreefoldRepetitions(m_startBoard, m_variant, m_startNode);
	}

	updateLine();

	if (action & (UpdatePgn | UpdateOpening | UpdateLanguageSet))
	{
		typedef mstl::auto_ptr<edit::Root> Root;

		Root editNode(buildEditNodes());

		if (m_subscriber->mainlineOnly())
		{
			m_editNode = editNode.release();
			m_subscriber->updateEditor(m_editNode, m_editorOptions.m_moveStyle);
		}
		else
		{
			edit::Node::List diff;
			editNode->difference(m_editNode, diff);
			m_subscriber->updateEditor(diff,
												m_tags,
												m_editorOptions.m_moveStyle,
												m_termination,
												m_finalBoard.sideToMove());
			if (!m_mergeResults.empty())
				m_subscriber->updateMergeResults(m_mergeResults);
			delete m_editNode;
			m_editNode = editNode.release();
		}
	}

	if (m_isModified != m_wasModified)
		m_subscriber->stateChanged(m_wasModified = m_isModified);

	if ((action & (UpdateBoard | UpdateNewPosition)) && m_undoCommand == None && m_redoCommand == None)
	{
		if (action & UpdateNewPosition)
			m_previousKey.clear();

		goToCurrentMove();
	}
}


edit::Root*
Game::buildEditNodes() const
{
	if (m_subscriber && m_subscriber->mainlineOnly())
	{
		return edit::Root::makeList(	m_tags,
												m_idn,
												m_eco,
												m_startBoard,
												m_variant,
												m_finalBoard,
												m_termination,
												m_startNode,
												m_editorOptions.m_linebreakThreshold,
												m_editorOptions.m_linebreakMaxLineLengthMain,
												m_editorOptions.m_displayStyle);
	}

	return edit::Root::makeList(	m_tags,
											m_idn,
											m_eco,
											m_startBoard,
											m_variant,
											m_finalBoard,
											m_termination,
											m_languageSet,
											m_wantedLanguages,
											m_engines,
											m_startNode,
											m_editorOptions.m_linebreakThreshold,
											m_editorOptions.m_linebreakMaxLineLengthMain,
											m_editorOptions.m_linebreakMaxLineLengthVar,
											m_editorOptions.m_linebreakMinCommentLength,
											m_editorOptions.m_displayStyle,
											m_editorOptions.m_moveInfoTypes);
}


Board
Game::board(edit::Key const& key) const
{
	M_REQUIRE(isValidKey(key));

	Board board = m_startBoard;
	key.setBoard(m_startNode, board, m_variant);
	return board;
}


mstl::string&
Game::printFen(mstl::string& result) const
{
	return m_currentBoard.toFen(result, m_variant);
}


mstl::string&
Game::printFen(mstl::string const& key, mstl::string& result) const
{
	return board(key).toFen(result, m_variant);
}


void
Game::setup(unsigned linebreakThreshold,
				unsigned linebreakMaxLineLengthMain,
				unsigned linebreakMaxLineLengthVar,
				unsigned linebreakMinCommentLength,
				unsigned displayStyle,
				unsigned moveInfoTypes,
				move::Notation moveStyle)
{
	M_REQUIRE(displayStyle & (display::CompactStyle | display::ColumnStyle));
	M_REQUIRE((displayStyle & (display::CompactStyle | display::ColumnStyle))
					!= (display::CompactStyle | display::ColumnStyle));

	m_editorOptions.m_linebreakThreshold			= linebreakThreshold;
	m_editorOptions.m_linebreakMaxLineLengthMain	= linebreakMaxLineLengthMain;
	m_editorOptions.m_linebreakMaxLineLengthVar	= linebreakMaxLineLengthVar;
	m_editorOptions.m_linebreakMinCommentLength	= linebreakMinCommentLength;
	m_editorOptions.m_displayStyle					= displayStyle;
	m_editorOptions.m_moveInfoTypes					= moveInfoTypes;
	m_editorOptions.m_moveStyle						= moveStyle;
}


void
Game::setIsModified(bool flag)
{
	m_isModified = flag;

	if (flag)
		m_isIrreversible = false;
	else
		clearUndo();

	if (m_subscriber && m_isModified != m_wasModified)
		m_subscriber->stateChanged(m_wasModified = m_isModified);
}


void
Game::setIsIrreversible(bool flag)
{
	if (flag)
	{
		m_isModified = true;
		m_isIrreversible = true;
		clearUndo();

		if (m_subscriber && m_isModified != m_wasModified)
			m_subscriber->stateChanged(m_wasModified = m_isModified);
	}
	else
	{
		m_isIrreversible = false;
	}
}


MoveNode*
Game::findPosition(Board wanted, MoveNode* node, Board board, unsigned depth, bool ignoreEnPassant) const
{
	for ( ; !node->atLineEnd() ; node = node->next())
	{
		if (!node->atLineStart())
			board.doMove(node->move(), m_variant);

		if (ignoreEnPassant && !node->move().isEnPassant())
		{
			if (wanted.isSamePosition(board))
			{
				Square epw = wanted.enPassantSquare();
				Square epb = board.enPassantSquare();

				wanted.setEnPassantSquare(sq::Null);
				board.setEnPassantSquare(sq::Null);

				if (wanted.isEqualZHPosition(board))
					return node;

				wanted.setEnPassantSquare(epw);
				board.setEnPassantSquare(epb);
			}
		}
		else if (wanted.isEqualZHPosition(board))
		{
			return node;
		}

		if (depth > 0 && node->hasVariation())
		{
			board.undoMove(node->move(), m_variant);

			for (unsigned i = 0; i < node->variationCount(); ++i)
			{
				MoveNode* n = findPosition(wanted, node->variation(i), board, depth - 1, ignoreEnPassant);

				if (n)
					return n;
			}

			board.doMove(node->move(), m_variant);
		}
	}

	return 0;
}


bool
Game::merge(unsigned modificationPosition,
				Game const& game,
				position::ID startPosition,
				move::Order order,
				unsigned variationDepth,
				unsigned maximalVariationLength)
{
	if (modificationPosition & modification::First)
		m_changed = false;

	::updateMoveNumbers(game.m_startNode, game.m_startBoard.moveNumber());

	Board startBoard(startPosition == position::Current ? m_currentBoard : m_startBoard);

	MoveNode* startNode	= startPosition == position::Current ? m_currentNode : m_startNode;
	MoveNode* node			= findPosition(startBoard,
													game.m_startNode,
													game.m_startBoard,
													variationDepth,
													!startNode->move().isEnPassant());

	if (node == 0)
		return false;

	mstl::auto_ptr<MoveNode> clone(m_startNode->clone());

	Variants variants;
	::splitForMerge(variants, node, m_variant, variationDepth);

	if (order == move::Transposition)
	{
		Variants myVariants;

		::splitForMerge(myVariants, m_startNode, m_variant, mstl::numeric_limits<unsigned>::max());

		for (Variants::iterator i = variants.begin(); i != variants.end(); ++i)
			::transpose(*i, myVariants);
	}

	BEGIN_BACKUP;

	mstl::string	delim(game.isModified() ? mstl::string::empty_string : m_delim);
	bool				changed(false);

	for (Variants::const_iterator i = variants.begin(); i != variants.end(); ++i)
	{
		if (::merge(startNode,
						i->begin(),
						i->end(),
						&m_languageSet,
						i == variants.begin() ? game.m_tags : TagSet(),
						delim,
						maximalVariationLength,
						false))
		{
			changed = true;
		}
	}

	if (changed && order == move::Transposition)
		m_startNode->finish(m_startBoard, m_variant);

	END_BACKUP;

	if (changed)
	{
		if (!m_changed)
		{
			updateLanguageSet();
			insertUndo(Revert_Game, Merge, clone.release());
		}

		m_changed = true;
	}

	if ((modificationPosition & modification::Last) && m_changed)
	{
		edit::Key key(m_startBoard.plyNumber());
		m_mergeResults.clear();
		::collectMergeResults(m_startNode, m_startBoard, m_variant, key, m_mergeResults);
		updateSubscriber(UpdateAll);
	}

	return true;
}


bool
Game::merge(Game const& game1,
				Game const& game2,
				position::ID startPosition,
				move::Order order,
				unsigned variationDepth,
				unsigned maximalVariationLength)
{
	M_REQUIRE(isEmpty());

	if (game1.isEmpty() || game2.isEmpty())
		return false;

	::updateMoveNumbers(game1.m_startNode, game1.m_startBoard.moveNumber());
	::updateMoveNumbers(game2.m_startNode, game2.m_startBoard.moveNumber());

	Board startBoard1(startPosition == position::Current ? game1.m_currentBoard : game1.m_startBoard);
	Board startBoard2(startPosition == position::Current ? game2.m_currentBoard : game2.m_startBoard);

	MoveNode* startNode1(startPosition == position::Current ? game1.m_currentNode : game1.m_startNode);
	MoveNode* startNode2(startPosition == position::Current ? game2.m_currentNode : game2.m_startNode);
	MoveNode* node1(findPosition(startBoard2, startNode1, startBoard1, variationDepth, true));
	MoveNode* node2(findPosition(startBoard1, startNode2, startBoard2, variationDepth, true));

	if (node1 == 0 || node2 == 0)
		return false;

	Variants variants1;
	Variants variants2;

	::splitForMerge(variants1, game1.m_startNode, m_variant, variationDepth);
	::splitForMerge(variants2, node2, m_variant, variationDepth);

	if (order == move::Transposition)
	{
		for (Variants::iterator i = variants2.begin(); i != variants2.end(); ++i)
			::transpose(*i, variants1);
	}

	BEGIN_BACKUP;

	m_startBoard = game1.m_startBoard;
	m_tags = game1.m_tags;

	for (Variants::const_iterator i = variants1.begin(); i != variants1.end(); ++i)
	{
		::merge(	m_startNode,
					i->begin(),
					i->end(),
					nullptr,
					i == variants1.begin() ? game1.m_tags : TagSet(),
					mstl::string::empty_string,
					maximalVariationLength,
					true);
	}

	mstl::string delim(game2.isModified() ? mstl::string::empty_string : m_delim);
	node2 = findPosition(startBoard1, m_startNode, m_startBoard, variationDepth, true);

	if (node2)
	{
		for (Variants::const_iterator i = variants2.begin(); i != variants2.end(); ++i)
		{
			::merge(	node2,
						i->begin(),
						i->end(),
						&game1.m_languageSet,
						i == variants2.begin() ? game2.m_tags : TagSet(),
						delim,
						maximalVariationLength,
						true);
		}
	}

	m_startNode->finish(m_startBoard, m_variant);

	END_BACKUP;

	if (!isEmpty())
	{
		m_isIrreversible = m_isModified = true;
		updateLanguageSet();
		updateSubscriber(UpdateAll);
	}

	return true;
}


void
Game::swapGameSpecificData(Game& game)
{
	mstl::swap(m_id, game.m_id);
	mstl::swap(m_subscriber, game.m_subscriber);
	mstl::swap(m_flags, game.m_flags);
	mstl::swap(m_editorOptions, game.m_editorOptions);
}


void
Game::clearMergeResults()
{
	m_mergeResults.clear();
}

// vi:set ts=3 sw=3:
