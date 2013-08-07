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
# Copyright: (C) 2009-2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source overview-dialog

namespace eval overview {
namespace eval mc {

set Overview				"Overview"
set RotateBoard			"Rotate Board"
set AcceleratorRotate	"R"

} ;# namespace mc

namespace import ::tcl::mathfunc::min

array set Options {
	background:normal		background:normal
	background:modified	background:modified
	minSize					30
}

array set Priv {
	count	0
	tab	0
	flip	0
}


proc open {parent base variant info view index {fen {}}} {
	variable Priv

	set number [::gametable::column $info number]
	set name [file rootname [file tail $base]]

	if {[info exists Priv($base:$variant:$number:$view)]} {
		set dlg [lindex $Priv($base:$variant:$number:$view) 0]
		if {[winfo exists $dlg]} { ;# prevent raise conditions
			::widget::dialogRaise $dlg
			return
		}
	}

	set position [incr Priv(count)]
	set dlg $parent.overview$position
	lappend Priv($base:$variant:$number:$view) $dlg
	tk::toplevel $dlg -class Scidb
	bind $dlg <Alt-Key> [list tk::AltKeyInDialog $dlg %A]
	::widget::dialogButtons $dlg {close previous next help} -default close
#	foreach type {close previous next help} { $dlg.$type configure -width 15 }
	$dlg.close configure -command [list destroy $dlg]
	$dlg.help configure -command [list ::help::open .application Game-Overview -parent $dlg]
	::tooltip::tooltip $dlg.previous ::browser::mc::LoadPrevGame
	::tooltip::tooltip $dlg.next ::browser::mc::LoadNextGame

	set sw [expr {[winfo workareawidth $dlg] - 20}]
	set sh [expr {[winfo workareaheight $dlg] - 110}]

	set boardSize(1) [expr {($sh - 2*47)/16}]
	set boardSize(3) [expr {($sh - 3*47)/24}]
	set boardSize(2) [expr {$boardSize(1) - ($boardSize(1) - $boardSize(3))/2}]
	set boardSize(4) [expr {$boardSize(3) - ($boardSize(1) - $boardSize(3))/2}]

	set nb [::ttk::notebook $dlg.nb -takefocus 1]

	bind $dlg <F1>					[list ::help::open .application Game-Overview -parent $dlg]
	bind $dlg <ButtonPress-3>	[namespace code [list PopupMenu $nb]]
	bind $dlg <Control-Home>	[namespace code [list GotoGame(first) $nb]]
	bind $dlg <Control-End>		[namespace code [list GotoGame(last) $nb]]
	bind $dlg <Control-Down>	[namespace code [list GotoGame(next) $nb]]
	bind $dlg <Control-Up>		[namespace code [list GotoGame(prev) $nb]]

	namespace eval $nb {}
	variable ${nb}::Vars
	set Vars(dlg) $dlg
	set Vars(index) $index
	set Vars(number) $number
	set Vars(base) $base
	set Vars(variant) $variant
	set Vars(name) $name
	set Vars(view) $view
	set Vars(after) {}
	set Vars(flip) $Priv(flip)
	set Vars(fen) $fen
	set Vars(closed) 0
	set Vars(info) $info
	set Vars(after) {}
	set Vars(moves) ""
	set Vars(modified) 0
	set Vars(text) {}

	set Priv(tabs) {}
	for {set i 1} {$i <= 4} {incr i} { BuildTab $nb $boardSize($i) $sw $sh [expr {$i % 2}] }
	$nb select $Priv(tab)
	pack $nb

	bind $nb <Destroy> [namespace code [list Destroy $nb]]
	$dlg.previous configure -command [namespace code [list NextGame $nb -1]]
	$dlg.next configure -command [namespace code [list NextGame $nb +1]]

	SetAccelerator $nb

	wm withdraw $dlg
	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	wm resizable $dlg false false
	::util::place $dlg -position center
	wm deiconify $dlg
	focus $nb

	NextGame $nb
	bind $nb <<NotebookTabChanged>> [namespace code [list TabChanged $nb]]
	bind $nb <<LanguageChanged>> [namespace code [list LanguageChanged $nb]]

	set Vars(subscribe:list)  [list [namespace current]::Update [namespace current]::Close $nb]
	set Vars(subscribe:close) [list [namespace current]::Close $base $variant $nb]
	set Vars(subscribe:data)  [list [namespace current]::UpdateData $nb]

	::scidb::db::subscribe gameList {*}$Vars(subscribe:list)
	::scidb::db::subscribe gameData {*}$Vars(subscribe:data)
	::scidb::view::subscribe {*}$Vars(subscribe:close)

	if {$variant == [::scidb::app::variant] && $view == [::scidb::tree::view $base]} {
		set Vars(subscribe:tree) [list [namespace current]::UpdateTreeBase {} $nb]
		::scidb::db::subscribe tree {*}$Vars(subscribe:tree)
	}

	return $nb
}


proc closeAll {base variant} {
	variable Priv

	foreach key [array names Priv $base:$variant:*] {
		foreach dlg $Priv($key) { destroy $dlg }
	}
}


proc load {parent base variant info view index windowId} {
	if {[llength $windowId] == 0} { set windowId _ }

	if {![namespace exists [namespace current]::${windowId}]} {
		return [open $parent $base $variant $info $view $index]
	}

	variable ${windowId}::Vars
	NextGame $windowId [expr {$index - $Vars(index)}]
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
		set count [scidb::view::count games $Vars(base) $Vars(variant) $Vars(view)]
		if {$Vars(index) + 1 == $count} { set state disabled } else { set state normal }
		$dlg.next configure -state $state
	}
}


proc Update {nb id base variant {view -1} {index -1}} {
	variable ${nb}::Vars

	if {	$Vars(base) eq $base
		&& $variant eq $Vars(variant)
		&& ($Vars(view) == $view || $Vars(view) == 0)} {
		if {$Vars(closed)} {
			set index $Vars(index:last)
			if {[::scidb::view::count games $base $variant $Vars(view)] <= $index} { return }
			set info [::scidb::db::get gameInfo $index $Vars(view) $base $variant]
			if {$info ne $Vars(info)} { return }
			set Vars(index) $index
			set Vars(closed) false
			SetTitle $nb
		}
		after cancel $Vars(after)
		set Vars(after) [after idle [namespace code [list Update2 $nb]]]
	}
}


proc Update2 {nb} {
	variable ${nb}::Vars

	set Vars(index) \
		[::scidb::db::get gameIndex [expr {$Vars(number) - 1}] $Vars(view) $Vars(base) $Vars(variant)]
	ConfigureButtons $nb
}


proc UpdateData {nb id evenMainline} {
	if {![info exists ${nb}::Vars]} { return }

	variable ${nb}::Vars
	variable Options

	if {$evenMainline} {
		lassign [::scidb::game::link? $id] base variant index
		set link [list $base [::util::toMainVariant $variant] $index]
		if {$Vars(link) eq $link} {
			set Vars(modified) 1
			set background [::colors::lookup overview $Options(background:modified)]
			foreach text $Vars(text) {
				$text configure -background $background -inactiveselectbackground $background
			}
		}
	}
}


proc Close {nb base variant {view {}}} {
	variable ${nb}::Vars

	if {!$Vars(closed) && $variant eq $Vars(variant) && ([llength $view] == 0 || $view == $Vars(view))} {
		set Vars(index:last) $Vars(index)
		set Vars(index) -1
		set Vars(closed) 1
		ConfigureButtons $nb
		SetTitle $nb
	}
}


proc UpdateTreeBase {nb base variant} {
	variable ${nb}::Vars

	if {$base ne $Vars(base) || $variant ne $Vars(variant)} {
		Close $nb $base $variant
	}
}


proc GotoGame(first) {nb} {
	variable ${nb}::Vars

	if {$Vars(index) > 0} {
		set Vars(index) 0
		NextGame $nb
	}
}


proc GotoGame(last) {nb} {
	variable ${nb}::Vars

	set index [expr {[scidb::view::count games $base $variant $Vars(view)] - 1}]

	if {$Vars(index) < $index} {
		set Vars(index) $index
		NextGame $nb
	}
}


proc GotoGame(next) {nb} {
	NextGame $nb +1
}


proc GotoGame(prev) {nb} {
	NextGame $nb -1
}


proc NextGame {nb {step 0}} {
	variable ${nb}::Vars
	variable Options
	variable Priv

	if {$Vars(index) == -1} { return }
	set number $Vars(number)
	set base $Vars(base)
	set variant $Vars(variant)
	set view $Vars(view)
	incr Vars(index) $step
	ConfigureButtons $nb

	set Vars(info) [::scidb::db::get gameInfo $Vars(index) $view $base $variant]
	set Vars(number) [::gametable::column $Vars(info) number]
	set dlg [winfo toplevel $nb]
	set key "$base:$variant:$number:$view"
	set i [lsearch -exact $Priv($key) $dlg]
	if {$i >= 0} { set Priv($key) [lreplace $Priv($key) $i $i] }
	if {[llength $Priv($key)] == 0} { array unset Priv $key }
	set key "$base:$variant:$Vars(number):$view"
	set Vars(link) [list $base $variant $Vars(index)]
	lappend Priv($key) $dlg

	SetTitle $nb
	array unset Vars result:*
	array set Vars { fill:0 1 fill:1 1 fill:2 1 fill:3 1 }
	set failed 0
	set index 0

	foreach {boardSize nrows ncols} $Priv(tabs) {
		if {$failed} { continue }
		set num [expr {$ncols*$nrows}]
		set result [::widget::busyOperation \
			{ ::scidb::game::dump $base $variant $view $Vars(index) $Vars(fen) $num }]
		set failed 1
		switch [lindex $result 0] {
			 1 { set failed 0 }
			-1 { after idle [list ::dialog::info  -parent $nb -message $::game::mc::GameDecodingFailed] }
			-2 { after idle [list ::dialog::error -parent $nb -message $::game::mc::GameDataCorrupted] }
		}
		set Vars(result:$index) [lreplace $result 0 0]
		incr index
	}

	if {$Vars(modified)} {
		set background [::colors::lookup overview $Options(background:normal)]
		foreach text $Vars(text) {
			$text configure -background $background -inactiveselectbackground $background
		}
		set Vars(modified) 0
	}

	ConfigureTab [$nb select]
	FillTab $nb [$nb select]
}


proc LanguageChanged {nb} {
	SetAccelerator $nb
	SetTitle $nb
}


proc SetAccelerator {nb} {
	variable ${nb}::Vars
	variable Accelerator

	if {[info exists Accelerator]} {
		bind $Vars(dlg) <Key-[string tolower $Accelerator]> {#}
		bind $Vars(dlg) <Key-[string toupper $Accelerator]> {#}
	}

	bind $Vars(dlg) <Key-[string tolower $mc::AcceleratorRotate]> [namespace code [list RotateBoard $nb]]
	bind $Vars(dlg) <Key-[string toupper $mc::AcceleratorRotate]> [namespace code [list RotateBoard $nb]]

	set Accelerator $mc::AcceleratorRotate
}


proc SetTitle {nb} {
	variable ${nb}::Vars

	set title "[tk appname] - $mc::Overview"
	if {$Vars(index) >= 0} { append title " ($Vars(name) #$Vars(number))" }
	wm title [winfo toplevel $nb] $title
}


proc BuildTab {nb boardSize sw sh specified} {
	variable ${nb}::Vars
	variable Options
	variable Priv

	if {$boardSize < $Options(minSize) && [llength [$nb tabs]] >= 2} { return }
	set nrows [expr {$sh/(8*$boardSize + 47)}]
	set ncols [expr {$sw/(8*$boardSize + 12)}]
	if {!$specified} {
		set size1 [expr {($sw - 12)/int(8.5*$ncols)}]
		set size2 [expr {($sh - 47)/int(8.5*$nrows)}]
		set boardSize [min $size1 $size2]
	}
	if {[winfo exists $nb.s$boardSize]} { return }
	set f [::ttk::frame $nb.s$boardSize]
	set Priv(pane:$f) [list $boardSize $nrows $ncols]
	$nb add $f -sticky nsew -text "${nrows}x${ncols}"
	lappend Priv(tabs) $boardSize $nrows $ncols
	set size [expr {8*$boardSize + 2}]
	set background [::colors::lookup overview $Options(background:normal)]

	for {set row 0} {$row < $nrows} {incr row} {
		for {set col 0} {$col < $ncols} {incr col} {
			set board [tk::frame $f.frame_${row}_${col} -width $size -height $size]
			set t $f.text_${row}_${col}
			set text [tk::text $t                    \
				-borderwidth 1                        \
				-relief raised                        \
				-width 0                              \
				-height 2                             \
				-state disabled                       \
				-wrap word                            \
				-cursor {}                            \
				-background $background               \
				-inactiveselectbackground $background \
				-selectforeground black               \
				-exportselection no                   \
			]
			lappend Vars(text) $text
			::widget::textPreventSelection $text
			::widget::bindMouseWheel $text 1
			grid $board -column [expr {2*($col + 1)}] -row [expr {4*($row + 1)}]
			grid $text  -column [expr {2*($col + 1)}] -row [expr {4*($row + 1) + 2}] -sticky ew
			$text tag configure figurine -font $::font::figurine(text:normal)
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


proc ConfigureTab {pane} {
	variable Priv

	if {[winfo exists $pane.frame_0_0.board]} { return }
	lassign $Priv(pane:$pane) boardSize nrows ncols
	::board::registerSize $boardSize

	for {set row 0} {$row < $nrows} {incr row} {
		for {set col 0} {$col < $ncols} {incr col} {
			pack [::board::diagram::new $pane.frame_${row}_${col}.board $boardSize \
				-bordersize 1 -flipped $Priv(flip)]
		}
	}

	update idletasks
}


proc FillTab {nb pane} {
	variable ${nb}::Vars
	variable Priv

	set index $Priv(tab)
	if {!$Vars(fill:$index)} { return }
	lassign $Priv(pane:$pane) boardSize nrows ncols
	set num [expr {$ncols*$nrows}]
	set result $Vars(result:$index)
	set length [expr {[llength $result]/2}]
	set idn [::gametable::column $Vars(info) idn]

	for {set i 0} {$i < $num} {incr i} {
		set row [expr {$i/$ncols}]
		set col [expr {$i % $ncols}]
		set text $pane.text_${row}_${col}
		$text configure -state normal
		$text delete 1.0 end
		if {$i == 0 && $idn != 0 && $idn != 518} {
			$text insert end "$::gamebar::mc::StartPosition $idn\n"
		}
		set moves [::font::splitMoves [lindex $result [expr {2*$i}]]]
		foreach {move tag} $moves { $text insert end $move $tag }
		if {$i == $length - 1} {
			set res [::gametable::column $Vars(info) result]
			set res [::util::formatResult $res]
			if {[lindex [split [$text index current] .] 1] > 1} {
				$text insert end " "
			}
			$text insert end "$res"
		}
		if {$i < $length} {
			set position [lindex $result [expr {2*$i + 1}]]
		} else {
			set position empty
		}
		$text configure -state disabled
		update idletasks
		::board::diagram::update $pane.frame_${row}_${col}.board $position
	}
}


proc PopupMenu {nb} {
	variable ${nb}::Vars

	set menu $nb.__menu__
	catch { destroy $menu }
	menu $menu -tearoff 0
	catch { wm attributes $menu -type popup_menu }

	set base $Vars(base)
	set variant $Vars(variant)
	set view $Vars(view)
	if {$Vars(index) == -1} { set state disabled } else { set state normal }

	$menu add command \
		-compound left \
		-image $::icon::16x16::rotateBoard \
		-label " $mc::RotateBoard" \
		-accelerator [string toupper $mc::AcceleratorRotate] \
		-command [namespace code [list RotateBoard $nb]] \
		;
	$menu add command \
		-compound left \
		-image $::icon::16x16::document \
		-label " $::browser::mc::LoadGame" \
		-command [namespace code [list LoadGame $nb]] \
		-state $state \
		;
#	if {[::scidb::game::current] == -1} { sert state disabled } else { set state normal }
#	$menu add command \
#		-label $::browser::mc::MergeGame \
#		-command [list gamebar::mergeGame $nb $position] \
#		-state $state \
#		;
	if {!$Vars(modified)} { set state disabled }
	$menu add command \
		-label " $::browser::mc::ReloadGame" \
		-image $::icon::16x16::refresh \
		-compound left \
		-command [namespace code [list NextGame $nb 0]] \
		-state $state \
		;
	if {$Vars(index) >= 0} {
		$menu add separator
		set count [scidb::view::count games $base $variant $view]
		if {$count <= 1 || $Vars(index) == 0} { set state disabled } else { set state normal }
		$menu add command \
			-label " $::browser::mc::GotoGame(prev)" \
			-image $::icon::16x16::backward \
			-compound left \
			-command [namespace code [list GotoGame(prev) $nb]] \
			-accel "$::mc::Key(Ctrl)-$::mc::Key(Up)" \
			-state $state \
			;
		if {$count <= 1 || $Vars(index) + 1 == $count} { set state disabled } else { set state normal }
		$menu add command \
			-label " $::browser::mc::GotoGame(next)" \
			-image $::icon::16x16::forward \
			-compound left \
			-command [namespace code [list GotoGame(next) $nb]] \
			-accel "$::mc::Key(Ctrl)-$::mc::Key(Down)" \
			-state $state \
			;
		if {$count <= 1 || $Vars(index) == 0} { set state disabled } else { set state normal }
		$menu add command \
			-compound left \
			-image $::icon::16x16::first \
			-label " $::browser::mc::GotoGame(first)" \
			-command [namespace code [list GotoGame(first) $nb]] \
			-accel "$::mc::Key(Ctrl)-$::mc::Key(Home)" \
			-state $state \
			;
		if {$count <= 1 || $Vars(index) + 1 == $count} { set state disabled } else { set state normal }
		$menu add command \
			-compound left \
			-image $::icon::16x16::last \
			-label " $::browser::mc::GotoGame(last)" \
			-command [namespace code [list GotoGame(last) $nb]] \
			-accel "$::mc::Key(Ctrl)-$::mc::Key(End)" \
			-state $state \
			;
	}

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
		foreach v [winfo children $tab] {
			foreach w [winfo children $v] {
				if {[winfo class $w] eq "Board"} { ::board::diagram::rotate $w }
			}
		}
	}

	::widget::busyCursor off
}


proc Destroy {nb} {
	if {[namespace exists [namespace current]::${nb}]} {
		variable ${nb}::Vars
		variable Priv

		catch { destroy $nb.__menu__ }

		set key "$Vars(base):$Vars(variant):$Vars(number):$Vars(view)"
		set i [lsearch -exact $Priv($key) [winfo toplevel $nb]]
		if {$i >= 0} { set Priv($key) [lreplace $Priv($key) $i $i] }
		if {[llength $Priv($key)] == 0} { array unset Priv $key }

		::scidb::db::unsubscribe gameList {*}$Vars(subscribe:list)
		::scidb::db::unsubscribe gameData {*}$Vars(subscribe:data)
		::scidb::view::unsubscribe {*}$Vars(subscribe:close)
		if {[info exists Vars(subscribe:tree)]} {
			::scidb::db::unsubscribe tree {*}$Vars(subscribe:tree)
		}

		namespace delete [namespace current]::${nb}
	}
}


proc TabChanged {nb} {
	variable Priv

	set pane [$nb select]
	set Priv(tab) [$nb index $pane]
	ConfigureTab $pane
	FillTab $nb $pane
}


proc LoadGame {nb} {
	variable ${nb}::Vars

	::widget::busyOperation {
		::game::new $nb \
			-base $Vars(base) \
			-variant $Vars(variant) \
			-view $Vars(view) \
			-number [expr {$Vars(number) - 1}] \
			-fen $Vars(fen) \
			;
	}
}	

} ;# namespace overview

# vi:set ts=3 sw=3:
