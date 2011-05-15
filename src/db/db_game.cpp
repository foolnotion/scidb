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

#include "db_game.h"
#include "db_move_node.h"
#include "db_annotation.h"
#include "db_mark_set.h"
#include "db_eco_table.h"
#include "db_home_pawns.h"
#include "db_edit_node.h"
#include "db_exception.h"

#include "sys_utf8_codec.h"

#include "m_string.h"
#include "m_vector.h"
#include "m_stack.h"
#include "m_hash.h"
#include "m_utility.h"
#include "m_auto_ptr.h"
#include "m_stdio.h"
#include "m_assert.h"

#include <string.h>
#include <stdlib.h>
#include <ctype.h>

using namespace db;


unsigned Game::undoLevel = 20;


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


struct Game::CleanUp
{
	struct Position
	{
		Position();
		Position(board::ExactPosition const& pos, MoveNode* n) :position(pos), node(n) {}

		bool operator==(board::ExactPosition const& pos) const { return position == pos; }

		board::ExactPosition	position;
		MoveNode*				node;
	};

	typedef mstl::list<Position> List;
	typedef mstl::hash<uint64_t,List> Map;

	static unsigned
	transfer(Board board, Map& map, MoveNode* main, unsigned varno, Position const* dest)
	{
		MoveNode* node = main->variation(varno)->next();

		Position const* prev = dest;
		Position const* next = dest;

		// XXX wrong!
		// we have to search backwards, and we have to compare the position traces

		do
		{
			board.doMove(node->move());

			prev = next;
			node = node->next();

			if (Map::const_pointer j = map.find(board.hash()))
				next = mstl::find(j->begin(), j->end(), board.exactPosition());
			else
				next = 0;
		}
		while (node && next && prev->node->next() == next->node);

		if (node)
		{
			// TODO
			// strip variation from beginning to node; but: merge annotations
			// transfer stripped variation to dest
		}
		else
		{
			// TODO
			// delete whole variation; but: merge annotations
		}

		return 0;
	}

	static unsigned
	cleanup(MoveNode* root, Board const& board, Map map)
	{
		M_ASSERT(root->atLineStart());

		Board myBoard(board);

		for (MoveNode* node = root->next(); node; node = node->next())
		{
			myBoard.doMove(node->move());

			List& positions = map.find_or_insert(board.hash(), List());
			List::iterator i = mstl::find(positions.begin(), positions.end(), board.exactPosition());

			if (i == positions.end())
				positions.push_back(Position(board.exactPosition(), node));
		}

		unsigned count = 0;

		myBoard = board;

		for (MoveNode* node = root->next(); node; node = node->next())
		{
			if (node->hasVariation())
			{
				for (unsigned i = 0; i < node->variationCount(); ++i)
				{
					MoveNode* n = node->variation(i)->next();

					if (n)
					{
						if (Map::const_pointer p = map.find(myBoard.hash()))
						{
							Position const* pos = mstl::find(p->begin(), p->end(), myBoard.exactPosition());

							if (pos)
								count += transfer(myBoard, map, node, i, pos);
						}
					}
				}
			}

			myBoard.doMove(node->move());
		}

		myBoard = board;

		for (MoveNode* node = root->next(); node; node = node->next())
		{
			if (node->hasVariation())
			{
				for (unsigned i = 0; i < node->variationCount(); ++i)
					count += cleanup(node->variation(i), myBoard, map);
			}
		}

		return count;
	}

	static unsigned
	cleanup(MoveNode* root, Board const& board)
	{
		return cleanup(root, board, Map());
	}
};


Game::Subscriber::~Subscriber() throw() {}
bool Game::Subscriber::mainlineOnly() { return false; }


void
Game::Subscriber::setFlag(unsigned& value, unsigned flag, bool set)
{
	if (set)
		value |= flag;
	else
		value &= ~flag;
}


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
	mstl::string*	comment;
	MarkSet*			marks;
	Annotation*		annotation;
	unsigned			varNo;
	unsigned			varNo2;
	Board				board;
};


Game::Undo::Undo()
	:command(None)
	,comment(0)
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
	:GameData()
	,m_currentNode(m_startNode)
	,m_editNode(0)
	,m_currentBoard(m_startBoard)
	,m_currentLevel(0)
	,m_idn(0)
	,m_undoIndex(0)
	,m_maxUndoLevel(0)
	,m_undoCommand(None)
	,m_redoCommand(None)
	,m_flags(0)
	,m_isModified(false)
	,m_containsIllegalMoves(false)
	,m_finalBoardIsValid(false)
	,m_line(m_lineBuf[0])
{
}


Game::Game(Game const& game)
	:GameData()
	,m_editNode(0)
	,m_line(m_lineBuf[0])
{
	*this = game;
}


Game::~Game() throw()
{
	delete m_editNode;

	for (unsigned i = 0; i < m_undoList.size(); ++i)
		delete m_undoList[i];
}


Game&
Game::operator=(Game const& game)
{
	if (this != &game)
	{
		m_startNode					= game.m_startNode ? game.m_startNode->clone() : 0;
		m_startBoard				= game.m_startBoard;
		m_currentBoard				= game.m_startBoard;
		m_currentNode				= m_startNode;
		m_editNode					= 0;
		m_currentKey				= edit::Key(game.m_startBoard.plyNumber());
		m_currentLevel				= 0;
		m_idn							= game.m_idn;
		m_eco							= game.m_eco;
		m_opening					= game.m_opening;
		m_languageSet				= game.m_languageSet;
		m_wantedLanguages			= game.m_wantedLanguages;
		m_isModified				= false;
		m_containsIllegalMoves	= game.m_containsIllegalMoves;
		m_finalBoardIsValid		= false;
		m_subscriber				= game.m_subscriber;
		m_undoIndex					= 0;
		m_maxUndoLevel				= 0;
		m_undoCommand				= None;
		m_redoCommand				= None;
		m_flags						= game.m_flags;

		m_line.copy(game.m_line);

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
			m_isModified = true;
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
		--m_undoIndex;
	else if (m_redoCommand == None)
		undo.command = command;

	return undo;
}


Game::Undo*
Game::prevUndo()
{
	M_ASSERT(m_maxUndoLevel > 0);

	if (m_undoCommand != None)
		return m_undoIndex < m_undoList.size() ? m_undoList[m_undoIndex] : 0;

	if (m_undoIndex == 0)
		return 0;

	return m_undoList[m_undoIndex - 1];
}


void
Game::insertUndo(UndoAction action, Command command)
{
	M_ASSERT(action == Unstrip_Moves || action == Truncate_Variation || action == Remove_Mainline);

	if (m_maxUndoLevel)
		newUndo(action, command);
	else
		m_isModified = true;
}


void
Game::insertUndo(	UndoAction action,
						Command command,
						mstl::string const& oldComment,
						mstl::string const& newComment)
{
	M_ASSERT(action == Set_Annotation);

	if (m_maxUndoLevel)
	{
		Undo* prev = prevUndo();

		if (prev == 0 || prev->action != action || prev->key != m_currentKey)
		{
			newUndo(action, command).comment = new mstl::string(oldComment);
		}
		else if (prev->comment == 0)
		{
			prev->comment = new mstl::string(oldComment);
		}
		else if (	m_undoCommand == None
					&& *prev->comment == newComment
					&& (prev->annotation == 0 || *prev->annotation == m_currentNode->annotation())
					&& (prev->marks == 0 || *prev->marks == m_currentNode->marks()))
		{
			prev->clear();
			--m_undoIndex;
		}
	}
	else
	{
		m_isModified = true;
	}
}


void
Game::insertUndo(UndoAction action, Command command, MarkSet const& oldMarks, MarkSet const& newMarks)
{
	M_ASSERT(action == Set_Annotation);

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
		else if (	m_undoCommand == None
					&& *prev->marks == newMarks
					&& (prev->comment == 0 || *prev->comment == m_currentNode->comment())
					&& (prev->annotation == 0 || *prev->annotation == m_currentNode->annotation()))
		{
			prev->clear();
			--m_undoIndex;
		}
	}
	else
	{
		m_isModified = true;
	}
}


void
Game::insertUndo(	UndoAction action,
						Command command,
						Annotation const& oldAnnotation,
						Annotation const& newAnnotation)
{
	M_ASSERT(action == Set_Annotation);

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
		else if (	m_undoCommand == None
					&& *prev->annotation == newAnnotation
					&& (prev->comment == 0 || *prev->comment == m_currentNode->comment())
					&& (prev->marks == 0 || *prev->marks == m_currentNode->marks()))
		{
			prev->clear();
			--m_undoIndex;
		}
	}
	else
	{
		m_isModified = true;
	}
}


void
Game::insertUndo(UndoAction action, Command command, MoveNode* node)
{
	M_ASSERT(action == Replace_Node || action == Revert_Game);

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
		m_isModified = true;
		delete node;
	}
}


void
Game::insertUndo(UndoAction action, Command command, MoveNode* node, unsigned varNo)
{
	M_ASSERT(action == Insert_Variation || action == New_Mainline);

	if (m_maxUndoLevel)
	{
		Undo& undo = newUndo(action, command);
		undo.node = node;
		undo.varNo = varNo;
	}
	else
	{
		m_isModified = true;
		delete node;
	}
}


void
Game::insertUndo(UndoAction action, Command command, unsigned varNo)
{
	M_ASSERT(action == Remove_Variation);

	if (m_maxUndoLevel)
		newUndo(action, command).varNo = varNo;
	else
		m_isModified = true;
}


void
Game::insertUndo(UndoAction action, Command command, unsigned varNo1, unsigned varNo2)
{
	M_ASSERT(action == Swap_Variations || action == Promote_Variation);

	if (m_maxUndoLevel)
	{
		Undo& undo = newUndo(action, command);
		undo.varNo = varNo1;
		undo.varNo2 = varNo2;
	}
	else
	{
		m_isModified = true;
	}
}


void
Game::insertUndo(UndoAction action, Command command, MoveNode* node, Board const& board)
{
	M_ASSERT(action == Strip_Moves || action == Set_Start_Position);

	if (m_maxUndoLevel)
	{
		Undo& undo = newUndo(action, command);
		undo.node = node;
		undo.board = board;
	}
	else
	{
		m_isModified = true;
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
Game::applyUndo(Undo& undo, bool redo)
{
	if (redo || undo.action != Set_Start_Position)
		moveTo(undo.key);

	switch (undo.action)
	{
		case Replace_Node:			replaceNode(undo.node.release(), undo.command); break;
		case Truncate_Variation:	truncateVariation(AfterMove); break;
		case Swap_Variations:		moveVariation(undo.varNo, undo.varNo2, undo.command); break;
		case Insert_Variation:		insertVariation(undo.node.release(), undo.varNo); break;
		case Promote_Variation:		promoteVariation(undo.varNo, undo.varNo2); break;
		case Remove_Variation:		removeVariation(undo.varNo); break;
		case Remove_Mainline:		removeMainline(); break;
		case New_Mainline:			newMainline(undo.node.release()); break;
		case Strip_Moves:				unstripMoves(undo.node.release(), undo.board, undo.key); break;
		case Unstrip_Moves:			stripMoves(AfterMove); break;
		case Revert_Game:				revertGame(undo.node.release(), undo.command); break;
		case Set_Start_Position:	resetGame(undo.node.release(), undo.board, undo.key.id()); break;

		case Set_Annotation:
			{
				unsigned n = 1;
				unsigned flags = UpdatePgn;

				if (undo.annotation)
				{
					if (	m_currentNode->annotation().contains(nag::Diagram)
						^ undo.annotation->contains(nag::Diagram))
					{
						++n;
					}
					Annotation annotation(*undo.annotation);
					insertUndo(Set_Annotation, SetAnnotation, m_currentNode->annotation(), annotation);
					m_currentNode->setAnnotation(annotation);
				}
				if (undo.comment)
				{
					mstl::string comment(*undo.comment);
					insertUndo(Set_Annotation, SetAnnotation, m_currentNode->comment(), comment);
					m_currentNode->swapComment(comment);
					if (updateLanguageSet())
						flags |= UpdateLanguageSet;
				}
				if (undo.marks)
				{
					MarkSet marks(*undo.marks);
					insertUndo(Set_Annotation, SetAnnotation, m_currentNode->marks(), marks);
					m_currentNode->swapMarks(marks);
				}

				updateSubscriber(flags);
			}
			break;
	}

	if (!redo || undo.action != Set_Start_Position)
		moveTo(undo.key);

	switch (int(undo.action))
	{
		case Promote_Variation:
		case Remove_Variation:
			backward();
			break;
	}

	if (redo)
	{
		switch (int(undo.command))
		{
			case AddMove:
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
	applyUndo(redo, true);
}


bool
Game::isEmpty() const
{
	return m_startNode->next() == 0;
}


bool
Game::atMainlineEnd() const
{
	return isMainline() && !m_currentNode->next();
}


bool
Game::atLineStart() const
{
	return m_currentNode->atLineStart();
}


bool
Game::atLineEnd() const
{
	return !m_currentNode->next();
}


bool
Game::isFirstVariation() const
{
	if (m_currentLevel == 0)
		return false;

	MoveNode* node = m_currentNode;

	while (!node->atLineStart())
		node = node->prev();

	MoveNode*	prev	= node->prev();
	unsigned		n		= prev->variationNumber(node);

	while (n > 0 && prev->variation(n - 1)->atLineEnd())
		--n;

	return n == 0;
}


bool
Game::isLastVariation() const
{
	if (m_currentLevel == 0)
		return true;

	MoveNode* node = m_currentNode;

	while (!node->atLineStart())
		node = node->prev();

	MoveNode*	prev	= node->prev();
	unsigned		n		= prev->variationNumber(node) + 1;

	while (n < prev->variationCount() && prev->variation(n)->atLineEnd())
		++n;

	return n == prev->variationCount();
}


Board const&
Game::getFinalBoard() const
{
	if (!m_finalBoardIsValid)
	{
		MoveNode const* node = m_startNode;
		HomePawns hp;

		m_finalBoard = m_startBoard;

		while (!node->atLineEnd())
		{
			node = node->next();
			m_finalBoard.doMove(node->move());
			hp.move(node->move());
		}

		m_finalBoard.signature().setHomePawns(hp.used(), hp.data());
		m_finalBoardIsValid = true;
	}

	return m_finalBoard;
}


Board const&
Game::getStartBoard() const
{
	return startBoard();
}

Move const&
Game::currentMove() const
{
	return m_currentNode->move();
}


Move const&
Game::nextMove() const
{
	return m_currentNode->next() ? m_currentNode->next()->move() : Move::empty();
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


Comment const&
Game::comment() const
{
	return m_currentNode->comment();
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


mstl::string&
Game::printSan(Board const& board, MoveNode* node, mstl::string& result, unsigned flags)
{
	M_ASSERT(node);

	Move& move = node->move();

	if (!move)
		return result;

	M_ASSERT(move.isPrintable());

	// move number
	if (board.blackToMove())
	{
		if (flags & BlackNumbers)
		{
			result.format("%u", board.moveNumber());
			result += "...";

			if (!(flags & SuppressSpace) || (flags & ExportFormat))
				result += " ";
		}
	}
	else
	{
		if (flags & WhiteNumbers)
		{
			result.format("%u", board.moveNumber());
			result += '.';

			if (!(flags & SuppressSpace) || (flags & ExportFormat))
				result += " ";
		}
	}

	// move
	move.printSan(result, flags & ExportFormat ? Move::Ascii : Move::Unicode);

	if (!(flags & ExportFormat) && !move.givesMate() && board.isDoubleCheck())
		result += '+';

	// annotation
	if (flags & IncludeAnnotation)
	{
		node->annotation().print(
			result,
			flags & ExportFormat ? 0 : Annotation::Flag_Extended_Symbolic_Annotation_Style);
	}

	return result;
}


mstl::string&
Game::printSan(mstl::string& result, unsigned flags) const
{
	return printSan(m_currentBoard, m_currentNode, result, flags);
}


mstl::string
Game::getNextMove(unsigned flags)
{
	M_ASSERT(!atLineEnd());

	mstl::string san;

	m_currentNode = m_currentNode->next();
	doMove();
	printSan(san, flags);
	undoMove();
	m_currentNode = m_currentNode->prev();

	return san;
}


void
Game::setComment(mstl::string const& comment, Position position)
{
	M_REQUIRE(position == AfterMove || !atLineStart());

	if (position == BeforeMove)
		backward();

	if (comment != m_currentNode->comment())
	{
		insertUndo(Set_Annotation, SetAnnotation, m_currentNode->comment(), comment);
		m_currentNode->setComment(comment);

		{
			Comment comm;
			m_currentNode->swapComment(comm);
			comm.normalize();
			m_currentNode->swapComment(comm);
		}

		unsigned flags = UpdatePgn | UpdateBoard;

		if (updateLanguageSet())
			flags |= UpdateLanguageSet;

		updateSubscriber(flags);
	}

	if (position == BeforeMove)
		forward();
}


void
Game::setMarks(MarkSet const& marks, Position position)
{
	M_REQUIRE(position == AfterMove || !atLineStart());

	if (position == BeforeMove)
		backward();

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

	if (position == BeforeMove)
		forward();
}


void
Game::setAnnotation(Annotation const& annotation)
{
	if (annotation == m_currentNode->annotation())
		return;

	unsigned n = 1;

	if (annotation.contains(nag::Diagram) ^ m_currentNode->annotation().contains(nag::Diagram))
		++n;

	insertUndo(Set_Annotation, SetAnnotation, m_currentNode->annotation(), annotation);
	m_currentNode->setAnnotation(annotation);
	updateSubscriber(UpdatePgn | UpdateBoard);
}


void
Game::doMove()
{
	m_currentBoard.doMove(m_currentNode->move());
	m_currentKey.exchangePly(m_currentBoard.plyNumber());
}


void
Game::undoMove()
{
	m_currentBoard.undoMove(m_currentNode->move());
	m_currentKey.exchangePly(m_currentBoard.plyNumber());
}


bool
Game::forward()
{
	if (!m_currentNode->next())
		return false;

	m_currentNode = m_currentNode->next();
	doMove();
	return true;
}


bool
Game::backward()
{
	if (m_currentNode->atLineStart())
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
	m_currentLevel = 0;
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
	if (isMainline())
		return;

	do
		exitVariation();
	while (isVariation());
}


void
Game::goToCurrentMove() const
{
	if (m_subscriber)
	{
		m_subscriber->boardSetup(m_currentBoard);
		m_subscriber->gotoMove(m_currentKey.id(), successorKey());
	}
}


void
Game::goToCurrentMove(bool forward) const
{
	M_ASSERT(forward || m_currentNode->next());

	if (m_subscriber)
	{
		Move move = forward ? m_currentNode->move() : m_currentNode->next()->move();

		m_subscriber->boardMove(m_currentBoard, move, forward);
		m_subscriber->gotoMove(m_currentKey.id(), successorKey());
	}
}


void
Game::goToPosition(mstl::string const& fen)
{
	Board position;
	position.setup(fen);

	moveToMainlineStart();

	while (!atMainlineEnd() && !position.isEqualPosition(m_currentBoard))
		forward();

	goToCurrentMove();
}


void
Game::moveTo(edit::Key const& key)
{
	edit::Key wantedKey(key);
	edit::Key currentKey(m_currentKey);

	moveToMainlineStart();

	if (!wantedKey.setPosition(*this))
	{
		currentKey.setPosition(*this);
		DB_RAISE("invalid key '%s'", key.id().c_str());
	}

	m_currentKey = wantedKey;
}


void
Game::moveTo(mstl::string const& key)
{
	M_REQUIRE(edit::Key::isValid(key));
	moveTo(edit::Key(key));
}


void
Game::getMoves(StringList& result, unsigned flags)
{
	result.clear();

	if (atLineEnd())
		return;

	forward();
	result.push_back();
	printSan(result.back(), flags);

	for (unsigned i = 0; i < m_currentNode->variationCount(); ++i)
	{
		enterVariation(i);

		if (!atLineEnd())
		{
			forward();
			result.push_back();
			printSan(result.back(), flags);
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

		if (!atLineEnd())
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
	return m_currentNode->atLineEnd() ? 0 : m_currentNode->next()->variationCount();
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
	MoveNode const* n = m_currentNode;

	while (!n->atLineStart())
		n = n->prev();

	return n->countHalfMoves();
}


unsigned
Game::countAnnotations() const
{
	return m_startNode->countAnnotations();
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
	if (m_currentLevel == 0)
		return 0;

	MoveNode* node = m_currentNode;

	while (!node->atLineStart())
		node = node->prev();

	M_ASSERT(node->prev());

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
	++m_currentLevel;
}


void
Game::exitVariation()
{
	M_REQUIRE(isVariation());

	moveToStart();
	m_currentNode = m_currentNode->prev();
	m_currentKey.removePly();
	m_currentKey.removeVariation();
	--m_currentLevel;
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
	M_REQUIRE(!atLineEnd());

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
	if (m_currentLevel == 0 && m_currentNode->atLineEnd())
		return;

	if (m_currentLevel == 0 && m_currentNode->next()->variationCount() == 0)
	{
		goForward();
	}
	else
	{
		forward();

		MoveNode*	node	= m_currentNode;
		unsigned		n		= 0;

		if (node->variationCount() == 0)
		{
			if (m_currentLevel > 0)
				exitVariation();

			while (!node->atLineStart())
				node = node->prev();

			if (node->prev() == m_currentNode)
			{
				n = m_currentNode->variationNumber(node) + 1;

				while (n < m_currentNode->variationCount() && m_currentNode->variation(n)->atLineEnd())
					++n;
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
	if (m_currentLevel == 0 && m_currentNode->atLineStart())
		return;

	if (m_currentLevel == 0)
	{
		goBackward();
	}
	else
	{
		backward();

		MoveNode*	node	= m_currentNode;
		unsigned		n		= 0;

		exitVariation();

		while (!node->atLineStart())
			node = node->prev();

		if (node->prev() == m_currentNode)
		{
			n = m_currentNode->variationNumber(node);

			while (n > 0 && m_currentNode->variation(n - 1)->atLineEnd())
				--n;
		}

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
	Move move = m_currentBoard.parseMove(san, move::AllowIllegalMove);

	if (!move)
	{
		Board			board	= m_currentBoard;
		color::ID	side	= board.sideToMove();

		board.tryCastleShort(side);
		board.tryCastleLong(side);

		move = board.parseMove(san, move::AllowIllegalMove);
	}

	return move;
}


void
Game::replaceNode(MoveNode* newNode, Command command)
{
	M_ASSERT(newNode);

	bool truncate = m_currentNode->next();

	if (truncate)
		insertUndo(Replace_Node, command, m_currentNode->removeNext());
	else
		insertUndo(Truncate_Variation, command);

	m_currentNode->setNext(newNode);

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
//	M_ASSERT(!atLineEnd());

	mstl::auto_ptr<MoveNode> node(variation);

	insertUndo(Remove_Variation, RemoveVariation, number);

	m_currentNode->addVariation(node.release());
	m_currentNode->swapVariations(number, m_currentNode->variationCount() - 1);

	unsigned flags = UpdatePgn | UpdateIllegalMoves | UpdateLanguageSet | UpdateBoard;

	if (isMainline())
		flags |= UpdateOpening;

	updateSubscriber(flags);
}


bool
Game::exchangeMove(Move move, Force flag)
{
	M_REQUIRE(!atLineEnd());
	M_REQUIRE(currentBoard().checkMove(move));

	if (move == m_currentNode->next()->move())
		return true;

	Board board(m_currentBoard);
	mstl::auto_ptr<MoveNode> node(m_currentNode->next()->clone());
	node->setMove(m_currentBoard, move);

	board = m_currentBoard;
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
	M_REQUIRE(m_currentBoard.checkMove(move));

	insertUndo(Truncate_Variation, AddMove);
	m_currentNode->setNext(new MoveNode(m_currentBoard, move));

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


bool
Game::isValidVariation(MoveNode const* node) const
{
	M_REQUIRE(node);

	Board board(m_currentBoard);

	for (node = node->next(); node; node = node->next())
	{
		if (!board.isValidMove(node->move()))
			return false;

		board.doMove(node->move());
	}

	return true;
}


unsigned
Game::addVariation(MoveNodeP node)
{
	M_REQUIRE(!atLineEnd());
	M_REQUIRE(node);
	M_REQUIRE(isValidVariation(node.get()));

	forward();
	insertUndo(Remove_Variation, AddVariation, m_currentNode->variationCount());
	backward();

	Board board(m_currentBoard);

	for (MoveNode* n = node->next(); n; n = n->next())
	{
		board.prepareUndo(n->move());
		board.prepareForSan(n->move());
		board.doMove(n->move());
	}

	MoveNode* varNode = node.release();
	m_currentNode->next()->addVariation(varNode);
	updateSubscriber(UpdatePgn | UpdateBoard);

	return m_currentNode->next()->variationCount() - 1;
}


unsigned
Game::addVariation(Move const& move)
{
	M_REQUIRE(!atLineEnd());
	M_REQUIRE(currentBoard().checkMove(move));

	MoveNodeP varNode(new MoveNode);
	varNode->setNext(new MoveNode(m_currentBoard, move));
	return addVariation(varNode);
}


unsigned
Game::addVariation(mstl::string const& san)
{
	return addVariation(parseMove(san));
}


void
Game::newMainline(MoveNode* node)
{
	M_REQUIRE(!atLineEnd());

	edit::Key currentKey = m_currentKey;

	forward();
	insertUndo(Remove_Mainline, NewMainline);
	m_currentNode->addVariation(node);
	unsigned varNo = m_currentNode->variationCount() - 1;
	promoteVariation(varNo, varNo, false);
	moveTo(currentKey);
	updateSubscriber(UpdateAll);
}


void
Game::newMainline(Move const& move)
{
	M_REQUIRE(!atLineEnd());
	M_REQUIRE(currentBoard().checkMove(move));

	MoveNode* varNode = new MoveNode;
	varNode->setNext(new MoveNode(m_currentBoard, move));
	newMainline(varNode);
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

	unsigned varNo = m_currentNode->variationCount() - 1;
	promoteVariation(varNo, varNo, false);
	MoveNode* node = m_currentNode->removeVariation(varNo);

	backward();
	insertUndo(New_Mainline, NewMainline, node, varNo);
	forward();

	updateSubscriber(UpdateAll);
}


bool
Game::checkConsistency(MoveNode* node, Board& board, Force flag, bool tryToFixKingMoves)
{
	M_ASSERT(node);

	while (node->next())
	{
		if (node->move())
			board.doMove(node->move());

		node = node->next();

		if (!board.isValidMove(node->move(), node->constraint()))
		{
			if (flag == OnlyIfRemainsConsistent)
				return false;

			bool truncate = true;

#if 0
			if (tryToFixKingMoves && !node->move().isCastling() && node->move().pieceMoved() == piece::King)
			{
				color::ID stm = board.sideToMove();

				if (board.kingSquare(stm) != node->move().to())
				{
					Move move = board.prepareMove(board.kingSquare(stm), node->move().to());

					if (move.isLegal() && board.isValidMove(move, node->constraint()))
					{
						board.prepareUndo(move);
						board.prepareForSan(move);

						node->setMove(move);
						truncate = false;
					}
				}
			}
#endif

			if (truncate)
			{
				node->prev()->deleteNext();
				return true;
			}
		}

		for (unsigned i = 0; i < node->variationCount(); ++i)
		{
			if (!node->variation(i)->atLineEnd())
			{
				Board b(board);

				if (!checkConsistency(node->variation(i)->next(), b, flag, tryToFixKingMoves))
					return false;

				if (node->variation(i)->atLineEnd())
				{
					if (i-- > 0)
						node->swapVariations(i, node->variationCount() - 1);
					node->deleteVariation(node->variationCount() - 1);
				}
			}
		}
	}

	return true;
}


void
Game::moveVariation(unsigned from, unsigned to, Command command)
{
	M_REQUIRE(from < variationCount());
	M_REQUIRE(to < variationCount());

	if (from == to)
		return;

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

	// we cannot promote if variation is empty.
	if (m_currentNode->variation(oldVariationNumber)->next() == 0)
		return;

	MoveNode* variation	= m_currentNode->removeVariation(oldVariationNumber);
	MoveNode* parent		= m_currentNode->prev();
	MoveNode* next			= variation->removeNext();

	M_ASSERT(parent);
	M_ASSERT(next);

	parent->removeNext();	// = m_currentNode
	parent->setNext(next);
	variation->setNext(m_currentNode);
	next->addVariation(variation);

	while (m_currentNode->hasVariation())
		next->addVariation(m_currentNode->removeVariation(0));

	for (unsigned i = 1; i <= newVariationNumber; ++i)
		next->swapVariations(i - 1, i);

	moveTo(m_currentKey);

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

	MoveNode* node = m_currentNode->removeVariation(variationNumber);
	insertUndo(Insert_Variation, RemoveVariation, node, variationNumber);
	updateSubscriber(UpdatePgn | UpdateBoard | UpdateLanguageSet | UpdateIllegalMoves);
}


bool
Game::insertMoves(unsigned variationNumber, Force flag)
{
	M_REQUIRE(variationNumber < variationCount());
	M_ASSERT(!atLineStart());

	if (m_currentNode->variation(variationNumber)->countHalfMoves() == 0)
		return true;

	Board board(m_currentBoard);
	board.undoMove(m_currentNode->move());

	MoveNode* curr = m_currentNode->clone();
	MoveNode* node = curr->removeVariation(variationNumber);
	MoveNode* last = node;

	while (last->next())
		last = last->next();

	last->setNext(curr);

	MoveNode root(node->removeNext());

	delete node;
	board = m_currentBoard;
	board.undoMove(m_currentNode->move());

	if (!checkConsistency(&root, board, flag))
		return false;

	backward();
	insertUndo(Replace_Node, InsertMoves, m_currentNode->removeNext());
	m_currentNode->setNext(root.removeNext());
	moveTo(m_currentKey);

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

	Board board(m_currentBoard);
	board.undoMove(m_currentNode->move());

	MoveNode* curr = m_currentNode->clone();
	MoveNode* node = curr->removeVariation(variationNumber);
	MoveNode* last = node;

	while (last->next())
		last = last->next();

	MoveNode* tail = curr;

	for (unsigned i = 0, n = mstl::min(movesToExchange - 1, tail->countHalfMoves()); i < n; ++i)
		tail = tail->next();

	MoveNode* line = node->removeNext();

	last->setNext(tail->removeNext());
	node->setNext(curr);
	line->addVariation(node);

	MoveNode root(line);

	board = m_currentBoard;
	board.undoMove(node->next()->move());

	if (!checkConsistency(&root, board, flag))
		return false;

	backward();
	insertUndo(Replace_Node, ExchangeMoves, m_currentNode->removeNext());
	m_currentNode->setNext(root.removeNext());
	moveTo(m_currentKey);

	unsigned flags = UpdatePgn | UpdateBoard | UpdateIllegalMoves;

	if (isMainline())
		flags |= UpdateOpening;

	updateSubscriber(flags);
	return true;
}


void
Game::truncateVariation(Position position)
{
	if (position == BeforeMove)
		backward();

	if (atLineEnd())
		return;

	insertUndo(Replace_Node, TruncateVariation, m_currentNode->removeNext());

	unsigned flags = UpdatePgn | UpdateIllegalMoves | UpdateLanguageSet;

	if (isMainline())
		flags |= UpdateOpening;
	if (position == BeforeMove)
		flags |= UpdateBoard;

	updateSubscriber(flags);
}


void
Game::changeVariation(MoveNodeP node, unsigned variationNumber)
{
	M_REQUIRE(!atLineEnd());
	M_REQUIRE(node);
	M_REQUIRE(isValidVariation(node.get()));
	M_REQUIRE(variationNumber < subVariationCount());

	Board board(m_currentBoard);

	for (MoveNode* n = node->next(); n; n = n->next())
	{
		board.prepareUndo(n->move());
		board.prepareForSan(n->move());
		board.doMove(n->move());
	}

	MoveNode* varNode = node.release();
	delete m_currentNode->next()->replaceVariation(variationNumber, varNode);

	updateSubscriber(UpdatePgn | UpdateBoard | UpdateIllegalMoves | UpdateLanguageSet);
}


void
Game::replaceVariation(Move const& move)
{
	M_REQUIRE(currentBoard().checkMove(move));

	if (atLineEnd())
		addMove(move);
	else
		replaceNode(new MoveNode(m_currentBoard, move), ReplaceVariation);
}


void
Game::replaceVariation(mstl::string const& san)
{
	replaceVariation(parseMove(san));
}


bool
Game::stripMoves(Position position)
{
	M_REQUIRE(isMainline());

	if (position == BeforeMove)
		backward();

	if (atLineStart())
		return false;

	insertUndo(Strip_Moves, StripMoves, m_startNode->removeNext(), m_startBoard);
	if (m_currentNode->next())
		m_startNode->setNext(m_currentNode->removeNext());
	m_startBoard = m_currentBoard;
	moveTo(m_currentKey);

	unsigned flags = UpdatePgn | UpdateBoard | UpdateLanguageSet | UpdateIllegalMoves;

	if (isMainline())
		flags |= UpdateOpening;

	updateSubscriber(flags);
	return true;
}


void
Game::unstripMoves(MoveNode* startNode, Board const& startBoard, edit::Key const& key)
{
	MoveNode* last = startNode;

	while (last->next())
		last = last->next();

	if (m_startNode->next())
		last->setNext(m_startNode->removeNext());
	m_startNode->setNext(startNode);
	m_startBoard = startBoard;
	moveTo(key);
	insertUndo(Unstrip_Moves, StripMoves);

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

	insertUndo(Revert_Game, StripAnnotations, m_startNode);
	m_startNode = m_startNode->clone();
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

	insertUndo(Revert_Game, StripComments, m_startNode);
	m_startNode = m_startNode->clone();
	m_startNode->stripComments();
	moveTo(m_currentKey);
	updateSubscriber(UpdatePgn | UpdateBoard | UpdateLanguageSet);

	return true;
}


bool
Game::stripComments(mstl::string const& lang)
{
	if (m_startNode->countComments(lang) == 0)
		return false;

	insertUndo(Revert_Game, StripComments, m_startNode);
	m_startNode = m_startNode->clone();
	m_startNode->stripComments(lang);
	moveTo(m_currentKey);
	updateSubscriber(UpdatePgn | UpdateBoard | UpdateLanguageSet);

	return true;
}


bool
Game::stripMarks()
{
	if (m_startNode->countMarks() == 0)
		return false;

	insertUndo(Revert_Game, StripMarks, m_startNode);
	m_startNode = m_startNode->clone();
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

	insertUndo(Revert_Game, StripVariations, m_startNode);
	m_startNode = m_startNode->clone();
	m_startNode->stripVariations();
	moveTo(m_currentKey);
	updateSubscriber(UpdatePgn | UpdateBoard | UpdateLanguageSet | UpdateIllegalMoves);

	return true;
}


void
Game::revertGame(MoveNode* startNode, Command command)
{
	insertUndo(Revert_Game, command, m_startNode);
	m_startNode = startNode;

	if (command == Transpose)
	{
		m_idn = chess960::twin(m_idn);
		m_startBoard.transpose();
	}

	moveTo(m_currentKey);
	updateSubscriber(UpdateAll);
}


void
Game::resetGame(MoveNode* startNode, Board const& startBoard, edit::Key const&)
{
	Board board(m_startBoard);
	MoveNode* node(m_startNode);

	moveToMainlineStart();
	m_startNode = startNode;
	m_startBoard = startBoard;
	insertUndo(Set_Start_Position, Clear, node, board);
	moveToMainlineStart();
	updateSubscriber(UpdateAll);
}


void
Game::clear(Board const* startPosition)
{
	moveToMainlineStart();
	insertUndo(Set_Start_Position, Clear, m_startNode, m_startBoard);
	m_startNode = m_currentNode = new MoveNode();
	if (startPosition)
		m_startBoard = *startPosition;
	m_currentBoard = m_startBoard;
	updateSubscriber(UpdateAll);
}


void
Game::resetForNextLoad()
{
	delete m_startNode;
	m_startNode = m_currentNode = new MoveNode();
	m_currentKey.clear();
	m_currentLevel = 0;
	m_undoList.clear();
	m_languageSet.clear();
	m_undoIndex = 0;
	m_idn = 0;
	m_isModified = false;
	m_finalBoardIsValid = false;
	m_currentBoard = m_startBoard;
	m_tags.clear();
	m_flags = 0;
}


uint64_t
Game::computeChecksum(uint64_t crc) const
{
	return m_startNode->computeChecksum(crc);
}


void
Game::setStartPosition(mstl::string const& fen)
{
	M_REQUIRE(isEmpty());

	if (!m_startBoard.setup(fen))
		DB_RAISE("invalid FEN");

	m_currentBoard = m_startBoard;

	M_DEBUG(m_startBoard.validate(variant::Unknown, castling::AllowHandicap) == Board::Valid);
}


void
Game::setStartPosition(unsigned idn)
{
	M_REQUIRE(isEmpty());
	M_REQUIRE(idn <= 4*960);

	m_startBoard.setup(idn);
	m_currentBoard = m_startBoard;

	M_DEBUG(m_startBoard.validate(variant::fromIdn(idn)) == Board::Valid);
}


unsigned
Game::dumpMoves(mstl::string& result, unsigned length)
{
	result.clear();

	if (atLineStart())
	{
		if (!m_currentNode->next())
			return 0;
	}

	unsigned n = 0;

	while (length--)
	{
		if (m_currentNode->next() == 0)
			return n;

		m_currentNode = m_currentNode->next();
		printSan(result, SuppressSpace | WhiteNumbers | (result.empty() ? BlackNumbers : 0));
		m_currentNode = m_currentNode->prev();
		forward();
		result += ' ';
		++n;
	}

	result.rtrim();
	return n;
}


unsigned
Game::dumpMoves(mstl::string& result)
{
	return dumpMoves(result, mstl::numeric_limits<unsigned>::max());
}


bool
Game::finishLoad()
{
	M_REQUIRE(atMainlineStart());

	Board board(m_startBoard);

	bool ok = checkConsistency(m_startNode, board, OnlyIfRemainsConsistent);

	if (!ok)
		checkConsistency(m_startNode, board, TruncateIfNeccessary);

	m_startNode->finish(m_startBoard);
	m_currentBoard = m_startBoard;

	updateLine();
	updateLanguageSet();
	m_wantedLanguages = m_languageSet;

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
	m_currentBoard.signature().setHomePawns(hp.used(), hp.data());

	return hp.signature();
}


bool
Game::updateLine()
{
	if (!isMainline())
		return false;

	m_finalBoardIsValid = false;

	unsigned idn = m_startBoard.computeIdn();

	bool update = m_idn != idn;

	if (idn)
	{
		uint16_t* lineBuf = m_line.moves == m_lineBuf[0] ? m_lineBuf[1] : m_lineBuf[0];

		unsigned	i = 0;

		for (	MoveNode const* node = m_startNode->next();
				node && i < opening::Max_Line_Length;
				node = node->next(), ++i)
		{
			lineBuf[i] = node->move().index();
		}

		Line line(lineBuf, i);

		if (idn == chess960::StandardIdn)
		{
			if (line != m_line || !m_eco)
			{
				Eco opening(m_opening);
				Eco eco(m_eco);

				m_line = line;
				m_eco = EcoTable::specimen().getEco(m_line);

				EcoTable::specimen().lookup(m_line, m_opening);

				if (m_eco != eco || opening != m_opening)
					update = true;
			}
		}
		else
		{
			m_eco = m_opening = 0;
			m_eco = 0;
		}
	}
	else
	{
		m_eco = m_opening = 0;
		m_line.length = 0;
	}

	m_idn = idn;
	return update;
}


Eco
Game::computeEcoCode() const
{
	if (m_idn != chess960::StandardIdn)
		return Eco();

	uint16_t lineBuf[opening::Max_Line_Length];

	unsigned	i = 0;

	for (	MoveNode const* node = m_startNode->next();
			node && i < opening::Max_Line_Length;
			node = node->next(), ++i)
	{
		lineBuf[i] = node->move().index();
	}

	Line line(lineBuf, i);
	return EcoTable::specimen().getEco(m_line);
}


void
Game::setUndoLevel(unsigned level)
{
	m_maxUndoLevel = level;

	if (m_undoList.size() > m_maxUndoLevel)
	{
		unsigned n = m_undoList.size() - m_maxUndoLevel;
		unsigned r = mstl::min(m_undoList.size() - m_undoIndex, n);
		unsigned k = m_undoList.size() - r;

		// firstly erase redo's
		for (unsigned i = k; i < m_undoList.size(); ++i)
			delete m_undoList[i];

		m_undoList.resize(k);
		n -= r;

		// secondly erase undo's
		for (unsigned i = 0; i < n; ++i)
			delete m_undoList[i];

		m_undoList.erase(m_undoList.begin(), m_undoList.begin() + n);
		m_undoIndex = mstl::min(m_undoIndex, m_maxUndoLevel);
	}
}


bool
Game::transpose(Force flag)
{
	if (m_idn)
	{
		mstl::auto_ptr<MoveNode> root(m_startNode->clone());
		Board board(m_startBoard);

		root->transpose();
		board.transpose();

		if (!checkConsistency(root.get(), board, flag, true))
			return false;

		insertUndo(Revert_Game, Transpose, m_startNode);

		m_startNode = root.release();
		m_idn = chess960::twin(m_idn);
		m_startBoard.transpose();
		moveToMainlineStart();
		updateSubscriber(UpdateBoard | UpdatePgn | UpdateOpening | UpdateIllegalMoves);
	}

	return true;
}


unsigned
Game::cleanupVariations()
{
	unsigned k = CleanUp::cleanup(m_startNode, m_startBoard);
	unsigned n = k;

	while (k)
	{
		k = CleanUp::cleanup(m_startNode, m_startBoard);
		n += k;
	}

	return n;
}


void
Game::setSubscriber(SubscriberP subscriber, unsigned action)
{
	if ((m_subscriber = subscriber))
		moveToMainlineStart();
}


void
Game::setLanguages(LanguageSet const& set)
{
	if (m_wantedLanguages != set)
	{
		m_wantedLanguages = set;
		updateSubscriber(UpdatePgn | UpdateBoard);
	}
}


bool
Game::containsLanguage(edit::Key const& key, mstl::string const& lang) const
{
	MoveNode* node = key.findPosition(m_startNode, m_startBoard.plyNumber());
	return node && node->comment().containsLanguage(lang);
}


void
Game::refreshSubscriber()
{
	delete m_editNode;
	m_editNode = 0;
	updateSubscriber(Game::UpdateAll);
}


void
Game::updateSubscriber(unsigned action)
{
	if (!m_subscriber)
		return;

	if (action & UpdateIllegalMoves)
		m_containsIllegalMoves = m_startNode->containsIllegalMoves();

	updateLine();

	if (action & (UpdatePgn | UpdateOpening | UpdateLanguageSet))
	{
		typedef mstl::auto_ptr<edit::Root> Root;

		if (m_subscriber->mainlineOnly())
		{
			Root editNode(edit::Root::makeList(m_tags, m_idn, m_eco, m_startBoard, m_startNode));
			m_editNode = editNode.release();
			m_subscriber->updateEditor(m_editNode);
		}
		else
		{
			Root editNode(edit::Root::makeList(	m_tags,
															m_idn,
															m_eco,
															m_startBoard,
															m_languageSet,
															m_wantedLanguages,
															m_startNode));

			edit::Node::List diff;
			editNode->difference(m_editNode, diff);
//			m_subscriber->updateEditor(editNode.get());
			m_subscriber->updateEditor(diff, m_tags);
			delete m_editNode;
			m_editNode = editNode.release();
		}
	}

	if (action & UpdateBoard)
		goToCurrentMove();
}


Board
Game::board(edit::Key const& key) const
{
	Board board = m_startBoard;
	key.setBoard(m_startNode, board);
	return board;
}


mstl::string&
Game::printFen(mstl::string& result) const
{
	return m_currentBoard.toFen(result);
}


mstl::string&
Game::printFen(mstl::string const& key, mstl::string& result) const
{
	return board(key).toFen(result);
}

// vi:set ts=3 sw=3:
