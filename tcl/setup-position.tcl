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
# Copyright: (C) 2011 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

namespace eval setup {
namespace eval position {
namespace eval mc {

set SetStartPosition		"Set Start Position"
set UsePreviousPosition	"Use previous position"

} ;# namespace mc

variable Previous {}


proc open {parent} {
	variable Vars
	variable Previous

	set dlg $parent.setup_position
	if {[winfo exists $dlg]} { return }

	toplevel $dlg -class Scidb
	wm withdraw $dlg
	set top [ttk::frame $dlg.top]
	pack $dlg.top

	ttk::frame $top.buttons
	ttk::frame $top.board
	ttk::frame $top.control

	set squareSize 40
	set pieceSize [expr {$squareSize - 4}]
	set borderSize 2
	set edge 20
	set rank $top.board.rank

	if {![info exists Vars(position)]} {
		::board::registerBoardSize $squareSize
		::board::registerPieceSize $pieceSize
		::board::setupSquares $squareSize
		::board::setupPieces $pieceSize
	}

	set Vars(position) "--------"
	set Vars(castling) 1
	set Vars(idn) 0
	set Vars(size) $pieceSize
	set Vars(dlg) $dlg
	set Vars(board) $rank
	set Vars(idn:text) ""

	set activebg [::theme::getActiveBackgroundColor]
	set selectbg $::board::square::style(hilite,selected)
	if {[string length $activebg] == 0} {
		tk::button $top.temp
		set activebg [$top.temp cget -activebackground]
		destroy $top.temp
	}

	set col 0
	set offs [expr {$borderSize + ($squareSize - $pieceSize)/2}]
	set y [expr {$offs + $edge}]
	foreach c {A B C D E F G H} {
		set Vars(piece:$c) -
		set row 1
		foreach piece {k q r b n} {
			set btn $top.buttons.$piece$c
			set img photo_Piece(w$piece,$pieceSize)
			tk::radiobutton $btn \
				-image $img \
				-indicatoron no \
				-value $piece \
				-variable [namespace current]::Vars(piece:$c) \
				-activebackground $activebg \
				-selectcolor $selectbg \
				-takefocus 0 \
				-command [namespace code [list UpdatePiece $piece $col]] \
				;
			set Vars(x:$col) [expr {$col*$squareSize + $offs}]
			set Vars(y:$col) $y
			::theme::configureBackground $btn
			grid $btn -row $row -column $col -padx 1 -pady 1
			incr row
		}
		incr col
	}

	set bg(0) photo_Square(lite,$squareSize)
	set bg(1) photo_Square(dark,$squareSize)

	canvas $rank \
		-width [expr {8*$squareSize + 2*$borderSize}] \
		-height [expr {$squareSize + $edge + 2*$borderSize}] \
		-borderwidth 0 \
		;
	::theme::configureCanvas $rank

	set wd [$rank cget -width]
	set ht [expr {$squareSize + 2*$borderSize + $edge}]
	$rank create rectangle 0 $edge $wd $ht \
		-fill #8f8f8f \
		-width 0 \
		;
	$rank create rectangle 0 $edge $wd [expr {$edge + 1}] \
		-fill white \
		-width 0 \
		;
	$rank create rectangle 0 [expr {$edge + 1}] [expr {$wd - 1}] [expr {$edge + 2}] \
		-fill white \
		-width 0 \
		;
	$rank create rectangle 0 $edge 1 [expr {$edge + $squareSize + 4}] \
		-fill white \
		-width 0 \
		;
	$rank create rectangle 1 $edge 2 [expr {$edge + $squareSize + 3}] \
		-fill white \
		-width 0 \
		;

	set which 0
	set x $borderSize
	foreach c {A B C D E F G H} {
		$rank create image $x [expr {$borderSize + $edge}] -image $bg($which) -anchor nw -tag square
		set which [expr {1 - $which}]
		$rank create text [expr {$x + $squareSize/2}] [expr {$edge/2}] \
			-font TkTextFont \
			-text $c \
			-tag coord \
			;
		incr x $squareSize
	}

	::ttk::checkbutton $top.control.castling \
		-textvar [namespace parent]::board::mc::Chess960Castling \
		-variable [namespace current]::Vars(castling) \
		;
	::ttk::entry $top.control.idn \
		-textvariable [namespace current]::Vars(idn:text) \
		-width 5 \
		-state readonly \
		;
	::ttk::button $top.control.standard \
		-style icon.TButton \
		-image $::icon::16x16::home \
		-command [namespace code { Shuffle std }] \
		;
	::ttk::button $top.control.shuffle \
		-style icon.TButton \
		-image $::icon::16x16::dice \
		-command \
			[list [namespace parent]::popupShuffleMenu [namespace current] $top.control.shuffle] \
		;
	if {[llength $Previous]} { set state normal } else { set state disabled }
	::ttk::button $top.control.previous \
		-style icon.TButton \
		-image $::icon::iconRepeat \
		-command [namespace code [list UsePrevious $dlg]] \
		-state $state \
		;
	::ttk::button $top.control.clear \
		-style icon.TButton \
		-image $::icon::16x16::clear \
		-command [namespace code Clear] \
		;

	::tooltip::tooltip $top.control.standard [namespace parent]::board::mc::StandardPosition
	::tooltip::tooltip $top.control.shuffle [namespace parent]::board::mc::Shuffle
	::tooltip::tooltip $top.control.previous [namespace current]::mc::UsePreviousPosition
	::tooltip::tooltip $top.control.clear ::mc::Clear

	grid $rank -column 1 -row 1

	grid $top.control.castling -column  1 -row 1 -sticky w
	grid $top.control.idn      -column  3 -row 1
	grid $top.control.standard -column  5 -row 1
	grid $top.control.shuffle  -column  7 -row 1
	grid $top.control.previous -column  9 -row 1
	grid $top.control.clear    -column 11 -row 1
	grid columnconfigure $top.control {2 4 6 8 10} -minsize $::theme::padding
	grid columnconfigure $top.control {2 4} -weight 1

	grid $top.buttons -row 1 -column 2
	grid $top.board   -row 3 -column 1 -columnspan 3
	grid $top.control -row 5 -column 2 -sticky ew

	grid columnconfigure $top {2 4} -minsize $borderSize
	grid columnconfigure $top {0 5} -minsize [expr {$::theme::padding - $borderSize}]
	grid rowconfigure $top 4 -minsize [expr {2*$::theme::padding}]
	grid rowconfigure $top {0 2 6} -minsize $::theme::padding

	::widget::dialogButtons $dlg {ok cancel} ok
	$dlg.cancel configure -command [list destroy $dlg]
	$dlg.ok configure -command [namespace code [list Accept $dlg]] -state disabled

	wm withdraw $dlg
	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	wm transient $dlg [winfo toplevel $parent]
	wm title $dlg "[tk appname] - $mc::SetStartPosition"
	wm resizable $dlg no no
	::util::place $dlg center $parent
	wm deiconify $dlg
	focus $top.control.castling
}


proc Shuffle {variant} {
	variable Vars

	set Vars(idn) [[namespace parent]::shuffle $variant]

	switch $variant {
		std - frc - sfrc	{ set Vars(castling) 1 }
		shuffle				{ set Vars(castling) 0 }
	}

	set fen [::scidb::board::idnToFen $Vars(idn)]
	set Vars(position) [string range $fen 36 43]

	UpdateBoard
	UpdateButtons
	Update
}


proc UpdateBoard {} {
	variable Vars

	for {set col 0} {$col < 8} {incr col} {
		set piece [string tolower [string index $Vars(position) $col]]
		SetPiece $piece $col
	}
}


proc SetPiece {piece col} {
	variable Vars

	$Vars(board) delete piece:$col

	if {$piece ne "-"} {
		set img photo_Piece(w$piece,$Vars(size))
		$Vars(board) create image $Vars(x:$col) $Vars(y:$col) -image $img -tag piece:$col -anchor nw
	}
}


proc UpdatePiece {piece col} {
	variable Vars

	SetPiece $piece $col

	set Vars(position) [string replace $Vars(position) $col $col [string toupper $piece]]
	set Vars(idn) [::scidb::board::positionNumber $Vars(position)]

	Update
}


proc UpdateButtons {} {
	variable Vars

	set col 0
	foreach c {A B C D E F G H} {
		set piece [string tolower [string index $Vars(position) $col]]
		set Vars(piece:$c) $piece
		incr col
	}
}


proc Update {} {
	variable Vars

	if {$Vars(idn) == 0} {
		set Vars(idn:text) ""
		set state disabled
	} else {
		set Vars(idn:text) $Vars(idn)
		set state normal
	}

	$Vars(dlg).ok configure -state $state
}


proc UsePrevious {dlg} {
	variable Previous
	variable Vars

	lassign $Previous Vars(position) Vars(castling)

	set col 0
	foreach c {A B C D E F G H} {
		set piece [string tolower [string index $Vars(position) $col]]
		SetPiece $piece $col
		incr col
	}

	set Vars(idn) [::scidb::board::positionNumber $Vars(position)]
	UpdateButtons
	Update
}


proc Clear {} {
	variable Vars

	set Vars(position) "--------"
	set Vars(idn) 0

	UpdateBoard
	UpdateButtons
	Update
}


proc Accept {dlg} {
	variable Previous
	variable Vars

	set fen ""
	if {$Vars(castling)} { set castling "KQkq" } else { set castling  "-" }

	append fen [string tolower $Vars(position)]
	append fen "/pppppppp/8/8/8/8/PPPPPPPP/"
	append fen [string toupper $Vars(position)]
	append fen " w "
	append fen $castling
	append fen " - 0 1"

	set Previous [list $Vars(position) $Vars(castling)]

	::scidb::game::clear $fen
	destroy $dlg
}


proc WriteOptions {chan} {
	::options::writeList $chan [namespace current]::Previous
}


::options::hookWriter [namespace current]::WriteOptions

} ;# namespace position
} ;# namespace setup

# vi:set ts=3 sw=3:
