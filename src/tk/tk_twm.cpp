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

#else

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

#else

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
	// in tkWinWm or tkUnixWm.c Is having this event handler around really cause
	// a problem?
//		Tk_DeleteEventHandler(tkwin, StructureNotifyMask, TopLevelEventProc, winPtr);

	return 1;
}

#undef None

using namespace tcl;


static char const* KeyPosition	= "-position";
static char const* KeyExpand		= "-expand";
static char const* KeySide			= "-side";


namespace {

struct Node;
typedef mstl::vector<Node*> Childs;
typedef mstl::list<mstl::string> Commands;

enum Type	{ Widget, PanedWindow, Notebook };
enum Side	{ Center, Left, Right, Top, Bottom};
enum Expand	{ None, X = 1, Y = 2 };
enum Orient	{ Horizontal = X, Vertical = Y };


class Node
{
public:

	static int const MinPos		= INT_MIN;
	static int const MaxPos		= INT_MAX;
	static int const Increment	= 10;

	Node();
	Node(Type type);
	Node(Tcl_Obj* name, Tcl_Obj* opts);
	~Node() throw();

	bool isEmpty() const;
	bool isExpandable(Orient orient) const;

	char const* name() const;
	Type type() const;
	Side side() const;
	int position() const;
	int minPosition() const;
	int maxPosition() const;
	int expand() const;
	Node* parent() const;
	Node* child(unsigned index) const;
	Node* firstChild() const;
	Node* lastChild() const;
	Childs const& childs() const;
	unsigned size() const;

	Node* find(int position);

	int findPosition(int position) const;

	void pack(Node* node);
	void pack(Childs const& childs);
	void unpack(unsigned index);
	void unpack();

	void renumber();

	static Tcl_Obj* makeCommands();
	static void clearCommands();

	static Node			m_root;
	static Commands	m_commands;

private:

	Tcl_Obj* getValue(char const* key) const;

	void updatePositions();
	void computeExtrema();
	void packAndTrace(Node* node);
	void unpackAndTrace(unsigned index);
	int renumber(int n);

	Type		m_type;
	Tcl_Obj*	m_name;
	Tcl_Obj*	m_opts;
	int		m_minPos;
	int		m_maxPos;
	Childs	m_childs;
	Node*		m_parent;
};

Node Node::m_root;
Commands Node::m_commands;

} // namespace


namespace mstl {

bool operator<(Node const* lhs, Node const& rhs)
{
	return lhs->maxPosition() < rhs.minPosition();
}

} // namespace mstl


namespace {

Type Node::type() const					{ return m_type; }
Childs const& Node::childs() const	{ return m_childs; }
unsigned Node::size() const			{ return m_childs.size(); }
bool Node::isEmpty() const				{ return m_childs.empty(); }

void Node::renumber()					{ renumber(0); }
void Node::clearCommands()				{ m_commands.clear(); }

int Node::minPosition() const			{ return m_minPos; }
int Node::maxPosition() const			{ return m_maxPos; }
int Node::position() const				{ return m_minPos; }


Node::Node()
	:m_type(Widget)
	,m_name(0)
	,m_opts(0)
	,m_minPos(MaxPos)
	,m_maxPos(MinPos)
	,m_parent(0)
{
}


Node::Node(Type type)
	:m_type(type)
	,m_name(0)
	,m_opts(0)
	,m_minPos(MaxPos)
	,m_maxPos(MinPos)
	,m_parent(0)
{
}


Node::Node(Tcl_Obj* name, Tcl_Obj* opts)
	:m_type(Widget)
	,m_name(name)
	,m_opts(opts)
	,m_minPos(MaxPos)
	,m_maxPos(MinPos)
{
	M_ASSERT(name);
	M_ASSERT(opts);

	Tcl_IncrRefCount(m_name);
	Tcl_IncrRefCount(m_opts);

	int pos;

	if (Tcl_GetIntFromObj(interp(), getValue(KeyPosition), &pos) != TCL_OK)
		TCL_RAISE("integer expected for option '%s'", KeyPosition);

	m_minPos = m_maxPos = pos;
}


Node::~Node() throw()
{
	if (m_opts)
		Tcl_DecrRefCount(m_opts);

	for (unsigned i = 0; i < m_childs.size(); ++i)
		delete m_childs[i];
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

	TCL_RAISE("cannot find option '%s'", key);
	return 0;	// never reached
}


Side
Node::side() const
{
	char const* value = Tcl_GetStringFromObj(getValue(KeySide), 0);

	switch (value[0])
	{
		case 'c': return Center;
		case 'l': return Left;
		case 'r': return Right;
		case 't': return Top;
		case 'b': return Bottom;
	}

	return Center;	// should not be reached
}


int
Node::expand() const
{
	char const* value = Tcl_GetStringFromObj(getValue(KeyExpand), 0);

	switch (value[0])
	{
		case 'x': return X;
		case 'y': return Y;
		case 'b': return X | Y;
	}

	return None;
}


Node*
Node::parent() const
{
	return m_parent;
}


char const*
Node::name() const
{
	M_ASSERT(m_name);
	return Tcl_GetStringFromObj(m_name, 0);
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


Node*
Node::find(int position)
{
	for (unsigned i = 0; i < m_childs.size(); ++i)
	{
		Node* child = m_childs[i];

		if (child->m_minPos <= position && position <= child->m_maxPos)
			return child->find(position);
	}

	return position == m_minPos && position == m_maxPos ? this : 0;
}


bool
Node::isExpandable(Orient orient) const
{
	switch (m_type)
	{
		case Widget:
			return expand() & orient;

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


int
Node::findPosition(int position) const
{
	for (unsigned i = 0; i < m_childs.size(); ++i)
	{
		if (position == m_childs[i]->position())
			return i;
	}

	return -1;
}


Tcl_Obj*
Node::makeCommands()
{
	Tcl_Obj* objv[m_commands.size()];

	for (unsigned i = 0; i < m_commands.size(); ++i)
		objv[i] = Tcl_NewStringObj(m_commands[i], m_commands[i].size());

	return Tcl_NewListObj(m_commands.size(), objv);
}


void
Node::packAndTrace(Node* node)
{
	M_ASSERT(node);

	mstl::string cmd;

	if (node->m_name == 0)
	{
		mstl::string name(this->name());

		name += '.';
		name += "notebook";
		name.format("%p", node);

		node->m_name = Tcl_NewStringObj(name, name.size());
	}

	m_childs.insert(mstl::lower_bound(m_childs.begin(), m_childs.end(), *node), node);

	node->m_parent = this;

	cmd += "pack ";
	cmd += name();
	cmd += ' ';
	cmd += node->name();
	cmd += ' ';

	switch (expand())
	{
		case X:		cmd += "{ x }"; break;
		case Y:		cmd += "{ y }"; break;
		case X | Y:	cmd += "{ both }"; break;
		default:		cmd += "{}"; break;
	}

	m_commands.push_back(cmd);

	m_minPos = mstl::min(m_minPos, node->m_minPos);
	m_maxPos = mstl::max(m_maxPos, node->m_maxPos);
}


void
Node::pack(Node* node)
{
	M_ASSERT(node);

	packAndTrace(node);
	updatePositions();
}


void
Node::pack(Childs const& childs)
{
	for (Childs::const_iterator i = childs.begin(); i != childs.end(); ++i)
		packAndTrace(*i);

	updatePositions();
}


void
Node::unpackAndTrace(unsigned index)
{
	M_ASSERT(index < m_childs.size());

	Childs::iterator i = m_childs.begin() + index;
	mstl::string cmd;

	(*i)->m_parent = 0;

	cmd += "unpack ";
	cmd += name();
	cmd += ' ';
	cmd += (*i)->name();

	m_commands.push_back(cmd);
}


void
Node::unpack(unsigned index)
{
	M_ASSERT(index < m_childs.size());

	unpackAndTrace(index);
	m_childs.erase(m_childs.begin() + index);

	m_minPos = MaxPos;
	m_maxPos = MinPos;

	for (Childs::const_iterator i = m_childs.begin(); i != m_childs.end(); ++i)
	{
		m_minPos = mstl::min(m_minPos, (*i)->m_minPos);
		m_maxPos = mstl::max(m_maxPos, (*i)->m_maxPos);
	}
}


void
Node::unpack()
{
	for (unsigned i = 0; i < m_childs.size(); ++i)
		unpackAndTrace(i);

	m_childs.clear();

	m_minPos = MaxPos;
	m_maxPos = MinPos;
}


void
Node::updatePositions()
{
	if (m_parent)
	{
		m_parent->m_minPos = mstl::min(m_parent->m_minPos, m_minPos);
		m_parent->m_maxPos = mstl::max(m_parent->m_maxPos, m_maxPos);
		m_parent->updatePositions();
	}
}


int
Node::renumber(int n)
{
	if (m_type == Widget)
	{
		m_minPos = m_maxPos = n;
		n += Increment;
	}
	else
	{
		for (Childs::iterator i = m_childs.begin(); i != m_childs.end(); ++i)
			n = (*i)->renumber(n);
	}

	return n;
}


void
Node::computeExtrema()
{
	if (m_type != Widget)
	{
		m_minPos = MaxPos;
		m_maxPos = MinPos;

		for (Childs::iterator i = m_childs.begin(); i != m_childs.end(); ++i)
		{
			(*i)->computeExtrema();

			m_minPos = mstl::min(m_minPos, (*i)->m_minPos);
			m_maxPos = mstl::max(m_maxPos, (*i)->m_maxPos);
		}
	}
}

} // namespace


static char const* CmdTwm = "::scidb::tk::twm";


static void
insertNode(Node* pred, Node* curr, Node* node)
{
	M_ASSERT(pred);
	M_ASSERT(curr);
	M_ASSERT(node);
	M_ASSERT(node->type() == Widget);

	int position = node->position();

	if (position >= curr->minPosition() && curr->maxPosition() >= position)
	{
		switch (curr->type())
		{
			case Widget:
				{
					Node* nobk = new Node(Notebook);

					pred->unpack();
					nobk->pack(curr);
					nobk->pack(node);
					pred->pack(nobk);
				}
				break;

			case PanedWindow:
				{
					int childIndex = curr->findPosition(position);

					if (childIndex >= 0)
					{
						Node* widg = curr->child(childIndex);

						if (widg->type() == Notebook)
						{
							widg->pack(node);
						}
						else
						{
							Node* nobk = new Node(Notebook);

							curr->unpack(childIndex);
							nobk->pack(node);
							nobk->pack(widg);
							curr->pack(nobk);
						}
					}
					else
					{
						curr->pack(node);
					}
				}
				break;

			case Notebook:
				curr->pack(node);
				break;
		}
	}
	else
	{
		switch (curr->type())
		{
			case Widget:
			case Notebook:
				{
					Node* pane = new Node(PanedWindow);

					pred->unpack();
					pane->pack(node);
					pane->pack(curr);
					pred->pack(pane);
				}
				break;

			case PanedWindow:
				curr->pack(node);
				break;
		}
	}
}


static int
cmdInit(int objc, Tcl_Obj* const objv[])
{
	return TCL_OK;
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


static int
cmdAdd(int objc, Tcl_Obj* const objv[])
{
	Node* newn = new Node(objectFromObj(objc, objv, 1), objectFromObj(objc, objv, 2));
	Node* root = &Node::m_root;
	Side	side = newn->side();

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

			root->unpack(0);
			pane->pack(chld);
			pane->pack(newn);
			root->pack(pane);
		}
	}

	setResult(root->makeCommands());

	root->renumber();
	root->clearCommands();

	return TCL_OK;
}


static int
cmdRemove(int objc, Tcl_Obj* const objv[])
{
	int	pos	= intFromObj(objc, objv, 1);
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

	return TCL_OK;
}


static int
cmdTwm(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] = { "init", "add", "remove", "capture", "release", 0 };
	struct { char const* usage; int min_args; } const definitions[] =
	{
		{ "<left-list> <right-list> <top-list> <bottom-list>", 4 },
		{ "<widget> ?left|right|above|below|before|after|at <widget>?", 2 },
		{ "<position>", 1 },
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
	createCommand(ti, CmdTwm, cmdTwm);
}

// vi:set ts=3 sw=3:
