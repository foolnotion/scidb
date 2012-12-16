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

::util::source player-list

namespace eval application {
namespace eval database {
namespace eval players {
namespace eval mc {

set EditPlayer	"Edit Player"
set Score		"Score"

} ;# namespace mc


array set Defaults {
	sort:players	{}
	sort:events		{}
}

variable Tables {}


proc build {parent} {
	variable Tables
#	variable ::icon::12x12::I_Federation

	set top [tk::panedwindow $parent.top \
		-orient horizontal \
		-opaqueresize true \
		-borderwidth 0]
	pack $top -fill both -expand yes
	lappend Tables $top

	set lt ${top}.players
	set rt ${top}.info

	set gl ${rt}.games
	set ev ${rt}.events

	namespace eval [namespace current]::$top {}
	variable ${top}::Vars

	set Vars(after:games) {}
	set Vars(after:events) {}
	set Vars(after:players) {}
	set Vars(active) 0

	set columns {lastName firstName type sex rating1 federation title frequency}
	::playertable::build $lt [namespace code [list View $top]] $columns \
		-selectcmd [list [namespace current]::players::Search $top] \
		-usefind 1 \
		;

	tk::panedwindow $rt -orient vertical -opaqueresize true -borderwidth 0
	set columns {white whiteElo black blackElo event result date length}
	::gametable::build $gl [namespace code [list View $top]] $columns
	set columns {event eventType eventDate eventMode timeMode eventCountry site}
	::eventtable::build $ev [namespace code [list View $top]] $columns \
		-selectcmd [namespace code [list SelectEvent $top]] \
		;

	::scidb::db::subscribe playerList \
		[namespace current]::players::Update \
		[namespace current]::Close \
		$top \
		;
	::scidb::db::subscribe gameList \
		[namespace current]::games::Update \
		$top \
		;
	::scidb::db::subscribe eventList \
		[namespace current]::events::Update \
		$top \
		;

	bind $rt <<TableMinSize>> [namespace code [list TableMinSize $rt %d]]
	bind $lt <<TableMinSize>> [namespace code [list TableMinSize $lt %d]]

	$top add $lt
	$top add $rt

	$rt add $gl
	$rt add $ev

	$top paneconfigure $lt -sticky nsew -stretch middle -minsize 420	;# XXX
	$top paneconfigure $rt -sticky nsew -stretch always

	$rt paneconfigure $gl -sticky nsew -stretch always
	$rt paneconfigure $ev -sticky nsew -stretch always

	return $top
}


proc activate {w flag} {
	set path $w.top
	variable ${path}::Vars

	set Vars(active) $flag
	set base [::scidb::db::get name]
	set variant [::scidb::app::variant]
	set Vars($base:$variant:update:players) 1
	players::DoUpdate $path $base $variant

	if {[winfo toplevel $w] ne $w} {
		::toolbar::activate $path.players $flag
	}
}


proc overhang {parent} {
	return [::playertable::overhang $parent.top.players]
}


proc linespace {parent} {
	return [::playertable::linespace $parent.top.players]
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

	set position [::scidb::db::get lookupPlayer $index $Vars($base:$variant:view) $base $variant]
	::playertable::see $path.players $position
	update idletasks
	set row [::playertable::indexToRow $path.players $position]
	::playertable::setSelection $path.players $row
}


proc View {path base variant} {
	variable ${path}::Vars
	return $Vars($base:$variant:view)
}


proc Close {path base variant} {
	variable ${path}::Vars

	array unset Vars $base:$variant:*
	::playertable::clear $path.players
	::playertable::forget $path.players $base $variant
	::eventtable::clear $path.info.events
	::eventtable::forget $path.info.events $base $variant
	::gametable::clear $path.info.games
	::gametable::forget $path.info.games $base $variant
}


proc InitBase {path base variant} {
	variable ${path}::Vars
	variable Defaults

	if {[info exists Vars($base:$variant:initializing)]} { return }

	if {![info exists Vars($base:$variant:view)]} {
		set Vars($base:$variant:initializing) 1
		set Vars($base:$variant:view) [::scidb::view::new $base $variant slave master slave slave slave]
		set Vars($base:$variant:update:players) 1
		set Vars($base:$variant:sort:players) $Defaults(sort:players)
		set Vars($base:$variant:sort:events) $Defaults(sort:events)
		set Vars($base:$variant:lastChange) [::scidb::db::get lastChange $base $variant]
		set Vars($base:$variant:players:lastId) -1
		set Vars($base:$variant:games:lastId) -1
		set Vars($base:$variant:events:lastId) -1
		set Vars($base:$variant:select) -1
		set Vars($base:$variant:selected:key) {}
		::playertable::init $path.players $base $variant
		::gametable::init $path.info.games $base $variant
		::eventtable::init $path.info.events $base $variant
		::scidb::view::search $base $variant $Vars($base:$variant:view) null events
	}
}


proc TableMinSize {pane minsize} {
	[winfo parent $pane] paneconfigure $pane -minsize [lindex $minsize 0 0]
}


proc SelectEvent {path base variant view} {
	set index [::eventtable::selectedEvent $path.info.events $base $variant]
	[namespace parent]::selectEvent $base $variant $index
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
	set selected [::playertable::selectedPlayer $path.players $base $variant]
	set view $Vars($base:$variant:view)

	if {$selected >= 0 && $lastChange < $Vars($base:$variant:lastChange)} {
		if {[llength $Vars($base:$variant:selected:key)]} {
			set index [::scidb::db::find player $base $variant $Vars($base:$variant:selected:key)]
			if {$index >= 0} {
				set selected [::scidb::db::get lookupPlayer $index $view $base $variant]
				[namespace parent]::players::Search $path $base $variant $view $selected
			} else {
				[namespace parent]::players::Reset $path $base $variant
			}
		}
	} else {
		set Vars($base:$variant:lastChange) $lastChange

		set n [::scidb::view::count games $base $variant $view]
		after idle [list ::gametable::update $path.info.games $base $variant $n]

		set n [::scidb::view::count events $base $variant $view]
		after idle [list ::eventtable::update $path.info.events $base $variant $n]
		set Vars($base:$variant:events:lastId) $id
	}
}

} ;# namespace games


namespace eval players {

proc Reset {path base variant} {
	variable [namespace parent]::${path}::Vars

	::eventtable::clear $path.info.events
	::gametable::clear $path.info.games
	::playertable::select $path.players none
	::playertable::activate $path.players none
	set Vars($base:$variant:selected:key) {}
}


proc Search {path base variant view {selected -1}} {
	variable [namespace parent]::${path}::Vars

	::widget::busyCursor on
	::gametable::activate $path.info.games none
	::gametable::select $path.info.games none
	::eventtable::activate $path.info.events none
	::eventtable::select $path.info.events none

	if {$selected == -1} {
		set selected [::playertable::selectedPlayer $path.players $base $variant]
		if {$selected >= 0} {
			set index [::scidb::db::get playerIndex $selected $view $base $variant]
			set Vars($base:$variant:selected:key) [scidb::db::get playerKey $base $variant $index]
		}
	}

	if {$selected >= 0} {
		# TODO: we do an exact search, but probably we like to seach only for player name!
		::scidb::view::search $base $variant $view null events [list player $selected]
		::eventtable::scroll $path.info.events home
		::gametable::scroll $path.info.games home
	} else {
		Reset $path $base $variant
	}

	::widget::busyCursor off
}


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
			set n [::scidb::db::count players $base $variant]
			after idle [list ::playertable::update $path.players $base $variant $n]
			after idle [namespace code [list [namespace parent]::games::Update2 \
				$Vars($base:$variant:players:lastId) $path $base $variant]]
			set Vars($base:$variant:update:players) 0
			if {$Vars($base:$variant:select) >= 0} {
				after idle \
					[list [namespace parent]::Select $path $base $variant $Vars($base:$variant:select)]
				set Vars($base:$variant:select) -1
			}
		}
	}
}

} ;# namespace players

namespace eval events {

proc Update {path id base variant {view -1} {index -1}} {
	variable [namespace parent]::${path}::Vars

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
			set n [::scidb::view::count events $base $variant $Vars($base:$variant:view)]
			after idle [list ::eventtable::update $path.info.events $base $variant $n]
			set Vars($base:$variant:update:events) 0
		}
	}
}

} ;# namespace events


proc WriteOptions {chan} {
	variable Tables

	foreach table $Tables {
		puts $chan "::playertable::setOptions $table.players {"
		::options::writeArray $chan [::playertable::getOptions $table.players]
		puts $chan "}"
		puts $chan "::gametable::setOptions $table.info.games {"
		::options::writeArray $chan [::gametable::getOptions $table.info.games]
		puts $chan "}"
		puts $chan "::eventtable::setOptions $table.info.events {"
		::options::writeArray $chan [::eventtable::getOptions $table.info.events]
		puts $chan "}"
	}
}

::options::hookWriter [namespace current]::WriteOptions

} ;# namespace players
} ;# namespace database
} ;# namespace application

# vi:set ts=3 sw=3:
