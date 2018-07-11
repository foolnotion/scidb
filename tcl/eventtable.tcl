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
# Copyright: (C) 2011-2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source event-table

namespace eval eventtable {
namespace eval mc {

set Attendance "Attendance"
set FindEvent	"Search Event Name"

}

#		ID   		Adjustment	Min	Max	Width	Stretch	Removable	Elipsis	Color
#	----------------------------------------------------------------------------------
set Columns {
	{ event			left		10		 0		14			1			0			1			{}			}
	{ eventType		left		 2		 8		 6			0			1			0			{}			}
	{ eventDate		left		 5		10		10			0			1			0			darkred	}
	{ eventMode		center	 0		 0		14px		0			1			1			{}			}
	{ timeMode		center	 0		 0		14px		0			1			1			{}			}
	{ eventCountry	center	 4		 5		 5			0			1			0			{}			}
	{ site			left		10		 0		14			1			1			1			{}			}
	{ frequency		right		 4		 8		 6			0			1			1			{}			}
}

variable columns {}
foreach col $Columns { lappend columns [lindex $col 0] }

array set Defaults {
	country-code	flags
	eventtype-icon	1
}

variable History {}


proc build {path getViewCmd {visibleColumns {}} {args {}}} {
	variable Columns
	variable Defaults
	variable columns

	namespace eval $path {}
	variable ${path}::Vars
	variable ${path}::Options

	array set Vars {
		columns		{}
		selectcmd	{}
		usefind		0
	}

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

		switch $id {
			eventCountry {
				foreach {labelvar value} {Flags flags PGN_CountryCode PGN ISO_CountryCode ISO} {
					lappend menu [list radiobutton \
						-command [namespace code [list Refresh $path]] \
						-labelvar ::gametable::mc::$labelvar \
						-variable [namespace current]::${path}::Options(country-code) \
						-value $value \
					]
				}
				lappend menu { separator }
			}

			eventType {
				lappend menu [list radiobutton \
					-command [namespace code [list RefreshEventType $path]] \
					-labelvar ::gametable::mc::Icons \
					-variable [namespace current]::${path}::Options(eventtype-icon) \
					-value 1 \
				]
				lappend menu [list radiobutton \
					-command [namespace code [list RefreshEventType $path]] \
					-labelvar ::gametable::mc::Abbreviations \
					-variable [namespace current]::${path}::Options(eventtype-icon) \
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
		lappend menu [list command \
			-command [namespace code [list SortColumn $path $id cancel]] \
			-labelvar ::gametable::mc::CancelSort \
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

	set Vars(table) [::scrolledtable::build $path $columns {*}$args]
	pack $path -fill both -expand yes
	RefreshEventType $path

	::scrolledtable::configure $path event \
		-specialfont [list [list $::font::figurine(text:normal) 9812 9823]] \
		;

	::bind $path <<TableFill>>			[namespace code [list TableFill $path %d]]
	::bind $path <<TableSelected>>	[namespace code [list TableSelected $path %d]]
	::bind $path <<TableVisit>>		[namespace code [list TableVisit $path %d]]
	::bind $path <<LanguageChanged>> [namespace code [list BindAccelerators $path]]

	bind $path <ButtonPress-2>			[namespace code [list ShowInfo $path %x %y]]
	bind $path <ButtonRelease-2>		[namespace code [list popdownInfo $path]]
	bind $path <ButtonPress-3>			+[namespace code [list popdownInfo $path]]

	set Vars(viewcmd) $getViewCmd
	BindAccelerators $path

	if {$Vars(usefind)} {
		set tbFind [::toolbar::toolbar $path \
			-id eventtable-find \
			-hide 1 \
			-side bottom \
			-alignment left \
			-allow {top bottom} \
			-tooltipvar ::playertable::mc::Find \
		]
		set cb [::toolbar::add $tbFind searchentry \
			-width 24 \
			-parent $path \
			-history [namespace current]::History \
			-ghosttextvar [namespace current]::mc::FindEvent \
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


proc borderwidth {path} {
	return [::scrolledtable::borderwidth $path]
}


proc selectedEvent {path base variant} {
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


proc popupInfo {path info} {
	set w $path.showinfo
	catch { destroy $w }
	set top [::util::makePopup $w]
	set bg [$top cget -background]

	set f [tk::frame $top.f -borderwidth 0 -background $bg]
	grid $f -column 3 -row 1

	set columns {event type eventDate eventMode timeMode
					country site frequency attendance averageRating category}
	lassign $info {*}$columns
	set countryCode $country
	set country [::country::name $country]
	if {[string length $type]} { set type $::eventtypebox::mc::Type($type) } else { set type "" }
	if {[string length $timeMode]} {
		set timeMode $::timemodebox::mc::Mode($timeMode)
	} else {
		set timeMode ""
	}
	set eventDate [::locale::formatDate $eventDate]
	if {[string length $eventMode] > 1} { set mode [set ::eventmodebox::mc::$eventMode] }
	set row 1
	foreach var $columns {
		if {$var ne "frequency"} {
			set value [set $var]
			if {[string length $value] == 0 || $value == 0} { set value "\u2013" }
			set attr [string toupper $var 0 0]
			if {[info exists ::gametable::mc::F_$attr]} {
				set text [set ::gametable::mc::F_$attr]
			} elseif {[info exists ::dialog::save::mc::Label($var)]} {
				set text [set ::dialog::save::mc::Label($var)]
			} elseif {[info exists ::crosstable::mc::$attr]} {
				set text [set ::crosstable::mc::$attr]
			} else {
				set text [set mc::$attr]
			}
			tk::label $f.lbl$row -background $bg -text "$text:"
			tk::label $f.val$row -background $bg -text $value -justify left
			grid $f.lbl$row -row $row -column 3 -sticky nw
			grid $f.val$row -row $row -column 5 -sticky w
#			grid rowconfigure $f [expr {$row + 1}] -minsize $::theme::padding
			incr row 2
		}
	}
	grid columnconfigure $f 4 -minsize $::theme::padding
	grid columnconfigure $f {2 6} -minsize 2
	grid rowconfigure $f [list 0 [incr row -1]] -minsize 2

	set icon [::country::countryFlag $countryCode]
	if {[llength $icon]} {
		if {![winfo exists $top.lt]} { tk::frame $top.lt -background $bg -borderwidth 0 }
		set lbl [tk::label $top.lt.flag -background $bg -image $icon -borderwidth 0]
		grid $lbl -column 1 -row 3 -sticky n
		grid $top.lt -column 1 -row 1
		grid columnconfigure $top 0 -minsize 2
		grid columnconfigure $top 2 -minsize $::theme::padding
		grid rowconfigure $top {0 2} -minsize 2
	}

	::tooltip::popup $path $w cursor
}


proc popdownInfo {path} {
	::tooltip::popdown $path.showinfo
}


proc popupMenu {parent menu base variant view index source} {
	set accel $::gametable::mc::Accel(tourntable)
	$menu add command \
		-compound left \
		-image $::icon::16x16::crossTable \
		-label " $::gametable::mc::ShowTournamentTable" \
		-accelerator $accel \
		-command [namespace code [list OpenCrosstable $parent $source $base $variant $view $index]] \
		;
	set cmd [namespace code [list OpenCrosstable $parent $source $base $variant $view $index $menu]]
	::bind $menu <Key-$accel> $cmd
	::bind $menu <Key-[string tolower $accel]> $cmd
}


proc Refresh {path} {
	::scrolledtable::refresh $path
}


proc RefreshEventType {path} {
	variable ${path}::Options

	set justification [expr {$Options(eventtype-icon) ? "center" : "left"}]
	::scrolledtable::clearColumn $path eventType
	::scrolledtable::setColumnJustification $path eventType $justification
	Refresh $path
}


proc TableSelected {path index} {
	variable ${path}::Vars

	if {[llength $Vars(selectcmd)]} {
		::widget::busyCursor on
		set base [::scrolledtable::base $path]
		set variant [::scrolledtable::variant $path]
		set view [{*}$Vars(viewcmd) $base $variant]
		set Vars($base:$variant:index) [::scidb::db::get eventIndex $index $view $base $variant]
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
	set last [expr {min($last, [scidb::view::count events $base $variant $view] - $start)}]

	if {![info exists Vars($base:$variant:index)]} {
		set Vars($base:$variant:index) -1
	}

	for {set i $first} {$i < $last} {incr i} {
		set index [expr {$start + $i}]
		set line [::scidb::db::get eventInfo $index $view $base $variant]
		set text {}
		set k 0

		foreach id $columns {
			if {[::table::visible? $table $id]} {
				set item [lindex $line $k]

				switch $id {
					event {
						if {[string length $item] == 0} {
							lappend text "-"
						} else {
							lappend text $item
						}
					}

					eventCountry {
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

					eventType {
						if {[string length $item]} {
							if {$Options(eventtype-icon)} {
								lappend text [list @ $::eventtypebox::icon::12x12::Type($item)]
							} else {
								lappend text $::gametable::mc::EventType($item)
							}
						} elseif {$codec eq "si3" || $codec eq "si4"} {
							lappend text $::mc::NotAvailableSign
						} else {
							lappend text {}
						}
					}

					eventMode {
						if {[string length $item] > 0} {
							lappend text [list @ [set ::eventmodebox::icon::12x12::$item]]
						} else {
							lappend text [list @ $::icon::12x12::none]
						}
					}

					timeMode {
						if {[string length $item] > 0} {
							lappend text [list @ $::timemodebox::icon::12x12::Mode($item)]
						} else {
							lappend text [list @ $::icon::12x12::none]
						}
					}

					default {
						lappend text $item
					}
				}
			} else {
				lappend text {}
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

	switch $id {
		eventCountry - eventType - eventMode - timeMode {}
		default { return }
	}

	set view [{*}$Vars(viewcmd) $base $variant]
	set row  [::scrolledtable::rowToIndex $table $row]
	set col  [lsearch -exact $Vars(columns) $id]
	set item [::scidb::db::get eventInfo $row $view $base $variant $col]

	if {[string length $item] == 0} { return }

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
	set variant [::scrolledtable::variant $path]
	set view [{*}$Vars(viewcmd) $base $variant]
	set see 0
	set selection [::scrolledtable::selection $path]
	if {$selection >= 0 && [::scrolledtable::selectionIsVisible? $path]} { set see 1 }
	switch $dir {
		reverse {
			::scidb::db::reverse event $base $variant $view
		}
		cancel {
			set columnNo [::scrolledtable::columnNo $path event]
			::scidb::db::sort event $base $variant $columnNo $view -ascending -reset
		}
		default {
			set columnNo [::scrolledtable::columnNo $path $id]
			::scidb::db::sort event $base $variant $columnNo $view -$dir
		}
	}
	if {$selection >= 0} {
		set selection [::scidb::db::get lookupEvent $selection $view $base $variant]
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
	set i [::scidb::view::find event $base $variant $view "$name*" $lastIndex]
	if {$i >= 0} {
		::scrolledtable::see $path $i
		::scrolledtable::activate $path $i
	}
}


proc ShowInfo {path x y} {
	variable ${path}::Vars

	set table $path
	set index [::scrolledtable::at $table $y]
	if {![string is digit $index]} { return }
	::scrolledtable::focus $table
	::scrolledtable::activate $table [::scrolledtable::indexToRow $table $index]
	set base [::scrolledtable::base $table]
	set variant [::scrolledtable::variant $table]
	set view [{*}$Vars(viewcmd) $base $variant]
	set info [scidb::db::get eventInfo $index $view $base $variant -card]
	popupInfo $path $info
}


proc PopupMenu {path menu base variant index} {
	variable ${path}::Vars

	if {$index eq "none" || $index eq "outside"} { return }
	popupMenu $path $menu $base $variant [{*}$Vars(viewcmd) $base $variant] $index event

	$menu add separator

	set visible [::scrolledtable::visibleColumns $path]
	foreach dir {ascending descending} {
		set m [menu $menu.$dir]
		$menu add cascade -label [set ::gametable::mc::Sort[string toupper $dir 0 0]] -menu $m
		foreach id $visible {
			set idl [string toupper $id 0 0]
			foreach ns { eventtable gametable playertable } {
				set fvar ::${ns}::mc::F_$idl
				set tvar ::${ns}::mc::T_$idl
				if {[info exists $tvar]} {
					set var $tvar
					break
				} elseif {[info exists $fvar]} {
					set var $fvar
					break
				}
			}
			$m add command \
				-label [set $var] \
				-command [namespace code [list SortColumn $path $id $dir]] \
				;
		}
	}
}


proc BindAccelerators {path} {
	variable ${path}::Vars

	foreach {accel proc} [list $::gametable::mc::Accel(tourntable) OpenCrosstable] {
		set cmd [namespace code [list $proc $path event]]
		bind $path <Key-[string toupper $accel]> [list ::util::doAccelCmd $accel %s $cmd]
		bind $path <Key-[string tolower $accel]> [list ::util::doAccelCmd $accel %s $cmd]
	}
}


proc OpenCrosstable {path source {base ""} {variant ""} {view -1} {index -1} {menu ""}} {
	if {[string length $menu]} { ::tk::MenuUnpost $menu }
	if {$index == -1} { set index [::scrolledtable::active $path] }
	if {$index == -1} { return }

	if {[string length $base] == 0} {
		set base [::scrolledtable::base $path]
		set variant [::scrolledtable::variant $path]
	}

	if {$view == -1} {
		variable ${path}::Vars
		set view [{*}$Vars(viewcmd) $base $variant]
	}

	::crosstable::open $path $base $variant $index $view $source
}


namespace eval icon {
namespace eval 12x12 {

set I_TimeMode $::terminationbox::icon::12x12::TimeForfeit

} ;# namespace 12x12
} ;# namespace icon
} ;# namespace eventtable

# vi:set ts=3 sw=3:
