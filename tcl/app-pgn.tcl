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
set Command(variation:remove:n)	"Delete Variations"
set Command(variation:mainline)	"New Mainline"
set Command(variation:insert)		"Insert Moves"
set Command(variation:exchange)	"Exchange Moves"
set Command(strip:moves)			"Moves from the beginning"
set Command(strip:truncate)		"Moves to the end"
set Command(strip:annotations)	"Annotations"
set Command(strip:moveinfo)		"Move Information"
set Command(strip:marks)			"Marks"
set Command(strip:comments)		"Comments"
set Command(strip:language)		"Language"
set Command(strip:variations)		"Variations"
set Command(copy:comments)			"Copy Comments"
set Command(move:comments)			"Move Comments"
set Command(game:clear)				"Clear Game"
set Command(game:merge)				"Merge Game"
set Command(game:transpose)		"Transpose Game"

set LanguageSelection				"Language Selection"
set MoveInfoSelection				"Move Info Selection"
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
set InsertDiagram						"Insert Diagram"
set InsertDiagramFromBlack			"Insert Diagram from Black's Perspective"
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

set MoveInfo(eval)					"Evaluation"
set MoveInfo(clk)						"Players Clock"
set MoveInfo(emt)						"Elapsed Time"
set MoveInfo(ccsnt)					"Correspondence Chess Sent"
set MoveInfo(video)					"Video Time"

} ;# namespace mc

variable Vars
variable CharLimit 250
variable CursorCounter 0
variable EmoticonCounter 0

array set MoveInfoPGN {
	eval	"%eval"
	clk	"%clk, %ct"
	emt	"%emt, %egt"
	ccsnt	"%ccsnt"
	video	"%video"
}


proc build {parent width height} {
	variable Vars

	set top   [::tk::frame $parent.top -borderwidth 0 -background white]
	set main  [::tk::multiwindow $top.main -borderwidth 0 -background white]
	set games [::tk::multiwindow $main.games -borderwidth 0 -background white]
	set logo  [::tk::frame $main.logo -borderwidth 0 -background white -cursor left_ptr]
	set hist  [::game::history $main.hist -cursor left_ptr]

	# TODO: we need key bindings of board

	pack $top -fill both -expand yes
	pack $main -fill both -expand yes

	$main add $hist $logo $games
	$hist bind <Button-3> [namespace code [list PopupHistoryMenu $hist]]
	$hist bind <Double-3> {#} ;# catch double clicks
	bind $hist <<GameHistorySelection>> [namespace code HistorySelectionChanged]

	# logo pane --------------------------------------------------------------------------------
	$main paneconfigure $logo -sticky ""

	tk::label $logo.icon -image $::icon::64x64::logo -background white
	tk::label $logo.logo \
		-text "Scidb" \
		-foreground steelblue4 \
		-font [list {Final Frontier} 26] \
		-background white \
		;
	grid $logo.icon -row 1 -column 1
	grid $logo.logo -row 2 -column 1

	# games pane -------------------------------------------------------------------------------
	set edit [::tk::frame $games.edit -borderwidth 0]
	pack $edit -expand yes -fill both
	bind $edit <Configure> [namespace code { Configure %h }]
	set panes [::tk::multiwindow $edit.panes -borderwidth 0 -background white -overlay yes]
	set gamebar [::gamebar::gamebar $edit.gamebar]

	grid $gamebar -row 1 -column 1 -sticky nsew
	grid $panes   -row 2 -column 1 -sticky nsew

	::gamebar::addReceiver $gamebar [namespace code GameBarEvent]

	set popupcmd [namespace code [list ::gamebar::popupMenu $gamebar $top no]]
	bind $main <Button-3> $popupcmd
	bind $main <Double-3> {#} ;# catch double clicks
	bind $logo <Button-3> $popupcmd
	bind $logo <Double-3> {#} ;# catch double clicks
	bind $games <Button-3> [list ::gamebar::popupMenu $gamebar $top]
	bind $games <Double-3> {#} ;# catch double clicks
	foreach child [winfo children $logo] {
		bind $child <Button-3> $popupcmd
		bind $child <Double-3> ;# catch double clicks
	}

	set Vars(frame) $edit
	set Vars(delta) 0
	set Vars(after) {}
	set Vars(index) -1
	set Vars(position) -1
	set Vars(break) 0
	set Vars(height) 0

	for {set i 0} {$i < 9} {incr i} {
		set pgn [::pgn::setup::buildText $edit.f$i editor]
		$pgn mark set insert begin left ;# fix the position of this mark
		bind $pgn <Button-3> [namespace code [list PopupMenu $edit $i]]
		bind $pgn <Double-3> {#} ;# catch double clicks
		bind $pgn <Leave> [namespace code [list HidePosition $pgn]]
		$panes add $edit.f$i
		set Vars(pgn:$i) $pgn
		set Vars(frame:$i) $edit.f$i
	}

	set Vars(main) $main
	set Vars(hist) $hist
	set Vars(gamebar) $gamebar
	set Vars(games) $games
	set Vars(logo) $logo
	set Vars(panes) $panes
	set Vars(charwidth) [font measure [$Vars(pgn:0) cget -font] "0"]
	set Vars(diagram:show) 0
	set Vars(diagram:state) 0
	set Vars(diagram:caps) 0

	## The following does not work, because it may happen that we have the following
	## succeeding actions:
	##		action {remove 1 m-0.22.0.77.0.76 m-0.23}
	##		action {replace 1 m-0.22.0.78 m-0.23}
	## So we have to retain the marks.
	# set Vars(deletemarks) -marks

	::pgn::setup::setupStyle editor {0 1 2 3 4 5 6 7 8}
	::scidb::game::undoSetup 200 1

	set tbGame [::toolbar::toolbar $top \
		-id editor-game \
		-hide 1 \
		-side bottom \
		-tooltipvar ::mc::Game \
	]
	set Vars(button:new) [::toolbar::add $tbGame dropdownbutton \
		-image $::icon::toolbarDocumentNew \
		-tooltip "$::gamebar::mc::GameNew ($::mc::VariantName(Normal))" \
		-arrowttipvar ::gamebar::mc::GameNew \
		-command [list ::menu::gameNew $tbGame] \
		-menucmd ::gamebar::addVariantsToMenu \
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
		-command [namespace code [list importGame $Vars(main)]] \
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

	[namespace parent]::board::needBinding $main
	[namespace parent]::board::bindKeys

	::scidb::db::subscribe gameSwitch [namespace current]::GameSwitched
	::pgn::setup::setupNags editor
	InitScratchGame
	Raise history
}


proc languages {} {
	variable Vars

	set langSet {}
	foreach key [array names Vars lang:active:*] {
		if {$Vars($key)} {
			set lang [lindex [split $key :] 2]
			if {$lang eq "xx"} { set lang "" }
			lappend langSet $lang
		}
	}

	return $langSet
}


proc refresh {{regardFontSize no}} {
	variable Vars

	::widget::busyCursor on

	for {set i 0} {$i < 9} {incr i} {
		::pgn::setup::setupStyle editor $i
		::pgn::setup::configureText $Vars(frame:$i)
		::scidb::game::refresh $i
	}

	set Vars(charwidth) [font measure [$Vars(pgn:0) cget -font] "0"]

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


proc add {position base variant tags {at -1}} {
	variable Vars

	if {$at >= 0} {
		::gamebar::insert $Vars(gamebar) $at $position $tags
	} else {
		::gamebar::add $Vars(gamebar) $position $tags
	}
	ResetGame $Vars(pgn:$position) $position $tags
	::scidb::game::switch $position
}


proc replace {position base variant tags} {
	variable Vars

	::gamebar::replace $Vars(gamebar) $position $tags
	ResetGame $Vars(pgn:$position) $position $tags
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

	if {![info exists Vars(current:$position)]} {
		return
	}

	$w tag remove h:next begin end
	$w tag remove h:curr begin end

	set Vars(current:$position) {}
	set Vars(previous:$position) {}
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


proc selected {} {
	return [::gamebar::selected  [set [namespace current]::Vars(gamebar)]]
}


proc lock {position} {
	return [::gamebar::lock [set [namespace current]::Vars(gamebar)] $position]
}


proc unlock {position} {
	return [::gamebar::unlock [set [namespace current]::Vars(gamebar)] $position]
}


proc unlocked? {position} {
	return [::gamebar::unlocked? [set [namespace current]::Vars(gamebar)] $position]
}


proc freeze {position {tooltipvar ""}} {
	return [::gamebar::setFrozen [set [namespace current]::Vars(gamebar)] $position 1 $tooltipvar]
}


proc unfreeze {position} {
	return [::gamebar::setFrozen [set [namespace current]::Vars(gamebar)] $position 0]
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


proc fontSizeChanged {} {
	refresh
	SetAlignment
	UpdateScrollbar
}


proc importGame {parent} {
	set pos [::game::replace $parent]
	if {$pos >= 0} { ::import::openEdit $parent $pos }
}


proc saveGame {mode {base ""}} {
	variable ::scidb::scratchbaseName
	variable Vars

	set position [::scidb::game::current]
	set parent $Vars(main)
	lassign [::scidb::game::link? $position] myBase variant index
	set number [expr {$index + 1}]
	if {$mode ne "add" && ![::game::verify $parent $position $number]} { return }

	if {[string length $base] == 0} {
		set base $myBase
	}
	if {$base eq $scratchbaseName} {
		set base [::scidb::db::get name]
	}

	if {[::scidb::db::get readonly? $base $variant]} { return }
	if {$variant ni [::scidb::db::get variants $base]} { return }

	switch $mode {
		add		{ ::dialog::save::open $parent $base $variant $position }
		replace	{ ::dialog::save::open $parent $base $variant $position $number }
		moves		{ replaceMoves $parent $base $variant $position $number }
	}
}


proc FindKey {w attr} {
	if {[catch { set key [$w mark previous m:$attr.current.last {m-*}] }]} {
		set cx [expr {[winfo pointerx $w] - [winfo rootx $w]}]
		set cy [expr {[winfo pointery $w] - [winfo rooty $w]}]
		$w mark set current [$w index @$cx,$cy]
		set key [$w mark previous m:$attr.current.last {m-*}]
		puts stderr "Couldn't find tag m:$attr near $key ([$w index current])"
	}
	return $key
}


proc FindRange {w key} {
	if {$key eq "m-0.0"} { return {end end} }
	return [$w tag nextrange m:move $key]
}


proc EditAnnotation {{attr {}}} {
	variable Vars

	set position $Vars(position)
	if {[llength $attr]} {
		GotoMove $position [FindKey $Vars(pgn:$position) $attr]
	}
	Edit $position ::annotation
}


proc editAnnotation {} {
	if {[::annotation::open?]} {
		::annotation::close
	} else {
		EditAnnotation
	}
}


proc editComment {pos {position -1} {key {}} {lang {}}} {
	variable Vars

	if {$position == -1} { set position $Vars(position) }

	if {[::scidb::game::position $position atStart?]} {
		switch $pos {
			after		{ return }
			before	{ set pos preceding }
		}
	}

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
	variable Vars
	::widget::textLineScroll $Vars(pgn:[::scidb::game::current]) scroll {*}$args
}


proc flipTrialMode {} {
	variable Vars

	set Vars(current:[::scidb::game::current]) ""
	::game::flipTrialMode
}


proc undo {} { Undo undo }
proc redo {} { Undo redo }


proc undoLastMove {} {
	set cmd [::scidb::game::query undo]
	if {$cmd eq "move:append" || $cmd eq "move:nappend"} { Undo undo }
}


proc replaceMoves {parent base variant position number} {
	if {![::dialog::save::checkIfWriteable $parent $base $variant $position $number]} { return }

	if {[::scidb::game::query modified?]} {
		set reply [::dialog::question -parent $parent -message $mc::ReallyReplaceMoves]
		if {$reply eq "yes"} { ::util::catchException { ::scidb::game::update moves } }
	} else {
		::dialog::info -parent $parent -message $mc::CurrentGameIsNotModified
	}
}


proc showDiagram {w keysym state} {
	variable ::util::shiftMask
	variable ::util::lockMask
	variable Vars

	if {$Vars(diagram:show)} { return }
	set position $Vars(position)
	if {$position < 0 || 9 <= $position} { return }
	set key $Vars(active:$position)
	if {[llength $key] == 0} { return }

	bind $w <Alt-KeyPress>		[namespace code [list CheckKey $w press %K %s]]
	bind $w <Alt-KeyRelease>	[namespace code [list CheckKey $w release %K %s]]

	set Vars(diagram:show) 1
	set Vars(diagram:state) $state
	set Vars(diagram:caps) [expr {$state & $lockMask}]
	set w $Vars(pgn:$position)
	set mask [expr {$shiftMask|$lockMask}]
	if {($state & $mask) == $mask} { set state 0 }
	::browser::showPosition $w $position [[namespace parent]::board::rotated?] $key $state
}


proc ensureScratchGame {} {
	variable ::scidb::scratchbaseName
	variable Vars

	if {![::gamebar::empty? $Vars(gamebar)]} { return 0 }

	::scidb::game::switch 9
	set fen [::scidb::pos::fen]
	::scidb::game::new 0
	::scidb::game::switch 0
	::scidb::pos::setup $fen
	set tags [::scidb::game::tags 0]
	::game::setFirst $scratchbaseName Normal $tags utf-8
	add 0 $scratchbaseName Normal $tags
	select 0
	return 1
}


proc CheckKey {w mode keysym state} {
	variable ::util::shiftMask
	variable ::util::lockMask
	variable Vars

	if {!$Vars(diagram:show)} { return }
	set position $Vars(position)
	if {$position < 0 || 9 <= $position} { return }

	if {$mode eq "release" && ($keysym == "Alt_L" || $keysym == "ISO_Level3_Shift")} {
		bind $w <Alt-KeyPress> {#}
		bind $w <Alt-KeyRelease> {#}
		HidePosition $Vars(pgn:$position)
	} elseif {[string match Shift_? $keysym] || ($keysym eq "Caps_Lock" && $mode eq "press")} {
		set key $Vars(active:$position)
		set w $Vars(pgn:$position)
		if {$keysym ne "Caps_Lock"} {
			set mask $shiftMask
		} else {
			set mask $lockMask
			if {$Vars(diagram:caps)} { set mode "release" }
		}
		if {$mode eq "press"} {
			set state [expr {$state | $mask}]
		} else {
			set state [expr {$state & ~$mask}]
		}
		set Vars(diagram:caps) [expr {$state & $lockMask}]
		::browser::updatePosition $w $position [[namespace parent]::board::rotated?] $key $state
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
	::scidb::game::langSet 9 [languages]
	::scidb::game::switch 9

	set Vars(current:9) {}
	set Vars(successor:9) {}
	set Vars(previous:9) {}
	set Vars(active:9) {}
	set Vars(see:9) 1
	set Vars(last:9) {}
	set Vars(tags:9) {}

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


proc See {position {key ""} {succKey ""}} {
	variable Vars
	variable CharLimit

	if {!$Vars(see:$position)} { return }

	if {[string length $key] == 0} {
		set key $Vars(current:$position)

 		if {[string length $succKey] == 0} {
 			set succKey $Vars(successor:$position)
 		}
	}

	if {[string length $key] == 0} { return }

	set w $Vars(pgn:$position)

	if {$key eq [::scidb::game::position startKey]} {
		$w see begin 
		return
	}

	# TODO experimental
#	if {[string length $succKey]} {
#		$w see $succKey
#	}
# TODO: rework the whole logic, it is jumping too much

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
			incr count [$w count -chars $r.begin $r.end]
			if {$count > $CharLimit} {
				incr r -1
				break
			}
		}
		if {$r > $row} { $w see $r.begin }
		if {$rest < $CharLimit} {
			set offs [expr {[winfo width $w]/$Vars(charwidth)}]
			$w see $row.[expr {$col + min($CharLimit, 3*$offs)}]
		}
		$w see $row.$col
	} else {
		$w see $key
	}
	::pgn::setup::adjustLinePosition $w
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
		See $position
	}
}


proc GameBarEvent {action position} {
	variable Vars
	variable ::pgn::editor::Colors

	switch $action {
		removed {
			::game::release $position
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
	if {$position <= 10} {
		after idle [list ::scidb::game::langSet $position [languages]]
	}
}


proc AddLanguageButton {lang} {
	variable Vars

	if {$lang eq "xx" || [string length $lang] == 0} { return }
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


proc UpdateLanguages {position languageSet} {
	variable Vars

	if {$position >= 9} { return }

	if {"" in $languageSet} {
		set languageSet [lremove $languageSet ""]
		set languageSet [linsert $languageSet 0 "xx"]
	}

	if {$Vars(lang:set) eq $languageSet} {
		set Vars(lang:set:$position) $Vars(lang:set)
		return
	}

	if {[llength $Vars(lang:set:$position)]} {
		foreach lang $languageSet {
			if {$lang ni $Vars(lang:set:$position)} {
				set Vars(lang:active:$lang) 1
			}
		}
		SetLanguages $position
	}

	set Vars(lang:set) $languageSet
	set Vars(lang:set:$position) $languageSet
	set langButtons [array names Vars lang:button:*]
	
	foreach button $langButtons {
		::toolbar::forget $Vars($button)
		unset Vars($button)
	}

	foreach lang $languageSet {
		AddLanguageButton $lang
	}
}


proc GameSwitched {position} {
	variable Vars

	if {[info exists Vars(lang:set:$position)]} {
		UpdateLanguages $position $Vars(lang:set:$position)
	}
	if {[info exists Vars(successor:$position)]} {
		ProcessGoto $position [::scidb::game::position key] $Vars(successor:$position)
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


proc ConfigureEditor {} {
	variable Vars

	set position $Vars(position)
	::scidb::tree::freeze 1
	::scidb::game::new 10
	set Vars(current:10) {}
	set Vars(successor:10) {}
	set Vars(previous:10) {}
	set Vars(active:10) {}
	set Vars(lang:set:10) [list {} $::mc::langID]
	set Vars(see:10) 1
	set Vars(dirty:10) 0
	set Vars(comment:10) ""
	set Vars(last:10) {}
	set Vars(virgin:10) 1
	set Vars(result:10) ""
	set Vars(header:10) ""
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

	set Vars(current:$position) ""
	ProcessGoto $position [::scidb::game::position key] $Vars(successor:$position)
}


proc Dump {w type attr pos} {
	switch $type {
		text {
			if {[string index $attr end] eq "\n"} {
				set attr [string replace $attr end-1 end "\\n"]
			}
		}
		mark {
			if {$attr eq "insert" || [string match {#ID#*} $attr]} { return }
			set attr "${attr} ([$w mark gravity $attr])"
		}
	}
	puts "$pos: $type $attr"
}


proc DoLayout {position content {context editor} {w {}}} {
	variable ::pgn::${context}::Options
	variable Vars
	global env

	if {[llength $w] == 0} { set w $Vars(pgn:$position) }

	if {[llength $content] > 1} {
		if {[info exists env(SCIDB_PGN_CLOCK)]} {
			set clock0 [clock milliseconds]
		}
	}

	if {[info exists env(SCIDB_PGN_TRACE)]} {
		puts "============================================================="
		set trace 1
	} else {
		set trace 0
	}

	foreach node $content {
		if {$trace} { puts $node }

		switch [lindex $node 0] {
			start     { # no action }
			languages { UpdateLanguages $position [lindex $node 1] }
			header    { UpdateHeader $context $position $w [lindex $node 1] }

			begin {
				set level [lindex $node 3]
				if {$level == 0} {
					$w mark set main:start cur left
				} elseif {$level == 1 && [$w mark exists main:start]} {
					$w tag add main main:start cur
				}
				set startVar($level) [lindex $node 2]
			}

			end {
				if {$level == 1} {
					$w mark set main:start cur left
				} elseif {$level == 0 && [$w mark exists main:start]} {
					$w tag add main main:start cur
				}
				set level [lindex $node 3]
				Indent $context $w $level $startVar($level) cur
				incr level -1
			}

			action {
				set Vars(dirty:$position) 1
				set args [lindex $node 1]

				switch [lindex $args 0] {
					replace {
						lassign $args unused level removePos insertMark
						$w delete $removePos $insertMark
						$w mark gravity $insertMark right
						$w mark set indent:start $removePos left
						$w mark set cur $insertMark
						if {$level == 0} { $w mark set main:start cur left }
					}

					insert {
						lassign $args unused level insertMark
						$w mark gravity $insertMark right
						$w mark set indent:start $insertMark left
						$w mark set cur $insertMark
						if {$level == 0} { $w mark set main:start cur left }
					}

					finish {
						set level [lindex $args 1]
						if {$level == 0} { $w tag add main main:start cur }
						Indent $context $w $level indent:start cur
					}

					remove {
						$w delete {*}[lrange $args 2 end]
					}

					clear {
 						$w delete m-start m-0 ;# TODO use option -marks?
						set Vars(result:$position) ""
					}

					marks	{ [namespace parent]::board::updateMarks [::scidb::game::query marks] }
					goto	{ ProcessGoto $position [lindex $args 1] [lindex $args 2] }
				}
			}

			move {
				set key  [lindex $node 1]
				set data [lindex $node 2]

				$w mark set $key cur left
				InsertMove $context $position $w $level $key $data
				set Vars(last:$position) $key
			}

			diagram {
				set key  [lindex $node 1]
				set data [lindex $node 2]

				$w mark set $key cur left
				InsertDiagram $context $position $w $level $key $data
			}

			result {
				if {$Options(show:result)} {
					set reason [::scidb::game::query $position termination]
					set resultList [list {*}[lrange $node 1 end] $reason $Options(spacing:paragraph)]
					set stm [lindex $node 2]

					if {$Vars(result:$position) != $resultList} {
						set last $Vars(last:$position)
						if {[string length $last]} { $w mark gravity $last left }
						$w mark gravity m-0 left
						$w mark set cur m-0
						$w delete cur end
						set variant [::scidb::game::query $position variant]
						set result [::browser::makeResult {*}[lrange $resultList 0 end-1] $variant]
						if {[llength $result]} {
							lassign $result result reason
							$w insert cur [expr {$Options(spacing:paragraph) ? "\n\n" : "\n"}]
							set space ""
							if {[string length $result]} {
								set space " "
								$w insert cur $result result
							}
							if {[string length $reason]} {
								$w insert cur "${space}($reason)"
							}
						}
						$w mark gravity m-0 right
						if {[string length $last]} { $w mark gravity $last right }
						set Vars(result:$position) $resultList
					}
					$w mark gravity m-0 right
					$w mark set cur m-0
					set Vars(lastrow:$position) [$w lineno end]
				} elseif {[$w get cur-1c] eq "\n"} {
					$w delete cur-1c end
				}

				# delete all the temporary marks
				$w mark unset indent:start main:start cur:start my:start cur
			}

			merge {
				$w tag remove h:merge begin end
				set ranges {}
				foreach {start end} [lindex $node 1] {
					set ismove [expr {$start == $end}]

					if {$ismove} {
						set end [::scidb::game::query $position nextKey? $end]
					}

					set start [$w index $start]
					set end [$w index $end]

					if {[$w compare "$start linestart" != begin]} {
						while {[$w compare $start < $end] && [string is space [$w get $start]]} {
							set start [$w index $start+1c]
						}
					}
					while {[$w compare $end > $start] && [$w get $end-1c] eq " "} {
						set end [$w index $end-1c]
					}

					if {!$ismove} {
						lassign [scan $end "%u.%u"] line col
						set end [expr {$line + 1}].begin
					}

					lappend ranges $start $end
				}
				$w tag add merge {*}$ranges
			}
		}
	}

	after idle [namespace code UpdateButtons]

	if {[llength $content] > 1} {
		if {[info exists env(SCIDB_PGN_DUMP)]} {
			puts "==============================================="
			# puts [$w dump -all -command [namespace code [list Dump $w]] begin end]
			puts [$w dump -text -mark -command [namespace code [list Dump $w]] begin end]
			puts "==============================================="
		}
		if {[info exists env(SCIDB_PGN_INSPECT)]} {
			puts "==============================================="
			#foreach item [$w inspect -mark -tag -text] { puts "{$item}" }
			foreach item [$w inspect -all -bindings] { puts "{$item}" }
			puts "==============================================="
		}
		if {[info exists env(SCIDB_PGN_CLOCK)]} {
			set clock1 [clock milliseconds]
			puts "clock: [expr {$clock1 - $clock0}]"
		}
	}
}


proc Indent {context w level from to} {
	variable ::pgn::${context}::Options

	if {$level > 0 && (!$Options(style:column) || [incr level -1] > 0)} {
		set level [expr {min($level, $Options(indent:max))}]
		$w tag add indent$level $from $to
		$w tag add variation $from $to
	}
}


proc ProcessGoto {position key succKey} {
	variable Vars

	if {[llength $Vars(tags:$position)] == 0} { return }

	::move::reset
	after cancel $Vars(after:$position)
	set Vars(after:$position) {}
	set w $Vars(pgn:$position)

	if {$Vars(current:$position) ne $key} {
		::scidb::game::variation unfold
		$w tag remove h:next begin end
		$w tag remove h:curr begin end
		$w tag remove h:move begin end
		$w tag add h:curr {*}[FindRange $w $key]
		if {$Vars(active:$position) eq $key} { $w configure -cursor {} }
		set Vars(current:$position) $key
		set Vars(successor:$position) $succKey
		if {[llength $Vars(previous:$position)]} {
			See $position $key $succKey
			if {$Vars(active:$position) eq $Vars(previous:$position)} {
				EnterMove $w $Vars(previous:$position)
			}
		}
		set Vars(previous:$position) $key
		if {[llength [set nextKeys [::scidb::game::next keys $position]]] > 1} {
			foreach k [::scidb::game::next keys $position] {
				$w tag add h:next {*}[FindRange $w $k]
			}
		}
		[namespace parent]::board::updateMarks [::scidb::game::query marks]
		if {$position < 9} { ::annotation::update $key }
	} elseif {$Vars(dirty:$position)} {
		set Vars(dirty:$position) 0
		See $position $key $succKey
	}
}


proc UpdateHeader {context position w data} {
	variable ::pgn::${context}::Options
	variable Vars

	if {!$Vars(virgin:$position)} {
		$w delete begin m-start
	}

	$w mark set cur begin

	if {$Options(show:opening) || $position < 9} {
		set idn 0
		set opening {}
		set pos {}
		set eco ""

		foreach entry $data {
			set value [lrange $entry 1 end]
			switch [lindex $entry 0] {
				idn		{ set idn $value }
				eco		{ set eco $value }
				position { set pos $value }
				opening	{ set opg $value }
			}
		}

		set variant [::scidb::game::query $position variant?]
		set newline ""

		switch $variant {
			Normal {
				# no action
			}
			Suicide - Giveaway - Losers {
				set newline \n
				$w insert cur "$::mc::VariantName(Antichess) - $::mc::VariantName($variant)" opening
			}
			default {
				set newline \n
				$w insert cur $::mc::VariantName($variant) opening
			}
		}

		foreach line [::browser::makeOpeningLines [list $idn $pos $eco $opg]] {
			set tag {}
			lassign $line content tag
			if {$tag eq "figurine"} { set tag figurineb } else { lappend tag opening }
			$w insert cur ${newline}${content} $tag
			set newline ""
		}

		$w insert cur "\n"
	} else {
		while {![$w isempty] && [$w get begin] == "\n"} {
			$w delete begin
		}
	}

	$w mark set m-start cur
	$w mark gravity m-start left

	if {$Vars(virgin:$position)} {
		$w mark set m-0 cur right
		$w mark set cur m-0
	}

	set Vars(virgin:$position) 0
	set Vars(header:$position) $data
}


proc InsertMove {context position w level key data} {
	variable ::pgn::editor::Options
	variable Vars

	set havePly 0
	set prefixAnnotation {}
	set suffixAnnotation {}
	set textualAnnotation {}

	foreach node $data {
		switch [lindex $node 0] {
			break {
				set lvl [lindex $node 1]
				if {$lvl <= $Options(indent:max)} {
					set space "\n"
				} elseif {$lvl + 1 == $Options(indent:max)} {
					set space [expr {$Options(style:column) ? "\n" : " "}]
				} elseif {	$Options(indent:max) == 0
							&& ($Options(style:column) || ($lvl == 1 && $Options(spacing:paragraph)))} {
					set space "\n"
				} else {
					set space " "
				}
				$w insert cur $space
			}

			space {
				lassign $node _ space count number
				set tag {}
				switch $space {
					")" {
						if {$level != 1 || !$Options(spacing:paragraph)} {
							$w insert cur "\u00a0)" m:bracket
						}
					}

					"e" {
						if {$Options(show:opening) || $position < 9} {
							$w insert cur "\n"
							$w insert cur "<$mc::EmptyGame>" empty
						}
					}

					"s" {
						if {[$w compare cur != begin]} {
							$w insert cur "\n"
						}
					}

					" " { $w insert cur " " }

					"]" {
						if {$count == $number && $level > $Options(indent:max)} {
							$w insert cur "]" m:bracket
						}
					}

					"+" - "*" {
						$w insert cur " "
						if {[::font::truetypeSupport?]} {
							$w insert cur "+" {m:expand circled}
						} else {
							set img [$w image create cur \
								-align center \
								-image $icon::12x12::expand \
								-tags m:expand \
							]
						}
						if {$space eq "*" && ($level != 1 || !$Options(spacing:paragraph))} {
							$w insert cur "\u00a0)" m:bracket
						}
					}

					default {
						variable cursor::collapse

						if {[info exists collapse]} {
							if {$space eq "\["} {
								if {$count == $number && $level > $Options(indent:max)} {
									$w insert cur "\[" {m:bracket m:fold}
								}
								# TODO "-"
								if {$number ne "-"} { set txt "($number)" } else { set txt "\u2022" }
								$w insert cur "$txt " {m:fold m:numbering}
							} elseif {$level != 1 || !$Options(spacing:paragraph)} {
								$w insert cur "(\u00a0" {m:fold m:bracket}
							} else {
								set txt [format "(%c) " [expr {96 + $number}]]
								$w insert cur $txt {m:fold m:numbering}
							}
						} elseif {$space eq "\["} {
							if {$count == $number && $level > $Options(indent:max)} {
								$w insert cur "\[" m:bracket
							}
							# TODO "-"
							if {$number ne "-"} { set number "($number)" } else { set number "\u2022" }
							$w insert cur "$number " m:numbering
						} else {
							$w insert cur "(\u00a0" m:bracket
						}
					}
				}
			}

			ply {
				PrintMove $context $position $w $level $key [lindex $node 1] $prefixAnnotation
				if {[llength $suffixAnnotation]} {
					PrintNumericalAnnotation $context $position $w $level $key $suffixAnnotation 0 1
					set suffixAnnotation {}
				}
				if {[llength $textualAnnotation]} {
					PrintTextualAnnotation $position $w $level $key $textualAnnotation 1
					set textualAnnotation {}
				}
				set havePly 1
			}

			annotation {
				if {[llength $node] == 2} {
					PrintTextualAnnotation $position $w $level $key [lindex $node 1]
				} else {
					lassign $node _ prefixAnnotation infix suffix textualAnnotation
					set suffixAnnotation [concat $infix $suffix]
				}
			}

			states {
				set states [lindex $node 1]
				if {[string match *3* $states]} {
					$w insert cur " "
					$w insert cur "3\u00d7" {state threefold}
				}
				if {[string match *f* $states]} {
					$w insert cur " "
					$w insert cur "50" {state fifty}
				}
			}

			marks {
				set hasMarks [lindex $node 1]
				if {$hasMarks} {
					if {$havePly} { $w insert cur " " }
					$w insert cur "\u27f8" m:marks
				}
			}

			comment {
				$w mark set cur:start cur left
				set type [lindex $node 1]
				if {$type eq "finally"} {
					PrintMoveInfo $position $w $level $key [lindex $node 2]
				} else {
					PrintComment $position $w $level $key $type [lindex $node 2]
				}
				if {$level == 0 && !($Options(style:column))} {
					$w tag add indent1 cur:start cur
				}
			}
		}
	}

	if {[llength $suffixAnnotation]} {
		PrintNumericalAnnotation $context $position $w $level $key $suffixAnnotation 0 0
	}
}


proc InsertDiagram {context position w level key data} {
	variable ::pgn::${context}::Options
	variable ::pgn::editor::Colors
	variable Vars

	set color white

	foreach entry $data {
		switch [lindex $entry 0] {
			color { set color [lindex $entry 1] }
			break { $w insert cur "\n" }

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
				set emb $w.[string map {. :} $key]
				board::diagram::new $emb $size -bordersize $borderSize
				if {2*$pady < $alignment} {
					board::diagram::alignBoard $emb [::colors::lookup $Colors(background)] 
				}
				if {$color eq "black"} { ::board::diagram::rotate $emb }
				::board::diagram::update $emb $board
				::board::diagram::bind $emb <Button-1> [namespace code [list EditAnnotation nag]]
				::board::diagram::bind $emb <Double-1> {#} ;# catch double clicks
				::board::diagram::bind $emb <Button-3> [namespace code [list PopupMenu $w $position]]
				::board::diagram::bind $emb <Double-3> {#} ;# catch double clicks
				::board::diagram::bind $emb <Button-4> [string map [list %W $w] [bind $w <Button-4>]]
				::board::diagram::bind $emb <Button-4> {+ break }
				::board::diagram::bind $emb <Button-5> [string map [list %W $w] [bind $w <Button-5>]]
				::board::diagram::bind $emb <Button-5> {+ break }
				$w window create cur \
					-align center \
					-window $emb \
					-padx $Options(diagram:padx) \
					-pady $pady \
					-tags m:nag \
					;
			}
		}
	}
}


proc PrintMove {context position w level key data annotation} {
	variable ::pgn::${context}::Options
	variable Vars

	lassign $data moveNo stm san legal
	set additional {}
	if {$key eq $Vars(current:$position)} { lappend additional h:curr }

	if {$level == 0 && $Options(style:column)} {
		set text "\t"

		if {$moveNo} {
			append text $moveNo ".\t"
			if {$stm eq "black"} { append text "...\t" }
		} 

		$w insert cur $text

		if {[llength $annotation]} {
			PrintNumericalAnnotation $context $position $w $level $key $annotation 1 1
			$w insert cur "\u2006"
		}
	} else {
		if {[llength $annotation]} {
			PrintNumericalAnnotation $context $position $w $level $key $annotation 1 1
			$w insert cur "\u2006"
		}

		if {$moveNo} {
			set text "."
			if {$stm eq "black"} { append text ".." }
			$w insert cur ${moveNo}${text} [list m:move {*}$additional]
		}
	}

	if {!$legal && $level > 0} { lappend additional illegal }
	set t [expr {$level == 0 && $Options(weight:mainline) eq "bold" ? "figurineb" : "figurine"}]

	foreach {text tag} [::font::splitMoves $san $t] {
		$w insert cur $text [list m:move {*}$tag {*}$additional]
	}

	if {!$legal} {
		$w insert cur "\u26A1" {m:move illegal} ;# alternatives: u26A0, u2716
	}
}


proc ShowPosition {w state} {
	variable Vars

	set position $Vars(position)
	set key [FindKey $w move]
	::browser::showPosition $w $position [[namespace parent]::board::rotated?] $key $state
}


proc HidePosition {w} {
	variable Vars

	set Vars(diagram:show) 0
	set Vars(diagram:state) 0
	set Vars(diagram:caps) 0
	::browser::hidePosition $w
}


proc PrintComment {position w level key pos data} {
	set startPos 0
	set underline 0
	set flags 0
	set count 0
	set needSpace 0
	set lastChar ""
	set paragraph 0

	foreach entry [::scidb::misc::xml toList $data] {
		lassign $entry lang comment
		if {[string length $lang] == 0} {
			set lang xx
		} elseif {[incr paragraph] >= 2} {
			$w insert cur " \u2726 "
			set needSpace 0
		}
		foreach pair $comment {
			lassign $pair code text
			set text [string map {"<brace/>" "\{"} $text]
			if {$needSpace} {
				if {![string is space -strict [string index $text 0]]} {
					$w insert cur " " $lang
				}
				set needSpace 0
			}
			set lastChar [string index $text end]
			switch -- $code {
				sym {
					if {$startPos == 0} { $w mark set my:start cur left; set startPos 1 }
					set tag [expr {$flags & 1 ? "figurineb" : "figurine"}]
					$w insert cur [string map $::figurines::pieceMap $text] $tag
				}
				nag {
					if {$startPos == 0} { $w mark set my:start cur left; set startPos 1 }
					lassign [::font::splitAnnotation $text] value sym tag
					set tags {}
					if {$tag eq "symbol"} {
						if {$flags & 1} { set tags symbolb }
					} else {
						set tags [expr {$flags & 1 ? "codeb" : "code"}]
					}
					lappend tags nag$text
					set sym [::font::mapNagToUtfSymbol $sym]
					if {[string is integer $sym]} { set sym "{\$$sym}" }
					$w insert cur [::font::mapNagToUtfSymbol $sym] $tags
					incr count
				}
				emo {
					if {$startPos == 0} { $w mark set my:start cur left; set startPos 1 }
					set emotion [::emoticons::lookupEmotion $text]
					if {[string length $emotion]} {
						set img [$w image create cur  \
							-align center \
							-image $::emoticons::icon($emotion) \
							-tags t:emo:$emotion \
						]
						$w insert cur "\ufeff"
					} else {
						switch $flags {
							0 { set tag {} }
							1 { set tag bold }
							2 { set tag italic }
							3 { set tag bold-italic }
						}
						$w insert cur $text $tag
					}
				}
				str {
					if {$startPos == 0} { $w mark set my:start cur left; set startPos 1 }
					set tags {}
					switch $flags {
						1 { lappend tags bold }
						2 { lappend tags italic }
						3 { lappend tags bold-italic }
					}
					if {$underline} { lappend tags underline }
					$w insert cur $text {*}$tags
				}
				+bold			{ incr flags +1 }
				-bold			{ incr flags -1 }
				+italic		{ incr flags +2 }
				-italic		{ incr flags -2 }
				+underline	{ set underline 1 }
				-underline	{ set underline 0 }
			}
		}

		if {$startPos} {
			$w tag add m:comment my:start cur
			$w tag add lang:$lang my:start cur
			$w tag add pos:$pos my:start cur
			set startPos 0
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
	set moveInfo [lindex [::scidb::misc::xml toList $data] 0 1]

	foreach pair $moveInfo {
		lassign $pair code text
		switch -- $code {
			str {
				set k 0
				while {$k < [string length $text]} {
					set n [string first ";" $text $k]
					if {$n == -1} { set n [string length $text] }
					set space [expr {$k ? " \u2726 " : ""}]
					switch $flags {
						0 { set tag {} }
						1 { set tag bold }
						2 { set tag italic }
						3 { set tag bold-italic }
					}
					$w insert cur ${space}[string range $text $k [expr {$n - 1}]] [list m:info {*}$tag]
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


proc PrintNumericalAnnotation {context position w level key nags isPrefix afterPly} {
	$w mark set my:start cur left
	set prevSym -1
	set firstSym 1

	foreach {value nag tag} [::font::splitAnnotation $nags] {
		set space ""
		if {$tag eq "symbol"} {
			if {$level == 0} { set tag symbolb }
			set sym 1
		} else {
			set sym 0
		}
		set c [string index $nag 0]
		if {[string is alpha $c] && [string is ascii $c]} {
			if {$isPrefix || $afterPly || $prevSym >= 0} { set space " " }
			set prevSym 2
		} elseif {$value <= 6} {
			if {!$firstSym} { set space "\u2005" }
			set prevSym 1
			set needSpace 1
		} elseif {$value == 155 || $value == 156} {
			if {!$firstSym || $value > 6} { set space "\u2005" }
			if {$isPrefix || $afterPly} { set space "\u2005" }
			set prevSym $sym
		} elseif {!$sym && !$isPrefix} {
			set space "\u2005"
			set prevSym $sym
		} elseif {!$firstSym || $value > 6} {
			set space "\u2005"
		}
		$w insert cur ${space}${nag} [list t:nag:$value {*}$tag]
		set isPrefix 0
		set afterPly 0
		set firstSym 0
	}

	$w tag add m:nag my:start cur
	if {$isPrefix && $prevSym == 2} { $w insert cur " " }
}


proc PrintTextualAnnotation {position w level key nags {needSpace 0}} {
	set space [expr {$needSpace ? " " : ""}]
	set text ""

	foreach nag $nags {
		append text $space $::annotation::mc::Nag([string range $nag 1 end])
		set space " \u2726 "
	}

	$w insert cur $text m:nagtext
}


proc EditComment {w} {
	variable Vars

	set position $Vars(position)
	set key [FindKey $w comment]
	GotoMove $position $key
	set tags [$w tag names m:comment.current.first]
	regexp {lang:([a-z]+)} $tags -> lang
	regexp {pos:([a-z]+)} $tags -> pos
	set Vars(edit:comment) 1
	editComment $pos $position $key $lang
	set Vars(edit:comment) 0
	LeaveComment $w
}


proc EnterNag {w} {
	if {[lindex [$w dump -window current] 0] ne "window"} {
		$w tag add h:nag m:nag.current.first m:nag.current.last
	}
}


proc LeaveNag {w} {
	$w tag remove h:nag begin end
}


proc EnterMove {w key {state 0}} {
	variable ::util::lockMask
	variable Vars

	if {$key eq "current"} {
		set range {m:move.current.first m:move.current.last}
		set key [FindKey $w move]
	} else {
		set range [FindRange $w $key]
	}
	$w tag add h:move {*}$range

	set position $Vars(position)
	set Vars(active:$position) $key

   # this seems to be a performance problem
	# after cancel $Vars(after:$position)
	# set Vars(after:$position) [after 75 [namespace code [list ChangeCursor $position hand2]]]

	if {$Vars(diagram:show)} {
		set Vars(diagram:state) $state
		set Vars(diagram:caps) [expr {$state & $lockMask}]
		::browser::updatePosition $w $position [[namespace parent]::board::rotated?] $key $state
	}
}


proc LeaveMove {w} {
	variable Vars

	set position $Vars(position)
	set Vars(active:$position) {}
	$w tag remove h:move begin end

#	if {$Vars(current:$position) ne $Vars(active:$position)} {
   	# this seems to be a performance problem
		# after cancel $Vars(after:$position)
		# set Vars(after:$position) [after 75 [namespace code [list ChangeCursor $position {}]]]
#	}
}


#proc ChangeCursor {position cursor} {
#	variable Vars
#
#	if {[winfo exists $Vars(pgn:$position)]} {
#		set Vars(after:$position) {}
#		$Vars(pgn:$position) configure -cursor $cursor
#	}
#}


proc EnterMark {w} {
	$w tag add h:mark m:mark.current.first m:mark.current.last
	::tooltip::show $w [string map {",," "," " " "\n"} [::scidb::game::query marks [FindKey $w mark]]]
}


proc LeaveMark {w tag} {
	$w tag remove h:mark begin end
	::tooltip::hide
}


proc EnterBracket {w} {
	variable CursorCounter

	set mode [expr {[::scidb::game::variation folded? [FindKey $w fold]] ? "expand" : "collapse"}]
	set cursor [set cursor::$mode]
	incr CursorCounter
	after 75 [namespace code [list SetCursor $w $CursorCounter $cursor]]
}


proc LeaveBracket {w} {
	variable CursorCounter

	incr CursorCounter
	after 75 [namespace code [list UnsetCursor $w $CursorCounter]]
}


proc EnterPlus {w} {
	variable CursorCounter

	incr CursorCounter
	after 75 [namespace code [list SetCursor $w $CursorCounter $cursor::expand]]
}


proc LeavePlus {w} {
	variable CursorCounter

	incr CursorCounter
	after 75 [namespace code [list UnsetCursor $w $CursorCounter]]
}


proc ToggleFold {w mode triggerEnter} {
	set current [$w index current]
	::scidb::game::variation fold [FindKey $w $mode] toggle
	if {$triggerEnter} {
		$w mark set current $current
		EnterBracket $w ;# toggle cursor
	}
}


proc SetCursor {w counter cursor} {
	variable CursorCounter

	if {![winfo exists $w]} { return }

	if {$counter < $CursorCounter} { return }

	if {[tk windowingsystem] eq "x11"} {
		::xcursor::setCursor $w $cursor
	} else {
		$w configure -cursor $cursor
	}
}


proc UnsetCursor {w counter} {
	variable CursorCounter

	if {![winfo exists $w]} { return }
	if {$counter < $CursorCounter} { return }

	if {[tk windowingsystem] eq "x11"} {
		::xcursor::unsetCursor $w
	} else {
		$w configure -cursor {}
	}
}


proc GotoMove {{position {}} {key {}}} {
	variable Vars

	if {[llength $position] == 0} { set position $Vars(position) }
	if {[llength $key] == 0} { set key $Vars(active:$position) }

	set Vars(see:$position) 0
	::scidb::game::moveto $position $key
	set Vars(see:$position) 1
}


proc EnterComment {w} {
	$w tag add h:comment m:comment.current.first m:comment.current.last
}


proc LeaveComment {w} {
	variable Vars

	if {!$Vars(edit:comment)} {
		$w tag remove h:comment begin end
	}
}


proc EnterInfo {w} {
	$w tag add h:info m:info.current.first m:info.current.last
}


proc LeaveInfo {w} {
	variable Vars

	if {!$Vars(edit:comment)} {
		$w tag remove h:info begin end
	}
}


proc EditInfo {w {key {}}} {
	variable Vars

	if {[string length $key]} {
		set position $Vars(position)
		if {[string length $Vars(active:$position)]} {
			set key [FindKey $w info]
		} else {
			set key [::scidb::game::query start]
		}
		GotoMove $position $key
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


proc SetupBindings {w position} {
	if {$position >= 9} { return }

	$w tag bind m:nag     <Enter> [namespace code [list EnterNag $w]]
	$w tag bind m:nag     <Leave> [namespace code [list LeaveNag $w]]
	$w tag bind m:move    <Enter> [namespace code [list EnterMove $w current %s]]
	$w tag bind m:move    <Leave> [namespace code [list LeaveMove $w]]
	$w tag bind m:mark    <Enter> [namespace code [list EnterMark $w]]
	$w tag bind m:mark    <Leave> [namespace code [list LeaveMark $w]]
	$w tag bind m:info    <Enter> [namespace code [list EnterInfo $w]]
	$w tag bind m:info    <Leave> [namespace code [list LeaveInfo $w]]
	$w tag bind m:comment <Enter> [namespace code [list EnterComment $w]]
	$w tag bind m:comment <Leave> [namespace code [list LeaveComment $w]]
	$w tag bind m:expand  <Enter> [namespace code [list EnterPlus $w]]
	$w tag bind m:expand  <Leave> [namespace code [list LeavePlus $w]]
	$w tag bind m:fold    <Enter> [namespace code [list EnterBracket $w]]
	$w tag bind m:fold    <Leave> [namespace code [list LeaveBracket $w]]

	$w tag bind m:move    <ButtonPress-1>   [namespace code [list GotoMove]]
	$w tag bind m:move    <ButtonPress-2>   [namespace code [list ShowPosition $w %s]]
	$w tag bind m:move    <ButtonRelease-2> [namespace code [list HidePosition $w]]
	$w tag bind m:move    <Any-Button>      [namespace code [list HidePosition $w]]
	$w tag bind m:illegal <ButtonPress-1>   [namespace code [list GotoMove]]
	$w tag bind m:nag     <ButtonPress-1>   [namespace code [list EditAnnotation nag]]
	$w tag bind m:mark    <ButtonPress-1>   [namespace code [list OpenMarksPalette]]
	$w tag bind m:info    <ButtonPress-1>   [namespace code [list EditInfo $w this]]
	$w tag bind m:comment <ButtonPress-1>   [namespace code [list EditComment $w]]
	$w tag bind m:expand  <ButtonPress-1>   [namespace code [list ToggleFold $w expand 0]]
	$w tag bind m:fold    <ButtonPress-1>   [namespace code [list ToggleFold $w fold 1]]
}


proc ResetGame {w position {tags {}}} {
	variable Vars
	variable ::pgn::editor::Colors

	$w clear
	::pgn::setup::configureText [::pgn::setup::getPath $w]
	SetupBindings $w $position

	if {$position <= 9} {
		::gamebar::activate $Vars(gamebar) $position
		Raise $position
	}

	set Vars(current:$position) {}
	set Vars(successor:$position) {}
	set Vars(previous:$position) {}
	set Vars(active:$position) {}
	set Vars(lang:set:$position) {}
	set Vars(see:$position) 1
	set Vars(dirty:$position) 0
	set Vars(comment:$position) ""
	set Vars(result:$position) ""
	set Vars(virgin:$position) 1
	set Vars(header:$position) ""
	set Vars(last:$position) ""
	set Vars(tags:$position) $tags
	set Vars(after:$position) {}

	SetLanguages $position

	if {$position <= 10} {
		::pgn::setup::setupStyle editor $position
		::scidb::game::subscribe pgn $position [namespace current]::DoLayout
		::scidb::game::subscribe board $position [namespace parent]::board::update
		::scidb::game::subscribe tree $position [namespace parent]::tree::update
		::scidb::game::subscribe board $position [namespace parent]::analysis::update
		::scidb::game::subscribe state $position [namespace current]::StateChanged
	}
}


proc ForgetGame {position} {
	variable Vars
	array unset Vars *:$position
}


proc HasMoveInfo {} {
	variable ::pgn::setup::ShowMoveInfo

	set showMoveInfo {}
	foreach {type use} [array get ShowMoveInfo] {
		if {$use} { lappend showMoveInfo $type }
	}

	return [::scidb::game::query moveInfo? $showMoveInfo]
}


proc UpdateButtons {} {
	variable Vars

	if {![winfo exists $Vars(button:show:moveinfo)]} { return }

	if {[HasMoveInfo]} {
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
	variable MoveInfoPGN
	variable Vars

	set menu $parent.__menu__
	# Try to catch accidental double clicks.
	if {[winfo exists $menu]} { return }
	menu $menu
	catch { wm attributes $m -type popup_menu }

	if {[::game::trialMode?]} {
		$menu add command \
			-label " $mc::StopTrialMode" \
			-image $::icon::16x16::delete \
			-compound left \
			-command [namespace code flipTrialMode] \
			-accel "$::mc::Key(Ctrl)-[set [namespace parent]::board::mc::Accel(trial-mode)]" \
			;
		$menu add separator
	} else {
		if {[::scidb::game::level] > 0} {
			set varno [::scidb::game::variation current]
			if {$varno > 1} {
				$menu add command \
					-label " $mc::Command(variation:first)" \
					-image $::icon::16x16::promote \
					-compound left \
					-command [namespace code FirstVariation] \
					;
			}
			$menu add command \
				-label " $mc::Command(variation:promote)" \
				-image $::icon::16x16::arrowUp \
				-compound left \
				-command [namespace code PromoteVariation] \
				;
			$menu add command \
				-label " $mc::Command(variation:remove)" \
				-image $::fsbox::filelist::icon::16x16::delete \
				-compound left \
				-command [namespace code RemoveVariation] \
				;
			if {[::scidb::game::variation length] % 2} {
				set state disabled
			} else {
				set state normal
			}
			$menu add command \
				-state $state \
				-label " $mc::Command(variation:insert)" \
				-image $::icon::16x16::plus \
				-compound left \
				-command [namespace code [list InsertMoves $parent]] \
				;
			$menu add command \
				-label " $mc::Command(variation:exchange)..." \
				-image $::icon::16x16::exchange \
				-compound left \
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

		menu $menu.strip
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
		lassign [::scidb::game::link? $position] base variant index

		$menu.strip add command \
			-label " $mc::Command(strip:comments)" \
			-command [list ::widget::busyOperation { ::scidb::game::strip comments }] \
			-state $state \
			;

		menu $menu.strip.comments
		$menu.strip add cascade \
			-menu $menu.strip.comments \
			-label " $mc::Command(strip:language)" \
			-state $state \
			-command [list ::widget::busyOperation [list ::scidb::game::strip comments]] \
			;

		if {$state eq "normal"} {
			foreach lang $Vars(lang:set) {
				if {$lang == "xx"} { set l "" } else { set l $lang }
				$menu.strip.comments add command \
					-compound left \
					-image $::country::icon::flag([::mc::countryForLang $lang]) \
					-label " [::encoding::languageName $lang]" \
					-command [list ::widget::busyOperation [list ::scidb::game::strip comments $l]] \
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
		if {$base eq $::scidb::scratchbaseName} {
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

		$menu add command \
			-label " $mc::InsertDiagram" \
			-image $::icon::16x16::board \
			-compound left \
			-command [list ::annotation::addNag suffix 155] \
			;
		$menu add command \
			-label " $mc::InsertDiagramFromBlack" \
			-image $::icon::16x16::board \
			-compound left \
			-command [list ::annotation::addNag suffix 156] \
			;

		if {![::scidb::game::position atStart?]} {
			set cmd ::annotation::addNag

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
						if {(14 <= $nag && $nag <= 21) || !$isStmNag($nag)} {
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
			-command [namespace code EditAnnotation] \
			-accel "$::mc::Key(Ctrl)-[set [namespace parent]::board::mc::Accel(edit-annotation)]" \
			;
		set accel "$::mc::Key(Ctrl)-$::mc::Key(Shift)-"
		append accel "[set [namespace parent]::board::mc::Accel(edit-comment)]"
		if {[::scidb::game::position atStart?]} {
			$menu add command \
				-label " $mc::EditPrecedingComment..." \
				-image $::fsbox::bookmarks::icon::16x16::modify \
				-compound left \
				-command [namespace code [list editComment preceding $position]] \
				-accel $accel \
				;
		} else {
			$menu add command \
				-label " $mc::EditCommentBefore..." \
				-image $::fsbox::bookmarks::icon::16x16::modify \
				-compound left \
				-command [namespace code [list editComment before $position]] \
				-accel $accel \
				;
			$menu add command \
				-label " $mc::EditCommentAfter..." \
				-image $::fsbox::bookmarks::icon::16x16::modify \
				-compound left \
				-command [namespace code [list editComment after $position]] \
				-accel "$::mc::Key(Ctrl)-[set [namespace parent]::board::mc::Accel(edit-comment)]" \
				;
		}
		if {[::scidb::game::position atEnd?] || [::scidb::game::query length] == 0} {
			$menu add command \
				-label " $mc::EditTrailingComment..." \
				-image $::fsbox::bookmarks::icon::16x16::modify \
				-compound left \
				-command [namespace code [list editComment trailing $position]] \
				;
		}
		$menu add command \
			-label " $mc::EditMoveInformation..." \
			-image $::icon::16x16::clock \
			-compound left \
			-state $state \
			-command [namespace code [list EditInfo $parent]] \
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

	::font::addChangeFontSizeToMenu editor $menu.display [namespace current]::fontSizeChanged
	$menu.display add separator

	foreach {label var} {ParLayout(column-style) style:column
								ParLayout(use-spacing) spacing:paragraph
								Display(numbering) show:varnumbers
								Display(moveinfo) show:moveinfo
								Display(nagtext) show:nagtext
								Diagrams(show) show:diagram
								Emoticons(show) show:emoticon} {
		$menu.display add checkbutton \
			-label [set ::pgn::setup::mc::$label] \
			-onvalue 1 \
			-offvalue 0 \
			-variable ::pgn::editor::Options($var) \
			-command [namespace code [list Refresh $var]] \
			;
		::theme::configureCheckEntry $menu.display
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
	::theme::configureCheckEntry $menu.display

	$menu.display add separator

	menu $menu.display.moveStyles
	$menu.display add cascade \
		-menu $menu.display.moveStyles \
		-label $mc::MoveNotation \
		;
	foreach style $moveStyles {
		$menu.display.moveStyles add radiobutton \
			-compound left \
			-label $::notation::mc::MoveForm($style) \
			-variable ::pgn::editor::Options(style:move) \
			-value $style \
			-command [namespace code [list Refresh style:move]] \
			;
		::theme::configureRadioEntry $menu.display.moveStyles
	}

	menu $menu.display.languages
	$menu.display add cascade \
		-menu $menu.display.languages \
		-label $mc::LanguageSelection \
		;
	$menu.display.languages add checkbutton \
		-compound left \
		-image $::country::icon::flag([::mc::countryForLang xx]) \
		-label $::languagebox::mc::AllLanguages \
		-variable [namespace current]::Vars(lang:active:xx) \
		-command [namespace code [list SetLanguages $Vars(position)]] \
		;
	::theme::configureCheckEntry $menu.display.languages
	if {[llength $Vars(lang:set)]} {
		foreach entry [::country::makeCountryList $Vars(lang:set)] {
			lassign $entry flag name code
			$menu.display.languages add checkbutton \
				-compound left \
				-image $flag \
				-label " $name" \
				-variable [namespace current]::Vars(lang:active:$code) \
				-command [namespace code [list SetLanguages $Vars(position)]] \
				;
			::theme::configureCheckEntry $menu.display.languages
		}
	}

	menu $menu.display.moveinfo -tearoff no
	$menu.display add cascade \
		-menu $menu.display.moveinfo \
		-label $mc::MoveInfoSelection \
		;
	foreach type {eval clk emt ccsnt video} {
		$menu.display.moveinfo add checkbutton \
			-label "$mc::MoveInfo($type) ($MoveInfoPGN($type))" \
			-variable ::pgn::setup::ShowMoveInfo($type) \
			-command [namespace code [list Refresh moveinfo:$type]] \
			;
		::theme::configureCheckEntry $menu.display.moveinfo
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

	bind $menu <<MenuUnpost>> [list after idle [list catch [list destroy $menu]]]
	tk_popup $menu {*}[winfo pointerxy $parent]
}


proc PopupHistoryMenu {parent} {
	variable Vars
	::gamebar::popupMenu $Vars(gamebar) $parent no [$parent selection]
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
	set variant [::scidb::game::query $position variant?]
	::import::openEdit $Vars(frame:$position) $position -mode game -variant $variant
}


proc PasteClipboardVariation {} {
	variable Vars

	set position $Vars(position)
	set variant [::scidb::game::query $position variant?]
	::import::openEdit $Vars(frame:$position) $position -mode variation -variant $variant
}


proc ShowCountry {cb okBtn} {
	variable Vars

	if {![winfo exists $cb]} { return }

	set icon [$cb get flag]
	if {[string length $icon]} {
		$cb placeicon $icon
	}
	if {$Vars(lang:src) eq $Vars(lang:dst)} {
		set state disabled
	} else {
		set state normal
	}
	$okBtn configure -state $state
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
		set  Vars(lang:src) [::country::makeCountryList $Vars(lang:set)]
	} else {
		set Vars(lang:src) {}
	}
	set Vars(lang:dst) [::country::makeCountryList]

	ttk::labelframe $top.src -text $::mc::From
	ttk::labelframe $top.dst -text $::mc::To

	foreach what {src dst} {
		if {$what eq "dst" || "xx" in $Vars(lang:set)} {
			set Vars(lang:$what) [linsert $Vars(lang:$what) 0 $allLang]
		}
		set w $top.$what.cb
		::ttk::tcombobox $w \
			-state readonly \
			-showcolumns {flag code} \
			-height [expr {min(15, [llength $Vars(lang:$what)])}] \
			-textvariable [namespace current]::Vars(lang:$what) \
			-exportselection no \
			-format "%2" \
			;
		$w addcol image -id flag -width 20 -justify center
		$w addcol text -id code
		foreach entry $Vars(lang:$what) {
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
	::util::place $dlg -parent $parent -position center
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
	::scidb::game::copy comments $srcCode $dstCode -strip $Vars(strip:orig)
	destroy $dlg
}


proc FoldVariations {flag} {
	variable Vars

	set position $Vars(position)
	if {$position == -1} { return }
	::scidb::game::variation fold $flag
	See $position
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
	::validate::spinboxInt $top.sblength -clamp no
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
	::util::place $dlg -parent $parent -position center
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
		::validate::spinboxInt $dlg.top.sblength -clamp no
		focus $dlg.top.sblength
	} else {
		destroy $dlg
	}
}


proc Refresh {var} {
	variable Vars

	switch -glob $var {
		weight:mainline {
			variable _BoldTextForMainlineMoves
			variable ::pgn::editor::Options
			set Options(weight:mainline) [expr {$_BoldTextForMainlineMoves ? "bold" : "normal"}]
		}
		show:nagtext {
			::pgn::setup::setupNags editor
		}
		moveinfo:* {
			variable ::pgn::setup::ShowMoveInfo
			variable ::pgn::editor::Options
			set type [lindex [split $var :] 1]
			if {$ShowMoveInfo($type) && [HasMoveInfo]} { set Options(show:moveinfo) 1 }
		}
	}

	set Vars(current:$Vars(position)) {}
	set Vars(successor:$Vars(position)) {}

	refresh
}


# NOTE: will be called from ::setup::popupShuffleMenu
proc Shuffle {variant} {
	variable Vars

	set parent $Vars(frame)

	if {[::scidb::game::query modified?]} {
		set reply [::dialog::question -parent $parent -message $::gamebar::mc::DiscardNewGame]
		if {$reply eq "no"} { return }
	}

	if {[string is integer -strict $variant]} {
		set newIdn $variant
	} elseif {$variant eq "Normal"} {
		set newIdn [::setup::shuffle $variant]
	} else {
		set oldIdn [::scidb::game::query idn]
		set newIdn [::setup::shuffle $variant]
		while {$oldIdn == $newIdn} { set newIdn [::setup::shuffle $variant] }
	}

	::scidb::game::clear $newIdn
	if {$Vars(position) >= 0} {
		::scidb::game::modified $Vars(position) no
	}
}


proc LanguageChanged {} {
	variable Vars 

	foreach position [::game::usedPositions?] {
		if {[::scidb::game::query $position length] == 0} {
			::scidb::game::refresh $position
		} else {
			set w $Vars(pgn:$position)
			UpdateHeader editor $position $w $Vars(header:$position)
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

proc refresh {regardFontSize}					{ ::application::pgn::refresh $regardFontSize }
proc resetGoto {w position}					{ ::application::pgn::resetGoto $w $position }
proc doLayout {position data context w}	{ ::application::pgn::DoLayout $position $data $context $w }
proc resetGame {w position}					{ ::application::pgn::ResetGame $w $position }
proc forgetGame {position}						{ ::application::pgn::ForgetGame $position }

} ;# editor
} ;# pgn

# vi:set ts=3 sw=3:
