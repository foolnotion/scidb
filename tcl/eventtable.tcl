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
# Copyright: (C) 2011 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

namespace eval eventtable {

#		ID   		Adjustment	Min	Max	Width	Stretch	Removable	Elipsis	Color
#	----------------------------------------------------------------------------------
set Columns {
	{ event			left		10		 0		14			1			0			1			{}			}
	{ eventType		left		 2		 8		 6			0			1			0			{}			}
	{ eventDate		left		 5		10		10			0			1			0			darkred	}
	{ eventMode		center	 0		 0		14px		0			1			1			{}			}
	{ timeMode		center	 0		 0		14px		0			1			1			{}			}
	{ eventCountry	center	 0		 0		 5			0			1			0			{}			}
	{ site			left		10		 0		14			1			1			1			{}			}
	{ frequency		right		 4		 8		 5			0			1			1			{}			}
}

variable columns {}
foreach col $Columns { lappend columns [lindex $col 0] }

array set Defaults {
	sort				{}
	country-code	flags
	eventtype-icon	1
}

array set Options {}


proc build {path getViewCmd {visibleColumns {}} {args {}}} {
	variable Columns
	variable Defaults
	variable Options
	variable columns

	namespace eval [namespace current]::$path {}
	variable [namespace current]::${path}::Vars

	array set Vars {
		columns		{}
		selectcmd	{}
	}

	if {[array size Options] == 0} {
		array set Options [array get Defaults]
	}

	if {[llength $visibleColumns] == 0} { set visibleColumns $columns }

	set columns {}
	foreach column $Columns {
		lassign $column id adjustment minwidth maxwidth width stretch removable ellipsis color
		set menu {}

		switch $id {
			eventCountry {
				foreach {labelvar value} {Flags flags PGN_CountryCode PGN ISO_CountryCode ISO} {
					lappend menu [list radiobutton \
						-command [namespace code [list Refresh $path]] \
						-labelvar ::gametable::mc::$labelvar \
						-variable [namespace current]::Options(country-code) \
						-value $value \
					]
				}
				lappend menu { separator }
			}

			eventType {
				lappend menu [list radiobutton \
					-command [namespace code [list RefreshEventType $path]] \
					-labelvar ::gametable::mc::Icons \
					-variable [namespace current]::Options(eventtype-icon) \
					-value 1 \
				]
				lappend menu [list radiobutton \
					-command [namespace code [list RefreshEventType $path]] \
					-labelvar ::gametable::mc::Abbreviations \
					-variable [namespace current]::Options(eventtype-icon) \
					-value 0 \
				]
				lappend menu { separator }
			}
		}

		lappend menu [list command \
			-command [namespace code [list SortColumn $path $id ascending]] \
			-labelvar ::gametable::mc::SortAscending \
		]
		lappend menu [list command \
			-command [namespace code [list SortColumn $path $id descending]] \
			-labelvar ::gametable::mc::SortDescending \
		]
		lappend menu [list command \
			-command [namespace code [list SortColumn $path $id reverse]] \
			-labelvar ::gametable::mc::ReverseOrder \
		]
		lappend menu { separator }

		set ivar [namespace current]::icon::12x12::I_[string toupper $id 0 0]
		if {$id eq "frequency"} {
			set fvar ::playertable::mc::F_Frequency
			set tvar ::playertable::mc::T_Frequency
		} else {
			set fvar ::gametable::mc::F_[string toupper $id 0 0]
			set tvar ::gametable::mc::T_[string toupper $id 0 0]
		}
		if {![info exists $tvar]} { set tvar {} }
		if {![info exists $fvar]} { set fvar $tvar }
		if {![info exists $ivar]} { set ivar {} } else { set ivar [set $ivar] }
		if {$id in $visibleColumns} { set visible 1 } else { set visible 0 }

		set opts {}
		lappend opts -justify $adjustment
		lappend opts -minwidth $minwidth
		lappend opts -maxwidth $maxwidth
		lappend opts -width $width
		lappend opts -stretch $stretch
		lappend opts -removable $removable
		lappend opts -ellipsis $ellipsis
		lappend opts -visible $visible
		lappend opts -foreground $color
		lappend opts -menu $menu
		lappend opts -image $ivar
		lappend opts -textvar $fvar
		lappend opts -tooltipvar $tvar

		lappend columns $id $opts
		lappend Vars(columns) $id
	}

	array set options $args
	if {[info exists options(-selectcmd)]} {
		set Vars(selectcmd) $options(-selectcmd)
		unset options(-selectcmd)
		set args [array get options]
	}
	lappend args -popupcmd [namespace code PopupMenu]
	set Vars(table) [::scrolledtable::build $path $columns {*}$args]
	RefreshEventType $path

	::bind $path <<TableFill>>			[namespace code [list TableFill $path %d]]
	::bind $path <<TableSelected>>	[namespace code [list TableSelected $path %d]]
	::bind $path <<TableVisit>>		[namespace code [list TableVisit $path %d]]
	::bind $path <<Language>>  		[namespace code [list BindAccelerators $path]]

#	bind $path <ButtonPress-2>			[namespace code [list ShowMoves $path %x %y]]
#	bind $path <ButtonRelease-2>		[namespace code [list hideMoves $path]]
#	bind $path <ButtonPress-3>			+[namespace code [list hideMoves $path]]

	set Vars(viewcmd) $getViewCmd
	BindAccelerators $path

	return $Vars(table)
}


proc init {path base} {
	variable ${path}::Vars
	set Vars($base:index) -1
}


proc forget {path base} {
	::scrolledtable::forget $path $base
	unset [namespace current]::${path}::Vars($base:index)
}


proc columnIndex {name} {
	variable columns
	return [lsearch -exact $columns $name]
}


proc column {info name} {
	variable columns
	return [lindex $info [lsearch -exact $columns $name]]
}


proc clear {path} {
	::scrolledtable::clear $path
}


proc clearColumn {path id} {
	::scrolledtable::clearColumn $path $id
}


proc fill {path first last} {
	::scrolledtable::fill $path $first $last
}


proc update {path base size} {
	::scrolledtable::update $path $base $size
}


proc changeLayout {path dir} {
	return [::scrolledtable::changeLayout $path $dir]
}


proc overhang {path} {
	return [::scrolledtable::overhang $path]
}


proc borderwidth {path} {
	return [::scrolledtable::borderwidth $path]
}


proc selectedEvent {path base} {
	variable ${path}::Vars
	return $Vars($base:index) 
}


proc getOptions {path} {
	return [::scrolledtable::getOptions $path]
}


proc setOptions {path options} {
	::scrolledtable::setOptions $path $options
}


proc scroll {path position} {
	::scrolledtable::scroll $path $position
}


proc activate {path row} {
	::scrolledtable::activate $path $row
}


proc select {path row} {
	::scrolledtable::select $path $row
}


proc setSelection {path row} {
	::scrolledtable::setSelection $path $row
}


proc index {path} {
	return [::scrolledtable::index $path]
}


proc indexToRow {path index} {
	return [::scrolledtable::indexToRow $path $index]
}


proc at {path y} {
	return [::scrolledtable::at $path $y]
}


proc focus {path} {
	::scrolledtable::focus $path
}


proc bind {path sequence script} {
	::scrolledtable::bind $path $sequence $script
}


proc see {path position} {
	::scrolledtable::see $path $position
}


proc Refresh {path} {
	::scrolledtable::refresh $path
}


proc RefreshEventType {path} {
	variable Options

	if {$Options(eventtype-icon)} {
		set justification center
	} else {
		set justification left
	}

	::scrolledtable::clearColumn $path eventType
	::scrolledtable::setColumnJustification $path eventType $justification
	Refresh $path
}


proc TableSelected {path index} {
	variable ${path}::Vars

	if {[llength $Vars(selectcmd)]} {
		set base [::scrolledtable::base $path]
		set view [{*}$Vars(viewcmd) $base]
		set Vars($base:index) [::scidb::db::get eventIndex $index $view $base]
		{*}$Vars(selectcmd) $base $view
	}
}


proc TableFill {path args} {
	variable ${path}::Vars
	variable Options

	lassign [lindex $args 0] table base start first last columns

	set codec [::scidb::db::get codec $base]
	set view [{*}$Vars(viewcmd) $base]
	set last [expr {min($last, [scidb::view::count events $base $view] - $start)}]

	if {![info exists Vars($base:index)]} {
		set Vars($base:index) -1
	}

	for {set i $first} {$i < $last} {incr i} {
		set index [expr {$start + $i}]
		set line [::scidb::db::get eventInfo $index $view $base]
		set text {}
		set k -1

		foreach id $columns {
			if {[::table::visible? $table $id]} {
				set item [lindex $line [incr k]]

				switch $id {
					eventCountry {
						if {$codec eq "si3" || $codec eq "si4"} {
							lappend text $::mc::NotAvailable
						} elseif {[string length $item] == 0} {
							if {$Options(country-code) eq "flags"} {
								lappend text [list @ {}]
							} else {
								lappend text {}
							}
						} else {
							switch $Options(country-code) {
								flags	{ lappend text [list @ $::country::icon::flag($item)] }
								PGN	{ lappend text $item }
								ISO	{ lappend text [::country::iso $item] }
							}
						}
					}

					eventType {
						if {[llength $item]} {
							if {$Options(eventtype-icon)} {
								lappend text [list @ $::eventtypebox::icon::12x12::Type($item)]
							} else {
								lappend text $::gametable::mc::EventType($item)
							}
						} elseif {$codec eq "si3" || $codec eq "si4"} {
							lappend text $::mc::NotAvailable
						} else {
							lappend text {}
						}
					}

					eventMode {
						if {[string length $item] == 0} {
							lappend text [list @ $::icon::12x12::none]
						} else {
							lappend text [list @ [set ::eventmodebox::icon::12x12::$item]]
						}
					}

					timeMode {
						if {[string length $item] == 0} {
							lappend text [list @ $::icon::12x12::none]
						} else {
							lappend text [list @ $::timemodebox::icon::12x12::Mode($item)]
						}
					}

					default {
						lappend text $item
					}
				}
			} else {
				lappend text ""
			}
		}

		::table::insert $table $i $text
	}
}


proc TableVisit {table data} {
	variable ${table}::Vars

	lassign $data base mode id row

	if {$mode eq "leave"} {
		::tooltip::hide true
		return
	}

	switch $id {
		eventCountry - eventType - eventMode - timeMode {}
		default { return }
	}

	set view [{*}$Vars(viewcmd) $base]
	set row  [::scrolledtable::rowToIndex $table $row]
	set col  [lsearch -exact $Vars(columns) $id]
	set item [::scidb::db::get eventInfo $row $view $base $col]

	if {[llength $item] == 0} { return }

	switch $id {
		eventCountry	{ set tip [::country::name $item] }
		eventType		{ set tip $::eventtypebox::mc::Type($item) }
		eventMode		{ set tip [set ::eventmodebox::mc::$item] }
		timeMode			{ set tip $::timemodebox::mc::Mode($item) }
	}

	if {[string length $tip]} {
		::tooltip::show $table $tip
	}
}


proc SortColumn {path id dir {rating {}}} {
	variable ${path}::Vars

	::widget::busyCursor on
	set base [::scrolledtable::base $path]
	set view [{*}$Vars(viewcmd) $base]
	set see 0
	set selection [::scrolledtable::selection $path]
	if {$selection >= 0 && [::scrolledtable::selectionIsVisible? $path]} { set see 1 }
	if {$dir eq "reverse"} {
		::scidb::db::reverse event $base $view
	} else {
		set options {}
		if {$dir eq "descending"} { lappend options -descending }
		set column [::scrolledtable::columnNo $path $id]
		::scidb::db::sort event $base $column $view {*}$options
	}
	if {$selection >= 0} {
		set selection [::scidb::db::get lookupEvent $selection $view $base]
	}
	::widget::busyCursor off
	::scrolledtable::updateColumn $path $selection $see
}


proc PopupMenu {path menu base index} {
	variable ${path}::Vars

	if {$index eq "none" || $index eq "outside"} { return }

	$menu add command \
		-compound left \
		-image $::icon::16x16::crossTable \
		-label " $::gametable::mc::ShowTournamentTable" \
		-command [namespace code [list OpenCrosstable $path $index]] \
		;
}


proc BindAccelerators {path} {
	variable ${path}::Vars

	foreach {accel proc} [list $::gametable::mc::AccelTournTable OpenCrosstable] {
		set cmd [namespace code [list $proc $path]]
		bind $path <Key-[string toupper $accel]> [list ::util::doAccelCmd $accel %s $cmd]
		bind $path <Key-[string tolower $accel]> [list ::util::doAccelCmd $accel %s $cmd]
	}
}


proc OpenCrosstable {path {index -1}} {
	variable ${path}::Vars

	if {$index == -1} { set index [::scrolledtable::active $path] }
	if {$index == -1} { return }

	set base [::scrolledtable::base $path]
	set view [{*}$Vars(viewcmd) $base]

	::crosstable::open $path $base $index $view event
}


proc WriteOptions {chan} {
	options::writeItem $chan [namespace current]::Options
}

::options::hookWriter [namespace current]::WriteOptions


namespace eval icon {
namespace eval 12x12 {

set I_TimeMode $::terminationbox::icon::12x12::TimeForfeit

} ;# namespace 12x12
} ;# namespace icon
} ;# namespace eventtable

# vi:set ts=3 sw=3:
