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

::util::source variation-tool

namespace eval application {
namespace eval vars {
namespace eval mc {


} ;# namespace mc

#		ID   			Adjustment	Min	Max	Width	Stretch	Removable	Ellipsis	Color
#	----------------------------------------------------------------------------------------
set Columns {
	{ eco					left		4		 4		 4			0			1			0			darkgreen	}
	{ frequency			right		5		10		 9			0			1			0			{}				}
	{ line				left	  20		 0	   20			1			0			1			{}				}
}

array set Options {
	-background	variation,background
	-emphasize	variation,emphasize
	-stripes		variation,stripes
}

array set Defaults {
}

array set Vars {
}


proc build {parent menu width height} {
	variable ::ratingbox::ratings
	variable Columns
	variable Options
	variable Vars

	set top [::ttk::frame $parent.vars]
	pack $top -fill both -expand yes

	set tb $top.table
	set sb $top.scrollbar
	set sq $top.square

	::table::table $tb \
		-listmode 1 \
		-fixedrows 1 \
		-moveable 1 \
		-setgrid 0 \
		-takefocus 0 \
		-fillcolumn end \
		-stripes {} \
		-fullstripes 0 \
		-background $Options(-background) \
		-pady {1 0} \
		-highlightcolor $Options(-emphasize) \
		;
	::table::setColumnBackground $tb tail \
		[::colors::lookup $Options(-stripes)] [::colors::lookup $Options(-background)]
	::table::setScrollCommand $tb [list $sb set]
	::ttk::scrollbar $sb  \
		-orient vertical \
		-takefocus 0     \
		-command [namespace code [list $tb.t yview]] \
		;
	bind $sb <Any-Button> [list ::tooltip::hide]
	::ttk::frame $sq -borderwidth 1 -relief sunken

	grid $tb -row 0 -column 0 -rowspan 2 -sticky nsew
	grid $sb -row 0 -column 1 -rowspan 2 -sticky ns
	grid rowconfigure $top 0 -weight 1
	grid columnconfigure $top 0 -weight 1

	set Vars(styles) {}
	$tb.t element create elemTotal rect -fill [::colors::lookup $Options(-emphasize)]
	set padx $::table::options(element:padding)

	foreach col $Columns {
		lassign $col id adjustment minwidth maxwidth width stretch removable ellipsis color

		set ivar [namespace current]::I_[string toupper $id 0 0]
		set fvar [namespace current]::mc::F_[string toupper $id 0 0]
		set tvar [namespace current]::mc::T_[string toupper $id 0 0]
		if {![info exists $tvar]} { set tvar {} }
		if {![info exists $fvar]} { set fvar $tvar }
		if {![info exists $ivar]} { set ivar {} } else { set ivar [set $ivar] }

		set menu {}
		lappend menu [list checkbutton \
			-command [namespace code [list SortColumn $tb]] \
			-labelvar ::gametable::mc::SortAscending \
			-variable [namespace current]::Options(sort:column) \
			-onvalue $value \
			]
		lappend menu { separator }

		::table::addcol $tb $id \
			-justify $adjustment \
			-minwidth $minwidth \
			-maxwidth $maxwidth \
			-width $width \
			-stretch $stretch \
			-removable $removable \
			-ellipsis $ellipsis \
			-visible $visible \
			-foreground $color \
			-menu $menu \
			-image $ivar \
			-textvar $fvar \
			-tooltipvar $tvar \
			-stripes $Options(-stripes) \
			;

		if {$ellipsis} { set squeeze "x" } else { set squeeze "" }

		$tb.t style create styTotal$id
		$tb.t style elements styTotal$id [list elemTotal elemImg elemIco elemTxt$id]
		::table::setDefaultLayout $tb $id styTotal$id
		$tb.t style layout styTotal$id elemTotal -union elemTxt$id -iexpand nswe
		lappend Vars(styles) $id styTotal$id
	}

	::table::configure $tb line -secondfont [list [list $::font::figurine(text:normal) 9812 9823]]

	::table::bind $tb <ButtonPress-1>	[namespace code [list Select $tb %x %y]]
	::table::bind $tb <Button1-Motion>	[namespace code [list Motion1 $tb %x %y]]
	::table::bind $tb <ButtonRelease-1>	[namespace code [list Activate $tb]]
	::table::bind $tb <ButtonRelease-3>	+[list set [namespace current]::Vars(button) 0]
	::table::bind $tb <Leave>				[namespace code [list Leave %W]]
	::table::bind $tb <Motion>				[namespace code [list Motion %W %x %y]]

	foreach seq {	Shift-Up Shift-Down ButtonPress-1 ButtonPress-3
						ButtonRelease-3 Double-Button-1 Leave Motion} {
		::table::bind $tb <$seq> {+ break }
	}

	bind $tb <<TableScrollbar>>	[namespace code [list Scrollbar $tb %d]]
	bind $tb <<TableVisit>>			[namespace code [list VisitItem $tb %d]]
	bind $tb <<TableFill>>			[namespace code [list FillTable $tb]]
	bind $tb <<TableMenu>>			[namespace code [list PopupMenu $tb %X %Y]]
	bind $tb <Destroy>				[array unset [namespace current]::Vars]

	TreeCtrl::finishBindings $tb

	$tb.t element create rectDivider rect -fill blue -height 1
	$tb.t style create styLine
	$tb.t style elements styLine {rectDivider}
	$tb.t style layout styLine rectDivider -pady {3 2} -iexpand x

	set Vars(table) $tb
	set Vars(data) {}
}


proc activate {w menu flag} {
	variable Vars

	::toolbar::activate $w $flag
	set Vars(hidden) [expr {!$flag}]
}


proc columnIndex {name} {
	variable Columns

	set n [lsearch -exact -index 0 $Columns $name]

	if {$n <= 1} { return 0 }
	if {$n == 2} { return 1 }
	if {$n <= 4} { return 2 }

	return [incr n -2]
}


proc update {position} {
	variable Vars

	if {![info exists Vars(table)]} { return }
	if {![winfo exists $Vars(table)]} { return }

	# TODO
}


proc View {pane base} {
	set view [::scidb::tree::view]
	if {$view == -1} { return 0 }
	return $view
}


proc StartSearch {table} {
	variable Vars

	if {[llength [::scidb::vars::get]] == 0} { return }

	if {$Vars(searching)} {
		set Vars(searching) 0
		::scidb::vars::stop
		place forget $Vars(progress)
		ConfigSearchButton $table Start
		# show "interrupted by user"
	} else {
		DoSearch $table
	}
}


proc Close {table base} {
	variable Vars

	if {$base eq [::scidb::vars::get]} {
		set Vars(data) {}
		::table::clear $table
		::table::setHeight $table 0
		# TODO: clear vars game list
	}
}


proc SortColumn {table} {
	FetchResult $table true
}


proc DoSelection {table} {
	variable Vars

	if {$Vars(hidden)} { return }

	lassign [winfo pointerxy $table] x y
	set x [expr {$x - [winfo rootx $table]}]
	set y [expr {$y - [winfo rooty $table]}]
	lassign [::table::identify $table $x $y] row
	set nrows [llength $Vars(data)]

	if {$row + 1 < $nrows} {
		::table::activate $table $row true
		set Vars(active) $row
	}
}


proc VisitItem {table data} {
	variable Vars

	lassign $data mode id row
	set nrows [llength $Vars(data)]
	set Vars(active) -1

	if {$row + 1 < $nrows} {
		if {$mode eq "enter"} {
			if {$Vars(enabled)} {
				::table::activate $table $row true
			}
			set Vars(active) $row
		} else {
			::table::activate $table none true
		}
	}

	if {$nrows <= 1 || $row + 1 == $nrows} { return }

	if {$mode eq "leave"} {
		::tooltip::hide
	} elseif {$id eq "eco"} {
		if {$row == $nrows} { incr row -1 }
		set value [lindex $Vars(data) $row [columnIndex $id]]
		set item {}

		set opening [::scidb::app::lookup ecoCode $value]
		lassign $opening long short
		set vars [lrange $opening 2 end]
		if {[llength $vars} {
			set item [::mc::translateEco $short]
			foreach var $vars { append item ", " [::mc::translateEco $var] }
		} else {
			set item [::mc::translateEco $long]
		}

		if {[string length $item]} {
			::tooltip::show $table $item
		}
	}
}


proc ToggleTransparentBar {table} {
	variable [namespace parent]::tree::Bars

	foreach key [array names Bars] {
		image delete $Bars($key)
	}
	array unset Bars
	FetchResult $table true
}


proc FetchResult {table {force false}} {
	variable Options
	variable Vars

	set options {}
	if {[llength $Options(sort:column)]} {
		lappend options -sort [columnIndex $Options(sort:column)]
	}
	set state [::scidb::vars::finish $Options(rating:type) $Options(search:mode) {*}$options]

	if {$force || $state ne "unchanged"} {
		set Vars(data) [::scidb::vars::fetch]
		set nrows [llength $Vars(data)]
		if {$nrows == 2} { set nrows 1 } elseif {$nrows} { incr nrows }
		set active [::table::active $table]

		::table::clear $table
		::table::setHeight $table 0

		if {$nrows} {
			::table::setHeight $table $nrows [namespace current]::SetItemStyle
			FillTable $table

			if {0 <= $active && $active < max(1, $nrows - 1)} {
				::table::activate $table $active true
			}
		}
	}

	set Vars(activated) 0
}


proc SetItemStyle {table item row} {
	variable Vars
	variable Columns

	set nrows [expr {[llength $Vars(data)] + 1}]

	if {$row == [expr {$nrows - 2}]} {
		set style {}
		foreach col $Columns { lappend style [lindex $col 0] styLine }
		$table.t item style set $item {*}$style
		$table.t item enabled $item false
	} elseif {$row == [expr {$nrows - 1}]} {
		$table.t item style set $item {*}$Vars(styles)
	} else {
		$table.t item style set $item {*}[::table::defaultStyles $table]
	}
}


proc Format {value} {
	return [expr {$value/10}],[expr {$value%10}]
}


proc FillTable {table} {
	variable Columns
	variable Vars
	variable [namespace parent]::tree::Bars

	if {[llength $Vars(data)] == 0} { return }

	set total [lindex $Vars(data) end [columnIndex frequency]]
	set nrows [llength $Vars(data)]
	set stm [::scidb::pos::stm]
	set row 1

	foreach rowData $Vars(data) {
		set col 0
		set text {}

		foreach entry $Columns {
			set id [lindex $entry 0]
			set item [lindex $rowData $col]
			incr col

			switch $id {
				line			{ lappend text [::font::translate $item] }
				eco			{ lappend text [string range $item 0 2] }
				frequency	{ lappend text [::locale::formatNumber $item] }
			}
		}

		::table::insert $table [expr {$row - 1}] $text

		if {$nrows == 2} { return }

		if {[incr row] == $nrows} {
			::table::insert $table $row [lrepeat [llength $Columns] {}]
			incr row
		}
	}

	catch { ::table::see $table 0 }
	DoSelection $table
}


proc Select {table x y} {
	variable Vars

	set Vars(button) 1
	if {$Vars(activated)} { return }

	::tooltip::disable
	lassign [::table::identify $table $x $y] row column

	if {$row == -1} {
		::table::Highlight $table $x $y
	} else {
		set nrows [llength $Vars(data)]

		if {0 <= $row && ($nrows == 1 || $row < $nrows - 1)} {
			set move [::scidb::vars::move $row]
			if {[string length $move]} {
				set Vars(selected) $row
				::table::select $table $row
			}
		}
	}
}


proc Motion1 {table x y} {
	variable Vars

	if {!$Vars(enabled)} { return }
	if {$Vars(activated)} { return }
	if {$Vars(selected) == -1} { return }

	lassign [::table::identify $table $x $y] row column

	if {$row < 0} {
		::table::activate $table none
		::table::select $table none
		set offs [::table::scrolldistance $table $y]

		if {$offs != 0} {
			if {$offs < 0} {
				set Vars(dir) -1
			} else {	;# offs > 0
				set Vars(dir) +1
			}

			set Vars(interval) [expr {300/max(int(abs($offs)/5.0 + 0.5), 1)}]

			if {![info exists Vars(timer)]} {
				set Vars(timer) [after $Vars(interval) [namespace code [list Scroll $table]]]
			}
		} elseif {[info exists Vars(timer)]} {
			after cancel $Vars(timer)
			unset Vars(timer)
		}
	} else {
		if {[info exists Vars(timer)]} {
			after cancel $Vars(timer)
			unset Vars(timer)
		}
		if {$row == $Vars(selected)} {
			if {$row != [::table::selection $table]} {
				::table::select $table $row
			}
		} elseif {$row >= 0} {
			if {$Vars(selected) == [::table::selection $table]} {
				::table::select $table none
			}
		}
	}

	TreeCtrl::MotionInItems $table.t $x $y
}


proc Motion {w x y} {
	variable Vars

	if {$Vars(button) != 2} {
		TreeCtrl::CursorCheck $w $x $y
		TreeCtrl::MotionInHeader $w $x $y
		TreeCtrl::MotionInItems $w $x $y
	}
}


proc Leave {w} {
	variable Vars

	if {$Vars(button) != 2} {
		TreeCtrl::CursorCancel $w
		TreeCtrl::MotionInHeader $w
		TreeCtrl::MotionInItems $w
	}
}


proc Scroll {table} {
	variable Vars

	if {[info exists Vars(dir)]} {
		$table.t yview scroll $Vars(dir) units
		set Vars(timer) [after $Vars(interval) [namespace code [list Scroll $table]]]
	}
}


proc Activate {table} {
	variable Vars

	set Vars(button) 0
	::tooltip::enable

	if {[info exists Vars(dir)]} {
		catch { after kill $Vars(timer) }
		unset -nocomplain Vars(dir)
		unset -nocomplain Vars(timer)
		unset -nocomplain Vars(interval)
	}

	if {$Vars(activated)} { return }
	if {$Vars(selected) == -1} { return }

	set Vars(activated) 1
	
	if {$Vars(selected) == [::table::selection $table]} {
		set move [::scidb::vars::move $Vars(selected)]
		::move::addMove menu $move -nomovecmd [list set [namespace current]::Vars(activated)]
	} else {
		set Vars(activated) 0
	}

	set Vars(selected) -1
	::table::select $table none
}


proc Scrollbar {table state} {
	set parent [winfo parent $table]
	set sq $parent.square
	set sb $parent.scrollbar

	if {$state eq "hide"} {
		grid forget $sq
		grid $sb -row 0 -column 1 -rowspan 2 -sticky ns
	} elseif {$sq ni [grid slaves $parent]} {
		set size [winfo width $sb]
		$sq configure -width $size -height $size
		grid $sb -row 0 -column 1 -rowspan 1 -sticky ns
		grid $sq -row 1 -column 1
	}
}


proc PopupMenu {table x y} {
	variable ::scidb::clipbaseName
	variable Vars
	variable _Current

	set Vars(button) 3
	set m $table.popup_menu
	if {[winfo exists $m]} { destroy $m }
	menu $m -tearoff false
	catch { wm attributes $m -type popup_menu }

	$m add command \
		-label $mc::StartSearch \
		-command [namespace code [list StartSearch $table]] \
		;
	$m add separator
	foreach mode {exact fast} {
		set text [set mc::Use[string toupper $mode 0 0]Mode]
		$m add radiobutton \
			-label $text \
			-variable [namespace current]::Options(search:mode) \
			-value $mode \
			;
		::theme::configureRadioEntry $m $text
	}
	$m add separator
	$m add checkbutton \
		-label $mc::AutomaticSearch \
		-variable [namespace current]::Options(search:automatic) \
		;
	::theme::configureCheckEntry $m
	$m add separator
	$m add checkbutton \
		-label $mc::LockReferenceBase \
		-variable [namespace current]::Options(base:lock) \
		;
	::theme::configureCheckEntry $m
	$m add separator

	set n [menu $m.switch -tearoff false]
	$m add cascade -menu $n -label $mc::ChooseReferenceBase

	set list {}
	foreach base [::scidb::vars::list] {
		if {$base eq $Vars(current)} { set _Current $base }
		lappend list [list [::util::databaseName $base] $base]
	}
	if {$Vars(current) eq $clipbaseName} {
		set _Current $clipbaseName
	}

	set text $::util::clipbaseName
	$n add radiobutton \
		-label $text \
		-value $clipbaseName \
		-variable [namespace current]::_Current \
		-command [list ::scidb::vars::set $clipbaseName] \
		;
	::theme::configureRadioEntry $n $text
	foreach base [lsort -dictionary -index 0 $list] {
		lassign $base text value
		$n add radiobutton \
			-label $text \
			-value $value \
			-variable [namespace current]::_Current \
			-command [list ::scidb::vars::set $value] \
			;
		::theme::configureRadioEntry $n $text
	}

	tk_popup $m $x $y
}


proc WriteOptions {chan} {
	::options::writeItem $chan [namespace current]::Options
}

::options::hookWriter [namespace current]::WriteOptions

} ;# namespace vars
} ;# namespace application

# vi:set ts=3 sw=3:
