# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# ======================================================================
#    _/|            __
#   // o\         /    )           ,        /    /
#   || ._)    ----\---------__----------__-/----/__-
#   //__\          \      /   '  /    /   /    /   )
#   )___(     _(____/____(___ __/____(___/____(___/_
# ======================================================================

# ======================================================================
# Copyright: (C) 2011 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

namespace eval engine {

variable Engines {}


proc choose {parent} {
	variable Engines
	global photo_Engine

	set dlg $parent.chooseEngine
	toplevel $dlg -class Scidb
	wm withdraw $dlg
	set top [ttk::frame $dlg.top]
	pack $top

	set list [::tlistbox $top.list -usescroll yes -padx 15 -pady 15]
	pack $list -expand yes -fill both
	$list addcol image -id icon
	foreach entry $Engines {
		array set opts $entry
		set hasLogo 0

		if {[info exists photo_Engine($opts(Logo))]} {
			lassign $photo_Engine($opts(Logo)) file offset size

			catch {
				set fd [open $file]
				seek $fd $offset start
				set data [read $fd $size]
				set photo [image create photo -data $data]
				$list insert [list $photo]
				set hasLogo 1}
		}

		if {!$hasLogo} {
			# TODO use big font
			$list insert [list $opts(Name)]
		}
	}
	$list resize
	
#	::widget::dialogButtons $dlg cancel cancel
#	$dlg.ok configure -command [list destroy $dlg]
#	$dlg.cancel configure -command [list destroy $dlg]

	wm resizable $dlg false true
	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	::util::place $dlg center $parent
	wm deiconify $dlg
}


proc engine {entry} {
	lappend [namespace current]::Engines $entry
}


proc engines {} {
	variable Engines

	set list {}

	foreach entry $Engines {
		array set opts $entry
		lappend list [list $opts(Name) $opts(Timestamp)]
	}

	set entries [lsort  -dictionary -index 0 $list]
	set entries [lsort -integer -index 1 $entries]
	set list {}
	foreach entry $entries { lappend list [lindex $entry 0] }
	return $list
}


proc WriteOptions {chan} {
	options::writeItem $chan [namespace current]::Engines
}

::options::hookWriter [namespace current]::WriteOptions

} ;# namespace engine

# vi:set ts=3 sw=3:
