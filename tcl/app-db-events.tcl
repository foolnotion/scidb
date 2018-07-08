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

array set Prios { event 300 games 200 player 100 }

array set FrameOptions {
	event	 { -width 400 -height 640 -minwidth 200 -minheight 100 -expand both }
	games	 { -width 600 -height 310 -minwidth 200 -minheight 100 -expand both }
	player { -width 600 -height 310 -minwidth 200 -minheight 100 -expand both }
}

variable Layout {
	root { -shrink none -grow none } {
		panedwindow { -orient horz } {
			frame event %event%
			panedwindow { -orient vert } {
				frame games %games%
				frame player %player%
			}
		}
	}
}

variable Tables {}


proc build {parent} {
	variable Tables
	variable Layout
	variable FrameOptions

	set twm $parent.twm
	namespace eval [namespace current]::$twm {}
	variable ${twm}::Vars

	set Vars(after:games) {}
	set Vars(after:events) {}
	set Vars(after:players) {}
	set Vars(active) 0
	set Vars(base) ""

	::application::twm::make $twm event \
		[namespace current]::MakeFrame \
		[namespace current]::BuildFrame \
		[array get FrameOptions] \
		$Layout \
		;
	::application::twm::load $twm
	lappend Tables $twm
	return $twm
}


proc activate {w flag} {
	set path $w.twm
	variable ${path}::Vars

	set Vars(active) $flag
	set base [::scidb::db::get name]
	set variant [::scidb::app::variant]
	set Vars($base:$variant:update:events) 1
	events::DoUpdate $path $base $variant

	if {[winfo toplevel $w] ne $w} {
		::toolbar::activate $Vars(frame:event) $flag
	}
}


proc overhang {parent} {
	set path $parent.twm
	variable ${path}::Vars

	return [::eventtable::overhang $Vars(frame:event)]
}


proc linespace {parent} {
	set path $parent.twm
	variable ${path}::Vars

	return [::eventtable::linespace $Vars(frame:event)]
}


proc setActive {flag} {
	# no action
}


proc select {parent base variant index} {
	set path $parent.twm
	variable ${path}::Vars

	if {$Vars(active)} {
		Select $path $base $variant $index
	} else {
		set Vars($base:$variant:select) $index
	}
}


proc MakeFrame {twm parent type uid} {
	variable Prios

	set frame [tk::frame $parent.$uid -borderwidth 0 -takefocus 1]
	set nameVar ::application::twm::mc::Pane($uid)
	return [list $frame $nameVar $Prios($uid) [expr {$uid ne "event"}] yes yes]
}


proc BuildFrame {twm frame uid width height} {
	variable ${twm}::Vars
	set Vars(frame:$uid) $frame

	switch $uid {
		event {
			::eventtable::build $frame [namespace code [list View $twm]] {} \
				-selectcmd [list [namespace current]::events::Search $twm] \
				-usefind yes \
				-id db:events:$uid \
				;
			::scidb::db::subscribe eventList \
				[namespace current]::players::Update \
				[namespace current]::Close \
				$twm \
				;
		}
		games {
			set columns {white whiteElo black blackElo result date round length}
			::gametable::build $frame [namespace code [list View $twm]] $columns -id db:events:$uid
			::scidb::db::subscribe gameList [namespace current]::games::Update $twm
		}
		player {
			set columns {lastName firstName type sex rating1 federation title}
			::playertable::build $frame [namespace code [list View $twm]] $columns \
				-selectcmd [namespace code [list SelectPlayer $twm]] \
				-id db:events:$uid \
				;
			::scidb::db::subscribe playerList [namespace current]::events::Update $twm
		}
	}
}


proc Select {path base variant index} {
	variable ${path}::Vars

	set position [::scidb::db::get lookupEvent $index $Vars($base:$variant:view) $base $variant]
	::eventtable::see $Vars(frame:event) $position
	update idletasks
	set row [::eventtable::indexToRow $Vars(frame:event) $position]
	::eventtable::setSelection $Vars(frame:event) $row
}


proc Close {path base variant} {
	variable ${path}::Vars

	array unset Vars $base:$variant:*
	::eventtable::forget $Vars(frame:event) $base $variant
	::playertable::forget $Vars(frame:player) $base $variant
	::gametable::forget $Vars(frame:games) $base $variant

	if {$Vars(base) eq "$base:$variant"} {
		::eventtable::clear $Vars(frame:event)
		::playertable::clear $Vars(frame:player)
		::gametable::clear $Vars(frame:games)
	}
}


proc View {path base variant} {
	variable ${path}::Vars

	if {[string length $base] == 0} { return 0 }
	return $Vars($base:$variant:view)
}


proc InitBase {path base variant} {
	variable ${path}::Vars
	variable Defaults

	if {[info exists Vars($base:$variant:initializing)]} { return }

	if {![info exists Vars($base:$variant:view)]} {
		set Vars($base:$variant:initializing) 1
		set Vars($base:$variant:view) \
			[::scidb::view::new $base $variant slave slave master slave slave slave]
		set Vars($base:$variant:update:events) 1
		set Vars($base:$variant:sort:events) $Defaults(sort:events)
		set Vars($base:$variant:sort:players) $Defaults(sort:players)
		set Vars($base:$variant:lastChange) [::scidb::db::get lastChange $base $variant]
		set Vars($base:$variant:games:lastId) -1
		set Vars($base:$variant:events:lastId) -1
		set Vars($base:$variant:players:lastId) -1
		set Vars($base:$variant:select) -1
		set Vars($base:$variant:selected:key) {}

		::eventtable::init $Vars(frame:event) $base $variant
		::playertable::init $Vars(frame:player) $base $variant
		::gametable::init $Vars(frame:games) $base $variant
		::scidb::view::search $base $variant $Vars($base:$variant:view) null player
	}
}


proc SelectPlayer {path base variant view} {
	variable ${path}::Vars

	set index [::playertable::selectedPlayer $Vars(frame:player) $base $variant]
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
	set selected [::eventtable::selectedEvent $Vars(frame:event) $base $variant]
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
		after idle [list ::gametable::update $Vars(frame:games) $base $variant $n]

		set n [::scidb::view::count players $base $variant $Vars($base:$variant:view)]
		after idle [list ::playertable::update $Vars(frame:player) $base $variant $n]
		set Vars($base:$variant:players:lastId) $id
	}
}

} ;# namespace games


namespace eval events {

proc Reset {path base variant} {
	variable [namespace parent]::${path}::Vars

	::playertable::clear $Vars(frame:player)
	::gametable::clear $Vars(frame:games)
	::eventtable::select $Vars(frame:event) none
	set Vars($base:$variant:selected:key) {}
}


proc Search {path base variant view {selected -1}} {
	variable [namespace parent]::${path}::Vars

	::widget::busyCursor on
	::gametable::activate $Vars(frame:games) none
	::gametable::select $Vars(frame:games) none
	::playertable::activate $Vars(frame:player) none
	::playertable::select $Vars(frame:player) none

	if {$selected == -1} {
		set selected [::eventtable::selectedEvent $Vars(frame:event) $base $variant]
		if {$selected >= 0} {
			set index [::scidb::db::get eventIndex $selected $view $base $variant]
			set Vars($base:$variant:selected:key) [scidb::db::get eventKey $base $variant event $index]
		}
	}

	if {$selected >= 0} {
		# TODO: we do an exact search, but probably we like to seach only for player name!
		::scidb::view::search $base $variant $view null player [list event $selected]
		::playertable::scroll $Vars(frame:player) home
		::gametable::scroll $Vars(frame:games) home
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
			after idle [list ::eventtable::update $Vars(frame:event) $base $variant $n]
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
			after idle [list ::playertable::update $Vars(frame:player) $base $variant $n]
			set Vars($base:$variant:update:players) 0
		}
	}
}

} ;# namespace players


proc WriteTableOptions {chan {id "event"}} {
	variable Tables

	if {$id ne "event"} { return }

	foreach table $Tables {
		foreach attr {event games player} {
			puts $chan "::scrolledtable::setOptions db:events:$attr {"
			::options::writeArray $chan [::scrolledtable::getOptions db:events:$attr]
			puts $chan "}"
		}
	}
}
::options::hookTableWriter [namespace current]::WriteTableOptions

} ;# namespace events
} ;# namespace database
} ;# namespace application

# vi:set ts=3 sw=3:
