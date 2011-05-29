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

#include "sys_utf8_codec.h"

#include "m_limits.h"
#include "m_stdio.h"
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


Node::~Node() throw()				{}
Visitor::~Visitor() throw()		{}
Variation::~Variation() throw()	{ ::deleteList(m_list); }
Move::~Move() throw()				{ ::deleteList(m_list); }


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
Node::Type Marks::type() const		{ return TMarks; }
Node::Type Space::type() const		{ return TSpace; }


void Opening::visit(Visitor& visitor) const		{ visitor.opening(m_board, m_idn, m_eco); }
void Languages::visit(Visitor& visitor) const	{ visitor.languages(m_langSet); }
void Ply::visit(Visitor& visitor) const			{ visitor.move(m_moveNo, m_move); }
void Comment::visit(Visitor& visitor) const		{ visitor.comment(m_position, m_comment); }
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
			&& m_suffixBreak && static_cast<Diagram const*>(node)->m_suffixBreak
			&& m_board.isEqualPosition(static_cast<Diagram const*>(node)->m_board);
}


inline
Diagram::Diagram(Work& work, color::ID fromColor)
	:KeyNode(Key(work.key, PrefixDiagram))
	,m_board(work.board)
	,m_fromColor(fromColor)
	,m_prefixBreak((work.spacing & ~Move::SuppressBreak) == Move::NoSpace ? 0 : 1)
	,m_suffixBreak(0)
{
	unsigned spacing = ForcedBreak;

	if (!(work.displayStyle & (display::CompactStyle | display::NarrowLines)))
	{
		if (!(work.spacing & SuppressBreak) || (work.spacing & PrefixSpace))
			++m_prefixBreak;
		++m_suffixBreak;
		spacing |= SuppressBreak;
	}

	work.spacing = spacing;
}


void
Diagram::visit(Visitor& visitor) const
{
	visitor.startDiagram(m_key);
	if (m_prefixBreak > 0)
		visitor.linebreak(0, None);
	if (m_prefixBreak > 1)
		visitor.linebreak(0, None);
	visitor.position(m_board, m_fromColor);
	if (m_suffixBreak > 0)
		visitor.linebreak(0, None);
	visitor.endDiagram(m_key);
}


void
Diagram::dump(unsigned level) const
{
	mstl::string fen;
	mstl::string space(2*(level + 1), ' ');
	m_board.toFen(fen);

	::printf(mstl::string(2*level, ' ').c_str());
	::printf("diagram %s {", m_key.id().c_str());

	if (m_prefixBreak)
	{
		::printf("\n%slinebreak\n", space.c_str());
		if (m_prefixBreak > 1)
			::printf("%slinebreak\n", space.c_str());
	}

	::printf("%scolor %s\n", space.c_str(), color::printColor(m_fromColor));
	::printf("%sboard %s\n", space.c_str(), fen.c_str());
	if (m_suffixBreak)
		::printf("%slinebreak\n", space.c_str());
	::printf(mstl::string(2*level, ' ').c_str());
	::printf("}\n");
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


void
Ply::dump(unsigned level) const
{
	mstl::string san;
	m_move.printSan(san);

	::printf(mstl::string(2*level, ' ').c_str());
	::printf("ply ");
	if (m_moveNo)
		::printf("%u ", m_moveNo);
	::printf("{ %s %s ", color::printColor(m_move.color()), san.c_str());
		if (!m_move.isLegal())
			::printf("illegal ");
	::printf("}\n");
}


bool
Comment::operator==(Node const* node) const
{
	M_ASSERT(node);
	M_ASSERT(dynamic_cast<Comment const*>(node));

	return	m_position == static_cast<Comment const*>(node)->m_position
			&& m_comment == static_cast<Comment const*>(node)->m_comment;
}


void
Comment::dump(unsigned level) const
{
	mstl::string buf;

	if (::sys::utf8::Codec::fitsRegion(m_comment.content(), 1))
		::sys::utf8::Codec::convertToNonDiacritics(1, m_comment.content(), buf);
	else
		buf = "<comment not LATIN-1>";

	::printf(mstl::string(2*level, ' ').c_str());
	::printf("comment {");
	::printf("%s \"%s\"", m_position == move::Ante ? "ante" : "post", buf.c_str());
	::printf("}\n");
}


Annotation::Annotation(db::Annotation const& annotation, bool deleteDiagram)
	:m_annotation(annotation)
{
	if (deleteDiagram)
	{
		m_annotation.remove(nag::Diagram);
		m_annotation.remove(nag::DiagramFromBlack);
	}
}


bool
Annotation::operator==(Node const* node) const
{
	M_ASSERT(node);
	M_ASSERT(dynamic_cast<Annotation const*>(node));

	return m_annotation == static_cast<Annotation const*>(node)->m_annotation;
}


void
Annotation::dump(unsigned level) const
{
	mstl::string prefix, infix, suffix;

	m_annotation.prefix(prefix);
	m_annotation.infix(infix);
	m_annotation.suffix(suffix);

	::printf(mstl::string(2*level, ' ').c_str());
	::printf("annotation { %s } { %s } { %s }\n", prefix.c_str(), infix.c_str(), suffix.c_str());
}


bool
Marks::operator==(Node const* node) const
{
	M_ASSERT(node);
	M_ASSERT(dynamic_cast<Marks const*>(node));

	return m_marks == static_cast<Marks const*>(node)->m_marks;
}


void
Marks::dump(unsigned level) const
{
	::printf(mstl::string(2*level, ' ').c_str());
	::printf("marks %u\n", unsigned(m_marks.count()));
}


void
Space::visit(Visitor& visitor) const
{
	if (m_level >= 0)
		visitor.linebreak(m_level, m_bracket);
	else
		visitor.space(m_bracket);
}


void
Space::dump(unsigned level) const
{
	::printf(mstl::string(2*level, ' ').c_str());

	if (m_level >= 0)
		::printf("linebreak %u", m_level);
	else
		::printf("space");

	if (m_bracket == '(')
		::printf(" { open } ");
	else if (m_bracket == ')')
		::printf(" { close } ");

	::printf("\n");
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


void
Opening::dump(unsigned) const
{
	mstl::string openingLong, openingShort, variation, subvariation, position;
	mstl::string pos;

	if (m_idn)
		pos = shuffle::position(m_idn);
	else
		m_board.toFen(pos);

	::printf("header {\n");
	::printf("  idn %u\n", unsigned(m_idn));
	::printf("  eco %s\n", m_eco.asShortString().c_str());
	::printf("}\n");
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


void
Action::dump(unsigned level) const
{
	::printf(mstl::string(2*level, ' ').c_str());

	switch (m_command)
	{
		case Clear:
			::printf("action { clear }\n");
			break;

		case Insert:
			::printf("action { insert %u %s }\n", level, m_key1.id().c_str());
			break;

		case Replace:
			::printf("action { replace %u %s %s }\n", level, m_key1.id().c_str(), m_key2.id().c_str());
			break;

		case Remove:
			::printf("action { remove %u %s %s }\n", level, m_key1.id().c_str(), m_key2.id().c_str());
			break;

		case Finish:
			::printf("action { finish %u }\n", level);
			break;
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


void
Languages::dump(unsigned level) const
{
	::printf(mstl::string(2*level, ' ').c_str());
	::printf("languages {");

	for (LanguageSet::const_iterator i = m_langSet.begin(), e = m_langSet.end(); i != e; ++i)
	{
		if (!i->first.empty())
		{
			if (i != m_langSet.begin())
				::printf(" ");
			::printf(i->first.c_str());
		}
	}

	::printf("}\n");
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
	Key key(startKey());
	key.removePly();

	visitor.startVariation(key, startKey(), endKey());

	for (unsigned i = 0; i < m_list.size(); ++i)
		m_list[i]->visit(visitor);

	visitor.endVariation(key, startKey(), endKey());
}


void
Variation::dump(unsigned level) const
{
	if (m_list.empty())
		return;

	Key const& startKey	= m_list.front()->startKey();
	Key const& endKey		= m_list.back()->startKey();

	::printf(mstl::string(2*level, ' ').c_str());
	::printf("begin %s { %u }\n", startKey.id().c_str(), startKey.level());

	for (unsigned i = 0; i < m_list.size(); ++i)
		m_list[i]->dump(level + 1);

	::printf(mstl::string(2*level, ' ').c_str());
	::printf("end %s { %u }\n", endKey.id().c_str(), endKey.level());
}


void
Variation::difference(Root const* root, Variation const* var, unsigned level, Node::List& nodes) const
{
	M_ASSERT(root);
	M_ASSERT(var);

	Key const& endVar = var->successor();

	unsigned	i = 0;
	unsigned k = 0;
	unsigned m = m_list.size();
	unsigned n = var->m_list.size();

	if (m > 0 && n > 0)
	{
		KeyNode const* lhs = m_list[0];			// node from current game
		KeyNode const* rhs = var->m_list[0];	// node from previous game

		if (lhs->key() < rhs->key())
		{
			do
				++i;
			while (i < m && m_list[i]->key() < rhs->key());

			nodes.push_back(root->newAction(Action::Insert, level, rhs->startKey()));
			nodes.insert(nodes.end(), m_list.begin(), m_list.begin() + i);
			nodes.push_back(root->newAction(Action::Finish, level));
		}
		else if (rhs->key() < lhs->key())
		{
			do
				++k;
			while (k < n && var->m_list[k]->key() < lhs->key());

			Key const& after = k == n ? endVar : var->m_list[k]->startKey();
			nodes.push_back(root->newAction(Action::Remove, level, rhs->startKey(), after));
		}
	}

	while (i < m && k < n)
	{
		KeyNode const* lhs = m_list[i];			// node from current game
		KeyNode const* rhs = var->m_list[k];	// node from previous game

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
				if (	lhsType == TMove
					&& (	static_cast<Move const*>(lhs)->ply() == 0
						|| static_cast<Move const*>(rhs)->ply() == 0
						|| *static_cast<Move const*>(lhs)->ply() != static_cast<Move const*>(rhs)->ply()))
				{
					KeyNode const* const* lhsLast	= m_list.begin() + i + 1;
					KeyNode const* const* lhsEnd	= m_list.end();
					KeyNode const* const* rhsLast	= var->m_list.begin() + k + 1;
					KeyNode const* const* rhsEnd	= var->m_list.end();

					while	(	lhsLast < lhsEnd
							&& rhsLast < rhsEnd
							&& (*lhsLast)->type() == (*rhsLast)->type()
							&& (*lhsLast)->key() == (*rhsLast)->key()
							&& *static_cast<Node const*>(*lhsLast) == static_cast<Node const*>(*rhsLast))
					{
						++lhsLast;
						++rhsLast;
					}

					Key const& before = rhs->endKey();
					Key const& after = rhsLast == var->m_list.end() ? endVar : (*rhsLast)->startKey();
					nodes.push_back(root->newAction(Action::Replace, level, before, after));
					nodes.insert(nodes.end(), m_list.begin() + i, lhsLast);
					nodes.push_back(root->newAction(Action::Finish, level));
					i = lhsLast - m_list.begin() - 1;
					k = rhsLast - var->m_list.begin() - 1;
				}
				else
				{
					Key const& before	= rhs->endKey();
					Key const& after	= (k == n - 1) ? endVar : var->m_list[k + 1]->startKey();

					nodes.push_back(root->newAction(Action::Replace, level, before, after));
					nodes.push_back(lhs);
					nodes.push_back(root->newAction(Action::Finish, level));
				}
			}

			++i;
			++k;
		}
		else // if (lhsType != rhsType)
		{
			enum { Insert, Remove } action;

			switch (rhsType)
			{
				case TDiagram:		action = Remove; break;
				case TMove:			action = Insert; break;
				case TVariation:	action = (lhsType == TMove) ? Remove : Insert; break;
				default:				M_ASSERT(!"should not happen"); break;
			}

			switch (action)
			{
				case Insert:
					nodes.push_back(root->newAction(Action::Insert, level, rhs->startKey()));
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
		nodes.push_back(root->newAction(Action::Remove, level, var->m_list[k]->startKey(), endVar));
}


void
Move::dump(unsigned level) const
{
	::printf(mstl::string(2*level, ' ').c_str());
	::printf("move %s {\n", m_key.id().c_str());

	for (unsigned i = 0; i < m_list.size(); ++i)
		m_list[i]->dump(level + 1);

	::printf(mstl::string(2*level, ' ').c_str());
	::printf("}\n");
}


bool
Move::operator==(Node const* node) const
{
	M_ASSERT(node);
	M_ASSERT(dynamic_cast<Move const*>(node));
	M_ASSERT(m_key == static_cast<Move const*>(node)->m_key);

	if (m_list.size() != static_cast<Move const*>(node)->m_list.size())
		return false;

	for (unsigned i = 0; i < m_list.size(); ++i)
	{
		if (m_list[i]->type() != static_cast<Move const*>(node)->m_list[i]->type())
			return false;
		if (*m_list[i] != static_cast<Move const*>(node)->m_list[i])
			return false;
	}

	return true;
}


Move::Move(Work& work, db::Comment const& comment)
	:KeyNode(work.key)
	,m_ply(0)
{
	if (work.spacing & RequiredBreak)
	{
		m_list.push_back(new Space(0));
		m_list.push_back(new Space(0, work.bracket));
		work.plyCount = 0;
	}
	else if (work.spacing & ForcedBreak)
	{
		m_list.push_back(new Space(0, work.bracket));
		work.plyCount = 0;
	}
	else if (work.spacing & PrefixBreak)
	{
		m_list.push_back(new Space(work.level, work.bracket));
		if (	work.level == 0
			&& !(work.spacing & SuppressBreak)
			&& !(work.displayStyle & (display::CompactStyle | display::NarrowLines)))
		{
			m_list.push_back(new Space(0));
		}
		work.plyCount = 0;
	}
	else if (work.spacing & PrefixSpace)
	{
		m_list.push_back(new Space(work.bracket));
	}

	work.spacing = NoSpace;
	work.bracket = None;

	if (!comment.isEmpty())
	{
		db::Comment comm(comment);
		comm.strip(*work.wantedLanguages);

		if (!comm.isEmpty())
		{
			m_list.push_back(new Comment(comm, move::Post));

			if (work.level == 0)
			{
				m_list.push_back(new Space(0));

				if ((work.displayStyle & (display::CompactStyle | display::NarrowLines)) == 0)
					work.spacing = PrefixBreak;
			}
			else
			{
				work.spacing = PrefixSpace;
			}

			work.spacing |= SuppressBreak;
			work.needMoveNo = true;
		}
	}
}


Move::Move(Work& work, MoveNode const* move)
	:KeyNode(work.key)
{
	M_ASSERT(!move->atLineStart());

	bool atLineStart = move->prev()->atLineStart();

	if (work.board.whiteToMove())
		work.needMoveNo = true;

	if (move->hasComment(move::Ante))
	{
		db::Comment comment(move->comment(move::Ante));
		comment.strip(*work.wantedLanguages);

		if (!comment.isEmpty())
		{
			preSpacing(work, atLineStart, PrefixBreak);
			work.spacing = putComment(work, comment, move::Ante);
			work.needMoveNo = true;
			atLineStart = false;
		}
	}

	preSpacing(work, atLineStart, PrefixSpace);

	m_ply = work.needMoveNo ? new Ply(move, work.board.moveNumber()) : new Ply(move);
	m_list.push_back(m_ply);
	work.needMoveNo = false;

	unsigned spacing = PrefixSpace;

	if (move->hasAnnotation())
	{
		m_list.push_back(new Annotation(
			move->annotation(),
			bool(work.displayStyle & display::ShowDiagrams)));
		spacing = PrefixSpace;
	}

	if (move->hasMark())
	{
		m_list.push_back(new Marks(move->marks()));
		spacing = PrefixSpace;
	}

	if (move->hasComment(move::Post))
	{
		db::Comment comment(move->comment(move::Post));
		comment.strip(*work.wantedLanguages);

		if (!comment.isEmpty())
			spacing = putComment(work, comment, move::Post);
	}

	work.spacing = spacing;
	work.bracket = None;
}


void
Move::preSpacing(Work& work, bool atLineStart, unsigned space)
{
	if (work.spacing & RequiredBreak)
	{
		m_list.push_back(new Space(0));
		m_list.push_back(new Space(0, work.bracket));
		work.plyCount = 0;
		work.needMoveNo = true;
	}
	else if (work.spacing & ForcedBreak)
	{
		m_list.push_back(new Space(0, work.bracket));
		work.plyCount = 0;
		work.needMoveNo = true;
	}
	else if (work.spacing & PrefixBreak)
	{
		m_list.push_back(new Space(work.level, work.bracket));
		work.plyCount = 0;
		work.needMoveNo = true;
	}
	else if (	(work.displayStyle & display::ColumnStyle)
				&& !atLineStart
				&& work.level == 0
				&& work.board.whiteToMove())
	{
		m_list.push_back(new Space(0, work.bracket));
		work.plyCount = 0;
		work.needMoveNo = true;
	}
	else if (work.spacing & PrefixSpace)
	{
		if (space == PrefixBreak && work.level == 0)
			m_list.push_back(new Space(work.level, work.bracket));
		else
			m_list.push_back(new Space(work.bracket));
	}
}


unsigned
Move::putComment(Work& work, db::Comment const& comment, move::Position position)
{
	unsigned spacing;

	if (	work.level == 0
		&& (	(work.displayStyle & display::ColumnStyle)
			|| comment.size() > work.linebreakMinCommentLength))
	{
		if (position == move::Post)
		{
			if (	!(work.spacing & SuppressBreak)
				&& !(work.displayStyle & (display::CompactStyle | display::NarrowLines)))
			{
				m_list.push_back(new Space(0));
			}
			m_list.push_back(new Space(0));
		}

		spacing = PrefixBreak;
	}
	else
	{
		if (position == move::Post)
			m_list.push_back(new Space);

		spacing = PrefixSpace;
	}

	m_list.push_back(new Comment(comment, position));
	work.plyCount = 0;
	work.needMoveNo = true;

	if (work.level == 0 && !(work.displayStyle & (display::CompactStyle | display::NarrowLines)))
		m_list.push_back(new Space(0));

	return spacing | SuppressBreak;
}


Move::Move(Work& work)
	:KeyNode(work.key)
	,m_ply(0)
{
	if (	(work.spacing & ForcedBreak)
		&& !(work.spacing & SuppressBreak)
		&& !(work.displayStyle & display::NarrowLines))
	{
		m_list.push_back(new Space(0, Close));
	}

	if (work.level == 1 && !(work.displayStyle & (display::CompactStyle | display::NarrowLines)))
	{
		m_list.push_back(new Space(Close));
		if (!(work.spacing & ForcedBreak))
			m_list.push_back(new Space(0));
		work.spacing = PrefixBreak;
	}
	else if (work.level > 0)
	{
		m_list.push_back(new Space(Close));
		work.spacing = PrefixBreak;
	}
	else if (work.displayStyle & display::CompactStyle)
	{
		work.spacing = PrefixBreak;
	}
	else
	{
		work.spacing = NoSpace;
	}

	work.bracket = None;
	work.needMoveNo = true;
}


Move::Move(Key const& key, unsigned moveNumber, unsigned spacing, MoveNode const* move)
	:KeyNode(key)
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


void
Root::dump(unsigned level) const
{
	m_opening->dump(level);
	m_languages->dump(level);
	m_variation->dump(level);
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
					MoveNode const* node,
					unsigned linebreakThreshold,
					unsigned linebreakMaxLineLength)
{
	M_REQUIRE(node);
	M_REQUIRE(node->atLineStart());

	if (node->countHalfMoves() <= linebreakThreshold)
		linebreakMaxLineLength = ::DontSetBreaks;

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
					MoveNode const* node,
					unsigned linebreakThreshold,
					unsigned linebreakMaxLineLength,
					unsigned linebreakMaxLineLengthVar,
					unsigned linebreakMinCommentLength,
					unsigned displayStyle)
{
	M_REQUIRE(node);
	M_REQUIRE(node->atLineStart());
	M_REQUIRE(displayStyle & (display::CompactStyle | display::ColumnStyle));
	M_REQUIRE((displayStyle & (display::CompactStyle | display::ColumnStyle))
					!= (display::CompactStyle | display::ColumnStyle));

	Work work;
	work.board = startBoard;
	work.languages = new Languages(node);
	work.spacing = PrefixBreak | SuppressBreak;
	work.bracket = None;
	work.needMoveNo = true;
	work.wantedLanguages = &wantedLanguages;
	work.level = 0;
	work.linebreakMaxLineLength = ::DontSetBreaks;
	work.linebreakMaxLineLengthVar = linebreakMaxLineLengthVar;
	work.linebreakMinCommentLength = linebreakMinCommentLength;
	work.displayStyle = displayStyle;

	if ((displayStyle & display::CompactStyle) && node->countHalfMoves() > linebreakThreshold)
		work.linebreakMaxLineLength = linebreakMaxLineLength;

	Root*			root	= new Root;
	Variation*	var	= new Variation(work.key);

	root->m_opening = new Opening(startBoard, idn, eco);
	root->m_languages = work.languages;
	root->m_variation = var;
	root->m_result = result::fromString(tags.value(tag::Result));

	makeList(work, var->m_list, node, work.linebreakMaxLineLength);

	return root;
}


void
Root::makeList(Work& work, KeyNode::List& result, MoveNode const* node, unsigned linebreakMaxLineLength)
{
	M_ASSERT(node);
	M_ASSERT(node->atLineStart());

	result.reserve(2*node->countHalfMoves() + 10);
	work.key.addPly(work.board.plyNumber());

	if (node->prev())
		++work.level;

	result.push_back(new Move(work, node->comment(move::Post)));

	if (	(work.displayStyle & display::ShowDiagrams)
		&& (	node->annotation().contains(nag::Diagram)
			|| node->annotation().contains(nag::DiagramFromBlack)))
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

		if (work.plyCount++ == linebreakMaxLineLength)
		{
			work.spacing |= RequiredBreak;
			work.plyCount = 0;
		}

		result.push_back(new Move(work, node));

		if (	(work.displayStyle & display::ShowDiagrams)
			&& (	node->annotation().contains(nag::Diagram)
				|| node->annotation().contains(nag::DiagramFromBlack)))
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
				else if (work.level > 0)
				{
					succKey = work.key;
					succKey.removePly();
					succKey.removeVariation();
					succKey.incrementPly();
				}

				unsigned spacing = work.spacing;

				work.key.addVariation(i);
				work.spacing = PrefixBreak;
				work.bracket = Open;
				work.needMoveNo = true;

				if ((spacing & SuppressBreak) || (0 < i && i < node->variationCount()))
					work.spacing |= SuppressBreak;

				Variation* var = new Variation(work.key, succKey);
				result.push_back(var);

				unsigned linebreakMaxLineLengthVar = ::DontSetBreaks;

				if (	work.linebreakMaxLineLength != ::DontSetBreaks
					&& work.linebreakMaxLineLengthVar > 0
					&& node->variation(i)->countNodes() > work.linebreakMaxLineLengthVar)
				{
					linebreakMaxLineLengthVar = work.linebreakMaxLineLengthVar;
				}

				makeList(work, var->m_list, node->variation(i), linebreakMaxLineLengthVar);
				M_ASSERT(work.level > 0);
				--work.level;
				work.key.removeVariation();
				work.board = board;
			}

			work.plyCount = 0;
		}

		work.board.doMove(node->move());
		work.key.removePly();
	}

	work.key.addPly(work.board.plyNumber() + 1);
	result.push_back(new Move(work));
	work.key.removePly();
}

// vi:set ts=3 sw=3:
