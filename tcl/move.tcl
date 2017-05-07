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

::util::source move-handling

namespace eval move {
namespace eval mc {

set Action(replace)		"Replace Move"
set Action(variation)	"Add New Variation"
set Action(mainline)		"New Main Line"
set Action(trial)			"Try Variation"
set Action(exchange)		"Exchange Move"
set Action(append)		"Append move"
set Action(load)			"Load first game with this continuation"

set Accel(trial)			"T" ;# should coincide with ::application::board::mc::Accel(trial-mode)
set Accel(replace)		"R"
set Accel(variation)		"V"
set Accel(append)			"A"
set Accel(load)			"L"

set GameWillBeTruncated	"Game will be truncated. Continue with '%s'?"

} ;# namespace mc


array set Square {
	current		-1
	selected		-1
	suggested	-1
	origin		-1
	hilited		-1
}

array set Drop {
	piece		" "
	takeBack	-1
}

array set Options {
	addVarWithoutAsking	0
	askToReplaceMoves		1
	defaultAction			replace
	searchDepth				3
	figurineSize			24
}

variable Disabled	0
variable Leave		1
variable Lock		0


proc translate {san} {
	return $san	;# TODO
}


proc setup {} {
	::scidb::pos::searchDepth [set [namespace current]::Options(searchDepth)]
}


proc enable {args} {
	variable ::application::board::board
	variable Disabled
	variable Lock

	if {$Lock} { return }

	set Disabled 0

	if {[llength $args]} {
		set square [::board::diagram::getSquare $board {*}$args]
	
		if {$square != -1} {
			enterSquare $square
		}
	}
}


proc disable {} {
	variable ::application::board::board
	variable ::board::hilite
	variable Disabled
	variable Square

	::variation::hide
	set Disabled 1

	if {$Square(selected) != -1} {
		::board::diagram::hilite $board $Square(selected) off
	}

	if {$hilite(show-suggested)} {
		::board::diagram::hilite $board $Square(suggested) off
		::board::diagram::hilite $board $Square(current) off
	}

}


proc reset {} {
	variable ::application::board::board
	variable Square
	variable Drop

	::application::board::deselectInHandPiece
	set Drop(piece) " "

	if {$Square(selected) != -1} {
		::board::diagram::hilite $board $Square(selected) off
		set Square(selected) -1
	}

	if {$Square(suggested) != -1} {
		::board::diagram::hilite $board $Square(suggested) off
		set Square(suggested) -1
	}
}


proc nextGuess {args} {
	variable ::application::board::board
	variable ::board::hilite
	variable Square
	variable Drop
	variable Disabled

	::variation::hide

	if {$Disabled} { return }
	if {$Square(current) == -1} { return }
	if {!$hilite(show-suggested)} { return }
	if {$Square(selected) != -1} { return }

	if {$Drop(piece) ne " "} {
		set Drop(piece) " "
		::application::board::deselectInHandPiece
		::board::diagram::hilite $board $Square(origin) off
		set meth guess
	} else {
		set meth guessNext
	}

	if {[llength $args] == 2} {
		set square [::board::diagram::getSquare $board {*}$args]
		if {$square != $Square(current)} { return }
	}

	set suggested [::scidb::pos::$meth $Square(current)]

	if {$suggested != -1} {
		if {$Square(suggested) != -1} {
			::board::diagram::hilite $board $Square(suggested) off
		}
		::board::diagram::hilite $board $suggested suggested
		::board::diagram::hilite $board $Square(current) suggested
		set Square(suggested) $suggested
	}
}


proc enterSquare {{square {}}} {
	variable ::application::board::board
	variable ::board::hilite
	variable Square
	variable Disabled
	variable Drop

	if {$Disabled} { return }

	if {[string length $square]} {
		set Square(current) $square
	} elseif {$Square(current) == -1} {
		return
	} else {
		set square $Square(current)
	}

	set Square(suggested) -1

	if {$Drop(piece) ne " "} {
		if {$hilite(show-suggested) && [::scidb::pos::legal? $square $square no $Drop(piece)]} {
			set Square(origin) $square
			set Square(suggested) $square
			::board::diagram::hilite $board $Square(suggested) suggested
		}
	} elseif {$Square(selected) == -1} {
		set Square(origin) -1

		if {$hilite(show-suggested)} {
			set suggested [::scidb::pos::guess $square]
			if {$suggested != -1} { set Square(origin) $square }
		} else {
			set suggested -1
		}
	
		if {$suggested != -1} {
			::board::diagram::hilite $board $square suggested
			::board::diagram::hilite $board $suggested suggested
		}

		if {$hilite(show-suggested)} {
			set Square(suggested) $suggested
		}
	} elseif {$hilite(show-suggested)} {
		::board::diagram::hilite $board $Square(selected) selected
		if {$Square(origin) != -1} {
			::board::diagram::hilite $board $Square(origin) suggested
		}
	}
}


proc leaveSquare {{square {}}} {
	variable ::application::board::board
	variable ::board::hilite
	variable Square
	variable Leave

	if {[::board::diagram::isDragged? $board]} { return }

	if {[string length $square] == 0} {
		if {$Square(current) != -1} {
			::board::diagram::hilite $board $Square(current) off
		}
		if {$Square(suggested) != -1} {
			::board::diagram::hilite $board $Square(suggested) off
			set Square(suggested) -1
		}
	} elseif {$Leave <= 0} {
		set Leave [expr {-($square + 1)}]
	} else {
		if {$Square(selected) != -1 && $square != $Square(selected)} {
			::board::diagram::hilite $board $square off
		}

		if {$hilite(show-suggested)} {
			::board::diagram::hilite $board $Square(current) off
			::board::diagram::hilite $board $Square(suggested) off
		}

		set Square(current) -1
	}
}


proc pressSquare {square state} {
	variable ::application::board::board
	variable ::board::hilite
	variable Square
	variable Disabled

	::variation::hide

	if {$Disabled} { return }

	if {$Square(selected) == -1} {
		set Square(selected) $square
		::board::diagram::hilite $board $square selected

		# Drag this piece if it is the same color as the side to move:
		set c [::scidb::pos::stm]
		set p [string index [::board::diagram::piece $board $square] 0]
		if {$c eq $p} { ::board::diagram::setDragSquare $board $square }
	} elseif {$hilite(show-suggested)} {
		::board::diagram::setDragSquare $board
		::board::diagram::hilite $board $Square(selected) off
		::board::diagram::hilite $board $Square(suggested) off
		::board::diagram::hilite $board $square off
		set Square(selected) -1
		enterSquare $square
	} elseif {$square eq $Square(selected)} {
		::board::diagram::hilite $board $Square(selected) off
		set Square(selected) -1
	}
}


proc releaseSquare {x y state} {
	variable ::application::board::board
	variable ::board::hilite
	variable Square
	variable Drop
	variable Disabled

	if {[$board cget -cursor] ne "crosshair"} {
		$board configure -cursor crosshair
	}

	if {$Disabled} { return }

	set suggested $Square(suggested)
	set selected $Square(selected)
	set dragged [::board::diagram::isDragged? $board]
	set square [::board::diagram::getSquare $board $x $y]

	if {$dragged} {
		::board::diagram::finishDrag $board
	}

	if {$hilite(show-suggested) || $square != $Square(selected)} {
		set Square(selected) -1
	}

	if {$square >= 0} {
		set allowIllegalMove [::util::shiftIsHeldDown? $state]

		if {$square == $selected} {
			::board::diagram::setDragSquare $board
			if {$hilite(show-suggested)} {
				# user pressed and released on same square, so make the suggested
				# move if there is one and the piece was not dragged
				set drop $Drop(piece)
				set Square(current) -1
				if {!$dragged} {
					AddMove $square $Square(suggested) $allowIllegalMove
				}
				if {$drop ne " "} {
					::application::board::deselectInHandPiece
					set suggested $Square(suggested)
				}
				::board::diagram::hilite $board $selected off
				enterSquare $square
			} elseif {$Drop(piece) ne " "} {
				AddMove $square $selected $allowIllegalMove
				::application::board::deselectInHandPiece
				::board::diagram::hilite $board $selected off
				set Drop(piece) " "
			}
			# else current square is the square user pressed the button on, so we do nothing
		} else {
			# user has dragged to another square, so try to add this as a move
			set Square(current) -1
			::board::diagram::hilite $board $selected off
			::board::diagram::hilite $board $Square(hilited) off
			set piece [::board::diagram::piece $board $square]
			::board::diagram::animate $board 0
			AddMove $square $selected $allowIllegalMove
			::board::diagram::animate $board 1
		}
	}
	
	if {$hilite(show-suggested) && $suggested != $Square(suggested)} {
		::board::diagram::hilite $board $suggested off
	}

	::board::diagram::setDragSquare $board

	if {$Drop(piece) ne " "} {
		::application::board::deselectInHandPiece
		set Drop(piece) " "
	}
}


proc dragPiece {x y state} {
	variable ::application::board::board
	variable ::board::hilite
	variable Square

	if {[::board::diagram::dragSquare $board] == -1} { return }
	set isDragging [::board::diagram::isDragged? $board]
	::board::diagram::dragPiece $board $x $y

	if {[$board cget -cursor] ne "hand2"} {
		$board configure -cursor hand2
	}

	if {$hilite(show-suggested)} {
		set from [::board::diagram::dragSquare $board]

		if {!$isDragging} {
			::board::diagram::hilite $board $Square(suggested) off
			::board::diagram::hilite $board $Square(selected) off
			set Square(hilited) -1
		}

		set square [::board::diagram::getSquare $board $x $y]
		if {$square == $Square(hilited)} { return }
		if {$Square(hilited) ne $from} {
			::board::diagram::hilite $board $Square(hilited) off
		}

		set allowIllegalMove [::util::shiftIsHeldDown? $state]

		if {$square != -1 && [::scidb::pos::legal? $from $square $allowIllegalMove]} {
			::board::diagram::hilite $board $square suggested
			::board::diagram::raisePiece $board $from
		}

		set Square(hilited) $square
	}
}


proc addMove {confirmWindowType san {noMoveCmd {}} {myActions {}} {force no}} {
	variable ::application::board::board

	if {[::scidb::game::position atEnd?]} {
		::application::pgn::ensureScratchGame
		set action "append"
	} else {
		if {!$force} {
			set moves [::scidb::game::next moves -ascii]

			for {set i 0} {$i < [llength $moves]} {incr i} {
				if {[lindex $moves $i] eq $san} {
					::scidb::game::go variation [expr {$i - 1}]
					::application::board::goto 1
					return ""
				}
			}
		}
		::board::diagram::finishDrag $board
		update idletasks
		set action [ConfirmReplaceMove $confirmWindowType $myActions]
	}

	if {![doAction $action $san $noMoveCmd]} {
		if {$action in $myActions} { return $action }
		if {[llength $noMoveCmd]} { eval $noMoveCmd }
	}

	return ""
}


proc doAction {action san {noMoveCmd {}}} {
	switch $action {
		mainline {
			::scidb::game::variation mainline $san
			::scidb::game::go 1
		}

		variation {
			set varno [::scidb::game::variation new $san]
			EnterVariation $varno
		}

		replace {
			::scidb::game::replace $san
			::scidb::game::go 1
		}

		trial {
			::game::flipTrialMode
			::scidb::game::trial $san
			::scidb::game::go 1
		}

		exchange {
			variable ::application::board::board
			doDestructiveCommand \
				$board \
				$mc::Action(exchange) \
				[list ::scidb::game::exchange $san] \
				[list ::scidb::game::go 1] \
				$noMoveCmd \
				;
		}

		append {
			::application::pgn::ensureScratchGame
			::scidb::game::move $san
			::scidb::game::go 1
		}

		default {
			return 0
		}
	}

	return 1
}


proc addActionsToMenu {m command {extraActions {}}} {
	set i 0
	set atEnd [::scidb::game::position atEnd?]

	set actionList {}
	if {$atEnd} {
		if {"append" in $extraActions} { lappend actionList append }
	} else {
		lappend actionList replace variation mainline
	}
	if {![::scidb::game::query trial]} {
		lappend actionList trial
	}
	if {!$atEnd} {
		lappend actionList exchange
	}
	foreach action $extraActions {
		if {$action ni $actionList && ($action ne "append" || $atEnd)} {
			lappend actionList $action
		}
	}

	foreach action $actionList {
		set accel {}
		if {[info exists mc::Accel($action)]} {
			set key $mc::Accel($action)
			lappend accel -accelerator $key
			set cmd [namespace code [list InvokeAction $m $command $action]]
			bind $m <Key-$key> $cmd
			bind $m <Key-[string tolower $key]> $cmd
		}
		$m add command \
			-command [list eval $command $action] \
			-image $icon::16x16::Action($action) \
			-compound left \
			{*}$accel \
			;
		::widget::menuTextvarHook $m $i [namespace current]::mc::Action($action)
		incr i
	}

	return $i
}


proc doDestructiveCommand {parent action cmd yesAction noAction} {
	if {![{*}$cmd]} {
		set rc [;;dialog::question -parent $parent -message [format $mc::GameWillBeTruncated $action]]
		if {$rc eq "no"} {
			if {[llength $noAction]} {
				{*}$noAction
			}
			return
		}
		if {[string match *widget::busyOperation [lindex $cmd 0]]} {
			lassign $cmd cmd args
			set cmd [list $cmd [list {*}$args -force]]
		} else {
			lappend cmd -force
		}
		{*}$cmd
	}

	if {[llength $yesAction]} {
		{*}$yesAction
	}
}


proc inHandSelected {w piece} {
	variable Drop
	set Drop(piece) $piece
}


proc inHandDropPosition {w x y state piece} {
	variable ::application::board::board
	variable ::board::hilite
	variable Square

	if {$hilite(show-suggested)} {
		set square [::board::diagram::getSquare $board $x $y]
		if {$square == $Square(hilited)} { return }
		::board::diagram::hilite $board $Square(hilited) off

		set allowIllegalMove [::util::shiftIsHeldDown? $state]

		if {$square != -1 && [::scidb::pos::legal? $square $square $allowIllegalMove $piece]} {
			::board::diagram::hilite $board $square suggested
			[::board::diagram::canvas $board] raise drag-piece
		}

		set Square(hilited) $square
		set Square(origin) $square
	}
}


proc inHandPieceDrop {w x y state piece} {
	variable ::application::board::board
	variable ::board::hilite
	variable Square
	variable Drop

	if {$hilite(show-suggested)} {
		::board::diagram::hilite $board $Square(hilited) off
		set Square(hilited) -1
	}

	set square [::board::diagram::getSquare $board $x $y]
	set allowIllegalMove [::util::shiftIsHeldDown? $state]

	if {$square == -1} {
		::application::board::finishDrop
	} else {
		::application::board::deselectInHandPiece
		if {[::scidb::pos::legal? $square $square $allowIllegalMove $piece]} {
			::board::diagram::setPiece $board $square $piece
			set Drop(takeBack) $square
			set Drop(piece) $piece
			::board::diagram::animate $board 0
			AddMove $square $square $allowIllegalMove
			::board::diagram::animate $board 1
			set Drop(takeBack) -1
		} else {
			::application::board::finishDrop
		}
	}

	set Drop(piece) " "
}


proc EnterVariation {varno} {
	::scidb::game::go variation $varno
	::scidb::game::go 1
}


proc AddMove {sq1 sq2 allowIllegalMove} {
	if {![DoAddMove $sq1 $sq2 $allowIllegalMove]} { AfterAddMove }
}


proc DoAddMove {sq1 sq2 allowIllegalMove} {
	variable ::application::board::board
	variable Options
	variable Leave
	variable Drop

	if {$sq2 == -1} { return 0 }
	if {[::scidb::game::query over?]} { return 0 }
	if {$sq2 == -1} { return 0 }
	set nullmove [expr {$sq1 eq "null" && $sq2 eq "null"}]

	if {$sq1 ne "null"} {
		set c [::scidb::pos::stm]
		set s [string index [::board::diagram::piece $board $sq1] 0]
		set f [string index [::board::diagram::piece $board $sq2] 1]
		if {$s ne $c || $f eq "k"} {
			set tmp $sq1
			set sq1 $sq2
			set sq2 $tmp
		}
	}

	if {![::scidb::pos::valid? $sq1 $sq2]} { return 0 }

	if {!$allowIllegalMove && ![::scidb::pos::legal? $sq1 $sq2 $allowIllegalMove $Drop(piece)]} {
		return 0
	}

	variable _promoted $Drop(piece)
	set Drop(piece) " "

	if {[scidb::pos::promotion? $sq1 $sq2 $allowIllegalMove]} {
		catch { destroy $board.popup_promotion }
		set color [string index [::board::diagram::piece $board $sq1] 0]
		set variant [::scidb::game::query Variant?]
		set m [menu $board.popup_promotion -tearoff false]
		catch { wm attributes $m -type popup_menu }
		switch $variant {
			Antichess	{ set pieces {k r n q b} }
			Losers		{ set pieces {q r n b} }
			default		{ set pieces {q r b n} }
		}
		foreach p $pieces {
			$m add command \
				-image photo_Piece(figurine,1,$color$p,$Options(figurineSize)) \
				-command [namespace code [list set _promoted $p]] \
				;
		}
		set Leave 0
		variable trigger_ 0
		bind $board.popup_promotion <<MenuUnpost>> [list set [namespace current]::trigger_ 1]
		tk_popup $board.popup_promotion {*}[winfo pointerxy $board]
		vwait [namespace current]::trigger_
		if {$Leave < 0} { leaveSquare [expr {-($Leave - 1)}] }
		set Leave 1
		if {$_promoted == " "} { return 0 }
#	} elseif {!$nullmove && $sq1 eq $sq2 && $Drop(piece) eq " "} {
#		catch { destroy $board.popup_drop }
#		set color [string range [::scidb::game::query stm] 0 0]
#		set m [menu $board.popup_drop -tearoff false]
#		catch { wm attributes $m -type popup_menu }
#		set pieceCount [::scidb::pos::inHand? -destination $sq1 -stm]
#		set havePieces 0
#		foreach n $pieceCount p {q r b n p} {
#			if {$n} {
#				$m add command \
#					-image photo_Piece(figurine,1,$color$p,$Options(figurineSize)) \
#					-command [namespace code [list set _promoted $p]] \
#					;
#				incr havePieces 1
#				set piece $p
#			}
#		}
#		switch $havePieces {
#			0 { return 0 }
#			1 { set _promoted $piece }
#
#			default {
#				set Leave 0
#				variable trigger_ 0
#				bind $board.popup_drop <<MenuUnpost>> [list set [namespace current]::trigger_ 1]
#				tk_popup $board.popup_drop {*}[winfo pointerxy $board]
#				vwait [namespace current]::trigger_
#				if {$Leave < 0} { leaveSquare [expr {-($Leave - 1)}] }
#				set Leave 1
#				if {$_promoted == " "} { return 0 }
#			}
#		}
	}

	addMove \
		menu \
		[::scidb::pos::san $sq1 $sq2 $_promoted] \
		[namespace code AfterAddMove] \
		{} \
		$allowIllegalMove \
		;

	return 1
}


proc AfterAddMove {} {
	variable ::application::board::board
	variable Drop

	::board::diagram::setDragSquare $board

	if {$Drop(takeBack) != -1} {
		::application::board::finishDrop
		::board::diagram::setPiece $board $Drop(takeBack) .
		set Drop(takeBack) -1
	}

	reset
}


proc InvokeAction {m command action} {
	::tk::MenuUnpost $m
	eval $command $action
}


proc SetAction {action} {
	set [namespace current]::action_ $action
}


proc ConfirmReplaceMove {confirmWindowType extraActions} {
	variable ::application::board::board
	variable Options
	variable Disabled
	variable Leave
	variable Lock

	if {$Options(addVarWithoutAsking)}	{ return "variation" }
	if {[::game::trialMode?]}				{ return "replace" }
	if {!$Options(askToReplaceMoves)}	{ return "replace" }

	set m $board.popup_confirm
	catch { destroy $m }
	variable action_ cancel
	menu $m -tearoff false
	catch { wm attributes $m -type popup_menu }
	set i [addActionsToMenu $m [namespace current]::SetAction $extraActions]
	$m add separator; incr i
	$m add command \
		-image $::icon::16x16::crossHand \
		-compound left \
		-command [namespace code [list set action_ cancel]] \
		-accelerator $::mc::Key(Esc) \
		;
	::widget::menuTextvarHook $m $i ::mc::Cancel
	set entry [lsearch -exact {replace variation} $Options(defaultAction)]
	set Leave 0
	set Disabled 1
	set Lock 1
	variable _wait 1
	bind $m <<MenuUnpost>> [list set [namespace current]::_wait 0]
	tk_popup $m {*}[winfo pointerxy $board]
	tkwait variable [namespace current]::_wait
	if {$Leave < 0} { leaveSquare [expr {-($Leave - 1)}] }
	set Leave 1
	after idle [namespace code [list Unlock $action_]]
	return $action_
}


proc Unlock {action} {
	variable Lock
	variable Disabled

	set Lock 0

	if {$action eq "cancel"} {
		enable {*}[winfo pointerxy .]
	} else {
		set Disabled 0
	}
}


::board::pieceset::registerFigurines $Options(figurineSize) 1

namespace eval icon {
namespace eval 16x16 {

set Action(trial)		$::icon::16x16::trial
set Action(exchange)	$::icon::16x16::exchange
set Action(append)	$::icon::16x16::plus
set Action(load)		$::icon::16x16::document

set Action(replace) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABaUlEQVQ4y82SQU7bUBCGv/fe
	GOPUejJNRKQoUffcwCx6C7gHQarECegG5R45CHt2SGxQUyWADIvGYI+TNF0grBQkCCsYaTYz
	8+v/55+Bjw7z1sBhp9MFOBmPfz+rfweQNUhS4ADYXS0mcTwEsOvI/Op9+qPbPX1SAyAibRFp
	y2GnM3wN7Kzt+jjmSxSlV1k2fK5ENkT2mknCZhThnMOY/22ZqWJF2Gq3ieI4PTLmtJrP95/6
	1lhLEAQYY2rwTPXRYWspVJmpMisKklaLb71euiFSqxZrDE4E51zNulgsmN7d4ZwjDAKMtagq
	DWC710PLMn0oCmoTV8EAQRjivcd7/8gSBCTNJpuNBqOLCyY3N4N6hb/LJfd5Tj6d1lmWJapK
	pUo1n+OTBCvC5fk5vyaT/s/RqF+voFW1P8my166QNlutg9vra66ybHAyHg/e+4l7URgOC9X+
	Kvh4Z2e57idSqL5g/pPnZ3yK+AfVGIHeAU/ChAAAAABJRU5ErkJggg==
}]

set Action(variation) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9i
	ZSBJbWFnZVJlYWR5ccllPAAAAh1JREFUeNqkU81rE0EUfzszu2uDpK2yFlqoICK2IhameKhX
	b3qznhQ8FvGS/8F/IKAiUZAe9qQXjz14sBQ8SFdKvAixRWJADNmmqXE/Z3Z8s001XYwKDrzd
	x5vf+/6NoZSC/zls6XETDMP4K9C0LI2robohhXCFEIB/YP+aSaQpEEI4qnxgcvMKQKma+mUc
	eXSrWZbBzauz/MWrZgUOWneZECm/de0MD0M5ABYdj+rtdgTXr0zzl68/VdDUYWmcgJQKokiC
	DhIEEjMBOI6tXXKnwyC6iv193YoC7Ze3IJLEe/a8DrbFqHNyrHR2dvIUATbh7waq1ek1Gzvd
	znBFi/OTfN3rejjQKmVszbhw/x0oTCmlHMcUC5jl3vlzzlJfwczxkik+b/sfvvfjB+jwBO82
	dRDtzCzLZaYJZCh4DwHruJq79fetN6Zt7m3HjI1PlZ0kjmdQIMVqUaqIc3/yoDjtOAx9rORR
	a+frpXh+bqKf2eU0+jiXZ6Z0RWc9QiT9+dbtQhQEkEQRGIRo0mztfvEDa3EMfGnbuoJMSt0m
	HCuVIEUcYUzzAlir0SjurYZlchSJKUFSSlDXK9nEOy/s91eG4UQOKHkoyLiNFPudurPMeylW
	h1K+vcy1Td8V8dS6eKPIuDpeBHtvt06fuLwwbeGY/dqqh/YqtucW3w0bQVtXR28/fFqBg73p
	nbu/fY1/IL+LQ8tJRCldGwX7IcAAni09bHQU/ZAAAAAASUVORK5CYII=
}]

set Action(mainline) [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAB+ElEQVQ4y72Sz2sTQRiG3/2R
	jUQ2alKDGOgeAi1FiME9pV7Eeoj/Quitx1zqvSJCwYvgQg8lhd5CD3oQQfCkSGsOSkJDD0WE
	hWpVSNqkDUsm2dnJfB40paat0YvfaZh53of5vhngf9ZyOl1cTqdnj++p/yIQQWCLIJhfmpo6
	kihPUqmioqr230puzs3Z5dXVKknp3HPdkvLYsiq3CgW7126fGiApf1uzVgvnx8bwfm2tCmBB
	55xDCoGAMXQPD+F7HkhKXLKso9BAQlKCNZvQdB2c858tPIzHiwBsPRTSYolE5MrERALARUVV
	aX9n58s3190/fqNUJmO7tVoVgPOg2Swpg4P70egFIsoAKFiTk9OC8+Q50xTfXfdjt9NZWvS8
	lQXTrPzCnUXPKwGANhCs+76/zvnnaU1702o0rl9OJpOs3Y5ETJNae3ufykK8zaqqLaV8+oix
	0iCnDQ/tnRDdG5rWkIzdjsZicd0wtK/1+sGHfv9ZWYiXZSG2Rv6DDlGt7nksFA4DQLhDlDzr
	WU8I8oZR7AGvD4j6A6YHhPOGUckbRnGkICDa4ETIZbM273YR+D7u2LbNiRAQbQzzJ2awLeVW
	StPY9u6udW18/KqqqnixuVntA87zICgN88pZvd0NhWYl0TwAqIrivDolPLJmdD03o+u5PzE/
	AHBq6kpnPytDAAAAAElFTkSuQmCC
}]

} ;# namespace 16x16
} ;# namespace icon
} ;# namespace move

# vi:set ts=3 sw=3:
