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
// Copyright: (C) 2010-2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "tk_base.h"
#include "tk_init.h"

#include "tcl_base.h"
#include "tcl_exception.h"

#include "m_vector.h"
#include "m_string.h"
#include "m_carray.h"
#include "m_map.h"
#include "m_limits.h"
#include "m_list.h"
#include "m_utility.h"
#include "m_assert.h"

#include <string.h>
#include <stdarg.h>
#include <stdio.h>

#undef None // defined inside tk.h


static void
releaseWindow(char const* path)
{
	M_ASSERT(path);

	Tk_Window tkwin = tk::window(path);

	if (!tkwin)
		M_THROW(tcl::Exception("invalid window '%s'", path));

	if (!tk::release(tkwin))
		M_THROW(tcl::Exception("failed to release window '%s'", path));
}


static void
captureWindow(char const* path, char const* receiver = nullptr)
{
	Tk_Window tkwin		= tk::window(path);
	Tk_Window tkparent	= 0;

	if (!tkwin)
		M_THROW(tcl::Exception("invalid window '%s'", path));

	if (receiver)
	{
		tkparent = tk::window(receiver);

		if (!tkparent)
			M_THROW(tcl::Exception("invalid receiver '%s'", receiver));
	}

	if (!tk::capture(tkwin, tkparent))
		M_THROW(tcl::Exception("failed to capture window '%s'", path));
}


static bool
isSubset(mstl::vector<mstl::string> const& lhs, mstl::vector<mstl::string> const& rhs)
{
	unsigned i = 0;
	unsigned k = 0;

	// test whether lhs is subset of rhs, both sets must be sorted

	while (i < lhs.size() && k < rhs.size())
	{
		if (lhs[i] == rhs[k])
		{
			++i;
			++k;
		}
		else if (lhs[i] < rhs[k])
		{
			return false;
		}
		else // if (lhs[i] > rhs[k])
		{
			++k;
		}
	}

	return i == lhs.size();
}


namespace {

static Tcl_Obj* m_obj							= nullptr;
static Tcl_Obj* m_objBoth						= nullptr;
static Tcl_Obj* m_objBuildCmd					= nullptr;
static Tcl_Obj* m_objDeiconifyCmd			= nullptr;
static Tcl_Obj* m_objDestroyCmd				= nullptr;
static Tcl_Obj* m_objDirsLR					= nullptr;
static Tcl_Obj* m_objDirsTB					= nullptr;
static Tcl_Obj* m_objDirsTBLR					= nullptr;
static Tcl_Obj* m_objDirsTBLREW				= nullptr;
static Tcl_Obj* m_objDirsTBLRNS				= nullptr;
static Tcl_Obj* m_objDirsTBLRNSEW			= nullptr;
static Tcl_Obj* m_objFloating					= nullptr;
static Tcl_Obj* m_objFrame						= nullptr;
static Tcl_Obj* m_objFrame2Cmd				= nullptr;
static Tcl_Obj* m_objFrameHdrSizeCmd		= nullptr;
static Tcl_Obj* m_objGeometryCmd				= nullptr;
static Tcl_Obj* m_objHeaderCmd				= nullptr;
static Tcl_Obj* m_objHorizontal				= nullptr;
static Tcl_Obj* m_objHorz						= nullptr;
static Tcl_Obj* m_objMetaFrame				= nullptr;
static Tcl_Obj* m_objMultiWindow				= nullptr;
static Tcl_Obj* m_objNone						= nullptr;
static Tcl_Obj* m_objNormal					= nullptr;
static Tcl_Obj* m_objNotebook					= nullptr;
static Tcl_Obj* m_objNotebookHdrSizeCmd	= nullptr;
static Tcl_Obj* m_objOptAttrs					= nullptr;
static Tcl_Obj* m_objOptBefore				= nullptr;
static Tcl_Obj* m_objOptExpand				= nullptr;
static Tcl_Obj* m_objOptGrow					= nullptr;
static Tcl_Obj* m_objOptHeight				= nullptr;
static Tcl_Obj* m_objOptMaxHeight			= nullptr;
static Tcl_Obj* m_objOptMaxWidth				= nullptr;
static Tcl_Obj* m_objOptMinHeight			= nullptr;
static Tcl_Obj* m_objOptMinWidth				= nullptr;
static Tcl_Obj* m_objOptOrient				= nullptr;
static Tcl_Obj* m_objOptRecover				= nullptr;
static Tcl_Obj* m_objOptShrink				= nullptr;
static Tcl_Obj* m_objOptSnapshots			= nullptr;
static Tcl_Obj* m_objOptStructures			= nullptr;
static Tcl_Obj* m_objOptState					= nullptr;
static Tcl_Obj* m_objOptSticky				= nullptr;
static Tcl_Obj* m_objOptWidth					= nullptr;
static Tcl_Obj* m_objOptX						= nullptr;
static Tcl_Obj* m_objOptY						= nullptr;
static Tcl_Obj* m_objPackCmd					= nullptr;
static Tcl_Obj* m_objPaneConfigCmd			= nullptr;
static Tcl_Obj* m_objPanedWindow				= nullptr;
static Tcl_Obj* m_objPane						= nullptr;
static Tcl_Obj* m_objReadyCmd					= nullptr;
static Tcl_Obj* m_objResizingCmd				= nullptr;
static Tcl_Obj* m_objRoot						= nullptr;
static Tcl_Obj* m_objSashSizeCmd				= nullptr;
static Tcl_Obj* m_objSelectCmd				= nullptr;
static Tcl_Obj* m_objTitleCmd					= nullptr;
static Tcl_Obj* m_objUnpackCmd				= nullptr;
static Tcl_Obj* m_objVert						= nullptr;
static Tcl_Obj* m_objVertical					= nullptr;
static Tcl_Obj* m_objWithdrawn				= nullptr;
static Tcl_Obj* m_objWorkAreaCmd				= nullptr;
static Tcl_Obj* m_objX							= nullptr;
static Tcl_Obj* m_objY							= nullptr;


// IMPORTANT NOTE: order of Type should never change!
enum Type		{ Root, MetaFrame, Frame, Pane, PanedWindow, Notebook, MultiWindow, LAST = MultiWindow };

enum State		{ Packed, Floating, Withdrawn };
enum Sticky		{ West = 1, East = 2, North = 4, South = 8 };
enum Position	{ Center = 0, Left = West, Right = East, Top = North, Bottom = South };
enum Orient		{ Horz = Left|Right, Vert = Top|Bottom };
enum Expand		{ None = 0, X = Horz, Y = Vert, Both = X|Y };
enum Quantity	{ Actual, Min, Max };
enum Enclosure	{ Inner, Outer };


namespace structure {

enum Type { Leaf, Vert, Horz, Multi };


class Node
{
public:

	Node(Node* parent, Tcl_Obj* uid);
	Node(Node* parent, Type type);
	~Node();

	bool isLeaf() const;
	bool isHorz() const;
	bool isVert() const;
	bool isMulti() const;
	bool containsOneOf(tcl::List const& childs) const;

	Type type() const;

	unsigned numChilds() const;
	unsigned depth() const;
	const char* uid() const;
	Tcl_Obj* uidObj() const;

	Node const* child(unsigned i) const;
	Node const* parent() const;
	Node const* find(tcl::List const& leaves, int& level) const;

	void add(Node* node);
	void collectLeaves(tcl::List& leaves) const;
	void collectLeaves(mstl::vector<mstl::string>& leaves) const;
	void inspect(tcl::DString& list) const;
	void dump();

	static Node* load(Tcl_Obj* obj, Node* parent = nullptr);

private:

	typedef mstl::vector<Node*> Childs;

	bool hasParent(Node const* thisParent) const;

	Node* child(unsigned i);

	Node const* find(Tcl_Obj* uid, int& level) const;
	Node const* commonAncestor(Node const* node) const;

	void dump(unsigned level);

	Node*		m_parent;
	Type		m_type;
	Tcl_Obj*	m_uid;
	Childs	m_childs;
};


bool Node::isLeaf() const	{ return m_type == Leaf; }
bool Node::isHorz() const	{ return m_type == Horz; }
bool Node::isVert() const	{ return m_type == Vert; }
bool Node::isMulti() const	{ return m_type == Multi; }

Type Node::type() const { return m_type; }

unsigned Node::numChilds() const	{ return m_childs.size(); }
const char* Node::uid() const		{ M_ASSERT(isLeaf()); return tcl::asString(m_uid); }
Tcl_Obj* Node::uidObj() const		{ M_ASSERT(isLeaf()); return m_uid; }

Node const* Node::child(unsigned i) const	{ return m_childs[i]; }
Node* Node::child(unsigned i)					{ return m_childs[i]; }
Node const* Node::parent() const				{ return m_parent; }


Node::Node(Node* parent, Type type)
	:m_parent(parent)
	,m_type(type)
	,m_uid(nullptr)
{
	M_ASSERT(type != Leaf);
}


Node::Node(Node* parent, Tcl_Obj* uid)
	:m_parent(parent)
	,m_type(Leaf)
	,m_uid(tcl::incrRef(uid))
{
	M_ASSERT(parent);
}


Node::~Node()
{
	tcl::decrRef(m_uid);

	for (unsigned i = 0; i < numChilds(); ++i)
		delete child(i);
}


unsigned
Node::depth() const
{
	Node const* node = this;
	unsigned depth = 0;

	while (node->m_parent)
	{
		depth += 1;
		node = node->m_parent;
	}

	return depth;
}


void
Node::collectLeaves(tcl::List& leaves) const
{
	if (isLeaf())
	{
		leaves.push_back(m_uid);
	}
	else
	{
		for (unsigned i = 0; i < numChilds(); ++i)
			child(i)->collectLeaves(leaves);
	}
}


void
Node::collectLeaves(mstl::vector<mstl::string>& leaves) const
{
	if (isLeaf())
	{
		leaves.push_back(tcl::asString(m_uid));
	}
	else
	{
		for (unsigned i = 0; i < numChilds(); ++i)
			child(i)->collectLeaves(leaves);
	}
}


bool
Node::containsOneOf(tcl::List const& childs) const
{
	if (isLeaf())
	{
		for (unsigned i = 0; i < childs.size(); ++i)
		{
			if (tcl::equal(m_uid, childs[i]))
				return true;
		}
	}
	else
	{
		for (unsigned i = 0; i < numChilds(); ++i)
		{
			if (child(i)->containsOneOf(childs))
				return true;
		}
	}

	return false;
}


void
Node::add(Node* node)
{
	M_ASSERT(node);
	M_ASSERT(!isLeaf());
	m_childs.push_back(node);
}


bool
Node::hasParent(Node const* thisParent) const
{
	Node const* parent = m_parent;

	while (parent && parent != thisParent)
		parent = parent->m_parent;
	
	return parent != nullptr;
}


Node const*
Node::commonAncestor(Node const* node) const
{
	if (node == this)
		return this;

	if (node->hasParent(this))
		return this;
	
	if (hasParent(node))
		return node;
	
	M_ASSERT(m_parent);
	return m_parent->commonAncestor(node);
}


Node const*
Node::find(Tcl_Obj* uid, int& level) const
{
	level += 1;

	if (isLeaf())
		return tcl::equal(m_uid, uid) ? this : nullptr;

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (Node const* node = child(i)->find(uid, level))
			return node;
	}

	level -= 1;
	return nullptr;
}


Node const*
Node::find(tcl::List const& leaves, int& level) const
{
	Node const* commonAncestor = nullptr;

	for (unsigned i = 0; i < leaves.size(); ++i)
	{
		int myLevel = -1;

		if (Node const* node = find(leaves[i], myLevel))
		{
			if (level < 0 || myLevel < level)
				level = myLevel;

			commonAncestor = commonAncestor ? this->commonAncestor(node) : node;
		}
	}

	return commonAncestor;
}


void
Node::inspect(tcl::DString& list) const
{
	if (m_type == Leaf)
	{
		list.append(m_uid);
	}
	else
	{
		list.startList();

		switch (m_type)
		{
			case Leaf:	break;
			case Multi:	list.append("m"); break;
			case Horz:	list.append("h"); break;
			case Vert:	list.append("v"); break;
		}

		for (unsigned i = 0; i < numChilds(); ++i)
			child(i)->inspect(list);

		list.endList();
	}
}


Node*
Node::load(Tcl_Obj* obj, Node* parent)
{
	M_ASSERT(obj);

	tcl::Array elems = tcl::getElements(obj);
	Node* node;

	if (elems.size() == 1)
	{
		node = new Node(parent, elems[0]);
	}
	else
	{
		Type type;

		switch (*tcl::asString(elems[0]))
		{
			case 'm': type = Multi; break;
			case 'h': type = Horz; break;
			case 'v': type = Vert; break;
			default:  M_THROW(tcl::Exception("unknown structure type '%s'", tcl::asString(elems[0])));
		}

		node = new Node(parent, type);

		for (unsigned i = 1; i < elems.size(); ++i)
			node->add(load(elems[i], node));
	}

	return node;
}

#ifndef NDEBUG

void
Node::dump()
{
	printf("================================================\n");
	dump(0);
	printf("\n");
}


void
Node::dump(unsigned level)
{
	if (isLeaf())
	{
		printf(" %s", uid());
	}
	else
	{
		if (level > 0)
			printf(" ");
		printf("{ <%s>", m_type == Multi ? "multi" : (m_type == Horz ? "horz" : "vert"));
		for (unsigned i = 0; i < numChilds(); ++i)
			child(i)->dump(level + 1);
		printf(" }");
	}
}

#endif // NDEBUG
} // namespace structure


class Node;
typedef mstl::vector<Node*> Childs;


static Position
parsePositionOption(const char* s)
{
	M_ASSERT(s);

	if (tcl::equal(s, "center"))	return Center;
	if (tcl::equal(s, "left"))		return Left;
	if (tcl::equal(s, "right"))	return Right;
	if (tcl::equal(s, "top"))		return Top;
	if (tcl::equal(s, "bottom"))	return Bottom;

	M_THROW(tcl::Exception("invalid position option '%s'", s));
}


static int
parseExpandOption(Tcl_Obj* obj)
{
	M_ASSERT(obj);

	if (tcl::equal(obj, m_objBoth))	return X | Y;
	if (tcl::equal(obj, m_objX))		return X;
	if (tcl::equal(obj, m_objY))		return Y;
	if (tcl::equal(obj, m_objNone))	return 0;

	M_THROW(tcl::Exception("invalid expand option '%s'", tcl::asString(obj)));
}


static int parseResizeOption(Tcl_Obj* obj) { return parseExpandOption(obj); }


static int
parseStickyOption(const char* s)
{
	M_ASSERT(s);

	int sticky = 0;

	for ( ; *s; ++s)
	{
		switch (*s)
		{
			case 'n': sticky |= North; break;
			case 's': sticky |= South; break;
			case 'w': sticky |= West; break;
			case 'e': sticky |= East; break;
			case ' ': // fallthru
			case ',': break;
			default : M_THROW(tcl::Exception("invalid sticky option '%s'", s));
		}
	}

	return sticky;
}


static Orient
parseOrientOption(Tcl_Obj* obj)
{
	M_ASSERT(obj);

	if (tcl::equal(obj, m_objHorz) || tcl::equal(obj, m_objHorizontal))	return Horz;
	if (tcl::equal(obj, m_objVert) || tcl::equal(obj, m_objVertical))		return Vert;

	M_THROW(tcl::Exception("invalid orientation '%s'", tcl::asString(obj)));
}


static Type
parseTypeOption(Tcl_Obj* obj)
{
	M_ASSERT(obj);

	if (tcl::equal(obj, m_objRoot))			return Root;
	if (tcl::equal(obj, m_objPane))			return Pane;
	if (tcl::equal(obj, m_objFrame))			return Frame;
	if (tcl::equal(obj, m_objMetaFrame))	return MetaFrame;
	if (tcl::equal(obj, m_objMultiWindow))	return MultiWindow;
	if (tcl::equal(obj, m_objNotebook))		return Notebook;
	if (tcl::equal(obj, m_objPanedWindow))	return PanedWindow;

	M_THROW(tcl::Exception("unknown type '%s'", tcl::asString(obj)));
}


static char const*
makeTypeID(Type type)
{
	switch (type)
	{
		case Root:			return tcl::asString(m_objRoot);
		case Pane:			return tcl::asString(m_objPane);
		case Frame:			return tcl::asString(m_objFrame);
		case MetaFrame:	return tcl::asString(m_objMetaFrame);
		case MultiWindow:	return tcl::asString(m_objMultiWindow);
		case Notebook:		return tcl::asString(m_objNotebook);
		case PanedWindow:	return tcl::asString(m_objPanedWindow);
	}
	return nullptr; // never reached
}


static char const*
makeStickyOptionValue(int sticky, mstl::string& buf)
{
	if (sticky & North) buf.append('n');
	if (sticky & South) buf.append('s');
	if (sticky & East)  buf.append('e');
	if (sticky & West)  buf.append('w');
	return buf.c_str();
}


static char const*
makeOrientationOptionValue(int orientation)
{
	M_ASSERT(orientation);
	return tcl::asString(orientation & Horz ? m_objHorizontal : m_objVertical);
}


static char const*
makeExpandOptionValue(int expand)
{
	if ((expand & (X|Y)) == (X|Y)) return tcl::asString(m_objBoth);
	if (expand & X) return tcl::asString(m_objX);
	if (expand & Y) return tcl::asString(m_objY);
	return tcl::asString(m_objNone);
}

static char const* makeResizeOptionValue(int resize) { return makeExpandOptionValue(resize); }


struct Terminated {};


struct Coord
{
	Coord() :x(0), y(0) {}

	int x;
	int y;
};


struct Size
{
	Size() :width(0), height(0) {}

	int width;
	int height;

	template <Orient D> int dimen() const;

	int area() const { return width*height; }

	void zero() { width = height = 0; }
	template <Orient D> void set(int size);
};

template <> int Size::dimen<Horz>() const { return width; }
template <> int Size::dimen<Vert>() const { return height; }

template <> void Size::set<Horz>(int size) { width = size; }
template <> void Size::set<Vert>(int size) { height = size; }

bool operator==(Size const& lhs, Size const& rhs)
{ return lhs.width == rhs.width && lhs.height == rhs.height; }

bool operator<=(Size const& lhs, Size const& rhs)
{ return lhs.width <= rhs.width && lhs.height <= rhs.height; }

bool operator<(Size const& lhs, Size const& rhs)
{ return lhs.width < rhs.width && lhs.height < rhs.height; }

bool operator!=(Size const& lhs, Size const& rhs) { return !operator==(lhs, rhs); }
bool operator>=(Size const& lhs, Size const& rhs) { return !operator< (lhs, rhs); }
bool operator> (Size const& lhs, Size const& rhs) { return !operator<=(lhs, rhs); }


typedef mstl::map<mstl::string,Size> SizeMap;

struct Snapshot
{
	Size		size;
	SizeMap	sizeMap;
};


struct Dimension
{
	Size min;
	Size max;
	Size actual;

	template <Orient D,Quantity Q = Actual> int dimen() const;
	template <Orient D,Quantity Q = Actual> void set(int size) __m_warn_unused;

	void setActual(int width, int height);
	void zero();
};

template <> int Dimension::dimen<Horz,Actual>() const		{ return actual.dimen<Horz>(); }
template <> int Dimension::dimen<Vert,Actual>() const		{ return actual.dimen<Vert>(); }
template <> int Dimension::dimen<Horz,Min>() const			{ return min.dimen<Horz>(); }
template <> int Dimension::dimen<Vert,Min>() const			{ return min.dimen<Vert>(); }
template <> int Dimension::dimen<Horz,Max>() const			{ return max.dimen<Horz>(); }
template <> int Dimension::dimen<Vert,Max>() const			{ return max.dimen<Vert>(); }

template <> void Dimension::set<Horz,Actual>(int size)	{ actual.width = size; }
template <> void Dimension::set<Vert,Actual>(int size)	{ actual.height = size; }
template <> void Dimension::set<Horz,Min>(int size)		{ min.width = size; }
template <> void Dimension::set<Vert,Min>(int size)		{ min.height = size; }
template <> void Dimension::set<Horz,Max>(int size)		{ max.width = size; }
template <> void Dimension::set<Vert,Max>(int size)		{ max.height = size; }


bool operator==(Dimension const& lhs, Dimension const& rhs)
{ return lhs.actual == rhs.actual && lhs.min == rhs.min && lhs.max == rhs.max; }

bool operator!=(Dimension const& lhs, Dimension const& rhs)
{ return !operator==(lhs, rhs); }


void
Dimension::setActual(int width, int height)
{
	if (min.width)
		width = mstl::max(width, min.width);
	if (max.width)
		width = mstl::min(width, min.width);
	if (min.height)
		height = mstl::max(height, min.height);
	if (max.height)
		height = mstl::min(height, min.height);

	actual.width = width;
	actual.height = height;
}


void
Dimension::zero()
{
	actual.zero();
	min.zero();
	max.zero();
}


struct Base
{
	Base() :root(nullptr), setup(nullptr) {}

	Node* root;
	Node* setup;
};


class Node
{
public:

	typedef mstl::vector<mstl::string> AttrSet;
	typedef mstl::map<mstl::string,Node*> LeafMap;

	~Node();

	bool isEmpty() const;
	bool isRoot() const;
	bool isContainer() const;
	bool isPanedWindow() const;
	bool isMultiWindow() const;
	bool isNotebook() const;
	bool isNotebookOrMultiWindow() const;
	bool isFrame() const;
	bool isMetaFrame() const;
	bool isFrameOrMetaFrame() const;
	bool isPane() const;
	bool isLeaf() const;
	bool isPacked() const;
	bool isWithdrawn() const;
	bool isDeleted() const;
	bool isDestroyed() const;
	bool isFloating() const;
	bool isToplevel() const;
	bool isLocked() const;
	bool isHorz() const;
	bool isVert() const;
	bool hasChilds() const;
	bool hasAncestor(Node const* node) const;
	bool contains(Node const* node) const;
	bool exists() const;
	bool isAlreadyDead() const;

	template <Orient D> bool grow() const;
	template <Orient D> bool shrink() const;
	template <Orient D> bool orientation() const;

	unsigned numChilds() const;
	unsigned descendantOf(Node const* child) const;
	unsigned depth() const;
	int sashSize() const;
	int frameHeaderSize() const;
	int notebookHeaderSize() const;
	int multiwindowHeaderSize() const;
	Tk_Window tkwin() const;
	char const* uid() const;
	char const* path() const;
	char const* id() const; // for debugging
	Tcl_Obj* uidObj() const;
	Tcl_Obj* pathObj() const;
	Tcl_Obj* typeObj() const;
	int expand() const;
	int sticky() const;
	int x() const;
	int y() const;
	template <Enclosure Enc> int width() const;
	template <Enclosure Enc> int height() const;
	template <Enclosure Enc> int minWidth() const;
	template <Enclosure Enc> int minHeight() const;
	template <Enclosure Enc> int maxWidth() const;
	template <Enclosure Enc> int maxHeight() const;
	template <Enclosure Enc,Orient D,Quantity Q = Actual> int dimen() const;
	template <Enclosure Enc,Orient D> int actualSize() const;
	template <Enclosure Enc,Orient D> int maxSize() const;
	template <Enclosure Enc,Orient D> int minSize() const;
	Node* parent() const;
	Node* root() const;
	Node* toplevel() const;
	Node* selected() const;
	Node* clone(LeafMap const& leaves) __m_warn_unused;

	tcl::List collectFrames() const;
	tcl::List collectPanes() const;
	tcl::List collectPanesRecursively() const;
	tcl::List collectLeaves() const;
	tcl::List collectContainer() const;
	tcl::List collectFloats() const;
	tcl::List collectVisible() const;
	tcl::List collectHidden() const;
	tcl::List findWindows(char const* attr, Tcl_Obj* value) const;

	Tcl_Obj* inspect(AttrSet const& exportList) const;

	Node const* child(unsigned i) const;
	Node* child(unsigned i);

	Node const* child() const;
	Node* child();

	void refresh();
	void resize(int width, int height, int minWidth, int minHeight, int maxWidth, int maxHeight);
	void setState(State state);
	void updateDimen(int x, int y, int width, int height);
	void perform(Node* toplevel = nullptr);
	void show();
	void ready();

	Node* findPath(char const* path);
	Node* findUid(char const* uid);
	Node const* findUid(char const* uid) const;
	Node* getCurrent() const;
	Node const* leftNeighbor(Node const* neighbor) const;
	Node const* rightNeighbor(Node const* neighbor) const;
	Node const* findLeader() const;

	void set(char const* attribute, Tcl_Obj* value, bool ignoreMeta);
	Tcl_Obj* get(char const* attribute, bool ignoreMeta) const;

	void load(Tcl_Obj* list);
	void load(Tcl_Obj* list, LeafMap const* leaves, Node const* sRoot);
	void saveLeaves(LeafMap& leaves);
	void create();
	void destroy();
	void pack();
	void reparentChildsRecursively(Tk_Window topLevel);
	void select();
	void isSelected();
	void withdraw();
	void unpack();
	void packChilds();
	void remove(Node* node);
	void remove();
	void floating(bool temporary);
	void unfloat(Node* toplevel);
	void toggle();
	void destroyed(bool finalize);
	void makeMetaFrame();
	void setShowBar(bool flag);
	void dump() const;

	Node* dock(Node*& recv, Position position, Node const* setup);
	Node const* makeNew(Tcl_Obj* typeObj, Tcl_Obj* uidObj, Tcl_Obj* optObj, Node const* setup);
	Node const* makeClone(Tcl_Obj* uidObj);

	static bool isRoot(Type type);
	static bool isMetaFrame(Type type);
	static bool isContainer(Type type);
	static bool isLeaf(Type type);

	static Base* createBase(Tcl_Obj* path) __m_warn_unused;
	static void removeBase(char const* path);
	static Base* lookupBase(char const* path);
	static Node* makeRoot(Tcl_Obj* path) __m_warn_unused;

private:

	typedef mstl::map<mstl::string,Tcl_Obj*> AttrMap;
	typedef mstl::map<mstl::string,Snapshot> SnapshotMap;
	typedef mstl::vector<structure::Node*> Structures;

	enum Flag
	{
		F_Create		= 1 << 0,
		F_Pack		= 1 << 1,
		F_Unpack		= 1 << 2,
		F_Destroy	= 1 << 3,
		F_Select		= 1 << 4,
		F_Reparent	= 1 << 5,
		F_Raise		= 1 << 6,
		F_Config		= 1 << 7,
		F_Unframe	= 1 << 8,
		F_Build		= 1 << 9,
		F_Header		= 1 << 10,
		F_Docked		= 1 << 11,
		F_Undocked	= 1 << 12,
		F_Deiconify	= 1 << 13,
	};

	Node(Tcl_Obj* path, Node const* setup = nullptr);
	Node(Node& parent, Type type, Tcl_Obj* uid = nullptr);
	Node(Node const& node);

	bool fits(Size size, Position position) const;

	Childs::const_iterator begin() const;
	Childs::const_iterator end() const;

	Childs::iterator find(Node const* node);
	Childs::const_iterator find(Node const* node) const;
	Node const* findAfter(bool onlyPackedChild = false) const;
	Node const* findRelation(structure::Node const* parent, tcl::List const& childs) const;
	Position defaultPosition() const;
	void collectLeaves(mstl::vector<mstl::string>& result) const;
	void collectFramesRecursively(tcl::List& result) const;
	void collectPanesRecursively(tcl::List& result) const;
	void collectLeavesRecursively(tcl::List& result) const;
	void collectVisibleRecursively(tcl::List& result) const;
	void inspect(AttrSet const& exportList, tcl::DString& str) const;
	void inspectAttrs(AttrSet const& exportList, tcl::DString& str) const;
	void inspect(tcl::DString& str, Structures const& structures) const;
	static void inspect(tcl::DString& str, SnapshotMap const& snapshots);

	Tcl_Obj* makeOptions(Flag flags, Node const* before = nullptr) const __m_warn_unused;
	void parseOptions(Tcl_Obj* opts);
	void parseSnapshot(Tcl_Obj* obj);
	void parseAttributes(Tcl_Obj* obj);
	void parseStructures(Tcl_Obj* obj);

	void load(Tcl_Obj* list, LeafMap const* leaves);
	void finishLoad(LeafMap const* leaves, Node const* sRoot = nullptr);
	void makeStructure();
	structure::Node* makeStructure(structure::Node* parent) const __m_warn_unused;
	void releaseStructures();

	void move(Node* node, Node const* before = nullptr);
	void add(Node* node, Node const* before = nullptr);

	void computeDimensionsRecursively();
	void adjustDimensions();
	void resizeDimensions();
	void unframe();
	void flatten();
	void deleteChilds();
	void resizeToParent(int dir);

	template <Orient D,Quantity Q = Actual> void addDimen(Node const* node);
	template <Orient D,Quantity Q = Actual> void adjustDimen(double f);

	unsigned descendantOf(Node const* child, unsigned level) const;

	template <Orient D> int contentSize(int size) const;
	template <Orient D,Enclosure Enc = Outer> int frameSize(int size) const;

	template <Orient D> void adjustToplevel();
	template <Orient D> void doAdjustment(int size);
	template <Orient D> void resizeFrame(int reqSize);
	template <Orient D> void expandPanes(int computedSize, int space);
	template <Orient D> void shrinkPanes(int computedSize, int space);

	template <Orient D> int doExpandPanes(int space, bool expandable, int stage) __m_warn_unused;
	template <Orient D> int doShrinkPanes(int space, bool expandable, int stage) __m_warn_unused;
	template <Orient D> int computeExpand(int stage) const __m_warn_unused;
	template <Orient D> int computeShrink(int stage) const __m_warn_unused;
	template <Orient D> int computeUnderflow() const __m_warn_unused;

	template <Orient D> bool isExpandable() const;

	Node* insertNotebook(Node* child, Type type, Node const* beforeChild = nullptr);
	Node* insertPanedWindow(Position position, Node* child, Node const* beforeChild = nullptr);
	Node* clone(LeafMap const& leaves, Node* parent) const __m_warn_unused;
	Node* clone(Node* parent, Tcl_Obj* uid) const __m_warn_unused;
	Node* findDockingNode(Position& position, Node const*& after, Node const* setup);
	Node* dock(Node* node, Position position, Node const* before, bool newParent);
	Node* findBestPlace(Dimension const& dimen, int& bestDistance);
	Node* findBest(tcl::List const& childs);
	unsigned findBest(tcl::List const& childs, Node*& bestNode, unsigned& bestCount);

	void insertNode(Node* node, Node const* before = nullptr);
	void remove(Childs::iterator pos);
	void updateAllHeaders();
	void updateHeader();

	void addFlag(unsigned flag);
	void delFlag(unsigned flag);
	bool testFlags(unsigned flag) const;

	void makeSnapshot();
	bool makeSnapshot(mstl::string& structure, SizeMap* sizeMap) const;
	void makeSnapshotKey(mstl::string& structure) const;
	bool applySnapshot();
	void applySnapshot(double scaleWidth, double scaleHeight, SizeMap const& sizeMap);

	void performCreate();
	void performFinalizeCreate();
	void performBuild();
	void performReady();
	void performPack();
	void performUnpack(Node* parent);
	void performConfig();
	void performGeometry();
	void performSelect();
	void performDestroy();
	void performUpdateHeader();
	void performUpdateTitle();
	void performGetWorkArea();
	void performResizeDimensions(int& width, int& height);
	void performUpdateHeaderRecursively(bool force = false);
	void performConfigRecursively();
	void performCreateRecursively();
	void performBuildRecursively();
	void performFinalizeCreateRecursively();
	void performPackRecursively();
	void performFlattenRecursively();
	void performRestructureRecursively();
	void performPackChildsRecursively();
	void performUnpackChildsRecursively();
	void performAllActiveNodes(Flag flag);
	void performDeleteInactiveNodes();
	void performDeiconifyFloats();
	void performDeiconify(bool force = false);
	void performUpdateDimensions();
	void performRaiseRecursively(bool needed = false);
	int performQuerySashSize() const;
	int performQueryFrameHeaderSize() const;
	int performQueryNotebookHeaderSize() const;

	unsigned collectFlags() const;
	void clearAllFlags();

	template <Orient D> int computeDimen() const;

	void dump(unsigned level, bool parentIsWithdrawn) const;

	static void initialize();

	Type			m_type;
	State			m_state;
	Tcl_Obj*		m_path;
	Tcl_Obj*		m_uid;
	int			m_priority;
	Childs		m_childs;
	Node*			m_root;
	Node*			m_parent;
	Node*			m_savedParent;
	Node*			m_selected;
	Dimension	m_dimen;
	Dimension	m_actual;
	Coord			m_coord;
	Size			m_workArea;
	int			m_orientation;
	int			m_expand;
	int			m_sticky;
	int			m_shrink;
	int			m_grow;
	Tcl_Obj*		m_headerObj;
	Tcl_Obj*		m_oldHeaderObj;
	Tcl_Obj*		m_titleObj;
	Tcl_Obj*		m_oldTitleObj;
	Childs		m_active;
	Childs		m_toplevel;
	Childs		m_deleted;
	AttrMap		m_attrMap;
	Node*			m_current;
	unsigned		m_flags;
	SnapshotMap	m_snapshotMap;
	Structures	m_structures;
	bool			m_initialStructure;
	bool			m_isClone;
	bool			m_isDeleted;
	bool			m_isDestroyed;
	bool			m_isLocked;
	bool			m_temporary;

	mutable bool m_dumpFlag;

	typedef mstl::map<mstl::string,Base> Lookup;
	static Lookup m_lookup;
};

Node::Lookup Node::m_lookup;

} // namespace


static void
WindowEventProc(ClientData clientData, XEvent* event)
{
	switch (event->type)
	{
		case ConfigureNotify:
			static_cast<Node*>(clientData)->updateDimen(
				event->xconfigure.x, event->xconfigure.y,
				event->xconfigure.width, event->xconfigure.height);
			break;

		case DestroyNotify:	static_cast<Node*>(clientData)->destroyed(false); break;
		case UnmapNotify:		static_cast<Node*>(clientData)->destroyed(true); break;
		case MapNotify:		static_cast<Node*>(clientData)->isSelected(); break;
	}
}


namespace {

Node* Node::root() const						{ return m_root; }
Node const* Node::child(unsigned i) const { return m_childs[i]; }
Node* Node::child(unsigned i)					{ return m_childs[i]; }
Node const* Node::child() const				{ return const_cast<Node*>(this)->child(); }

Node const* Node::findUid(char const* uid) const { return const_cast<Node*>(this)->findUid(uid); }

unsigned Node::numChilds() const	{ return m_childs.size(); }
Tk_Window Node::tkwin() const		{ return tk::window(m_path); }
bool Node::exists() const			{ return m_path && tk::exists(m_path); }
bool Node::isAlreadyDead() const	{ return m_path && tk::isAlreadyDead(m_path); }

bool Node::isContainer(Type type)
{ return type == MultiWindow || type == Notebook || type == PanedWindow; }

bool Node::isRoot(Type type)						{ return type == Root; }
bool Node::isMetaFrame(Type type)				{ return type == MetaFrame; }
bool Node::isLeaf(Type type)						{ return type == Frame || type == Pane; }
bool Node::isRoot() const							{ return isRoot(m_type); }
bool Node::isPanedWindow() const					{ return m_type == PanedWindow; }
bool Node::isMultiWindow() const					{ return m_type == MultiWindow; }
bool Node::isNotebook() const						{ return m_type == Notebook; }
bool Node::isFrame() const							{ return m_type == Frame; }
bool Node::isMetaFrame() const					{ return isMetaFrame(m_type); }
bool Node::isLeaf() const							{ return isLeaf(m_type); }
bool Node::isPane() const							{ return m_type == Pane; }
bool Node::isFrameOrMetaFrame() const			{ return isFrame() || isMetaFrame(); }
bool Node::isNotebookOrMultiWindow() const	{ return isNotebook() || isMultiWindow(); }
bool Node::isContainer() const					{ return isContainer(m_type); }
bool Node::isEmpty() const							{ return m_childs.empty(); }
bool Node::isPacked() const						{ return m_state == Packed; }
bool Node::isWithdrawn() const					{ return m_state == Withdrawn; }
bool Node::isDeleted() const						{ return m_isDeleted; }
bool Node::isDestroyed() const					{ return m_isDestroyed; }
bool Node::isFloating() const						{ return m_state == Floating; }
bool Node::isToplevel() const						{ return m_parent == nullptr; }
bool Node::isLocked() const						{ return m_root->m_isLocked; }
bool Node::isHorz() const							{ return m_orientation == Horz; }
bool Node::isVert() const							{ return m_orientation == Vert; }
bool Node::hasChilds() const						{ return !m_childs.empty(); }

int Node::sticky() const { return m_sticky; }

Node* Node::parent() const { return isRoot() ? nullptr : (m_parent ? m_parent : m_root); }

Childs::const_iterator Node::begin() const	{ return m_childs.begin(); }
Childs::const_iterator Node::end() const		{ return m_childs.end(); }

bool Node::contains(Node const* node) const	{ return find(node) != end(); }

template <Orient D> bool Node::isExpandable() const { return bool(expand() & D); }

template <Orient D> bool Node::grow() const			{ return m_grow & D; }
template <Orient D> bool Node::shrink() const		{ return m_shrink & D; }
template <Orient D> bool Node::orientation() const	{ return m_orientation & D; }

char const* Node::uid() const				{ return tcl::asString(m_uid); }
char const* Node::path() const			{ return tcl::asString(m_path); }
char const* Node::id() const				{ return m_uid ? uid() : (m_path ? path() : "null"); }

Tcl_Obj* Node::uidObj() const				{ return m_uid; }
Tcl_Obj* Node::pathObj() const			{ return m_path ? m_path : nullptr; }

int Node::sashSize() const					{ return performQuerySashSize(); }
int Node::frameHeaderSize() const		{ return m_headerObj ? performQueryFrameHeaderSize() : 0; }
int Node::notebookHeaderSize() const	{ return performQueryNotebookHeaderSize(); }

void Node::remove(Node* node)				{ remove(find(node)); }
void Node::setState(State state)			{ m_state = state; }
void Node::load(Tcl_Obj* list)			{ load(list, nullptr, nullptr); }

void Node::ready()							{ performReady(); }

void Node::addFlag(unsigned flag)		{ m_flags |= flag; }
void Node::delFlag(unsigned flag)		{ m_flags &= ~flag; }

bool Node::testFlags(unsigned flag) const { return m_flags & flag; }

unsigned Node::descendantOf(Node const* child) const { return descendantOf(child, 1); }

void Node::makeSnapshotKey(mstl::string& key) const { makeSnapshot(key, nullptr); }


Node*
Node::selected() const
{
	M_ASSERT(isNotebookOrMultiWindow());
	M_ASSERT(m_selected);

	return m_selected;
}


Node*
Node::child()
{
	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isPacked())
			return child(i);
	}
	return nullptr;
}


unsigned
Node::depth() const
{
	Node const* node = this;
	unsigned depth = 0;

	while (node->m_parent)
	{
		depth += 1;
		node = node->m_parent;
	}

	return depth;
}


bool
Node::hasAncestor(Node const* node) const
{
	for (Node const* parent = m_parent; parent; parent = parent->m_parent)
	{
		if (parent == node)
			return true;
	}

	return false;
}


int
Node::x() const
{
	Tk_Window window = tkwin();
	return tk::isToplevel(window) ? tk::x(window) : tk::rootx(window);
}


int
Node::y() const
{
	Tk_Window window = tkwin();
	return tk::isToplevel(window) ? tk::y(window) : tk::rooty(window);
}


int
Node::multiwindowHeaderSize() const
{
	unsigned i = 0;
	Node const* node = child(i);

	if (node->isPacked())
		return frameHeaderSize();

	return 0;
}


template <Orient D>
int
Node::contentSize(int size) const
{
	if (D == Vert && size > 0)
	{
		if (isNotebook())
			size = mstl::max(0, size - notebookHeaderSize());
		else if (m_headerObj && !isMultiWindow())
			size = mstl::max(0, size - frameHeaderSize());
	}

	return size;
}


template <Orient D,Enclosure Enc>
int
Node::frameSize(int size) const
{
	if (Enc == Outer && D == Vert && size > 0)
	{
		if (isNotebook())
			size += notebookHeaderSize();
		else if (m_headerObj && !isMultiWindow())
			size += frameHeaderSize();
	}

	return size;
}


template <Enclosure Enc>
int Node::width() const { return frameSize<Horz,Enc>(m_dimen.dimen<Horz>()); }

template <Enclosure Enc>
int Node::height() const { return frameSize<Vert,Enc>(m_dimen.dimen<Vert>()); }

template <Enclosure Enc>
int Node::minWidth() const { return frameSize<Horz,Enc>(m_dimen.dimen<Horz,Min>()); }

template <Enclosure Enc>
int Node::minHeight() const { return frameSize<Vert,Enc>(m_dimen.dimen<Vert,Min>()); }

template <Enclosure Enc>
int Node::maxWidth() const { return frameSize<Horz,Enc>(m_dimen.dimen<Horz,Max>()); }

template <Enclosure Enc>
int Node::maxHeight() const { return frameSize<Vert,Enc>(m_dimen.dimen<Vert,Max>()); }

template <> int Node::maxSize<Inner,Horz>() const { return maxWidth <Inner>(); }
template <> int Node::maxSize<Inner,Vert>() const { return maxHeight<Inner>(); }
template <> int Node::minSize<Inner,Horz>() const { return minWidth <Inner>(); }
template <> int Node::minSize<Inner,Vert>() const { return minHeight<Inner>(); }
template <> int Node::maxSize<Outer,Horz>() const { return maxWidth <Outer>(); }
template <> int Node::maxSize<Outer,Vert>() const { return maxHeight<Outer>(); }
template <> int Node::minSize<Outer,Horz>() const { return minWidth <Outer>(); }
template <> int Node::minSize<Outer,Vert>() const { return minHeight<Outer>(); }

template <Enclosure Enc,Orient D,Quantity Q>
int Node::dimen() const { return frameSize<D,Enc>(m_dimen.dimen<D,Q>()); }

template <Enclosure Enc,Orient D> int Node::actualSize() const { return dimen<Enc,D>(); }


Node const*
Node::leftNeighbor(Node const* neighbor) const
{
	M_ASSERT(neighbor);
	M_ASSERT(isPanedWindow());
	M_ASSERT(contains(neighbor));

	Childs::const_iterator i = find(neighbor);

	if (i == begin())
		return nullptr;

	return *(i - 1);
}


Node const*
Node::rightNeighbor(Node const* neighbor) const
{
	M_ASSERT(neighbor);
	M_ASSERT(isPanedWindow());
	M_ASSERT(contains(neighbor));

	Childs::const_iterator i = find(neighbor);

	if (++i == end())
		return nullptr;

	return *i;
}


Node const*
Node::findLeader() const
{
	if (isLeaf())
		return this;
	
	int priority = mstl::numeric_limits<int>::min();
	Node const *node = nullptr;

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		Node const* leader = child(i)->findLeader();

		if (!node || leader->m_priority > priority)
		{
			node = leader;
			priority = leader->m_priority;
		}
	}

	return node;
}


void
Node::create()
{
	//M_ASSERT(isWithdrawn());
	M_ASSERT(!testFlags(F_Create));

	if (isRoot())
	{
		tk::createEventHandler(tkwin(), StructureNotifyMask, ::WindowEventProc, this);
	}
	else
	{
		M_ASSERT(!exists());

		addFlag(F_Create);
		addFlag(F_Raise);

		if (isLeaf())
			addFlag(F_Build);
	}
}


void
Node::pack()
{
	//M_ASSERT(m_parent);
	//M_ASSERT(m_parent->contains(this));
	//M_ASSERT(!m_parent->isPane() && !m_parent->isFrameOrMetaFrame());
	M_ASSERT(!testFlags(F_Destroy));

	m_state = Packed;

	addFlag(F_Pack);
	addFlag(F_Raise);

	if (m_savedParent == this)
	{
		delFlag(F_Unpack);
		m_savedParent = nullptr;
	}
}


void
Node::unpack()
{
	M_ASSERT(isPacked());
	M_ASSERT(m_parent);
	M_ASSERT(m_parent->contains(this));
	M_ASSERT(!testFlags(F_Destroy));

	m_state = Withdrawn;
	m_savedParent = m_parent;

	addFlag(F_Unpack);
	delFlag(F_Pack);
	delFlag(F_Select);
}


void
Node::isSelected()
{
	if (!m_parent || !m_parent->isNotebookOrMultiWindow())
		return;

	if (!isLocked() || !m_parent->m_selected)
		m_parent->m_selected = this;
}


void
Node::select()
{
	M_ASSERT(m_parent);

	if (testFlags(F_Unpack|F_Destroy))
		return;

	if (m_parent->isNotebookOrMultiWindow())
	{
		addFlag(F_Select);
		isSelected();
	}

	if (m_parent->m_parent)
		m_parent->select();
}


void
Node::destroy()
{
	M_ASSERT(isToplevel() || isWithdrawn());
	M_ASSERT(!testFlags(F_Pack) || isMetaFrame());

	addFlag(F_Destroy);
	delFlag(F_Select);
	delFlag(F_Pack);
	delFlag(F_Unpack);
}


Node::Node(Node& parent, Type type, Tcl_Obj* uid)
	:m_type(type)
	,m_state(Withdrawn)
	,m_path(nullptr)
	,m_uid(uid)
	,m_priority(0)
	,m_root(parent.m_root)
	,m_parent(&parent)
	,m_savedParent(nullptr)
	,m_selected(nullptr)
	,m_orientation(0)
	,m_expand(None)
	,m_sticky(0)
	,m_shrink(0)
	,m_grow(0)
	,m_headerObj(nullptr)
	,m_oldHeaderObj(nullptr)
	,m_titleObj(nullptr)
	,m_oldTitleObj(nullptr)
	,m_current(nullptr)
	,m_flags(0)
	,m_initialStructure(false)
	,m_isClone(false)
	,m_isDeleted(false)
	,m_isDestroyed(false)
	,m_isLocked(false)
	,m_temporary(false)
	,m_dumpFlag(false)
{
	M_ASSERT(type != Root);
	tcl::incrRef(m_uid);
}


Node::Node(Tcl_Obj* path, Node const* setup)
	:m_type(Root)
	,m_state(Packed)
	,m_path(path)
	,m_uid(nullptr)
	,m_priority(0)
	,m_root(setup ? setup->m_root : this)
	,m_parent(nullptr)
	,m_savedParent(nullptr)
	,m_selected(nullptr)
	,m_orientation(0)
	,m_expand(None)
	,m_sticky(0)
	,m_shrink(0)
	,m_grow(0)
	,m_headerObj(nullptr)
	,m_oldHeaderObj(nullptr)
	,m_titleObj(nullptr)
	,m_oldTitleObj(nullptr)
	,m_current(nullptr)
	,m_flags(0)
	,m_initialStructure(false)
	,m_isClone(false)
	,m_isDeleted(false)
	,m_isDestroyed(false)
	,m_isLocked(false)
	,m_temporary(false)
	,m_dumpFlag(false)
{
	M_ASSERT(path);

	tcl::incrRef(path);

	if (setup)
	{
		m_type = setup->m_type;
		m_orientation = setup->m_orientation;
		m_expand = setup->m_expand;
		m_sticky = setup->m_sticky;
		m_shrink = setup->m_shrink;
		m_grow = setup->m_grow;
		tcl::incrRef(m_uid = setup->m_uid);
	}
}


Node::Node(Node const& node)
	:m_type(node.m_type)
	,m_state(Withdrawn)
	,m_path(node.m_path)
	,m_uid(node.m_uid)
	,m_priority(node.m_priority)
	,m_root(this)
	,m_parent(nullptr)
	,m_savedParent(nullptr)
	,m_selected(nullptr)
	,m_dimen(node.m_dimen)
	,m_actual(node.m_actual)
	,m_orientation(node.m_orientation)
	,m_expand(node.m_expand)
	,m_sticky(node.m_sticky)
	,m_shrink(node.m_shrink)
	,m_grow(node.m_grow)
	,m_headerObj(nullptr)
	,m_oldHeaderObj(nullptr)
	,m_titleObj(nullptr)
	,m_oldTitleObj(nullptr)
	,m_current(nullptr)
	,m_flags(0)
	,m_initialStructure(false)
	,m_isClone(false)
	,m_isDeleted(false)
	,m_isDestroyed(false)
	,m_isLocked(false)
	,m_temporary(false)
	,m_dumpFlag(false)
{
	tcl::incrRef(m_path);
	tcl::incrRef(m_uid);
}


Node::~Node()
{
	if (!isRoot() && exists())
		::fprintf(stderr, "window '%s' is not withdrawn\n", id());

	if (m_path && tk::exists(path()))
		tk::deleteEventHandler(tkwin(), StructureNotifyMask, ::WindowEventProc, this);

	for (Childs::iterator i = m_deleted.begin(); i != m_deleted.end(); ++i)
		delete *i;

	for (Childs::iterator i = m_active.begin(); i != m_active.end(); ++i)
		delete *i;

	tcl::decrRef(m_path);
	tcl::decrRef(m_uid);
	tcl::decrRef(m_headerObj);
	tcl::decrRef(m_oldHeaderObj);
	tcl::decrRef(m_titleObj);
	tcl::decrRef(m_oldTitleObj);

	for (AttrMap::iterator i = m_attrMap.begin(); i != m_attrMap.end(); ++i)
		tcl::decrRef(i->second);
	
	for (Structures::iterator i = m_structures.begin(); i != m_structures.end(); ++i)
		delete *i;
}


Node*
Node::makeRoot(Tcl_Obj* path)
{
	M_ASSERT(path);
	return new Node(path);
}


Node*
Node::getCurrent() const
{
	M_ASSERT(isRoot());
	return m_current;
}


void
Node::set(char const* attribute, Tcl_Obj* value, bool ignoreMeta)
{
	M_ASSERT(attribute);
	M_ASSERT(value);

	AttrMap& attrs = isMetaFrame() && ignoreMeta ? child()->m_attrMap : m_attrMap;
	Tcl_Obj*& obj = attrs[attribute];

	if (tcl::equal(attribute, "priority") && tcl::isInt(value))
		m_priority = tcl::asInt(value);

	tcl::decrRef(obj);
	obj = tcl::incrRef(value);
}


Tcl_Obj*
Node::get(char const* attribute, bool ignoreMeta) const
{
	M_ASSERT(attribute);

	if (isMetaFrame() && ignoreMeta && !child())
		ignoreMeta = false; // this may happen when destroying a metaframe

	AttrMap const& attrs = isMetaFrame() && ignoreMeta ? child()->m_attrMap : m_attrMap;
	AttrMap::const_iterator i = attrs.find(attribute);
	return i == attrs.end() ? nullptr : i->second;
}


void
Node::resize(int width, int height, int minWidth, int minHeight, int maxWidth, int maxHeight)
{
	if (width > 0)
	{
		if (m_dimen.actual.width != width)
		{
			m_dimen.actual.width = width;
			addFlag(F_Config);
		}
	}
	if (height > 0)
	{
		if (m_dimen.actual.height != height)
		{
			m_dimen.actual.height = height;
			addFlag(F_Config);
		}
	}
	if (minWidth > 0)
	{
		if (m_dimen.min.width != minWidth)
		{
			m_dimen.min.width = minWidth;
			addFlag(F_Config);
		}
	}
	if (minHeight > 0)
	{
		if (m_dimen.min.height != minHeight)
		{
			m_dimen.min.height = minHeight;
			addFlag(F_Config);
		}
	}
	if (maxWidth > 0)
	{
		if (m_dimen.max.width != maxWidth)
		{
			m_dimen.max.width = maxWidth;
			addFlag(F_Config);
		}
	}
	if (maxHeight > 0)
	{
		if (m_dimen.max.height != maxHeight)
		{
			m_dimen.max.height = maxHeight;
			addFlag(F_Config);
		}
	}

	if (testFlags(F_Config))
		m_root->perform();
}


void
Node::show()
{
	M_ASSERT(isToplevel());
	M_ASSERT(exists());
	M_ASSERT(tk::isToplevel(tkwin()));

	performDeiconify(true);
}


void
Node::refresh()
{
	for (unsigned i = 0; i < m_toplevel.size(); ++i)
	{
		m_toplevel[i]->addFlag(F_Config|F_Header);
		m_toplevel[i]->perform();
	}
}


Childs::iterator
Node::find(Node const* node)
{
	M_ASSERT(node);
	return m_childs.find(node);
}


Childs::const_iterator
Node::find(Node const* node) const
{
	M_ASSERT(node);
	return m_childs.find(node);
}


void
Node::collectFramesRecursively(tcl::List& result) const
{
	if (isFrame())
	{
		result.push_back(m_path);
	}
	else
	{
		for (unsigned i = 0; i < numChilds(); ++i)
			child(i)->collectFramesRecursively(result);
	}
}


void
Node::collectPanesRecursively(tcl::List& result) const
{
	if (isLeaf())
	{
		result.push_back(pathObj());
	}
	else
	{
		for (unsigned i = 0; i < numChilds(); ++i)
			child(i)->collectPanesRecursively(result);
	}
}


void
Node::collectLeavesRecursively(tcl::List& result) const
{
	if (isLeaf())
	{
		result.push_back(m_uid);
	}
	else
	{
		for (unsigned i = 0; i < numChilds(); ++i)
			child(i)->collectLeavesRecursively(result);
	}
}


void
Node::collectVisibleRecursively(tcl::List& result) const
{
	if (m_temporary)
		return;
	
	M_ASSERT(!isWithdrawn());
	
	if (!(isRoot() || isMetaFrame() || (m_parent->isMetaFrame() && !m_parent->isToplevel())))
	{
		Tcl_Obj* dirs;

		if (isPanedWindow())
		{
			dirs = (m_orientation == Horz ? m_objDirsTB : m_objDirsLR);
		}
		else if (isNotebookOrMultiWindow())
		{
			if (m_selected->isMetaFrame() && m_selected->child()->isPanedWindow())
				dirs = (m_selected->child()->m_orientation == Horz ? m_objDirsTBLRNS : m_objDirsTBLREW);
			else
				dirs = m_objDirsTBLRNSEW;
		}
		else
		{
			dirs = m_objDirsTBLR;
		}

		result.push_back(tcl::newObj(m_path, dirs));
	}

	if (isToplevel() || isMetaFrame() || isPanedWindow())
	{
		for (unsigned i = 0; i < numChilds(); ++i)
			child(i)->collectVisibleRecursively(result);
	}
	else if (m_selected && m_selected->isMetaFrame())
	{
		M_ASSERT(isNotebookOrMultiWindow());
		m_selected->collectVisibleRecursively(result);
	}
}


tcl::List
Node::collectPanesRecursively() const
{
	tcl::List result;
	collectPanesRecursively(result);
	return result;
}


tcl::List
Node::collectFrames() const
{
	tcl::List result;
	collectFramesRecursively(result);
	return result;
}


tcl::List
Node::findWindows(char const* attr, Tcl_Obj* value) const
{
	M_ASSERT(attr);
	M_ASSERT(value);
	M_ASSERT(isRoot());

	tcl::List result;

	for (unsigned i = 0; i < m_active.size(); ++i)
	{
		Node const* node = m_active[i];

		M_ASSERT(!node->isWithdrawn());

		Tcl_Obj* obj = node->get(attr, false);

		if (obj && tcl::equal(obj, value))
			result.push_back(node->m_path);
	}

	return result;
}


tcl::List
Node::collectPanes() const
{
	M_ASSERT(isRoot());

	tcl::List result;

	for (unsigned i = 0; i < m_active.size(); ++i)
	{
		if (m_active[i]->isLeaf())
			result.push_back(m_active[i]->pathObj());
	}

	return result;
}


void
Node::collectLeaves(mstl::vector<mstl::string>& result) const
{
	M_ASSERT(isRoot());

	for (unsigned i = 0; i < m_active.size(); ++i)
	{
		Node const* node = m_active[i];

		if (node->toplevel() == this && node->isLeaf())
			result.push_back(m_active[i]->uid());
	}
}


tcl::List
Node::collectLeaves() const
{
	M_ASSERT(isRoot());

	tcl::List result;

	for (unsigned i = 0; i < m_active.size(); ++i)
	{
		if (m_active[i]->isLeaf())
			result.push_back(m_active[i]->uidObj());
	}

	return result;
}


tcl::List
Node::collectContainer() const
{
	M_ASSERT(isRoot());

	tcl::List result;

	for (unsigned i = 0; i < m_active.size(); ++i)
	{
		if (m_active[i]->isContainer())
			result.push_back(m_active[i]->uidObj());
	}

	return result;
}


tcl::List
Node::collectFloats() const
{
	M_ASSERT(isRoot());

	tcl::List result;

	for (unsigned i = 1; i < m_toplevel.size(); ++i)
		result.push_back(m_toplevel[i]->pathObj());

	return result;
}


tcl::List
Node::collectVisible() const
{
	tcl::List result;

	if (isRoot())
	{
		for (unsigned i = 0; i < m_toplevel.size(); ++i)
			m_toplevel[i]->collectVisibleRecursively(result);
	}
	else
	{
		collectVisibleRecursively(result);
	}

	return result;
}


tcl::List
Node::collectHidden() const
{
	tcl::List result;
	Node const* node = this;
	Node const* parent = m_parent;

	for ( ; parent; node = parent, parent = parent->m_parent)
	{
		if (parent->isNotebookOrMultiWindow())
		{
			for (unsigned i = 0; i < parent->numChilds(); ++i)
			{
				if (parent->child(i) != node)
					parent->child(i)->collectPanesRecursively(result);
			}
		}
	}

	return result;
}


Base*
Node::createBase(Tcl_Obj* path)
{
	M_ASSERT(path);

	initialize();
	return &m_lookup[tcl::asString(path)];
}


Base*
Node::lookupBase(char const* path)
{
	M_ASSERT(path);

	Lookup::iterator i = m_lookup.find(path);
	return i == m_lookup.end() ? nullptr : &i->second;
}


void
Node::removeBase(char const* path)
{
	Lookup::iterator i = m_lookup.find(path);

	if (i != m_lookup.end())
	{
		delete i->second.root;
		delete i->second.setup;
		m_lookup.erase(i);
	}
}


void
Node::makeStructure()
{
	M_ASSERT(isRoot());

	if (child() && child()->isContainer())
		m_structures.push_back(child()->makeStructure(nullptr));
}


structure::Node*
Node::makeStructure(structure::Node* parent) const
{
	M_ASSERT(isPacked());
	M_ASSERT(!isRoot());

	if (isLeaf())
		return new structure::Node(parent, m_uid);

	if (isMetaFrame())
		return child()->makeStructure(parent);

	M_ASSERT(isNotebookOrMultiWindow() || isPanedWindow());

	structure::Type type;
	
	if (isNotebookOrMultiWindow())
		type = structure::Multi;
	else if (isHorz())
		type = structure::Horz;
	else
		type = structure::Vert;

	structure::Node* node = new structure::Node(parent, type);

	for (unsigned i = 0; i < numChilds(); ++i)
		node->add(child(i)->makeStructure(node));

	return node;
}


void
Node::releaseStructures()
{
	M_ASSERT(isRoot());

	unsigned offs = m_initialStructure ? 1 : 0;

	if (m_structures.size() <= offs)
		return;

	mstl::vector<mstl::string> leaves1;
	mstl::vector<mstl::string> leaves2;

	collectLeaves(leaves1);
	leaves1.bubblesort();

	for (Structures::iterator i = m_structures.begin() + offs; i != m_structures.end(); )
	{
		leaves2.clear();
		(*i)->collectLeaves(leaves2);
		leaves2.bubblesort();

		if (::isSubset(leaves2, leaves1))
			i = m_structures.erase(i);
		else
			i += 1;
	}
}


int
Node::expand() const
{
	if (isRoot())
		return m_grow | m_shrink;
	
	if (isLeaf())
		return m_expand;
	
	int result = None;

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isPacked())
			result |= child(i)->expand();
	}

	return result;
}


void
Node::updateDimen(int x, int y, int width, int height)
{
	// NOTE: Don't use tk::isMapped(), this function seems to return false
	// if a window is hidden.

	if (width > 1 && height > 1 && exists())
	{
		m_coord.x = x;
		m_coord.y = y;
		if (!isRoot())
		{
			m_coord.x -= m_root->x();
			m_coord.y -= m_root->y();
		}
		width = contentSize<Horz>(width);
		height = contentSize<Vert>(height);

		if (isLocked())
		{
			m_actual.actual.width = width;
			m_actual.actual.height = height;
		}
		else
		{
			m_dimen.set<Horz>(width);
			m_dimen.set<Vert>(height);

			if (m_parent && m_parent->isNotebookOrMultiWindow())
			{
				for (unsigned i = 0; i < m_parent->numChilds(); ++i)
				{
					Node* node = m_parent->child(i);

					if (node != this)
					{
						node->resizeFrame<Horz>(width);
						node->resizeFrame<Vert>(height);
					}
				}
			}
		}
	}
}


template <Orient D>
int
Node::computeExpand(int stage) const
{
	M_ASSERT(stage == 1 || stage == 2);
	M_ASSERT(!isWithdrawn());

	int size		= dimen<Inner,D>();
	int minSize	= dimen<Inner,D,Min>();
	int maxSize	= dimen<Inner,D,Max>();
	int spread;

	if (minSize && maxSize)
		spread = maxSize - minSize;
	else if (minSize && stage == 2)
		spread = mstl::max(0, size - minSize);
	else if (maxSize && stage == 2)
		spread = mstl::max(0, maxSize - size);
	else if (minSize)
		spread = mstl::max(size, minSize);
	else
		spread = size;
	
	return spread;
}


template <Orient D>
int
Node::computeShrink(int stage) const
{
	M_ASSERT(stage == 1 || stage == 2);
	M_ASSERT(!isWithdrawn());

	int size		= dimen<Inner,D>();
	int minSize	= dimen<Inner,D,Min>();
	int maxSize	= dimen<Inner,D,Max>();
	int spread;

	if (minSize && maxSize)
		spread = maxSize - minSize;
	else if (minSize && stage == 2)
		spread = mstl::max(0, size - minSize);
	else if (maxSize && stage == 2)
		spread = mstl::max(0, maxSize - size);
	else if (maxSize)
		spread = mstl::min(size, maxSize);
	else
		spread = size;
	
	return spread;
}


template <Orient D>
int
Node::computeUnderflow() const
{
	return mstl::max(0, dimen<Inner,D,Min>() - dimen<Inner,D>());
}


template <Orient D>
int
Node::computeDimen() const
{
	M_ASSERT(!isWithdrawn());

	if (!hasChilds())
		return actualSize<Inner,D>();
	
	int totalSize = 0;

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		int size = child(i)->frameSize<D>(child(i)->computeDimen<D>());

		if (orientation<D>())
			totalSize += size + (totalSize ? sashSize() : 0);
		else
			totalSize = mstl::max(totalSize, size);
	}

	return totalSize;
}


template <Orient D,Quantity Q>
void
Node::addDimen(Node const* node)
{
	M_ASSERT(!isWithdrawn());

	static_assert(Q != Max, "not working for Maxima");

	if (Q == Actual || node->dimen<Inner,D,Q>())
	{
		int nodeSize = node->dimen<Outer,D,Q>();

		m_dimen.set<D,Q>(orientation<D>()
			? dimen<Inner,D,Q>() + nodeSize + (dimen<Inner,D,Q>() ? sashSize() : 0)
			: mstl::max(dimen<Inner,D,Q>(), nodeSize));
	}
}


void
Node::computeDimensionsRecursively()
{
	M_ASSERT(!isWithdrawn());

	if (!hasChilds())
		return;
	
	bool needComputedWidth  = (!isToplevel() || width<Inner>() == 0);
	bool needComputedHeight = (!isToplevel() || height<Inner>() == 0);

	if (needComputedWidth)
		m_dimen.actual.width = 0;
	if (needComputedHeight)
		m_dimen.actual.height = 0;
	m_dimen.min.zero();
	m_dimen.max.zero();

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		Node* node = child(i);

		if (node->isPacked())
		{
			node->computeDimensionsRecursively();

			if (needComputedWidth)
				addDimen<Horz>(node);
			if (needComputedHeight)
				addDimen<Vert>(node);

			addDimen<Horz,Min>(node);
			addDimen<Vert,Min>(node);

			if (m_dimen.max.width >= 0)
			{
				if (isHorz() && node->dimen<Inner,Horz,Max>() == 0)
					m_dimen.max.width = -1;
				else
					m_dimen.max.width = mstl::max(m_dimen.max.width, node->dimen<Outer,Horz,Max>());
			}

			if (m_dimen.max.height >= 0)
			{
				if (isVert() && node->dimen<Inner,Vert,Max>() == 0)
					m_dimen.max.height = -1;
				else
					m_dimen.max.height = mstl::max(m_dimen.max.height, node->dimen<Outer,Vert,Max>());
			}
		}
	}

	m_dimen.max.width = mstl::max(0, m_dimen.max.width);
	m_dimen.max.height = mstl::max(0, m_dimen.max.height);
}


void
Node::insertNode(Node* node, Node const* before)
{
	M_ASSERT(node);
	M_ASSERT(!contains(node));
	M_ASSERT(!before || contains(before));
	//M_ASSERT(!isMetaFrame() || numChilds() == 0); we allow it temporarily

	if (before)
		m_childs.insert(find(before), node);
	else
		m_childs.push_back(node);
}


void
Node::destroyed(bool finalize)
{
	if (finalize)
	{
		if (!m_isDestroyed)
			return;

		if (isRoot())
		{
			bool isLocked = m_isLocked;

			removeBase(m_root->path());

			if (isLocked)
				throw Terminated();
		}
		else if (m_isDeleted)
		{
			Childs::iterator i = m_deleted.find(this);
			if (i != m_deleted.end())
			{
				delete *i;
				m_deleted.erase(i);
			}
		}
	}
	else if (isAlreadyDead())
	{
		m_isDestroyed = true;
		m_isDeleted = true;

		if (toplevel() == m_root)
		{
			if (m_parent)
				m_parent->makeSnapshot();
			m_root->makeStructure();
		}

		deleteChilds();

		if (m_parent)
			m_parent->addFlag(F_Header);

		if (m_parent && m_parent->isToplevel() && !m_parent->isRoot())
		{
			m_parent->performDestroy();
			m_parent->m_isDestroyed = true;
			m_parent->m_isDeleted = true;
			m_parent->m_state = Withdrawn;
		}
		
		if (m_parent && !m_parent->isToplevel())
		{
			Node* toplevel = this->toplevel();

			remove();
			setState(Withdrawn);

			if (toplevel->exists() && !toplevel->isAlreadyDead())
			{
				toplevel->adjustDimensions();
				toplevel->perform();
			}
		}
		else
		{
			toplevel()->perform();
		}
	}
}


void
Node::deleteChilds()
{
	for (unsigned i = 0; i < numChilds(); ++i)
	{
		Node* node = child(i);

		if (!node->m_isDestroyed)
		{
			node->m_state = Withdrawn;
			node->deleteChilds();
			node->destroy();
			node->m_isDeleted = true;
			node->m_isDestroyed = true;
		}
	}
}


Tcl_Obj*
Node::typeObj() const
{
	switch (m_type)
	{
		case PanedWindow:	return m_objPanedWindow; break;
		case MultiWindow:	return m_objMultiWindow; break;
		case Notebook:		return m_objNotebook; break;
		case Pane:			return m_objPane; break;
		case Frame:			return m_objFrame; break;
		case MetaFrame:	return m_objMetaFrame; break;
		case Root:			break; // should not happen
	}

	M_ASSERT(!"should not happen");
	return nullptr;
}


Node*
Node::toplevel() const
{
	Node* parent = const_cast<Node*>(this);

	while (parent->m_parent)
		parent = parent->m_parent;

	return parent;
}


Node*
Node::findPath(char const* path)
{
	M_ASSERT(path);
	M_ASSERT(isRoot());

	if (tcl::equal(m_path, path))
		return this;

	for (unsigned i = 0; i < m_active.size(); ++i)
	{
		Node* node = m_active[i];

		if (node->m_path && tcl::equal(node->m_path, path))
			return node;
	}

	return nullptr;
}


Node*
Node::findUid(char const* uid)
{
	M_ASSERT(uid);
	M_ASSERT(isRoot());

	for (unsigned i = 0; i < m_active.size(); ++i)
	{
		Node* node = m_active[i];

		if (node->m_uid && tcl::equal(node->m_uid, uid))
			return node;
	}

	return nullptr;
}


Node*
Node::clone(Node* parent, Tcl_Obj* uid) const
{
	M_ASSERT(parent);
	M_ASSERT(uid);

	Node* node = new Node(*this);

	node->m_isClone = true;
	node->m_parent = parent;
	node->m_orientation = m_orientation;
	node->m_priority = m_priority;
	node->m_expand = m_expand;
	node->m_sticky = m_sticky;
	node->m_root = parent->m_root;
	node->m_root->m_active.push_back(node);
	tcl::set(node->m_uid, uid);
	tcl::set(node->m_path, nullptr);

	return node;
}


Node*
Node::clone(LeafMap const& leaves) 
{
	M_ASSERT(isRoot());

	Node* root = clone(leaves, nullptr);
	root->create();
	root->setState(Packed);
	root->finishLoad(&leaves, this);
	return root;
}


Node*
Node::clone(LeafMap const& leaves, Node* parent) const
{
	LeafMap::const_iterator k;
	Node* node;

	if (isLeaf() && (k = leaves.find(uid())) != leaves.end())
		node = k->second;
	else
		node = new Node(*this);

	if ((node->m_parent = parent))
	{
		node->m_root = parent->m_root;
		node->m_root->m_active.push_back(node);
	}
	else
	{
		node->m_toplevel.push_back(node);
	}

	for (unsigned i = 0; i < numChilds(); ++i)
		node->insertNode(child(i)->clone(leaves, node));

	if (isPacked())
	{
		if (!node->m_path)
			node->create();
		node->pack();
	}

	return node;
}


void
Node::toggle()
{
	M_ASSERT(isNotebookOrMultiWindow());
	M_ASSERT(isPacked());
	M_ASSERT(m_parent);

	Node* selected = m_selected;

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		child(i)->unpack();
		child(i)->performUnpack(this);
	}

	unpack();
	performUnpack(m_parent);
	performDestroy();
	m_type = isNotebook() ? MultiWindow : Notebook;
	create();
	pack();
	delFlag(F_Unpack);

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		Node* node = child(i);

		if (node->testFlags(F_Unpack))
		{
			node->m_savedParent = nullptr;
			node->delFlag(F_Unpack);
			node->pack();
		}
	}

	selected->select();
	toplevel()->perform();
}


void
Node::unframe()
{
	M_ASSERT(m_path);

	if (!isMetaFrame())
		return;

	M_ASSERT(numChilds() >= 1);
	
	Node* child = this->child();
	State state = m_state;
	unsigned flags = m_flags;

	if (exists())
		tk::deleteEventHandler(tkwin(), StructureNotifyMask, ::WindowEventProc, this);
	if (child->exists())
		tk::deleteEventHandler(child->tkwin(), StructureNotifyMask, ::WindowEventProc, child);

	mstl::swap(m_type, child->m_type);
	mstl::swap(m_state, child->m_state);
	mstl::swap(m_path, child->m_path);
	mstl::swap(m_uid, child->m_uid);
	mstl::swap(m_priority, child->m_priority);
	mstl::swap(m_childs, child->m_childs);
	// child->m_root
	child->m_parent = this;
	mstl::swap(m_savedParent, child->m_savedParent);
	mstl::swap(m_selected, child->m_selected);
	mstl::swap(m_dimen, child->m_dimen);
	mstl::swap(m_actual, child->m_actual);
	// child->m_coord
	// child->m_workArea
	mstl::swap(m_orientation, child->m_orientation);
	mstl::swap(m_expand, child->m_expand);
	mstl::swap(m_sticky, child->m_sticky);
	mstl::swap(m_shrink, child->m_shrink);
	mstl::swap(m_grow, child->m_grow);
	mstl::swap(m_headerObj, child->m_headerObj);
	mstl::swap(m_oldHeaderObj, child->m_oldHeaderObj);
	mstl::swap(m_titleObj, child->m_titleObj);
	mstl::swap(m_oldTitleObj, child->m_oldTitleObj);
	mstl::swap(m_active, child->m_active);
	mstl::swap(m_deleted, child->m_deleted);
	mstl::swap(m_attrMap, child->m_attrMap);
	// child->m_current
	mstl::swap(m_flags, child->m_flags);
	// child->m_snapshotMap
	// child->m_initialStructure
	// child->m_isClone
	mstl::swap(m_isDeleted, child->m_isDeleted);
	// child->m_isDestroyed
	// child->m_isLocked
	// child->m_temporary
	// child->m_dumpFlag

	if (flags & F_Pack)
		addFlag(F_Pack);
	delFlag(F_Unpack);
	if (!m_savedParent)
		m_savedParent = child;
	m_state = state;

	//child->m_parent = this;
	child->m_state = Withdrawn;
	child->m_isDeleted = true;
	child->destroy();

	for (unsigned i = 0; i < numChilds(); ++i)
		this->child(i)->m_parent = this;

	if (m_parent && m_parent->m_selected == child)
		m_parent->m_selected = this;

	if (exists())
		tk::createEventHandler(tkwin(), StructureNotifyMask, ::WindowEventProc, this);
	if (child->exists())
		tk::createEventHandler(child->tkwin(), StructureNotifyMask, ::WindowEventProc, child);
}


void
Node::makeMetaFrame()
{
	M_ASSERT(!isRoot());
	M_ASSERT(!isMetaFrame());

	Node* child = new Node(*this);
	bool isPacked = this->isPacked();

	if (child->exists())
		tk::deleteEventHandler(child->tkwin(), StructureNotifyMask, ::WindowEventProc, this);

	if (isPacked)
		unpack();

	m_root->m_active.push_back(child);

	for (unsigned i = 0; i < numChilds(); ++i)
		this->child(i)->m_parent = child;

	// Reset the child

	// child->m_type
	child->m_state = Packed;
	// child->m_path
	// child->m_uid
	// child->m_priority
	child->m_childs.swap(m_childs);
	child->m_root = m_root;
	child->m_parent = this;
	// child->m_savedParent
	child->m_selected = nullptr;
	// child->m_dimen
	// child->m_actual
	// child->m_coord
	// child->m_workArea
	// child->m_orientation
	// child->m_expand
	// child->m_sticky
	// child->m_shrink
	// child->m_grow
	// child->m_headerObj
	// child->m_oldHeaderObj
	// child->m_titleObj
	// child->m_oldTitleObj
	// child->m_active
	// child->m_deleted
	mstl::swap(child->m_attrMap, m_attrMap);
	// child->m_current
	child->m_flags = (m_flags & (F_Create|F_Build|F_Header|F_Destroy|F_Docked|F_Raise));
	// child->m_snapshotMap
	// child->m_initialStructure
	child->m_isClone = m_isClone;
	// child->m_isDeleted
	// child->m_isDestroyed
	// child->m_isLocked
	// child->m_temporary
	// child->m_dumpFlag

	// Change this node to a MetaFrame

	m_type = MetaFrame;
	m_state = Withdrawn;
	tcl::zero(m_path);
	tcl::zero(m_uid);
	m_priority = 0;
	m_childs.push_back(child);
	// m_root
	// m_parent
	m_savedParent = nullptr;
	m_selected = nullptr;
	// m_dimen
	// m_actual
	// m_coord
	// m_workArea
	m_orientation = 0;
	// m_expand
	// m_sticky
	// m_shrink
	// m_grow
	tcl::zero(m_headerObj);
	tcl::zero(m_oldHeaderObj);
	tcl::zero(m_titleObj);
	tcl::zero(m_oldTitleObj);
	// m_active
	// m_deleted
	// m_attrMap
	// m_current
	m_flags = 0;
	// m_snapshotMap
	// m_initialStructure
	// m_isClone
	// m_isDeleted
	// m_isDestroyed
	// m_isLocked
	// m_temporary
	// m_dumpFlag

	if (child->exists())
	{
		create();
	}
	else
	{
		addFlag(F_Create);
		child->addFlag(F_Create);
	}
	addFlag(F_Raise);

	if (isPacked)
		pack();
	child->pack();

	if (child->exists())
		tk::createEventHandler(child->tkwin(), StructureNotifyMask, ::WindowEventProc, child);
}


Node*
Node::insertNotebook(Node* newChild, Type type, Node const* beforeChild)
{
	M_ASSERT(m_parent);
	M_ASSERT(newChild);
	M_ASSERT(type == Notebook || type == MultiWindow);

	Node* nb = new Node(*m_parent, type);
	Node const* before = findAfter();
	bool isPacked = this->isPacked();

	m_root->m_active.push_back(nb);
	nb->m_parent->add(nb, before);
	nb->m_dimen.actual = m_dimen.actual;
	nb->create();
	if (isPacked)
		unpack();
	nb->move(this);
	nb->move(newChild, beforeChild);
	nb->packChilds();
	if (isPacked)
		nb->pack();
	return nb;
}


Node*
Node::insertPanedWindow(Position position, Node* newChild, Node const* beforeChild)
{
	M_ASSERT(m_parent);
	M_ASSERT(newChild);

	Node* pw = new Node(*m_parent, PanedWindow);
	Node const* before = findAfter();

	m_root->m_active.push_back(pw);
	m_parent->add(pw, before);
	pw->m_orientation = (position == Left || position == Right) ? Horz : Vert;
	pw->m_dimen.actual = m_dimen.actual;
	pw->create();
	unpack();
	if (beforeChild || position == Right || position == Bottom)
		{ pw->move(this); pw->move(newChild, beforeChild); }
	else
		{ pw->move(newChild); pw->move(this); }
	pw->packChilds();
	pw->pack();
	return pw;
}


Position
Node::defaultPosition() const
{
	return isPanedWindow() ? (isHorz() ? Right : Bottom) : Center;
}


unsigned
Node::descendantOf(Node const* child, unsigned level) const
{
	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (this->child(i) == child)
			return level;

		unsigned level = this->child(i)->descendantOf(child, level + 1);
		
		if (level < mstl::numeric_limits<unsigned>::max())
			return level;
	}

	return mstl::numeric_limits<unsigned>::max();
}


Node*
Node::findBestPlace(Dimension const& dimen, int& bestDistance)
{
	Node* node = nullptr;
	
	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isPacked())
		{
			int distance = bestDistance;

			if (Node* n = child(i)->findBestPlace(dimen, distance))
			{
				node = n;
				bestDistance = distance;
			}
		}
	}

	if (!node)
	{
		int distance = mstl::abs(m_dimen.actual.area() - dimen.actual.area());

		if (distance < bestDistance)
		{
			node = this;
			bestDistance = distance;
		}
	}

	return node;
}


Node*
Node::findBest(tcl::List const& childs)
{
	M_ASSERT(isRoot());
	M_ASSERT(!childs.empty());

	if (childs.size() == 1)
		return findUid(tcl::asString(childs[0]));
		
	Node* bestNode = nullptr;
	unsigned bestCount = 0;

	findBest(childs, bestNode, bestCount);
	return bestNode;
}


unsigned
Node::findBest(tcl::List const& childs, Node*& bestNode, unsigned& bestCount)
{
	if (isLeaf())
	{
		for (unsigned i = 0; i < childs.size(); ++i)
		{
			if (tcl::equal(childs[i], m_uid))
			{
				if (bestCount == 0)
				{
					bestNode = this;
					bestCount = 1;
				}
				return 1;
			}
		}

		return 0;
	}

	unsigned count = 0;
	bool candidate = true;

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		unsigned n = child(i)->findBest(childs, bestNode, bestCount);

		if (n == 0)
			candidate = false;
		else
			count += n;
	}

	if (candidate && count > bestCount)
	{
		bestNode = this;
		bestCount = count;
	}

	return count;
}


bool
Node::fits(Size size, Position position) const
{
	if (position == Center)
	{
		size.width = mstl::max(size.width, minWidth<Outer>());
		size.height = mstl::max(size.height, minHeight<Outer>());

		return size.width <= m_root->width<Inner>() && size.height <= m_root->height<Inner>();
	}

	if (position & Horz)
	{
		size.width += minWidth<Outer>() + sashSize();
		return size.width <= m_root->width<Inner>();
	}

	size.height += minHeight<Outer>() + sashSize();
	return size.height <= m_root->height<Inner>();
}


Node const*
Node::findRelation(structure::Node const* parent, tcl::List const& childs) const
{
	M_ASSERT(parent);

	unsigned i = 0;

	for ( ; i < parent->numChilds(); ++i)
	{
		structure::Node const* node = parent->child(i);

		if (node->containsOneOf(childs))
			break;
	}

	for (++i; i < parent->numChilds(); ++i)
	{
		tcl::List leaves2;
		parent->child(i)->collectLeaves(leaves2);

		for (unsigned k = 0; k < leaves2.size(); ++k)
		{
			if (Node* node = m_root->findUid(tcl::asString(leaves2[k])))
			{
				if (node->hasAncestor(m_parent->m_parent ? m_parent->m_parent : m_parent))
				{
					while (node->m_parent != m_parent)
						node = node->m_parent;
					return node;
				}
			}
		}
	}

	return nullptr;
}


Node*
Node::findDockingNode(Position& position, Node const*& after, Node const* setup)
{
	if (isMetaFrame())
		return child()->findDockingNode(position, after, setup);

	// 1. Search in saved structures.

	int bestLevel = mstl::numeric_limits<int>::min();
	structure::Type bestType = structure::Leaf;
	structure::Node const* bestNode = nullptr;

	tcl::List leaves;
	collectLeavesRecursively(leaves);

	for (int i = m_root->m_structures.size() - 1; i >= 0; --i)
	{
		int level = -1;
		structure::Node const* sNode = m_root->m_structures[i]->find(leaves, level);

		if (sNode && level >= bestLevel)
		{
			for (	structure::Node const* sParent = sNode->parent();
					sParent && level >= bestLevel;
					sParent = sParent->parent(), level -= 1)
			{
				switch (sParent->type())
				{
					case structure::Horz:	position = Left; break;
					case structure::Vert:	position = Top; break;
					default:						position = Center;
				}

				for (unsigned k = 0; k < sParent->numChilds(); ++k)
				{
					structure::Node const* sChild = sParent->child(k);

					if (sChild != sNode)
					{
						int myLevel = level;

						tcl::List leaves2;
						sChild->collectLeaves(leaves2);

						if (!sChild->isLeaf())
							myLevel -= 1;
						if (sChild->containsOneOf(leaves))
							myLevel += 1;

						if (myLevel > bestLevel)
						{
							for (unsigned j = 0; j < leaves2.size(); ++j)
							{
								Node* node = m_root->findUid(tcl::asString(leaves2[j]));

								if (	node
									&& node != this
									&& node->toplevel() == m_root
									&& node->fits(m_dimen.min, position))
								{
									M_ASSERT(sNode->parent());

									myLevel -= mstl::abs(int(node->depth()) - int(sNode->depth()));

									if (	myLevel > bestLevel
										|| (myLevel == bestLevel && sParent->type() > bestType))
									{
										bestType = sParent->type();
										bestLevel = level;
										bestNode = sChild;
									}
								}
							}
						}
					}
				}
			}
		}
	}

	if (bestNode)
	{
		tcl::List leaves2;
		bestNode->collectLeaves(leaves2);

		Node* node = m_root->findBest(leaves2);

		M_ASSERT(node);

		switch (bestNode->parent()->type())
		{
			case structure::Horz:	position = Right; break;
			case structure::Vert:	position = Bottom; break;
			default:						position = Center; break;
		}

		if (!node->m_parent->isToplevel() && (bestNode->isHorz() || bestNode->isVert()) && node->isLeaf())
			node = node->m_parent;
		if (node->isMetaFrame())
			node = node->m_parent;

		if (	node->m_parent
			&& !node->m_parent->isToplevel()
			&& (	(	(bestNode->parent()->isHorz() || bestNode->parent()->isVert())
					&& !node->isContainer()
					&& node->m_parent->isNotebookOrMultiWindow())
				|| (bestNode->isHorz() && bestNode->parent()->isVert())
				|| (bestNode->isVert() && bestNode->parent()->isHorz())))
		{
			node = node->m_parent;
		}

		if (node->m_parent->isMetaFrame())
			node = node->m_parent;
		after = node->findRelation(bestNode->parent(), leaves);
		return node;
	}

	// 3. Find best place.

	int distance = mstl::numeric_limits<int>::max();
	Node* parent = m_root->findBestPlace(m_dimen, distance);

	// 4. Use child of root, or root if no child exists.

	if (!parent)
	{
		if ((parent = m_root)->child())
			parent = m_root->child();
	}
	
	position = parent->defaultPosition();
	return parent;
}


void
Node::add(Node* node, Node const* before)
{
	M_ASSERT(node);
	M_ASSERT(!node->isPacked());
	M_ASSERT(!contains(node));
	M_ASSERT(!before || contains(before));

	insertNode(node, before);
	node->m_parent = this;
}


void
Node::move(Node* node, Node const* before)
{
	M_ASSERT(node);
	M_ASSERT(!node->isPacked());
	M_ASSERT(!before || contains(before));

	if (node->m_parent) // otherwise it was a float before
		node->remove();
	add(node, before);
}


void
Node::remove()
{
	M_ASSERT(m_parent);
	m_parent->remove(this);
}


void
Node::remove(Childs::iterator pos)
{
	M_ASSERT(pos != end());
	M_ASSERT(!(*pos)->isRoot());

	if (m_selected == *pos)
		m_selected = nullptr;
	m_childs.erase(pos);
}


void
Node::parseStructures(Tcl_Obj *obj)
{
	if (!isRoot())
		return; // Oops, this shouldn't happen

	tcl::Array elems = tcl::getElements(obj);

	for (unsigned i = 0; i < elems.size(); i += 2)
		m_structures.push_back(structure::Node::load(elems[i]));
}


void
Node::parseAttributes(Tcl_Obj* obj)
{
	M_ASSERT(obj);

	tcl::Array elems = tcl::getElements(obj);

	if (elems.size() % 2)
		M_THROW(tcl::Exception("odd attribute list '%s'", tcl::asString(obj)));

	for (unsigned i = 0; i < elems.size(); i += 2)
		tcl::incrRef(m_attrMap[tcl::asString(elems[i])] = elems[i + 1]);
}


void
Node::parseSnapshot(Tcl_Obj* obj)
{
	M_ASSERT(obj);

	if (!isRoot())
		return; // Oops, this shouldn't happen

	tcl::Array elems = tcl::getElements(obj);

	if (elems.size() == 0 || elems.size() % 2)
		M_THROW(tcl::Exception("odd snapshot list '%s'", tcl::asString(obj)));
	
	for (unsigned i = 0; i < elems.size(); i += 2)
	{
		Tcl_Obj* structure	= elems[i];
		tcl::Array sizeList	= tcl::getElements(elems[i + 1]);

		if ((sizeList.size() - 2) % 3)
			M_THROW(tcl::Exception("odd snapshot list '%s'", tcl::asString(obj)));

		Snapshot& snapshot = m_snapshotMap[tcl::asString(structure)];

		snapshot.size.width = tcl::asUnsigned(sizeList[0]);
		snapshot.size.height = tcl::asUnsigned(sizeList[1]);

		for (unsigned k = 2; k < sizeList.size(); k += 3)
		{
			Size& size = snapshot.sizeMap[tcl::asString(sizeList[k])];
			size.width = tcl::asUnsigned(sizeList[k + 1]);
			size.height = tcl::asUnsigned(sizeList[k + 2]);
		}
	}
}


void
Node::parseOptions(Tcl_Obj* opts)
{
	M_ASSERT(opts);

	mstl::carray<Tcl_Obj*> elems = tcl::getElements(opts);

	if (elems.size() % 2 == 1)
		M_THROW(tcl::Exception("odd option list '%s'", tcl::asString(opts)));

	for (unsigned i = 0; i < elems.size(); i += 2)
	{
		char const* name = tcl::asString(elems[i]);
		Tcl_Obj* value = elems[i + 1];

		if (tcl::equal(name, m_objOptX))
			m_coord.x = tcl::asUnsigned(value);
		else if (tcl::equal(name, m_objOptY))
			m_coord.y = tcl::asUnsigned(value);
		else if (tcl::equal(name, m_objOptWidth))
			m_dimen.actual.width = tcl::asUnsigned(value);
		else if (tcl::equal(name, m_objOptHeight))
			m_dimen.actual.height = tcl::asUnsigned(value);
		else if (tcl::equal(name, m_objOptMinWidth))
			m_dimen.min.width = tcl::asUnsigned(value);
		else if (tcl::equal(name, m_objOptMinHeight))
			m_dimen.min.height = tcl::asUnsigned(value);
		else if (tcl::equal(name, m_objOptMaxWidth))
			m_dimen.max.width = tcl::asUnsigned(value);
		else if (tcl::equal(name, m_objOptMaxHeight))
			m_dimen.max.height = tcl::asUnsigned(value);
		else if (tcl::equal(name, m_objOptExpand))
			m_expand = ::parseExpandOption(value);
		else if (tcl::equal(name, m_objOptSticky))
			m_sticky = ::parseStickyOption(tcl::asString(value));
		else if (tcl::equal(name, m_objOptShrink))
			m_shrink = ::parseResizeOption(value);
		else if (tcl::equal(name, m_objOptGrow))
			m_grow = ::parseResizeOption(value);
		else if (tcl::equal(name, m_objOptOrient))
			m_orientation = parseOrientOption(value);
		else if (tcl::equal(name, m_objOptSnapshots))
			parseSnapshot(value);
		else if (tcl::equal(name, m_objOptAttrs))
			parseAttributes(value);
		else if (tcl::equal(name, m_objOptStructures))
			parseStructures(value);
		else
			M_THROW(tcl::Exception("invalid option '%s'", name));
	}

	if (m_dimen.min.width && m_dimen.max.width)
		m_dimen.max.width = mstl::max(m_dimen.min.width, m_dimen.max.width);
	if (m_dimen.min.height && m_dimen.max.height)
		m_dimen.max.height = mstl::max(m_dimen.min.height, m_dimen.max.height);
}


Tcl_Obj*
Node::makeOptions(Flag flags, Node const* before) const
{
	M_ASSERT(flags & (F_Create|F_Pack|F_Config));
	M_ASSERT(!before || before->isPacked());

	tcl::List optList;
	int value;

	if (flags & F_Pack)
	{
		if (((value = expand()) & Both) == Both)
		{
			optList.push_back(m_objOptExpand);
			optList.push_back(m_objBoth);
		}
		else if (value & X)
		{
			optList.push_back(m_objOptExpand);
			optList.push_back(m_objX);
		}
		else if (value & Y)
		{
			optList.push_back(m_objOptExpand);
			optList.push_back(m_objY);
		}
		if ((value = sticky()))
		{
			mstl::string buf;
			optList.push_back(m_objOptSticky);
			optList.push_back(tcl::newObj(makeStickyOptionValue(value, buf)));
		}
	}

	if (flags & (F_Pack|F_Config))
	{
		if (m_parent && m_parent->isContainer())
		{
			if (before)
			{
				optList.push_back(m_objOptBefore);
				optList.push_back(before->pathObj());
			}
		}

		if (isPane() || isFrame() || (m_parent && m_parent->isPanedWindow()))
		{
			if ((value = minWidth<Outer>()) > 0)
			{
				optList.push_back(m_objOptMinWidth);
				optList.push_back(tcl::newObj(value));
			}
			if ((value = minHeight<Outer>()) > 0)
			{
				optList.push_back(m_objOptMinHeight);
				optList.push_back(tcl::newObj(value));
			}
			if ((value = maxWidth<Outer>()) > 0)
			{
				optList.push_back(m_objOptMaxWidth);
				optList.push_back(tcl::newObj(value));
			}
			if ((value = maxHeight<Outer>()) > 0)
			{
				optList.push_back(m_objOptMaxHeight);
				optList.push_back(tcl::newObj(value));
			}
		}
	}

	if (flags & F_Create)
	{
		if ((value = m_orientation))
		{
			optList.push_back(m_objOptOrient);
			optList.push_back(value == Horz ? m_objHorizontal : m_objVertical);
		}
	}

	if ((value = width<Inner>()) > 0)
	{
		optList.push_back(m_objOptWidth);
		optList.push_back(tcl::newObj(value));
	}
	if ((value = height<Inner>()) > 0)
	{
		optList.push_back(m_objOptHeight);
		optList.push_back(tcl::newObj(value));
	}

	return tcl::newObj(optList);
}


Node const*
Node::findAfter(bool onlyPackedChild) const
{
	M_ASSERT(m_parent);
	M_ASSERT(m_parent->contains(this));

	Childs::const_iterator i = m_parent->find(this) + 1;

	if (onlyPackedChild)
	{
		while (	i != m_parent->end()
				&& (!(*i)->isPacked() || (*i)->testFlags(F_Create|F_Pack|F_Unpack|F_Destroy)))
		{
			++i;
		}
	}

	return i == m_parent->end() ? nullptr : *i;
}


void
Node::flatten()
{
	M_ASSERT(!isToplevel());

	if (isWithdrawn())
	{
		destroy();
		remove();
		return;
	}

	if (!(isContainer() || isMetaFrame()))
		return;

	if (numChilds() <= (isMetaFrame() ? 0 : 1))
	{
		Childs childs(m_childs);

		for (unsigned i = 0; i < childs.size(); ++i)
		{
			Node const* before = findAfter();
			Node* child = childs[i];

			M_ASSERT(child->isPacked() || child->testFlags(F_Destroy));

			if (child->isPacked())
			{
				child->unpack();
				m_parent->add(child, before);
				child->pack();
			}
		}

		unpack();
		destroy();
	}
	else if (isPanedWindow())
	{
		Childs childs1(m_childs);

		for (unsigned i = 0; i < childs1.size(); ++i)
		{
			Node* node = childs1[i];

			if (node->isPanedWindow() && node->m_orientation == m_orientation)
			{
				Childs childs2(node->m_childs);
				Node const* before = node->findAfter();

				node->unpack();

				for (unsigned k = 0; k < childs2.size(); ++k)
				{
					Node* n = childs2[k];

					n->unpack();
					move(n, before);
					n->pack();
				}

				node->destroy();
				node->remove();
			}
		}
	}
	else if (isMetaFrame() && (!m_parent->isNotebookOrMultiWindow() || child()->isFrame()))
	{
		unframe();
		addFlag(F_Unframe);
	}
}


void
Node::resizeToParent(int dir)
{
	m_dimen.setActual(
		(dir & X) ? m_parent->width<Inner>() : width<Inner>(),
		(dir & Y) ? m_parent->height<Inner>() : height<Inner>());
}


Node*
Node::dock(Node*& recv, Position position, Node const* setup)
{
	M_ASSERT(!isPacked());

	Node const* before = nullptr;
	bool newParent = bool(recv);

	if (!recv)
		recv = findDockingNode(position, before, setup);
	
	M_ASSERT(recv);

	if (isFloating())
		unfloat(recv->toplevel());
	else if (isWithdrawn())
		create();
	
	if (recv->isRoot() && recv->child())
	{
		recv = recv->child();
		position = Center;
	}
	
	return recv->dock(this, position, before, newParent);
}


Node*
Node::dock(Node* node, Position position, Node const* before, bool newParent)
{
	M_ASSERT(node);

	if (node->isMetaFrame())
		node->unframe();

	Tk_Window tlw = toplevel()->tkwin();

	if (node->exists() && tk::parent(node->tkwin()) != tlw)
	{
		node->performUnpackChildsRecursively();
		tk::reparent(node->tkwin(), tlw);
		node->reparentChildsRecursively(tlw);
		node->performPackChildsRecursively();
	}

	Node* parent = this;

	switch (position)
	{
		case Center:
			if (isNotebookOrMultiWindow() || isRoot())
			{
				move(node, before);
				node->pack();
			}
			else if (node->isNotebookOrMultiWindow())
			{
				Node const* before = findAfter();
				Childs childs(node->m_childs);

				for (unsigned i = 0; i < childs.size(); ++i)
				{
					Node* n = childs[i];

					n->unpack();
					move(n, before);
					n->pack();
				}

				if (node->m_selected)
					node->m_selected->select();
				node->destroy();
				node->remove();
				node->resizeToParent(Both);

				return this;
			}
			else if (m_parent->isNotebookOrMultiWindow())
			{
				m_parent->move(node, before);
				node->pack();
			}
			else
			{
				insertNotebook(node, MultiWindow, before); // isPane() || isFrame() ? MultiWindow : Notebook
			}
			node->resizeToParent(Both);
			break;

		case Left:
		case Right:
		case Top:
		case Bottom:
			if (isPanedWindow() && (m_orientation & position))
			{
				if (!before && (position == Left || position == Top))
					before = *begin();
				move(node, before);
				node->pack();
			}
			else if (m_parent && m_parent->isPanedWindow() && (m_parent->m_orientation & position))
			{
				if (!before)
					before = (position == Right || position == Bottom) ? findAfter() : this;
				m_parent->move(node, before);
				node->pack();
				parent = m_parent;
			}
			else
			{
				insertPanedWindow(position, node, before);
			}
			parent->select();
			node->resizeToParent((position & (Left|Right)) ? Y : X);
			break;
	}

	node->select();
	parent->addFlag(F_Docked);

	if (toplevel() == m_root)
		m_root->releaseStructures();

	return node;
}


bool
Node::applySnapshot()
{
	if (!isPacked())
		return false;

	mstl::string key;

	makeSnapshotKey(key);
	SnapshotMap::iterator i = m_root->m_snapshotMap.find(key);

	if (i == m_root->m_snapshotMap.end())
		return false;

	Snapshot const& snapshot = i->second;

	double scaleWidth		= double(width<Inner>())/double(snapshot.size.width);
	double scaleHeight	= double(height<Inner>())/double(snapshot.size.height);

	applySnapshot(scaleWidth, scaleHeight, snapshot.sizeMap);
	m_root->m_snapshotMap.erase(i);
	return true;
}


void
Node::applySnapshot(double scaleWidth, double scaleHeight, SizeMap const& sizeMap)
{
	if (isLeaf())
	{
		SizeMap::const_iterator i = sizeMap.find(tcl::asString(m_uid));

		if (i != sizeMap.end())
			m_dimen.setActual(i->second.width*scaleWidth + 0.5, i->second.height*scaleHeight + 0.5);
	}
	else
	{
		for (unsigned i = 0; i < numChilds(); ++i)
		{
			if (child(i)->isPacked())
				child(i)->applySnapshot(scaleWidth, scaleHeight, sizeMap);
		}
	}
}


void
Node::packChilds()
{
	for (unsigned i = 0; i < numChilds(); ++i)
		child(i)->pack();
}


void
Node::reparentChildsRecursively(Tk_Window topLevel)
{
	for (unsigned i = 0; i < numChilds(); ++i)
	{
		Node* node = child(i);

		M_ASSERT(!node->isFloating());

		node->reparentChildsRecursively(topLevel);

		if (node->exists())
			tk::reparent(node->tkwin(), topLevel);
	}
}


template <Orient D>
int
Node::doExpandPanes(int space, bool expandable, int stage)
{
	M_ASSERT(space > 0);

	int available = 0;
	int spread = 0;

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		Node const* child = this->child(i);

		if (child->isPacked() && (expandable == child->isExpandable<D>()))
			available += child->computeExpand<D>(stage);
	}

	if (available > 0)
	{
		int remaining = mstl::min(available, space);

		for (unsigned i = 0; i < numChilds(); ++i)
		{
			Node* child = this->child(i);

			if (child->isPacked() && (expandable == child->isExpandable<D>()))
			{
				int expand = child->computeExpand<D>(stage);
				int share = mstl::min(remaining, int((double(expand)/available)*space + 0.5));

				if (int maxSize = child->maxSize<Inner,D>())
					share = mstl::min(share, maxSize - child->actualSize<Inner,D>());

				if (share > 0)
				{
					spread += share;
					remaining -= share;
					M_ASSERT(remaining >= 0);
					M_ASSERT(spread <= space);
					child->doAdjustment<D>(child->actualSize<Inner,D>() + share);
				}
			}
		}
	}

	return spread;
}


template <Orient D>
void
Node::expandPanes(int computedSize, int space)
{
	M_ASSERT(computedSize >= 0);
	M_ASSERT(space > 0);

	int spread = 0;
	int available = 0;

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		Node* child = this->child(i);

		if (child->isPacked())
			available += mstl::max(0, child->computeUnderflow<D>());
	}

	if (available > 0)
	{
		int remaining = mstl::min(available, space);

		for (unsigned i = 0; i < numChilds(); ++i)
		{
			Node* child = this->child(i);

			if (child->isPacked())
			{
				int expand = child->computeUnderflow<D>();

				if (int share = mstl::min(remaining, int((double(expand)/available)*space + 0.5)))
				{
					spread += share;
					M_ASSERT(spread <= space);
					M_ASSERT(remaining >= 0);
					child->doAdjustment<D>(child->actualSize<Inner,D>() + share);
				}
			}
		}
	}

	if (space - spread > 0)
		spread += doExpandPanes<D>(space - spread, true, 1);
	if (space - spread > 0)
		spread += doExpandPanes<D>(space - spread, true, 2);
	if (space - spread > 0)
		spread += doExpandPanes<D>(space - spread, false, 1);
	if (space - spread > 0)
		spread += doExpandPanes<D>(space - spread, false, 2);

	m_dimen.set<D>(computedSize + spread);
}


template <Orient D>
int
Node::doShrinkPanes(int space, bool expandable, int stage)
{
	int available = 0;
	int spread = 0;

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		Node const* child = this->child(i);

		if (child->isPacked() && (expandable == child->isExpandable<D>()))
			available += child->computeShrink<D>(stage);
	}

	if (available > 0)
	{
		int remaining = mstl::min(available, space);

		for (unsigned i = 0; i < numChilds(); ++i)
		{
			Node* child = this->child(i);

			if (child->isPacked() && (expandable == child->isExpandable<D>()))
			{
				int shrink = child->computeShrink<D>(stage);
				int share = mstl::min(remaining, int((double(shrink)/available)*space + 0.5));

				if (child->minSize<Inner,D>())
					share = mstl::min(share, child->actualSize<Inner,D>() - child->minSize<Inner,D>());

				if (share > 0)
				{
					spread += share;
					remaining -= share;
					M_ASSERT(remaining >= 0);
					M_ASSERT(spread <= space);
					child->doAdjustment<D>(child->actualSize<Inner,D>() - share);
				}
			}
		}
	}

	return spread;
}


template <Orient D>
void
Node::shrinkPanes(int computedSize, int space)
{
	M_ASSERT(computedSize >= 0);
	M_ASSERT(space > 0);

	int spread = doShrinkPanes<D>(space, true, 1);
	if (space - spread > 0)
		spread += doShrinkPanes<D>(space - spread, true, 2);
	if (space - spread > 0)
		spread += doShrinkPanes<D>(space - spread, false, 1);
	if (space - spread > 0)
		spread += doShrinkPanes<D>(space - spread, false, 2);

	m_dimen.set<D>(computedSize - spread);
}


template <Orient D>
void
Node::resizeFrame(int reqSize)
{
	M_ASSERT(reqSize >= 0);

	if (!isToplevel())
		m_dimen.set<D>(reqSize);

	int size = actualSize<Inner,D>();
	
	for (unsigned i = 0; i < numChilds(); ++i)
		child(i)->doAdjustment<D>(size);
}


template <Orient D>
void
Node::doAdjustment(int size)
{
	if (orientation<D>())
	{
		// try to grow underflowing childs (not recursively!)
		// try to shrink overflowing childs (not recursively!)
	}

	int computedSize = computeDimen<D>();
	int space = size - computedSize;

	if (space != 0)
	{
		if (orientation<D>())
		{
			addFlag(F_Config);

			if (space > 0)
				expandPanes<D>(computedSize, space);
			else
				shrinkPanes<D>(computedSize, -space);
		}
		else
		{
			resizeFrame<D>(size);
		}
	}
	else if (!orientation<D>())
	{
		for (unsigned i = 0; i < numChilds(); ++i)
		{
			if (child(i)->isPacked())
				child(i)->doAdjustment<D>(child(i)->contentSize<D>(size));
		}
	}
}


template <Orient D>
void
Node::adjustToplevel()
{
	if (grow<D>() && actualSize<Inner,D>() < minSize<Inner,D>())
		m_dimen.set<D>(mstl::min(minSize<Inner,D>(), m_actual.min.dimen<D>()));
	else if (shrink<D>() && maxSize<Inner,D>() && actualSize<Inner,D>() > maxSize<Inner,D>())
		m_dimen.set<D>(mstl::min(maxSize<Inner,D>(), m_actual.min.dimen<D>()));
}


void
Node::adjustDimensions()
{
	M_ASSERT(isToplevel());

	adjustToplevel<Horz>();
	adjustToplevel<Vert>();

	doAdjustment<Horz>(actualSize<Inner,Horz>());
	doAdjustment<Vert>(actualSize<Inner,Vert>());
}


void
Node::withdraw()
{
	M_ASSERT(m_parent);
	M_ASSERT(m_parent->contains(this));

	if (isPacked())
		unpack();
	else
		m_state = Withdrawn;
}


bool
Node::makeSnapshot(mstl::string& structure, SizeMap* sizeMap) const
{
	if (isMetaFrame())
		return child()->makeSnapshot(structure, sizeMap);

	if (m_priority < 0)
		return false;
	
	if (sizeMap && isLeaf())
		sizeMap->insert(SizeMap::value_type(tcl::asString(m_uid), m_dimen.actual));

	if (!isRoot() && !isMetaFrame())
	{
		static_assert(LAST < 10, "range problem");

		if (isLeaf())
			structure.append(tcl::asString(m_uid));
		else
			structure.append(char(int(isNotebookOrMultiWindow() ? Notebook : m_type) + '0'));
	}

	mstl::vector<mstl::string> keyList;
	bool rc = isPanedWindow();

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		M_ASSERT(child(i)->isPacked());

		if (child(i)->m_parent == this)
		{
			keyList.push_back();

			if (child(i)->makeSnapshot(keyList.back(), sizeMap))
				rc = true;
		}
	}

	keyList.bubblesort();
	if (keyList.size() > 1)
		structure.append('(');
	for (unsigned i = 0; i < keyList.size(); ++i)
	{
		if (i > 0 && keyList[i].front() != '(' && keyList[i - 1].back() != ')')
			structure.append(':');
		structure.append(keyList[i]);
	}
	if (keyList.size() > 1)
		structure.append(')');

	return rc;
}


void
Node::makeSnapshot()
{
	M_ASSERT(m_root == toplevel());

	Snapshot snapshot;
	mstl::string structure;

	for (Node* node = this; node; node = node->m_parent)
	{
		snapshot.size.width = node->width<Inner>();
		snapshot.size.height = node->height<Inner>();
		structure.clear();

		if (node->makeSnapshot(structure, &snapshot.sizeMap))
			return mstl::swap(m_root->m_snapshotMap[structure], snapshot);
	}
}


void
Node::floating(bool temporary)
{
	bool whileLoading = (m_parent == nullptr);

	if (m_root == toplevel())
	{
		m_parent->makeSnapshot();
		m_root->makeStructure();
	}

	if (!isWithdrawn())
		withdraw();
	
	if (!whileLoading)
	{
		remove();
		m_parent = nullptr;
	}

	if (!temporary && !isMetaFrame())
		makeMetaFrame();

	m_temporary = temporary;

	bool exists = this->exists();

	if (!exists)
		performCreate();

	performUnpackChildsRecursively();
	::releaseWindow(path());
	setState(Floating);
	reparentChildsRecursively(tkwin());
	performPackChildsRecursively();
	tk::reparent(tkwin(), m_root->tkwin());

	if (!whileLoading)
		m_root->m_toplevel.push_back(this);

	if (!exists)
	{
		performFinalizeCreate();
		delFlag(F_Create);
	}

	m_parent = nullptr;
	m_shrink = m_grow = true;
	addFlag(F_Raise|F_Header|F_Undocked);
}


void
Node::unfloat(Node* toplevel)
{
	M_ASSERT(isFrameOrMetaFrame());

	if (!toplevel)
		toplevel = this->toplevel();

	m_temporary = false;
	performUnpackChildsRecursively();
	::captureWindow(path(), toplevel->path());
	setState(Withdrawn);
	reparentChildsRecursively(toplevel->tkwin());
	performPackChildsRecursively();

	Childs::iterator i = m_root->m_toplevel.find(this);
	M_ASSERT(i != m_root->m_toplevel.end());
	m_root->m_toplevel.erase(i);
}


Tcl_Obj*
Node::inspect(AttrSet const& exportList) const
{
	M_ASSERT(isRoot());

	tcl::DString str;

	for (unsigned i = 0; i < m_toplevel.size(); ++i)
		m_toplevel[i]->inspect(exportList, str);

	return str.toObj();
}


void
Node::inspect(tcl::DString& str, Structures const& structures) const
{
	M_ASSERT(isRoot());

	str.startList();

	// Skip initial structure if existing.
	unsigned i = m_initialStructure ? 1 : 0;

	for ( ; i < structures.size(); ++i)
		structures[i]->inspect(str);

	str.endList();
}


void
Node::inspect(tcl::DString& str, SnapshotMap const& snapshots)
{
	SnapshotMap::const_iterator i;

	str.startList();

	for (i = snapshots.begin(); i != snapshots.end(); ++i)
	{
		SizeMap::const_iterator k;

		str.append(i->first);
		str.startList();
		str.append(i->second.size.width);
		str.append(i->second.size.height);
		for (k = i->second.sizeMap.begin(); k != i->second.sizeMap.end(); ++k)
		{
			str.append(k->first);
			str.append(k->second.width);
			str.append(k->second.height);
		}
		str.endList();
	}

	str.endList();
}


void
Node::inspectAttrs(AttrSet const& exportList, tcl::DString& str) const
{
	str.startList();

	for (unsigned i = 0; i < exportList.size(); ++i)
	{
		AttrMap::const_iterator k = m_attrMap.find(exportList[i]);

		if (k != m_attrMap.end())
		{
			str.append(k->first);
			str.append(k->second);
		}
	}

	str.endList();
}


void
Node::inspect(AttrSet const& exportList, tcl::DString& str) const
{
	if (isMetaFrame())
		return child()->inspect(exportList, str);

	str.append(::makeTypeID(m_type));
	if (isLeaf())
		str.append(uidObj());

	str.startList();

	if (!isRoot() && m_parent->isMetaFrame() && m_parent->isToplevel())
	{
		str.append(m_objOptX);
		str.append(m_parent->x() - m_root->x());
		str.append(m_objOptY);
		str.append(m_parent->y() - m_root->y());
	}

	switch (m_type)
	{
		case Root:
			str.append(m_objOptX);
			str.append(x());
			str.append(m_objOptY);
			str.append(y());
			str.append(m_objOptShrink);
			str.append(::makeResizeOptionValue(m_shrink));
			str.append(m_objOptGrow);
			str.append(::makeResizeOptionValue(m_grow));

			if (!m_snapshotMap.empty())
			{
				str.append(m_objOptSnapshots);
				inspect(str, m_snapshotMap);
			}

			if (!m_structures.empty())
			{
				str.append(m_objOptStructures);
				inspect(str, m_structures);
			}
			break;

		case Pane:
		case Frame:
			str.append(m_objOptWidth);
			str.append(width<Inner>());
			str.append(m_objOptHeight);
			str.append(height<Inner>());
			if (minWidth<Inner>())
			{
				str.append(m_objOptMinWidth);
				str.append(minWidth<Inner>());
			}
			if (minHeight<Inner>())
			{
				str.append(m_objOptMinHeight);
				str.append(minHeight<Inner>());
			}
			if (maxWidth<Inner>())
			{
				str.append(m_objOptMaxWidth);
				str.append(maxWidth<Inner>());
			}
			if (maxHeight<Inner>())
			{
				str.append(m_objOptMaxHeight);
				str.append(maxHeight<Inner>());
			}
			str.append(m_objOptExpand);
			str.append(::makeExpandOptionValue(m_expand));
			str.append(m_objOptAttrs);
			inspectAttrs(exportList, str);
			break;

		case PanedWindow:
			str.append(m_objOptOrient);
			str.append(::makeOrientationOptionValue(m_orientation));
			// fallthru

		case MultiWindow:
		case Notebook:
			if (m_sticky)
			{
				mstl::string buf(4);
				str.append(m_objOptSticky);
				str.append(::makeStickyOptionValue(m_sticky, buf));
			}
			break;

		case MetaFrame:
			if (isToplevel())
			{
				str.append(m_objOptX);
				str.append(x());
				str.append(m_objOptY);
				str.append(y());
			}
			break;
	}

	str.endList();

	if (!isLeaf())
	{
		str.startList();

		for (unsigned i = 0; i < numChilds(); ++i)
			child(i)->inspect(exportList, str);

		str.endList();
	}
}


Node const*
Node::makeClone(Tcl_Obj* uidObj)
{
	M_ASSERT(uidObj);
	M_ASSERT(isLeaf());

	Node* node = clone(m_parent, uidObj);
	Node* recv = m_parent;

	node->create();

	if (m_parent->isNotebookOrMultiWindow())
	{
		m_parent->add(node, findAfter());
		node->pack();
	}
	else
	{
		m_parent->m_childs.push_back(node); // temporary
		recv = insertNotebook(node, MultiWindow);
	}
	
	node->select();
	node->toplevel()->perform();
	return recv;
}


Node const*
Node::makeNew(Tcl_Obj* typeObj, Tcl_Obj* uidObj, Tcl_Obj* optObj, Node const* setup)
{
	M_ASSERT(typeObj);
	M_ASSERT(uidObj);
	M_ASSERT(optObj);
	M_ASSERT(isRoot());

	Type type = ::parseTypeOption(typeObj);

	if (!isLeaf(type))
		M_THROW(tcl::Exception("type 'pane' or 'frame' expected instead of '%s'", tcl::asString(typeObj)));
	
	if (m_root->findUid(tcl::asString(uidObj)))
		M_THROW(tcl::Exception("leaf '%s' already exists", tcl::asString(uidObj)));

	if (toplevel() == m_root)
		m_root->releaseStructures();

	Node* node = new Node(*this, type, uidObj);
	node->m_state = Withdrawn;
	m_active.push_back(node);
	node->parseOptions(optObj);
	m_childs.push_back(node);

	Node* recv = nullptr;
	recv = node->dock(recv, Center, setup);
	node->toplevel()->perform();
	return recv;
}


void
Node::saveLeaves(LeafMap& leaves)
{
	M_ASSERT(isRoot());

	Tk_Window tlw = tkwin();

	for (Childs::iterator i = m_active.begin(); i != m_active.end(); )
	{
		Node* node = *i;

		if (node->isPacked())
			node->unpack();

		if (node->isLeaf())
		{
			leaves[node->uid()] = node;
			node->remove();
			i = m_active.erase(i);

			if (tk::parent(node->tkwin()) != tlw)
				tk::reparent(node->tkwin(), tlw);
		}
		else
		{
			node->destroy();
			node->m_state = Withdrawn;
			i += 1;
		}
	}

	performAllActiveNodes(F_Unpack);
	performAllActiveNodes(F_Destroy);
	performDeleteInactiveNodes();

	for (LeafMap::iterator k = leaves.begin(); k != leaves.end(); ++k)
	{
		Node* node = k->second;

		node->m_priority = 0;
		node->m_root = nullptr;
		node->m_parent = nullptr;
		node->m_savedParent = nullptr;
		node->m_selected = nullptr;
		node->m_expand = 0;
		node->m_sticky = 0;
		tcl::zero(node->m_headerObj);
		tcl::zero(node->m_oldHeaderObj);
		tcl::zero(node->m_titleObj);
		tcl::zero(node->m_oldTitleObj);
	}
}


void
Node::load(Tcl_Obj* list, LeafMap const* leaves)
{
	M_ASSERT(list);

	Tcl_Obj**	objv;
	unsigned		numElems;

	numElems = tcl::getElements(list, objv);

	if (isContainer() || isRoot())
	{
		if (numElems % 3)
			M_THROW(tcl::Exception("odd list size"));
	}
	else
	{
		if (numElems != 3)
			M_THROW(tcl::Exception("entry for root/pane/frame/metaframe must have three elements"));
	}

	for (unsigned i = 0; i < numElems; i += 3)
	{
		Tcl_Obj*	what = objv[i];
		Tcl_Obj*	uid = nullptr;
		Tcl_Obj*	opts = nullptr;
		Type		type = ::parseTypeOption(objv[i]);

		if (isLeaf(type))
		{
			uid = objv[i + 1];
			opts = objv[i + 2];

			if (tcl::isInt(uid))
				M_THROW(tcl::Exception(" invalid UID '%s'; must not be an integer", tcl::asString(uid)));
		}
		else
		{
			opts = objv[i + 1];
		}

		if (isRoot(type))
		{
			if (this != m_root)
				M_THROW(tcl::Exception("unexpected widget type 'root'"));

			parseOptions(opts);
			load(objv[i + 2], leaves);
			m_toplevel.push_back(this);
			if (leaves)
				create();
		}
		else
		{
			if (this == m_root && !isPacked())
				M_THROW(tcl::Exception("unexpected widget type '%s' for root", tcl::asString(what)));
			if (uid && m_root->findUid(tcl::asString(uid)))
				M_THROW(tcl::Exception("leaf '%s' already exists", tcl::asString(uid)));

			LeafMap::const_iterator n;
			Node* node;

			if (uid && leaves && (n = leaves->find(tcl::asString(uid))) != leaves->end())
			{
				node = n->second;
				node->m_parent = this;
				node->m_root = m_root;
			}
			else
			{
				node = new Node(*this, type, uid);
				if (leaves)
					node->create();
			}

			node->m_state = isRoot() && i >= 3 ? Floating : Packed;
			m_root->m_active.push_back(node);
			node->parseOptions(opts);
			insertNode(node);

			switch (node->m_state)
			{
				case Packed:
					node->pack();
					break;

				case Floating:
					node->remove();
					node->m_parent = nullptr;
					node->addFlag(F_Deiconify);
					m_root->m_toplevel.push_back(node);
					break;

				case Withdrawn:
					M_THROW(tcl::Exception("withdrawn window '%s'", tcl::asString(uid)));
			}

			if (isContainer(type) || isMetaFrame(type))
				node->load(objv[i + 2], leaves);
		}
	}
}


void
Node::load(Tcl_Obj* list, LeafMap const* leaves, Node const* sRoot)
{
	M_ASSERT(list);
	M_ASSERT(isRoot());

	load(list, leaves);

	if (sRoot)
		finishLoad(leaves, sRoot);
}


void
Node::finishLoad(LeafMap const* leaves, Node const* sRoot)
{
	M_ASSERT(sRoot);
	M_ASSERT(isRoot());

	m_dimen.zero();

	if (leaves)
	{
		for (LeafMap::const_iterator k = leaves->begin(); k != leaves->end(); ++k)
		{
			Node* node = k->second;

			if (node->isWithdrawn())
			{
				m_active.push_back(node);
				node->m_parent = this;
				node->m_root = this;
				node->destroy();
			}

			node->delFlag(F_Unpack);
		}
	}

	if (sRoot->child() && sRoot->child()->isContainer())
	{
		m_initialStructure = true;
		structure::Node* node = sRoot->child()->makeStructure(nullptr);
		m_structures.push_front(node);
	}
}


template <Orient D,Quantity Q>
void
Node::adjustDimen(double f)
{
	int outer	= dimen<Outer,D,Q>();
	int inner	= dimen<Inner,D,Q>();
	int offs		= outer - inner;

	if (outer)
		m_dimen.set<D,Q>(mstl::max(5, int(f*outer + 0.5) - offs));
}


void
Node::resizeDimensions()
{
	M_ASSERT(isToplevel());

	int width		= this->width<Outer>();
	int height		= this->height<Outer>();
	int newWidth	= width;
	int newHeight	= height;

	performResizeDimensions(newWidth, newHeight);

	if (width == newWidth && height == newHeight)
		return;

	double fh = double(newWidth)/double(mstl::max(1, width));
	double fv = double(newHeight)/double(mstl::max(1, height));

	for (unsigned i = 0; i < m_active.size(); ++i)
	{
		Node* node = m_active[i];

		node->adjustDimen<Horz>(fh);
		node->adjustDimen<Vert>(fv);
		node->adjustDimen<Horz,Min>(fh);
		node->adjustDimen<Vert,Min>(fv);
		node->adjustDimen<Horz,Max>(fh);
		node->adjustDimen<Vert,Max>(fv);

		node->m_coord.x = int(fh*node->m_coord.x + 0.5);
		node->m_coord.y = int(fv*node->m_coord.y + 0.5);
	}

	adjustDimen<Horz>(fh);
	adjustDimen<Vert>(fv);
	adjustDimen<Horz,Min>(fh);
	adjustDimen<Vert,Min>(fv);
	adjustDimen<Horz,Max>(fh);
	adjustDimen<Vert,Max>(fv);
}


int
Node::performQueryFrameHeaderSize() const
{
	M_ASSERT(exists());

	Tcl_Obj* result;
	
	result = tcl::call(__func__, m_root->pathObj(), m_objFrameHdrSizeCmd, pathObj(), nullptr);
	if (!result)
		M_THROW(tcl::Error());
	int size = tcl::asInt(result);
	tcl::decrRef(result);
	return size;
}


int
Node::performQueryNotebookHeaderSize() const
{
	M_ASSERT(exists());

	Tcl_Obj*	result;
	
	result = tcl::call(__func__, m_root->pathObj(), m_objNotebookHdrSizeCmd, pathObj(), nullptr);
	if (!result)
		M_THROW(tcl::Error());
	int size = tcl::asInt(result);
	tcl::decrRef(result);
	return size;
}


int
Node::performQuerySashSize() const
{
	M_ASSERT(exists());

	Tcl_Obj* result = tcl::call(__func__, m_root->pathObj(), m_objSashSizeCmd, nullptr);

	if (!result)
		M_THROW(tcl::Error());
		
	int size = tcl::asInt(result);
	tcl::decrRef(result);
	return size;
}


void
Node::performPackChildsRecursively()
{
	for (unsigned i = 0; i < numChilds(); ++i)
	{
		Node* node = child(i);

		if (node->testFlags(F_Reparent))
		{
			node->performPackChildsRecursively();
			node->performPack();
			node->m_state = Packed;
			node->delFlag(F_Reparent);
		}
	}
}


void
Node::performUnpackChildsRecursively()
{
	for (unsigned i = 0; i < numChilds(); ++i)
	{
		Node* node = child(i);

		M_ASSERT(node->isPacked());

		if (node->testFlags(F_Unpack))
		{
			node->performUnpack(node->m_savedParent);
			node->delFlag(F_Unpack);
		}
		else
		{
			node->performUnpack(this);
		}

		node->m_state = Withdrawn;
		node->addFlag(F_Reparent);
		node->performUnpackChildsRecursively();
	}
}


void
Node::performPack()
{
	if (isRoot())
		return;

	M_ASSERT(m_parent);
	M_ASSERT(m_parent->contains(this));
	M_ASSERT(!isToplevel() || isRoot());
	M_ASSERT(exists());
	M_ASSERT(m_parent->exists());

	tcl::invoke(__func__,
					m_root->pathObj(),
					m_objPackCmd,
					m_parent->pathObj(),
					pathObj(),
					makeOptions(F_Pack, findAfter(true)),
					nullptr);
}


void
Node::performUnpack(Node* parent)
{
	M_ASSERT(parent);
	M_ASSERT(exists());
	M_ASSERT(parent->exists());

	tcl::invoke(__func__, m_root->pathObj(), m_objUnpackCmd, parent->pathObj(), pathObj(), nullptr);
}


void
Node::performCreate()
{
	M_ASSERT(!exists());
	M_ASSERT(!isRoot());

	Tcl_Obj* opts = isContainer() ? makeOptions(F_Create) : (isLeaf() ? m_uid : nullptr);

	m_root->m_current = this;

	if (opts)
		m_path = tcl::call(__func__, m_root->pathObj(), typeObj(), opts, nullptr);
	else
		m_path = tcl::call(__func__, m_root->pathObj(), typeObj(), nullptr);

	m_root->m_current = nullptr;

	if (!m_path)
		M_THROW(tcl::Error());

	if (!isToplevel() && toplevel()->isFloating())
		tk::reparent(tkwin(), toplevel()->tkwin());

	tk::createEventHandler(tkwin(), StructureNotifyMask, ::WindowEventProc, this);
}


void
Node::performFinalizeCreate()
{
	M_ASSERT(exists());
	M_ASSERT(!isMetaFrame() || child()->exists());

	if (tcl::invoke(	__func__,
							m_root->pathObj(),
							m_objFrame2Cmd,
							pathObj(),
							isMetaFrame() ? child()->m_path : m_uid,
							nullptr) != TCL_OK)
	{
		M_THROW(tcl::Error());
	}
}


void
Node::performBuild()
{
	M_ASSERT(exists());
	M_ASSERT(isLeaf());

	if (tcl::invoke(	__func__,
							m_root->pathObj(),
							m_objBuildCmd,
							pathObj(),
							uidObj(),
							tcl::newObj(width<Inner>()),
							tcl::newObj(height<Inner>()),
							nullptr) != TCL_OK)
	{
		M_THROW(tcl::Error());
	}
}


void
Node::performReady()
{
	M_ASSERT(isRoot());

	if (tcl::invoke(	__func__,
							m_root->pathObj(),
							m_objReadyCmd,
							tcl::newObj(width<Outer>()),
							tcl::newObj(height<Outer>()),
							nullptr) != TCL_OK)
	{
		M_THROW(tcl::Error());
	}
}


void
Node::performResizeDimensions(int& width, int& height)
{
	M_ASSERT(isToplevel());

	Tcl_Obj* result = tcl::call(	__func__,
											m_root->pathObj(),
											m_objResizingCmd,
											pathObj(),
											tcl::newObj(width),
											tcl::newObj(height),
											nullptr);
	if (!result)
		M_THROW(tcl::Error());

	tcl::Array elems = tcl::getElements(result);

	if (elems.size() == 0)
		return;
	
	if (elems.size() != 2 || !tcl::isInt(elems[0]) || !tcl::isInt(elems[0]))
		M_THROW(tcl::Exception("width/height pair expected"));
	
	width = mstl::max(1, tcl::asInt(elems[0]));
	height = mstl::max(1, tcl::asInt(elems[1]));
}


void
Node::performGetWorkArea()
{
	M_ASSERT(isRoot());

	Tcl_Obj* result = tcl::call(__func__, pathObj(), m_objWorkAreaCmd, nullptr);

	if (!result)
		M_THROW(tcl::Error());
		
	tcl::Array elems = tcl::getElements(result);

	if (elems.size() != 2 || !tcl::isInt(elems[0]) || !tcl::isInt(elems[1]))
	{
		tcl::decrRef(result);
		M_THROW(tcl::Exception("'workarea' expects { width height }"));
	}

	m_workArea.width = tcl::asInt(elems[0]);
	m_workArea.height = tcl::asInt(elems[1]);
	tcl::decrRef(result);
}


void
Node::performConfig()
{
	M_ASSERT(m_parent);
	M_ASSERT(m_parent->isPanedWindow());
	M_ASSERT(exists());
	M_ASSERT(!isToplevel());
	M_ASSERT(isPacked());

	tk::makeExists(tkwin());
	tk::makeExists(m_parent->tkwin());

	Tcl_Obj* list = makeOptions(F_Config);

	if (list)
	{
		tcl::invoke(__func__,
						m_root->pathObj(),
						m_objPaneConfigCmd,
						m_parent->pathObj(),
						pathObj(),
						list,
						nullptr);
	}
}


void
Node::performGeometry()
{
	M_ASSERT(isToplevel());

	if (width<Inner>() > 1 && height<Inner>() > 1)
	{
		int newWidth	= width<Outer>();
		int newHeight	= height<Outer>();

		if (	(m_flags & F_Undocked)
			|| m_dimen != m_actual
			|| newWidth != tk::width(tkwin())
			|| newHeight != tk::height(tkwin()))
		{
			bool h = isExpandable<Horz>();
			bool v = isExpandable<Vert>();

			m_actual.min = m_dimen.min;
			m_actual.max = m_dimen.max;

			tcl::invoke(__func__,
							m_root->pathObj(),
							m_objGeometryCmd,
							pathObj(),
							tcl::newObj(newWidth),
							tcl::newObj(newHeight),
							tcl::newObj(m_actual.min.width),
							tcl::newObj(m_actual.min.height),
							tcl::newObj(m_actual.max.width),
							tcl::newObj(m_actual.max.height),
							(h && v) ? m_objBoth : (h ? m_objX : (v ? m_objY : m_objNone)),
							nullptr);
		}
	}
}


void
Node::performDestroy()
{
	M_ASSERT(isToplevel() || isWithdrawn());

	if (!exists())
		return;

	// IMPORTANT NOTE:
	// Even after deleting the event handler still some events may arrive.
	// This is a severe Tk bug.
	tk::deleteEventHandler(tkwin(), StructureNotifyMask, ::WindowEventProc, this);

	tcl::invoke(__func__, m_root->pathObj(), m_objDestroyCmd, pathObj(), nullptr);
}


void
Node::performSelect()
{
	M_ASSERT(m_parent);
	M_ASSERT(exists());
	M_ASSERT(isPacked());
	M_ASSERT(m_parent->exists());
	M_ASSERT(m_parent->isNotebookOrMultiWindow());

	m_parent->m_selected = this;

	tcl::invoke(__func__,
					m_root->pathObj(),
					m_objSelectCmd,
					m_parent->pathObj(),
					pathObj(),
					nullptr);
}


void
Node::performUpdateHeader()
{
	M_ASSERT(exists());
	M_ASSERT(isFrameOrMetaFrame());

	tcl::invoke(__func__,
					m_root->pathObj(),
					m_objHeaderCmd,
					pathObj(),
					m_headerObj ? m_headerObj : m_obj,
					nullptr);
}


void
Node::performUpdateTitle()
{
	M_ASSERT(exists());
	M_ASSERT(isFloating());

	tcl::invoke(__func__, m_root->pathObj(), m_objTitleCmd, pathObj(), m_titleObj, nullptr);
}


unsigned
Node::collectFlags() const
{
	M_ASSERT(isRoot());

	unsigned flags = m_flags;

	for (unsigned i = 0; i < m_active.size(); ++i)
		flags |= m_active[i]->m_flags;
	
	return flags;
}


void
Node::clearAllFlags()
{
	M_ASSERT(isToplevel());

	m_flags = 0;

	for (unsigned i = 0; i < m_active.size(); ++i)
		m_active[i]->m_flags = 0;
}


void
Node::updateHeader()
{
	M_ASSERT(!isWithdrawn());

	if (isMultiWindow())
	{
		Tcl_Obj* list = nullptr;

		for (unsigned i = 0; i < numChilds(); ++i)
		{
			if (child(i)->isPacked())
				tcl::addElement(list, child(i)->pathObj());
		}

		tcl::incrRef(list);
		tcl::set(m_headerObj, list);

		for (unsigned i = 0; i < numChilds(); ++i)
		{
			Node* node = child(i);

			if (node->isPacked() && node->isFrameOrMetaFrame())
				tcl::set(node->m_headerObj, list);
		}

		tcl::decrRef(list);
	}
	else if (isNotebook())
	{
		for (unsigned i = 0; i < numChilds(); ++i)
		{
			Node* node = child(i);

			if (node->isPacked())
				tcl::zero(node->m_headerObj);
		}
	}
	else if (isPanedWindow())
	{
		for (unsigned i = 0; i < numChilds(); ++i)
		{
			Node* node = child(i);

			if (node->isPacked() && node->isFrameOrMetaFrame())
				tcl::set(node->m_headerObj, node->pathObj());
		}
	}
	else if (isFloating())
	{
		if (isFrame())
		{
			tcl::zero(m_headerObj);
		}
		else if (isMetaFrame())
		{
			tcl::zero(m_headerObj);

			if (child()->isFrame())
				tcl::zero(child()->m_headerObj);
		}
		else
		{
			M_ASSERT(isFrame());
			tcl::set(m_headerObj, pathObj());
		}

		tcl::set(m_titleObj, findLeader()->pathObj());
	}
	else if (isFrame() && m_parent->isRoot())
	{
		tcl::set(m_headerObj, pathObj());
	}
}


void
Node::updateAllHeaders()
{
	M_ASSERT(isRoot());

	for (unsigned i = 0; i < m_active.size(); ++i)
	{
		Node* node = m_active[i];

		tcl::set(node->m_oldHeaderObj, node->m_headerObj);
		tcl::set(node->m_oldTitleObj, node->m_titleObj);
		tcl::zero(node->m_headerObj);
		tcl::zero(node->m_titleObj);
	}

	for (unsigned i = 0; i < m_active.size(); ++i)
	{
		Node* node = m_active[i];

		if (!node->isWithdrawn())
			node->updateHeader();
	}
}


void
Node::performRaiseRecursively(bool needed)
{
	for (unsigned i = 0; i < numChilds(); ++i)
	{
		Node* child = this->child(i);

		M_ASSERT(child->isPacked());

		bool doIt = needed || child->testFlags(F_Raise);

		if (doIt && !isToplevel())
		{
			M_ASSERT(!m_selected || m_selected->isPacked());

			if (m_selected)
				m_selected->performSelect();
			if (testFlags(F_Select))
				performSelect();
			tk::raise(child->tkwin(), tkwin());
		}

		child->performRaiseRecursively(doIt);
	}
}


void
Node::performCreateRecursively()
{
	if (testFlags(F_Create))
		performCreate();

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isPacked())
			child(i)->performCreateRecursively();
	}
}


void
Node::performBuildRecursively()
{
	if (testFlags(F_Build))
		performBuild();

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isPacked())
			child(i)->performBuildRecursively();
	}
}


void
Node::performFinalizeCreateRecursively()
{
	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isPacked())
			child(i)->performFinalizeCreateRecursively();
	}

	if (testFlags(F_Create) && isFrameOrMetaFrame())
		performFinalizeCreate();
}


void
Node::performPackRecursively()
{
	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isPacked())
			child(i)->performPackRecursively();
	}

	if (testFlags(F_Pack))
		performPack();
}


void
Node::performFlattenRecursively()
{
	Childs childs(m_childs);

	for (unsigned i = 0; i < childs.size(); ++i)
		childs[i]->performFlattenRecursively();
	
	if (!isToplevel())
		flatten();
}


void
Node::performRestructureRecursively()
{
	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isPacked())
			child(i)->performRestructureRecursively();
	}

	if ((isPanedWindow() || isPane()) && m_parent && m_parent->isNotebookOrMultiWindow())
		makeMetaFrame();
}


void
Node::performConfigRecursively()
{
	if (m_parent && m_parent->isPanedWindow() && !isToplevel())
		performConfig();
	
	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isPacked())
			child(i)->performConfigRecursively();
	}
}


void
Node::performUpdateHeaderRecursively(bool force)
{
	M_ASSERT(!isWithdrawn());

	if (isFrameOrMetaFrame())
	{
		if (force || testFlags(F_Create|F_Pack|F_Header) || !tcl::eqOrNull(m_headerObj, m_oldHeaderObj))
			performUpdateHeader();

		if (isFloating() && m_titleObj && !tcl::eqOrNull(m_titleObj, m_oldTitleObj))
			performUpdateTitle();
	}

	for (unsigned i = 0; i < numChilds(); ++i)
		child(i)->performUpdateHeaderRecursively(force);
}


void
Node::performAllActiveNodes(Flag flag)
{
	M_ASSERT(isRoot());

	for (unsigned i = 0; i < m_active.size(); ++i)
	{
		Node* node = m_active[i];

		if (node->testFlags(flag))
		{
			switch (flag)
			{
				case F_Unpack:
					M_ASSERT(node->m_savedParent);
					if (node->m_savedParent->m_selected == this)
						node->m_savedParent->m_selected = nullptr;
					node->performUnpack(node->m_savedParent);
					node->m_savedParent = nullptr;
					break;

				case F_Unframe:
				{
					M_ASSERT(node->isPacked());
					M_ASSERT(node->m_savedParent);

					node->performUnpack(node->m_savedParent);
					if (!node->testFlags(F_Pack))
						node->performPack();
					break;
				}

				case F_Docked:
					for (Node* n = node; n && !n->applySnapshot(); n = n->m_parent)
						;
					break;

				case F_Destroy:
					node->performDestroy();
					node->m_isDeleted = true;
					break;

				case F_Build:		// fallthru
				case F_Pack:		// fallthru
				case F_Create:		// fallthru
				case F_Config:		// fallthru
				case F_Raise:		// fallthru
				case F_Select:		// fallthru
				case F_Header:		// fallthru
				case F_Undocked:	// fallthru
				case F_Reparent:	// fallthru
				case F_Deiconify:	M_ASSERT(!"unexpected"); break;
			}
		}
	}
}


void
Node::performUpdateDimensions()
{
	M_ASSERT(isRoot());

	if (m_actual.actual.width > 0 && m_actual.actual.height > 0)
	{
		m_dimen.actual = m_actual.actual;
		m_actual.actual.zero();
	}

	for (unsigned i = 0; i < m_active.size(); ++i)
	{
		Node* node = m_active[i];

		if (node->m_actual.actual.width > 0 && node->m_actual.actual.height > 0)
		{
			node->m_dimen.actual = node->m_actual.actual;
			node->m_actual.actual.zero();
		}
	}
}


void
Node::performDeleteInactiveNodes()
{
	M_ASSERT(isRoot());

	// IMPORTANT NOTE: Do not destroy the node immediately, because still
	// some events may arrive. The deleted nodes will be destroyed later.

	Childs::iterator i = m_active.begin();

	while (i != m_active.end())
	{
		if ((*i)->m_isDeleted)
		{
			M_ASSERT(m_deleted.find(*i) == m_deleted.end());
			M_ASSERT(!(*i)->exists() || (*i)->isAlreadyDead());

			if ((*i)->isToplevel())
			{
				Childs::iterator k = m_toplevel.find(*i);
				M_ASSERT(k != m_toplevel.end());
				m_toplevel.erase(k);
			}

			m_deleted.push_back(*i);
			i = m_active.erase(i);
		}
		else
		{
			i += 1;
		}
	}
}


void
Node::performDeiconify(bool force)
{
	if (tcl::invoke(
			__func__,
			m_root->pathObj(),
			m_objDeiconifyCmd,
			pathObj(),
			tcl::newObj(dimen<Outer,Horz>()),
			tcl::newObj(dimen<Outer,Vert>()),
			tcl::newObj(m_coord.x),
			tcl::newObj(m_coord.y),
			tcl::newObj(force),
			nullptr) != TCL_OK)
	{
		M_THROW(tcl::Error());
	}
}

void
Node::performDeiconifyFloats()
{
	M_ASSERT(isRoot());

	for (unsigned i = 1; i < m_toplevel.size(); ++i)
	{
		Node* toplevel = m_toplevel[i];

		if (toplevel->testFlags(F_Deiconify))
		{
			toplevel->performRestructureRecursively();
			toplevel->performCreateRecursively();
			toplevel->performFinalizeCreateRecursively();
			toplevel->computeDimensionsRecursively();
			toplevel->adjustDimensions();
			toplevel->performPackRecursively();
			toplevel->performUpdateHeaderRecursively(true);
			toplevel->setState(Withdrawn);
			toplevel->floating(false);
			toplevel->performRaiseRecursively();
			toplevel->performBuildRecursively();
			toplevel->performDeiconify();
		}
	}
}


void
Node::perform(Node* toplevel)
{
	M_ASSERT(isToplevel());
	M_ASSERT(!toplevel || toplevel->isToplevel());

	m_root->m_isLocked = true;

	if (toplevel == this)
		toplevel = nullptr;

	try
	{
		if (m_isDeleted)
		{
			m_root->performAllActiveNodes(F_Destroy);
			m_root->performDeleteInactiveNodes();
		}
		else
		{
			performFlattenRecursively();
			performFlattenRecursively(); // we need a second pass for unframing

			if (toplevel)
			{
				toplevel->performFlattenRecursively();
				toplevel->performFlattenRecursively(); // we need a second pass for unframing
			}

			unsigned flags = m_root->collectFlags();

			if (flags & F_Unpack)
				m_root->performAllActiveNodes(F_Unpack);

			if (flags & F_Unframe)
				m_root->performAllActiveNodes(F_Unframe);

			if (flags & (F_Pack|F_Unpack))
			{
				performRestructureRecursively();
				if (toplevel)
					toplevel->performRestructureRecursively();
				flags = m_root->collectFlags();
			}

			if (flags & F_Create)
			{
				performCreateRecursively();
				if (toplevel)
					toplevel->performCreateRecursively();
				performFinalizeCreateRecursively();
				if (toplevel)
					toplevel->performFinalizeCreateRecursively();
			}

			if (flags & (F_Pack|F_Unpack|F_Header))
				m_root->updateAllHeaders();

			m_root->performGetWorkArea();

			if (isRoot() && (flags & F_Docked))
				m_root->performAllActiveNodes(F_Docked);

			if (flags & (F_Create|F_Pack|F_Unpack|F_Config))
			{
				computeDimensionsRecursively();
				if (toplevel)
					toplevel->computeDimensionsRecursively();
			}

			m_root->resizeDimensions();
			if (toplevel)
				toplevel->resizeDimensions();

			if (flags & (F_Pack|F_Unpack|F_Config))
			{
				adjustDimensions();
				if (toplevel)
					toplevel->adjustDimensions();
			}

			performGeometry();
			if (toplevel)
				toplevel->performGeometry();

			if (flags & F_Pack)
			{
				performPackRecursively();
				if (toplevel)
					toplevel->performPackRecursively();
			}

			performConfigRecursively();
			if (toplevel)
				toplevel->performConfigRecursively();

			if (flags & F_Raise)
			{
				performRaiseRecursively();
				if (toplevel)
					toplevel->performRaiseRecursively(toplevel->testFlags(F_Raise));
			}

			if (flags & (F_Pack|F_Unpack|F_Raise|F_Header))
			{
				performUpdateHeaderRecursively();
				if (toplevel)
					toplevel->performUpdateHeaderRecursively();
			}

			if (flags & F_Destroy)
				m_root->performAllActiveNodes(F_Destroy);

			m_root->performDeleteInactiveNodes();
			m_root->performUpdateDimensions();

			if (flags & F_Build)
			{
				m_root->performBuildRecursively();
				if (toplevel)
					toplevel->performBuildRecursively();
			}

			if (flags & F_Deiconify)
				m_root->performDeiconifyFloats();

			m_root->performUpdateDimensions();
		}
	}
	catch (Terminated)
	{
		throw;
	}
	catch (...)
	{
		m_root->m_isLocked = false;
		m_root->clearAllFlags();
		throw;
	}

	m_root->m_isLocked = false;
	m_root->clearAllFlags();
}

#ifndef NDEBUG

void
Node::dump() const
{
	Childs& active = m_root->m_active;

	for (unsigned i = 0; i < active.size(); ++i)
		active[i]->m_dumpFlag = false;

	printf("=================================================\n");
	dump(0, false);
}


void
Node::dump(unsigned level, bool parentIsWithdrawn) const
{
	M_ASSERT(parentIsWithdrawn || !m_parent || !isPacked() || m_parent->contains(this));

	bool isWithdrawn = parentIsWithdrawn || this->isWithdrawn();

	if (isToplevel())
	{
		printf("%s (%dx%d)\n", m_path ? path() : "<null>", width<Outer>(), height<Outer>());
		level += 1;
	}
	else if (!isMetaFrame())
	{
		for (unsigned i = 1; i < level; ++i)
			printf("| ");

		if (m_dumpFlag)
		{
			printf("**** recursion detect: %s *****\n", id());
			return;
		}

		char const* state;

		if (m_parent && m_parent->isMetaFrame() && m_parent->isFloating())
			state = "floating";
		else if (isPacked())
			state = "packed";
		else
			state = "withdrawn";

		if (isWithdrawn)
			printf("#");

		printf("%s", m_uid ? uid() : (m_path ? path() : "<null>"));
		if (isLeaf())
			printf(" {%u}", m_priority);
		if (isPanedWindow())
			printf(" [%s]", isHorz() ? "h" : "v");
		if (m_parent && m_parent->isMetaFrame())
			printf(" [meta=%s]", m_parent->id());
		if (isLeaf())
			printf(isFrame() ? " [frame]" : " [pane]");
		printf(" [%s] (%dx%d)", state, width<Inner>(), height<Inner>());
		if (minWidth<Inner>() || minHeight<Inner>())
			printf(" min(%dx%d)", minWidth<Inner>(), minHeight<Inner>());
		if (maxWidth<Inner>() || maxHeight<Inner>())
			printf(" max(%dx%d)", maxWidth<Inner>(), maxHeight<Inner>());
		printf(" \n");
		level += 1;
	}

	m_dumpFlag = true;
	{
		for (unsigned i = 0; i < numChilds(); ++i)
			child(i)->dump(level, isWithdrawn);
	}
	m_dumpFlag = false;
}

#endif // NDEBUG

void
Node::initialize()
{
	if (m_objPanedWindow)
		return;

	m_obj = tcl::incrRef(tcl::newObj());
	m_objBoth = tcl::incrRef(tcl::newObj("both"));
	m_objBuildCmd = tcl::incrRef(tcl::newObj("build"));
	m_objDeiconifyCmd = tcl::incrRef(tcl::newObj("deiconify"));
	m_objDestroyCmd = tcl::incrRef(tcl::newObj("destroy"));
	m_objDirsLR = tcl::incrRef(tcl::newListObj("l r"));
	m_objDirsTB = tcl::incrRef(tcl::newListObj("t b"));
	m_objDirsTBLR = tcl::incrRef(tcl::newListObj("t b l r"));
	m_objDirsTBLREW = tcl::incrRef(tcl::newListObj("t b l r e w"));
	m_objDirsTBLRNS = tcl::incrRef(tcl::newListObj("t b l r n s"));
	m_objDirsTBLRNSEW = tcl::incrRef(tcl::newListObj("t b l r n s e w"));
	m_objFloating = tcl::incrRef(tcl::newObj("floating"));
	m_objFrame = tcl::incrRef(tcl::newObj("frame"));
	m_objFrame2Cmd = tcl::incrRef(tcl::newObj("frame2"));
	m_objFrameHdrSizeCmd = tcl::incrRef(tcl::newObj("framehdrsize"));
	m_objGeometryCmd = tcl::incrRef(tcl::newObj("geometry"));
	m_objHeaderCmd = tcl::incrRef(tcl::newObj("header"));
	m_objHorizontal = tcl::incrRef(tcl::newObj("horizontal"));
	m_objHorz = tcl::incrRef(tcl::newObj("horz"));
	m_objMetaFrame = tcl::incrRef(tcl::newObj("metaframe"));
	m_objMultiWindow = tcl::incrRef(tcl::newObj("multiwindow"));
	m_objNone = tcl::incrRef(tcl::newObj("none"));
	m_objNormal = tcl::incrRef(tcl::newObj("normal"));
	m_objNotebook = tcl::incrRef(tcl::newObj("notebook"));
	m_objNotebookHdrSizeCmd = tcl::incrRef(tcl::newObj("nbhdrsize"));
	m_objOptAttrs = tcl::incrRef(tcl::newObj("-attrs"));
	m_objOptBefore = tcl::incrRef(tcl::newObj("-before"));
	m_objOptExpand = tcl::incrRef(tcl::newObj("-expand"));
	m_objOptGrow = tcl::incrRef(tcl::newObj("-grow"));
	m_objOptHeight = tcl::incrRef(tcl::newObj("-height"));
	m_objOptMaxHeight = tcl::incrRef(tcl::newObj("-maxheight"));
	m_objOptMaxWidth = tcl::incrRef(tcl::newObj("-maxwidth"));
	m_objOptMinHeight = tcl::incrRef(tcl::newObj("-minheight"));
	m_objOptMinWidth = tcl::incrRef(tcl::newObj("-minwidth"));
	m_objOptOrient = tcl::incrRef(tcl::newObj("-orient"));
	m_objOptRecover = tcl::incrRef(tcl::newObj("-recover"));
	m_objOptShrink = tcl::incrRef(tcl::newObj("-shrink"));
	m_objOptSnapshots = tcl::incrRef(tcl::newObj("-snapshots"));
	m_objOptStructures = tcl::incrRef(tcl::newObj("-structures"));
	m_objOptState = tcl::incrRef(tcl::newObj("-state"));
	m_objOptSticky = tcl::incrRef(tcl::newObj("-sticky"));
	m_objOptWidth = tcl::incrRef(tcl::newObj("-width"));
	m_objOptX = tcl::incrRef(tcl::newObj("-x"));
	m_objOptY = tcl::incrRef(tcl::newObj("-y"));
	m_objPackCmd = tcl::incrRef(tcl::newObj("pack"));
	m_objPaneConfigCmd = tcl::incrRef(tcl::newObj("paneconfigure"));
	m_objPanedWindow = tcl::incrRef(tcl::newObj("panedwindow"));
	m_objPane = tcl::incrRef(tcl::newObj("pane"));
	m_objReadyCmd = tcl::incrRef(tcl::newObj("ready"));
	m_objResizingCmd = tcl::incrRef(tcl::newObj("resizing"));
	m_objRoot = tcl::incrRef(tcl::newObj("root"));
	m_objSashSizeCmd = tcl::incrRef(tcl::newObj("sashsize"));
	m_objSelectCmd = tcl::incrRef(tcl::newObj("select"));
	m_objTitleCmd = tcl::incrRef(tcl::newObj("title"));
	m_objUnpackCmd = tcl::incrRef(tcl::newObj("unpack"));
	m_objVert = tcl::incrRef(tcl::newObj("vert"));
	m_objVertical = tcl::incrRef(tcl::newObj("vertical"));
	m_objWithdrawn = tcl::incrRef(tcl::newObj("withdrawn"));
	m_objWorkAreaCmd = tcl::incrRef(tcl::newObj("workarea"));
	m_objX = tcl::incrRef(tcl::newObj("x"));
	m_objY = tcl::incrRef(tcl::newObj("y"));
}

} // namespace


static void
cmdCapture(int objc, Tcl_Obj* const objv[])
{
	if (objc != 3 && objc != 4)
		M_THROW(tcl::Exception(3, objv, "window ?receiver?"));

	captureWindow(tcl::asString(objv[2]), objc == 4 ? tcl::asString(objv[3]) : nullptr);
}


static void
cmdRelease(int objc, Tcl_Obj* const objv[])
{
	if (objc != 3)
		M_THROW(tcl::Exception(3, objv, "window"));

	releaseWindow(tcl::asString(objv[2]));
}


static void
cmdInit(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
		M_THROW(tcl::Exception(3, objv, "list"));

	M_ASSERT(!base.setup);

	base.setup = Node::makeRoot(objv[2]);
	base.setup->load(objv[3]);
}


static void
cmdLoad(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 3 && objc != 4)
		M_THROW(tcl::Exception(3, objv, "?list?"));

	M_ASSERT(base.setup);

	Node::LeafMap leaves;

	if (base.root)
	{
		base.root->saveLeaves(leaves);
		delete base.root;
		base.root = nullptr;
	}

	if (objc > 3 && tcl::countElements(objv[3]) > 0)
	{
		base.root = Node::makeRoot(objv[2]);
		base.root->load(objv[3], &leaves, base.setup);
	}
	else // if (objc == 3)
	{
		base.root = base.setup->clone(leaves);
	}

	base.root->perform(nullptr);
	base.root->ready();
}


static void
cmdClone(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 5)
		M_THROW(tcl::Exception(3, objv, "template uid"));

	char const* uid = tcl::asString(objv[3]);
	Node* node = base.root->findUid(uid);

	if (!node)
		M_THROW(tcl::Exception("cannot find leaf '%s'", uid));

	tcl::setResult(node->makeClone(objv[4])->pathObj());
}


static void
cmdNew(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 6)
		M_THROW(tcl::Exception(3, objv, "type uid options"));
	
	tcl::setResult(base.root->makeNew(objv[3], objv[4], objv[5], base.setup)->pathObj());
}


static void
cmdClose(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 3)
		M_THROW(tcl::Exception(3, objv));

	Node::removeBase(tcl::asString(objv[2]));
}


static void
cmdIsContainer(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
		M_THROW(tcl::Exception(3, objv, "window"));

	char const* path = tcl::asString(objv[3]);
	Node const* node = base.root->findPath(path);

	if (!node)
		M_THROW(tcl::Exception("cannot find window '%s'", path));

	tcl::setResult(node->isContainer());
}


static void
cmdIsMetaChild(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
		M_THROW(tcl::Exception(3, objv, "window"));

	char const* path = tcl::asString(objv[3]);
	Node const* node = base.root->findPath(path);

	if (!node)
		M_THROW(tcl::Exception("cannot find window '%s'", path));

	Node const* parent = node->parent();
	tcl::setResult(parent && (parent->isMultiWindow() || parent->isMetaFrame()));
}


static void
cmdIsPane(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
		M_THROW(tcl::Exception(3, objv, "window"));

	char const* path = tcl::asString(objv[3]);
	Node* node = base.root->findPath(path);

	if (!node)
		M_THROW(tcl::Exception("cannot find window '%s'", path));

	tcl::setResult(node->isPane());
}


static void
cmdIsDocked(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
		M_THROW(tcl::Exception(3, objv, "uid"));

	char const* path = tcl::asString(objv[3]);
	Node* node = base.root->findUid(path);

	tcl::setResult(node != nullptr);
}


static void
cmdContainer(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 3 && objc != 4)
		M_THROW(tcl::Exception(3, objv, "window"));

	if (objc == 4)
	{
		char const* path = tcl::asString(objv[3]);
		Node* node = base.root->findPath(path);

		if (!node)
			M_THROW(tcl::Exception("cannot find window '%s'", path));

		node = node->parent();

		if (node)
		{
			if (node->isMetaFrame())
				node = node->parent();
			if (node->isContainer())
				tcl::setResult(node->pathObj());
		}
	}
	else
	{
		tcl::setResult(base.root->collectContainer());
	}
}


static void
cmdFloats(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 3)
		M_THROW(tcl::Exception(2, objv));

	tcl::setResult(base.root->collectFloats());
}


static void
cmdSelected(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
		M_THROW(tcl::Exception(3, objv, "window"));

	char const* path = tcl::asString(objv[3]);
	Node* node = base.root->findPath(path);

	if (!node)
		M_THROW(tcl::Exception("cannot find window '%s'", path));
	if (!node->isNotebookOrMultiWindow())
		M_THROW(tcl::Exception("'%s' is not a notebook/multiwindow", path));

	tcl::setResult(node->selected()->pathObj());
}


static void
cmdParent(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
		M_THROW(tcl::Exception(3, objv, "window"));

	char const* path = tcl::asString(objv[3]);
	Node* node = base.root->findPath(path);

	if (!node)
	{
		node = base.root->getCurrent();

		if (!node)
			M_THROW(tcl::Exception("cannot find window '%s'", path));
	}

	node = node->parent();

	if (!node)
		M_THROW(tcl::Exception("root has no parent"));
	
	if (!node->exists())
		M_THROW(tcl::Exception("'%s' has no parent", path));

	tcl::setResult(node->pathObj());
}


static void
cmdToplevel(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
		M_THROW(tcl::Exception(3, objv, "window"));

	char const* path = tcl::asString(objv[3]);
	Node* node = base.root->findPath(path);

	if (!node)
	{
		node = base.root->getCurrent();

		if (!node)
			M_THROW(tcl::Exception("cannot find window '%s'", path));
	}

	tcl::setResult(node->toplevel()->pathObj());
}


static void
cmdNeighbors(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
		M_THROW(tcl::Exception(3, objv, "window"));

	char const* path = tcl::asString(objv[3]);
	Node* node = base.root->findPath(path);

	if (!node)
		M_THROW(tcl::Exception("cannot find window '%s'", path));
	
	if (!node->isToplevel())
	{
		Node const* parent	= node->parent();
		Node const* left		= nullptr;
		Node const* right		= nullptr;

		if (parent && parent->isPanedWindow())
		{
			left	= parent->leftNeighbor(node);
			right	= parent->rightNeighbor(node);
		}

		Tcl_Obj* result[2] =
		{
			left ? left->pathObj() : tcl::newObj(),
			right ? right->pathObj() : tcl::newObj()
		};
		tcl::setResult(2, result);
	}
}


static void
cmdOrientation(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
		M_THROW(tcl::Exception(3, objv, "window"));

	char const* path = tcl::asString(objv[3]);
	Node* node = base.root->findPath(path);

	if (!node)
		M_THROW(tcl::Exception("cannot find window '%s'", path));

	Node const* parent = node->parent();

	if (parent && parent->isPanedWindow())
		tcl::setResult(parent->orientation<Horz>() ? m_objHorizontal : m_objVertical);
}


static void
cmdFind(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 5)
		M_THROW(tcl::Exception(3, objv, "attribute value"));

	tcl::setResult(base.root->findWindows(tcl::asString(objv[3]), objv[4]));
}


static void
cmdFrames(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
		M_THROW(tcl::Exception(3, objv, "window"));

	char const* path = tcl::asString(objv[3]);
	Node* node = base.root->findPath(path);

	if (!node)
		M_THROW(tcl::Exception("cannot find window '%s'", path));

	tcl::setResult(node->collectFrames());
}


static void
cmdLeaves(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 3)
		M_THROW(tcl::Exception(3, objv));

	tcl::setResult(base.root->collectLeaves());
}


static void
cmdPanes(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 3 && objc != 4)
		M_THROW(tcl::Exception(3, objv, "?window?"));

	if (objc == 3)
	{
		tcl::setResult(base.root->collectPanes());
	}
	else
	{
		char const* path = tcl::asString(objv[3]);
		Node* node = base.root->findPath(path);

		if (!node)
			M_THROW(tcl::Exception("cannot find window '%s'", path));

		tcl::setResult(node->collectPanesRecursively());
	}
}


static void
cmdVisible(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 3 && objc != 4)
		M_THROW(tcl::Exception(3, objv, "?window?"));
	
	Node* node = base.root;

	if (objc == 4 && !(node = base.root->findPath(tcl::asString(objv[3]))))
		M_THROW(tcl::Exception("cannot find window '%s'", tcl::asString(objv[3])));

	tcl::setResult(node->collectVisible());
}


static void
cmdHidden(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
		M_THROW(tcl::Exception(3, objv, "window"));

	char const* path = tcl::asString(objv[3]);
	Node* node = base.root->findPath(path);

	if (!node)
		M_THROW(tcl::Exception("cannot find window '%s'", path));

	tcl::setResult(node->collectHidden());
}


static void
cmdLeader(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
		M_THROW(tcl::Exception(3, objv, "window"));

	char const* path = tcl::asString(objv[3]);
	Node* node = base.root->findPath(path);

	if (!node)
		M_THROW(tcl::Exception("cannot find window '%s'", path));

	if (Node const* leader = node->findLeader())
		tcl::setResult(leader->pathObj());
}


static void
cmdLeaf(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
		M_THROW(tcl::Exception(3, objv, "uid"));

	char const* uid = tcl::asString(objv[3]);
	Node* node = base.root->findUid(uid);

	if (!node)
		M_THROW(tcl::Exception("cannot find leaf '%s'", uid));

	tcl::setResult(node->pathObj());
}


static void
cmdUid(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
		M_THROW(tcl::Exception(3, objv, "window"));

	char const* path = tcl::asString(objv[3]);
	Node* node = base.root->findPath(path);

	if (!node)
		M_THROW(tcl::Exception("cannot find window '%s'", path));

	if (node->isFrame())
		tcl::setResult(node->uidObj());
}


static void
cmdId(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
		M_THROW(tcl::Exception(3, objv, "window"));

	char const* path = tcl::asString(objv[3]);
	Node* node = base.root->findPath(path);

	if (!node)
	{
		node = base.root->getCurrent();

		if (!node)
			M_THROW(tcl::Exception("cannot find window '%s'", path));
	}

	tcl::setResult(node->id());
}


static void
cmdInspect(Base& base, int objc, Tcl_Obj* const objv[])
{
	Node::AttrSet attrSet;

	for (int i = 3; i < objc; ++i)
		attrSet.push_back(tcl::asString(objv[i]));
	
	tcl::setResult(base.root->inspect(attrSet));
}

	
static void
cmdDock(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4 && objc != 6)
		M_THROW(tcl::Exception(3, objv, "window ?receiver position?"));
	
	char const* path = tcl::asString(objv[3]);
	Node* node = base.root->findPath(path);

	if (!node)
		M_THROW(tcl::Exception("cannot find window '%s'", path));

	if (!node->isFrameOrMetaFrame())
		M_THROW(tcl::Exception("cannot dock '%s', it's not a frame", path));

	Node* recv = nullptr;
	Position position = Center;

	if (objc == 6)
	{
		recv = base.root->findPath(tcl::asString(objv[4]));

		if (!recv)
			M_THROW(tcl::Exception("cannot find receiver '%s'", tcl::asString(objv[4])));

		position = parsePositionOption(tcl::asString(objv[5]));
	}

	Node* parent = node->dock(recv, position, base.setup);

	node->toplevel()->perform(recv->toplevel());
	tcl::setResult(parent->pathObj());
}


static void
cmdUndock(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4 && objc != 5)
		M_THROW(tcl::Exception(3, objv, "?-temporary? window"));
	
	unsigned pathIndex = 3;
	bool temporary = false;

	if (objc == 5)
	{
		if (!tcl::equal(objv[pathIndex], "-temporary"))
			M_THROW(tcl::Exception("invalid option '%s'", tcl::asString(objv[pathIndex])));
		temporary = true;
		pathIndex += 1;
	}

	char const* path = tcl::asString(objv[pathIndex]);
	Node* node = base.root->findPath(path);
	Node* toplevel = node->toplevel();

	if (!node)
		M_THROW(tcl::Exception("cannot find window '%s'", path));

	if (!node->isFrameOrMetaFrame())
		M_THROW(tcl::Exception("cannot undock '%s', it's not a frame", path));

	M_ASSERT(node->parent());

	node->floating(temporary);
	toplevel->perform(node->toplevel());
	tcl::setResult(node->pathObj());
}


static void
cmdShow(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
		M_THROW(tcl::Exception(3, objv, "toplevel"));
	
	char const* path = tcl::asString(objv[3]);
	Node* node = base.root->findPath(path);

	if (!node)
		M_THROW(tcl::Exception("cannot find window '%s'", path));

	if (!tk::isToplevel(node->tkwin()))
		M_THROW(tcl::Exception("'%s' is not a toplevel window", path));

	node->show();
}


static void
cmdToggle(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
		M_THROW(tcl::Exception(3, objv, "window"));
	
	char const* path = tcl::asString(objv[3]);
	Node* node = base.root->findPath(path);

	if (!node)
		M_THROW(tcl::Exception("cannot find window '%s'", path));

	if (!node->isNotebookOrMultiWindow())
		M_THROW(tcl::Exception("cannot toggle '%s', it's not a notebook or multiwindow", path));

	node->toggle();
}


static void
cmdRefresh(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 3)
		M_THROW(tcl::Exception(3, objv));

	base.root->refresh();
}


static void
cmdResize(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 10)
		M_THROW(tcl::Exception(3, objv, "window width height minwidth minheight maxwidth maxheight"));

	char const* path = tcl::asString(objv[3]);
	Node* node = base.root->findPath(path);

	if (!node)
		M_THROW(tcl::Exception("cannot find window '%s'", path));

	node->resize(
		tcl::asInt(objv[4]), tcl::asInt(objv[5]),
		tcl::asInt(objv[6]), tcl::asInt(objv[7]),
		tcl::asInt(objv[8]), tcl::asInt(objv[9]));
}


static void
cmdSet(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc < 4)
		M_THROW(tcl::Exception(3, objv, "window ?attribute value...?"));
	
	if (objc % 2 == 1)
		M_THROW(tcl::Exception("odd number of arguments"));

	char const* cmd = tcl::asString(objv[1]);
	char const* path = tcl::asString(objv[3]);
	Node* node = base.root->findPath(path);

	if (!node)
	{
		node = base.root->getCurrent();

		if (!node)
			M_THROW(tcl::Exception("cannot find window '%s'", path));
	}

	bool ignoreMeta = cmd[::strlen(cmd) - 1] == '!';

	for (int i = 4; i < objc; i += 2)
		node->set(tcl::asString(objv[i]), objv[i + 1], ignoreMeta);
}


static void
cmdGet(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 5 && objc != 6)
		M_THROW(tcl::Exception(3, objv, "window attribute ?default?"));
	
	char const* cmd = tcl::asString(objv[1]);
	char const* path = tcl::asString(objv[3]);
	Node* node = base.root->findPath(path);

	if (!node)
	{
		node = base.root->getCurrent();

		if (!node)
			M_THROW(tcl::Exception("cannot find window '%s'", path));
	}

	Tcl_Obj* value = node->get(tcl::asString(objv[4]), cmd[::strlen(cmd) - 1] == '!');

	if (!value)
	{
		if (objc == 5)
		{
			M_THROW(tcl::Exception(
				"can't find attribute '%s' for window '%s'", tcl::asString(objv[4]), path));
		}

		value = objv[5];
	}

	tcl::setResult(value);
}


static Base&
initBase(Tcl_Obj* path)
{
	Base* base = Node::createBase(path);

	if (base->setup)
		M_THROW(tcl::Exception("'%s' is already exisiting", tcl::asString(path)));

	return *base;
}


typedef void (*PerformFunc)(Base& base, int objc, Tcl_Obj* const objv[]);

static Base&
lookupBase(bool forLoad, Tcl_Obj* path)
{
	M_ASSERT(path);

	char const* pathName = tcl::asString(path);
	Base* base = Node::lookupBase(pathName);

	if (!base)
		M_THROW(tcl::Exception("cannot find base '%s'", pathName));

	if (!base->setup)
		M_THROW(tcl::Exception("'%s' is not initialized", pathName));

	if (!base->root && !forLoad)
		M_THROW(tcl::Exception("'%s' is not loaded", pathName));

	return *base;
}


static void
execute(PerformFunc func, bool forLoad, int objc, Tcl_Obj* const objv[])
{
	M_ASSERT(objc > 2);
	func(lookupBase(forLoad, objv[2]), objc, objv);
}


static int
cmdTwm(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] =
	{
		"clone",			"capture",		"close",			"container",	"dock",
		"find",			"floats",		"frames",		"get",			"get!",
		"hidden",		"id",				"init",			"inspect",		"iscontainer",
		"isdocked",		"ismetachild",	"ispane",		"leaf",			"leader",
		"leaves",		"load",			"neighbors",	"new",			"orientation",
		"panes",			"parent",		"refresh",		"release",		"resize",
		"selected",		"set",			"set!",			"show",			"toggle",
		"toplevel",		"uid",			"undock",		"visible",		nullptr
	};
	enum
	{
		Cmd_Clone,		Cmd_Capture,		Cmd_Close,		Cmd_Container,	Cmd_Dock,
		Cmd_Find,		Cmd_Floats,			Cmd_Frames,		Cmd_Get,			Cmd_Get_,
		Cmd_Hidden,		Cmd_Id,				Cmd_Init,		Cmd_Inspect,	Cmd_IsContainer,
		Cmd_IsDocked,	Cmd_IsMetaChild,	Cmd_IsPane,		Cmd_Leaf,		Cmd_Leader,
		Cmd_Leaves,		Cmd_Load,			Cmd_Neighbors,	Cmd_New,			Cmd_Orientation,
		Cmd_Panes,		Cmd_Parent,			Cmd_Refresh,	Cmd_Release,	Cmd_Resize,
		Cmd_Selected,	Cmd_Set,				Cmd_Set_,		Cmd_Show,		Cmd_Toggle,
		Cmd_Toplevel,	Cmd_Uid,				Cmd_Undock,		Cmd_Visible,	Cmd_NULL
	};

	static_assert(sizeof(subcommands)/sizeof(subcommands[0]) == Cmd_NULL + 1, "initialization failed");

	if (objc <= 2)
		return tcl::wrongNumArgs(objc, objv, objc == 1 ? "command path ?args?" : "command ?args?");

	int index;

	if (Tcl_GetIndexFromObj(ti, objv[1], subcommands, "subcommand", TCL_EXACT, &index) != TCL_OK)
		return TCL_ERROR;

	try
	{
		switch (index)
		{
			case Cmd_Clone:			execute(cmdClone, false, objc, objv); break;
			case Cmd_Close:			execute(cmdClose, true, objc, objv); break;
			case Cmd_Container:		execute(cmdContainer, false, objc, objv); break;
			case Cmd_Dock:				execute(cmdDock, false, objc, objv); break;
			case Cmd_Find:				execute(cmdFind, false, objc, objv); break;
			case Cmd_Floats:			execute(cmdFloats, false, objc, objv); break;
			case Cmd_Frames:			execute(cmdFrames, false, objc, objv); break;
			case Cmd_Get:				// fallthru
			case Cmd_Get_:				execute(cmdGet, false, objc, objv); break;
			case Cmd_Hidden:			execute(cmdHidden, false, objc, objv); break;
			case Cmd_Id:				execute(cmdId, false, objc, objv); break;
			case Cmd_Init:				cmdInit(initBase(objv[2]), objc, objv); break;
			case Cmd_Inspect:			execute(cmdInspect, false, objc, objv); break;
			case Cmd_IsContainer:	execute(cmdIsContainer, false, objc, objv); break;
			case Cmd_IsDocked:		execute(cmdIsDocked, false, objc, objv); break;
			case Cmd_IsMetaChild:	execute(cmdIsMetaChild, false, objc, objv); break;
			case Cmd_IsPane:			execute(cmdIsPane, false, objc, objv); break;
			case Cmd_Leader:			execute(cmdLeader, false, objc, objv); break;
			case Cmd_Leaves:			execute(cmdLeaves, false, objc, objv); break;
			case Cmd_Leaf:				execute(cmdLeaf, false, objc, objv); break;
			case Cmd_Load:				execute(cmdLoad, true, objc, objv); break;
			case Cmd_Neighbors:		execute(cmdNeighbors, false, objc, objv); break;
			case Cmd_New:				execute(cmdNew, false, objc, objv); break;
			case Cmd_Orientation:	execute(cmdOrientation, false, objc, objv); break;
			case Cmd_Panes:			execute(cmdPanes, false, objc, objv); break;
			case Cmd_Parent:			execute(cmdParent, false, objc, objv); break;
			case Cmd_Refresh:			execute(cmdRefresh, false, objc, objv); break;
			case Cmd_Resize:			execute(cmdResize, false, objc, objv); break;
			case Cmd_Selected:		execute(cmdSelected, false, objc, objv); break;
			case Cmd_Set:				// fallthru
			case Cmd_Set_:				execute(cmdSet, false, objc, objv); break;
			case Cmd_Show:				execute(cmdShow, false, objc, objv); break;
			case Cmd_Toggle:			execute(cmdToggle, false, objc, objv); break;
			case Cmd_Toplevel:		execute(cmdToplevel, false, objc, objv); break;
			case Cmd_Undock:			execute(cmdUndock, false, objc, objv); break;
			case Cmd_Uid:				execute(cmdUid, false, objc, objv); break;
			case Cmd_Visible:			execute(cmdVisible, false, objc, objv); break;

			case Cmd_Capture:			cmdCapture(objc, objv); break;
			case Cmd_Release:			cmdRelease(objc, objv); break;

			case Cmd_NULL:				break; // never reached
		}
	}
	catch (Terminated const& exc)
	{
		// no action
	}
#if 0
	catch (tcl::Exception const& exc)
	{
		if (*exc.what())
			tcl::setResult(exc.what());
		return TCL_ERROR;
	}
#endif

	return TCL_OK;
}


void
tk::twm_init(Tcl_Interp* ti)
{
	Tcl_PkgProvide(ti, "tktwm", "1.0");
	tcl::createCommand(ti, "::scidb::tk::twm", cmdTwm);
}

// vi:set ts=3 sw=3:
