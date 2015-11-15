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

::util::source game-browser-dialog

namespace eval browser {
namespace eval mc {

set BrowseGame				"Browse Game"
set StartAutoplay			"Start Autoplay"
set StopAutoplay			"Stop Autoplay"
set GoForward				"Go forward one move"
set GoBackward				"Go back one move"
set GoForwardFast			"Go forward some moves"
set GoBackFast				"Go back some moves"
set GotoStartOfGame		"Go to start of game"
set GotoEndOfGame			"Go to end of game"
set IncreaseBoardSize	"Increase board size"
set DecreaseBoardSize	"Decrease board size"
set MaximizeBoardSize	"Maximize board size"
set MinimizeBoardSize	"Minimize board size"
set LoadPrevGame			"Load previous game"
set LoadNextGame			"Load next game"
set HandicapGame			"Handicap game"

set IllegalMove			"Illegal move"
set NoCastlingRights		"no castling rights"

set GotoGame(first)		"Goto first game"
set GotoGame(last)		"Goto last game"
set GotoGame(next)		"Goto next game"
set GotoGame(prev)		"Goto previous game"

set LoadGame				"Load game into editor"
set ReloadGame				"Reload game"
set MergeGame				"Merge game"

} ;# namespace mc

namespace import ::tcl::mathfunc::min
namespace import ::tcl::mathfunc::max

array set Priv {
	controls:height		19
	fullscreen:size		0
	fullscreen:size:ext	0
	board:size				0
	board:size:ext			0
}

array set Options {
	fullscreen				0
	board:size				40
	board:size:ext			40
	holding:distance		15
	miniboard:size			30
	autoplay:delay			2500
	repeat:interval		300
	background:header		browser,background:header
	background:hilite		browser,background:hilite
	background:modified	browser,background:modified
	foreground:hilite		browser,foreground:hilite
}

array set Active {}


proc open {parent base variant info view index {fen {}}} {
	variable Options
	variable Active
	variable Priv

	if {$variant eq "Crazyhouse"} {
		set squareSize $Options(board:size:ext)
	} else {
		set squareSize $Options(board:size)
	}
	if {$squareSize != $Priv(board:size)} {
		::board::registerSize $squareSize
		set Priv(board:size) $squareSize
	}
	set number [::gametable::column $info number]
	set name [::util::databaseName $base]
	if {[info exists Priv($base:$number:$variant:$view)]} {
		set dlg [lindex $Priv($base:$variant:$number:$view) 0]
		if {[winfo exists $dlg]} { ;# prevent raise conditions
			::widget::dialogRaise $dlg
			return
		}
	}
	set position [::game::nextGamePosition]
	set dlg $parent.browser$position
	lappend Priv($base:$variant:$number:$view) $dlg
	tk::toplevel $dlg -class Scidb
	if {[tk windowingsystem] eq "x11"} {
		bind $dlg <Button-4> [namespace code [list Goto $position -1]]
		bind $dlg <Button-5> [namespace code [list Goto $position +1]]
	} else {
		bind $dlg <MouseWheel> [namespace code [list Goto $position [expr {%D < 0 ? +1 : -1}]]]
	}
	namespace eval [namespace current]::${position} {}
	variable ${position}::Vars

	set Active($position) $dlg
	set top [::ttk::frame $dlg.top]
	set bot [tk::frame $dlg.bot]
	::ttk::separator $dlg.sep -class Dialog
	grid $dlg.top -column 0 -row 1 -sticky nsew
	grid $dlg.sep -column 0 -row 2 -sticky nsew
	grid $dlg.bot -column 0 -row 3 -sticky nsew

	grid columnconfigure $dlg 0 -weight 1
	grid rowconfigure $dlg 1 -weight 1

	set lt [::ttk::frame $top.lt]
	set rt [::ttk::frame $top.rt]
	grid $lt -column 0 -row 0 -sticky nsew
	grid $rt -column 1 -row 0 -sticky nsew

	grid columnconfigure $top 1 -weight 1

	set background [::colors::lookup theme,background]
	set activebackground [$dlg cget -background]

	# board
	set board [::board::diagram::new $lt.board $squareSize -bordersize 1]
	grid $board -column 3 -row 1 -sticky nsew

	if {$variant eq "Crazyhouse"} {
		set pieces {q r b n p}
		set Vars(holding:w) [::board::holding::new $lt.holding-w w $squareSize $pieces]
		set Vars(holding:b) [::board::holding::new $lt.holding-b b $squareSize $pieces]
		grid $Vars(holding:b) -column 1 -row 1 -sticky n
		grid $Vars(holding:w) -column 5 -row 1 -sticky s
		grid columnconfigure $lt {2 4} -minsize $Options(holding:distance)
	}

	grid columnconfigure $lt {0 6} -minsize $::theme::padding
	grid rowconfigure $lt {0 2} -minsize $::theme::padding

	# board buttons
	set controls [tk::frame $bot.controls]
	tk::button $controls.rotateBoard \
		-takefocus 0 \
		-background $background \
		-activebackground $activebackground \
		-image $::icon::22x22::rotateBoard \
		-command [namespace code [list RotateBoard $position]] \
		;
	grid $controls.rotateBoard -row 0 -column 0
	set Vars(control:rotate) $controls.rotateBoard
	foreach {control column key tipvar} {	GotoStart 4 Home GotoStartOfGame
														FastBackward 5 Prior GoBackFast
														Backward 6 Left GoBackward
														Forward 7 Right GoForward
														FastForward 8 Next GoForwardFast
														GotoEnd 9 End GotoEndOfGame} {
		set w $controls.[string tolower $control 0 0]
		set Vars(control:$key) $w
		tk::button $w \
			-image [set ::icon::22x22::control$control] \
			-background $background \
			-activebackground $activebackground \
			-takefocus 0 \
			-command [list event generate $w <$key>] \
			;
		grid $w -row 0 -column $column
	}
	foreach control {FastBackward Backward Forward FastForward} {
		set w $controls.[string tolower $control 0 0]
		$w configure -repeatdelay $::theme::repeatDelay -repeatinterval $Options(repeat:interval)
	}
	tk::button $controls.autoplay \
		-takefocus 0 \
		-background $background \
		-activebackground $activebackground \
		-image $::icon::22x22::start \
		-command [namespace code [list ToggleAutoPlay $position 1]] \
		;
	set Vars(control:autoplay) $controls.autoplay
	grid $controls.autoplay -row 0 -column 11
	set Vars(control:help) [tk::button $controls.help \
		-takefocus 0 \
		-background $background \
		-activebackground $activebackground \
		-image $::icon::22x22::help \
		-command [list ::help::open .application Game-Browser -parent $dlg] \
	]
	::tooltip::tooltip $controls.help "$::help::mc::Help (F1)"
	grid $controls.help -row 0 -column 13

	grid columnconfigure $controls {1 10} -minsize 10
	grid columnconfigure $controls {2} -minsize 26
	grid columnconfigure $controls {3} -weight 2
	grid columnconfigure $controls {12 14} -weight 1

	# PGN side
	tk::text $rt.header \
		-background [::colors::lookup $Options(background:header)] \
		-height 3 \
		-width 0 \
		-state disabled \
		-takefocus 0 \
		-undo 0 \
		-exportselection 0 \
		-wrap word \
		-cursor {} \
		;
	::widget::textPreventSelection $rt.header
	set Vars(pgn) [::pgn::setup::buildText $rt.pgn browser]
	$rt.header configure -font $::font::text(browser:normal)
	
	grid $rt.header	-row 1 -column 1 -columnspan 2 -sticky nsew
	grid $rt.pgn		-row 3 -column 1 -sticky nsew -ipady 1
	grid rowconfigure $rt {0 2 4} -minsize $::theme::padding
	grid rowconfigure $rt 3 -weight 1
	grid columnconfigure $rt 1 -weight 1
	grid columnconfigure $rt 3 -minsize $::theme::padding

	# PGN buttons
	set buttons [tk::frame $bot.buttons -takefocus 0]
	foreach {cmd var column} {backward Previous 0 forward Next 2 close Close 4} {
		set w $buttons.$cmd
		::ttk::button $w -class TButton
		$w configure -compound left -image [set ::icon::icon[string toupper $cmd 0 0]]
		::widget::dialogButtonsSetup $buttons $cmd ::widget::mc::$var close
		grid $w -row 0 -column $column -sticky ns
	}
	grid columnconfigure $buttons {1 3} -minsize $::theme::padding
	$buttons.close configure -command [list destroy $dlg]
	$buttons.backward configure -command [namespace code [list NextGame $dlg $position -1]]
	$buttons.forward configure -command [namespace code [list NextGame $dlg $position +1]]
	::tooltip::tooltip $buttons.backward [namespace current]::mc::LoadPrevGame
	::tooltip::tooltip $buttons.forward [namespace current]::mc::LoadNextGame

	set boardSize [expr {8*$squareSize + 2}]
	if {$variant eq "Crazyhouse"} {
		set holdingSize [::board::holding::computeWidth $squareSize]
		incr boardSize [expr {2*($holdingSize + $Options(holding:distance))}]
	}

	grid $controls	-row 1 -column 1 -sticky ew
	grid $buttons	-row 1 -column 3
	grid columnconfigure $bot {0 2 4} -minsize $::theme::padding
	grid columnconfigure $bot 1 -minsize $boardSize
	grid columnconfigure $bot 3 -weight 1
	grid rowconfigure $bot {0 2} -minsize $::theme::padding

	foreach t {white black event} {
		$rt.header tag bind $t <ButtonPress-3> [namespace code [list PopupMenu $dlg $board $position $t]]
	}

	set Vars(frame) $rt.pgn
	set Vars(board) $board
	set Vars(autoplay) 0
	set Vars(control:forward) $buttons.forward
	set Vars(control:backward) $buttons.backward
	set Vars(afterid) {}
	set Vars(afterid2) {}
	set Vars(header) $rt.header
	set Vars(board:size) $Options(board:size)
	set Vars(board:size:ext) $Options(board:size:ext)
	set Vars(length) -1
	set Vars(base) $base
	set Vars(variant) $variant
	set Vars(name) $name
	set Vars(view) $view
	set Vars(index) $index
	set Vars(number) $number
	set Vars(after) {}
	set Vars(current) {}
	set Vars(size:width) 0
	set Vars(size:width:plus) 0
	set Vars(size:height) 0
	set Vars(pos:x) 0
	set Vars(pos:y) 0
	set Vars(dlg) $dlg
	set Vars(closed) 0
	set Vars(fen) $fen
	set Vars(locked) no
	set Vars(info) $info
	set Vars(fullscreen) 0
	set Vars(next) {}
	set Vars(next:move) {}
	set Vars(modified) 0
	set Vars(setup) 1

	bind $dlg <Alt-Key>					[list tk::AltKeyInDialog $dlg %A]
	bind $dlg <Return>					[namespace code [list ::widget::dialogButtonInvoke $buttons]]
	bind $dlg <Return>					{+ break }
	bind $dlg <Configure>				[namespace code [list FirstConfigure %W $position]]
	bind $dlg <Control-a>				[namespace code [list ToggleAutoPlay $position]]
	bind $dlg <Destroy>					[namespace code [list Destroy $dlg %W $position]]
	bind $dlg <Left>						[namespace code [list Goto $position -1]]
	bind $dlg <Right>						[namespace code [list Goto $position +1]]
	bind $dlg <Prior>						[namespace code [list Goto $position -10]]
	bind $dlg <Next>						[namespace code [list Goto $position +10]]
	bind $dlg <Home>						[namespace code [list Goto $position -9999]]
	bind $dlg <End>						[namespace code [list Goto $position +9999]]
	bind $dlg <Control-Home>			[namespace code [list GotoGame(first) $board $position]]
	bind $dlg <Control-End>				[namespace code [list GotoGame(last) $board $position]]
	bind $dlg <Control-Down>			[namespace code [list GotoGame(next) $board $position]]
	bind $dlg <Control-Up>				[namespace code [list GotoGame(prev) $board $position]]
	bind $dlg <ButtonPress-3>			[namespace code [list PopupMenu $dlg $board $position]]
	bind $dlg <Key-plus>					[namespace code [list ChangeBoardSize $position $lt.board +5]]
	bind $dlg <Key-KP_Add>				[namespace code [list ChangeBoardSize $position $lt.board +5]]
	bind $dlg <Key-minus>				[namespace code [list ChangeBoardSize $position $lt.board -5]]
	bind $dlg <Key-KP_Subtract>		[namespace code [list ChangeBoardSize $position $lt.board -5]]
	bind $dlg <Alt-plus>					[namespace code [list ChangeBoardSize $position $lt.board max]]
	bind $dlg <Alt-KP_Add>				[namespace code [list ChangeBoardSize $position $lt.board max]]
	bind $dlg <Alt-minus>				[namespace code [list ChangeBoardSize $position $lt.board min]]
	bind $dlg <Alt-KP_Subtract>		[namespace code [list ChangeBoardSize $position $lt.board min]]
	bind $dlg <F1>							[list ::help::open .application Game-Browser -parent $dlg]

	::font::addChangeFontSizeBindings browser $dlg
	SetupControlButtons $position

	wm withdraw $dlg
#	wm minsize $dlg [expr {$Vars(size:width) + $Vars(size:width:plus)}] 1
	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	wm resizable $dlg true false
	::util::place $dlg -parent $parent -position center
	wm deiconify $dlg
	focus $buttons.close

	SetupStyle $position no
	$rt.header tag configure bold -font $::font::text(browser:bold)
	NextGame $dlg $position	;# too early for ::scidb::game::go

	bind $rt.header <<LanguageChanged>> [namespace code [list LanguageChanged $position]]
	bind $rt.header <Configure> [namespace code [list ConfigureHeader $position]]

	set Vars(subscribe:board) [list $position [namespace current]::UpdateBoard]
	set Vars(subscribe:pgn)   [list $position [namespace current]::UpdatePGN true]
	set Vars(subscribe:info)  [list [namespace current]::UpdateInfo $position]
	set Vars(subscribe:data)  [list [namespace current]::UpdateData $position]
	set Vars(subscribe:list)  [list [namespace current]::Update [namespace current]::Close $position]
	set Vars(subscribe:close) [list [namespace current]::Close $base $variant $position]

	::scidb::game::subscribe board {*}$Vars(subscribe:board)
	::scidb::game::subscribe pgn {*}$Vars(subscribe:pgn)
	::scidb::view::subscribe {*}$Vars(subscribe:close)
	::scidb::db::subscribe gameList {*}$Vars(subscribe:list)
	::scidb::db::subscribe gameInfo {*}$Vars(subscribe:info)
	::scidb::db::subscribe gameData {*}$Vars(subscribe:data)

	if {$variant == [::scidb::app::variant] && $view == [::scidb::tree::view $base]} {
		set Vars(subscribe:tree) [list [namespace current]::UpdateTreeBase {} $position]
		::scidb::db::subscribe tree {*}$Vars(subscribe:tree)
	}

	update idletasks
	::scidb::game::layout $position
	::scidb::game::go $position position $Vars(fen)

	set Priv(minWidth) [expr {[winfo width $dlg] - [winfo width $lt]}]
	set Priv(minHeight) $Priv(minWidth)
	if {[info exists Vars(holding:w)]} {
		set holdingSize [::board::holding::computeWidth $squareSize]
		set size [expr {2*($holdingSize + $Options(holding:distance))}]
		decr Priv(minHeight) $size
	}
	if {[UseFullscreen?]} {
		bind $dlg <F11> [namespace code [list ViewFullscreen $position $board]]
	}

	return $position
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
	set Vars(index) $index
	NextGame $Vars(dlg) $windowId 0
	return $windowId
}


proc showPosition {parent position flip key {state 0}} {
	set w .application.showboard

	if {![winfo exists $w]} {
		variable Options

		destroy [::util::makePopup $w]
		::board::diagram::new $w.board $Options(miniboard:size) -bordersize 2
		pack $w.board
	}

	updatePosition $parent $position $flip $key $state
	::tooltip::popup $parent $w cursor
}


proc updatePosition {parent position flip key {state 0}} {
	set w .application.showboard

	if {![winfo exists $w]} { 
		return [showPosition $parent $position $flip $key $state]
	}

	if {[llength $key] == 0} { set key [::scidb::game::query start] }
	set fen [::scidb::game::board $position $key]
	# show pawn structure if shift key is held down (or shift key is locked)
	set mask [expr {$::util::shiftMask | $::util::lockMask}]
	if {($state & $mask) == $::util::shiftMask || ($state & $mask) == $::util::lockMask} {
		set fen [string map {K . Q . R . B . N . k . q . r . b . n .} $fen]
	}
	if {$flip != [::board::diagram::rotated? $w.board]} {
		::board::diagram::rotate $w.board
	}
	::board::diagram::update $w.board $fen
	::tooltip::updatePosition $parent $w
}


proc hidePosition {parent} {
	if {[winfo exists .application.showboard]} {
		::tooltip::popdown .application.showboard
	}
}


proc showPosition? {parent} {
	return [winfo exists .application.showboard]
}


proc refresh {{unused -1}} {
	variable Active

	::widget::busyCursor on

	foreach position [array names Active] {
		variable ${position}::Vars
		::pgn::setup::setupStyle browser $position
		::pgn::setup::configureText $Vars(frame)
		::scidb::game::refresh $position -immediate
	}

	::widget::busyCursor off
}


proc resetGoto {w position} {
	variable ${position}::Vars
	variable ::pgn::browser::Colors

	if {[llength $Vars(next)]} {
		$w tag configure $Vars(next) -background [::colors::lookup $Colors(background)]
	}
	if {[llength $Vars(current)]} {
		$w tag configure $Vars(current) -background [::colors::lookup $Colors(background)]
	}
	set Vars(current) {}
	set Vars(next) {}
	set Vars(next:move) {}
}


proc showNext {w position flag} {
	variable ${position}::Vars
	variable ::pgn::browser::Colors

	if {[llength $Vars(next:move)]} {
		if {$flag} { set attr background:nextmove } else { set attr background }
		$w tag configure $Vars(next:move) -background [::colors::lookup $Colors($attr)]
	}
}


proc makeResult {result toMove termination reason variant} {
	set reasonText [::terminationbox::buildText $reason $result $toMove $termination $variant]
	set result [::util::formatResult $result]
	if {$result ne "*"} { set r1 $result } else { set r1 "" }
	if {[string length $reasonText]} { set r2 $reasonText } else { set r2 "" }
	if {[string length $r1] || [string length $r2]} { return [list $r1 $r2] }
	return {}
}


proc makeOpeningLines {data} {
	lassign $data idn position eco opening
	lassign {"" {} ""} line1 line2 line3
	lassign $opening short long
	set vars [lrange $opening 2 end]
	set eco [lindex $eco 0]
	set idn [lindex $idn 0]

if {0} {
	# TODO: should be language independent!
	foreach word {" Variation" " Defence" " Line" " Attack" " Gambit"} {
		set i [string first $word $variation]
		set k [string first $word $subvar]
		
		if {	$i + [string length $word] == [string length $variation]
			&& $k + [string length $word] == [string length $subvar]} {

			set variation [string range $variation 0 [expr {$i - 1}]]
		}
	}
}

	if {[llength $eco]} {
		append line1 $eco
		if {[string length $long]} {
			if {[llength $vars]} {
				append line1 " - " [::mc::translateEco $short]
				foreach var $vars { append line1 ", "  [::mc::translateEco $var] }
			} else {
				append line1 " - " [::mc::translateEco $long]
			}
		}
		set line1 [encoding convertfrom iso8859-1 $line1]
	} elseif {$idn > 0} {
		if {[llength $position] == 3} {
			append line1 $mc::HandicapGame ": "
			lappend line2 [lindex $position 2] figurine
			append line3 [lindex $position 1]
		} else {
			append line1 $::gamebar::mc::StartPosition " "
			if {$idn > 4*960} {
				append line1 "\""
				append line1 $position
				if {[info exists ::setup::PositionAlt($position)]} {
					append line1 " ($::setup::PositionAlt($position))"
				}
				append line1 "\""
			} else {
				if {$idn > 3*960} {
					append line1 [expr {$idn - 3*960}]
				} else {
					append line1 $idn
				}
				append line1 " ("
				lappend line2 [::font::translate $position] figurine
				append line3 ")"
				if {$idn > 960} {
					append line3 " \[$mc::NoCastlingRights\]"
				}
			}
		}
	} elseif {$idn == 0 && [llength $position]} {
		append line1 "FEN: "
		append line1 $position
	}

	if {[llength $line2] == 0} {
		set line2 {"" {}}
	}

	return [list [list $line1 eco] $line2 [list $line3 eco]]
}


proc ShowPosition {parent position key {state 0}} {
	variable ${position}::Vars
	showPosition $parent $position [::board::diagram::rotated? $Vars(board)] $key $state
}


proc SetupColumnStyle {position} {
	variable ::pgn::browser::Options

	set Options(style:column) [expr {!$Options(style:column)}]
	SetupStyle $position
}


proc SetupStyle {position {refresh yes}} {
	variable ${position}::Vars
	variable ::pgn::browser::Colors
	variable ::pgn::browser::Options
	variable Active

	if {[llength $Vars(next)]} {
		$Vars(pgn) tag configure $Vars(next) -background [::colors::lookup $Colors(background)]
	}
	if {$Options(style:column)} { set Vars(next) $Vars(next:move) } else { set Vars(next) {} }

	foreach pos [array names Active] {
		variable ${pos}::Vars
		::pgn::setup::setupStyle browser $pos
		::pgn::setup::configureText $Vars(frame)
		if {$refresh} { ::scidb::game::refresh $pos -immediate }
	}
}


proc ConfigureButtons {position} {
	variable ${position}::Vars

	if {$Vars(index) == -1} {
		$Vars(control:backward) configure -state disabled
		$Vars(control:forward) configure -state disabled
	} else {
		if {$Vars(index) == 0} { set state disabled } else { set state normal }
		$Vars(control:backward) configure -state $state
		set count [scidb::view::count games $Vars(base) $Vars(variant) $Vars(view)]
		if {$Vars(index) + 1 == $count} { set state disabled } else { set state normal }
		$Vars(control:forward) configure -state $state
	}
}


proc Update {position id base variant {view -1} {index -1}} {
	variable ${position}::Vars

	if {	$Vars(base) eq $base
		&& $Vars(variant) eq $variant
		&& ($Vars(view) == $view || $Vars(view) == 0)} {
		if {$Vars(closed)} {
			set index $Vars(index:last)
			if {[::scidb::view::count games $base $variant $Vars(view)] <= $index} { return }
			set info [::scidb::db::get gameInfo $index $Vars(view) $base $variant]
			if {$info ne $Vars(info)} { return }
			set Vars(index) $index
			set Vars(closed) false
			SetTitle $position
		}
		after cancel $Vars(after)
		set Vars(after) [after idle [namespace code [list Update2 $position]]]
	}
}


proc Update2 {position} {
	variable ${position}::Vars

	if {![namespace exists [namespace current]::${position}]} { return }
	set index [expr {$Vars(number) - 1}]
	set Vars(index) [::scidb::db::get gameIndex $index $Vars(view) $Vars(base) $Vars(variant)]
	ConfigureButtons $position
}


proc UpdateInfo {position id} {
	if {$id > 10} { return }
	if {![info exists ${position}::Vars]} { return }

	variable ${position}::Vars
	variable Options

	set sink [::scidb::game::sink? $position]
	lset sink 1 [::util::toMainVariant [lindex $sink 1]]

	if {$Vars(link) eq $sink} {
		set Vars(modified) 1
		$Vars(header) configure -background [::colors::lookup $Options(background:modified)]
		foreach item {event white black} {
			$Vars(header) tag configure $item \
				-background [::colors::lookup $Options(background:modified)] \
				;
		}
	}
}


proc UpdateData {position id evenMainline} {
	if {$evenMainline} {
		UpdateInfo $position $id
	}
}


proc Close {position base variant {view {}}} {
	variable ${position}::Vars

	if {!$Vars(closed) && ([llength $view] == 0 || $view == $Vars(view))} {
		set Vars(index:last) $Vars(index)
		set Vars(index) -1
		set Vars(closed) 1
		ConfigureButtons $position
		SetTitle $position
	}
}


proc UpdateTreeBase {position base variant} {
	variable ${position}::Vars

	if {$base ne $Vars(base) || $variant ne $Vars(variant)} {
		Close $position $base $variant
	}
}


proc GotoGame(first) {parent position} {
	variable ${position}::Vars

	if {$Vars(index) > 0} {
		set Vars(index) 0
		NextGame $parent $position
	}
}


proc GotoGame(last) {parent position} {
	variable ${position}::Vars

	set index [expr {[scidb::view::count games $Vars(base) $Vars(variant) $Vars(view)] - 1}]

	if {$Vars(index) < $index} {
		set Vars(index) $index
		NextGame $parent $position
	}
}


proc GotoGame(next) {parent position} {
	NextGame $parent $position +1
}


proc GotoGame(prev) {parent position} {
	NextGame $parent $position -1
}


proc NextGame {parent position {step 0}} {
	variable ${position}::Vars
	variable Options
	variable Priv

	if {$Vars(index) == -1} { return }
	set count [scidb::view::count games $Vars(base) $Vars(variant) $Vars(view)]
	set number $Vars(number)
	set index [expr {$Vars(index) + $step}]
	if {$index < 0 || $index == $count} { return }
	set Vars(index) $index
	set Vars(info) [::scidb::db::get gameInfo $index $Vars(view) $Vars(base) $Vars(variant)]
	set Vars(result) [list [::util::formatResult [::gametable::column $Vars(info) result]] ""]
	set Vars(number) [::gametable::column $Vars(info) number]
	set key "$Vars(base):$Vars(variant):$number:$Vars(view)"
	set i [lsearch -exact $Priv($key) $parent]
	if {$i >= 0} { set Priv($key) [lreplace $Priv($key) $i $i] }
	if {[llength $Priv($key)] == 0} { array unset Priv $key }
	set key "$Vars(base):$Vars(variant):$Vars(number):$Vars(view)"
	lappend Priv($key) [winfo toplevel $parent]
	ConfigureButtons $position
	SetTitle $position
	set number [::scidb::db::get gameNumber $Vars(base) $Vars(variant) $index $Vars(view)]
	::widget::busyOperation {
		::game::load $parent $position $Vars(base) \
			-number $number \
			-variant $Vars(variant) \
			-view $Vars(view) \
			;
	}
	::scidb::game::go $position position $Vars(fen)
	if {$Vars(modified)} {
		$Vars(header) configure -background [::colors::lookup $Options(background:header)]
		set Vars(modified) 0
	}
	if {$Vars(setup)} {
		::pgn::setup::setupStyle browser $position
		set Vars(setup) 0
	}
	::scidb::game::refresh $position -immediate
	set Vars(link) [lrange [::scidb::game::link? $position] 0 2]
	lset Vars(link) 1 [::util::toMainVariant [lindex $Vars(link) 1]]
}


proc SetTitle {position} {
	variable ${position}::Vars

	set title "[tk appname] - $mc::BrowseGame"
	if {$Vars(index) >= 0} {
		append title " ($Vars(name) #$Vars(number))"
	}
	wm title [winfo toplevel $Vars(board)] $title
}


proc Goto {position step} {
	if {![namespace exists [namespace current]::${position}]} { return }

	variable ${position}::Vars
	variable Options

	::scidb::game::go $position $step

	if {$Vars(autoplay)} {
		if {[::scidb::game::position $position atEnd?]} {
			ToggleAutoPlay $position
		} else {
			after cancel $Vars(afterid)
			set Vars(afterid) [after $Options(autoplay:delay) [namespace code [list Goto $position +1]]]
		}
	}
}


proc LanguageChanged {position} {
	variable ${position}::Vars

	if {[::scidb::game::query $position length] == 0} {
		set w $Vars(pgn)
		$w configure -state normal
		$w delete 1.0 end
		PrintResult $w $position
		$w configure -state disabled
	}

	SetupControlButtons $position
	UpdateHeader $position
	SetTitle $position
}


proc SetupControlButtons {position} {
	variable ${position}::Vars
	variable Accelerator

	::tooltip::tooltip $Vars(control:help) "$::help::mc::Help (F1)"

	foreach {control var} {	Home	GotoStartOfGame
									Prior	GoBackFast
									Left	GoBackward
									Right	GoForward
									Next	GoForwardFast
									End	GotoEndOfGame} {
		::tooltip::tooltip $Vars(control:$control) "[set mc::$var] ($::mc::Key($control))"
	}

	::tooltip::tooltip $Vars(control:rotate) \
		"$::overview::mc::RotateBoard ($::overview::mc::AcceleratorRotate)"

	SetAutoPlayTooltip $position

	if {[info exists Accelerator]} {
		bind $Vars(dlg) <Key-[string tolower $Accelerator]> {#}
		bind $Vars(dlg) <Key-[string toupper $Accelerator]> {#}
	}

	set accel $::overview::mc::AcceleratorRotate
	bind $Vars(dlg) <Key-[string tolower $accel]> [namespace code [list RotateBoard $position]]
	bind $Vars(dlg) <Key-[string toupper $accel]> [namespace code [list RotateBoard $position]]

	set Accelerator $::overview::mc::AcceleratorRotate
}


proc UpdateHeader {position} {
	variable ${position}::Vars

	set text $Vars(header)
	$text configure -state normal

	$text delete 1.0 end

	foreach id {white black event site date annotator} {
		set $id [::gametable::column $Vars(info) $id]
	}

	set data $Vars(data)

	if {[lindex $data 0] == 0} {
		lset data 1 [::scidb::game::query $position fen]
	}

	if {[llength $white] == 0} { set white "?" }
	if {[llength $black] == 0} { set black "?" }
	if {$event eq "-" || $event eq "?"} { set event "" }
	if {$site eq "-" || $site eq "?"} { set site "" }

	set evline $event
	if {[llength $event] && [llength $site]} { append evline ", " }
	append evline $site
	if {[llength $evline] && [llength $date]} { append evline ", " }
	append evline [::locale::formatNormalDate $date]

	$text delete 1.0 end
	if {[string length $evline]} {
		$text insert end $evline event
		$text insert end \n
	}
	$text insert end $white {white bold}
	$text insert end " \u2013 " bold
	$text insert end $black {black bold}

	if {[string length $event] > 1} {
		$text tag bind event <Any-Enter>			[namespace code [list EnterItem $position event]]
		$text tag bind event <Any-Leave>			[namespace code [list LeaveItem $position event]]
		$text tag bind event <ButtonPress-2>	[namespace code [list ShowEvent $position]]
		$text tag bind event <ButtonRelease-2>	[namespace code [list HideEvent $position]]
	}

	foreach side {white black} {
		if {[string length [set $side]] > 1} {
			$text tag bind $side <Any-Enter>			[namespace code [list EnterItem $position $side]]
			$text tag bind $side <Any-Leave>			[namespace code [list LeaveItem $position $side]]
			$text tag bind $side <ButtonPress-1>	[namespace code [list ShowPlayerCard $position $side]]
			$text tag bind $side <ButtonPress-2>	[namespace code [list ShowPlayerInfo $position $side]]
			$text tag bind $side <ButtonRelease-2>	[namespace code [list HidePlayerInfo $position $side]]
		}
	}

	set variant [::scidb::game::query $position variant?]

	switch $variant {
		Normal {
			set Vars(opening) [makeOpeningLines $data]

			if {[llength [lindex $Vars(opening) 0 0]]} {
				$text insert end "\n"
				foreach line $Vars(opening) {
					$text insert end {*}$line
				}
			}
		}
		Suicide - Giveaway - Losers {
			$text insert end "\n$::mc::VariantName(Antichess) - $::mc::VariantName($variant)"
		}
		default {
			$text insert end "\n$::mc::VariantName($variant)"
		}
	}

	update idletasks ;# makes -displaylines working
	$text configure -height [$text count -displaylines 1.0 end]
	$text configure -state disabled
}


proc ShowEvent {position} {
	variable ${position}::Vars

	if {$Vars(modified)} { return }
	if {$Vars(closed)} { return }

	set index [expr {$Vars(number) - 1}]

	set info [scidb::db::fetch eventInfo $index $Vars(base) $Vars(variant) -card]
	::eventtable::popupInfo $Vars(header) $info
}


proc HideEvent {position} {
	variable ${position}::Vars

	if {$Vars(modified)} { return }
	::eventtable::popdownInfo $Vars(header)
}


proc EnterItem {position item {locked no}} {
	variable ${position}::Vars
	variable Options

	if {$Vars(modified)} { return }
	set Vars(locked) $locked
	if {$Vars(closed)} { return }

	$Vars(header) tag configure $item \
		-background [::colors::lookup $Options(background:hilite)] \
		-foreground [::colors::lookup $Options(foreground:hilite)] \
		;
}


proc LeaveItem {position item {force no}} {
	variable ${position}::Vars
	variable Options

	if {$Vars(modified)} { return }
	if {$force} { set Vars(locked) no }
	if {$Vars(closed)} { return }

	if {!$Vars(locked)} {
		$Vars(header) tag configure $item \
			-background [::colors::lookup $Options(background:header)] \
			-foreground black \
			;
	}
}


proc ShowPlayerCard {position side} {
	variable ${position}::Vars

	if {$Vars(modified)} { return }
	if {$Vars(closed)} { return }
	::playercard::show $Vars(base) $Vars(variant) [expr {$Vars(number) - 1}] $side
}


proc ShowPlayerInfo {position side} {
	variable ${position}::Vars

	if {$Vars(modified)} { return }
	if {$Vars(closed)} { return }

	set base $Vars(base)
	set variant $Vars(variant)
	set index [expr {$Vars(number) - 1}]

	set info [scidb::db::fetch ${side}PlayerInfo $index $base $variant -card -ratings {Any Any}]
	::playercard::popupInfo $Vars(header) $info
}


proc HidePlayerInfo {position side} {
	variable ${position}::Vars

	if {$Vars(modified)} { return }
	::playercard::popdownInfo $Vars(header)
}


proc Dump {w} {
	set dump [$w dump -all 1.0 end]
	foreach {type attr pos} $dump {
		if {$attr ne "current" && $attr ne "insert"} {
			if {$attr eq "\n"} { set attr "\\n" }
			if {$attr eq "\t"} { set attr "\\t" }
			switch $type {
				tagon - tagoff {}
				default { puts "$pos: $type $attr" }
			}
		}
	}
	puts "==============================================="
}


proc UpdatePGN {position data {w {}}} {
	variable ${position}::Vars
	variable ::pgn::browser::Colors
	variable ::pgn::browser::Options

	if {[llength $w] == 0} { set w $Vars(pgn) }

	foreach node $data {
		switch [lindex $node 0] {
			start {
				$w configure -state normal
				$w delete 1.0 end
				set current $Vars(current)
				set Vars(current) {}
				set Vars(active) {}
				set Vars(next) {}
				set Vars(next:move) {}
			}

			header {
				if {[info exists Vars(header)]} {
					foreach entry [lindex $node 1] {
						set value [lrange $entry 1 end]
						switch [lindex $entry 0] {
							idn		{ set idn $value }
							eco		{ set eco $value }
							position { set pos $value }
							opening	{ set opg $value }
						}
					}
					set Vars(data) [list $idn $pos $eco $opg]
					UpdateHeader $position
				}
			}

			move {
				set key [lindex $node 1]
				set moves [lindex $node 2]

				if {[llength $moves] == 0} {
					if {![::scidb::game::query $position empty?]} {
						$w insert end "\u200b" $key
#						PrintMove $w $position $key "\u27a4 "
					}
				}

				foreach move $moves {
					switch [lindex $move 0] {
						annotation - marks { ;# skip }

						space { $w insert end " " }
						break { $w insert end "\n" }

						ply {
							lassign [lindex $move 1] moveNo stm san legal
							if {$Options(style:column)} { $w insert end "\t" }
							if {$moveNo > 0} {
								$w insert end "$moveNo." $key
								if {$Options(style:column)} { $w insert end "\t" }
							}
							foreach {text tag} [::font::splitMoves $san] {
								if {!$legal} { lappend tag illegal }
								PrintMove $w $position $key $text $tag
							}
						}
					}
				}
			}

			result {
				set reason [::scidb::game::query $position termination]
				if {[info exists Vars(variant)]} { set variant $Vars(variant) } else { set variant Normal }
				set Vars(result) [makeResult {*}[lrange $node 1 end] $reason $variant]
				PrintResult $w $position
				if {[llength $current]} {
					catch { $w tag configure $current -background [::colors::lookup $Colors(background)] }
				}
				$w configure -state disabled
			}

			action {
				lassign [lindex $node 1] cmd key

				if {$cmd eq "goto" } {
					if {$Vars(current) eq $key} { return }
					if {[llength $Vars(next)]} {
						$w tag configure $Vars(next) -background [::colors::lookup $Colors(background)]
					}
					set Vars(next:move) [::scidb::game::next keys $position]
					if {$Options(style:column)} {
						set Vars(next) $Vars(next:move)
					}
					if {$Vars(active) eq $key} { $w configure -cursor {} }
					set previous $Vars(current)
					if {[llength $previous]} {
						$w tag configure $previous -background  [::colors::lookup $Colors(background)]
					}
					$w tag configure $key -background [::colors::lookup $Colors(background:current)]
					if {[llength $Vars(next)]} {
						$w tag configure $Vars(next) \
							-background [::colors::lookup $Colors(background:nextmove)]
					}
					if {[llength $previous]} {
						set nextkey [$w tag nextrange $key 1.0]
						if {[llength $nextkey]} { $w see [lindex $nextkey 0] }
					}
					set Vars(current) $key
					if {[llength $previous] && $Vars(active) eq $previous} {
						EnterMove $w $position $previous
					}
					if {[info exists Vars(holding:w)]} {
						lassign [::scidb::pos::inHand? $position] matw matb
						::board::holding::update $Vars(holding:w) $matw
						::board::holding::update $Vars(holding:b) $matb
					}
				}
			}
		}
	}
}


proc PrintResult {w position} {
	variable ${position}::Vars
	variable ::pgn::browser::Options

	if {[::scidb::game::query $position length] == 0} {
		$w insert end "<$::application::pgn::mc::EmptyGame>" empty
	}
	if {[llength $Vars(result)]} {
		lassign $Vars(result) result reason
		$w insert end \n
		if {[string length $result]} {
			$w insert end $result result
		}
		if {[string length $reason]} {
			if {[string length $result]} { $w insert current " " }
			$w insert current "($reason)"
		}
	}
}


proc PrintMove {w position key text {tag ""}} {
	$w insert end $text [list {*}$tag $key]

	if {$position >= 100} {
		$w tag bind $key <Any-Enter> [namespace code [list EnterMove $w $position $key]]
		$w tag bind $key <Any-Leave> [namespace code [list LeaveMove $w $position $key]]
		$w tag bind $key <ButtonPress-1> [list ::scidb::game::moveto $position $key]
		$w tag bind $key <ButtonPress-2> [namespace code [list ShowPosition $w $position $key %s]]
		$w tag bind $key <ButtonRelease-2> [namespace code [list hidePosition $w]]
	}
}


proc Tooltip {path nag} {
	variable ::annotation::mc::Nag

	switch $nag {
		hide		{ ::tooltip::tooltip hide }
		illegal	{ ::tooltip::show $path $mc::IllegalMove }
	}
}


proc EnterMove {w position key} {
	variable ${position}::Vars
	variable ::pgn::browser::Colors

	if {$Vars(current) ne $key} {
		$w tag configure $key -background [::colors::lookup $Colors(hilite:move)]
		$w configure -cursor hand2
	}

	set Vars(active) $key
}


proc LeaveMove {w position key} {
	variable ${position}::Vars
	variable ::pgn::browser::Colors

	set Vars(active) {}

	if {$Vars(current) ne $key} {
		if {$key in $Vars(next)} {
			set color $Colors(background:nextmove)
		} else {
			set color $Colors(background)
		}
		$w tag configure $key -background [::colors::lookup $color]
		$w configure -cursor {}
	}
}


proc UpdateBoard {position cmd data} {
	variable ${position}::Vars

	switch $cmd {
		set	{ ::board::diagram::update $Vars(board) $data }
		move	{ ::board::diagram::move $Vars(board) $data }
	}
}


proc ToggleAutoPlay {position {hide 0}} {
	variable ${position}::Vars

	set w $Vars(control:autoplay)

	if {[$w cget -image] eq $::icon::22x22::start} {
		$w configure -image $::icon::22x22::playerStop
		set Vars(autoplay) 1
		Goto $position +1
	} else {
		$w configure -image $::icon::22x22::start
		set Vars(autoplay) 0
		after cancel $Vars(afterid)
		set Vars(afterid) {}
	}

	SetAutoPlayTooltip $position
	if {$hide} { ::tooltip::tooltip hide }
}


proc SetAutoPlayTooltip {position} {
	variable ${position}::Vars

	if {[$Vars(control:autoplay) cget -image] eq $::icon::22x22::start} {
		set tooltipVar StartAutoplay
	} else {
		set tooltipVar StopAutoplay
	}

	::tooltip::tooltip $Vars(control:autoplay) "[set mc::$tooltipVar] ($::mc::Key(Ctrl)-A)"
}	


proc RotateBoard {position} {
	variable ${position}::Vars

	::board::diagram::rotate $Vars(board)
	if {[::board::diagram::rotated? $Vars(board)]} { set w b; set b w } else { set w w; set b b }

	if {[info exists Vars(holding:w)]} {
		grid $Vars(holding:$w) -column 5 -row 1 -sticky s
		grid $Vars(holding:$b) -column 1 -row 1 -sticky n
	}
}


proc Destroy {dlg w position} {
	variable Active

	if {$w ne $dlg} { return }

	variable ${position}::Vars
	variable Priv

#	XXX
#	::scidb::game::unsubscribe board {*}$Vars(subscribe:board)
#	::scidb::game::unsubscribe pgn {*}$Vars(subscribe:pgn)
	::scidb::db::unsubscribe gameInfo {*}$Vars(subscribe:info)
	::scidb::db::unsubscribe gameList {*}$Vars(subscribe:list)
	::scidb::view::unsubscribe {*}$Vars(subscribe:close)

	if {[info exists Vars(subscribe:tree)]} {
		::scidb::db::unsubscribe tree {*}$Vars(subscribe:tree)
	}

	set key "$Vars(base):$Vars(variant):$Vars(number):$Vars(view)"
	set i [lsearch -exact $Priv($key) $dlg]
	if {$i >= 0} { set Priv($key) [lreplace $Priv($key) $i $i] }
	if {[llength $Priv($key)] == 0} { array unset Priv $key }

	::scidb::game::release $position
	::pgn::setup::closeText $Vars(frame) browser
	namespace delete [namespace current]::${position}
	array unset Active $position
}


proc ConfigureHeader {position} {
	variable ${position}::Vars

	after cancel $Vars(afterid2)
	set Vars(afterid2) [after 50 [namespace code [list ConfigureHeader2 $position]]]
}


proc ConfigureHeader2 {position} {
	variable ${position}::Vars

	if {![namespace exists [namespace current]::${position}]} { return }
	$Vars(header) configure -height [$Vars(header) count -displaylines 1.0 end]
}


proc FirstConfigure {w position} {
	if {[winfo toplevel $w] eq $w && [winfo width $w] > 1} {
		after idle [namespace code [list SetMinSize $w $position]]
		bind $w <Configure> [namespace code [list SecondConfigure $w $position %w]]
	}
}


proc SecondConfigure {w position width} {
	variable ${position}::Vars

	if {!$Vars(fullscreen)} {
		set Vars(size:width:plus) [expr {max(0, [winfo width $w] - $Vars(size:width))}]
		set Vars(pos:x) [max 0 [winfo rootx $w]]
		set Vars(pos:y) [max 0 [winfo rooty $w]]
	}
}


proc SetMinSize {w position} {
	variable ${position}::Vars

	if {![namespace exists [namespace current]::${position}]} { return }
	wm minsize $w [winfo width $w] [winfo height $w]
	set Vars(size:width) [winfo width $w]
	set Vars(size:height) [winfo height $w]
}


proc PopupMenu {parent board position {what ""}} {
	variable ${position}::Vars

	if {$Vars(locked)} { return }

	set dlg [winfo toplevel $board]
	set menu $dlg.__menu__
	catch { destroy $menu }
	menu $menu -tearoff 0
	catch { wm attributes $m -type popup_menu }

	if {!$Vars(closed) && [string length $what]} {
		EnterItem $position $what yes
		set index [expr {$Vars(number) - 1}]

		switch $what {
			white - black {
				set info [scidb::db::fetch \
					${what}PlayerInfo $index $Vars(base) $Vars(variant) -card -ratings {Any Any}]
				::playertable::popupMenu \
					$menu $Vars(base) $Vars(variant) $info [list [expr {$Vars(number) - 1}] $what]
			}

			event {
				set info [scidb::db::fetch eventInfo $index $Vars(base) $Vars(variant) -card]
				::eventtable::popupMenu $dlg $menu $Vars(base) $Vars(variant) 0 $index game
			}
		}

		bind $menu <<MenuUnpost>> [namespace code [list LeaveItem $position $what yes]]
		$menu add separator
	}

	if {!$Vars(closed)} {
		set count [scidb::view::count games $Vars(base) $Vars(variant) $Vars(view)]

		if {$Vars(index) == -1} { set state disabled } else { set state normal }
		$menu add command \
			-label " $mc::LoadGame" \
			-image $::icon::16x16::document \
			-compound left \
			-command [namespace code [list LoadGame $dlg $position [::scidb::game::fen $position]]] \
			-state $state \
			;
		if {[::scidb::game::current] < 9} { set state normal } else { set state disabled }
		if {[::merge::alreadyMerged [::scidb::game::current] $position]} { set state disabled }
		$menu add command \
			-label " $::merge::mc::MergeGameFrom..." \
			-image $::icon::16x16::merge \
			-compound left \
			-command [list gamebar::mergeGame $parent $position] \
			-state $state \
			;
		if {$Vars(modified)} { set state normal } else { set state disabled }
		$menu add command \
			-label " $mc::ReloadGame" \
			-image $::icon::16x16::refresh \
			-compound left \
			-command [namespace code [list ReloadGame $dlg $position]] \
			-state $state \
			;
		$menu add separator
		if {$count <= 1 || $Vars(index) == 0} { set state disabled } else { set state normal }
		$menu add command \
			-label " $mc::GotoGame(prev)" \
			-image $::icon::16x16::backward \
			-compound left \
			-command [namespace code [list GotoGame(prev) $parent $position]] \
			-accel "$::mc::Key(Ctrl)-$::mc::Key(Up)" \
			-state $state \
			;
		if {$count <= 1 || $Vars(index) + 1 == $count} { set state disabled } else { set state normal }
		$menu add command \
			-label " $mc::GotoGame(next)" \
			-image $::icon::16x16::forward \
			-compound left \
			-command [namespace code [list GotoGame(next) $parent $position]] \
			-accel "$::mc::Key(Ctrl)-$::mc::Key(Down)" \
			-state $state \
			;
		if {$count <= 1 || $Vars(index) == 0} { set state disabled } else { set state normal }
		$menu add command \
			-label " $mc::GotoGame(first)" \
			-image $::icon::16x16::first \
			-compound left \
			-command [namespace code [list GotoGame(first) $parent $position]] \
			-accel "$::mc::Key(Ctrl)-$::mc::Key(Home)" \
			-state $state \
			;
		if {$count <= 1 || $Vars(index) + 1 == $count} { set state disabled } else { set state normal }
		$menu add command \
			-label " $mc::GotoGame(last)" \
			-image $::icon::16x16::last \
			-compound left \
			-command [namespace code [list GotoGame(last) $parent $position]] \
			-accel "$::mc::Key(Ctrl)-$::mc::Key(End)" \
			-state $state \
			;
		$menu add separator
	}

	if {!$Vars(fullscreen)} {
		$menu add command \
			-label " $mc::IncreaseBoardSize" \
			-image $::icon::16x16::plus \
			-compound left \
			-command [namespace code [list ChangeBoardSize $position $board +5]] \
			-accelerator "+" \
			;
		$menu add command \
			-label " $mc::DecreaseBoardSize" \
			-image $::icon::16x16::minus \
			-compound left \
			-command [namespace code [list ChangeBoardSize $position $board -5]] \
			-accelerator "\u2212" \
			;
		$menu add command \
			-label " $mc::MaximizeBoardSize" \
			-image $::icon::16x16::maximize \
			-compound left \
			-command [namespace code [list ChangeBoardSize $position $board max]] \
			-accelerator "${::mc::Key(Alt)} +" \
			;
		$menu add command \
			-label " $mc::MinimizeBoardSize" \
			-image $::icon::16x16::minimize \
			-compound left \
			-command [namespace code [list ChangeBoardSize $position $board min]] \
			-accelerator "${::mc::Key(Alt)} \u2212" \
			;
	}
	if {[UseFullscreen?]} {
		if {$Vars(fullscreen)} { set var LeaveFullscreen } else { set var Fullscreen }
		$menu add command \
			-label " [::mc::stripAmpersand [set ::menu::mc::$var]]" \
			-image $::icon::16x16::fullscreen \
			-compound left \
			-command [namespace code [list ViewFullscreen $position $board]] \
			-accelerator "F11" \
			;
	}

	$menu add separator
	::font::addChangeFontSizeToMenu browser $menu
	if {$::theme::useCustomStyleMenuEntries} {
		if {$::pgn::browser::Options(style:column)} { set state Yes } else { set state No }
		$menu add command \
			-label " $::pgn::setup::mc::ParLayout(column-style)" \
			-image [set ::theme::icon::16x16::check$state] \
			-compound left \
			-command [namespace code [list SetupColumnStyle $position]] \
			;
	} else {
		$menu add checkbutton \
			-label " $::pgn::setup::mc::ParLayout(column-style)" \
			-variable ::pgn::browser::Options(style:column) \
			;
		::theme::configureCheckEntry $menu
	}
	menu $menu.moveStyles -tearoff no
	$menu add cascade \
		-menu $menu.moveStyles \
		-label " $::application::pgn::mc::MoveNotation" \
		-image $::icon::16x16::none \
		-compound left \
		;
	foreach style $::notation::moveStyles {
		$menu.moveStyles add radiobutton \
			-compound left \
			-label $::notation::mc::MoveForm($style) \
			-variable ::pgn::browser::Options(style:move) \
			-value $style \
			-command [namespace code [list SetupStyle $position]] \
			;
		::theme::configureRadioEntry $menu.moveStyles
	}
	$menu add command \
		-label " $::pgn::setup::mc::Configure(browser)..." \
		-command [namespace code [list ConfigureBrowser $parent]] \
		-image $::icon::16x16::none \
		-compound left \
		;

	$menu add separator
	$menu add command \
		-label " $::help::mc::Help" \
		-image $::icon::16x16::help \
		-compound left \
		-command [list ::help::open .application Game-Browser -parent $dlg] \
		-accelerator "F1" \
		;

	tk_popup $menu {*}[winfo pointerxy $dlg]
}


proc ConfigureBrowser {parent} {
	namespace eval [namespace current]::11 {}
	variable 11::Vars

	set Vars(next) {}
	set Vars(next:move) {}
	set Vars(current) {}
	::scidb::game::new 11
	::pgn::setup::openSetupDialog [winfo toplevel $parent] browser 11
	::scidb::game::release 11
	::scidb::tree::freeze 0
	namespace delete [namespace current]::11
}


proc ViewFullscreen {position board} {
	variable ${position}::Vars

	set Vars(fullscreen) [expr {!$Vars(fullscreen)}]
	wm attributes [winfo toplevel $Vars(pgn)] -fullscreen $Vars(fullscreen)
	if {$Vars(fullscreen)} { set mode fullscreen } else { set mode restore }
	after idle [namespace code [list ChangeBoardSize $position $board $mode]]
}


proc LoadGame {parent position fen} {
	variable ${position}::Vars

	::widget::busyOperation {
		::game::new $parent \
			-base $Vars(base) \
			-variant $Vars(variant) \
			-view $Vars(view) \
			-number [expr {$Vars(number) - 1}] \
			-fen $fen \
			;
	}
}


proc ReloadGame {parent position} {
	variable ${position}::Vars
	variable Options

	set Vars(info) [::scidb::db::get gameInfo $Vars(index) $Vars(view) $Vars(base) $Vars(variant)]

	::widget::busyOperation {
		::game::load $parent $position $Vars(base) \
			-variant $Vars(variant) \
			-view $Vars(view) \
			-number [expr {$Vars(number) - 1}] \
			;
	}

	set Vars(modified) 0
	$Vars(header) configure -background [::colors::lookup $Options(background:header)]
	foreach item {event white black} {
		$Vars(header) tag configure $item \
			-background [::colors::lookup $Options(background:header)] \
			;
	}
	::scidb::game::refresh $position -immediate
}


proc ChangeBoardSize {position board mode} {
	variable ${position}::Vars
	variable Options
	variable Priv

	if {![namespace exists [namespace current]::${position}]} { return }
	if {$Vars(fullscreen) && $mode ne "fullscreen"} { return }

	set squareSize $Vars(board:size)
	set squareSizeExt $Vars(board:size:ext)

	if {$Vars(variant) eq "Crazyhouse"} { set ext ":ext" } else { set ext "" }
	set result [ComputeBoardSize $position $board $mode $ext]

	if {[llength $result]} {
		lassign $result newSize delta

		if {$mode ne "fullscreen" && $mode ne "restore"} {

			if {[string length $ext]} { set notExt "" } else { set notExt ":ext" }
			set result2 [ComputeBoardSize $position $board $mode $notExt]

			if {[llength $result2]} {
				lassign $result2 newSize2 _

				switch $mode {
					min - max {
						set Vars(board:size$notExt) $newSize2
						set Options(board:size$notExt) $newSize2
					}
					default {
						if {$mode < 0} {
							set newSize2 [expr {max($newSize, $newSize2)}]
							if {$newSize2 < $Vars(board:size$notExt)} {
								set Vars(board:size$notExt) $newSize2
								set Options(board:size$notExt) $newSize2
							}
						} else {
							set newSize2 [expr {min($newSize, $newSize2)}]
							if {$newSize2 > $Vars(board:size$notExt)} {
								set Vars(board:size$notExt) $newSize2
								set Options(board:size$notExt) $newSize2
							}
						}
					}
				}
			}
		}

		Resize $position $mode $board $newSize $delta $ext
	}
}


proc Resize {position mode board newSize delta ext} {
	variable ${position}::Vars
	variable Options
	variable Priv

	set dlg [winfo toplevel $board]

	if {$mode eq "fullscreen"} {
		if {[info exists Vars(control)]} {
			grid $Vars(control)
		} else {
			set Vars(control) [::widget::dialogFullscreenButtons $dlg]
			grid $Vars(control) -row 0 -column 0 -sticky ens
			grid rowconfigure $dlg 0 -minsize $Priv(controls:height)
			$Vars(control).minimize configure -command [list wm iconify $dlg]
			$Vars(control).restore configure \
				-command [namespace code [list ViewFullscreen $position $board]] \
				;
			$Vars(control).close configure -command [list destroy $dlg]
		}
	} else {
		if {$mode eq "restore"} {
			grid remove $Vars(control)
			grid rowconfigure $dlg 0 -minsize 0
			wm geometry $dlg +$Vars(pos:x)+$Vars(pos:y)
		}
		set Vars(size:width) [expr {$Vars(size:width) + 8*$delta}]
		set Vars(size:height) [expr {$Vars(size:height) + 8*$delta}]
		if {[string length $ext]} { incr Vars(size:width) [expr {2*$delta}] }
		wm minsize $dlg $Vars(size:width) $Vars(size:height)
		wm geometry $dlg [expr {$Vars(size:width) + $Vars(size:width:plus)}]x${Vars(size:height)}
	}

	if {$newSize != $Vars(board:size$ext)} {
		if {$Vars(fullscreen)} {
			if {$Priv(fullscreen:size$ext) == 0} {
				::board::registerSize $newSize
				set Priv(board:size) $newSize
				set Priv(fullscreen:size$ext) $newSize
			}
		} else {
			if {$newSize != $Priv(fullscreen:size$ext)} {
				::board::registerSize $newSize
				set Priv(board:size) $newSize
			}
			if {$Vars(board:size$ext) != $Priv(fullscreen:size$ext)} {
				::board::unregisterSize $Vars(board:size$ext)
			}
		}
		::board::diagram::resize $board $newSize
		set size [expr {8*$newSize + 2}]
		if {[info exists Vars(holding:w)]} {
			::board::holding::resize $Vars(holding:w) $newSize
			::board::holding::resize $Vars(holding:b) $newSize
			set holdingSize [::board::holding::computeWidth $newSize]
			incr size [expr {2*($holdingSize + $Options(holding:distance))}]
		}
		grid columnconfigure $dlg.bot 1 -minsize $size
		set Vars(board:size$ext) $newSize
	}

	if {!$Vars(fullscreen)} {
		set Options(board:size$ext) $newSize

		update idletasks

		set x0 [winfo rootx $dlg]
		set y0 [winfo rooty $dlg]
		set x1 [expr {[winfo workareawidth  $dlg] - [winfo width  $dlg] - 25}]
		set y1 [expr {[winfo workareaheight $dlg] - [winfo height $dlg] - 25}]

		if {$x1 >= 0 && $y1 >= 0 && ($x1 < $x0 || $y1 < $y0)} {
			wm geometry $dlg +[min $x0 $x1]+[min $y0 $y1]
		}
	}
}


proc ComputeBoardSize {position board mode ext} {
	variable ${position}::Vars
	variable Options
	variable Priv

	set squareSize $Options(board:size$ext)
	set dlg [winfo toplevel $board]
	set max1 [expr {([winfo workareaheight $dlg] - [winfo height $dlg] + 8*$squareSize - 30)/8}]
	if {[string length $ext]} { set n 10 } else { set n 8 }
	set max2 [expr {([winfo workareawidth $dlg] - $Priv(minWidth) - 16)/$n}]
	set maxSize [min $max1 $max2]
	set maxSize [expr {$maxSize - ($maxSize % 5)}]

	switch $mode {
		max {
			set newSize $maxSize
			set delta [expr {$newSize - $squareSize}]
			if {$delta <= 0} { return {} }
		}

		min {
			set newSize 35
			set delta [expr {$newSize - $squareSize}]
			if {$delta >= 0} { return {} }
		}

		fullscreen {
			set boardSize [expr {[winfo screenheight $dlg] - [winfo height $dlg] -
										$Priv(controls:height) + 8*$squareSize}]
			set newSize [expr {$boardSize/8}]
			set delta 0
		}

		restore {
			set newSize $squareSize
			set delta 0
		}

		default {
			set delta $mode
			set newSize [expr {$squareSize + $delta}]
			if {$delta < 0 && $newSize < 35} { return {} }
			if {$delta > 0 && $newSize > $maxSize} { return {} }
		}
	}

	return [list $newSize $delta]
}


proc UseFullscreen? {} {
	variable Priv

	set sw [winfo screenwidth .application]
	set sh [winfo screenheight .application]
	return [expr {$sh + $Priv(minHeight) - $Priv(controls:height) <= $sw}]
}


proc WriteOptions {chan} {
	options::writeItem $chan [namespace current]::Options
}

::options::hookWriter [namespace current]::WriteOptions

} ;# namespace browser

namespace eval pgn {
namespace eval browser {

proc refresh {regardFontSize}					{ ::browser::refresh $regardFontSize }
proc resetGoto {w position}					{ ::browser::resetGoto $w $position }
proc showNext {w position flag}				{ ::browser::showNext $w $position $flag }
proc doLayout {position data context w}	{ ::browser::UpdatePGN $position $data $w }

} ;# browser
} ;# pgn

# vi:set ts=3 sw=3:
