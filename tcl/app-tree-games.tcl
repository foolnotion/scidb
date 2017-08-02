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

::util::source tree-game-list

namespace eval application {
namespace eval tree {
namespace eval games {

variable Tables {}


proc build {parent width height} {
	variable Tables
	variable Vars

	set table $parent.treeGames
	set columns {white whiteElo black blackElo event result date length}
	set tb [::gametable::build $table [namespace code [list View $parent.treeGames]] $columns \
		-id db:tree:games \
		-takefocus 0 \
		-mode list \
		-positioncmd ::scidb::tree::position \
	]
	lappend Tables $table

	::bind $tb <<TableVisit>>		+[namespace code [list TableVisit $table %d]]
	::bind $tb <<TablePopdown>>	+[namespace code [list ReleaseButton $table]]

	::bind [::scrolledtable::scrolledtablePath $tb] <<TableScroll>> \
		+[namespace code [list ::gametable::doSelection $table]]

	::gametable::bind $table <ButtonPress-1>		+[namespace code [list Press1 $table %x %y]]
	::gametable::bind $table <Button1-Motion>		 [namespace code [list Motion1 $table %x %y]]
	::gametable::bind $table <ButtonRelease-1>	+[namespace code [list Release1 $table]]
	::gametable::bind $table <ButtonPress-2>		+[list set [namespace current]::Vars(button) 2]
	::gametable::bind $table <ButtonRelease-2>	+[namespace code [list ReleaseButton $table]]
	::gametable::bind $table <ButtonPress-3>		+[list set [namespace current]::Vars(button) 3]

	set Vars(after)  {}
	set Vars(button) 0
	set Vars(start) -1
	set Vars(hidden) 1
	set Vars(update) {}
	set Vars(parent) $parent
	set Vars(table)  $table

	::scidb::db::subscribe gameList \
		[namespace current]::TableUpdate \
		[namespace current]::Close \
		$table \
		;
	bind $table <<TableMinSize>> [namespace code [list TableMinSize $table %d]]
	after idle [namespace parent]::startSearch
	return $table
}


proc activate {w flag} {
	variable Vars

	set Vars(hidden) [expr {!$flag}]

	if {$flag && [llength $Vars(update)]} {
		TableUpdate {*}$Vars(update)
		set $Vars(update) {}
	}
}


proc closed {w} {
	variable Vars

	::scidb::db::unsubscribe gameList \
		[namespace current]::TableUpdate \
		[namespace current]::Close \
		$Vars(table) \
		;
	catch { after cancel $Vars(after) }
	catch { after cancel $Vars(timer) }
	catch { after cancel $Vars(interval) }
}


proc clear {{parent ""}} {
	variable Vars

	if {[string length $parent] == 0} { set parent $Vars(parent) }
	::gametable::clear $parent.treeGames
	set Vars(update) {}
}


proc parent {} { return [set [namespace current]::Vars(parent)] }
proc table {}  { return [set [namespace current]::Vars(table)] }


proc ReleaseButton {table} {
	variable Vars

	set Vars(button) 0
	::gametable::doSelection $table
}


proc Press1 {table x y} {
	variable Vars
	lassign [::gametable::identify $table $x $y] row column
	set Vars(start) $row
	set Vars(button) 1
}


proc Motion1 {table x y} {
	variable Vars

	if {$Vars(start) < 0} { return }

	lassign [::gametable::identify $table $x $y] row column

	if {$row < 0} {
#		::gametable::activate $table none
#		::gametable::select $table none
		set offs [::gametable::scrolldistance $table $y]

		if {$offs != 0} {
			if {$offs < 0} {
				set Vars(dir) up
			} else {	;# offs > 0
				set Vars(dir) down
			}

			set Vars(interval) [expr {300/max(int(abs($offs)/5.0 + 0.5), 1)}]

			if {![info exists Vars(timer)]} {
				set Vars(timer) [after $Vars(interval) [namespace code [list Scroll $table]]]
			}
		} elseif {[info exists Vars(timer)]} {
			after cancel $Vars(timer)
			unset Vars(timer)
		}
	} else {
		if {[info exists Vars(timer)]} {
			after cancel $Vars(timer)
			unset Vars(timer)
		}
#		if {$row == $Vars(selected)} {
#			if {$row != [::table::selection $table]} {
#				::table::select $table $row
#			}
#		} elseif {$row >= 0} {
#			if {$Vars(selected) == [::table::selection $table]} {
#				::table::select $table none
#			}
#		}
	}

	TreeCtrl::MotionInItems [::gametable::tablePath $table] $x $y
}


proc Release1 {table} {
	variable Vars

	set Vars(button) 0
	set Vars(start) -1

	if {[info exists Vars(dir)]} {
		catch { after cancel $Vars(timer) }
		unset -nocomplain Vars(dir)
		unset -nocomplain Vars(timer)
		unset -nocomplain Vars(interval)
	}
}


proc Scroll {table} {
	variable Vars

	if {[info exists Vars(dir)]} {
		::gametable::scroll $table $Vars(dir)
		set Vars(timer) [after $Vars(interval) [namespace code [list Scroll $table]]]
	}
}


proc TableVisit {table data} {
	variable Vars

	if {$Vars(button) >= 1} { return }
	lassign $data mode id row
	if {$mode eq "leave"} { set row none }
	::gametable::activate $table $row
}


proc View {pane base variant} {
	return [::scidb::tree::view $pane $base]
}


proc TableUpdate {table id base variant {view -1} {index -1}} {
	variable Vars

	if {[::scidb::tree::isRefBase? $base] && $view == [::scidb::tree::view]} {
		if {$Vars(hidden)} {
			set Vars(update) [list $table $id $base $variant $view $index]
		} else {
			after cancel $Vars(after)

			if {$index == -1} {
				set Vars(after) [after idle [namespace code [list UpdateTable $table $base $variant]]]
			} else {
				set Vars(after) [after idle [list ::gametable::fill $table $index [expr {$index + 1}]]]
			}
			set Vars(update) {}
		}
	}
}


proc UpdateTable {table base variant} {
	set size [::scidb::view::count games $base $variant [::scidb::tree::view]]
	::scrolledtable::select $table none
	after idle [list ::gametable::update $table $base $variant $size]
	after idle [list ::scrolledtable::scroll $table home]
}


proc TableMinSize {table minsize} {
	# TODO
}


proc Close {table base variant} {
	::gametable::forget $table $base $variant
}


proc WriteOptions {chan} {
	variable Tables

	foreach table $Tables {
		puts $chan "::gametable::setOptions db:tree:games {"
		::options::writeArray $chan [::gametable::getOptions $table]
		puts $chan "}"
	}
}

::options::hookWriter [namespace current]::WriteOptions

} ;# namespace games
} ;# namespace tree
} ;# namespace application

# vi:set ts=3 sw=3:
