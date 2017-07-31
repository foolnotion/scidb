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
# Copyright: (C) 2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source game-merge

namespace eval merge {
namespace eval mc {

set MergeLastClipbaseGame		"Merge last Clipbase game"
set MergeGameFrom					"Merge game"

set MergeTitle						"Merge with games"
set StartFromCurrentPosition	"Start merge from current position"
set StartFromInitialPosition	"Start merge from initial position"
set NoTranspositions				"No transpositions"
set IncludeTranspositions		"Include transpositions"
set VariationDepth				"Variation depth"
set VariationLength				"Maximal variation length"
set UpdatePreview					"Update preview"
set SelectedGame					"Selected Game"
set SaveAs							"Save as new game"
set Save								"Merge into game"
set GameisLocked					"Game is locked by Merge-Dialog"

set AlreadyInUse					"Merge dialog is already in use with game #%d."
set AlreadyInUseDetail			"Please finish merge of this game before merging into another game. This means you have to switch to game #%d for continuing."
set CannotMerge					"Cannot merge games with different variants."

} ;# namespace mc


proc openDialog {parent primary secondary} {
	variable ::pgn::merge::Options
	variable ::scidb::mergebaseName
	variable ::scidb::clipbaseName
	variable Priv

	set dlg .mergeDialog
	set updateCmd [namespace code ConfigureUpdateButton]

	if {![winfo exists $dlg]} {
		array set Priv {
			action			cancel
			startpos			initial
			transposition	ignore
			depth				""
			length			""
			numericDepth	-1
			numericLength	-1
			variant			Normal
			update			""
			secondaries		{}
			games				{}
			temporary		{}
			clipbaseNo		-1
			state				{}
			view				-1
			used:0			0
			current			0
			script			{}
		}

		foreach opt {indent:amount indent:max tabstop:1 tabstop:2 tabstop:3 tabstop:4} {
			set Options($opt) $::pgn::editor::Options($opt)
		}

		set Priv(primary) $primary
		set Priv(position) [::gamebar::getIndex [::application::pgn::gamebar] $primary]

		tk::toplevel $dlg -class Dialog
		wm withdraw $dlg

		set pw [tk::panedwindow $dlg.main -orient horizontal -borderwidth 0 -opaqueresize true -sashwidth 6]
#		$pw configure -background [::theme::getColor background]
		::theme::configurePanedWindow $pw
		pack $pw -fill both -expand yes

		set control [ttk::frame $pw.control -borderwidth 0 -takefocus 0]
		set preview [ttk::frame $pw.preview -borderwidth 0 -takefocus 0]
		$pw add $control -sticky nsew -stretch never
		$pw add $preview -sticky nsew -stretch always

		::game::freeze $primary [namespace current]::mc::GameisLocked
		::scidb::db::new $mergebaseName Undetermined [::application::database::lookupType Clipbase]
		lassign [::scidb::game::sink? $primary] base variant number
		lappend Priv(secondaries) [list $base $variant $number]
		set Priv(variant) [::util::toMainVariant $variant]
		set Priv(pos:merge) 20
		set Priv(pos:game) 21
		lappend Priv(temporary) $Priv(pos:merge) $Priv(pos:game)
		lappend Priv(games) $Priv(pos:game)
		::scidb::game::copy game $mergebaseName $primary original
		::scidb::game::new $Priv(pos:merge)
		::scidb::game::new $Priv(pos:game)
		set number [expr {[::scidb::db::count games $mergebaseName $Priv(variant)] - 1}]
		::scidb::game::load $Priv(pos:merge) $mergebaseName $Priv(variant) $number
		::scidb::game::load $Priv(pos:game) $mergebaseName $Priv(variant) $number
		::scidb::game::langSet $Priv(pos:merge) *
		::scidb::game::langSet $Priv(pos:game) *

		### left frame with controls ###############################

		variable columns { number white black length eco }
		set tb $control.table
		set table [::gametable::build $tb       \
			[namespace code View]                \
			$columns                             \
			-id game:merge                       \
			-mode merge                          \
			-sortable 0                          \
			-useScale 0                          \
			-selectcmd [namespace code ShowGame] \
		]
		::bind $table <<TableCheckbutton>> [namespace code { TableCheckbutton %d }]
		::bind $table <<TableConfigured>> [namespace code { TableConfigured %W }]
		::scidb::db::subscribe gameList [namespace current]::Update {} $tb

		set btns [ttk::frame $control.buttons -borderwidth 2 -relief ridge]

		grid $control.table -row 1 -column 1 -sticky nsew
		grid $control.buttons -row 3 -column 1 -sticky ew
		grid rowconfigure $control 1 -weight 1
		grid rowconfigure $control {0 2 4} -minsize $::theme::pady
		grid columnconfigure $control {0} -minsize $::theme::padx
		grid columnconfigure $control {1} -weight 1

		set Priv(table) $tb

		ttk::radiobutton $btns.ignoreTrans \
			-textvar [namespace current]::mc::NoTranspositions \
			-variable [namespace current]::Priv(transposition) \
			-value ignore \
			-command $updateCmd \
			;
		ttk::radiobutton $btns.considerTrans \
			-textvar [namespace current]::mc::IncludeTranspositions \
			-variable [namespace current]::Priv(transposition) \
			-value consider \
			-command $updateCmd \
			;

		ttk::separator $btns.sep1
		ttk::radiobutton $btns.posInitial \
			-textvar [namespace current]::mc::StartFromInitialPosition \
			-variable [namespace current]::Priv(startpos) \
			-value initial \
			-command $updateCmd \
			;
		ttk::radiobutton $btns.posCurrent \
			-textvar [namespace current]::mc::StartFromCurrentPosition \
			-variable [namespace current]::Priv(startpos) \
			-value current \
			-command $updateCmd \
			;

		ttk::separator $btns.sep2
		ttk::label $btns.ldepth -textvar [::mc::var [namespace current]::mc::VariationDepth :]
		ttk::spinbox $btns.depth \
			-textvar [namespace current]::Priv(depth) \
			-from 0 \
			-to 9999999999 \
			-width 12 \
			-exportselection false \
			;
		bind $btns.depth <<ValueChanged>> [namespace code { ValueChanged %d numericDepth }]
		::validate::spinboxInt $btns.depth -clamp no -unlimited 1
		::theme::configureSpinbox $btns.depth

		ttk::separator $btns.sep3
		ttk::label $btns.llength  -textvar [::mc::var [namespace current]::mc::VariationLength :]
		ttk::spinbox $btns.length \
			-textvar [namespace current]::Priv(length) \
			-from 0 \
			-to 9999999999 \
			-width 12 \
			-exportselection false \
			;
		bind $btns.length <<ValueChanged>> [namespace code { ValueChanged %d numericLength }]
		::validate::spinboxInt $btns.length -clamp no -unlimited 1
		::theme::configureSpinbox $btns.length

		grid $btns.ignoreTrans   -row  1 -column 1 -columnspan 3 -sticky ew
		grid $btns.considerTrans -row  3 -column 1 -columnspan 3 -sticky ew
		grid $btns.sep1          -row  5 -column 0 -columnspan 5 -sticky ew
		grid $btns.posInitial    -row  7 -column 1 -columnspan 3 -sticky ew
		grid $btns.posCurrent    -row  9 -column 1 -columnspan 3 -sticky ew
		grid $btns.sep2          -row 11 -column 0 -columnspan 5 -sticky ew
		grid $btns.ldepth        -row 13 -column 1 -sticky ew
		grid $btns.depth         -row 13 -column 3 -sticky w
		grid $btns.sep3          -row 15 -column 0 -columnspan 5 -sticky ew
		grid $btns.llength       -row 17 -column 1 -sticky ew
		grid $btns.length        -row 17 -column 3 -sticky w
		grid columnconfigure $btns {0 2 4} -minsize $::theme::padx
		grid columnconfigure $btns {3} -weight 1
		grid rowconfigure $btns {0 2 4 6 8 10 12 14 16 18} -minsize $::theme::pady

		### right frame with previews ##############################

		foreach {pane position} {merge 20 game 21} {
			set Priv(path:$pane) $preview.$pane
			set Priv(pgn:$pane) [::pgn::setup::buildText $preview.$pane merge]

			$Priv(pgn:$pane) configure \
				-font $::font::text(merge:normal) \
				-inactiveselectbackground white \
				-selectforeground black \
				-width 40 \
				-height 30 \
				;
			bind $Priv(pgn:$pane) <ButtonPress-3> [namespace code [list PopupMenu $dlg]]
		}

		::pgn::setup::setupStyle merge $Priv(pos:merge)
		::pgn::editor::resetGame $Priv(pgn:merge) $Priv(pos:merge)
		set update [ttk::button $preview.update \
			-textvar [namespace current]::mc::UpdatePreview \
			-command [namespace code UpdatePreview] \
		]
		set Priv(update) $update
		set current [ttk::label $preview.current \
			-textvar [namespace current]::mc::SelectedGame \
			-borderwidth 0 \
			-anchor center \
		]

		grid $preview.merge   -row 1 -column 1 -sticky ewns
		grid $preview.game    -row 1 -column 3 -sticky ewns
		grid $preview.update  -row 3 -column 1 -sticky ewns
		grid $preview.current -row 3 -column 3 -sticky ewns
		grid columnconfigure $preview {0 2 4} -minsize $::theme::padx
		grid columnconfigure $preview {1 3} -weight 1
		grid rowconfigure $preview {0 2 4} -minsize $::theme::pady
		grid rowconfigure $preview {1} -weight 1

		### popup dialog ###########################################

		update idletasks
		$pw paneconfigure $control -minsize [winfo reqwidth $control]
		$pw paneconfigure $preview -minsize 600

		::widget::dialogButtons $dlg {cancel} -default save
		::widget::dialogButtonAdd $dlg saveAs [namespace current]::mc::SaveAs \
			$::icon::16x16::saveAs -position start
		::widget::dialogButtonAdd $dlg save [namespace current]::mc::Save \
			$::icon::16x16::save -position start
		$dlg.cancel configure -command [list destroy $dlg]
		$dlg.saveAs configure -command [namespace code [list Save $dlg new]]
		$dlg.save configure -command [namespace code [list Save $dlg replace]]
		bind $dlg.cancel <Destroy> [namespace code [list Destroy $dlg]]
		::font::addChangeFontSizeBindings merge $dlg

		wm protocol $dlg WM_DELETE_WINDOW [$dlg.cancel cget -command]
		wm withdraw $dlg
		wm title $dlg "$mc::MergeTitle ($::mc::Game [expr {$Priv(position) + 1}])"
		wm resizable $dlg true true
		::util::place $dlg -parent $parent -position center
		::widget::dialogRaise $dlg
		::gametable::activate $Priv(table) 0
		::gametable::focus $Priv(table)
		set Priv(selection) 0

		lappend Priv(script) [list gametable::select $Priv(table) 0]
		lappend Priv(script) [namespace code [list ShowGame "" "" $number ""]]
		lappend Priv(script) [namespace code UpdatePreview]
	} elseif {$Priv(primary) != $primary} {
		::dialog::error \
			-parent $parent \
			-message [format $mc::AlreadyInUse [expr {$Priv(primary) + 1}]] \
			-detail [format $mc::AlreadyInUseDetail [expr {$Priv(primary) + 1}]] \
			;
		return
	}

	if {$secondary eq "clipbase"} {
		set base $clipbaseName
		set variant $Priv(variant)
		set number [expr {[::scidb::db::count games $clipbaseName $variant] - 1}]
	} elseif {[llength $secondary] == 4} {
		lassign $secondary base variant view index
		set number [::scidb::db::get gameNumber $base $variant $index $view]
	} else {
		lassign [::scidb::game::sink? $secondary] base variant number
	}

	set id [list $base $variant $number]
	if {$id in $Priv(secondaries)} { return }
	lappend Priv(secondaries) $id

	if {$variant ne $Priv(variant)} {
		::dialog::error \
			-parent $parent \
			-message $mc::CannotMerge \
			;
		return
	}

	set temporary [::game::nextGamePosition]
	::scidb::game::new $temporary
	::scidb::game::load $temporary $base $variant $number
	::scidb::game::langSet $temporary *
	::scidb::game::copy game $mergebaseName $temporary original
	set number [expr {[::scidb::db::count games $mergebaseName $variant] - 1}]
	::scidb::game::load $temporary $mergebaseName $variant $number
	::scidb::game::langSet $temporary *
	set Priv(used:$number) 1
	set cmd [list ::gametable::setState $Priv(table) $number check]
	if {[llength $Priv(games)] > 1} { {*}$cmd } else { lappend Priv(script) $cmd }
	lappend Priv(games) $temporary
	lappend Priv(temporary) $temporary
	ConfigureUpdateButton
}


proc alreadyMerged {primary secondary} {
	variable ::scidb::clipbaseName
	variable Priv

	lassign [::scidb::game::sink? $primary] base variant number
	set id1 [list $base $variant $number]

	if {$secondary eq "clipbase"} {
		set base $clipbaseName
		set number [expr {[::scidb::db::count games $clipbaseName $variant] - 1}]
	} elseif {[llength $secondary] == 4} {
		lassign $secondary base variant view index
		set number [::scidb::db::get gameNumber $base $variant $index $view]
	} else {
		lassign [::scidb::game::sink? $secondary] base variant number
	}

	set id2 [list $base $variant $number]
	if {$id1 eq $id2} { return 1 }
	if {[winfo exists .mergeDialog] && $id2 in $Priv(secondaries)} { return 1 }

	return 0
}


proc TableConfigured {t} {
	variable Priv

	bind $t <<TableConfigured>> {#}

	foreach cmd $Priv(script) {
		{*}$cmd
	}
}


proc TableCheckbutton {data} {
	variable Priv

	lassign $data index state
	set Priv(used:$index) $state
	ConfigureUpdateButton
}


proc ShowGame {base variant number fen} {
	variable Priv

	set position [lindex $Priv(games) $number]
	if {$position == $Priv(current)} { return }
	::pgn::setup::setupStyle merge $position
	::pgn::editor::resetGame $Priv(pgn:game) $position
	set updateCmd [namespace current]::UpdateDisplay(game)
	::scidb::game::langSet $position *
	::scidb::game::subscribe pgn $position $updateCmd no
	::scidb::game::refresh $position -immediate
	$Priv(pgn:game) yview moveto 0.0
	::scidb::game::unsubscribe pgn $Priv(pos:game) $updateCmd
	set Priv(current) $position
}


proc View {base variant} {
	return -1
}


proc Update {path id base variant {view -1} {index -1}} {
	variable ::scidb::mergebaseName
	variable Priv

	if {$base == $mergebaseName && $variant == $Priv(variant)} {
		set n [::scidb::view::count games $base $variant $view]
		set selection [gametable::selection $path]
		gametable::update $path $base $variant $n
		gametable::select $path $selection
	}
}


proc ValueChanged {value attr} {
	variable Priv

	set Priv($attr) $value
	ConfigureUpdateButton
}


proc ConfigureUpdateButton {} {
	variable Priv

	set mergeState [GetMergeState]
	if {$mergeState ne $Priv(state)} { set state normal } else { set state disabled }
	$Priv(update) configure -state $state

	if {[llength [lindex $mergeState 4]] > 0} { set state normal } else { set state disabled }
	.mergeDialog.save configure -state $state
	.mergeDialog.saveAs configure -state $state
}


proc GetMergeState {} {
	variable Priv

	set games {}

	for {set i 0} {$i < [llength $Priv(games)]} {incr i} {
		if {$Priv(used:$i)} { lappend games [lindex $Priv(games) $i] }
	}

	return [concat \
		$Priv(transposition) \
		$Priv(startpos) \
		$Priv(numericDepth) \
		$Priv(numericLength) \
		[lsort -unique $games] \
	]
}


proc Destroy {dlg} {
	variable ::scidb::mergebaseName
	variable Priv

	::scidb::db::unsubscribe gameList [namespace current]::Update {} $Priv(table)

	foreach position $Priv(temporary) {
		::pgn::editor::forgetGame $position
		::scidb::game::release $position
	}

	foreach pane {game merge} {
		::pgn::setup::closeText $Priv(pgn:$pane) merge
	}

	::scidb::db::close $mergebaseName
	::game::unfreeze $Priv(primary)
	unset Priv
}


proc Save {dlg mode} {
	variable Priv

	::widget::busyCursor on

	DoMerge

	if {$mode eq "new"} {
		set position [::game::new $dlg -variant $Priv(variant)]
	} else {
		set position $Priv(primary)
	}

	::scidb::game::swap $Priv(pos:merge) $position
	::game::setModified $position
	::widget::busyCursor off

	destroy $dlg
}


proc DoMerge {} {
	variable Priv

	set mergeState [GetMergeState]

	if {$Priv(state) ne $mergeState} {
		set depth $Priv(numericDepth)
		if {$depth == -1} { set depth unlimited }
		set length $Priv(numericLength)
		if {$length == -1} { set length unlimited }
		set games [lrange $mergeState 4 end]

		set startKey [::scidb::game::query current $Priv(primary)]
		::scidb::game::moveto [lindex $Priv(pos:merge)] $startKey
		::scidb::game::moveto [lindex $Priv(pos:game)] $startKey

		set position $Priv(pos:merge)
		while {[string length [::scidb::game::query $position undo]]} {
			::scidb::game::execute undo $position
		}
		::scidb::game::langSet $position *
		::scidb::game::merge $position $games $Priv(startpos) $Priv(transposition) $depth $length
		::scidb::game::langSet $position *

		set Priv(state) $mergeState
	}
}


proc UpdatePreview {} {
	variable Priv

	::widget::busyCursor on
	DoMerge

	::pgn::setup::setupStyle merge $Priv(pos:merge)
	set updateCmd [namespace current]::UpdateDisplay(merge)
	::scidb::game::subscribe pgn $Priv(pos:merge) $updateCmd no
	::scidb::game::layout $Priv(pos:merge)
	$Priv(pgn:merge) yview moveto 0.0
	::scidb::game::unsubscribe pgn $Priv(pos:merge) $updateCmd

	ConfigureUpdateButton
	::widget::busyCursor off
}


proc UpdateDisplay(game) {position data} {
	after idle [namespace code [list DoUpdateDisplay game $position $data]]
}


proc UpdateDisplay(merge) {position data} {
	after idle [namespace code [list DoUpdateDisplay merge $position $data]]
}


proc DoUpdateDisplay {pane position data} {
	variable Priv

	if {[::scidb::game::query $position open?]} {
		::pgn::editor::doLayout $position $data merge $Priv(pgn:$pane)
	}
}


proc ChangeFontSize {incr} {
	variable Priv

	::pgn::setup::setupStyle merge $Priv(pos:merge)
	::pgn::setup::setupStyle merge $Priv(pos:game)
}


proc Refresh {} {
	variable Priv

	::widget::busyCursor on

	foreach pane {merge game} {
		if {$Priv(pos:$pane)} {
			::pgn::setup::setupStyle merge $Priv(pos:$pane)
			set updateCmd [namespace current]::UpdateDisplay($pane)
			::scidb::game::subscribe pgn $Priv(pos:$pane) $updateCmd no
			::scidb::game::refresh $Priv(pos:$pane) -immediate
			::scidb::game::unsubscribe pgn $Priv(pos:$pane) $updateCmd
		}
	}

	::widget::busyCursor off
}


proc PopupMenu {parent} {
	variable ::notation::moveStyles

	set menu $parent.__menu__
	catch { destroy $menu }
	menu $menu -tearoff 0
	catch { wm attributes $menu -type popup_menu }

	::font::addChangeFontSizeToMenu merge $menu

	menu $menu.moveStyles -tearoff no
	$menu add cascade \
		-menu $menu.moveStyles \
		-label " $::application::pgn::mc::MoveNotation" \
		-image $::icon::16x16::none \
		-compound left \
		;
	foreach style $moveStyles {
		$menu.moveStyles add radiobutton \
			-compound left \
			-label $::notation::mc::MoveForm($style) \
			-variable ::pgn::merge::Options(style:move) \
			-value $style \
			-command [namespace code Refresh] \
			;
		::theme::configureRadioEntry $menu.moveStyles
	}

	tk_popup $menu {*}[winfo pointerxy $parent]
}

} ;# namespace merge

namespace eval pgn {
namespace eval merge {

array set Options {
	style:column		1
	style:move			san
	spacing:paragraph	1
	weight:mainline	bold
	show:moveinfo		1
	show:varnumbers	1
	show:diagram		0
	show:emoticon		0
	show:opening		0
	show:nagtext		0
	indent:amount		25
	indent:max			2
	diagram:size		30
	diagram:padx		25
	diagram:pady		5
	tabstop:1			6.0
	tabstop:2			0.7
	tabstop:3			12.0
	tabstop:4			4.0
}

} ;# namespace merge
} ;# namespace pgn

# vi:set ts=3 sw=3:
