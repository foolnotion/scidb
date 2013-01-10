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

::util::source annotator-list

namespace eval application {
namespace eval database {
namespace eval annotators {
namespace eval mc {

set F_Annotator	"Annotator"
set F_Frequency	"Frequency"

set Find				"Find"
set FindAnnotator	"Find annotator"
set ClearEntries	"Clear entries"
set NotFound		"Not found."

} ;# namespace mc

#		ID   		Adjustment	Min	Max	Width	Stretch	Removable	Elipsis	Color
#	-------------------------------------------------------------------------------------
set Columns {
	{ annotator		left		10		0		18			1			0			1			{}	}
	{ frequency		right		 4		8		 5			0			0			1			{}	}
}

array set Defaults {
	sort 0
}

variable Tables {}
variable Find {}


proc build {parent} {
	variable ::gametable::Defaults
	variable Columns
	variable Tables
	variable Find

	set top [tk::panedwindow $parent.top \
		-orient horizontal \
		-opaqueresize true \
		-borderwidth 0]
	pack $top -fill both -expand yes
	lappend Tables $top

	set lt ${top}.names
	set rt ${top}.pairings

	set columns {}
	foreach col $Columns {
		lassign $col id adjustment minwidth maxwidth width stretch removable ellipsis color

		set ivar [namespace current]::I_[string toupper $id 0 0]
		set fvar [namespace current]::mc::F_[string toupper $id 0 0]
		set tvar [namespace current]::mc::T_[string toupper $id 0 0]
		if {![info exists $tvar]} { set tvar {} }
		if {![info exists $fvar]} { set fvar $tvar }
		if {![info exists $ivar]} { set ivar {} } else { set ivar [set $ivar] }

		set menu {}
		lappend menu [list command \
			-command [namespace code [list SortColumn $top $id ascending]] \
			-labelvar ::gametable::mc::SortAscending \
		]
		lappend menu [list command \
			-command [namespace code [list SortColumn $top $id descending]] \
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

		lappend columns $id $opts
	}
	set table [::scrolledtable::build $lt $columns]
	::scidb::db::subscribe annotatorList \
		[namespace current]::names::Update \
		[namespace current]::Close \
		$top

	set columns {white whiteElo black blackElo event result date acv}
	::gametable::build $rt [namespace code [list View $rt]] $columns
	::scidb::db::subscribe gameList \
		[namespace current]::games::Update \
		[namespace current]::Close \
		$top
	bind $rt <<TableMinSize>> [namespace code [list TableMinSize $rt %d]]
	bind $rt <<TableOptions>> [namespace code [list games::TableOptions $rt]]

	namespace eval [namespace current]::$top {}
	variable [namespace current]::${top}::Vars
	set Vars(find-current) {}
	set Vars(active) 0

	bind $lt <<TableMinSize>>	[namespace code [list TableMinSize $lt %d]]
	bind $lt <<TableFill>>		[namespace code [list names::TableFill $top %d]]
	bind $lt <<TableOptions>>	[namespace code [list names::TableOptions $top]]
	bind $lt <<TableSelected>>	[namespace code [list names::TableSelected $top %d]]

	$top add $lt -sticky nsew -stretch middle -width 260 ;# XXX
	$top add $rt -sticky nsew -stretch always

	set tbFind [::toolbar::toolbar $lt \
		-id annotators-find \
		-hide 1 \
		-side bottom \
		-alignment left \
		-allow {top bottom} \
		-tooltipvar [namespace current]::mc::Find \
	]
	::toolbar::add $tbFind label -float 0 -textvar [::mc::var [namespace current]::mc::Find ":"]
	set cb [::toolbar::add $tbFind ::ttk::combobox \
		-width 14 \
		-takefocus 1 \
		-values $Find \
		-textvariable [namespace current]::${top}::Vars(find-current)]
	bind $cb <Return> [namespace code [list Find $top $cb]]
	::toolbar::add $tbFind button \
		-image $::icon::22x22::enter \
		-tooltipvar [namespace current]::mc::FindAnnotator \
		-command [namespace code [list Find $top $cb] \
	]
	::toolbar::add $tbFind button \
		-image $::icon::22x22::clear \
		-tooltipvar [namespace current]::mc::ClearEntries \
		-command [namespace code [list Clear $top $cb] \
	]

	return $table
}


proc activate {w flag} {
	set path $w.top
	variable ${path}::Vars

	set Vars(active) $flag
	set base [::scidb::db::get name]
	set variant [::scidb::app::variant]
	set Vars($base:$variant:update) 1
	names::UpdateTable $path $base $variant

	if {[winfo toplevel $w] ne $w} {
		::toolbar::activate $path.names $flag
	}
}


proc overhang {parent} {
	return [::scrolledtable::overhang $parent.top.names]
}


proc linespace {parent} {
	return [::scrolledtable::linespace $parent.top.names]
}


proc Close {path base variant} {
	variable ${path}::Vars

	array unset Vars $base:$variant:*
	::scrolledtable::clear $path.names
	::scrolledtable::forget $path.names $base $variant
	::gametable::clear $path.pairings
	::gametable::forget $path.pairings $base $variant
}


proc View {pane base variant} {
	set path [winfo parent $pane]
	variable ${path}::Vars

	return $Vars($base:$variant:view)
}


proc TableMinSize {pane minsize} {
	[winfo parent $pane] paneconfigure $pane -minsize [lindex $minsize 0 0]
}


proc InitBase {path base variant} {
	variable ${path}::Vars
	variable Defaults

	if {[info exists Vars($base:$variant:initializing)]} { return }

	if {![info exists Vars($base:$variant:view)]} {
		set Vars($base:$variant:initializing) 1
		set Vars($base:$variant:view) [::scidb::view::new $base $variant slave slave slave slave master]
		set Vars($base:$variant:update) 1
		set Vars($base:$variant:sort) $Defaults(sort)
		set Vars($base:$variant:annotator) ""
		set Vars($base:$variant:after:games) {}
		set Vars($base:$variant:after:names) {}
		set Vars($base:$variant:lastChange) [::scidb::db::get lastChange $base $variant]
		set Vars($base:$variant:names:lastId) -1
		set Vars($base:$variant:games:lastId) -1
		::scidb::view::search $base $variant $Vars($base:$variant:view) null none
	}
}


namespace eval games {

proc Update {path id base variant {view -1} {index -1}} {
	variable [namespace parent]::${path}::Vars
	
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
		after idle [list ::gametable::update $path.pairings $base $variant $n]
	}
}


proc TableOptions {path} {
	# TODO
}

} ;# namespace games


namespace eval names {

proc Reset {path base variant} {
	variable [namespace parent]::${path}::Vars

	::gametable::clear $path.pairings
	::scrolledtable::select $path.names none
	::scrolledtable::activate none
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
			after idle [list ::scrolledtable::update $path.names $base $variant $n]
			after idle [list \
				[namespace parent]::games::Update2 $Vars($base:$variant:names:lastId) $path $base $variant]
			set Vars($base:$variant:update) 0
		}
	}
}


proc Update {path id base variant {view -1} {index -1}} {
	variable [namespace parent]::${path}::Vars

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


proc TableOptions {path} {
	# TODO
}


proc TableFill {path args} {
	variable [namespace parent]::${path}::Vars

	lassign [lindex $args 0] table base variant start first last columns
	if {![info exists Vars($base:$variant:view)]} { return }
	set view $Vars($base:$variant:view)
	set last [expr {min($last, [scidb::view::count annotators $base $variant $view] - $start)}]

	for {set i $first} {$i < $last} {incr i} {
		set index [expr {$start + $i}]
		set line [scidb::db::get annotator $index $view]
		set text {}
		set k -1
		foreach id $columns { lappend text [lindex $line [incr k]] }
		::table::insert $table $i $text
	}
}


proc TableSelected {path index} {
	variable [namespace parent]::${path}::Vars

	::widget::busyCursor on
	set table $path.names
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
	::gametable::activate $path.pairings none
	::gametable::select $path.pairings none
	::gametable::scroll $path.pairings home
	::scidb::view::search $base $variant $view null none [list annotator $Vars($base:$variant:annotator)]
	::widget::busyCursor off
}

} ;# namespace names


proc SortColumn {path id dir} {
	variable ${path}::Vars

	::widget::busyCursor on
	set base [::scrolledtable::base $path.names]
	set variant [::scrolledtable::variant $path.names]
	set view $Vars($base:$variant:view)
	set see 0
	if {[string length $Vars($base:$variant:annotator)]} {
		set selection [::scrolledtable::selection $path.names]
		if {$selection >= 0 && [::scrolledtable::selectionIsVisible? $path.names]} { set see 1 }
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
			set columnNo [::scrolledtable::columnNo $path.names $id]
			::scidb::db::sort annotator $base $variant $columnNo $view {*}$options
		}
	}
	if {$selection >= 0} {
		set selection \
			[::scidb::db::get annotatorIndex $Vars($base:$variant:annotator) $view $base $variant]
	}
	::widget::busyCursor off
	::scrolledtable::updateColumn $path.names $selection $see
}


proc Find {path combo} {
	variable ${path}::Vars
	variable Find

	set value $Vars(find-current)
	if {[string length $value] == 0} { return }
	set base [::scidb::db::get name]
	set variant [::scrolledtable::variant $path]
	set variant [::scidb::app::variant]
	set i [::scidb::view::find annotator $base $variant $Vars($base:$variant:view) $value]
	if {[string length $value] > 2} {
		lappend Find $value
		set Find [lsort -dictionary -increasing -unique $Find]
		::toolbar::childconfigure $combo -values $Find
	}
	if {$i >= 0} {
		::scrolledtable::see $path.names $i
		::scrolledtable::focus $path.names
	} else {
		::dialog::info -parent [::toolbar::lookupChild $combo] -message $mc::NotFound
	}
}


proc Clear {path combo} {
	variable ${path}::Vars
	variable Find

	set Find {}
	::toolbar::childconfigure $combo -values {}
	set Vars(find-current) {}
}


proc WriteOptions {chan} {
	variable Tables

#	::options::writeItem $chan [namespace current]::Defaults
	::options::writeList $chan [namespace current]::Find

	foreach table $Tables {
		foreach type {names pairings} {
			puts $chan "::scrolledtable::setOptions $table.$type {"
			::options::writeArray $chan [::scrolledtable::getOptions $table.$type]
			puts $chan "}"
		}
	}
}

::options::hookWriter [namespace current]::WriteOptions

} ;# namespace annotators
} ;# namespace database
} ;# namespace application

# vi:set ts=3 sw=3:
