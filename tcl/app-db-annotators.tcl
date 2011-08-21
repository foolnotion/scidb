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
			-labelvar ::gametable::mc::SortAscending]
		lappend menu [list command \
			-command [namespace code [list SortColumn $top $id descending]] \
			-labelvar ::gametable::mc::SortDescending]
		lappend menu [list command \
			-command [namespace code [list SortColumn $top $id reverse]] \
			-labelvar ::gametable::mc::ReverseOrder]
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
		[namespace current]::::names::TableUpdate \
		[namespace current]::Close \
		$top

	set columns {white whiteElo black blackElo event result date acv}
	::gametable::build $rt [namespace code [list View $rt]] $columns
	::scidb::db::subscribe gameList \
		[namespace current]::games::TableUpdate \
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

	$top add $lt
	$top add $rt
	$top paneconfigure $lt -sticky nsew -stretch middle
	$top paneconfigure $rt -sticky nsew -stretch always

	set tbFind [::toolbar::toolbar $lt \
		-id find \
		-hide 1 \
		-side bottom \
		-alignment left \
		-allow {top bottom} \
		-tooltipvar [namespace current]::mc::Find]
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
		-command [namespace code [list Find $top $cb]]
	::toolbar::add $tbFind button \
		-image $::icon::22x22::clear \
		-tooltipvar [namespace current]::mc::ClearEntries \
		-command [namespace code [list Clear $top $cb]]

	return $table
}


proc activate {w menu flag} {
	set path $w.top
	variable ${path}::Vars

	set Vars(active) $flag
	names::TableUpdate2 $path [::scidb::db::get name]
	::toolbar::activate $path.names $flag
}


proc Close {path base} {
	variable ${path}::Vars

	array unset Vars $base:*
	::scrolledtable::clear $path.names
	::scrolledtable::forget $path.names $base
	::gametable::clear $path.pairings
	::gametable::forget $path.pairings $base
}


proc View {pane base} {
	set path [winfo parent $pane]
	variable ${path}::Vars

	return $Vars($base:view)
}


proc TableMinSize {pane minsize} {
	[winfo parent $pane] paneconfigure $pane -minsize [lindex $minsize 0 0]
}


proc InitBase {path base} {
	variable ${path}::Vars
	variable Defaults

	if {[info exists Vars($base:initializing)]} { return }

	if {![info exists Vars($base:view)]} {
		set Vars($base:initializing) 1
		set Vars($base:view) [::scidb::view::new $base slave slave slave master]
		set Vars($base:update) 1
		set Vars($base:sort) $Defaults(sort)
		set Vars($base:annotator) {}
		set Vars($base:after:games) {}
		set Vars($base:after:names) {}
		set Vars($base:lastChange) [::scidb::db::get lastChange $base]
		::scidb::view::search $base $Vars($base:view) null none
	}
}


namespace eval games {

proc TableUpdate {path base {view -1} {index -1}} {
	variable [namespace parent]::${path}::Vars
	
	[namespace parent]::InitBase $path $base

	if {$view == $Vars($base:view)} {
		after cancel $Vars($base:after:games)
		set Vars($base:after:games) [after idle [namespace code [list GameTableUpdate2 $path $base]]]
	}
}


proc GameTableUpdate2 {path base} {
	variable [namespace parent]::${path}::Vars

	set lastChange $Vars($base:lastChange)
	set Vars($base:lastChange) [::scidb::db::get lastChange $base]

	if {[llength $Vars($base:annotator)] && $lastChange < $Vars($base:lastChange)} {
		[namespace parent]::names::TableSearch $path $base $Vars($base:view)
	} else {
		set n [::scidb::view::count games $base $Vars($base:view)]
		after idle [list ::gametable::update $path.pairings $base $n]
	}
}


proc TableOptions {path} {
	# TODO
}

} ;# namespace games


namespace eval names {

proc UpdateTable {path base} {
	variable [namespace parent]::${path}::Vars
	variable [namespace parent]::Defaults

	if {$Vars(active)} {
		if {[llength $Vars($base:sort)]} {
			::widget::busyCursor on
			::scidb::db::sort annotator $base $Vars($base:sort) $Vars($base:view)
			::widget::busyCursor off
			set Vars($base:sort) {}
		}
		if {$Vars($base:update)} {
			set n [::scidb::db::count annotators $base]
			after idle [list ::scrolledtable::update $path.names $base $n]
			after idle [list [namespace parent]::games::GameTableUpdate2 $path $base]
			set Vars($base:update) 0
		}
	} else {
		set Vars($base:update) 1
	}
}


proc TableUpdate {path base {view -1} {index -1}} {
	variable [namespace parent]::${path}::Vars

	[namespace parent]::InitBase $path $base
	after cancel $Vars($base:after:names)
	set Vars($base:after:names) [after idle [namespace code [list TableUpdate2 $path $base]]]
}


proc TableUpdate2 {path base} {
	variable [namespace parent]::${path}::Vars

	set Vars($base:update) 1
	UpdateTable $path $base
}


proc TableOptions {path} {
	# TODO
}


proc TableFill {path args} {
	variable [namespace parent]::${path}::Vars

	lassign [lindex $args 0] table base start first last columns
	if {![info exists Vars($base:view)]} { return }
	set view $Vars($base:view)
	set last [expr {min($last, [scidb::view::count annotators $base $view] - $start)}]

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
	set base [::scidb::db::get name]
	set view $Vars($base:view)
	set annotator [scidb::db::get annotator $index $view]
	set Vars($base:annotator) [lindex $annotator 0]
	TableSearch $path $base $view
	::widget::busyCursor off
}


proc TableSearch {path base view} {
	variable [namespace parent]::${path}::Vars

	::widget::busyCursor on
	::gametable::activate $path.pairings none
	::gametable::select $path.pairings none
	::scidb::view::search $base $view null none [list annotator $Vars($base:annotator)]
	::widget::busyCursor off
}

} ;# namespace names


proc SortColumn {path id dir} {
	variable ${path}::Vars

	::widget::busyCursor on
	set base [::scidb::db::get name]
	set view $Vars($base:view)
	set see 0
	if {[llength $Vars($base:annotator)]} {
		set selection [::scrolledtable::selection $path.names]
		if {$selection >= 0 && [::scrolledtable::selectionIsVisible? $path.names]} { set see 1 }
	} else {
		set selection -1
	}
	switch $dir {
		reverse {
			::scidb::db::reverse annotator $base $view
		}

		default {
			set options {}
			if {$dir eq "descending"} { lappend options -descending }
			::scidb::db::sort annotator $base [::scrolledtable::columnNo $path.names $id] $view {*}$options
		}
	}
	if {$selection >= 0} {
		set selection [::scidb::db::get annotatorIndex $Vars($base:annotator) $view]
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
	set i [::scidb::view::find annotator $base $Vars($base:view) $value]
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
