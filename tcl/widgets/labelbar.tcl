# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# ======================================================================
# Copyright: (C) 2010-2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

package require Ttk

namespace eval ttk {

proc labelbar {w text} {
	return [labelbar::Build $w $text]
}


namespace eval labelbar {

proc Build {w text} {
	::frame $w -borderwidth 0
	::frame $w.top -height 1 -background black
	::label $w.lbl -borderwidth 0 -background grey52 -foreground white -font TkCaptionFont
	if {[info exists $text]} {
		$w.lbl configure -textvar $text
	} else {
		$w.lbl configure -text $text
	}
	::frame $w.bot -height 1 -background black
	#::ttk::separator $w.bot

	grid $w.top -sticky ew -row 0 -column 0
	grid $w.lbl -sticky ew -row 1 -column 0
	grid $w.bot -sticky ew -row 2 -column 0
	grid columnconfigure $w 0 -weight 1

	return $w
}

} ;# namespace labelbar
} ;# namespace ttk

# vi:set ts=3 sw=3:
