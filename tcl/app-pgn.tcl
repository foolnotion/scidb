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
# Copyright: (C) 2009-2012 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source game-editor-pane

namespace eval application {
namespace eval pgn {
namespace eval mc {

set Command(move:annotation)		"Set Annotation/Comment/Marks"
set Command(move:append)			"Add Move"
set Command(move:nappend)			"Add Moves"
set Command(move:exchange)			"Exchange Move"
set Command(variation:new)			"Add Variation"
set Command(variation:replace)	"Replace Moves"
set Command(variation:truncate)	"Truncate Variation"
set Command(variation:first)		"Make First Variation"
set Command(variation:promote)	"Promote Variation"
set Command(variation:remove)		"Delete Variation"
set Command(variation:mainline)	"New Mainline"
set Command(variation:insert)		"Insert Moves"
set Command(variation:exchange)	"Exchange Moves"
set Command(strip:moves)			"Moves from the beginning"
set Command(strip:truncate)		"Moves to the end"
set Command(strip:annotations)	"Annotations"
set Command(strip:moveinfo)		"Move Information"
set Command(strip:marks)			"Marks"
set Command(strip:comments)		"Comments"
set Command(strip:variations)		"Variations"
set Command(copy:comments)			"Copy Comments"
set Command(move:comments)			"Move Comments"
set Command(game:clear)				"Clear Game"
set Command(game:transpose)		"Transpose Game"

set LanguageSelection				"Language Selection"
set MoveNotation						"Move Notation"
set CollapseVariations				"Collapse Variations"
set ExpandVariations					"Expand Variations"
set EmptyGame							"Empty Game"

set NumberOfMoves						"Number of moves (in main line):"
set InvalidInput						"Invalid input '%d'."
set MustBeEven							"Input must be an even number."
set MustBeOdd							"Input must be an odd number."
set CannotOpenCursorFiles			"Cannot open cursor files: %s"
set ReallyReplaceMoves				"Really replace moves of current game?"
set CurrentGameIsNotModified		"Current game is not modified."
set ShufflePosition					"Shuffle position..." ;# currently unused

set StartTrialMode					"Start Trial Mode"
set StopTrialMode						"Stop Trial Mode"
set Strip								"Strip"
set InsertDiagram						"Insert Diagramm"
set InsertDiagramFromBlack			"Insert Diagramm from Black's Perspective"
set SuffixCommentaries				"Suffixed Commentaries"
set StripOriginalComments			"Strip original comments"

set EditAnnotation					"Edit annotation"
set EditMoveInformation				"Edit move information"
set EditCommentBefore				"Edit comment before move"
set EditCommentAfter					"Edit comment after move"
set EditCommentAtStart				"Edit comment at start"
set EditPrecedingComment			"Edit preceding comment"
set EditTrailingComment				"Edit trailing comment"
set Display								"Display"
set None									"none"

} ;# namespace mc

variable Vars
variable CharLimit 250
variable Counter 0


proc build {parent width height} {
	variable Vars

	set top   [::tk::frame $parent.top -borderwidth 0 -background white]
	set main  [::tk::multiwindow $top.main -borderwidth 0 -background white]
	set games [::tk::multiwindow $main.games -borderwidth 0 -background white]
	set logo  [::tk::frame $main.logo -borderwidth 0 -background white -cursor left_ptr]
	set hist  [::game::history $main.hist -cursor left_ptr]

	pack $top -fill both -expand yes
	pack $main -fill both -expand yes

	set popupcmd [namespace code [list ::gamebar::popupMenu $top no]]

	$main add $hist $logo $games
	bind $main <Button-3> $popupcmd
	$hist bind <Button-3> [namespace code [list PopupHistoryMenu $hist]]
	bind $hist <<GameHistorySelection>> [namespace code HistorySelectionChanged]

	# logo pane --------------------------------------------------------------------------------
	$main paneconfigure $logo -sticky ""
	bind $logo <Button-3> $popupcmd

	tk::label $logo.icon -image $::icon::64x64::logo -background white
	tk::label $logo.logo \
		-text "Scidb" \
		-foreground steelblue4 \
		-font [list {Final Frontier} 26] \
		-background white \
		;
	grid $logo.icon -row 1 -column 1
	grid $logo.logo -row 2 -column 1

	foreach child [winfo children $logo] {
		bind $child <Button-3> $popupcmd
	}

	# games pane -------------------------------------------------------------------------------
	bind $games <Button-3> [namespace code [list ::gamebar::popupMenu $top]]
	set edit [::tk::frame $games.edit -borderwidth 0]
	pack $edit -expand yes -fill both
	bind $edit <Configure> [namespace code { Configure %h }]
	set panes [::tk::multiwindow $edit.panes -borderwidth 0 -background white -overlay yes]
	set gamebar [::gamebar::gamebar $edit.gamebar]

	grid $gamebar -row 1 -column 1 -sticky nsew
	grid $panes   -row 2 -column 1 -sticky nsew

	::gamebar::addReceiver $gamebar [namespace code GameBarEvent]

	set Vars(frame) $edit
	set Vars(delta) 0
	set Vars(after) {}
	set Vars(index) -1
	set Vars(position) -1
	set Vars(break) 0
	set Vars(height) 0

	for {set i 0} {$i < 9} {incr i} {
		set pgn [::pgn::setup::buildText $edit.f$i editor]
		bind $pgn <Button-3> [namespace code [list PopupMenu $edit $i]]
		$panes add $edit.f$i
		set Vars(pgn:$i) $pgn
		set Vars(frame:$i) $edit.f$i
		set Vars(after:$i) {}
	}

	set Vars(main) $main
	set Vars(hist) $hist
	set Vars(gamebar) $gamebar
	set Vars(games) $games
	set Vars(logo) $logo
	set Vars(panes) $panes
	set Vars(charwidth) [font measure [$Vars(pgn:0) cget -font] "0"]

	::pgn::setup::setupStyle editor
#	::scidb::game::undoSetup 20 9999
	::scidb::game::undoSetup 200 1

	set tbGame [::toolbar::toolbar $top \
		-id editor-game \
		-hide 1 \
		-side bottom \
		-tooltipvar ::mc::Game \
	]
	set Vars(button:new) [::toolbar::add $tbGame button \
		-image $::icon::toolbarDocumentNew \
		-tooltip "$::gamebar::mc::GameNew ($::mc::VariantName(Normal))" \
		-command [list ::menu::gameNew $tbGame] \
	]
	set Vars(button:new...) [::toolbar::add $tbGame button \
		-image $::icon::toolbarDocumentNewAlt \
		-tooltipvar [::mc::var ::gamebar::mc::GameNew "..."] \
		-command [namespace code NewGame] \
	]
#	set Vars(button:shuffle) [::toolbar::add $tbGame button \
#		-image $::icon::toolbarDice \
#		-tooltipvar [namespace current]::mc::ShufflePosition \
#		-command [namespace code ShufflePosition] \
#		-state disabled \
#	]
	set Vars(button:import) [::toolbar::add $tbGame button \
		-image $::icon::toolbarPGN \
		-tooltipvar ::import::mc::ImportPgnGame \
		-command [namespace code [list ImportGame $Vars(main)]] \
	]
	set tbGameHistory [::toolbar::toolbar $top \
		-id editor-history \
		-hide 1 \
		-side bottom \
		-tooltipvar ::dialog::save::mc::History \
	]
	set Vars(button:remove) [::toolbar::add $tbGameHistory button \
		-image $::icon::toolbarRemove \
		-tooltipvar ::game::mc::RemoveSelectedGame \
		-command [namespace code RemoveHistoryEntry] \
	]
	::toolbar::add $tbGameHistory button \
		-image $::icon::toolbarClear \
		-tooltipvar ::game::mc::ClearHistory \
		-command [list ::game::clearHistory] \
		;
	set tbDisplay [::toolbar::toolbar $top \
		-id editor-display \
		-side bottom \
		-tooltipvar [namespace current]::mc::Display \
	]
	::toolbar::add $tbDisplay checkbutton \
		-image $::icon::toolbarColumnLayout \
		-command [namespace code [list Refresh style:column]] \
		-tooltipvar ::pgn::setup::mc::ParLayout(column-style) \
		-variable ::pgn::editor::Options(style:column) \
		-padx 1 \
		;
	::toolbar::add $tbDisplay checkbutton \
		-image $::icon::toolbarParagraphSpacing \
		-command [namespace code [list Refresh spacing:paragraph]] \
		-tooltipvar ::pgn::setup::mc::ParLayout(use-spacing) \
		-variable ::pgn::editor::Options(spacing:paragraph) \
		-padx 1 \
		;
	set Vars(button:show:moveinfo) [::toolbar::add $tbDisplay checkbutton \
		-image $::icon::toolbarClock \
		-command [namespace code [list Refresh show:moveinfo]] \
		-tooltipvar ::pgn::setup::mc::Display(moveinfo) \
		-variable ::pgn::editor::Options(show:moveinfo) \
		-padx 1 \
	]
	set Vars(separator:variations) [::toolbar::addSeparator $tbDisplay]
	set Vars(button:fold-variations) [::toolbar::add $tbDisplay button \
		-image $::icon::toolbarToggleMinus \
		-command [namespace code { FoldVariations on }] \
		-tooltipvar [namespace current]::mc::CollapseVariations \
	]
	set Vars(button:expand-variations) [::toolbar::add $tbDisplay button \
		-image $::icon::toolbarTogglePlus \
		-command [namespace code { FoldVariations off }] \
		-tooltipvar [namespace current]::mc::ExpandVariations \
	]

	set tbLanguages [::toolbar::toolbar $top \
		-id editor-languages \
		-side bottom \
		-tooltipvar [namespace current]::mc::LanguageSelection \
	]
	set Vars(lang:active:xx) 1
	::toolbar::add $tbLanguages checkbutton \
		-image [::country::makeToolbarIcon ZZX] \
		-command [namespace code [list ToggleLanguage xx]] \
		-tooltipvar ::languagebox::mc::AllLanguages \
		-variable [namespace current]::Vars(lang:active:xx) \
		-padx 1 \
		;
	set Vars(lang:toolbar) $tbLanguages
	set Vars(lang:active:$::mc::langID) 1
	set Vars(toolbars) [list $tbGame $tbGameHistory $tbDisplay $tbLanguages]
	set Vars(toolbar:history) $tbGameHistory
	set Vars(toolbar:display) $tbDisplay
	set Vars(toolbar:languages) $tbLanguages

	grid columnconfigure $edit 1 -weight 1
	grid rowconfigure $edit 2 -weight 1
	bind $top <<LanguageChanged>> [namespace code LanguageChanged]

	set Vars(lang:set) {}
	set Vars(edit:comment) 0

	::scidb::db::subscribe gameSwitch [namespace current]::GameSwitched
	::pgn::setup::setupNags editor
	InitScratchGame
	Raise history
}


proc refresh {{regardFontSize no}} {
	variable Vars

	::widget::busyCursor on
	::pgn::setup::setupStyle editor

	for {set i 0} {$i < 9} {incr i} {
		::pgn::setup::configureText $Vars(frame:$i)
	}

	set Vars(charwidth) [font measure [$Vars(pgn:0) cget -font] "0"]
	::scidb::game::refresh -all

	if {$regardFontSize} {
		if {$Vars(index) >= 0} { ::scidb::game::refresh $Vars(index) -immediate }
		SetAlignment
		UpdateScrollbar
	}

	::widget::busyCursor off
}


proc setActiveLang {code flag} {
	set [namespace current]::Vars(lang:active:$code) $flag
}


proc activate {w flag} {
	variable Vars

	::toolbar::activate [winfo parent [lindex $Vars(toolbars) 0]] $flag
}


proc empty? {} {
	variable Vars
	return [expr {[::gamebar::size $Vars(gamebar)] == 0}]
}


proc gamebar {} {
	return [set [namespace current]::Vars(gamebar)]
}


proc add {position base variant tags} {
	variable Vars

	::gamebar::add $Vars(gamebar) $position $tags
	ResetGame $position $tags
}


proc replace {position base variant tags} {
	variable Vars

	::gamebar::replace $Vars(gamebar) $position $tags
	ResetGame $position $tags
}


proc release {position} {
	variable Vars
	::gamebar::remove $Vars(gamebar) $position
}


proc getTags {position} {
	return [set [namespace current]::Vars(tags:$position)]
}


proc resetGoto {w position} {
	variable Vars
	variable ::pgn::editor::Colors

	if {[llength $Vars(current:$position)]} {
		$w tag configure $Vars(current:$position) -background $Colors(background)
		set Vars(current:$position) {}
	}

	foreach k $Vars(next:$position) { $w tag configure $k -background $Colors(background) }
	set Vars(next:$position) {}

	if {[llength $Vars(previous:$position)]} {
		$w tag configure $Vars(previous:$position) -background $Colors(background)
		set Vars(previous:$position) {}
	}
}


proc select {{position {}}} {
	variable Vars

	if {[llength $position] == 0} {
		set position [::gamebar::selected $Vars(gamebar)]
		if {[llength $position]} { return }
		if {[::gamebar::empty? $Vars(gamebar)]} {
			::scidb::game::switch 9
			Raise history
			return
		}
		set position [::gamebar::getId $Vars(gamebar) 0]
	}

	::gamebar::activate $Vars(gamebar) $position
	Raise $position
}


proc selectAt {index} {
	variable Vars

	if {$index < [::gamebar::size $Vars(gamebar)]} {
		select [::gamebar::getId $Vars(gamebar) $index]
	}
}


proc lock {position} {
	::gamebar::lock [set [namespace current]::Vars(gamebar)] $position
}


proc setModified {position} {
	::gamebar::setState [set [namespace current]::Vars(gamebar)] $position yes
}


proc gamebarIsEmpty? {} {
	variable Vars
	return [::gamebar::empty? $Vars(gamebar)]
}


proc historyChanged {} {
	Raise logo
}


proc changeFontSize {incr} {
	if {[::font::changeSize editor $incr]} {
		refresh
		SetAlignment
		UpdateScrollbar
	}
}


proc saveGame {mode} {
	variable ::scidb::clipbaseName
	variable Vars

	set position [::gamebar::selected $Vars(gamebar)]
	lassign [::scidb::game::link? $position] base variant_

	if {$base eq $clipbaseName} { return }
	if {[::scidb::db::get readonly? $base $variant]} { return }


	switch $mode {
		add {
			::dialog::save::open $Vars(main) $base $variant $position
		}

		replace {
			lassign [::scidb::game::link? $position] _ _ index
			::dialog::save::open $Vars(main) $base $variant $position [expr {$index + 1}]
		}

		moves {
			replaceMoves $Vars(main)
		}
	}
}


proc editAnnotation {{position -1} {key {}}} {
	variable Vars

	if {$position == -1} {
		if {[::annotation::open?]} {
			return [::annotation::close]
		}
		set position $Vars(position)
	}

	if {[string length $key]} {
		GotoMove $position $key
	}

	Edit $position ::annotation
}


proc editComment {pos {position -1} {key {}} {lang {}}} {
	variable Vars

	if {$position == -1} { set position $Vars(position) }
	if {[llength $key] == 0 && $pos eq "a" && [::scidb::game::position $position atStart?]} { return }

	if {[llength $lang] == 0} {
		set lang ""
		foreach code [array names Vars lang:active:*] {
			set code [string range $code end-1 end]
			if {[string length $lang] == 0 || $code eq $::mc::langID} {
				if {[::scidb::game::query $position langSet $pos $Vars(current:$position) $code]} {
					set lang $code
				}
			}
		}
		if {[string length $lang] == 0} { set lang xx }
	}

	::scidb::game::variation unfold -force
	Edit $position ::comment $key $pos $lang
}


proc openMarksPalette {{position -1} {key {}}} {
	if {$position == -1 && [::marks::open?]} {
		::marks::close
	} else {
		Edit $position ::marks $key
	}
}


proc scroll {args} {
	::widget::textLineScroll [set [namespace current]::Vars(pgn:[::scidb::game::current])] scroll {*}$args
}


proc undo {} { Undo undo }
proc redo {} { Undo redo }


proc undoLastMove {} {
	set cmd [::scidb::game::query undo]
	if {$cmd eq "move:append" || $cmd eq "move:nappend"} { Undo undo }
}


proc replaceMoves {parent} {
	if {[::scidb::game::query modified?]} {
		set reply [::dialog::question -parent $parent -message $mc::ReallyReplaceMoves]
		if {$reply eq "yes"} { ::util::catchException { ::scidb::game::update moves } }
	} else {
		::dialog::info -parent $parent -message $mc::CurrentGameIsNotModified
	}
}


proc ensureScratchGame {} {
	variable ::scidb::scratchbaseName
	variable Vars

	if {[::gamebar::empty? $Vars(gamebar)]} {
		::scidb::game::switch 9
		set fen [::scidb::pos::fen]
		::scidb::game::new 0
		::scidb::game::switch 0
		::scidb::pos::setup $fen
		set tags [::scidb::game::tags 0]
		::game::setFirst $scratchbaseName Normal $tags
		add 0 $scratchbaseName Normal $tags
		select 0
	}
}


proc Raise {what} {
	variable Vars

	if {[string is integer $what]} {
		$Vars(panes) raise $Vars(frame:$what)
		$Vars(main) raise $Vars(games)
		set Vars(index) $what
		set Vars(position) $what
		::toolbar::setState $Vars(toolbar:display) enabled
		::toolbar::setState $Vars(toolbar:languages) enabled
		::toolbar::setState $Vars(toolbar:history) disabled
	} else {
		$Vars(hist) rebuild
		if {[$Vars(hist) empty?]} { set what logo } else { set what hist }
		$Vars(main) raise $Vars($what)
		set Vars(index) -1
		set Vars(position) -1
		::toolbar::setState $Vars(toolbar:display) disabled
		::toolbar::setState $Vars(toolbar:languages) disabled
		if {$what eq "hist"} {
			set selection [$Vars(hist) selection]
			if {$selection >= 0} { set state normal } else { set state disabled }
			::toolbar::childconfigure $Vars(button:remove) -state $state
			set state enabled
		} else {
			set state disabled
		}
		::toolbar::setState $Vars(toolbar:history) $state
	}

	set focus [::focus]
	if {[string length $focus] == 0 || [string match *.pgn.* $focus]} {
		[namespace parent]::board::setFocus
	}
}


proc InitScratchGame {} {
	variable Vars

	::scidb::game::new 9
	::scidb::game::switch 9

	set Vars(current:9) {}
	set Vars(successor:9) {}
	set Vars(previous:9) {}
	set Vars(next:9) {}
	set Vars(active:9) {}
	set Vars(see:9) 1
	set Vars(last:9) {}

	::scidb::game::subscribe board 9 [namespace parent]::board::update
	::scidb::game::subscribe board 9 [namespace parent]::analysis::update
	::scidb::game::switch 9
	set Vars(position) -1
}


proc StateChanged {position modified} {
	if {![::scidb::game::query trial]} {
		::gamebar::setState [set [namespace current]::Vars(gamebar)] $position $modified
		::game::stateChanged $position $modified
	}
}


proc See {position w key succKey} { ;# NOTE: we do not use succKey
	variable Vars
	variable CharLimit

	if {!$Vars(see:$position)} { return }
	if {[string length $key] == 0} { return }

	if {$Vars(start:$position)} {
		if {$key eq [::scidb::game::position startKey]} { return }
		set Vars(start:$position) 0
	}

	if {$key eq [::scidb::game::position startKey]} {
		$w see 1.0
		return
	}

	set firstLine [$w index m-start]
	set range [$w index $key]

	if {[llength $range]} {
		lassign [split [lindex $range 0] .] row col
		set last [expr {min($row + 3, $Vars(lastrow:$position))}]
		set rest [$w count -chars $row.$col $row.end]
		set count $rest
		set r $row
		while {$r < $last} {
			incr r
			incr count [$w count -chars $r.0 $r.end]
			if {$count > $CharLimit} {
				incr r -1
				break
			}
		}
		if {$r > $row} { $w see $r.0 }
		if {$rest < $CharLimit} {
			set offs [expr {[winfo width $w]/$Vars(charwidth)}]
			$w see $row.[expr {$col + min($CharLimit, 3*$offs)}]
		}
		$w see $row.$col
	} else {
		$w see $key
	}
}


proc Configure {height} {
	variable Vars

	after cancel $Vars(after)
	set Vars(after) [after 75 [namespace code [list Align $height]]]
}


proc Align {height} {
	variable Vars

	if {$height != $Vars(height)} {
		set Vars(height) $height
		SetAlignment
		UpdateScrollbar
	}
}


proc SetAlignment {} {
	variable Vars

	set height [winfo height $Vars(frame)]
	set pady [$Vars(pgn:0) cget -pady]
	set linespace1 [font metrics [$Vars(pgn:0) cget -font] -linespace]
	set linespace2 [expr {$linespace1 - 2*$pady}]
	set border [expr {2*[$Vars(pgn:0) cget -borderwidth]}]
	set delta [expr {($height - $border) % $linespace1}]
	set amounts [list $linespace1 $linespace2 $delta]
	::gamebar::setAlignment $Vars(gamebar) $amounts
}


proc UpdateScrollbar {} {
	variable Vars

	::widget::textLineScroll $Vars(pgn:0) moveto 0
	set position $Vars(index)
	if {$position >= 0} {
		See $position $Vars(pgn:$position) $Vars(current:$position) $Vars(successor:$position)
	}
}


proc GameBarEvent {action position} {
	variable Vars
	variable ::pgn::editor::Colors

	switch $action {
		removed {
			::game::release $position

			set w $Vars(pgn:$position)
			$w tag configure $Vars(current:$position) -background $Colors(background)
			foreach k $Vars(next:$position) { $w tag configure $k -background $Colors(background) }
			unset -nocomplain Vars(lang:set:$position)

			if {[::gamebar::empty? $Vars(gamebar)]} {
				::widget::busyCursor on
				::scidb::game::switch 9
				Raise history
				::widget::busyCursor off
				::annotation::deactivate
#				::toolbar::childconfigure $Vars(button:shuffle) -state disabled
			}

			$Vars(panes) unmap $Vars(frame:$position)
		}

		inserted {
#			::toolbar::childconfigure $Vars(button:shuffle) -state normal
		}

		lock {
			::game::lockChanged $position [::gamebar::locked? $Vars(gamebar) $position]
		}

		select {
			::scidb::game::switch $position
			[namespace parent]::board::updateMarks [::scidb::game::query marks]
			Raise $position
		}
	}
}


proc ToggleLanguage {lang} {
	SetLanguages [set [namespace current]::Vars(position)]
}


proc SetLanguages {position} {
	variable Vars

	set langSet {}
	foreach key [array names Vars lang:active:*] {
		if {$Vars($key)} {
			set lang [lindex [split $key :] 2]
			if {$lang eq "xx"} { set lang "" }
			lappend langSet $lang
		}
	}
	::scidb::game::langSet $position $langSet
}


proc AddLanguageButton {lang} {
	variable Vars

	if {![info exists Vars(lang:active:$lang)]} {
		set Vars(lang:active:$lang) 0
	}
	set countryCode [::mc::countryForLang $lang]
	set w [::toolbar::add $Vars(lang:toolbar) checkbutton \
		-image [::country::makeToolbarIcon $countryCode] \
		-command [namespace code [list ToggleLanguage $lang]] \
		-tooltipvar ::encoding::mc::Lang($lang) \
		-variable [namespace current]::Vars(lang:active:$lang) \
		-padx 1 \
	]
	set Vars(lang:button:$lang) $w
}


proc UpdateLanguages {position languages} {
	variable Vars

	if {$position >= 9} { return }
	if {$Vars(lang:set) eq $languages} { return }

	if {[llength $Vars(lang:set:$position)]} {
		foreach lang $languages {
			if {$lang ni $Vars(lang:set:$position)} {
				set Vars(lang:active:$lang) 1
			}
		}
		SetLanguages $position
	}

	set Vars(lang:set) $languages
	set Vars(lang:set:$position) $languages
	set langButtons [array names Vars lang:button:*]
	
	foreach button $langButtons {
		::toolbar::forget $Vars($button)
		unset Vars($button)
	}

	foreach lang $languages {
		AddLanguageButton $lang
	}
}


proc GameSwitched {position} {
	variable Vars

	if {[info exists Vars(lang:set:$position)]} {
		UpdateLanguages $position $Vars(lang:set:$position)
	}
}


proc Edit {position ns {key {}} {pos {}} {lang {}}} {
	variable Vars

	if {![::gamebar::empty? $Vars(gamebar)]} {
		if {$position == -1} {
			set position $Vars(position)
		}

		if {[llength $key]} {
			GotoMove $position $key
		}

		${ns}::open [winfo toplevel $Vars(pgn:$position)] {*}$pos {*}$lang
	}
}


proc Dump {w} {
	set dump [$w dump -all 1.0 end]
	foreach {type attr pos} $dump {
		if {$attr ne "current" && $attr ne "insert"} {
			if {$attr eq "\n"} { set attr "\\n" }
			switch $type {
				tagon - tagoff {}
				default { puts "$pos: $type $attr" }
			}
		}
	}
	puts "==============================================="
}


proc ConfigureEditor {} {
	variable Vars

	set position $Vars(position)
	::scidb::tree::freeze 1
	::scidb::game::new 10
	set Vars(current:10) {}
	set Vars(successor:10) {}
	set Vars(previous:10) {}
	set Vars(next:10) {}
	set Vars(active:10) {}
	set Vars(lang:set:10) [list {} $::mc::langID]
	set Vars(see:10) 1
	set Vars(dirty:10) 0
	set Vars(comment:10) ""
	set Vars(last:10) {}
	set Vars(virgin:10) 1
	set Vars(result:10) ""
	set Vars(header:10) ""
	set Vars(last:10) ""
	set Vars(start:10) 1
	set Vars(tags:10) {}
	set Vars(after:10) {}
	set Vars(position) 10
	::scidb::game::switch 10
	::pgn::setup::openSetupDialog [winfo toplevel $Vars(main)] editor 10
	set Vars(position) $position
	::scidb::game::release 10
	::scidb::game::switch $position
	::scidb::tree::freeze 0
	refresh
}


proc DoLayout {position data {w {}}} {
	variable ::pgn::editor::Options
	variable Vars

	if {[llength $w] == 0} { set w $Vars(pgn:$position) }

#set clock0 [clock milliseconds]
	foreach node $data {
		switch [lindex $node 0] {
			start {
				$w configure -state normal
				set Vars(marks) {}
			}

			languages {
				UpdateLanguages $position [lindex $node 1]
			}

			header {
				UpdateHeader $position $w [lindex $node 1]
			}

			begin {
				set level [lindex $node 3]
				set startVar($level) [lindex $node 2]
			}

			end {
				set level [lindex $node 3]
				Indent $w $level $startVar($level)
				incr level -1
			}

			action {
				set Vars(dirty:$position) 1
				set args [lindex $node 1]

				switch [lindex $args 0] {
					replace {
						lassign $args unused level removePos insertMark
						$w delete $removePos $insertMark
						$w mark gravity $removePos left
						$w mark gravity $insertMark right
						$w mark set current $insertMark
						set insertPos [$w index $insertMark]
					}

					insert {
						lassign $args unused level insertMark
						$w mark gravity $insertMark right
						$w mark set current $insertMark
						set insertPos [$w index $insertMark]
					}

					finish {
						set level [lindex $args 1]
						Indent $w $level $insertPos
						Mark $w $insertMark
					}

					remove {
						$w delete {*}[lrange $args 2 end]
					}

					clear {
						$w delete m-start m-0
						$w insert m-0 "\u200b"
					}

					marks	{ [namespace parent]::board::updateMarks [::scidb::game::query marks] }
					goto	{ ProcessGoto $position $w [lindex $args 1] [lindex $args 2] }
				}
			}

			move {
				set key  [lindex $node 1]
				set data [lindex $node 2]

				Mark $w $key
				InsertMove $position $w $level $key $data
				set Vars(last:$position) $key
			}

			diagram {
				set key  [lindex $node 1]
				set data [lindex $node 2]

				Mark $w $key
				InsertDiagram $position $w $level $key $data
			}

			result {
				set reason [::scidb::game::query $position termination]
				set resultList [list {*}[lrange $node 1 end] $reason]

				if {$Vars(result:$position) != $resultList} {
					if {[string length $Vars(last:$position)]} {
						$w mark gravity $Vars(last:$position) left
					}
					$w mark gravity m-0 left
					$w mark set current m-0
					set prevChar [$w get current-1c]
					$w delete current end
					set result [::browser::makeResult {*}$resultList]
					if {[llength $result]} {
						lassign $result result reason
						if {$Options(spacing:paragraph)} { $w insert current \n }
						if {[string length $result]} {
							$w insert current $result result
						}
						if {[string length $reason]} {
							if {[string length $result]} { $w insert current " " }
							$w insert current "($reason)"
						}
					} else {
						# NOTE: We need a blind character between the marks because
						# the editor is permuting consecutive marks.
						$w insert current "\u200b"
					}
					$w mark gravity m-0 right
					# NOTE: the text editor has a severe bug:
					# If the char after <pos1> is a newline, the command
					# '<text> delete <pos1> <pos2>' will also delete one
					# newline before <pos1>. We have to catch this case:
					if {$prevChar eq "\n"} { $w insert m-0 \n }
					if {[string length $Vars(last:$position)]} {
						$w mark gravity $Vars(last:$position) right
					}
					set Vars(result:$position) $resultList
				}
				# NOTE: very slow!!
#				foreach mark $Vars(marks) { $w mark gravity $mark right }
				$w mark gravity m-0 right
				$w configure -state disabled
				set Vars(lastrow:$position) [lindex [split [$w index end] .] 0]
			}
		}
	}

	after idle [namespace code UpdateButtons]
#set clock1 [clock milliseconds]
#puts "clock: [expr {$clock1 - $clock0}]"
}


proc Indent {w level key} {
	variable ::pgn::editor::Options

	if {$level > 0} {
		if {($::pgn::editor::Options(style:column))} {
			if {[incr level -1] == 0} { return }
		}
		set level [expr {min($level, $Options(indent:max))}]
		$w tag add indent$level $key current
	}
}


proc ProcessGoto {position w key succKey} {
	variable Vars
	variable ::pgn::editor::Colors

	::move::reset

	if {$Vars(current:$position) ne $key} {
		::scidb::game::variation unfold
		foreach k $Vars(next:$position) { $w tag configure $k -background $Colors(background) }
		set Vars(next:$position) [::scidb::game::next keys $position]
		if {$Vars(active:$position) eq $key} { $w configure -cursor {} }
		if {[llength $Vars(previous:$position)]} {
			$w tag configure $Vars(previous:$position) -background $Colors(background)
		}
		$w tag configure $key -background $Colors(background:current)
		set Vars(current:$position) $key
		set Vars(successor:$position) $succKey
		if {[llength $Vars(previous:$position)]} {
			after cancel $Vars(after:$position)
			set Vars(after:$position) {}
			See $position $w $key $succKey
			if {$Vars(active:$position) eq $Vars(previous:$position)} {
				EnterMove $position $Vars(previous:$position)
			}
		}
		foreach k $Vars(next:$position) {
			$w tag configure $k -background $Colors(background:nextmove)
		}
		set Vars(previous:$position) $Vars(current:$position)
		[namespace parent]::board::updateMarks [::scidb::game::query marks]
		if {$position < 9} { ::annotation::update $key }
	} elseif {$Vars(dirty:$position)} {
		set Vars(dirty:$position) 0
		after cancel $Vars(after:$position)
		set Vars(after:$position) {}
		See $position $w $key $succKey
	}
}


proc UpdateHeader {position w data} {
	variable ::pgn::editor::Options
	variable Vars

	if {!$Vars(virgin:$position)} {
		$w delete 1.0 m-start
	}

	$w mark set current 1.0

	if {$Options(show:opening) || $position < 9} {
		set idn 0
		set opening {}
		set pos ""

		foreach pair $data {
			lassign $pair name value
			switch $name {
				idn		{ set idn $value }
				eco		{ set eco $value }
				position { set pos $value }
				opening	{ set opg $value }
			}
		}

		set variant [::scidb::game::query $position variant?]

		switch $variant {
			Normal {
				foreach line [::browser::makeOpeningLines [list $idn $pos $eco {*}$opg]] {
					set tags {}
					lassign $line content tags
					if {$tags eq "figurine"} {
						set tags figurineb
					} else {
						lappend tags opening
					}
					$w insert current $content $tags
				}
			}
			Suicide - Giveaway - Losers {
				$w insert current "$::mc::VariantName(Antichess) - $::mc::VariantName($variant)" opening
			}
			default {
				$w insert current $::mc::VariantName($variant) opening
			}
		}

		$w insert current "\n"
	}
	$w mark set m-start [$w index current]
	$w mark gravity m-start left

	if {$Vars(virgin:$position)} {
		$w mark set m-0 [$w index current]
		$w mark gravity m-0 right
	}

	set Vars(virgin:$position) 0
	set Vars(header:$position) $data
}


proc InsertMove {position w level key data} {
	variable ::pgn::editor::Options
	variable Vars

	if {[llength $data] == 0} {
		# NOTE: We need a blind character between the marks because
		# the editor is permuting consecutive marks.
		# NOTE: Actually this case (empty data) should not happen.
		$w insert current "\u200b"
	}

	set havePly 0
	set prefixAnnotation {}
	set suffixAnnotation {}

	foreach node $data {
		switch [lindex $node 0] {
			break {
				set lvl [lindex $node 1]
				if {$lvl <= $Options(indent:max)} {
					set space "\n"
				} elseif {$lvl + 1 == $Options(indent:max)} {
					if {$Options(style:column)} { set space "\n" } else { set space " " }
				} elseif {	$Options(indent:max) == 0
							&& (	$Options(style:column)
								|| ($lvl == 1 && $Options(spacing:paragraph)))} {
					set space "\n"
				} else {
					set space " "
				}
				$w insert current $space
			}

			space {
				lassign $node _ space flag number
				switch $space {
					" " { $w insert current " " }
					")" { $w insert current " )" bracket }
					"e" { $w insert current "\n"; $w insert current "<$mc::EmptyGame>" empty }
					"s" { if {[$w index current] ne "1.1"} { $w insert current "\n" } }

					"]" {
						if {$flag && $level > $Options(indent:max)} {
							set txt "]"
						} else {
							# NOTE: We need a blind character between the marks because
							# the editor is permuting consecutive marks.
							set txt "\u200b"
						}
						$w insert current $txt bracket
					}

					default {
						variable cursor::collapse
						variable ::pgn::editor::Colors

						if {$space eq "+"} {
							$w insert current " "
							set img $w.[string map {. :} $key]
							tk::label $img \
								-background $Colors(background) \
								-borderwidth 0 \
								-padx 0 \
								-pady 0 \
								-image $icon::12x12::expand \
								;
							$w window create current -align center -window $img
							bind $img <ButtonPress-1> [namespace code [list ToggleFold $w $key 0]]
							$w insert current " )" bracket
						} elseif {[info exists collapse]} {
							set tag fold:$key
							if {$space eq "\["} {
								if {$flag && $level > $Options(indent:max)} {
									$w insert current "\[" [list bracket $tag]
								}
								$w insert current "($number) " [list numbering $tag]
							} else {
								$w insert current "( " [list bracket $tag]
							}
							if {$position < 9} {
								$w tag bind $tag <Any-Enter> +[namespace code [list EnterBracket $w $key]]
								$w tag bind $tag <Any-Leave> +[namespace code [list LeaveBracket $w]]
								$w tag bind $tag <ButtonPress-1> [namespace code [list ToggleFold $w $key 1]]
							}
						} else {
							if {$space eq "\["} {
								if {$flag && $level > $Options(indent:max)} {
									$w insert current "\[" bracket
								}
								$w insert current "($number) " numbering
							} else {
								$w insert current "( " bracket
							}
						}
					}
				}
			}

			ply {
				PrintMove $position $w $level $key [lindex $node 1] $prefixAnnotation
				if {[llength $suffixAnnotation]} {
					PrintNumericalAnnotation $position $w $level $key $suffixAnnotation 0
				}
				set havePly 1
			}

			annotation {
				lassign $node _ isTextual prefix infix suffix
				lappend infix {*}$suffix
				if {$isTextual} {
					lappend prefix {*}$infix
					PrintTextualAnnotation $position $w $level $key $prefix
				} else {
					set prefixAnnotation $prefix
					set suffixAnnotation $infix
				}
			}

			marks {
				set hasMarks [lindex $node 1]
				if {$hasMarks} {
					set tag marks:$key
					if {$havePly} { $w insert current " " }
					$w insert current "\u27f8" [list marks $tag]
					if {$position < 9} {
						$w tag bind $tag <Any-Enter> +[namespace code [list EnterMark $w $tag $key]]
						$w tag bind $tag <Any-Leave> +[namespace code [list LeaveMark $w $tag]]
						$w tag bind $tag <ButtonPress-1> \
							[namespace code [list openMarksPalette $position $key]]
					}
				}
			}

			comment {
				set startPos [$w index current]
				set type [lindex $node 1]
				if {$type eq "f"} {
					PrintMoveInfo $position $w $level $key [lindex $node 2]
				} else {
					PrintComment $position $w $level $key $type [lindex $node 2]
				}
				if {$level == 0 && !($Options(style:column))} {
					$w tag add indent1 $startPos current
				}
			}
		}
	}
}


proc InsertDiagram {position w level key data} {
	variable ::pgn::editor::Options
	variable ::pgn::editor::Colors
	variable Vars

	set color white

	foreach entry $data {
		switch [lindex $entry 0] {
			color { set color [lindex $entry 1] }
			break { $w insert current "\n" }

			board {
				set linespace [font metrics [$w cget -font] -linespace]
				set borderSize 2
				set size $Options(diagram:size)
				set alignment [expr {$linespace - ((8*$size + 2*$borderSize) % $linespace)}]
				if {$alignment/2 < $Options(diagram:pady) - 1} { incr alignment $linespace }
				if {$alignment/2 - $Options(diagram:pady) >= 8} {
					incr size -1
					incr alignment -8
				}
				set pady [expr {$alignment/2}]
				set board [lindex $entry 1]
				set index 0
				set key [string map {d m} $key]
				set img $w.[string map {. :} $key]
				board::diagram::new $img $size $borderSize
				if {2*$pady < $alignment} {board::diagram::alignBoard $img $Colors(background)}
				if {$color eq "black"} { ::board::diagram::rotate $img }
				::board::diagram::update $img $board
				::board::diagram::bind $img <Button-1> [namespace code [list editAnnotation $position $key]]
				::board::diagram::bind $img <Button-3> [namespace code [list PopupMenu $w $position]]
				$w window create current \
					-align center \
					-window $img \
					-padx $Options(diagram:padx) \
					-pady $pady \
					;
			}
		}
	}
}


proc PrintMove {position w level key data annotation} {
	variable ::pgn::editor::Options

	lassign $data moveNo stm san legal
	set tags $key

	if {$level > 0} {
		lappend tags variation
		set main {}
	} else {
		set main main
	}

	if {$level == 0 && $Options(style:column)} {
		$w insert current "\t"

		if {$moveNo} {
			$w insert current $moveNo main
			$w insert current ". " main
			$w insert current "\t"
			if {$stm eq "black"} { $w insert current "...\t" main }
		} 

		if {[llength $annotation]} {
			PrintNumericalAnnotation $position $w $level $key $annotation 1
			$w insert current "\u2006"
		}
	} else {
		if {[llength $annotation]} {
			PrintNumericalAnnotation $position $w $level $key $annotation 1
			$w insert current "\u2006"
		}

		set myTags [list {*}$tags $main]

		if {$moveNo} {
			$w insert current $moveNo $myTags
			$w insert current "." $myTags
			if {$stm eq "black"} { $w insert current ".." $myTags }
		}
	}

	if {$level == 0} {
		if {!$legal} { lappend tags illegal }
		if {$Options(weight:mainline) eq "bold"} { set t figurineb } else { set t figurine }
	} else {
		set t figurine
	}

	foreach {text tag} [::font::splitMoves $san $t] {
		if {[llength $tag] == 0} { set tag $main }
		PrintSingleMove $position $w $key $text [list {*}$tags {*}$tag]
	}

	if {!$legal && $level > 0} {
		set tags illegal
#		if {$level == 0} { lappend tags main }
		$w insert current "\u26A1" $tags ;# alternatives: u26A0, u2716
		if {$position < 9} {
			$w tag bind illegal <ButtonPress-1> [namespace code [list GotoMove $position $key]]
		}
	}
}


proc PrintSingleMove {position w key text tags} {
	$w insert current $text [list {*}$tags]
	if {$position < 9} {
		$w tag bind $key <Any-Enter> [namespace code [list EnterMove $position $key]]
		$w tag bind $key <Any-Leave> [namespace code [list LeaveMove $position $key]]
		$w tag bind $key <ButtonPress-1> [namespace code [list GotoMove $position $key]]
		$w tag bind $key <ButtonPress-2> [namespace code [list ShowPosition $position $w $key %s]]
		$w tag bind $key <ButtonRelease-2> [list ::browser::hidePosition $w]
		$w tag bind $key <Any-Button> [list ::browser::hidePosition $w]
	}
}


proc ShowPosition {position w key state} {
	::browser::showPosition $w $position [[namespace parent]::board::rotated?] $key $state
}


proc PrintComment {position w level key pos data} {
	set startPos {}
	set underline 0
	set flags 0
	set count 0
	set needSpace 0
	set lastChar ""
	set paragraph 0
	set keyTag comment:$key:$pos

	foreach entry [::scidb::misc::xml toList $data] {
		lassign $entry lang comment
		if {[string length $lang] == 0} {
			set lang xx
		} elseif {[incr paragraph] >= 2} {
			$w insert current " \u2726 "
			set needSpace 0
		}
		set langTag $keyTag:$lang
		foreach pair $comment {
			lassign $pair code text
			set text [string map {"<brace/>" "\{"} $text]
			if {$needSpace} {
				if {![string is space -strict [string index $text 0]]} {
					$w insert current " " $langTag
				}
				set needSpace 0
			}
			set lastChar [string index $text end]
			switch -- $code {
				sym {
					if {[llength $startPos] == 0} { set startPos [$w index current] }
					$w insert current [string map $::figurines::pieceMap $text] [list figurine $langTag]
				}
				nag {
					if {[llength $startPos] == 0} { set startPos [$w index current] }
					lassign [::font::splitAnnotation $text] value sym tag
					set nagTag nag$text
					if {($flags & 1) && $tag eq "symbol"} { set tag symbolb }
					if {[string is digit $sym]} { set text "{\$$text}" }
					lappend tag $langTag $nagTag
					$w insert current $sym $tag
					incr count
				}
				str {
					if {[llength $startPos] == 0} { set startPos [$w index current] }
					switch $flags {
						0 { set tag {} }
						1 { set tag bold }
						2 { set tag italic }
						3 { set tag bold-italic }
					}
					$w insert current $text [list $langTag $tag]
				}
				+bold			{ incr flags +1 }
				-bold			{ incr flags -1 }
				+italic		{ incr flags +2 }
				-italic		{ incr flags -2 }
				+underline	{ set underline 1 }
				-underline	{ set underline 0 }
			}
		}

		if {[llength $startPos]} {
			$w tag add comment $startPos current
			if {$position < 9} {
				$w tag bind $langTag <Enter> [namespace code [list EnterComment $w $key:$pos:$lang]]
				$w tag bind $langTag <Leave> \
					[namespace code [list LeaveComment $w $position $key:$pos:$lang]]
				$w tag bind $langTag <ButtonPress-1> \
					[namespace code [list EditComment $position $key $pos $lang]]
			}
			set startPos {}
		}

		if {![string is space -strict $lastChar]} {
			set needSpace 1
		}
	}
}


proc PrintMoveInfo {position w level key data} {
	set underline 0
	set flags 0
	set count 0
	set keyTag info:$key
	set moveInfo [lindex [::scidb::misc::xml toList $data] 0 1]

	foreach pair $moveInfo {
		lassign $pair code text
		switch -- $code {
			str {
				set k 0
				while {$k < [string length $text]} {
					set n [string first ";" $text $k]
					if {$n == -1} { set n [string length $text] }
					if {$k > 0} { $w insert current " \u2726 " }
					set startPos [$w index current]
					switch $flags {
						0 { set tag {} }
						1 { set tag bold }
						2 { set tag italic }
						3 { set tag bold-italic }
					}
					$w insert current [string range $text $k [expr {$n - 1}]] [list $keyTag $tag]
					$w tag add info $startPos current
					if {$position < 9} {
						$w tag bind $keyTag <Enter> [namespace code [list EnterInfo $w $key]]
						$w tag bind $keyTag <Leave> [namespace code [list LeaveInfo $w $position $key]]
						$w tag bind $keyTag <ButtonPress-1> [namespace code [list EditInfo $w $position $key]]
					}
					set k [incr n]
				}
			}
			+bold			{ incr flags +1 }
			-bold			{ incr flags -1 }
			+italic		{ incr flags +2 }
			-italic		{ incr flags -2 }
			+underline	{ set underline 1 }
			-underline	{ set underline 0 }
		}
	}
}


proc PrintNumericalAnnotation {position w level key nags isPrefix} {
	variable ::pgn::editor::Options

	set annotation [::font::splitAnnotation $nags]
	set pos [$w index current]
	set keyTag nag:$key
	set prevSym -1
	set count 0

	foreach {value nag tag} $annotation {
		if {$tag eq "symbol"} {
			if {$level == 0} { set tag symbolb }
			set sym 1
		} else {
			set sym 0
		}
		set nagTag $keyTag:[incr count]
		set c [string index $nag 0]
		if {[string is alpha $c] && [string is ascii $c]} {
			if {[lindex [split [$w index current] .] end] ne "0"} {
				if {$prevSym >= 0 || !$isPrefix} {
					$w insert current " "
				}
			}
			set prevSym 1
		} elseif {$value <= 6} {
			if {$count > 1} { $w insert current "\u2005" }
			set prevSym 1
		} elseif {$value == 155 || $value == 156} {
			if {[lindex [split [$w index current] .] end] ne "0"} { $w insert current "\u2005" }
			set prevSym $sym
		} elseif {!$sym && !$isPrefix} {
			$w insert current "\u2005"
			set prevSym $sym
		}
		if {[string length $nag]} {
			if {$level == 0 && [string index $nag 0] ne "$"} { lappend tag main }
			lappend tag nag$value
			$w insert current $nag [list {*}$tag $nagTag]
			if {$position < 9} {
				$w tag bind $nagTag <Enter> [namespace code [list EnterAnnotation $w $nagTag]]
				$w tag bind $nagTag <Leave> [namespace code [list LeaveAnnotation $w $nagTag]]
			}
		}
		set prefix 0
	}

	set keyTag numerical:$key
	$w tag add nag $pos current
	$w tag raise symbol
	$w tag raise symbolb
	$w tag add $keyTag $pos current

	if {$position < 9} {
		$w tag bind $keyTag <ButtonPress-1> [namespace code [list editAnnotation $position $key]]
	}
}


proc PrintTextualAnnotation {position w level key nags} {
	set pos [$w index current]
	set keyTag nagtext:$key
	set count 0

#	set pos [$w index current]
#	if {![string match *.0 $pos]} { $w insert current " " }

	foreach nag $nags {
		if {$count > 0} { $w insert current " \u2726 " nagtext }
		set nagTag $keyTag:[incr count]
		set txt $::annotation::mc::Nag([string range $nag 1 end])
		$w insert current $txt [list $nagTag nagtext]
		if {$position < 9} {
			$w tag bind $nagTag <Enter> [namespace code [list EnterAnnotation $w $nagTag]]
			$w tag bind $nagTag <Leave> [namespace code [list LeaveAnnotation $w $nagTag]]
		}
	}

	set keyTag textual:$key
	$w tag add nag $pos current
	$w tag add $keyTag $pos current

	if {$position < 9} {
		$w tag bind $keyTag <ButtonPress-1> [namespace code [list editAnnotation $position $key]]
	}
}


proc EditComment {position key pos lang} {
	variable Vars

	set w $Vars(pgn:$position)
	set Vars(edit:comment) 1
	editComment $pos $position $key $lang
	set Vars(edit:comment) 0
	LeaveComment $w $position $key:$pos:$lang
}


proc Mark {w key} {
	variable Vars

	$w mark unset $key
	$w mark set $key [$w index current]
	$w mark gravity $key left
	lappend Vars(marks) $key
}


proc EnterMove {position key} {
	variable Vars
	variable ::pgn::editor::Colors

	if {$Vars(current:$position) ne $key} {
		$Vars(pgn:$position) tag configure $key -background $Colors(hilite:move)
		$Vars(pgn:$position) configure -cursor hand2
	}

	set Vars(active:$position) $key
}


proc LeaveMove {position key} {
	variable Vars
	variable ::pgn::editor::Colors

	set Vars(active:$position) {}

	if {$Vars(current:$position) ne $key} {
		if {$key in $Vars(next:$position)} {
			set color $Colors(background:nextmove)
		} else {
			set color $Colors(background)
		}
		$Vars(pgn:$position) tag configure $key -background $color
		$Vars(pgn:$position) configure -cursor {}
	}
}


proc EnterMark {w tag key} {
	variable ::pgn::editor::Colors

	$w tag configure $tag -background $Colors(hilite:move)
	::tooltip::show $w [string map {",," "," " " "\n"} [::scidb::game::query marks $key]]
}


proc LeaveMark {w tag} {
	variable ::pgn::editor::Colors

	$w tag configure $tag -background $Colors(background)
	::tooltip::hide
}


proc EnterBracket {w key} {
	variable Counter
	variable Vars

	if {[::scidb::game::variation folded? $key]} {
		set cursor $cursor::expand
	} else {
		set cursor $cursor::collapse
	}

	incr Counter
	after 75 [namespace code [list SetCursor $w $cursor $Counter]]
}


proc SetCursor {w cursor counter} {
	variable Counter

	if {$counter < $Counter} { return }

	if {[tk windowingsystem] eq "x11"} {
		::xcursor::setCursor $w $cursor
	} else {
		$w configure -cursor $cursor
	}
}


proc LeaveBracket {w} {
	variable Vars
	variable Counter

	incr Counter

	if {[tk windowingsystem] eq "x11"} {
		::xcursor::unsetCursor $w
	} else {
		$w configure -cursor {}
	}
}


proc ToggleFold {w key triggerEnter} {
	::scidb::game::variation fold $key toggle
	if {$triggerEnter} {
		EnterBracket $w $key	;# toggle cursor
	}
}


proc GotoMove {position key} {
	variable Vars

	set Vars(see:$position) 0
	if {[llength $key] == 0} { set key [::scidb::game::query start] }
	::scidb::game::moveto $position $key
	set Vars(see:$position) 1
}


proc EnterComment {w key} {
	variable ::pgn::editor::Colors
	$w tag configure comment:$key -foreground $Colors(hilite:comment)
}


proc LeaveComment {w position key} {
	variable ::pgn::editor::Colors
	variable Vars

	if {!$Vars(edit:comment)} {
		$w tag configure comment:$key -foreground $Colors(foreground:comment)
	}
}


proc EnterInfo {w key} {
	variable ::pgn::editor::Colors
	$w tag configure info:$key -foreground $Colors(hilite:info)
}


proc LeaveInfo {w position key} {
	variable ::pgn::editor::Colors
	variable Vars

	if {!$Vars(edit:comment)} {
		$w tag configure info:$key -foreground $Colors(foreground:info)
	}
}


proc EnterAnnotation {w tag} {
	variable ::pgn::editor::Colors
	$w tag configure $tag -background $Colors(hilite:move)
}


proc LeaveAnnotation {w tag} {
	variable ::pgn::editor::Colors
	$w tag configure $tag -background $Colors(background)
}


proc EditInfo {w position {key {}}} {
	variable Vars

	if {[string length $key]} {
		GotoMove $position $key
	} else {
		set key $Vars(current:$position)
	}

	::beta::notYetImplemented $w moveinfo
}


proc Undo {action} {
	variable Vars

	if {[llength [::scidb::game::query $action]]} {
#		XXX Do not use busy cursor, because the KeyRelease event will be lost!
#		::widget::busyCursor on
		::scidb::game::execute $action
		[namespace parent]::board::updateMarks [::scidb::game::query marks]
		::annotation::update
#		::widget::busyCursor off
	}
}


proc ResetGame {position tags} {
	variable Vars
	variable ::pgn::editor::Colors

	set w $Vars(pgn:$position)

	$w configure -state normal
	$w delete 1.0 end
#	foreach tag [$Vars(pgn:$position) tag names] {
#		if {[string match m-* $tag]} { $w tag delete $tag }
#	}
	$w edit reset
	$w configure -state disabled

	::gamebar::activate $Vars(gamebar) $position
	Raise $position

	if {[info exists Vars(next:$position)]} {
		foreach k $Vars(next:$position) { $w tag configure $k -background $Colors(background) }
		$w tag configure $Vars(current:$position) -background $Colors(background)
	}

	set Vars(current:$position) {}
	set Vars(successor:$position) {}
	set Vars(previous:$position) {}
	set Vars(next:$position) {}
	set Vars(active:$position) {}
	set Vars(lang:set:$position) {}
	set Vars(see:$position) 1
	set Vars(dirty:$position) 0
	set Vars(comment:$position) ""
	set Vars(result:$position) ""
	set Vars(virgin:$position) 1
	set Vars(header:$position) ""
	set Vars(last:$position) ""
	set Vars(start:$position) 1
	set Vars(tags:$position) $tags

	SetLanguages $position
	::pgn::setup::setupStyle editor $position

	::scidb::game::subscribe pgn $position [namespace current]::DoLayout
	::scidb::game::subscribe board $position [namespace parent]::board::update
	::scidb::game::subscribe tree $position [namespace parent]::tree::update
	::scidb::game::subscribe board $position [namespace parent]::analysis::update
	::scidb::game::subscribe state $position [namespace current]::StateChanged
}


proc UpdateButtons {} {
	variable Vars

	if {[::scidb::game::query moveInfo?]} {
		::toolbar::add $Vars(button:show:moveinfo)
	} else {
		::toolbar::remove $Vars(button:show:moveinfo)
	}

	if {[::scidb::game::query variations?]} {
		::toolbar::add $Vars(separator:variations)
		::toolbar::add $Vars(button:expand-variations)
		::toolbar::add $Vars(button:fold-variations)
	} else {
		::toolbar::remove $Vars(separator:variations)
		::toolbar::remove $Vars(button:expand-variations)
		::toolbar::remove $Vars(button:fold-variations)
	}
}


proc PopupMenu {parent position} {
	variable ::annotation::mc::Nag
	variable ::annotation::LastNag
	variable ::scidb::scratchbaseName
	variable ::notation::moveStyles
	variable Vars

	set menu $parent.__menu__
	catch { destroy $menu }
	menu $menu -tearoff 0
	catch { wm attributes $menu -type popup_menu }

	if {[::game::trialMode?]} {
		$menu add command \
			-label " $mc::StopTrialMode" \
			-image $::icon::16x16::delete \
			-compound left \
			-command ::game::flipTrialMode \
			-accel "$::mc::Key(Ctrl)-[set [namespace parent]::board::mc::Accel(trial-mode)]" \
			;
		$menu add separator
	} else {
		if {[::scidb::game::level] > 0} {
			set varno [::scidb::game::variation current]
			if {$varno > 1} {
				$menu add command \
					-label "$mc::Command(variation:first)" \
					-command [namespace code FirstVariation] \
					;
			}
			foreach {action cmd} {promote PromoteVariation remove RemoveVariation} {
				$menu add command -label $mc::Command(variation:$action) -command [namespace code $cmd]
			}
			if {[::scidb::game::variation length] % 2} {
				set state disabled
			} else {
				set state normal
			}
			$menu add command \
				-state $state \
				-label $mc::Command(variation:insert) \
				-command [namespace code [list InsertMoves $parent]] \
				;
			$menu add command \
				-label "$mc::Command(variation:exchange)..." \
				-command [namespace code [list ExchangeMoves $parent]] \
				;
			$menu add separator
		}

		$menu add command \
			-label " $mc::StartTrialMode" \
			-image $::icon::16x16::trial \
			-compound left \
			-command ::game::flipTrialMode \
			-accel "$::mc::Key(Ctrl)-[set [namespace parent]::board::mc::Accel(trial-mode)]" \
			;
		$menu add command \
			-label " $mc::Command(game:transpose)" \
			-image $::icon::16x16::none \
			-compound left \
			-command [namespace code TransposeGame] \
			;

		menu $menu.strip -tearoff no
		set state "normal"
		if {![::scidb::game::position isMainline?] || [::scidb::game::position atStart?]} {
			set state "disabled"
		}
		$menu.strip add command \
			-label $mc::Command(strip:moves) \
			-state $state \
			-command [list ::widget::busyOperation { ::scidb::game::strip moves }] \
			;
		set state "normal"
		if {	[::scidb::game::position atEnd?]
			|| (![::scidb::game::position isMainline?] && [::scidb::game::position atStart?])} {
			
			set state "disabled"
		}
		$menu.strip add command \
			-label $mc::Command(strip:truncate) \
			-state $state \
			-command [list ::widget::busyOperation { ::scidb::game::strip truncate }] \
			;
		foreach cmd {variations annotations info marks} {
			set state "normal"
			if {[::scidb::game::count $cmd] == 0} { set state "disabled" }
			$menu.strip add command \
				-label $mc::Command(strip:$cmd) \
				-state $state \
				-command [list ::widget::busyOperation [list ::scidb::game::strip $cmd]] \
				;
		}

		set state "normal"
		if {[::scidb::game::count comments] == 0} { set state disabled }

		menu $menu.strip.comments -tearoff no
		$menu.strip add cascade \
			-menu $menu.strip.comments \
			-label " $mc::Command(strip:comments)" \
			-state $state \
			;

		if {$state eq "normal"} {
			$menu.strip.comments add command \
				-compound left \
				-image $::country::icon::flag([::mc::countryForLang xx]) \
				-label " $::languagebox::mc::AllLanguages" \
				-command [list ::widget::busyOperation { ::scidb::game::strip comments }] \
				;

			foreach lang $Vars(lang:set) {
				$menu.strip.comments add command \
					-compound left \
					-image $::country::icon::flag([::mc::countryForLang $lang]) \
					-label " [::encoding::languageName $lang]" \
					-command [list ::widget::busyOperation [list ::scidb::game::strip comments $lang]] \
					;
			}
		}

		$menu add cascade \
			-menu $menu.strip \
			-label " $mc::Strip" \
			-image $::fsbox::filelist::icon::16x16::delete \
			-compound left \
			;
		$menu add command \
			-label " $mc::Command(copy:comments)..." \
			-image $::icon::16x16::none \
			-compound left \
			-command [namespace code [list CopyComments $parent]] \
			-state $state \
			;

		if {[::scidb::game::query database] eq $::scidb::scratchbaseName} {
			$menu add command \
				-label " $::import::mc::ImportPgnGame..." \
				-image $::icon::16x16::filetypePGN \
				-compound left \
				-command [namespace code PasteClipboardGame] \
				;
		}
		$menu add command \
			-label " $::import::mc::ImportPgnVariation..." \
			-image $::icon::16x16::filetypePGN \
			-compound left \
			-command [namespace code PasteClipboardVariation] \
			;

#		set vars [::scidb::game::next moves -unicode]
#
#		foreach {which cmd start} {first FirstVariation 2
#											promote PromoteVariation 1
#											remove RemoveVariation 1} {
#			if {[llength $vars] > $start} {
#				if {[llength $vars] > [expr {$start + 1}]} {
#					menu $menu.$which
#					$menu add cascade -menu $menu.$which -label $mc::Command($which)
#
#					for {set i $start} {$i < [llength $vars]} {incr i} {
#						$menu.$which add command \
#							-label [::font::translate [lindex $vars $i]] \
#							-command [namespace code [list $cmd $i]]
#					}
#				} else {
#					$menu add command \
#						-label "$mc::Command($which): [::font::translate [lindex $vars 1]]" \
#						-command [namespace code [list $cmd 1]]
#				}
#			}
#		}

		$menu add separator

		if {[::scidb::game::position atStart?]} {
			$menu add command \
				-label " $mc::InsertDiagram" \
				-image $::icon::16x16::board \
				-compound left \
				-command [list ::annotation::setNags suffix 155] \
				;
			$menu add command \
				-label " $mc::InsertDiagramFromBlack" \
				-image $::icon::16x16::board \
				-compound left \
				-command [list ::annotation::setNags suffix 156] \
				;
		} else {
			set cmd ::annotation::setNags

			if {[::scidb::pos::stm] eq "w"} {
				upvar #0 ::annotation::isWhiteNag isStmNag
			} else {
				upvar #0 ::annotation::isBlackNag isStmNag
			}

			foreach type {prefix infix suffix} {
				set ranges $::annotation::sections($type)
				set m [menu $menu.$type]

				if {[llength $ranges] == 1} {
					$m add command -command "$cmd $type 0"
					lassign [lindex $ranges 0] descr from to
					bind $m <<MenuSelect>> [namespace code { ::widget::menuItemHighlightSecond %W }]
				} else {
					$menu add cascade \
						-menu $m \
						-label " $mc::SuffixCommentaries" \
						-image $::icon::16x16::annotation($type) \
						-compound left \
						;
					$m add command -label "($mc::None)" -command "$cmd $type 0"
				}

				foreach range $::annotation::sections($type) {
					lassign $range descr from to
					set text [set ::annotation::mc::$descr]

					if {[llength $ranges] == 1} {
						$menu add cascade \
							-menu $m \
							-label " $text"  \
							-image $::icon::16x16::annotation($type) \
							-compound left \
							;
						set sub $m
					} else {
						set sub [menu $m.[string tolower $descr 0 0]]
						$m add cascade -menu $sub -label $text 
						bind $sub <<MenuSelect>> [namespace code { ::widget::menuItemHighlightSecond %W }]
					}

					set nags {}
					for {set nag $from} {$nag <= $to} {incr nag} {
						if {!$isStmNag($nag)} {
							set symbol [::font::mapNagToUtfSymbol $nag]
							if {$symbol ne $nag} {
								$sub add command -label $symbol -command "$cmd $type $nag"
								lappend nags $nag
							}
						}
					}

					if {[llength $ranges] == 1} {
						$sub add command -columnbreak 1 -label "($mc::None)" -command "$cmd infix 0"
						set columnbreak 0
					} else {
						set columnbreak 1
					}

					foreach nag $nags {
						$sub add command \
							-label [string toupper $Nag($nag) 0 0] \
							-command "$cmd $type $nag" \
							-columnbreak $columnbreak \
							;
						set columnbreak 0
					}
				}
			}
		}

		if {[::annotation::open?]} { set state disabled } else { set state normal }
		$menu add command \
			-label " $mc::EditAnnotation..." \
			-image $::icon::16x16::annotation(all) \
			-compound left \
			-state $state \
			-command [namespace code [list editAnnotation $position]] \
			-accel "$::mc::Key(Ctrl)-[set [namespace parent]::board::mc::Accel(edit-annotation)]" \
			;
		if {[::scidb::game::position atStart?]} {
			$menu add command \
				-label " $mc::EditPrecedingComment..." \
				-image $::fsbox::bookmarks::icon::16x16::modify \
				-compound left \
				-command [namespace code [list editComment p $position]] \
				;
		} else {
			set accel "$::mc::Key(Ctrl)-$::mc::Key(Shift)-"
			append accel "[set [namespace parent]::board::mc::Accel(edit-comment)]"
			$menu add command \
				-label " $mc::EditCommentBefore..." \
				-image $::fsbox::bookmarks::icon::16x16::modify \
				-compound left \
				-command [namespace code [list editComment a $position]] \
				-accel $accel \
				;
			$menu add command \
				-label " $mc::EditCommentAfter..." \
				-image $::fsbox::bookmarks::icon::16x16::modify \
				-compound left \
				-command [namespace code [list editComment p $position]] \
				-accel "$::mc::Key(Ctrl)-[set [namespace parent]::board::mc::Accel(edit-comment)]" \
				;
		}
		if {[::scidb::game::position atEnd?] || [::scidb::game::query length] == 0} {
			$menu add command \
				-label " $mc::EditTrailingComment..." \
				-image $::fsbox::bookmarks::icon::16x16::modify \
				-compound left \
				-command [namespace code [list editComment e $position]] \
				;
		}
		$menu add command \
			-label " $mc::EditMoveInformation..." \
			-image $::icon::16x16::clock \
			-compound left \
			-state $state \
			-command [namespace code [list EditInfo $parent $position]] \
			;
		if {[::marks::open?]} { set state disabled } else { set state normal }
		$menu add command \
			-label " $::marks::mc::MarksPalette..." \
			-image $::icon::16x16::mark \
			-compound left \
			-state $state \
			-command [namespace code [list openMarksPalette $position]] \
			-accel "$::mc::Key(Ctrl)-[set [namespace parent]::board::mc::Accel(edit-marks)]" \
			;

		$menu add separator
	}

	foreach action {undo redo} {
		set cmd [::scidb::game::query $action]
		set label [set ::mc::[string toupper $action 0 0]]
		set accel "$::mc::Key(Ctrl)-"
		if {$action eq "undo"} { append accel "Z" } else { append accel "Y" }
		if {[llength $cmd]} {
			append label " '"
			if {[string match strip:* $cmd]} { append label "$mc::Strip: " }
			append label $mc::Command($cmd) "'"
		}
		$menu add command \
			-compound left \
			-image [set ::icon::16x16::$action] \
			-label " $label" \
			-command [namespace code [list Undo $action]] \
			-state [expr {[llength $cmd] ? "normal" : "disabled"}] \
			-accelerator $accel \
			;
	}

	$menu add separator

	if {[::scidb::game::query variations?]} {
		$menu add command \
			-compound left \
			-label " $mc::CollapseVariations" \
			-image $::icon::16x16::toggleMinus \
			-command [list ::scidb::game::variation fold on] \
			;
		$menu add command \
			-compound left \
			-label " $mc::ExpandVariations" \
			-image $::icon::16x16::togglePlus \
			-command [list ::scidb::game::variation fold off] \
			;
		$menu add separator
	}

	menu $menu.display
	$menu add cascade \
		-menu $menu.display \
		-label " $mc::Display" \
		-image $::icon::16x16::paragraphSpacing \
		-compound left \
		;
	array unset state

	$menu.display add command \
		-label " $::font::mc::IncreaseFontSize" \
		-image $::icon::16x16::font(incr) \
		-compound left \
		-command [namespace code [list changeFontSize +1]] \
		-accel "$::mc::Key(Ctrl) +" \
		;
	$menu.display add command \
		-label " $::font::mc::DecreaseFontSize" \
		-image $::icon::16x16::font(decr) \
		-compound left \
		-command [namespace code [list changeFontSize -1]] \
		-accel "$::mc::Key(Ctrl) \u2212" \
		;
	$menu.display add separator

	foreach {label var} {ParLayout(column-style) style:column
								ParLayout(use-spacing) spacing:paragraph
								Display(numbering) show:varnumbers
								Display(moveinfo) show:moveinfo
								Display(nagtext) show:nagtext
								Diagrams(show) show:diagram} {
		$menu.display add checkbutton \
			-label [set ::pgn::setup::mc::$label] \
			-onvalue 1 \
			-offvalue 0 \
			-variable ::pgn::editor::Options($var) \
			-command [namespace code [list Refresh $var]] \
			;
	}

	variable _BoldTextForMainlineMoves \
		[expr {$::pgn::editor::Options(weight:mainline) eq "bold"}]
	$menu.display add checkbutton \
		-label $::pgn::setup::mc::ParLayout(mainline-bold) \
		-onvalue 1 \
		-offvalue 0 \
		-variable [namespace current]::_BoldTextForMainlineMoves \
		-command [namespace code [list Refresh weight:mainline]] \
		;

	menu $menu.display.moveStyles -tearoff no
	$menu.display add cascade -menu $menu.display.moveStyles -label $mc::MoveNotation
	foreach style $moveStyles {
		$menu.display.moveStyles add radiobutton \
			-compound left \
			-label $::notation::mc::MoveForm($style) \
			-variable ::pgn::editor::Options(style:move) \
			-value $style \
			-command [namespace code [list Refresh style:move]] \
			;
		::theme::configureRadioEntry $menu.display.moveStyles end
	}

	menu $menu.display.languages -tearoff no
	$menu.display add cascade -menu $menu.display.languages -label $mc::LanguageSelection
	$menu.display.languages add checkbutton \
		-compound left \
		-image $::country::icon::flag([::mc::countryForLang xx]) \
		-label " $::languagebox::mc::AllLanguages" \
		-variable [namespace current]::Vars(lang:active:xx) \
		-command [namespace code [list SetLanguages $Vars(position)]] \
		;
	if {[llength $Vars(lang:set)]} { ;# not the complete set?
		foreach entry [::country::makeCountryList $Vars(lang:set)] {
			lassign $entry flag name code
			$menu.display.languages add checkbutton \
				-compound left \
				-image $flag \
				-label " $name" \
				-variable [namespace current]::Vars(lang:active:$code) \
				-command [namespace code [list SetLanguages $Vars(position)]] \
				;
		}
	}

	$menu.display add separator
	
	$menu.display add command \
		-label " $::pgn::setup::mc::Configure(editor)..." \
		-image $::icon::16x16::setup \
		-compound left \
		-command [namespace code ConfigureEditor] \
		;

#	$menu add separator
#
#	$menu add command -label $CopyGameToClipboard
#	$menu add command -label "$PrintToFile..."

	tk_popup $menu {*}[winfo pointerxy $parent]
}


proc PopupHistoryMenu {parent} {
	::gamebar::popupMenu $parent no [$parent selection]
}


proc RemoveHistoryEntry {} {
	variable Vars
	::game::removeHistoryEntry [$Vars(hist) selection]
}


proc HistorySelectionChanged {} {
	variable Vars

	set selection [$Vars(hist) selection]
	if {$selection >= 0} { set state normal } else { set state disabled }
	::toolbar::childconfigure $Vars(button:remove) -state $state
}


proc PasteClipboardGame {} {
	variable Vars

	set position $Vars(position)
	::import::openEdit $Vars(frame:$position) $position game
}


proc PasteClipboardVariation {} {
	variable Vars

	set position $Vars(position)
	::import::openEdit $Vars(frame:$position) $position variation
}


proc ShowCountry {cb okbtn} {
	variable Vars

	set icon [$cb get flag]
	if {[string length $icon]} {
		$cb placeicon $icon
	}
	if {$Vars(lang:src) eq $Vars(lang:dst)} {
		set state disabled
	} else {
		set state normal
	}
	$okbtn configure -state $state
}


proc SearchLang {w code sym} {
	if {[string is alpha -strict $code]} {
		$w search code $code
	}
}


proc CopyComments {parent} {
	variable Vars

	set dlg [tk::toplevel $parent.copy_comments -class Dialog]
	set top [::ttk::frame $dlg.top]
	pack $dlg.top

	set allLang [list \
		$::country::icon::flag([::mc::countryForLang xx]) \
		$::languagebox::mc::AllLanguages \
		xx \
	]
	if {[llength $Vars(lang:set)]} {
		set langSet(src) [::country::makeCountryList $Vars(lang:set)]
	} else {
		set langSet(src) {}
	}
	set langSet(dst) [::country::makeCountryList]

	ttk::labelframe $top.src -text $::mc::From
	ttk::labelframe $top.dst -text $::mc::To

	foreach what {src dst} {
		set langSet($what) [linsert $langSet($what) 0 $allLang]
		set w $top.$what.cb
		::ttk::tcombobox $w \
			-state readonly \
			-showcolumns {flag code} \
			-height [expr {min(15, [llength $langSet($what)])}] \
			-textvariable [namespace current]::Vars(lang:$what) \
			-exportselection no \
			-format "%2" \
			;
		$w addcol image -id flag -width 20 -justify center
		$w addcol text -id code
		foreach entry $langSet($what) {
			lassign $entry flag name _
			$w listinsert [list $flag $name]
		}
		$w mapping [mc::mappingForSort] [mc::mappingToAscii]
		$w resize -force
		$w current 0
		bind $w <Any-KeyPress> [namespace code [list SearchLang $w %A %K]]
		bind $w <<ComboboxCurrent>> [namespace code [list ShowCountry $w $dlg.ok]]
		after idle [namespace code [list ShowCountry $w $dlg.ok]]
		pack $w -padx $::theme::padx -pady $::theme::pady
	}

	set Vars(strip:orig) 0
	::ttk::checkbutton $top.strip \
		-text $mc::StripOriginalComments \
		-variable [namespace current]::Vars(strip:orig) \
		;

	grid $top.src   -row 1 -column 1
	grid $top.dst   -row 1 -column 3
	grid $top.strip -row 3 -column 1 -columnspan 3 -sticky w

	grid columnconfigure $top {0 2 4} -minsize $::theme::padx
	grid rowconfigure $top {0 4} -minsize $::theme::pady
	grid rowconfigure $top {2} -minsize $::theme::padY

	::widget::dialogButtons $dlg {ok cancel} -default cancel
	$dlg.cancel configure -command [list destroy $dlg]
	$dlg.ok configure -command [namespace code [list DoCopyComments $dlg]]

	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	wm transient $dlg [winfo toplevel $parent]
	wm withdraw $dlg
	wm title $dlg $mc::Command(copy:comments)
	wm resizable $dlg false false
	::util::place $dlg center
	wm deiconify $dlg
	focus $top.src
	::ttk::grabWindow $dlg
	tkwait window $dlg
	::ttk::releaseGrab $dlg
}


proc DoCopyComments {dlg} {
	variable Vars

	set countryList [::country::makeCountryList]
	set srcCode [lindex $countryList [lsearch -exact -index 1 $countryList $Vars(lang:src)] 2]
	set dstCode [lindex $countryList [lsearch -exact -index 1 $countryList $Vars(lang:dst)] 2]
	::scidb::game::copy $srcCode $dstCode -strip $Vars(strip:orig)
	destroy $dlg
}


proc FoldVariations {flag} {
	variable Vars

	set position $Vars(position)
	if {$position == -1} { return }
	::scidb::game::variation fold $flag
	See $position $Vars(pgn:$position) $Vars(current:$position) $Vars(successor:$position)
}


proc TransposeGame {} {
	::game::flipTrialMode
	::widget::busyOperation { ::scidb::game::transpose true }
}


proc FirstVariation {{varno 0}} {
	variable Vars

	set key [::scidb::game::position key]

	if {$varno} {
		set position [::scidb::game::current]
		set Vars(current:$position) {}
		set Vars(successor:$position) {}
		::scidb::game::position forward
	} else {
		set varno [::scidb::game::variation leave]
		set parts [split $key "."]
		lset parts end-1 0
		set key [join $parts "."]
	}

	::widget::busyOperation { ::scidb::game::variation first $varno }
	::scidb::game::moveto $key
}


proc PromoteVariation {{varno 0}} {
	set key [::scidb::game::position key]

	if {$varno} {
		::scidb::game::position forward
	} else {
		set varno [::scidb::game::variation leave]
		set parts [split $key "."]
		set parts [lreplace $parts end-2 end-1]
		set key [join $parts "."]
	}

	::widget::busyOperation { ::scidb::game::variation promote $varno }
	::scidb::game::moveto $key
}


proc RemoveVariation {{varno 0}} {
	if {$varno} {
		::scidb::game::position forward
	} else {
		set varno [::scidb::game::variation leave]
	}

	::widget::busyOperation { ::scidb::game::variation remove $varno }

	if {$varno} {
		::scidb::game::position backward
		::scidb::game::moveto [::scidb::game::position key]
	} else {
		::scidb::game::moveto [::scidb::game::query parent $key]
	}
}


proc InsertMoves {parent} {
	set key [::scidb::game::position key]
	set varno  [::scidb::game::variation leave]
	::move::doDestructiveCommand \
		$parent \
		$mc::Command(variation:insert) \
		[list ::widget::busyOperation [list ::scidb::game::variation insert $varno]] \
		[list ::scidb::game::moveto [::scidb::game::query parent $key]] \
		[list ::scidb::game::moveto $key]
}


proc ExchangeMoves {parent} {
	variable Length_
	variable Key_

	set key [::scidb::game::position key]
	set varno [::scidb::game::variation leave]
	set dlg [tk::toplevel $parent.exchange -class Dialog]
	set top [::ttk::frame $dlg.top]
	pack $dlg.top
	set Length_ [::scidb::game::variation length $varno]
	::ttk::spinbox $top.sblength \
		-from [expr {$Length_ % 2 ? 1 : 2}]  \
		-to [expr {10000 + ($Length_ % 2)}] \
		-increment 2 \
		-textvariable [namespace current]::Length_ \
		-width 4 \
		-exportselection false \
		-justify right \
		;
	::validate::spinboxInt $top.sblength no
	::theme::configureSpinbox $top.sblength
	$top.sblength selection range 0 end
	$top.sblength icursor end
	::ttk::label $top.llength -text $mc::NumberOfMoves
	::widget::dialogButtons $dlg {ok cancel}
	$dlg.cancel configure -command [namespace code [list DontExchangeMoves $dlg $key]]
	$dlg.ok configure -command [namespace code [list VerifyNumberOfMoves $dlg $Length_]]

	grid $top.llength		-row 1 -column 1
	grid $top.sblength	-row 1 -column 3
	grid columnconfigure $top {0 2 4} -minsize $::theme::padding
	grid rowconfigure $top {0 2} -minsize $::theme::padding

	wm protocol $dlg WM_DELETE_WINDOW [namespace code [list DontExchangeMoves $dlg $key]]]
	wm transient $dlg [winfo toplevel $parent]
	wm withdraw $dlg
	wm title $dlg $mc::Command(variation:exchange)
	wm resizable $dlg false false
	::util::place $dlg center
	wm deiconify $dlg
	focus $top.sblength
	::ttk::grabWindow $dlg
	tkwait window $dlg
	::ttk::releaseGrab $dlg

	if {$Length_ >= 0} {
		::move::doDestructiveCommand \
			$parent \
			$mc::Command(variation:exchange) \
			[list ::widget::busyOperation [list ::scidb::game::variation exchange $varno $Length_]] \
			[list ::scidb::game::moveto [::scidb::game::query parent $key]] \
			[list ::scidb::game::moveto $key]
	}
}


proc DontExchangeMoves {dlg key} {
	variable Length_

	destroy $dlg
	set Length_ -1
	::scidb::game::moveto $key
}


proc VerifyNumberOfMoves {dlg length} {
	variable Length_

	if {$length % 2 != $Length_ % 2} {
		if {$length % 2} {
			set detail $mc::MustBeOdd
		} else {
			set detail $mc::MustBeEven
		}

		::dialog::error -parent $dlg -message [format $mc::InvalidInput $Length_] -detail $detail
		set Length_ $length
		$dlg.top.sblength selection range 0 end
		$dlg.top.sblength icursor end
		::validate::spinboxInt $dlg.top.sblength off
		focus $dlg.top.sblength
	} else {
		destroy $dlg
	}
}


proc Refresh {var} {
	variable Vars

	switch $var {
		weight:mainline {
			variable _BoldTextForMainlineMoves
			variable ::pgn::editor::Options
			set Options(weight:mainline) [expr {$_BoldTextForMainlineMoves ? "bold" : "normal"}]
		}
		show:nagtext {
			::pgn::setup::setupNags editor
		}
	}

	set Vars(current:$Vars(position)) {}
	set Vars(successor:$Vars(position)) {}

	refresh
}


proc ImportGame {parent} {
	set pos [::game::new $parent]
	if {$pos >= 0} { ::import::openEdit $parent $pos }
}


proc NewGame {} {
	variable Vars

	set parent $Vars(button:new...)
	set m $parent.newGame
	if {[winfo exists $m]} { destroy $m }
	menu $m -tearoff false
	catch { wm attributes $m -type popup_menu }
	::gamebar::addVariantsToMenu $parent $m
	tk_popdown $m $parent
}


# # NOTE: will be called from popupShuffleMenu
# proc Shuffle {variant} {
# 	variable Vars
# 
# 	set parent $Vars(button:shuffle)
# 
# 	if {[::scidb::game::query modified?]} {
# 		set reply [::dialog::question -parent $parent -message $::gamebar::mc::DiscardNewGame]
# 		if {$reply eq "no"} { return }
# 	}
# 
# 	set oldIdn [::scidb::game::query idn]
# 	set newIdn [::setup::shuffle $variant]
# 	while {$oldIdn == $newIdn} { set newIdn [::setup:shuffle $variant] }
# 	::scidb::game::clear $newIdn
# 	::scidb::game::modified $Vars(position) no
# }
# 
# 
# proc ShufflePosition {} {
# 	variable Vars
# 	::setup::popupShuffleMenu [namespace current] $Vars(button:shuffle)
# }


proc LanguageChanged {} {
	variable Vars 

	foreach position [::game::usedPositions?] {
		if {[::scidb::game::query $position length] == 0} {
			::scidb::game::refresh $position
		} else {
			set w $Vars(pgn:$position)
			$w configure -state normal
			UpdateHeader $position $w $Vars(header:$position)
			$w configure -state disabled
		}
	}

	::toolbar::childconfigure $Vars(button:new) \
		-tooltip "$::gamebar::mc::GameNew ($::mc::VariantName(Normal))"
}


namespace eval cursor {

switch [tk windowingsystem] {
	variable collapse
	variable expand

	x11 {
		if {[::xcursor::supported?]} {
			set file1 [file join $::scidb::dir::share cursor collapse-16x16.xcur]
			set file2 [file join $::scidb::dir::share cursor expand-16x16.xcur]
			if {[file readable $file1] && [file readable $file2]} {
				catch {
					set collapse [::xcursor::loadCursor $file1]
					set expand [::xcursor::loadCursor $file2]
				}
			} else {
				::log::info PGN-Editor [format $mc::CannotOpenCursorFiles "$file1 $file2"]
			}
		}
	}

	win32 - aqua {
		if {[tk windowingsystem] eq "win32"} { set ext cur } else { set ext crsr }
		# IMPORTANT NOTE:
		# under windows the cursor wil be displayed with size 32x32
		# (source: http://wiki.tcl.tk/8674)
		# but probably this information is not up-to-date
		set file1 [file join $::scidb::dir::share cursor collapse-16x16.$ext]
		set file2 [file join $::scidb::dir::share cursor expand-16x16.$ext]
		if {[file readable $file1] && [file readable $file2]} {
			set collapse [list @$file1]
			set expand [list @$file2]
		} else {
			::log::info PGN-Editor [format $mc::CannotOpenCursorFiles "$file1 $file2"]
		}
	}
}

} ;# namespace cursor

namespace eval icon {
namespace eval 12x12 {

set expand [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAMAAABhq6zVAAABL1BMVEUAAAAFEwAPXgA2eABV
	lwBXlQBqpCSHtCYAAAAAAAArbQA4dgAULQBEhABHhg1JhwBTjRUwXQA4ZAAxWgA/bwBRiwBc
	kxM5ZwBOgwJfmgiDsj5flwhsoBpnnwuJtzxflglimQponRFsow2cxVRgkwtsoA9+sB+cxkx0
	pxJ9rxeIuBqmzkKIuxyMvRyNvRySvx++31uSvzWVzgOWwx6WxQCWxwOWzwCXxRyXxwCXyACY
	xgCYyRuY0gGZyRuZywWZyx2ayRyaywWa0wOa1QWbzRyb0AmcyQiczRyc0gedx0Wdywyd1Q6e
	ywyf0BegziGg0BehyxOhzxGiyxujzRWl0Sem0S6o0jOv0kCv1i223VK63ky94GfA42ng7rjg
	8bvm8sjq9M/s9tX6/PT9/vv////Gb6PpAAAAMXRSTlMAAAAAAAAAAAEEEREcHh4lJStOU1Zb
	W3B6iYmlpa2tsre3u7u80ODg5e709Pv7+/z85zOZ6QAAAAFiS0dEZMLauAkAAACVSURBVAgd
	BcFLDoIwEADQaTuligUiwbBxo0sTL+D9z+ABXOAnSOQjbWmd+h7jUuns+PiOkyUh06o8i7xe
	MHihthd1q7ApY/CoM9OyBPxYG4vJ6bnnHA70znqUrtCcgSYfJNIgHU9goZmiWPOiee3itd+0
	AzoT9UKQJsE6AeTT/DNpd+9mdIyCFPDznXEMYIUKIbhg4Q/3gUdcn5n7ugAAAABJRU5ErkJg
	gg==
}]

# set collapse [image create photo -data {
# 	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABmJLR0QA/wD/AP+gvaeTAAAA
# 	CXBIWXMAAABIAAAASABGyWs+AAAB7UlEQVQoz1WQvWsTYQCHn/feu9zl0qSXi59E6wetBbU4
# 	itTFqTSCk1D8F3TwHxBH3QUdHOzg5FhXRVFBWkFQaMQ2Hayp1djmq7nk7s3l7nVoF4ff+PB7
# 	eMRCGW7NT/J1rTExMz1z55CTXxBKnYp6XTrd3c1G9++LHaUee/BzS4JYvHmGRndv6srM7JOy
# 	zlzrf6/KQatJmqaQseg7MtlSnbdbYXB73KQmjyWd4tXzlx6dHsnrjQ9vjN7vbUaqT6IGJL2A
# 	TDQ0CuP+2aEYlTfC+JUxfcKvHMWaa335RDzoIyUYAgzAMCBVEZl2m+NOYe6wScXMm3ZFtJu5
# 	OApwz00hsi460QAIKdDhgLj+g3wqcmOWXTETFfqptrB8n8kHz7FPTaKT9AAwUJsbbNy9AUJj
# 	CMM3lYriWLqYgz3+LD5Eej6agwcESaeFHuyhC0USrWOzGQ6XA1fPl7Q2e6+X0IAW7AMaBCCz
# 	Nh3BqBkOl41akC7Vo3418UqYjsQ0+X+2JCmWqEf9ai1Il+Rqi92JMdXK2ubseMHLZ4RGGiBN
# 	iXCyKK9ETYXbn3e7956t8076OXi/zZpnR+uxkRxJHLeo3LwVOG7aEEb3W9D7uLLTu/90jZd+
# 	jvTAdl/5gk/5osflMYuTAEFMfbXNSrXNL9gv8Q+fYd/xb8HXjAAAAABJRU5ErkJggg==
# }]

} ;# namespace 12x12

} ;# namespace icon
} ;# namespace pgn
} ;# namespace application

namespace eval pgn {
namespace eval editor {

proc refresh {regardFontSize}		{ ::application::pgn::refresh $regardFontSize }
proc resetGoto {w position}		{ ::application::pgn::resetGoto $w $position }
proc doLayout {position data w}	{ ::application::pgn::DoLayout $position $data $w }

} ;# editor
} ;# pgn

# vi:set ts=3 sw=3:
