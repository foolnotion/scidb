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

namespace eval marks {
namespace eval mc {

set MarksPalette "Marks - Palette"

} ;# namespace mc

array set Vars {
	dialog	{}
}

variable Position		{}
variable ShapeList	{{full circle disk x + - = ? !} {1 2 3 4 5 6 7 8 9}}
variable ShapeSize	20
variable Border		3
variable Lookup

variable ColorList {	red		orange	yellow
							green		blue		darkblue
							purple	white		black}

array set State {
	markColor	red
	markType		full
	square1		-1
	square2		-1
	erase			-1
}


proc open {parent} {
	variable ::toolbar::Defaults
	variable Position
	variable ColorList
	variable ShapeList
	variable State
	variable ShapeSize
	variable Border
	variable Lookup
	variable Vars

	set dlg $parent.__marks__

	if {[winfo exists $dlg]} {
		wm state $dlg normal
		return
	}

	set Vars(dialog) $dlg
	set Vars(hidden) 0
	toplevel $dlg -class Scidb -relief solid
	wm withdraw $dlg
	set title "$::scidb::app: $mc::MarksPalette"

	set top [ttk::frame $dlg.top -relief raised -borderwidth 2]
	pack $dlg.top -fill both -expand yes
	bind $dlg <<Language>> [namespace code [list LanguageChanged $dlg %W]]

	if {[tk windowingsystem] ne "win32"} {
		set decor [tk::label $top.decor -justify left -text $title -font TkSmallCaptionFont]
		set font [$decor cget -font]
		$decor configure -font [list [font configure $font -family] [font configure $font -size] bold]
		pack $decor -fill x -expand yes
		tk::button $decor.close \
			-command [namespace code [list Close $dlg]] \
			-image $::gamebar::icon::15x15::close(locked) \
			;
		Focus $dlg out
		pack $decor.close -side right

		bind $decor <ButtonPress-1>	[namespace code [list StartMotion $top %X %Y]]
		bind $decor <ButtonRelease-1>	[namespace code [list TracePosition $top $parent]]
		bind $decor <Button1-Motion>	[namespace code [list Motion $top %X %Y]]

		grid $decor -row 0 -column 0 -columnspan 100 -sticky ew
		grid rowconfigure $top 2 -minsize $::theme::padding
	}

	set buttonSize [expr {$ShapeSize + 2}]
	set length [llength $ColorList]
	set dark \#8f8f8f
	set norm \#d9d9d9
	set width [expr {$length*$buttonSize + ($length + 1)*$Border}]

	# Top subframe: color (radio)buttons ##################################################
	set canv $top.colors
	set height [expr {$buttonSize + 2*$Border}]
	tk::canvas $canv -height $height -width $width -highlightthickness 0 -borderwidth 0
	::theme::configureCanvas $canv
	set imageSize [expr {$ShapeSize - 2}]

	set y1 $height
	set x0 0
	foreach color $ColorList {
		set x1  [expr {$x0 + $buttonSize + 2*$Border}]
		set bx0 [expr {$x0 + $Border}]
		set by0 $Border
		set bx1 [expr {$x1 - $Border}]
		set by1 [expr {$y1 - $Border}]
		# hilite rectangle
		$canv create rectangle $x0 0 $x1 $y1 -fill black -tags [list hilite hilite:$color] -width 0
		# sunken border
		$canv create rectangle $bx0 $by0 $bx1 $by1 -tag border -fill $dark -width 0
		incr bx0 1; incr by0 1
		$canv create rectangle $bx0 $by0 $bx1 $by1 -tag border -fill white -width 0
		# color content
		incr bx1 -1; incr by1 -1
		$canv create rectangle $bx0 $by0 $bx1 $by1 -tag color -fill white -width 0
		incr bx0 1; incr by0 1
		$canv create rectangle $bx0 $by0 $bx1 $by1 -tag color -fill $color -width 0
		# input rectangle
		incr bx0 -2; incr by0 -2; incr bx1 1; incr by1 1
		$canv create rectangle $bx0 $by0 $bx1 $by1 -tag input:$color -fill {} -width 0
		$canv bind input:$color <ButtonPress-1> \
			[namespace code [list SetMarkColor $canv $top.shapes $color]]
		# prepare for next step
		set x0 [expr {$x1 - $Border}]
	}

	# Bottom subframe: type/shape (radio)buttons ##########################################
	set rows [llength $ShapeList]
	set canv $top.shapes
	set height [expr {$rows*$buttonSize + ($rows + 1)*$Border}]
	tk::canvas $canv -height $height -width $width -highlightthickness 0 -borderwidth 0
	::theme::configureCanvas $canv

	# this board size is not too large; we want to avoid the black borderline
	::board::registerBoardSize $buttonSize
	::board::setupSquares $buttonSize
	set bg(0) photo_Square(lite,$buttonSize)
	set bg(1) photo_Square(dark,$buttonSize)

	set which 0
	set index 0
	set y0 0
	foreach shapeList $ShapeList {
		set x0 0
		set y1 [expr {$y0 + $buttonSize + 2*$Border}]
		foreach shape $shapeList {
			set x1  [expr {$x0 + $buttonSize + 2*$Border}]
			set bx0 [expr {$x0 + $Border}]
			set bx1 [expr {$x1 - $Border}]
			set by0 [expr {$y0 + $Border}]
			set by1 [expr {$y1 - $Border}]
			# hilite rectangle
			set tags [list hilite hilite:$index]
			$canv create rectangle $x0 $y0 $x1 $y1 -fill black -tags $tags -width 0
			# shape content
			$canv create image [expr {$bx0 + 1 + $ShapeSize/2}] [expr {$by0 + 1 + $ShapeSize/2}] \
				-image $bg($which) \
				-tag image \
				;
			# sunken border
			$canv create line $bx0 $by0 $bx1 $by0 -fill $dark -tag border
			$canv create line $bx0 $by0 $bx0 $by1 -fill $dark -tag border
			incr bx0 1; incr by1 -1
			$canv create line $bx0 $by1 $bx1 $by1 -fill white -tag border
			incr bx0 -1; incr by1 1
			incr bx1 -1; incr by0 1
			$canv create line $bx1 $by0 $bx1 $by1 -fill white -tag border
			incr bx1 1; incr by0 -1
			# input rectangle
			$canv create rectangle $bx0 $by0 $bx1 $by1 -tags [list input input:$index] -fill {} -width 0
			$canv bind input:$index <ButtonPress-1> [namespace code [list SetMarkType $canv $shape]]
			# prepare for next step
			set x0 [expr {$x1 - $Border}]
			set which [expr {1 - $which}]
			set Lookup($shape) $index
			incr index
		}
		set y0 [expr {$y1 - $Border}]
		if {$length % 2 == 0} { set $which [expr {1 - $which}] }
	}

	grid $top.colors -row 3 -column 1
	grid $top.shapes -row 5 -column 1

	grid rowconfigure $top {2 4 6} -minsize 3
	grid columnconfigure $top {0 2} -minsize 3

	# "Press" button:
	SetMarkColor $top.colors $top.shapes $State(markColor)
	SetMarkType $top.shapes $State(markType)

	wm transient $dlg $parent
	wm focusmodel $dlg $Defaults(floating:focusmodel)
	if {[tk windowingsystem] ne "win32"} {
		if {$Defaults(floating:overrideredirect)} {
			wm overrideredirect $dlg true
		} elseif {$Defaults(floating:focusmodel) ne "active"} {
			bind $dlg <FocusIn>  [namespace code [list Focus $dlg in]]
			bind $dlg <FocusOut> [namespace code [list Focus $dlg out]]
		}
	}
	if {[llength $Position] == 2} {
		::update idletasks
		scan [winfo geometry [winfo toplevel $parent]] "%dx%d+%d+%d" tw th tx ty
		set rx [expr {$tx + [lindex $Position 0]}]
		set ry [expr {$ty + [lindex $Position 1]}]
		set rw [winfo reqwidth $dlg]
		set rh [winfo reqheight $dlg]
		set sw [winfo screenwidth $dlg]
		set sh [winfo screenheight $dlg]
		set rx [expr {max(min($rx, $sw - $rw), 0)}]
		set ry [expr {max(min($ry, $sh - $rh), 0)}]
		wm geometry $dlg +$rx+$ry
	} else {
		::util::place $dlg center $parent
	}
	if {[tk windowingsystem] eq "aqua"} {
		::tk::unsupported::MacWindowStyle style $dlg plainDBox {}
	} elseif {[tk windowingsystem] eq "win32"} {
		wm attributes $dlg -toolwindow
		wm title $dlg $title
	} else {
		::scidb::tk::wm noDecor $dlg
	}
	Init $dlg
	wm deiconify $dlg
}


proc open? {} {
	variable Vars

	if {[llength $Vars(dialog)] == 0} { return 0 }
	if {![winfo exists $Vars(dialog)]} { return 0 }
	return [expr {[wm state $Vars(dialog)] eq "normal"}]
}


proc hide {flag} {
	variable Vars

	if {[llength $Vars(dialog)] == 0} { return }
	if {![winfo exists $Vars(dialog)]} { return }

	if {$flag} {
		if {[wm state $Vars(dialog)] eq "normal"} {
			wm state $Vars(dialog) withdrawn
			set Vars(hidden) 1
		}
	} else {
		if {$Vars(hidden)} {
			wm state $Vars(dialog) normal
			set Vars(hidden) 0
		}
	}
}


proc close {} {
	variable Vars

	if {[llength $Vars(dialog)]} {
		Close $Vars(dialog)
	}
}


proc pressSquare {x y} {
	variable ::application::board::board
	variable State

	set square [::board::stuff::getSquare $board $x $y]

	if {$State(square1) == -1} {
		# first click: draw sign
		set State(square1) $square
		::board::stuff::setSign $board $square
	} else {
		# second click: draw mark/arrow
		if {$square eq $State(square1)} {
			::board::stuff::eraseSign $board $square
			set type $State(markType)
		} else {
			::board::stuff::setSign $board $square
			set State(square2) $square
			set State(erase) $State(square1)
			set type arrow
		}
		set key [::scidb::game::position key]
		::scidb::game::update marks $key $type $State(markColor) $State(square1) $square
		set State(square1) -1
	}
}


proc unpressSquare {} {
	variable ::application::board::board
	variable State

	if {$State(erase) >= 0} {
		::board::stuff::eraseSign $board $State(erase)
		set State(erase) -1
	}
	if {$State(square2) >= 0} {
		::board::stuff::eraseSign $board $State(square2)
		set State(square2) -1
	}
}


proc releaseSquare {} {
	variable ::application::board::board
	variable State

	if {$State(square1) >= 0} {
		::board::stuff::eraseSign $board $State(square1)
		set State(square1) -1
	}
}


proc Close {dlg} {
	if {[winfo exists $dlg]} {
		wm withdraw $dlg
	}
}


proc Init {dlg} {
	# TODO
}


proc SetMarkType {shapeButtons shape} {
	variable State
	variable Lookup

	$shapeButtons itemconfigure hilite -state hidden
	$shapeButtons itemconfigure hilite:$Lookup($shape) -state normal

	set State(markType) $shape
}


proc SetMarkColor {colorButtons shapeButtons color} {
	variable ShapeList
	variable ShapeSize
	variable Border
	variable State

	$colorButtons itemconfigure hilite -state hidden
	$colorButtons itemconfigure hilite:$color -state normal
	$shapeButtons delete mark

	set State(markColor) $color

	set y [expr {$Border + 1}]
	foreach shapeList $ShapeList {
		set x [expr {$Border + 1}]
		foreach shape $shapeList {
			switch $shape {
				full		{ ::board::stuff::drawFull $shapeButtons $ShapeSize $State(markColor) $x $y }
				disk		{ ::board::stuff::drawDisk $shapeButtons $ShapeSize $State(markColor) $x $y }
				circle	{ ::board::stuff::drawCircle $shapeButtons $ShapeSize $State(markColor) $x $y }
				default	{ ::board::stuff::drawText $shapeButtons $ShapeSize $State(markColor) $x $y $shape }
			}
			incr x [expr {$ShapeSize + $Border + 2}]
		}
		incr y [expr {$ShapeSize + $Border + 2}]
	}

	$shapeButtons raise input
}


proc TracePosition {frame parent} {
	variable Position

	set fx [winfo rootx $frame]
	set fy [winfo rooty $frame]
	set tx [winfo rootx $parent]
	set ty [winfo rooty $parent]

	set Position [list [expr {$fx - $tx}] [expr {$fy - $ty}]]
}


proc StartMotion {frame x y} {
	variable Vars

	set win [winfo parent $frame]
	set Vars(x) [expr {[winfo rootx $win] - $x}]
	set Vars(y) [expr {[winfo rooty $win] - $y}]
}


proc Motion {frame x y} {
	variable Vars

	if {![info exists Vars(x)]} { return }	;# this may happen during a double click

	incr x $Vars(x)
	incr y $Vars(y)
	wm geometry [winfo parent $frame] +$x+$y
}


proc Focus {dlg mode} {
	variable ::toolbar::Defaults

	if {$mode eq "in"} {
		set bg $Defaults(floating:frame:activebg)
		set fg $Defaults(floating:frame:activefg)
	} else {
		set bg $Defaults(floating:frame:background)
		set fg $Defaults(floating:frame:foreground)
	}

	$dlg.top.decor configure -background $bg -foreground $fg
	$dlg.top.decor.close configure \
		-background $bg \
		-foreground $fg \
		-activebackground $bg \
		-activeforeground $fg \
		;
}



proc LanguageChanged {dlg w} {
	if {$dlg eq $w} {
		$dlg.top.decor configure -text "$::scidb::app: $mc::MarksPalette"
	}
}


proc WriteOptions {chan} {
	::options::writeList $chan [namespace current]::Position
}


::options::hookWriter [namespace current]::WriteOptions

} ;# namespace marks

# vi:set ts=3 sw=3:
