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

#include "db_edit_node.h"
#include "db_move_node.h"
#include "db_board.h"
#include "db_annotation.h"
#include "db_mark_set.h"
#include "db_tag_set.h"

#include "m_limits.h"
#include "m_assert.h"

using namespace db::edit;


unsigned Node::linebreakThreshold			= 0;
unsigned Node::linebreakMaxLineLengthMain	= 0;
unsigned Node::linebreakMaxLineLengthVar	= 0;
unsigned Node::linebreakMinCommentLength	= 1;


static unsigned const DontSetBreaks = mstl::numeric_limits<unsigned>::max();


template <class List>
static void
deleteList(List& list)
{
	for (unsigned i = 0; i < list.size(); ++i)
		delete list[i];
}


Node::DisplayStyle Node::m_style = Node::CompactStyle;


Node::~Node() throw()				{}
Visitor::~Visitor() throw()		{}
Variation::~Variation() throw()	{ ::deleteList(m_list); }
Move::~Move() throw()				{ ::deleteList(m_list); }


Node::Type Action::type() const		{ return TAction; }
Node::Type Root::type() const			{ return TRoot; }
Node::Type Opening::type() const		{ return TOpening; }
Node::Type Languages::type() const	{ return TLanguages; }
Node::Type Variation::type() const	{ return TVariation; }
Node::Type PreComment::type() const	{ return TPreComment; }
Node::Type Move::type() const			{ return TMove; }
Node::Type Diagram::type() const		{ return TDiagram; }
Node::Type Ply::type() const			{ return TPly; }
Node::Type Comment::type() const		{ return TComment; }
Node::Type Annotation::type() const	{ return TAnnotation; }
Node::Type Marks::type() const		{ return TMarks; }
Node::Type Space::type() const		{ return TSpace; }


void Opening::visit(Visitor& visitor) const		{ visitor.opening(m_board, m_idn, m_eco); }
void Languages::visit(Visitor& visitor) const	{ visitor.languages(m_langSet); }
void Ply::visit(Visitor& visitor) const			{ visitor.move(m_moveNo, m_move); }
void Comment::visit(Visitor& visitor) const		{ visitor.comment(m_comment); }
void Annotation::visit(Visitor& visitor) const	{ visitor.annotation(m_annotation); }
void Marks::visit(Visitor& visitor) const			{ visitor.marks(m_marks); }


inline bool KeyNode::operator<(KeyNode const* node) const { return m_key < node->m_key; }
inline bool KeyNode::operator>(KeyNode const* node) const { return node->m_key < m_key; }

Key const& KeyNode::startKey() const	{ return m_key; }
Key const& KeyNode::endKey() const		{ return m_key; }


bool
KeyNode::operator==(KeyNode const* node) const
{
	return m_key == node->key() && Node::operator==(node);
}


bool
KeyNode::operator!=(KeyNode const* node) const
{
	return m_key != node->key() || Node::operator!=(node);
}


bool
Diagram::operator==(Node const* node) const
{
	M_ASSERT(node);
	M_ASSERT(dynamic_cast<Diagram const*>(node));
	M_ASSERT(m_key == static_cast<Diagram const*>(node)->m_key);

	return	m_fromColor == static_cast<Diagram const*>(node)->m_fromColor
			&& m_prefixBreak && static_cast<Diagram const*>(node)->m_prefixBreak
			&& m_board.isEqualPosition(static_cast<Diagram const*>(node)->m_board);
}


inline
Diagram::Diagram(Work& work, color::ID fromColor)
	:KeyNode(Key(work.key, PrefixDiagram))
	,m_board(work.board)
	,m_fromColor(fromColor)
	,m_prefixBreak(work.spacing != Move::NoSpace)
{
	work.spacing = ForcedBreak;
}


void
Diagram::visit(Visitor& visitor) const
{
	visitor.startDiagram(m_key);
	if (m_prefixBreak)
		visitor.linebreak(0, None);
	visitor.position(m_board, m_fromColor);
	visitor.endDiagram(m_key);
}


PreComment::PreComment(Work const& work, db::Comment const& comment)
	:KeyNode(work.key, PrefixComment)
	,m_comment(comment)
{
}


bool
PreComment::operator==(Node const* node) const
{
	M_ASSERT(node);
	M_ASSERT(dynamic_cast<PreComment const*>(node));
	M_ASSERT(m_key == static_cast<PreComment const*>(node)->m_key);

	return m_comment == static_cast<PreComment const*>(node)->m_comment;
}


void
PreComment::visit(Visitor& visitor) const
{
	visitor.comment(m_key, m_comment);
}


Ply::Ply(MoveNode const* move, unsigned moveno)
	:m_moveNo(moveno)
	,m_move(move->move())
{
}


bool
Ply::operator==(Node const* node) const
{
	M_ASSERT(node);
	M_ASSERT(dynamic_cast<Ply const*>(node));

	return	m_moveNo == static_cast<Ply const*>(node)->m_moveNo
			&& m_move == static_cast<Ply const*>(node)->m_move;
}


bool
Comment::operator==(Node const* node) const
{
	M_ASSERT(node);
	M_ASSERT(dynamic_cast<Comment const*>(node));

	return m_comment == static_cast<Comment const*>(node)->m_comment;
}


bool
Annotation::operator==(Node const* node) const
{
	M_ASSERT(node);
	M_ASSERT(dynamic_cast<Annotation const*>(node));

	return m_annotation == static_cast<Annotation const*>(node)->m_annotation;
}


bool
Marks::operator==(Node const* node) const
{
	M_ASSERT(node);
	M_ASSERT(dynamic_cast<Marks const*>(node));

	return m_marks == static_cast<Marks const*>(node)->m_marks;
}


void
Space::visit(Visitor& visitor) const
{
	if (m_level >= 0)
		visitor.linebreak(m_level, m_bracket);
	else
		visitor.space(m_bracket);
}


bool
Space::operator==(Node const* node) const
{
	M_ASSERT(node);
	M_ASSERT(dynamic_cast<Space const*>(node));

	return	m_level == static_cast<Space const*>(node)->m_level
			&& m_bracket == static_cast<Space const*>(node)->m_bracket;
}


bool
Opening::operator==(Node const* node) const
{
	M_ASSERT(node);
	M_ASSERT(dynamic_cast<Opening const*>(node));

	return	m_idn == static_cast<Opening const*>(node)->m_idn
			&& m_eco == static_cast<Opening const*>(node)->m_eco
			&& m_board.isEqualPosition(static_cast<Opening const*>(node)->m_board);
}


bool
Node::operator==(Node const* node) const
{
	M_ASSERT(!"unexpected call");
	return false;
}


void
Node::visit(Visitor& visitor, List const& nodes, TagSet const& tags)
{
	result::ID result = result::fromString(tags.value(tag::Result));

	visitor.start(result);

	for (unsigned i = 0; i < nodes.size(); ++i)
		nodes[i]->visit(visitor);

	visitor.finish(result);
}


Action::Action(Command command, unsigned level)
	:m_command(command)
	,m_level(level)
{
	M_ASSERT(command == Finish);
}


Action::Action(Command command)
	:m_command(command)
{
	M_ASSERT(command == Clear);
}


Action::Action(Command command, unsigned level, Key const& beforeKey)
	:m_command(command)
	,m_key1(beforeKey)
	,m_level(level)
{
	M_ASSERT(command == Insert);
}


Action::Action(Command command, unsigned level, Key const& startKey, Key const& endKey)
	:m_command(command)
	,m_key1(startKey)
	,m_key2(endKey)
	,m_level(level)
{
	M_ASSERT(command == Remove || command == Replace);
}


void
Action::visit(Visitor& visitor) const
{
	switch (m_command)
	{
		case Clear:		visitor.clear(); break;
		case Insert:	visitor.insert(m_level, m_key1); break;
		case Replace:	visitor.replace(m_level, m_key1, m_key2); break;
		case Remove:	visitor.remove(m_level, m_key1, m_key2); break;
		case Finish:	visitor.finish(m_level); break;
	}
}


Languages::Languages(MoveNode const* root)
{
	if (root)
		root->collectLanguages(m_langSet);
}


bool
Languages::operator==(Node const* node) const
{
	M_ASSERT(node);
	M_ASSERT(dynamic_cast<Languages const*>(node));

	return m_langSet == dynamic_cast<Languages const*>(node)->m_langSet;
}


Key const& Variation::startKey() const
{
	return m_list.empty() ? m_key : m_list.front()->startKey();
}


Key const&
Variation::endKey() const
{
	return m_list.empty() ? m_key : m_list.back()->endKey();
}


bool
Variation::operator==(Node const* node) const
{
	M_ASSERT(node);
	M_ASSERT(dynamic_cast<Variation const*>(node));

	if (m_key != static_cast<Variation const*>(node)->m_key)
		return false;

	if (m_list.size() != static_cast<Variation const*>(node)->m_list.size())
		return false;

	for (unsigned i = 0; i < m_list.size(); ++i)
	{
		if (*m_list[i] != static_cast<Variation const*>(node)->m_list[i])
			return false;
	}

	return true;
}


void
Variation::visit(Visitor& visitor) const
{
	visitor.startVariation(startKey(), endKey());

	for (unsigned i = 0; i < m_list.size(); ++i)
		m_list[i]->visit(visitor);

	visitor.endVariation(startKey(), endKey());
}


void
Variation::difference(Root const* root, Variation const* var, unsigned level, Node::List& nodes) const
{
	M_ASSERT(root);
	M_ASSERT(var);

	// Game::setComment()
	// Game::setAnnotation()
	// Game::exchangeMove()
	// Game::setMarks()
	//		replace current move and successor diagram/move
	//
	// Game::replaceNode()
	// Game::newMainline()
	// Game::removeMainline()
	// Game::promoteVariation()
	//		replace rest of variation
	//
	// Game::insertVariation()
	// Game::addVariation()
	//		insert variation
	//
	// Game::addMove()
	//		insert move
	//
	// Game::moveVariation()
	//		replace variations
	//
	// Game::changeVariation()
	//		replace variation
	//
	// Game::removeVariation()
	//		remove variation
	//
	// Game::insertMoves()
	//		remove variation
	//		insert moves
	//
	// Game::exchangeMoves()
	//		remove variation
	//		replace moves
	//
	// Game::truncateVariation()
	// Game::stripMoves()
	//		remove rest of variation
	//
	// Game::unstripMoves
	//		insert moves
	//
	// Game::stripAnnotations()
	// Game::stripComments()
	// Game::stripMarks()
	// Game::revertGame()
	// Game::resetGame()
	//		replace all
	//
	// Game::clear()
	//		remove all

	Key const& endVar = var->successor();

	unsigned	i = 0;
	unsigned k = 0;
	unsigned m = m_list.size();
	unsigned n = var->m_list.size();

	while (i < m && k < n)
	{
		KeyNode const* lhs = m_list[i];			// node from current game
		KeyNode const* rhs = var->m_list[k];	// node from previous game

		Type lhsType = lhs->type();
		Type rhsType = rhs->type();

		if (lhsType == rhsType)
		{
			M_ASSERT(lhs->key() == rhs->key());

			if (lhsType == TVariation)
			{
				Variation const* lhsVar = static_cast<Variation const*>(lhs);
				Variation const* rhsVar = static_cast<Variation const*>(rhs);

				lhsVar->difference(root, rhsVar, level + 1, nodes);
			}
			else if (*lhs != rhs)
			{
				if (lhsType == TMove)
				{
					if (	static_cast<Move const*>(lhs)->ply() == 0
						|| *static_cast<Move const*>(lhs)->ply() != static_cast<Move const*>(rhs)->ply())
					{
						KeyNode const* const* lhsFirst	= m_list.begin() + i + 1;
						KeyNode const* const* lhsLast		= m_list.end() - 1;
						KeyNode const* const* rhsFirst	= var->m_list.begin() + k + 1;
						KeyNode const* const* rhsLast		= var->m_list.end() - 1;

						while (	lhsFirst <= lhsLast
								&& rhsFirst <= rhsLast
								&& (*lhsLast)->type() == (*rhsLast)->type()
								&& *static_cast<Node const*>(*lhsLast) == static_cast<Node const*>(*rhsLast))
						{
							--lhsLast;
							--rhsLast;
						}

						++lhsLast;
						++rhsLast;

						Key const& before = rhs->endKey();
						Key const& after = rhsLast == var->m_list.end() ? endVar : (*rhsLast)->startKey();
						nodes.push_back(root->newAction(Action::Replace, level, before, after));
						nodes.insert(nodes.end(), m_list.begin() + i, lhsLast);
						nodes.push_back(root->newAction(Action::Finish, level));
						return;
					}
				}

				Key const& before	= rhs->endKey();
				Key const& after	= (k == n - 1) ? endVar : var->m_list[k + 1]->startKey();

				nodes.push_back(root->newAction(Action::Replace, level, before, after));
				nodes.push_back(lhs);
				nodes.push_back(root->newAction(Action::Finish, level));
			}

			++i;
			++k;
		}
		else // if (lhsType != rhsType)
		{
			enum { Insert, Remove } action;

			switch (rhsType)
			{
				case TPreComment:
					action = Remove;
					break;

				case TDiagram:
					action = (lhsType == TPreComment) ? Insert : Remove;
					break;

				case TMove:
					action = Insert;
					break;

				case TVariation:
					action = (lhsType == TMove) ? Remove : Insert;
					break;

				default:
					M_ASSERT(!"should not happen");
					break;
			}

			switch (action)
			{
				case Insert:
					nodes.push_back(root->newAction(Action::Insert, level, rhs->endKey()));
					nodes.push_back(lhs);
					nodes.push_back(root->newAction(Action::Finish, level));
					++i;
					break;

				case Remove:
					Key const& endKey = (k == n - 1) ? endVar : var->m_list[k + 1]->startKey();
					nodes.push_back(root->newAction(Action::Remove, level, rhs->startKey(), endKey));
					++k;
					break;
			}
		}
	}

	if (i < m)
	{
		nodes.push_back(root->newAction(Action::Insert, level, endVar));
		nodes.insert(nodes.end(), m_list.begin() + i, m_list.end());
		nodes.push_back(root->newAction(Action::Finish, level));
	}

	if (k < n)
	{
		Key const& before = (k == 0) ? var->startKey() : var->m_list[k - 1]->endKey();
		nodes.push_back(root->newAction(Action::Remove, level, before, endVar));
	}
}


bool
Move::operator==(Node const* node) const
{
	M_ASSERT(node);
	M_ASSERT(dynamic_cast<Move const*>(node));
	M_ASSERT(m_key == static_cast<Move const*>(node)->m_key);

	if (m_list.size() != dynamic_cast<Move const*>(node)->m_list.size())
		return false;

	for (unsigned i = 0; i < m_list.size(); ++i)
	{
		if (*m_list[i] != dynamic_cast<Move const*>(node)->m_list[i])
			return false;
	}

	return true;
}


Move::Move(Work& work)
	:KeyNode(work.key)
	,m_ply(0)
	,m_endKey(m_key)
{
	if (work.spacing & ForcedBreak)
	{
		m_list.push_back(new Space(0, work.bracket));
		work.plyCount = 0;
	}
	else if (work.spacing & RequiredBreak)
	{
		m_list.push_back(new Space(0, work.bracket));
		work.plyCount = 0;
	}
	else if (work.spacing & PrefixBreak)
	{
		m_list.push_back(new Space(work.level, work.bracket));
		work.plyCount = 0;
	}
	else if (work.spacing & PrefixSpace)
	{
		m_list.push_back(new Space(work.bracket));
	}

	work.spacing = None;
	work.bracket = None;
}


Move::Move(Key const& key, unsigned moveNumber, unsigned spacing, MoveNode const* move)
	:KeyNode(key)
	,m_endKey(m_key)
{
	M_ASSERT(!move->atLineStart());

	if (spacing & RequiredBreak)
		m_list.push_back(new Space(0));
	else if (spacing & PrefixSpace)
		m_list.push_back(new Space);

	m_ply = color::isWhite(move->move().color()) ? new Ply(move, moveNumber) : new Ply(move);
	m_list.push_back(m_ply);

	if (move->hasAnnotation())
		m_list.push_back(new Annotation(move->annotation()));

	if (move->hasMark())
		m_list.push_back(new Marks(move->marks()));
}


Move::Move(Work& work, MoveNode const* move)
	:KeyNode(work.key)
	,m_endKey(m_key)
{
	M_ASSERT(!move->atLineStart());

	bool useMoveNo = work.board.whiteToMove() || work.needMoveNo;

	work.needMoveNo = false;

	if (work.spacing & ForcedBreak)
	{
		m_list.push_back(new Space(0, work.bracket));
		work.plyCount = 0;
		useMoveNo = true;
	}
	else if (work.spacing & PrefixBreak)
	{
		m_list.push_back(new Space(work.level, work.bracket));
		work.plyCount = 0;
		useMoveNo = true;
	}
	else if (m_style == ColumnStyle)
	{
		if (	work.spacing == PrefixSpace
			|| (!move->atLineStart() && work.board.whiteToMove()))
		{
			m_list.push_back(new Space(0, work.bracket));
			work.plyCount = 0;
			useMoveNo = true;
		}
	}
	else if (work.spacing & RequiredBreak)
	{
		m_list.push_back(new Space(0, work.bracket));
		work.plyCount = 0;
		useMoveNo = true;
	}
	else if (work.spacing == PrefixSpace)
	{
		m_list.push_back(new Space(work.bracket));
	}

	m_ply = useMoveNo ? new Ply(move, work.board.moveNumber()) : new Ply(move);
	m_list.push_back(m_ply);

	unsigned spacing = PrefixSpace;

	if (move->hasAnnotation())
	{
		m_list.push_back(new Annotation(move->annotation()));
		spacing = PrefixSpace;
	}

	if (move->hasMark())
	{
		m_list.push_back(new Marks(move->marks()));
		spacing = PrefixSpace;
	}

	if (move->hasComment())
	{
		if (unsigned length = move->comment().countLength(*work.wantedLanguages))
		{
			if (work.level == 0 && length > linebreakMinCommentLength)
			{
				m_list.push_back(new Space(work.level));
				spacing = PrefixBreak;
			}
			else
			{
				m_list.push_back(new Space);
				spacing = PrefixSpace;
			}

			m_list.push_back(new Comment(move->comment()));
			m_endKey.exchangePrefix(PrefixComment);
			work.plyCount = 0;
			work.needMoveNo = true;
		}
	}

	if (move->atLineEnd() && work.level > 0)
		m_list.push_back(new Space(Close));

	work.spacing = spacing;
	work.bracket = None;
}


Key const& Move::startKey() const	{ return m_key; }
Key const& Move::endKey() const		{ return m_endKey; }


void
Move::visit(Visitor& visitor) const
{
	visitor.startMove(m_key);

	for (unsigned i = 0; i < m_list.size(); ++i)
		m_list[i]->visit(visitor);

	visitor.endMove(m_key);
}


Root::~Root() throw()
{
	delete m_opening;
	delete m_languages;
	delete m_variation;

	for (unsigned i = 0; i < m_nodes.size(); ++i)
		delete m_nodes[i];
}


void
Root::visit(Visitor& visitor) const
{
	visitor.start(m_result);
	m_opening->visit(visitor);
	m_languages->visit(visitor);
	m_variation->visit(visitor);
	visitor.finish(m_result);
}


Node*
Root::newAction(Action::Command command) const
{
	Node* node = new Action(command);
	m_nodes.push_back(node);
	return node;
}


Node*
Root::newAction(Action::Command command, unsigned level) const
{
	Node* node = new Action(command, level);
	m_nodes.push_back(node);
	return node;
}


Node*
Root::newAction(Action::Command command, unsigned level, Key const& beforeKey) const
{
	Node* node = new Action(command, level, beforeKey);
	m_nodes.push_back(node);
	return node;
}


Node*
Root::newAction(Action::Command command, unsigned level, Key const& startKey, Key const& endKey) const
{
	Node* node = new Action(command, level, startKey, endKey);
	m_nodes.push_back(node);
	return node;
}


void
Root::difference(Root const* root, List& nodes) const
{
	for (unsigned i = 0; i < m_nodes.size(); ++i)
		delete m_nodes[i];

	if (root == 0)
	{
		nodes.push_back(m_opening);
		nodes.push_back(m_languages);
		nodes.push_back(newAction(Action::Clear));

		if (!m_variation->empty())
		{
			nodes.push_back(newAction(Action::Insert, 0, Key()));
			nodes.push_back(m_variation);
		}
	}
	else
	{
		if (*m_opening != root->m_opening)
			nodes.push_back(m_opening);

		if (*m_languages != root->m_languages)
			nodes.push_back(m_languages);

		m_variation->difference(this, root->m_variation, 0, nodes);
	}
}


Root*
Root::makeList(TagSet const& tags,
					uint16_t idn,
					Eco eco,
					db::Board const& startBoard,
					MoveNode const* node)
{
	M_REQUIRE(node);
	M_REQUIRE(node->atLineStart());

	unsigned	linebreakMaxLineLength = ::DontSetBreaks;

	if (m_style != ColumnStyle && node->countHalfMoves() > linebreakThreshold)
		linebreakMaxLineLength = linebreakMaxLineLengthMain;

	unsigned	moveNumber	= startBoard.moveNumber();
	unsigned	plyNumber	= startBoard.plyNumber();
	unsigned	spacing		= NoSpace;
	Key		key;

	Root* root = new Root;

	root->m_opening = new Opening(startBoard, idn, eco);
	root->m_languages = new Languages;
	root->m_variation = new Variation(key);
	root->m_result = result::fromString(tags.value(tag::Result));

	KeyNode::List& result = root->m_variation->m_list;

	result.reserve(2*node->countHalfMoves() + 10);
	key.addPly(plyNumber);
	result.push_back(new Move(key));

	unsigned plyCount = 0;

	for (node = node->next(); node; node = node->next())
	{
		key.exchangePly(++plyNumber);
		if (plyCount++ == linebreakMaxLineLength)
		{
			spacing = RequiredBreak;
			plyCount = 0;
		}
		result.push_back(new Move(key, moveNumber, spacing, node));
		if (color::isBlack(node->move().color()))
			++moveNumber;
		spacing = PrefixSpace;
	}

	return root;
}


Root*
Root::makeList(TagSet const& tags,
					uint16_t idn,
					Eco eco,
					db::Board const& startBoard,
					LanguageSet const& langSet,
					LanguageSet const& wantedLanguages,
					MoveNode const* node)
{
	M_REQUIRE(node);
	M_REQUIRE(node->atLineStart());

	Work work;
	work.board = startBoard;
	work.languages = new Languages(node);
	work.spacing = PrefixBreak;
	work.bracket = None;
	work.needMoveNo = true;
	work.wantedLanguages = &wantedLanguages;
	work.level = 0;
	work.linebreakMaxLineLength = ::DontSetBreaks;

	if (m_style != ColumnStyle && node->countHalfMoves() > linebreakThreshold)
		work.linebreakMaxLineLength = linebreakMaxLineLengthMain;

	Root*			root	= new Root;
	Variation*	var	= new Variation(work.key);

	root->m_opening = new Opening(startBoard, idn, eco);
	root->m_languages = work.languages;
	root->m_variation = var;
	root->m_result = result::fromString(tags.value(tag::Result));

	makeList(work, var->m_list, node);

	return root;
}


void
Root::makeList(Work& work, KeyNode::List& result, MoveNode const* node)
{
	M_ASSERT(node);
	M_ASSERT(node->atLineStart());

	result.reserve(2*node->countHalfMoves() + 10);
	work.key.addPly(work.board.plyNumber());
	result.push_back(new Move(work));

	if (node->prev())
		++work.level;

	if (node->hasComment())
	{
		if (unsigned length = node->comment().countLength(*work.wantedLanguages))
		{
			result.push_back(new PreComment(work, node->comment()));
			work.spacing = (length > linebreakMinCommentLength) ? PrefixBreak : PrefixSpace;
			work.needMoveNo = true;
			work.bracket = None;
		}
	}

	if (	node->annotation().contains(nag::Diagram)
		|| node->annotation().contains(nag::DiagramFromBlack))
	{
		result.push_back(new Diagram(
			work, node->annotation().contains(nag::Diagram) ? color::White : color::Black));
		work.needMoveNo = true;
	}

	work.key.removePly();
	work.plyCount = 0;

	for (node = node->next(); node; node = node->next())
	{
		work.key.addPly(work.board.plyNumber() + 1);

		if (work.plyCount++ == work.linebreakMaxLineLength)
		{
			work.spacing |= RequiredBreak;
			work.plyCount = 0;
		}

		result.push_back(new Move(work, node));

		if (	node->annotation().contains(nag::Diagram)
			|| node->annotation().contains(nag::DiagramFromBlack))
		{
			work.board.doMove(node->move());
			result.push_back(new Diagram(
				work,
				node->annotation().contains(nag::Diagram) ? color::White : color::Black));
			work.board.undoMove(node->move());
			work.plyCount = 0;
		}

		if (node->hasVariation())
		{
			for (unsigned i = 0; i < node->variationCount(); ++i)
			{
				Board	board(work.board);
				Key	succKey;

				if (i + 1 < node->variationCount())
				{
					succKey = work.key;
					succKey.addVariation(i + 1);
					succKey.addPly(work.board.plyNumber());
				}
				else if (node->next())
				{
					succKey = work.key;
					succKey.exchangePly(work.board.plyNumber() + 2);
				}

				work.key.addVariation(i);
				work.spacing = PrefixBreak;
				work.bracket = Open;
				work.needMoveNo = true;

				Variation* var = new Variation(work.key, succKey);
				result.push_back(var);

				if (	work.linebreakMaxLineLength != ::DontSetBreaks
					&& linebreakMaxLineLengthVar > 0
					&& node->variation(i)->countNodes() > linebreakMaxLineLengthVar)
				{
					work.linebreakMaxLineLength = linebreakMaxLineLengthVar;
				}

				makeList(work, var->m_list, node->variation(i));
				M_ASSERT(work.level > 0);
				--work.level;
				work.key.removeVariation();
				work.board = board;
			}

			work.spacing = PrefixBreak;
			work.needMoveNo = true;
			work.plyCount = 0;
		}

		work.board.doMove(node->move());
		work.key.removePly();
	}
}

// vi:set ts=3 sw=3:
