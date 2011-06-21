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

namespace eval application {
namespace eval database {
namespace eval events {

array set Defaults {
	sort:players	{}
	sort:events		{}
}

variable Tables {}


proc build {parent} {
	variable Tables

	set top [panedwindow $parent.top \
		-orient horizontal \
		-opaqueresize true \
		-borderwidth 0]
	pack $top -fill both -expand yes
	lappend Tables $top

	set lt ${top}.events

	set rt [panedwindow $top.info \
		-orient vertical \
		-opaqueresize true \
		-borderwidth 0]

	set gl ${rt}.games
	set pl ${rt}.players

	namespace eval [namespace current]::$top {}
	variable ${top}::Vars

	set Vars(after:games) {}
	set Vars(after:events) {}
	set Vars(after:players) {}
	set Vars(active) 0

	::eventtable::build $lt [namespace code [list View $top]] {} \
		-selectcmd [list [namespace current]::events::Search $top] \
		;
	set columns {white whiteElo black blackElo result date round length}
	::gametable::build $gl [namespace code [list View $top]] $columns
	set columns {lastName firstName type sex rating1 federation title}
	::playertable::build $pl [namespace code [list View $top]] $columns \
		-selectcmd [namespace code [list SelectPlayer $top]] \
		;

	::scidb::db::subscribe eventList \
		[namespace current]::players::Update \
		[namespace current]::Close \
		$top \
		;
	::scidb::db::subscribe gameList \
		[namespace current]::games::Update \
		$top \
		;
	::scidb::db::subscribe playerList \
		[namespace current]::events::Update \
		$top \
		;

	bind $rt <<TableMinSize>>	[namespace code [list TableMinSize $rt %d]]
	bind $lt <<TableMinSize>>	[namespace code [list TableMinSize $lt %d]]

	$top add $lt
	$top add $rt

	$rt add $gl
	$rt add $pl

	$top paneconfigure $lt -sticky nsew -stretch middle -minsize 580	;# XXX
	$top paneconfigure $rt -sticky nsew -stretch always

	$rt paneconfigure $gl -sticky nsew -stretch always
	$rt paneconfigure $pl -sticky nsew -stretch always

	return $top
}


proc activate {w menu flag} {
	set path $w.top
	variable ${path}::Vars

	set Vars(active) $flag
	events::Update2 $path [::scidb::db::get name]
	::toolbar::activate $path.events $flag
}


proc select {parent base index} {
	set path $parent.top
	variable ${path}::Vars

	if {$Vars(active)} {
		Select $path $base $index
	} else {
		set Vars($base:select) $index
	}
}


proc Select {path base index} {
	variable ${path}::Vars

	set position [::scidb::db::get lookupEvent $index $Vars($base:view) $base]
	::eventtable::see $path.events $position
	update idletasks
	set row [::eventtable::indexToRow $path.events $position]
	::eventtable::setSelection $path.events $row
}


proc Close {path base} {
	variable ${path}::Vars

	array unset Vars $base:*
	::eventtable::clear $path.events
	::eventtable::forget $path.events $base
	::playertable::clear $path.info.players
	::playertable::forget $path.info.players $base
	::gametable::clear $path.info.games
	::gametable::forget $path.info.games $base
}


proc View {path base} {
	variable ${path}::Vars
	return $Vars($base:view)
}


proc InitBase {path base} {
	variable ${path}::Vars
	variable Defaults

	if {![info exists Vars($base:view)]} {
		set Vars($base:view) [::scidb::view::new $base slave slave master slave]
		set Vars($base:update:events) 1
		set Vars($base:sort:events) $Defaults(sort:events)
		set Vars($base:sort:players) $Defaults(sort:players)
		set Vars($base:lastChange) [::scidb::db::get lastChange $base]
		set Vars($base:select) -1
		::eventtable::init $path.events $base
		::playertable::init $path.info.players $base
		::gametable::init $path.info.games $base
		::scidb::view::search $base $Vars($base:view) null player
	}
}


proc TableMinSize {pane minsize} {
	[winfo parent $pane] paneconfigure $pane -minsize [lindex $minsize 0 0]
}


proc SelectPlayer {path base view} {
	[namespace parent]::selectPlayer $base [::playertable::selectedPlayer $path.info.players $base]
}


namespace eval games {

proc Update {path base {view -1} {index -1}} {
	variable [namespace parent]::${path}::Vars

	[namespace parent]::InitBase $path $base

	if {$view == $Vars($base:view)} {
		after cancel $Vars(after:games)
		set Vars(after:games) [after idle [namespace code [list Update2 $path $base]]]
	}
}


proc Update2 {path base} {
	variable [namespace parent]::${path}::Vars

	set lastChange $Vars($base:lastChange)
	set Vars($base:lastChange) [::scidb::db::get lastChange $base]
	set selected [::eventtable::selectedEvent $path.events $base]

	if {$selected >= 0 && $lastChange < $Vars($base:lastChange)} {
		[namespace parent]::events::Search $path $base $Vars($base:view)
	} else {
		set Vars($base:lastChange) $lastChange

		set n [::scidb::view::count games $base $Vars($base:view)]
		after idle [list ::gametable::update $path.info.games $base $n]

		set n [::scidb::view::count players $base $Vars($base:view)]
		after idle [list ::playertable::update $path.info.players $base $n]
	}
}

} ;# namespace games


namespace eval events {

proc Search {path base view} {
	variable [namespace parent]::${path}::Vars

	::widget::busyCursor on
	::gametable::activate $path.info.games none
	::gametable::select $path.info.games none
	::playertable::activate $path.info.players none
	::playertable::select $path.info.players none
	set selected [::eventtable::selectedEvent $path.events $base]
	::scidb::view::search $base $view null player [list event $selected]
	::widget::busyCursor off
}


proc Update {path base {view -1} {index -1}} {
	variable [namespace parent]::${path}::Vars

	after cancel $Vars(after:events)
	set Vars(after:events) [after idle [namespace code [list Update2 $path $base]]]
}


proc Update2 {path base} {
	variable [namespace parent]::${path}::Vars

	[namespace parent]::InitBase $path $base
	set Vars($base:update:events) 1
	DoUpdate $path $base
}


proc DoUpdate {path base} {
	variable [namespace parent]::${path}::Vars

	if {$Vars(active)} {
		if {[llength $Vars($base:sort:events)]} {
			::widget::busyCursor on
			::scidb::db::sort event $base $Vars($base:sort:events) $Vars($base:view)
			::widget::busyCursor off
			set Vars($base:sort:events) {}
		}
		if {$Vars($base:update:events)} {
			set n [::scidb::db::count events $base]
			after idle [list ::eventtable::update $path.events $base $n]
			after idle [namespace code [list [namespace parent]::games::Update2 $path $base]]
			set Vars($base:update:events) 0
			if {$Vars($base:select) >= 0} {
				after idle [list [namespace parent]::Select $path $base $Vars($base:select)]
				set Vars($base:select) -1
			}
		}
	} else {
		set Vars($base:updateeventsplayers) 1
	}
}

} ;# namespace events

namespace eval players {

proc Update {path base {view -1} {index -1}} {
	variable [namespace parent]::${path}::Vars

	set Vars($base:update:players) 1
	after cancel $Vars(after:players)
	set Vars(after:players) [after idle [namespace code [list Update2 $path $base]]]
}


proc Update2 {path base} {
	variable [namespace parent]::${path}::Vars

	[namespace parent]::InitBase $path $base
	set Vars($base:update:players) 1
	DoUpdate $path $base
}


proc DoUpdate {path base} {
	variable [namespace parent]::${path}::Vars

	if {$Vars(active)} {
		if {[llength $Vars($base:sort:players)]} {
			::widget::busyCursor on
			::scidb::db::sort player $base $Vars($base:sort:players) $Vars($base:view)
			::widget::busyCursor off
			set Vars($base:sort:players) {}
		}
		if {$Vars($base:update:players)} {
			set n [::scidb::view::count players $base $Vars($base:view)]
			after idle [list ::playertable::update $path.info.players $base $n]
			set Vars($base:update:players) 0
		}
	} else {
		set Vars($base:update:players) 1
	}
}

} ;# namespace players


proc WriteOptions {chan} {
	variable Tables

	foreach table $Tables {
		puts $chan "::eventtable::setOptions $table.events {"
		::options::writeArray $chan [::eventtable::getOptions $table.events]
		puts $chan "}"
		puts $chan "::gametable::setOptions $table.info.games {"
		::options::writeArray $chan [::gametable::getOptions $table.info.games]
		puts $chan "}"
		puts $chan "::playertable::setOptions $table.info.players {"
		::options::writeArray $chan [::playertable::getOptions $table.info.players]
		puts $chan "}"
	}
}

::options::hookWriter [namespace current]::WriteOptions

} ;# namespace events
} ;# namespace database
} ;# namespace application

# vi:set ts=3 sw=3:
