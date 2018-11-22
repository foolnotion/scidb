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

::util::source site-table

namespace eval sitetable {
namespace eval mc {

set FindSite "Search Site"

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

variable History {}


proc build {path getViewCmd {visibleColumns {}} {args {}}} {
	variable columns
	variable Columns
	variable Defaults

	namespace eval $path {}
	variable ${path}::Vars
	variable ${path}::Options

	array set Vars { columns {} usefind 0 }

	array set options $args
	foreach opt {id selectcmd usefind} {
		if {[info exists options(-$opt)]} {
			set Vars($opt) $options(-$opt)
			unset options(-$opt)
		}
	}
	set args [array get options]
	lappend args -popupcmd [namespace code PopupMenu]
	lappend args -id $Vars(id)

	array set Options [array get Defaults]
	::scrolledtable::bindOptions $Vars(id) [namespace current]::${path}::Options [array names Defaults]

	if {[llength $visibleColumns] == 0} { set visibleColumns $columns }

	set columns {}
	foreach column $Columns {
		lassign $column id adjustment minwidth maxwidth width stretch removable ellipsis color
		set menu {}

		if {$id eq "country"} {
			foreach {labelvar value} {Flags flags PGN_CountryCode PGN ISO_CountryCode ISO} {
				lappend menu [list radiobutton \
					-command [namespace code [list Refresh $path]] \
					-labelvar ::gamestable::mc::$labelvar \
					-variable [namespace current]::${path}::Options(country-code) \
					-value $value \
				]
			}
			lappend menu { separator }
		}

		lappend menu [list command \
			-command [namespace code [list SortColumn $path $id ascending]] \
			-labelvar ::gamestable::mc::SortAscending \
		]
		lappend menu [list command \
			-command [namespace code [list SortColumn $path $id descending]] \
			-labelvar ::gamestable::mc::SortDescending \
		]
		lappend menu [list command \
			-command [namespace code [list SortColumn $path $id reverse]] \
			-labelvar ::gamestable::mc::ReverseOrder \
		]
		lappend menu [list command \
			-command [namespace code [list SortColumn $path $id cancel]] \
			-labelvar ::gamestable::mc::CancelSort \
		]
		lappend menu { separator }

		set ivar [namespace current]::icon::12x12::I_[string toupper $id 0 0]
		switch $id {
			site {
				set fvar ::gamestable::mc::F_Site
				set tvar ::gamestable::mc::T_Site
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

	set Vars(table) [::scrolledtable::build $path $columns {*}$args]
	::scrolledtable::bindOptions $Vars(id) [namespace current]::${path}::Options [array names Defaults]
	pack $path -fill both -expand yes

	::bind $path <<TableFill>>			[namespace code [list TableFill $path %d]]
	::bind $path <<TableSelected>>	[namespace code [list TableSelected $path %d]]
	::bind $path <<TableVisit>>		[namespace code [list TableVisit $path %d]]
	::bind $path <<LanguageChanged>> [namespace code [list BindAccelerators $path]]

	set Vars(viewcmd) $getViewCmd
	BindAccelerators $path

	if {$Vars(usefind)} {
		::toolbar::setup $path -id sitetable -layout site
		set tbFind [::toolbar::toolbar $path \
			-id sitetable-find \
			-hide 1 \
			-side bottom \
			-alignment left \
			-allow {top bottom} \
			-tooltipvar ::playertable::mc::Find \
		]
		set cb [::toolbar::add $tbFind searchentry \
			-float 0 \
			-width 24 \
			-parent $path \
			-history [namespace current]::History \
			-ghosttextvar [namespace current]::mc::FindSite \
			-helpinfo ::playerdict::mc::HelpPatternMatching \
			-mode key \
		]
		::bind $cb <<Find>> [namespace code [list Find $path first %d]]
		::bind $cb <<FindNext>> [namespace code [list Find $path next %d]]
		::bind $cb <<Help>> [list ::help::open .application Pattern-Matching]
	}

	return $Vars(table)
}


proc init {path base variant} {
	variable ${path}::Vars
	set Vars($base:$variant:index) -1
}


proc forget {path base variant} {
	::scrolledtable::forget $path $base $variant
	unset -nocomplain [namespace current]::${path}::Vars($base:$variant:index)
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


proc update {path base variant size} {
	::scrolledtable::update $path $base $variant $size
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


proc computeHeight {path} {
	return [expr {[::toolbar::totalHeight $path] + [::scrolledtable::computeHeight $path 0]}]
}


proc borderwidth {path} {
	return [::scrolledtable::borderwidth $path]
}


proc selectedSite {path base variant} {
	variable ${path}::Vars
	return $Vars($base:$variant:index) 
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


proc popupMenu {parent menu site} {
	set accel [set [namespace parent]::gamestable::mc::Accel(openurl)]
	set cmd [namespace code [list ::web::open $parent $site]]
	$menu add command \
		-compound left \
		-image $::icon::16x16::internet \
		-label " $::engine::mc::OpenUrl" \
		-accelerator $accel \
		-command $cmd \
		;
	::bind $menu <Key-$accel> $cmd
	::bind $menu <Key-[string tolower $accel]> $cmd
}


proc BindAccelerators {path} {
	variable ${path}::Vars

	set cmd [namespace code [list OpenURL $path]]
	set accel [set [namespace parent]::gamestable::mc::Accel(openurl)]
	bind $path <Key-[string toupper $accel]> [list ::util::doAccelCmd $accel %s $cmd]
	bind $path <Key-[string tolower $accel]> [list ::util::doAccelCmd $accel %s $cmd]
}


proc OpenURL {path} {
	variable ${path}::Vars

	set index [::scrolledtable::active $path]
	if {$index == -1} { return }
	set base [::scrolledtable::base $path]
	set variant [::scrolledtable::variant $path]
	set view [{*}$Vars(viewcmd) $base $variant]
	set col  [lsearch -exact $Vars(columns) site]
	set site [::scidb::db::get siteInfo $index $view $base $variant $col]

	if {[::web::isWebLink $site]} {
		::web::open $path $site
	}
}


proc Refresh {path} {
	::scrolledtable::refresh $path
}


proc TableSelected {path index} {
	variable ${path}::Vars

	if {[llength $Vars(selectcmd)]} {
		::widget::busyCursor on
		set base [::scrolledtable::base $path]
		set variant [::scrolledtable::variant $path]
		set view [{*}$Vars(viewcmd) $base $variant]
		set Vars($base:$variant:index) [::scidb::db::get siteIndex $index $view $base $variant]
		set Vars($base:$variant:index) $index
		{*}$Vars(selectcmd) $base $variant $view
		::widget::busyCursor off
	}
}


proc TableFill {path args} {
	variable ${path}::Vars
	variable ${path}::Options

	lassign [lindex $args 0] table base variant start first last columns

	set codec [::scidb::db::get codec $base $variant]
	set view [{*}$Vars(viewcmd) $base $variant]
	set last [expr {min($last, [scidb::view::count sites $base $variant $view] - $start)}]

	if {![info exists Vars($base:$variant:index)]} {
		set Vars($base:$variant:index) -1
	}

	for {set i $first} {$i < $last} {incr i} {
		set index [expr {$start + $i}]
		set line [::scidb::db::get siteInfo $index $view $base $variant]
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

	lassign $data base variant mode id row
	if {[string length $base] == 0} { return }

	if {$mode eq "leave"} {
		::tooltip::hide true
		return
	}

	if {$id ne "country"} { return }

	set view [{*}$Vars(viewcmd) $base $variant]
	set row  [::scrolledtable::rowToIndex $table $row]
	set col  [lsearch -exact $Vars(columns) $id]
	set item [::scidb::db::get siteInfo $row $view $base $variant $col]

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
	set variant [::scrolledtable::variant $path]
	set view [{*}$Vars(viewcmd) $base $variant]
	set see 0
	set selection [::scrolledtable::selection $path]
	if {$selection >= 0 && [::scrolledtable::selectionIsVisible? $path]} { set see 1 }
	switch $dir {
		reverse {
			::scidb::db::reverse site $base $variant $view
		}
		cancel {
			set columnNo [::scrolledtable::columnNo $path site]
			::scidb::db::sort site $base $variant $columnNo $view -reset -ascending
		}
		default {
			set columnNo [::scrolledtable::columnNo $path $id]
			::scidb::db::sort site $base $variant $columnNo $view -$dir
		}
	}
	if {$selection >= 0} {
		set selection [::scidb::db::get lookupSite $selection $view $base $variant]
	}
	::widget::busyCursor off
	::scrolledtable::updateColumn $path $selection $see
}


proc Find {path mode name} {
	variable ${path}::Vars

	set base [::scrolledtable::base $path]
	if {[string length $base] == 0} { return }
	set variant [::scrolledtable::variant $path]
	set view [{*}$Vars(viewcmd) $base $variant]
	if {$mode eq "next"} { set lastIndex [::scrolledtable::active $path] } else { set lastIndex -1 }
	set i [::scidb::view::find site $base $variant $view "$name*" $lastIndex]
	if {$i >= 0} {
		::scrolledtable::see $path $i
		::scrolledtable::activate $path $i
	}
}


proc GetSite {path base variant view index} {
	variable ${path}::Vars

	if {$index == "outside"} { return "" }
	set col [lsearch -exact $Vars(columns) site]
	set site [::scidb::db::get siteInfo $index $view $base $variant $col]
}


proc PopupMenu {path menu base variant index column} {
	variable ${path}::Vars

	set view [{*}$Vars(viewcmd) $base $variant]
	set site [GetSite $path $base $variant $view $index]

	if {[::web::isWebLink $site]} {
		set accel $::gamestable::mc::Accel(openurl)
		$menu add command \
			-compound left \
			-image $::icon::16x16::internet \
			-label " $::engine::mc::OpenUrl" \
			-accelerator $accel \
			-command [namespace code [list ::web::open $path $site]] \
			;
		set cmd [namespace code [list ::web::open $path $site]]
		::bind $menu <Key-$accel> $cmd
		::bind $menu <Key-[string tolower $accel]> $cmd
	}
}

} ;# namespace sitetable

# vi:set ts=3 sw=3:
