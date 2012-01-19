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
# Copyright: (C) 2010-2012 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

namespace eval setup {
namespace eval mc {

set Chess960Position			"Chess 960 position"
set SymmChess960Position	"Symmetrical chess 960 position"
set ShuffleChessPosition	"Shuffle chess position"

}

variable SFRC { 446 462 518 524 534 540 692 708 }

proc shuffle {variant} {
	variable SFRC

	switch $variant {
		std		{ set idn 518 }
		frc		{ set idn [expr {int(rand()*960.0) + 1}] }
		sfrc		{ set idn [lindex $SFRC [expr {int(rand()*[llength $SFRC])}]] }
		shuffle	{ set idn [expr {int(rand()*2880.0) + 1}] }
	}

	return $idn
}


proc popupShuffleMenu {ns w} {
	set m $w.spopup
	if {[winfo exists $m]} { destroy $m }
	menu $m -tearoff false
	catch { wm attributes $m -type popup_menu }

	$m add command \
		-label $mc::Chess960Position \
		-command [list ${ns}::Shuffle frc] \
		;
	$m add command \
		-label $mc::SymmChess960Position \
		-command [list ${ns}::Shuffle sfrc] \
		;
	$m add command \
		-label $mc::ShuffleChessPosition \
		-command [list ${ns}::Shuffle shuffle] \
		;
	
	tk_popup $m [winfo rootx $w] [expr {[winfo rooty $w] + [winfo height $w]}]
}

namespace eval board {
namespace eval mc {

set SetStartBoard				"Set Start Board"
set SideToMove					"Side to move"
set Castling					"Castling"
set MoveNumber					"Move number"
set EnPassantFile				"En passant"
set StartPosition				"Start position"
set Fen							"FEN"
set Clear						"Clear"
set CopyFen						"Copy FEN to clipboard"
set Shuffle						"Shuffle..."
set StandardPosition			"Standard Position"
set Chess960Castling			"Chess 960 castling"

set InvalidFen					"Invalid FEN"
set CastlingWithoutRook		"You have set castling rights, but at least one rook for castling is missing. This can happen only in handicap games. Are you sure that the castling rights are ok?"
set UnsupportedVariant		"Position is a start position but not a Shuffle Chess position. Are you sure?"

set Error(InvalidFen)					"FEN is invalid."
set Error(NoWhiteKing)					"Missing white king."
set Error(NoBlackKing)					"Missing black king."
set Error(DoubleCheck)					"Both kings are in check."
set Error(OppositeCheck)				"Side not to move is in check."
set Error(TooManyWhitePawns)			"Too many white pawns."
set Error(TooManyBlackPawns)			"Too many black pawns."
set Error(TooManyWhitePieces)			"Too many white pieces."
set Error(TooManyBlackPieces)			"Too many black pieces."
set Error(PawnsOn18)						"Pawn on 1st or 8th rank."
set Error(TooManyKings)					"More than two kings."
set Error(TooManyWhite)					"Too many white pieces."
set Error(TooManyBlack)					"Too many black pieces."
set Error(BadCastlingRights)			"Bad castling rights."
set Error(InvalidCastlingRights)		"Unreasonable rook files for castling."
set Error(InvalidCastlingFile)		"Invalid castling file."
set Error(AmbiguousCastlingFyles)	"Castling needs rook files to be disambiguous (possibly they are set wrong)."
set Error(InvalidEnPassant)			"Unreasonable en passant file."
set Error(MultiPawnCheck)				"Two or more pawns give check."
set Error(TripleCheck)					"Three or more pieces give check."
set Error(InvalidStartPosition)		"Castling rights not allowed in start positions which are not Chess 960 positions."

} ;# namespace mc

array set NextPiece { wk wq wq wr wr wb wb wn wn wp wp wk bk bq bq br br bb bb bn bn bp bp bk }
foreach key [array names NextPiece] { set PrevPiece($NextPiece($key)) $key }
unset key

variable Padding5x5			[image create photo -width 5 -height 5]
variable History				{}
variable BorderThickness	2
variable Vars


proc open {parent} {
	variable BorderThickness
	variable Vars
	variable Memo
	variable History

	set dlg $parent.setup_board
	if {[winfo exists $dlg]} { return }

	SetupCursors
	toplevel $dlg -class Scidb
	wm withdraw $dlg
	set top [ttk::frame $dlg.top]
	pack $dlg.top

	set Vars(pos) [::scidb::pos::board]
	set Vars(positionId) 0
	set Vars(castling) 1
	set Vars(fen) [::scidb::pos::fen]
	AnalyseFen $Vars(fen) init
	array set Memo [array get Vars]
	set Vars(fen:memo) ""
	set Vars(piece) wk
	set Vars(freeze) 0
	set Vars(skip) 0
	set Vars(field) ""
	set Vars(popup) 0

	set right [ttk::frame $top.right]
	set bottom [ttk::frame $top.bottom]
	set edge 20

	# castling rights #########################################
	set castling [ttk::labelframe $right.castling \
		      -labelwidget [ttk::label $right.castlinglbl -textvar [namespace current]::mc::Castling]]

	ttk::checkbutton $castling.wshort \
		-variable [namespace current]::Vars(w:short) \
		-command [namespace code UpdateCastlingRights] \
		;
	ttk::combobox $castling.wshortsq \
		-exportselection 0 \
		-state readonly  \
		-values {- C D E F G H} \
		-textvariable [namespace current]::Vars(w:short:fyle) \
		-width 2 \
		;
	bind $castling.wshortsq <<ComboboxSelected>> [namespace code Update]
	ttk::checkbutton $castling.wlong \
		-variable [namespace current]::Vars(w:long) \
		-command [namespace code UpdateCastlingRights] \
		;
	ttk::combobox $castling.wlongsq \
		-exportselection 0 \
		-state readonly  \
		-values {- A B C D E F} \
		-textvariable [namespace current]::Vars(w:long:fyle) \
		-width 2 \
		;
	bind $castling.wlongsq <<ComboboxSelected>> [namespace code Update]
	ttk::checkbutton $castling.bshort \
		-variable [namespace current]::Vars(b:short) \
		-command [namespace code UpdateCastlingRights] \
		;
	ttk::combobox $castling.bshortsq \
		-exportselection 0 \
		-state readonly  \
		-values {- c d e f g h} \
		-textvariable [namespace current]::Vars(b:short:fyle) \
		-width 2 \
		;
	bind $castling.bshortsq <<ComboboxSelected>> [namespace code Update]
	ttk::checkbutton $castling.blong \
		-variable [namespace current]::Vars(b:long) \
		-command [namespace code UpdateCastlingRights] \
		;
	ttk::combobox $castling.blongsq \
		-exportselection 0 \
		-state readonly  \
		-values {- a b c d e f} \
		-textvariable [namespace current]::Vars(b:long:fyle) \
		-width 2 \
		;
	bind $castling.blongsq <<ComboboxSelected>> [namespace code Update]
	bind $castling.wshort <<LanguageChanged>> [namespace code [list SetupCastlingButtons $castling]]
	SetupCastlingButtons $castling

	grid $castling.wshort	-row 1 -column 1 -sticky ew
	grid $castling.wshortsq	-row 1 -column 3 -sticky ew
	grid $castling.wlong		-row 3 -column 1 -sticky ew
	grid $castling.wlongsq	-row 3 -column 3 -sticky ew
	grid $castling.bshort	-row 5 -column 1 -sticky ew
	grid $castling.bshortsq	-row 5 -column 3 -sticky ew
	grid $castling.blong		-row 7 -column 1 -sticky ew
	grid $castling.blongsq	-row 7 -column 3 -sticky ew
	grid rowconfigure $castling {0 2 4 6 8} -minsize $::theme::padding
	grid columnconfigure $castling {0 2 4} -minsize $::theme::padding
	grid columnconfigure $castling 3 -weight 1

	# side to move ############################################
	set stm [ttk::labelframe $right.stm \
		-labelwidget [ttk::label $right.stmlbl -textvar [namespace current]::mc::SideToMove]]

	ttk::radiobutton $stm.white \
		-value "w" \
		-variable [namespace current]::Vars(stm) \
		-textvar ::mc::White \
		-command [namespace code Update] \
		;
	ttk::radiobutton $stm.black \
		-value "b" \
		-variable [namespace current]::Vars(stm) \
		-textvar ::mc::Black \
		-command [namespace code Update] \
		;

	grid $stm.white -row 1 -column 1 -sticky ew
	grid $stm.black -row 1 -column 3 -sticky ew
	grid rowconfigure $stm {0 2} -minsize $::theme::padding
	grid columnconfigure $stm {0 2 4} -minsize $::theme::padding
	grid columnconfigure $stm {1 3} -weight 1

	# move number + en passant file ###########################
	set moveno [ttk::frame $right.moveno]

	ttk::label $moveno.move_text -textvar [namespace current]::mc::MoveNumber
	::ttk::spinbox $moveno.move_value \
		-from 1 \
		-to 999 \
		-textvariable [namespace current]::Vars(moveno) \
		-command [namespace code [list MoveNumberChanged $moveno.move_value]] \
		-width 3 \
		;
	::validate::spinboxInt $moveno.move_value
	::theme::configureSpinbox $moveno.move_value
	bind $moveno.move_value <FocusOut> +[namespace code Update]

	ttk::label $moveno.ep_text -textvar [namespace current]::mc::EnPassantFile
	ttk::combobox $moveno.ep_value \
		-exportselection 0 \
		-state readonly  \
		-values {- a b c d e f g h} \
		-textvariable [namespace current]::Vars(ep) \
		-width 2 \
		;
	bind $moveno.ep_value <<ComboboxSelected>> [namespace code Update]

	grid $moveno.move_text	-row 0 -column 0 -sticky w
	grid $moveno.move_value	-row 0 -column 2 -sticky ew
	grid $moveno.ep_text		-row 2 -column 0 -sticky w
	grid $moveno.ep_value	-row 2 -column 2 -sticky ew
	grid columnconfigure $moveno 1 -minsize $::theme::padding
	grid columnconfigure $moveno 2 -weight 1
	grid rowconfigure $moveno 1 -minsize $::theme::padding

	# IDN #####################################################
	set idn [ttk::labelframe $right.idn \
		-labelwidget [ttk::label $right.idnlbl -textvar [namespace current]::mc::StartPosition]]
	
	::ttk::spinbox $idn.value \
		-from 1 \
		-to 2880 \
		-width 5 \
		-exportselection 0 \
		-validatecommand [namespace code [list ValidateIdn %P]] \
		-invalidcommand { bell } \
		-textvariable [namespace current]::Vars(idn) \
		;
	::theme::configureSpinbox $idn.value
	bind $idn.value <ButtonRelease-1> [namespace code StopSelectIdn]
	bind $idn.value <FocusOut> +[namespace code { CheckIdn }]
	bind $idn.value <FocusIn>  {+ %W configure -validate key }
	bind $idn.value <FocusIn>  +[list set [namespace current]::Vars(field) idn]

	::ttk::button $idn.standard \
		-style icon.TButton \
		-image $::icon::16x16::home \
		-command [namespace code { Shuffle std }] \
		;
	::ttk::button $idn.shuffle \
		-style icon.TButton \
		-image $::icon::16x16::dice \
		-command [list [namespace parent]::popupShuffleMenu [namespace current] $idn.shuffle] \
		;
	::tooltip::tooltip $idn.standard [namespace current]::mc::StandardPosition
	::tooltip::tooltip $idn.shuffle [namespace current]::mc::Shuffle

	::ttk::checkbutton $idn.castling \
		-textvar [namespace current]::mc::Chess960Castling \
		-command [namespace code SetCastlingRights] \
		-variable [namespace current]::Vars(castling) \
		;
	set Vars(castling:widget) $idn.castling

	grid $idn.value		-row 1 -column 1 -sticky ew
	grid $idn.standard	-row 1 -column 3 -sticky ew
	grid $idn.shuffle		-row 1 -column 5 -sticky ew
	grid $idn.castling	-row 3 -column 1 -sticky ew -columnspan 5
	grid columnconfigure $idn {0 2 4 6} -minsize $::theme::padding
	grid columnconfigure $idn 1 -weight 1
	grid rowconfigure $idn {0 2 4} -minsize $::theme::padding

	# buttons #################################################
	if {![info exists [namespace current]::_MirrorSide]} {
		proc SetupVars {args} {
			set [namespace current]::_MirrorSide "$::mc::King \u2194 $::mc::Queen"
			set [namespace current]::_FlipSide "$::mc::White \u2194 $::mc::Black"
		}

		trace add variable ::mc::White write [namespace code SetupVars]
		trace add variable ::mc::Black write [namespace code SetupVars]
		trace add variable ::mc::King write [namespace code SetupVars]
		trace add variable ::mc::Queen write [namespace code SetupVars]

		SetupVars
	}

	ttk::button $right.empty \
		-style aligned.TButton \
		-compound left \
		-image [set [namespace current]::Padding5x5] \
		-textvar [namespace current]::mc::Clear \
		-command [namespace code [list SetupBoard empty]]
		;
	ttk::button $right.mirror \
		-style aligned.TButton \
		-compound left \
		-image [set [namespace current]::Padding5x5] \
		-textvar [namespace current]::_MirrorSide \
		-command [namespace code [list SetupBoard mirror]]
		;
	ttk::button $right.flip \
		-style aligned.TButton \
		-compound left \
		-image [set [namespace current]::Padding5x5] \
		-textvar [namespace current]::_FlipSide \
		-command [namespace code [list SetupBoard flip]]
		;

	# FEN #####################################################
	set fen [ttk::labelframe $bottom.fen \
		-labelwidget [ttk::label $bottom.fenlbl -textvar [namespace current]::mc::Fen]]
	
	ttk::combobox $fen.text \
		-exportselection 0 \
		-textvariable [namespace current]::Vars(fen) \
		-width 0 \
		-values $History \
		;
	bind $fen.text <FocusOut> [namespace code ResetFen]
	bind $fen.text <FocusIn> [list set [namespace current]::Vars(field) fen]
	bind $fen.text <<ComboboxSelected>> [namespace code ResetFen]
	::ttk::button $fen.clear \
		-style icon.TButton \
		-image $::icon::16x16::clear \
		-command [namespace code [list ClearFen $fen.text]] \
		;
	::ttk::button $fen.copy \
		-style icon.TButton \
		-image $::icon::16x16::clipboardIn \
		-command [namespace code CopyFen] \
		;
	::tooltip::tooltip $fen.clear [namespace current]::mc::Clear
	::tooltip::tooltip $fen.copy [namespace current]::mc::CopyFen
	set Vars(combo) $fen.text
	
	grid $fen.text		-row 1 -column 1 -sticky ew
	grid $fen.clear	-row 1 -column 3 -sticky ew
	grid $fen.copy		-row 1 -column 5 -sticky ew
	grid columnconfigure $fen {0 2 4 6} -minsize $::theme::padding
	grid columnconfigure $fen 1 -weight 1
	grid rowconfigure $fen {0 2} -minsize $::theme::padding

	# layout controls #########################################
	grid $right.castling -column 0 -row  0 -sticky ew
	grid $right.stm		-column 0 -row  2 -sticky ew
	grid $right.moveno	-column 0 -row  4 -sticky ew
	grid $right.idn		-column 0 -row  6 -sticky ew
	grid $right.empty		-column 0 -row  8 -sticky ew
	grid $right.mirror	-column 0 -row 10 -sticky ew
	grid $right.flip		-column 0 -row 12 -sticky ew
	grid rowconfigure $right {1 3 7 9 11} -minsize $::theme::padding -weight 1
	grid rowconfigure $right 5 -minsize [expr {2*$::theme::padding}] -weight 1
	grid rowconfigure $right 13 -minsize [expr {$edge + $BorderThickness}]

	grid $bottom.fen -row 0 -column 1 -sticky ew
	grid rowconfigure $bottom 1 -minsize $::theme::padding
	grid columnconfigure $bottom 1 -weight 1

	# board ###################################################
	update idletasks
	set squareSize [expr {[winfo reqheight $right]/8}]
	::board::registerSize $squareSize
	if {[info exists Vars(BoardSize)]} { ::board::unregisterSize $Vars(BoardSize) }
	set Vars(BoardSize) $squareSize
	set size [expr {$squareSize*8 + 2*$BorderThickness + $edge}]
	set canv [tk::canvas $top.board -width $size -height $size -takefocus 0]
	::theme::configureCanvas $canv
	set board [::board::stuff::new $canv.board $squareSize $BorderThickness]
	::board::stuff::update $board $Vars(pos)
	$board configure -cursor crosshair
	set Vars(board) $board
	$canv create window $edge 0 -window $board -anchor nw -tag board
	::board::stuff::bind $board all <ButtonPress-1> [namespace code [list SetPiece %q]]
	::board::stuff::bind $board all <ButtonPress-3> [namespace code ChangeColor]
	::board::stuff::bind $board all <ButtonPress-2> [namespace code [list NextPiece %s]]
	set Vars(board) $board

	set x [expr {$edge/2}]
	set y [expr {$BorderThickness + $squareSize/2}]
	foreach c {8 7 6 5 4 3 2 1} {
		$canv create text $x $y -font TkTextFont -text $c
		incr y $squareSize
	}

	set y [expr {8*$squareSize + 2*$BorderThickness + $edge/2}]
	set x [expr {$BorderThickness + $edge + $squareSize/2}]
	foreach c {A B C D E F G H} {
		$canv create text $x $y -font TkTextFont -text $c
		incr x $squareSize
	}

	# panel ###################################################
	set panel [ttk::frame $top.panel]
	set selectbg $::board::square::style(hilite,selected)
	set activebg [::theme::getActiveBackgroundColor]
	if {[string length $activebg] == 0} {
		tk::button $top.temp
		set activebg [$top.temp cget -activebackground]
		destroy $top.temp
	}
	set row 1
	foreach piece {k q r b n p} {
		set col 1
		foreach side {w b} {
			set fig $side$piece
			tk::radiobutton $panel.$fig \
				-image photo_Piece($fig,$squareSize) \
				-indicatoron no \
				-value $fig \
				-variable [namespace current]::Vars(piece) \
				-activebackground $activebg \
				-selectcolor $selectbg \
				-takefocus 0 \
				-command [namespace code [list SetCursor $side$piece]] \
				;
			::theme::configureBackground $panel.$fig
			grid $panel.$fig -row $row -column $col
			incr col 2
		}
		incr row 2
	}
	grid columnconfigure $panel 2 -minsize 5
	grid rowconfigure $panel 0 -minsize $BorderThickness
	grid rowconfigure $panel {2 4 6 8 10} -weight 1
	grid rowconfigure $panel 12 -minsize [expr {$edge + $BorderThickness}]

	bind $Vars(board) <Map> [namespace code [list SetupCursor $dlg $Vars(piece)]]

	###########################################################

	grid $panel		-row 1 -column 1 -sticky ns
	grid $canv		-row 1 -column 3
	grid $right		-row 1 -column 5 -sticky ns
	grid $bottom	-row 3 -column 1 -sticky ew -columnspan 5
	grid columnconfigure $top {0 4 6} -minsize $::theme::padding
	grid columnconfigure $top {2 4} -minsize 10
	grid rowconfigure $top 0 -minsize $::theme::padding

	::widget::dialogButtons $dlg {ok cancel reset} ok
	$dlg.cancel configure -command [list destroy $dlg]
	$dlg.reset configure -command [namespace code Reset]
	$dlg.ok configure -command [namespace code Accept]

	Update

	wm withdraw $dlg
	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	wm transient $dlg [winfo toplevel $parent]
	catch { wm attributes $dlg -type dialog }
	wm title $dlg "[tk appname] - $mc::SetStartBoard"
	wm resizable $dlg false false
	::util::place $dlg center $parent
	wm deiconify $dlg
	focus $castling.wshort
}


proc SetupCursor {w piece} {
	bind $w <Map> {}
	after idle [namespace code [list SetCursor $piece]]
}


proc SetCursor {piece} {
	variable Vars
	variable Cursor

	if {[string match *32x32* $Cursor($piece)]} {
		::xcursor::setCursor $Vars(board) $Cursor($piece)
	} else {
		$Vars(board) configure -cursor $Cursor($piece)
	}
}


proc SetupCastlingButtons {f} {
	$f.wshort configure -text "$::mc::White 0-0"
	$f.bshort configure -text "$::mc::Black 0-0"
	$f.wlong  configure -text "$::mc::White 0-0-0"
	$f.blong  configure -text "$::mc::Black 0-0-0"
}


proc UpdateCastlingRights {} {
	variable Vars

	Update
	UpdateChess960CastlingFlag $Vars(positionId)
}


proc UpdateChess960CastlingFlag {positionId} {
	variable Vars

	if {$positionId == 0} { return }

	set count 0
	foreach type {w:short w:long b:short b:long} {
		if {$Vars($type)} { incr count }
	}
	set Vars(freeze) 1
	if {$count == 0 && $positionId > 2880} {
		set Vars(castling) 0
	} elseif {$count == 4 && $positionId <= 960} {
		set Vars(castling) 1
	}
	set Vars(freeze) 0
}


proc AnalyseFen {fen {cmd none}} {
	variable Vars

	if {$cmd eq "init"} {
		lassign [::scidb::board::analyseFen $fen] error idn notStd not960 castling ep stm moveno
		AnalyseCastlingRights $fen $castling $idn

		switch -- $error {
			CastlingWithoutRook - UnsupportedVariant {
				set error ""
			}
		}
	} else {
		set castling ""
		if {$Vars(w:short)} { append castling "K" }
		if {$Vars(w:long) } { append castling "Q" }
		if {$Vars(b:short)} { append castling "k" }
		if {$Vars(b:long) } { append castling "q" }

		set castlingFiles ""
		foreach right {w:short w:long b:short b:long} { append castlingFiles $Vars($right:fyle) }

		lassign [::scidb::board::analyseFen $fen $castling $castlingFiles] \
			error idn notStd not960 unused ep stm moveno
	}

	if {$cmd eq "check" && [string length $error]} {
		switch $error {
			CastlingWithoutRook - UnsupportedVariant {
				set answer [::dialog::question \
									-parent [winfo toplevel $Vars(board)]  \
									-title "$::scidb::app: $mc::InvalidFen" \
									-message [set mc::$error] \
									;]
				return [expr {$answer eq "yes"}]
			}

			default {
				::dialog::error \
					-parent [winfo toplevel $Vars(board)]  \
					-title "$::scidb::app: $mc::InvalidFen" \
					-message $mc::Error($error) \
					;
				return 0
			}
		}
	}

	set Vars(freeze) 1
	set Vars(positionId) $idn
	if {$idn == 0} {
		set idn ""
	} elseif {$idn <= 960} {
		set Vars(castling) 1
	} elseif {$idn > 2880} {
		set idn [expr {$idn - 2880}]
		set Vars(castling) 0
	}
	set Vars(idn) $idn
	set Vars(freeze) 0

	if {[string length $error] && $cmd ne "init"} { return 0 }

	set Vars(freeze) 1
	set Vars(fen) $fen
	set Vars(stm) $stm
	set Vars(ep) [string index $ep 0]
	set Vars(moveno) $moveno
	set Vars(freeze) 0

	if {[string length $error]} { return 0 }
	return 1
}


proc NextPiece {state} {
	variable NextPiece
	variable PrevPiece
	variable Vars

	if {$state == 1} {
		set Vars(piece) $PrevPiece($Vars(piece))
	} else {
		set Vars(piece) $NextPiece($Vars(piece))
	}
	SetCursor $Vars(piece)
}


proc ChangeColor {} {
	variable Vars

	lassign [split $Vars(piece) {}] side piece
	if {$side eq "w"} { set side b } else { set side w }
	set Vars(piece) ${side}${piece}
	SetCursor $Vars(piece)
}


proc SetPiece {square} {
	variable Vars

	if {$Vars(piece) eq [::board::stuff::piece $Vars(board) $square]} {
		set piece "."
	} else {
		set piece $::board::stuff::pieceToLetter($Vars(piece))
	}

	switch $Vars(piece) {
		wk - bk {
			set i [string first [expr {$Vars(piece) eq "wk" ? "K" : "k"}] $Vars(pos)]

			if {$i >= 0} {
				::board::stuff::setPiece $Vars(board) $i "."
			}
		}

		wp - bp {
			set rank [string index [lindex $::board::stuff::squareIndex $square] 1]
			if {$rank == 1 || $rank == 8} {
				bell -displayof . -nice
				return
			}
		}
	}

	set Vars(pos) [::board::stuff::setPiece $Vars(board) $square $piece]
	Update
}


proc SetupBoard {cmd} {
	variable Vars

	switch $cmd {
		empty {
			set Vars(pos) [::board::stuff::update $Vars(board) $cmd]
			foreach type {w:short w:long b:short b:long} {
				set Vars($type) 0
				set Vars($type:fyle) "-"
			}
			set Vars(ep) "-"
		}

		flip {
			set Vars(pos) [::board::stuff::update $Vars(board) $cmd]
		}

		mirror {
			set Vars(fen) [::scidb::board::transposeFen $Vars(fen)]
			set Vars(pos) [::scidb::board::fenToBoard $Vars(fen)]
			::board::stuff::update $Vars(board) $Vars(pos)
			AnalyseFen $Vars(fen) init
		}
	}
	
	Update
}

proc Shuffle {variant} {
	variable Vars

	set castling $Vars(castling)

	if {$variant eq "update"} {
		set idn $Vars(idn)
	} else {
		set idn [[namespace parent]::shuffle $variant]

		switch $variant {
			std - frc - sfrc	{ set castling 1 }
			shuffle				{ set castling 0 }
		}
	}

	if {$idn == 0} {
		set idn 960
	} elseif {$idn eq "" || $idn > 2880} {
		set idn 0
	}

	if {$idn eq 0} {
		set Vars(freeze) 1
		set Vars(idn) ""
		set Vars(positionId) 0
		set Vars(freeze) 0
	} else {
		set Vars(freeze) 1
		set Vars(castling) $castling
		set Vars(positionId) [expr {!$Vars(castling) && $idn <= 960 ? $idn + 2880 : $idn}]
		set Vars(idn) $idn
		set Vars(ep) "-"
		set Vars(moveno) 1
		set Vars(stm) "w"
		set Vars(freeze) 0

		SetCastlingRights
		::board::stuff::update $Vars(board) $Vars(pos)
	}

	Update
}


proc AnalyseCastlingRights {fen castling positionId} {
	variable Vars

	set Vars(freeze) 1
	foreach type {w:short w:long b:short b:long} {
		set Vars($type:fyle) "-"
	}
	lassign $castling vars(w:short) vars(w:long) vars(b:short) vars(b:long)
	foreach type {w:short w:long b:short b:long} {
		set Vars($type) [expr {$vars($type) ne "--"}]
		set vars($type) [string index $vars($type) 0]
	}
	foreach fyle [split [lindex $fen 2] {}] {
		switch -- $fyle {
			A - B - C - D - E - F - G - H {
				if {[string tolower $fyle] eq $vars(w:short)} {
					set Vars(w:short:fyle) $fyle
				} else {
					set Vars(w:long:fyle) $fyle
				}
			}
			a - b - c - d - e - f - g - h {
				if {$fyle eq $vars(b:short)} {
					set Vars(b:short:fyle) $fyle
				} else {
					set Vars(b:long:fyle) $fyle
				}
			}
		}
	}
	set Vars(freeze) 0
	UpdateChess960CastlingFlag $positionId
}


proc SetCastlingRights {} {
	variable Vars

	if {$Vars(freeze)} { return }
	set idn $Vars(positionId)
	if {$idn == 0} { return }

	if {$idn > 2880 && $Vars(castling) == 1} {
		set idn [expr {$idn - 2880}]
	} elseif {$idn <= 960 && $Vars(castling) == 0} {
		set idn [expr {$idn + 2880}]
	}

	lassign [::scidb::board::idnToFen $idn] Vars(fen) castlingRights
	set Vars(pos) [::scidb::board::fenToBoard $Vars(fen)]
	AnalyseFen $Vars(fen) init
}


proc MoveNumberChanged {w} {
	variable Vars

	set Vars(moveno) [$w get]
	Update
}


proc StopSelectIdn {} {
	after idle [namespace code [list Shuffle update]]
}


proc CheckIdn {} {
	variable Vars

	if {$Vars(idn) eq "" || $Vars(idn) > 2880} {
		set Vars(fen:memo) ""
		Update
	} else {
		if {$Vars(idn) == 0} {
			set Vars(freeze) 1
			set Vars(idn) 960
			set Vars(positionId) 960
			set Vars(freeze) 0
		}
		Shuffle update
	}

	set Vars(field) ""
}


proc ValidateIdn {value} {
	variable	Vars

	set value [string trim $value]
	if {[string length $value] > 4} { return 0 }
	if {![string is digit $value]} { return 0 }
	return 1
}


proc Update {} {
	variable Vars

	set Vars(skip) 0

	set castling ""
	foreach {right piece} {w:short K w:long Q b:short k b:long q} {
		if {$Vars($right)} {
			if {$Vars($right:fyle) ne "-"} {
				append castling $Vars($right:fyle)
			} else {
				append castling $piece
			}
		}
	}

	set Vars(fen) [::scidb::board::makeFen $Vars(pos) $Vars(stm) $Vars(ep) $Vars(moveno)]

	if {[string length $castling]} {
		lset Vars(fen) 2 $castling
	}

	if {$Vars(fen:memo) ne $Vars(fen)} {
		set Vars(fen:memo) $Vars(fen)
		$Vars(combo) set $Vars(fen)
		AnalyseFen $Vars(fen)
	}

	if {[llength $Vars(idn)] && $Vars(idn) <= 960} {
		$Vars(castling:widget) configure -state normal
	} else {
		$Vars(castling:widget) configure -state disabled
	}
}


proc ClearFen {cb} {
	variable Vars

	set Vars(fen) ""
	focus $cb
}


proc ResetFen {} {
	variable Vars

	set Vars(fen) [string trim $Vars(fen)]

	if {[string length $Vars(fen)]} {
		if {[AnalyseFen $Vars(fen) init]} {
			set Vars(pos) [::scidb::board::fenToBoard $Vars(fen)]
			::board::stuff::update $Vars(board) $Vars(pos)
			set Vars(field) ""
			Update
		}
	}
}


proc Reset {} {
	variable Vars
	variable Memo

	array set Vars [array get Memo]
	::board::stuff::update $Vars(board) $Vars(pos)
	Update
}


proc Accept {} {
	variable Vars
	variable History

	update idletasks
	set Vars(fen) [string trim $Vars(fen)]

	switch $Vars(field) {
		fen		{ ;# no action }
		idn		{ Shuffle update }
		default	{ Update }
	}

	if {[AnalyseFen $Vars(fen) check]} {
		set Vars(fen) [::scidb::board::normalizeFen $Vars(fen)]
		::scidb::game::clear $Vars(fen)
		destroy [winfo toplevel $Vars(combo)]
		set i [lsearch $History $Vars(fen)]
		if {$i != 0} {
			if {$i == -1 && [llength $History] == 10} { set i 9 }
			if {$i != -1} { set History [lreplace $History $i $i] }
			set History [linsert $History 0 $Vars(fen)]
		}
	}
}


proc CopyFen {} {
	variable Vars

	set fen $Vars(fen)

	# create a text widget to hold the fen so it can be the owner of the current text selection
	set w .__setup__CopyFen__
	if {![winfo exists $w]} { text $w }
	$w delete 1.0 end
	$w insert end $fen sel

	clipboard clear
	clipboard append $fen
	selection own $w
	selection get
}


proc SetupCursors {} {
	variable Cursor

	if {[info exists Cursor(bk)]} { return }

	switch [tk windowingsystem] {
		x11 {
			if {[::xcursor::supported?]} {
				foreach fig {k q r b n p} {
					set wfile [file join $::scidb::dir::share cursor igor-w${fig}-32x32.xcur]
					set bfile [file join $::scidb::dir::share cursor igor-b${fig}-32x32.xcur]

					if {[file readable $wfile] && [file readable $bfile]} {
						catch {
							set Cursor(w$fig) [::xcursor::loadCursor $wfile]
							set Cursor(b$fig) [::xcursor::loadCursor $bfile]
						}
					} else {
						set msg [format $::application::pgn::mc::CannotOpenCursorFiles "$wfile $bfile"]
						::log::info Setup $msg
					}
				}
			} else {
				foreach fig {k q r b n p} {
					set wfile [file join $::scidb::dir::share cursor igor-w${fig}-32x32.xbm]
					set bfile [file join $::scidb::dir::share cursor igor-b${fig}-32x32.xbm]
					set mfile [file join $::scidb::dir::share cursor igor-w${fig}-32x32_mask.xbm]

					if {[file readable $wfile] && [file readable $bfile] && [file readable $mfile]} {
						set Cursor(w$fig) [list @$wfile $mfile black white]
						set Cursor(b$fig) [list @$bfile $mfile white black]
					} else {
						set msg [format $::application::pgn::mc::CannotOpenCursorFiles "$wfile $bfile $mfile"]
						::log::info Setup $msg
					}
				}
			}
		}

		win32 - aqua {
			if {[tk windowingsystem] eq "win32"} { set ext cur } else { set ext crsr }
			set wfile [file join $::scidb::dir::share cursor igor-w${fig}-32x32.$ext]
			set bfile [file join $::scidb::dir::share cursor igor-b${fig}-32x32.$ext]

			if {[file readable $wfile] && [file readable $bfile]} {
				set Cursor(w$fig) [list @$wfile]
				set Cursor(b$fig) [list @$bfile]
			} else {
				::log::info Setup [format $::application::pgn::mc::CannotOpenCursorFiles "$wfile $bfile"]
			}
		}
	}

	foreach fig {k q r b n p} {
		if {![info exists Cursor(b$fig)]} {
			foreach fig {k q r b n p} {
				set Cursor(w$fig) crosshair
				set Cursor(b$fig) crosshair
			}
			return
		}
	}
}


proc WriteOptions {chan} {
	options::writeList $chan [namespace current]::History
}

::options::hookWriter [namespace current]::WriteOptions

} ;# namespace board
} ;# namespace setup

# vi:set ts=3 sw=3:
