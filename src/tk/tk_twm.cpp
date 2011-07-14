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
// Copyright: (C) 2010-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "tk_init.h"

#include "tcl_exception.h"
#include "tcl_base.h"

#include "m_vector.h"
#include "m_list.h"
#include "m_string.h"
#include "m_algorithm.h"
#include "m_map.h"
#include "m_limits.h"
#include "m_utility.h"
#include "m_assert.h"

#include <string.h>
#include <tcl.h>
#define namespace namespace_	// bug in tcl8.6/tkInt.h
#include <tkInt.h>
#undef namespace


extern "C" { void TkpWmSetState(TkWindow* winPtr, int state); }


//	Since there is a bug in tkGeometry.c, we need this routine to
//	replace Tk_ManageGeometry(tkwin, 0, 0);
static void
UnmanageGeometry(Tk_Window tkwin)
{
	TkWindow* winPtr = reinterpret_cast<TkWindow*>(tkwin);

	if (winPtr->geomMgrPtr && winPtr->geomMgrPtr->lostSlaveProc)
		(*winPtr->geomMgrPtr->lostSlaveProc)(winPtr->geomData, tkwin);

	winPtr->geomMgrPtr = 0;
	winPtr->geomData = 0;
}


static void
UnlinkWindow(TkWindow* winPtr)
{
	if (winPtr->parentPtr == 0)
		return;

	TkWindow* prevPtr = winPtr->parentPtr->childList;

	if (prevPtr == winPtr)
	{
		winPtr->parentPtr->childList = winPtr->nextPtr;

		if (winPtr->nextPtr == 0)
			winPtr->parentPtr->lastChildPtr = 0;
	}
	else
	{
		M_ASSERT(prevPtr);

		while (prevPtr->nextPtr != winPtr)
		{
			prevPtr = prevPtr->nextPtr;
			M_ASSERT(prevPtr);
		}

		prevPtr->nextPtr = winPtr->nextPtr;

		if (winPtr->nextPtr == 0)
			winPtr->parentPtr->lastChildPtr = prevPtr;
	}
}


static void
LinkWindow(TkWindow* winPtr)
{
	TkWindow* parent = winPtr->parentPtr;

	if (TkWindow* prevPtr = parent->childList)
	{
		while (prevPtr->nextPtr)
			prevPtr = prevPtr->nextPtr;

		prevPtr->nextPtr = winPtr;
		parent->childList->nextPtr = winPtr;
	}
	else
	{
		parent->childList = winPtr;
		parent->childList->nextPtr = 0;
	}

	parent->lastChildPtr = winPtr;
}


static int
releaseWindow(Tcl_Interp *interp, Tk_Window tkmain, Tk_Window tkwin)
{
	if (Tk_IsTopLevel(tkwin))
		return 0;

	// detach the window from its gemoetry manager, if any
	UnmanageGeometry(tkwin);

	TkWindow* winPtr = reinterpret_cast<TkWindow*>(tkwin);

	if (winPtr->window == None)
	{
		// The window is not created yet, we still have time
		// to make it an legitimate toplevel window.
		winPtr->dirtyAtts |= CWBorderPixel;
	}
	else
	{
		Window parent;

		if (winPtr->flags & TK_MAPPED)
			Tk_UnmapWindow(tkwin);

#ifdef WIN32

		// Reparent to NULL so UpdateWrapper won't delete our original parent window
		SetParent(TkWinGetHWND(winPtr->window), 0);

#elif defined(__MacOSX__)

# error "not yet implemented"

#else // if defined(__unix__)

		parent = XRootWindow(winPtr->display, winPtr->screenNum);
		XReparentWindow(winPtr->display, winPtr->window, parent, 0, 0);

#endif

		// Should flush the events here
	}

	winPtr->flags |= TK_TOP_HIERARCHY | TK_TOP_LEVEL | TK_HAS_WRAPPER | TK_WIN_MANAGED;

	TkWmNewWindow(winPtr);
	TkpWmSetState(winPtr, WithdrawnState);

	// Size was set - force a call to Geometry Manager
	winPtr->reqWidth++;
	winPtr->reqHeight++;
	Tk_GeometryRequest(tkmain, winPtr->reqWidth - 1, winPtr->reqHeight - 1);

	TkWmMapWindow(winPtr);

	return 1;
}


static int
captureWindow(Tcl_Interp *interp, Tk_Window tkmain, Tk_Window tkwin, Tk_Window tkparent)
{
	TkWindow* winPtr = reinterpret_cast<TkWindow*>(tkwin);

	if (winPtr->parentPtr == 0)
		return 0;

	if ((winPtr->flags & TK_TOP_LEVEL) == 0)
		return 1;	// window is already captured

	// withdraw the window
	TkpWmSetState(winPtr, WithdrawnState);

	if (tkparent)
	{
		TkWindow* parent = reinterpret_cast<TkWindow*>(tkparent);

//		if (parent->childList)
//			return 0;

		UnlinkWindow(winPtr);
		winPtr->parentPtr = parent;
		winPtr->nextPtr = 0;
		LinkWindow(winPtr);
	}

	if (winPtr->window == None)
	{
		// cause this and parent window to exist
		winPtr->atts.event_mask &= ~StructureNotifyMask;
		winPtr->flags &= ~TK_TOP_LEVEL;
	}
	else
	{
		XSetWindowAttributes atts;

#ifdef WIN32

		// SetParent must be done before TkWmDeadWindow or it's DestroyWindow on the
		// parent Hwnd will also destroy the child
		Tk_MakeWindowExist(reinterpret_cast<Tk_Window>(winPtr->parentPtr));
		SetParent(TkWinGetHWND(winPtr->window), TkWinGetHWND(winPtr->parentPtr->window));
		// Dis-associate from wm
		TkWmDeadWindow(winPtr);

#elif defined(__MacOSX__)

# error "not yet implemented"

#else // if defined(__unix__)

		TkWmDeadWindow(winPtr);
		XUnmapWindow(winPtr->display, winPtr->window);
		Tk_MakeWindowExist(reinterpret_cast<Tk_Window>(winPtr->parentPtr));
		XReparentWindow(winPtr->display, winPtr->window, winPtr->parentPtr->window, 0, 0);

#endif

		// clear those attributes that non-toplevel windows don't possess
		winPtr->flags &= ~(TK_TOP_HIERARCHY | TK_TOP_LEVEL | TK_HAS_WRAPPER | TK_WIN_MANAGED);
		atts.event_mask = winPtr->atts.event_mask;
		atts.event_mask &= ~StructureNotifyMask;
		Tk_ChangeWindowAttributes(tkwin, CWEventMask, &atts);
	}

	UnmanageGeometry(tkwin);

	// Can't delete the TopLevelEventProc, because this definition only exists
	// in tkWinWm or tkUnixWm.c. Is having this event handler around really cause
	// a problem?
//	Tk_DeleteEventHandler(tkwin, StructureNotifyMask, TopLevelEventProc, winPtr);

	return 1;
}

#undef None

using namespace tcl;


namespace {

struct Node;
typedef mstl::vector<Node*> Childs;
typedef mstl::list<mstl::string> Commands;

enum Type	{ Frame, Pane, PanedWindow, Notebook };
enum Expand	{ None, X = 1, Y = 2 };
enum Orient	{ Horizontal = X, Vertical = Y };


// ================================================================
// Some examples of a node list structure:
// ================================================================
//
// (horz (vert (horz 1 0) 2) 3)			(horz 1 (vert (horz 0 3) 2))
// +---+-----------+---+					+---+-----------+---+
// |   |           |   |					|   |           |   |
// | 1 |     0     | 3 |					| 1 |     0     | 3 |
// |   |           |   |					|   |           |   |
// +---+-----------+   |					|   |-----------+---|
// |         2     |   |					|   |      2        |
// +---------------+---+					+---+---------------+
//
//
// (vert (horz 1 0 3) 2)					(horz 1 (vert 0 2) 3)
// +---+-----------+---+					+---+-----------+---+
// |   |           |   |					|   |           |   |
// | 1 |     0     | 3 |					| 1 |     0     | 3 |
// |   |           |   |					|   |           |   |
// +---+-----------+---+					|   +-----------+   |
// |         2         |					|   |     2     |   |
// +-------------------+					+---+-----------+---+


class Node
{
public:

	typedef mstl::map<mstl::string,Node*> Lookup;

	Node();
	Node(Type type);
	Node(Tcl_Obj* path);
	~Node() throw();

	bool isEmpty() const;
	bool isExpandable(Orient orient) const;
	bool contains(Node const* node) const;

	mstl::string const& name() const;
	char const* pathName() const;
	Tcl_Obj* path() const;
	Type type() const;
	int expand() const;
	unsigned minWidth() const;
	unsigned maxWidth() const;
	Node* parent() const;
	Node* child(unsigned index) const;
	Node* firstChild() const;
	Node* lastChild() const;
	Node* root() const;
	Childs const& childs() const;
	unsigned size() const;

	void create(Node* parent, int n, Tcl_Obj** opts);
	void configure();
	void pack(Node* node);
	void pack(Childs const& childs);
	void packBefore(Node* node, Node const* succ);
	void packAfter(Node* node, Node const* pred);
	void unpack(Node const* node);
	void unpack();

	static Tcl_Obj* makeCommands();
	static void clearCommands();

	static Node* lookupRoot(char const* path);
	static void initialize();

private:

	Tcl_Obj* getValue(char const* key) const;

	void unpack(unsigned index);
	void configure(unsigned& minw, unsigned& maxw);

	Type				m_type;
	mstl::string	m_name;
	Tcl_Obj*			m_path;
	Tcl_Obj*			m_opts;
	Childs			m_childs;
	Node*				m_parent;

	static Lookup m_lookup;

	static Tcl_Obj* m_objPanedWindow;
	static Tcl_Obj* m_objNotebook;
	static Tcl_Obj* m_objPane;
	static Tcl_Obj* m_objFrame;
	static Tcl_Obj* m_objCreateCmd;
	static Tcl_Obj* m_objPackCmd;
	static Tcl_Obj* m_objUnpackCmd;
	static Tcl_Obj* m_objConfigureCmd;
	static Tcl_Obj* m_objBefore;
	static Tcl_Obj* m_objAfter;
	static Tcl_Obj* m_objMinsize;
	static Tcl_Obj* m_objMaxsize;
};

Tcl_Obj* Node::m_objPanedWindow = 0;
Tcl_Obj* Node::m_objNotebook = 0;
Tcl_Obj* Node::m_objPane = 0;
Tcl_Obj* Node::m_objFrame = 0;
Tcl_Obj* Node::m_objCreateCmd = 0;
Tcl_Obj* Node::m_objPackCmd = 0;
Tcl_Obj* Node::m_objUnpackCmd = 0;
Tcl_Obj* Node::m_objConfigureCmd = 0;
Tcl_Obj* Node::m_objBefore = 0;
Tcl_Obj* Node::m_objAfter = 0;
Tcl_Obj* Node::m_objMinsize = 0;
Tcl_Obj* Node::m_objMaxsize = 0;

Node::Lookup Node::m_lookup;

} // namespace


namespace {

Type Node::type() const			{ return m_type; }
unsigned Node::size() const	{ return m_childs.size(); }
bool Node::isEmpty() const		{ return m_childs.empty(); }
Node* Node::parent() const		{ return m_parent; }
Tcl_Obj* Node::path() const	{ return m_path; }

Childs const& Node::childs() const		{ return m_childs; }
mstl::string const& Node::name() const	{ return m_name; }
char const* Node::pathName() const		{ return Tcl_GetStringFromObj(m_path, 0); }


Node::Node()
	:m_type(Pane)
	,m_opts(0)
	,m_parent(0)
{
}


Node::Node(Type type)
	:m_type(type)
	,m_opts(0)
	,m_parent(0)
{
}


Node::Node(Tcl_Obj* path)
	:m_type(Frame)
	,m_path(path)
	,m_opts(0)
	,m_parent(0)
{
	m_lookup[Tcl_GetStringFromObj(path, 0)] = this;
}


Node::~Node() throw()
{
	if (m_opts)
		Tcl_DecrRefCount(m_opts);
	if (m_path)
		Tcl_IncrRefCount(m_path);

	for (unsigned i = 0; i < m_childs.size(); ++i)
		delete m_childs[i];
}


void
Node::initialize()
{
	if (m_objCreateCmd == 0)
	{
		m_objCreateCmd = Tcl_NewStringObj("::twm::callback::Create", -1);
		m_objPackCmd = Tcl_NewStringObj("::twm::callback::Pack", -1);
		m_objUnpackCmd = Tcl_NewStringObj("::twm::callback::Unpack", -1);
		m_objConfigureCmd = Tcl_NewStringObj("::twm::callback::Configure", -1);
		m_objPanedWindow = Tcl_NewStringObj("panedwindow", -1);
		m_objNotebook = Tcl_NewStringObj("notebook", -1);
		m_objPane = Tcl_NewStringObj("pane", -1);
		m_objFrame = Tcl_NewStringObj("frame", -1);
		m_objBefore = Tcl_NewStringObj("-before", -1);
		m_objAfter = Tcl_NewStringObj("-after", -1);
		m_objMinsize = Tcl_NewStringObj("-minsize", -1);
		m_objMaxsize = Tcl_NewStringObj("-maxsize", -1);
	}
}


bool
Node::contains(Node const* node) const
{
	return mstl::find(m_childs.begin(), m_childs.end(), node) != m_childs.end();
}


Node*
Node::root() const
{
	Node* parent = m_parent;

	while (parent)
		parent = parent->m_parent;

	return parent;
}


void
Node::create(Node* parent, int n, Tcl_Obj** opts)
{
	M_ASSERT(opts);
	M_ASSERT(n > 0);

	Tcl_Obj* type;

	switch (m_type)
	{
		case PanedWindow:	type = m_objPanedWindow; break;
		case Notebook:		type = m_objNotebook; break;
		case Pane:			type = m_objPane; break;
		case Frame:			type = m_objFrame; break;
	}

	m_name.assign(Tcl_GetStringFromObj(opts[0], 0));
	m_opts = Tcl_NewListObj(n - 1, opts + 1);
	m_path = call(	__func__,
						m_objCreateCmd,
						root()->path(),
						parent->path(),
						opts[0],
						type,
						n, opts);

	Tcl_IncrRefCount(m_opts);
	Tcl_IncrRefCount(m_path);
}


Node*
Node::lookupRoot(char const* path)
{
	Lookup::const_iterator i = m_lookup.find(path);
	M_ASSERT(i != m_lookup.end());
	return i->second;
}


Tcl_Obj*
Node::getValue(char const* key) const
{
	int			objc;
	Tcl_Obj**	objv;

	Tcl_ListObjGetElements(interp(), m_opts, &objc, &objv);

	for (int i = 0; i < objc - 1; i += 2)
	{
		if (::strcmp(Tcl_GetStringFromObj(objv[i], 0), key) == 0)
			return objv[i + 1];
	}

	return 0;
}


int
Node::expand() const
{
	if (Tcl_Obj* v = getValue("-expand"))
	{
		switch (*Tcl_GetStringFromObj(v, 0))
		{
			case 'x': return X;
			case 'y': return Y;
			case 'b': return X | Y;
		}
	}

	return None;
}


unsigned
Node::minWidth() const
{
	if (Tcl_Obj* v = getValue("-minwidth"))
	{
		int value;
		Tcl_GetIntFromObj(tcl::interp(), v, &value);
		return value;
	}

	return 0;
}


unsigned
Node::maxWidth() const
{
	if (Tcl_Obj* v = getValue("-maxwidth"))
	{
		int value;
		Tcl_GetIntFromObj(tcl::interp(), v, &value);
		return value;
	}

	return mstl::numeric_limits<unsigned>::max();
}


Node*
Node::child(unsigned index) const
{
	M_ASSERT(index < m_childs.size());
	return m_childs[index];
}


Node*
Node::firstChild() const
{
	M_ASSERT(!m_childs.empty());
	return m_childs[0];
}


Node*
Node::lastChild() const
{
	M_ASSERT(!m_childs.empty());
	return m_childs[m_childs.size() - 1];
}


bool
Node::isExpandable(Orient orient) const
{
	switch (m_type)
	{
		case Pane:
			return expand() & orient;

		case Frame:
		case PanedWindow:
		case Notebook:
			for (unsigned i = 0; i < m_childs.size(); ++i)
			{
				if (m_childs[i]->isExpandable(orient))
					return true;
			}
			return false;
	}

	return false;	// never reached
}


void
Node::configure(unsigned& minw, unsigned& maxw)
{
	for (unsigned i = 0; i < m_childs.size(); ++i)
		m_childs[i]->configure(minw, maxw);

	switch (m_type)
	{
		case PanedWindow:
		case Notebook:
			// nothing to do
			break;

		case Frame:
		case Pane:
			minw = mstl::min(minw, minWidth());
			maxw = mstl::min(maxw, maxWidth());
			break;
	}

	Tcl_Obj* objv[4];

	objv[0] = m_objMinsize;
	objv[1] = Tcl_NewIntObj(minw);
	objv[2] = m_objMaxsize;
	objv[3] = Tcl_NewIntObj(maxw);

	tcl::call(__func__, m_objConfigureCmd, root()->path(), m_parent->path(), path(), 4, objv);
}


void
Node::configure()
{
	if (!m_childs.empty())
	{
		unsigned minw = 0;
		unsigned maxw = mstl::numeric_limits<unsigned>::max();

		m_childs[0]->configure(minw, maxw);
	}
}


void
Node::packBefore(Node* node, Node const* succ)
{
	M_ASSERT(node);
	M_ASSERT(m_type != Pane && m_type != Frame);
	M_ASSERT(contains(succ));

	Tcl_Obj* opts = Tcl_NewListObj(0, 0);

	Tcl_IncrRefCount(opts);
	Tcl_ListObjAppendList(tcl::interp(), opts, m_opts);
	Tcl_ListObjAppendElement(tcl::interp(), opts, m_objBefore);
	Tcl_ListObjAppendElement(tcl::interp(), opts, succ->path());

	node->m_parent = this;
	tcl::call(__func__, m_objPackCmd, root()->path(), path(), node->path(), opts, NULL);
	m_childs.insert(mstl::find(m_childs.begin(), m_childs.end(), succ), node);

	Tcl_DecrRefCount(opts);
}


void
Node::packAfter(Node* node, Node const* pred)
{
	M_ASSERT(node);
	M_ASSERT(m_type != Pane && m_type != Frame);
	M_ASSERT(contains(pred));

	Tcl_Obj* opts = Tcl_NewListObj(0, 0);

	Tcl_IncrRefCount(opts);
	Tcl_ListObjAppendList(tcl::interp(), opts, m_opts);
	Tcl_ListObjAppendElement(tcl::interp(), opts, m_objAfter);
	Tcl_ListObjAppendElement(tcl::interp(), opts, pred->path());

	node->m_parent = this;
	tcl::call(__func__, m_objPackCmd, root()->path(), path(), node->path(), opts, NULL);
	m_childs.insert(mstl::find(m_childs.begin(), m_childs.end(), pred) + 1, node);

	Tcl_DecrRefCount(opts);
}


void
Node::pack(Node* node)
{
	M_ASSERT(node);
	M_ASSERT(m_type != Pane && m_type != Frame);

	node->m_parent = this;
	tcl::call(__func__, m_objPackCmd, root()->path(), path(), node->path(), m_opts, NULL);
	m_childs.push_back(node);
}


void
Node::pack(Childs const& childs)
{
	M_ASSERT(m_type != Pane && m_type != Frame);

	for (Childs::const_iterator i = childs.begin(); i != childs.end(); ++i)
		pack(*i);
}


void
Node::unpack(unsigned index)
{
	M_ASSERT(m_type != Pane && m_type != Frame);
	M_ASSERT(index < m_childs.size());

	m_childs[index]->m_parent = 0;
	tcl::call(__func__, m_objUnpackCmd, root()->path(), m_parent->path(), m_childs[index]->path(), NULL);
}


void
Node::unpack(Node const* node)
{
	M_ASSERT(m_type != Pane && m_type != Frame);
	M_ASSERT(contains(node));

	Childs::iterator i = mstl::find(m_childs.begin(), m_childs.end(), node);
	unpack(i - m_childs.begin());
	m_childs.erase(i);
}


void
Node::unpack()
{
	m_childs.clear();

	if (m_type == Notebook || m_type == PanedWindow)
		tcl::call(__func__, m_objUnpackCmd, root()->path(), path(), NULL);
}


enum Relation { Successor, Predecessor, Ancestor };

} // namespace


static char const* CmdTwm = "::scidb::tk::twm";


static void
insertNode(Node* root, Node* relative, Relation relation, Node* node)
{
	M_ASSERT(root);
	M_ASSERT(relative);
	M_ASSERT(node);
	M_ASSERT(node->type() == Pane);

	switch (relation)
	{
		case Predecessor:
			switch (root->type())
			{
				case Pane:
				case Frame:
				case Notebook:
					{
						Node* panw = new Node(PanedWindow);
						Node* pane = root->child(0);

						root->unpack();
						root->pack(panw);
						panw->pack(node);
						panw->pack(pane);
					}
					break;

				case PanedWindow:
					root->packBefore(node, relative);
					break;
			}
			break;

		case Successor:
			switch (root->type())
			{
				case Pane:
				case Frame:
				case Notebook:
					{
						Node* panw = new Node(PanedWindow);
						Node* pane = root->child(0);

						root->unpack();
						root->pack(panw);
						panw->pack(pane);
						panw->pack(node);
					}
					break;

				case PanedWindow:
					root->packAfter(node, relative);
					break;
			}
			break;

		case Ancestor:
			switch (root->type())
			{
				case Pane:
				case Frame:
					{
						Node* nobk = new Node(Notebook);
						Node* pane = root->child(0);

						root->unpack();
						root->pack(nobk);
						nobk->pack(pane);
						nobk->pack(node);
					}
					break;

				case Notebook:
					root->pack(node);
					break;

				case PanedWindow:
					M_RAISE("%s: paned window cannot be an ancestor", __func__);
					break;
			}
			break;
	}
}


static int
cmdCapture(int objc, Tcl_Obj* const objv[])
{
	Tk_Window tkmain		= Tk_MainWindow(interp());
	Tk_Window tkwin		= Tk_NameToWindow(interp(), stringFromObj(objc, objv, 0), tkmain);
	Tk_Window tkparent	= 0;

	if (!tkwin)
	{
		appendResult("invalid window '%s'", stringFromObj(objc, objv, 0));
		return TCL_ERROR;
	}

	if (objc >= 2)
	{
		tkparent = Tk_NameToWindow(interp(), stringFromObj(objc, objv, 1), tkmain);

		if (!tkparent)
		{
			appendResult("invalid parent '%s'", stringFromObj(objc, objv, 1));
			return TCL_ERROR;
		}
	}

	return captureWindow(interp(), tkmain, tkwin, tkparent) ? TCL_OK : TCL_ERROR;
}


static int
cmdRelease(int objc, Tcl_Obj* const objv[])
{
	Tk_Window tkmain	= Tk_MainWindow(interp());
	Tk_Window tkwin	= Tk_NameToWindow(interp(), stringFromObj(objc, objv, 0), tkmain);

	if (!tkwin)
	{
		appendResult("invalid window '%s'", stringFromObj(objc, objv, 0));
		return TCL_ERROR;
	}

	return releaseWindow(interp(), tkmain, tkwin) ? TCL_OK : TCL_ERROR;
}


static void
traverseList(Node* root, Node* parent, Tcl_Obj* list)
{
	M_ASSERT(root);
	M_ASSERT(parent);
	M_ASSERT(list);

	Tcl_Obj**	objv;
	int			objc;

	if (Tcl_ListObjGetElements(interp(), list, &objc, &objv) != TCL_OK)
		M_RAISE("%s: list object expected", __func__);
	if (objc < 2)
		M_RAISE("%s: list too short", __func__);

	Tcl_Obj**	args;
	int			argc;

	if (Tcl_ListObjGetElements(interp(), objv[1], &argc, &args) != TCL_OK)
		M_RAISE("%s: list object expected", __func__);
	if (argc == 0)
		M_RAISE("%s: list too short", __func__);

	char const*	what = stringFromObj(objc, objv, 0);
	Type			type = Pane;

	switch (what[0])
	{
		case 'p': type = (::strcmp(what, "pane") == 0) ? Pane : PanedWindow; break;
		case 'f': type = Frame; break;
		case 'n': type = Notebook; break;
	}

	Node* node = new Node(type);
	node->create(root, argc, args);
	root->pack(node);

	for (int i = 2; i < objc; ++i)
		traverseList(root, node, objv[i]);
}


static int
cmdInit(int objc, Tcl_Obj* const objv[])
{
	Node::initialize();
	Node* root = new Node(objectFromObj(objc, objv, 0));
	traverseList(root, root, objectFromObj(objc, objv, 1));
	root->configure();
	return TCL_OK;
}


static int
cmdAdd(int objc, Tcl_Obj* const objv[])
{
insertNode(0, 0, Ancestor, 0);
#if 0
	Node* newn = new Node(objectFromObj(objc, objv, 1), objectFromObj(objc, objv, 2));
	Node* root = Node::lookupRoot(stringFromObj(objc, objv, 0));

	root->clearCommands();

	if (side == Center)
	{
		M_ASSERT(root->isEmpty());

		root->pack(newn);
	}
	else
	{
		M_ASSERT(root->size() == 1);

		while (root->child(0)->side() != side)
			root = root->child(0);

		if (root->child(0)->side() == side)
		{
			insertNode(root, root->child(0), newn);
		}
		else
		{
			M_ASSERT(root->size() == 1);

			Node* pane = new Node(PanedWindow);
			Node* chld = root->child(0);

			root->unpack(chld);
			pane->pack(chld);
			pane->pack(newn);
			root->pack(pane);
		}
	}

	setResult(root->makeCommands());
	root->clearCommands();
#endif

	return TCL_OK;
}


static int
cmdRemove(int objc, Tcl_Obj* const objv[])
{
#if 0
	int	pos	= Node::positionFromName(stringFromObj(objc, objv, 1));
	Node* root	= &Node::m_root;
	Node*	node	= root->find(pos);

	if (node == 0)
	{
		appendResult("cannot find position %d", pos);
		return TCL_ERROR;
	}

	node->parent()->unpack(node->position());
	setResult(root->makeCommands());
	root->clearCommands();
#endif

	return TCL_OK;
}


static int
cmdTwm(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] = { "init", "add", "remove", "capture", "release", 0 };
	struct { char const* usage; int min_args; } const definitions[] =
	{
		{ "<root> <node-list>", 1 },
		{ "<root> <widget> ?left|right|above|below|before|after|at <widget>?", 2 },
		{ "<root> <widget>", 1 },
		{ "<widget> <new-parent>", 2 },
		{ "<widget>", 1 },
	};
	enum { Cmd_Init, Cmd_Add, Cmd_Remove, Cmd_Capture, Cmd_Release };

	if (objc < 2)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "subcommand ?options?");
		return TCL_ERROR;
	}

	int index;
	int result = Tcl_GetIndexFromObj(ti, objv[1], subcommands, "subcommand", TCL_EXACT, &index);

	if (result != TCL_OK)
		return TCL_ERROR;

	if (objc < definitions[index].min_args)
	{
		Tcl_WrongNumArgs(ti, 1, objv, definitions[index].usage);
		return TCL_ERROR;
	}

	objv += 2;
	objc -= 2;

	switch (index)
	{
		case Cmd_Init:		return cmdInit(objc, objv);
		case Cmd_Add:		return cmdAdd(objc, objv);
		case Cmd_Remove:	return cmdRemove(objc, objv);
		case Cmd_Capture:	return cmdCapture(objc, objv);
		case Cmd_Release:	return cmdRelease(objc, objv);
	}

	return TCL_OK;	// not reached
}


void
tk::twm_init(Tcl_Interp* ti)
{
	Tcl_PkgProvide(ti, "tktwm", "1.0");
	createCommand(ti, CmdTwm, cmdTwm);
}

// vi:set ts=3 sw=3:
