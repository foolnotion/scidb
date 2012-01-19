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
# Copyright: (C) 2012 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

namespace eval shadow {

set Used 0


proc prepare {w x y width height} {
	variable Geometry

	if {$width > 1 && $height > 1} {
		set Geometry($w) [list $x $y $width $height]
		Create
	}
}


proc map {w} {
	variable Geometry
	variable Used

	if {![info exists Geometry($w)]} { return }
	lassign $Geometry($w) x y width height

	set b .__shadow__b__$Used
	set r .__shadow__r__$Used
	if {![winfo exists $b]} { return }
	incr Used

	set bx [expr {$x + 5}]
	set by [expr {$y + $height}]
	set rx [expr {$x + $width}]
	set ry [expr {$y + 5}]

	set img [$b.c itemcget image -image]
	$img configure -width $width
	::scidb::tk::x11 region $bx $by $img
	::scidb::tk::image shadow 1.0 x $img

	set img [$r.c itemcget image -image]
	$img configure -height $height
	::scidb::tk::x11 region $rx $ry $img
	::scidb::tk::image shadow 1.0 y $img

	wm geometry $b ${width}x5+${bx}+${by}
	wm geometry $r 5x${height}+${rx}+${ry}
	wm deiconify $b
	wm deiconify $r
	raise $b
	raise $r
}


proc unmap {w} {
	variable Geometry
	variable Used

	if {![info exists Geometry($w)]} { return }
	incr Used -1

	set b .__shadow__b__$Used
	set r .__shadow__r__$Used

	if {[winfo exists $b]} {
		wm withdraw $b
		wm withdraw $r
	} else {
		incr Used
	}
}


proc Create {} {
	variable Geometry
	variable Used

	set b .__shadow__b__$Used
	set r .__shadow__r__$Used

	if {![winfo exists $b]} {
		foreach w [list $b $r] {
			toplevel $w -background black -borderwidth 0 -relief flat -highlightthickness 0
			wm withdraw $w
			wm overrideredirect $w 1
			pack [tk::canvas $w.c -borderwidth 0] -fill both -expand yes
			$w.c xview moveto 0
			$w.c yview moveto 0
		}

		$b.c create image 0 0 -anchor nw -image [image create photo -width 0 -height 5] -tag image
		$r.c create image 0 0 -anchor nw -image [image create photo -width 5 -height 0] -tag image
	}
}

} ;# shadow

### M E N U #####################################################################################

bind Menu <Configure> {+
	if {![string match *#application#menu %W]} {
		shadow::prepare %W %x %y %w %h
	}
}

bind Menu <Map> {+
	if {![string match *#application#menu %W]} {
		after idle [namespace code [list shadow::map %W]]
	}
}

bind Menu <Unmap> {+
	variable ::shadow::Geometry

	if {![string match *#application#menu %W]} {
		shadow::unmap %W
		array unset Geometry %W
	}
}

###  C O M B O B O X ############################################################################

bind ComboboxPopdown <Configure>	{+ shadow::prepare %W %x %y %w %h }
bind ComboboxPopdown <Map>			{+ after idle [list shadow::map %W] }
bind ComboboxPopdown <Unmap>		{+ shadow::unmap %W }
bind ComboboxPopdown <Destroy>	{+ array unset ::shadow::Geometry %W }

###  T O O L T I P ##############################################################################

bind Tooltip <Configure>	{+ if {[winfo class %W] eq "Tooltip"} { shadow::prepare %W %x %y %w %h } }
bind Tooltip <Map>			{+ if {[winfo class %W] eq "Tooltip"} { after idle [list shadow::map %W] } }
bind Tooltip <Unmap>			{+ if {[winfo class %W] eq "Tooltip"} { shadow::unmap %W } }

# vi:set ts=3 sw=3:
