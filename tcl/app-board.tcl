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
# Copyright: (C) 2009-2018 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source board-pane

namespace eval application {
namespace eval board {
namespace eval mc {

set ShowCrosstable			"Show tournament table for this game"
set StartEngine				"Start chess analysis engine in new window"
set InsertNullMove			"Insert null move"
set SelectStartPosition		"Select Start Position"
set LoadRandomGame			"Load random game"
set AddNewGame					"Add New Game..."
set SlidingVarPanePosition	"Sliding variation pane position"
set ShowVariationArrows		"Show variation arrows"
set ShowAnnotation			"Show annotation glyph"
set ShowAnnotationTimeout	"Timeout for annotation glyph"
set None							"None"

set MarkPromotedPiece		"Use mark for promoted pieces"
set PromoSign(none)			"None"
set PromoSign(bullet)		"Bullet"
set PromoSign(star)			"Star"
set PromoSign(disk)			"Disk"

set Tools						"Tools"
set Control						"Control"
set Game							"Game"
set GoIntoNextVar				"Go into next variation"
set GoIntPrevVar				"Go into previous variation"

set LoadGame(next)			"Load next game"
set LoadGame(prev)			"Load previous game"
set LoadGame(first)			"Load first game"
set LoadGame(last)			"Load last game"
set LoadFirstLast(next)		"End of list reached, continue with first game?"
set LoadFirstLast(prev)		"Start of list reached, continue with last game?"

set SwitchView(base)			"Switch to database view"
set SwitchView(list)			"Switch to game list view"

set Accel(edit-annotation)	"A"
set Accel(edit-comment)		"C"
set Accel(edit-marks)		"M"
set Accel(add-new-game)		"S"
set Accel(replace-game)		"R"
set Accel(replace-moves)	"V"
set Accel(trial-mode)		"T"
set Accel(export-game)		"E"
set Accel(import-game)		"I"

} ;# namespace mc

namespace import ::tcl::mathfunc::max
namespace import ::tcl::mathfunc::min
namespace import ::tcl::mathfunc::abs

variable board {}

variable Vars
variable Dim
variable Layouts {Normal ThreeCheck Crazyhouse}

set Defaults(coords-font-family) [font configure TkDefaultFont -family]

array set Options {
	variations:arrows		0
	show:annotation		0
	annotation:timeout	1500
	promoted:mark			bullet
}


proc build {w width height} {
	variable Dim
	variable Vars
	variable Options
	variable Layouts
	variable board
	variable mc::Accel

	set Vars(variant) Normal
	set Vars(layout) Normal
	set Vars(initialized) 0
	set Vars(afterid:switched) {}

	pack [set canv [tk::canvas $w.c -takefocus 1 -borderwidth 0]] -fill both -expand yes
	$canv xview moveto 0
	$canv yview moveto 0
	SetBackground $canv window $width $height
	set border [tk::canvas $canv.border -takefocus 0 -borderwidth 0]
	$border xview moveto 0
	$border yview moveto 0
	Preload $width [expr {$height - [[winfo parent $w] get $w Extent 74] + 2}]
	set board [::board::diagram::new $border.diagram $Dim(squaresize) \
		-bordersize $Dim(edgethickness) \
		-bordertype lines \
		-promosign $Options(promoted:mark) \
		-targets $board $border $canv \
	]
	set boardc [::board::diagram::canvas $board]
	::variation::build $canv [namespace code SelectAlternative]

	set family [font configure TkTextFont -family]
	set size [font configure TkTextFont -size]
	if {$size < 0} { incr size -6 } else { incr size 6 }
	set Vars(annotation) ""
	tk::label $canv.annotation \
		-textvar [namespace current]::Vars(annotation) \
		-takefocus 0 \
		-borderwidth 1 \
		-relief solid \
		-background yellow \
		-foreground darkred \
		-font [list $family $size normal] \
		;
	$canv create window 0 0 -anchor ne -window $canv.annotation -state hidden -tags annotation

	set pieces {q r b n p}
	set Vars(holding:w) \
		[::board::holding::new $canv.holding-w w $Dim(squaresize) $pieces $boardc $border $canv]
	set Vars(holding:b) \
		[::board::holding::new $canv.holding-b b $Dim(squaresize) $pieces $boardc $border $canv]
	::bind $Vars(holding:w) <<InHandSelection>> { ::move::inHandSelected %W %d }
	::bind $Vars(holding:b) <<InHandSelection>> { ::move::inHandSelected %W %d }
	::bind $Vars(holding:w) <<InHandPieceDrop>> { ::move::inHandPieceDrop %W %x %y %s %d }
	::bind $Vars(holding:b) <<InHandPieceDrop>> { ::move::inHandPieceDrop %W %x %y %s %d }
	::bind $Vars(holding:w) <<InHandDropPosition>> { ::move::inHandDropPosition %W %x %y %s %d }
	::bind $Vars(holding:b) <<InHandDropPosition>> { ::move::inHandDropPosition %W %x %y %s %d }
	$canv create window 0 0 -window $border -anchor nw -tag board
	$border create window 0 0 -window $board -anchor nw -tag board
	set Vars(widget:border) $border
	set Vars(widget:frame) $canv
	set Vars(autoplay) 0
	set Vars(active) 0
	set Vars(material) {}
	set Vars(registered:0) {}
	set Vars(registered:1) {}
	set Vars(subscribe:list) {}
	set Vars(subscribe:info) {}
	set Vars(current:game) {}
	set Vars(load:method) base
	set Vars(select-var-is-pending) 0
	set Vars(width) $width
	set Vars(height) $height
	set Vars(dimensions) ${width}x${height}
	foreach layout $Layouts {
		set Vars(inuse:$layout) {}
		set Vars(registered:$layout) 0
		set Vars(registered:$layout) 0
	}

	$board configure -cursor crosshair
	::bind $canv <Configure> [namespace code { ConfigureWindow %W %w %h }]
	::bind $canv <Destroy> [namespace code [list activate $w 0]]
	::bind $canv <FocusIn> [namespace code { GotFocus %W }]
	::bind $canv <FocusOut> [namespace code LostFocus]
	::bind $canv <Any-Button> { ::variation::hide; ::move::cancelVariation }
	::bind $canv <<FontSizeChanged>> [list after idle [namespace code Redraw]]

	foreach {bind canvas} [list ::bind $canv ::bind $border ::board::diagram::bind $board] {
		if {[tk windowingsystem] eq "x11"} {
			$bind $canvas <Button-4> [namespace code [list goto -1]]
			$bind $canvas <Button-5> [namespace code [list goto +1]]
		} else {
			$bind $canvas <MouseWheel> [namespace code [list goto [expr {%D < 0 ? +1 : -1}]]]
		}
	}

	::board::diagram::bind $board all <Enter>					{ ::move::enterSquare %q }
	::board::diagram::bind $board all <Leave>					{ ::move::leaveSquare %q }
	::board::diagram::bind $board all <ButtonPress-1>		{ ::move::pressSquare %q %s }
	::board::diagram::bind $board all <ButtonPress-1>		{+::focus %W }
	::board::diagram::bind $board all <ButtonPress-2>		{ ::move::nextGuess %X %Y }
	::board::diagram::bind $board all <ButtonRelease-1>	{ ::move::releaseSquare %X %Y %s }
	::board::diagram::bind $board all <Button1-Motion>		{ ::move::dragPiece %X %Y %s }

	::board::diagram::bind $board all <Control-ButtonPress-1>	{ ::marks::pressSquare %X %Y }
	::board::diagram::bind $board all <Control-ButtonPress-1>	{+::move::disable }
	::board::diagram::bind $board all <Control-ButtonRelease-1>	{ ::marks::unpressSquare }

	::bind .application <<ControlOn>>	{ ::move::disable }
	::bind .application <<ControlOff>>	{ ::move::enable %X %Y }
	::bind .application <<ControlOff>>	{+::marks::releaseSquare }
	::bind .application <FocusOut>		{ ::move::enable }
	::bind .application <FocusOut>		{+::marks::releaseSquare }
	::bind .application <FocusOut>		+[namespace code LostFocus]

	::board::diagram::update $board standard
	::board::unregisterSize $Dim(squaresize)

	set tbTools		[::toolbar::toolbar $w \
							-hide 1 \
							-id board-tools \
							-tooltipvar [namespace current]::mc::Tools \
						]
	set tbLayout	[::toolbar::toolbar $w \
							-hide 1 \
							-id board-layout \
							-tooltipvar ::mc::Layout \
						]
	set tbControl	[::toolbar::toolbar $w \
							-hide 1 \
							-id board-control \
							-tooltipvar [namespace current]::mc::Control \
							-side bottom \
							-alignment center \
						]
	set tbGame		[::toolbar::toolbar $w \
							-hide 1 \
							-id board-game \
							-tooltipvar [namespace current]::mc::Game \
							-side top \
						]

#	::toolbar::add $tbTools button -image $::icon::toolbarGameList			-command {}
#	::toolbar::add $tbTools button -image $::icon::toolbarGameNotation	-command {}
#	::toolbar::add $tbTools button -image $::icon::toolbarMaintenance		-command {}
#	::toolbar::add $tbTools button -image $::icon::toolbarEcoBrowser		-command {}
#	::toolbar::add $tbTools button -image $::icon::toolbarTreeWindow		-command {}

	set Vars(crossTable) [::toolbar::add $tbTools button \
		-image $::icon::toolbarCrossTable \
		-command [namespace code [list ShowCrossTable [winfo toplevel $board]]] \
		-tooltipvar [namespace current]::mc::ShowCrosstable \
	]
	::toolbar::add $tbTools button \
		-image $::icon::toolbarEngine \
		-command [list ::engine::openSetup .application] \
		-tooltipvar [namespace current]::mc::StartEngine \
		;

	::toolbar::add $tbLayout button \
		-image $::icon::toolbarRotateBoard \
		-tooltipvar ::overview::mc::RotateBoard \
		-command [namespace code [list Rotate $canv]]
		;
	::toolbar::add $tbLayout checkbutton \
		-image $::icon::toolbarSuggestion \
		-variable ::board::hilite(show-suggested) \
		-tooltipvar ::board::options::mc::ShowSuggestedMove \
		;
	::toolbar::add $tbLayout checkbutton \
		-image $::icon::toolbarSideToMove \
		-variable ::board::layout(side-to-move) \
		-tooltipvar ::board::options::mc::ShowSideToMove \
		-command [namespace code Apply] \
		;

	set Vars(game:prev) [::toolbar::add $tbGame button \
		-image $::icon::toolbarPrev \
		-command [namespace code [list LoadGame(any) $w prev]] \
		-state disabled \
	]
	set Vars(game:next) [::toolbar::add $tbGame button \
		-image $::icon::toolbarNext \
		-command [namespace code [list LoadGame(any) $w next]] \
		-state disabled \
	]
	set Vars(game:first) [::toolbar::add $tbGame button \
		-image $::icon::toolbarFront \
		-command [namespace code [list LoadGame(any) $w first]] \
		-state disabled \
	]
	set Vars(game:last) [::toolbar::add $tbGame button \
		-image $::icon::toolbarBack \
		-command [namespace code [list LoadGame(any) $w last]] \
		-state disabled \
	]
	set Vars(game:view) [::toolbar::add $tbGame button \
		-image $::icon::toolbarDatabase \
		-command [namespace code SwitchGameButtons] \
		-tooltipvar [namespace current]::mc::SwitchView(list) \
	]
	set Vars(game:random) [::toolbar::add $tbGame button \
		-image $::icon::toolbarDiceGreen \
		-command [namespace code [list LoadGame(any) $w random]] \
		-tooltipvar [namespace current]::mc::LoadRandomGame \
		-state disabled \
	]
	::toolbar::addSeparator $tbGame
	set Vars(game:replace) [::toolbar::add $tbGame button \
		-image $::icon::toolbarSave \
		-command [namespace code [list SaveGame replace]] \
		-state disabled \
	]
	set Vars(game:save) [::toolbar::add $tbGame dropdownbutton \
		-image $::icon::toolbarSaveAs \
		-command [namespace code [list SaveGame add]] \
		-arrowttipvar [namespace current]::mc::AddNewGame \
		-state disabled \
		-menucmd ::gamebar::addDestinationsForSaveToMenu \
	]

	foreach {action key} {	GotoStart start
									FastBack  -10
									Back      -1
									Fwd       +1
									FastFwd   +10
									GotoEnd   end} {
		set Vars(control:[string tolower $action 0]) \
			[::toolbar::add $tbControl button \
				-state disabled \
				-image [set ::icon::toolbarCtrl${action}] \
				-command [namespace code [list Goto $key]] \
			]
	}

	::toolbar::addSeparator $tbControl
	set Vars(control:enterVar) [::toolbar::add $tbControl button \
		-state disabled \
		-image [set ::icon::toolbarCtrlEnterVar] \
		-command [namespace code { Goto down }]]
	set Vars(control:leaveVar) [::toolbar::add $tbControl button \
		-state disabled \
		-image [set ::icon::toolbarCtrlLeaveVar] \
		-command [namespace code { Goto up }]]

	needBinding $Vars(widget:border)
	needBinding $Vars(widget:frame)
	needBinding $Vars(holding:w)
	needBinding $Vars(holding:b)
	needBinding [::board::diagram::canvas $board]

	foreach w $Vars(need-binding) {
		::font::addChangeFontSizeBindings editor $w ::application::pgn::fontSizeChanged
	}
	
	bind <Key-space>				::move::nextGuess
	bind <Left>						[namespace code { Goto -1 }]
	bind <Right>					[namespace code { Goto +1 }]
	bind <Prior>					[namespace code { Goto -10 }]
	bind <Next>						[namespace code { Goto +10 }]
	bind <Home>						[namespace code { Goto start }]
	bind <End>						[namespace code { Goto end }]
	bind <Down>						[namespace code { Goto down }]
	bind <Up>						[namespace code { Goto up }]
	bind <Control-Down>			[namespace code [list LoadGame(any) $w next]]
	bind <Control-Up>				[namespace code [list LoadGame(any) $w prev]]
	bind <Control-Home>			[namespace code [list LoadGame(any) $w first]]
	bind <Control-End>			[namespace code [list LoadGame(any) $w last]]
	bind <Shift-Up>				[list [namespace parent]::pgn::scroll -1 units]
	bind <Shift-Down>				[list [namespace parent]::pgn::scroll +1 units]
	bind <Shift-Prior>			[list [namespace parent]::pgn::scroll -1 pages]
	bind <Shift-Next>				[list [namespace parent]::pgn::scroll +1 pages]
	bind <Shift-Home>				[list [namespace parent]::pgn::scroll -9999 pages]
	bind <Shift-End>				[list [namespace parent]::pgn::scroll +9999 pages]
	bind <Control-0>				[namespace code InsertNullMove]
	bind <<Undo>>					[namespace parent]::pgn::undo
	bind <<Redo>>					[namespace parent]::pgn::redo
	bind <BackSpace>				[namespace parent]::pgn::undoLastMove
	bind <Delete>					[list ::scidb::game::strip truncate]
	bind <ButtonPress-3>			[namespace code { PopupMenu %W }]
	bind <<LanguageChanged>>	[namespace code LanguageChanged]
	bind <F1>						[list ::help::open .application]
	bind <F5>						[list ::move::nextVariation]

	set tl [winfo toplevel $w]

	# the Alt-Key binding isn't working, so do it by hand
	set cmd [list tk::AltKeyInDialog $tl %A]
	for {set i 0} {$i < 26} {incr i} {
		set c [::util::intToChar $i]
		bind <Alt-Key-$c> $cmd
		bind <Alt-Key-[string tolower $c]> $cmd
	}

	bind <Alt-Key-s> [list ::application::pgn::showDiagram %W %K %s]
	bind <Alt-Key-S> [list ::application::pgn::showDiagram %W %K %s]

	# for sliding pane
	foreach key {Escape Return Shift-Left Shift-Right} { bind <$key> {} }

	# for sliding pane
	for {set i 0} {$i <= 35} {incr i} {
		if {$i < 10} {
			bind <Key-$i> {}
			bind <Key-KP_$i> {}
		} else {
			set k [::util::intToChar [expr {$i - 10}]]
			bind <Key-$k> {}
			bind <Key-[string tolower $k]> {}
		}
	}

	for {set i 1} {$i <= 9} {incr i} {
		bind <Control-Key-$i>    [namespace code [list [namespace parent]::pgn::selectAt [expr {$i - 1}]]]
		# NOTE: the working of the following depends on actual keyboard bindings!
		bind <Control-Key-KP_$i> [namespace code [list [namespace parent]::pgn::selectAt [expr {$i - 1}]]]
	}

	set Vars(after) {}
	foreach key [array names Accel] { set Vars(key:$key) $Accel($key) }

	set Vars(cmd:edit-annotation)		[namespace parent]::pgn::editAnnotation
	set Vars(cmd:edit-comment)			[list [namespace parent]::pgn::editComment after]
	set Vars(cmd:shift:edit-comment)	[list [namespace parent]::pgn::editComment before]
	set Vars(cmd:edit-marks)			[namespace parent]::pgn::openMarksPalette
	set Vars(cmd:add-new-game)			[namespace code [list SaveGame add]]
	set Vars(cmd:replace-game)			[namespace code [list SaveGame replace]]
	set Vars(cmd:replace-moves)		[namespace code [list SaveGame moves]]
	set Vars(cmd:trial-mode)			[namespace parent]::pgn::flipTrialMode
	set Vars(cmd:import-game)			[list [namespace parent]::pgn::importGame no]
	set Vars(cmd:shift:import-game)	[list [namespace parent]::pgn::importGame yes]
	set Vars(cmd:export-game)			[list ::gamebar::exportGame .application]

	BuildBoard $canv
	ConfigureBoard $canv

	::scidb::db::subscribe gameSwitch [namespace current]::GameSwitched
	::scidb::db::subscribe gameClose [namespace current]::GameClosed
	::scidb::db::subscribe databaseSwitch [namespace current]::DatabaseSwitched
	::scidb::db::subscribe dbInfo [namespace current]::UpdateInfo
}


proc activate {w flag} {
	variable Vars

	if {![winfo exists $w]} { return }

	set Vars(active) $flag
	::toolbar::activate $w $flag

	if {$flag} {
		focus $Vars(widget:frame)
	}

	[namespace parent]::pgn::activate $w $flag
	set Vars(initialized) 1
}


proc closed {w} {
	# should only happen after shutdown
}


proc setActive {flag} {
	variable Vars

	::move::enable ;# required here because <<ControlOff>> might fail
	::marks::releaseSquare

#	if {$flag && $Vars(active) && [focus] ne $Vars(widget:frame)} {
#		setFocus
#	}
}


proc setFocus {} {
	focus [set [namespace current]::Vars(widget:frame)]
}


proc active? {} {
	return [set [namespace current]::Vars(active)]
}


proc goto {step} {
	variable Vars

	set Vars(select-var-is-pending) 0
	::variation::hide
	::move::cancelVariation
	::scidb::game::go -1 $step

	if {$Vars(autoplay)} {
		if {[::scidb::game::position -1 atEnd?]} {
			ToggleAutoPlay
		} else {
			variable ::browser::Options
			after cancel $Vars(afterid)
			set Vars(afterid) [after $Options(autoplayDelay) [namespace code { goto +1 }]]
		}
	}
}


proc deselectInHandPiece {} {
	variable Vars

	::board::holding::deselect $Vars(holding:w)
	::board::holding::deselect $Vars(holding:b)
}


proc finishDrop {} {
	variable Vars

	set color [::scidb::game::query stm]
	::board::holding::finishDrop $Vars(holding:[string index $color 0])
}


proc update {position cmd data promoted} {
	variable ::board::layout
	variable board
	variable Vars

	switch $cmd {
		set	{ ::board::diagram::update $board $data $promoted }
		move	{ ::board::diagram::move $board $data }
	}

	set Vars(select-var-is-pending) 0
	::board::diagram::clearMarks $board
	UpdateSideToMove $Vars(widget:frame)
	DrawMaterialValues $Vars(widget:frame)
	DrawChecks $Vars(widget:frame)
	UpdateControls
	::variation::hide 0
	::move::cancelVariation
}


proc updateMarks {marks} {
	variable board
	variable Vars

	::board::diagram::updateMarks $board $marks
	if {!$Vars(autoplay)} {
		::move::leaveSquare
		::move::enterSquare
	}
}


proc rotated? {} {
	variable board
	return [::board::diagram::rotated? $board]
}


proc bind {key cmd} {
	variable Vars

	foreach w $Vars(need-binding) {
		::bind $w $key [namespace code [list FilterKey %K %s $cmd]]
		::bind $w $key {+ break }
	}
}


proc unbindGameControls {position base variant} {
	variable Vars

	Unsubscribe $position
	set Vars(current:game) {}
	UpdateGameButtonState(list) $position
}


proc needBinding {w} {
	variable Vars
	lappend Vars(need-binding) $w
}


proc bindKeys {} {
	variable Vars
	variable mc::Accel

	foreach key [array names Accel] {
		bind <Control-[string tolower $Vars(key:$key)]> {}
		bind <Control-[string toupper $Vars(key:$key)]> {}
	}

	bind <Control-Shift-[string tolower $Vars(key:edit-comment)]> {}
	bind <Control-Shift-[string toupper $Vars(key:edit-comment)]> {}
	bind <Control-Shift-[string tolower $Vars(key:import-game)]> {}
	bind <Control-Shift-[string toupper $Vars(key:import-game)]> {}

	foreach key [array names Accel] {
		bind <Control-[string tolower $Accel($key)]> $Vars(cmd:$key)
		bind <Control-[string toupper $Accel($key)]> $Vars(cmd:$key)
		set Vars(key:$key) $Accel($key)
	}

	bind <Control-Shift-[string tolower $Accel(edit-comment)]> $Vars(cmd:shift:edit-comment)
	bind <Control-Shift-[string toupper $Accel(edit-comment)]> $Vars(cmd:shift:edit-comment)

	bind <Control-Shift-[string tolower $Accel(import-game)]> $Vars(cmd:shift:import-game)
	bind <Control-Shift-[string toupper $Accel(import-game)]> $Vars(cmd:shift:import-game)

	foreach {action key tipvar} {	GotoStart	Home	GotoStartOfGame
											FastBack		Prior	GoBackFast
											Back			Left	GoBackward
											Fwd			Right	GoForward
											FastFwd		Next	GoForwardFast
											GotoEnd		End	GotoEndOfGame} {
		set tip "[set ::browser::mc::$tipvar] ($::mc::Key($key))"
		::toolbar::childconfigure $Vars(control:[string tolower $action 0]) -tooltip $tip
	}

	foreach {action key tipvar} {	EnterVar		Down	GoIntoNextVar
											LeaveVar		Up		GoIntPrevVar} {
		set tip "[set mc::$tipvar] ($::mc::Key($key))"
		::toolbar::childconfigure $Vars(control:[string tolower $action 0]) -tooltip $tip
	}

	foreach {action key} {next Down prev Up first Home last End} {
		set tip $mc::LoadGame($action)
		append tip " (" $::mc::Key(Ctrl) "-" $::mc::Key($key) ")"
		::toolbar::childconfigure $Vars(game:$action) -tooltip $tip
	}
}


proc FilterKey {key state cmd} {
	variable Vars

	switch [::variation::handle $key $state] {
		0 {
			::variation::hide
			::move::cancelVariation
			if {[llength $cmd]} { {*}$cmd }
		}

		1 {
			set Vars(select-var-is-pending) 0
		}

		2 {
			set Vars(select-var-is-pending) 0
			if {[llength $cmd]} {
				if {[string match {* Goto +1 *} $cmd]} {
					goto +1
				} else {
					{*}$cmd
				}
			}
		}
	}
}


proc Goto {step} {
	variable Options
	variable Vars
	variable board

	if {	$step == +1
		&& !$Vars(select-var-is-pending)
		&& ([::variation::use?] || $Options(variations:arrows))
		&& [llength [set vars [::scidb::pos::nextMoves]]] > 1} {
		set rvars [list {*}[lrange $vars 1 end] [lindex $vars 0]]
		if {$Options(variations:arrows)} {
			# draw main line last, a variation should not overlap the main line
			set Vars(select-var-is-pending) 1
			set i 1
			foreach entry $rvars {
				lassign $entry _ from to
				if {$i == 0} { set color yellow } else { set color greenyellow }
				set cmd [namespace code [list SelectAlternative $i]]
				::board::diagram::drawAlternative $board $from $to $color $cmd
				if {[incr i] == [llength $vars]} { set i 0 }
			}
		}
		if {[::variation::use?]} {
			$Vars(widget:frame) itemconfigure annotation -state hidden
			set moves {}
			foreach entry $vars { lappend moves [::font::translate [lindex $entry 0]] }
			::variation::show $moves
			return
		}
		::move::cancelVariation
	} else {
		set Vars(select-var-is-pending) 0
		goto $step
	}

	if {$step == +1 && $Options(show:annotation)} {
		ShowAnnotation
	}
}


proc ShowAnnotation {} {
	variable Vars
	variable Options

	set text ""
	lassign [::scidb::game::query annotation] prf inf suf

	foreach list {prf inf suf} {
		foreach nag [set $list] {
			set nag [string range $nag 1 end]
			set t [::font::mapNagToUtfSymbol $nag]
			if {$nag != $t && [string length $text] == 0} {
				set text $t
			}
		}
	}

	if {[string length $text]} {
		set Vars(annotation) $text
		$Vars(widget:frame) itemconfigure annotation -state normal
		if {$Options(annotation:timeout) > 0} {
			after $Options(annotation:timeout) \
				[list $Vars(widget:frame) itemconfigure annotation -state hidden]
		}
	} else {
		$Vars(widget:frame) itemconfigure annotation -state hidden
	}
}


proc SelectAlternative {index} {
	variable Options

	if {$index >= 0 && $index <= [::scidb::game::count variations]} {
		if {$index > 0} { ::scidb::game::go variation [expr {$index - 1}] }
		::scidb::game::go +1
		if {$Options(show:annotation)} { ShowAnnotation }
	}
}


proc LoadGame(any) {w incr} {
	LoadGame([set [namespace current]::Vars(load:method)]) $w $incr
}


proc LoadGame(list) {w incr} {
	variable Vars

	if {[llength $Vars(current:game)] > 1} {
		::widget::busyCursor on
		set number [LoadGame(all) $w {*}$Vars(current:game) $incr]
		lset Vars(current:game) 4 $number
		UpdateGameButtonState(list) [lindex $Vars(current:game) 0]
		::widget::busyCursor off
	}
}


proc LoadGame(base) {w incr} {
	::widget::busyCursor on
	set position [::scidb::game::current]
	lassign [::scidb::game::link? $position] base variant index
	set variant [::util::toMainVariant $variant]
	set currentBase [::scidb::db::get name]
	set currentVariant [::scidb::app::variant]

	if {$index >= 0 && $currentBase eq $base && $currentVariant eq $variant} {
		set number [::scidb::db::get gameNumber $base $variant $index -1]
	} else {
		set number -1
	}

	set n [LoadGame(all) $w $position $currentBase $currentVariant -1 $number $incr]
	UpdateGameButtonState(base) $currentBase $currentVariant
	::widget::busyCursor off
}


proc LoadGame(all) {w position base variant view number incr} {
	variable Vars

	set numGames [scidb::view::count games $base $variant $view]
	if {$numGames == 0} { return }

	if {$view >= 0} {
		set prevNumber $number
		set number [scidb::game::view $position $incr]
		if {$number == -1} {
			set number [::scidb::db::get gameNumber $base $variant 0 $view]
			if {$prevNumber == $number} {
				set number [::scidb::db::get gameNumber $base $variant [expr {$numGames - 1}] $view]
			}
			return [LoadFirstLastGame $w $base $variant $view $number $incr]
		}
	} else {
		if {$incr eq "random"} {
			if {$numGames == 1} {
				set index 0
			} elseif {$number == -1} {
				set index [expr {min($numGames - 1, int(rand()*$numGames))}]
			} else {
				set index [::scidb::db::get gameIndex $number $view $base $variant]
				do { set i [expr {min($numGames - 1, int(rand()*$numGames))}] } while {$i == $index}
				set index $i
			}
		} elseif {$number == -1} {
			switch $incr {
				next - first	{ set index 0 }
				prev - last		{ set index [expr {$numGames - 1}] }
			}
		} else {
			if {$numGames <= 1} { return }
			set index [::scidb::db::get gameIndex $number $view $base $variant]
			if {$index == -1} { return }

			switch $incr {
				next	{ incr index +1 }
				prev	{ incr index -1 }
				first { set index 0 }
				last  { set index [expr {$numGames - 1}] }
			}

			if {$index < 0 || $numGames <= $index} {
				if {$index < 0} { set index [expr {$numGames - 1}] } else { set index 0 }
				set number [::scidb::db::get gameNumber $base $variant $index $view]
				return [LoadFirstLastGame $w $base $variant $view $number $incr]
			}
		}

		set number [::scidb::db::get gameNumber $base $variant $index $view]
	}

	return [LoadGame(single) $w $base $variant $view $number]
}


proc LoadGame(single) {w base variant view number} {
	if {[::scidb::tree::isRefBase? $base] && $view == [::scidb::tree::view]} {
		set fen [::scidb::tree::position]
	} else {
		set fen ""
	}
	::game::new .application -base $base -variant $variant -view $view -number $number -fen $fen
	return $number
}


proc LoadFirstLastGame {w base variant view number incr} {
	if {[::dialog::question \
			-parent $w \
			-message [set [namespace current]::mc::LoadFirstLast($incr)]] eq "yes"} {
		return [LoadGame(single) $w $base $variant $view $number]
	}
}


proc SwitchView {view} {
	variable Vars

	if {$Vars(load:method) ne $view} {
		set v $Vars(load:method)
		set Vars(load:method) $view
		::toolbar::childconfigure $Vars(game:view) -tooltipvar [namespace current]::mc::SwitchView($v)

		switch $view {
			list {
				UpdateGameButtonState(list) [::scidb::game::current]
				::toolbar::childconfigure $Vars(game:view) -image $::icon::toolbarList
			}
			base {
				UpdateGameButtonState(base) [::scidb::db::get name] [::scidb::app::variant]
				::toolbar::childconfigure $Vars(game:view) -image $::icon::toolbarDatabase
			}
		}
	}
}


proc SwitchGameButtons {} {
	variable Vars

	if {$Vars(load:method) eq "list"} { set view base } else { set view list }
	SwitchView $view
}


proc GotFocus {w} {
	variable Vars

	# we have to skip the focus if no game is open
	if {[::application::pgn::empty?]} { focus [::tk_focusNext $w] }
	set Vars(select-var-is-pending) 0
	::variation::hide 0
	::move::cancelVariation
	::move::enable
}


proc LostFocus {} {
	variable Vars

	set Vars(select-var-is-pending) 0
	::variation::hide 0
	::move::cancelVariation
}


proc Preload {width height} {
	variable ::board::layout
	variable Attr
	variable Dim

	set Dim(bordersize) 0
	set Dim(fontsize) 0
	ComputeLayout $width $height

	::board::registerSize $Dim(squaresize)
	::board::setupSquares $Dim(squaresize)
	::board::setupPieces $Dim(squaresize)
	::board::pieceset::registerFigurines $Dim(piece:size) $layout(material-bar)
	::board::pieceset::registerFigurines $Dim(piece:size) 0
}


proc ConfigureWindow {w width height} {
	variable Vars

	if {$width <= 1 || $height <= 1} { return }

	set Vars(width) $width
	set Vars(height) $height

	if {[::twm::frozen?]} {
		if {$Vars(initialized)} { SetBackground $Vars(widget:frame) window $width $height }
		return
	}

	if {$Vars(initialized)} {
		set parent [winfo parent $w]
		[winfo parent $parent] set $parent Extent [expr {[winfo height $parent] - $height}]
		after cancel $Vars(after)
		if {$Vars(initialized) == 1} {
			set timeout 300
			set Vars(initialized) 2
		} else {
			set timeout 100
		}
		set Vars(after) [after $timeout [namespace code [list RebuildBoard $w $width $height]]]
	}
}


proc afterTWM {} {
	variable Vars

	if !{[winfo exists $Vars(widget:frame)]} { return }
	ConfigureWindow $Vars(widget:frame) $Vars(width) $Vars(height)
}


proc SetBackground {canv which {width 0} {height 0}} {
	variable ::board::colors

	if {[llength $colors(hint,background-color)]} {
		$canv configure -background $colors(hint,background-color)
	} else {
		::theme::configureBackground $canv
	}
	::board::setBackground $canv window $width $height
}


proc PopupMenu {w} {
	variable Options
	variable Vars
	variable board

	set m $w.popup_menu
	if {[winfo exists $m]} { destroy $m }
	menu $m -tearoff false
	catch { wm attributes $m -type popup_menu }

	$m add command \
		-compound left \
		-image $::icon::16x16::rotateBoard \
		-label " $::overview::mc::RotateBoard" \
		-command [namespace code [list Rotate $Vars(widget:frame)]] \
		;
	set pos [menu $m.pos -tearoff false]
	$pos add command \
		-label " $::setup::board::mc::StandardPosition" \
		-image $::icon::16x16::home \
		-compound left \
		-command [list ::application::pgn::Shuffle Normal] \
		;
	foreach variant {Chess960 Symm960 Shuffle} {
		$pos add command \
			-label " $::setup::mc::Position($variant)" \
			-image $::icon::16x16::dice \
			-compound left \
			-command [list ::application::pgn::Shuffle $variant] \
			;
	}
	if {[::scidb::game::query variant?] eq "Normal"} {
		$pos add separator
		::setup::setupPositionMenu ::application::pgn $pos
	}
	$m add cascade \
		-menu $pos \
		-compound left \
		-image $::icon::16x16::checker \
		-label " $mc::SelectStartPosition" \
		;
	$m add command \
		-compound left \
		-image $::icon::16x16::checker \
		-label " $::setup::board::mc::SetStartBoard..." \
		-command [namespace code [list SetStartBoard $Vars(widget:frame)]] \
		;
	$m add command \
		-compound left \
		-image $::icon::16x16::checker \
		-label " $::setup::position::mc::SetStartPosition..." \
		-command [namespace code [list SetStartPosition $Vars(widget:frame)]] \
		;
	
	if {![::application::pgn::empty?] && ![::scidb::game::query over]} {
		$m add separator

		$m add command \
			-label " $mc::InsertNullMove" \
			-command { ::move::addMove dialog -- } \
			-accelerator "$::mc::Key(Ctrl)-0" \
			;
	}

	$m add separator

	$m add checkbutton \
		-label $::board::options::mc::ShowSideToMove \
		-variable ::board::layout(side-to-move) \
		-command [namespace code Apply] \
		;
	::theme::configureCheckEntry $m
	$m add checkbutton \
		-label $::board::options::mc::ShowMaterialValues \
		-variable ::board::layout(material-values) \
		-command [namespace code Apply] \
		;
	::theme::configureCheckEntry $m
	$m add checkbutton \
		-label $::board::options::mc::ShowMaterialBar \
		-variable ::board::layout(material-bar) \
		-state [expr {$::board::layout(material-values) ? "normal" : "disabled"}] \
		-command [namespace code Apply] \
		;
	::theme::configureCheckEntry $m
	$m add checkbutton \
		-label $::board::options::mc::ShowBorder \
		-variable ::board::layout(border) \
		-command [namespace code Apply] \
		;
	::theme::configureCheckEntry $m
	$m add checkbutton \
		-label $::board::options::mc::ShowCoordinates \
		-variable ::board::layout(coordinates) \
		-command [namespace code Redraw] \
		;
	::theme::configureCheckEntry $m
	$m add checkbutton \
		-label "$::board::options::mc::UseSmallLetters" \
		-variable ::board::layout(coords-small) \
		-command [namespace code RedrawCoordinates] \
		-state [expr {$::board::layout(coordinates) ? "normal" : "disabled"}] \
		;
	::theme::configureCheckEntry $m
	$m add checkbutton \
		-label $::board::options::mc::ShowSuggestedMove \
		-variable ::board::hilite(show-suggested) \
		-command [namespace code Apply] \
		;
	::theme::configureCheckEntry $m
	$m add checkbutton \
		-label $mc::ShowVariationArrows \
		-variable [namespace current]::Options(variations:arrows) \
		;
	::theme::configureCheckEntry $m
	$m add checkbutton \
		-label $mc::ShowAnnotation \
		-variable [namespace current]::Options(show:annotation) \
		;
	::theme::configureCheckEntry $m

	$m add separator
	if {[::board::options::isOpen]} { set state disabled } else { set state normal }
	$m add command \
		-compound left \
		-image $::icon::16x16::setup \
		-label " $::board::options::mc::BoardSetup..." \
		-command [list ::board::options::openConfigDialog $w [namespace current]::Redraw] \
		-state $state \
		;
	set slider [menu $m.slider -tearoff false]
	$m add cascade \
		-menu $slider \
		-compound left \
		-image $::icon::16x16::none \
		-label " $mc::SlidingVarPanePosition" \
		;
	::variation::addToMenu $slider
	set timeout [menu $m.timeout -tearoff false]
	$m add cascade \
		-menu $timeout \
		-compound left \
		-image $::icon::16x16::none \
		-label " $mc::ShowAnnotationTimeout" \
		;
	foreach s {1500 2000 2500 3000 3500 4000 4500 5000 0} {
		if {$s == 0} { set txt $mc::None } else { set txt $s }
		$timeout add radiobutton \
			-label $txt \
			-variable [namespace current]::Options(annotation:timeout) \
			-value $s \
			-command [list $Vars(widget:frame) itemconfigure annotation -state hidden] \
			;
		::theme::configureRadioEntry $timeout
	}
	if {[::scidb::game::query variant?] in {Crazyhouse}} {
		menu $m.promo
		$m add cascade \
			-menu $m.promo \
			-compound left \
			-image $::icon::16x16::none \
			-label " $mc::MarkPromotedPiece" \
			;
		foreach mark {none bullet star disk} {
			$m.promo add radiobutton \
				-label $mc::PromoSign($mark) \
				-variable [namespace current]::Options(promoted:mark) \
				-value $mark \
				-command [list ::board::diagram::setPromoSign $board $mark] \
				;
			::theme::configureRadioEntry $m.promo
		}
	}

	tk_popup $m {*}[winfo pointerxy $w]
}


proc InsertNullMove {} {
	if {![::application::pgn::empty?] && ![::scidb::game::query over]} {
		::move::addMove dialog --
	}
}


proc Apply {} {
	variable Vars

	if {[[namespace parent]::ready?]} {
		RebuildBoard $Vars(widget:frame) $Vars(width) $Vars(height) true
	}
}


proc Redraw {} {
	Apply
	RedrawCoordinates
}


proc RedrawCoordinates {} {
	variable ::board::layout
	variable Vars

	if {!$layout(coordinates)} { return }
	set border $Vars(widget:border)
	set canv $Vars(widget:frame)

	if {[llength [$border find withtag coords]] > 0} {
		foreach w [list $canv $border] {
			foreach c {A B C D E F G H} {
				set letter $c
				if {$layout(coords-small)} { set letter [string tolower $c] }
				$w itemconfigure cc$c -text $letter
			}
		}
	}
}


proc RebuildBoard {canv width height {force false}} {
	variable ::board::layout
	variable Layouts
	variable Dim
	variable Vars
	variable board

	set dimensions ${width}x${height}
	if {!$force && $dimensions eq $Vars(dimensions)} { return }
	set Vars(dimensions) $dimensions

	set squareSize $Dim(squaresize)
	set edgeThickness $Dim(edgethickness)
	ComputeLayout $width $height $Dim(bordersize)
	SetBackground $canv window $width $height
	$canv coords board $Dim(border:x1) $Dim(border:y1)
	$canv coords annotation [expr {$Dim(border:x1) - 10}] [expr {$Dim(border:y1) + $Dim(borderthickness)}]
	$Vars(widget:border) coords board $Dim(borderthickness) $Dim(borderthickness)
	set bordersize [expr {$Dim(bordersize) + $Dim(border:gap)}]
	$Vars(widget:border) configure -width $bordersize -height $bordersize

	if {$Dim(border:gap) > 0} {
		$Vars(widget:border) configure -background black
	} else {
		$Vars(widget:border) configure -background [$canv cget -background]
	}

	set inuse(0) 0
	set inuse(1) 0
	if {$Vars(layout) eq "Normal" || $Vars(layout) eq "ThreeCheck"} {
		set pieceSize $Dim(piece:size)
		catch { set inuse(0) [image inuse photo_Piece(figurine,0,wq,$pieceSize)] }
		catch { set inuse(1) [image inuse photo_Piece(figurine,1,wq,$pieceSize)] }
		if {!$inuse($layout(material-bar))} {
			::board::pieceset::registerFigurines $pieceSize $layout(material-bar)
			set Vars(registered:$layout(material-bar)) [list $pieceSize $layout(material-bar)]
		}
		if {!$inuse(0)} {
			::board::pieceset::registerFigurines $pieceSize 0
			set Vars(registered:0) [list $pieceSize $layout(material-bar)]
		}
	}
	if {!$inuse(0) && [llength $Vars(registered:0)]} {
		::board::pieceset::unregisterFigurines {*}$Vars(registered:0)
	}
	if {!$inuse(1) && [llength $Vars(registered:1)]} {
		::board::pieceset::unregisterFigurines {*}$Vars(registered:1)
	}

	if {$squareSize != $Dim(squaresize) || $edgeThickness != $Dim(edgethickness)} {
		::update idletasks
		foreach l $Layouts {
			if {$l ne $Vars(layout) && [llength $Vars(inuse:$l)] && !$Vars(registered:$l)} {
				::board::registerSize $Vars(inuse:$l)
				set Vars(registered:$l) 1
			}
		}
		::board::diagram::resize $board $Dim(squaresize) -bordersize $Dim(edgethickness)
		if {$Vars(registered:$Vars(layout))} {
			::board::unregisterSize $Vars(inuse:$Vars(layout))
			set Vars(registered:$Vars(layout)) 0
		}
		set Vars(inuse:$Vars(layout)) $Dim(squaresize)
	} else {
		::board::diagram::rebuild $board
	}

	if {$Vars(layout) eq "Crazyhouse"} {
		::board::holding::resize $Vars(holding:w) $Dim(squaresize)
		::board::holding::resize $Vars(holding:b) $Dim(squaresize)
	}

	BuildBoard $canv
	ConfigureBoard $canv
	DrawMaterialValues $canv
	DrawChecks $canv
}


proc DrawMaterialValues {canv} {
	variable ::board::layout
	variable Vars

	if {$Vars(layout) eq "Normal" || $Vars(layout) eq "ThreeCheck"} {
		if {$layout(material-values)} {
			set material [::scidb::game::material]
			if {[string equal $material $Vars(material)]} { return }

			$canv delete material
			lassign $material p n b r q k

			if {$Vars(variant) ne "Crazyhouse"} {
				# match knights and bishops
				for {} {$n < 0 && $b > 0} {incr b -1} {incr n}
				for {} {$b < 0 && $n > 0} {incr n -1} {incr b}
			}

			set sum [expr {abs($p) + abs($n) + abs($b) + abs($r) + abs($q) + abs($k)}]
			set rank 0

			switch $Vars(variant) {
				Suicide - Giveaway	{ set pieces {k r n q p b} }
				default					{ set pieces {k q r b n p} }
			}

			foreach piece $pieces {
				AddMaterial [set $piece] $piece $canv $rank $sum; incr rank [abs [set $piece]]
			}
		} elseif {[string length $Vars(material)]} {
			$canv delete material
			set Vars(material) {}
		}
	} else {
		lassign [::scidb::pos::inHand?] matw matb
		::board::holding::update $Vars(holding:w) $matw
		::board::holding::update $Vars(holding:b) $matb
	}
}


proc DrawChecks {canv} {
	variable Vars

	lassign [::scidb::pos::checks] w b
	$canv itemconfigure checks -state hidden

	for {set i 1} {$i <= $w} {incr i} {
		$canv itemconfigure chb-$i -state normal
	}
	for {set i 1} {$i <= $b} {incr i} {
		$canv itemconfigure chw-$i -state normal
	}
}


proc AddMaterial {count piece canv rank sum} {
	variable ::board::layout
	variable Vars
	variable Dim

	if {$count == 0} { return }

	set dist	[expr {$Dim(piece)/8}]
	set gap	[expr {$Dim(piece)/4}]
	set offs	[expr {$Dim(piece) + $gap}]
	set size	[expr {$sum*$Dim(piece) + ($sum - 1)*$gap}]
	set x		[expr {$Dim(border:x2) + $Dim(gap:x) + ($Dim(stm) - $Dim(piece) - $dist)/2 + 1}]
	set y		[expr {$Dim(mid:y) - $size/2 + $rank*$offs}]
	set res	${Dim(piece)}x${Dim(piece)}

	if {$count < 0} {
		set color "b"
		set count [abs $count]
	} else {
		set color "w"
	}

	if {$Vars(variant) ne "Normal"} {
		if {$color eq "w"} { set color "b" } else { set color "w" }
	}

	set img photo_Piece(figurine,$layout(material-bar),${color}${piece},$Dim(piece:size))

	for {set i 0} {$i < $count} {incr i} {
		set n [expr {$i + $rank}]
		$canv create image $x $y -image $img -tags [list material mv$n] -anchor nw
		incr y $offs
	}
}


proc ComputeLayout {canvWidth canvHeight {bordersize -1}} {
	variable ::board::layout
	variable Dim
	variable Vars

	if {$bordersize > 0} {
		::update idletasks
	}

	set distance	[expr {max(1, min($canvWidth, $canvHeight)/150)}]
	set width		[expr {$canvWidth - 2*$distance}]
	set height		[expr {$canvHeight - 2*$distance}]
	set stmsize		0

	if {$layout(side-to-move) || ($layout(material-values) && $Vars(layout) ne "Crazyhouse")} {
		if {$layout(side-to-move)} { set minsize 64 } else { set minsize 34 }
		set Dim(stm) [expr {max(18, min($minsize, (min($canvWidth, $canvHeight) - 19)/24 + 5))}]
		set Dim(gap:x) [expr {max(7, $Dim(stm)/3)}]
		set Dim(gap:y) $Dim(gap:x)
	} else {
		set Dim(stm) 0
		set Dim(gap:x) 0
		set Dim(gap:y) 0
	}

	if {$Vars(layout) ne "Crazyhouse"} {
		set stmsize [expr {$Dim(gap:x) + $Dim(stm)}]
	}

	if {$layout(border) && $layout(coordinates)} {
		set Dim(borderthickness) [expr {min(36, max(16, int(min($width, $height)/24.0 + 0.5)))}]
		set Dim(offset) $Dim(borderthickness)
	} elseif {$layout(border)} {
		set Dim(borderthickness) 12
		set Dim(offset) 12
	} elseif {$layout(coordinates)} {
		set Dim(borderthickness) 0
		set Dim(offset) [expr {min(36, max(16, int(min($width, $height)/20.0 + 0.5)))}]
	} else {
		set Dim(borderthickness) 0
		set Dim(offset) 0
	}

	if {$layout(border) && $layout(coordinates)} {
		set Dim(borderthickness) [expr {int([::font::scaleFactor]*$Dim(borderthickness) + 0.5)}]
		set Dim(offset) [expr {int([::font::scaleFactor]*$Dim(offset) + 0.5)}]
	}

	if {	$Vars(layout) eq "ThreeCheck"
		&& $layout(coordinates)
		&& !$layout(border)
		&& ($layout(side-to-move) || $layout(material-values))} {
		set Dim(offset:coords) $Dim(offset)
	} else {
		set Dim(offset:coords) 0
	}

	if {$Vars(layout) eq "Crazyhouse" && $layout(coordinates) && !$layout(border)} {
		set Dim(offset:coords) [expr {(2*$Dim(offset))/3}]
	}

	if {$layout(border)} {
		set width [expr {$width - 2*$Dim(borderthickness) - 2*$stmsize}]
	} else {
		set width [expr {$width - 2*max($Dim(offset), $stmsize)}]
	}

	set height [expr {$height - 2*$Dim(offset)}]

	if {$Vars(layout) eq "Crazyhouse" && ($layout(border) || !$layout(coordinates))} {
		set width [expr {$width - min($width, $height)/24}]
	}

	set boardsize				[expr {min($width, $height)}]
	set Dim(edgethickness)	[expr {$Dim(borderthickness) ? 0 : ($boardsize/8 < 45 ? 1 : 2)}]

	if {$Vars(layout) eq "Crazyhouse"} {
		set squaresize		[expr {($boardsize - 2*$Dim(edgethickness) - 4)/10.3333}]
		set Dim(distance)	[expr {round($squaresize/3.0)}]
		if {$layout(side-to-move)} { set Dim(gap:x) $Dim(distance) }

		set width				[expr {$width - 2*$Dim(distance) - 4}]
		set squaresize1		[expr {($width - 2*$Dim(edgethickness))/10}]
		set squaresize2		[expr {($height - 2*$Dim(edgethickness))/8}]
		set Dim(squaresize)	[expr {min($squaresize1, $squaresize2)}]
		set width				[expr {$width - 2*$Dim(squaresize)}]
	} else {
		set Dim(squaresize)	[expr {($boardsize - 2*$Dim(edgethickness))/8}]
	}

	set Dim(border:gap) [::board::computeGap $Dim(squaresize)]

	if {$Dim(border:gap) > 0} {
		if {[::board::borderlineGap] > 0 || $layout(border)} {
			set Dim(border:gap)		0
		} else {
			set height					[expr {$height - $Dim(border:gap)}]
			set width					[expr {$width - $Dim(border:gap)}]
			set boardsize				[expr {min($width, $height)}]
			set Dim(squaresize)		[expr {$boardsize/8}]
			set Dim(edgethickness)	0
		}
	}

	set Dim(boardsize)	[expr {8*$Dim(squaresize) + 2*$Dim(edgethickness)}]
	set Dim(bordersize)	[expr {$Dim(boardsize) + 2*$Dim(borderthickness)}]
	set Dim(border:x1)	[expr {($canvWidth - $Dim(bordersize) + $Dim(offset:coords))/2}]
	set Dim(border:y1)	[expr {($canvHeight - $Dim(bordersize))/2}]
	set Dim(border:x2)	[expr {$Dim(border:x1) + $Dim(bordersize)}]
	set Dim(border:y2)	[expr {$Dim(border:y1) + $Dim(bordersize)}]
	set Dim(mid:y)			[expr {$Dim(border:y1) + $Dim(bordersize)/2}]

	if {$bordersize != -1 && $Dim(bordersize) != $bordersize} {
		$Vars(widget:frame) delete stm
		$Vars(widget:frame) delete checks
		$Vars(widget:border) delete shadow
		$Vars(widget:border) delete mvbar
		$Vars(widget:border) delete holdingbar
	}

	if {$layout(material-bar)} {
		set Dim(piece) [expr {$Dim(stm) - 2}]
		set Dim(piece:size) [expr {$Dim(stm) - 3}]
	} else {
		set Dim(piece) $Dim(stm)
		set Dim(piece:size) $Dim(stm)
	}
}


proc ConfigureBoard {canv} {
	variable ::board::layout
	variable ::board::colors
	variable Dim
	variable Vars
	variable board

	set border $Vars(widget:border)

	# configure border #############################
	set state hidden
	if {$layout(border)} { set state normal }
	$border itemconfigure -state $state

	# configure side to move #######################
	if {$layout(side-to-move)} {
		if {[rotated?]} {
			set stmw stmb
			set stmb stmw
		} else {
			set stmw stmw
			set stmb stmb
		}
		set x [expr {$Dim(border:x2) + $Dim(gap:x)}]
		set y [expr {$Dim(border:y1) + $Dim(gap:y)}]
		$canv coords $stmb $x $y
		set y [expr {$Dim(border:y2) - $Dim(stm) - $Dim(gap:y)}]
		$canv coords $stmw $x $y
		$canv raise stm
	}
	$canv itemconfigure stmb -state hidden
	$canv itemconfigure stmw -state hidden
	UpdateSideToMove $canv

	# configure material bar #######################
	$canv delete material

	if {$Vars(layout) ne "Crazyhouse"} {
		set state hidden
		if {$layout(material-values) && $layout(material-bar)} {
			set size $Dim(piece)
			set dist [expr {$size/8}]
			set x3 [expr {$Dim(border:x2) + $Dim(gap:x) + ($Dim(stm) - $size - $dist)/2}]
			set x4 [expr {$x3 + $size + $dist}]

			if {$layout(side-to-move)} {
				set y3 [expr {$Dim(border:y1) + $Dim(stm) + 2*$Dim(gap:y) + 1}]
				set y4 [expr {$Dim(border:y2) - $Dim(stm) - 2*$Dim(gap:y) - 1}]
			} else {
				set y3 [expr {$Dim(border:y1) + $Dim(edgethickness)}]
				set y4 [expr {$Dim(border:y2) - $Dim(edgethickness)}]
			}

			$canv coords mvbar-1 $x3 $y3 $x4 $y4
			incr x3; incr y3
			$canv coords mvbar-2 $x3 $y3 $x4 $y4
			incr x4 -1; incr y4 -1
			$canv coords mvbar-3 $x3 $y3 $x4 $y4

			$canv raise mvbar
			set state normal
		}
		$canv itemconfigure mvbar-1 -state $state
		$canv itemconfigure mvbar-2 -state $state
		$canv itemconfigure mvbar-3 -state $state
	}

	# configure check counts #######################
	if {$Vars(layout) eq "ThreeCheck" && ($layout(side-to-move) || $layout(material-values))} {
		set size $Dim(piece)
		set dist [expr {max($Dim(gap:x), ($Dim(stm) + $Dim(gap:x) - $size)/2)}]
		set dist [expr {$Dim(stm) + $Dim(gap:x) + $Dim(offset:coords) - $size}]
		set x0 [expr {$Dim(border:x1) - $size - $dist}]
		set y1 [expr {$Dim(border:y1) + $Dim(gap:y) + $Dim(borderthickness)}]
		set y2 [expr {$y1 + $size + $Dim(gap:y)}]
		set y3 [expr {$y2 + $size + $Dim(gap:y)}]
		set z1 [expr {$Dim(border:y2) - $Dim(borderthickness) - $Dim(gap:y) - $size}]
		set z2 [expr {$z1 - $size - $Dim(gap:y)}]
		set z3 [expr {$z2 - $size - $Dim(gap:y)}]

		if {[rotated?]} {
			set t1 $y1; set y1 $z1; set z1 $t1
			set t2 $y2; set y2 $z2; set z2 $t2
			set t3 $y3; set y3 $z3; set z3 $t3
		}

		$canv coords chw-1 $x0 $y1; $canv coords chw-2 $x0 $y2; $canv coords chw-3 $x0 $y3
		$canv coords chb-1 $x0 $z1; $canv coords chb-2 $x0 $z2; $canv coords chb-3 $x0 $z3
	} else {
		$canv delete checks
	}

	# configure in-hand bars #######################
	if {$Vars(layout) eq "Crazyhouse"} {
		set wd [::board::holding::width $Vars(holding:w)]
		set ht [::board::holding::height $Vars(holding:w)]
		set distance $Dim(distance)
		if {$layout(side-to-move)} {
			set yincr [expr {2*$Dim(gap:y) + $Dim(stm) + $Dim(edgethickness)}]
		} else {
			set yincr $Dim(edgethickness)
		}
		set xw [expr {$Dim(border:x2) + $distance}]
		set yw [expr {$Dim(border:y2) - $ht - $yincr}]
		set xb [expr {$Dim(border:x1) - $distance - $Dim(offset:coords) - $wd}]
		set yb [expr {$Dim(border:y1) + $yincr}]
		if {[rotated?]} { lassign {b w} w b } else { lassign {w b} w b }
		$canv coords holdingbar-w [set x$w] [set y$w]
		$canv coords holdingbar-b [set x$b] [set y$b]
		$canv raise holdingbar-w
		$canv raise holdingbar-b
	}

	# configure coordinates ########################
	if {$layout(coordinates)} {
		if {$layout(border)} { set w $border } else { set w $canv }
		$w itemconfigure ncoords -state normal
		set size $Dim(offset)
		if {$layout(border)} { incr size -4 }
		set font [ComputeCoordFont $w $size]
	}
	$canv itemconfigure coords -state hidden
	$border itemconfigure coords -state hidden
	if {$layout(coordinates)} {
		if {$layout(border)} { set w $border } else { set w $canv }
		if {$layout(border)} { set which border } else { set which background }
		$w itemconfigure ncoords -state normal -fill $colors(hint,${which}-coords)
		$w itemconfigure coords -font $font
		if {$layout(coords-embossed)} {
			scan $colors(hint,${which}-coords) "\#%2x%2x%2x" r g b
			set luma	[expr {$r*0.2125 + $g*0.7154 + $b*0.0721}]
			if {$luma >= 128} { $w itemconfigure bcoords -state normal -fill black }
			if {$luma <  128} { $w itemconfigure wcoords -state normal -fill white }
		} else {
			$w itemconfigure bcoords -state normal -fill gray48
		}
		if {$layout(border)} {
			set x [expr {$Dim(offset)/2 + 1}]
			set y [expr {$Dim(offset) + $Dim(squaresize)/2}]
		} else {
			set x [expr {$Dim(border:x1) - $Dim(offset)/2 - $Dim(edgethickness)}]
			set y [expr {$Dim(border:y1) + $Dim(edgethickness) + $Dim(squaresize)/2}]
		}
		set columns {8 7 6 5 4 3 2 1}
		set rows {A B C D E F G H}
		if {[rotated?]} {
			set columns [lreverse $columns]
			set rows [lreverse $rows]
		}
		foreach r $columns {
			foreach {k offs} {w -1 b 1 {} 0} {
				$w coords ${k}coord${r} [expr {$x + $offs}] [expr {$y + $offs}]
			}
			incr y $Dim(squaresize)
		}
		if {$layout(border)} {
			set x [expr {$Dim(offset) + $Dim(squaresize)/2}]
			set y [expr {$Dim(bordersize) - $Dim(offset)/2 - 2}]
		} else {
			set x [expr {$Dim(border:x1) + $Dim(edgethickness) + $Dim(squaresize)/2}]
			set y [expr {$Dim(border:y2) + $Dim(edgethickness) + $Dim(offset)/2}]
		}
		foreach c $rows {
			foreach {k offs} {w -1 b 1 {} 0} {
				$w coords ${k}coord${c} [expr {$x + $offs}] [expr {$y + $offs}]
			}
			incr x $Dim(squaresize)
		}
	}
}


proc ComputeCoordFont {w size} {
	variable ::board::layout
	variable Defaults
	variable Dim

	set factor [::font::scaleFactor]
	set size [expr {max(6, int($factor*$size + 0.5))}]
	if {$Dim(fontsize) == $size} { return $Dim(font) }
	set delta [expr {min(6, int(($size - 10)/3.0 + 0.5) + 2)}]
	set Dim(fontsize) $size

	while {$size >= 6} {
		set Dim(font) [list $Defaults(coords-font-family) $size]
		$w itemconfigure coordA -font $Dim(font)
		lassign [$w bbox coordA] x1 y1 x2 y2
		set width [expr {$x2 - $x1}]
		set height [expr {$y2 - $y1}]
		set dx [expr {$Dim(offset) - $width - $delta}]
		set dy [expr {$Dim(offset) - $height - $delta}]
		if {$dx >= 0 && $dy >= 0} { return $Dim(font) }
		incr size [expr {min(-1, min($dx, $dy)/2)}]
	}

	return $Dim(font)
}


proc BuildBoard {canv} {
	variable ::board::layout
	variable ::board::colors
	variable ::board::square::style
	variable stmWhite
	variable stmBlack
	variable Dim
	variable Vars

	set border $Vars(widget:border)

	# border #######################################
	if {$layout(border)} {
		::board::setBackground $border border
		if {[llength $colors(hint,border-color)]} {
			$border configure -background $colors(hint,border-color)
		}
		if {[llength [$border find withtag shadow]] == 0} {
			::board::diagram::drawBorderlines $border $Dim(bordersize)
		}
	}

	# side to move #################################
	if {$layout(side-to-move) && [llength [$canv find withtag stm]] == 0} {
		catch { image delete [namespace current]::Stm(white) }
		catch { image delete [namespace current]::Stm(black) }
		image create photo [namespace current]::Stm(white) -width $Dim(stm) -height $Dim(stm)
		image create photo [namespace current]::Stm(black) -width $Dim(stm) -height $Dim(stm)
		::scidb::tk::image copy $stmWhite [namespace current]::Stm(white)
		::scidb::tk::image copy $stmBlack [namespace current]::Stm(black)
		$canv create image 0 0 -image [namespace current]::Stm(black) -tags {stm stmb} -anchor nw
		$canv create image 0 0 -image [namespace current]::Stm(white) -tags {stm stmw} -anchor nw
	}

	# material bar #################################
	if {$Vars(layout) eq "Crazyhouse" || !$layout(material-values) || !$layout(material-bar)} {
		$canv delete mvbar
	} elseif {[llength [$canv find withtag mvbar]] == 0} {
		$canv create rectangle 0 0 0 0 -fill white -width 0 -tags {mvbar mvbar-1}
		$canv create rectangle 0 0 0 0 -fill black -width 0 -tags {mvbar mvbar-2}
		$canv create rectangle 0 0 0 0  -fill #e6e6e6 -width 0 -tags {mvbar mvbar-3}
	}

	# check counts #################################
	if {$Vars(layout) eq "Crazyhouse" || !$layout(side-to-move) && !$layout(material-values)} {
		$canv delete checks
	} elseif {[llength [$canv find withtag checks]] == 0} {
		set wk photo_Piece(figurine,0,wk,$Dim(piece:size))
		set bk photo_Piece(figurine,0,bk,$Dim(piece:size))
		for {set i 1} {$i <= 3} {incr i} {
			$canv create image 0 0 -image $wk -tags [list checks chw-$i] -anchor nw -state hidden
			$canv create image 0 0 -image $bk -tags [list checks chb-$i] -anchor nw -state hidden
		}
	}

	# in-hand bars #################################
	if {$Vars(layout) ne "Crazyhouse"} {
		$canv delete holdingbar
	} elseif {[llength [$canv find withtag holdingbar]] == 0} {
		$canv create window 0 0 -anchor nw -tags {holdingbar holdingbar-w} -window $Vars(holding:w)
		$canv create window 0 0 -anchor nw -tags {holdingbar holdingbar-b} -window $Vars(holding:b)
	}

	# coordinates ##################################
	if {$layout(coordinates) && [llength [$border find withtag coords]] == 0} {
		foreach w [list $canv $border] {
			foreach r {1 2 3 4 5 6 7 8} {
				$w create text 0 0 -justify right -text $r -tags [list coords wcoords wcoord$r]
				$w create text 0 0 -justify right -text $r -tags [list coords bcoords bcoord$r]
				$w create text 0 0 -justify right -text $r -tags [list coords ncoords coord$r]
			}
			foreach c {A B C D E F G H} {
				set letter $c
				if {$layout(coords-small)} { set letter [string tolower $c] }
				$w create text 0 0 -text $letter -tags [list coords wcoords cc$c wcoord$c]
				$w create text 0 0 -text $letter -tags [list coords bcoords cc$c bcoord$c]
				$w create text 0 0 -text $letter -tags [list coords ncoords cc$c coord$c]
			}
		}
	}
}


proc Rotate {canv} {
	variable board
	variable Vars

	::board::diagram::rotate $board
	ConfigureBoard $canv
	DrawMaterialValues $Vars(widget:frame)
	DrawChecks $Vars(widget:frame)
}


proc SetStartBoard {canv} {
	::setup::board::open [winfo toplevel $canv]
}


proc SetStartPosition {canv} {
	::setup::position::open [winfo toplevel $canv]
}


proc UpdateSideToMove {canv} {
	variable ::board::layout
	variable Vars

	if {$layout(side-to-move)} {
		if {[::scidb::game::ply] % 2} { set color b } else { set color w }
		if {$color eq "w"} { set other b} else { set other w }
		$canv itemconfigure stm$color -state normal
		$canv itemconfigure stm$other -state hidden
	}
}


proc UpdateControls {} {
	variable Vars

	set level [::scidb::game::level]

	if {[::scidb::game::position -1 atStart?]} { set state disabled } else { set state normal }
	::toolbar::childconfigure $Vars(control:back) -state $state
	::toolbar::childconfigure $Vars(control:fastBack) -state $state
	if {$level} { set state normal }
	::toolbar::childconfigure $Vars(control:gotoStart) -state $state

	if {[::scidb::game::position -1 atEnd?]} { set state disabled } else { set state normal }
	::toolbar::childconfigure $Vars(control:fwd) -state $state
	::toolbar::childconfigure $Vars(control:fastFwd) -state $state
	if {$level} { set state normal }
	::toolbar::childconfigure $Vars(control:gotoEnd) -state $state

	if {$level == 0} { set state disabled } else { set state normal }
	::toolbar::childconfigure $Vars(control:leaveVar) -state $state

	if {[::scidb::game::variation count]} { set state normal } else { set state disabled }
	::toolbar::childconfigure $Vars(control:enterVar) -state $state
}


proc GameSwitched {position} {
	variable Vars

	after cancel $Vars(afterid:switched)
	set Vars(afterid:switched) [after 1 [namespace code [list GameSwitched2 $position]]]
}


proc GameSwitched2 {position} {
	variable Vars
	variable board

	# reset if position is 9 (all games closed)

	set variant [::scidb::game::query $position mainvariant?]
	set base [lindex [::scidb::game::link?] 0]
	set Vars(variant) $variant

	set view [::scidb::game::view $position id]
	if {$view >= 0} {
		Unsubscribe $position
		set Vars(current:game) [list $position $base $variant $view 0]
		SwitchView list
		Subscribe $position $base $variant
	}

	UpdateCrossTableButton
	UpdateGameControls $position
	UpdateGameButtonState(list) $position
	UpdateGameButtonState(base) [::scidb::db::get name] [::scidb::app::variant]
	UpdateSaveButton

	set layout [expr {$variant eq "Crazyhouse" || $variant eq "ThreeCheck" ? $variant : "Normal"}]
	if {$layout ne $Vars(layout)} {
		::board::diagram::showPromoted $board [expr {$variant eq "Crazyhouse"}]
		set Vars(layout) $layout
		Apply
	}
}


proc GameClosed {position} {
	if {$position < 9} {
		Unsubscribe $position
	}
}


proc UpdateInfo {_ base variant} {
	if {$base eq [::scidb::db::get name]} {
		DatabaseSwitched $base $variant
	}
}


proc DatabaseSwitched {base variant} {
	UpdateGameButtonState(list) [::scidb::game::current]
	UpdateGameButtonState(base) $base $variant
	UpdateSaveButton
	UpdateCrossTableButton
}


proc UpdateCrossTableButton {} {
	variable ::scidb::scratchbaseName
	variable Vars

	set base [lindex [::scidb::game::sink?] 0]
	if {$base eq $scratchbaseName} { set state disabled } else { set state normal }
	::toolbar::childconfigure $Vars(crossTable) -state $state
}


proc UpdateSaveButton {} {
	variable ::scidb::scratchbaseName
	variable ::scidb::clipbaseName
	variable Vars

	set position [::scidb::game::current]

	if {$position == 9} {
		::toolbar::childconfigure $Vars(game:replace) -state disabled
		::toolbar::childconfigure $Vars(game:save) -state disabled
	} elseif {$position >= 0} {
		set actual [lindex [::scidb::game::link?] 0]
		set current [::scidb::db::get name]
		set tip(replace) ""
		set tip(save) ""
		set state(replace) normal
		set state(save) normal
		if {$actual ne $scratchbaseName} {
			set tip(replace) [format $::gamebar::mc::ReplaceGame [::util::databaseName $actual]]
		}
		if {	$actual eq $scratchbaseName
			|| ![::scidb::db::get open? $actual]
			|| [::scidb::db::get readonly? $actual]
			|| $Vars(variant) ni [::scidb::db::get variants $actual]} {
			set state(replace) disabled
			set tip(replace) ""
		}
		if {	$Vars(variant) in [::scidb::db::get variants $current]
			&& ![::scidb::db::get readonly? $current $Vars(variant)]} {
			set tip(save) [format $::gamebar::mc::AddNewGame [::util::databaseName $current]]
		} else {
			set state(save) disabled
		}
		::toolbar::childconfigure $Vars(game:replace) -state $state(replace) -tooltip $tip(replace)
		::toolbar::childconfigure $Vars(game:save) -state $state(save) -tooltip $tip(save)
	}
}


proc UpdateGameControls {position} {
	variable Vars

	if {$Vars(load:method) eq "base" || $position >= 9} { return }

	Unsubscribe $position
	set Vars(current:game) {}
	set info [::game::getSourceInfo $position]

	if {[llength $info]} {
		lassign $info base variant view number
		if {$view >= 0} {
			set variant [::util::toMainVariant $variant]
			set Vars(current:game) [list $position $base $variant $view $number]
			Subscribe $position $base $variant
			SwitchView list
		} else {
			set Vars(current:game) {}
		}
	}
}


proc UpdateGameButtonState(list) {position} {
	variable Vars

	if {$Vars(load:method) eq "base"} { return }
	array set state { random disabled prev disabled next disabled first disabled last disabled }

	if {[llength $Vars(current:game)] > 1 && $position < 9} {
		lassign $Vars(current:game) position base variant view number
		if {[::scidb::db::get open? $base $variant]} {
			if {[::scidb::view::open? games $base $variant $view]} {
				if {[scidb::view::count games $base $variant $view] > 1} {
					if {[::scidb::game::view $position next] >= 0} {
						array set state { next normal last normal }
						set state(random) normal
					}
					if {[::scidb::game::view $position prev] >= 0} {
						array set state { prev normal first normal }
						set state(random) normal
					}
				}
			}
		}
	}

	foreach action [array names state] {
		::toolbar::childconfigure $Vars(game:$action) -state $state($action)
	}
}


proc UpdateGameButtonState(base) {base variant} {
	variable Vars

	if {$Vars(load:method) eq "list"} { return }

	set position [::scidb::game::current]
	set numGames [scidb::view::count games $base $variant 0]
	array set state { random disabled prev disabled next disabled first disabled last disabled }

	if {$numGames > 0} {
		set state(random) normal
		if {$position < 9} {
			lassign [::scidb::game::link? $position] myBase myVariant index
			set myVariant [::util::toMainVariant $myVariant]
			if {$myBase eq $base && $myVariant eq $variant} {
				if {$index > 0} { array set state { prev normal first normal } }
				if {$index + 1 < $numGames} { array set state { next normal last normal } }
			}
		} else {
			array set state { prev normal next normal first normal last normal }
		}
	}

	foreach action {next prev first last random} {
		::toolbar::childconfigure $Vars(game:$action) -state $state($action)
	}
}


proc UpdateGameList {position id base variant {view -1} {index -1}} {
	variable Vars

	if {[llength $Vars(current:game)] <= 1} {
		UpdateGameButtonState(list) $position
	} else {
		lassign $Vars(current:game) currPos currBase currVariant currView currNumber

		if {$currBase eq $base && $variant eq $currVariant && ($currView == $view || $currView == 0)} {
			UpdateGameButtonState(list) $position
		}
	}
}


proc UpdateGameInfo {position id} {
	variable Vars

	if {$position == $id && [llength $Vars(current:game)]} {
		if {[lindex $Vars(current:game) 0] == $position} {
			Unsubscribe $position
			set Vars(current:game) {}
			#SwitchView base # not required
		}
	}
}


proc Subscribe {position base variant} {
	variable Vars

	set cmd [list [namespace current]::UpdateGameList {} $position]
	after idle [list ::scidb::db::subscribe gameList {*}$cmd]
	set Vars(subscribe:list) $cmd

	set cmd [list [namespace current]::UpdateGameInfo $position]
	after idle [list ::scidb::db::subscribe gameInfo {*}$cmd]
	set Vars(subscribe:info) $cmd
}


proc Unsubscribe {position} {
	variable Vars

	if {[llength $Vars(subscribe:list)]} {
		after idle [list ::scidb::db::unsubscribe gameList {*}$Vars(subscribe:list)]
		after idle [list ::scidb::db::unsubscribe gameInfo {*}$Vars(subscribe:info)]
		set Vars(subscribe:list) {}
		set Vars(subscribe:info) {}
	}
}


proc ShowCrossTable {parent} {
	set base [::scidb::game::query database]
	set variant [::scidb::app::variant]
	set index [::scidb::game::index]
	::crosstable::open .application $base $variant $index -1 game
}


proc SaveGame {{mode ""}} {
	variable ::scidb::scratchbaseName
	variable ::scidb::clipbaseName
	variable Vars

	::tooltip::hide
	set position [::scidb::game::current]

	if {0 <= $position && $position < 9} {
		if {[string length $mode] == 0} {
			if {[lindex [::scidb::game::link? $position] 0] eq $scratchbaseName} {
				set mode add
			} else {
				set mode replace
			}
		}
		[namespace parent]::pgn::saveGame $mode
	}
}


proc LanguageChanged {} {
	bindKeys
	UpdateSaveButton
}


proc WriteOptions {chan} {
	::options::writeItem $chan [namespace current]::Options
}

::options::hookWriter [namespace current]::WriteOptions


# 80x80
set stmWhite [image create photo -data {
	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
	EL0AAAAASUVORK5CYII=
}]

set stmBlack [image create photo -data {
	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
	82tOVvj6PzoZkRdVHOXfAAAAAElFTkSuQmCC
}]

foreach size {16 22 32} {
	set ::icon::${size}x${size}::whiteKnob [image create photo -width $size -height $size]
	set ::icon::${size}x${size}::blackKnob [image create photo -width $size -height $size]
	::scidb::tk::image copy $stmWhite [set ::icon::${size}x${size}::whiteKnob]
	::scidb::tk::image copy $stmBlack [set ::icon::${size}x${size}::blackKnob]
}
unset size

} ;# namespace board
} ;# namespace application

# vi:set ts=3 sw=3:
