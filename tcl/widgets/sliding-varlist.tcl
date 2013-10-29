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

array set Slide {
	open	3
	close	3
}

array set Options {
	slide:position bottom
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
	$t state define current

	$t element create elemMov text -lines 1
	$t element create elemNum text -lines 1 -fill darkred
	$t element create elemRec rect

	set s [$t style create styMov]
	$t style elements $s {elemRec elemMov}
	$t style layout $s elemMov -padx {2 4} -pady {1 1} -expand ns -sticky w
	$t style layout $s elemRec -detach yes -iexpand xy

	set s [$t style create styNum]
	$t style elements $s {elemRec elemNum}
	$t style layout $s elemNum -padx {4 2} -pady {1 1} -expand ns -sticky w
	$t style layout $s elemRec -detach yes -iexpand xy

	$t notify install <Item-enter>
	$t notify install <Item-leave>
	$t notify bind $t <Item-enter> [namespace code { VisitItem enter %C %I }]
	$t notify bind $t <Item-leave> [namespace code { VisitItem leave %C %I }]

	set item [$t item create]
	$t item lastchild root $item
	MakeColumn $t 1

	set Vars(parent) $parent
	set Vars(list) $t
	set Vars(frame) $f
	set Vars(selectcmd) $selectcmd
	set Vars(current) 0
	set Vars(size) 0

	SetupOrientation
}


proc SetupOrientation {} {
	variable Vars

	set t $Vars(list)

	if {[vertical?]} {
		set orient vertical
		set justify left
		foreach col [lrange [$t column list] 2 end] { $t column delete $col }
	} else {
		set orient horizontal
		set justify center
		catch { $t item delete 2 end }
	}

	$t configure -orient $orient

	foreach col [$t column list] {
		$t column configure $col -justify $justify
	}
}


proc show {moves {slide 1}} {
	variable Slide
	variable Vars

	set Vars(size) [llength $moves]

	if {[llength $moves] == 0} {
		if {$Vars(state) eq "open" || $Vars(state) eq "active"} { hide }
		return
	}

	set t $Vars(list)
	Resize $t [llength $moves]

	set item 1
	set col 1
	if {[horizontal?]} { set cincr 2; set iincr 0 } else { set cincr 0; set iincr 1 }
	set color [::colors::lookup varslider,background]
	foreach move $moves {
		set c1 c$col
		set c2 c[expr {$col + 1}]
		$t item element configure $item $c1 elemRec -fill $color
		$t item element configure $item $c2 elemRec -fill $color
		$t item element configure $item $c2 elemMov -text $move
		incr item $iincr
		incr col $cincr
	}

	Layout $t
	raise $Vars(frame)

	set Vars(current) 0
	SetCurrent 1
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
		set delay $Slide(open)
		if {[vertical?]} { set delay [expr {$delay/3}] }
		set Vars(afterid) [after $Slide(open) [namespace code [list SlideToShow $delay]]]]
	}
}


proc hide {{slide 1}} {
	variable ::application::board::board
	variable Slide
	variable Vars

	::board::diagram::clearAlternatives $board

	if {$Vars(state) ne "close" && $Vars(state) ne "hidden"} {
		after cancel $Vars(afterid)
		set Vars(afterid) {}

		if {$slide} {
			set Vars(state) close
			set delay $Slide(close)
			if {[vertical?]} { set delay [expr {$delay/3}] }
			SlideToHide $delay
		} else {
			set Vars(state) hidden
			place forget $Vars(frame)
		}
	}
}


proc handle {key state} {
	variable Vars

	if {$Vars(state) eq "open"} { return 2 }

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
					if {[string is alpha $key]} { set key [expr {[::util::charToInt $key] + 10}] }
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
	set i $Vars(current)
	set n $Vars(size)

	if {[incr i $dir] == 0} {
		set i $n
	} elseif {$i > $n} {
		set i 1
	}

	SetCurrent $i
}


proc ConfigureElement {weight} {
	variable Vars

	if {[horizontal?]} {
		set item 1
		set col [expr {2*($Vars(current) - 1) + 1}]
	} else {
		set item $Vars(current)
		set col 1
	}
	set font [list [list $::font::text(editor:$weight)]]
	set specialfont [list [list $::font::figurine(editor:$weight) 9812 9823]]
	$Vars(list) item element configure $item c$col elemNum -font $font
	$Vars(list) item element configure $item c[incr col] elemMov -font $font -specialfont $specialfont
}


proc SetCurrent {column} {
	variable Vars

	if {$Vars(current) > 0} { ConfigureElement normal }
	set Vars(current) $column
	ConfigureElement bold
}


proc VisitItem {mode col item} {
	variable Vars

	if {[string length $item] > 0 && [string length $col] > 0} {
		if {$col % 2 == 1} { incr col -1 }
		if {$mode eq "enter"} { set attr hilite } else { set attr background }
		set color [::colors::lookup varslider,$attr]
		$Vars(list) item element configure $item $col elemRec -fill $color
		$Vars(list) item element configure $item [expr {$col + 1}] elemRec -fill $color
	}
}


proc Select {item col} {
	variable Vars

	if {[horizontal?]} { set i [expr {($col + 2)/2}] } else { set i $item }
	{*}$Vars(selectcmd) [expr {$i - 1}]
}


proc SelectActive {} {
	variable Vars
	{*}$Vars(selectcmd) [expr {$Vars(current) - 1}]
}


proc SetupElement {t item col num} {
	set col [expr {2*($col - 1) + 1}]
	$t item style set $item c$col styNum
	if {$num >= 10} { set num [::util::intToChar [expr {$num - 10}]] }
	$t item element configure $item c$col elemNum -text $num
	$t item style set $item c[incr col] styMov
}


proc MakeColumn {t i} {
	if {[vertical?]} { set justify left } else { set justify center }
	set j [expr {2*($i - 1) + 1}]
	set k [expr {$j + 1}]
	$t column create     \
		-justify $justify \
		-expand no        \
		-steady yes       \
		-borderwidth 0    \
		-visible yes      \
		-button no        \
		-expand no        \
		-tag c$j          \
		;
	$t column create     \
		-justify $justify \
		-expand no        \
		-steady yes       \
		-borderwidth 0    \
		-visible yes      \
		-button no        \
		-expand no        \
		-tag c$k          \
		;
	SetupElement $t 1 $i [expr {$i - 1}]
}


proc Resize {t nentries} {
	variable Options

	if {[horizontal?]} {
		set n [expr {[$t column count]/2}]
		set k [expr {min($n,$nentries)}]

		for {set i 1} {$i <= $k} {incr i} {
			set c [expr {2*($i - 1) + 1}]
			$t column configure c$c -visible yes
			$t column configure c[expr {$c + 1}] -visible yes
		}

		if {$i < $nentries} {
			for {} {$i <= $nentries} {incr i} {
				MakeColumn $t $i
			}
		} elseif {$nentries < $i} {
			for {} {$i <= $n} {incr i} {
				set c [expr {2*($i - 1) + 1}]
				$t column configure c$c -visible no
				$t column configure c[expr {$c + 1}] -visible no
			}
		}
	} else {
		set n [expr {[$t item count] - 1}]

		if {$n < $nentries} {
			for {incr n} {$n <= $nentries} {incr n} {
				set item [$t item create]
				$t item lastchild root $item
				SetupElement $t $item 1 [expr {$n - 1}]
			}
		} elseif {$nentries < $n} {
			$t item delete [expr {$nentries + 1}] end
		}
	}
}


proc Layout {t} {
	set font [list [list $::font::text(editor:bold)]]
	set specialfont [list [list $::font::figurine(editor:bold) 9812 9823]]
	set cols [$t column list -visible]
	set items [expr {[$t item count] - 1}]

	for {set i 1} {$i <= $items} {incr i} {
		foreach {c1 c2} $cols {
			$t item element configure $i $c1 elemNum -font $font
			$t item element configure $i $c2 elemMov -font $font -specialfont $specialfont
		}
	}

	$t column optimize
	update idletasks

	lassign [$t item bbox 1] x0 y0 x1 y1
	set h [expr {$y1 - $y0}]

	if {[vertical?]} {
		set w [expr {[$t column width c1] + [$t column width c2]}]
		set h [expr {$items*$h}]
		for {set i 1} {$i <= $items} {incr i} { lappend rows $i }
		set cols {c1 c2}
	} else {
		set w 0
		foreach c $cols { incr w [$t column width $c] }
		set rows {1}
		set cols  [lrange $cols 2 end]
	}

	$t item element configure 1 c1 elemNum -font $font
	$t item element configure 1 c2 elemMov -font $font -specialfont $specialfont

	set font [list [list $::font::text(editor:normal)]]
	set specialfont [list [list $::font::figurine(editor:normal) 9812 9823]]

	foreach i $rows {
		foreach {c1 c2} $cols {
			$t item element configure $i $c1 elemNum -font $font
			$t item element configure $i $c2 elemMov -font $font -specialfont $specialfont
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
			set x [expr {$Vars(visible) - [winfo reqwidth $Vars(frame)]}]
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
			set y [expr {$Vars(visible) - [winfo reqheight $Vars(frame)]}]
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
			TreeCtrl::CursorCheck $t $x $y
			TreeCtrl::MotionInItems $t $x $y
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
	::variation::Select [lindex $id 1] [lindex $id 3]
}

bind SlidingVarPane <Leave> {
	TreeCtrl::CursorCancel %W
	TreeCtrl::MotionInItems %W
}

# vi:set ts=3 sw=3:
