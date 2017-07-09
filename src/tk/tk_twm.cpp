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

#undef None // defined via tk.h


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


namespace {

static Tcl_Obj* m_obj							= nullptr;
static Tcl_Obj* m_objBoth						= nullptr;
static Tcl_Obj* m_objDestroyCmd				= nullptr;
static Tcl_Obj* m_objDirsLR					= nullptr;
static Tcl_Obj* m_objDirsTB					= nullptr;
static Tcl_Obj* m_objDirsTBLR					= nullptr;
static Tcl_Obj* m_objDirsTBLREW				= nullptr;
static Tcl_Obj* m_objDirsTBLRNS				= nullptr;
static Tcl_Obj* m_objDirsTBLRNSEW			= nullptr;
static Tcl_Obj* m_objFrame						= nullptr;
static Tcl_Obj* m_objFrame2					= nullptr;
static Tcl_Obj* m_objFrameHdrSizeCmd		= nullptr;
static Tcl_Obj* m_objOptGrow					= nullptr;
static Tcl_Obj* m_objHeaderCmd				= nullptr;
static Tcl_Obj* m_objHorizontal				= nullptr;
static Tcl_Obj* m_objHorz						= nullptr;
static Tcl_Obj* m_objMetaFrame				= nullptr;
static Tcl_Obj* m_objMultiWindow				= nullptr;
static Tcl_Obj* m_objNotebook					= nullptr;
static Tcl_Obj* m_objNotebookHdrSizeCmd	= nullptr;
static Tcl_Obj* m_objOptBefore				= nullptr;
static Tcl_Obj* m_objOptExpand				= nullptr;
static Tcl_Obj* m_objOptHeader				= nullptr;
static Tcl_Obj* m_objOptHeight				= nullptr;
static Tcl_Obj* m_objOptMaxHeight			= nullptr;
static Tcl_Obj* m_objOptMaxWidth				= nullptr;
static Tcl_Obj* m_objOptMinHeight			= nullptr;
static Tcl_Obj* m_objOptMinWidth				= nullptr;
static Tcl_Obj* m_objOptOrient				= nullptr;
static Tcl_Obj* m_objOptShrink				= nullptr;
static Tcl_Obj* m_objOptSticky				= nullptr;
static Tcl_Obj* m_objOptWidth					= nullptr;
static Tcl_Obj* m_objPackCmd					= nullptr;
static Tcl_Obj* m_objPaneConfigCmd			= nullptr;
static Tcl_Obj* m_objPanedWindow				= nullptr;
static Tcl_Obj* m_objPane						= nullptr;
static Tcl_Obj* m_objResizedCmd				= nullptr;
static Tcl_Obj* m_objSashSizeCmd				= nullptr;
static Tcl_Obj* m_objSelectCmd				= nullptr;
static Tcl_Obj* m_objUnpackCmd				= nullptr;
static Tcl_Obj* m_objVert						= nullptr;
static Tcl_Obj* m_objVertical					= nullptr;
static Tcl_Obj* m_objX							= nullptr;
static Tcl_Obj* m_objY							= nullptr;

class Node;
typedef mstl::vector<Node*> Childs;

enum Type		{ Root, MetaFrame, Frame, Pane, PanedWindow, MultiWindow, Notebook, LAST = Notebook };
enum State		{ Packed, Floating, Withdrawn };
enum Sticky		{ West = 1, East = 2, North = 4, South = 8 };
enum Position	{ Center = 0, Left = West, Right = East, Top = North, Bottom = South };
enum Orient		{ Horz = Left|Right, Vert = Top|Bottom };
enum Expand		{ None = 0, X = Horz, Y = Vert, Both = X|Y };
enum Quantity	{ Actual, Min, Max };
enum Enclosure	{ Inner, Outer };


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
parseExpandOption(const char* s)
{
	M_ASSERT(s);

	if (tcl::equal(s, "both"))	return X | Y;
	if (tcl::equal(s, "x"))		return X;
	if (tcl::equal(s, "y"))		return Y;
	if (tcl::equal(s, "none"))	return 0;

	M_THROW(tcl::Exception("invalid expand option '%s'", s));
}


static int parseResizeOption(const char* s) { return parseExpandOption(s); }


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

			default:
				M_THROW(tcl::Exception("invalid sticky option '%s'", s));
		}
	}

	return sticky;
}


static Orient
parseOrientOption(const char* s)
{
	M_ASSERT(s);

	if (tcl::equal(s, m_objHorz) || tcl::equal(s, m_objHorizontal))	return Horz;
	if (tcl::equal(s, m_objVert) || tcl::equal(s, m_objVertical))		return Vert;

	M_THROW(tcl::Exception("invalid orientation '%s'", s));
}


struct Terminated {};


struct Size
{
	Size() :width(0), height(0) {}

	int width;
	int height;

	void zero() { width = height = 0; }

	template <Orient D> int dimen() const;
};

template <> int Size::dimen<Horz>() const { return width; }
template <> int Size::dimen<Vert>() const { return height; }

bool
operator!=(Size const& lhs, Size const& rhs)
{
	return lhs.width != rhs.width || lhs.height != rhs.height;
}


typedef mstl::map<mstl::string,Size> SizeMap;

struct Snapshot
{
	Size				size;
	mstl::string	structure;
	SizeMap			sizeMap;
};


struct Dimension
{
	Size min;
	Size max;
	Size actual;

	template <Orient D,Quantity Q = Actual> int dimen() const;
	template <Orient D,Quantity Q = Actual> void set(int size) __m_warn_unused;

	void setActual(int width, int height);
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


struct Base
{
	Base() :root(nullptr), setup(nullptr) {}

	Node* root;
	Node* setup;
};


class Node
{
public:

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
	bool isPaneOrFrame() const;
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
	bool contains(Node const* node) const;
	bool exists() const;

	template <Orient D> bool grow() const;
	template <Orient D> bool shrink() const;
	template <Orient D> bool orientation() const;

	unsigned numChilds() const;
	unsigned countPackedChilds() const;
	unsigned descendantOf(Node const* child) const;
	int frameHeaderSize() const;
	int notebookHeaderSize() const;
	Tk_Window tkwin() const;
	char const* uid() const;
	char const* path() const;
	char const* oldPath() const;
	char const* id() const; // for debugging
	Tcl_Obj* uidObj() const;
	Tcl_Obj* pathObj() const;
	Tcl_Obj* typeObj() const;
	int expand() const;
	int sticky() const;
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
	Node* clone() const __m_warn_unused;

	tcl::List collectFrames() const;
	tcl::List collectPanes() const;
	tcl::List collectContainer() const;
	tcl::List collectVisible() const;

	Node const* child(unsigned i) const;
	Node* child(unsigned i);

	Node const* child() const;
	Node* child();

	void setState(State state);
	void updateDimen(int width, int height);
	void perform(Node* toplevel = nullptr);

	Node* findPath(char const* path);
	Node* getCurrent() const;
	Node* skipMetaFrame();
	Node const* leftNeighbor(Node const* neighbor) const;
	Node const* rightNeighbor(Node const* neighbor) const;
	Node const* findLeader() const;

	void set(char const* attribute, Tcl_Obj* value);
	Tcl_Obj* get(char const* attribute) const;

	void load(Tcl_Obj* list);
	void create();
	void destroy();
	void pack();
	void reparentChildsRecursively(Tk_Window topLevel);
	void select();
	void selected();
	void configure();
	void withdraw();
	void unpack();
	void packChilds();
	void remove(Node* node);
	void remove();
	void floating(bool temporary);
	void unfloat(Node* toplevel);
	void destroyed(bool finalize);
	void makeMetaFrame();
	void dump() const;

	Node* dock(Node*& recv, Position position);

	Tcl_Obj* makeOptions(Node const* before = nullptr) const __m_warn_unused;
	Tcl_Obj* makeConfigOptions(Tcl_Obj* list = nullptr) const;
	void parseOptions(Tcl_Obj* opts);

	static bool isRoot(Type type);
	static bool isMetaFrame(Type type);
	static bool isContainer(Type type);

	static Base* createBase(Tcl_Obj* path) __m_warn_unused;
	static void removeBase(char const* path);
	static Base* lookupBase(char const* path);
	static Node* makeRoot(Tcl_Obj* path);

private:

	typedef mstl::map<mstl::string,Tcl_Obj*> AttrMap;
	typedef mstl::map<mstl::string,Snapshot> SnapshotMap;

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
	};

	Node(Tcl_Obj* path, Node const* setup = nullptr);
	Node(Node& parent, Type type, Tcl_Obj* uid = nullptr);
	Node(Node const& node);

	bool isUsed(Node const* node) const;
	bool hasAncestor(Node const* parent) const;

	Childs::const_iterator begin() const;
	Childs::const_iterator end() const;

	Childs::iterator find(Node const* node);
	Childs::const_iterator find(Node const* node) const;
	Node const* findAfter(bool onlyPackedChild = false) const;
	Node const* findAfter(Node const* node) const;
	Position defaultPosition() const;
	void collectFrames(tcl::List& result) const;
	void collectPanes(tcl::List& result) const;
	void collectContainer(tcl::List& result) const;
	void collectVisible(tcl::List& result) const;
	void collectPackedChilds(tcl::List& list);

	void move(Node* node, Node const* before = nullptr);
	void doMove(Node* node, Node const* before = nullptr);
	void add(Node* node, Node const* before = nullptr);

	void computeDimensions();
	void adjustDimensions();
	void unframe();
	void flatten();
	void withdrawn();

	void setWidth(int width);
	void setHeight(int height);
	template <Orient D,Quantity Q = Actual> void addDimen(Node const* node);
	void resetToWithdrawn();

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

	Node* insertNotebook(Node* child, Type type);
	Node* insertMultiWindow(Node* child);
	Node* insertPanedWindow(Position position, Node* child);
	Node* clone(Node* parent) const __m_warn_unused;
	Node* prepareDocking(Position& position, Node const*& after);
	Node* dock(Node* node, Position position, Node const* before, bool newParent);

	void insertNode(Node* node, Node const* before = nullptr);
	void remove(Childs::iterator pos);
	void removeFromOldParent();
	void updateAllHeaders();
	void updateHeader();

	void addFlag(unsigned flag);
	void delFlag(unsigned flag);
	void clearFlags();
	bool testFlags(unsigned flag) const;

	void makeSnapshot();
	bool makeSnapshot(mstl::string& structure, SizeMap* sizeMap);
	void makeSnapshotKey(mstl::string& structure);
	bool applySnapshot();
	void applySnapshot(double scaleWidth, double scaleHeight, SizeMap const& sizeMap);

	void performCreate();
	void performFinalizeCreate();
	void performPack();
	void performUnpack(Node* parent);
	void performConfig();
	void performResize();
	void performSelect();
	void performDestroy();
	void performUpdateHeader();
	void performUpdateHeaderRecursively();
	void performConfigRecursively();
	void performCreateRecursively();
	void performPackRecursively();
	void performFlattenRecursively();
	void performRestructureRecursively();
	void performPackChildsRecursively();
	void performUnpackChildsRecursively();
	void performAllActiveNodes(Flag flag);
	void performDeleteInactiveNodes();
	void performUpdateDimensions();
	void performRaiseRecursively(bool needed = false);
	void performQuerySashSize();
	static void performQueryFrameHeaderSize(ClientData clientData);
	static void performQueryNotebookHeaderSize(ClientData clientData);

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
	Node*			m_origParent;
	Node*			m_savedParent;
	Node*			m_selected;
	int			m_sashSize;
	int			m_frameHeaderSize;
	int			m_notebookHeaderSize;
	Dimension	m_dimen;
	Size			m_actual;
	int			m_orientation;
	int			m_expand;
	int			m_sticky;
	int			m_shrink;
	int			m_grow;
	Tcl_Obj*		m_oldPath;
	Tcl_Obj*		m_headerObj;
	Tcl_Obj*		m_oldHeaderObj;
	Childs		m_active;
	Childs		m_deleted;
	AttrMap		m_attrMap;
	Node*			m_current;
	unsigned		m_flags;
	SnapshotMap	m_snapshotMap;
	bool			m_isDeleted;
	bool			m_isDestroyed;
	bool			m_isLocked;
	bool			m_hideHeader;
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
		{
			Node* node = static_cast<Node*>(clientData);

			if (!node->isDeleted())
				node->updateDimen(event->xconfigure.width, event->xconfigure.height);
			break;
		}

		case DestroyNotify:
			static_cast<Node*>(clientData)->destroyed(false);
			break;

		case MapNotify:
			static_cast<Node*>(clientData)->configure();
			static_cast<Node*>(clientData)->selected();
			break;

		case UnmapNotify:
			static_cast<Node*>(clientData)->destroyed(true);
			break;
	}
}


namespace {

Node* Node::root() const						{ return m_root; }
Node* Node::parent() const						{ return m_parent; }
Node* Node::clone() const						{ return clone(nullptr); }
Node const* Node::child(unsigned i) const { return m_childs[i]; }
Node* Node::child(unsigned i)					{ return m_childs[i]; }

bool Node::isContainer(Type type)
{ return type == MultiWindow || type == Notebook || type == PanedWindow; }

bool Node::isRoot(Type type)						{ return type == Root; }
bool Node::isMetaFrame(Type type)				{ return type == MetaFrame; }
bool Node::isRoot() const							{ return isRoot(m_type); }
bool Node::isPanedWindow() const					{ return m_type == PanedWindow; }
bool Node::isMultiWindow() const					{ return m_type == MultiWindow; }
bool Node::isNotebook() const						{ return m_type == Notebook; }
bool Node::isFrame() const							{ return m_type == Frame; }
bool Node::isMetaFrame() const					{ return isMetaFrame(m_type); }
bool Node::isPane() const							{ return m_type == Pane; }
bool Node::isPaneOrFrame() const					{ return m_type == Pane || m_type == Frame; }
bool Node::isFrameOrMetaFrame() const			{ return isFrame() || isMetaFrame(); }
bool Node::isNotebookOrMultiWindow() const	{ return isNotebook() || isMultiWindow(); }
bool Node::isContainer() const					{ return isContainer(m_type); }
bool Node::isEmpty() const							{ return m_childs.empty(); }
bool Node::isPacked() const						{ return m_state == Packed; }
bool Node::isWithdrawn() const					{ return m_state == Withdrawn; }
bool Node::isDeleted() const						{ return m_isDeleted; }
bool Node::isDestroyed() const					{ return m_isDestroyed; }
bool Node::isFloating() const						{ return m_state == Floating; }
bool Node::isToplevel() const						{ return isRoot() || isFloating(); }
bool Node::isLocked() const						{ return m_root->m_isLocked; }
bool Node::isHorz() const							{ return m_orientation == Horz; }
bool Node::isVert() const							{ return m_orientation == Vert; }
bool Node::hasChilds() const						{ return !m_childs.empty(); }

int Node::sticky() const { return m_sticky; }

Childs::const_iterator Node::begin() const	{ return m_childs.begin(); }
Childs::const_iterator Node::end() const		{ return m_childs.end(); }

bool Node::contains(Node const* node) const	{ return find(node) != end(); }

template <Orient D> bool Node::isExpandable() const { return bool(expand() & D); }

template <Orient D> bool Node::grow() const			{ return m_grow & D; }
template <Orient D> bool Node::shrink() const		{ return m_shrink & D; }
template <Orient D> bool Node::orientation() const	{ return m_orientation & D; }

char const* Node::uid() const				{ return tcl::asString(m_uid); }
char const* Node::path() const			{ return tcl::asString(m_path); }
char const* Node::oldPath() const		{ return tcl::asString(m_oldPath); }
char const* Node::id() const				{ return m_uid ? uid() : (m_path ? path() : "null"); }

Tcl_Obj* Node::uidObj() const				{ return m_uid; }

unsigned Node::numChilds() const			{ return m_childs.size(); }
Tk_Window Node::tkwin() const				{ return tk::window(m_path); }
bool Node::exists() const					{ return m_path && tk::exists(m_path); }

void Node::remove(Node* node)				{ remove(find(node)); }
void Node::setWidth(int width)			{ m_dimen.set<Horz>(width); }
void Node::setHeight(int height)			{ m_dimen.set<Vert>(height); }
void Node::setState(State state)			{ m_state = state; }

void Node::addFlag(unsigned flag)		{ m_flags |= flag; }
void Node::delFlag(unsigned flag)		{ m_flags &= ~flag; }

bool Node::testFlags(unsigned flag) const { return m_flags & flag; }

unsigned Node::descendantOf(Node const* child) const { return descendantOf(child, 1); }

int Node::frameHeaderSize() const
{ return m_root->m_frameHeaderSize ? m_root->m_frameHeaderSize : 22; }

int Node::notebookHeaderSize() const
{ return m_root->m_notebookHeaderSize ? m_root->m_notebookHeaderSize : 24; }

void Node::makeSnapshotKey(mstl::string& key) { makeSnapshot(key, nullptr); }


template <Orient D>
int
Node::contentSize(int size) const
{
	if (D == Vert && size > 0)
	{
		if (isNotebook())
			size = mstl::max(0, size - notebookHeaderSize());
		else if (isFrameOrMetaFrame() && m_headerObj)
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
		else if (isFrameOrMetaFrame() && m_headerObj)
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


Node*
Node::child()
{
	M_ASSERT(countPackedChilds() == 1);

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isPacked())
			return child(i);
	}

	return nullptr; // should be never reached
}


Node const*
Node::child() const
{
	return const_cast<Node*>(this)->child();
}


Tcl_Obj*
Node::pathObj() const
{
	return m_path ? m_path : (m_isDeleted ? m_oldPath : nullptr);
}


void
Node::clearFlags()
{
	m_flags = 0;
	m_savedParent = nullptr;
}


Node const*
Node::leftNeighbor(Node const* neighbor) const
{
	M_ASSERT(neighbor);
	M_ASSERT(isPanedWindow());
	M_ASSERT(contains(neighbor));

	Childs::const_iterator i = find(neighbor);

	do
	{
		if (i == begin())
			return nullptr;

		--i;
	}
	while (!(*i)->isPacked());

	return *i;
}


Node const*
Node::rightNeighbor(Node const* neighbor) const
{
	M_ASSERT(neighbor);
	M_ASSERT(isPanedWindow());
	M_ASSERT(contains(neighbor));

	Childs::const_iterator i = find(neighbor);

	do
	{
		if (++i == end())
			return nullptr;
	}
	while (!(*i)->isPacked());

	return *i;
}


Node const*
Node::findLeader() const
{
	if (isPaneOrFrame())
		return this;
	
	int priority = mstl::numeric_limits<int>::min();
	Node const *node = nullptr;

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isPacked())
		{
			Node const* leader = child(i)->findLeader();

			if (!node || leader->m_priority > priority)
			{
				node = leader;
				priority = leader->m_priority;
			}
		}
	}

	return node;
}


void
Node::create()
{
	M_ASSERT(isWithdrawn());
	M_ASSERT(!exists());
	M_ASSERT(!testFlags(F_Create));

	addFlag(F_Create);
	addFlag(F_Raise);
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

	if (m_parent && m_parent->m_selected == this)
		m_parent->m_selected = nullptr;
	
	tcl::zero(m_headerObj);

	addFlag(F_Unpack);
	delFlag(F_Pack);
	delFlag(F_Select);
}


void
Node::selected()
{
	if (m_parent && m_parent->isNotebookOrMultiWindow())
		m_parent->m_selected = this;
}


void
Node::configure()
{
	if (isFrameOrMetaFrame())
	{
		if (m_root->m_frameHeaderSize == 0 && m_headerObj)
			Tcl_DoWhenIdle(performQueryFrameHeaderSize, this);
	}
	else if (isNotebook())
	{
		if (m_root->m_notebookHeaderSize == 0)
			Tcl_DoWhenIdle(performQueryNotebookHeaderSize, this);
	}
}


void
Node::select()
{
	M_ASSERT(!testFlags(F_Unpack));
	M_ASSERT(!testFlags(F_Destroy));

	addFlag(F_Select);
	selected();
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
	,m_origParent(&parent)
	,m_savedParent(nullptr)
	,m_selected(nullptr)
	,m_sashSize(0)
	,m_frameHeaderSize(0)
	,m_notebookHeaderSize(0)
	,m_orientation(0)
	,m_expand(None)
	,m_sticky(0)
	,m_shrink(0)
	,m_grow(0)
	,m_oldPath(nullptr)
	,m_headerObj(nullptr)
	,m_oldHeaderObj(nullptr)
	,m_current(nullptr)
	,m_flags(0)
	,m_isDeleted(false)
	,m_isDestroyed(false)
	,m_isLocked(false)
	,m_hideHeader(false)
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
	,m_origParent(nullptr)
	,m_savedParent(nullptr)
	,m_selected(nullptr)
	,m_sashSize(0)
	,m_frameHeaderSize(0)
	,m_notebookHeaderSize(0)
	,m_orientation(0)
	,m_expand(None)
	,m_sticky(0)
	,m_shrink(0)
	,m_grow(0)
	,m_oldPath(nullptr)
	,m_headerObj(nullptr)
	,m_oldHeaderObj(nullptr)
	,m_current(nullptr)
	,m_flags(0)
	,m_isDeleted(false)
	,m_isDestroyed(false)
	,m_isLocked(false)
	,m_hideHeader(false)
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

		if ((m_uid = setup->m_uid))
			tcl::incrRef(m_uid);
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
	,m_origParent(nullptr)
	,m_savedParent(nullptr)
	,m_selected(nullptr)
	,m_sashSize(node.m_sashSize)
	,m_frameHeaderSize(node.m_frameHeaderSize)
	,m_notebookHeaderSize(node.m_notebookHeaderSize)
	,m_dimen(node.m_dimen)
	,m_actual(node.m_actual)
	,m_orientation(node.m_orientation)
	,m_expand(node.m_expand)
	,m_sticky(node.m_sticky)
	,m_shrink(node.m_shrink)
	,m_grow(node.m_grow)
	,m_oldPath(nullptr)
	,m_headerObj(nullptr)
	,m_oldHeaderObj(nullptr)
	,m_current(nullptr)
	,m_flags(0)
	,m_isDeleted(false)
	,m_isDestroyed(false)
	,m_isLocked(false)
	,m_hideHeader(false)
	,m_temporary(false)
	,m_dumpFlag(false)
{
	tcl::incrRef(m_path);
	tcl::incrRef(m_uid);
}


Node::~Node()
{
	if (m_path && tk::exists(path()))
		tk::deleteEventHandler(tkwin(), StructureNotifyMask, ::WindowEventProc, this);

	for (Childs::iterator i = m_deleted.begin(); i != m_deleted.end(); ++i)
		delete *i;

	if (isRoot())
	{
		for (Childs::iterator i = m_active.begin(); i != m_active.end(); ++i)
			delete *i;
	}
	else
	{
		if (!isWithdrawn())
			::fprintf(stderr, "window '%s' is not withdrawn\n", path());
	}

	tcl::decrRef(m_path);
	tcl::decrRef(m_uid);
	tcl::decrRef(m_oldPath);
	tcl::decrRef(m_headerObj);
	tcl::decrRef(m_oldHeaderObj);

	for (AttrMap::iterator i = m_attrMap.begin(); i != m_attrMap.end(); ++i)
		tcl::decrRef(i->second);
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
Node::set(char const* attribute, Tcl_Obj* value)
{
	M_ASSERT(attribute);
	M_ASSERT(value);

	Tcl_Obj*& obj = m_attrMap[attribute];

	if (tcl::equal(attribute, "priority") && tcl::isInt(value))
		m_priority = tcl::asInt(value);

	tcl::decrRef(obj);
	obj = tcl::incrRef(value);
}


Tcl_Obj*
Node::get(char const* attribute) const
{
	M_ASSERT(attribute);

	AttrMap::const_iterator i = m_attrMap.find(attribute);
	return i == m_attrMap.end() ? nullptr : i->second;
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
Node::hasAncestor(Node const* parent) const
{
	Node const* node = this;

	do
	{
		if (node == parent)
			return true;
		node = node->m_parent;
	}
	while (node);

	return false;
}


void
Node::collectFrames(tcl::List& result) const
{
	if (isFrame())
	{
		result.push_back(m_path);
	}
	else
	{
		for (unsigned i = 0; i < numChilds(); ++i)
		{
			if (child(i)->isPacked())
				child(i)->collectFrames(result);
		}
	}
}


void
Node::collectPanes(tcl::List& result) const
{
	if (isPane())
	{
		result.push_back(m_path);
	}
	else
	{
		for (unsigned i = 0; i < numChilds(); ++i)
		{
			if (child(i)->isPacked())
				child(i)->collectPanes(result);
		}
	}
}


void
Node::collectContainer(tcl::List& result) const
{
	if (isContainer())
		result.push_back(m_path);

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isPacked())
			child(i)->collectContainer(result);
	}
}


void
Node::collectVisible(tcl::List& result) const
{
	if (m_temporary || !(isPacked() || isToplevel()) || (isToplevel() && isFrame()))
		return;
	
	if (!(isRoot() || isMetaFrame() || (m_parent->isMetaFrame() && !m_parent->isFloating())))
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
			child(i)->collectVisible(result);
	}
	else if (m_selected && m_selected->isMetaFrame())
	{
		M_ASSERT(isNotebookOrMultiWindow());
		m_selected->collectVisible(result);
	}
}


tcl::List
Node::collectFrames() const
{
	tcl::List result;
	collectFrames(result);
	return result;
}


tcl::List
Node::collectPanes() const
{
	tcl::List result;
	collectPanes(result);
	return result;
}


tcl::List
Node::collectContainer() const
{
	tcl::List result;
	collectContainer(result);
	return result;
}


tcl::List
Node::collectVisible() const
{
	tcl::List result;
	collectVisible(result);
	return result;
}


void
Node::collectPackedChilds(tcl::List& list)
{
	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isPacked())
			list.push_back(child(i)->isMetaFrame() ? child(i)->child()->pathObj() : child(i)->pathObj());
	}
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


int
Node::expand() const
{
	if (!hasChilds())
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
Node::updateDimen(int width, int height)
{
	if (width > 1 && height > 1)
	{
		if (isLocked())
		{
			m_actual.width = contentSize<Horz>(width);
			m_actual.height = contentSize<Vert>(height);
		}
		else
		{
			m_dimen.actual.width = contentSize<Horz>(width);
			m_dimen.actual.height = contentSize<Vert>(height);
		}
	}
}


template <Orient D>
int
Node::computeExpand(int stage) const
{
	M_ASSERT(stage == 1 || stage == 2);

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
	if (!hasChilds())
		return actualSize<Outer,D>();
	
	int totalSize = 0;

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isPacked())
		{
			int size = child(i)->computeDimen<D>();

			if (orientation<D>())
				totalSize += size + (totalSize ? m_root->m_sashSize : 0);
			else
				totalSize = mstl::max(totalSize, size);
		}
	}

	return frameSize<D>(totalSize);
}


template <Orient D,Quantity Q>
void
Node::addDimen(Node const* node)
{
	if (Q == Actual || node->dimen<Inner,D,Q>())
	{
		int nodeSize = node->dimen<Outer,D,Q>();

		m_dimen.set<D,Q>(orientation<D>()
			? dimen<Outer,D,Q>() + nodeSize + (dimen<Outer,D,Q>() ? m_root->m_sashSize : 0)
			: (Q == Max) ? mstl::min(dimen<Outer,D,Q>(), nodeSize) : mstl::max(dimen<Outer,D,Q>(), nodeSize));
	}
}


void
Node::computeDimensions()
{
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

		if (node->isPacked() || node->isToplevel())
			node->computeDimensions();

		if (node->isPacked())
		{
			if (needComputedWidth)
				addDimen<Horz>(node);
			if (needComputedHeight)
				addDimen<Vert>(node);
			addDimen<Horz,Min>(node);
			addDimen<Vert,Min>(node);
			addDimen<Horz,Max>(node);
			addDimen<Vert,Max>(node);
		}
	}
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
Node::withdrawn()
{
	m_state = Withdrawn;

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isPacked())
			child(i)->withdrawn();
	}
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
			M_ASSERT(!m_root->isUsed(this));

			Childs::iterator i = m_deleted.find(this);
			if (i != m_deleted.end())
			{
				delete *i;
				m_deleted.erase(i);
			}
		}
	}
	else
	{
		withdrawn();
		m_isDestroyed = true;

		if (!isRoot() && !isWithdrawn())
		{
			toplevel()->adjustDimensions();
			m_root->perform(toplevel());
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

	while (!parent->isFloating() && parent->m_parent)
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
Node::skipMetaFrame()
{
	Node* node = this;

	while (node->isMetaFrame())
		node = node->m_parent;
	
	return node;
}


Node*
Node::clone(Node* parent) const
{
	Node* node = new Node(*this);

	if ((node->m_parent = parent))
	{
		node->m_root = parent->m_root;
		node->m_root->m_active.push_back(node);
		node->m_origParent = parent->skipMetaFrame();
	}

	for (unsigned i = 0; i < numChilds(); ++i)
		node->insertNode(child(i)->clone(node));

	if (isPacked())
	{
		if (!isRoot())
			node->create();
		node->pack();
	}

	return node;
}


void
Node::unframe()
{
	M_ASSERT(m_path);
	M_ASSERT(m_path != m_oldPath);
	M_ASSERT(numChilds() == 1);
	//M_ASSERT(isWithdrawn() || isFloating());

	if (!isMetaFrame())
		return;

	Node* child = this->child();
	Node* origParent = child->m_origParent;
	State state = m_state;
	unsigned flags = m_flags;

	tk::deleteEventHandler(tkwin(), StructureNotifyMask, ::WindowEventProc, this);
	tk::deleteEventHandler(child->tkwin(), StructureNotifyMask, ::WindowEventProc, child);

	mstl::swap(m_type, child->m_type);
	mstl::swap(m_state, child->m_state);
	mstl::swap(m_path, child->m_path);
	mstl::swap(m_uid, child->m_uid);
	mstl::swap(m_priority, child->m_priority);
	mstl::swap(m_childs, child->m_childs);
	// child->m_root
	child->m_parent = this;
	mstl::swap(m_origParent, child->m_origParent);
	mstl::swap(m_savedParent, child->m_savedParent);
	mstl::swap(m_selected, child->m_selected);
	// child->m_sashSize
	// child->m_frameHeaderSize
	// child->m_notebookHeaderSize
	mstl::swap(m_dimen, child->m_dimen);
	mstl::swap(m_actual, child->m_actual);
	mstl::swap(m_orientation, child->m_orientation);
	mstl::swap(m_expand, child->m_expand);
	mstl::swap(m_sticky, child->m_sticky);
	mstl::swap(m_shrink, child->m_shrink);
	mstl::swap(m_grow, child->m_grow);
	mstl::swap(m_oldPath, child->m_oldPath);
	mstl::swap(m_headerObj, child->m_headerObj);
	mstl::swap(m_oldHeaderObj, child->m_oldHeaderObj);
	mstl::swap(m_active, child->m_active);
	mstl::swap(m_deleted, child->m_deleted);
	mstl::swap(child->m_attrMap, m_attrMap);
	// child->m_current
	mstl::swap(m_flags, child->m_flags);
	mstl::swap(child->m_snapshotMap, m_snapshotMap);
	mstl::swap(m_isDeleted, child->m_isDeleted);
	// child->m_isDestroyed
	// child->m_isLocked
	mstl::swap(m_hideHeader, child->m_hideHeader);
	// child->m_temporary
	// child->m_dumpFlag

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (this->child(i)->m_parent == child)
			this->child(i)->m_parent = this;
	}

	if (flags & F_Pack)
		addFlag(F_Pack);
	delFlag(F_Unpack);
	if (!m_savedParent)
		m_savedParent = child;
	m_state = state;

	child->m_state = Withdrawn;
	child->m_isDeleted = true;
	child->destroy();

	Childs& active = m_root->m_active;

	for (unsigned i = 0; i < active.size(); ++i)
	{
		Node* node = active[i];

		if (node->m_origParent == child)
			node->m_origParent = this;
	}

	if (origParent && origParent != m_parent)
	{
		for (unsigned i = 0; i < origParent->numChilds(); ++i)
		{
			if (origParent->child(i) == child)
				origParent->m_childs[i] = this;
		}
	}

	tk::createEventHandler(tkwin(), StructureNotifyMask, ::WindowEventProc, this);
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
	{
		if (this->child(i)->m_parent == this)
			this->child(i)->m_parent = child;
	}

	// Reset the child

	// child->m_type
	child->m_state = Packed;
	// child->m_path
	// child->m_uid
	// child->m_priority
	child->m_childs.swap(m_childs);
	child->m_root = m_root;
	child->m_parent = this;
	child->m_origParent = m_origParent;
	// child->m_savedParent
	// child->m_selected
	// child->m_sashSize
	// child->m_frameHeaderSize
	// child->m_notebookHeaderSize
	// child->m_dimen
	// child->m_actual
	// child->m_orientation
	// child->m_expand
	// child->m_sticky
	// child->m_shrink
	// child->m_grow
	// child->m_oldPath
	// child->m_headerObj
	// child->m_oldHeaderObj
	// child->m_active
	// child->m_deleted
	mstl::swap(child->m_attrMap, m_attrMap);
	// child->m_current
	child->m_flags = 0; // Ok?
	mstl::swap(child->m_snapshotMap, m_snapshotMap);
	// child->m_isDeleted
	// child->m_isDestroyed
	// child->m_isLocked
	// child->m_hideHeader
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
	// m_origParent
	m_savedParent = nullptr;
	m_selected = nullptr;
	// m_sashSize
	// m_frameHeaderSize
	// m_notebookHeaderSize
	// m_dimen
	// m_actual
	m_orientation = 0;
	// m_expand
	// m_sticky
	// m_shrink
	// m_grow
	tcl::zero(m_oldPath);
	tcl::zero(m_headerObj);
	tcl::zero(m_oldHeaderObj);
	// m_active
	// m_deleted
	// m_attrMap // TODO should we copy?
	// m_current
	m_flags = 0;
	// m_snapshotMap
	// m_isDeleted
	// m_isDestroyed
	// m_isLocked
	m_hideHeader = child->m_hideHeader;
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

	Childs& active = m_root->m_active;

	for (unsigned i = 0; i < active.size(); ++i)
	{
		Node* node = active[i];

		if (node->m_origParent == this)
			node->m_origParent = child;
	}

	if (isPacked)
		pack();

	if (child->exists())
		tk::createEventHandler(child->tkwin(), StructureNotifyMask, ::WindowEventProc, child);
}


#if 0
void
Node::makeMetaFrame()
{
	M_ASSERT(!isRoot());
	M_ASSERT(!isMetaFrame());
	M_ASSERT(!m_savedParent);

	bool isPacked = this->isPacked();

	if (isPacked)
		unpack();

	Node* metaFrame = new Node(*this);

	metaFrame->m_type = MetaFrame;
	metaFrame->m_state = m_state;
	tcl::zero(metaFrame->m_path);
	tcl::zero(metaFrame->m_uid);
	metaFrame->m_priority = 0;
	metaFrame->m_childs.push_back(child);
	metaFrame->m_root = m_root;
	metaFrame->m_parent = m_parent;
	metaFrame->m_origParent = m_origParent;
	// metaFrame->m_savedParent
	// metaFrame->m_selected
	// metaFrame->m_sashSize
	// metaFrame->m_frameHeaderSize
	// metaFrame->m_notebookHeaderSize
	// metaFrame->m_dimen
	// metaFrame->m_actual
	metaFrame->m_orientation = 0;
	// metaFrame->m_expand
	// metaFrame->m_sticky
	// metaFrame->m_shrink
	// metaFrame->m_grow
	tcl::zero(metaFrame->m_oldPath);
	// metaFrame->m_headerObj
	// metaFrame->m_oldHeaderObj
	// metaFrame->m_active
	// metaFrame->m_deleted
	// metaFrame->m_attrMap // TODO should we copy?
	// metaFrame->m_current
	// metaFrame->m_flags
	// metaFrame->m_snapshotMap
	// metaFrame->m_isDeleted
	// metaFrame->m_isDestroyed
	// metaFrame->m_isLocked
	metaFrame->m_hideHeader = m_hideHeader;
	// metaFrame->m_temporary
	// metaFrame->m_dumpFlag

	if (isPacked)
		metaFrame->pack();

	m_state = Withdrawn;
	m_parent = metaFrame;
	pack();

	Childs& active = m_root->m_active;
	for (unsigned i = 0; i < active.size(); ++i)
	{
		if (active[i] == this)
			active[i] = metaFrame;
	}
}
#endif


Node*
Node::insertNotebook(Node* newChild, Type type)
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
	nb->move(newChild);
	nb->packChilds();
	if (isPacked)
		nb->pack();
	return nb;
}


Node*
Node::insertPanedWindow(Position position, Node* newChild)
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
	if (position == Left || position == Top)
		{ pw->move(newChild); pw->move(this); }
	else
		{ pw->move(this); pw->move(newChild); }
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
Node::prepareDocking(Position& position, Node const*& after)
{
	M_ASSERT(m_parent);
	M_ASSERT(m_parent->isContainer() || m_parent->isMetaFrame() || m_parent->isRoot());
	M_ASSERT(m_path);
	M_ASSERT(!isPacked());
	M_ASSERT(m_origParent);

	Node* parent = m_origParent;
	unsigned descendantLevel = mstl::numeric_limits<unsigned>::max();

	if (parent && parent->isWithdrawn())
	{
		while (parent->m_parent && parent->m_parent->isWithdrawn())
			parent = parent->m_parent;
		if (parent->isMetaFrame())
			parent = parent->child();

		Childs childs;

		for (unsigned i = 0; i < parent->numChilds(); ++i)
		{
			Node* child = parent->child(i);

			if (child->isPacked() && child->m_parent == parent->m_parent)
				childs.push_back(child);
		}

		if (!childs.empty() && childs.size() == parent->countPackedChilds())
		{
			bool afterThis = false;

			parent->create();

			for (unsigned i = 0; i < parent->numChilds(); ++i)
			{
				Node* child = parent->child(i);

				if (child == this)
				{
					afterThis = true;
					descendantLevel = 0;
				}
				else if (child->isPacked())
				{
					child->unpack();
					child->remove();
					child->m_parent = parent;
					child->pack();

					if (afterThis)
						after = child;
				}
				else if (!afterThis)
				{
					if (unsigned level = child->descendantOf(this) < descendantLevel)
					{
						afterThis = true;
						descendantLevel = level;
					}
				}
			}

			parent->pack();
		}
		else
		{
			parent = m_parent;
			after = findAfter();
		}
	}
	else if (parent)
	{
		if (parent->isMetaFrame())
			parent = parent->child();

		Childs::iterator i = parent->find(this);

		if (i != parent->end() && ++i != parent->end())
			after = *i;
	}
	else
	{
		// TODO
		if ((parent = m_parent)->isMetaFrame())
			parent = parent->child();
		after = findAfter();
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
Node::doMove(Node* node, Node const* before)
{
	if (contains(node))
	{
		M_ASSERT(node->isFloating());

		if (node->m_parent != this)
		{
			node->remove();
			node->m_parent = this;
		}
		else if (before)
		{
			m_childs.erase(find(node));
			insertNode(node, before);
		}
	}
	else
	{
		Node* oldParent = node->m_parent;
		add(node, before);
		oldParent->remove(node);
	}
}


void
Node::move(Node* node, Node const* before)
{
	M_ASSERT(node);
	M_ASSERT(node->m_parent);
	M_ASSERT(!node->isPacked());
	M_ASSERT(!before || contains(before));

	if (node->isFloating())
	{
		Childs childs(node->m_parent->m_childs);

		for (unsigned i = 0; i < childs.size(); ++i)
		{
			M_ASSERT(m_origParent);

			Node* child = childs[i];

			if (child->isFloating() && child->m_origParent->hasAncestor(node->m_origParent))
			{
				if (child != node)
					doMove(child, findAfter(child));
			}
		}
	}

	doMove(node, before);
}


void
Node::removeFromOldParent()
{
	M_ASSERT(m_origParent);
	M_ASSERT(m_origParent->contains(this));

	if (m_origParent == m_parent)
		return;

	m_origParent->remove(this);

	if (m_origParent->isWithdrawn())
	{
		bool keep = false;

		for (unsigned i = 0; i < m_origParent->numChilds(); ++i)
		{
			if (	!m_origParent->child(i)->isPacked()
				&& m_origParent->child(i)->m_origParent == m_origParent)
			{
				keep = true;
			}
		}

		if (!keep)
			m_origParent->m_childs.clear();
	}

	m_origParent = m_parent->skipMetaFrame();
}


bool
Node::isUsed(Node const* node) const
{
	if (this == node)
		return true;
	
	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isUsed(node))
			return true;
	}

	return false;
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

	Node* node = *pos;

	m_childs.erase(pos);

	if (!node->m_isDeleted && !m_root->isUsed(node))
	{
		M_ASSERT(!node->isPacked());

		Childs& active = m_root->m_active;

		for (unsigned i = 0; i < active.size(); ++i)
		{
			if (active[i]->m_origParent == node)
				active[i]->m_origParent = active[i]->m_origParent->m_parent->skipMetaFrame();
		}

		if (node->exists())
			node->destroy();
		node->m_isDeleted = true;
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

		if (tcl::equal(name, m_objOptWidth))
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
			m_expand = ::parseExpandOption(tcl::asString(value));
		else if (tcl::equal(name, m_objOptSticky))
			m_sticky = ::parseStickyOption(tcl::asString(value));
		else if (tcl::equal(name, m_objOptShrink))
			m_shrink = ::parseResizeOption(tcl::asString(value));
		else if (tcl::equal(name, m_objOptGrow))
			m_grow = ::parseResizeOption(tcl::asString(value));
		else if (tcl::equal(name, m_objOptOrient))
			m_orientation = parseOrientOption(tcl::asString(value));
		else if (tcl::equal(name, m_objOptHeader))
			m_hideHeader = !tcl::asBoolean(value);
		else
			M_THROW(tcl::Exception("invalid option '%s'", name));
	}

	m_dimen.max.width = mstl::min(m_dimen.min.width, m_dimen.max.width);
	m_dimen.max.height = mstl::min(m_dimen.min.height, m_dimen.max.height);
}


Tcl_Obj*
Node::makeConfigOptions(Tcl_Obj* list) const
{
	int value;

	if ((value = width<Outer>()) > 0)
	{
		tcl::addElement(list, m_objOptWidth);
		tcl::addElement(list, tcl::newObj(value));
	}
	if ((value = height<Outer>()) > 0)
	{
		tcl::addElement(list, m_objOptHeight);
		tcl::addElement(list, tcl::newObj(value));
	}
	if ((value = minWidth<Outer>()) > 0)
	{
		tcl::addElement(list, m_objOptMinWidth);
		tcl::addElement(list, tcl::newObj(value));
	}
	if ((value = minHeight<Outer>()) > 0)
	{
		tcl::addElement(list, m_objOptMinHeight);
		tcl::addElement(list, tcl::newObj(value));
	}
	if ((value = maxWidth<Outer>()) > 0)
	{
		tcl::addElement(list, m_objOptMaxWidth);
		tcl::addElement(list, tcl::newObj(value));
	}
	if ((value = maxHeight<Outer>()) > 0)
	{
		tcl::addElement(list, m_objOptMaxHeight);
		tcl::addElement(list, tcl::newObj(value));
	}

	return list;
}


Tcl_Obj*
Node::makeOptions(Node const* before) const
{
	M_ASSERT(!before || before->isPacked());

	tcl::List optList;
	int value;

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
		char buf[4] = { 0, 0, 0, 0 };
		unsigned n = 0;

		if (value & North) buf[n++] = 'n';
		if (value & South) buf[n++] = 's';
		if (value & West)  buf[n++] = 'w';
		if (value & East)  buf[n++] = 'e';

		optList.push_back(m_objOptSticky);
		optList.push_back(tcl::newObj(buf, n));
	}
	if ((value = m_orientation))
	{
		optList.push_back(m_objOptOrient);
		optList.push_back(value == Horz ? m_objHorizontal : m_objVertical);
	}
	if (before)
	{
		optList.push_back(m_objOptBefore);
		optList.push_back(before->pathObj());
	}

	return makeConfigOptions(tcl::newObj(optList));
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


Node const*
Node::findAfter(Node const* node) const
{
	M_ASSERT(m_parent);

	unsigned level = mstl::numeric_limits<unsigned>::max();
	Node const* before = nullptr;

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		unsigned n = descendantOf(child(i));

		if (n == 0)
			return i + 1 == numChilds() ? nullptr : child(i + 1);

		if (n < level)
		{
			before = child(i);
			level = n;
		}
	}

	return before;
}


unsigned
Node::countPackedChilds() const
{
	unsigned count = 0;

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isPacked())
			count += 1;
	}

	return count;
}


void
Node::flatten()
{
	M_ASSERT(!m_parent || m_parent->contains(this));

	if (!(isContainer() || isMetaFrame()))
		return;
	
	unsigned count = countPackedChilds();

	if (isWithdrawn())
	{
		if (count == numChilds())
		{
			destroy();
			remove();
		}
		else if (!isMetaFrame() && numChilds() <= 1)
		{
			if (numChilds() == 0 || (child(0)->isPacked() && child(0)->m_parent == this))
				remove();
		}
	}

	if (!isPacked())
		return;

	if (count <= (isMetaFrame() ? 0 : 1))
	{
		Node const* before = findAfter();
		Node* parent = m_parent;
		Childs childs(m_childs);

		M_ASSERT(parent);

		for (unsigned i = 0; i < childs.size(); ++i)
		{
			Node* child = childs[i];
			//Node* oldParent = child->m_parent;

			if (child->isPacked())
			{
				child->unpack();
				parent->add(child, before);
				child->pack();
			}
			else
			{
				if (isMetaFrame() || (count > 0 && !child->isContainer()))
					parent->add(child, before);
			}
		}

		if (isPacked())
			unpack();
		destroy();
	}
	else if (isPanedWindow() && countPackedChilds() == numChilds())
	{
		Childs childs1(m_childs);

		for (unsigned i = 0; i < childs1.size(); ++i)
		{
			Node* node = childs1[i];

			if (	node->isPanedWindow()
				&& node->m_orientation == m_orientation
				&& node->countPackedChilds() == node->numChilds())
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
	else if (	isMetaFrame()
				&& !isFloating()
				&& (!m_parent->isNotebookOrMultiWindow() || child()->isFrame()))
	{
		M_ASSERT(countPackedChilds() == 1);

		Node const* before = findAfter();
		Childs childs(m_childs);

		m_childs.clear();

		for (unsigned i = 0; i < childs.size(); ++i)
		{
			Node* node = childs[i];

			if (node->isPacked())
				m_childs.push_back(node);
			else if (node->m_parent == this)
				m_parent->add(node, before);
			else
				m_parent->insertNode(node, before);
		}

		unframe();
		addFlag(F_Unframe);
	}
}


Node*
Node::dock(Node*& recv, Position position)
{
	M_ASSERT(m_parent);

	Node const* before = nullptr;
	bool newParent = bool(recv);

	if (!recv)
		recv = prepareDocking(position, before);
	
	M_ASSERT(recv);

	if (isFloating())
		unfloat(recv->toplevel());

	return recv->dock(this, position, before, newParent);
}


Node*
Node::dock(Node* node, Position position, Node const* before, bool newParent)
{
	M_ASSERT(m_parent);
	M_ASSERT(node);
	M_ASSERT(node->m_parent);

	if (node->isMetaFrame())
		node->unframe();

	Tk_Window tlw = toplevel()->tkwin();

	if (tk::parent(node->tkwin()) != tlw)
	{
		node->performUnpackChildsRecursively();
		tk::reparent(node->tkwin(), tlw);
		node->reparentChildsRecursively(tlw);
		node->performPackChildsRecursively();
	}

	node->m_state = Floating; // remember that this window was floating before

	Node* parent = this;

	switch (position)
	{
		case Center:
			if (!isNotebookOrMultiWindow())
			{
				Type nbType = MultiWindow; // isPane() || isFrame() ? MultiWindow : Notebook;
				insertNotebook(node, nbType);
			}
			else if (node->isNotebookOrMultiWindow())
			{
				Node const* before = findAfter();
				Childs childs(node->m_childs);

				for (unsigned i = 0; i < childs.size(); ++i)
				{
					Node* n = childs[i];
					bool isPacked = n->isPacked();

					if (isPacked)
						n->unpack();
					move(n, before);
					if (isPacked)
						n->pack();
				}

				if (node->m_selected)
					node->m_selected->select();
				node->destroy();
				node->removeFromOldParent();
				node->remove();

				return this;
			}
			else
			{
				move(node, before);
				node->pack();
			}
			node->select();
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
			else if (m_parent->isPanedWindow() && (m_parent->m_orientation & position))
			{
				if (!before)
					before = (position == Right || position == Bottom) ? findAfter() : this;
				m_parent->move(node, before);
				node->pack();
				parent = m_parent;
			}
			else
			{
				insertPanedWindow(position, node);
			}
			break;
	}

	if (newParent)
		node->removeFromOldParent();

	if (!node->m_parent->isHorz())
		node->setWidth(node->m_parent->width<Inner>());
	if (!node->m_parent->isVert())
		node->setHeight(node->m_parent->height<Inner>());
	
	while (!parent->applySnapshot() && parent->m_parent)
		parent = parent->m_parent;

	return node;
}


bool
Node::applySnapshot()
{
	mstl::string key;

	makeSnapshotKey(key);
	SnapshotMap::iterator i = m_snapshotMap.find(key);

	if (i == m_snapshotMap.end())
		return false;

printf("applySnapshot: %s\n", key.c_str());
	Snapshot const& snapshot = i->second;
	
	double scaleWidth		= double(width<Inner>())/double(snapshot.size.width);
	double scaleHeight	= double(height<Inner>())/double(snapshot.size.height);

	applySnapshot(scaleWidth, scaleHeight, snapshot.sizeMap);
	m_snapshotMap.erase(i);
	return true;
}


void
Node::applySnapshot(double scaleWidth, double scaleHeight, SizeMap const& sizeMap)
{
	if (isPaneOrFrame())
	{
		SizeMap::const_iterator i = sizeMap.find(tcl::asString(m_uid));
		if (i != sizeMap.end())
		{
			int width = contentSize<Horz>(i->second.width)*scaleWidth + 0.5;
			int height = contentSize<Vert>(i->second.height)*scaleHeight + 0.5;
			m_dimen.setActual(frameSize<Horz>(width), frameSize<Vert>(height));
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
		child(i)->reparentChildsRecursively(topLevel);
		tk::reparent(child(i)->tkwin(), topLevel);
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
	{
		if (child(i)->isPacked())
			child(i)->doAdjustment<D>(size);
	}
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

	int computedSize = contentSize<D>(computeDimen<D>());
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
				child(i)->doAdjustment<D>(size);
		}
	}
}


template <Orient D>
void
Node::adjustToplevel()
{
	if (grow<D>() && actualSize<Inner,D>() < minSize<Inner,D>())
		m_dimen.set<D>(minSize<Inner,D>());
	else if (shrink<D>() && maxSize<Inner,D>() && actualSize<Inner,D>() > maxSize<Inner,D>())
		m_dimen.set<D>(maxSize<Inner,D>());
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

	unpack();
}


bool
Node::makeSnapshot(mstl::string& structure, SizeMap* sizeMap)
{
	if (m_priority < 0)
		return false;

	if (sizeMap && isPaneOrFrame())
		sizeMap->insert(SizeMap::value_type(tcl::asString(m_uid), m_dimen.actual));

	if (!isRoot() && !isMetaFrame())
	{
		static_assert(LAST < 10, "range problem");

		if (isPaneOrFrame())
			structure.append(tcl::asString(m_uid));
		else
			structure.append(char(int(m_type) + '0'));
	}

	mstl::vector<mstl::string> keyList;
	bool rc = isPanedWindow();

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isPacked())
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
	Snapshot snapshot;
	Node* node = this;

	for ( ; node; node = node->m_parent)
	{
		snapshot.size = node->m_dimen.actual;

		if (node->makeSnapshot(snapshot.structure, &snapshot.sizeMap))
		{
			mstl::swap(node->m_snapshotMap[snapshot.structure], snapshot);
			return;
		}
	}
}


void
Node::floating(bool temporary)
{
	M_ASSERT(isFrameOrMetaFrame());

	m_parent->makeSnapshot();

	if (!isWithdrawn())
		withdraw();

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
	addFlag(F_Raise);

	if (!exists)
	{
		performFinalizeCreate();
		delFlag(F_Create);
	}
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
}


void
Node::resetToWithdrawn()
{
	m_state = Withdrawn;

	for (unsigned i = 0; i < numChilds(); ++i)
		child(i)->resetToWithdrawn();
}


void
Node::performQuerySashSize()
{
	Tcl_Obj* result = tcl::call(__func__, m_root->pathObj(), m_objSashSizeCmd, nullptr);

	if (!result)
		M_THROW(tcl::Error());
		
	m_root->m_sashSize = tcl::asUnsigned(result);
	tcl::decrRef(result);
}


void
Node::performQueryFrameHeaderSize(ClientData clientData)
{
	Node*		node		= static_cast<Node*>(clientData);
	Tcl_Obj*	result;
	
	result = tcl::call(	__func__,
								node->m_root->pathObj(),
								m_objFrameHdrSizeCmd,
								node->pathObj(),
								nullptr);

	if (!result)
		M_THROW(tcl::Error());
	
	node->m_root->m_frameHeaderSize = tcl::asUnsigned(result);
	tcl::decrRef(result);
}


void
Node::performQueryNotebookHeaderSize(ClientData clientData)
{
	Node*		node		= static_cast<Node*>(clientData);
	Tcl_Obj*	result;
	
	result = tcl::call(	__func__,
								node->m_root->pathObj(),
								m_objNotebookHdrSizeCmd,
								node->pathObj(),
								nullptr);

	if (!result)
		M_THROW(tcl::Error());
	
	node->m_root->m_notebookHeaderSize = tcl::asUnsigned(result);
	tcl::decrRef(result);
}


void
Node::load(Tcl_Obj* list)
{
	M_ASSERT(list);

	Tcl_Obj**	objv;
	unsigned		numElems;

	numElems = tcl::getElements(list, objv);

	if (isContainer())
	{
		if (numElems % 3 != 0)
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
		Type		type;

		if (tcl::equal(what, "root"))
		{
			opts = objv[i + 1];
			type = Root;
		}
		else if (tcl::equal(what, "pane"))
		{
			uid = objv[i + 1];
			opts = objv[i + 2];
			type = Pane;
		}
		else if (tcl::equal(what, "frame"))
		{
			uid = objv[i + 1];
			opts = objv[i + 2];
			type = Frame;
		}
		else if (tcl::equal(what, "metaframe"))
		{
			opts = objv[i + 1];
			type = MetaFrame;
		}
		else if (tcl::equal(what, "panedwindow"))
		{
			opts = objv[i + 1];
			type = PanedWindow;
		}
		else if (tcl::equal(what, "multiwindow"))
		{
			opts = objv[i + 1];
			type = MultiWindow;
		}
		else if (tcl::equal(what, "notebook"))
		{
			opts = objv[i + 1];
			type = Notebook;
		}
		else
		{
			M_THROW(tcl::Exception("invalid widget type '%s'", tcl::asString(what)));
		}

		if (isRoot(type))
		{
			if (this != m_root)
				M_THROW(tcl::Exception("unexpected widget type 'root'"));

			parseOptions(opts);
			load(objv[i + 2]);
			m_state = Packed;
			performQuerySashSize();
		}
		else
		{
			if (this == m_root && !isPacked())
				M_THROW(tcl::Exception("unexpected widget type '%s' for root", tcl::asString(what)));

			Node* node = new Node(*this, type, uid);
			m_root->m_active.push_back(node);
			node->parseOptions(opts);
			insertNode(node);
			node->pack();

			if (isContainer(type) || isMetaFrame(type))
				node->load(objv[i + 2]);
		}
	}
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

		if (node->isPacked())
		{
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
}


void
Node::performPack()
{
	if (isRoot())
		return;

	M_ASSERT(m_parent);
	M_ASSERT(m_parent->contains(this));
	M_ASSERT(!isToplevel() || isRoot());
	//M_ASSERT(!m_parent->isPane() && !m_parent->isFrameOrMetaFrame());
	M_ASSERT(exists());
	M_ASSERT(m_parent->exists());

	tcl::invoke(__func__,
					m_root->pathObj(),
					m_objPackCmd,
					m_parent->pathObj(),
					pathObj(),
					makeOptions(findAfter(true)),
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

	if (m_path)
	{
		tcl::decrRef(m_oldPath);
		m_oldPath = m_path;
	}

	Tcl_Obj* opts = isContainer() ? makeOptions() : (isPane() ? m_uid : nullptr);

	m_root->m_current = this;

	if (opts)
		m_path = tcl::call(__func__, m_root->pathObj(), typeObj(), opts, nullptr);
	else
		m_path = tcl::call(__func__, m_root->pathObj(), typeObj(), nullptr);

	m_root->m_current = nullptr;

	if (!m_path)
		M_THROW(tcl::Error());

	if (toplevel()->isFloating())
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
							m_objFrame2,
							pathObj(),
							isMetaFrame() ? child()->m_path : m_uid,
							nullptr) != TCL_OK)
	{
		M_THROW(tcl::Error());
	}
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

	Tcl_Obj* list = makeConfigOptions();

	if (list)
	{
		tcl::invoke(__func__,
						m_root->pathObj(),
						m_objPaneConfigCmd,
						m_parent->pathObj(),
						pathObj(),
						makeConfigOptions(),
						nullptr);
	}
}


void
Node::performResize()
{
	M_ASSERT(isToplevel());

	// TODO: also send minSize, maxSize

	if (width<Inner>() > 1 && height<Inner>() > 1)
	{
		int newWidth	= width<Outer>();
		int newHeight	= height<Outer>();

		if (newWidth != tk::width(tkwin()) || newHeight != tk::height(tkwin()))
		{
			tk::resize(tkwin(), newWidth, newHeight);

			tcl::invoke(__func__,
							m_root->pathObj(),
							m_objResizedCmd,
							pathObj(),
							tcl::newObj(newWidth),
							tcl::newObj(newHeight),
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
	tcl::decrRef(m_oldPath);
	tcl::incrRef(m_oldPath = m_path);
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
	M_ASSERT(isRoot());

	m_flags = 0;

	for (unsigned i = 0; i < m_active.size(); ++i)
		m_active[i]->m_flags = 0;
}


void
Node::updateHeader()
{
	M_ASSERT(isPacked());

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
		if (isMetaFrame())
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
	}
}


void
Node::updateAllHeaders()
{
	for (unsigned i = 0; i < m_active.size(); ++i)
	{
		Node* node = m_active[i];

		tcl::set(node->m_oldHeaderObj, node->m_headerObj);
		tcl::zero(node->m_headerObj);
	}

	for (unsigned i = 0; i < m_active.size(); ++i)
	{
		Node* node = m_active[i];

		if (node->isPacked())
			node->updateHeader();
	}
}


void
Node::performRaiseRecursively(bool needed)
{
	for (unsigned i = 0; i < numChilds(); ++i)
	{
		Node* child = this->child(i);

		if (child->isToplevel())
		{
			child->performRaiseRecursively(child->testFlags(F_Raise));
		}
		else if (child->isPacked())
		{
			bool doIt = needed || child->testFlags(F_Raise);

			if (doIt && !isToplevel())
			{
				if (m_selected && m_selected->isPacked())
					m_selected->performSelect();
				if (testFlags(F_Select))
					performSelect();
				tk::raise(child->tkwin(), tkwin());
			}

			child->performRaiseRecursively(doIt);
		}
	}
}


void
Node::performCreateRecursively()
{
	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isPacked() || child(i)->isToplevel())
			child(i)->performCreateRecursively();
	}

	if (testFlags(F_Create))
	{
		performCreate();
		if (isFrameOrMetaFrame())
			performFinalizeCreate();
	}
}


void
Node::performPackRecursively()
{
	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isPacked() || child(i)->isToplevel())
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
	
	if (!m_parent || m_parent->contains(this))
		flatten();
}


void
Node::performRestructureRecursively()
{
	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isPacked() || child(i)->isToplevel())
			child(i)->performRestructureRecursively();
	}

	if ((isPanedWindow() || isPane()) && m_parent->isNotebookOrMultiWindow())
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
Node::performUpdateHeaderRecursively()
{
	if (isPacked() && isFrameOrMetaFrame())
	{
		if (!tcl::eqOrNull(m_headerObj, m_oldHeaderObj))
			performUpdateHeader();
	}

	for (unsigned i = 0; i < numChilds(); ++i)
	{
		if (child(i)->isPacked() || child(i)->isToplevel())
			child(i)->performUpdateHeaderRecursively();
	}
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

				case F_Destroy:	node->performDestroy(); break;

				case F_Pack:		// fallthru
				case F_Create:		// fallthru
				case F_Config:		// fallthru
				case F_Raise:		// fallthru
				case F_Select:		// fallthru
				case F_Reparent:	M_ASSERT(!"unexpected"); break;
			}
		}
	}
}


void
Node::performUpdateDimensions()
{
	M_ASSERT(isRoot());

	if (m_actual.width > 0 && m_actual.height > 0)
	{
		m_dimen.actual = m_actual;
		m_actual.zero();
	}

	for (unsigned i = 0; i < m_active.size(); ++i)
	{
		Node* node = m_active[i];

		if (node->m_actual.width > 0 && node->m_actual.height > 0)
		{
			node->m_dimen.actual = node->m_actual;
			node->m_actual.zero();
		}
	}
}


void
Node::performDeleteInactiveNodes()
{
	M_ASSERT(isRoot());

	Childs::iterator i = m_active.begin();

	while (i != m_active.end())
	{
		if ((*i)->m_isDeleted)
		{
			M_ASSERT(m_deleted.find(*i) == m_deleted.end());
			M_ASSERT(!(*i)->exists());
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
Node::perform(Node* toplevel)
{
	M_ASSERT(isRoot());
	M_ASSERT(!toplevel || toplevel->isToplevel());

	unsigned flags = collectFlags();

	if (flags == 0)
		return;
	
	m_isLocked = true;

	if (toplevel == this)
		toplevel = nullptr;
	
	try
	{
		if ((flags & (F_Pack|F_Unpack)) || toplevel)
		{
			performFlattenRecursively();
			performFlattenRecursively(); // we need a second pass for unframing
			flags = collectFlags();
		}

		if (flags & F_Unpack)
			performAllActiveNodes(F_Unpack);

		if (flags & F_Unframe)
			performAllActiveNodes(F_Unframe);

		if (flags & (F_Pack|F_Unpack))
		{
			performRestructureRecursively();
			flags = collectFlags();
		}

		if (flags & F_Create)
			performCreateRecursively();

		if (flags & (F_Pack|F_Unpack))
			updateAllHeaders();

		if (flags & (F_Create|F_Pack|F_Unpack))
			computeDimensions();

		if (flags & (F_Pack|F_Unpack))
		{
			adjustDimensions();
			if (toplevel)
				toplevel->adjustDimensions();
		}

		performResize();

		if (toplevel)
			toplevel->performResize();

		if (flags & F_Pack)
			performPackRecursively();

		performConfigRecursively();

		if (toplevel)
			toplevel->performConfigRecursively();

		if (flags & F_Raise)
			performRaiseRecursively();

		if (flags & (F_Pack|F_Unpack|F_Raise))
			performUpdateHeaderRecursively();

		if (flags & F_Destroy)
			performAllActiveNodes(F_Destroy);

		performDeleteInactiveNodes();
		performUpdateDimensions();
	}
	catch (Terminated)
	{
		throw;
	}
	catch (...)
	{
		m_isLocked = false;
		clearAllFlags();
		throw;
	}

	m_isLocked = false;
	clearAllFlags();
}


void
Node::dump() const
{
	Childs& active = m_root->m_active;

	for (unsigned i = 0; i < active.size(); ++i)
		active[i]->m_dumpFlag = false;

	m_dumpFlag = false;
	dump(0, false);
}


void
Node::dump(unsigned level, bool parentIsWithdrawn) const
{
	M_ASSERT(parentIsWithdrawn || !m_parent || !isPacked() || m_parent->contains(this));

	if (level == 0)
		printf("=================================================\n");
	for (unsigned i = 1; i < level; ++i)
		printf("| ");

	if (m_dumpFlag)
	{
		printf("**** recursion detect: %s *****\n", id());
		return;
	}

	char const* state;

	switch (m_state)
	{
		case Packed:		state = "packed"; break;
		case Floating:		state = "floating"; break;
		case Withdrawn:	state = "withdrawn"; break;
	}

	bool isWithdrawn = parentIsWithdrawn || this->isWithdrawn();

	if (isWithdrawn)
		printf("#");

	if (m_uid)
		printf("%s", uid());
	else if (!isWithdrawn)
		printf("%s", path());
	else if (m_oldPath)
		printf("%s", oldPath());
	else if (m_path)
		printf("%s", path());
	else
		printf("<null>");
	if (isPaneOrFrame())
		printf(" {%u}", m_priority);
	if (isPanedWindow())
		printf(" [%s]", isHorz() ? "h" : "v");
	if (isFrameOrMetaFrame())
		printf(m_headerObj ? " [frame]" : " [pane]");
	printf(" [%s] (%dx%d)", state, width<Inner>(), height<Inner>());
	if (minWidth<Inner>() || minHeight<Inner>())
		printf(" min(%dx%d)", minWidth<Inner>(), minHeight<Inner>());
	if (maxWidth<Inner>() || maxHeight<Inner>())
		printf(" max(%dx%d)", maxWidth<Inner>(), maxHeight<Inner>());
	//if (isFloating()) XXX
	if (m_origParent)
		printf(" -> %s", m_origParent->id());
	printf(" \n");

	m_dumpFlag = true;
	//if (!parentIsWithdrawn || !isPacked() || (m_parent && m_parent->isMetaFrame()))
	{
		for (unsigned i = 0; i < numChilds(); ++i)
			child(i)->dump(level + 1, isWithdrawn);
	}
	m_dumpFlag = false;
}


void
Node::initialize()
{
	if (m_objPanedWindow)
		return;

	m_obj = tcl::incrRef(tcl::newObj());
	m_objBoth = tcl::incrRef(tcl::newObj("both"));
	m_objDestroyCmd = tcl::incrRef(tcl::newObj("destroy"));
	m_objDirsLR = tcl::incrRef(tcl::newListObj("l r"));
	m_objDirsTB = tcl::incrRef(tcl::newListObj("t b"));
	m_objDirsTBLR = tcl::incrRef(tcl::newListObj("t b l r"));
	m_objDirsTBLREW = tcl::incrRef(tcl::newListObj("t b l r e w"));
	m_objDirsTBLRNS = tcl::incrRef(tcl::newListObj("t b l r n s"));
	m_objDirsTBLRNSEW = tcl::incrRef(tcl::newListObj("t b l r n s e w"));
	m_objFrame = tcl::incrRef(tcl::newObj("frame"));
	m_objFrame2 = tcl::incrRef(tcl::newObj("frame2"));
	m_objFrameHdrSizeCmd = tcl::incrRef(tcl::newObj("framehdrsize"));
	m_objOptGrow = tcl::incrRef(tcl::newObj("-grow"));
	m_objHeaderCmd = tcl::incrRef(tcl::newObj("header"));
	m_objHorizontal = tcl::incrRef(tcl::newObj("horizontal"));
	m_objHorz = tcl::incrRef(tcl::newObj("horz"));
	m_objMetaFrame = tcl::incrRef(tcl::newObj("metaframe"));
	m_objMultiWindow = tcl::incrRef(tcl::newObj("multiwindow"));
	m_objNotebook = tcl::incrRef(tcl::newObj("notebook"));
	m_objNotebookHdrSizeCmd = tcl::incrRef(tcl::newObj("nbhdrsize"));
	m_objOptBefore = tcl::incrRef(tcl::newObj("-before"));
	m_objOptExpand = tcl::incrRef(tcl::newObj("-expand"));
	m_objOptHeader = tcl::incrRef(tcl::newObj("-header"));
	m_objOptHeight = tcl::incrRef(tcl::newObj("-height"));
	m_objOptMaxHeight = tcl::incrRef(tcl::newObj("-maxheight"));
	m_objOptMaxWidth = tcl::incrRef(tcl::newObj("-maxwidth"));
	m_objOptMinHeight = tcl::incrRef(tcl::newObj("-minheight"));
	m_objOptMinWidth = tcl::incrRef(tcl::newObj("-minwidth"));
	m_objOptOrient = tcl::incrRef(tcl::newObj("-orient"));
	m_objOptShrink = tcl::incrRef(tcl::newObj("-shrink"));
	m_objOptSticky = tcl::incrRef(tcl::newObj("-sticky"));
	m_objOptWidth = tcl::incrRef(tcl::newObj("-width"));
	m_objPackCmd = tcl::incrRef(tcl::newObj("pack"));
	m_objPaneConfigCmd = tcl::incrRef(tcl::newObj("paneconfigure"));
	m_objPanedWindow = tcl::incrRef(tcl::newObj("panedwindow"));
	m_objPane = tcl::incrRef(tcl::newObj("pane"));
	m_objResizedCmd = tcl::incrRef(tcl::newObj("resized"));
	m_objSashSizeCmd = tcl::incrRef(tcl::newObj("sashsize"));
	m_objSelectCmd = tcl::incrRef(tcl::newObj("select"));
	m_objUnpackCmd = tcl::incrRef(tcl::newObj("unpack"));
	m_objVert = tcl::incrRef(tcl::newObj("vert"));
	m_objVertical = tcl::incrRef(tcl::newObj("vertical"));
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

	if (base.root)
		M_THROW(tcl::Exception("'%s' is already loaded", tcl::asString(objv[2])));

	M_ASSERT(base.setup);

	if (objc == 4)
	{
		base.root = Node::makeRoot(objv[2]);
		base.root->load(objv[3]);
	}
	else // if (objc == 3)
	{
		base.root = base.setup->clone();
	}

	base.root->perform();
base.root->dump();
}


static void
cmdClose(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
		M_THROW(tcl::Exception(3, objv, "list"));

	Node::removeBase(tcl::asString(objv[2]));
}


static void
cmdIsContainer(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
		M_THROW(tcl::Exception(3, objv, "window"));

	char const* path = tcl::asString(objv[3]);
	Node* node = base.root->findPath(path);

	if (!node)
		M_THROW(tcl::Exception("cannot find window '%s'", path));

	tcl::setResult(node->isContainer());
}


static void
cmdIsPacked(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
		M_THROW(tcl::Exception(3, objv, "window"));

	char const* path = tcl::asString(objv[3]);
	Node* node = base.root->findPath(path);

	tcl::setResult(node && node->isPacked());
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

	tcl::setResult(node->pathObj());
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
cmdPanes(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
		M_THROW(tcl::Exception(3, objv, "window"));

	char const* path = tcl::asString(objv[3]);
	Node* node = base.root->findPath(path);

	if (!node)
		M_THROW(tcl::Exception("cannot find window '%s'", path));

	tcl::setResult(node->collectPanes());
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

	if (node->isPacked())
		M_THROW(tcl::Exception("frame '%s' is already packed", path));

	Node* recv = nullptr;
	Position position = Center;

	if (objc == 6)
	{
		recv = base.root->findPath(tcl::asString(objv[4]));

		if (!recv)
			M_THROW(tcl::Exception("cannot find receiver '%s'", tcl::asString(objv[4])));

		position = parsePositionOption(tcl::asString(objv[5]));
	}

	node = node->dock(recv, position);
	recv->root()->perform(recv->toplevel());
	tcl::setResult(node->pathObj());
base.root->dump();
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

	if (!node)
		M_THROW(tcl::Exception("cannot find window '%s'", path));

	if (!node->isFrameOrMetaFrame())
		M_THROW(tcl::Exception("cannot undock '%s', it's not a frame", path));

	M_ASSERT(node->parent());

	node->floating(temporary);
	node->root()->perform(node->toplevel());
	tcl::setResult(node->pathObj());
base.root->dump();
}


static void
cmdSet(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc < 4)
		M_THROW(tcl::Exception(3, objv, "window ?attribute value...?"));
	
	if (objc % 2 == 1)
		M_THROW(tcl::Exception("odd number of arguments"));

	char const* path = tcl::asString(objv[3]);
	Node* node = base.root->findPath(path);

	if (!node)
	{
		node = base.root->getCurrent();

		if (!node)
			M_THROW(tcl::Exception("cannot find window '%s'", path));
	}

	for (int i = 4; i < objc; i += 2)
		node->set(tcl::asString(objv[i]), objv[i + 1]);
}


static void
cmdGet(Base& base, int objc, Tcl_Obj* const objv[])
{
	if (objc != 5 && objc != 6)
		M_THROW(tcl::Exception(3, objv, "window attribute ?default?"));
	
	char const* path = tcl::asString(objv[3]);
	Node* node = base.root->findPath(path);

	if (!node)
	{
		node = base.root->getCurrent();

		if (!node)
			M_THROW(tcl::Exception("cannot find window '%s'", path));
	}

	Tcl_Obj* value = node->get(tcl::asString(objv[4]));

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
		"capture",		"close",			"container",	"dock",			"frames",
		"get",			"id",				"init",			"iscontainer",	"ispacked",
		"leader",		"load",			"neighbors",	"orientation",	"panes",
		"parent",		"release",		"set",			"uid",			"undock",
		"visible",
		nullptr
	};
	enum
	{
		Cmd_Capture,	Cmd_Close,		Cmd_Container,	Cmd_Dock,			Cmd_Frames,
		Cmd_Get,			Cmd_Id,			Cmd_Init,		Cmd_IsContainer,	Cmd_IsPacked,
		Cmd_Leader,		Cmd_Load,		Cmd_Neighbors,	Cmd_Orientation,	Cmd_Panes,
		Cmd_Parent,		Cmd_Release,	Cmd_Set,			Cmd_Uid,				Cmd_Undock,
		Cmd_Visible,
	};

	if (objc <= 2)
		return tcl::wrongNumArgs(objc, objv, objc == 1 ? "command path ?args?" : "command ?args?");

	int index;

	if (Tcl_GetIndexFromObj(ti, objv[1], subcommands, "subcommand", TCL_EXACT, &index) != TCL_OK)
		return TCL_ERROR;

	try
	{
		switch (index)
		{
			case Cmd_Close:			execute(cmdClose, false, objc, objv); break;
			case Cmd_Container:		execute(cmdContainer, false, objc, objv); break;
			case Cmd_Dock:				execute(cmdDock, false, objc, objv); break;
			case Cmd_Frames:			execute(cmdFrames, false, objc, objv); break;
			case Cmd_Get:				execute(cmdGet, false, objc, objv); break;
			case Cmd_Id:				execute(cmdId, false, objc, objv); break;
			case Cmd_Init:				cmdInit(initBase(objv[2]), objc, objv); break;
			case Cmd_IsContainer:	execute(cmdIsContainer, false, objc, objv); break;
			case Cmd_IsPacked:		execute(cmdIsPacked, false, objc, objv); break;
			case Cmd_Leader:			execute(cmdLeader, false, objc, objv); break;
			case Cmd_Load:				execute(cmdLoad, true, objc, objv); break;
			case Cmd_Neighbors:		execute(cmdNeighbors, false, objc, objv); break;
			case Cmd_Orientation:	execute(cmdOrientation, false, objc, objv); break;
			case Cmd_Panes:			execute(cmdPanes, false, objc, objv); break;
			case Cmd_Parent:			execute(cmdParent, false, objc, objv); break;
			case Cmd_Set:				execute(cmdSet, false, objc, objv); break;
			case Cmd_Undock:			execute(cmdUndock, false, objc, objv); break;
			case Cmd_Uid:				execute(cmdUid, false, objc, objv); break;
			case Cmd_Visible:			execute(cmdVisible, false, objc, objv); break;

			case Cmd_Capture:			cmdCapture(objc, objv); break;
			case Cmd_Release:			cmdRelease(objc, objv); break;
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
