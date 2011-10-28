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

set IllegalMove			"Illegal move"
set NoCastlingRights		"no castling rights"

set GotoFirstGame			"Goto first game"
set GotoLastGame			"Goto last game"

set LoadGame				"Load Game"
set MergeGame				"Merge Game"

} ;# namespace mc

namespace import ::tcl::mathfunc::max

set Priv(count) 100

array set Options {
	font						TkTextFont
	board:size				40
	autoplay:delay			2500
	repeat:interval		300
	background:pgn			white
	background:header		#ebf4f5
	background:hilite		cornflowerblue
	foreground:hilite		white
	background:current	#ffdd76
	foreground:result		black
	foreground:empty		#666666
}

set Options(font:bold) [list \
	[font configure $Options(font) -family] \
	[font configure $Options(font) -size] \
	bold \
]


proc open {parent base info view index {fen {}}} {
	variable Options
	variable Priv

	if {$Priv(count) == 100} {
		::board::registerSize $Options(board:size)
	}

	set number [::gametable::column $info number]
	set name [file rootname [file tail $base]]
	if {[info exists Priv($base:$number:$view)]} {
		wm withdraw $Priv($base:$number:$view)
		wm deiconify $Priv($base:$number:$view)
		return
	}

	set position [incr Priv(count)]
	set dlg $parent.browser$position
	set Priv($base:$number:$view) $dlg
	incr Priv($base:$number:$view:count)
	toplevel $dlg -class Scidb

	set top [::ttk::frame $dlg.top]
	set bot [tk::frame $dlg.bot]
	::ttk::separator $dlg.sep -class Dialog
	grid $dlg.top -column 0 -row 0 -sticky nsew
	grid $dlg.sep -column 0 -row 1 -sticky nsew
	grid $dlg.bot -column 0 -row 2 -sticky nsew

	grid columnconfigure $dlg 0 -weight 1
	grid rowconfigure $dlg 0 -weight 1

	set lt [::ttk::frame $top.lt]
	set rt [::ttk::frame $top.rt]
	grid $lt -column 0 -row 0 -sticky nsew
	grid $rt -column 1 -row 0 -sticky nsew

	grid columnconfigure $top 1 -weight 1

	set background [::theme::getBackgroundColor]

	# board
	set board [::board::stuff::new $lt.board $Options(board:size) 1]
	grid $board -column 0 -row 0 -sticky nsew -padx $::theme::padding -pady $::theme::padding

	# board buttons
	set controls [tk::frame $bot.controls]
	tk::button $controls.rotateBoard \
		-takefocus 0 \
		-background $background \
		-image $::icon::22x22::rotateBoard \
		-command [namespace code [list RotateBoard $board]] \
		;
	::tooltip::tooltip $controls.rotateBoard ::overview::mc::RotateBoard
	grid $controls.rotateBoard -row 0 -column 0
	foreach {control column key tipvar} {	GotoStart 4 <Home> GotoStartOfGame
														FastBackward 5 <Prior> GoBackFast
														Backward 6 <Left> GoBackward
														Forward 7 <Right> GoForward
														FastForward 8 <Next> GoForwardFast
														GotoEnd 9 <End> GotoEndOfGame} {
		set w $controls.[string tolower $control 0 0]
		tk::button $w \
			-image [set ::icon::22x22::control$control] \
			-background $background \
			-takefocus 0 \
			-command [list event generate $w $key] \
			;
		::tooltip::tooltip $w [namespace current]::mc::$tipvar
		grid $w -row 0 -column $column
	}
	foreach control {FastBackward Backward Forward FastForward} {
		set w $controls.[string tolower $control 0 0]
		$w configure -repeatdelay $::theme::repeatDelay -repeatinterval $Options(repeat:interval)
	}
	tk::button $controls.autoplay \
		-takefocus 0 \
		-background $background \
		-image $::icon::22x22::playerStart \
		-command [namespace code [list ToggleAutoPlay $position 1]] \
		;
	::tooltip::tooltip $controls.autoplay [namespace current]::mc::StartAutoplay
	grid $controls.autoplay -row 0 -column 11
	grid columnconfigure $controls {1 10} -minsize 10
	grid columnconfigure $controls {2 13} -minsize 22
	grid columnconfigure $controls {3 12} -weight 1

	# PGN side
	tk::text $rt.header \
		-background $Options(background:header) \
		-height 3 -width 0 \
		-state disabled \
		-takefocus 0 \
		-undo 0 \
		-exportselection 0 \
		-wrap word \
		-font $Options(font) \
		-cursor {} \
		;
	tk::text $rt.pgn \
		-height 0 -width 0 \
		-yscrollcommand [list ::scrolledframe::sbset $rt.sb] \
		-state disabled \
		-takefocus 0 \
		-exportselection 0 \
		-undo 0 \
		-wrap word \
		-font $Options(font) \
		-cursor {} \
		;
	::ttk::scrollbar $rt.sb -command [list $rt.pgn yview] -takefocus 0

	grid $rt.header	-row 1 -column 1 -columnspan 2 -sticky nsew
	grid $rt.pgn		-row 3 -column 1 -sticky nsew -ipady 1
	grid $rt.sb			-row 3 -column 2 -sticky ns
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
#	bind $buttons.loadGame <ButtonRelease-1>   [list focus $buttons.close]
#	bind $buttons.mergeGame <ButtonRelease-1>  [list focus $buttons.close]
	grid columnconfigure $buttons {1 3} -minsize $::theme::padding
	$buttons.close configure -command [list destroy $dlg]
	$buttons.backward configure -command [namespace code [list NextGame $dlg $position -1]]
	$buttons.forward configure -command [namespace code [list NextGame $dlg $position +1]]

	grid $controls	-row 1 -column 1 -sticky ew
	grid $buttons	-row 1 -column 3
	grid columnconfigure $bot {0 2 4} -minsize $::theme::padding
	grid columnconfigure $bot 1 -minsize [expr {8*$Options(board:size) + 2}]
	grid columnconfigure $bot 3 -weight 1
	grid rowconfigure $bot {0 2} -minsize $::theme::padding

	bind $rt.pgn <Double-1>		{ break }
	bind $rt.pgn <B1-Motion>	{ break }
	bind $rt.pgn <B2-Motion>	{ break }

	$rt.header tag configure bold -font $Options(font:bold)
	$rt.header tag configure figurine -font $::font::figurine
	$rt.pgn tag configure figurine -font $::font::figurine
	$rt.pgn tag configure result -foreground $Options(foreground:result)
	$rt.pgn tag configure empty -foreground $Options(foreground:empty)

	bind $dlg <Alt-Key>				[list tk::AltKeyInDialog $dlg %A]
	bind $dlg <Return>				[namespace code [list ::widget::dialogButtonInvoke $buttons]]
	bind $dlg <Return>				{+ break }
	bind $dlg <Configure>			[namespace code [list Configure %W $position]]
	bind $dlg <Control-a>			[namespace code [list ToggleAutoPlay $position]]
	bind $dlg <Control-r>			[namespace code [list RotateBoard $board]]
	bind $dlg <Destroy>				[namespace code [list Destroy $dlg %W $position $base]]
	bind $dlg <Left>					[namespace code [list Goto $position -1]]
	bind $dlg <Right>					[namespace code [list Goto $position +1]]
	bind $dlg <Prior>					[namespace code [list Goto $position -10]]
	bind $dlg <Next>					[namespace code [list Goto $position +10]]
	bind $dlg <Home>					[namespace code [list Goto $position -9999]]
	bind $dlg <End>					[namespace code [list Goto $position +9999]]
	bind $dlg <ButtonPress-3>		[namespace code [list PopupMenu $dlg $board $position]]
	bind $dlg <Key-plus>				[namespace code [list IncreaseBoardSize $position $lt.board +5]]
	bind $dlg <Key-KP_Add>			[namespace code [list IncreaseBoardSize $position $lt.board +5]]
	bind $dlg <Key-minus>			[namespace code [list IncreaseBoardSize $position $lt.board -5]]
	bind $dlg <Key-KP_Subtract>	[namespace code [list IncreaseBoardSize $position $lt.board -5]]

	wm withdraw $dlg
	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	wm resizable $dlg true false
	::util::place $dlg center $parent
	wm deiconify $dlg
	focus $buttons.close

	namespace eval [namespace current]::${position} {}
	variable ${position}::Vars
	set Vars(pgn) $rt.pgn
	set Vars(board) $board
	set Vars(autoplay) 0
	set Vars(autoplay:control) $controls.autoplay
	set Vars(forward:control) $buttons.forward
	set Vars(backward:control) $buttons.backward
	set Vars(afterid) {}
	set Vars(afterid2) {}
	set Vars(header) $rt.header
	set Vars(size) $Options(board:size)
	set Vars(length) -1
	set Vars(base) $base
	set Vars(name) $name
	set Vars(view) $view
	set Vars(index) $index
	set Vars(number) $number
	set Vars(after) {}
	set Vars(current) {}
	set Vars(minsize) 0
	set Vars(dlg) $dlg
	set Vars(closed) 0
	set Vars(fen) $fen

	set Vars(subscribe:board) [list $position [namespace current]::UpdateBoard]
	set Vars(subscribe:pgn)   [list $position [namespace current]::UpdatePGN true]
	set Vars(subscribe:list)  [list [namespace current]::Update [namespace current]::Close $position]
	set Vars(subscribe:close) [list [namespace current]::Close $base $position]

	NextGame $dlg $position	;# too early for ::scidb::game::go

	bind $rt.header <<LanguageChanged>> [namespace code [list LanguageChanged $position $info]]
	bind $rt.header <Configure> [namespace code [list ConfigureHeader $position]]

	::scidb::game::setup $position 240 80 0 0 no no no no

	::scidb::game::subscribe board {*}$Vars(subscribe:board)
	::scidb::game::subscribe pgn {*}$Vars(subscribe:pgn)
	::scidb::db::subscribe gameList {*}$Vars(subscribe:list)
	::scidb::view::subscribe {*}$Vars(subscribe:close)

	if {$view == [::scidb::tree::view $base]} {
		set Vars(subscribe:tree) [list [namespace current]::UpdateTreeBase {} $position]
		::scidb::db::subscribe tree {*}$Vars(subscribe:tree)
	}

	::scidb::game::go $position position $Vars(fen)
	return $position
}


proc load {parent base info view index windowId} {
	if {[llength $windowId] == 0} { set windowId _ }

	if {![namespace exists [namespace current]::${windowId}]} {
		return [open $parent $base $info $view $index]
	}

	variable ${windowId}::Vars
	NextGame $Vars(dlg) $windowId [expr {$index - $Vars(index)}]
	return $windowId
}


proc makeOpeningLines {data} {
	lassign $data idn position eco opening variation subvar
	set opening1 ""
	set opening2 {}
	set opening3 ""

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
		append opening1 $eco
		if {[string length [lindex $opening 0]]} {
			if {[llength $variation]} {
				append opening1 " - " [::mc::translateEco [lindex $opening 1]]
				append opening1 ", "  [::mc::translateEco $variation]
				if {[llength $subvar]} {
					append opening1 ", " [::mc::translateEco $subvar]
				}
			} else {
				append opening1 " - " [::mc::translateEco [lindex $opening 0]]
			}
		}
	} elseif {$idn > 0} {
		append opening1 $::gamebar::mc::StartPosition " "
		if {$idn > 3*960} {
			append opening1 [expr {$idn - 3*960}]
		} else {
			append opening1 $idn
		}
		append opening1 " ("
		lappend opening2 [::font::translate $position] figurine
		append opening3 ")"
		if {$idn > 960} {
			append opening3 " \[$mc::NoCastlingRights\]"
		}
	} elseif {$idn == 0 && [llength $position]} {
		append opening1 "FEN: "
		append opening1 $position
	}

	if {[llength $opening2] == 0} {
		set opening2 {"" {}}
	}

	return [list [list $opening1 eco] $opening2 [list $opening3 eco]]
}


proc ConfigureButtons {position} {
	variable ${position}::Vars

	if {$Vars(index) == -1} {
		$Vars(backward:control) configure -state disabled
		$Vars(forward:control) configure -state disabled
	} else {
		if {$Vars(index) == 0} { set state disabled } else { set state normal }
		$Vars(backward:control) configure -state $state
		set count [scidb::view::count games $Vars(base) $Vars(view)]
		if {$Vars(index) + 1 == $count} { set state disabled } else { set state normal }
		$Vars(forward:control) configure -state $state
	}
}


proc Update {position base {view -1} {index -1}} {
	variable ${position}::Vars

	if {!$Vars(closed) && $Vars(base) eq $base && $Vars(view) == $view} {
		after cancel $Vars(after)
		set Vars(after) [after idle [namespace code [list Update2 $position $base]]]
	}
}


proc Update2 {position base} {
	variable ${position}::Vars

	set Vars(index) [::scidb::db::get gameIndex [expr {$Vars(number) - 1}] $Vars(view) $base]
	set Vars(fen) [::scidb::game::fen]
	ConfigureButtons $position
}


proc Close {position base {view {}}} {
	variable ${position}::Vars

	if {[llength $view] == 0 || $view == $Vars(view)} {
		set Vars(index) -1
		set Vars(closed) 1
		ConfigureButtons $position
		SetTitle $position
	}
}


proc UpdateTreeBase {position base} {
	variable ${position}::Vars

	if {$base ne $Vars(base)} {
		Close $position $base
	}
}


proc GotoFirstGame {parent position} {
	variable ${position}::Vars

	if {$Vars(index) > 0} {
		set Vars(index) 0
		NextGame $parent $position
	}
}


proc GotoLastGame {parent position} {
	variable ${position}::Vars

	set index [expr {[scidb::view::count games $Vars(base) $Vars(view)] - 1}]

	if {$Vars(index) < $index} {
		set Vars(index) $index
		NextGame $parent $position
	}
}


proc NextGame {parent position {step 0}} {
	variable ${position}::Vars
	variable Priv

	if {$Vars(index) == -1} { return }
	set number $Vars(number)
	incr Vars(index) $step
	set info [::scidb::db::get gameInfo $Vars(index) $Vars(view) $Vars(base)]
	set Vars(result) [::util::formatResult [::gametable::column $info result]]
	set Vars(number) [::gametable::column $info number]
	if {$step} {
		set key $Vars(base):$number:$Vars(view)
		if {[incr Priv($key:count) -1] == 0} {
			unset Priv($key)
			unset Priv($key:count)
		}
		set key $Vars(base):$Vars(number):$Vars(view)
		set Priv($key) [winfo toplevel $parent]
		incr Priv($key:count)
	}
	ConfigureButtons $position
	SetTitle $position
	set index [::scidb::db::get gameNumber $Vars(base) $Vars(index) $Vars(view)]
	::widget::busyOperation ::game::load $parent $position $Vars(base) $index
	::scidb::game::go $position position $Vars(fen)
	UpdateHeader $position $info
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


proc LanguageChanged {position info} {
	variable ${position}::Vars

	if {[::scidb::game::query $position length] == 0} {
		set w $Vars(pgn)
		$w configure -state normal
		$w delete 1.0 end
		$w insert end "<$::application::pgn::mc::EmptyGame> " empty
		$w insert end {*}$Vars(result)
		$w configure -state disabled
	}

	UpdateHeader $position $info
	SetTitle $position
}


proc UpdateHeader {position {info {}}} {
	variable ${position}::Vars

	set text $Vars(header)
	$text configure -state normal

	$text delete 1.0 end
	foreach id {white black event site date annotator} {
		set $id [::gametable::column $info $id]
	}

	set data {}
	foreach id {idn position eco opening variation subvar} {
		lappend data [::gametable::column $info $id]
	}

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
	$text insert end $white {bold white}
	$text insert end " \u2013 " bold
	$text insert end $black {bold black}

	$text tag bind event <Any-Enter>			[namespace code [list EnterItem $position event]]
	$text tag bind event <Any-Leave>			[namespace code [list LeaveItem $position event]]
	$text tag bind event <ButtonPress-2>	[namespace code [list ShowEvent $position]]
	$text tag bind event <ButtonRelease-2>	[namespace code [list HideEvent $position]]

	foreach side {white black} {
		$text tag bind $side <Any-Enter>			[namespace code [list EnterItem $position $side]]
		$text tag bind $side <Any-Leave>			[namespace code [list LeaveItem $position $side]]
		$text tag bind $side <ButtonPress-2>	[namespace code [list ShowPlayer $position $side]]
		$text tag bind $side <ButtonRelease-2>	[namespace code [list HidePlayer $position $side]]
	}

	set Vars(opening) [makeOpeningLines $data]

	if {[llength [lindex $Vars(opening) 0 0]]} {
		$text insert end "\n"
		foreach line $Vars(opening) {
			$text insert end {*}$line
		}
	}

	update idletasks ;# makes -displaylines working
	$text configure -height [$text count -displaylines 1.0 end]
	$text configure -state disabled
}


proc ShowEvent {position} {
	variable ${position}::Vars

	set base  $Vars(base)
	set index [expr $Vars(number) - 1]

	set info [scidb::db::fetch eventInfo $index $base -card]
	::eventtable::showInfo $Vars(header) $info
}


proc HideEvent {position} {
	variable ${position}::Vars
	::eventtable::hideInfo $Vars(header)
}


proc EnterItem {position item} {
	variable ${position}::Vars
	variable Options

	$Vars(header) tag configure $item \
		-background $Options(background:hilite) \
		-foreground $Options(foreground:hilite) \
		;
}


proc LeaveItem {position item} {
	variable ${position}::Vars
	variable Options

	$Vars(header) tag configure $item -background $Options(background:header) -foreground black
}


proc ShowPlayer {position side} {
	variable ${position}::Vars

	set base  $Vars(base)
	set index [expr $Vars(number) - 1]

	set info [scidb::db::fetch ${side}PlayerInfo $index $base -card -ratings {Elo Elo}]
	::playertable::showInfo $Vars(header) $info
}


proc HidePlayer {position side} {
	variable ${position}::Vars
	::playertable::hideInfo $Vars(header)
}


proc UpdatePGN {position data} {
	variable ${position}::Vars
	variable Options

	set w $Vars(pgn)

	foreach node $data {
		switch [lindex $node 0] {
			start {
				$w configure -state normal
				$w delete 1.0 end
				set current $Vars(current)
				set Vars(current) {}
				set Vars(active) {}
				set Vars(key) ""
			}

			move {
				set key $Vars(key)
				set Vars(key) [lindex $node 1]

				foreach move [lindex $node 2] {
					switch [lindex $move 0] {
						annotation - marks { ;# skip }

						space { $w insert end " " }
						break { $w insert end "\n" }

						ply {
							lassign [lindex $move 1] moveNo stm san legal
							if {$moveNo > 0} {
								$w insert end "$moveNo." $key
							}
							foreach {text tag} [::font::splitMoves $san] {
								$w insert end $text [list {*}$tag $key]
								$w tag bind $key <Any-Enter> [namespace code [list EnterMove $position $key]]
								$w tag bind $key <Any-Leave> [namespace code [list LeaveMove $position $key]]
								$w tag bind $key <ButtonPress-1> [list ::scidb::game::moveto $position $key]
							}
							if {!$legal} {
								$w insert end "\u26A1" illegal
								$w tag bind illegal <Any-Enter> +[namespace code [list Tooltip $w illegal]]
								$w tag bind illegal <Any-Leave> +[namespace code [list Tooltip $w hide]]
								$w tag bind illegal <ButtonPress-1> [list ::scidb::game::moveto $position $key]
							}
						}
					}
				}
			}

			result {
				set key $Vars(key)
				set Vars(result) [list [::util::formatResult [lindex $node 1]] [list $key result]]
				if {[::scidb::game::query $position length] == 0} {
					$w insert end "<$::application::pgn::mc::EmptyGame>" empty
				}
				$w insert end " "
				$w insert end {*}$Vars(result)
				$w tag bind $key <Any-Enter> [namespace code [list EnterMove $position $key]]
				$w tag bind $key <Any-Leave> [namespace code [list LeaveMove $position $key]]
				$w tag bind $key <ButtonPress-1> [list ::scidb::game::moveto $position $key]
				if {[llength $current]} {
					catch { $w tag configure $current -background $Options(background:pgn) }
				}
				$w configure -state disabled
			}

			action {
				lassign [lindex $node 1] cmd key

				if {$cmd eq "goto" } {
					if {$Vars(current) eq $key} { return }
					if {$Vars(active) eq $key} { $w configure -cursor {} }
					set previous $Vars(current)
					if {[llength $previous]} {
						$w tag configure $previous -background $Options(background:pgn)
					}
					$w tag configure $key -background $Options(background:current)
					if {[llength $previous]} { $w see [lindex [$w tag nextrange $key 1.0] 0] }
					set Vars(current) $key
					if {[llength $previous] && $Vars(active) eq $previous} { EnterMove $position $previous }
				}
			}
		}
	}
}


proc Tooltip {path nag} {
	variable ::annotation::mc::Nag

	switch $nag {
		hide		{ ::tooltip::tooltip hide }
		illegal	{ ::tooltip::show $path $mc::IllegalMove }
	}
}


proc EnterMove {position key} {
	variable ${position}::Vars

	if {$Vars(current) ne $key} {
		$Vars(pgn) tag configure $key -background #ebf4f5
		$Vars(pgn) configure -cursor hand2
	}

	set Vars(active) $key
}


proc LeaveMove {position key} {
	variable ${position}::Vars

	set Vars(active) {}

	if {$Vars(current) ne $key} {
		$Vars(pgn) tag configure $key -background white
		$Vars(pgn) configure -cursor {}
	}
}


proc UpdateBoard {position cmd data} {
	variable ${position}::Vars

	switch $cmd {
		set	{ ::board::stuff::update $Vars(board) $data }
		move	{ ::board::stuff::move $Vars(board) $data }
	}
}


proc ToggleAutoPlay {position {hide 0}} {
	variable ${position}::Vars

	set w $Vars(autoplay:control)

	if {[$w cget -image] eq $::icon::22x22::hiliteStart} {
		$w configure -image $::icon::22x22::hiliteStop
		set Vars(autoplay) 1
		Goto $position +1
		set tooltipVar StopAutoplay
	} else {
		$w configure -image $::icon::22x22::hiliteStart
		set Vars(autoplay) 0
		after cancel $Vars(afterid)
		set Vars(afterid) {}
		set tooltipVar StartAutoplay
	}

	::tooltip::tooltip $w [namespace current]::mc::$tooltipVar
	if {$hide} { ::tooltip::tooltip hide }
}


proc RotateBoard {board} {
	::board::stuff::rotate $board
}


proc Destroy {dlg w position base} {
	if {$w ne $dlg} { return }

	variable ${position}::Vars
	variable Priv

#	::scidb::game::unsubscribe board {*}$Vars(subscribe:board)
#	::scidb::game::unsubscribe pgn {*}$Vars(subscribe:pgn)
	::scidb::db::unsubscribe gameList {*}$Vars(subscribe:list)
	::scidb::view::unsubscribe {*}$Vars(subscribe:close)

	if {[info exists Vars(subscribe:tree)]} {
		::scidb::db::unsubscribe tree {*}$Vars(subscribe:tree)
	}

	::scidb::game::release $position
	set key $Vars(base):$Vars(number):$Vars(view)
	if {[incr Priv($key:count) -1] == 0} {
		unset Priv($key)
		unset Priv($key:count)
	}
	namespace delete [namespace current]::${position}
}


proc ConfigureHeader {position} {
	variable ${position}::Vars

	after cancel $Vars(afterid2)
	set Vars(afterid2) [after 50 [namespace code [list ConfigureHeader2 $position]]]
}


proc ConfigureHeader2 {position} {
	variable ${position}::Vars
	$Vars(header) configure -height [$Vars(header) count -displaylines 1.0 end]
}


proc Configure {w position} {
	if {[winfo toplevel $w] eq $w && [winfo width $w] > 1} {
		after idle [namespace code [list SetMinSize $w $position]]
		bind $w <Configure> {}
	}
}


proc SetMinSize {w position} {
	variable ${position}::Vars

	wm minsize $w [winfo width $w] [winfo height $w]
	set Vars(minsize) [winfo width $w]
}


proc PopupMenu {parent board position} {
	variable ${position}::Vars

	set dlg [winfo toplevel $board]
	set menu $dlg.__menu__
	catch { destroy $menu }
	menu $menu -tearoff 0
	catch { wm attributes $m -type popup_menu }

	if {$Vars(index) == -1} { set state disabled } else { set state normal }

	$menu add command \
		-compound left \
		-image $::icon::16x16::document \
		-label " $mc::LoadGame" \
		-command [namespace code [list LoadGame $dlg $position]] \
		-state $state \
		;
#	$menu add command \
#		-label $mc::MergeGame \
#		-command [namespace code [list MergeGame $dlg $position]] \
#		-state $state \
#		;
	$menu add separator
	$menu add command \
		-label $mc::GotoFirstGame \
		-command [namespace code [list GotoFirstGame $parent $position]] \
		-state $state \
		;
	$menu add command \
		-label $mc::GotoLastGame \
		-command [namespace code [list GotoLastGame $parent $position]] \
		-state $state \
		;
	$menu add separator
	$menu add command \
		-label $mc::IncreaseBoardSize \
		-command [namespace code [list IncreaseBoardSize $position $board +5]] \
		-accelerator "+" \
		;
	$menu add command \
		-label $mc::DecreaseBoardSize \
		-command [namespace code [list IncreaseBoardSize $position $board -5]] \
		-accelerator "\u2212" \
		;

	tk_popup $menu {*}[winfo pointerxy $dlg]
}


proc LoadGame {parent position} {
	variable ${position}::Vars

	set base  $Vars(base)
	set index [::scidb::db::get gameIndex [expr {$Vars(number) - 1}] $Vars(view) $base]

	::widget::busyOperation ::game::new $parent $base $index
}	


proc MergeGame {parent position} {
	variable ${position}::Vars

	set index [::scidb::db::get gameIndex [expr {$Vars(number) - 1}] $Vars(view) $Vars(base)]
puts "MergeGame $index"	;# TODO
}


proc IncreaseBoardSize {position board delta} {
	variable ${position}::Vars
	variable Options

	update idletasks

	set dlg [winfo toplevel $board]
	set maxSize [expr {([winfo screenheight $dlg] - [winfo height $dlg] + 8*$Options(board:size) - 75)/8}]
	set newSize [expr {$Options(board:size) + $delta}]

	if {$delta < 0 && $newSize < 35} { return }
	if {$delta > 0 && $newSize > $maxSize} { return }

	set w [expr {$Vars(minsize) + 8*$delta}]
	set h [expr {[winfo height $dlg] + 8*$delta}]
	wm minsize $dlg $w $h
	set Vars(minsize) $w

	::board::unregisterSize $Options(board:size)
	set Options(board:size) $newSize
	::board::registerSize $newSize
	::board::stuff::resize $board $newSize 1
	grid columnconfigure $dlg.bot 1 -minsize [expr {8*$newSize + 2}]
}


proc WriteOptions {chan} {
	options::writeItem $chan [namespace current]::Options
}


::options::hookWriter [namespace current]::WriteOptions

} ;# namespace browser

# vi:set ts=3 sw=3:
