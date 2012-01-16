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

namespace eval move {
namespace eval mc {

set ReplaceMove		"Replace Move"
set AddNewVariation	"Add New Variation"
set NewMainLine		"New Main Line"
set TryVariation		"Try Variation"
set ExchangeMove		"Exchange Move"

set GameWillBeTruncated	"Game will be truncated. Continue with '%s'?"

} ;# namespace mc


array set Square {
	current		-1
	selected		-1
	suggested	-1
	origin		-1
}

array set Options {
	addVarWithoutAsking	0
	askToReplaceMoves		1
	defaultAction			replace
	searchDepth				3
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
		set square [::board::stuff::getSquare $board {*}$args]
	
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

	set Disabled 1

	if {$Square(selected) != -1} {
		::board::stuff::hilite $board $Square(selected) off
	}

	if {$hilite(show-suggested)} {
		::board::stuff::hilite $board $Square(suggested) off
		::board::stuff::hilite $board $Square(current) off
	}

}


proc enterSquare {{square {}}} {
	variable ::application::board::board
	variable ::board::hilite
	variable Square
	variable Disabled

	if {$Disabled} { return }

	if {[llength $square]} {
		set Square(current) $square
	} elseif {$Square(current) == -1} {
		return
	} else {
		set square $Square(current)
	}

	if {$Square(selected) == -1} {
		if {$hilite(show-suggested)} {
			set Square(origin) -1
			set suggested [::scidb::pos::guess $square]
			if {$suggested != -1} { set Square(origin) $square }
		} else {
			set suggested -1
		}
	
		if {$suggested == -1} {
			::board::stuff::hilite $board $square off
			::board::stuff::hilite $board $Square(suggested) off
		} else {
			::board::stuff::hilite $board $square suggested
			::board::stuff::hilite $board $suggested suggested
		}

		set Square(suggested) $suggested
	} else {
		::board::stuff::hilite $board $Square(selected) selected
		if {$Square(origin) != -1} {
			::board::stuff::hilite $board $Square(suggested) suggested
			::board::stuff::hilite $board $Square(origin) suggested
		}
	}
}


proc leaveSquare {{square {}}} {
	variable ::application::board::board
	variable ::board::hilite
	variable Square
	variable Leave

	if {[llength $square] == 0} {
		if {$Square(current) != -1} {
			::board::stuff::hilite $board $Square(current) off
		}
		if {$Square(suggested) != -1} {
			::board::stuff::hilite $board $Square(suggested) off
			set Square(suggested) -1
		}
	} elseif {$Leave <= 0} {
		set Leave [expr {-($square + 1)}]
	} else {
		if {$Square(selected) != -1} {
			if {$square != $Square(selected)} {
				::board::stuff::hilite $board $square off
			}
		}

		if {$hilite(show-suggested)} {
			::board::stuff::hilite $board $Square(current) off
			::board::stuff::hilite $board $Square(suggested) off
		}

		set Square(current) -1
	}
}


proc pressSquare {square state} {
	variable ::application::board::board
	variable Square
	variable Disabled

	if {$Disabled} { return }

	if {$Square(selected) == -1} {
		set Square(selected) $square
		::board::stuff::hilite $board $square selected

		# Drag this piece if it is the same color as the side to move:
		set c [::scidb::pos::stm]
		set p [string index [::board::stuff::piece $board $square] 0]
		if {$c eq $p} { ::board::stuff::setDragSquare $board $square }
	} else {
		::board::stuff::setDragSquare $board
		::board::stuff::hilite $board $Square(selected) off
		::board::stuff::hilite $board $square off
		set Square(selected) -1
		enterSquare $square
	}
}


proc releaseSquare {x y state} {
	variable ::application::board::board
	variable ::board::hilite
	variable Square
	variable Disabled

	if {$Disabled} { return }

	set suggested $Square(suggested)
	set selected $Square(selected)
	set Square(selected) -1
	set dragged [::board::stuff::isDragged? $board]
	set square [::board::stuff::getSquare $board $x $y]

	if {$square >= 0} {
		set allowIllegalMove [expr {$state & 1}] ;# detect whether Shift is held down

		if {$square == $selected} {
			::board::stuff::setDragSquare $board
			if {$hilite(show-suggested)} {
				# user pressed and released on same square, so make the suggested
				# move if there is one and the piece was not dragged
				set Square(current) -1
				if {!$dragged} {
					AddMove $square $Square(suggested) $allowIllegalMove
				}
				::board::stuff::hilite $board $selected off
				enterSquare $square
			} else {
				::board::stuff::hilite $board $selected off
			}
			# else current square is the square user pressed the button on, so we do nothing
		} else {
			# user has dragged to another square, so try to add this as a move
			::board::stuff::hilite $board $selected off
			set piece [::board::stuff::piece $board $square]
			::board::stuff::animate $board 0
			AddMove $square $selected $allowIllegalMove
			::board::stuff::animate $board 1
		}
	}
	
	if {$suggested != $Square(suggested)} {
		::board::stuff::hilite $board $suggested off
	}
	::board::stuff::setDragSquare $board
}


proc addMove {san noMoveCmd {force no}} {
	if {[::scidb::game::position atEnd?]} {
		application::pgn::ensureScratchGame
		set action "add"
	} else {
		if {!$force} {
			set moves [::scidb::game::next moves -ascii]

			for {set i 0} {$i < [llength $moves]} {incr i} {
				if {[lindex $moves $i] eq $san} {
					::scidb::game::go variation [expr {$i - 1}]
					::application::board::goto 1
					return
				}
			}
		}
		set action [ConfirmReplaceMove]
	}

	switch $action {
		mainline {
			::widget::busyOperation ::scidb::game::variation mainline $san
			::scidb::game::go 1
		}

		variation {
			set varno [::scidb::game::variation new $san]
			::widget::busyOperation [namespace code [list EnterVariation $varno]]
		}

		replace {
			::widget::busyOperation ::scidb::game::replace $san
			::scidb::game::go 1
		}

		trial {
			::widget::busyOperation ::scidb::game::trial $san
			::scidb::game::go 1
		}

		exchange {
			variable ::application::board::board
			doDestructiveCommand \
				$board \
				$mc::ExchangeMove \
				[list ::widget::busyOperation ::scidb::game::exchange $san] \
				[list ::scidb::game::go 1] \
				$noMoveCmd \
				;
		}

		add {
			::scidb::game::move $san
			::scidb::game::go 1
		}

		default {
			if {[llength $noMoveCmd]} { eval $noMoveCmd }
		}
	}
}


proc doDestructiveCommand {parent action cmd yesAction noAction} {
	if {![eval $cmd]} {
		set rc [;;dialog::question -parent $parent -message [format $mc::GameWillBeTruncated $action]]
		if {$rc eq "no"} {
			eval $noAction
			return
		}
		eval $cmd -force
	}

	eval $yesAction
}


proc EnterVariation {varno} {
	::scidb::game::go variation $varno
	::scidb::game::go 1
}


proc AddMove {sq1 sq2 allowIllegalMove} {
	variable ::application::board::board
	variable Leave

	if {$sq2 == -1} { return [::board::stuff::setDragSquare $board] }
	set nullmove [expr {$sq1 eq "null" && $sq2 eq "null"}]

	if {$sq1 ne "null"} {
		set c [::scidb::pos::stm]
		set s [string index [::board::stuff::piece $board $sq1] 0]
		set f [string index [::board::stuff::piece $board $sq2] 1]
		if {$s ne $c || $f eq "k"} {
			set tmp $sq1
			set sq1 $sq2
			set sq2 $tmp
		}
	}

	if {!$nullmove && ![::scidb::pos::valid? $sq1 $sq2 $allowIllegalMove]} {
		# illegal move, but if it is king takes king then treat it as entering a null move
		set boardPos [::scidb::pos::board]
		::board::stuff::setDragSquare $board
		set k1 [string tolower [string index $boardPos $sq1]]
		set k2 [string tolower [string index $boardPos $sq2]]
		if {$k1 ne "k" || $k2 ne "k"} { return }
		set sq1 null
		set sq2 null
	}

	variable _promoted 0

	if {[scidb::pos::promotion? $sq1 $sq2 $allowIllegalMove]} {
		if {![winfo exists $board.popup_promotion]} {
			set m [menu $board.popup_promotion -tearoff false]
			catch { wm attributes $m -type popup_menu }
			$m add command -image $::icon::22x22::piece(bq) -command [namespace code { set _promoted 2 }]
			$m add command -image $::icon::22x22::piece(br) -command [namespace code { set _promoted 3 }]
			$m add command -image $::icon::22x22::piece(bb) -command [namespace code { set _promoted 4 }]
			$m add command -image $::icon::22x22::piece(bn) -command [namespace code { set _promoted 5 }]
		}
		set Leave 0
		variable _trigger 0
		bind $board.popup_promotion <<MenuUnpost>> [list set [namespace current]::_trigger 1]
		tk_popup $board.popup_promotion {*}[winfo pointerxy $board]
		vwait [namespace current]::_trigger
		if {$Leave < 0} { leaveSquare [expr {-($Leave - 1)}] }
		set Leave 1
		if {$_promoted == 0} { return [::board::stuff::setDragSquare $board] }
	}

	addMove \
		[::scidb::pos::san $sq1 $sq2 $_promoted] \
		[list ::board::stuff::setDragSquare $board] \
		$allowIllegalMove \
		;
}


proc ConfirmReplaceMove {} {
	variable ::application::board::board
	variable Options
	variable Disabled
	variable Leave
	variable Lock

	if {$Options(addVarWithoutAsking)}	{ return "variation" }
	if {[::game::trialMode?]}				{ return "replace" }
	if {!$Options(askToReplaceMoves)}	{ return "replace" }

	set i 0
	set m $board.popup_confirm
	catch { destroy $m }
	variable _action cancel
	menu $m -tearoff false
	catch { wm attributes $m -type popup_menu }
	foreach {label action} [list	[namespace current]::mc::ReplaceMove		replace   \
											[namespace current]::mc::AddNewVariation	variation \
											[namespace current]::mc::NewMainLine		mainline  \
											[namespace current]::mc::TryVariation		trial     \
											[namespace current]::mc::ExchangeMove		exchange  \
											::mc::Cancel										cancel] {
		$m add command -command [namespace code [list set _action $action]]
		::widget::menuTextvarHook $m $i $label
		incr i
	}
	$m entryconfigure 5 -accelerator $::mc::Escape
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
	after idle [namespace code Unlock]

	if {$_action eq "trial"} {
		::game::startTrialMode
	}

	return $_action
}


proc Unlock {} {
	set [namespace current]::Lock 0
	set [namespace current]::Disabled 0
}

} ;# namespace move

# vi:set ts=3 sw=3:
