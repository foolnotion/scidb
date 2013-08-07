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
# Copyright: (C) 2011-2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source game-history

package require Tk 8.5
package require tktreectrl 2.2
package require scrolledframe

namespace eval game {

proc history {path args} {
	return [history::Build $path {*}$args]
}

namespace eval history {
namespace eval mc {

set GameHistory	"Game History"
set Games			"Games"

}

proc Build {w args} {
	set myList {}

	set parent [::scrolledframe $w -fill both -background white -borderwidth 0 -wheelunits 1 {*}$args]
	set f $parent.f
	set t $f.t
	set h $f.h

	set font TkTextFont
	set family [font configure $font -family]
	set size [font configure $font -size]
	set boldFont [list [list $family $size bold]]

	::tk::frame $f -background white -borderwidth 0 {*}$args -takefocus 0
	bind $f <Configure> [list $parent fit] ;# help the scrolled window
	grid $f
	grid anchor $parent center

	set lbl [namespace current]::mc::GameHistory
	::tk::label $h            \
		-textvariable $lbl     \
		-background white      \
		-font $boldFont        \
		-padx 6                \
		-pady 4                \
		;

	treectrl $t              \
		-class GHist          \
		-borderwidth 0        \
		-highlightthickness 0 \
		-takefocus 0          \
		-showroot no          \
		-showheader no        \
		-showbuttons no       \
		-showlines no         \
		-selectmode single    \
		-font $font           \
		-background white     \
		;
	::scrolledframe::bindMousewheel $parent $t
	$t state define hilite
	$t column create -tags game
	$t element create elemHdr text -font $boldFont -lines 1 -fill darkred
	$t element create elemTxt text -lines 1
	$t element create elemSel rect -fill [list                          \
		[::colors::lookup gamehistory selected:focus]  {selected focus}  \
		[::colors::lookup gamehistory selected:hilite] {selected hilite} \
		[::colors::lookup gamehistory selected!focus]  {selected !focus} \
		[::colors::lookup gamehistory hilite]          {hilite}          \
	]
	$t element create elemBrd border          \
		-filled no                             \
		-relief raised                         \
		-thickness 1                           \
		-background {#e5e5e5 {selected} {} {}} \
		;
	$t element create elemDiv rect -fill black -height 1

	$t notify install <Item-enter>
	$t notify install <Item-leave>
	$t notify bind $t <Item-enter> [namespace code [list VisitItem $t enter %I]]
	$t notify bind $t <Item-leave> [namespace code [list VisitItem $t leave %I]]
	$t notify bind $t <Selection>  [namespace code [list SelectionChanged $w]]

	bind $t <ButtonPress-2> [namespace code { ShowTooltip %W %x %y }]
	bind $t <ButtonRelease-2> [namespace code { HideTooltip %W }]
	bind $t <Double-Button-1>	[namespace code [list OpenGame $t %x %y]]
	bind $t <Key-space> [namespace code [list OpenGame $t]]

	pack $h -side top -anchor w
	pack $t -side top

	set linespace [font metrics [$t cget -font] -linespace]
	set pady [expr {(max(20,$linespace) - $linespace)/2}]

	# game --------------------------------
	set s [$t style create styGame]
	$t style elements $s {elemSel elemBrd elemTxt}
	$t style layout $s elemTxt -padx {6 6} -pady $pady -expand ns -squeeze x
	$t style layout $s elemSel -union {elemTxt} -iexpand nsew
	$t style layout $s elemBrd -iexpand xy -detach yes
	# header ------------------------------
	set s [$t style create styHeader -orient vertical]
	$t style elements $s {elemHdr elemDiv}
	$t style layout $s elemHdr -padx {6 6} -pady {10 0} -expand ns
	$t style layout $s elemDiv -pady {3 2} -padx {0 0} -iexpand x -expand ns
	# divider -----------------------------
	$t style create styLine
	$t style elements styLine {elemDiv}
	$t style layout styLine elemDiv -pady {3 2} -padx {4 4} -iexpand x -expand ns

	rename ::$w $w.__hist__
	proc ::$w {command args} "[namespace current]::WidgetProc $w \$command {*}\$args"

	return $w
}


proc WidgetProc {w command args} {
	set s $w.__scrolledframe__.scrolled

	switch -- $command {
		rebuild	{ return [Rebuild $s.f.t] }
		empty?	{ return [expr {[$s.f.t item count] <= 1}] }

		selection {
			variable Map
			set selection [$s.f.t selection get]
			if {[llength $selection] == 0} { return -1 }
			set selection [expr {[lindex $selection 0]}]
			if {![info exists Map($selection)]} { return -1 }
			if {[llength $Map($selection)] == 1} { return -1 }
			return [lindex $Map($selection) 0]
		}

		bind {
			if {1 > [llength $args] || [llength $args] > 3} {
				error "wrong # args: should be \"[namespace current] bind <tag> ?<sequence>? ?<script?>\""
			}
			bind $s.f.t {*}$args
			bind $s.f.h {*}$args
			bind $s {*}$args
			return
		}
	}

	return [$w.__hist__ $command {*}$args]
}


proc Rebuild {t} {
	variable Map

	array set Map {}

	set headerScript {
		upvar t u

		set item [$u item create]
		$u item style set $item first styHeader
		$u item enabled $item no
		$u item text $item game [::util::databaseName $base]
		$u item lastchild root $item

		uplevel [list set Map($item) [list [file dirname $base]]]
	}

	set gameScript {
		upvar t u

		set lbl ""
		append lbl [lindex $tags 4]
		append lbl " - "
		append lbl [lindex $tags 5]

		set item [$u item create -open no]
		$u item style set $item game styGame
		$u item text $item game $lbl
		$u item lastchild root $item

		uplevel [list set Map($item) [list $index $tags]]
	}

	$t item delete 0 end
	::game::traverseHistory $headerScript $gameScript
	$t column squeeze game
	$t column fit game

	set width [$t column cget game -width]
	if {[llength $width] == 0} { set width [$t column width game] }
	incr width [expr {2*[$t cget -borderwidth]}]
	$t configure -width $width

	set height 0
	foreach i [$t item children root] {
		lassign [$t item bbox $i] x0 y0 x1 y1
		incr height [expr {$y1 - $y0}]
	}
	$t configure -height $height
}


proc OpenGame {t args} {
	variable Map

	if {[llength $args] == 2} {
		lassign $args x y
		set id [$t identify $x $y]
		if {[lindex $id 0] eq "header"} { return }
		if {[lindex $id 1] eq ""} { return }
		set sel [expr {[lindex $id 1]}]
	} else {
		set sel [expr {[$t item id active]}]
	}

	if {[info exists Map($sel)] && [llength $Map($sel)] > 1} {
		::game::openGame $t [lindex $Map($sel) 0]
	}
}


proc VisitItem {t mode item} {
	# Note: this function may be invoked with non-existing items
	if {[string length $item]} {
		switch $mode {
			enter { catch { $t item state set $item {hilite}  } }
			leave { catch { $t item state set $item {!hilite} } }
		}
	}
}


proc ShowTooltip {t x y} {
	variable Map

	set id [$t identify $x $y]
	if {[lindex $id 0] eq "header"} { return }
	if {[lindex $id 1] eq ""} { return }
	set sel [expr {[lindex $id 1]}]
	if {![info exists Map($sel)]} { return }

	set dlg $t.__popup__
	if {[winfo exists $dlg]} {
		set f [lindex [winfo children $dlg] 0]
	} else {
		set f [::util::makePopup $dlg]
		set background [$f cget -background]
		grid [::tk::label $f.evline -background $background] -row 1 -column 1 -sticky w
		grid [::tk::label $f.coline -background $background] -row 2 -column 1 -sticky w
		grid [::tk::label $f.siline -background $background] -row 3 -column 1 -sticky w
		grid rowconfigure $f {0 4} -minsize 2
		grid columnconfigure $f {0 2} -minsize 2

		set family [font configure [$f.coline cget -font] -family]
		set size [font configure [$f.coline cget -font] -size]
		set boldFont [list $family $size bold]
		$f.coline configure -font $boldFont
	}

	if {[llength $Map($sel)] == 1} {
		grid remove $f.coline $f.siline
		$f.evline configure -text [lindex $Map($sel) 0] -foreground black
		::tooltip::show $t [lindex $Map($sel) 0]
	} else {
		lassign [lindex $Map($sel) 1] event site date round white black result

		if {[string length $white] == 0} { set white "?" }
		if {[string length $black] == 0} { set black "?" }
		if {$event eq "-" || $event eq "?"} { set event "" }
		if {$site eq "-" || $site eq "?"} { set site "" }
		set date [::locale::formatNormalDate $date]

		append evline $event

		append siline $site
		if {[string length $siline] && [string length $date]} { append siline ", " }
		append siline $date

		append coline $white
		append coline " \u2013 "
		append coline $black

		foreach what {evline coline siline} {
			if {[string length [set $what]]} { grid $f.$what } else { grid remove $f.$what }
			$f.$what configure -text [set $what]
		}
	}

	::tooltip::disable
	::tooltip::popup $t $dlg cursor
}


proc HideTooltip {t} {
	::tooltip::popdown $t.__popup__
	::tooltip::enable
}


proc SelectionChanged {w} {
	if {[$w selection] >= 0} {
		event generate $w <<GameHistorySelection>>
	}
}


proc SetActiveItem {w item} {
	if {[string length $item] > 0} {
		::TreeCtrl::SetActiveItem $w $item
		lassign [$w item bbox $item] x0 y0 x1 y1
		incr x0 [winfo x $w]
		incr x1 [winfo x $w]
		incr y0 [winfo y $w]
		incr y1 [winfo y $w]
		[winfo parent [winfo parent $w]] see $x0 $y0 $x1 $y1
	}
}

} ;# namespace history
} ;# namespace game


bind GHist <KeyPress-Up>	{ game::history::SetActiveItem %W [TreeCtrl::UpDown %W active -1] }
bind GHist <KeyPress-Down>	{ game::history::SetActiveItem %W [TreeCtrl::UpDown %W active +1] }
bind GHist <KeyPress-Home>	{ game::history::SetActiveItem %W [%W item id {first visible state enabled}]}
bind GHist <KeyPress-End>	{ game::history::SetActiveItem %W [%W item id {last visible state enabled}] }

bind GHist <KeyPress-space>		{ game::history::SetActiveItem %W [%W item id active] }
bind GHist <Shift-KeyPress-Down>	{ TreeCtrl::Extend %W below }
bind GHist <Shift-KeyPress-Up>	{ TreeCtrl::Extend %W above }
bind GHist <ButtonPress-1>			{ game::history::SetActiveItem %W [TreeCtrl::ButtonPress1 %W %x %y] }
bind GHist <ButtonRelease-1>		{ TreeCtrl::Release1 %W %x %y }
bind GHist <Button1-Motion>		{ TreeCtrl::Motion1 %W %x %y }
bind GHist <Button1-Leave>			{ TreeCtrl::Leave1 %W %x %y }
bind GHist <Button1-Enter>			{ TreeCtrl::Enter1 %W %x %y }

bind GHist <Motion> {
    TreeCtrl::CursorCheck %W %x %y
    TreeCtrl::MotionInHeader %W %x %y
    TreeCtrl::MotionInItems %W %x %y
}

bind GHist <Leave> {
    TreeCtrl::CursorCancel %W
    TreeCtrl::MotionInHeader %W
    TreeCtrl::MotionInItems %W
}

event add <<GameHistorySelection>> GameHistorySelection

# vi:set ts=3 sw=3:
