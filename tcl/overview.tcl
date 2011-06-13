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
# Copyright: (C) 2009-2011 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

namespace eval overview {
namespace eval mc {

set Overview				"Overview"
set RotateBoard			"Rotate Board"
set AcceleratorRotate	"R"

} ;# namespace mc

namespace import ::tcl::mathfunc::min

set Background	#ebf4f5
set MinSize		30

array set Priv {
	count	0
	tab	0
	flip	0
}


proc open {parent base info view index {fen {}}} {
	variable Priv

	set number [::gametable::column $info number]
	set name [file rootname [file tail $base]]

	if {[info exists Priv($base:$number:$view)]} {
		wm withdraw $Priv($base:$number:$view)
		wm deiconify $Priv($base:$number:$view)
		return
	}

	set position [incr Priv(count)]
	set dlg $parent.overview$position
	set Priv($base:$number:$view) $dlg
	incr Priv($base:$number:$view:count)
	toplevel $dlg -class Scidb
	bind $dlg <Alt-Key> [list tk::AltKeyInDialog $dlg %A]
	::widget::dialogButtons $dlg {close previous next} close
	foreach type {close previous next} { $dlg.$type configure -width 15 }
	$dlg.close configure -command [list destroy $dlg]

	set sw [expr {[winfo screenwidth $dlg] - 30}]
	set sh [expr {[winfo screenheight $dlg] - 140}]

	set boardSize(1) [expr {($sh - 2*47)/16}]
	set boardSize(3) [expr {($sh - 3*47)/24}]
	set boardSize(2) [expr {$boardSize(1) - ($boardSize(1) - $boardSize(3))/2}]
	set boardSize(4) [expr {$boardSize(3) - ($boardSize(1) - $boardSize(3))/2}]

	set nb [::ttk::notebook $dlg.nb -takefocus 1]
	bind $nb <<NotebookTabChanged>> [namespace code [list TabChanged $nb]]
	bind $dlg <Key-[string tolower $mc::AcceleratorRotate]> [namespace code [list RotateBoard $nb]]
	bind $dlg <ButtonPress-3> [namespace code [list PopupMenu $nb]]

	namespace eval $nb {}
	variable ${nb}::Vars
	set Vars(index) $index
	set Vars(number) $number
	set Vars(base) $base
	set Vars(name) $name
	set Vars(view) $view
	set Vars(tabs) {}
	set Vars(after) {}
	set Vars(flip) $Priv(flip)

	set idn [::gametable::column $info idn]
	for {set i 1} {$i <= 4} {incr i} { BuildTab $nb $boardSize($i) $sw $sh [expr {$i % 2}] }
	$nb select $Priv(tab)
	pack $nb

	bind $dlg <Destroy> [namespace code [list Destroy $nb]]
	$dlg.previous configure -command [namespace code [list NextGame $nb $base $fen -1]]
	$dlg.next configure -command [namespace code [list NextGame $nb $base $fen +1]]

	wm withdraw $dlg
	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	wm resizable $dlg false false
	::util::place $dlg center $parent
	wm deiconify $dlg
	focus $nb

	NextGame $nb $base $fen
	::scidb::db::subscribe gameList [namespace current]::Update [namespace current]::Close $nb
	if {$view == [::scidb::tree::view $base]} {
		::scidb::db::subscribe tree [namespace current]::UpdateTreeBase {} $nb
	}

	return $nb
}


proc load {parent base info view index windowId} {
	if {[llength $windowId] == 0} { set windowId _ }

	if {![namespace exists [namespace current]::${windowId}]} {
		return [open $parent $base $info $view $index]
	}

	variable ${windowId}::Vars
	NextGame $windowId $base {} [expr {$index - $Vars(index)}]
	return $windowId
}


proc ConfigureButtons {nb} {
	variable ${nb}::Vars

	set dlg [winfo toplevel $nb]

	if {$Vars(index) == -1} {
		$dlg.previous configure -state disabled
		$dlg.next configure -state disabled
	} else {
		if {$Vars(index) == 0} { set state disabled } else { set state normal }
		$dlg.previous configure -state $state
		set count [scidb::view::count games $Vars(base) $Vars(view)]
		if {$Vars(index) + 1 == $count} { set state disabled } else { set state normal }
		$dlg.next configure -state $state
	}
}


proc Update {nb base {view -1} {index -1}} {
	variable ${nb}::Vars

	if {$Vars(index) != -1 && $Vars(base) eq $base && $Vars(view) == $view} {
		after cancel $Vars(after)
		set Vars(after) [after idle [namespace code [list Update2 $nb]]]
	}
}


proc Update2 {nb} {
	variable ${nb}::Vars

	set Vars(index) [::scidb::db::get gameIndex [expr {$Vars(number) - 1}] $Vars(view) $Vars(base)]
	ConfigureButtons $nb
}


proc Close {nb base} {
	variable ${nb}::Vars

	set Vars(index) -1
	ConfigureButtons $nb
	wm title [winfo toplevel $nb] "[tk appname] - $mc::Overview"
}


proc UpdateTreeBase {nb base} {
	variable ${nb}::Vars

	if {$base ne $Vars(base)} {
		Close $nb $base
	}
}


proc NextGame {nb base fen {step 0}} {
	variable ${nb}::Vars
	variable Priv

	if {$Vars(index) == -1} { return }
	incr Vars(index) $step
	ConfigureButtons $nb
	set info [::scidb::db::get gameInfo $Vars(index) $Vars(view) $Vars(base)]
	if {$step} {
		set key $Vars(base):$Vars(number):$Vars(view)
		if {[incr Priv($key:count) -1] == 0} {
			unset Priv($key)
			unset Priv($key:count)
		}
		set Vars(number) [::gametable::column $info number]
		set key $Vars(base):$Vars(number):$Vars(view)
		set Priv($key) [winfo toplevel $nb]
		incr Priv($key:count)
	}
	set idn [::gametable::column $info idn]
	wm title [winfo toplevel $nb] "[tk appname] - $mc::Overview ($Vars(name) #$Vars(number))"
	set showError 1

	foreach {boardSize nrows ncols} $Vars(tabs) {
		set num [expr {$ncols*$nrows}]
		set result [::scidb::game::dump $base $Vars(view) $Vars(index) $fen $num]
		if {![lindex $result 0]} {
			if {$showError} {
				after idle [list ::dialog::error -parent $nb -message $::browser::mc::GameDataCorrupted]
			}
		}
		set showError 0
		set result [lreplace $result 0 0]
		set length [expr {[llength $result]/2}]

		for {set i 0} {$i < $num} {incr i} {
			set row [expr {$i/$ncols}]
			set col [expr {$i % $ncols}]
			set text $nb.s$boardSize.text_${row}_${col}
			$text configure -state normal
			$text delete 1.0 end
			if {$i == 0 && $idn != 0 && $idn != 518} {
				$text insert end "$::gamebar::mc::StartPosition $idn\n"
			}
			set moves [::font::splitMoves [lindex $result [expr {2*$i}]]]
			foreach {move tag} $moves { $text insert end $move $tag }
			if {$i == $length - 1} {
				set res [::gametable::column $info result]
				set res [::util::formatResult $res]
				if {[lindex [split [$text index current] .] 1] > 1} {
					$text insert end " "
				}
				$text insert end "$res"
			}
			$text configure -state disabled
			if {$i < $length} {
				set position [lindex $result [expr {2*$i + 1}]]
			} else {
				set position empty
			}
			::board::stuff::update $nb.s$boardSize.board_${row}_${col} $position
		}
	}
}


proc BuildTab {nb boardSize sw sh specified} {
	variable Background
	variable MinSize
	variable Priv

	if {$boardSize < $MinSize && [llength [$nb tabs]] >= 2} { return }
	if {$Priv(count) == 1} { ::board::registerSize $boardSize }
	set nrows [expr {$sh/(8*$boardSize + 47)}]
	set ncols [expr {$sw/(8*$boardSize + 12)}]
	if {!$specified} {
		set size1 [expr {($sw - 12)/int(8.5*$ncols)}]
		set size2 [expr {($sh - 47)/int(8.5*$nrows)}]
		set boardSize [min $size1 $size2]
	}
	if {[winfo exists $nb.s$boardSize]} { return }
	set f [::ttk::frame $nb.s$boardSize]
	$nb add $f -sticky nsew -text "${nrows}x${ncols}"
	variable ${nb}::Vars
	lappend Vars(tabs) $boardSize $nrows $ncols

	for {set row 0} {$row < $nrows} {incr row} {
		for {set col 0} {$col < $ncols} {incr col} {
			set board [::board::stuff::new $f.board_${row}_${col} $boardSize 1 $Priv(flip)]
			set text [tk::text $f.text_${row}_${col} \
				-borderwidth 1 \
				-relief raised \
				-width 0 -height 2 \
				-state disabled \
				-wrap word \
				-cursor {} \
				-background $Background]
			grid $board -column [expr {2*($col + 1)}] -row [expr {4*($row + 1)}]
			grid $text  -column [expr {2*($col + 1)}] -row [expr {4*($row + 1) + 2}] -sticky ew
			$text tag configure figurine -font $::font::figurine
			bind $text <Enter> [namespace code [list ShowMoves $text]]
			bind $text <Leave> [namespace code [list HideMoves $text]]
		}
	}

	set rows {}
	for {set row 0} {$row < $nrows} {incr row} { lappend rows [expr {4*($row + 1) + 1}] }
	grid rowconfigure $f $rows -minsize 5

	set rows {}
	set cols {}
	for {set row 0} {$row < $nrows} {incr row} { lappend rows [expr {4*($row + 1) + 3}] }
	for {set col 0} {$col < $ncols} {incr col} { lappend cols [expr {2*($col + 1) + 1}] }

	grid columnconfigure $f $cols -minsize 10
	grid rowconfigure $f $rows -minsize 10

	grid columnconfigure $f [list 1 [lindex $cols end]] -weight 1 -minsize 5
	grid rowconfigure $f [list 3 [lindex $rows end]] -weight 1 -minsize 5
}


proc ShowMoves {text} {
	if {[$text count -displaylines 1.0 2.0] > 2} {
		::gametable::showMoves $text [$text get 1.0 end]
	}
}


proc HideMoves {text} {
	::gametable::hideMoves $text
}


proc PopupMenu {nb} {
	variable ${nb}::Vars

	set menu $nb.__menu__
	catch { destroy $menu }
	menu $menu -tearoff 0

	if {$Vars(index) == -1} { set state disabled } else { set state normal }

	$menu add command \
		-label $mc::RotateBoard \
		-accelerator [string toupper $mc::AcceleratorRotate] \
		-command [namespace code [list RotateBoard $nb]]
	$menu add command \
		-label $::browser::mc::LoadGame \
		-command [namespace code [list LoadGame $nb]] \
		-state $state \
		;
	$menu add command \
		-label $::browser::mc::MergeGame \
		-command [namespace code [list MergeGame $nb]] \
		-state $state \
		;

	tk_popup $menu {*}[winfo pointerxy $nb]
}


proc RotateBoard {nb} {
	variable ${nb}::Vars
	variable Priv

	::widget::busyCursor on

	if {$Priv(flip) == $Vars(flip)} {
		set Priv(flip) [expr {!$Priv(flip)}]
	}
	set Vars(flip) [expr {!$Vars(flip)}]

	foreach tab [$nb tabs] {
		foreach w [winfo children $tab] {
			if {[winfo class $w] eq "Board"} { ::board::stuff::rotate $w }
		}
	}

	::widget::busyCursor off
}


proc Destroy {nb} {
	if {[namespace exists [namespace current]::${nb}]} {
		variable ${nb}::Vars
		variable Priv

		catch { destroy $nb.__menu__ }
		set key $Vars(base):$Vars(number):$Vars(view)
		if {[incr Priv($key:count) -1] == 0} {
			unset Priv($key)
			unset Priv($key:count)
		}
		namespace delete [namespace current]::${nb}
		::scidb::db::unsubscribe gameList [namespace current]::Update [namespace current]::Close $nb
		::scidb::db::unsubscribe tree [namespace current]::UpdateTreeBase {} $nb
	}
}


proc TabChanged {nb} {
	variable Priv
	set Priv(tab) [$nb index [$nb select]]
}


proc LoadGame {nb} {
	variable ${nb}::Vars

	set index [::scidb::db::get gameIndex [expr {$Vars(number) - 1}] $Vars(view) $Vars(base)]
	set tags  [::scidb::db::get tags $index $Vars(view) $Vars(base)]

	::widget::busyOperation ::game::new $nb $Vars(base) $tags $index
}	


proc MergeGame {nb} {
	variable ${nb}::Vars

	set index [::scidb::db::get gameIndex [expr {$Vars(number) - 1}] $Vars(view) $Vars(base)]
puts "MergeGame $index"	;# TODO
}

} ;# namespace overview

# vi:set ts=3 sw=3:
