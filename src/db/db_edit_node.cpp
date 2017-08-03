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
// Copyright: (C) 2011-2013 Gregor Cramer
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
#include "db_move_info_set.h"
#include "db_tag_set.h"
#include "db_engine_list.h"

#include "sys_utf8_codec.h"

#include "m_stack.h"
#include "m_limits.h"
#include "m_utility.h"
#include "m_cast.h"
#include "m_assert.h"

using namespace db::edit;


static unsigned const DontSetBreaks = mstl::numeric_limits<unsigned>::max();


template <class List>
static void
deleteList(List& list)
{
	for (unsigned i = 0; i < list.size(); ++i)
		delete list[i];
}


struct Node::Spacing
{
	enum Type
	{
		Zero, Space, Open, Close, Break, Para
	};

	enum Context
	{
		None, Comment, MoveInfo, Annotation,
		PreComment, Diagram, Result, StartVariation, EndVariation
	};

	struct Token
	{
		Token(unsigned lvl, Type t)
			:level(mstl::min(lvl, 255u))
			,number(0)
			,count(0)
			,space(t)
			,context(None)
		{
		}

		Token(unsigned lvl, Type t, Context c)
			:level(mstl::min(lvl, 255u))
			,number(0)
			,count(0)
			,space(t)
			,context(c)
		{
		}

		Token(unsigned lvl, Type t, unsigned no, unsigned last)
			:level(mstl::min(lvl, 255u))
			,number(mstl::min(no, 255u))
			,count(last)
			,space(t)
			,context(None)
		{
		}

		bool operator==(Type t) const { return space == t; }
		bool operator!=(Type t) const { return space != t; }

		uint8_t level;
		uint8_t number;
		uint8_t count;
		uint8_t space:4;
		uint8_t context:4;
	};

	typedef mstl::stack<Token> TokenList;

	Spacing();

	void incrPlyCount();

	void pushSpace();
	void pushOpen(unsigned number, unsigned count);
	void pushClose(unsigned number, unsigned count);
	void pushBreak();
	void pushBreak(unsigned level);
	void pushParagraph(Context context);
	void pushSpaceOrParagraph(Context context);
	void pushBreakOrParagraph(Context context);

	void pop(List& list);

	bool m_isVirgin;

	TokenList	m_tokenList;
	unsigned		m_level;
	unsigned		m_plyCount;
	unsigned		m_commentCount;
	unsigned		m_linebreakMaxLineLength;
	unsigned		m_displayStyle;
	unsigned		m_moveInfoTypes;
};


Node::Spacing::Spacing()
	:m_isVirgin(true)
	,m_tokenList(1, Token(0, Zero))
	,m_level(0)
	,m_plyCount(0)
	,m_linebreakMaxLineLength(::DontSetBreaks)
	,m_displayStyle(display::CompactStyle)
	,m_moveInfoTypes(0)
{
}


void
Node::Spacing::incrPlyCount()
{
	if (++m_plyCount == m_linebreakMaxLineLength)
	{
		m_tokenList.push(Token(0, Break));
		m_tokenList.push(Token(0, Break));
		m_plyCount = 0;
	}

	m_isVirgin = false;
}


void
Node::Spacing::pushOpen(unsigned number, unsigned count)
{
	while (m_tokenList.top() == Space || m_tokenList.top() == Break || m_tokenList.top() == Para)
		m_tokenList.pop();

	Type type = m_level > 1 || !(m_displayStyle & display::ParagraphSpacing) ? Break : Para;

	if (	(m_level > 1 || !(m_displayStyle & display::ParagraphSpacing))
		&& !(m_displayStyle & display::ShowVariationNumbers))
	{
		number = 0;
	}

#if 0
	// don't use paragraph spacing between variations
	if (m_tokenList.pop() == Close || m_tokenList.pop() == CloseFold)
		type = Break;
#endif

	m_tokenList.push(Token(m_level, type));
	m_tokenList.push(Token(m_level, Open, number, count));
	m_plyCount = 0;
}


void
Node::Spacing::pushClose(unsigned number, unsigned count)
{
   m_tokenList.clear();
   m_tokenList.push(Token(0, Zero));
   m_tokenList.push(Token(m_level, Close, number, count));
}


void
Node::Spacing::pushSpace()
{
   if (!m_isVirgin && m_tokenList.size() == 1)
   	m_tokenList.push(Token(m_level, Space));
}


void
Node::Spacing::pushBreak(unsigned level)
{
	if (	!m_isVirgin
		&& (m_tokenList.top() != Break || level == 0)
		&& m_tokenList.top() != Para
		&& m_tokenList.top() != Open)
	{
		if (m_tokenList.top() == Space || m_tokenList.top() == Break)
			m_tokenList.pop();

		m_tokenList.push(Token(level, Break));
		m_plyCount = 0;
	}
}


void
Node::Spacing::pushBreak()
{
	pushBreak(m_level);
}


void
Node::Spacing::pushParagraph(Context context)
{
	if (!m_isVirgin)
	{
		if (context != None && m_tokenList.top() == Para && m_tokenList.top().context == context)
		{
			m_tokenList.top() = Token(m_level, Break);
		}
		else if (m_tokenList.top() != Para && m_tokenList.top() != Open)
		{
			if ((m_level == 0 || context == Diagram) && (m_displayStyle & display::ParagraphSpacing))
			{
				while (m_tokenList.top() == Break || m_tokenList.top() == Space)
					m_tokenList.pop();

				if (m_tokenList.top() != Para)
					m_tokenList.push(Token(m_level, Para, context));
				else if (context != None && m_tokenList.top().context == context)
					m_tokenList.top() = Token(m_level, Break);
			}
			else if (context == EndVariation)
			{
				pushBreak(m_level + 1);
			}
			else
			{
				pushBreak();
			}
		}

		m_plyCount = 0;
	}
}


void
Node::Spacing::pushSpaceOrParagraph(Context context)
{
	if (m_level == 0)
		pushParagraph(context);
	else
		pushSpace();
}


void
Node::Spacing::pushBreakOrParagraph(Context context)
{
	if (m_level == 0)
		pushParagraph(context);
	else
		pushBreak(0);
}


void
Node::Spacing::pop(List& list)
{
	for (unsigned i = 1; i < m_tokenList.size(); ++i)
	{
		Token const& token = m_tokenList[i];

		switch (token.space)
		{
			case None:	/* skip */ break;
			case Space:	list.push_back(new edit::Space); break;
			case Close:	/* skip */ break;
			case Para:	list.push_back(new edit::Space(token.level)); // fallthru
			case Break:	list.push_back(new edit::Space(token.level)); break;

			case Open:
				if (token.number)
					list.push_back(new edit::Space(token.level, token.number, token.count, true));
				else
					list.push_back(new edit::Space(Node::Open));
				break;
		}
	}

	m_tokenList.clear();
	m_tokenList.push(Token(0, Zero));
}


struct Node::Work : public Node::Spacing
{
	Work();
	~Work();

	LanguageSet const*	m_wantedLanguages;
	EngineList const*		m_engineList;

	db::Board				m_board;
	Languages*				m_languages;
	result::ID				m_result;
	termination::State	m_termination;
	Key						m_key;
	MoveNode*				m_emptyLine;
	bool						m_needMoveNo;
	bool						m_isFolded;
	bool						m_isEmpty;
	unsigned					m_linebreakMaxLineLengthVar;
	unsigned					m_linebreakMinCommentLength;
};


Node::Work::Work()
	:m_wantedLanguages(0)
	,m_engineList(0)
	,m_languages(0)
	,m_result(result::Unknown)
	,m_termination(termination::None)
	,m_emptyLine(0)
	,m_needMoveNo(true)
	,m_isFolded(false)
	,m_linebreakMaxLineLengthVar(0)
	,m_linebreakMinCommentLength(0)
{
}


Node::Work::~Work() { delete m_emptyLine; }


Node::~Node()				{}
Visitor::~Visitor()		{}
Variation::~Variation()	{ ::deleteList(m_list); }
Move::~Move()				{ ::deleteList(m_list); }


Node::Type Action::type() const		{ return TAction; }
Node::Type Root::type() const			{ return TRoot; }
Node::Type Opening::type() const		{ return TOpening; }
Node::Type Languages::type() const	{ return TLanguages; }
Node::Type Variation::type() const	{ return TVariation; }
Node::Type Move::type() const			{ return TMove; }
Node::Type Diagram::type() const		{ return TDiagram; }
Node::Type Ply::type() const			{ return TPly; }
Node::Type Comment::type() const		{ return TComment; }
Node::Type Annotation::type() const	{ return TAnnotation; }
Node::Type States::type() const		{ return TStates; }
Node::Type Marks::type() const		{ return TMarks; }
Node::Type Space::type() const		{ return TSpace; }


void Opening::visit(Visitor& visitor) const		{ visitor.opening(m_board, m_variant, m_idn, m_eco); }
void Languages::visit(Visitor& visitor) const	{ visitor.languages(m_langSet); }
void Ply::visit(Visitor& visitor) const			{ visitor.move(m_moveNo, m_move); }
void Comment::visit(Visitor& visitor) const		{ visitor.comment(m_position, m_varPos, m_comment); }
void Marks::visit(Visitor& visitor) const			{ visitor.marks(m_hasMarks); }


Key const& KeyNode::startKey() const	{ return m_key; }
Key const& KeyNode::endKey() const		{ return m_key; }


bool
Node::operator<(Node const* node) const
{
	M_ASSERT(node);
	return type() < node->type();
}


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

	Diagram const* diagram = mstl::safe_cast_ptr<Diagram const>(node);
	return m_fromColor == diagram->m_fromColor && m_board.isEqualZHPosition(diagram->m_board);
}


inline
Diagram::Diagram(Work& work, color::ID fromColor)
	:KeyNode(Key(work.m_key, PrefixDiagram))
	,m_board(work.m_board)
	,m_fromColor(fromColor)
{
}


void
Diagram::visit(Visitor& visitor) const
{
	visitor.startDiagram(m_key);
	visitor.position(m_board, m_fromColor);
	visitor.endDiagram(m_key);
}


Ply::Ply(MoveNode const* move, unsigned moveno)
	:m_moveNo(moveno)
	,m_move(move->move())
{
	M_ASSERT(!move->move().isEmpty());
}


bool
Ply::operator==(Node const* node) const
{
	M_ASSERT(node);

	Ply const* ply = mstl::safe_cast_ptr<Ply const>(node);
	return m_moveNo == ply->m_moveNo && m_move == ply->m_move;
}


bool
Comment::operator==(Node const* node) const
{
	M_ASSERT(node);

	Comment const* comment = mstl::safe_cast_ptr<Comment const>(node);

	return	m_varPos == comment->m_varPos
			&& m_position == comment->m_position
			&& m_comment == comment->m_comment;
}


bool
Comment::operator<(Node const* node) const
{
	M_ASSERT(node);

	if (type() < node->type())	return true;
	if (type() > node->type())	return false;

	Comment const* comment = static_cast<Comment const*>(node);

	if (m_varPos < comment->m_varPos) return true;
	if (m_varPos > comment->m_varPos) return false;

	return m_position < comment->m_position;
}


Annotation::Annotation(	Position position,
								db::Annotation const& annotation,
								DisplayType displayType,
								bool skipDiagram)
	:m_position(position)
	,m_displayType(displayType)
{
	switch (displayType)
	{
		case Numerical:	m_annotation.setUsualNags(annotation); break;
		case Textual:		m_annotation.setUnusualNags(annotation); break;
		case All:			m_annotation = annotation; break;
	}

	if (skipDiagram)
		m_annotation.removeDiagramNags();
}


bool
Annotation::operator==(Node const* node) const
{
	M_ASSERT(node);

	Annotation const* annotation = mstl::safe_cast_ptr<Annotation const>(node);

	return	m_position == annotation->m_position
			&& m_displayType == annotation->m_displayType
			&& m_annotation == annotation->m_annotation;
}


bool
Annotation::operator<(Node const* node) const
{
	M_ASSERT(node);

	if (type() < node->type())	return true;
	if (type() > node->type())	return false;

	return m_position < static_cast<Annotation const*>(node)->m_position;
}


void
Annotation::visit(Visitor& visitor) const
{
	visitor.annotation(m_annotation, m_displayType);
}


States::States(MoveNode const& node)
	:m_threefoldRepetition(node.threefoldRepetition())
	,m_fiftyMoveRule(node.fiftyMoveRule())
{
}


bool
States::operator==(Node const* node) const
{
	M_ASSERT(node);

	States const* states = mstl::safe_cast_ptr<States const>(node);

	return	m_threefoldRepetition == states->m_threefoldRepetition
			&& m_fiftyMoveRule == static_cast<States const*>(node)->m_fiftyMoveRule;
}


void
States::visit(Visitor& visitor) const
{
	visitor.states(m_threefoldRepetition, m_fiftyMoveRule);
}


Marks::Marks(MarkSet const& marks)
	:m_hasMarks(!marks.isEmpty())
{
}


bool
Marks::operator==(Node const* node) const
{
	M_ASSERT(node);
	return m_hasMarks == mstl::safe_cast_ptr<Marks const>(node)->m_hasMarks;
}


void
Space::visit(Visitor& visitor) const
{
	if (m_level >= 0 && m_varNo == 0)
	{
		visitor.linebreak(m_level);
	}
	else if (!m_asNumber || m_level <= 0 || 3 < m_level)
	{
		visitor.space(m_bracket, m_varNo, m_varCount);
	}
	else
	{
		mstl::string s;

//		if (m_varCount == 1)
//		{
//			s.append('-');
//		}
//		else
		{
			switch (m_level)
			{
				case 1: s.format("%u", m_varNo); break;
				case 2: s.append(char(((m_varNo - 1) % 26) + 'a')); break;
				case 3: s.appendSmallRomanNumber(m_varNo); break;
			}
		}

		visitor.number(s, m_varNo == 1);
	}
}


bool
Space::operator==(Node const* node) const
{
	M_ASSERT(node);

	Space const* space = mstl::safe_cast_ptr<Space const>(node);

	return	m_level == space->m_level
			&& m_bracket == space->m_bracket
			&& m_varNo == space->m_varNo
			&& (m_varNo == m_varCount) == (space->m_varNo == space->m_varCount);
}


bool
Opening::operator==(Node const* node) const
{
	M_ASSERT(node);
	M_ASSERT(dynamic_cast<Opening const*>(node));

	return	m_idn == static_cast<Opening const*>(node)->m_idn
			&& m_eco == static_cast<Opening const*>(node)->m_eco
			&& m_board.isEqualZHPosition(static_cast<Opening const*>(node)->m_board);
}


bool
Node::operator==(Node const* node) const
{
	M_ASSERT(!"unexpected call");
	return false;
}


void
Node::visit(Visitor& visitor,
				List const& nodes,
				TagSet const& tags,
				termination::State termination,
				color::ID toMove)
{
	result::ID result = result::fromString(tags.value(tag::Result));

	visitor.start(result);

	for (unsigned i = 0; i < nodes.size(); ++i)
		nodes[i]->visit(visitor);

	visitor.finish(result, termination, toMove);
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
Action::replace(unsigned level, Key const& start, Key const& end)
{
	m_level = level;
	m_key1 = start;
	m_key2 = end;
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
	return m_langSet == mstl::safe_cast_ptr<Languages const>(node)->m_langSet;
}


Key const&
Variation::startKey() const
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

	Variation const* variation = mstl::safe_cast_ptr<Variation const>(node);

	if (m_key != variation->m_key)
		return false;

	if (m_list.size() != variation->m_list.size())
		return false;

	for (unsigned i = 0; i < m_list.size(); ++i)
	{
		if (*m_list[i] != variation->m_list[i])
			return false;
	}

	return true;
}


void
Variation::visit(Visitor& visitor) const
{
	Key key(startKey());
	key.removePly();

	visitor.startVariation(key, startKey(), endKey());

	for (unsigned i = 0; i < m_list.size(); ++i)
		m_list[i]->visit(visitor);

	visitor.endVariation(key, startKey(), endKey());
}


void
Variation::difference(Root const* root, Variation const* var, unsigned level, Node::List& nodes) const
{
	M_ASSERT(root);
	M_ASSERT(var);

	Key const* endKey = &var->successor();

	unsigned	i = 0;
	unsigned k = 0;
	unsigned m = m_list.size();
	unsigned n = var->m_list.size();

	while (i < m && k < n)
	{
		KeyNode const* lhs = m_list[i];			// node from current game
		KeyNode const* rhs = var->m_list[k];	// node from previous game

		if (lhs->key() < rhs->key())
		{
			unsigned ii = i;

			do
				++ii;
			while (ii < m && m_list[ii]->key() < rhs->key());

			nodes.push_back(root->newAction(Action::Insert, level, rhs->startKey()));
			nodes.insert(nodes.end(), m_list.begin() + i, m_list.begin() + ii);
			nodes.push_back(root->newAction(Action::Finish, level));
			i = ii;
		}
		else if (rhs->key() < lhs->key())
		{
			do
				++k;
			while (k < n && var->m_list[k]->key() < lhs->key());

			Key const& after = k == n ? *endKey : var->m_list[k]->startKey();
			pushRemove(root, nodes, level, rhs->startKey(), after);
		}
		else
		{
			Type lhsType = lhs->type();
			Type rhsType = rhs->type();

			if (lhsType == rhsType)
			{
				if (lhsType == TVariation)
				{
					Variation const* lhsVar = static_cast<Variation const*>(lhs);
					Variation const* rhsVar = static_cast<Variation const*>(rhs);

					lhsVar->difference(root, rhsVar, level + 1, nodes);
				}
				else if (*lhs != rhs)
				{
					bool done = false;

					if (lhsType == TMove)
					{
						const Ply* lhsPly = static_cast<Move const*>(lhs)->ply();
						const Ply* rhsPly = static_cast<Move const*>(rhs)->ply();

						if (lhsPly && rhsPly)
						{
							List::const_iterator lhsLast	= m_list.begin() + i + 1;
							List::const_iterator rhsLast	= var->m_list.begin() + k + 1;
							List::const_iterator lhsEnd	= m_list.end();
							List::const_iterator rhsEnd	= var->m_list.end();

							while	(	lhsLast < lhsEnd
									&& rhsLast < rhsEnd
									&& (*lhsLast)->type() == TMove
									&& (*rhsLast)->type() == TMove
									&& **lhsLast != *rhsLast)
							{
								M_ASSERT((*lhsLast)->key() == (*rhsLast)->key());
								++lhsLast; ++rhsLast;
							}

							List::const_iterator lhsIter = m_list.begin() + i;
							List::const_iterator rhsIter = var->m_list.begin() + k;

							Key const& before	= rhs->endKey();
							Key const& after	= rhsLast == var->m_list.end() ? *endKey : (*rhsLast)->startKey();

							nodes.push_back(root->newAction(Action::Replace, level, before, after));
							nodes.insert(nodes.end(), lhsIter, lhsLast);
							nodes.push_back(root->newAction(Action::Finish, level));

							for ( ; lhsIter != lhsLast; ++lhsIter, ++rhsIter)
							{
								Move const* m1 = static_cast<Move const*>(*lhsIter);
								Move const* m2 = static_cast<Move const*>(*rhsIter);

								const_cast<Move*>(m1)->markDifferences(*m2);
							}

							i = lhsLast - m_list.begin() - 1;
							k = rhsLast - var->m_list.begin() - 1;
							done = true;
						}
						else if (lhsPly == 0)
						{
							List::const_iterator rhsIter	= var->m_list.begin() + k;
							List::const_iterator rhsEnd	= var->m_list.end();

							for ( ; rhsIter != rhsEnd; ++rhsIter)
							{
								if (	(*rhsIter)->type() == TMove
									&& static_cast<Move const*>(*rhsIter)->ply() == 0)
								{
									Move const* m1 = static_cast<Move const*>(lhs);
									Move const* m2 = static_cast<Move const*>(*rhsIter);

									const_cast<Move*>(m1)->markDifferences(*m2);
									break;
								}
							}
						}
					}

					if (!done)
					{
						Key const& before	= rhs->endKey();
						Key const& after	= (k == n - 1) ? *endKey : var->m_list[k + 1]->startKey();

						nodes.push_back(root->newAction(Action::Replace, level, before, after));
						nodes.push_back(lhs);
						nodes.push_back(root->newAction(Action::Finish, level));
					}
				}

				++i;
				++k;
			}
			else
			{
				enum { Insert, Remove } action;

				switch (rhsType)
				{
					case TDiagram:		action = Remove; break;
					case TMove:			action = Insert; break;
					case TVariation:	action = (lhsType == TMove) ? Remove : Insert; break;
					default:				M_ASSERT(!"should not happen"); return;
				}

				switch (action)
				{
					case Insert:
					{
						nodes.push_back(root->newAction(Action::Insert, level, rhs->startKey()));
						nodes.push_back(lhs);
						nodes.push_back(root->newAction(Action::Finish, level));
						++i;
						break;
					}

					case Remove:
						if (rhsType == TDiagram)
						{
							Key const& after = (k == n - 1) ? *endKey : var->m_list[k + 1]->startKey();
							pushRemove(root, nodes, level, rhs->startKey(), after);
						}
						else
						{
							Variation const* variation = mstl::safe_cast_ptr<Variation const>(rhs);

							Key const& key		= variation->key();
							Key const& succ	= variation->successor();

							pushRemove(root, nodes, level, key, succ);

							if (*endKey == key)
								endKey = &succ;
						}

						++k;
						break;
				}
			}
		}
	}

	if (i < m)
	{
		List::const_iterator firstNode	= m_list.begin() + i;
		List::const_iterator lastNode		= m_list.end();

		nodes.push_back(root->newAction(Action::Insert, level, *endKey));
		nodes.insert(nodes.end(), firstNode, lastNode);
		nodes.push_back(root->newAction(Action::Finish, level));
	}

	if (k < n)
	{
		Key before	= var->m_list[k]->type() == TVariation
						? var->m_list[k]->key()
						: var->m_list[k]->startKey();
		Key after	= var->m_list[n - 1]->type() == TVariation
						? mstl::safe_cast_ptr<Variation const>(var->m_list[n - 1])->successor()
						: *endKey;

		pushRemove(root, nodes, level, before, after);
	}
}


void
Variation::pushRemove(	Root const* root,
								Node::List& nodes,
								unsigned level,
								Key const& start,
								Key const& end)
{
	if (!nodes.empty() && nodes.back()->type() == TAction)
	{
		Action* action = static_cast<Action*>(const_cast<Node*>(nodes.back()));

		if (action->command() == Action::Remove && action->end() == start)
			return action->replace(level, action->start(), end);
	}

	nodes.push_back(root->newAction(Action::Remove, level, start, end));
}


bool
Move::operator==(Node const* node) const
{
	M_ASSERT(node);

	Move const* move = mstl::safe_cast_ptr<Move const>(node);

	if (m_list.size() != move->m_list.size())
		return false;

	for (unsigned i = 0; i < m_list.size(); ++i)
	{
		if (m_list[i]->type() != move->m_list[i]->type())
			return false;
		if (*m_list[i] != move->m_list[i])
			return false;
	}

	return true;
}


void
Move::markDifferences(Move const& move) const
{
	struct Comp { bool operator()(Node const* lhs, Node const* rhs) { return *lhs < rhs; } };

	List thisList(m_list);
	List thatList(move.m_list);

	thisList.bubblesort(Comp());
	thatList.bubblesort(Comp());

	List::const_iterator i = thisList.begin();
	List::const_iterator k = thatList.begin();

	while (i != thisList.end() && k != thatList.end())
	{
		MovePart const* lhs = mstl::safe_cast_ptr<MovePart const>(*i);
		MovePart const* rhs = mstl::safe_cast_ptr<MovePart const>(*k);

		if (lhs->type() < rhs->type())
		{
			lhs->markAsInserted();
			++i;
		}
		else
		{
			if (lhs->type() == rhs->type())
			{
				if (*lhs != rhs)
					lhs->markAsChanged();
				++i;
			}

			++k;
		}
	}

	for ( ; i != thisList.end(); ++i)
		mstl::safe_cast_ptr<MovePart const>(*i)->markAsInserted();
}


Move::Move(Work& work, MoveNode const* move, bool isEmptyGame, unsigned varNo, unsigned varCount)
	:KeyNode(work.m_key)
	,m_ply(0)
{
	if (work.m_level == 0)
	{
		m_list.push_back(new Space(work.m_isEmpty && isEmptyGame ? Empty : Start));
	}
	else
	{
		work.pushOpen(varNo, varCount);
		work.pushSpace();
		work.m_needMoveNo = true;
	}

	if (work.m_isFolded)
		return;

	bool needSpace = false;

	if (move->hasMark())
	{
		work.pop(m_list);
		m_list.push_back(new Marks(move->marks()));
		work.m_isVirgin = false;
		work.pushSpace();
		needSpace = true;
	}

	mstl::string info;
	getMoveInfo(work, move, info);

	if (move->hasComment(move::Post))
	{
		db::Comment comm(move->comment(move::Post));
		comm.strip(*work.m_wantedLanguages);

		if (work.m_displayStyle & display::ShowEmoticons)
			comm.detectEmoticons();

		if (!comm.isEmpty())
		{
			work.pop(m_list);
			m_list.push_back(new Comment(comm, move::Post, Comment::AtStart));
			work.m_isVirgin = false;
			needSpace = true;
		}
	}

	if (!info.empty())
	{
		if (needSpace)
			work.pushSpace();
		work.pop(m_list);
		work.m_isVirgin = false;
		m_list.push_back(new Comment(db::Comment(info, i18n::None), move::Post, Comment::Finally));
		needSpace = true;
	}

	if (needSpace)
	{
//		work.pushParagraph(Spacing::PreComment);
		if (move->hasComment(move::Post))
		{
			work.pushSpaceOrParagraph(Spacing::Comment);
			work.m_needMoveNo = true;
		}
		else if (!info.empty())
			work.pushSpaceOrParagraph(Spacing::Comment);
		else
			work.pushSpace();
	}

	if (!(work.m_displayStyle & display::ShowDiagrams) && move->hasAnnotation())
	{
		work.pop(m_list);
		m_list.push_back(new Annotation(Annotation::Prefix, move->annotation()));
		work.m_isVirgin = false;
		work.pushSpace();
	}
}


Move::Move(Work& work, MoveNode const* move)
	:KeyNode(work.m_key)
{
	if (work.m_board.whiteToMove())
	{
		if (work.m_level == 0 && (work.m_displayStyle & display::ColumnStyle))
			work.pushBreak();
		work.m_needMoveNo = true;
	}

	if (!work.m_isFolded && move->hasComment(move::Ante))
	{
		db::Comment comment(move->comment(move::Ante));
		comment.strip(*work.m_wantedLanguages);

		if (work.m_displayStyle & display::ShowEmoticons)
			comment.detectEmoticons();

		if (!comment.isEmpty())
		{
			if (!move->prev()->hasMark() || move->prev()->hasComment(move::Post))
				work.pushSpaceOrParagraph(Spacing::Comment);
			work.pop(m_list);
			m_list.push_back(new Comment(comment, move::Ante));
			work.m_isVirgin = false;
			work.pushSpaceOrParagraph(Spacing::Comment);
			work.m_needMoveNo = true;
		}
	}

	work.pop(m_list);

	if (!move->annotation().isEmpty())
	{
		if (work.m_isFolded)
		{
			nag::ID mostImportant = move->annotation().mostImportantNag();

			if (mostImportant != nag::Null)
			{
				m_list.push_back(new Annotation(	Annotation::Prefix,
															::db::Annotation(mostImportant),
															Annotation::Numerical,
															true));
			}
		}
		else if (	!work.m_isFolded
					&& (	work.m_level > 0
						|| !(work.m_displayStyle & display::ColumnStyle)
						|| !move->annotation().containsUnusualNags()))
		{
			Annotation annotation(	Annotation::Prefix,
											move->annotation(),
											!work.m_isFolded
												&& work.m_level == 0
												&& (work.m_displayStyle & display::ColumnStyle)
												&& move->annotation().containsUnusualNags()
												? Annotation::Numerical : Annotation::All,
											bool(work.m_displayStyle & display::ShowDiagrams));

			if (!annotation.isEmpty())
				m_list.push_back(new Annotation(annotation));
		}
	}

	m_ply = work.m_needMoveNo ? new Ply(move, work.m_board.moveNumber()) : new Ply(move);

	m_list.push_back(m_ply);
	work.incrPlyCount();
	work.m_needMoveNo = false;

	if (	!work.m_isFolded
		&& work.m_level == 0
		&& (work.m_displayStyle & display::ColumnStyle)
		&& move->annotation().containsUnusualNags())
	{
		Annotation* annotation = new Annotation(
											Annotation::Suffix,
											move->annotation(),
											Annotation::Textual,
											bool(work.m_displayStyle & display::ShowDiagrams));

		M_ASSERT(!annotation->isEmpty());

		work.pushParagraph(Spacing::Annotation);
		work.pop(m_list);
		m_list.push_back(annotation);
		work.pushParagraph(Spacing::Annotation);
		work.m_needMoveNo = true;
	}

	work.pushSpace();

	if (work.m_isFolded)
		return;

	if (move->threefoldRepetition() || move->fiftyMoveRule())
	{
		m_list.push_back(new States(*move));
		work.pushSpace();
	}

	if (move->hasMark())
	{
		m_list.push_back(new Marks(move->marks()));
		work.pushSpace();
	}

	mstl::string info;
	getMoveInfo(work, move, info);

	Node::Spacing::Context context = Node::Spacing::None;

	if (move->hasComment(move::Post))
	{
		db::Comment comment(move->comment(move::Post));
		comment.strip(*work.m_wantedLanguages);

		if (work.m_displayStyle & display::ShowEmoticons)
			comment.detectEmoticons();

		if (!comment.isEmpty())
		{
			bool isShort =		info.empty()
								&& comment.length() <= work.m_linebreakMinCommentLength
								&& bool(work.m_displayStyle & display::CompactStyle);

			if (isShort)
				work.pushSpace();
			else
				work.pushSpaceOrParagraph(context = Spacing::Comment);

			work.pop(m_list);
			m_list.push_back(new Comment(comment, move::Post));

			if (isShort)
				work.pushSpace();
		}
	}

	if (!info.empty())
	{
		if (context == Node::Spacing::None)
		{
			context = Node::Spacing::MoveInfo;
			work.pushSpaceOrParagraph(context);
		}
		else
		{
			work.pushSpace();
		}
		work.pop(m_list);
		m_list.push_back(new Comment(db::Comment(info, i18n::None), move::Post, Comment::Finally));
	}

	if (context != Node::Spacing::None)
	{
		work.pushSpaceOrParagraph(context);
		work.m_needMoveNo = true;
	}
}


Move::Move(Work& work, db::Comment const& comment, unsigned varNo, unsigned varCount)
	:KeyNode(work.m_key)
	,m_ply(0)
{
	m_list.push_back(new Ply);

	if (!work.m_isFolded && !comment.isEmpty())
	{
		db::Comment comm(comment);
		comm.strip(*work.m_wantedLanguages);

		if (work.m_displayStyle & display::ShowEmoticons)
			comm.detectEmoticons();

		if (!comm.isEmpty())
		{
			work.pushSpaceOrParagraph(Spacing::Comment);
			work.pop(m_list);
			m_list.push_back(new Comment(comm, move::Post, Comment::AtEnd));
		}
	}

	if (work.m_level > 0)
	{
		Node::Bracket bracket;

		if (/*varCount > 1 && */(work.m_displayStyle & display::ShowVariationNumbers))
			bracket = work.m_isFolded ? Node::Fold : Node::End;
		else
			bracket = work.m_isFolded ? Node::CloseFold : Node::Close;

		work.pushClose(varNo, varCount);
		m_list.push_back(new Space(bracket, varNo, varCount));
	}
	else if (	(	work.m_result != result::Unknown
					|| work.m_termination != termination::None
					|| (work.m_displayStyle & display::DiscardUnknownResult) == 0)
				&& !(work.m_displayStyle & display::ColumnStyle)
				&& !(work.m_displayStyle & display::ParagraphSpacing))
	{
		m_list.push_back(new Space());
	}
}


Move::Move(Spacing& spacing, Key const& key, unsigned moveNumber, MoveNode const* move, bool isFirstPly)
	:KeyNode(key)
{
	if (color::isWhite(move->move().color()) && (spacing.m_displayStyle & display::ColumnStyle))
		spacing.pushBreak();
	else
		spacing.pushSpace();

	spacing.pop(m_list);

	if (move->hasAnnotation())
		m_list.push_back(new Annotation(Annotation::Prefix, move->annotation()));

	if (isFirstPly || color::isWhite(move->move().color()))
		m_ply = new Ply(move, moveNumber);
	else
		m_ply = new Ply(move);

	m_list.push_back(m_ply);
	spacing.incrPlyCount();

	if (move->hasMark())
		m_list.push_back(new Marks(move->marks()));
}


void
Move::getMoveInfo(Work& work, MoveNode const* move, mstl::string& result)
{
	if (bool(work.m_displayStyle & display::ShowMoveInfo) && move->hasMoveInfo())
	{
		M_ASSERT(work.m_engineList);

		move->moveInfo().print(*work.m_engineList, result, MoveInfo::Text, work.m_moveInfoTypes);

		if (!result.empty())
		{
			result.insert(result.begin(), "<xml><b>", 8);
			result.append("</b></xml>", 10);
		}
	}
}


void
Move::visit(Visitor& visitor) const
{
	visitor.startMove(m_key);

	for (unsigned i = 0; i < m_list.size(); ++i)
		m_list[i]->visit(visitor);

	visitor.endMove(m_key);
}


Root::Root()
	:m_opening(0)
	,m_languages(0)
	,m_variation(0)
	,m_result(result::Unknown)
	,m_termination(termination::None)
	,m_toMove(color::White)
{
}


Root::~Root()
{
	delete m_opening;
	delete m_languages;
	delete m_variation;
	::deleteList(m_nodes);
}


void
Root::visit(Visitor& visitor) const
{
	visitor.start(m_result);
	m_opening->visit(visitor);
	m_languages->visit(visitor);
	m_variation->visit(visitor);
	visitor.finish(m_result, m_termination, m_toMove);
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
					variant::Type variant,
					db::Board const& finalBoard,
					termination::State termination,
					MoveNode const* node,
					unsigned linebreakThreshold,
					unsigned linebreakMaxLineLength,
					unsigned displayStyle)
{
	M_REQUIRE(node);
	M_REQUIRE(node->atLineStart());
	M_REQUIRE(	(displayStyle & display::CompactStyle) == display::CompactStyle
				|| (displayStyle & display::ColumnStyle) == display::ColumnStyle);

	if (node->countHalfMoves() <= linebreakThreshold)
		linebreakMaxLineLength = ::DontSetBreaks;

	unsigned	moveNumber	= startBoard.moveNumber();
	unsigned	plyNumber	= startBoard.plyNumber();
	Spacing	spacing;
	Key		key;

	Root* root = new Root;

	root->m_opening = new Opening(startBoard, variant, idn, eco);
	root->m_languages = new Languages;
	root->m_variation = new Variation(key);
	root->m_result = result::fromString(tags.value(tag::Result));
	root->m_termination = termination;
	root->m_toMove = finalBoard.sideToMove();

	KeyNode::List& result = root->m_variation->m_list;

	result.reserve(2*node->countHalfMoves() + 10);
	key.addPly(plyNumber);
	result.push_back(new Move(key));
	spacing.m_linebreakMaxLineLength = linebreakMaxLineLength;
	spacing.m_displayStyle = displayStyle;

	Board board(startBoard);
	bool firstPly = true;

	for (node = node->next(); node->isBeforeLineEnd(); node = node->next())
	{
		key.exchangePly(++plyNumber);
		result.push_back(new Move(spacing, key, moveNumber, node, firstPly));
		if (color::isBlack(node->move().color()))
			++moveNumber;
		firstPly = false;
	}

	return root;
}


Root*
Root::makeList(TagSet const& tags,
					uint16_t idn,
					Eco eco,
					db::Board const& startBoard,
					variant::Type variant,
					db::Board const& finalBoard,
					termination::State termination,
					LanguageSet const& langSet, // unused
					LanguageSet const& wantedLanguages,
					EngineList const& engines,
					MoveNode const* node,
					unsigned linebreakThreshold,
					unsigned linebreakMaxLineLength,
					unsigned linebreakMaxLineLengthVar,
					unsigned linebreakMinCommentLength,
					unsigned displayStyle,
					unsigned moveInfoTypes)
{
	M_REQUIRE(node);
	M_REQUIRE(node->atLineStart());
	M_REQUIRE(	(displayStyle & display::CompactStyle) == display::CompactStyle
				|| (displayStyle & display::ColumnStyle) == display::ColumnStyle);

	Work work;
	work.m_board = startBoard;
	work.m_languages = new Languages(node);
	work.m_engineList = &engines;
	work.m_wantedLanguages = &wantedLanguages;
	work.m_result = result::fromString(tags.value(tag::Result));
	work.m_termination = termination;
	work.m_linebreakMaxLineLengthVar = linebreakMaxLineLengthVar;
	work.m_linebreakMinCommentLength = linebreakMinCommentLength;
	work.m_isEmpty = node->isEmptyLine(); // && !finalBoard.cannotMove()
	work.m_displayStyle = displayStyle;
	work.m_moveInfoTypes = moveInfoTypes;

	if ((displayStyle & display::CompactStyle) && node->countHalfMoves() > linebreakThreshold)
		work.m_linebreakMaxLineLength = linebreakMaxLineLength;

	Root*			root	= new Root;
	Variation*	var	= new Variation(work.m_key);

	root->m_opening = new Opening(startBoard, variant, idn, eco);
	root->m_languages = work.m_languages;
	root->m_variation = var;
	root->m_result = work.m_result;
	root->m_termination = termination;
	root->m_toMove = finalBoard.sideToMove();

	makeList(work, var->m_list, node, variant, 0, 0);

	if (	root->m_result != result::Unknown
		|| work.m_termination != termination::None
		|| (displayStyle & display::DiscardUnknownResult) == 0)
	{
		work.pushParagraph(Spacing::Result);
	}

	return root;
}


void
Root::makeList(Work& work,
					KeyNode::List& result,
					MoveNode const* node,
					variant::Type variant,
					unsigned varNo,
					unsigned varCount)
{
	M_ASSERT(node);
	M_ASSERT(node->atLineStart());

	bool isFolded = node->isFolded();

	work.m_isFolded = isFolded;
	result.reserve(2*node->countHalfMoves() + 10);
	work.m_key.addPly(work.m_board.plyNumber());

	if (node->prev())
		++work.m_level;

	result.push_back(new Move(work, node, node->isEmptyLine(), varNo, varCount));

	if (	!work.m_isFolded
		&& (work.m_displayStyle & display::ShowDiagrams)
		&& (	node->annotation().contains(nag::Diagram)
			|| node->annotation().contains(nag::DiagramFromBlack)))
	{
		work.pushParagraph(Spacing::Diagram);
		work.pop(const_cast<Move*>(static_cast<Move const*>(result.back()))->m_list);
		result.push_back(new Diagram(
			work, node->annotation().contains(nag::Diagram) ? color::White : color::Black));
		work.m_isVirgin = false;
		work.pushParagraph(Spacing::Diagram);
		work.m_needMoveNo = true;
	}

	work.m_key.removePly();
	node = node->next();
	M_ASSERT(node);

	if (work.m_isFolded)
	{
//		too confusing for the user!
//		if (node->next()->atLineEnd() && !node->hasNote() && !node->prev()->hasNote())
//			work.m_isFolded = false;
		work.m_key.addPly(work.m_board.plyNumber() + 1);
		result.push_back(new Move(work, node));
		work.m_board.doMove(node->move(), variant);
		work.m_key.incrementPly();
		result.push_back(new Move(work, db::Comment(), varNo, varCount));
		work.m_key.removePly();
	}
	else
	{
		node = traverseLine(work, result, node, variant);

		db::Comment comment;

		if (node->atLineEnd())
			comment = node->comment(move::Post);

		work.m_key.addPly(work.m_board.plyNumber() + 1);
		result.push_back(new Move(work, comment, varNo, varCount));
		work.m_key.removePly();
	}
}


db::MoveNode const*
Root::traverseLine(Work& work, KeyNode::List& result, MoveNode const* node, variant::Type variant)
{
	M_ASSERT(!node->atLineStart());

	MoveNode const* last = node;

	bool isFolded = node->prev()->isFolded();

	for ( ; node && !node->isFolded(); node = node->next())
	{
		work.m_key.addPly(work.m_board.plyNumber() + 1);
		last = node;

		if (!node->atLineEnd())
		{
			result.push_back(new Move(work, node));

			if (	(work.m_displayStyle & display::ShowDiagrams)
				&& (	node->annotation().contains(nag::Diagram)
					|| node->annotation().contains(nag::DiagramFromBlack)))
			{
				work.pushParagraph(Spacing::Diagram);
				work.pop(const_cast<Move*>(static_cast<Move const*>(result.back()))->m_list);
				M_ASSERT(work.m_board.isValidMove(node->move(), variant));
				work.m_board.doMove(node->move(), variant);
				result.push_back(new Diagram(
					work,
					node->annotation().contains(nag::Diagram) ? color::White : color::Black));
				work.m_board.undoMove(node->move(), variant);
				work.pushParagraph(Spacing::Diagram);
				work.m_needMoveNo = true;
			}
		}

		if (node->hasVariation())
		{
			Key moveKey(work.m_key);

			unsigned n = node->variationCount();
			
			for (unsigned i = 0; i < n; ++i)
			{
				Board board(work.m_board);

				work.m_key.addVariation(i);
				work.m_needMoveNo = true;

				Key startKey(work.m_key);
				startKey.addPly(work.m_board.plyNumber());
				Key endKey(startKey.successorKey(node->variation(i)));

				Variation* var = new Variation(startKey, endKey);
				result.push_back(var);

				work.pushParagraph(Spacing::StartVariation);

				unsigned linebreakMaxLineLength = work.m_linebreakMaxLineLength;

				if (	work.m_linebreakMaxLineLength != ::DontSetBreaks
					&& work.m_linebreakMaxLineLengthVar > 0
					&& node->variation(i)->countHalfMoves() > work.m_linebreakMaxLineLengthVar)
				{
					work.m_linebreakMaxLineLength = work.m_linebreakMaxLineLengthVar;
				}
				else
				{
					work.m_linebreakMaxLineLength = ::DontSetBreaks;
				}

				makeList(work, var->m_list, node->variation(i), variant, i + 1, n);
				work.m_linebreakMaxLineLength = linebreakMaxLineLength;

				M_ASSERT(work.m_level > 0);
				--work.m_level;

				work.m_key.removeVariation();
				work.m_board = board;
			}

			work.pushParagraph(Spacing::EndVariation);
			work.m_needMoveNo = true;
		}

		work.m_isFolded = isFolded;

		if (node && !node->atLineEnd())
		{
			M_ASSERT(work.m_board.isValidMove(node->move(), variant));
			work.m_board.doMove(node->move(), variant);
		}

		work.m_key.removePly();
	}

	return last;
}

// vi:set ts=3 sw=3:
