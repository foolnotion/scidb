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

::util::source annotator-list

namespace eval application {
namespace eval database {
namespace eval annotators {
namespace eval mc {

set F_Annotator	"Annotator"
set F_Frequency	"Frequency"

set Find				"Find"
set FindAnnotator	"Find annotator"
set NoAnnotator	"No annotator"

} ;# namespace mc

#		ID   		Adjustment	Min	Max	Width	Stretch	Removable	Elipsis	Color
#	-------------------------------------------------------------------------------------
set Columns {
	{ annotator		left		10		 0		18			1			0			1			{}	}
	{ frequency		right		 4		14		 6			0			0			1			{}	}
}

array set Defaults {
	sort 0
}

array set Prios { annotator 200 games 100 }

array set FrameOptions {
	annotator { -width 200 -height 640 -minwidth 200 -minheight 100 -expand both }
	games     { -width 800 -height 640 -minwidth 200 -minheight 100 -expand both }
}

variable Layout {
	root { -shrink none -grow none } {
		panedwindow { -orient horz } {
			frame annotator %annotator%
			frame games %games%
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
	set Vars(active) 0
	set Vars(base) ""

	::application::twm::make $twm annotator \
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
	set Vars($base:$variant:update) 1
	names::UpdateTable $path $base $variant

	if {[winfo toplevel $w] ne $w} {
		::toolbar::activate $Vars(frame:annotator) $flag
	}
}


proc overhang {parent} {
	set path $parent.twm
	variable ${path}::Vars

	return [::scrolledtable::overhang $Vars(frame:annotator)]
}


proc linespace {parent} {
	set path $parent.twm
	variable ${path}::Vars

	return [::scrolledtable::linespace $Vars(frame:annotator)]
}


proc setActive {flag} {
	# no action
}


proc MakeFrame {twm parent type uid} {
	variable Prios

	set frame [tk::frame $parent.$uid -borderwidth 0 -takefocus 1]
	set nameVar ::application::twm::mc::Pane($uid)
	return [list $frame $nameVar $Prios($uid) [expr {$uid ne "annotator"}] yes yes]
}


proc BuildFrame {twm frame uid width height} {
	variable ${twm}::Vars
	set Vars(frame:$uid) $frame
	set id [::application::twm::getId $twm]

	switch $uid {
		annotator {
			variable Columns

			set columns {}
			foreach col $Columns {
				lassign $col cid adjustment minwidth maxwidth width stretch removable ellipsis color

				set ivar [namespace current]::I_[string toupper $cid 0 0]
				set fvar [namespace current]::mc::F_[string toupper $cid 0 0]
				set tvar [namespace current]::mc::T_[string toupper $cid 0 0]
				if {![info exists $tvar]} { set tvar {} }
				if {![info exists $fvar]} { set fvar $tvar }
				if {![info exists $ivar]} { set ivar {} } else { set ivar [set $ivar] }

				set menu {}
				lappend menu [list command \
					-command [namespace code [list SortColumn $twm $cid ascending]] \
					-labelvar ::gametable::mc::SortAscending \
				]
				lappend menu [list command \
					-command [namespace code [list SortColumn $twm $cid descending]] \
					-labelvar ::gametable::mc::SortDescending \
				]
				lappend menu { separator }

				set opts {}
				lappend opts -justify $adjustment
				lappend opts -minwidth $minwidth
				lappend opts -maxwidth $maxwidth
				lappend opts -width $width
				lappend opts -stretch $stretch
				lappend opts -removable $removable
				lappend opts -ellipsis $ellipsis
				lappend opts -visible 1
				lappend opts -foreground $color
				lappend opts -menu $menu
				lappend opts -image $ivar
				lappend opts -textvar $fvar
				lappend opts -tooltipvar $tvar

				lappend columns $cid $opts
			}
			set table [::scrolledtable::build $frame $columns -id db:annotators:$id:$uid]
			::scidb::db::subscribe annotatorList \
				[list [namespace current]::names::Update $twm] \
				[list [namespace current]::Close $twm] \
				;
			bind $frame <<TableFill>>		[namespace code [list names::TableFill $twm %d]]
			bind $frame <<TableSelected>>	[namespace code [list names::TableSelected $twm %d]]
		}
		games {
			set columns {white whiteElo black blackElo event result site date acv}
			::gametable::build $frame [namespace code [list View $twm]] $columns -id db:annotators:$id:$uid
			::scidb::db::subscribe gameList \
				[list [namespace current]::games::Update $twm] \
				[list [namespace current]::Close $twm] \
				;
		}
	}
}


proc Close {path base variant} {
	variable ${path}::Vars

	array unset Vars $base:$variant:*
	::scrolledtable::forget $Vars(frame:annotator) $base $variant
	::gametable::forget $Vars(frame:games) $base $variant

	if {$Vars(base) eq "$base:$variant"} {
		::scrolledtable::clear $Vars(frame:annotator)
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
			[::scidb::view::new $base $variant slave slave slave master slave slave]
		set Vars($base:$variant:update) 1
		set Vars($base:$variant:sort) $Defaults(sort)
		set Vars($base:$variant:annotator) ""
		set Vars($base:$variant:after:games) {}
		set Vars($base:$variant:after:names) {}
		set Vars($base:$variant:after:names) {}
		set Vars($base:$variant:after:lastId) {}
		set Vars($base:$variant:lastChange) [::scidb::db::get lastChange $base $variant]
		set Vars($base:$variant:names:lastId) -1
		set Vars($base:$variant:games:lastId) -1
		::scidb::view::search $base $variant $Vars($base:$variant:view) null none
	}
}


namespace eval games {

proc Update {path id base variant {view -1} {index -1}} {
	variable ::scidb::clipbaseName
	variable [namespace parent]::${path}::Vars
	
	if {$base ne $clipbaseName && [string length [file extension $base]] == 0} { return }
	[namespace parent]::InitBase $path $base $variant

	if {$view == $Vars($base:$variant:view)} {
		after cancel $Vars($base:$variant:after:games)
		set Vars($base:$variant:after:games) \
			[after idle [namespace code [list Update2 $id $path $base $variant]]]
	}
}


proc Update2 {id path base variant} {
	variable [namespace parent]::${path}::Vars

	if {$id <= $Vars($base:$variant:games:lastId)} { return }
	set Vars($base:$variant:games:lastId) $id
	set lastChange $Vars($base:$variant:lastChange)
	set Vars($base:$variant:lastChange) [::scidb::db::get lastChange $base $variant]
	set view $Vars($base:$variant:view)

	if {[llength $Vars($base:$variant:annotator)] && $lastChange < $Vars($base:$variant:lastChange)} {
		if {[string length $Vars($base:$variant:annotator)]} {
			set selected [::scidb::db::find annotator $base $variant $Vars($base:$variant:annotator)]
			if {$selected >= 0} {
				[namespace parent]::names::TableSearch $path $base $variant $view
			} else {
				[namespace parent]::names::Reset $path $base $variant
			}
		}
	} else {
		set n [::scidb::view::count games $base $variant $view]
		after idle [list ::gametable::update $Vars(frame:games) $base $variant $n]
	}
}

} ;# namespace games


namespace eval names {

proc Reset {path base variant} {
	variable [namespace parent]::${path}::Vars

	::gametable::clear $Vars(frame:games)
	::scrolledtable::select $Vars(frame:annotator) none
	::scrolledtable::activate $Vars(frame:annotator) none
	set Vars($base:$variant:annotator) ""
}


proc UpdateTable {path base variant} {
	variable [namespace parent]::${path}::Vars
	variable [namespace parent]::Defaults

	if {$Vars(active)} {
		if {[llength $Vars($base:$variant:sort)]} {
			::widget::busyCursor on
			::scidb::db::sort annotator $base $variant $Vars($base:$variant:sort) $Vars($base:$variant:view)
			::widget::busyCursor off
			set Vars($base:$variant:sort) {}
		}
		if {$Vars($base:$variant:update)} {
			set n [::scidb::db::count annotators $base $variant]
			after cancel $Vars($base:$variant:after:names)
			after cancel $Vars($base:$variant:after:lastId)
			set Vars($base:$variant:after:names) [after idle [list \
				::scrolledtable::update $Vars(frame:annotator) $base $variant $n]]
			set Vars($base:$variant:after:lastId) [after idle [list \
				[namespace parent]::games::Update2 $Vars($base:$variant:names:lastId) $path $base $variant]]
			set Vars($base:$variant:update) 0
		}
	}
}


proc Update {path id base variant {view -1} {index -1}} {
	variable ::scidb::clipbaseName
	variable [namespace parent]::${path}::Vars

	if {$base ne $clipbaseName && [string length [file extension $base]] == 0} { return }

	set Vars(base) "$base:$variant"
	[namespace parent]::InitBase $path $base $variant
	after cancel $Vars($base:$variant:after:names)
	set Vars($base:$variant:after:names) \
		[after idle [namespace code [list Update2 $id $path $base $variant]]]
}


proc Update2 {id path base variant} {
	variable [namespace parent]::${path}::Vars

	if {$id <= $Vars($base:$variant:names:lastId)} { return }
	set Vars($base:$variant:names:lastId) $id
	set Vars($base:$variant:update) 1
	UpdateTable $path $base $variant
}


proc TableFill {path args} {
	variable [namespace parent]::${path}::Vars

	lassign [lindex $args 0] table base variant start first last columns
	if {![info exists Vars($base:$variant:view)]} { return }
	set view $Vars($base:$variant:view)
	set last [expr {min($last, [scidb::view::count annotators $base $variant $view] - $start)}]
	set state !deleted

	for {set i $first} {$i < $last} {incr i} {
		set index [expr {$start + $i}]
		set line [scidb::db::get annotator $index $view]
		set text {}
		set k -1
		foreach id $columns {
			set value [lindex $line [incr k]]
			switch $id {
				annotator {
					if {$k == 0 && [string length $value] == 0} {
						set value "([set [namespace parent]::mc::NoAnnotator])"
						set state deleted
					}
				}
				
				frequency {
					set value [::locale::formatNumber $value]
				}
			}
			lappend text $value
		}
		::table::insert $table $i $text
	}

	if {$first < $last} { ::table::setState $table 0 $state }
}


proc TableSelected {path index} {
	variable [namespace parent]::${path}::Vars

	::widget::busyCursor on
	set table $Vars(frame:annotator)
	set base [::scrolledtable::base $table]
	set variant [::scrolledtable::variant $table]
	set view $Vars($base:$variant:view)
	set annotator [scidb::db::get annotator $index $view]
	set Vars($base:$variant:annotator) [lindex $annotator 0]
	TableSearch $path $base $variant $view
	::widget::busyCursor off
}


proc TableSearch {path base variant view} {
	variable [namespace parent]::${path}::Vars

	::widget::busyCursor on
	::gametable::activate $Vars(frame:games) none
	::gametable::select $Vars(frame:games) none
	::gametable::scroll $Vars(frame:games) home
	::scidb::view::search $base $variant $view null none [list annotator $Vars($base:$variant:annotator)]
	::widget::busyCursor off
}

} ;# namespace names


proc SortColumn {path id dir} {
	variable ${path}::Vars

	::widget::busyCursor on
	set base [::scrolledtable::base $Vars(frame:annotator)]
	set variant [::scrolledtable::variant $Vars(frame:annotator)]
	set view $Vars($base:$variant:view)
	set see 0
	if {[string length $Vars($base:$variant:annotator)]} {
		set selection [::scrolledtable::selection $Vars(frame:annotator)]
		if {$selection >= 0 && [::scrolledtable::selectionIsVisible? $Vars(frame:annotator)]} { set see 1 }
	} else {
		set selection -1
	}
	switch $dir {
		reverse {
			::scidb::db::reverse annotator $base $variant $view
		}

		default {
			set options {}
			if {$dir eq "descending"} { lappend options -descending }
			set columnNo [::scrolledtable::columnNo $Vars(frame:annotator) $id]
			::scidb::db::sort annotator $base $variant $columnNo $view {*}$options
		}
	}
	if {$selection >= 0} {
		set selection \
			[::scidb::db::get annotatorIndex $Vars($base:$variant:annotator) $view $base $variant]
	}
	::widget::busyCursor off
	::scrolledtable::updateColumn $Vars(frame:annotator) $selection $see
}


proc Find {path mode name} {
	variable ${path}::Vars

	set base [::scidb::db::get name]
	set variant [::scidb::app::variant]
	set view $Vars($base:$variant:view)
	if {$mode eq "next"} {
		set lastIndex [::scrolledtable::active $Vars(frame:annotator)]
	} else {
		set lastIndex -1
	}
	set i [::scidb::view::find annotator $base $variant $view "$name*" $lastIndex]
	if {$i >= 0} {
		::scrolledtable::see $Vars(frame:annotator) $i
		::scrolledtable::activate $Vars(frame:annotator) $i
	}
}


proc WriteTableOptions {chan {id "annotator"}} {
	variable Tables

	if {$id ne "annotator"} { return }

	foreach table $Tables {
		set id [::application::twm::getId $table]
		foreach uid {annotator games} {
			if {[::scrolledtable::countOptions db:annotators:$id:$uid] > 0} {
				puts $chan "::scrolledtable::setOptions db:annotators:$id:$uid {"
				::options::writeArray $chan [::scrolledtable::getOptions db:annotators:$id:$uid]
				puts $chan "}"
			}
		}
	}
}
::options::hookTableWriter [namespace current]::WriteTableOptions


proc SaveOptions {twm variant} {
	variable TableOptions

	set id [::application::twm::getId $twm]
	foreach uid {annotator games} {
		set TableOptions($variant:$id:$uid) [::scrolledtable::getOptions db:annotators:$id:$uid]
	}
}


proc RestoreOptions {twm variant} {
	variable TableOptions

	set id [::application::twm::getId $twm]
	foreach uid {annotator games} {
		::scrolledtable::setOptions db:annotators:$id:$uid $TableOptions($variant:$id:$uid)
	}
}


proc CompareOptions {twm variant} {
	variable TableOptions

	set id [::application::twm::getId $twm]
	foreach uid {annotator games} {
		if {[::scrolledtable::countOptions db:annotators:$id:$uid] > 0} {
			set lhs $TableOptions($variant:$id:$uid)
			set rhs [::scrolledtable::getOptions db:annotators:$id:$uid]
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

} ;# namespace annotators
} ;# namespace database
} ;# namespace application

# vi:set ts=3 sw=3:
