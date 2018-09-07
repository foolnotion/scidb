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
# Copyright: (C) 2009-2018 Gregor Cramer
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
namespace eval player {
namespace eval mc {

set EditPlayer	"Edit Player"
set Score		"Score"

} ;# namespace mc


array set Defaults {
	sort:players	{}
	sort:events		{}
}

array set Prios { player 300 games 200 event 100 }

array set FrameOptions {
	player { -width 400 -height 100% -minwidth 200 -minheight 4u -expand both }
	games	 { -width 600 -height  66% -minwidth 200 -minheight 4u -expand both }
	event	 { -width 600 -height  34% -minwidth 200 -minheight 4u -expand both }
}

variable Layout {
	root { -shrink none -grow none } {
		panedwindow { -orient horz } {
			frame player %player%
			panedwindow { -orient vert } {
				frame games %games%
				frame event %event%
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

	if {$twm ni $Tables} { lappend Tables $twm }
	set Vars(after:games) {}
	set Vars(after:events) {}
	set Vars(after:players) {}
	set Vars(active) 0
	set Vars(base) ""

	::application::twm::make $twm player \
		[namespace current]::Prios \
		[array get FrameOptions] \
		$Layout \
		-makepane [namespace current]::MakeFrame \
		-buildpane [namespace current]::BuildFrame \
		-adjustcmd [namespace parent]::event::adjustFrame \
		;
	::application::twm::load $twm
	return $twm
}


proc activate {w flag} {
	set path $w.twm
	variable ${path}::Vars

	set Vars(active) $flag
	set base [::scidb::db::get name]
	set variant [::scidb::app::variant]
	set Vars($base:$variant:update:players) 1
	player::DoUpdate $path $base $variant

	if {[winfo toplevel $w] ne $w} {
		::toolbar::activate $Vars(frame:player) $flag
	}
}


proc overhang {parent} {
	set path $parent.twm
	variable ${path}::Vars

	return [::playertable::overhang $Vars(frame:player)]
}


proc linespace {parent} {
	set path $parent.twm
	variable ${path}::Vars

	return [::playertable::linespace $Vars(frame:player)]
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
	return [list $frame $nameVar $Prios($uid) no [expr {$uid ne "player"}] yes yes]
}


proc BuildFrame {twm frame uid width height} {
	variable ${twm}::Vars
	set Vars(frame:$uid) $frame
	set id [::application::twm::getId $twm]

	switch $uid {
		player {
			set columns {lastName firstName type sex rating1 federation title frequency}
			::playertable::build $frame [namespace code [list View $twm]] $columns \
				-selectcmd [list [namespace current]::player::Search $twm] \
				-id db:players:$id:$uid \
				-usefind 1 \
				;
			::scidb::db::subscribe playerList \
				[list [namespace current]::player::Update $twm] \
				[list [namespace current]::Close $twm] \
				;
		}
		games {
			set columns {white whiteElo black blackElo event result date length}
			::gamestable::build $frame [namespace code [list View $twm]] $columns -id db:players:$id:$uid
			::scidb::db::subscribe gameList [list [namespace current]::games::Update $twm]
		}
		event {
			set columns {event eventType eventDate eventMode timeMode eventCountry site}
			::eventtable::build $frame [namespace code [list View $twm]] $columns \
				-selectcmd [namespace code [list SelectEvent $twm]] \
				-id db:players:$id:$uid \
				;
			::scidb::db::subscribe eventList [list [namespace current]::event::Update $twm]
		}
	}
}


proc Select {path base variant index} {
	variable ${path}::Vars

	set position [::scidb::db::get lookupPlayer $index $Vars($base:$variant:view) $base $variant]
	::playertable::see $Vars(frame:player) $position
	update idletasks
	set row [::playertable::indexToRow $Vars(frame:player) $position]
	::playertable::setSelection $Vars(frame:player) $row
}


proc View {path base variant} {
	variable ${path}::Vars

	if {[string length $base] == 0} { return 0 }
	return $Vars($base:$variant:view)
}


proc Close {path base variant} {
	variable ${path}::Vars

	array unset Vars $base:$variant:*
	::playertable::forget $Vars(frame:player) $base $variant
	::eventtable::forget $Vars(frame:event) $base $variant
	::gamestable::forget $Vars(frame:games) $base $variant

	if {$Vars(base) eq "$base:$variant"} {
		::playertable::clear $Vars(frame:player)
		::eventtable::clear $Vars(frame:event)
		::gamestable::clear $Vars(frame:games)
	}
}


proc InitBase {path base variant} {
	variable ${path}::Vars
	variable Defaults

	if {[info exists Vars($base:$variant:initializing)]} { return }

	if {![info exists Vars($base:$variant:view)]} {
		set Vars($base:$variant:initializing) 1
		set Vars($base:$variant:view) \
			[::scidb::view::new $base $variant master slave slave slave slave slave]
		set Vars($base:$variant:update:players) 1
		set Vars($base:$variant:sort:players) $Defaults(sort:players)
		set Vars($base:$variant:sort:events) $Defaults(sort:events)
		set Vars($base:$variant:lastChange) [::scidb::db::get lastChange $base $variant]
		set Vars($base:$variant:players:lastId) -1
		set Vars($base:$variant:games:lastId) -1
		set Vars($base:$variant:events:lastId) -1
		set Vars($base:$variant:select) -1
		set Vars($base:$variant:selected:key) {}
		::playertable::init $Vars(frame:player) $base $variant
		::gamestable::init $Vars(frame:games) $base $variant
		::eventtable::init $Vars(frame:event) $base $variant
		::scidb::view::search $base $variant $Vars($base:$variant:view) null events
	}
}


proc SelectEvent {path base variant view} {
	variable ${path}::Vars

	set index [::eventtable::selectedEvent $Vars(frame:event) $base $variant]
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
	set selected [::playertable::selectedPlayer $Vars(frame:player) $base $variant]
	set view $Vars($base:$variant:view)

	if {$selected >= 0 && $lastChange < $Vars($base:$variant:lastChange)} {
		if {[llength $Vars($base:$variant:selected:key)]} {
			set index [::scidb::db::find player $base $variant $Vars($base:$variant:selected:key)]
			if {$index >= 0} {
				set selected [::scidb::db::get lookupPlayer $index $view $base $variant]
				[namespace parent]::player::Search $path $base $variant $view $selected
			} else {
				[namespace parent]::player::Reset $path $base $variant
			}
		}
	} else {
		set Vars($base:$variant:lastChange) $lastChange

		set n [::scidb::view::count games $base $variant $view]
		after idle [list ::gamestable::update $Vars(frame:games) $base $variant $n]

		set n [::scidb::view::count events $base $variant $view]
		after idle [list ::eventtable::update $Vars(frame:event) $base $variant $n]
		set Vars($base:$variant:events:lastId) $id
	}
}

} ;# namespace games


namespace eval player {

proc Reset {path base variant} {
	variable [namespace parent]::${path}::Vars

	::eventtable::clear $Vars(frame:event)
	::gamestable::clear $Vars(frame:games)
	::playertable::select $Vars(frame:player) none
	::playertable::activate $Vars(frame:player) none
	set Vars($base:$variant:selected:key) {}
}


proc Search {path base variant view {selected -1}} {
	variable [namespace parent]::${path}::Vars

	::widget::busyCursor on
	::gamestable::activate $Vars(frame:games) none
	::gamestable::select $Vars(frame:games) none
	::eventtable::activate $Vars(frame:event) none
	::eventtable::select $Vars(frame:event) none

	if {$selected == -1} {
		set selected [::playertable::selectedPlayer $Vars(frame:player) $base $variant]
		if {$selected >= 0} {
			set index [::scidb::db::get playerIndex $selected $view $base $variant]
			set Vars($base:$variant:selected:key) [scidb::db::get playerKey $base $variant $index]
		}
	}

	if {$selected >= 0} {
		# TODO: we do an exact search, but probably we like to seach only for player name!
		set Vars($base:$variant:lastChange) [::scidb::db::get lastChange $base $variant]
		::scidb::view::search $base $variant $view null events [list player $selected]
		::eventtable::scroll $Vars(frame:event) home
		::gamestable::scroll $Vars(frame:games) home
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
			after idle [list ::playertable::update $Vars(frame:player) $base $variant $n]
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

} ;# namespace player

namespace eval event {

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
			after idle [list ::eventtable::update $Vars(frame:event) $base $variant $n]
			set Vars($base:$variant:update:events) 0
		}
	}
}

} ;# namespace event


proc WriteTableOptions {chan variant {id "player"}} {
	variable TableOptions
	variable Tables

	if {$id ne "player"} { return }

	foreach table $Tables {
		set id [::application::twm::getId $table]
		foreach uid {player games event} {
			if {[info exists TableOptions($variant:$id:$uid)]} {
				puts $chan "::scrolledtable::setOptions db:players:$id:$uid {"
				::options::writeArray $chan $TableOptions($variant:$id:$uid)
				puts $chan "}"
			}
		}
	}
}
::options::hookTableWriter [namespace current]::WriteTableOptions


proc SaveOptions {twm variant} {
	variable TableOptions

	set id [::application::twm::getId $twm]
	foreach uid {player games event} {
		set TableOptions($variant:$id:$uid) [::scrolledtable::getOptions db:players:$id:$uid]
	}
}


proc RestoreOptions {twm variant} {
	variable TableOptions

	set id [::application::twm::getId $twm]
	foreach uid {player games event} {
		::scrolledtable::setOptions db:players:$id:$uid $TableOptions($variant:$id:$uid)
	}
}


proc CompareOptions {twm variant} {
	variable TableOptions

	set id [::application::twm::getId $twm]
	foreach uid {player games event} {
		if {[::scrolledtable::countOptions db:players:$id:$uid] > 0} {
			set lhs $TableOptions($variant:$id:$uid)
			set rhs [::scrolledtable::getOptions db:players:$id:$uid]
			if {![::arrayListEqual $lhs $rhs]} { return false }
		}
	}
	return true
}


::options::hookSaveOptions \
	[namespace current]::SaveOptions \
	[namespace current]::RestoreOptions \
	[namespace current]::CompareOptions \
	;

} ;# namespace player
} ;# namespace database
} ;# namespace application

# vi:set ts=3 sw=3:
