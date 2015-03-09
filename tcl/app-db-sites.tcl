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
# Copyright: (C) 2012-2013 Gregor Cramer
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
	set Vars(base) ""

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
	set variant [::scidb::app::variant]
	set Vars($base:$variant:update:sites) 1
	sites::DoUpdate $path $base $variant

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


proc setActive {} {
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

	set position [::scidb::db::get lookupSite $index $Vars($base:$variant:view) $base $variant]
	::sitetable::see $path.sites $position
	update idletasks
	set row [::qsitetable::indexToRow $path.sites $position]
	::sitetable::setSelection $path.sites $row
}


proc View {path base variant} {
	variable ${path}::Vars
	return $Vars($base:$variant:view)
}


proc Close {path base variant} {
	variable ${path}::Vars

	array unset Vars $base:$variant:*
	::sitetable::forget $path.sites $base $variant
	::eventtable::forget $path.events $base $variant

	if {$Vars(base) eq "$base:$variant"} {
		::sitetable::clear $path.sites
		::eventtable::clear $path.events
	}
}


proc InitBase {path base variant} {
	variable ${path}::Vars
	variable Defaults

	if {[info exists Vars($base:$variant:initializing)]} { return }

	if {![info exists Vars($base:$variant:view)]} {
		set Vars($base:$variant:initializing) 1
		set Vars($base:$variant:view) [::scidb::view::new $base $variant slave slave slave master slave]
		set Vars($base:$variant:update:sites) 1
		set Vars($base:$variant:sort:sites) $Defaults(sort:sites)
		set Vars($base:$variant:sort:events) $Defaults(sort:events)
		set Vars($base:$variant:lastChange) [::scidb::db::get lastChange $base $variant]
		set Vars($base:$variant:sites:lastId) -1
		set Vars($base:$variant:events:lastId) -1
		set Vars($base:$variant:select) -1
		set Vars($base:$variant:selected:key) {}
		::sitetable::init $path.sites $base $variant
		::eventtable::init $path.events $base $variant
		::scidb::view::search $base $variant $Vars($base:$variant:view) null events
	}
}


proc TableMinSize {pane minsize} {
	[winfo parent $pane] paneconfigure $pane -minsize [lindex $minsize 0 0]
}


proc SelectEvent {path base variant view} {
	set index [::eventtable::selectedEvent $path.events $base $variant]
	[namespace parent]::selectEvent $base $variant $index
}


namespace eval sites {

proc Reset {path base variant} {
	variable [namespace parent]::${path}::Vars

	::eventtable::clear $path.events
	::sitetable::select $path.sites none
	::sitetable::activate $path.events none
	set Vars($base:$variant:selected:key) {}
}


proc Search {path base variant view {selected -1}} {
	variable [namespace parent]::${path}::Vars

	::widget::busyCursor on
	::eventtable::activate $path.events none
	::eventtable::select $path.events none
	set index -1

	if {$selected == -1} {
		set selected [::sitetable::selectedSite $path.sites $base $variant]
		if {$selected >= 0} {
			set index [::scidb::db::get siteIndex $selected $view $base $variant]
			set Vars($base:$variant:selected:key) [scidb::db::get siteKey $base $variant site $index]
		}
	}

	if {$selected >= 0} {
		if {$index == -1} { set index [::scidb::db::get siteIndex $selected $view $base $variant] }
		::scidb::view::search $base $variant $view null events [list site $index]
		::eventtable::scroll $path.events home
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
	after cancel $Vars(after:sites)
	set Vars(after:sites) [after idle [namespace code [list Update2 $id $path $base $variant]]]
}


proc Update2 {id path base variant} {
	variable [namespace parent]::${path}::Vars

	[namespace parent]::InitBase $path $base $variant
	if {$id <= $Vars($base:$variant:sites:lastId)} { return }
	set Vars($base:$variant:sites:lastId) $id
	set Vars($base:$variant:update:sites) 1
	DoUpdate $path $base $variant
}


proc DoUpdate {path base variant} {
	variable [namespace parent]::${path}::Vars

	if {$Vars(active)} {
		if {[llength $Vars($base:$variant:sort:sites)]} {
			::widget::busyCursor on
			set view $Vars($base:$variant:view)
			::scidb::db::sort site $base $variant $Vars($base:$variant:sort:sites) $view
			::widget::busyCursor off
			set Vars($base:$variant:sort:sites) {}
		}
		if {$Vars($base:$variant:update:sites)} {
			set n [::scidb::db::count sites $base $variant]
			after idle [list ::sitetable::update $path.sites $base $variant $n]
			after idle [namespace code [list [namespace parent]::events::Update2 \
				$Vars($base:$variant:sites:lastId) $path $base $variant]]
			set Vars($base:$variant:update:sites) 0
			if {$Vars($base:$variant:select) >= 0} {
				after idle \
					[list [namespace parent]::Select $path $base $variant $Vars($base:$variant:select)]
				set Vars($base:$variant:select) -1
			}
		}
	}
}

} ;# namespace sites

namespace eval games {

proc Update {path id base variant {view -1} {index -1}} {
	variable [namespace parent]::${path}::Vars

	[namespace parent]::InitBase $path $base $variant

	if {$view == $Vars($base:$variant:view)} {
		set n [::scidb::view::count events $base $variant $view]
		after idle [list ::eventtable::update $path.events $base $variant $n]
		set Vars($base:$variant:events:lastId) $id
	}
}

} ;# namespace games

namespace eval events {

proc Update {path id base variant {view -1} {index -1}} {
	variable [namespace parent]::${path}::Vars

	after cancel $Vars(after:events)
	set Vars(after:events) [after idle [namespace code [list Update2 $id $path $base $variant]]]
}


proc Update2 {id path base variant} {
	variable [namespace parent]::${path}::Vars

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
			after idle [list ::eventtable::update $path.events $base $variant $n]
			set Vars($base:$variant:update:events) 0
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
