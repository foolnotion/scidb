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
# Copyright: (C) 2012 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source site-list

namespace eval application {
namespace eval database {
namespace eval sites {

array set Defaults {
	sort:sites	{}
	sort:events	{}
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

	set lt ${top}.sites
	set rt ${top}.events

	namespace eval [namespace current]::$top {}
	variable ${top}::Vars

	set Vars(after:sites) {}
	set Vars(after:events) {}
	set Vars(active) 0

	::sitetable::build $lt [namespace code [list View $top]] {} \
		-selectcmd [list [namespace current]::sites::Search $top] \
		-usefind 1 \
		;

	set columns {event eventType eventDate eventMode timeMode}
	::eventtable::build $rt [namespace code [list View $top]] $columns \
		-selectcmd [namespace code [list SelectEvent $top]] \
		;

	::scidb::db::subscribe siteList \
		[namespace current]::sites::Update \
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

	$top add $lt -sticky nsew -stretch middle -width 320
	$top add $rt -sticky nsew -stretch always

	return $top
}


proc activate {w flag} {
	set path $w.top
	variable ${path}::Vars

	set Vars(active) $flag
	set base [::scidb::db::get name]
	set Vars($base:update:sites) 1
	sites::DoUpdate $path $base

	if {[winfo toplevel $w] ne $w} {
		::toolbar::activate $path.sites $flag
	}
}


proc overhang {parent} {
	return [::sitetable::overhang $parent.top.sites]
}


proc linespace {parent} {
	return [::sitetable::linespace $parent.top.sites]
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

	set position [::scidb::db::get lookupSite $index $Vars($base:view) $base]
	::sitetable::see $path.sites $position
	update idletasks
	set row [::qsitetable::indexToRow $path.sites $position]
	::sitetable::setSelection $path.sites $row
}


proc View {path base} {
	variable ${path}::Vars
	return $Vars($base:view)
}


proc Close {path base} {
	variable ${path}::Vars

	array unset Vars $base:*
	::sitetable::clear $path.sites
	::sitetable::forget $path.sites $base
	::eventtable::clear $path.events
	::eventtable::forget $path.events $base
}


proc InitBase {path base} {
	variable ${path}::Vars
	variable Defaults

	if {[info exists Vars($base:initializing)]} { return }

	if {![info exists Vars($base:view)]} {
		set Vars($base:initializing) 1
		set Vars($base:view) [::scidb::view::new $base slave slave slave master slave]
		set Vars($base:update:sites) 1
		set Vars($base:sort:sites) $Defaults(sort:sites)
		set Vars($base:sort:events) $Defaults(sort:events)
		set Vars($base:lastChange) [::scidb::db::get lastChange $base]
		set Vars($base:sites:lastId) -1
		set Vars($base:events:lastId) -1
		set Vars($base:select) -1
		set Vars($base:selected:key) {}
		::sitetable::init $path.sites $base
		::eventtable::init $path.events $base
		::scidb::view::search $base $Vars($base:view) null events
	}
}


proc TableMinSize {pane minsize} {
	[winfo parent $pane] paneconfigure $pane -minsize [lindex $minsize 0 0]
}


proc SelectEvent {path base view} {
	[namespace parent]::selectEvent $base [::eventtable::selectedEvent $path.events $base]
}


namespace eval sites {

proc Reset {path base} {
	variable [namespace parent]::${path}::Vars

	::eventtable::clear $path.events
	::sitetable::select $path.sites none
	::sitetable::activate $path.events none
	set Vars($base:selected:key) {}
}


proc Search {path base view {selected -1}} {
	variable [namespace parent]::${path}::Vars

	::widget::busyCursor on
	::eventtable::activate $path.events none
	::eventtable::select $path.events none
	set index -1

	if {$selected == -1} {
		set selected [::sitetable::selectedSite $path.sites $base]
		if {$selected >= 0} {
			set index [::scidb::db::get siteIndex $selected $view $base]
			set Vars($base:selected:key) [scidb::db::get siteKey $base site $index]
		}
	}

	if {$selected >= 0} {
		if {$index == -1} { set index [::scidb::db::get siteIndex $selected $view $base] }
		::scidb::view::search $base $view null events [list site $index]
		::eventtable::scroll $path.events home
	} else {
		Reset $path $base
	}

	::widget::busyCursor off
}


proc Update {path id base {view -1} {index -1}} {
	variable [namespace parent]::${path}::Vars

	after cancel $Vars(after:sites)
	set Vars(after:sites) [after idle [namespace code [list Update2 $id $path $base]]]
}


proc Update2 {id path base} {
	variable [namespace parent]::${path}::Vars

	[namespace parent]::InitBase $path $base
	if {$id <= $Vars($base:sites:lastId)} { return }
	set Vars($base:sites:lastId) $id
	set Vars($base:update:sites) 1
	DoUpdate $path $base
}


proc DoUpdate {path base} {
	variable [namespace parent]::${path}::Vars

	if {$Vars(active)} {
		if {[llength $Vars($base:sort:sites)]} {
			::widget::busyCursor on
			::scidb::db::sort site $base $Vars($base:sort:sites) $Vars($base:view)
			::widget::busyCursor off
			set Vars($base:sort:sites) {}
		}
		if {$Vars($base:update:sites)} {
			set n [::scidb::db::count sites $base]
			after idle [list ::sitetable::update $path.sites $base $n]
			after idle [namespace code \
				[list [namespace parent]::events::Update2 $Vars($base:sites:lastId) $path $base]]
			set Vars($base:update:sites) 0
			if {$Vars($base:select) >= 0} {
				after idle [list [namespace parent]::Select $path $base $Vars($base:select)]
				set Vars($base:select) -1
			}
		}
	}
}

} ;# namespace sites

namespace eval games {

proc Update {path id base {view -1} {index -1}} {
	variable [namespace parent]::${path}::Vars

	[namespace parent]::InitBase $path $base

	if {$view == $Vars($base:view)} {
		set n [::scidb::view::count events $base $view]
		after idle [list ::eventtable::update $path.events $base $n]
		set Vars($base:events:lastId) $id
	}
}

} ;# namespace games

namespace eval events {

proc Update {path id base {view -1} {index -1}} {
	variable [namespace parent]::${path}::Vars

	after cancel $Vars(after:events)
	set Vars(after:events) [after idle [namespace code [list Update2 $id $path $base]]]
}


proc Update2 {id path base} {
	variable [namespace parent]::${path}::Vars

	if {$id <= $Vars($base:events:lastId)} { return }
	set Vars($base:events:lastId) $id
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
			set n [::scidb::view::count events $base $Vars($base:view)]
			after idle [list ::eventtable::update $path.events $base $n]
			set Vars($base:update:events) 0
		}
	}
}

} ;# namespace events


proc WriteOptions {chan} {
	variable Tables

	foreach table $Tables {
		puts $chan "::sitetable::setOptions $table.sites {"
		::options::writeArray $chan [::sitetable::getOptions $table.sites]
		puts $chan "}"
		puts $chan "::eventtable::setOptions $table.events {"
		::options::writeArray $chan [::eventtable::getOptions $table.events]
		puts $chan "}"
	}
}

::options::hookWriter [namespace current]::WriteOptions

} ;# namespace sites
} ;# namespace database
} ;# namespace application

# vi:set ts=3 sw=3:
