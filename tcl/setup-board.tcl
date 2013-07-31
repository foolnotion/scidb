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
# Copyright: (C) 2010-2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source setup-board-dialog

namespace eval setup {
namespace eval mc {

set Position(Chess960)	"Chess 960 position"
set Position(Symm960)	"Symmetrical chess 960 position"
set Position(Shuffle)	"Shuffle chess position"

}

set PositionAlt(wild/5)	"Upside down"

variable SFRC { 446 462 518 524 534 540 692 708 }

proc shuffle {variant} {
	variable SFRC

	switch $variant {
		Normal	{ set idn 518 }
		Chess960	{ set idn [expr {int(rand()*960.0) + 1}] }
		Symm960	{ set idn [lindex $SFRC [expr {int(rand()*[llength $SFRC]) + 1}]] }
		Shuffle	{ set idn [expr {int(rand()*2880.0) + 1}] }
	}

	return $idn
}


proc popupShuffleMenu {ns w} {
	set m $w.ficspopup
	if {[winfo exists $m]} { destroy $m }
	menu $m -tearoff false
	catch { wm attributes $m -type popup_menu }
	setupShuffleMenu $ns $m
	tk_popdown $m $w
}


proc setupShuffleMenu {ns m} {
	foreach variant {Chess960 Symm960 Shuffle} {
		$m add command -label $mc::Position($variant) -command [list ${ns}::Shuffle $variant]
	}
}


proc setupPositionMenu {ns m} {
	variable PositionAlt

	foreach {idn name} { 4015 "wild/5"
								4000 "wild/7"
								4001 "wild/8"
								4002 "wild/19"
								4004 "pawns/pawns-only"
								4000 "pawns/little-game"
								4010 "pawns/wild-five"
								4003 "misc/pyramid"
								4013 "misc/runaway"
								4009 "misc/no-queens"
								4014 "misc/queen-rooks"
								4005 "misc/knights-only"
								4006 "misc/bishops-only"
								4007 "misc/rooks-only"
								4008 "misc/queens-only"
								4011 "endings/kbnk"
								4012 "endings/kbbk"} {
		if {[info exists PositionAlt($name)]} {
			append name " ($PositionAlt($name))"
		}
		$m add command -label "FICS - $name" -command [list ${ns}::Shuffle $idn]
	}
}


proc popupPositionMenu {ns w} {
	set m $w.shufflepopup
	if {[winfo exists $m]} { destroy $m }
	menu $m -tearoff false
	catch { wm attributes $m -type popup_menu }
	setupPositionMenu $ns $m
	tk_popdown $m $w
}

namespace eval board {
namespace eval mc {

set SetStartBoard							"Set Start Board"
set SideToMove								"Side to move"
set Castling								"Castling"
set MoveNumber								"Move number"
set HalfMoves								"Half moves"
set EnPassantFile							"En passant"
set StartPosition							"Start position"
set Fen										"FEN"
set Promoted								"Promoted"
set Holding									"Holding"
set ChecksGiven							"Checks Given"
set Clear									"Clear"
set CopyFen									"Copy FEN to clipboard"
set Shuffle									"Shuffle..."
set FICSPosition							"FICS Start Position..."
set StandardPosition						"Standard Position"
set Chess960Castling						"Chess 960 castling"

set InvalidFen								"Invalid FEN"

set ChangeToFormat(xfen)				"Change to X-Fen format"
set ChangeToFormat(shredder)			"Change to Shredder format"

set Error(InvalidFen)					"FEN is invalid."
set Error(EmptyBoard)					"Board is empty."
set Error(NoWhiteKing)					"Missing white king."
set Error(NoBlackKing)					"Missing black king."
set Error(BothInCheck)					"Both kings are in check."
set Error(OppositeCheck)				"Side not to move is in check."
set Error(OppositeLosing)				"Side not to move has no pieces."
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
set Error(TooManyPiecesInHolding)	"Too many pieces in holding."
set Error(TooManyPromotedPieces)		"Too many pieces marked as promoted."
set Error(TooFewPromotedPieces)		"Too few pieces marked as promoted."
set Error(InvalidEnPassant)			"Unreasonable en passant file."
set Error(MultiPawnCheck)				"Two or more pawns give check."
set Error(TripleCheck)					"Three or more pieces give check."
set Error(InvalidStartPosition)		"Castling rights not allowed in start positions which are not Chess 960 positions."

set Warning(TooFewPiecesInHolding)	"Too few pieces in holding. Are you sure that this is ok?"
set Warning(CastlingWithoutRook)		"You have set castling rights, but at least one rook for castling is missing. This can happen only in handicap games. Are you sure that the castling rights are ok?"
set Warning(UnsupportedVariant)		"Position is a start position but not a Shuffle Chess position. Are you sure?"

} ;# namespace mc

set FenPattern {^[a-zA-Z0-9~]+/[a-zA-Z0-9~]+/[a-zA-Z0-9~]+/[a-zA-Z0-9~]+/[a-zA-Z0-9~]+/[a-zA-Z0-9~]+/[a-zA-Z0-9~]+/[a-zA-Z0-9~]+/([a-zA-Z]+)}

array set NextPiece {wk wq wq wr wr wb wb wn wn wp wp w. w. wk bk bq bq br br bb bb bn bn bp bp b. b. bk}
foreach key [array names NextPiece] { set PrevPiece($NextPiece($key)) $key }
unset key

variable Padding5x5			[image create photo -width 5 -height 5]
variable BorderThickness	2
variable Vars

array set History {
	Normal		{}
	ThreeCheck	{}
	Crazyhouse	{}
	Antichess	{}
}

array set Options {
	fen:format xfen
}


proc open {parent} {
	variable BorderThickness
	variable Vars
	variable Memo
	variable History
	variable Options
	variable Marker

	set dlg $parent.setup_board
	if {[winfo exists $dlg]} { return }

	SetupCursors
	tk::toplevel $dlg -class Scidb
	wm withdraw $dlg
	set top [ttk::frame $dlg.top]
	pack $dlg.top

	unset -nocomplain Vars
	unset -nocomplain Marker

	set variant [::scidb::game::query Variant?]
	if {$variant eq "Antichess"} {
		set normal disabled
		set readonly disabled
	} else {
		set normal normal
		set readonly readonly
	}

	set Vars(pos) [::scidb::pos::board]
	set Vars(positionId) 0
	set Vars(castling) 1
	set Vars(fen) [::scidb::board::normalizeFen [::scidb::pos::fen] $Options(fen:format)]
	AnalyseFen $Vars(fen) init
	array set Memo [array get Vars]
	set Vars(fen:memo) ""
	set Vars(piece) wk
	set Vars(piece:memo) wk
	set Vars(freeze) 0
	set Vars(skip) 0
	set Vars(field) ""
	set Vars(popup) 0
	set Vars(variant) $variant

	set right [ttk::frame $top.right]
	set bottom [ttk::frame $top.bottom]
	set edge 20

#	set selectbg $::board::square::style(hilite,selected)
	set selectbg [::theme::getSelectBackgroundColor]
	set activebg [::theme::getActiveBackgroundColor]

	# castling rights #########################################
	set castling [ttk::labelframe $right.castling -labelwidget [ \
		ttk::label $right.castlinglbl -textvar [namespace current]::mc::Castling -state $normal]]

	ttk::checkbutton $castling.wshort \
		-variable [namespace current]::Vars(w:short) \
		-command [namespace code UpdateCastlingRights] \
		-state $normal \
		;
	ttk::combobox $castling.wshortsq \
		-exportselection 0 \
		-state $readonly  \
		-values {- C D E F G H} \
		-textvariable [namespace current]::Vars(w:short:fyle) \
		-width 2 \
		;
	bind $castling.wshortsq <<ComboboxSelected>> [namespace code [list UpdateCastlingFlag w:short]]
	ttk::checkbutton $castling.wlong \
		-variable [namespace current]::Vars(w:long) \
		-command [namespace code UpdateCastlingRights] \
		-state $normal \
		;
	ttk::combobox $castling.wlongsq \
		-exportselection 0 \
		-state $readonly  \
		-values {- A B C D E F} \
		-textvariable [namespace current]::Vars(w:long:fyle) \
		-width 2 \
		;
	bind $castling.wlongsq <<ComboboxSelected>> [namespace code [list UpdateCastlingFlag w:long]]
	ttk::checkbutton $castling.bshort \
		-variable [namespace current]::Vars(b:short) \
		-command [namespace code UpdateCastlingRights] \
		-state $normal \
		;
	ttk::combobox $castling.bshortsq \
		-exportselection 0 \
		-state $readonly  \
		-values {- c d e f g h} \
		-textvariable [namespace current]::Vars(b:short:fyle) \
		-width 2 \
		;
	bind $castling.bshortsq <<ComboboxSelected>> [namespace code [list UpdateCastlingFlag b:short]]
	ttk::checkbutton $castling.blong \
		-variable [namespace current]::Vars(b:long) \
		-command [namespace code UpdateCastlingRights] \
		-state $normal \
		;
	ttk::combobox $castling.blongsq \
		-exportselection 0 \
		-state $readonly  \
		-values {- a b c d e f} \
		-textvariable [namespace current]::Vars(b:long:fyle) \
		-width 2 \
		;
	bind $castling.blongsq <<ComboboxSelected>> [namespace code [list UpdateCastlingFlag b:long]]
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

	# move number + en passant file + half moves ##############
	set moveno [ttk::frame $right.moveno]

	ttk::label $moveno.move_text -textvar [namespace current]::mc::MoveNumber
	::ttk::spinbox $moveno.move_value \
		-from 1 \
		-to 9999 \
		-textvariable [namespace current]::Vars(moveno) \
		-command [namespace code Update] \
		-width 4 \
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
		-width 4 \
		;
	bind $moveno.ep_value <<ComboboxSelected>> [namespace code Update]

	ttk::label $moveno.halfmoves_text -textvar [namespace current]::mc::HalfMoves
	::ttk::spinbox $moveno.halfmoves_value \
		-from 0 \
		-to 9999 \
		-textvariable [namespace current]::Vars(halfmoves) \
		-command [namespace code Update] \
		-width 4 \
		;
	::validate::spinboxInt $moveno.halfmoves_value
	::theme::configureSpinbox $moveno.halfmoves_value
	bind $moveno.halfmoves_value <FocusOut> +[namespace code Update]

	grid $moveno.move_text			-row 0 -column 0 -sticky w
	grid $moveno.move_value			-row 0 -column 2 -sticky ew
	grid $moveno.ep_text				-row 2 -column 0 -sticky w
	grid $moveno.ep_value			-row 2 -column 2 -sticky ew
	grid $moveno.halfmoves_text	-row 4 -column 0 -sticky w
	grid $moveno.halfmoves_value	-row 4 -column 2 -sticky ew
	grid columnconfigure $moveno 1 -minsize $::theme::padding
	grid columnconfigure $moveno 2 -weight 1
	grid rowconfigure $moveno {1 3} -minsize $::theme::padding

	# IDN #####################################################
	set idn [ttk::labelframe $right.idn \
		-labelwidget [ttk::label $right.idnlbl -textvar [namespace current]::mc::StartPosition]]
	
	set memo $Vars(idn)
	::ttk::spinbox $idn.value \
		-from 1 \
		-to 2880 \
		-width 5 \
		-exportselection 0 \
		-validatecommand [namespace code [list ValidateIdn %P]] \
		-invalidcommand { bell } \
		-textvariable [namespace current]::Vars(idn) \
		;
	set Vars(idn) $memo
	::theme::configureSpinbox $idn.value
	bind $idn.value <ButtonRelease-1> [namespace code StopSelectIdn]
	bind $idn.value <FocusOut> +[namespace code { CheckIdn }]
	bind $idn.value <FocusIn>  {+ %W configure -validate key }
	bind $idn.value <FocusIn>  +[list set [namespace current]::Vars(field) idn]

	::ttk::button $idn.standard \
		-style icon.TButton \
		-image $::icon::16x16::home \
		-command [namespace code { Shuffle Normal }] \
		;
	::ttk::button $idn.shuffle \
		-style icon.TButton \
		-image $::icon::16x16::dice \
		-command [list [namespace parent]::popupShuffleMenu [namespace current] $idn.shuffle] \
		;
	::tooltip::tooltip $idn.standard [namespace current]::mc::StandardPosition
	::tooltip::tooltip $idn.shuffle [namespace current]::mc::Shuffle
	if {$variant eq "Normal"} {
		::ttk::button $idn.nonstandard \
			-style icon.TButton \
			-image $icon::16x16::fics \
			-command [list [namespace parent]::popupPositionMenu [namespace current] $idn.nonstandard] \
			;
		::tooltip::tooltip $idn.nonstandard [namespace current]::mc::FICSPosition
	}

	::ttk::checkbutton $idn.castling \
		-textvar [namespace current]::mc::Chess960Castling \
		-command [namespace code SetCastlingRights] \
		-variable [namespace current]::Vars(castling) \
		-state $normal \
		;
	set Vars(castling:widget) $idn.castling

	grid $idn.value		-row 1 -column 1 -sticky ew
	grid $idn.standard	-row 1 -column 3 -sticky ew
	grid $idn.shuffle		-row 1 -column 5 -sticky ew
	grid $idn.castling	-row 3 -column 1 -sticky ew -columnspan 5
	grid columnconfigure $idn {0 2 4 6} -minsize $::theme::padding
	if {$variant eq "Normal"} {
		grid $idn.nonstandard -row 1 -column 7 -sticky ew
		grid columnconfigure $idn {8} -minsize $::theme::padding
	}
	grid columnconfigure $idn 1 -weight 1
	grid rowconfigure $idn {0 2 4} -minsize $::theme::padding

	# buttons #################################################
	if {![info exists [namespace current]::_MirrorSide]} {
		proc SetupVars {args} {
			set [namespace current]::_MirrorSide "$::mc::Piece(K) \u2194 $::mc::Piece(Q)"
			set [namespace current]::_FlipSide "$::mc::White \u2194 $::mc::Black"
		}

		set cmd [namespace code SetupVars]
		foreach piece {White Black King Queen} {
			trace add variable ::mc::$piece write $cmd
		}

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

	# Holding #################################################
	if {$variant eq "Crazyhouse"} {
		set promo $bottom.promo
		tk::radiobutton $promo \
			-textvar [namespace current]::mc::Promoted \
			-image $icon::16x16::marker \
			-compound bottom \
			-indicatoron no \
			-value "." \
			-variable [namespace current]::Vars(piece) \
			-activebackground $activebg \
			-takefocus 0 \
			-command [namespace code [list SetCursor .]] \
			;
		::theme::configureBackground $promo

		set hold [ttk::labelframe $bottom.hold \
			-labelwidget [ttk::label $bottom.holdlbl -textvar [namespace current]::mc::Holding]]

		set figfont $::font::figurine(text:normal)
		set figfont [list [font configure $figfont -family] -20]

		set col 1
		foreach {piece fig} {q "\u265b" r "\u265c" b "\u265d" n "\u265e" p "\u265f"
									Q "\u2655" R "\u2656" B "\u2657" N "\u2658" P "\u2659"} {
			set lbl $hold._$piece
			set spb ${lbl}_s
			ttk::label $lbl \
				-text $fig \
				-font $figfont \
				;
			tk::spinbox $spb \
				-textvariable [namespace current]::Vars(holding:$piece) \
				-command [namespace code Update] \
				-width 2 \
				-from 0 \
				-to 8 \
				;
			::validate::spinboxInt $spb
			::theme::configureSpinbox $spb
			bind $spb <FocusOut> +[namespace code Update]
			grid $lbl -column $col -row 1
			grid $spb -column [expr {$col + 2}] -row 1
			incr col 4
		}

		grid columnconfigure $hold {0 40} -minsize $::theme::padding
		grid columnconfigure $hold {2 6 10 14 18 22 26 30 34 38} -minsize 3
		grid columnconfigure $hold {4 8 12 16 20 24 28 32 36} -weight 1
		grid columnconfigure $hold {20} -weight 3
		grid rowconfigure $hold {0 2} -minsize $::theme::padding
	}

	# FEN #####################################################
	set fen [ttk::labelframe $bottom.fen \
		-labelwidget [ttk::label $bottom.fenlbl -textvar [namespace current]::mc::Fen]]
	
	ttk::combobox $fen.text \
		-exportselection 0 \
		-textvariable [namespace current]::Vars(fen) \
		-width 0 \
		-values $History([Variant?]) \
		;
	bind $fen.text <FocusOut> [namespace code ResetFen]
	bind $fen.text <FocusIn> [list set [namespace current]::Vars(field) fen]
	bind $fen.text <<ComboboxSelected>> [namespace code ResetFen]
	::ttk::button $fen.format \
		-style icon.TButton \
		-command [namespace code [list SwitchFormat $fen.format]] \
		;
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
	SetupFormat $fen.format
	
	grid $fen.text		-row 1 -column 1 -sticky ew
	grid $fen.format	-row 1 -column 3 -sticky ew
	grid $fen.clear	-row 1 -column 5 -sticky ew
	grid $fen.copy		-row 1 -column 7 -sticky ew
	grid columnconfigure $fen {0 2 4 6 8} -minsize $::theme::padding
	grid columnconfigure $fen 1 -weight 1
	grid rowconfigure $fen {0 2} -minsize $::theme::padding

	# checks given ############################################
	if {$variant eq "ThreeCheck"} {
		set checks [ttk::labelframe $bottom.checks \
			-labelwidget [ttk::label $bottom.checkslbl -textvar [namespace current]::mc::ChecksGiven]]

		::ttk::label $checks.lblw -textvar ::mc::White
		::ttk::label $checks.lblb -textvar ::mc::Black

		foreach side {w b} {
			set Vars(checks:$side) 0
			::ttk::spinbox $checks.val$side \
				-from 0 \
				-to 3 \
				-textvariable [namespace current]::Vars(checks:$side) \
				-command [namespace code Update] \
				-width 1 \
				;
			::validate::spinboxInt $checks.val$side
			::theme::configureSpinbox $checks.val$side
			bind $checks.val$side <FocusOut> +[namespace code Update]
		}

		grid $checks.lblw -row 1 -column 1 -sticky ew
		grid $checks.valw -row 1 -column 3 -sticky ew
		grid $checks.lblb -row 1 -column 5 -sticky ew
		grid $checks.valb -row 1 -column 7 -sticky ew
		grid columnconfigure $checks {0 2 6 8} -minsize $::theme::padding
		grid columnconfigure $checks {4} -minsize $::theme::padX
		grid columnconfigure $checks {4} -weight 1
		grid rowconfigure $checks {0 2} -minsize $::theme::padding

		set Vars(widget:checks:w) $checks.valw
		set Vars(widget:checks:b) $checks.valb
	} else {
		set Vars(checks:w) 0
		set Vars(checks:b) 0
	}

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

	switch $variant {
		Crazyhouse {
			grid $bottom.promo -row 1 -column 1 -sticky ewns
			grid $bottom.hold  -row 1 -column 3 -sticky ewns
			grid $bottom.fen   -row 3 -column 1 -sticky ew -columnspan 3
			grid columnconfigure $bottom 3 -weight 1
			grid rowconfigure $bottom 2 -minsize 2
			grid columnconfigure $bottom 2 -minsize 15
		}
		ThreeCheck {
			grid $bottom.fen    -row 0 -column 1 -sticky ewns
			grid $bottom.checks -row 0 -column 3 -sticky ewns
			grid columnconfigure $bottom 2 -minsize $::theme::padding
			grid columnconfigure $bottom 1 -weight 1
		}
		default {
			grid $bottom.fen -row 0 -column 1 -sticky ew
			grid columnconfigure $bottom 1 -weight 1
		}
	}

	grid rowconfigure $bottom 1 -minsize $::theme::padding

	# board ###################################################
	update idletasks
	set squareSize [expr {[winfo reqheight $right]/8}]
	if {![info exists Vars(SquareSize)] || $Vars(SquareSize) != $squareSize} {
		if {[info exists Vars(SquareSize)]} { ::board::unregisterSize $Vars(SquareSize) }
		::board::registerSize $squareSize
		set Vars(SquareSize) $squareSize
	}
	set size [expr {$squareSize*8 + 2*$BorderThickness + $edge}]
	set canv [tk::canvas $top.board -width $size -height $size -takefocus 0]
	::theme::configureCanvas $canv
	set board [::board::diagram::new $canv.board $squareSize -bordersize $BorderThickness]
	::board::diagram::update $board $Vars(pos)
	$board configure -cursor crosshair
	set Vars(board) $board
	$canv create window $edge 0 -window $board -anchor nw -tag board
	::board::diagram::bind $board all <ButtonPress-1> [namespace code [list SetPiece %q]]
	::board::diagram::bind $board all <ButtonPress-3> [namespace code ChangeColor]
	::board::diagram::bind $board all <ButtonPress-2> [namespace code [list NextPiece %s]]
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

	bind $Vars(board) <Map> [namespace code [list SetupCursor %W $Vars(piece)]]

	###########################################################

	switch $variant {
		Crazyhouse { bind $panel <Configure> +[namespace code [list FitBottom $bottom $panel 1]] }
		ThreeCheck { bind $right <Configure> +[namespace code [list FitBottom $bottom $right 3]] }
	}

	grid $panel		-row 1 -column 1 -sticky ns
	grid $canv		-row 1 -column 3
	grid $right		-row 1 -column 5 -sticky ns
	grid $bottom	-row 3 -column 1 -sticky ew -columnspan 5

	grid columnconfigure $top {0 4 6} -minsize $::theme::padding
	grid columnconfigure $top {2 4} -minsize 10
	grid rowconfigure $top 0 -minsize $::theme::padding

	::widget::dialogButtons $dlg {ok cancel revert help}
	$dlg.cancel configure -command [list destroy $dlg]
	$dlg.revert configure -command [namespace code Reset]
	$dlg.ok configure -command [namespace code Accept]
	$dlg.help configure -command [list ::help::open .application Board-Setup-Dialog -parent $dlg]

	bind $dlg <F1> [$dlg.help cget -command]

	SetupPromoted
	Update
	if {$normal eq "normal"} { set focus $castling.wshort } else { set focus $stm.white }

	wm withdraw $dlg
	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	wm transient $dlg [winfo toplevel $parent]
	catch { wm attributes $dlg -type dialog }
	wm title $dlg "[tk appname] - $mc::SetStartBoard"
	wm resizable $dlg false false
	::util::place $dlg -parent $parent -position center
	wm deiconify $dlg
	focus $focus
	::ttk::grabWindow $dlg
	tkwait window $dlg
	::ttk::releaseGrab $dlg
}


proc FitBottom {dst src cols} {
	grid columnconfigure $dst $cols -minsize [winfo width $src]
}


proc Variant? {} {
	set variant [::scidb::game::query Variant?]

	switch $variant {
		Crazyhouse - Antichess - ThreeCheck { return $variant }
	}

	return "Normal"
}


proc SetupCursor {w piece} {
	bind $w <Map> {}
	after idle [namespace code [list SetCursor $piece]]
}


proc SetCursor {piece} {
	variable Vars
	variable Cursor

	if {[string match *32x32 $Cursor($piece)] || [string match *16x16 $Cursor($piece)]} {
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


proc SetupPromoted {} {
	variable Vars
	variable Marker

	lassign [::scidb::board::analyseFen $Vars(fen)] error _ idn _ _ _ _ _ _ _ _ promoted
	if {$idn > 4*960} { set idn 0 }

	::board::diagram::removeAllMarkers $Vars(board)

	for {set i 0} {$i < 64} {incr i} { set Marker($i) 0 }

	foreach i $promoted {
		set Marker($i) 1
		::board::diagram::drawMarker $Vars(board) $i $icon::16x16::marker
	}
}


proc UpdateCastlingFlag {right} {
	variable Vars

	if {$Vars($right:fyle) ne "-"} { set Vars($right) 1 }
	Update
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
	variable FenPattern
	variable Vars

	if {$cmd eq "init"} {
		lassign [::scidb::board::analyseFen $fen] \
			error _ idn _ _ castling ep stm moveno halfmoves checksGiven promoted

		if {$idn > 4*960} { set idn 0 }
		AnalyseCastlingRights $fen $castling $idn

		switch -- $error {
			CastlingWithoutRook -
			TooManyPiecesInHolding -
			TooFewPiecesInHolding -
			TooManyPromotedPieces -
			TooFewPromotedPieces -
			UnsupportedVariant {
				set error ""
			}
		}

		set holding ""
		regexp $FenPattern $fen _ holding

		foreach piece {Q R B N P q r b n p} { set Vars(holding:$piece) 0 }

		for {set i 0} {$i < [string length $holding]} {incr i} {
			set piece [string index $holding $i]
			incr Vars(holding:$piece)
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
			error warnings idn _ _ _ ep stm moveno halfmoves checksGiven promoted
		if {$idn > 4*960} { set idn 0 }
	}

	if {$cmd eq "check"} {
		if {[string length $error]} {
			::dialog::error \
				-parent [winfo toplevel $Vars(board)]  \
				-title "$::scidb::app: $mc::InvalidFen" \
				-message $mc::Error($error) \
				;
			return 0
		}
		foreach warning $warnings {
			set answer [::dialog::question \
				-parent [winfo toplevel $Vars(board)]  \
				-title "$::scidb::app: $mc::InvalidFen" \
				-message [set mc::Warning($warning)] \
			]
			if {$answer eq "no"} { return 0 }
		}
	}

	set Vars(freeze) 1
	set Vars(positionId) $idn
	if {$idn == 0} {
		set idn ""
	} elseif {$idn <= 960} {
		if {[Variant?] ne "Antichess"} {
			set Vars(castling) 1
		}
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
	set Vars(halfmoves) $halfmoves

	if {[llength $idn] == 0} {
		lassign $checksGiven Vars(checks:w) Vars(checks:b)
	}

	set Vars(freeze) 0

	if {[string length $error]} { return 0 }
	return 1
}


proc NextPiece {state} {
	variable NextPiece
	variable PrevPiece
	variable Vars

	if {$Vars(piece) eq "."} {
		set Vars(piece) $Vars(piece:memo)
	}

	if {[::util::shiftIsHeldDown? $state]} {
		set Vars(piece) $PrevPiece($Vars(piece))
		set Vars(piece:memo) $Vars(piece)
		if {[string match *. $Vars(piece)]} {
			if {$Vars(variant) in {Crazyhouse Bughouse}} {
				set Vars(piece) .
			} else {
				set Vars(piece) $PrevPiece($Vars(piece))
			}
		}
	} else {
		set Vars(piece) $NextPiece($Vars(piece))
		set Vars(piece:memo) $Vars(piece)
		if {[string match *. $Vars(piece)]} {
			if {$Vars(variant) in {Crazyhouse Bughouse}} {
				set Vars(piece) .
			} else {
				set Vars(piece) $NextPiece($Vars(piece))
			}
		}
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
	variable Marker

	if {$Vars(piece) eq "."} {
		set Marker($square) [expr {!$Marker($square)}]
		if {$Marker($square)} {
			::board::diagram::drawMarker $Vars(board) $square $icon::16x16::marker
		} else {
			::board::diagram::removeMarker $Vars(board) $square
		}
	} else {
		if {$Vars(piece) eq [::board::diagram::piece $Vars(board) $square]} {
			set piece "."
		} else {
			set piece $::board::diagram::pieceToLetter($Vars(piece))
		}

		switch $Vars(piece) {
			wk - bk {
				if {[Variant?] ne "Antichess"} {
					set i [string first [expr {$Vars(piece) eq "wk" ? "K" : "k"}] $Vars(pos)]
					if {$i >= 0} {
						::board::diagram::setPiece $Vars(board) $i "."
					}
				}
			}

			wp - bp {
				set rank [string index [lindex $::board::diagram::squareIndex $square] 1]
				if {$rank == 1 || $rank == 8} {
					bell -displayof . -nice
					return
				}
			}
		}

		set Vars(pos) [::board::diagram::setPiece $Vars(board) $square $piece]
		::board::diagram::raiseMarker $Vars(board)
	}

	Update
}


proc SetupBoard {cmd} {
	variable Vars
	variable Options

	switch $cmd {
		empty {
			set Vars(pos) [::board::diagram::update $Vars(board) $cmd]
			foreach type {w:short w:long b:short b:long} {
				set Vars($type) 0
				set Vars($type:fyle) "-"
			}
			set Vars(ep) "-"
		}

		flip {
			set Vars(pos) [::board::diagram::update $Vars(board) $cmd]
		}

		mirror {
			set Vars(fen) [::scidb::board::transposeFen $Vars(fen) $Options(fen:format)]
			set Vars(fen) [scidb::board::normalizeFen $Vars(fen) $Options(fen:format)]
			set Vars(pos) [::scidb::board::fenToBoard $Vars(fen)]
			::board::diagram::update $Vars(board) $Vars(pos)
		}
	}

	Update
}


proc Shuffle {variant} {
	variable Vars
	variable Options

	set castling $Vars(castling)

	if {[string is integer $variant]} {
		lassign [::scidb::board::idnToFen $variant $Options(fen:format)] Vars(fen) castlingRights
		set Vars(pos) [::scidb::board::fenToBoard $Vars(fen)]
		::board::diagram::update $Vars(board) $Vars(pos)
		AnalyseFen $Vars(fen) init
		set idn ""
	} elseif {$variant eq "update"} {
		set idn $Vars(idn)
	} else {
		set idn [[namespace parent]::shuffle $variant]

		if {[Variant?] eq "Antichess"} {
			set castling 0
		} else {
			switch $variant {
				Normal - Chess960 - Symm960	{ set castling 1 }
				Shuffle								{ set castling 0 }
			}
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
		set Vars(halfmoves) 0
		set Vars(stm) "w"
		set Vars(freeze) 0

		SetCastlingRights
		SetupPromoted
		::board::diagram::update $Vars(board) $Vars(pos)
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
	set fen [::scidb::board::normalizeFen $fen xfen]
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
	variable Options

	if {$Vars(freeze)} { return }
	set idn $Vars(positionId)
	if {$idn == 0} { return }

	if {$idn > 2880 && $Vars(castling) == 1} {
		set idn [expr {$idn - 2880}]
	} elseif {$idn <= 960 && $Vars(castling) == 0} {
		set idn [expr {$idn + 2880}]
	}

	lassign [::scidb::board::idnToFen $idn $Options(fen:format)] Vars(fen) castlingRights
	set Vars(pos) [::scidb::board::fenToBoard $Vars(fen)]
	AnalyseFen $Vars(fen) init
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
	variable Options
	variable Marker

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

	if {[llength $Vars(idn)] == 0} {
		set checksW $Vars(checks:w)
		set checksB $Vars(checks:b)
	} else {
		set checksW 0
		set checksB 0
	}

	set holding ""
	foreach piece {Q R B N P q r b n p} {
		append holding [string repeat $piece $Vars(holding:$piece)]
	}

	set promoted {}
	for {set i 0} {$i < 64} {incr i} {
		if {$Marker($i)} { lappend promoted $i }
	}

	set Vars(fen) [::scidb::board::makeFen $Vars(pos) $Vars(stm) $Vars(ep) $Vars(moveno) \
		$Vars(halfmoves) $checksW $checksB $holding $promoted $Options(fen:format)]

	if {[string length $castling]} {
		lset Vars(fen) 2 $castling
	}

	if {$Vars(fen:memo) ne $Vars(fen)} {
		set Vars(fen:memo) $Vars(fen)
		$Vars(combo) set $Vars(fen)
		AnalyseFen $Vars(fen)
	}

	if {[llength $Vars(idn)] == 0} {
		set Vars(fen) [::scidb::board::makeFen \
			$Vars(pos) $Vars(stm) $Vars(ep) $Vars(moveno) $Vars(halfmoves) \
			$Vars(checks:w) $Vars(checks:b) $holding $promoted $Options(fen:format)] \
			;
		if {[string length $castling]} {
			lset Vars(fen) 2 $castling
		}
	}

	if {[Variant?] ne "Antichess"} {
		if {[llength $Vars(idn)] && $Vars(idn) <= 960} {
			$Vars(castling:widget) configure -state normal
		} else {
			$Vars(castling:widget) configure -state disabled
		}
	}
}


proc ClearFen {cb} {
	variable Vars

	set Vars(fen) ""
	focus $cb
}


proc SetupFormat {w} {
	variable Options

	if {$Options(fen:format) eq "xfen"} { set other shredder } else { set other xfen }
	$w configure -image [set icon::16x16::$Options(fen:format)]
	::tooltip::tooltip $w [namespace current]::mc::ChangeToFormat($other)
}


proc SwitchFormat {w} {
	variable Options
	variable History
	variable Vars

	if {$Options(fen:format) eq "xfen"} {
		set Options(fen:format) shredder
	} else {
		set Options(fen:format) xfen
	}

	SetupFormat $w
	set variant [Variant?]

	set values {}
	foreach fen $History($variant) {
		lappend values [::scidb::board::normalizeFen $fen $Options(fen:format)]
	}
	set History($variant) $values
	set Vars(fen) [::scidb::board::normalizeFen $Vars(fen) $Options(fen:format)]

	set cb $Vars(combo)
	set current [$cb current]
	bind $cb <<ComboboxSelected>> {#}
	$cb configure -values $History($variant)
	if {$current >= 0} { $cb current $current }
	bind $cb <<ComboboxSelected>> [namespace code ResetFen]
}


proc ResetFen {} {
	variable Vars
	variable Options

	set Vars(fen) [string trim $Vars(fen)]

	if {[Variant?] eq "Antichess"} {
		lset Vars(fen) 2 "-"
	}

	if {[string length $Vars(fen)]} {
		lassign [::scidb::board::analyseFen $Vars(fen)] \
			error _ _ _ _ castling ep stm moveno halfmoves _ promoted

		if {$error eq "TooManyPiecesInHolding"} {
			set Vars(fen) [::scidb::board::normalizeFen $Vars(fen) $Options(fen:format) -clearholding]
		}

		if {[AnalyseFen $Vars(fen) init]} {
			set Vars(pos) [::scidb::board::fenToBoard $Vars(fen)]
			::board::diagram::update $Vars(board) $Vars(pos)
			set Vars(field) ""
			SetupPromoted
			Update
		}
	}
}


proc Reset {} {
	variable Vars
	variable Memo

	array set Vars [array get Memo]
	::board::diagram::update $Vars(board) $Vars(pos)
	Update
}


proc Accept {} {
	variable Vars
	variable History
	variable Options

	update idletasks
	set Vars(fen) [string trim $Vars(fen)]

	switch $Vars(field) {
		fen		{ ;# no action }
		idn		{ Shuffle update }
		default	{ Update }
	}

	if {[AnalyseFen $Vars(fen) check]} {
		set Vars(fen) [::scidb::board::normalizeFen $Vars(fen) $Options(fen:format)]
		::scidb::game::clear $Vars(fen)
		destroy [winfo toplevel $Vars(combo)]
		set variant [Variant?]
		set i [lsearch -exact $History($variant) $Vars(fen)]
		if {$i != 0} {
			if {$i == -1 && [llength $History($variant)] == 10} { set i 9 }
			if {$i != -1} { set History($variant) [lreplace $History($variant) $i $i] }
			set History($variant) [linsert $History($variant) 0 $Vars(fen)]
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

	::clipboard::selectText $fen
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
				set file [file join $::scidb::dir::share cursor circle-orange-16x16.xcur]
				if {[file readable $file]} {
					catch { set Cursor(.) [::xcursor::loadCursor $file] }
				} else {
					set msg [format $::application::pgn::mc::CannotOpenCursorFiles $file]
					::log::info Setup $msg
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
				set Cursor(.) circle
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

			set file [file join $::scidb::dir::share cursor circle-orange-32x32.$ext]
			if {[file readable $file]} {
				set Cursor(.) [list @$file]
			} else {
				::log::info Setup [format $::application::pgn::mc::CannotOpenCursorFiles $file]
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
	options::writeItem $chan [namespace current]::History no
	options::writeItem $chan [namespace current]::Options
}

::options::hookWriter [namespace current]::WriteOptions


namespace eval icon {
namespace eval 16x16 {

set marker [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAABrVBMVEWCfXmCfXmCfXmCfXmC
	fXmCfXmCfXmalJCalZGalpKblpKblpOCfXnBvLfCvLfCv7jCv7nDv7rDv7vFwb3Fwb7Fwr7F
	wr/Gwr/k4uHoYgjoYgnpYgfpZgzpZw3qZAbqaA7qaQ/qbx3rdCHsaArsbhLseSztZgXtZwXt
	bxPtdyPuchbucxbvdBfvgjTvk1TwdhjwhDfwkVHwlFfxagTxeBrxeRvxehvxkk7yexzzfB30
	fB70fx/0lEv0lU70s4b1cQf1gSH1gyL1m1X2bwP2hST2k0b2lUv3hST3hyX3lkj4o1v49/f5
	cwL5jCn5pV35uIT5+fn6jSr6l0X6zKr607X62sP7jyz7kCz7mET7mEX7mUf8ki78mkX9ji79
	lC/9mUL9mkP9rWP9zqb+lzH+mDH+nEH+nUP+3Lz+9vD++PX/m0D/nDH/nD//nT7/njH/nz3/
	nz//n0X/oC//oDv/oUH/ozn/ozv/pD3/piz/pyz/uG7/umv/unb/u3P/1J7/1J//1pf/2Zb/
	2rf/4L3/4MH/4r//4sH/9+//+fL/+fP/+vL/+vP/+/j//Pr//flu8RMVAAAAGHRSTlMAIEaM
	jaPH6+vr6+vw+fn5+fn5/f39/f3XsTcUAAAA70lEQVQY013Pu07DMBQA0HuvHdt1QqJKUGCp
	ECtjB0AVYuhvsfJbgBh4DPmISpUQIi2pnLit4wc75w8OAgAQkQAXYwQABEBSms2gTuYQEyAg
	L+5vgk06e381PiGw8mG7iy5YL64et4GRWoz3bjCbtvveTJeBUz5vnO1aM7jQXxeOExuC7Zuf
	3qNMDREb3Z4c1stVC0pqEaYrDpCar7WVulQSRQBytfjtOq6ranw8Oa8djz7bmSTzvCo1n4TI
	o/ks9iTF6KiU8sNEiv7p7oJxoZVQ5fMQEZCrxVljTy/l20vvEwIgZXk2gzp0LibA//0/DtN0
	smnEFL8AAAAASUVORK5CYII=
}]

set xfen [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAAAnNCSVQICFXsRgQAAAEsSURB
	VCjPY+hfdegNCO5/sVr9PwMUsm+7ARGdtI5BRab725L/IDj39H9GiILpCyAi3d+05YBcp4yJ
	/6eAYV8hSHqS09RfIN6E/04p/xnAOkL3tPwHwbZ386Xvc7TegfCCt4DkwAr4hBLflf4HwYpt
	5dMhrLgXDLxwBf8Z9IIT/6eC4L+0XyA67q+WE0QG5m4G8+Wh/xHQeAJMHK6Agcfyiet/CDS/
	wsCCoeA/o9Ues/8QaHqKgRFDgUGK2n8IFP/P9J8hF02Bppz4e7H/Iv95/0PN/sqgiqKAZScz
	SN9/htkMe6FCRxmY4AoYsqCCjxn4GJQZvkF5pVAFDKpAAyFCHmChUijvB4MWkMfAzHACKjAf
	aiszw1moyGkGFgaGGijnKYMA3OUGDL+hzFoADl4EDlJ56u4AAAAASUVORK5CYII=
}]

set shredder [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAA/0lEQVQYGQXBv4vOcQDA8bfF
	cFJXdos6N9n8Bc9mtNmY3a4YbFcmk4lJskmhZHwmJiULxWJwyq8nHnfd3ffzfXm9qmq3L2k0
	N5qaOm7V63aqqpZJtjzy1bFflm5qbtX9qt0kF/wBAEn77dQqyUtw2ykXfUKS3pYka3Bact6h
	JE0lyRrclSRJmmpO8gLwypYkSWpOsu03YPLQWUkaNZJk2xsA352TNNeUJMklS8BTSaOOkiRJ
	boB/ko7qb5K1y5JsgB+SPtSzJMOB6zZtugMeSKN7tehnTgIA3jsjfWxRda29E/MVj3126MA7
	t2xI37paVbXoSXuNRhrNTe33vEXVf56uMWyFqlWhAAAAAElFTkSuQmCC
}]

set fics [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAC50lEQVQYGR3B22tTZwAA8O96
	vpOTmJwkrU1rbdPaDuO1XlBwIOkQRJE5hohuA8dgUxBfFN/cHnwTX0TwD/BRGBNBxdvmppub
	rVovc62sJmna9JKa9DTpyTn5zncR/f3g5F9na8X7EDOoueQuXtZH7cz8Owdh1JY03Zknyi/T
	UFIqbVDwz4tZohqTweK/GEqBk0bvDzKSefhoyG5ZrbV4M1fNZk83Ctfc8cuUUklxYSpAxEBh
	o4Fj/bLvTKJ/79CftzZvz36258sD3xyVCg4NP0+uO4L6TwGkrJA0GUSM+JiZzY7jWiw5pScY
	NDMbPxWC+54fS2VKY7eF85+9YitcdRKpdwbV+Mfv01WyI977ueS10OzFYtWemW/Wl9zXr0Z+
	//Xuhva3qbjrqUS0M6tqT3P5HNHU5tZWb/yCoJuNroNBsfHw3lWDGQgiIjhOfWG0tvvVaTF9
	RSX2Qf0YcdJJWRRH+sNmgGq/rWrN9ySLg3uPZDYNpu3RtmUzevI8YG0mgyjcIxFGElAWihmo
	TqilI9t71+5KdW/Zkd0da+1i0fQnA/tE8itCKZZlIZEEJsIwUDJgoQTngtTvlwt/KF7hXEAA
	hDdfyd8B1Rt+w+E6hhEksIksUHadvCpeskyk24+RyBpqD4Qtku7pXuBdLL5epU6EkOt7XLgF
	qgX+6bv2RhACVh+uXC9MLj548DS98VA+N+Z7bs0zRod+bl2eiMydc+OH2cKNiYkcrP39tZO/
	iXeOTI9ef/7i/0i8O5DAcRYYY/G4HQSBUxreNngwGob22P5fhuPE55by6mr425fFnX0De4RU
	zkIlFGuDEFJC0h0rnnnw2aPbuzrvKhD1fUQ4h24zacyN1Ce8QrhD81qTC6WkBkAKMTc1Xl1s
	mlPXUEuwpKM84EQpU0lDQmu5FSg+CyCAKFBAAwAkElBw6E6vbLF4oADQSiqSz5devfQJNYEu
	ld+ckxp+AD6CUCttMuLY4XsVSBHIzcj3v8J7zNxrjOMAAAAASUVORK5CYII=
}]

} ;# namespace 16x16
} ;# namespace icon
} ;# namespace board
} ;# namespace setup

# vi:set ts=3 sw=3:
