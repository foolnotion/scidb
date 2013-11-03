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

array set Pad {
	l 4
	r 3
	t 3
	b 2
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
	variable Pad

	set background [::colors::lookup varslider,background]

	foreach orient {vert horz} {
		set f [tk::frame $parent.$orient -background $background -borderwidth 0 -takefocus 0]
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
		grid columnconfigure $f {0} -minsize $Pad(l)
		grid columnconfigure $f {2} -minsize $Pad(r)
		grid columnconfigure $f {1} -weight 1
		grid rowconfigure $f {0} -minsize $Pad(t)
		grid rowconfigure $f {2} -minsize $Pad(b)
		grid rowconfigure $f {1} -weight 1

		$t state define hilite
		$t state define current

		$t element create elemMov text -lines 1
		$t element create elemNum text -lines 1 -fill darkred
		$t element create elemRec rect

		set s [$t style create styNum]
		$t style elements $s {elemRec elemNum}
		$t style layout $s elemNum -padx {2 0} -pady {1 1} -expand ns -sticky w
		$t style layout $s elemRec -detach yes -iexpand xy

		set s [$t style create styMov]
		$t style elements $s {elemRec elemMov}
		$t style layout $s elemMov -padx {3 2} -pady {1 1} -expand ns -sticky w
		$t style layout $s elemRec -detach yes -iexpand xy

		$t notify install <Item-enter>
		$t notify install <Item-leave>
		$t notify bind $t <Item-enter> [namespace code { VisitItem enter %C %I }]
		$t notify bind $t <Item-leave> [namespace code { VisitItem leave %C %I }]
	}

	set Vars(parent) $parent
	set Vars(selectcmd) $selectcmd
	set Vars(current) -1
	set Vars(size) 0

	CreateColumns $parent.horz.list 0
	MakeItem $parent.horz.list 0
	CreateColumns $parent.vert.list 0
}


proc show {moves {slide 1}} {
	variable Slide
	variable Vars

	set Vars(size) [llength $moves]

	if {[llength $moves] == 0} {
		if {$Vars(state) eq "open" || $Vars(state) eq "active"} { hide }
		return
	}

	if {[horizontal?]} { set orient horz } else { set orient vert }
	set Vars(frame) $Vars(parent).$orient
	set Vars(list) $Vars(frame).list
	set t $Vars(list)
	$t configure -orient vertical
	set color [::colors::lookup varslider,background]

	while {1} {
		Resize $t [llength $moves]

		set i 0
		foreach move $moves {
			ConfigureElement $t $i elemRec -fill $color
			ConfigureElement $t $i elemRec -fill $color
			ConfigureElement $t $i elemMov -text $move
			incr i
		}

		if {[Layout $t]} { break }

		set Vars(frame) $Vars(parent).vert
		set Vars(list) $Vars(frame).list
		set t $Vars(list)
		$t configure -orient horizontal
	}

	raise $Vars(frame)

	set Vars(current) -1
	SetCurrent 0
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

	if {$Vars(state) eq "active"} {
		if {[string match KP_* $key]} {
			set key [string range $key 3 end]
		}

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
	foreach pos {hidden bottom top right left} {
		$m add radiobutton \
			-compound left \
			-label [set ::mc::[string toupper $pos 0 0]] \
			-variable [namespace current]::Options(slide:position) \
			-value $pos \
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

	if {[incr i $dir] < 0} {
		set i [expr {$n - 1}]
	} elseif {$i == $n} {
		set i 0
	}

	SetCurrent $i
}


proc ConfigureElement {t n elem args} {
	if {[string match *horz* $t]} {
		$t item element configure r0 mov$n $elem {*}$args
	} else {
		$t item element configure r$n mov0 $elem {*}$args
	}
}


proc ConfigureItem {weight} {
	variable Vars

	set font [list [list $::font::text(editor:$weight)]]
	set specialfont [list [list $::font::figurine(editor:$weight) 9812 9823]]
	ConfigureElement $Vars(list) $Vars(current) elemMov -font $font -specialfont $specialfont
}


proc SetCurrent {n} {
	variable Vars

	if {$Vars(current) >= 0} { ConfigureItem normal }
	set Vars(current) $n
	ConfigureItem bold
}


proc VisitItem {mode col item} {
	variable Vars

	if {[string length $item] > 0 && [string length $col] > 0} {
		set t $Vars(list)
		if {$mode eq "enter"} { set attr hilite } else { set attr background }
		set color [::colors::lookup varslider,$attr]
		set col [string range [$t column tag names $col] 3 end]
		$t item element configure $item num$col elemRec -fill $color
		$t item element configure $item mov$col elemRec -fill $color
	}
}


proc Select {item col} {
	variable Vars

	set t $Vars(list)
	if {[string match *horz* $t]} {
		set n [string range [$t column tag names $col] 3 end]
	} else {
		set n [string range [lindex [$t item tag names $item] 0] 1 end]
	}
	{*}$Vars(selectcmd) $n
}


proc SelectActive {} {
	variable Vars
	{*}$Vars(selectcmd) $Vars(current)
}


proc SetupElement {t item col num} {
	$t item style set r$item num$col styNum
	if {$num >= 10} { set num [::util::intToChar [expr {$num - 10}]] }
	$t item element configure r$item num$col elemNum -text $num
	$t item style set r$item mov$col styMov
}


proc CreateColumns {t n} {
	if {[string match *horz* $t]} {
		set justify center
	} else {
		set justify left
	}
	foreach col {num mov} {
		$t column create     \
			-expand no        \
			-steady yes       \
			-justify $justify \
			-borderwidth 0    \
			-button no        \
			-expand no        \
			-tag $col$n       \
			;
	}
}


proc MakeColumns {t n} {
	CreateColumns $t $n
	SetupElement $t 0 $n $n
}


proc MakeItem {t n} {
	set item [$t item create -tag r$n]
	$t item lastchild root $item
	SetupElement $t $n 0 $n
}


proc Resize {t nentries} {
	variable Options
	variable Vars

	if {[string match *horz* $t]} {
		set n [expr {[$t column count]/2}]
		set k [expr {min($n,$nentries)}]

		for {set i 0} {$i < $k} {incr i} {
			$t column configure num$i -visible yes
			$t column configure mov$i -visible yes
		}

		if {$i < $nentries} {
			for {} {$i < $nentries} {incr i} {
				MakeColumns $t $i
				SetupElement $t 0 $i $i
			}
		} elseif {$nentries <= $i} {
			for {} {$i < $n} {incr i} {
				$t column configure num$i -visible no
				$t column configure mov$i -visible no
			}
		}
	} else {
		set n [expr {[$t item count] - 1}]

		if {$n < $nentries} {
			for {} {$n < $nentries} {incr n} {
				set item [$t item create -tag r$n]
				$t item lastchild root $item
				SetupElement $t $n 0 $n
			}
		} elseif {$nentries < $n} {
			for {set i $nentries} {$i < $n} {incr i} {
				$t item delete r$i
			}
		}
	}
}


proc Layout {t} {
	variable Vars
	variable Pad

	set font [list [list $::font::text(editor:bold)]]
	set specialfont [list [list $::font::figurine(editor:bold) 9812 9823]]

	if {[string match *horz* $t]} {
		set count [expr {[$t column count]/2}]
	} else {
		set count [expr {[$t item count] - 1}]
	}

	for {set i 0} {$i < $count} {incr i} {
		ConfigureElement $t $i elemMov -font $font -specialfont $specialfont
	}

	$t column optimize
	update idletasks

	set pw [winfo width $Vars(parent)]
	set ph [winfo height $Vars(parent)]
	set tw 0
	set th 0

	if {[string match *horz* $t]} {
		lassign [$t item bbox r0] _ _ tw th
		if {($tw > $pw - 10 - $Pad(l) - $Pad(r)) == ([$t cget -orient] == "vertical")} { return 0 } 
	} elseif {[horizontal?]} {
		set iw 0
		set ih 0
		set pad [expr {10 + $Pad(l) + $Pad(r)}]

		for {set i 0} {$i < $count} {incr i} {
			lassign [$t item bbox r$i] x0 y0 x1 y1
			set tw [expr {$tw + $x1 - $x0}]
			set th [expr {$th + $y1 - $y0}]
			set iw [expr {max($iw, $x1 - $x0)}]
			set ih [expr {max($ih, $y1 - $y0)}]
		}

		set n [expr {($tw + $pw - $pad - 1)/($pw - $pad)}]
		set k [expr {($count + $n - 1)/$n}]
		set tw [expr {$k*$iw}]

		if {$count % $n > 0} {
			incr tw $iw
			if {$tw > $pw - $pad} { incr n }
		}

		if {$n == 1} {
			set n 2
			set k [expr {($count + 1)/2}]
		}

		$t configure -wrap [list $k items]
	} else {
		set iw 0
		set ih 0
		set pad [expr {10 + $Pad(t) + $Pad(b)}]

		for {set i 0} {$i < $count} {incr i} {
			lassign [$t item bbox r$i] x0 y0 x1 y1
			set tw [expr {$tw + $x1 - $x0}]
			set th [expr {$th + $y1 - $y0}]
			set iw [expr {max($iw, $x1 - $x0)}]
			set ih [expr {max($ih, $y1 - $y0)}]
		}

		set n [expr {($th + $ph - $pad - 1)/($ph - $pad)}]
		set k [expr {($count + $n - 1)/$n}]
		set th [expr {$k*$ih}]

		if {$count % $n > 0} {
			incr th $ih
			if {$th > $ph - $pad} { incr n }
		}

		if {$n == 1} {
			$t configure -wrap {}
		} else {
			$t configure -wrap [list $k items]
		}
	}

	set f $Vars(frame)
	$f configure -width [expr {$tw + $Pad(l) + $Pad(r)}] -height [expr {$th + $Pad(t) + $Pad(b)}]
	$t configure -width $tw -height $th
	update idletasks

	if {[$t item count] == 2} {
		lassign [$t item bbox r0] _ _ tw th
	} else {
		set tw 0
		set th 0

		for {set i 0} {$i < $count} {incr i} {
			lassign [$t item bbox r$i] _ _ x1 y1
			set tw [expr {max($tw, $x1)}]
			set th [expr {max($th, $y1)}]
		}
	}

	$f configure -width [expr {$tw + $Pad(l) + $Pad(r)}] -height [expr {$th + $Pad(t) + $Pad(b)}]
	$t configure -width $tw -height $th

	set font [list [list $::font::text(editor:normal)]]
	set specialfont [list [list $::font::figurine(editor:normal) 9812 9823]]

	for {set i 0} {$i < $count} {incr i} {
		ConfigureElement $t $i elemMov -font $font -specialfont $specialfont
	}

	return 1
}


proc PlacePane {} {
	variable Options
	variable Vars

	if {[vertical?]} {
		set ph [winfo height $Vars(parent)]
		set lh [winfo height $Vars(frame)]
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
		set lw [winfo width $Vars(frame)]
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
