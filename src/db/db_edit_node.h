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

#ifndef _db_edit_node_included
#define _db_edit_node_included

#include "db_board.h"
#include "db_move.h"
#include "db_edit_key.h"
#include "db_comment.h"
#include "db_annotation.h"
#include "db_eco.h"

#include "m_vector.h"
#include "m_map.h"
#include "m_string.h"
#include "m_utility.h"

namespace db {

class Comment;
class Annotation;
class MarkSet;
class MoveNode;
class TagSet;
class EngineList;
class GameLinkSet;

namespace edit {

class Visitor;
class Languages;
class Root;
class Variation;


class Node
{
public:

	enum Type
	{
		TRoot, TOpening, TLanguages,	// root level (unused)
		TAction,								// root level (used)
		TMove, TDiagram, TVariation,	// variation level
		TPly, TAnnotation, TStates, TMarks, TGameLink, TLink, TComment, TSpace,	// move level
	};

	enum Bracket { Blank, Open, Close, CloseFold, End, Fold, Empty, Start };

	typedef mstl::vector<Node const*> List;
	typedef mstl::map<mstl::string,unsigned> LanguageSet;

	virtual ~Node() = 0;

	virtual bool operator==(Node const* node) const;
	bool operator!=(Node const* node) const;

	virtual bool operator<(Node const* node) const;

	virtual Type type() const = 0;

	virtual void visit(Visitor& visitor) const = 0;

	static void visit(Visitor& visitor,
							List const& nodes,
							TagSet const& tags,
							termination::State termination,
							color::ID toMove);

protected:

	struct Work;
	struct Spacing;

	static char const PrefixDiagram	= 'd';
	static char const PrefixComment	= 'c';

	bool isRoot() const;
};


class KeyNode : public Node
{
public:

	typedef mstl::vector<KeyNode const*> List;

	KeyNode(Key const& key);
	KeyNode(Key const& key, char prefix);

	using Node::operator==;
	bool operator==(KeyNode const* node) const;
	bool operator!=(KeyNode const* node) const;

	Key const& key() const;
	virtual Key const& startKey() const;
	virtual Key const& endKey() const;

protected:

	Key m_key;
};


class Action : public Node
{
public:

	enum Command { Clear, Insert, Replace, Remove, Finish };

	Action(Command command);
	Action(Command command, unsigned level);
	Action(Command command, unsigned level, Key const& beforeKey);
	Action(Command command, unsigned level, Key const& startKey, Key const& endKey);

	Type type() const override;
	Command command() const;
	Key start() const;
	Key end() const;
	unsigned level() const;

	void replace(unsigned level, Key const& start, Key const& end);

	void visit(Visitor& visitor) const override;

private:

	Command	m_command;
	Key		m_key1;
	Key		m_key2;
	unsigned	m_level;
};


class Root : public Node, private mstl::noncopyable
{
public:

	Root();
	~Root();

	Type type() const override;

	void visit(Visitor& visitor) const override;
	void difference(Root const* root, List& nodes) const;

	static Root* makeList(	TagSet const& tags,
									uint16_t idn,
									Eco eco,
									db::Board const& startBoard,
									variant::Type variant,
									db::Board const& finalBoard,
									termination::State termination,
									MoveNode const* node,
									unsigned linebreakThreshold,
									unsigned linebreakMaxLineLength,
									unsigned displayStyle);
	static Root* makeList(	TagSet const& tags,
									uint16_t idn,
									Eco eco,
									db::Board const& startBoard,
									variant::Type variant,
									db::Board const& finalBoard,
									termination::State termination,
									LanguageSet const& langSet,
									LanguageSet const& wantedLanguages,
									db::EngineList const& engines,
									MoveNode const* node,
									unsigned linebreakThreshold,
									unsigned linebreakMaxLineLength,
									unsigned linebreakMaxLineLengthVar,
									unsigned linebreakMinCommentLength,
									unsigned displayStyle,
									unsigned moveInfoTypes);

	Node* newAction(Action::Command command) const;
	Node* newAction(Action::Command command, unsigned level) const;
	Node* newAction(Action::Command command, unsigned level, Key const& beforeKey) const;
	Node* newAction(Action::Command command, unsigned level, Key const& startKey, Key const& endKey)const;

private:

	typedef termination::State FinalState;

	static void makeList(Work& work,
								KeyNode::List& result,
								MoveNode const* node,
								variant::Type variant,
								unsigned varNo,
								unsigned varCount);
	static MoveNode const* traverseLine(Work& work,
													KeyNode::List& result,
													MoveNode const* node,
													variant::Type variant);

	Node*				m_opening;
	Node* 			m_languages;
	Variation*		m_variation;
	result::ID		m_result;
	FinalState		m_termination;
	color::ID		m_toMove;
	mutable List	m_nodes;
};


class Opening : public Node
{
public:

	Opening(Board const& startBoard, variant::Type variant, uint16_t idn, Eco eco);

	bool operator==(Node const* node) const override;

	Type type() const override;

	void visit(Visitor& visitor) const override;

private:

	Board				m_board;
	variant::Type	m_variant;
	uint16_t			m_idn;
	db::Eco			m_eco;
};


class Languages : public Node
{
public:

	Languages(MoveNode const* root = 0);

	bool operator==(Node const* node) const override;

	Type type() const override;
	LanguageSet const& langSet() const;
	void visit(Visitor& visitor) const override;

private:

	LanguageSet m_langSet;
};


class Variation : public KeyNode, private mstl::noncopyable
{
public:

	Variation(Key const& key);
	Variation(Key const& key, Key const& succ);
	~Variation();

	bool operator==(Node const* node) const override;

	bool empty() const;

	Type type() const override;

	using KeyNode::key;
	Key const& startKey() const override;
	Key const& endKey() const override;
	Key const& successor() const;

	void visit(Visitor& visitor) const override;

private:

	friend class Root;

	void difference(	Root const* root,
							Variation const* var,
							unsigned level,
							Node::List& nodes) const;
	static void pushRemove(	Root const* root,
									Node::List& nodes,
									unsigned level,
									Key const& start,
									Key const& end);

	List	m_list;
	Key	m_succ;
};


class MovePart : public Node
{
public:

	MovePart();

	void markAsInserted() const;
	void markAsChanged() const;

private:

	enum State { Inserted, Changed, Unchanged };

	mutable State m_state;
};


class Ply : public MovePart
{
public:

	Ply();
	Ply(db::MoveNode const* move, unsigned moveno = 0);

	bool operator==(Node const* node) const override;

	Type type() const override;
	unsigned moveNo() const;
	db::Move const& move() const;

	void visit(Visitor& visitor) const override;

private:

	unsigned m_moveNo;
	db::Move m_move;
};


class Move : public KeyNode, private mstl::noncopyable
{
public:

	typedef Node::List List;

	Move(Work& work, MoveNode const* move);
	Move(Work& work, db::Comment const& comment, unsigned varNo, unsigned varCount);
	Move(Work& work, MoveNode const* move, bool isEmptyGame, unsigned varNo, unsigned varCount);

	Move(Key const& key);
	Move(Spacing& spacing, Key const& key, unsigned moveNumber, MoveNode const* move);

	~Move();

	bool operator==(Node const* node) const override;

	Type type() const override;

	Ply const* ply() const;

	void visit(Visitor& visitor) const override;
	void markDifferences(Move const& move) const;

private:

	friend class Root;

	void getMoveInfo(Work& work, db::MoveNode const* move, mstl::string& result);

	List	m_list;
	Ply*	m_ply;
};


class Diagram : public KeyNode
{
public:

	Diagram(Work& work, color::ID fromColor);

	bool operator==(Node const* node) const override;

	Type type() const override;

	void visit(Visitor& visitor) const override;

private:

	db::Board	m_board;
	color::ID	m_fromColor;
};


class Comment : public MovePart
{
public:

	enum VarPos { Inside, AtStart, AtEnd, Finally };

	Comment(db::Comment const& comment, move::Position position, VarPos varPos = Inside);

	bool operator==(Node const* node) const override;
	bool operator< (Node const* node) const override;

	Type type() const override;

	void visit(Visitor& visitor) const override;

private:

	move::Position	m_position;
	VarPos			m_varPos;
	db::Comment		m_comment;
};


class Annotation : public MovePart
{
public:

	enum DisplayType	{ All, Numerical, Textual };
	enum Position		{ Prefix, Suffix };

	Annotation(	Position position,
					db::Annotation const& annotation,
					DisplayType displayType = All,
					bool skipDiagram = false);

	bool operator==(Node const* node) const override;
	bool operator< (Node const* node) const override;

	bool isEmpty() const;

	Type type() const override;

	void visit(Visitor& visitor) const override;

private:

	Position			m_position;
	DisplayType		m_displayType;
	db::Annotation	m_annotation;
};


class States : public Node
{
public:

	States(MoveNode const& node);

	Type type() const override;

	bool operator==(Node const* node) const override;

	void visit(Visitor& visitor) const override;

private:

	unsigned m_threefoldRepetition;
	unsigned m_fiftyMoveRule;
};


class Marks : public MovePart
{
public:

	Marks(MarkSet const& marks);

	bool operator==(Node const* node) const override;

	Type type() const override;

	void visit(Visitor& visitor) const override;

private:

	bool m_hasMarks;
};


class Space : public MovePart
{
public:

	Space();
	explicit Space(Bracket bracket);
	explicit Space(Bracket bracket, unsigned varNo, unsigned varCount);
	explicit Space(unsigned level);
	explicit Space(unsigned level, unsigned varNo, unsigned varCount, bool asNumber);

	bool operator==(Node const* node) const override;

	Type type() const override;

	void visit(Visitor& visitor) const override;

private:

	int		m_level;
	unsigned	m_varNo;
	unsigned	m_varCount;
	Bracket	m_bracket;
	bool		m_asNumber;
};


class Visitor
{
public:

	typedef Node::LanguageSet LanguageSet;
	typedef Node::Bracket Bracket;
	typedef Comment::VarPos VarPos;

	virtual ~Visitor();

	virtual void clear() = 0;
	virtual void insert(unsigned level, Key const& beforeKey) = 0;
	virtual void replace(unsigned level, Key const& startKey, Key const& endKey) = 0;
	virtual void remove(unsigned level, Key const& startKey, Key const& endKey) = 0;
	virtual void finish(unsigned level) = 0;

	virtual void opening(Board const& startBoard,
								variant::Type variant,
								uint16_t idn,
								Eco const& eco) = 0;
	virtual void languages(LanguageSet const& languages) = 0;
	virtual void move(unsigned moveNo, db::Move const& move) = 0;
	virtual void position(db::Board const& board, color::ID fromColor) = 0;
	virtual void comment(move::Position position, VarPos varPos, db::Comment const& comment) = 0;
	virtual void annotation(db::Annotation const& annotation, Annotation::DisplayType type) = 0;
	virtual void states(bool threefoldRepetition, bool fiftyMoveRule) = 0;
	virtual void marks(bool hasMarks) = 0;
	virtual void number(mstl::string const& number, bool isFirstVar) = 0;
	virtual void space(Bracket bracket, unsigned number, unsigned count) = 0;
	virtual void linebreak(unsigned level) = 0;

	virtual void start(result::ID result) = 0;
	virtual void finish(result::ID result, termination::State termination, color::ID toMove) = 0;

	virtual void startVariation(Key const& key, Key const& startKey, Key const& endKey) = 0;
	virtual void endVariation(Key const& key, Key const& startKey, Key const& endKey) = 0;

	virtual void startMove(Key const& key) = 0;
	virtual void endMove(Key const& key) = 0;

	virtual void startDiagram(Key const& key) = 0;
	virtual void endDiagram(Key const& key) = 0;
};

} // namespace edit
} // namespace db

#include "db_edit_node.ipp"

#endif // _db_edit_node_included

// vi:set ts=3 sw=3:
