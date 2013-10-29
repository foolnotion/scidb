# ======================================================================
# Author : $Author$
# Version: $Revision: 974 $
# Date   : $Date: 2013-10-16 16:17:54 +0200 (Wed, 16 Oct 2013) $
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
# Copyright: (C) 2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source sliding-variation-list

package require tktreectrl 2.2

namespace eval variation {

array set Vars {
	afterid 	{}
	state		hidden
	visible	0
}

array set Options {
	slide:open		6
	slide:close		4
	slide:position	bottom
}


proc use? {} {
	variable Options
	return [expr {$Options(slide:position) ne "hidden"}]
}


proc horizontal? {} {
	variable Options
	return [expr {$Options(slide:position) eq "top" || $Options(slide:position) eq "bottom"}]
}


proc vertical? {} {
	variable Options
	return [expr {$Options(slide:position) eq "left" || $Options(slide:position) eq "right"}]
}


proc build {parent selectcmd} {
	variable Vars

	set background [::colors::lookup varslider,background]
	set f [tk::frame $parent.f -background $background -takefocus 0]
	set t $f.list

	treectrl $t                \
		-class SlidingVarPane   \
		-borderwidth 0          \
		-highlightthickness 0   \
		-takefocus 0            \
		-showroot no            \
		-showheader no          \
		-showbuttons no         \
		-showlines no           \
		-showrootlines no       \
		-selectmode single      \
		-background $background \
		;
	grid $t -row 1 -column 1 -sticky nsew
	grid columnconfigure $f {0 2} -minsize 5
	grid columnconfigure $f {1} -weight 1
	grid rowconfigure $f {0 2} -minsize 5
	grid rowconfigure $f {1} -weight 1

	$t state define hilite

	$t element create elemMov text -lines 1
	$t element create elemNum text -lines 1 -fill darkred
	$t element create elemRec rect

	set s [$t style create styMove]
	$t style elements $s {elemRec elemNum elemMov}
	$t style layout $s elemNum -padx {4 2} -pady {1 1} -expand ns -sticky e
	$t style layout $s elemMov -padx {2 4} -pady {1 1} -expand ns -sticky w
	$t style layout $s elemRec -detach yes -iexpand xy

	$t notify install <Item-enter>
	$t notify install <Item-leave>
	$t notify bind $t <Item-enter> [namespace code { VisitItem enter %I }]
	$t notify bind $t <Item-leave> [namespace code { VisitItem leave %I }]

	$t column create  \
		-expand no     \
		-steady no     \
		-borderwidth 0 \
		-visible yes   \
		-justify left  \
		-button no     \
		-expand no     \
		-tag col       \
		;

	set Vars(parent) $parent
	set Vars(list) $t
	set Vars(frame) $f
	set Vars(selectcmd) $selectcmd
	set Vars(active) 0
	set Vars(size) 0

	SetupOrientation
	bind $t <Map> [namespace code { SetupElements %W }]
}


proc SetupElements {t} {
	set font [list \
		$::font::text(editor:normal) {!active} \
		$::font::text(editor:bold) {active} \
	]
	set specialfont [list \
		[list $::font::figurine(editor:normal) 9812 9823] {!active} \
		[list $::font::figurine(editor:bold) 9812 9823] {active} \
	]
	set colors [list \
		[::colors::lookup varslider,background] {!hilite} \
		[::colors::lookup varslider,active] {hilite} \
	]
	$t element configure elemMov -font $font -specialfont $specialfont
	$t element configure elemNum -font $font
	$t element configure elemRec -fill $colors
}


proc SetupOrientation {} {
	variable Vars

	if {[vertical?]} { set orient vertical } else { set orient horizontal }
	$Vars(list) configure -orient $orient
}


proc show {moves {slide 1}} {
	variable Options
	variable Vars

	set Vars(size) [llength $moves]

	if {[llength $moves] == 0} {
		if {$Vars(state) eq "open" || $Vars(state) eq "active"} { hide }
		return
	}

	set t $Vars(list)
	Resize $t [llength $moves]

	set item 0
	foreach move $moves {
		$t item element configure [incr item] col elemMov -text $move
	}

	Layout $t
	raise $Vars(frame)

	set Vars(active) 1
	$t activate 1
	if {[horizontal?]} { set Vars(reqsize) reqheight } else { set Vars(reqsize) reqwidth }

	if {$Vars(state) eq "active"} {
		PlacePane
	} elseif {!$slide} {
		after cancel $Vars(afterid)
		set Vars(afterid) {}
		set Vars(visible) [winfo height $t]
		PlacePane
	} elseif {$Vars(state) ne "open"} {
		set Vars(visible) 0
		set Vars(state) open
		set delay $Options(slide:open)
		if {[vertical?]} { set delay [expr {$delay/2}] }
		set Vars(afterid) [after $delay [namespace code [list SlideToShow $delay]]]]
	}
}


proc hide {{slide 1}} {
	variable ::application::board::board
	variable Options
	variable Vars

	::board::diagram::clearAlternatives $board

	if {$Vars(state) ne "close" && $Vars(state) ne "hidden"} {
		after cancel $Vars(afterid)
		set Vars(afterid) {}

		if {$slide} {
			set Vars(state) close
			set delay $Options(slide:close)
			if {[vertical?]} { set delay [expr {$delay/2}] }
			SlideToHide $delay
		} else {
			set Vars(state) hidden
			place forget $Vars(frame)
		}
	}
}


proc handle {key state} {
	variable Vars

	if {[string match KP_* $key]} {
		set key [string range $key 3 end]
	}

	if {$Vars(state) eq "active"} {
		switch $key {
			Escape			{ hide; return 2 }
			Return - space	{ SelectActive; return 1 }

			Left - Right {
				if {[horizontal?]} {
					Go [expr {$key eq "Left" ? -1 : +1}]
					return 1
				} else {
					hide
					return 2
				}
			}

			Up - Down {
				if {[vertical?]} {
					Go [expr {$key eq "Up" ? -1 : +1}]
					return 1
				} else {
					hide
					return 2
				}
			}

			default {
				if {[string is alnum -strict $key] && [string length $key] == 1} {
					if {[string is alpha $key]} { set key [::util::charToInt $key] }
					if {$key < $Vars(size)} {
						{*}$Vars(selectcmd) $key
						return 1
					}
				}
			}
		}
	}

	return 0
}


proc active? {} {
	variable Vars
	return [expr {$Vars(state) eq "active"}]
}


proc addToMenu {m} {
	foreach pos {hidden bottom top left right} {
		$m add radiobutton \
			-compound left \
			-label [set ::mc::[string toupper $pos 0 0]] \
			-variable [namespace current]::Options(slide:position) \
			-value $pos \
			-command [namespace code SetupOrientation] \
			;
		::theme::configureRadioEntry $m
	}
}


proc Go {dir} {
	variable Options
	variable Vars

	set t $Vars(list)
	set i $Vars(active)
	set n $Vars(size)

	if {[incr i $dir] == 0} {
		set i $n
	} elseif {$i > $n} {
		set i 1
	}

	set Vars(active) $i
	$t activate $i
}


proc VisitItem {mode item} {
	variable Vars

	if {[string length $item] > 0} {
		if {$mode eq "enter"} { set exclam "" } else { set exclam ! }
		$Vars(list) item state set $item ${exclam}hilite
	}
}


proc Select {item} {
	variable Vars
	{*}$Vars(selectcmd) [expr {$item - 1}]
}


proc SelectActive {} {
	variable Vars
	Select $Vars(active)
}


proc Resize {t nentries} {
	variable Options

	set n [expr {[$t item count] - 1}]

	if {$n < $nentries} {
		for {} {$n < $nentries} {incr n} {
			set item [$t item create]
			$t item lastchild root $item
			$t item style set $item col styMove
			set k $n
			if {$k >= 10} { set k [::util::intToChar $k] }
			$t item element configure $item col elemNum -text $k
		}
	} elseif {$nentries < $n} {
		$t item delete $n end
	}
}


proc Layout {t} {
	update idletasks
	$t column optimize

	set n [expr {[$t item count] - 1}]
	set w 0
	set h 0

	if {[vertical?]} {
		for {set i 1} {$i <= $n} {incr i} {
			lassign [$t item bbox $i] x0 y0 x1 y1
			set h [expr {$h + $y1 - $y0}]
			set w [expr {max($w, $x1 - $x0)}]
		}
	} else {
		for {set i 1} {$i <= $n} {incr i} {
			lassign [$t item bbox $i] x0 y0 x1 y1
			set h [expr {max($h, $y1 - $y0)}]
			set w [expr {$w + $x1 - $x0}]
		}
	}

	$t configure -width [expr {$w + 2*[$t cget -borderwidth]}] -height $h
}


proc PlacePane {} {
	variable Options
	variable Vars

	if {$Options(slide:position) eq "left" || $Options(slide:position) eq "right"} {
		set ph [winfo height $Vars(parent)]
		set lh [winfo height $Vars(list)]
		set y0 [expr {max(5, ($ph - $lh)/2)}]

		if {$Options(slide:position) eq "left"} {
			set rel 0.0
			set x [expr {$Vars(visible) - [winfo width $Vars(frame)]}]
		} else {
			set rel 1.0
			set x [expr {-$Vars(visible)}]
		}

		place $Vars(frame) -y $y0 -relx $rel -x $x
	} else {
		set pw [winfo width $Vars(parent)]
		set lw [winfo width $Vars(list)]
		set x0 [expr {max(5, ($pw - $lw)/2)}]

		if {$Options(slide:position) eq "top"} {
			set rel 0.0
			set y [expr {$Vars(visible) - [winfo height $Vars(frame)]}]
		} else {
			set rel 1.0
			set y [expr {-$Vars(visible)}]
		}

		place $Vars(frame) -x $x0 -rely $rel -y $y
	}
}


proc SlideToShow {delay} {
	variable Options
	variable Vars

	if {![winfo exists $Vars(frame)]} { return }
	if {$Vars(state) ne "open"} { return }

	incr Vars(visible) +1
	PlacePane

	if {$Vars(visible) < [winfo $Vars(reqsize) $Vars(frame)]} {
		set Vars(afterid) [after $delay [namespace code [list SlideToShow $delay]]]
	} else {
		set Vars(afterid) {}
		set Vars(state) active

		set t $Vars(list)
		lassign [winfo pointerxy $Vars(list)] x y
		set x [expr {$x - [winfo rootx $t]}]
		set y [expr {$y - [winfo rooty $t]}]
		set id [$t identify $x $y]
		if {[lindex $id 0] eq "item"} {
			VisitItem enter [lindex $id 1]
		}
	}
}


proc SlideToHide {delay} {
	variable Options
	variable Vars

	if {![winfo exists $Vars(frame)]} { return }
	if {$Vars(state) ne "close"} { return }

	if {$Vars(visible) == 0} {
		place forget $Vars(frame)
		set Vars(afterid) {}
		set Vars(state) hidden
	} else {
		incr Vars(visible) -1
		PlacePane
		set Vars(afterid) [after $delay [namespace code [list SlideToHide $delay]]]
	}
}


proc WriteOptions {chan} {
	::options::writeItem $chan [namespace current]::Options
}

::options::hookWriter [namespace current]::WriteOptions

} ;# namespace variation


bind SlidingVarPane <Motion> {
	TreeCtrl::CursorCheck %W %x %y
	TreeCtrl::MotionInItems %W %x %y
}

bind SlidingVarPane <ButtonPress-1> {
	set id [%W identify %x %y]
	if {$id eq ""} { return }
	if {[lindex $id 0] eq "header"} { return }
	::variation::Select [lindex $id 1]
}

bind SlidingVarPane <Leave> {
	TreeCtrl::CursorCancel %W
	TreeCtrl::MotionInItems %W
}

# vi:set ts=3 sw=3:
