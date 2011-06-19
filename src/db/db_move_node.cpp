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

#include "db_move_node.h"
#include "db_annotation.h"
#include "db_mark_set.h"
#include "db_board.h"

#include "u_crc.h"

#include "m_utility.h"
#include "m_assert.h"
#include "m_static_check.h"

#include <string.h>
#include <ctype.h>

using namespace db;


static MarkSet const NoMarks;


MoveNode::MoveNode(Move const& move)
	:m_flags(0)
	,m_next(0)
	,m_prev(0)
	,m_annotation(const_cast<Annotation*>(Annotation::defaultSet(nag::Null)))
	,m_marks(const_cast<MarkSet*>(&::NoMarks))
	,m_move(move)
{
}


MoveNode::MoveNode(Board const& board, Move const& move)
	:m_flags(0)
	,m_next(0)
	,m_prev(0)
	,m_annotation(const_cast<Annotation*>(Annotation::defaultSet(nag::Null)))
	,m_marks(const_cast<MarkSet*>(&::NoMarks))
	,m_move(move)
{
	M_REQUIRE(board.isValidMove(move));

	board.prepareUndo(m_move);
	board.prepareForSan(m_move);
}


MoveNode::MoveNode(MoveNode* node)
	:m_flags(0)
	,m_next(node)
	,m_prev(0)
	,m_annotation(const_cast<Annotation*>(Annotation::defaultSet(nag::Null)))
	,m_marks(const_cast<MarkSet*>(&::NoMarks))
{
	M_REQUIRE(node);
	m_next->m_prev = this;
}


MoveNode::MoveNode(Annotation* set)
	:m_flags(0)
	,m_next(0)
	,m_prev(0)
	,m_annotation(set ? set : const_cast<Annotation*>(Annotation::defaultSet(nag::Null)))
	,m_marks(const_cast<MarkSet*>(&::NoMarks))
{
}


MoveNode::~MoveNode()
{
	if (!m_annotation->isDefaultSet())
		delete m_annotation;

	if (m_marks != &::NoMarks)
		delete m_marks;

	for (unsigned i = 0; i < m_variations.size(); ++i)
		delete m_variations[i];

	delete m_next;
}


void
MoveNode::setMove(Board const& board, Move const& move)
{
	M_REQUIRE(board.isValidMove(move));

	m_move = move;
	board.prepareUndo(m_move);
	board.prepareForSan(m_move);
}


void
MoveNode::addAnnotation(nag::ID nag)
{
	if (nag == nag::Null)
		return;

	switch (m_annotation->count())
	{
		case 0:
			m_annotation = const_cast<Annotation*>(Annotation::defaultSet(nag));
			break;

		case 1:
			m_annotation = new Annotation(*m_annotation);
			// fallthru

		default:
			if (!m_annotation->contains(nag))
				m_annotation->add(nag);
			break;
	}

	m_flags |= HasAnnotation;
}


void
MoveNode::clearAnnotation()
{
	if (m_annotation->count() > 1)
		delete m_annotation;

	m_annotation = const_cast<Annotation*>(Annotation::defaultSet(nag::Null));
	m_flags &= ~HasAnnotation;
}


void
MoveNode::addMark(Mark const& mark)
{
	if (m_marks == &::NoMarks)
		m_marks = new MarkSet;

	m_marks->add(mark);
	m_flags |= HasMark;
}


void
MoveNode::setupAnnotation(Annotation const& annotation)
{
	if (annotation.isEmpty())
	{
		if (!m_annotation->isDefaultSet())
			delete m_annotation;

		 m_annotation = const_cast<Annotation*>(Annotation::defaultSet(nag::Null));
		 m_flags &= ~HasAnnotation;
	}
	else
	{
		if (annotation.count() == 1)
		{
			if (!m_annotation->isDefaultSet())
				delete m_annotation;

			m_annotation = const_cast<Annotation*>(Annotation::defaultSet(annotation[0]));
		}
		else if (m_annotation->count() > 1)
		{
			*m_annotation = annotation;
		}
		else
		{
			m_annotation = new Annotation(annotation);
		}

		m_flags |= HasAnnotation;
	}
}


void
MoveNode::setAnnotation(Annotation const& annotation)
{
	setupAnnotation(annotation);
	m_annotation->sort();
}


void
MoveNode::setMarks(MarkSet const& marks)
{
	M_REQUIRE(!hasMark());

	if (!marks.isEmpty())
	{
		m_marks = new MarkSet(marks);
		m_flags |= HasMark;
	}
}


void
MoveNode::swapMarks(MarkSet& marks)
{
	if (m_marks != &::NoMarks)
	{
		m_marks->swap(marks);

		if (m_marks->isEmpty())
			m_flags &= ~HasMark;
		else
			m_flags |= HasMark;
	}
	else if (!marks.isEmpty())
	{
		m_marks = new MarkSet;
		m_marks->swap(marks);
		m_flags |= HasMark;
	}
}


void
MoveNode::replaceMarks(MarkSet const& marks)
{
	if (marks.isEmpty())
	{
		if (m_marks != &::NoMarks)
			delete m_marks;

		m_marks = const_cast<MarkSet*>(&::NoMarks);
		m_flags &= ~HasMark;
	}
	else
	{
		m_marks = new MarkSet(marks);
		m_flags |= HasMark;
	}
}


void
MoveNode::setNext(MoveNode* next)
{
	M_REQUIRE(next);
	M_REQUIRE(!next->prev());

	delete m_next;
	m_next = next;
	next->m_prev = this;
}


void
MoveNode::deleteNext()
{
	delete m_next;
	m_next = 0;
}


MoveNode*
MoveNode::removeNext()
{
	MoveNode* next = m_next;

	if (next)
	{
		next->m_prev = 0;
		m_next = 0;
	}

	return next;
}


void
MoveNode::addVariation(MoveNode* variation)
{
	M_REQUIRE(variation);
	M_REQUIRE(!variation->prev());
	M_REQUIRE(!variation->move());

	m_variations.push_back(variation);
	variation->m_prev = this;
	m_flags |= HasVariation;
}


void
MoveNode::deleteVariation(unsigned varNo)
{
	M_REQUIRE(varNo < variationCount());

	delete m_variations[varNo];
	m_variations.erase(m_variations.begin() + varNo);

	if (m_variations.empty())
		m_flags &= ~HasVariation;
}


void
MoveNode::swapVariations(unsigned varNo1, unsigned varNo2)
{
	M_REQUIRE(varNo1 < variationCount());
	M_REQUIRE(varNo2 < variationCount());

	mstl::swap(m_variations[varNo1], m_variations[varNo2]);
}


void
MoveNode::swapData(MoveNode* node)
{
	M_REQUIRE(node);

	mstl::swap(m_flags,			node->m_flags);
	mstl::swap(m_annotation,	node->m_annotation);
	mstl::swap(m_marks,			node->m_marks);
	mstl::swap(m_comment[0],		node->m_comment[0]);
	mstl::swap(m_comment[1],		node->m_comment[1]);
}


MoveNode*
MoveNode::removeVariation(unsigned varNo)
{
	M_REQUIRE(varNo < variationCount());

	MoveNode* variation = m_variations[varNo];

	variation->m_prev = 0;
	m_variations.erase(m_variations.begin() + varNo);

	if (m_variations.empty())
		m_flags &= ~HasVariation;

	return variation;
}


MoveNode*
MoveNode::replaceVariation(unsigned varNo, MoveNode* node)
{
	M_REQUIRE(varNo < variationCount());
	M_REQUIRE(node);
	M_REQUIRE(!node->prev());
	M_REQUIRE(!node->move());

	MoveNode* variation = m_variations[varNo];
	node->m_prev = variation->m_prev;
	m_variations[varNo] = node;
	return variation;
}


MoveNode*
MoveNode::clone(MoveNode* prev) const
{
	MoveNode* node = new MoveNode;

	if (m_next)
		node->m_next = m_next->clone(node);

	if ((node->m_prev = prev))
		node->m_prev->m_next = node;

	if (!m_annotation->isEmpty())
		node->setupAnnotation(*m_annotation);

	node->m_comment[0] = m_comment[0];
	node->m_comment[1] = m_comment[1];
	node->m_move = m_move;
	node->m_flags = m_flags;

	if (!m_marks->isEmpty())
		node->m_marks = new MarkSet(*m_marks);

	for (unsigned i = 0; i < m_variations.size(); ++i)
		node->addVariation(m_variations[i]->clone());

	return node;
}


unsigned
MoveNode::variationNumber(MoveNode const* node) const
{
	M_REQUIRE(node->prev() == this);

	for (unsigned i = 0; i < m_variations.size(); ++i)
	{
		if (node == m_variations[i])
			return i;
	}

	return 0;	// not reached
}


void
MoveNode::prepareForSan(Board const& board)
{
	board.prepareForSan(m_move);
}


unsigned
MoveNode::countHalfMoves() const
{
	MoveNode const* p = atLineStart() ? m_next : this;
	unsigned count = 0;

	for ( ; p; p = p->m_next)
		++count;

	return count;
}


unsigned
MoveNode::countNodes() const
{
	MoveNode const* p = atLineStart() ? m_next : this;
	unsigned count = 0;

	for ( ; p; p = p->m_next)
	{
		++count;

		if (p->hasVariation())
		{
			for (unsigned i = 0; i < p->variationCount(); ++i)
				count += p->variation(i)->countNodes();
		}
	}

	return count;
}


unsigned
MoveNode::countAnnotations() const
{
	unsigned result = m_annotation->count();

	if (m_next)
		result += m_next->countAnnotations();

	for (unsigned i = 0; i < m_variations.size(); ++i)
		result += m_variations[i]->countAnnotations();

	return result;
}


unsigned
MoveNode::countMarks() const
{
	unsigned result = m_marks->count();

	if (m_next)
		result += m_next->countMarks();

	for (unsigned i = 0; i < m_variations.size(); ++i)
		result += m_variations[i]->countMarks();

	return result;
}


unsigned
MoveNode::countComments() const
{
	unsigned result = (m_comment[0].isEmpty() ? 0 : 1) + (m_comment[1].isEmpty() ? 0 : 1);

	if (m_next)
		result += m_next->countComments();

	for (unsigned i = 0; i < m_variations.size(); ++i)
		result += m_variations[i]->countComments();

	return result;
}


unsigned
MoveNode::countComments(mstl::string const& lang) const
{
	unsigned result = (m_comment[0].countLength(lang) ? 1 : 0) + (m_comment[1].countLength(lang) ? 1 : 0);

	if (m_next)
		result += m_next->countComments(lang);

	for (unsigned i = 0; i < m_variations.size(); ++i)
		result += m_variations[i]->countComments(lang);

	return result;
}


unsigned
MoveNode::countVariations() const
{
	unsigned result = m_variations.size();

	if (m_next)
		result += m_next->countVariations();

	return result;
}


unsigned
MoveNode::unfoldedVariationCount() const
{
	unsigned n = 0;

	for (unsigned i = 0; i < variationCount(); ++i)
	{
		if (!variation(i)->isFolded())
			++n;
	}

	return n;
}


void
MoveNode::stripAnnotations()
{
	if (!m_annotation->isDefaultSet())
		delete m_annotation;

	m_annotation = const_cast<Annotation*>(Annotation::defaultSet(nag::Null));
	m_flags &= ~HasAnnotation;

	for (unsigned i = 0; i < m_variations.size(); ++i)
		m_variations[i]->stripAnnotations();

	if (m_next)
		m_next->stripAnnotations();
}


void
MoveNode::stripMarks()
{
	m_flags &= ~HasMark;

	if (m_marks != &::NoMarks)
	{
		delete m_marks;
		m_marks = const_cast<MarkSet*>(&::NoMarks);
	}

	for (unsigned i = 0; i < m_variations.size(); ++i)
		m_variations[i]->stripMarks();

	if (m_next)
		m_next->stripMarks();
}


void
MoveNode::stripComments()
{
	m_comment[0].clear();
	m_comment[1].clear();
	m_flags &= ~(HasComment | IsPrepared);

	for (unsigned i = 0; i < m_variations.size(); ++i)
		m_variations[i]->stripComments();

	if (m_next)
		m_next->stripComments();
}


void
MoveNode::stripComments(mstl::string const& lang)
{
	m_comment[0].remove(lang);
	m_comment[1].remove(lang);
	m_flags &= ~IsPrepared;

	if (m_comment[move::Ante].isEmpty())
		m_flags &= ~HasPreComment;
	if (m_comment[move::Post].isEmpty())
		m_flags &= ~HasComment;

	for (unsigned i = 0; i < m_variations.size(); ++i)
		m_variations[i]->stripComments(lang);

	if (m_next)
		m_next->stripComments(lang);
}


void
MoveNode::stripVariations()
{
	for (unsigned i = 0; i < m_variations.size(); ++i)
		delete m_variations[i];

	m_variations.clear();
	m_flags &= ~HasVariation;

	if (m_next)
		m_next->stripVariations();
}


void
MoveNode::fold(bool flag)
{
	for (MoveNode* p = this; p; p = p->m_next)
	{
		if (p->hasVariation())
		{
			for (unsigned i = 0; i < p->m_variations.size(); ++i)
			{
				p->m_variations[i]->setFolded(flag);
				p->m_variations[i]->fold(flag);
			}
		}
	}
}


void
MoveNode::transpose()
{
	if (m_move)
		m_move.transpose();

	for (unsigned i = 0; i < m_variations.size(); ++i)
		m_variations[i]->transpose();

	if (m_next)
		m_next->transpose();
}


void
MoveNode::finish(Board const& board)
{
	M_REQUIRE(atLineStart());

	Board myBoard(board);

	for (MoveNode* node = m_next; node; node = node->m_next)
	{
		node->m_annotation->sort();

		for (unsigned i = 0; i < node->m_variations.size(); ++i)
			node->m_variations[i]->finish(myBoard);

		myBoard.prepareUndo(node->m_move);
		myBoard.prepareForSan(node->m_move);
		myBoard.doMove(node->m_move);
	}
}


void
MoveNode::setMark()
{
	m_flags |= HasMark;
	addMark(Mark());
}


util::crc::checksum_t
MoveNode::computeChecksum(util::crc::checksum_t crc) const
{
	if (m_move)
		crc = m_move.computeChecksum(crc);

	if (m_next)
		crc = m_next->computeChecksum(crc);

	for (unsigned i = 0; i < variationCount(); ++i)
		crc = variation(i)->computeChecksum(crc);

	return crc;
}


void
MoveNode::collectLanguages(LanguageSet& langSet) const
{
	m_comment[0].collectLanguages(langSet);
	m_comment[1].collectLanguages(langSet);

	if (m_next)
		m_next->collectLanguages(langSet);

	for (unsigned i = 0; i < variationCount(); ++i)
		variation(i)->collectLanguages(langSet);
}


bool
MoveNode::containsIllegalMoves() const
{
	for (MoveNode const* p = atLineStart() ? m_next : this; p; p = p->m_next)
	{
		if (!p->m_move.isLegal())
			return true;

		if (p->hasVariation())
		{
			for (unsigned i = 0; i < p->variationCount(); ++i)
			{
				if (p->variation(i)->containsIllegalMoves())
					return true;
			}
		}
	}

	return false;
}


bool
MoveNode::contains(MoveNode const* node) const
{
	for (MoveNode const* p = this; p; p = p->m_next)
	{
		if (p == node)
			return true;

		if (p->hasVariation())
		{
			for (unsigned i = 0; i < p->variationCount(); ++i)
			{
				if (p->variation(i)->contains(node))
					return true;
			}
		}
	}

	return false;
}


bool
MoveNode::containsEnglishLang() const
{
	for (MoveNode const* p = this; p; p = p->m_next)
	{
		if (p->m_comment[0].engFlag() || p->m_comment[1].engFlag())
			return true;
	}

	return false;
}


bool
MoveNode::containsOtherLang() const
{
	for (MoveNode const* p = this; p; p = p->m_next)
	{
		if (p->m_comment[0].othFlag() || p->m_comment[1].othFlag())
			return true;
	}

	return false;
}


void
MoveNode::unfold()
{
	MoveNode* node = this;

	while (!node->atLineStart())
		node = node->m_prev;

	node->m_flags &= ~IsFolded;
}


bool MoveNode::checkHasMark() const			{ return !m_marks->isEmpty(); }
bool MoveNode::checkHasAnnotation() const	{ return !m_annotation->isEmpty(); }

// vi:set ts=3 sw=3:
