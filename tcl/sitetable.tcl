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

::util::source site-table

namespace eval sitetable {
namespace eval mc {

set T_Country "Country"

# translation not needed (TODO)
set F_Country	"\u2691"

}

#		ID   		Adjustment	Min	Max	Width	Stretch	Removable	Elipsis	Color
#	----------------------------------------------------------------------------------
set Columns {
	{ site			left		20		 0		24			1			0			1			{}				}
	{ country		center	 4		 5		 4			0			1			0			darkgreen	}
	{ frequency		right		 4		 8		 5			0			1			1			{}				}
}

variable columns {}
foreach col $Columns { lappend columns [lindex $col 0] }

array set Defaults {
	sort				{}
	country-code	flags
}

array set Options {}
variable Find {}


proc build {path getViewCmd {visibleColumns {}} {args {}}} {
	namespace eval [namespace current]::$path {}
	variable [namespace current]::${path}::Vars
	variable columns
	variable Columns
	variable Options
	variable Defaults
	variable Find

	array set Vars {
		columns			{}
		find-current	{}
	}

	array set options [array get Defaults]
	array set options [array get Options]
	array set Options [array get options]

	if {[llength $visibleColumns] == 0} { set visibleColumns $columns }

	set columns {}
	foreach column $Columns {
		lassign $column id adjustment minwidth maxwidth width stretch removable ellipsis color
		set menu {}

		if {$id eq "country"} {
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
		switch $id {
			site {
				set fvar ::gametable::mc::F_Site
				set tvar ::gametable::mc::T_Site
			}
			frequency {
				set fvar ::playertable::mc::F_Frequency
				set tvar ::playertable::mc::T_Frequency
			}
			country {
				set fvar [namespace current]::mc::F_Country
				set tvar [namespace current]::mc::T_Country
			}
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

	set options(-usefind) 0
	array set options $args
	set useFind $options(-usefind)
	unset options(-usefind)
	if {[info exists options(-selectcmd)]} {
		set Vars(selectcmd) $options(-selectcmd)
		unset options(-selectcmd)
		set args [array get options]
	}
#	lappend args -popupcmd [namespace code PopupMenu]
	set Vars(table) [::scrolledtable::build $path $columns {*}$args]

	::bind $path <<TableFill>>			[namespace code [list TableFill $path %d]]
	::bind $path <<TableSelected>>	[namespace code [list TableSelected $path %d]]
	::bind $path <<TableVisit>>		[namespace code [list TableVisit $path %d]]

	set Vars(viewcmd) $getViewCmd

	if {$useFind} {
		set tbFind [::toolbar::toolbar $path \
			-id sitetable-find \
			-hide 1 \
			-side bottom \
			-alignment left \
			-allow {top bottom} \
			-tooltipvar ::playertable::mc::Find \
		]
		::toolbar::add $tbFind label -float 0 -textvar [::mc::var ::playertable::mc::Find ":"]
		set cb [::toolbar::add $tbFind ttk::combobox \
			-width 20 \
			-takefocus 1 \
			-values $Find \
			-textvariable [namespace current]::${path}::Vars(find-current) \
		]
		trace add variable [namespace current]::${path}::Vars(find-current) \
			write [namespace code [list Find $path $cb]]
		::bind $cb <Return> [namespace code [list Find $path $cb]]
		::toolbar::add $tbFind button \
			-image $::icon::22x22::enter \
			-tooltipvar ::playertable::mc::StartSearch \
			-command [namespace code [list Find $path $cb]] \
			;
		::toolbar::add $tbFind button \
			-image $::icon::22x22::clear \
			-tooltipvar ::playertable::mc::ClearEntries \
			-command [namespace code [list Clear $path $cb]] \
			;
	}

	return $Vars(table)
}


proc init {path base} {
	variable ${path}::Vars
	set Vars($base:index) -1
}


proc forget {path base} {
	::scrolledtable::forget $path $base
	unset -nocomplain [namespace current]::${path}::Vars($base:index)
}


proc columnIndex {name} {
	variable columns
	return [lsearch -exact $columns $name]
}


proc column {info name} {
	variable columns
	return [lindex $info [lsearch -exact $columns $name]]
}


proc base {path} {
	return [::scrolledtable::base $path]
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


proc linespace {path} {
	return [::scrolledtable::linespace $path]
}


proc borderwidth {path} {
	return [::scrolledtable::borderwidth $path]
}


proc selectedSite {path base} {
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


proc TableSelected {path index} {
	variable ${path}::Vars

	if {[llength $Vars(selectcmd)]} {
		::widget::busyCursor on
		set base [::scrolledtable::base $path]
		set view [{*}$Vars(viewcmd) $base]
		set Vars($base:index) [::scidb::db::get siteIndex $index $view $base]
		set Vars($base:index) $index
		{*}$Vars(selectcmd) $base $view
		::widget::busyCursor off
	}
}


proc TableFill {path args} {
	variable ${path}::Vars
	variable Options

	lassign [lindex $args 0] table base start first last columns

	set codec [::scidb::db::get codec $base]
	set view [{*}$Vars(viewcmd) $base]
	set last [expr {min($last, [scidb::view::count sites $base $view] - $start)}]

	if {![info exists Vars($base:index)]} {
		set Vars($base:index) -1
	}

	for {set i $first} {$i < $last} {incr i} {
		set index [expr {$start + $i}]
		set line [::scidb::db::get siteInfo $index $view $base]
		set text {}
		set k 0

		foreach id $columns {
			if {[::table::visible? $table $id]} {
				set item [lindex $line $k]

				switch $id {
					country {
						if {[string length $item] == 0} {
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

					default {
						lappend text $item
					}
				}
			} else {
				lappend text ""
			}

			incr k
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

	if {$id ne "country"} { return }

	set view [{*}$Vars(viewcmd) $base]
	set row  [::scrolledtable::rowToIndex $table $row]
	set col  [lsearch -exact $Vars(columns) $id]
	set item [::scidb::db::get siteInfo $row $view $base $col]

	if {[string length $item] > 0} {
		set tip [::country::name $item]

		if {[string length $tip]} {
			::tooltip::show $table $tip
		}
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
		::scidb::db::reverse site $base $view
	} else {
		set options {}
		if {$dir eq "descending"} { lappend options -descending }
		set column [::scrolledtable::columnNo $path $id]
		::scidb::db::sort site $base $column $view {*}$options
	}
	if {$selection >= 0} {
		set selection [::scidb::db::get lookupSite $selection $view $base]
	}
	::widget::busyCursor off
	::scrolledtable::updateColumn $path $selection $see
}


proc Find {path combo args} {
	variable ${path}::Vars
	variable Find

	set value $Vars(find-current)
	if {[string length $value] == 0} { return }
	set base [::scrolledtable::base $path]
	set view [{*}$Vars(viewcmd) $base]
	set i [::scidb::view::find site $base $view $value]
	if {[llength $args] == 0} {
		if {[string length $value] > 2} {
			lappend Find $value
			set Find [lsort -dictionary -increasing -unique $Find]
			::toolbar::childconfigure $combo -values $Find
		}
		if {$i >= 0} {
			::scrolledtable::see $path $i
			::scrolledtable::focus $path
		} else {
			::dialog::info -parent [::toolbar::lookupChild $combo] -message $mc::NotFound
		}
	} elseif {$i >= 0} {
		::scrolledtable::see $path $i
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
	options::writeItem $chan [namespace current]::Options
}

::options::hookWriter [namespace current]::WriteOptions

} ;# namespace sitetable

# vi:set ts=3 sw=3:
