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

#ifndef _db_edit_node_included
#define _db_edit_node_included

#include "db_board.h"
#include "db_move.h"
#include "db_eco.h"
#include "db_edit_key.h"
#include "db_comment.h"

#include "m_vector.h"
#include "m_map.h"
#include "m_string.h"

namespace db {

class Comment;
class Annotation;
class MarkSet;
class MoveNode;
class TagSet;

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
		TRoot, TOpening, TLanguages,						// root level (unused)
		TAction,													// root level (used)
		TPreComment, TMove, TDiagram, TVariation,		// variation level
		TPly, TAnnotation, TMarks, TComment, TSpace,	// move level
	};

	enum DisplayStyle
	{
		CompactStyle,
		ColumnStyle,
	};

	enum Bracket
	{
		None = ' ',
		Open = '(',
		Close = ')',
	};

	enum
	{
		NoSpace			= 0,
		PrefixSpace		= 1 << 0,
		PrefixBreak		= 1 << 1,
		SuffixBreak		= 1 << 2,
		ForcedBreak		= 1 << 3,
		RequiredBreak	= 1 << 4,
	};

	typedef mstl::vector<Node const*> List;
	typedef mstl::map<mstl::string,unsigned> LanguageSet;

	virtual ~Node() throw() = 0;

	virtual bool operator==(Node const* node) const;
	bool operator!=(Node const* node) const;

	virtual Type type() const = 0;

	virtual void visit(Visitor& visitor) const = 0;
	virtual void dump(unsigned level) const = 0;
	void dump() const;

	static void visit(Visitor& visitor, List const& nodes, TagSet const& tags);
	static void setStyle(DisplayStyle style);

	static unsigned linebreakThreshold;
	static unsigned linebreakMaxLineLengthMain;
	static unsigned linebreakMaxLineLengthVar;
	static unsigned linebreakMinCommentLength;

protected:

	static char const PrefixDiagram	= 'd';
	static char const PrefixComment	= 'c';

	bool isRoot() const;

	struct Work
	{
		LanguageSet const*	wantedLanguages;
		db::Board				board;
		Languages*				languages;
		Key						key;
		unsigned					spacing;
		Bracket					bracket;
		bool						needMoveNo;
		unsigned					level;
		unsigned					linebreakMaxLineLength;
		unsigned					plyCount;
	};

	static DisplayStyle m_style;
};


class KeyNode : public Node
{
public:

	typedef mstl::vector<KeyNode const*> List;

	KeyNode(Key const& key);
	KeyNode(Key const& key, char prefix);

	bool operator==(KeyNode const* node) const;
	bool operator!=(KeyNode const* node) const;

	bool operator<(KeyNode const* node) const;
	bool operator>(KeyNode const* node) const;

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

	Type type() const;

	void visit(Visitor& visitor) const;
	void dump(unsigned level) const;

private:

	Command	m_command;
	Key		m_key1;
	Key		m_key2;
	unsigned	m_level;
};


class Root : public Node
{
public:

	Root();
	~Root() throw();

	Type type() const;

	void visit(Visitor& visitor) const;
	void difference(Root const* root, List& nodes) const;
	void dump(unsigned level) const;

	static Root* makeList(	TagSet const& tags,
									uint16_t idn,
									Eco eco,
									db::Board const& startBoard,
									MoveNode const* node);
	static Root* makeList(	TagSet const& tags,
									uint16_t idn,
									Eco eco,
									db::Board const& startBoard,
									LanguageSet const& langSet,
									LanguageSet const& wantedLanguages,
									MoveNode const* node);

	Node* newAction(Action::Command command) const;
	Node* newAction(Action::Command command, unsigned level) const;
	Node* newAction(Action::Command command, unsigned level, Key const& beforeKey) const;
	Node* newAction(Action::Command command, unsigned level, Key const& startKey, Key const& endKey)const;

private:

	static void makeList(Work& work, KeyNode::List& result, MoveNode const* node);

	Node*				m_opening;
	Node* 			m_languages;
	Variation*		m_variation;
	result::ID		m_result;
	mutable List	m_nodes;
};



class Opening : public Node
{
public:

	Opening(Board const& startBoard, uint16_t idn, Eco eco);

	bool operator==(Node const* node) const;

	Type type() const;

	void visit(Visitor& visitor) const;
	void dump(unsigned level) const;

private:

	Board		m_board;
	uint16_t	m_idn;
	db::Eco	m_eco;
};


class Languages : public Node
{
public:

	Languages(MoveNode const* root = 0);

	bool operator==(Node const* node) const;

	Type type() const;
	LanguageSet const& langSet() const;

	void visit(Visitor& visitor) const;
	void dump(unsigned level) const;

private:

	LanguageSet m_langSet;
};


class Variation : public KeyNode
{
public:

	Variation(Key const& key);
	Variation(Key const& key, Key const& succ);
	~Variation() throw();

	bool operator==(Node const* node) const;

	bool empty() const;

	Type type() const;

	Key const& startKey() const;
	Key const& endKey() const;
	Key const& successor() const;

	void visit(Visitor& visitor) const;
	void dump(unsigned level) const;

private:

	friend class Root;

	void difference(Root const* root, Variation const* var, unsigned level, Node::List& nodes) const;

	List	m_list;
	Key	m_succ;
};


class Ply : public Node
{
public:

	Ply(db::MoveNode const* move, unsigned moveno = 0);

	bool operator==(Node const* node) const;

	Type type() const;
	unsigned moveNo() const;
	db::Move const& move() const;

	void visit(Visitor& visitor) const;
	void dump(unsigned level) const;

private:

	unsigned m_moveNo;
	db::Move m_move;
};


class Move : public KeyNode
{
public:

	typedef Node::List List;

	Move(Work& work);
	Move(Work& work, MoveNode const* move);
	Move(Key const& key);
	Move(Key const& key, unsigned moveNumber, unsigned spacing, MoveNode const* move);
	~Move() throw();

	bool operator==(Node const* node) const;

	Type type() const;

	Ply const* ply() const;

	void visit(Visitor& visitor) const;
	void dump(unsigned level) const;

private:

	List	m_list;
	Ply*	m_ply;
};


class PreComment : public KeyNode
{
public:

	PreComment(Work const& work, db::Comment const& comment);

	bool operator==(Node const* node) const;

	Type type() const;

	void visit(Visitor& visitor) const;
	void dump(unsigned level) const;

private:

	db::Comment m_comment;
};


class Diagram : public KeyNode
{
public:

	Diagram(Work& work, color::ID fromColor);

	bool operator==(Node const* node) const;

	Type type() const;

	void visit(Visitor& visitor) const;
	void dump(unsigned level) const;

private:

	db::Board	m_board;
	color::ID	m_fromColor;
	bool			m_prefixBreak;
};


class Comment : public Node
{
public:

	Comment(db::Comment const& comment);

	bool operator==(Node const* node) const;

	Type type() const;

	void visit(Visitor& visitor) const;
	void dump(unsigned level) const;

private:

	db::Comment m_comment;
};


class Annotation : public Node
{
public:

	Annotation(db::Annotation const& annotation);

	bool operator==(Node const* node) const;

	Type type() const;

	void visit(Visitor& visitor) const;
	void dump(unsigned level) const;

private:

	db::Annotation const& m_annotation;
};


class Marks : public Node
{
public:

	Marks(MarkSet const& marks);

	bool operator==(Node const* node) const;

	Type type() const;

	void visit(Visitor& visitor) const;
	void dump(unsigned level) const;

private:

	db::MarkSet const& m_marks;
};


class Space : public Node
{
public:

	Space(Bracket bracket = None);
	Space(unsigned level, Bracket bracket = None);

	bool operator==(Node const* node) const;

	Type type() const;

	void visit(Visitor& visitor) const;
	void dump(unsigned level) const;

private:

	int		m_level;
	Bracket	m_bracket;
};


class Visitor
{
public:

	typedef Node::LanguageSet LanguageSet;

	virtual ~Visitor() throw();

	virtual void clear() = 0;
	virtual void insert(unsigned level, Key const& beforeKey) = 0;
	virtual void replace(unsigned level, Key const& startKey, Key const& endKey) = 0;
	virtual void remove(unsigned level, Key const& startKey, Key const& endKey) = 0;
	virtual void finish(unsigned level) = 0;

	virtual void opening(Board const& startBoard, uint16_t idn, Eco const& eco) = 0;
	virtual void languages(LanguageSet const& languages) = 0;
	virtual void move(unsigned moveNo, db::Move const& move) = 0;
	virtual void position(db::Board const& board, color::ID fromColor) = 0;
	virtual void comment(Key const& key, db::Comment const& comment) = 0;
	virtual void comment(db::Comment const& comment) = 0;
	virtual void annotation(db::Annotation const& annotation) = 0;
	virtual void marks(MarkSet const& marks) = 0;
	virtual void space(char bracket) = 0;
	virtual void linebreak(unsigned level, char bracket) = 0;

	virtual void start(result::ID result) = 0;
	virtual void finish(result::ID result) = 0;

	virtual void startVariation(Key const& startKey, Key const& endKey) = 0;
	virtual void endVariation(Key const& startKey, Key const& endKey) = 0;

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
