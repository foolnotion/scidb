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
// Copyright: (C) 2010-2018 Gregor Cramer
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
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>

#undef None // defined inside tk.h


static const int kDefaultGridSize = 15;
static const unsigned kDefaultAlignTimeout = 50;


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

	if (lhs.size() > rhs.size())
		return false;

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
static Tcl_Obj* m_objAttrBoth					= nullptr;
static Tcl_Obj* m_objAttrHorizontal			= nullptr;
static Tcl_Obj* m_objAttrHorz					= nullptr;
static Tcl_Obj* m_objAttrNone					= nullptr;
static Tcl_Obj* m_objAttrVert					= nullptr;
static Tcl_Obj* m_objAttrVertical			= nullptr;
static Tcl_Obj* m_objAttrX						= nullptr;
static Tcl_Obj* m_objAttrY						= nullptr;
static Tcl_Obj* m_objCmdAdjust				= nullptr;
static Tcl_Obj* m_objCmdBuild					= nullptr;
static Tcl_Obj* m_objCmdChildConfigure		= nullptr;
static Tcl_Obj* m_objCmdDeiconify			= nullptr;
static Tcl_Obj* m_objCmdDestroy				= nullptr;
static Tcl_Obj* m_objCmdFrame2				= nullptr;
static Tcl_Obj* m_objCmdFrameHdrSize		= nullptr;
static Tcl_Obj* m_objCmdFullscreen			= nullptr;
static Tcl_Obj* m_objCmdGeometry				= nullptr;
static Tcl_Obj* m_objCmdHeader				= nullptr;
static Tcl_Obj* m_objCmdNotebookHdrSize	= nullptr;
static Tcl_Obj* m_objCmdPack					= nullptr;
static Tcl_Obj* m_objCmdPaneConfigure		= nullptr;
static Tcl_Obj* m_objCmdReady					= nullptr;
static Tcl_Obj* m_objCmdResizing				= nullptr;
static Tcl_Obj* m_objCmdSashSize				= nullptr;
static Tcl_Obj* m_objCmdSelected				= nullptr;
static Tcl_Obj* m_objCmdSelect				= nullptr;
static Tcl_Obj* m_objCmdTitle					= nullptr;
static Tcl_Obj* m_objCmdUnpack				= nullptr;
static Tcl_Obj* m_objCmdWorkArea				= nullptr;
static Tcl_Obj* m_objDirsLR					= nullptr;
static Tcl_Obj* m_objDirsTB					= nullptr;
static Tcl_Obj* m_objDirsTBLREW				= nullptr;
static Tcl_Obj* m_objDirsTBLRNSEW			= nullptr;
static Tcl_Obj* m_objDirsTBLRNS				= nullptr;
static Tcl_Obj* m_objDirsTBLR					= nullptr;
static Tcl_Obj* m_objOptAttrs					= nullptr;
static Tcl_Obj* m_objOptBefore				= nullptr;
static Tcl_Obj* m_objOptExpand				= nullptr;
static Tcl_Obj* m_objOptGridSize				= nullptr;
static Tcl_Obj* m_objOptGrow					= nullptr;
static Tcl_Obj* m_objOptHeight				= nullptr;
static Tcl_Obj* m_objOptHWeight				= nullptr;
static Tcl_Obj* m_objOptMaxHeight			= nullptr;
static Tcl_Obj* m_objOptMaxSize				= nullptr;
static Tcl_Obj* m_objOptMaxWidth				= nullptr;
static Tcl_Obj* m_objOptMinHeight			= nullptr;
static Tcl_Obj* m_objOptMinSize				= nullptr;
static Tcl_Obj* m_objOptMinWidth				= nullptr;
static Tcl_Obj* m_objOptOrient				= nullptr;
static Tcl_Obj* m_objOptRecover				= nullptr;
static Tcl_Obj* m_objOptShrink				= nullptr;
static Tcl_Obj* m_objOptSnapshots			= nullptr;
static Tcl_Obj* m_objOptState					= nullptr;
static Tcl_Obj* m_objOptSticky				= nullptr;
static Tcl_Obj* m_objOptStructures			= nullptr;
static Tcl_Obj* m_objOptVWeight				= nullptr;
static Tcl_Obj* m_objOptWidth					= nullptr;
static Tcl_Obj* m_objOptX						= nullptr;
static Tcl_Obj* m_objOptY						= nullptr;
static Tcl_Obj* m_objTypeFrame				= nullptr;
static Tcl_Obj* m_objTypeMetaFrame			= nullptr;
static Tcl_Obj* m_objTypeMultiWindow		= nullptr;
static Tcl_Obj* m_objTypeNotebook			= nullptr;
static Tcl_Obj* m_objTypePanedWindow		= nullptr;
static Tcl_Obj* m_objTypePane					= nullptr;
static Tcl_Obj* m_objTypeRoot					= nullptr;


// IMPORTANT NOTE: order of Type should never change!
enum Type		{ Root, MetaFrame, Frame, Pane, PanedWindow, Notebook, MultiWindow, LAST = MultiWindow };
enum State		{ Packed, Floating, Withdrawn };
enum Sticky		{ West = 1, East = 2, North = 4, South = 8 };
enum Position	{ Center = 0, Left = West, Right = East, Top = North, Bottom = South };
enum Orient		{ Horz = Left|Right, Vert = Top|Bottom };
enum Expand		{ None = 0, X = Horz, Y = Vert, Both = X|Y };
enum Quantity	{ Actual, Min, Max };
enum Enclosure	{ Inner, Outer };
enum Mode		{ Abs, Rel, Grd };


static constexpr Orient operator~(Orient orientation) { return orientation == Horz ? Vert : Horz; }


namespace structure {

enum Type { Leaf, Horz, Vert, Multi };


class Node
{
public:

	Node(Node* parent, Tcl_Obj* uid);
	Node(Node* parent, Type type);
	~Node();

	bool isLeaf() const;
	bool isHorz() const;
	bool isVert() const;
	bool containsOneOf(tcl::List const& childs) const;

	Type type() const;

	unsigned numChilds() const;
	unsigned depth() const;
	const char* uid() const;

	Node const* child(unsigned i) const;
	Node const* parent() const;
	Node const* findBest(tcl::List const& dockable, unsigned& count, tcl::List const& visible) const;

	int findIndex(tcl::List const& leaves) const;

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

	int findDepth(tcl::List const& childs, unsigned depth) const;
	int getIndex(Node const* node) const;

	Node const* commonAncestor(Node const* node) const;
	Node const* dfs(tcl::List const& leaves, unsigned& count) const;

	void dump(unsigned level);

	Node*		m_parent;
	Type		m_type;
	Tcl_Obj*	m_uid;
	Childs	m_childs;
};


bool Node::isLeaf() const	{ return m_type == Leaf; }
bool Node::isHorz() const	{ return m_type == Horz; }
bool Node::isVert() const	{ return m_type == Vert; }

Type Node::type() const { return m_type; }

unsigned Node::numChilds() const	{ return m_childs.size(); }
const char* Node::uid() const		{ M_ASSERT(isLeaf()); return tcl::asString(m_uid); }

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


int
Node::findDepth(tcl::List const& childs, unsigned depth) const
{
	if (isLeaf())
	{
		for (unsigned i = 0; i < childs.size(); ++i)
		{
			if (tcl::equal(m_uid, childs[i]))
				return depth;
		}
	}
	else
	{
		for (unsigned i = 0; i < numChilds(); ++i)
		{
			int d = child(i)->findDepth(childs, depth + 1);

			if (d >= 0)
				return d;
		}
	}

	return -1;
}


bool
Node::containsOneOf(tcl::List const& childs) const
{
	return findDepth(childs, 0) >= 0;
}


int
Node::findIndex(tcl::List const& leaves) const
{
	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->containsOneOf(leaves))
			return i;
	}
	return -1;
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
Node::dfs(tcl::List const& leaves, unsigned& count) const
{
	if (isLeaf())
	{
		if (tcl::containsElement(leaves, m_uid))
		{
			count += 1;
			return this;
		}
	}
	else
	{
		unsigned countNodes = 0;

		for (unsigned i = 0; i < numChilds(); ++i)
		{
			if (Node const* node = child(i)->dfs(leaves, count))
			{
				if (count == leaves.size())
					return countNodes ? this : node;

				countNodes += 1;
			}
		}

		if (countNodes)
			return this;
	}
	return nullptr;
}


int
Node::getIndex(Node const* node) const
{
	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i) == node)
			return i;
	}
	return -1;
}


Node const*
Node::findBest(tcl::List const& dockable, unsigned& count, tcl::List const& visible) const
{
	Node const* node = dfs(dockable, count);

	if (node)
	{
		for ( ; node->m_parent; node = node->m_parent)
		{
			unsigned i = node->m_parent->getIndex(node);
			M_ASSERT(int(i) != -1);

			for (unsigned k = i + 1; k < node->m_parent->numChilds(); ++k)
			{
				if (node->m_parent->child(k)->containsOneOf(visible))
					return node->m_parent->child(k);
			}

			for (int k = i - 1; k >= 0; --k)
			{
				if (node->m_parent->child(k)->containsOneOf(visible))
					return node->m_parent->child(k);
			}
		}
	}

	return node;
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

__attribute__((unused))
void
Node::dump()
{
	printf("================================================\n");
	dump(0);
	printf("\n");
}


__attribute__((unused))
void
Node::dump(unsigned level)
{
	if (level > 0)
		printf(" ");

	if (isLeaf())
	{
		printf("%s", uid());
	}
	else
	{
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


struct Terminated {};


struct Coord
{
	Coord() :x(0), y(0) {}

	template <Orient D> int value() const;

	void zero() { x = y = 0; }

	int x;
	int y;
};

template <> int Coord::value<Horz>() const { return x; }
template <> int Coord::value<Vert>() const { return y; }


struct Size
{
	Size() :width(0), height(0) {}
	Size(int w, int h) :width(w), height(h) {}

	int width;
	int height;

	template <Orient D> int dimen() const;
	int get(Orient orientation) const;

	int area() const { return width*height; }

	void zero() { width = height = 0; }
	template <Orient D> void set(int value);
};

template <> int Size::dimen<Horz>() const { return width; }
template <> int Size::dimen<Vert>() const { return height; }

inline int Size::get(Orient orientation) const { return orientation == Horz ? width : height; }

template <> void Size::set<Horz>(int value) { width = value; }
template <> void Size::set<Vert>(int value) { height = value; }

static bool operator==(Size const& lhs, Size const& rhs)
{ return lhs.width == rhs.width && lhs.height == rhs.height; }


struct Dimen
{
	Dimen();
	Dimen(int width, int height);

	template <Orient D> bool reliable() const;
	template <Orient D> Mode mode() const;
	template <Orient D,Mode M = Abs> int dimen() const;
	template <Orient D> int computeRelativeSize(int size) const;
	template <Orient D> int computePercentage(int size) const;

	void zero() { abs.zero(); rel.zero(); grd.zero(); }
	template <Orient D> void setup(int value, Mode mode = Abs);
	template <Orient D> void set(int value, Mode mode = Abs);
	template <Orient D> void setReliable();

	Size abs;
	Size rel;
	Size grd;
	Mode m[2];
	bool r[2];
};

Dimen::Dimen() { m[0] = m[1] = Abs; r[0] = r[1] = false; }
Dimen::Dimen(int width, int height) :abs(width, height) { m[0] = m[1] = Abs; r[0] = r[1] = false; }

template <> int Dimen::dimen<Horz,Abs>() const { return abs.dimen<Horz>(); }
template <> int Dimen::dimen<Vert,Abs>() const { return abs.dimen<Vert>(); }
template <> int Dimen::dimen<Horz,Rel>() const { return rel.dimen<Horz>(); }
template <> int Dimen::dimen<Vert,Rel>() const { return rel.dimen<Vert>(); }
template <> int Dimen::dimen<Horz,Grd>() const { return grd.dimen<Horz>(); }
template <> int Dimen::dimen<Vert,Grd>() const { return grd.dimen<Vert>(); }

template <> bool Dimen::reliable<Horz>() const { return r[0]; }
template <> bool Dimen::reliable<Vert>() const { return r[1]; }

template <> Mode Dimen::mode<Horz>() const { return m[0]; }
template <> Mode Dimen::mode<Vert>() const { return m[1]; }

template <> void Dimen::setReliable<Horz>() { r[0] = true; }
template <> void Dimen::setReliable<Vert>() { r[1] = true; }

static bool operator==(Dimen const& lhs, Dimen const& rhs)
{ return lhs.abs == rhs.abs && lhs.rel == rhs.rel && lhs.grd == rhs.grd; } // ignore mode


template <Orient D>
int
Dimen::computeRelativeSize(int size) const
{
	M_ASSERT(rel.dimen<D>() > 0);
	return int((double(mstl::max(size, 0))*double(rel.dimen<D>()))/10000.0 + 0.5);
}


template <Orient D>
int
Dimen::computePercentage(int size) const
{
	return size ? int(((double(abs.dimen<D>())*10000.0)/double(size)) + 0.5) : rel.dimen<D>();
}


template <Orient D>
void
Dimen::set(int value, Mode mode)
{
	if (mode == Abs)
		abs.set<D>(value);
	else if (mode == Grd)
		grd.set<D>(value);
	else
		rel.set<D>(value);
}


template <Orient D>
void
Dimen::setup(int value, Mode mode)
{
	if ((this->m[D == Horz ? 0 : 1] = mode) == Abs)
		abs.set<D>(value);
	else if (mode == Grd)
		grd.set<D>(value);
	else
		rel.set<D>(value);
}


typedef mstl::map<mstl::string,Size> SizeMap;

struct Snapshot
{
	Size		size;
	SizeMap	sizeMap;
};


struct Quants
{
	Dimen min;
	Dimen max;
	Dimen actual;

	Quants() {}
	Quants(
		int width,    int height,
		int minWidth, int minHeight,
		int maxWidth, int maxHeight);

	template <Orient D,Quantity Q = Actual> bool reliable() const;
	template <Orient D,Quantity Q = Actual> Mode mode() const;
	template <Orient D,Quantity Q = Actual,Mode M = Abs> int dimen() const;

	template <Orient D,Quantity Q = Actual> int computeRelativeSize(int size) const;
	template <Orient D,Quantity Q = Actual> int computePercentage(int size) const;

	template <Orient D,Quantity Q = Actual,Mode M = Abs> void setReliable();
	template <Orient D,Quantity Q = Actual,Mode M = Abs> void set(int size);
	template <Orient D,Quantity Q = Actual> void setup(int size);
	void setActual(int width, int height);
	void zero();
};

Quants::Quants(
	int width,     int height,
	int minWidth,  int minHeight,
	int maxWidth,  int maxHeight)
	:min(minWidth, minHeight)
	,max(maxWidth, maxHeight)
	,actual(width, height)
{
}

template <> bool Quants::reliable<Horz,Actual>() const	{ return actual.reliable<Horz>(); }
template <> bool Quants::reliable<Vert,Actual>() const	{ return actual.reliable<Vert>(); }
template <> bool Quants::reliable<Horz,Min>() const		{ return min.reliable<Horz>(); }
template <> bool Quants::reliable<Vert,Min>() const		{ return min.reliable<Vert>(); }
template <> bool Quants::reliable<Horz,Max>() const		{ return max.reliable<Horz>(); }
template <> bool Quants::reliable<Vert,Max>() const		{ return max.reliable<Vert>(); }

template <> Mode Quants::mode<Horz,Actual>() const			{ return actual.mode<Horz>(); }
template <> Mode Quants::mode<Vert,Actual>() const			{ return actual.mode<Vert>(); }
template <> Mode Quants::mode<Horz,Min>() const				{ return min.mode<Horz>(); }
template <> Mode Quants::mode<Vert,Min>() const				{ return min.mode<Vert>(); }
template <> Mode Quants::mode<Horz,Max>() const				{ return max.mode<Horz>(); }
template <> Mode Quants::mode<Vert,Max>() const				{ return max.mode<Vert>(); }

template <> int Quants::dimen<Horz,Actual,Abs>() const	{ return actual.abs.dimen<Horz>(); }
template <> int Quants::dimen<Vert,Actual,Abs>() const	{ return actual.abs.dimen<Vert>(); }
template <> int Quants::dimen<Horz,Actual,Rel>() const	{ return actual.rel.dimen<Horz>(); }
template <> int Quants::dimen<Vert,Actual,Rel>() const	{ return actual.rel.dimen<Vert>(); }
template <> int Quants::dimen<Horz,Actual,Grd>() const	{ return actual.grd.dimen<Horz>(); }
template <> int Quants::dimen<Vert,Actual,Grd>() const	{ return actual.grd.dimen<Vert>(); }
template <> int Quants::dimen<Horz,Min,Abs>() const		{ return min.abs.dimen<Horz>(); }
template <> int Quants::dimen<Vert,Min,Abs>() const		{ return min.abs.dimen<Vert>(); }
template <> int Quants::dimen<Horz,Min,Rel>() const		{ return min.rel.dimen<Horz>(); }
template <> int Quants::dimen<Vert,Min,Rel>() const		{ return min.rel.dimen<Vert>(); }
template <> int Quants::dimen<Horz,Min,Grd>() const		{ return min.grd.dimen<Horz>(); }
template <> int Quants::dimen<Vert,Min,Grd>() const		{ return min.grd.dimen<Vert>(); }
template <> int Quants::dimen<Horz,Max,Abs>() const		{ return max.abs.dimen<Horz>(); }
template <> int Quants::dimen<Vert,Max,Abs>() const		{ return max.abs.dimen<Vert>(); }
template <> int Quants::dimen<Horz,Max,Rel>() const		{ return max.rel.dimen<Horz>(); }
template <> int Quants::dimen<Vert,Max,Rel>() const		{ return max.rel.dimen<Vert>(); }
template <> int Quants::dimen<Horz,Max,Grd>() const		{ return max.grd.dimen<Horz>(); }
template <> int Quants::dimen<Vert,Max,Grd>() const		{ return max.grd.dimen<Vert>(); }

template <> void Quants::set<Horz,Actual,Abs>(int size)	{ actual.set<Horz>(size, Abs); }
template <> void Quants::set<Vert,Actual,Abs>(int size)	{ actual.set<Vert>(size, Abs); }
template <> void Quants::set<Horz,Actual,Rel>(int size)	{ actual.set<Horz>(size, Rel); }
template <> void Quants::set<Vert,Actual,Rel>(int size)	{ actual.set<Vert>(size, Rel); }
template <> void Quants::set<Horz,Actual,Grd>(int size)	{ actual.set<Horz>(size, Grd); }
template <> void Quants::set<Vert,Actual,Grd>(int size)	{ actual.set<Vert>(size, Grd); }
template <> void Quants::set<Horz,Min,Abs>(int size)		{ min.set<Horz>(size, Abs); }
template <> void Quants::set<Vert,Min,Abs>(int size)		{ min.set<Vert>(size, Abs); }
template <> void Quants::set<Horz,Min,Rel>(int size)		{ min.set<Horz>(size, Rel); }
template <> void Quants::set<Vert,Min,Rel>(int size)		{ min.set<Vert>(size, Rel); }
template <> void Quants::set<Horz,Min,Grd>(int size)		{ min.set<Horz>(size, Grd); }
template <> void Quants::set<Vert,Min,Grd>(int size)		{ min.set<Vert>(size, Grd); }
template <> void Quants::set<Horz,Max,Abs>(int size)		{ max.set<Horz>(size, Abs); }
template <> void Quants::set<Vert,Max,Abs>(int size)		{ max.set<Vert>(size, Abs); }
template <> void Quants::set<Horz,Max,Rel>(int size)		{ max.set<Horz>(size, Rel); }
template <> void Quants::set<Vert,Max,Rel>(int size)		{ max.set<Vert>(size, Rel); }
template <> void Quants::set<Horz,Max,Grd>(int size)		{ max.set<Horz>(size, Grd); }
template <> void Quants::set<Vert,Max,Grd>(int size)		{ max.set<Vert>(size, Grd); }

template <> void Quants::setup<Horz,Actual>(int size)		{ actual.setup<Horz>(size, Abs); }
template <> void Quants::setup<Vert,Actual>(int size)		{ actual.setup<Vert>(size, Abs); }
template <> void Quants::setup<Horz,Min>(int size)			{ min.setup<Horz>(size, Abs); }
template <> void Quants::setup<Vert,Min>(int size)			{ min.setup<Vert>(size, Abs); }
template <> void Quants::setup<Horz,Max>(int size)			{ max.setup<Horz>(size, Abs); }
template <> void Quants::setup<Vert,Max>(int size)			{ max.setup<Vert>(size, Abs); }

template <> void Quants::setReliable<Horz,Actual>()		{ actual.setReliable<Horz>(); }
template <> void Quants::setReliable<Vert,Actual>()		{ actual.setReliable<Vert>(); }
template <> void Quants::setReliable<Horz,Min>()			{ min.setReliable<Horz>(); }
template <> void Quants::setReliable<Vert,Min>()			{ min.setReliable<Vert>(); }
template <> void Quants::setReliable<Horz,Max>()			{ max.setReliable<Horz>(); }
template <> void Quants::setReliable<Vert,Max>()			{ max.setReliable<Vert>(); }

static bool operator==(Quants const& lhs, Quants const& rhs)
{ return lhs.actual == rhs.actual && lhs.min == rhs.min && lhs.max == rhs.max; }

static bool operator!=(Quants const& lhs, Quants const& rhs)
{ return !operator==(lhs, rhs); }

template <> int Quants::computeRelativeSize<Horz,Min>(int size) const
{ return min.computeRelativeSize<Horz>(size); }

template <> int Quants::computeRelativeSize<Vert,Min>(int size) const
{ return min.computeRelativeSize<Vert>(size); }

template <> int Quants::computeRelativeSize<Horz,Max>(int size) const
{ return max.computeRelativeSize<Horz>(size); }

template <> int Quants::computeRelativeSize<Vert,Max>(int size) const
{ return max.computeRelativeSize<Horz>(size); }

template <> int Quants::computeRelativeSize<Horz,Actual>(int size) const
{ return actual.computeRelativeSize<Horz>(size); }

template <> int Quants::computeRelativeSize<Vert,Actual>(int size) const
{ return actual.computeRelativeSize<Vert>(size); }

template <> int Quants::computePercentage<Horz,Min>(int size) const
{ return min.computePercentage<Horz>(size); }

template <> int Quants::computePercentage<Vert,Min>(int size) const
{ return min.computePercentage<Vert>(size); }

template <> int Quants::computePercentage<Horz,Max>(int size) const
{ return max.computePercentage<Horz>(size); }

template <> int Quants::computePercentage<Vert,Max>(int size) const
{ return max.computePercentage<Horz>(size); }

template <> int Quants::computePercentage<Horz,Actual>(int size) const
{ return actual.computePercentage<Horz>(size); }

template <> int Quants::computePercentage<Vert,Actual>(int size) const
{ return actual.computePercentage<Vert>(size); }


void
Quants::setActual(int width, int height)
{
	if (min.abs.width)
		width = mstl::max(width, min.abs.width);
	if (max.abs.width)
		width = mstl::min(width, min.abs.width);
	if (min.abs.height)
		height = mstl::max(height, min.abs.height);
	if (max.abs.height)
		height = mstl::min(height, min.abs.height);

	actual.abs.width = width;
	actual.abs.height = height;
}


void
Quants::zero()
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


template <Orient D>
static Mode
parseDimension(Tcl_Obj* obj, Dimen& dim)
{
	Mode mode;
	char* e = nullptr;
	int value = ::strtol(tcl::asString(obj), &e, 10);
	int fract = 0;

	if (e && *e == '.')
		fract = ::strtol(e + 1, &e, 10);

	if (e && *e == '%')
	{
		dim.set<D>(0, Abs);
		dim.set<D>(0, Grd);
		dim.setup<D>(value*100 + fract, Rel);
		mode = Rel;
		e += 1;
	}
	else if (e && *e == 'u')
	{
		dim.setup<D>(0, Abs);
		dim.setup<D>(0, Rel);
		dim.setup<D>(value, Grd);
		mode = Grd;
		e += 1;
	}
	else
	{
		dim.set<D>(0, Grd);
		dim.set<D>(0, Rel);
		dim.setup<D>(value, Abs);
		mode = Abs;
	}

	if (!e || *e != '\0')
		M_THROW(tcl::Exception("invalid dimension '%s'", tcl::asString(obj)));
	
	return mode;
}


static void
parseExpandOption(Tcl_Obj* obj, Coord& weight)
{
	M_ASSERT(obj);

	weight.zero();

	if (tcl::equal(obj, m_objAttrBoth))
		weight.x = weight.y = 1;
	else if (tcl::equal(obj, m_objAttrX))
		weight.x = 1;
	else if (tcl::equal(obj, m_objAttrY))
		weight.y = 1;
	else if (!tcl::equal(obj, m_objAttrNone))
		M_THROW(tcl::Exception("invalid expand option '%s'", tcl::asString(obj)));
}


static int
parseResizeOption(Tcl_Obj* obj)
{
	M_ASSERT(obj);

	if (tcl::equal(obj, m_objAttrBoth))	return X | Y;
	if (tcl::equal(obj, m_objAttrX))		return X;
	if (tcl::equal(obj, m_objAttrY))		return Y;
	if (tcl::equal(obj, m_objAttrNone))	return 0;

	M_THROW(tcl::Exception("invalid resize option '%s'", tcl::asString(obj)));
}


static int
parseWeightOption(Tcl_Obj* obj)
{
	M_ASSERT(obj);

	if (!tcl::isUnsigned(obj))
		M_THROW(tcl::Exception("invalid weight option '%s'", tcl::asString(obj)));
	
	return tcl::asUnsigned(obj);
}


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

	if (tcl::equal(obj, m_objAttrHorz) || tcl::equal(obj, m_objAttrHorizontal))	return Horz;
	if (tcl::equal(obj, m_objAttrVert) || tcl::equal(obj, m_objAttrVertical))		return Vert;

	M_THROW(tcl::Exception("invalid orientation '%s'", tcl::asString(obj)));
}


static Type
parseTypeOption(Tcl_Obj* obj)
{
	M_ASSERT(obj);

	if (tcl::equal(obj, m_objTypeRoot))				return Root;
	if (tcl::equal(obj, m_objTypePane))				return Pane;
	if (tcl::equal(obj, m_objTypeFrame))			return Frame;
	if (tcl::equal(obj, m_objTypeMetaFrame))		return MetaFrame;
	if (tcl::equal(obj, m_objTypeMultiWindow))	return MultiWindow;
	if (tcl::equal(obj, m_objTypeNotebook))		return Notebook;
	if (tcl::equal(obj, m_objTypePanedWindow))	return PanedWindow;

	M_THROW(tcl::Exception("unknown type '%s'", tcl::asString(obj)));
}


static char const*
makeTypeID(Type type)
{
	switch (type)
	{
		case Root:			return tcl::asString(m_objTypeRoot);
		case Pane:			return tcl::asString(m_objTypePane);
		case Frame:			return tcl::asString(m_objTypeFrame);
		case MetaFrame:	return tcl::asString(m_objTypeMetaFrame);
		case MultiWindow:	return tcl::asString(m_objTypeMultiWindow);
		case Notebook:		return tcl::asString(m_objTypeNotebook);
		case PanedWindow:	return tcl::asString(m_objTypePanedWindow);
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
	return tcl::asString(orientation & Horz ? m_objAttrHorizontal : m_objAttrVertical);
}


static char const*
makeResizeOptionValue(int expand)
{
	if ((expand & (X|Y)) == (X|Y)) return tcl::asString(m_objAttrBoth);
	if (expand & X) return tcl::asString(m_objAttrX);
	if (expand & Y) return tcl::asString(m_objAttrY);
	return tcl::asString(m_objAttrNone);
}


class Node
{
public:

	typedef mstl::vector<mstl::string> AttrSet;
	typedef mstl::vector<Quants*> QuantList;
	typedef mstl::map<mstl::string,Node*> LeafMap;

	~Node();

	bool isRoot() const;
	bool isContainer() const;
	bool isPanedWindow() const;
	bool isPanedWindow(Orient orientation) const;
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
	bool isVisible() const;
	bool isFloating() const;
	bool isToplevel() const;
	bool isPreserved() const;
	bool isTransient() const;
	bool isResized() const;
	bool isLocked() const;
	bool isReady() const;
	bool isHorz() const;
	bool isVert() const;
	template <Orient D> bool hasOrientation() const;
	bool hasPackedChilds() const;
	bool hasAncestor(Node const* node) const;
	bool contains(Node const* node) const;
	bool exists() const;
	bool amalgamate() const;
	bool isAlreadyDead() const;
	bool canAmalgamate() const;
	bool needsUpdate() const;

	template <Orient D> bool grow() const;
	template <Orient D> bool shrink() const;
	template <Orient D> bool orientation() const;
	template <Orient D> bool compare(int lhsPerc, int rhsPerc) const;

	unsigned numChilds() const;
	unsigned depth() const;
	unsigned countStableChilds() const;
	int sashSize() const;
	int frameHeaderSize() const;
	int notebookHeaderSize() const;
	Tk_Window tkwin() const;
	char const* uid() const;
	char const* path() const;
	char const* id() const; // for debugging
	Tcl_Obj* uidObj() const;
	Tcl_Obj* pathObj() const;
	Tcl_Obj* typeObj() const;
	int expand() const;
	template <Orient D> int weight() const;
	int sticky() const;
	int x() const;
	int y() const;
	Quants const& quants() const;
	template <Enclosure Enc> int width() const;
	template <Enclosure Enc> int height() const;
	template <Enclosure Enc> int minWidth() const;
	template <Enclosure Enc> int minHeight() const;
	template <Enclosure Enc> int maxWidth() const;
	template <Enclosure Enc> int maxHeight() const;
	template <Enclosure Enc,Orient D,Quantity Q = Actual,Mode M = Abs> int dimen() const;
	template <Enclosure Enc,Orient D> int actualSize() const;
	template <Enclosure Enc,Orient D> int maxSize() const;
	template <Enclosure Enc,Orient D> int minSize() const;
	template <Orient D,Quantity Q = Actual,Mode M = Abs> int value() const;
	Node* parent() const;
	Node* toplevel() const;
	Node* selected() const;
	Node* clone(LeafMap const& leaves) __m_warn_unused;
	Node const* stableChild() const;

	tcl::List collectToplevels() const;
	tcl::List collectFrames() const;
	tcl::List collectPanes() const;
	tcl::List collectPanesRecursively() const;
	tcl::List collectHeaderFramesRecursively() const;
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
	void resize(Quants const& maxHeight, bool perform = true);
	void setState(State state);
	void updateDimen(int x, int y, int width, int height);
	void perform(Node* toplevel = nullptr);
	void adjust();
	void setupDimensions(Quants const& dimen);
	void show();
	void ready();

	Node* findPath(char const* path) const;
	Node* findUid(char const* uid) const;
	Node* getJustCreated() const;
	Node const* leftNeighbor(Node const* neighbor) const;
	Node const* rightNeighbor(Node const* neighbor) const;
	Node const* findLeader() const;
	Node const* findAmalgamated() const;

	void setAttr(char const* attribute, Tcl_Obj* value, bool ignoreMeta = false);
	Tcl_Obj* getAttr(char const* attribute, bool ignoreMeta = false) const;

	void load(Tcl_Obj* list);
	void load(Tcl_Obj* list, LeafMap const* leaves, Node const* sRoot);
	void saveLeaves(LeafMap& leaves, tcl::Array const& preserved);
	void create();
	void destroy();
	void pack();
	void reparentChildsRecursively(Tk_Window topLevel);
	void select();
	void setSelected();
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
	void setUid(Tcl_Obj* uidObj);
	void setPreserved(bool flag);
	void setConfigured();
	void adjustDimensions();
	void computeDimensionsRecursively();
	void adjustDimensionsRecursively();
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
	static Node* makeRoot(Tcl_Obj* path, unsigned alignTimeout = ::kDefaultAlignTimeout) __m_warn_unused;

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
		F_Adjust		= 1 << 8,
		F_Unframe	= 1 << 9,
		F_Build		= 1 << 10,
		F_Header		= 1 << 11,
		F_Docked		= 1 << 12,
		F_Undocked	= 1 << 13,
		F_Deiconify	= 1 << 14,
	};

	Node(Tcl_Obj* path, Node const* setup = nullptr);
	Node(Node& parent, Type type, Tcl_Obj* uid = nullptr);
	Node(Node const& node);

	bool finished() const;
	bool containsDeadWindows(Node const* exceptThisOne = nullptr) const;
	bool fits(Size size, Position position) const;
	template <Orient D,Quantity Q> bool canComputeDimensions() const;
	bool isLastChild() const;
	bool containsGrid() const;

	Childs::const_iterator begin() const;
	Childs::const_iterator end() const;

	Childs::iterator find(Node const* node);
	Childs::const_iterator find(Node const* node) const;
	Node const* findAfter(bool onlyPackedChild = false) const;
	Node const* findRelation(structure::Node const* parent, tcl::List const& childs) const;
	Position defaultPosition() const;
	void collectLeaves(mstl::vector<mstl::string>& result) const;
	void collectToplevels(tcl::List& result) const;
	void collectFramesRecursively(tcl::List& result) const;
	void collectPanesRecursively(tcl::List& result) const;
	void collectHeaderFramesRecursively(tcl::List& result) const;
	void collectLeavesRecursively(tcl::List& result) const;
	void collectVisibleRecursively(tcl::List& result) const;
	void inspect(AttrSet const& exportList, tcl::DString& str, int horzGap, int vertGap) const;
	void inspectAttrs(AttrSet const& exportList, tcl::DString& str) const;
	template <Orient D,Quantity Q> void inspectDimen(Tcl_Obj* attr, tcl::DString& str, int gapSize) const;
	void inspect(tcl::DString& str, Structures const& structures) const;
	static void inspect(tcl::DString& str, SnapshotMap const& snapshots);
	void removeAttr(char const* attribute);

	template <Orient D> int computeGapRecursively() const;
	template <Orient D> int computeGap() const;

	Tcl_Obj* makeOptions(Flag flags, Node const* before = nullptr) const __m_warn_unused;
	template <Orient D,Quantity Q> Tcl_Obj* makeDimObj(int gapSize) const __m_warn_unused;
	void parseOptions(Tcl_Obj* opts);
	void parseSnapshot(Tcl_Obj* obj);
	void parseAttributes(Tcl_Obj* obj);
	void parseStructures(Tcl_Obj* obj);

	void load(Tcl_Obj* list, LeafMap const* leaves);
	void finishLoad(LeafMap const* leaves, Node const* sRoot, bool deleteTempStruct);
	bool makeStructure();
	structure::Node* makeStructure(structure::Node* parent) const __m_warn_unused;
	void releaseStructures();

	void move(Node* node, Node const* before = nullptr);
	void add(Node* node, Node const* before = nullptr);

	template <Orient D> void adjustDimensionsRecursively(int size, int gapSize, bool apply);
	template <Orient D,Quantity Q> void computeDimensionsRecursively(int size, int gapSize);
	template <Orient D,Quantity Q> void resolveGridUnits();
	void resolveGridUnitsRecursively();
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
	template <Orient D,Quantity Q = Actual> int gridSize() const;

	template <Orient D> void adjustRoot();
	template <Orient D> void adjustToplevel();
	template <Orient D> void doAdjustment(int size);
	template <Orient D> void resizeFrame(int reqSize);
	template <Orient D> void expandPanes(int computedSize, int space);
	template <Orient D> void shrinkPanes(int computedSize, int space);
	template <Orient D> void fitDimensions(int size);

	template <Orient D> int doExpandPanes(int space, bool expandable, int stage) __m_warn_unused;
	template <Orient D> int doShrinkPanes(int space, bool expandable, int stage) __m_warn_unused;
	template <Orient D> int computeExpand(int stage) const __m_warn_unused;
	template <Orient D> int computeShrink(int stage) const __m_warn_unused;
	template <Orient D> int computeUnderflow() const;
	template <Orient D> int applyGrid(int size, int remaining) const;

	template <Orient D> bool isExpandable() const;

	Node* insertNotebook(Node* child, Type type, Node const* beforeChild = nullptr);
	Node* insertPanedWindow(Position position, Node* child, Node const* beforeChild = nullptr);
	Node* clone(LeafMap const& leaves, Node* parent) const __m_warn_unused;
	Node* clone(Node* parent, Tcl_Obj* uid) const __m_warn_unused;
	Node* findDockingNode(Position& position, Node const*& before, Node const* setup);
	Node* dock(Node* node, Position position, Node const* before, bool newParent);
	Node* findBestPlace(Quants const& quant, int priority, int& bestDistance1, int& bestDistance2);
	Node* findBest(tcl::List const& childs);
	unsigned findBest(tcl::List const& childs, Node*& bestNode, unsigned& bestCount);
	Node* findHeaderWindow();

	void insertNode(Node* node, Node const* before = nullptr);
	void remove(Childs::iterator pos);
	void updateHeadersRecursively();
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
	void performDimensions(int horzGap, int vertGap);
	void performFinalizeCreate();
	void performFullscreen();
	void performBuild();
	void performReady();
	void performPack();
	void performUnpack(Node* parent);
	void performChildConfigure();
	void performPaneConfigure();
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
	void performDimensionsRecursively();
	void performDimensionsRecursively(int horzGap, int vertGap);
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
	void performSelectRecursively(bool needed = false);
	void performQuerySelected() const;
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
	Quants		m_dimen;
	Quants		m_actual;
	Coord			m_coord;
	Coord			m_weight;
	Size			m_workArea;
	Size			m_grid;
	int			m_orientation;
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
	QuantList	m_afterPerform;
	Node*			m_justCreated;
	unsigned		m_flags;
	unsigned		m_alignTimeout;
	SnapshotMap	m_snapshotMap;
	Structures	m_structures;
	bool			m_amalgamate;
	bool			m_fullscreen;
	bool			m_initialStructure;
	bool			m_isAmalgamated;
	bool			m_wasAmalgamatable;
	bool			m_isTransient;
	bool			m_isClone;
	bool			m_isDeleted;
	bool			m_isDestroyed;
	bool			m_isResized;
	bool			m_isLocked;
	bool			m_isReady;
	bool			m_isPreserved;
	bool			m_temporary;

	Tcl_TimerToken m_timerToken;
	mutable bool m_dumpFlag;

	typedef mstl::map<mstl::string,Base*> Lookup;
	static Lookup m_lookup;
};

Node::Lookup Node::m_lookup;

} // namespace


static void
Perform(ClientData clientData)
{
	Node* root = static_cast<Node*>(clientData);

	if (root->exists())
		root->perform();
}


static void
Adjust(ClientData clientData)
{
	Node* root = static_cast<Node*>(clientData);

	if (root->exists())
		root->adjust();
}


static void
WindowEventProc(ClientData clientData, XEvent* event)
{
	switch (event->type)
	{
		case ConfigureNotify:
		{
			static_cast<Node*>(clientData)->updateDimen(
				event->xconfigure.x, event->xconfigure.y,
				event->xconfigure.width, event->xconfigure.height);
			break;
		}

		case DestroyNotify:	static_cast<Node*>(clientData)->destroyed(false); break;
		case UnmapNotify:		static_cast<Node*>(clientData)->destroyed(true); break;
		case MapNotify:		static_cast<Node*>(clientData)->setSelected(); break;
	}
}


namespace {

Node const* Node::child(unsigned i) const { return m_childs[i]; }
Node* Node::child(unsigned i)					{ return m_childs[i]; }
Node const* Node::child() const				{ return const_cast<Node*>(this)->child(); }

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
bool Node::isPacked() const						{ return m_state == Packed; }
bool Node::isWithdrawn() const					{ return m_state == Withdrawn; }
bool Node::isFloating() const						{ return m_state == Floating; }
bool Node::isToplevel() const						{ return m_parent == nullptr; }
bool Node::isPreserved() const					{ return m_isPreserved; }
bool Node::isTransient() const					{ return m_isTransient; }
bool Node::isResized() const						{ return m_isResized; }
bool Node::isLocked() const						{ return m_root->m_isLocked; }
bool Node::isReady() const							{ return m_root->m_isReady; }
bool Node::isHorz() const							{ return m_orientation == Horz; }
bool Node::isVert() const							{ return m_orientation == Vert; }
bool Node::amalgamate() const						{ return m_amalgamate; }
bool Node::needsUpdate() const					{ return m_root->isReady() && testFlags(unsigned(-1)); }

template <> bool Node::hasOrientation<Horz>() const { return isHorz(); }
template <> bool Node::hasOrientation<Vert>() const { return isVert(); }

int Node::sticky() const { return m_sticky; }

Node* Node::parent() const { return isRoot() ? nullptr : (m_parent ? m_parent : m_root); }

Childs::const_iterator Node::begin() const	{ return m_childs.begin(); }
Childs::const_iterator Node::end() const		{ return m_childs.end(); }

bool Node::contains(Node const* node) const	{ return find(node) != end(); }

template <Orient D> bool Node::isExpandable() const { return bool(expand() & D); }

template <Orient D> bool Node::grow() const			{ return m_grow & D; }
template <Orient D> bool Node::shrink() const		{ return m_shrink & D; }
template <Orient D> bool Node::orientation() const	{ return m_orientation & D; }

char const* Node::uid() const			{ return tcl::asString(m_uid); }
char const* Node::path() const		{ return tcl::asString(m_path); }
char const* Node::id() const			{ return m_uid ? uid() : (m_path ? path() : "null"); }

Tcl_Obj* Node::uidObj() const			{ return m_uid; }
Tcl_Obj* Node::pathObj() const		{ return m_path; }

int Node::sashSize() const				{ return performQuerySashSize(); }

void Node::remove(Node* node)			{ remove(find(node)); }
void Node::setState(State state)		{ m_state = state; }
void Node::load(Tcl_Obj* list)		{ load(list, nullptr, nullptr); }
void Node::setPreserved(bool flag)	{ m_isPreserved = flag; }

void Node::addFlag(unsigned flag)	{ m_flags |= flag; }
void Node::delFlag(unsigned flag)	{ m_flags &= ~flag; }

bool Node::testFlags(unsigned flag) const { return m_flags & flag; }

Quants const& Node::quants() const { return m_dimen; }

void Node::makeSnapshotKey(mstl::string& key) const { makeSnapshot(key, nullptr); }


int
Node::frameHeaderSize() const
{
	return m_headerObj && exists() ? performQueryFrameHeaderSize() : 0;
}


int
Node::notebookHeaderSize() const
{
	return m_headerObj && exists() ? performQueryNotebookHeaderSize() : 0;
}


bool
Node::isPanedWindow(Orient orientation) const
{
	return m_type == PanedWindow && m_orientation == orientation;
}


bool
Node::isLastChild() const
{
	M_ASSERT(m_parent);
	M_ASSERT(m_parent->numChilds() > 0);

	return m_parent->m_childs[m_parent->numChilds() - 1] == this;
}


bool
Node::containsGrid() const
{
	if (gridSize<Horz>() || gridSize<Vert>())
		return true;
	
	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isPacked() && child(i)->containsGrid())
			return true;
	}

	return false;
}


void
Node::ready()
{
	m_isReady = true;
	performReady();
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


bool
Node::hasPackedChilds() const
{
	return child();
}


bool
Node::containsDeadWindows(Node const* exceptThisOne) const
{
	for (unsigned i = 0; i < numChilds(); ++i)
	{
		Node const* node = child(i);

		if ((!exceptThisOne || node != exceptThisOne) && node->isAlreadyDead())
			return true;
	}
	return false;
}


bool
Node::finished() const
{
	return	m_dimen.reliable<Horz,Actual>()
			&& m_dimen.reliable<Vert,Actual>()
			&& m_dimen.reliable<Horz,Min>()
			&& m_dimen.reliable<Vert,Min>()
			&& m_dimen.reliable<Horz,Max>()
			&& m_dimen.reliable<Vert,Max>();
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


unsigned
Node::countStableChilds() const
{
	unsigned count = 0;

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (!child(i)->m_isTransient)
			count += 1;
	}

	return count;
}


Node const*
Node::stableChild() const
{
	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (!child(i)->m_isTransient)
			return child(i);
	}

	return nullptr;
}


template <Orient D,Quantity Q>
int
Node::gridSize() const
{
	return m_dimen.mode<D,Q>() != Grd || m_grid.dimen<D>() ? m_grid.dimen<D>() : ::kDefaultGridSize;
}


template <Orient D>
int
Node::computeGapRecursively() const
{
	int size = 0;

	switch (m_type)
	{
		case Root:
			return 0;

		case Notebook:
		case MultiWindow:
		case PanedWindow:
			size = computeGap<D>();
			break;

		case Frame:
			if (D == Vert)
				size = frameHeaderSize();
			break;

		default: break;
	}

	return size + m_parent->computeGapRecursively<D>();
}


template <Orient D>
bool
Node::compare(int lhsPerc, int rhsPerc) const
{
	M_ASSERT(isToplevel());

	if (lhsPerc == 0)
		return rhsPerc == 0;
	if (rhsPerc == 0)
		return lhsPerc == 0;

	Dimen lhs, rhs;

	lhs.setup<D>(lhsPerc, Rel);
	rhs.setup<D>(rhsPerc, Rel);

	int size			= m_root->m_workArea.dimen<D>() - computeGapRecursively<D>();
	int lhsSize		= lhs.computeRelativeSize<D>(size);
	int rhsSize		= rhs.computeRelativeSize<D>(size);
	int gridSize	= this->gridSize<D>();

	if (gridSize == 0)
		return mstl::abs(lhsSize - rhsSize) <= 1; // we have to allow one pixel difference

	lhsSize = ((lhsSize - dimen<Inner,D,Min>() + gridSize - 1)/gridSize);
	rhsSize = ((rhsSize - dimen<Inner,D,Min>() + gridSize - 1)/gridSize);

	return lhsSize == rhsSize;
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


template <Orient D>
int
Node::weight() const
{
	if (isMetaFrame())
		return child()->weight<D>();

	if (!isContainer())
		return m_weight.value<D>();

	unsigned count = 0;
	unsigned total = 0;

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isPacked())
		{
			total += child(i)->weight<D>();
			count += 1;
		}
	}

	if (hasOrientation<D>())
		return total;

	return count ? (total + count - 1)/count : 0;
}


Node*
Node::selected() const
{
	M_ASSERT(isNotebookOrMultiWindow());

	if (!m_selected)
	{
		// It may happen that we don't know yet the
		// selected frame, so we have to ask about it.
		if (exists())
			performQuerySelected();
		if (!m_selected)
			const_cast<Node*>(this)->m_selected = const_cast<Node*>(this)->child();
	}

	return m_selected;
}


bool
Node::canAmalgamate() const
{
	if (!isToplevel() && (isFrame() || isMultiWindow()))
	{
		Node const* node		= this;
		Node const* parent	= m_parent;

		while (!parent->isToplevel())
		{
			if (parent->isMetaFrame() && parent->m_parent->isMultiWindow())
			{
				return true;
			}
			else if (parent->isPanedWindow(Vert))
			{
				if (parent->child() != node)
					return false;
			}
			else if (!parent->isMultiWindow())
			{
				return false;
			}

			node = parent;
			parent = parent->m_parent;
		}
	}

	return false;
}


Node const*
Node::findAmalgamated() const
{
	for (Node const* node = this; true; node = node->child())
	{
		if (node->m_isAmalgamated)
		{
			return node;
		}
		else if (node->isFrame() || node->isPane() || node->isPanedWindow(Horz) || node->isNotebook())
		{
			return nullptr;
		}
		else if (node->isMetaFrame())
		{
			if (!node->child()->isPanedWindow(Vert))
				return nullptr;
		}
		else if (node->isMultiWindow())
		{
			if (node->child() != node->selected())
				return nullptr;
		}
	}

	return nullptr;
}


template <Orient D>
int
Node::contentSize(int size) const
{
	if (D == Vert && size > 0 && m_headerObj)
	{
		if (isNotebook())
			size = mstl::max(0, size - notebookHeaderSize());
		else if (!isMultiWindow())
			size = mstl::max(0, size - frameHeaderSize());
	}
	return size;
}


template <Orient D,Enclosure Enc>
int
Node::frameSize(int size) const
{
	if (Enc == Outer && D == Vert && size > 0 && m_headerObj)
	{
		if (isNotebook())
			size += notebookHeaderSize();
		else if (!isMultiWindow())
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

template <Enclosure Enc,Orient D,Quantity Q,Mode M>
int Node::dimen() const { return frameSize<D,Enc>(m_dimen.dimen<D,Q,M>()); }

template <Enclosure Enc,Orient D>
int Node::actualSize() const { return dimen<Enc,D>(); }

template <Orient D,Quantity Q,Mode M>
int Node::value() const { return m_dimen.dimen<D,Q,M>(); }


void
Node::setUid(Tcl_Obj* uidObj)
{
	M_ASSERT(uidObj);
	tcl::set(m_uid, uidObj);
}


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


Node*
Node::findHeaderWindow()
{
	M_ASSERT(!isToplevel());

	Node* node = m_parent;

	while (node->m_amalgamate || node->isContainer())
	{
		if (node->isToplevel())
			return this;
		node = node->parent();
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
Node::setSelected()
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

	Node* node = this;
	Node* parent = m_parent;

	for ( ; parent; node = parent, parent = parent->m_parent)
	{
		if (parent->isNotebookOrMultiWindow())
		{
			if (parent->selected() != node)
			{
				parent->addFlag(F_Select);
				node->setSelected();
			}
		}
	}
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
	,m_sticky(0)
	,m_shrink(0)
	,m_grow(0)
	,m_headerObj(nullptr)
	,m_oldHeaderObj(nullptr)
	,m_titleObj(nullptr)
	,m_oldTitleObj(nullptr)
	,m_justCreated(nullptr)
	,m_flags(0)
	,m_alignTimeout(::kDefaultAlignTimeout)
	,m_amalgamate(false)
	,m_fullscreen(false)
	,m_initialStructure(false)
	,m_isAmalgamated(false)
	,m_wasAmalgamatable(false)
	,m_isTransient(false)
	,m_isClone(false)
	,m_isDeleted(false)
	,m_isDestroyed(false)
	,m_isResized(false)
	,m_isLocked(false)
	,m_isReady(false)
	,m_isPreserved(false)
	,m_temporary(false)
	,m_timerToken(nullptr)
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
	,m_sticky(0)
	,m_shrink(0)
	,m_grow(0)
	,m_headerObj(nullptr)
	,m_oldHeaderObj(nullptr)
	,m_titleObj(nullptr)
	,m_oldTitleObj(nullptr)
	,m_justCreated(nullptr)
	,m_flags(0)
	,m_alignTimeout(::kDefaultAlignTimeout)
	,m_amalgamate(false)
	,m_fullscreen(false)
	,m_initialStructure(false)
	,m_isAmalgamated(false)
	,m_wasAmalgamatable(false)
	,m_isTransient(false)
	,m_isClone(false)
	,m_isDeleted(false)
	,m_isDestroyed(false)
	,m_isResized(false)
	,m_isLocked(false)
	,m_isReady(false)
	,m_isPreserved(false)
	,m_temporary(false)
	,m_timerToken(nullptr)
	,m_dumpFlag(false)
{
	M_ASSERT(path);

	tcl::incrRef(path);

	if (setup)
	{
		m_type = setup->m_type;
		m_orientation = setup->m_orientation;
		m_sticky = setup->m_sticky;
		m_shrink = setup->m_shrink;
		m_grow = setup->m_grow;
		m_weight = setup->m_weight;
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
	,m_weight(node.m_weight)
	,m_orientation(node.m_orientation)
	,m_sticky(node.m_sticky)
	,m_shrink(node.m_shrink)
	,m_grow(node.m_grow)
	,m_headerObj(nullptr)
	,m_oldHeaderObj(nullptr)
	,m_titleObj(nullptr)
	,m_oldTitleObj(nullptr)
	,m_justCreated(nullptr)
	,m_flags(0)
	,m_alignTimeout(::kDefaultAlignTimeout)
	,m_amalgamate(node.m_amalgamate)
	,m_fullscreen(node.m_fullscreen)
	,m_initialStructure(false)
	,m_isAmalgamated(false)
	,m_wasAmalgamatable(false)
	,m_isTransient(false)
	,m_isClone(false)
	,m_isDeleted(false)
	,m_isDestroyed(false)
	,m_isResized(false)
	,m_isLocked(false)
	,m_isReady(false)
	,m_isPreserved(false)
	,m_temporary(false)
	,m_timerToken(nullptr)
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
Node::makeRoot(Tcl_Obj* path, unsigned alignTimeout)
{
	M_ASSERT(path);

	Node* node = new Node(path);
	node->m_alignTimeout = alignTimeout;
	return node;
}


Node*
Node::getJustCreated() const
{
	M_ASSERT(isRoot());
	return m_justCreated;
}


void
Node::removeAttr(char const* attribute)
{
	AttrMap::iterator i = m_attrMap.find(attribute);
	if (i != m_attrMap.end())
		m_attrMap.erase(i);
}


void
Node::setAttr(char const* attribute, Tcl_Obj* value, bool ignoreMeta)
{
	M_ASSERT(attribute);
	M_ASSERT(value);

	if (ignoreMeta && isMetaFrame() && child()) // !child() may happen when destroying a metaframe
		return child()->setAttr(attribute, value, false);

	switch (attribute[0])
	{
		case 'a':
			if (tcl::equal(attribute, "amalgamate"))
			{
				if (tcl::isBoolean(value))
				{
					m_amalgamate = tcl::asBoolean(value);

					if (exists() && !isToplevel())
					{
						addFlag(F_Header);
						findHeaderWindow()->addFlag(F_Header);
					}

					if (!m_amalgamate)
						return removeAttr(attribute);
				}
			}
			break;

		case 'f':
			if (tcl::equal(attribute, "fullscreen"))
			{
				if (tcl::isBoolean(value))
				{
					if (!(m_fullscreen = tcl::asBoolean(value)))
						return removeAttr(attribute);
				}
			}
			break;

		case 'h':
			if (tcl::equal(attribute, "hgrid"))
			{
				if (tcl::isInt(value))
				{
					int size = tcl::asInt(value);
					m_grid.set<Horz>(mstl::max(0, size == 1 ? 0 : size));
					addFlag(F_Config);

					if (size == 0)
						return removeAttr(attribute);
				}
			}
			break;

		case 'p':
			if (tcl::equal(attribute, "priority"))
			{
				if (tcl::isInt(value))
					m_priority = tcl::asInt(value);
			}
			break;

		case 't':
			if (tcl::equal(attribute, "transient"))
			{
				if (tcl::isBoolean(value))
				{
					if (!(m_isTransient = tcl::asBoolean(value)))
						return removeAttr(attribute);
				}
			}
			break;

		case 'v':
			if (tcl::equal(attribute, "vgrid"))
			{
				if (tcl::isInt(value))
				{
					int size = tcl::asInt(value);
					m_grid.set<Vert>(mstl::max(0, size == 1 ? 0 : size));
					addFlag(F_Config);

					if (size == 0)
						return removeAttr(attribute);
				}
			}
			break;
	}

	Tcl_Obj*& obj = m_attrMap[attribute];
	tcl::decrRef(obj);
	obj = tcl::incrRef(value);
}


Tcl_Obj*
Node::getAttr(char const* attribute, bool ignoreMeta) const
{
	M_ASSERT(attribute);

	if (ignoreMeta && isMetaFrame() && child()) // !child() may happen when destroying a metaframe
		return child()->getAttr(attribute, false);

	switch (attribute[0])
	{
		case 'a': if (tcl::equal(attribute, "amalgamate")) return tcl::newObj(m_amalgamate); break;
		case 'f': if (tcl::equal(attribute, "fullscreen")) return tcl::newObj(m_fullscreen); break;
		case 'h': if (tcl::equal(attribute, "hgrid")) return tcl::newObj(m_grid.dimen<Horz>()); break;
		case 'p': if (tcl::equal(attribute, "priority")) return tcl::newObj(m_priority); break;
		case 't': if (tcl::equal(attribute, "transient")) return tcl::newObj(m_isTransient); break;
		case 'v': if (tcl::equal(attribute, "vgrid")) return tcl::newObj(m_grid.dimen<Vert>()); break;
	}

	AttrMap::const_iterator i = m_attrMap.find(attribute);
	return i == m_attrMap.end() ? nullptr : i->second;
}


void
Node::resize(Quants const& quant, bool perform)
{
	if (isLocked())
	{
		m_afterPerform.push_back(new Quants(quant));
	}
	else
	{
		if (quant.actual.abs.width > 0)
		{
			if (m_dimen.actual.abs.width != quant.actual.abs.width)
			{
				m_dimen.actual.abs.width = quant.actual.abs.width;
				addFlag(F_Config);
			}
		}
		if (quant.actual.abs.height > 0)
		{
			if (m_dimen.actual.abs.height != quant.actual.abs.height)
			{
				m_dimen.actual.abs.height = quant.actual.abs.height;
				addFlag(F_Config);
			}
		}
		if (quant.min.abs.width > 0)
		{
			if (m_dimen.min.abs.width != quant.min.abs.width)
			{
				m_dimen.min.abs.width = quant.min.abs.width;
				addFlag(F_Config);
			}
		}
		if (quant.min.abs.height > 0)
		{
			if (m_dimen.min.abs.height != quant.min.abs.height)
			{
				m_dimen.min.abs.height = quant.min.abs.height;
				addFlag(F_Config);
			}
		}
		if (quant.max.abs.width > 0)
		{
			if (m_dimen.max.abs.width != quant.max.abs.width)
			{
				m_dimen.max.abs.width = quant.max.abs.width;
				addFlag(F_Config);
			}
		}
		if (quant.max.abs.height > 0)
		{
			if (m_dimen.max.abs.height != quant.max.abs.height)
			{
				m_dimen.max.abs.height = quant.max.abs.height;
				addFlag(F_Config);
			}
		}

		if (testFlags(F_Config))
		{
			Node* node = nullptr;

			if (m_parent)
			{
				if (m_parent->isNotebookOrMultiWindow())
				{
					node = m_parent;
				}
				else if (	m_parent->isMetaFrame()
							&& m_parent->m_parent
							&& m_parent->m_parent->isNotebookOrMultiWindow())
				{
					node = m_parent->m_parent;
				}

				if (node)
				{
					for (unsigned i = 0; i < node->numChilds(); ++i)
					{
						Node* child = node->child(i);

						if (	quant.actual.abs.width > 0
							&& child->m_dimen.actual.abs.width != quant.actual.abs.width)
						{
							child->m_dimen.actual.abs.width = quant.actual.abs.width;
							child->addFlag(F_Config);
						}
						if (	quant.actual.abs.height > 0
							&& child->m_dimen.actual.abs.height != quant.actual.abs.height)
						{
							child->m_dimen.actual.abs.height = quant.actual.abs.height;
							child->addFlag(F_Config);
						}
					}
				}
			}

			if (perform)
			{
				Coord weight(m_weight);
				m_weight.zero(); // don't resize this widget
				m_root->perform(toplevel());
				m_weight = weight;
			}
		}
	}
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
	M_ASSERT(isToplevel());

	for (unsigned i = 0; i < m_toplevel.size(); ++i)
	{
		Node *toplevel = m_toplevel[i];

		toplevel->addFlag(F_Header);

		for (unsigned k = 0; k < toplevel->m_active.size(); ++k)
			toplevel->m_active[k]->addFlag(F_Config);

		toplevel->perform();
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


bool
Node::isVisible() const
{
	Node const* node = this;

	for ( ; !node->isRoot(); node = node->m_parent)
	{
		if (!node->isPacked())
			return false;
		if (node->m_parent->isNotebookOrMultiWindow() && node->m_parent->m_selected != node)
			return false;
	}

	return true;
}


void
Node::collectToplevels(tcl::List& result) const
{
	for (unsigned i = 0; i < m_toplevel.size(); ++i)
	{
		if (m_toplevel[i]->exists())
			result.push_back(m_toplevel[i]->pathObj());
	}
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
Node::collectHeaderFramesRecursively(tcl::List& result) const
{
	if (m_headerObj)
		result.push_back(pathObj());

	if (!isLeaf())
	{
		for (unsigned i = 0; i < numChilds(); ++i)
			child(i)->collectHeaderFramesRecursively(result);
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
Node::collectHeaderFramesRecursively() const
{
	tcl::List result;
	collectHeaderFramesRecursively(result);
	return result;
}


tcl::List
Node::collectToplevels() const
{
	tcl::List result;
	collectToplevels(result);
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

		Tcl_Obj* obj = node->getAttr(attr, false);

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
	tcl::List result;

	if (isRoot())
	{
		for (unsigned i = 0; i < m_active.size(); ++i)
		{
			if (m_active[i]->isLeaf())
				result.push_back(m_active[i]->uidObj());
		}
	}
	else
	{
		collectLeavesRecursively(result);
	}

	return result;
}


tcl::List
Node::collectContainer() const
{
	tcl::List result;

	for (auto node : m_active)
	{
		if (node->pathObj() && node->isContainer() && (this == node || node->hasAncestor(this)))
			result.push_back(node->pathObj());
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
	else if (isVisible())
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
	return m_lookup[tcl::asString(path)] = new Base;
}


Base*
Node::lookupBase(char const* path)
{
	M_ASSERT(path);

	Lookup::iterator i = m_lookup.find(path);
	return i == m_lookup.end() ? nullptr : i->second;
}


void
Node::removeBase(char const* path)
{
	Lookup::iterator i = m_lookup.find(path);

	if (i != m_lookup.end())
	{
		delete i->second->root;
		delete i->second->setup;
		delete i->second;
		m_lookup.erase(i);
	}
}


bool
Node::makeStructure()
{
	M_ASSERT(isRoot());

	if (!child() || !child()->isContainer())
		return false;

	m_structures.push_back(child()->makeStructure(nullptr));
	return true;
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
	type = isNotebookOrMultiWindow() ? structure::Multi : (isHorz() ? structure::Horz : structure::Vert);
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
		{
			delete *i;
			i = m_structures.erase(i);
		}
		else
		{
			i += 1;
		}
	}
}


int
Node::expand() const
{
	if (isRoot())
		return m_grow | m_shrink;
	
	if (isLeaf())
		return (weight<Horz>() ? Horz : 0) | (weight<Vert>() ? Vert : 0);
	
	int result = None;

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isPacked())
		{
			if (isNotebookOrMultiWindow())
				result &= child(i)->expand();
			else
				result |= child(i)->expand();
		}
	}

	return result;
}


void
Node::setupDimensions(Quants const& dimen)
{
	if (!canComputeDimensions<Horz,Actual>())
		m_dimen.set<Horz,Actual>(dimen.dimen<Horz,Actual>());
	if (!canComputeDimensions<Vert,Actual>())
		m_dimen.set<Vert,Actual>(dimen.dimen<Vert,Actual>());
}


void
Node::updateDimen(int x, int y, int width, int height)
{
	if (width > 1 && height > 1 && exists())
	{
		width = contentSize<Horz>(width);
		height = contentSize<Vert>(height);

		if (this == m_root)
			performGetWorkArea();

		if (isLocked())
		{
			m_dimen.set<Horz>(width);
			m_dimen.set<Vert>(height);
		}
		else
		{
			if (tk::isMapped(tkwin()))
			{
				m_coord.x = x;
				m_coord.y = y;

				if (!isRoot())
				{
					m_coord.x -= m_root->x();
					m_coord.y -= m_root->y();
				}
			}

			int oldWidth	= m_dimen.dimen<Horz>();
			int oldHeight	= m_dimen.dimen<Vert>();

			if (width != oldWidth || height != oldHeight)
			{
				Node* toplevel = this->toplevel();

				m_dimen.set<Horz>(width);
				m_dimen.set<Vert>(height);

				if (!toplevel->isResized() || (isRoot() && !m_root->isReady()))
				{
					if (!m_root->isReady())
					{
						addFlag(F_Config);
						Tcl_CancelIdleCall(Perform, m_root);
						Tcl_DoWhenIdle(Perform, m_root);
					}
					else if (isPanedWindow() && m_root->isReady() && containsGrid())
					{
						if (width != oldWidth && hasOrientation<Horz>())
							addFlag(F_Adjust);
						if (height != oldHeight && hasOrientation<Vert>())
							addFlag(F_Adjust);

						if (testFlags(F_Adjust))
						{
							Tcl_DeleteTimerHandler(toplevel->m_timerToken);
							toplevel->m_timerToken =
								Tcl_CreateTimerHandler(m_root->m_alignTimeout, Adjust, toplevel);
						}
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
	
	return weight<D>()*spread;
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
	
	return weight<D>()*spread;
}


template <Orient D>
int
Node::computeUnderflow() const
{
	return mstl::max(0, weight<D>()*(dimen<Inner,D,Min>() - dimen<Inner,D>()));
}


template <Orient D>
int
Node::computeDimen() const
{
	M_ASSERT(!isWithdrawn());

	if (!hasPackedChilds())
		return actualSize<Inner,D>();
	
	int totalSize = 0;

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isPacked())
		{
			// ensure that the header will be added
			int size = child(i)->frameSize<D>(child(i)->computeDimen<D>() + 1) - 1;

			if (hasOrientation<D>())
				totalSize += size + (totalSize ? sashSize() : 0);
			else
				totalSize = mstl::max(totalSize, size);
		}
	}

	return totalSize;
}


template <Orient D,Quantity Q>
void
Node::addDimen(Node const* node)
{
	M_ASSERT(!isWithdrawn());
	M_ASSERT(Q != Max); // not working for Maxima

	if (Q == Actual || node->dimen<Inner,D,Q>())
	{
		int nodeSize = node->dimen<Outer,D,Q>();
		int mySize = dimen<Inner,D,Q>();

		m_dimen.set<D,Q>(hasOrientation<D>()
			? mySize + nodeSize + (mySize ? sashSize() : 0)
			: mstl::max(mySize, nodeSize));
	}
}


template <Orient D,Quantity Q>
bool
Node::canComputeDimensions() const
{
	M_ASSERT(!isWithdrawn());

	if (value<D,Q,Abs>() || m_dimen.mode<D>() == Grd)
		return true;

	if (isLeaf())
		return false;
	
#if !TWM_MIGRATE_LAYOUT
	if (isRoot())
		return false;
#endif

	if (isToplevel())
	{
#if TWM_MIGRATE_LAYOUT
		if (!isRoot())
#endif
		if (value<D,Q,Rel>())
			return true;
	}

	if (isPanedWindow())
	{
		for (unsigned i = 0; i < numChilds(); ++i)
		{
			Node const* node = child(i);

			if (node->isPacked() && !node->canComputeDimensions<D,Q>())
				return false;
		}

		return true;
	}

	if (isNotebookOrMultiWindow())
	{
		if (!hasPackedChilds())
			return true;

		for (unsigned i = 0; i < numChilds(); ++i)
		{
			Node const* node = child(i);

			if (node->isPacked() && node->canComputeDimensions<D,Q>())
				return true;
		}

		return false;
	}

	return child()->canComputeDimensions<D,Q>();
}


template <Orient D>
int
Node::computeGap() const
{
	int size = 0;

	if (isPanedWindow() && hasOrientation<D>())
	{
		for (unsigned i = 1; i < numChilds(); ++i)
			size += child(i)->sashSize();
	}
	else if (D == Vert && isNotebook())
	{
		size += notebookHeaderSize();
	}

	return size;
}


template <Orient D,Quantity Q>
void
Node::resolveGridUnits()
{
	if (m_dimen.mode<D>() == Grd && m_dimen.dimen<D,Q,Abs>() == 0)
		m_dimen.setup<D,Q>(m_dimen.dimen<D,Q,Grd>()*gridSize<D>());
}


void
Node::resolveGridUnitsRecursively()
{
	resolveGridUnits<Horz,Min>();
	resolveGridUnits<Vert,Min>();
	resolveGridUnits<Horz,Max>();
	resolveGridUnits<Vert,Max>();
	resolveGridUnits<Horz,Actual>();
	resolveGridUnits<Vert,Actual>();

	for (unsigned i = 0; i < numChilds(); ++i)
		child(i)->resolveGridUnitsRecursively();
}


template <Orient D,Quantity Q>
void
Node::computeDimensionsRecursively(int size, int gapSize)
{
	M_ASSERT(!isWithdrawn());
	//M_ASSERT(canComputeDimensions<D,Q>());

	int myGapSize = computeGap<D>();

	gapSize += myGapSize;

	if (isContainer())
	{
		m_dimen.set<D,Q>(0);
	}
	else if (value<D,Q>() == 0 && value<D,Q,Rel>() > 0)
	{
		int mySize = isToplevel() ? m_root->m_workArea.dimen<D>() : toplevel()->dimen<Inner,D,Q>();
		m_dimen.set<D,Q>(contentSize<D>(m_dimen.computeRelativeSize<D,Q>(mySize - gapSize)));
	}

	bool	needComputedSize	= (value<D,Q>() == 0);
	bool	useGridSize			= true;
	int	maxMinSize			= 0;
	int	gridSize				= 0;

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		Node* node = child(i);

		if (node->isPacked())
		{
			int childSize;

			if (Q == Max)
				childSize = 0;
			else if (Q == Min || hasOrientation<D>())
				childSize = node->dimen<Inner,D,Min>();
			else
				childSize = node->dimen<Inner,D,Actual>();

			node->computeDimensionsRecursively<D,Q>(childSize, gapSize);

			if (needComputedSize)
			{
				if (Q != Max)
				{
					addDimen<D,Q>(node);
				}
				else if (m_dimen.dimen<D,Max>() >= 0)
				{
					if (hasOrientation<D>() && node->value<D,Max>() == 0)
						m_dimen.set<D,Max>(-1);
					else
						m_dimen.set<D,Max>(mstl::max(m_dimen.dimen<D,Max>(), node->dimen<Outer,D,Max>()));
				}
			}

			if (node->m_grid.dimen<D>() == 0)
			{
				if (weight<D>() > 0)
					useGridSize = false;
			}
			else if (isContainer())
			{
				if (weight<D>() == 0)
					useGridSize = false;

				if (gridSize == 0)
					gridSize = node->m_grid.dimen<D>();
				else if (gridSize != node->m_grid.dimen<D>())
					gridSize = -1;

				maxMinSize = mstl::max(maxMinSize, node->dimen<Outer,D,Min>());
			}
		}
	}

	if (gridSize > 0)
		m_grid.set<D>(gridSize);
	else if (isMetaFrame())
		m_grid = child()->m_grid;
	
	if (isPanedWindow() && !useGridSize)
		m_grid.set<D>(0);

	gridSize = this->gridSize<D>();

	if (Q == Max)
	{
		if (m_dimen.dimen<D,Max>() == -1)
			m_dimen.set<D,Max>(0);
	}
	else if (value<D,Q>() == 0)
	{
		m_dimen.set<D,Q>(size);
	}

	if (Q != Min)
	{
		int mySize = m_dimen.dimen<D,Q>();

		if (Q == Actual || mySize > 0)
		{
			if (int minSize = dimen<Inner,D,Min>())
			{
				mySize = mstl::max(mySize, minSize);
				if (gridSize > 0)
					mySize = ((mySize - minSize)/gridSize)*gridSize + minSize;
				m_dimen.set<D,Q>(mySize);
			}
		}
	}
	else if (gridSize > 0)
	{
		if (isNotebookOrMultiWindow())
		{
			int minSize = m_dimen.dimen<D,Min>();
			m_dimen.set<D,Q>(((minSize - maxMinSize + gridSize - 1)/gridSize)*gridSize + maxMinSize);
		}
		else if (isPanedWindow())
		{
			// TODO nothing to do!?
		}
	}
	
	m_dimen.setReliable<D,Q>();

	if (Q == Actual)
	{
		if (isNotebookOrMultiWindow())
		{
			int size = dimen<Inner,D,Q>();

			for (unsigned i = 0; i < numChilds(); ++i)
			{
				Node* node = child(i);

				if (node->isPacked())
					node->m_dimen.set<D,Q>(node->contentSize<D>(size));
			}
		}
		else if (hasOrientation<~D>())
		{
			int size = dimen<Inner,D,Q>();

			for (unsigned i = 0; i < numChilds(); ++i)
			{
				Node* node = child(i);

				if (node->isPacked())
					node->m_dimen.set<D,Q>(node->contentSize<D>(size));
			}
		}
	}
}


void
Node::computeDimensionsRecursively()
{
	M_ASSERT(isToplevel());

	resolveGridUnitsRecursively();

	if (canComputeDimensions<Horz,Min>())
		computeDimensionsRecursively<Horz,Min>(0, 0);
	if (canComputeDimensions<Vert,Min>())
		computeDimensionsRecursively<Vert,Min>(0, 0);
	if (canComputeDimensions<Horz,Actual>())
		computeDimensionsRecursively<Horz,Actual>(0, 0);
	if (canComputeDimensions<Vert,Actual>())
		computeDimensionsRecursively<Vert,Actual>(0, 0);
	if (m_dimen.reliable<Horz,Actual>() || canComputeDimensions<Horz,Max>())
		computeDimensionsRecursively<Horz,Max>(0, 0);
	if (m_dimen.reliable<Vert,Actual>() || canComputeDimensions<Vert,Max>())
		computeDimensionsRecursively<Vert,Max>(0, 0);
}


template <Orient D>
void
Node::adjustDimensionsRecursively(int size, int gapSize, bool apply)
{
	M_ASSERT(!isWithdrawn());

	gapSize += computeGap<D>();

	if (isPanedWindow() && testFlags(F_Adjust))
		apply = true;
	
	if (apply)
	{
		bool changed = false;
	
		for (unsigned i = 0; i < numChilds(); ++i)
		{
			Node* node = child(i);

			if (int gridSize = node->gridSize<D>())
			{
				if (int minSize = node->dimen<Inner,D,Min>())
				{
					int oldSize = node->m_dimen.dimen<D>();
					int newSize = mstl::max(oldSize, minSize);

					newSize = ((newSize - minSize)/gridSize)*gridSize + minSize;

					if (newSize != oldSize)
					{
						int maxSize		= node->dimen<Inner,D,Max>();
						int nextSize	= newSize + gridSize;

						if (	(maxSize == 0 || nextSize <= maxSize)
							&& abs(nextSize - oldSize) < abs(newSize - oldSize))
						{
							newSize = nextSize;
						}
						node->m_dimen.set<D>(newSize);
						changed = true;
					}
				}
			}
		}

		if (changed)
			doAdjustment<D>(dimen<Inner,D>());
	}

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		Node* node = child(i);
		node->adjustDimensionsRecursively<D>(node->dimen<Inner,D>(), gapSize, apply);
	}
}


void
Node::adjustDimensionsRecursively()
{
	M_ASSERT(isToplevel());
	M_ASSERT(finished());

	m_isLocked = true;
	adjustDimensionsRecursively<Horz>(0, 0, false);
	adjustDimensionsRecursively<Vert>(0, 0, false);
	m_isLocked = false;

	for (unsigned i = 0; i < m_active.size(); ++i)
		m_active[i]->delFlag(F_Adjust);
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
	if (m_justCreated == this)
		m_justCreated = nullptr;
	
	if (isRoot())
		Tcl_CancelIdleCall(Perform, this);
	if (isToplevel())
		Tcl_DeleteTimerHandler(m_timerToken);

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

		if (	m_parent
			&& toplevel() == m_root
			&& !m_root->isAlreadyDead()
			&& !m_parent->containsDeadWindows(this))
		{
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
		else if (!toplevel()->isAlreadyDead())
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
		case PanedWindow:	return m_objTypePanedWindow; break;
		case MultiWindow:	return m_objTypeMultiWindow; break;
		case Notebook:		return m_objTypeNotebook; break;
		case Pane:			return m_objTypePane; break;
		case Frame:			return m_objTypeFrame; break;
		case MetaFrame:	return m_objTypeMetaFrame; break;
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
Node::findPath(char const* path) const
{
	M_ASSERT(path);
	M_ASSERT(isRoot());

	if (tcl::equal(m_path, path))
		return const_cast<Node*>(this);

	for (unsigned i = 0; i < m_active.size(); ++i)
	{
		Node* node = m_active[i];

		if (node->m_path && tcl::equal(node->m_path, path))
			return node;
	}

	return nullptr;
}


Node*
Node::findUid(char const* uid) const
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

	static char const* Attrs[] = { "amalgamate", "hgrid", "priority", "transient", "vgrid" };

	Node* node = new Node(*this);

	node->m_isClone = true;
	node->m_parent = parent;
	node->m_orientation = m_orientation;
	//node->m_priority = m_priority;
	//node->m_isTransient = m_isTransient;
	//node->m_amalgamate = m_amalgamate;
	//node->m_fullscreen = m_fullscreen;
	//node->m_grid = m_grid;
	node->m_weight = m_weight;
	node->m_sticky = m_sticky;
	node->m_root = parent->m_root;
	node->m_root->m_active.push_back(node);
	node->m_dimen = m_dimen;
	tcl::set(node->m_uid, uid);
	tcl::set(node->m_path, nullptr);

	for (unsigned i = 0; i < sizeof(Attrs)/sizeof(Attrs[0]); ++i)
	{
		if (Tcl_Obj* obj = m_root->getAttr(Attrs[i]))
			parent->m_root->setAttr(Attrs[i], obj);
	}

	return node;
}


Node*
Node::clone(LeafMap const& leaves) 
{
	M_ASSERT(isRoot());

	structure::Node* structure = nullptr;
	if (child() && child()->isContainer())
		structure = child()->makeStructure(nullptr);

	Node* root = clone(leaves, nullptr);
	root->create();
	root->setState(Packed);
	if (structure)
		root->m_structures.push_back(structure);
	root->finishLoad(&leaves, this, !!structure);
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
	mstl::swap(m_isTransient, child->m_isTransient);
	mstl::swap(m_amalgamate, child->m_amalgamate);
	mstl::swap(m_fullscreen, child->m_fullscreen);
	mstl::swap(m_childs, child->m_childs);
	// child->m_root
	child->m_parent = this;
	mstl::swap(m_savedParent, child->m_savedParent);
	mstl::swap(m_selected, child->m_selected);
	mstl::swap(m_dimen, child->m_dimen);
	mstl::swap(m_actual, child->m_actual);
	// child->m_coord
	// child->m_workArea
	mstl::swap(m_grid, child->m_grid);
	mstl::swap(m_orientation, child->m_orientation);
	mstl::swap(m_weight, child->m_weight);
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
	// child->m_justCreated
	mstl::swap(m_flags, child->m_flags);
	// child->m_snapshotMap
	// child->m_initialStructure
	// child->m_isClone
	mstl::swap(m_isDeleted, child->m_isDeleted);
	// child->m_isDestroyed
	// child->m_isResized
	// child->m_isLocked
	// child->m_isReady
	// child->m_isPreserved
	// child->m_temporary
	// child->m_timerToken
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
	// child->m_isTransient
	// child->m_amalgamate
	// child->m_fullscreen
	child->m_childs.swap(m_childs);
	child->m_root = m_root;
	child->m_parent = this;
	// child->m_savedParent
	child->m_selected = nullptr;
	// child->m_dimen
	// child->m_actual
	// child->m_coord
	// child->m_workArea
	mstl::swap(child->m_grid, m_grid);
	// child->m_orientation
	// child->m_weight
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
	// child->m_justCreated
	child->m_flags = (m_flags & (F_Create|F_Build|F_Header|F_Destroy|F_Docked|F_Raise));
	// child->m_snapshotMap
	// child->m_initialStructure
	child->m_isClone = m_isClone;
	// child->m_isDeleted
	// child->m_isDestroyed
	// child->m_isResized
	// child->m_isLocked
	// child->m_isReady
	// child->m_isPreserved
	// child->m_temporary
	// child->m_timerToken
	// child->m_dumpFlag

	// Change this node to a MetaFrame

	m_type = MetaFrame;
	m_state = Withdrawn;
	tcl::zero(m_path);
	tcl::zero(m_uid);
	m_priority = 0;
	m_isTransient = false;
	m_amalgamate = false;
	// m_fullscreen 
	m_childs.push_back(child);
	// m_root
	// m_parent
	m_savedParent = nullptr;
	m_selected = nullptr;
	// m_dimen
	// m_actual
	// m_coord
	// m_workArea
	// m_grid
	m_orientation = 0;
	// m_weight
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
	// m_justCreated
	m_flags = 0;
	// m_snapshotMap
	// m_initialStructure
	// m_isClone
	// m_isDeleted
	// m_isDestroyed
	// m_isResized
	// m_isLocked
	// m_isReady
	// m_isPreserved
	// m_temporary
	// m_timerToken
	// m_dumpFlag

	if (child->exists())
	{
		create();
	}
	else
	{
		M_ASSERT(!exists());
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
	nb->m_dimen.set<Horz>(width<Outer>());
	nb->m_dimen.set<Vert>(height<Outer>());
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
	pw->m_dimen.set<Horz>(width<Outer>());
	pw->m_dimen.set<Vert>(height<Outer>());
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

		unsigned lvl = this->child(i)->descendantOf(child, level + 1);

		if (lvl < mstl::numeric_limits<unsigned>::max())
			return lvl;
	}

	return mstl::numeric_limits<unsigned>::max();
}


Node*
Node::findBestPlace(Quants const& quant, int priority, int& bestDistance1, int& bestDistance2)
{
	Node* node = nullptr;

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isPacked())
		{
			int distance1 = bestDistance1;
			int distance2 = bestDistance2;

			if (Node* n = child(i)->findBestPlace(quant, priority, distance1, distance2))
			{
				node = n;
				bestDistance1 = distance1;
				bestDistance2 = distance2;
			}
		}
	}

	if (!node)
	{
		int distance1 = mstl::abs(m_dimen.actual.abs.area() - quant.actual.abs.area());
		int distance2 = mstl::abs(m_priority - priority);

		if (distance1 < bestDistance1 || (distance1 == bestDistance1 && distance2 < bestDistance2))
		{
			node = this;
			bestDistance1 = distance1;
			bestDistance2 = distance2;
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
			if (Node const* node = m_root->findUid(tcl::asString(leaves2[k])))
			{
				if (node->hasAncestor(m_parent->m_parent ? m_parent->m_parent : m_parent))
				{
					while (node->m_parent != m_parent)
						node = node->m_parent;
					if (parent->findIndex(childs) > int(i))
						node = node->findAfter();
					return node;
				}
			}
		}
	}

	return nullptr;
}


Node*
Node::findDockingNode(Position& position, Node const*& before, Node const* setup)
{
	if (isMetaFrame())
		return child()->findDockingNode(position, before, setup);

	// 1. Search in saved structures.

	tcl::List dockable, visible;
	collectLeavesRecursively(dockable);
	m_root->collectLeavesRecursively(visible);

	unsigned bestCount = 0;
	unsigned bestDepth = 0;
	structure::Node const* bestNode = nullptr;
	Node* node = nullptr;

	for (int i = m_root->m_structures.size() - 1; i >= 0; --i)
	{
		if (!m_root->m_initialStructure || i > 0 || !bestNode)
		{
			unsigned count = 0;

			if (structure::Node const* sNode = m_root->m_structures[i]->findBest(dockable, count, visible))
			{
				if (sNode->parent())
				{
					unsigned depth = sNode->depth();

					if (count > bestCount || (count == bestCount && depth > bestDepth))
					{
						tcl::List leaves;
						sNode->collectLeaves(leaves);

						if (Node* n = m_root->findBest(leaves))
						{
							bestNode = sNode;
							bestCount = count;
							bestDepth = depth;
							node = n;
						}
					}
				}
			}
		}
	}

	if (node)
	{
		structure::Node const* parent = bestNode->parent();
		M_ASSERT(parent);

		switch (parent->type())
		{
			case structure::Horz:	position = Right; break;
			case structure::Vert:	position = Bottom; break;
			default:						position = Center; break;
		}

		if (	node->m_parent
			&& !node->m_parent->isToplevel()
			&& (bestNode->isHorz() || bestNode->isVert())
			&& node->isLeaf())
		{
			node = node->m_parent;
		}

		if (node->isMetaFrame())
			node = node->m_parent;

		if (	node->m_parent
			&& !node->m_parent->isToplevel()
			&& (	(	(parent->isHorz() || parent->isVert())
					&& !node->isContainer()
					&& node->m_parent->isNotebookOrMultiWindow())
				|| (bestNode->isHorz() && parent->isVert())
				|| (bestNode->isVert() && parent->isHorz())))
		{
			if ((node = node->m_parent)->isMetaFrame())
				node = node->m_parent;
		}

		if (node->fits(m_dimen.min.abs, position))
		{
			before = node->findRelation(parent, dockable);
			return node;
		}
	}

	// 3. Find best place.

	int distance1 = mstl::numeric_limits<int>::max();
	int distance2 = mstl::numeric_limits<int>::max();
	Node* parent = m_root->findBestPlace(m_dimen, m_priority, distance1, distance2);

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
		setAttr(tcl::asString(elems[i]), elems[i + 1]);
}


void
Node::parseSnapshot(Tcl_Obj* obj)
{
	M_ASSERT(obj);

	if (!isRoot())
		return; // Oops, this shouldn't happen

	tcl::Array elems = tcl::getElements(obj);

	if (elems.size() == 0)
		M_THROW(tcl::Exception("empty snapshot list"));
	if (elems.size() % 2)
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
			::parseDimension<Horz>(value, m_dimen.actual);
		else if (tcl::equal(name, m_objOptHeight))
			::parseDimension<Vert>(value, m_dimen.actual);
		else if (tcl::equal(name, m_objOptMinWidth))
			::parseDimension<Horz>(value, m_dimen.min);
		else if (tcl::equal(name, m_objOptMinHeight))
			::parseDimension<Vert>(value, m_dimen.min);
		else if (tcl::equal(name, m_objOptMaxWidth))
			::parseDimension<Horz>(value, m_dimen.max);
		else if (tcl::equal(name, m_objOptMaxHeight))
			::parseDimension<Vert>(value, m_dimen.max);
		else if (tcl::equal(name, m_objOptExpand))
			::parseExpandOption(value, m_weight);
		else if (tcl::equal(name, m_objOptSticky))
			m_sticky = ::parseStickyOption(tcl::asString(value));
		else if (tcl::equal(name, m_objOptShrink))
			m_shrink = ::parseResizeOption(value);
		else if (tcl::equal(name, m_objOptGrow))
			m_grow = ::parseResizeOption(value);
		else if (tcl::equal(name, m_objOptHWeight))
			m_weight.x = ::parseWeightOption(value);
		else if (tcl::equal(name, m_objOptVWeight))
			m_weight.y = ::parseWeightOption(value);
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
#if TWM_MIGRATE_LAYOUT
	if (!tcl::equal(m_root->pathObj(), ".application.nb.board", 21) && m_dimen.min.mode<Vert>() == Abs)
		m_dimen.min.setup<Vert>((m_dimen.min.dimen<Vert>() + 7)/15, Grd);
#endif

	if (isRoot())
#if TWM_MIGRATE_LAYOUT
	if (!tcl::equal(m_root->pathObj(), ".application.nb.board", 21))
#endif
	{
#if TWM_MIGRATE_LAYOUT
		if (0)
#endif
		if (!m_dimen.actual.abs.width)
			m_dimen.actual.setup<Horz>(10000, Rel);
		if (!m_dimen.actual.abs.height)
			m_dimen.actual.setup<Vert>(10000, Rel);
	}

	if (m_dimen.min.abs.width && m_dimen.max.abs.width)
		m_dimen.max.abs.width = mstl::max(m_dimen.min.abs.width, m_dimen.max.abs.width);
	if (m_dimen.min.abs.height && m_dimen.max.abs.height)
		m_dimen.max.abs.height = mstl::max(m_dimen.min.abs.height, m_dimen.max.abs.height);
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
			optList.push_back(m_objAttrBoth);
		}
		else if (value & X)
		{
			optList.push_back(m_objOptExpand);
			optList.push_back(m_objAttrX);
		}
		else if (value & Y)
		{
			optList.push_back(m_objOptExpand);
			optList.push_back(m_objAttrY);
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

		if (m_parent && m_parent->isPanedWindow())
		{
			if (m_parent->hasOrientation<Horz>())
			{
				if ((value = minWidth<Outer>()) > 0 && m_dimen.reliable<Horz,Min>())
				{
					optList.push_back(m_objOptMinSize);
					optList.push_back(tcl::newObj(value));
				}
				if ((value = maxWidth<Outer>()) > 0 && m_dimen.reliable<Horz,Max>())
				{
					optList.push_back(m_objOptMaxSize);
					optList.push_back(tcl::newObj(value));
				}
			}
			else // if (m_parent->hasOrientation<Vert>())
			{
				if ((value = minHeight<Outer>()) > 0 && m_dimen.reliable<Vert,Min>())
				{
					optList.push_back(m_objOptMinSize);
					optList.push_back(tcl::newObj(value));
				}
				if ((value = maxHeight<Outer>()) > 0 && m_dimen.reliable<Vert,Min>())
				{
					optList.push_back(m_objOptMaxSize);
					optList.push_back(tcl::newObj(value));
				}
			}

			optList.push_back(m_objOptGridSize);
			optList.push_back(tcl::newObj(m_grid.get(Orient(m_parent->m_orientation))));
		}
		else if (isPane() || isFrameOrMetaFrame())
		{
			if ((value = minWidth<Outer>()) > 0 && m_dimen.reliable<Horz,Min>())
			{
				optList.push_back(m_objOptMinWidth);
				optList.push_back(tcl::newObj(value));
			}
			if ((value = maxWidth<Outer>()) > 0 && m_dimen.reliable<Horz,Max>())
			{
				optList.push_back(m_objOptMaxWidth);
				optList.push_back(tcl::newObj(value));
			}
			if ((value = minHeight<Outer>()) > 0 && m_dimen.reliable<Vert,Min>())
			{
				optList.push_back(m_objOptMinHeight);
				optList.push_back(tcl::newObj(value));
			}
			if ((value = maxHeight<Outer>()) > 0 && m_dimen.reliable<Vert,Min>())
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
			optList.push_back(value == Horz ? m_objAttrHorizontal : m_objAttrVertical);
		}
	}

	if ((value = width<Outer>()) > 0 && m_dimen.reliable<Horz,Actual>())
	{
		optList.push_back(m_objOptWidth);
		optList.push_back(tcl::newObj(value));
	}
	if ((value = height<Outer>()) > 0 && m_dimen.reliable<Vert,Actual>())
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
	else if (!exists())
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
				// isPane() || isFrame() ? MultiWindow : Notebook
				parent = insertNotebook(node, MultiWindow, before);
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
				parent = insertPanedWindow(position, node, before);
			}
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
		{
			m_dimen.setActual(i->second.width*scaleWidth + 0.5, i->second.height*scaleHeight + 0.5);
			addFlag(F_Config);
		}
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
Node::applyGrid(int size, int remaining) const
{
	if (isLastChild())
		return size;

	int gridSize = this->gridSize<D>();

	if (gridSize > 0)
	{
		if (size >= 0)
		{
			int lower = (size/gridSize)*gridSize;
			int newSize = -1;

			if (lower < size)
			{
				int upper = lower + gridSize;

				if (upper <= remaining)
				{
					int maxSize		= dimen<Inner,D,Max>();
					int actualSize	= this->actualSize<Inner,D>();

					if (maxSize == 0 || actualSize + upper <= maxSize)
					{
						newSize = (mstl::abs(size - upper) <= mstl::abs(size - lower)) ? upper : lower;

						if (maxSize && actualSize + newSize > maxSize)
							newSize = maxSize - actualSize;
					}
				}
			}

			size = (newSize == -1) ? lower : newSize;
		}
		else
		{
			int lower = ((size = -size)/gridSize)*gridSize;
			int newSize = -1;

			if (lower < size)
			{
				int upper = lower + gridSize;

				if (upper <= remaining)
				{
					int minSize		= dimen<Inner,D,Min>();
					int actualSize	= this->actualSize<Inner,D>();

					newSize = (mstl::abs(size - upper) <= mstl::abs(size - lower)) ? upper : lower;

					if (minSize && actualSize - newSize < minSize)
						newSize = actualSize - minSize;
				}
			}

			size = -(newSize == -1 ? lower : newSize);
		}
	}

	return size;
}


template <Orient D>
int
Node::doExpandPanes(int space, bool expandable, int stage)
{
	M_ASSERT(space > 0);

	int available = 0;
	int spread = 0;
	int count = 0;

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		Node const* child = this->child(i);

		if (child->isPacked() && (expandable == child->isExpandable<D>()))
		{
			if (int expand = child->computeExpand<D>(stage))
			{
				available += expand;
				count += 1;
			}
		}
	}

	if (available > 0)
	{
		int remaining = mstl::min(available, space);
		int shift = 0;

		for (unsigned i = 0; remaining > 0 && i < numChilds(); ++i)
		{
			Node* child = this->child(i);

			if (child->isPacked() && (expandable == child->isExpandable<D>()))
			{
				if (count == 1 && stage == 2 && !expandable)
				{
					child->doAdjustment<D>(child->actualSize<Inner,D>() - remaining);
				}
				else if (int expand = child->computeExpand<D>(stage))
				{
					int share = mstl::min(remaining, int((double(expand)/available)*space + 0.5));
					int add = int(double(shift)/count + 0.5);

					share = mstl::min(share + add, remaining);
					shift -= add;

					if (int maxSize = child->maxSize<Inner,D>())
					{
						int s = mstl::min(share, maxSize - child->actualSize<Inner,D>());
						add = mstl::min(remaining, add + share - s);
						share = s;
					}

					if (share > 0)
					{
						int myShare = child->applyGrid<D>(share, remaining);
						// TODO: ensure that remaining >= available

						if (myShare == 0)
						{
							add = mstl::min(remaining, add + share - myShare);
						}
						else
						{
							spread += myShare;
							remaining -= myShare;
							M_ASSERT(remaining >= 0);
							M_ASSERT(spread <= space);
							child->doAdjustment<D>(child->actualSize<Inner,D>() + myShare);
						}
					}

					count -= 1;
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
					int gridSize = m_grid.dimen<D>();

					if (gridSize > 0)
					{
						int lower = ((share - dimen<Inner,D,Min>())/gridSize)*gridSize + dimen<Inner,D,Min>();
						share = (lower < share) ? lower + gridSize : lower;
					}

					spread += share;
					remaining -= share;
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
	int count = 0;

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		Node const* child = this->child(i);

		if (child->isPacked() && (expandable == child->isExpandable<D>()))
		{
			if (int shrink = child->computeShrink<D>(stage))
			{
				available += shrink;
				count += 1;
			}
		}
	}

	if (available > 0)
	{
		int remaining = mstl::min(available, space);
		int shift = 0;

		for (unsigned i = 0; remaining > 0 && i < numChilds(); ++i)
		{
			Node* child = this->child(i);

			if (child->isPacked() && (expandable == child->isExpandable<D>()))
			{
				if (count == 1 && stage == 2 && !expandable)
				{
					child->doAdjustment<D>(child->actualSize<Inner,D>() + remaining);
				}
				else if (int shrink = child->computeShrink<D>(stage))
				{
					int share = mstl::min(remaining, int((double(shrink)/available)*space + 0.5));
					int add = int(double(shift)/count + 0.5);

					share = mstl::min(share + add, remaining);
					shift -= add;

					if (child->minSize<Inner,D>())
					{
						int s = mstl::min(share, child->actualSize<Inner,D>() - child->minSize<Inner,D>());
						add = mstl::min(remaining, add + share - s);
						share = s;
					}

					if (share > 0)
					{
						int myShare = -child->applyGrid<D>(-share, remaining);
						// TODO: ensure that remaining >= available

						if (myShare == 0)
						{
							shift = mstl::min(remaining, shift + share - myShare);
						}
						else
						{
							spread += myShare;
							remaining -= myShare;
							M_ASSERT(remaining >= 0);
							M_ASSERT(spread <= space);
							child->doAdjustment<D>(child->actualSize<Inner,D>() - myShare);
						}
					}

					count -= 1;
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
	{
		if (child(i)->isPacked())
			child(i)->doAdjustment<D>(child(i)->contentSize<D>(size));
	}
}


template <Orient D>
void
Node::doAdjustment(int size)
{
	M_ASSERT(isPacked() || isToplevel());

	if (orientation<D>())
	{
		// TODO:
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
Node::adjustRoot()
{
	if (grow<D>() && actualSize<Inner,D>() < minSize<Inner,D>())
		m_dimen.set<D>(mstl::min(minSize<Inner,D>(), m_actual.min.dimen<D>()));
	else if (shrink<D>() && maxSize<Inner,D>() && actualSize<Inner,D>() > maxSize<Inner,D>())
		m_dimen.set<D>(mstl::min(maxSize<Inner,D>(), m_actual.min.dimen<D>()));
}


template <Orient D>
void
Node::adjustToplevel()
{
	if (!(expand() & D))
	{
		if (actualSize<Inner,D>() < minSize<Inner,D>())
			m_dimen.set<D>(minSize<Inner,D>());
		else if (maxSize<Inner,D>() > 0 && actualSize<Inner,D>() < maxSize<Inner,D>())
			m_dimen.set<D>(maxSize<Inner,D>());
	}
}


void
Node::adjustDimensions()
{
	M_ASSERT(isToplevel());

	if (isRoot())
	{
		adjustRoot<Horz>();
		adjustRoot<Vert>();
	}
	else
	{
		adjustToplevel<Horz>();
		adjustToplevel<Vert>();
	}

	doAdjustment<Horz>(actualSize<Inner,Horz>());
	doAdjustment<Vert>(actualSize<Inner,Vert>());
	fitDimensions<Horz>(actualSize<Inner,Horz>());
	fitDimensions<Vert>(actualSize<Inner,Vert>());
}


template <Orient D>
void
Node::fitDimensions(int size)
{
	if (!isToplevel())
		m_dimen.set<D>(size);

	if (!isPanedWindow() || !orientation<D>())
	{
		for (unsigned i = 0; i < numChilds(); ++i)
		{
			if (child(i)->isPacked())
				child(i)->fitDimensions<D>(child(i)->contentSize<D>(size));
		}
	}
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
		sizeMap->insert(SizeMap::value_type(tcl::asString(m_uid), m_dimen.actual.abs));

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
			structure.append('|');
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
	m_amalgamate = false;
	m_fullscreen = false;
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
		m_toplevel[i]->inspect(exportList, str, 0, 0);

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
	bool first = true;

	for (unsigned i = 0; i < exportList.size(); ++i)
	{
		AttrMap::const_iterator k = m_attrMap.find(exportList[i]);
		// XXX may not contain actual value

		if (k != m_attrMap.end())
		{
			if (first)
			{
				str.append(m_objOptAttrs);
				str.startList();
				first = false;
			}
			str.append(k->first);
			str.append(k->second);
		}
	}

	if (!first)
		str.endList();
}


template <Orient D,Quantity Q>
void
Node::inspectDimen(Tcl_Obj* attr, tcl::DString& str, int gapSize) const
{
#if TWM_MIGRATE_LAYOUT
	if (	D == Vert
		&& Q == Actual
		&& m_root->exists()
		&& !tcl::equal(m_root->pathObj(), ".application.nb.board", 21)
		&& m_dimen.mode<D,Q>() == Abs)
	{
		Quants dim(m_dimen);

		dim.set<D,Q>(dimen<Outer,D,Q>());
		int size = isToplevel() ? m_root->m_workArea.dimen<D>() : toplevel()->dimen<Inner,D,Q>();
		size -= gapSize;
		const_cast<Node*>(this)->m_dimen.actual.setup<D>(dim.computePercentage<D,Q>(size), Rel);
		M_ASSERT((m_dimen.mode<D,Q>() == Rel));
		M_ASSERT((m_dimen.dimen<D,Q,Rel>()));
	}
#endif
#if TWM_MIGRATE_LAYOUT
	if (m_dimen.mode<D,Q>() == Grd && gridSize<D>() == 0)
		const_cast<Node*>(this)->m_dimen.setup<D,Q>(dimen<Inner,D,Q>());
#endif
	if (m_dimen.mode<D,Q>() == Abs)
	{
		if (dimen<Inner,D,Q,Abs>())
		{
			str.append(attr);
			str.append(dimen<Inner,D,Q>());
		}
	}
	else if (m_dimen.mode<D,Q>() == Grd)
	{
		int size  = dimen<Inner,D,Q,Abs>();
		int units = size ? size/gridSize<D>() : dimen<Inner,D,Q,Grd>();

		if (units)
		{
			char buf[100];
			::snprintf(buf, sizeof(buf), "%du", units);

			str.append(attr);
			str.append(buf);
		}
	}
	else if (dimen<Inner,D,Q,Rel>())
	{
		char buf[200];
		int percentage = m_dimen.dimen<D,Q,Rel>();

		if (dimen<Inner,D,Q>())
		{
			Quants dim(m_dimen);
			dim.set<D,Q>(dimen<Outer,D,Q>());
			percentage = dim.computePercentage<D,Q>(toplevel()->dimen<Inner,D,Q>() - gapSize);
		}

		int fract = percentage % 100;
		percentage = percentage/100;

		str.append(attr);
		if (fract == 0)
			::snprintf(buf, sizeof(buf), "%d%%", percentage);
		else
			::snprintf(buf, sizeof(buf), "%d.%d%%", percentage, fract);
		str.append(buf);
	}
}


void
Node::inspect(AttrSet const& exportList, tcl::DString& str, int horzGap, int vertGap) const
{
	if (isMetaFrame())
		return child()->inspect(exportList, str, horzGap, vertGap + frameHeaderSize());
	
	if (isContainer())
	{
		switch (countStableChilds())
		{
			case 0: return;
			case 1: return stableChild()->inspect(exportList, str, horzGap, vertGap);
		}

		horzGap += computeGap<Horz>();
		vertGap += computeGap<Vert>();
	}

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
			if (m_dimen.mode<Horz,Actual>() == Abs)
				inspectDimen<Horz,Actual>(m_objOptWidth, str, 0);
			if (m_dimen.mode<Vert,Actual>() == Abs)
				inspectDimen<Vert,Actual>(m_objOptHeight, str, 0);
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
			inspectAttrs(exportList, str);
			break;

		case Pane:
		case Frame:
			inspectDimen<Horz,Actual>(m_objOptWidth, str, horzGap);
			inspectDimen<Vert,Actual>(m_objOptHeight, str, vertGap);
			inspectDimen<Horz,Min>(m_objOptMinWidth, str, horzGap);
			inspectDimen<Vert,Min>(m_objOptMinHeight, str, vertGap);
			inspectDimen<Horz,Max>(m_objOptMaxWidth, str, horzGap);
			inspectDimen<Vert,Max>(m_objOptMaxHeight, str, vertGap);
			if (weight<Horz>())
			{
				str.append(m_objOptHWeight);
				str.append(weight<Horz>());
			}
			if (weight<Vert>())
			{
				str.append(m_objOptVWeight);
				str.append(weight<Vert>());
			}
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

	if (isLeaf())
		vertGap += frameHeaderSize();

	if (!isLeaf())
	{
		str.startList();

		for (unsigned i = 0; i < numChilds(); ++i)
		{
			if (!isContainer() || !child(i)->m_isTransient)
				child(i)->inspect(exportList, str, horzGap, vertGap);
		}

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
Node::saveLeaves(LeafMap& leaves, tcl::Array const& preserved)
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
			node->setPreserved(tcl::containsElement(preserved, node->uidObj()));
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

		node->m_amalgamate = false;
		node->m_root = nullptr;
		node->m_parent = nullptr;
		node->m_savedParent = nullptr;
		node->m_selected = nullptr;
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

	bool haveTempStruct = false;

	if (leaves && sRoot)
		haveTempStruct = makeStructure();
	load(list, leaves);
	if (sRoot)
		finishLoad(leaves, sRoot, haveTempStruct);
}


void
Node::finishLoad(LeafMap const* leaves, Node const* sRoot, bool deleteTempStruct)
{
	M_ASSERT(sRoot);
	M_ASSERT(isRoot());

	if (leaves)
	{
		for (LeafMap::const_iterator k = leaves->begin(); k != leaves->end(); ++k)
		{
			Node* node = k->second;

			node->delFlag(F_Unpack);

			if (node->isWithdrawn())
			{
				node->m_root = this;
				m_active.push_back(node);

				if (node->isPreserved())
				{
					Node* null = nullptr;
					node->dock(null, Center, sRoot);
				}
				else
				{
					node->m_parent = this;
					node->destroy();
				}
			}
		}
	}

	if (deleteTempStruct)
	{
		M_ASSERT(!m_structures.empty());
		delete m_structures.back();
		m_structures.pop_back();
	}

	if (sRoot->child() && sRoot->child()->isContainer())
	{
		m_initialStructure = true;
		m_structures.push_front(sRoot->child()->makeStructure(nullptr));
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

	int width		= mstl::max(1, this->width<Outer>());
	int height		= mstl::max(1, this->height<Outer>());
	int newWidth	= width;
	int newHeight	= height;

	if (width == 1 && height == 1)
		return;

	performResizeDimensions(newWidth, newHeight);

	if (width == newWidth && height == newHeight)
		return;

	m_isResized = true;

	double fh = double(newWidth)/double(width);
	double fv = double(newHeight)/double(height);

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

	if (newWidth > 1)
		m_dimen.set<Horz>(newWidth);
	if (newHeight > 1)
		m_dimen.set<Vert>(newHeight);
	computeDimensionsRecursively();

	if (numChilds() == 1 && ((width == 1 && newWidth > 1) || (height == 1 && newHeight > 1)))
		child()->performChildConfigure();
}


int
Node::performQueryFrameHeaderSize() const
{
	M_ASSERT(exists());

	Tcl_Obj* result;
	
	result = tcl::call(__func__, m_root->pathObj(), m_objCmdFrameHdrSize, pathObj(), nullptr);
	if (!result)
		M_THROW(tcl::Error());
	int size = tcl::asInt(result);
	tcl::decrRef(result);
	return size;
}


void
Node::performQuerySelected() const
{
	Tcl_Obj*	result;
	
	result = tcl::call(__func__, m_root->pathObj(), m_objCmdSelected, pathObj(), nullptr);
	if (!result)
		M_THROW(tcl::Error());
	Node* selected = m_root->findPath(tcl::asString(result));
	if (!selected && *tcl::asString(result))
	{
		tcl::decrRef(result);
		M_THROW(tcl::Exception("invalid widget %s", tcl::asString(result)));
	}
	tcl::decrRef(result);
	if (selected && contains(selected))
		const_cast<Node*>(this)->m_selected = selected;
}


int
Node::performQueryNotebookHeaderSize() const
{
	Tcl_Obj*	result;
	
	result = tcl::call(__func__, m_root->pathObj(), m_objCmdNotebookHdrSize, pathObj(), nullptr);
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

	Tcl_Obj* result = tcl::call(__func__, m_root->pathObj(), m_objCmdSashSize, nullptr);

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
					m_objCmdPack,
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

	tcl::invoke(__func__, m_root->pathObj(), m_objCmdUnpack, parent->pathObj(), pathObj(), nullptr);
}


void
Node::performCreate()
{
	M_ASSERT(!exists());
	M_ASSERT(!isRoot());

	Tcl_Obj* opts = isContainer() ? makeOptions(F_Create) : (isLeaf() ? m_uid : nullptr);
	Tcl_Obj* result;

	m_root->m_justCreated = this;

	if (opts)
		result = tcl::call(__func__, m_root->pathObj(), typeObj(), opts, nullptr);
	else
		result = tcl::call(__func__, m_root->pathObj(), typeObj(), nullptr);

	m_root->m_justCreated = nullptr;

	if (!result)
		M_THROW(tcl::Error());

	tcl::set(m_path, result);
	tcl::decrRef(result);

	if (!isToplevel() && toplevel()->isFloating())
		tk::reparent(tkwin(), toplevel()->tkwin());

	tk::createEventHandler(tkwin(), StructureNotifyMask, ::WindowEventProc, this);
}


void
Node::performFinalizeCreate()
{
	M_ASSERT(exists());
	M_ASSERT(!isRoot());
	M_ASSERT(!isMetaFrame() || child()->exists());

	tcl::invoke(__func__,
					m_root->pathObj(),
					m_objCmdFrame2,
					pathObj(),
					isMetaFrame() ? child()->m_path : m_uid,
					nullptr);
}


void
Node::performFullscreen()
{
	M_ASSERT(isToplevel());
	tcl::invoke(__func__, pathObj(), m_objCmdFullscreen, tcl::newObj(m_fullscreen), nullptr);
}


template <Orient D,Quantity Q>
Tcl_Obj*
Node::makeDimObj(int gapSize) const
{
	int size;

	switch (m_dimen.mode<D,Q>())
	{
		case Abs:
			size = m_dimen.dimen<D,Q>();
			break;

		case Grd:
			size = m_dimen.dimen<D,Q,Grd>()*gridSize<D,Q>();
			break;

		case Rel:
			if (m_dimen.dimen<D,Q,Rel>() > 0)
			{
				size = isToplevel() ? m_root->m_workArea.dimen<D>() : toplevel()->dimen<Inner,D,Q>();
				size = contentSize<D>(m_dimen.computeRelativeSize<D,Q>(size - gapSize));
			}
			else
			{
				size = 0;
			}
			break;
	}

	return tcl::newObj(size);
}


void
Node::performDimensions(int horzGap, int vertGap)
{
	M_ASSERT(exists());

	tcl::List optList;

	optList.push_back(makeDimObj<Horz,Actual>(horzGap));
	optList.push_back(makeDimObj<Vert,Actual>(vertGap));
	optList.push_back(makeDimObj<Horz,Min>(horzGap));
	optList.push_back(makeDimObj<Vert,Min>(vertGap));
	optList.push_back(makeDimObj<Horz,Max>(horzGap));
	optList.push_back(makeDimObj<Vert,Max>(vertGap));

	Tcl_Obj* result = tcl::call(	__func__,
											m_root->pathObj(),
											m_objCmdAdjust,
											pathObj(),
											m_uid,
											tcl::newObj(optList),
											nullptr);
	if (!result)
		M_THROW(tcl::Error());

	tcl::Array elems = tcl::getElements(result);
	tcl::decrRef(result);

	if (elems.size() == 0)
		return;

	if (	elems.size() != 6
		|| !tcl::isInt(elems[0])
		|| !tcl::isInt(elems[1])
		|| !tcl::isInt(elems[2])
		|| !tcl::isInt(elems[3])
		|| !tcl::isInt(elems[4])
		|| !tcl::isInt(elems[5]))
	{
		M_THROW(tcl::Exception("expecting ?width height minwidth minheight maxwidth maxheight?"));
	}
	
	m_dimen.set<Horz,Actual>(tcl::asInt(elems[0]));
	m_dimen.set<Vert,Actual>(tcl::asInt(elems[1]));
	m_dimen.set<Horz,Min>(tcl::asInt(elems[2]));
	m_dimen.set<Vert,Min>(tcl::asInt(elems[3]));
	m_dimen.set<Horz,Max>(tcl::asInt(elems[4]));
	m_dimen.set<Vert,Max>(tcl::asInt(elems[5]));
}


void
Node::performBuild()
{
	M_ASSERT(exists());
	M_ASSERT(isLeaf());

	tcl::invoke(__func__,
					m_root->pathObj(),
					m_objCmdBuild,
					pathObj(),
					uidObj(),
					tcl::newObj(width<Inner>()),
					tcl::newObj(height<Inner>()),
					nullptr);
}


void
Node::performReady()
{
	M_ASSERT(isRoot());

	tcl::invoke(__func__,
					m_root->pathObj(),
					m_objCmdReady,
					tcl::newObj(width<Outer>()),
					tcl::newObj(height<Outer>()),
					nullptr);
}


void
Node::performResizeDimensions(int& width, int& height)
{
	M_ASSERT(isToplevel());

	Tcl_Obj* result = tcl::call(	__func__,
											m_root->pathObj(),
											m_objCmdResizing,
											pathObj(),
											tcl::newObj(width),
											tcl::newObj(height),
											nullptr);
	if (!result)
		M_THROW(tcl::Error());

	tcl::Array elems = tcl::getElements(result);
	tcl::decrRef(result);

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

	Tcl_Obj* result = tcl::call(__func__, pathObj(), m_objCmdWorkArea, nullptr);

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
Node::performChildConfigure()
{
	M_ASSERT(m_parent);
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
						m_objCmdChildConfigure,
						m_parent->pathObj(),
						pathObj(),
						list,
						nullptr);
	}
}


void
Node::performPaneConfigure()
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
						m_objCmdPaneConfigure,
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

		if (	(m_flags & (F_Undocked|F_Deiconify))
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
							m_objCmdGeometry,
							pathObj(),
							tcl::newObj(newWidth),
							tcl::newObj(newHeight),
							tcl::newObj(m_actual.min.abs.width),
							tcl::newObj(m_actual.min.abs.height),
							tcl::newObj(m_actual.max.abs.width),
							tcl::newObj(m_actual.max.abs.height),
							(h && v) ? m_objAttrBoth : (h ? m_objAttrX : (v ? m_objAttrY : m_objAttrNone)),
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

	tcl::invoke(__func__, m_root->pathObj(), m_objCmdDestroy, pathObj(), nullptr);
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
					m_objCmdSelect,
					m_parent->pathObj(),
					pathObj(),
					nullptr);
}


void
Node::performUpdateHeader()
{
	M_ASSERT(exists());
	M_ASSERT(isFrameOrMetaFrame());

	Node const* node = findAmalgamated();

	if (node && node->m_selected)
	{
		tcl::invoke(__func__,
						m_root->pathObj(),
						m_objCmdHeader,
						pathObj(),
						m_headerObj ? m_headerObj : m_obj,
						node->m_selected->pathObj(),
						nullptr);
	}
	else
	{
		tcl::invoke(__func__,
						m_root->pathObj(),
						m_objCmdHeader,
						pathObj(),
						m_headerObj ? m_headerObj : m_obj,
						nullptr);
	}
}


void
Node::performUpdateTitle()
{
	M_ASSERT(exists());
	M_ASSERT(isFloating());

	tcl::invoke(__func__, m_root->pathObj(), m_objCmdTitle, pathObj(), m_titleObj, nullptr);
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

	unsigned flags = finished() ? 0 : F_Config;

	m_flags = flags;

	for (unsigned i = 0; i < m_active.size(); ++i)
		m_active[i]->m_flags = flags;
}


void
Node::updateHeader()
{
	M_ASSERT(!isWithdrawn());

	bool canAmalgamate = this->canAmalgamate();

	if (m_amalgamate && !canAmalgamate)
	{
		m_amalgamate = false;
		addFlag(F_Header);
	}

	if (!m_amalgamate && canAmalgamate)
		m_wasAmalgamatable = true;

	if (isMultiWindow())
	{
		if (m_amalgamate && canAmalgamate)
		{
			Node* headerWindow = findHeaderWindow();
			Tcl_Obj*& list = headerWindow->m_headerObj;

			M_ASSERT(list);

			int k = tcl::countElements(list);

			if (headerWindow->m_path)
			{
				int j = tcl::findElement(list, headerWindow->m_path);
				if (j >= 0)
					tcl::removeElement(list, k = j);
			}

			for (unsigned i = 0; i < numChilds(); ++i)
			{
				Node* node = child(i);

				if (node->isPacked())
					tcl::insertElement(list, node->pathObj(), k++);
			}

			tcl::zero(m_headerObj);
			m_isAmalgamated = true;
		}
		else
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
	else
	{
		if (isFloating())
		{
			if (isMetaFrame() && child()->isFrame())
				tcl::zero(child()->m_headerObj);

			tcl::zero(m_headerObj);
			tcl::set(m_titleObj, findLeader()->pathObj());
		}
		else if (isLeaf() && m_parent->isRoot())
		{
			tcl::set(m_headerObj, pathObj());
		}

		if (isFrameOrMetaFrame() && !isToplevel())
		{
			if (canAmalgamate)
			{
				if (m_amalgamate)
				{
					findHeaderWindow()->addFlag(F_Header); // because we have no change in labels
					tcl::zero(m_headerObj);
					m_isAmalgamated = true;
				}
				else
				{
					addFlag(F_Header); // because we have no change in labels
				}
			}
			else if (	m_parent->isContainer()
						&& m_parent->findAmalgamated()
						&& m_parent->child()->m_headerObj)
			{
				tcl::set(m_headerObj, m_parent->child()->m_headerObj);
				addFlag(F_Header);
			}
			else if (m_wasAmalgamatable)
			{
				addFlag(F_Header); // because we have no change in labels
				m_wasAmalgamatable = false;
			}
		}
	}
}


void
Node::updateAllHeaders()
{
	M_REQUIRE(isRoot());

	for (unsigned i = 0; i < m_active.size(); ++i)
	{
		Node* node = m_active[i];

		tcl::set(node->m_oldHeaderObj, node->m_headerObj);
		tcl::set(node->m_oldTitleObj, node->m_titleObj);
		tcl::zero(node->m_headerObj);
		tcl::zero(node->m_titleObj);
		node->m_isAmalgamated = false;

		if (node->isMultiWindow())
		{
			unsigned amalgamated = 0;

			for (unsigned k = 0; k < node->numChilds(); ++k)
			{
				if (node->child(k)->m_amalgamate)
					amalgamated += 1;
			}

			if (amalgamated > 0 && amalgamated != node->numChilds())
			{
				// Force update of metaframe header.
				if (node->m_parent && node->m_parent->m_parent && node->m_parent->m_parent->isMetaFrame())
					node->m_parent->m_parent->addFlag(F_Header);

				// Either all or none have to be amalgamated, in this case none.
				for (unsigned k = 0; k < node->numChilds(); ++k)
					node->child(k)->m_amalgamate = false;
			}
		}
	}

	for (unsigned i = 0; i < m_toplevel.size(); ++i)
		m_toplevel[i]->updateHeadersRecursively();
}


void
Node::updateHeadersRecursively()
{
	if (!isWithdrawn())
	{
		updateHeader();

		for (unsigned i = 0; i < numChilds(); ++i)
			m_childs[i]->updateHeadersRecursively();
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
			tk::raise(child->tkwin(), tkwin());

		child->performRaiseRecursively(doIt);
	}
}


void
Node::performSelectRecursively(bool needed)
{
	M_ASSERT(!isWithdrawn());

	if (testFlags(F_Select) || (needed && isNotebookOrMultiWindow()))
	{
		M_ASSERT(m_selected && m_selected->isPacked());
		m_selected->performSelect();
		needed = true;
	}

	for (unsigned i = 0; i < numChilds(); ++i)
		child(i)->performSelectRecursively(needed);
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
	if (isToplevel())
		performFullscreen();

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isPacked())
			child(i)->performFinalizeCreateRecursively();
	}

	if (testFlags(F_Create) && isFrameOrMetaFrame())
		performFinalizeCreate();
}


void
Node::performDimensionsRecursively(int horzGap, int vertGap)
{
	if (isLeaf())
	{
		if (testFlags(F_Create|F_Config))
			performDimensions(horzGap, vertGap);
	}
	else
	{
		horzGap += computeGap<Horz>();
		vertGap += computeGap<Vert>();

		for (unsigned i = 0; i < numChilds(); ++i)
		{
			if (child(i)->isPacked())
				child(i)->performDimensionsRecursively(horzGap, vertGap);
		}
	}
}


void
Node::performDimensionsRecursively()
{
	M_ASSERT(isToplevel());
	return performDimensionsRecursively(0, 0);
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
	if (m_parent && (m_parent->isPanedWindow() && !isToplevel()))
		performPaneConfigure();
	
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
		if (	force
			|| testFlags(F_Create|F_Pack|F_Header|F_Deiconify)
			|| !tcl::eqOrNull(m_headerObj, m_oldHeaderObj))
		{
			performUpdateHeader();
		}

		if (isFloating() && m_titleObj && !tcl::eqOrNull(m_titleObj, m_oldTitleObj))
			performUpdateTitle();
	}

	delFlag(F_Header);

	for (unsigned i = 0; i < numChilds(); ++i)
		child(i)->performUpdateHeaderRecursively(force);
}


void
Node::performAllActiveNodes(Flag flag)
{
	M_ASSERT(isRoot());
	M_ASSERT((flag & (F_Unpack|F_Unframe|F_Docked|F_Destroy)) == flag);

	for (unsigned i = 0; i < m_active.size(); ++i)
	{
		Node* node = m_active[i];

		if (node->testFlags(flag))
		{
			switch (int(flag))
			{
				case F_Unpack:
					M_ASSERT(node->m_savedParent);
					if (node->m_savedParent->m_selected == this)
						node->m_savedParent->m_selected = nullptr;
					if (node->m_savedParent->exists())
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
			}
		}
	}
}


void
Node::performUpdateDimensions()
{
	M_ASSERT(isRoot());

	if (m_actual.actual.abs.width > 0 && m_actual.actual.abs.height > 0)
	{
		m_dimen.actual = m_actual.actual;
		m_actual.actual.zero();
	}

	for (unsigned i = 0; i < m_active.size(); ++i)
	{
		Node* node = m_active[i];

		if (node->m_actual.actual.abs.width > 0 && node->m_actual.actual.abs.height > 0)
		{
			node->m_dimen.actual = node->m_actual.actual;
			node->m_actual.actual.zero();
		}
	}

	if (!isLocked())
	{
		bool needPerform = false;

		for (unsigned i = 0; i < m_active.size(); ++i)
		{
			Node* node = m_active[i];
			QuantList& afterPerformList = node->m_afterPerform;

			if (!afterPerformList.empty())
			{
				for (unsigned k = 0; k < afterPerformList.size(); ++k)
				{
					node->resize(*afterPerformList[k], false);
					delete afterPerformList[k];
					needPerform = true;
				}
				afterPerformList.clear();
			}
		}

		if (needPerform)
			perform();
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
	tcl::invoke(__func__,
					m_root->pathObj(),
					m_objCmdDeiconify,
					pathObj(),
					tcl::newObj(dimen<Outer,Horz>()),
					tcl::newObj(dimen<Outer,Vert>()),
					tcl::newObj(m_coord.x),
					tcl::newObj(m_coord.y),
					tcl::newObj(force),
					nullptr);
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
			toplevel->updateAllHeaders();
			toplevel->performDimensionsRecursively();
			toplevel->computeDimensionsRecursively();
			if (toplevel->finished())
				toplevel->adjustDimensions();
			toplevel->performPackRecursively();
			toplevel->performUpdateHeaderRecursively(true);
			toplevel->setState(Withdrawn);
			toplevel->floating(false);
			toplevel->performRaiseRecursively();
			toplevel->performSelectRecursively();
			toplevel->performBuildRecursively();
			toplevel->performDeiconify();
			if (toplevel->finished())
				toplevel->performGeometry();
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

			if (flags & (F_Pack|F_Unpack|F_Header|F_Deiconify))
				m_root->updateAllHeaders();

			if (isRoot() && (flags & F_Docked))
				m_root->performAllActiveNodes(F_Docked);

			m_root->performGetWorkArea();

			if (flags & F_Build)
			{
				m_root->performBuildRecursively();
				if (toplevel)
					toplevel->performBuildRecursively();
			}

			if (flags & (F_Create|F_Config))
			{
				performDimensionsRecursively();
				if (toplevel)
					toplevel->performDimensionsRecursively();
			}

			if (flags & (F_Create|F_Pack|F_Unpack|F_Config))
			{
				computeDimensionsRecursively();
				if (toplevel)
					toplevel->computeDimensionsRecursively();
			}

			resizeDimensions();
			if (toplevel)
				toplevel->resizeDimensions();

			if (!m_isReady || (flags & (F_Pack|F_Unpack|F_Config)))
			{
				if (finished())
					adjustDimensions();
				if (toplevel && toplevel->finished())
					toplevel->adjustDimensions();
			}

			if (finished())
				performGeometry();
			if (toplevel && toplevel->finished())
				toplevel->performGeometry();

			if (flags & F_Pack)
			{
				performPackRecursively();
				if (toplevel)
					toplevel->performPackRecursively();
			}

			if (finished())
				performConfigRecursively();
			if (toplevel && toplevel->finished())
				toplevel->performConfigRecursively();

			if (flags & F_Raise)
			{
				performRaiseRecursively();
				if (toplevel)
					toplevel->performRaiseRecursively(toplevel->testFlags(F_Raise));
			}

			if (flags & (F_Pack|F_Unpack|F_Create|F_Select))
			{
				performSelectRecursively();
				if (toplevel)
					toplevel->performSelectRecursively();
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

			if (finished())
				m_root->performUpdateDimensions();

			if (flags & F_Deiconify)
				m_root->performDeiconifyFloats();

			m_root->m_isLocked = false;
			m_root->clearAllFlags();
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

	if (isRoot() && !m_isReady && finished())
		ready();
}


void
Node::adjust()
{
	M_ASSERT(isToplevel());
	M_ASSERT(finished());

	adjustDimensionsRecursively();
	performGeometry();
	performConfigRecursively();
	performUpdateDimensions();
}

#ifndef NDEBUG

__attribute__((unused))
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
		if (amalgamate())
			printf(" {amalgamate}");
		if (isTransient())
			printf(" {transient}");
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
	if (m_objTypePanedWindow)
		return;

	m_obj = tcl::incrRef(tcl::newObj());
	m_objAttrBoth = tcl::incrRef(tcl::newObj("both"));
	m_objAttrHorizontal = tcl::incrRef(tcl::newObj("horizontal"));
	m_objAttrHorz = tcl::incrRef(tcl::newObj("horz"));
	m_objAttrNone = tcl::incrRef(tcl::newObj("none"));
	m_objAttrVert = tcl::incrRef(tcl::newObj("vert"));
	m_objAttrVertical = tcl::incrRef(tcl::newObj("vertical"));
	m_objAttrX = tcl::incrRef(tcl::newObj("x"));
	m_objAttrY = tcl::incrRef(tcl::newObj("y"));
	m_objCmdAdjust = tcl::incrRef(tcl::newObj("adjust"));
	m_objCmdBuild = tcl::incrRef(tcl::newObj("build"));
	m_objCmdChildConfigure = tcl::incrRef(tcl::newObj("childconfigure"));
	m_objCmdDeiconify = tcl::incrRef(tcl::newObj("deiconify"));
	m_objCmdDestroy = tcl::incrRef(tcl::newObj("destroy"));
	m_objCmdFrame2 = tcl::incrRef(tcl::newObj("frame2"));
	m_objCmdFrameHdrSize = tcl::incrRef(tcl::newObj("framehdrsize"));
	m_objCmdFullscreen = tcl::incrRef(tcl::newObj("fullscreen"));
	m_objCmdGeometry = tcl::incrRef(tcl::newObj("geometry"));
	m_objCmdHeader = tcl::incrRef(tcl::newObj("header"));
	m_objCmdNotebookHdrSize = tcl::incrRef(tcl::newObj("nbhdrsize"));
	m_objCmdPack = tcl::incrRef(tcl::newObj("pack"));
	m_objCmdPaneConfigure = tcl::incrRef(tcl::newObj("paneconfigure"));
	m_objCmdReady = tcl::incrRef(tcl::newObj("ready"));
	m_objCmdResizing = tcl::incrRef(tcl::newObj("resizing"));
	m_objCmdSashSize = tcl::incrRef(tcl::newObj("sashsize"));
	m_objCmdSelected = tcl::incrRef(tcl::newObj("selected"));
	m_objCmdSelect = tcl::incrRef(tcl::newObj("select"));
	m_objCmdTitle = tcl::incrRef(tcl::newObj("title"));
	m_objCmdUnpack = tcl::incrRef(tcl::newObj("unpack"));
	m_objCmdWorkArea = tcl::incrRef(tcl::newObj("workarea"));
	m_objDirsLR = tcl::incrRef(tcl::newListObj("l r"));
	m_objDirsTB = tcl::incrRef(tcl::newListObj("t b"));
	m_objDirsTBLREW = tcl::incrRef(tcl::newListObj("t b l r e w"));
	m_objDirsTBLRNSEW = tcl::incrRef(tcl::newListObj("t b l r n s e w"));
	m_objDirsTBLRNS = tcl::incrRef(tcl::newListObj("t b l r n s"));
	m_objDirsTBLR = tcl::incrRef(tcl::newListObj("t b l r"));
	m_objOptAttrs = tcl::incrRef(tcl::newObj("-attrs"));
	m_objOptBefore = tcl::incrRef(tcl::newObj("-before"));
	m_objOptExpand = tcl::incrRef(tcl::newObj("-expand"));
	m_objOptGridSize = tcl::incrRef(tcl::newObj("-gridsize"));
	m_objOptGrow = tcl::incrRef(tcl::newObj("-grow"));
	m_objOptHeight = tcl::incrRef(tcl::newObj("-height"));
	m_objOptHWeight = tcl::incrRef(tcl::newObj("-hweight"));
	m_objOptMaxHeight = tcl::incrRef(tcl::newObj("-maxheight"));
	m_objOptMaxSize = tcl::incrRef(tcl::newObj("-maxsize"));
	m_objOptMaxWidth = tcl::incrRef(tcl::newObj("-maxwidth"));
	m_objOptMinHeight = tcl::incrRef(tcl::newObj("-minheight"));
	m_objOptMinSize = tcl::incrRef(tcl::newObj("-minsize"));
	m_objOptMinWidth = tcl::incrRef(tcl::newObj("-minwidth"));
	m_objOptOrient = tcl::incrRef(tcl::newObj("-orient"));
	m_objOptRecover = tcl::incrRef(tcl::newObj("-recover"));
	m_objOptShrink = tcl::incrRef(tcl::newObj("-shrink"));
	m_objOptSnapshots = tcl::incrRef(tcl::newObj("-snapshots"));
	m_objOptState = tcl::incrRef(tcl::newObj("-state"));
	m_objOptSticky = tcl::incrRef(tcl::newObj("-sticky"));
	m_objOptStructures = tcl::incrRef(tcl::newObj("-structures"));
	m_objOptVWeight = tcl::incrRef(tcl::newObj("-vweight"));
	m_objOptWidth = tcl::incrRef(tcl::newObj("-width"));
	m_objOptX = tcl::incrRef(tcl::newObj("-x"));
	m_objOptY = tcl::incrRef(tcl::newObj("-y"));
	m_objTypeFrame = tcl::incrRef(tcl::newObj("frame"));
	m_objTypeMetaFrame = tcl::incrRef(tcl::newObj("metaframe"));
	m_objTypeMultiWindow = tcl::incrRef(tcl::newObj("multiwindow"));
	m_objTypeNotebook = tcl::incrRef(tcl::newObj("notebook"));
	m_objTypePanedWindow = tcl::incrRef(tcl::newObj("panedwindow"));
	m_objTypePane = tcl::incrRef(tcl::newObj("pane"));
	m_objTypeRoot = tcl::incrRef(tcl::newObj("root"));
}

} // namespace


static void
cmdExists(int objc, Tcl_Obj* const objv[])
{
	if (objc != 3)
		M_THROW(tcl::Exception(2, objv, ""));

	Base* base = Node::lookupBase(tcl::asString(objv[2]));
	tcl::setResult(base && base->root && base->root->exists());
}


static void
cmdReady(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 3)
		M_THROW(tcl::Exception(2, objv, ""));

	tcl::setResult(base.root->isReady());
}


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
	if (objc != 4 && (objc != 6 || !tcl::equal(objv[3], "-aligntimeout") || !tcl::isUnsigned(objv[4])))
		M_THROW(tcl::Exception(3, objv, "?-aligntimeout ms? list"));

	M_ASSERT(!base.setup);

	base.setup = Node::makeRoot(objv[2], objc == 6 ? tcl::asUnsigned(objv[4]) : kDefaultAlignTimeout);
	base.setup->load(objv[objc == 6 ? 5 : 3]);
}


static void
cmdLoad(Base& base, int objc, Tcl_Obj* const objv[])
{
	Tcl_Obj* preserved = nullptr;
	int index = 2;

	if (objc > 4 && tcl::equal(objv[3], "-preserve"))
	{
		preserved = objv[4];
		index += 2;
	}

	if (objc != index + 1 && objc != index + 2)
		M_THROW(tcl::Exception(3, objv, "?-preserve list-of-uids? ?list?"));

	M_ASSERT(base.setup);

	Node::LeafMap leaves;
	Quants dimen;

	if (base.root)
	{
		dimen = base.root->quants();
		base.root->saveLeaves(leaves, preserved ? tcl::getElements(preserved) : tcl::Array());
		delete base.root;
		base.root = nullptr;
	}

	if (objc > index + 1 && tcl::countElements(objv[index + 1]) > 0)
	{
		base.root = Node::makeRoot(objv[2]);
		base.root->load(objv[index + 1], &leaves, base.setup);
	}
	else // if (objc == index + 1 || tcl::countElements(objv[index + 1]) == 0)
	{
		base.root = base.setup->clone(leaves);
	}

	base.root->setupDimensions(dimen);
	base.root->perform();
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
cmdAmalgamatable(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
		M_THROW(tcl::Exception(3, objv, "window"));

	char const* path = tcl::asString(objv[3]);
	Node const* node = base.root->findPath(path);

	if (!node)
		M_THROW(tcl::Exception("cannot find window '%s'", path));

	tcl::setResult(node->canAmalgamate());
}


static void
cmdAmalgamated(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
		M_THROW(tcl::Exception(3, objv, "window"));

	char const* path = tcl::asString(objv[3]);
	Node const* node = base.root->findPath(path);

	if (!node)
		M_THROW(tcl::Exception("cannot find window '%s'", path));

	Node const* child = node->findAmalgamated();
	tcl::setResult(child ? child->pathObj() : nullptr);
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
cmdChangeUid(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 5)
		M_THROW(tcl::Exception(3, objv, "oldUid newUid"));

	Node* node = base.root->findUid(tcl::asString(objv[3]));

	if (!node)
		M_THROW(tcl::Exception("cannot find leaf '%s'", tcl::asString(objv[3])));

	node->setUid(objv[4]);
}


static void
cmdContainer(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 3 && objc != 4)
		M_THROW(tcl::Exception(3, objv, "window"));

	Node const* node = base.root;

	if (objc == 4)
	{
		char const* path = tcl::asString(objv[3]);

		if (!(node = base.root->findPath(path)))
			M_THROW(tcl::Exception("cannot find window '%s'", path));
	}

	tcl::setResult(node->collectContainer());
}


static void
cmdFloats(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 3)
		M_THROW(tcl::Exception(2, objv));

	tcl::setResult(base.root->collectFloats());
}


static void
cmdDimension(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 3 && objc != 4)
		M_THROW(tcl::Exception(3, objv, "?window?"));

	Node* node = base.root;

	if (objc == 4)
	{
		char const* path = tcl::asString(objv[3]);

		if (!(node = base.root->findPath(path)))
			M_THROW(tcl::Exception("cannot find window '%s'", path));
	}

	Quants const& quant = node->quants();
	tcl::List result(6);
	result[0] = tcl::newObj(quant.actual.abs.width);
	result[1] = tcl::newObj(quant.actual.abs.height);
	result[2] = tcl::newObj(quant.min.abs.width);
	result[3] = tcl::newObj(quant.min.abs.height);
	result[4] = tcl::newObj(quant.max.abs.width);
	result[5] = tcl::newObj(quant.max.abs.height);
	tcl::setResult(result);
}


static void
cmdEqP(Base& base, int objc, Tcl_Obj* const objv[])
{
	static char const* Usage = "horz|vert percentage percentage";

	if (objc != 6)
		M_THROW(tcl::Exception(3, objv, Usage));

	Orient orient = parseOrientOption(objv[3]);
	Dimen lhs, rhs;

	if (orient == Horz)
	{
		if (parseDimension<Horz>(objv[4], lhs) != Rel || parseDimension<Horz>(objv[5], rhs) != Rel)
			M_THROW(tcl::Exception(3, objv, Usage));

		tcl::setResult(base.root->compare<Horz>(lhs.dimen<Horz,Rel>(), rhs.dimen<Horz,Rel>()));
	}
	else
	{
		if (parseDimension<Vert>(objv[4], lhs) != Rel || parseDimension<Vert>(objv[5], rhs) != Rel)
			M_THROW(tcl::Exception(3, objv, Usage));

		tcl::setResult(base.root->compare<Vert>(lhs.dimen<Vert,Rel>(), rhs.dimen<Vert,Rel>()));
	}
}


static void
cmdSee(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
		M_THROW(tcl::Exception(3, objv, "window"));

	char const* path = tcl::asString(objv[3]);
	Node* node = base.root->findPath(path);

	if (!node)
		M_THROW(tcl::Exception("cannot find window '%s'", path));

	node->select();
	node->toplevel()->perform();
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
		node = base.root->getJustCreated();

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
		node = base.root->getJustCreated();

		if (!node)
			M_THROW(tcl::Exception("cannot find window '%s'", path));
	}

	tcl::setResult(node->toplevel()->pathObj());
}


static void
cmdToplevels(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 3)
		M_THROW(tcl::Exception(2, objv));

	tcl::setResult(base.root->collectToplevels());
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
		tcl::setResult(parent->orientation<Horz>() ? m_objAttrHorizontal : m_objAttrVertical);
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
	if (objc != 3 && objc != 4)
		M_THROW(tcl::Exception(3, objv, "?window?"));

	Node* node = base.root;

	if (objc == 4)
	{
		char const* path = tcl::asString(objv[3]);

		if (!(node = base.root->findPath(path)))
			M_THROW(tcl::Exception("cannot find window '%s'", path));
	}

	tcl::setResult(node->collectLeaves());
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
cmdHeaderFrames(Base& base, int objc, Tcl_Obj* const objv[])
{
	tcl::setResult(base.root->collectHeaderFramesRecursively());
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
		node = base.root->getJustCreated();

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

	// consider that flatten() might have been withdrawn this parent
	while (parent->isWithdrawn())
		parent = parent->parent();
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
cmdDump(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 3 && objc != 4)
		M_THROW(tcl::Exception(3, objv, "?window?"));

	if (objc == 3)
	{
		base.root->dump();
	}
	else
	{
		char const* path = tcl::asString(objv[3]);
		Node* node = base.root->findPath(path);

		if (!node)
			M_THROW(tcl::Exception("cannot find window '%s'", path));

		node->dump();
	}
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
	if (objc != 6 && objc != 10)
		M_THROW(tcl::Exception(3, objv, "window width height ?minwidth minheight maxwidth maxheight?"));

	char const* path = tcl::asString(objv[3]);
	Node* node = base.root->findPath(path);

	if (!node)
		M_THROW(tcl::Exception("cannot find window '%s'", path));

	Quants quant(
		tcl::asInt(objv[4]), tcl::asInt(objv[5]),
		objc == 10 ? tcl::asInt(objv[6]) : 0, objc == 10 ? tcl::asInt(objv[7]) : 0,
		objc == 10 ? tcl::asInt(objv[8]) : 0, objc == 10 ? tcl::asInt(objv[9]) : 0);
	node->resize(quant, objc == 6);
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
		node = base.root->getJustCreated();

		if (!node)
			M_THROW(tcl::Exception("cannot find window '%s'", path));
	}

	bool ignoreMeta = cmd[::strlen(cmd) - 1] == '!';

	for (int i = 4; i < objc; i += 2)
		node->setAttr(tcl::asString(objv[i]), objv[i + 1], ignoreMeta);
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
		node = base.root->getJustCreated();

		if (!node)
			M_THROW(tcl::Exception("cannot find window '%s'", path));
	}

	bool ignoreMeta = cmd[::strlen(cmd) - 1] == '!';

	if (ignoreMeta && node->isMetaFrame())
		node = node->child(0);
	M_ASSERT(node);

	Tcl_Obj* value = node->getAttr(tcl::asString(objv[4]), cmd[::strlen(cmd) - 1] == '!');

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
		"amalgamatable",	"amalgamated",		"clone",				"capture",			"changeuid",
		"close",				"container",		"dimension",		"dock",				"dump",
		"eqp",				"exists",			"find",				"floats",			"frames",
		"get",				"get!",				"headerframes",	"hidden",			"id",
		"init",				"inspect",			"iscontainer",		"isdocked",			"ismetachild",
		"ispane",			"leaf",				"leader",			"leaves",			"load",
		"neighbors",		"new",				"orientation",		"panes",				"parent",
		"ready",				"refresh",			"release",			"resize",			"see",
		"selected",			"set",				"set!",				"show",				"toggle",
		"toplevel",			"toplevels",		"uid",				"undock",			"visible",
		nullptr
	};
	enum
	{
		Cmd_Amalgamatable,	Cmd_Amalgamated,		Cmd_Clone,				Cmd_Capture,		Cmd_ChangeUid,
		Cmd_Close,				Cmd_Container,			Cmd_Dimension,			Cmd_Dock,			Cmd_Dump,
		Cmd_EqP,					Cmd_Exists,				Cmd_Find,				Cmd_Floats,			Cmd_Frames,
		Cmd_Get,					Cmd_Get_,				Cmd_HeaderFrames,		Cmd_Hidden,			Cmd_Id,
		Cmd_Init,				Cmd_Inspect,			Cmd_IsContainer,		Cmd_IsDocked,		Cmd_IsMetaChild,
		Cmd_IsPane,				Cmd_Leaf,				Cmd_Leader,				Cmd_Leaves,			Cmd_Load,
		Cmd_Neighbors,			Cmd_New,					Cmd_Orientation,		Cmd_Panes,			Cmd_Parent,
		Cmd_Ready,				Cmd_Refresh,			Cmd_Release,			Cmd_Resize,			Cmd_See,
		Cmd_Selected,			Cmd_Set,					Cmd_Set_,				Cmd_Show,			Cmd_Toggle,
		Cmd_Toplevel,			Cmd_Toplevels,			Cmd_Uid,					Cmd_Undock,			Cmd_Visible,
		Cmd_NULL
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
			case Cmd_Amalgamatable:	execute(cmdAmalgamatable, false, objc, objv); break;
			case Cmd_Amalgamated:	execute(cmdAmalgamated, false, objc, objv); break;
			case Cmd_Clone:			execute(cmdClone, false, objc, objv); break;
			case Cmd_Close:			execute(cmdClose, true, objc, objv); break;
			case Cmd_ChangeUid:		execute(cmdChangeUid, true, objc, objv); break;
			case Cmd_Container:		execute(cmdContainer, false, objc, objv); break;
			case Cmd_Dimension:		execute(cmdDimension, false, objc, objv); break;
			case Cmd_Dock:				execute(cmdDock, false, objc, objv); break;
			case Cmd_Dump:				execute(cmdDump, false, objc, objv); break;
			case Cmd_EqP:				execute(cmdEqP, false, objc, objv); break;
			case Cmd_Exists:			cmdExists(objc, objv); break;
			case Cmd_Find:				execute(cmdFind, false, objc, objv); break;
			case Cmd_Floats:			execute(cmdFloats, false, objc, objv); break;
			case Cmd_Frames:			execute(cmdFrames, false, objc, objv); break;
			case Cmd_Get:				// fallthru
			case Cmd_Get_:				execute(cmdGet, false, objc, objv); break;
			case Cmd_HeaderFrames:	execute(cmdHeaderFrames, false, objc, objv); break;
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
			case Cmd_Ready:			execute(cmdReady, false, objc, objv); break;
			case Cmd_Refresh:			execute(cmdRefresh, false, objc, objv); break;
			case Cmd_Resize:			execute(cmdResize, false, objc, objv); break;
			case Cmd_See:				execute(cmdSee, false, objc, objv); break;
			case Cmd_Selected:		execute(cmdSelected, false, objc, objv); break;
			case Cmd_Set:				// fallthru
			case Cmd_Set_:				execute(cmdSet, false, objc, objv); break;
			case Cmd_Show:				execute(cmdShow, false, objc, objv); break;
			case Cmd_Toggle:			execute(cmdToggle, false, objc, objv); break;
			case Cmd_Toplevel:		execute(cmdToplevel, false, objc, objv); break;
			case Cmd_Toplevels:		execute(cmdToplevels, false, objc, objv); break;
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
