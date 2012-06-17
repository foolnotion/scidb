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

set ColumnStyle						"Column Style"
set UseParagraphSpacing				"Use Paragraph Spacing"
set ShowMoveInfo						"Show Move Information"
set BoldTextForMainlineMoves		"Bold Text for Mainline Moves"
set ShowDiagrams						"Show Diagrams"
set Languages							"Languages"
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

set StartTrialMode					"Start Trial Mode"
set StopTrialMode						"Stop Trial Mode"
set Strip								"Strip"
set InsertDiagram						"Insert Diagramm"
set InsertDiagramFromBlack			"Insert Diagramm from Black's Perspective"
set SuffixCommentaries				"Suffixed Commentaries"
set StripOriginalComments			"Strip original comments"

set AddNewGame							"Save: Add New Game to %s..."
set ReplaceGame						"Save: Replace Game in %s..."
set ReplaceMoves						"Save: Replace Moves Only in Game"

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

array set Colors {
	main				#000000
	variation		#0000ee
	startvar			#68480a
	bracket			#0000ee
	nag				#ee0000
	comment			#006300
	comment:hilite	#7a5807
	info				#8b4513
	info:hilite		#b22222
	current			#ffdd76
	hilite			#ebf4f5
	next-move		#eeff00
	background		#ffffff
	emphasized		#ebf4f5
	result			#000000
	illegal			#ee0000
	marks				#6300c6
	header			#000000
	empty				#666666
}
#	header			#1c1cd6
#	next-move		#f8f2b1
#	next-move		#e5ff00
#	comment			#008b00
#	comment:hilite	#005500
#	info				#008b00

array set Options {
	font					TkTextFont
	font-bold			{}
	font-italic			{}
	font-bold-italic	{}
	mainline-bold		1
	indent-amount		25
	indent-max			2
	indent-comment		1
	indent-var			1
	column-style		0
	paragraph-spacing	0
	show-move-info		0
	tabstop-1			6.0
	tabstop-2			0.7
	tabstop-3			12.0
	diagram-size		30
	diagram-show		1
	diagram-pad-x		25
	diagram-pad-y		5
}

variable Vars
variable CharLimit 250
variable Counter 0


proc build {parent width height} {
	variable Vars
	variable Options

	set font $Options(font)
	foreach {key attrs} {bold bold italic italic bold-italic {bold italic}} {
		set Vars(font-$key) $Options(font-$key)
		if {[llength $Vars(font-$key)] == 0} {
			set Vars(font-$key) [list [font configure $font -family] [font configure $font -size] $attrs]
		}
	}

	set top   [::tk::frame $parent.top -borderwidth 0 -background white]
	set main  [::tk::multiwindow $top.main -borderwidth 0 -background white]
	set games [::tk::multiwindow $main.games -borderwidth 0 -background white]
	set logo  [::tk::frame $main.logo -borderwidth 0 -background white -cursor left_ptr]
	set hist  [::game::history $main.hist -cursor left_ptr]

	pack $top -fill both -expand yes
	pack $main -fill both -expand yes

	set popupcmd [namespace code [list ::gamebar::popupMenu $top no]]

	$main add $logo $hist $games
	bind $main <Button-3> $popupcmd
	$hist bind <Button-3> [namespace code [list PopupHistoryMenu $hist]]
	bind $hist <<GameHistorySelection>> [namespace code HistorySelectionChanged]

	# logo pane --------------------------------------------------------------------------------
	$main paneconfigure $logo -sticky ""
	bind $logo <Button-3> $popupcmd

	tk::label $logo.icon -image $::icon::64x64::logo -borderwidth 0 -background white
	tk::label $logo.logo -image $icon::104x30::logo  -borderwidth 0 -background white
	grid $logo.icon -row 1 -column 1
	grid $logo.logo -row 2 -column 1

	foreach child [winfo children $logo] {
		bind $child <Button-3> $popupcmd
	}

	# games pane -------------------------------------------------------------------------------
	bind $games <Button-3> [namespace code [list ::gamebar::popupMenu $top]]
	set edit [::tk::frame $games.edit -borderwidth 0]
	pack $edit -expand yes -fill both
	bind $edit <Configure> [namespace code { Configure %W %h }]
	set panes [::tk::multiwindow $edit.panes -borderwidth 0 -background white -overlay yes]
	set gamebar [::gamebar::gamebar $edit.gamebar]

	grid $gamebar -row 1 -column 1 -sticky nsew
	grid $panes   -row 2 -column 1 -sticky nsew

	::gamebar::addReceiver $gamebar [namespace code GameBarEvent]

	set Vars(frame) $edit
	set Vars(delta) 0
	set Vars(after) {}
	set Vars(index) -1
	set Vars(break) 0
	set Vars(height) 0

	for {set i 0} {$i < 9} {incr i} {
		set f [::tk::frame $edit.f$i]
		set sb [::ttk::scrollbar $f.sb \
			-command [namespace code [list ::widget::textLineScroll $f.pgn]] \
			-takefocus 0 \
		]
		set pgn [tk::text $f.pgn \
			-yscrollcommand [list $f.sb set] \
			-takefocus 0 \
			-exportselection 0 \
			-undo 0 \
			-width 0 \
			-height 0 \
			-relief sunken \
			-borderwidth 1 \
			-state disabled \
			-wrap word \
			-font $Options(font) \
			-cursor {} \
		]

		::widget::textPreventSelection $pgn
		bind $pgn <Button-3> [namespace code [list PopupMenu $edit $i]]

		if {[string equal "x11" [tk windowingsystem]]} {
			bind $pgn <4> { %W yview scroll -1 units }
			bind $pgn <5> { %W yview scroll +1 units }
			bind $pgn <4> {+ break }
			bind $pgn <5> {+ break }
		} else {
			bind $pgn <MouseWheel> { %W yview scroll [expr {-(%D/120)}] units }
			bind $pgn <MouseWheel> {+ break }
		}

		grid $pgn -row 1 -column 1 -sticky nsew
		grid $sb -row 1 -column 2 -sticky ns
		grid rowconfigure $f 1 -weight 1
		grid columnconfigure $f 1 -weight 1

		$panes add $f

		set Vars(pgn:$i) $pgn
		set Vars(frame:$i) $f
		set Vars(after:$i) {}
	}

	set Vars(main) $main
	set Vars(hist) $hist
	set Vars(gamebar) $gamebar
	set Vars(games) $games
	set Vars(logo) $logo
	set Vars(panes) $panes
	set Vars(charwidth) [font measure [$Vars(pgn:0) cget -font] "0"]

	set tab1 [expr {round($Options(tabstop-1)*$Vars(charwidth))}]
	set tab2 [expr {$tab1 + round($Options(tabstop-2)*$Vars(charwidth))}]
	set tab3 [expr {$tab2 + round($Options(tabstop-3)*$Vars(charwidth))}]

	set Vars(tabs) [list	$tab1 right $tab2 $tab3]

	SetupStyle
	::scidb::game::undoSetup 20 9999

	for {set i 0} {$i < 9} {incr i} { ConfigureText $Vars(pgn:$i) }

	set tbGame [::toolbar::toolbar $top \
		-id game \
		-hide 1 \
		-side bottom \
		-tooltipvar ::mc::Game \
	]
	set Vars(button:new) [::toolbar::add $tbGame button \
		-image $::icon::toolbarDocument \
		-tooltip $::gamebar::mc::GameNew \
		-command [list ::menu::gameNew $top] \
	]
	set Vars(button:shuffle) [::toolbar::add $tbGame button \
		-image $::icon::toolbarDice \
		-tooltip "${::gamebar::mc::GameNew}: $::setup::board::mc::Shuffle" \
		-command [namespace code NewGame] \
	]
	set Vars(button:import) [::toolbar::add $tbGame button \
		-image $::icon::toolbarPGN \
		-tooltip $::import::mc::ImportPgnGame \
		-command [namespace code [list ::menu::importGame $Vars(main)]] \
	]
	set tbGameHistory [::toolbar::toolbar $top \
		-id history \
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
		-id display \
		-side bottom \
		-tooltipvar [namespace current]::mc::Display \
	]
	::toolbar::add $tbDisplay checkbutton \
		-image $::icon::toolbarColumnLayout \
		-command [namespace code [list ToggleOption column-style]] \
		-tooltipvar [namespace current]::mc::ColumnStyle \
		-variable [namespace current]::Options(column-style) \
		-padx 1 \
		;
	::toolbar::add $tbDisplay checkbutton \
		-image $::icon::toolbarParagraphSpacing \
		-command [namespace code [list ToggleOption paragraph-spacing]] \
		-tooltipvar [namespace current]::mc::UseParagraphSpacing \
		-variable [namespace current]::Options(paragraph-spacing) \
		-padx 1 \
		;
	set Vars(button:show-move-info) [::toolbar::add $tbDisplay checkbutton \
		-image $::icon::toolbarClock \
		-command [namespace code [list ToggleOption show-move-info]] \
		-tooltipvar [namespace current]::mc::ShowMoveInfo \
		-variable [namespace current]::Options(show-move-info) \
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
		-id languages \
		-side bottom \
		-tooltipvar [namespace current]::mc::Languages \
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
	InitScratchGame
	Raise history
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


proc add {position base tags} {
	variable Vars

	::gamebar::add $Vars(gamebar) $position $tags
	ResetGame $position $tags
}


proc replace {position base tags} {
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


proc editAnnotation {{position -1} {key {}}} {
	variable Vars

	if {$position == -1} {
		if {[::annotation::open?]} {
			return [::annotation::close]
		}
		set position $Vars(index)
	}

	if {[string length $key]} {
		GotoMove $position $key
	}

	Edit $position ::annotation
}


proc editComment {pos {position -1} {key {}} {lang {}}} {
	variable Vars

	if {$position == -1} { set position $Vars(index) }
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


proc replaceMoves {parent} {
	if {[::scidb::game::query modified?]} {
		set reply [::dialog::question -parent $parent -message $mc::ReallyReplaceMoves]
		if {$reply eq "yes"} { ::util::catchIoError [list ::scidb::game::update moves }
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
		::game::setFirst $scratchbaseName $tags
		add 0 $scratchbaseName $tags
		select 0
	}
}


proc Raise {what} {
	variable Vars

	if {[string is integer $what]} {
		$Vars(panes) raise $Vars(frame:$what)
		$Vars(main) raise $Vars(games)
		set Vars(index) $what
		::toolbar::setState $Vars(toolbar:display) enabled
		::toolbar::setState $Vars(toolbar:languages) enabled
		::toolbar::setState $Vars(toolbar:history) disabled
	} else {
		$Vars(hist) rebuild
		if {[$Vars(hist) empty?]} { set what logo } else { set what hist }
		$Vars(main) raise $Vars($what)
		set Vars(index) -1
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
	::scidb::game::switch 9
	set Vars(index) -1
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

	if {$Vars(start:$position)} {
		if {$key eq "m-0.0"} { return }
		set Vars(start:$position) 0
	}

	if {$key eq "m-0.0"} {
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


proc Configure {w height} {
	variable Vars

	after cancel $Vars(after)
	set Vars(after) [after 75 [namespace code [list Align $w $height]]]
}


proc ConfigureText {w} {
	variable Options
	variable Colors
	variable Vars

	if {$Options(mainline-bold)} {
		set mainFont $Vars(font-bold)
	} else {
		set mainFont $Options(font)
	}

	$w tag configure eco -font $Vars(font-bold)
	$w tag configure main -font $mainFont
	$w tag configure variation -foreground $Colors(variation)
	$w tag configure nag -foreground $Colors(nag)
	$w tag configure illegal -foreground $Colors(illegal)
	$w tag configure result -font $mainFont -foreground $Colors(result)
#	$w tag configure startvar -foreground $Colors(startvar)
	$w tag configure bracket -foreground $Colors(bracket)
	$w tag configure marks -foreground $Colors(marks)
	$w tag configure header -foreground $Colors(header)
	$w tag configure empty -foreground $Colors(empty)

	$w tag configure figurine -font $::font::figurine
	$w tag configure symbol -font $::font::symbol
	$w tag configure symbolb -font $::font::symbolb

	$w tag configure comment -foreground $Colors(comment)
	$w tag configure info -foreground $Colors(info)
	$w tag configure bold -font $Vars(font-bold)
	$w tag configure italic -font $Vars(font-italic)
	$w tag configure bold-italic -font $Vars(font-bold-italic)
	$w tag configure underline -underline true

	$w tag bind illegal <Any-Enter> [namespace code [list Tooltip $w illegal]]
	$w tag bind illegal <Any-Leave> [namespace code [list Tooltip $w hide]]

	if {$Options(column-style)} {
		$w configure -tabs $Vars(tabs) -tabstyle wordprocessor
	} else {
		$w configure -tabs {} -tabstyle tabular
	}

	for {set k 0} {$k <= $Vars(indent-max)} {incr k} {
		set amount [expr {$k*$Options(indent-amount)}]
		$w tag configure indent$k -lmargin1 $amount -lmargin2 $amount
	}

	foreach k [array names ::annotation::mc::Nag] {
		$w tag bind nag$k <Any-Enter> [namespace code [list Tooltip $w $k]]
		$w tag bind nag$k <Any-Leave> [namespace code [list Tooltip $w hide]]
	}
}


proc Align {w height} {
	variable Vars

	if {$height != $Vars(height)} {
		set Vars(height) $height
		set linespace [font metrics [$Vars(pgn:0) cget -font] -linespace]
		set amounts [list $linespace [expr {$linespace - 2}] [expr {($height - 2) % $linespace}]]
		::gamebar::setAlignment $Vars(gamebar) $amounts
	}
}


proc GameBarEvent {action position} {
	variable Vars
	variable Colors

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
			}

			$Vars(panes) unmap $Vars(frame:$position)
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


proc ToggleOption {var} {
	variable Options

	set Options($var) [expr {!$Options($var)}]
	Refresh $var
}


proc ToggleLanguage {lang} {
	variable Vars

	set Vars(lang:active:$lang) [expr {!$Vars(lang:active:$lang)}]
	SetLanguages $Vars(index)
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
			set position $Vars(index)
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


proc Update {position data} {
	variable Options
	variable Vars

#set clock0 [clock milliseconds]
	set w $Vars(pgn:$position)

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
				set result [lindex $node 1]

				if {$Vars(result:$position) != $result} {
					if {[string length $Vars(last:$position)]} {
						$w mark gravity $Vars(last:$position) left
					}
					$w mark gravity m-0 left
					$w mark set current m-0
					set prevChar [$w get current-1c]
					$w delete current end
					if {$Options(paragraph-spacing)} { $w insert current \n }
					$w insert current [::util::formatResult $result] result
					$w mark gravity m-0 right
					# NOTE: the text editor has a severe bug:
					# If the char after <pos1> is a newline, the command
					# '<text> delete <pos1> <pos2>' will also delete one
					# newline before <pos1>. We should catch this case:
					if {$prevChar eq "\n"} { $w insert m-0 \n }
					if {[string length $Vars(last:$position)]} {
						$w mark gravity $Vars(last:$position) right
					}
					set Vars(result:$position) $result
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
	variable Options

	if {$level > 0} {
		if {($Options(column-style)) && [incr level -1] == 0} { return }
		set level [expr {min($level, $Options(indent-max))}]
		$w tag add indent$level $key current
	}
}


proc ProcessGoto {position w key succKey} {
	variable Vars
	variable Colors

	::move::reset

	if {$Vars(current:$position) ne $key} {
		::scidb::game::variation unfold
		foreach k $Vars(next:$position) { $w tag configure $k -background $Colors(background) }
		set Vars(next:$position) [::scidb::game::next keys $position]
		if {$Vars(active:$position) eq $key} { $w configure -cursor {} }
		if {[llength $Vars(previous:$position)]} {
			$w tag configure $Vars(previous:$position) -background $Colors(background)
		}
		$w tag configure $key -background $Colors(current)
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
			$w tag configure $k -background $Colors(next-move)
		}
		set Vars(previous:$position) $Vars(current:$position)
		[namespace parent]::board::updateMarks [::scidb::game::query marks]
		::annotation::update $key
	} elseif {$Vars(dirty:$position)} {
		set Vars(dirty:$position) 0
		after cancel $Vars(after:$position)
		set Vars(after:$position) {}
		See $position $w $key $succKey
	}
}


proc UpdateHeader {position w data} {
	variable Vars

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

	if {!$Vars(virgin:$position)} {
		$w delete 1.0 m-start
	}

	$w mark set current 1.0
	foreach line [::browser::makeOpeningLines [list $idn $pos $eco {*}$opg]] {
		set tags {}
		lassign $line content tags
		lappend tags header
		$w insert current $content $tags
	}
	$w insert current "\n"
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
	variable Options
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
				switch  [lindex $node 1] {
					0 - 1 - 2	{ set space "\n" }
					3				{ if {$Options(column-style)} { set space "\n" } else { set space " " } }
					default		{ set space " " }
				}

				$w insert current $space
			}

			space {
				set space [lindex $node 1]
				switch $space {
					" " { $w insert current " " }
					")" { $w insert current " )" }
					"s" { $w insert current "\n" }
					"e" { $w insert current "\n<$mc::EmptyGame>" empty }

					default {
						variable cursor::collapse
						variable Colors

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
							$w insert current "( " [list bracket $tag]
							$w tag bind $tag <Any-Enter> +[namespace code [list EnterBracket $w $key]]
							$w tag bind $tag <Any-Leave> +[namespace code [list LeaveBracket $w]]
							$w tag bind $tag <ButtonPress-1> [namespace code [list ToggleFold $w $key 1]]
						} else {
							$w insert current "( " bracket
						}
					}
				}
			}

			ply {
				PrintMove $position $w $level $key [lindex $node 1] $prefixAnnotation
				if {[llength $suffixAnnotation]} {
					PrintAnnotation $w $position $level $key $suffixAnnotation 0
				}
				set havePly 1
			}

			annotation {
				set prefixAnnotation [lindex $node 1]
				set suffixAnnotation [lindex $node 2]
				lappend suffixAnnotation {*}[lindex $node 3]
			}

			marks {
				set hasMarks [lindex $node 1]
				if {$hasMarks} {
					set tag marks:$key
					if {$havePly} { $w insert current " " }
					$w insert current "\u27f8" [list marks $tag]
					$w tag bind $tag <Any-Enter> +[namespace code [list EnterMark $w $tag $key]]
					$w tag bind $tag <Any-Leave> +[namespace code [list LeaveMark $w $tag]]
					$w tag bind $tag <ButtonPress-1> [namespace code [list openMarksPalette $position $key]]
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
				if {$level == 0 && !($Options(column-style))} {
					$w tag add indent1 $startPos current
				}
			}
		}
	}
}


proc InsertDiagram {position w level key data} {
	variable Options
	variable Colors
	variable Vars

	set color white

	foreach entry $data {
		switch [lindex $entry 0] {
			color { set color [lindex $entry 1] }
			break { $w insert current "\n" }

			board {
				set linespace [font metrics [$Vars(pgn:0) cget -font] -linespace]
				set borderSize 2
				set size $Options(diagram-size)
				set alignment [expr {$linespace - ((8*$size + 2*$borderSize) % $linespace)}]
				if {$alignment/2 < $Options(diagram-pad-y) - 1} { incr alignment $linespace }
				if {$alignment/2 - $Options(diagram-pad-y) >= 8} {
					incr size -1
					incr alignment -8
				}
				set pady [expr {$alignment/2}]
				set board [lindex $entry 1]
				set index 0
				set key [string map {d m} $key]
				set img $w.[string map {. :} $key]
				board::stuff::new $img $size $borderSize
				if {2*$pady < $alignment} {board::stuff::alignBoard $img $Colors(background)}
				if {$color eq "black"} { ::board::stuff::rotate $img }
				::board::stuff::update $img $board
				::board::stuff::bind $img <Button-1> [namespace code [list editAnnotation $position $key]]
				::board::stuff::bind $img <Button-3> [namespace code [list PopupMenu $w $position]]
				$w window create current \
					-align center \
					-window $img \
					-padx $Options(diagram-pad-x) \
					-pady $pady \
					;
			}
		}
	}
}


proc PrintMove {position w level key data annotation} {
	variable Options

	lassign $data moveNo stm san legal
	lappend tags $key

	if {$level > 0} {
		lappend tags variation
	} else {
		lappend tags main
	}

	if {$level == 0 && $Options(column-style)} {
		$w insert current "\t"

		if {$moveNo} {
			$w insert current $moveNo main
			$w insert current ". " main
			$w insert current "\t"
			if {$stm eq "black"} { $w insert current "...\t" main }
		} 

		if {[llength $annotation]} {
			PrintAnnotation $w $position $level $key $annotation 1
			$w insert current "\u2006"
		}
	} else {
		if {[llength $annotation]} {
			PrintAnnotation $w $position $level $key $annotation 1
			$w insert current "\u2006"
		}

		lappend tags $key

		if {$moveNo} {
			$w insert current $moveNo $tags
			$w insert current "." $tags
			if {$stm eq "black"} { $w insert current ".." $tags }
		}
	}

	foreach {text tag} [::font::splitMoves $san] {
		PrintSingleMove $position $w $key $text [list {*}$tags $tag]
	}

	if {!$legal} {
		set tags illegal
		if {$level == 0} { lappend tags main }
		$w insert current "\u26A1" $tags
		$w tag bind illegal <Any-Enter> +[namespace code [list Tooltip $w illegal]]
		$w tag bind illegal <Any-Leave> +[namespace code [list Tooltip $w hide]]
		$w tag bind illegal <ButtonPress-1> [namespace code [list GotoMove $position $key]]
	}
}


proc PrintSingleMove {position w key text tags} {
	$w insert current $text [list {*}$tags]
	$w tag bind $key <Any-Enter> [namespace code [list EnterMove $position $key]]
	$w tag bind $key <Any-Leave> [namespace code [list LeaveMove $position $key]]
	$w tag bind $key <ButtonPress-1> [namespace code [list GotoMove $position $key]]
	$w tag bind $key <ButtonPress-2> [list ::browser::showPosition $w $position $key %s]
	$w tag bind $key <ButtonRelease-2> [list ::browser::hidePosition $w]
	$w tag bind $key <Any-Button> [list ::browser::hidePosition $w]
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
					$w insert current [string map $::font::pieceMap $text] [list figurine $langTag]
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
			$w tag bind $langTag <Enter> [namespace code [list EnterComment $w $key:$pos:$lang]]
			$w tag bind $langTag <Leave> \
				[namespace code [list LeaveComment $w $position $key:$pos:$lang]]
			$w tag bind $langTag <ButtonPress-1> \
				[namespace code [list EditComment $position $key $pos $lang]]
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
					$w tag bind $keyTag <Enter> [namespace code [list EnterInfo $w $key]]
					$w tag bind $keyTag <Leave> [namespace code [list LeaveInfo $w $position $key]]
					$w tag bind $keyTag <ButtonPress-1> [namespace code [list EditInfo $w $position $key]]
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


proc PrintAnnotation {w position level key nags isPrefix} {
	variable Options

	set annotation [::font::splitAnnotation $nags]
	set pos [$w index current]
	set keyTag nag:$key
	set prevSym -1
	set count 0
	set nag ""

	foreach {value nag tag} $annotation {
		set sym [expr {$tag eq "symbol"}]
		if {$level == 0} {
			if {$sym} { set tag symbolb }
			lappend tag main
		}
		set nagTag $keyTag:[incr count]
		set c [string index $nag 0]
		if {[string is alpha $c] && [string is ascii $c]} {
			if {[lindex [split [$w index current] .] end] ne "0"} {
				if {!$isPrefix || !$Options(column-style)} {
					$w insert current " "
				}
			}
			set prevSym 1
		} elseif {$value <= 6} {
			if {$count > 1} { $w insert current "\u2005" }
			set prevSym 1
		} elseif {$value == 155 || $value == 156} {
			if {$Options(diagram-show)} {
				set nag ""
			} else {
				if {[lindex [split [$w index current] .] end] ne "0"} { $w insert current "\u2005" }
				set prevSym $sym
			}
		} elseif {!$sym && !$isPrefix} {
			$w insert current "\u2005"
			set prevSym $sym
		}
		if {[string length $nag]} {
			$w insert current $nag [list nag$value {*}$tag $nagTag]
			$w tag bind $nagTag <Enter> [namespace code [list EnterAnnotation $w $nagTag]]
			$w tag bind $nagTag <Leave> [namespace code [list LeaveAnnotation $w $nagTag]]
		}
		set prefix 0
	}

	set keyTag annotation:$key
	$w tag add nag $pos current
	$w tag raise symbol
	$w tag raise symbolb
	$w tag add $keyTag $pos current
	$w tag bind $keyTag <ButtonPress-1> [namespace code [list editAnnotation $position $key]]
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
	variable Colors

	if {$Vars(current:$position) ne $key} {
		$Vars(pgn:$position) tag configure $key -background $Colors(hilite)
		$Vars(pgn:$position) configure -cursor hand2
	}

	set Vars(active:$position) $key
}


proc LeaveMove {position key} {
	variable Vars
	variable Colors

	set Vars(active:$position) {}

	if {$Vars(current:$position) ne $key} {
		if {$key in $Vars(next:$position)} {
			set color $Colors(next-move)
		} else {
			set color $Colors(background)
		}
		$Vars(pgn:$position) tag configure $key -background $color
		$Vars(pgn:$position) configure -cursor {}
	}
}


proc EnterMark {w tag key} {
	variable Colors

	$w tag configure $tag -background $Colors(emphasized)
	::tooltip::show $w [string map {",," "," " " "\n"} [::scidb::game::query marks $key]]
}


proc LeaveMark {w tag} {
	variable Colors

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
	variable Colors
	$w tag configure comment:$key -foreground $Colors(comment:hilite)
}


proc LeaveComment {w position key} {
	variable Colors
	variable Vars

	if {!$Vars(edit:comment)} {
		$w tag configure comment:$key -foreground $Colors(comment)
	}
}


proc EnterInfo {w key} {
	variable Colors
	$w tag configure info:$key -foreground $Colors(info:hilite)
}


proc LeaveInfo {w position key} {
	variable Colors
	variable Vars

	if {!$Vars(edit:comment)} {
		$w tag configure info:$key -foreground $Colors(info)
	}
}


proc EnterAnnotation {w tag} {
	variable Colors
	$w tag configure $tag -background $Colors(emphasized)
}


proc LeaveAnnotation {w tag} {
	variable Colors
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


proc Tooltip {path nag} {
	variable ::annotation::mc::Nag

	switch $nag {
		hide		{ ::tooltip::hide }
		illegal	{ ::tooltip::show $path $::browser::mc::IllegalMove }
		
		default {
			if {[info exists Nag($nag)]} {
				::tooltip::show $path $Nag($nag)
			}
		}
	}
}


proc Undo {action} {
	variable Vars

	if {[llength [::scidb::game::query $action]]} {
#		Do not use busy cursor, because the KeyRelease event will be lost!
#		::widget::busyCursor on
		::scidb::game::execute $action
		[namespace parent]::board::updateMarks [::scidb::game::query marks]
		::annotation::update
#		::widget::busyCursor off
	}
}


proc ResetGame {position tags} {
	variable Vars
	variable Colors

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
	SetupStyle $position

	::scidb::game::subscribe pgn $position [namespace current]::Update
	::scidb::game::subscribe board $position [namespace parent]::board::update
	::scidb::game::subscribe tree $position [namespace parent]::tree::update
	::scidb::game::subscribe state $position [namespace current]::StateChanged
}


proc UpdateButtons {} {
	variable Vars

	if {[::scidb::game::query moveInfo?]} {
		::toolbar::add $Vars(button:show-move-info)
	} else {
		::toolbar::remove $Vars(button:show-move-info)
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
	variable ::scidb::clipbaseName
	variable ::scidb::scratchbaseName
	variable Options
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
			-command [list ::widget::busyOperation ::scidb::game::strip moves] \
			;
		set state "normal"
		if {	[::scidb::game::position atEnd?]
			|| (![::scidb::game::position isMainline?] && [::scidb::game::position atStart?])} {
			
			set state "disabled"
		}
		$menu.strip add command \
			-label $mc::Command(strip:truncate) \
			-state $state \
			-command [list ::widget::busyOperation ::scidb::game::strip truncate] \
			;
		foreach cmd {variations annotations info marks} {
			set state "normal"
			if {[::scidb::game::count $cmd] == 0} { set state "disabled" }
			$menu.strip add command \
				-label $mc::Command(strip:$cmd) \
				-state $state \
				-command [list ::widget::busyOperation ::scidb::game::strip $cmd] \
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
				-command [list ::widget::busyOperation ::scidb::game::strip comments] \
				;

			foreach lang $Vars(lang:set) {
				$menu.strip.comments add command \
					-compound left \
					-image $::country::icon::flag([::mc::countryForLang $lang]) \
					-label " [::encoding::languageName $lang]" \
					-command [list ::widget::busyOperation ::scidb::game::strip comments $lang] \
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
							set symbol [::font::mapNagToSymbol $nag]
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
			$menu add command \
				-label " $mc::EditCommentAfter..." \
				-image $::fsbox::bookmarks::icon::16x16::modify \
				-compound left \
				-command [namespace code [list editComment p $position]] \
				-accel "$::mc::Key(Ctrl)-[set [namespace parent]::board::mc::Accel(edit-comment)]" \
				;
			set accel "$::mc::Key(Ctrl)-$::mc::Key(Shift)-"
			append accel "[set [namespace parent]::board::mc::Accel(edit-comment)]"
			$menu add command \
				-label " $mc::EditCommentBefore..." \
				-image $::fsbox::bookmarks::icon::16x16::modify \
				-compound left \
				-command [namespace code [list editComment a $position]] \
				-accel $accel \
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
			-label "$mc::EditMoveInformation..." \
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

		if {[::scidb::game::query database] eq $::scidb::scratchbaseName} {
			$menu add command \
				-label " $::import::mc::ImportPgnGame..." \
				-image $::icon::16x16::pgn \
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
			-label $label \
			-command [namespace code [list Undo $action]] \
			-state [expr {[llength $cmd] ? "normal" : "disabled"}] \
			-accelerator $accel \
			;
	}

	$menu add separator

	if {![::game::trialMode?]} {
		lassign [::scidb::game::link? $position] base index
		unset -nocomplain state

		set actual [::scidb::db::get name]

		if {$base ne $scratchbaseName} {
			if {[::scidb::db::get open? $base] && ![::scidb::db::get readonly? $base]} {
				if {$index >= 0} { set state normal } else { set state disabled }
			} else {
				set state disabled
			}

			if {	$base eq $clipbaseName
				&& [lindex [::scidb::game::sink? $position] 0] eq $scratchbaseName} {
				set state disabled
			}

			set name [::util::databaseName $base]

			$menu add command \
				-label " [format $mc::ReplaceGame $name]" \
				-image $::icon::16x16::save \
				-compound left \
				-command [list ::dialog::save::open $parent $base $position [expr {$index + 1}]] \
				-state $state \
				-accel "$::mc::Key(Ctrl)-[set [namespace parent]::board::mc::Accel(replace-game)]" \
				;

			if {![::scidb::game::query modified?]} { set state disabled }
			$menu add command \
				-label " [format $mc::ReplaceMoves $name]" \
				-image $::icon::16x16::save \
				-compound left \
				-command [namespace code [list replaceMoves $parent]] \
				-state $state \
				-accel "$::mc::Key(Ctrl)-[set [namespace parent]::board::mc::Accel(replace-moves)]" \
				;
		}

		if {	$actual eq $scratchbaseName
			|| $actual eq $clipbaseName
			|| [::scidb::db::get readonly? $actual]} {
			set state disabled
		} else {
			set state normal
		}
		$menu add command \
			-label " [format $mc::AddNewGame [::util::databaseName $actual]]" \
			-image $::icon::16x16::saveAs \
			-compound left \
			-command [list ::dialog::save::open $parent $actual $position] \
			-state $state \
			-accel "$::mc::Key(Ctrl)-[set [namespace parent]::board::mc::Accel(add-new-game)]" \
			;

		menu $menu.save
		set count 0
		set bases [::scidb::app::bases]
		foreach base $bases {
			if {$base ne $actual && ![::scidb::db::get readonly? $base]} {
				set name [::util::databaseName $base]
				$menu.save add command \
					-label $name \
					-command [list ::dialog::save::open $parent $base $position] \
					;
				incr count
			}
		}

		if {$count} { set state normal } else { set state disabled }
		$menu add cascade \
			-menu $menu.save \
			-label " [format $mc::AddNewGame {}]" \
			-image $::icon::16x16::saveAs \
			-compound left \
			-state $state \
			;
		$menu add separator
	}

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

	foreach {label var} {ColumnStyle column-style
								UseParagraphSpacing paragraph-spacing
								ShowMoveInfo show-move-info
								BoldTextForMainlineMoves mainline-bold
								ShowDiagrams diagram-show} {
		set state normal

		$menu.display add checkbutton \
			-label [set mc::$label] \
			-onvalue 1 \
			-offvalue 0 \
			-variable [namespace current]::Options($var) \
			-command [namespace code [list Refresh $var]] \
			-state $state \
			;
	}

	menu $menu.display.languages -tearoff no
	$menu.display add cascade -menu $menu.display.languages -label $mc::Languages
	$menu.display.languages add checkbutton \
		-compound left \
		-image $::country::icon::flag([::mc::countryForLang xx]) \
		-label " $::languagebox::mc::AllLanguages" \
		-variable [namespace current]::Vars(lang:active:xx) \
		-command [namespace code [list SetLanguages $Vars(index)]] \
		;
	if {[llength $Vars(lang:set)]} { ;# not the complete set?
		foreach entry [::country::makeCountryList $Vars(lang:set)] {
			lassign $entry flag name code
			$menu.display.languages add checkbutton \
				-compound left \
				-image $flag \
				-label " $name" \
				-variable [namespace current]::Vars(lang:active:$code) \
				-command [namespace code [list SetLanguages $Vars(index)]] \
				;
		}
	}

#	$menu add separator
#
#	$menu add command -label "$SetupColors..."
#	$menu add command -label "$SetupFonts..."
#
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

	set position $Vars(index)
	::import::openEdit $Vars(frame:$position) $position game
}


proc PasteClipboardVariation {} {
	variable Vars

	set position $Vars(index)
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

	::widget::dialogButtons $dlg {ok cancel} cancel
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
	set srcCode [lindex $countryList [lsearch -index 1 $countryList $Vars(lang:src)] 2]
	set dstCode [lindex $countryList [lsearch -index 1 $countryList $Vars(lang:dst)] 2]
	::scidb::game::copy $srcCode $dstCode -strip $Vars(strip:orig)
	destroy $dlg
}


proc FoldVariations {flag} {
	variable Vars

	set position $Vars(index)
	if {$position == -1} { return }
	::scidb::game::variation fold $flag
	See $position $Vars(pgn:$position) $Vars(current:$position) $Vars(successor:$position)
}


proc TransposeGame {} {
	::game::flipTrialMode
	::widget::busyOperation ::scidb::game::transpose true
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

	::widget::busyOperation ::scidb::game::variation first $varno
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

	::widget::busyOperation ::scidb::game::variation promote $varno
	::scidb::game::moveto $key
}


proc RemoveVariation {{varno 0}} {
	if {$varno} {
		::scidb::game::position forward
	} else {
		set varno [::scidb::game::variation leave]
	}

	::widget::busyOperation ::scidb::game::variation remove $varno

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
		[list ::widget::busyOperation ::scidb::game::variation insert $varno] \
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
	::widget::dialogButtons $dlg {ok cancel} ok
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
			[list ::widget::busyOperation ::scidb::game::variation exchange $varno $Length_] \
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
	variable Options
	variable Colors
	variable Vars

	set radical ""

	if {$var eq "mainline-bold"} {
		if {$Options(mainline-bold)} {
			set mainFont $Vars(font-bold)
		} else {
			set mainFont $Options(font)
		}

		for {set i 0} {$i < 9} {incr i} {
			$Vars(pgn:$i) tag configure main -font $mainFont
		}
	}

	set Vars(current:$Vars(index)) {}
	set Vars(successor:$Vars(index)) {}
	SetupStyle

	if {$var eq "column-style" || $var eq "paragraph-spacing"} {
		for {set i 0} {$i < 9} {incr i} {
			if {$Options(column-style)} {
				$Vars(pgn:$i) configure -tabs $Vars(tabs) -tabstyle wordprocessor
			} else {
				$Vars(pgn:$i) configure -tabs {} -tabstyle tabular
			}
			set Vars(result:$i) ""
		}
	}

	if {$var eq "diagram-show"} { set radical "" } else { set radical "-radical" }
	::widget::busyOperation ::scidb::game::refresh {*}$radical
}


proc NewGame {} {
	variable Vars
	::setup::popupShuffleMenu [namespace current] $Vars(button:shuffle)
}


proc Shuffle {variant} {
	variable Vars
	::menu::gameNew $Vars(main) $variant
}


proc SetupStyle {{position {}}} {
	variable Options
	variable Vars

	set Vars(indent-max) $Options(indent-max)

	if {$Options(column-style)} {
		incr Vars(indent-max)
		set thresholds {0 0 0 0}
	} else {
		set thresholds {240 80 60 0}
	}

	::scidb::game::setup {*}$position \
		{*}$thresholds \
		$Options(column-style) \
		$Options(paragraph-spacing) \
		$Options(diagram-show) \
		$Options(show-move-info) \
		;
}


proc LanguageChanged {} {
	variable Vars 

	foreach position [::game::usedPositions?] {
		if {[::scidb::game::query $position length] == 0} {
			::scidb::game::refresh $position -radical
		} else {
			set w $Vars(pgn:$position)
			$w configure -state normal
			UpdateHeader $position $w $Vars(header:$position)
			$w configure -state disabled
		}
	}

	::toolbar::childconfigure $Vars(button:new) -tooltip $::gamebar::mc::GameNew
	::toolbar::childconfigure $Vars(button:shuffle) \
		-tooltip "${::gamebar::mc::GameNew}: $::setup::board::mc::Shuffle"
}


proc SaveGame {mode} {
	variable ::scidb::clipbaseName
	variable Vars

	set position [::gamebar::selected $Vars(gamebar)]
	set base [::scidb::db::get name]

	if {$base eq $clipbaseName} { return }
	if {[::scidb::db::get readonly? $base]} { return }


	switch $mode {
		add {
			::dialog::save::open $Vars(main) $base $position
		}

		replace {
			lassign [::scidb::game::link? $position] _ index
			::dialog::save::open $Vars(main) $base $position [expr {$index + 1}]
		}

		moves {
			replaceMoves $Vars(main)
		}
	}
}


proc WriteOptions {chan} {
	variable Vars

#	::options::writeItem $chan [namespace current]::Colors
	::options::writeItem $chan [namespace current]::Options
}


::options::hookWriter [namespace current]::WriteOptions


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

#set collapse [image create photo -data {
#	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABmJLR0QA/wD/AP+gvaeTAAAA
#	CXBIWXMAAABIAAAASABGyWs+AAAB7UlEQVQoz1WQvWsTYQCHn/feu9zl0qSXi59E6wetBbU4
#	itTFqTSCk1D8F3TwHxBH3QUdHOzg5FhXRVFBWkFQaMQ2Hayp1djmq7nk7s3l7nVoF4ff+PB7
#	eMRCGW7NT/J1rTExMz1z55CTXxBKnYp6XTrd3c1G9++LHaUee/BzS4JYvHmGRndv6srM7JOy
#	zlzrf6/KQatJmqaQseg7MtlSnbdbYXB73KQmjyWd4tXzlx6dHsnrjQ9vjN7vbUaqT6IGJL2A
#	TDQ0CuP+2aEYlTfC+JUxfcKvHMWaa335RDzoIyUYAgzAMCBVEZl2m+NOYe6wScXMm3ZFtJu5
#	OApwz00hsi460QAIKdDhgLj+g3wqcmOWXTETFfqptrB8n8kHz7FPTaKT9AAwUJsbbNy9AUJj
#	CMM3lYriWLqYgz3+LD5Eej6agwcESaeFHuyhC0USrWOzGQ6XA1fPl7Q2e6+X0IAW7AMaBCCz
#	Nh3BqBkOl41akC7Vo3418UqYjsQ0+X+2JCmWqEf9ai1Il+Rqi92JMdXK2ubseMHLZ4RGGiBN
#	iXCyKK9ETYXbn3e7956t8076OXi/zZpnR+uxkRxJHLeo3LwVOG7aEEb3W9D7uLLTu/90jZd+
#	jvTAdl/5gk/5osflMYuTAEFMfbXNSrXNL9gv8Q+fYd/xb8HXjAAAAABJRU5ErkJggg==
#}]

} ;# namespace 12x12

namespace eval 104x30 {

set logo [image create photo -data {
	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
	5+6xMI//AruNNzmyEcKFAAAAAElFTkSuQmCC
}]

} ;# namespace 104x30
} ;# namespace icon
} ;# namespace pgn
} ;# namespace application

# vi:set ts=3 sw=3:
