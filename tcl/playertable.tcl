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
# Copyright: (C) 2010-2012 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source player-table

namespace eval playertable {
namespace eval mc {

set Find							"Find"
set StartSearch				"Start search"
set ClearEntries				"Clear entries"
set NotFound					"Not found."

set Name							"Name"
set HighestRating				"Highest rating"
set MostRecentRating			"Most recent rating"
set DateOfBirth				"Date of birth"
set DateOfDeath				"Date of death"
set FideID						"Fide ID"

set TooltipRating				"Rating: %s"

set ShowPlayerCard			"Show Player Card..."

set F_LastName					"Last Name"
set F_FirstName				"First Name"
set F_FideID					"Fide ID"
set F_Title						"Title"

set T_Federation				"Federation"
set T_RatingType				"Rating Type"
set T_Type						"Type"
set T_Sex						"Sex"
set T_PlayerInfo				"Info Flag"

# translation not needed (TODO)
set F_RatingType				"RT"
set F_Federation				"\u2691"
set F_Frequency				"\u2211"

} ;# namespace mc

namespace import ::tcl::mathfunc::abs
namespace import ::tcl::mathfunc::max

#		ID   		Adjustment	Min	Max	Width	Stretch	Removable	Elipsis	Color
#	-------------------------------------------------------------------------------------
set Columns {
	{ lastName		left		10		0		14			1			0			1			{}				}
	{ firstName		left		10		0		14			1			0			1			{}				}
	{ fideID			right		 0		0		10			0			1			1			{}				}
	{ type			center	 0		0		14px		0			1			0			{}				}
	{ sex				center	 0		0		14px		0			1			0			{}				}
	{ rating1		center	 0		0		 6			0			1			1			darkblue		}
	{ rating2		center	 0		0		 6			0			1			1			darkblue		}
	{ ratingType	left      0    0      7       0        1        0        darkblue		}
	{ federation	center	 4		5		 5			0			1			0			darkgreen	}
	{ title			left		 0		0		 5			0			1			1			darkred		}
	{ playerInfo	center	 0		0		14px		0			1			0			red			}
	{ frequency		right		 4		8		 5			0			0			1			{}				}
}

variable columns {}
foreach col $Columns { lappend columns [lindex $col 0] }

array set Defaults {
	country-code	flags

	exclude-elo		1
	include-type	1

	rating1:which	highest
	rating2:which	highest
	rating1:type	Elo
	rating2:type	DWZ
}

array set Options {}
variable Find {}


proc build {path getViewCmd {visibleColumns {}} {args {}}} {
	variable ::gametable::ratings
	variable Columns
	variable Options
	variable Defaults
	variable Find
	variable columns

	namespace eval [namespace current]::$path {}
	variable ${path}::Vars

	if {[array size Options] < [array size Defaults]} {
		array set Options [array get Defaults]
	}

	set mc::F_Rating1 $Options(rating1:type)
	set mc::F_Rating2 $Options(rating2:type)

	RefreshHeader 1
	RefreshHeader 2

	array set Vars {
		columns			{}
		selectcmd		{}
		find-current	{}
	}

	if {[llength $visibleColumns] == 0} { set visibleColumns $columns }

	set columns {}
	foreach column $Columns {
		lassign $column id adjustment minwidth maxwidth width stretch removable ellipsis color
		set menu {}

		if {$id ne "firstName"} {
			lappend menu [list command \
				-command [namespace code [list SortColumn $path $id ascending]] \
				-labelvar ::gametable::mc::SortAscending]
			lappend menu [list command \
				-command [namespace code [list SortColumn $path $id descending]] \
				-labelvar ::gametable::mc::SortDescending]
			lappend menu [list command \
				-command [namespace code [list SortColumn $path $id reverse]] \
				-labelvar ::gametable::mc::ReverseOrder]
			lappend menu { separator }
		}

		switch $id {
			federation {
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

			rating1 - rating2 {
				foreach ratType $ratings {
				set number [string index $id 6]
					lappend menu [list radiobutton \
						-command [namespace code [list RefreshRatings $path $number]] \
						-label $ratType \
						-variable [namespace current]::Options($id:type) \
						-value $ratType \
					]
				}
				lappend menu { separator }
				foreach {labelvar value} {HighestRating highest MostRecentRating latest} {
					lappend menu [list radiobutton \
						-command [namespace code [list Refresh $path]] \
						-labelvar [namespace current]::mc::$labelvar \
						-variable [namespace current]::Options($id:which) \
						-value $value \
					]
				}
				lappend menu { separator }
			}

			ratingType {
				lappend menu [list checkbutton \
					-command [namespace code [list Refresh $path]] \
					-labelvar ::gametable::mc::ExcludeElo \
					-variable [namespace current]::Options(exclude-elo) \
				]
				lappend menu { separator }
			}

			sex {
				lappend menu [list checkbutton \
					-command [namespace code [list Refresh $path]] \
					-labelvar ::gametable::mc::IncludePlayerType \
					-variable [namespace current]::Options(include-type) \
				]
				lappend menu { separator }
			}
		}

		switch $id {
			rating2 - ratingType - type - playerInfo { set visible 0 }
			default { set visible [expr {$id in $visibleColumns}] }
		}

		set ivar [namespace current]::icon::12x12::I_[string toupper $id 0 0]
		set fvar ::playertable::mc::F_[string toupper $id 0 0]
		set tvar ::playertable::mc::T_[string toupper $id 0 0]
		if {![info exists $tvar]} { set tvar {} }
		if {![info exists $fvar]} { set fvar $tvar }
		if {![info exists $ivar]} { set ivar {} } else { set ivar [set $ivar] }

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

		if {$id ne "firstName"} {
			lappend Vars(columns) $id
		}
	}

	set options(-usefind) 0
	array set options $args
	set useFind $options(-usefind)
	unset options(-usefind)
	if {[info exists options(-selectcmd)]} {
		set Vars(selectcmd) $options(-selectcmd)
		unset options(-selectcmd)
	}
	set args [array get options]
	lappend args -popupcmd [namespace code PopupMenu]

	ttk::frame $path -takefocus 0 -borderwidth 0
	set table $path.table
	set Vars(table) [::scrolledtable::build $table $columns {*}$args]
	pack $table -fill both -expand yes

	::bind $table <<TableFill>>		[namespace code [list TableFill $path %d]]
	::bind $table <<TableSelected>>	[namespace code [list TableSelected $path %d]]
	::bind $table <<TableVisit>>		[namespace code [list TableVisit $path %d]]

	set Vars(viewcmd) $getViewCmd

	::scrolledtable::bind $table <ButtonPress-2>		[namespace code [list ShowInfo $path %x %y]]
	::scrolledtable::bind $table <ButtonRelease-2>	[namespace code [list HideInfo $path]]
	::scrolledtable::bind $table <ButtonPress-3>		+[namespace code [list HideInfo $path]]

#	::scrolledtable::configure $table lastName -font2 $::font::figurine(text:normal)

	if {$useFind} {
		set tbFind [::toolbar::toolbar $path \
			-id playertable-find \
			-hide 1 \
			-side bottom \
			-alignment left \
			-allow {top bottom} \
			-tooltipvar [namespace current]::mc::Find \
		]
		::toolbar::add $tbFind label -float 0 -textvar [::mc::var [namespace current]::mc::Find ":"]
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
			-tooltipvar [namespace current]::mc::StartSearch \
			-command [namespace code [list Find $path $cb] \
		]
		::toolbar::add $tbFind button \
			-image $::icon::22x22::clear \
			-tooltipvar [namespace current]::mc::ClearEntries \
			-command [namespace code [list Clear $path $cb] \
		]
	}

	return $Vars(table)
}


proc init {path base} {
	set [namespace current]::${path}::Vars($base:index) -1
}


proc forget {path base} {
	variable ${path}::Vars

	::scrolledtable::forget $path.table $base
	unset -nocomplain Vars($base:index)
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
	return [::scrolledtable::base $path.table]
}


proc clear {path} {
	::scrolledtable::clear $path.table
}


proc clearColumn {path id} {
	::scrolledtable::clearColumn $path.table $id
}


proc fill {path first last} {
	::scrolledtable::fill $path.table $first $last
}


proc update {path base size} {
	::scrolledtable::update $path.table $base $size
}


proc changeLayout {path dir} {
	return [::scrolledtable::changeLayout $path.table $dir]
}


proc overhang {path} {
	return [::scrolledtable::overhang $path.table]
}


proc linespace {path} {
	return [::scrolledtable::linespace $path.table]
}


proc borderwidth {path} {
	return [::scrolledtable::borderwidth $path.table]
}


proc selectedPlayer {path base} {
	return [set [namespace current]::${path}::Vars($base:index)]
}


proc getOptions {path} {
	return [::scrolledtable::getOptions $path.table]
}


proc setOptions {path options} {
	::scrolledtable::setOptions $path.table $options
}


proc scroll {path position} {
	::scrolledtable::scroll $path.table $position
}


proc activate {path row} {
	::scrolledtable::activate $path.table $row
}


proc select {path row} {
	::scrolledtable::select $path.table $row
}


proc setSelection {path row} {
	::scrolledtable::setSelection $path.table $row
}


proc index {path} {
	return [::scrolledtable::index $path.table]
}


proc indexToRow {path index} {
	return [::scrolledtable::indexToRow $path.table $index]
}


proc at {path y} {
	return [::scrolledtable::at $path.table $y]
}


proc focus {path} {
	::scrolledtable::focus $path.table
}


proc bind {path sequence script} {
	::scrolledtable::bind $path.table $sequence $script
}


proc see {path position} {
	::scrolledtable::see $path.table $position
}


proc popupMenu {menu base info {playerCard {}}} {
	variable Options

	set parent [winfo toplevel $menu]

	if {[llength $playerCard]} {
		$menu add command \
			-compound left \
			-image $::icon::16x16::playercard \
			-label " $mc::ShowPlayerCard" \
			-command [namespace code [list ::playercard::show $base {*}$playerCard]] \
			;
	}

	set m [menu $menu.web -tearoff false]
	$menu add cascade \
		-menu $m \
		-label " $::playercard::mc::OpenInWebBrowser" \
		-image $::icon::16x16::internet \
		-compound left \
		;
	
	if {![::playercard::buildWebMenu $parent $m $info]} {
		$menu entryconfigure end -state disabled
	}

#	if {![::scidb::db::get readonly? $base]} {
#		$menu add separator
#		$menu add command \
#			-label " $::mc::Edit..." \
#			-command [namespace code [list RenamePlayer $parent $index]] \
#			;
#	}
}


proc RefreshHeader {number} {
	variable Options

	set mc::F_Rating$number $Options(rating$number:type)
	set mc::T_Rating$number [format $mc::TooltipRating $Options(rating$number:type)]
}


proc RefreshRatings {path number} {
	RefreshHeader $number
	::scrolledtable::refresh $path.table
}


proc Refresh {path} {
	set table $path.table
	::scrolledtable::clear $table
	::scrolledtable::refresh $table
}


proc TableSelected {path index} {
	variable ${path}::Vars

	if {[llength $Vars(selectcmd)]} {
		::widget::busyCursor on
		set base [::scrolledtable::base $path.table]
		set view [{*}$Vars(viewcmd) $base]
		set Vars($base:index) [::scidb::db::get playerIndex $index $view $base]
		{*}$Vars(selectcmd) $base $view
		::widget::busyCursor off
	}
}


proc view {path} {
	variable ${path}::Vars
	return [{*}$Vars(viewcmd) [::scrolledtable::base $path.table]]
}


proc TableFill {path args} {
	variable icon::12x12::check
	variable ${path}::Vars
	variable Options

	lassign [lindex $args 0] table base start first last columns

	set codec [::scidb::db::get codec $base]
	set view [{*}$Vars(viewcmd) $base]
	set last [expr {min($last, [scidb::view::count players $base $view] - $start)}]
	set ratings [list $Options(rating1:type) $Options(rating2:type)]

	if {![info exists Vars($base:index)]} {
		set Vars($base:index) -1
	}

	for {set i $first} {$i < $last} {incr i} {
		set index [expr {$start + $i}]
		set base [::scrolledtable::base $path.table]
		set line [scidb::db::get playerInfo $index $view $base -ratings $ratings]
		set text {}
		set k 0

		foreach id $columns {
			set item [lindex $line $k]

			switch $id {
				lastName {
					if {[string length $item] == 0} {
						lappend text "-" ""
					} else {
						set parts [split $item ,]
						lappend text [lindex $parts 0] [lindex [lrange $parts 1 end] 0]
					}
				}

				firstName {
					incr k -1
				}

				fideID {
					if {[string index $item 0] eq "-"} {
						lappend text "*[string range $item 1 end]"
					} else {
						lappend text $item
					}
				}

				playerInfo {
					if {$item} {
						# TODO: only for 12pt; use U+2716 (or U+2718) for other sizes
						set image $check
					} else {
						set image {}
					}
					lappend text [list @ $image]
				}

				sex {
					switch $item {
						m { set icon $::icon::12x12::male }
						f { set icon $::icon::12x12::female }

						default	{
							if {$Options(include-type) && $type eq "program"} {
								set icon $::icon::12x12::program
							} else {
								set icon {}
							}
						}
					}
					lappend text [list @ $icon]
				}

				rating1 - rating2 {
					if {$Options($id:which) eq "highest"} {
						set value [lindex $item 0]
					} else {
						set value [lindex $item 1]
						if {$value == 0} { set value [lindex $item 0] }
					}
					if {$value == 0} {
						lappend text ""
					} elseif {$value > 0} {
						lappend text [format " %4d " $value]
					} elseif {$value <= -1000} {
						lappend text [format "(%4d)" [abs $value]]
					} else {
						lappend text [format " (%3d)" [abs $value]]
					}
				}

				ratingType {
					if {$Options(exclude-elo) && $item eq "Elo"} {
						lappend text {}
					} else {
						lappend text $item
					}
				}

				title {
					lappend text [lindex $item 0]
				}

				type {
					if {[string length $item]} {
						lappend text [list @ [set ::icon::12x12::$item]]
					} else {
						lappend text [list @ {}]
					}
					set type $item
				}

				federation {
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

			incr k
		}

		::table::insert $table $i $text
	}
}


proc TableVisit {path data} {
	variable ${path}::Vars
	variable Options

	lassign $data base mode id row
	set table $path.table

	if {$mode eq "leave"} {
		::tooltip::hide true
		return
	}

	switch $id {
		federation - title - type {}
		sex { if {!$Options(include-type)} { return } }
		default { return }
	}

	if {$id eq "sex"} {
		set col [lsearch -exact $Vars(columns) type]
	} else {
		set col [lsearch -exact $Vars(columns) $id]
	}

	set view [{*}$Vars(viewcmd) $base]
	set row  [::scrolledtable::rowToIndex $table $row]
	set item [::scidb::db::get playerInfo $row $view $base $col]

	if {[string length $item] == 0} { return }

	switch $id {
		federation	{ set tip [::country::name $item] }
		title			{ set tip $::titlebox::mc::Title([lindex $item 0]) }
		type			{ set tip $::gametable::mc::PlayerType($item) }

		sex { 
			if {$item eq "program"} {
				set tip $::gametable::mc::PlayerType(program)
			} else {
				set tip ""
			}
		}
	}

	if {[string length $tip]} {
		::tooltip::show $table $tip
	}
}


proc SortColumn {path id dir} {
	variable ${path}::Vars
	variable Options

	::widget::busyCursor on
	set base [::scrolledtable::base $path.table]
	set view [{*}$Vars(viewcmd) $base]
	set table $path.table
	set ratings [list $Options(rating1:type) $Options(rating2:type)]
	set see 0
	set selection [::scrolledtable::selection $table]
	if {$selection >= 0 && [::scrolledtable::selectionIsVisible? $table]} { set see 1 }
	if {$dir eq "reverse"} {
		::scidb::db::reverse player $base $view
	} else {
		set options [list -ratings $ratings]
		if {[string match {rating*} $id] && $Options($id:which) eq "latest"} {
			lappend options -latest
		}
		if {$dir eq "descending"} { lappend options -descending }
		set column [::scrolledtable::columnNo $table $id]
		if {$column > 1} { incr column -1 }
		::scidb::db::sort player $base $column $view {*}$options
	}
	if {$selection >= 0} {
		set selection [::scidb::db::get lookupPlayer $selection $view $base]
	}
	::widget::busyCursor off
	::scrolledtable::updateColumn $table $selection $see
}


proc Find {path combo args} {
	variable ${path}::Vars
	variable Find

	set value $Vars(find-current)
	if {[string length $value] == 0} { return }
	set base [::scrolledtable::base $path.table]
	set view [{*}$Vars(viewcmd) $base]
	set i [::scidb::view::find player $base $view $value]
	if {[llength $args] == 0} {
		if {[string length $value] > 2} {
			lappend Find $value
			set Find [lsort -dictionary -increasing -unique $Find]
			::toolbar::childconfigure $combo -values $Find
		}
		if {$i >= 0} {
			::scrolledtable::see $path.table $i
			::scrolledtable::focus $path.table
		} else {
			::dialog::info -parent [::toolbar::lookupChild $combo] -message $mc::NotFound
		}
	} elseif {$i >= 0} {
		::scrolledtable::see $path.table $i
	}
}


proc Clear {path combo} {
	variable ${path}::Vars
	variable Find

	set Find {}
	::toolbar::childconfigure $combo -values {}
	set Vars(find-current) {}
}


proc ShowInfo {path x y} {
	variable ${path}::Vars

	set table $path.table
	set index [::scrolledtable::at $table $y]
	if {![string is digit $index]} { return }
	::scrolledtable::focus $table
	::scrolledtable::activate $table [::scrolledtable::indexToRow $table $index]
	set base [::scrolledtable::base $table]
	set view [{*}$Vars(viewcmd) $base]
	set info [scidb::db::get playerInfo $index $view $base -card -ratings {Elo Elo}]
	::playercard::popupInfo $path $info
}


proc HideInfo {path} {
	::playercard::popdownInfo $path
}


proc PopupMenu {table menu base index} {
	set path [winfo parent $table]
	variable ${path}::Vars
	variable Options

	if {![string is digit $index]} { return }

	set view  [{*}$Vars(viewcmd) $base]
	set info  [scidb::db::get playerInfo $index $view $base -info]

	set playerIndex [scidb::db::get playerIndex $index $view $base]
	popupMenu $menu $base $info $playerIndex
}


proc WriteOptions {chan} {
	::options::writeList $chan [namespace current]::Find
	::options::writeItem $chan [namespace current]::Options
}

::options::hookWriter [namespace current]::WriteOptions


namespace eval icon {
namespace eval 12x12 {

set I_Type [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAQAAAD8fJRsAAAAAmJLR0QAAKqNIzIAAAEESURB
	VBjTY2AAAj0gTk1OfKzz3rzFhc2aAQ4sGAxlkq+l/Ff9b/LW2sIGIaHFoKWv/kb+v8p/0z+2
	obYICXkGeRn524r/rf+Hfo61jUFIKDOIsBgsMf7v8z/3XLV4OUKCA2iYRpDRb5//4fU2DNNg
	wjwMLEzSaroTbP66/zdao2AsySoHEnZl8BYK69J7ZPzP93/gf8v/eq81F6oqqjMweDA4hqX9
	Dv4f9D/kf/B/v//u/23/GxU7MDC4M5hW+f9v+l//v/p/1f+S/5lAfY6zgUbFMRjUOv4o+lfz
	vxYIa/4X/Xf6bTRfgpVBjUFGVDXMa0r6gfzLBddyjocs0kyUknNhAACyuV8yGfi7+AAAAABJ
	RU5ErkJggg==
}]

set I_PlayerInfo [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAQAAAD8fJRsAAAAAmJLR0QA/4ePzL8AAAB2SURB
	VBgZbcE9DsFgAADQRyJqsUnayRHEJSwSu8TPIWow6j0MtbhBF9FVHMEJDCajRWqRSL7Pe/yM
	VDZaIoVGrScyVZv7o22gK9KXu8oFUqWHRiGwcHD0MhFIZC5uUpGxp9JQJrD2tneyFNhp3G0l
	AjNnKx1fH6/zGA8ObbOQAAAAAElFTkSuQmCC
}]

set I_Sex $::icon::12x12::yinyang

set check [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABmJLR0QA/wD/AP+gvaeTAAAA
	CXBIWXMAAABIAAAASABGyWs+AAABuklEQVQoz32QP2gTUQCHf++9u8tdcjnOIz1qsUVNUilY
	KlYtCoKTi/9ABEWwq4OB6ORUF10srYNSkIqTi9pFRFF0F5QKhVoKNkpEKcY2ofGSy7s/7163
	ghD7zb9v+H0M25DeZ6eNXrMAhnXRigAAbDtBL5rjow/Ove3vL1y283aee/4v5X/j7IBN3dN7
	yr2HhsjY2JFBs+oN3kJptbtAANqnXXHH88MSApWlL3JubvJ2c2TjnqJaKThDbg9RaQ9vBV83
	Fn7HVt4x7EvuHbKD4k+lIt88e329bTVn7PumoEbRLKtnSE2/qi6pI+yFklFhHLSuWRdyu/zV
	BuafvLzbcbwZbVqK+nINiozwjmoU+t4UkmPiVJB1RpUCuxl7HN8fL87GB8QEKYeiUw8AABT1
	ZLn9yf+AEFBdFeG31sPMiWzu56OVp7wYlMIbf2PRjLfusdDjyFiWYxzVT5Ishb7b6Gu8X//M
	j4vzdCoORDWEFHJLoAAgIOejSggqCfgKX+P7xUUyG/nhgi+R/BuQAQATpIaULPEqDxo7W2e1
	j2wxftWRSSy6FQdSuTQUWzscudEaBsiP6HlbykSiG5sKg7NehOto0gAAAABJRU5ErkJggg==
}]

} ;# namespace 12x12
} ;# namespace icon
} ;# namespace playertable

# vi:set ts=3 sw=3:
