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
# Copyright: (C) 2012-2018 Gregor Cramer
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

array set Prios { site 200 event 100 }

array set FrameOptions {
	site  { -width 300 -height 640 -minwidth 200 -minheight 100 -expand both }
	event { -width 700 -height 640 -minwidth 200 -minheight 100 -expand both }
}

variable Layout {
	root { -shrink none -grow none } {
		panedwindow { -orient horz } {
			frame site %site%
			frame event %event%
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
	set Vars(after:sites) {}
	set Vars(after:events) {}
	set Vars(active) 0
	set Vars(base) ""

	::application::twm::make $twm site \
		[namespace current]::MakeFrame \
		[namespace current]::BuildFrame \
		[namespace current]::Prios \
		[array get FrameOptions] \
		$Layout \
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
	set Vars($base:$variant:update:sites) 1
	sites::DoUpdate $path $base $variant

	if {[winfo toplevel $w] ne $w} {
		::toolbar::activate $Vars(frame:site) $flag
	}
}


proc overhang {parent} {
	set path $parent.twm
	variable ${path}::Vars

	return [::sitetable::overhang $Vars(frame:site)]
}


proc linespace {parent} {
	set path $parent.twm
	variable ${path}::Vars

	return [::sitetable::linespace $Vars(frame:site)]
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
	return [list $frame $nameVar $Prios($uid) [expr {$uid ne "site"}] yes yes]
}


proc BuildFrame {twm frame uid width height} {
	variable ${twm}::Vars
	set Vars(frame:$uid) $frame
	set id [::application::twm::getId $twm]

	switch $uid {
		site {
			::sitetable::build $frame [namespace code [list View $twm]] {} \
				-selectcmd [list [namespace current]::sites::Search $twm] \
				-id db:sites:$id:$uid \
				-usefind 1 \
				;
			::scidb::db::subscribe siteList \
				[list [namespace current]::sites::Update $twm] \
				[list [namespace current]::Close $twm] \
				;
		}
		event {
			set columns {event eventType eventDate eventMode timeMode}
			::eventtable::build $frame [namespace code [list View $twm]] $columns \
				-selectcmd [namespace code [list SelectEvent $twm]] \
				-id db:sites:$id:$uid \
				;
			::scidb::db::subscribe eventList [list [namespace current]::events::Update $twm]
		}
	}
}


proc Select {path base variant index} {
	variable ${path}::Vars

	set position [::scidb::db::get lookupSite $index $Vars($base:$variant:view) $base $variant]
	::sitetable::see $Vars(frame:site) $position
	update idletasks
	set row [::qsitetable::indexToRow $Vars(frame:site) $position]
	::sitetable::setSelection $Vars(frame:site) $row
}


proc View {path base variant} {
	variable ${path}::Vars

	if {[string length $base] == 0} { return 0 }
	return $Vars($base:$variant:view)
}


proc Close {path base variant} {
	variable ${path}::Vars

	array unset Vars $base:$variant:*
	::sitetable::forget $Vars(frame:site) $base $variant
	::eventtable::forget $Vars(frame:event) $base $variant

	if {$Vars(base) eq "$base:$variant"} {
		::sitetable::clear $Vars(frame:site)
		::eventtable::clear $Vars(frame:event)
	}
}


proc InitBase {path base variant} {
	variable ${path}::Vars
	variable Defaults

	if {[info exists Vars($base:$variant:initializing)]} { return }

	if {![info exists Vars($base:$variant:view)]} {
		set Vars($base:$variant:initializing) 1
		set Vars($base:$variant:view) \
			[::scidb::view::new $base $variant slave master slave slave slave slave]
		set Vars($base:$variant:update:sites) 1
		set Vars($base:$variant:sort:sites) $Defaults(sort:sites)
		set Vars($base:$variant:sort:events) $Defaults(sort:events)
		set Vars($base:$variant:lastChange) [::scidb::db::get lastChange $base $variant]
		set Vars($base:$variant:sites:lastId) -1
		set Vars($base:$variant:events:lastId) -1
		set Vars($base:$variant:select) -1
		set Vars($base:$variant:selected:key) {}
		::sitetable::init $Vars(frame:site) $base $variant
		::eventtable::init $Vars(frame:event) $base $variant
		::scidb::view::search $base $variant $Vars($base:$variant:view) null events
	}
}


proc TableMinSize {pane minsize} {
	[winfo parent $pane] paneconfigure $pane -minsize [lindex $minsize 0 0]
}


proc SelectEvent {path base variant view} {
	set index [::eventtable::selectedEvent $Vars(frame:event) $base $variant]
	[namespace parent]::selectEvent $base $variant $index
}


namespace eval sites {

proc Reset {path base variant} {
	variable [namespace parent]::${path}::Vars

	::eventtable::clear $Vars(frame:event)
	::sitetable::select $Vars(frame:site) none
	::sitetable::activate $Vars(frame:event) none
	set Vars($base:$variant:selected:key) {}
}


proc Search {path base variant view {selected -1}} {
	variable [namespace parent]::${path}::Vars

	::widget::busyCursor on
	::eventtable::activate $Vars(frame:event) none
	::eventtable::select $Vars(frame:event) none
	set index -1

	if {$selected == -1} {
		set selected [::sitetable::selectedSite $Vars(frame:site) $base $variant]
		if {$selected >= 0} {
			set index [::scidb::db::get siteIndex $selected $view $base $variant]
			set Vars($base:$variant:selected:key) [scidb::db::get siteKey $base $variant site $index]
		}
	}

	if {$selected >= 0} {
		if {$index == -1} { set index [::scidb::db::get siteIndex $selected $view $base $variant] }
		::scidb::view::search $base $variant $view null events [list site $index]
		::eventtable::scroll $Vars(frame:event) home
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
			after idle [list ::sitetable::update $Vars(frame:site) $base $variant $n]
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
			after idle [list ::eventtable::update $Vars(frame:event) $base $variant $n]
			set Vars($base:$variant:update:events) 0
		}
	}
}

} ;# namespace events


proc WriteTableOptions {chan {id "site"}} {
	variable Tables

	if {$id ne "site"} { return }

	foreach table $Tables {
		set id [::application::twm::getId $table]
		foreach uid {site event} {
			if {[::scrolledtable::countOptions db:sites:$id:$uid] > 0} {
				puts $chan "::scrolledtable::setOptions db:sites:$id:$uid {"
				::options::writeArray $chan [::scrolledtable::getOptions db:sites:$id:$uid]
				puts $chan "}"
			}
		}
	}
}
::options::hookTableWriter [namespace current]::WriteTableOptions


proc SaveOptions {twm variant} {
	variable TableOptions

	set id [::application::twm::getId $twm]
	foreach uid {site event} {
		set TableOptions($variant:$id:$uid) [::scrolledtable::getOptions db:sites:$id:$uid]
	}
}


proc RestoreOptions {twm variant} {
	variable TableOptions

	set id [::application::twm::getId $twm]
	foreach uid {site event} {
		::scrolledtable::setOptions db:sites:$id:$uid $TableOptions($variant:$id:$uid)
	}
}


proc CompareOptions {twm variant} {
	variable TableOptions

	set id [::application::twm::getId $twm]
	foreach uid {site event} {
		if {[::scrolledtable::countOptions db:sites:$id:$uid] > 0} {
			set lhs $TableOptions($variant:$id:$uid)
			set rhs [::scrolledtable::getOptions db:sites:$id:$uid]
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

} ;# namespace sites
} ;# namespace database
} ;# namespace application

# vi:set ts=3 sw=3:
