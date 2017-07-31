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

::util::source event-list

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

	set top [tk::panedwindow $parent.top \
		-orient horizontal \
		-opaqueresize true \
		-borderwidth 0]
	pack $top -fill both -expand yes
	lappend Tables $top

	set lt ${top}.events
	set rt ${top}.info

	set gl ${rt}.games
	set pl ${rt}.players

	namespace eval [namespace current]::$top {}
	variable ${top}::Vars

	set Vars(after:games) {}
	set Vars(after:events) {}
	set Vars(after:players) {}
	set Vars(active) 0
	set Vars(base) ""

	::eventtable::build $lt [namespace code [list View $top]] {} \
		-selectcmd [list [namespace current]::events::Search $top] \
		-usefind 1 \
		;

	tk::panedwindow $rt -orient vertical -opaqueresize true -borderwidth 0
	set columns {white whiteElo black blackElo result date round length}
	::gametable::build $gl [namespace code [list View $top]] $columns -id db:events
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

	$top paneconfigure $lt -sticky nsew -stretch middle -minsize 380	;# XXX
	$top paneconfigure $rt -sticky nsew -stretch always

	$rt paneconfigure $gl -sticky nsew -stretch always
	$rt paneconfigure $pl -sticky nsew -stretch always

	return $top
}


proc activate {w flag} {
	set path $w.top
	variable ${path}::Vars

	set Vars(active) $flag
	set base [::scidb::db::get name]
	set variant [::scidb::app::variant]
	set Vars($base:$variant:update:events) 1
	events::DoUpdate $path $base $variant

	if {[winfo toplevel $w] ne $w} {
		::toolbar::activate $path.events $flag
	}
}


proc overhang {parent} {
	return [::eventtable::overhang $parent.top.events]
}


proc linespace {parent} {
	return [::eventtable::linespace $parent.top.events]
}


proc setActive {flag} {
	# no action
}


proc select {parent base variant index} {
	set path $parent.top
	variable ${path}::Vars

	if {$Vars(active)} {
		Select $path $base $variant $index
	} else {
		set Vars($base:$variant:select) $index
	}
}


proc Select {path base variant index} {
	variable ${path}::Vars

	set position [::scidb::db::get lookupEvent $index $Vars($base:$variant:view) $base $variant]
	::eventtable::see $path.events $position
	update idletasks
	set row [::eventtable::indexToRow $path.events $position]
	::eventtable::setSelection $path.events $row
}


proc Close {path base variant} {
	variable ${path}::Vars

	array unset Vars $base:$variant:*
	::eventtable::forget $path.events $base $variant
	::playertable::forget $path.info.players $base $variant
	::gametable::forget $path.info.games $base $variant

	if {$Vars(base) eq "$base:$variant"} {
		::eventtable::clear $path.events
		::playertable::clear $path.info.players
		::gametable::clear $path.info.games
	}
}


proc View {path base variant} {
	variable ${path}::Vars
	return $Vars($base:$variant:view)
}


proc InitBase {path base variant} {
	variable ${path}::Vars
	variable Defaults

	if {[info exists Vars($base:$variant:initializing)]} { return }

	if {![info exists Vars($base:$variant:view)]} {
		set Vars($base:$variant:initializing) 1
		set Vars($base:$variant:view) [::scidb::view::new $base $variant slave slave master slave slave]
		set Vars($base:$variant:update:events) 1
		set Vars($base:$variant:sort:events) $Defaults(sort:events)
		set Vars($base:$variant:sort:players) $Defaults(sort:players)
		set Vars($base:$variant:lastChange) [::scidb::db::get lastChange $base $variant]
		set Vars($base:$variant:games:lastId) -1
		set Vars($base:$variant:events:lastId) -1
		set Vars($base:$variant:players:lastId) -1
		set Vars($base:$variant:select) -1
		set Vars($base:$variant:selected:key) {}
		::eventtable::init $path.events $base $variant
		::playertable::init $path.info.players $base $variant
		::gametable::init $path.info.games $base $variant
		::scidb::view::search $base $variant $Vars($base:$variant:view) null player
	}
}


proc TableMinSize {pane minsize} {
	[winfo parent $pane] paneconfigure $pane -minsize [lindex $minsize 0 0]
}


proc SelectPlayer {path base variant view} {
	set index [::playertable::selectedPlayer $path.info.players $base $variant]
	[namespace parent]::selectPlayer $base $variant $index
}


namespace eval games {

proc Update {path id base variant {view -1} {index -1}} {
	variable [namespace parent]::${path}::Vars

	[namespace parent]::InitBase $path $base $variant

	if {$view == $Vars($base:$variant:view)} {
		after cancel $Vars(after:games)
		set Vars(after:games) [after idle [namespace code [list Update2 $id $path $base $variant]]]
	}
}


proc Update2 {id path base variant} {
	variable [namespace parent]::${path}::Vars

	if {$id <= $Vars($base:$variant:games:lastId)} { return }
	set Vars($base:$variant:games:lastId) $id
	set lastChange $Vars($base:$variant:lastChange)
	set Vars($base:$variant:lastChange) [::scidb::db::get lastChange $base $variant]
	set selected [::eventtable::selectedEvent $path.events $base $variant]
	set view $Vars($base:$variant:view)

	if {$selected >= 0 && $lastChange < $Vars($base:$variant:lastChange)} {
		if {[llength $Vars($base:$variant:selected:key)]} {
			set index [::scidb::db::find event $base $variant $Vars($base:$variant:selected:key)]
			if {$index >= 0} {
				set selected [::scidb::db::get lookupEvent $index $view $base $variant]
				[namespace parent]::events::Search $path $base $variant $view $selected
			} else {
				[namespace parent]::events::Reset $path $base $variant
			}
		}
	} else {
		set Vars($base:$variant:lastChange) $lastChange

		set n [::scidb::view::count games $base $variant $Vars($base:$variant:view)]
		after idle [list ::gametable::update $path.info.games $base $variant $n]

		set n [::scidb::view::count players $base $variant $Vars($base:$variant:view)]
		after idle [list ::playertable::update $path.info.players $base $variant $n]
		set Vars($base:$variant:players:lastId) $id
	}
}

} ;# namespace games


namespace eval events {

proc Reset {path base variant} {
	variable [namespace parent]::${path}::Vars

	::playertable::clear $path.info.players
	::gametable::clear $path.info.games
	::eventtable::select $path.events none
	set Vars($base:$variant:selected:key) {}
}


proc Search {path base variant view {selected -1}} {
	variable [namespace parent]::${path}::Vars

	::widget::busyCursor on
	::gametable::activate $path.info.games none
	::gametable::select $path.info.games none
	::playertable::activate $path.info.players none
	::playertable::select $path.info.players none

	if {$selected == -1} {
		set selected [::eventtable::selectedEvent $path.events $base $variant]
		if {$selected >= 0} {
			set index [::scidb::db::get eventIndex $selected $view $base $variant]
			set Vars($base:$variant:selected:key) [scidb::db::get eventKey $base $variant event $index]
		}
	}

	if {$selected >= 0} {
		# TODO: we do an exact search, but probably we like to seach only for player name!
		::scidb::view::search $base $variant $view null player [list event $selected]
		::playertable::scroll $path.info.players home
		::gametable::scroll $path.info.games home
	} else {
		Reset $path $base $variant
	}

	::widget::busyCursor off
}


proc Update {path id base variant {view -1} {index -1}} {
	variable ::scidb::clipbaseName
	variable [namespace parent]::${path}::Vars

	if {$base ne $clipbaseName && [string length [file extension $base]] == 0} { return }

	set Vars(base) "$base:$variant"
	after cancel $Vars(after:events)
	set Vars(after:events) [after idle [namespace code [list Update2 $id $path $base $variant]]]
}


proc Update2 {id path base variant} {
	variable [namespace parent]::${path}::Vars

	[namespace parent]::InitBase $path $base $variant
	if {$id <= $Vars($base:$variant:events:lastId)} { return }
	set Vars($base:$variant:events:lastId) $id
	set Vars($base:$variant:update:events) 1
	DoUpdate $path $base $variant
}


proc DoUpdate {path base variant} {
	variable [namespace parent]::${path}::Vars

	if {$Vars(active)} {
		if {[llength $Vars($base:$variant:sort:events)]} {
			::widget::busyCursor on
			set view $Vars($base:$variant:view)
			::scidb::db::sort event $base $variant $Vars($base:$variant:sort:events) $view
			::widget::busyCursor off
			set Vars($base:$variant:sort:events) {}
		}
		if {$Vars($base:$variant:update:events)} {
			set n [::scidb::db::count events $base $variant]
			after idle [list ::eventtable::update $path.events $base $variant $n]
			after idle [namespace code \
				[list [namespace parent]::games::Update2 \
					$Vars($base:$variant:events:lastId) $path $base $variant]]
			set Vars($base:$variant:update:events) 0
			if {$Vars($base:$variant:select) >= 0} {
				after idle \
					[list [namespace parent]::Select $path $base $variant $Vars($base:$variant:select)]
				set Vars($base:$variant:select) -1
			}
		}
	}
}

} ;# namespace events

namespace eval players {

proc Update {path id base variant {view -1} {index -1}} {
	variable [namespace parent]::${path}::Vars

	after cancel $Vars(after:players)
	set Vars(after:players) [after idle [namespace code [list Update2 $id $path $base $variant]]]
}


proc Update2 {id path base variant} {
	variable [namespace parent]::${path}::Vars

	[namespace parent]::InitBase $path $base $variant
	if {$id <= $Vars($base:$variant:players:lastId)} { return }
	set Vars($base:$variant:players:lastId) $id
	set Vars($base:$variant:update:players) 1
	DoUpdate $path $base $variant
}


proc DoUpdate {path base variant} {
	variable [namespace parent]::${path}::Vars

	if {$Vars(active)} {
		if {[llength $Vars($base:$variant:sort:players)]} {
			::widget::busyCursor on
			set view $Vars($base:$variant:view)
			::scidb::db::sort player $base $variant $Vars($base:$variant:sort:players) $view
			::widget::busyCursor off
			set Vars($base:$variant:sort:players) {}
		}
		if {$Vars($base:$variant:update:players)} {
			set n [::scidb::view::count players $base $variant $Vars($base:$variant:view)]
			after idle [list ::playertable::update $path.info.players $base $variant $n]
			set Vars($base:$variant:update:players) 0
		}
	}
}

} ;# namespace players


proc WriteOptions {chan} {
	variable Tables

	foreach table $Tables {
		puts $chan "::eventtable::setOptions $table.events {"
		::options::writeArray $chan [::eventtable::getOptions $table.events]
		puts $chan "}"
		puts $chan "::gametable::setOptions db:events {"
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
