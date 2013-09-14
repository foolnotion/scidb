# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
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

namespace eval scrolledtable {
namespace eval mc {
	set Sort		"Sort"
	set Reverse	"Reverse"
} ;# namespace mc

array set Defaults {
	background		scrolledtable,background
	stripes			scrolledtable,stripes
	highlight		scrolledtable,highlight
	separatorcolor	scrolledtable,separatorcolor
	scale:padx		30
	scale:pady		4
}

# alternative color themes:
#		background #fafafa stripes #e0e8f0
#		background white stripes #fafafa

namespace import ::tcl::mathfunc::min
namespace import ::tcl::mathfunc::max


proc build {path columns args} {
	variable Defaults

	set opts(-background) $Defaults(background)
	set opts(-stripes) $Defaults(stripes)

	array set opts {
		-useScale		0
		-layout			bottom
		-lock				{}
		-popupcmd		{}
		-takefocus		1
		-listmode		0
		-sortable		1
		-fixedrows		0
		-configurable	no
		-height			10
	}
	array set opts $args

	ttk::frame $path -takefocus 0
	set top [ttk::frame $path.top -takefocus 0]
	pack $top -fill both -expand yes

	set tb $top.table
	set sb $top.scrollbar
	set sc $top.scale
	set sq $top.square

	namespace eval [namespace current]::$tb {}
	variable [namespace current]::${tb}::Vars

	table::table $tb                                  \
		-moveable 1                                    \
		-takefocus $opts(-takefocus)                   \
		-fillcolumn end                                \
		-stripes $opts(-stripes)                       \
		-highlightcolor $Defaults(highlight)           \
		-background $opts(-background)                 \
		-separatorcolor $Defaults(separatorcolor)      \
		-listmode $opts(-listmode)                     \
		-fixedrows $opts(-fixedrows)                   \
		-sortable $opts(-sortable)                     \
		-labelbackground theme,background              \
		-configurable $opts(-configurable)             \
		-height $opts(-height)                         \
		;
	::bind $tb <Destroy> [namespace code [list TableOptions $tb]]
	
	if {$opts(-useScale)} {
		tk::scale $sc                                    \
			-orient horizontal                            \
			-from 0                                       \
			-showvalue 0                                  \
			-takefocus 0                                  \
			-width 10                                     \
			-command [namespace code [list SetStart $tb]] \
			;
		::bind $sc <ButtonRelease-1> [list ::table::focus $tb]
	}
	
	ttk::scrollbar $sb  \
		-orient vertical \
		-takefocus 0     \
		-command [namespace code [list Scroll $tb]] \
		;
	::bind $sb <Any-Button> [list ::tooltip::hide]
	if {$opts(-takefocus)} {
		::bind $sb <ButtonPress-1> [list ::table::focus $tb]
	}
	ttk::frame $sq -borderwidth 1 -relief sunken

	if {!$opts(-useScale) || $opts(-layout) eq "right"} {
		grid $sb -column 1 -row 0 -rowspan 2 -sticky ns
		grid rowconfigure $top {2 4} -minsize 0
	} else {
		grid $sc \
			-column 0 \
			-row 3 \
			-columnspan 2 \
			-sticky ew \
			-padx $Defaults(scale:padx) \
			;
		grid rowconfigure $top {2 4} -minsize $Defaults(scale:pady)
	}
	grid $tb -column 0 -row 0 -rowspan 2 -sticky nsew

	grid columnconfigure $top 0 -weight 1
	grid rowconfigure $top 0 -weight 1

	array set Vars {
		start			0
		height		0
		size			0
		minheight	0
		selection	-1
		active		-1
		minsize		{}
		columns		{}
		base			{}
		after			{}
	}

	set Vars(scale)		$sc
	set Vars(scrollbar)	$sb
	set Vars(popupcmd)	$opts(-popupcmd)
	set Vars(lock)			$opts(-lock)
	set Vars(takefocus)	$opts(-takefocus)
	set Vars(theme)		[::theme::currentTheme]
	if {$opts(-useScale)} {
		set Vars(slider)	[$sc cget -sliderlength]
		set Vars(layout)	$opts(-layout)
	} else {
		set Vars(layout)	right
	}

	foreach {id args} $columns {
		if {$Vars(lock) eq $id} { lappend args -lock left }
		::table::addcol $tb $id {*}$args
		lappend Vars(columns) $id
	}

	::bind $tb <<TableFill>>					 [namespace code [list TableFill $tb %d]]
	::bind $tb <<TableResized>>				 [namespace code [list TableResized $tb %d]]
	::bind $tb <<TableSelected>>				 [namespace code [list TableSelected $tb %d]]
	::bind $tb <<TableInvoked>>				 [namespace code [list TableInvoked $tb %d]]
	::bind $tb <<TableActivated>>				 [namespace code [list TableActivated $tb %d]]
	::bind $tb <<TableScroll>>					 [namespace code [list TableScroll $tb %d]]
	::bind $tb <<TableMinSize>>				 [namespace code [list TableMinSize $tb %d]]
	::bind $tb <<TableOptions>>				 [namespace code [list TableOptions $tb]]
	::bind $tb <<TableVisit>>					 [namespace code [list TableVisit $tb %d]]
	::bind $tb <<TableHide>>					 [namespace code [list TableHide $tb %d]]
	::bind $tb <<TableShow>>					 [namespace code [list TableShow $tb %d]]
	::bind $tb <<TableScrollbar>>				 [namespace code [list TableScrollbar $tb %d]]
#	::bind $sb <<ThemeChanged>>				 [namespace code [list GenerateTableMinSizeEvent $tb]]
#	::bind $sb <Destroy>							+[list namespace delete [namespace current]::$tb]
	::bind $sb <Configure>						 [namespace code [list ConfigureScrollbar $tb]]
	if {$opts(-useScale)} {
		::bind $tb <<TableScroll>>				+[namespace code [list ConfigureScale $tb]]
		::bind $sc <Configure>					 [namespace code [list ConfigureScale $tb]]
	}
	::table::bind $tb <Shift-Down>			 [namespace code [list ShiftScroll $tb down]]
	::table::bind $tb <Shift-Up>				 [namespace code [list ShiftScroll $tb up]]
	::table::bind $tb <Shift-Prior>			 [namespace code [list ShiftScroll $tb prior]]
	::table::bind $tb <Shift-Next>			 [namespace code [list ShiftScroll $tb next]]

	::table::bind $tb <ButtonPress-1>		+[namespace code [list ScanMark $tb %x %y]]
	::table::bind $tb <Button1-Motion>		 [namespace code [list ScanDrag $tb %x %y]]
	::table::bind $tb <ButtonRelease-1>		+[namespace code [list MoveRow $tb %x %y]]

	if {[tk windowingsystem] eq "x11"} {
		::table::bind $tb <Button-4> [namespace code [list scroll $path up 10]]
		::table::bind $tb <Button-5> [namespace code [list scroll $path down 10]]
		::table::bind $tb <Shift-Button-4> [namespace code [list scroll $path back]]
		::table::bind $tb <Shift-Button-5> [namespace code [list scroll $path forward]]
	} else {
		::table::bind $tb <MouseWheel> [namespace code [list \
			if {%D < 0} [list scroll $path up 10] else [list scroll $path down 10]]]
		::table::bind $tb <Shift-MouseWheel> [namespace code [list \
			if {%D < 0} [list scroll $path back] else [list scroll $path forward]]]
	}

	foreach seq {<Shift-Up> <Shift-Down> <ButtonPress-1> <ButtonRelease-1>} {
		::table::bind $tb $seq {+ break }
	}

	if {[llength $Vars(popupcmd)]} {
		::table::bind $tb <ButtonPress-3> +[namespace code [list PopupMenu $tb %y]]
	}

	TableResized $tb 0
	::table::activate $tb $Vars(active)
#	set Vars(options) [::table::getOptions $tb]
	return $tb
}


proc update {path base variant size} {
	set table $path.top.table
	variable ${table}::Vars

	if {![info exists Vars(variant)]} {
		set Vars(variant) $variant
		set Vars(base) $base
	}
	if {$Vars(base) ne $base || $Vars(variant) ne $variant} {
		::table::activate $table none
		::table::select $table none

		if {[llength $Vars(base)]} {
			set Vars(start:$Vars(base):$Vars(variant)) $Vars(start)
			set Vars(active:$Vars(base):$Vars(variant)) $Vars(active)
			set Vars(selection:$Vars(base):$Vars(variant)) $Vars(selection)
		}
	} else {
		set Vars(start:$Vars(base):$Vars(variant)) $Vars(start)
		set Vars(active:$Vars(base):$Vars(variant)) $Vars(active)
		set Vars(selection:$Vars(base):$Vars(variant)) $Vars(selection)
	}
	if {![info exists Vars(start:$base:$variant)]} {
		set Vars(start:$base:$variant) 0
		set Vars(active:$base:$variant) -1
		set Vars(selection:$base:$variant) -1
	}
	set oldSize $Vars(size)
	set Vars(size) $size
	::table::clear $table $Vars(size) $Vars(height)

	set Vars(start) [expr {max(0, min($Vars(start:$base:$variant), $Vars(size) - $Vars(height)))}]
	if {[string is integer -strict $Vars(active:$base:$variant)]} {
		set Vars(active) [expr {min($size - 1, $Vars(active:$base:$variant))}]
	}
	if {[string is integer -strict $Vars(selection:$base:$variant)]} {
		set Vars(selection) [expr {min($size - 1, $Vars(selection:$base:$variant))}]
	}
	set Vars(base) $base
	set Vars(variant) $variant

	set height [expr {min([::table::height $table], $Vars(height))}]
	TableResized $table $height
	# if not already done by TableResized
	if {$Vars(start) + $height < $Vars(size)} { TableFill $table }
}


proc base {path} {
	return [set [namespace current]::${path}.top.table::Vars(base)]
}


proc variant {path} {
	return [set [namespace current]::${path}.top.table::Vars(variant)]
}


proc tablePath {path} {
	return [::table::tablePath $path.top.table]
}


proc visibleColumns {path} {
	return [::table::visibleColumns $path.top.table]
}


proc forget {path base variant} {
	set table $path.top.table
	variable ${table}::Vars

	if {$Vars(base) eq $base && $Vars(variant) eq $variant} {
		array unset Vars *:$base:$variant
		set Vars(base) {}
		set Vars(variant) {}
		set Vars(size) 0
	}
}


proc scroll {path position {units 1}} {
	set table $path.top.table
	variable ${table}::Vars

	if {$Vars(size) == 0} { return }

	switch $position {
		back			{ SetStart $table [expr {$Vars(start) - $Vars(height)}] }
		forward		{ SetStart $table [expr {$Vars(start) + $Vars(height)}] }
		selection	{ if {$Vars(selection) != -1} { TableScroll $table see } }
		home			{ TableScroll $table home }
		end			{ TableScroll $table end }

		up - down	{
			if {$units > $Vars(height)/2} { set units [expr {max(1, $Vars(height)/2)}] }
			if {$position eq "up"} { set dir [expr {-$units}] } else { set dir $units }
			set start [expr {max(0, min($Vars(size) - 1, $Vars(start) + $dir))}]
			if {$start == $Vars(start)} { return }
			::tooltip::hide
			SetStart $table $start
		}

		default		{
			if {[string is integer -strict $position]} {
				set start [expr {max(0, min($Vars(size) - 1, $position))}]
				if {$start == $Vars(start)} { return }
				::tooltip::hide
				SetStart $table $start
			} else {
				SetStart $table $position
			}
		}
	}

	ConfigureScale $table
}


proc see {path position} {
	set table $path.top.table
	variable ${table}::Vars

	if {$Vars(size) == 0} { return }
	if {![expr {$Vars(start) <= $position && $position <= $Vars(start) + $Vars(height)}]} {
		set Vars(start) [expr {min($Vars(size) - $Vars(height), $position)}]
		TableFill $table
		ConfigureScrollbar $table
		ConfigureScale $table
	}
	activate $path [expr {$position - $Vars(start)}]
}


proc refresh {path} {
	set table $path.top.table
	variable ${table}::Vars

	TableFill $table
}


proc clear {path {first -1} {last -1}} {
	set table $path.top.table
	variable ${table}::Vars

	::table::clear $table $first $last
	ConfigureScrollbar $table
	ConfigureScale $table
}


proc clearColumn {path id} {
	::table::clearColumn $path.top.table $id
}


proc fill {path first {last -1}} {
	set table $path.top.table
	variable ${table}::Vars

	if {$last == -1} { set last $first }
	set start $Vars(start)
	TableFill $table [list [expr {$first - $start}] [expr {$last - $start}]] false
}


proc selection {path} {
	set table $path.top.table
	variable ${table}::Vars

	return $Vars(selection)
}


proc active {path} {
	set table $path.top.table
	variable ${table}::Vars

	return $Vars(active)
}


proc index {path} {
	set table $path.top.table
	variable ${table}::Vars

	if {$Vars(selection) == -1} { return -1 }
	return [expr {$Vars(start) + $Vars(selection)}]
}


proc indexToRow {path index} {
	set table $path.top.table
	variable ${table}::Vars

	return [expr {$index - $Vars(start)}]
}


proc rowToIndex {path row} {
	set table $path.top.table
	variable ${table}::Vars

	return [expr {$row + $Vars(start)}]
}


proc identify {path x y} {
	return [::table::identify $path.top.table $x $y]
}


proc scrolldistance {path y} {
	return [::table::scrolldistance $path.top.table $y]
}


proc visible? {path id} {
	return [::table::visible? $path.top.table $id]
}


proc bind {path sequence script} {
	::table::bind $path.top.table $sequence $script
}


proc configure {path id args} {
	::table::configure $path.top.table $id {*}$args
}


proc at {path y} {
	set table $path.top.table
	variable ${table}::Vars

	set row [::table::at $table $y]
	if {![string is digit -strict $row]} { return $row }
	return [expr {$row + $Vars(start)}]
}


proc getOptions {path} {
	set table $path.top.table
	variable ${table}::Vars

	if {![info exists Vars(options)]} {
		set Vars(options) [::table::getOptions $table]
	}

	return $Vars(options)
}


proc setColumnMininumWidth {path id width} {
	return [::table::setColumnMininumWidth $path.top.table $id $width]
}


proc setOptions {path options} {
	::table::setOptions $path.top.table $options
}


proc setState {path row state} {
	set table $path.top.table
	variable ${table}::Vars

	::table::setState $table [expr {$row + $Vars(start)}] $state
}


proc columnNo {path id} {
	set table $path.top.table
	variable ${table}::Vars

	return [lsearch -exact $Vars(columns) $id]
}


proc selectionIsVisible? {path} {
	set table $path.top.table
	variable ${table}::Vars

	return [expr {$Vars(start) <= $Vars(selection) && $Vars(selection) <= $Vars(start) + $Vars(height)}]
}


proc updateColumn {path selection {see 0}} {
	set table $path.top.table
	variable ${table}::Vars

	set Vars(active) -1
	set Vars(selection) $selection

	if {$see} {
		SetStart $table [expr {max(0, $Vars(selection) - $Vars(height)/2)}]
		ConfigureScale $table
		SetHighlighting $table
	} else {
		TableFill $table
	}
}


proc doSelection {path} {
	return [::table::doSelection $path.top.table]
}


proc changeLayout {path dir} {
	set table $path.top.table
	variable ${table}::Vars
	variable Defaults

	if {$Vars(layout) eq $dir} { return }
	set Vars(layout) $dir
	set parent [winfo parent $table]
	set sc ${parent}.scale
	set sb ${parent}.scrollbar
	set sq ${parent}.square
	set pady $Defaults(scale:pady)

	if {$dir eq "right"} {
		grid $sb -column 1 -row 0 -rowspan 2 -sticky ns
		grid rowconfigure $parent {2 3 4} -minsize 0
		grid forget $sc
		::update idletasks
		set width [winfo width $sb]
		set height -[expr {[winfo height $sc] + 2*$pady}]
	} else {
		grid forget $sb
		grid forget $sq
		grid $sc \
			-column 0 \
			-row 3 \
			-columnspan 2 \
			-sticky ew \
			-padx $Defaults(scale:padx) \
			;
		grid rowconfigure $parent {2 4} -minsize $Defaults(scale:pady)
		::update idletasks
		set width -[winfo width $sb]
		set height [expr {[winfo height $sc] + 2*$pady}]
	}

	return [list $width $height]
}


proc overhang {path} {
	return [::table::overhang $path.top.table]
}


proc computeHeight {path rows} {
	return [::table::computeHeight $path.top.table $rows]
}


proc linespace {path} {
	return [::table::linespace $path.top.table]
}


proc borderwidth {path} {
	return [::table::borderwidth $path.top.table]
}


proc activate {path row} {
	set table $path.top.table
	variable ${table}::Vars

	if {$row eq "none" || $row == -1 || ($row >= $Vars(start) || $Vars(start) + $Vars(height) > $row)} {
		set Vars(active) $row
		::table::activate $table $row true
	}
}


proc select {path row} {
	set table $path.top.table
	variable ${table}::Vars

	set Vars(selection) -1
	::table::select $table $row
}


proc setSelection {path row} {
	set table $path.top.table
	variable ${table}::Vars

	set Vars(selection) -1
	::table::setSelection $table $row
}


proc focus {path} {
	set table $path.top.table
	variable ${table}::Vars

	if {$Vars(takefocus)} {
		::table::focus $table
	}
}


proc setColumnJustification {path id justification} {
	::table::setColumnJustification $path.top.table $id $justification
}


proc keepFocus {path {flag {}}} {
	::table::keepFocus $path.top.table $flag
}


proc GenerateTableMinSizeEvent {table} {
	variable ${table}::Vars

	if {$Vars(theme) ne [::theme::currentTheme]} {
		after idle [event generate $table <<TableLayout>>]
		set Vars(theme) [::theme::currentTheme]
	}
}


proc ConfigureScale {table} {
	variable ${table}::Vars

	if {![winfo exists $Vars(scale)]} { return }
	set len [expr {[winfo width $Vars(scale)] - 4}]
	if {$Vars(height) > 0 && $Vars(size) > 0} {
		set len [expr {max($Vars(slider), min($len, $len*double($Vars(height))/double($Vars(size))))}]
	}
	$Vars(scale) configure -sliderlength $len
	$Vars(scale) set $Vars(start)
}


proc ConfigureScrollbar {table} {
	variable ${table}::Vars

	after idle "[namespace current]::Scroll \
		$table set \[set [namespace current]::${table}::Vars(start)\] false"
}


proc TableOptions {table} {
	variable ${table}::Vars

	set Vars(options) [::table::getOptions $table]
	event generate [winfo parent [winfo parent $table]] <<TableOptions>>
}


proc TableVisit {table data} {
	variable ${table}::Vars

	set data [list $Vars(base) $Vars(variant) {*}$data]
	event generate [winfo parent [winfo parent $table]] <<TableVisit>> -data $data
}


proc TableHide {table data} {
	event generate [winfo parent [winfo parent $table]] <<TableHide>> -data $data
}


proc TableShow {table data} {
	event generate [winfo parent [winfo parent $table]] <<TableShow>> -data $data
}


proc TableMinSize {table minsize} {
	variable ${table}::Vars
	variable Defaults

	if {[llength $minsize] == 0} { return }
	lassign $minsize minwidth minheight
	if {$Vars(layout) eq "right"} {
		incr minwidth [winfo width $Vars(scrollbar)]
	} else {
		incr minheight [expr {[winfo height $Vars(scale)] + 2*$Defaults(scale:pady)}]
	}
	set minsize [list $minwidth $minheight]
	set parent [winfo parent [winfo parent $table]]
	event generate $parent <<TableMinSize>> -data [list $minsize [::table::gridsize $table]]
}


proc TableScroll {table action} {
	variable ${table}::Vars

	::tooltip::hide
	if {$Vars(size) == 0} { return }
	set active $Vars(active)

	switch $action {
		home	{ set active 0 }
		end	{ set active [expr {$Vars(size) - 1}] }
		up		{ incr active -1 }
		down	{ incr active }
		prior	{ set active [expr {$Vars(active) - $Vars(height)}] }
		next	{ incr active $Vars(height) }
		see	{ set active $Vars(selection) }
	}

	set active [expr {max(0, min($active, $Vars(size) - 1))}]

	if {$Vars(active) >= 0} {
		set Vars(active) $active
	}

	switch $action {
		home - prior - up { set start $active }
		end - next - down { set start [expr $active - $Vars(height) + 1] }
		
		see {
			if {[::table::selection $table] == -1} {
				set start [expr {$Vars(selection) - $Vars(height)/2}]
			} else {
				set start $Vars(start)
			}
		}
	}

	if {$start != $Vars(start)} {
		SetStart $table $start
	}
}


proc TableActivated {table number} {
	variable ${table}::Vars

	if {$number == -1} {
		set Vars(active) -1
	} else {
		incr number $Vars(start)
		set Vars(active) $number

		if {$number < $Vars(start) || $Vars(start) + $Vars(height) < $number} {
			SetStart $table [expr {max(0, min($number, $Vars(size) - $Vars(height)))}]
		}
	}
}


proc TableSelected {table number} {
	variable ${table}::Vars

	set Vars(selection) [expr {$number + $Vars(start)}]
	event generate [winfo parent [winfo parent $table]] <<TableSelected>> -data $Vars(selection)
}


proc TableInvoked {table number} {
	variable ${table}::Vars
	event generate [winfo parent [winfo parent $table]] <<TableInvoked>> -data $Vars(selection)
}


proc TableResized {table height} {
	variable ${table}::Vars

	set Vars(height) $height
	if {[winfo exists $Vars(scale)]} {
		$Vars(scale) configure \
			-bigincrement $height \
			-to [expr {$Vars(size) - $height}]
		ConfigureScale $table
	}
	ConfigureScrollbar $table
	::table::select $table none
	::table::setRows $table [expr {min($height, $Vars(size))}]

	if {$Vars(start) + $height >= $Vars(size)} {
		SetStart $table $Vars(start) yes
	} else {
		SetHighlighting $table
	}

	event generate [winfo parent [winfo parent $table]] <<TableResized>> -data $height
}


proc SetStart {table start {force no}} {
	Scroll $table set $start $force
}


proc ShiftScroll {table action} {
	Scroll $table $action
	ConfigureScrollbar $table
	ConfigureScale $table
}


proc Scroll {table action args} {
	variable ${table}::Vars

	if {![winfo exists $Vars(scrollbar)]} { return }

	set force no

	switch $action {
		set		{ lassign $args start force }
		moveto	{ set start [expr {int($args*$Vars(size) + 0.5)}] }
		up			{ set start [expr {$Vars(start) - 1}] }
		down		{ set start [expr {$Vars(start) + 1}] }
		prior		{ set start [expr {$Vars(start) - $Vars(height)}] }
		next		{ set start [expr {$Vars(start) + $Vars(height)}] }

		scroll {
			lassign $args number unit
			switch $unit {
				units { set start [expr {$Vars(start) + $number}] }
				pages { set start [expr {$Vars(start) + $number*$Vars(height)}] }
			}
		}
	}

	set start [expr {max(0, min($start, $Vars(size) - $Vars(height)))}]
	set first [expr {$Vars(size) <= 1 ? 0.0 : double($start)/double($Vars(size) - 1)}]
	set last  [expr {$Vars(size) <= 1 ? 1.0 : double($start + $Vars(height))/double($Vars(size))}]
	$Vars(scrollbar) set $first $last

	if {$force} {
		set Vars(start) $start
		TableFill $table
	} elseif {$start != $Vars(start)} {
		if {abs($Vars(start) - $start) == 1} {
			::table::activate $table none
			if {$start < $Vars(start)} {
				::table::scroll $table down
				set Vars(start) $start
				TableFill $table {0 1}
			} else {
				::table::scroll $table up
				set Vars(start) $start
				TableFill $table [list [expr {$Vars(height) - 1}] $Vars(height)]
			}
		} else {
			set Vars(start) $start
			TableFill $table
		}
	}
}


proc TableFill {table {range {0 100000}} {hilite true}} {
	variable ${table}::Vars

	if {$Vars(size) == 0} { return }
	::table::select $table none
	lassign $range first last
	set last [min $last $Vars(height)]
	if {$first < 0} { set first 0 }
	if {$last < $first} { return }
	if {$Vars(start) + $first >= $Vars(size)} { return }
	set last [expr {min($last, $Vars(size))}]
	event generate [winfo parent [winfo parent $table]] <<TableFill>> \
		-data [list $table $Vars(base) $Vars(variant) $Vars(start) $first $last $Vars(columns)]
	if {$hilite} { SetHighlighting $table }
}


proc SetHighlighting {table} {
	variable ${table}::Vars

	set start $Vars(start)

	if {	$Vars(active) >= 0
		&& $start <= $Vars(active)
		&& $Vars(active) < $start + $Vars(height)} {

		::table::activate $table [expr {$Vars(active) - $start}]
	} else {
		::table::activate $table none
	}

	if {	$Vars(selection) >= 0
		&& $start <= $Vars(selection)
		&& $Vars(selection) < $start + $Vars(height)} {

		::table::select $table [expr {$Vars(selection) - $start}]
	} else {
		::table::select $table none
	}
}


proc PopupMenu {table y} {
	variable ${table}::Vars

	::tooltip::hide
	if {![info exists Vars(variant)]} { return }
	set row [::table::at $table $y]

	switch $row {
		none		{ return }
		outside	{ set index outside }

		default {
			set index [expr {$Vars(start) + $row}]
			set Vars(active) $row
			::table::activate $table $row
		}
	}

	if {$Vars(takefocus)} {
		::table::focus $table
	}
	::update idletasks
	set menu $table.menu
	catch { destroy $menu }
	menu $menu -tearoff false
	set base $Vars(base)
	set variant $Vars(variant)
	{*}$Vars(popupcmd) [winfo parent [winfo parent $table]] $menu $base $variant $index

	if {[$menu index 0] ne "none"} {
		::table::keepFocus $table true
		::bind $menu <<MenuUnpost>> [namespace code [list Popdown $table]]
		tk_popup $menu {*}[winfo pointerxy $table]
	}
}


proc Popdown {table} {
	::table::keepFocus $table false
	event generate $table <<TablePopdown>>
}


proc TableScrollbar {table state} {
	variable ${table}::Vars

	if {$Vars(layout) ne "right"} { return }

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


proc ScanMark {table x y} {
	variable ${table}::Vars

	lassign [::table::identify $table $x $y] row _

	if {$row >= 0} {
		set Vars(drag:click:x) $x
		set Vars(drag:click:y) $y
		set Vars(drag:x) [$table.t canvasx $x]
		set Vars(drag:y) [$table.t canvasy $y]
		set Vars(drag:motion) 0
		set Vars(drag:drop) {}
		set Vars(drag:row) $row
	}
}


proc ScanDrag {table x y} {
	variable ${table}::Vars

	if {![info exists Vars(drag:x)]} { return }

	if {!$Vars(drag:motion)} {
		if {abs($x - $Vars(drag:click:x)) > 4 || abs($y - $Vars(drag:click:y)) > 4} {
			set Vars(drag:motion) 1
			set Vars(drag:selection) [$table.t selection get]
			$table.t dragimage clear
			foreach col [::table::columns $table] {
				catch { $table.t dragimage add i$Vars(drag:row) $col elemBrd }
			}
			$table.t dragimage configure -visible yes
		}
	}

	if {$Vars(drag:motion)} {
		set x [expr {[$table.t canvasx $x] - $Vars(drag:x)}]
		set y [expr {[$table.t canvasx $y] - $Vars(drag:y)}]

		$table.t dragimage offset $x $y
	}
}


proc MoveRow {table x y} {
	variable ${table}::Vars

	if {![info exists Vars(drag:x)]} { return }

	if {$Vars(drag:motion)} {
		$table.t dragimage configure -visible no
		$table.t dragimage clear

		lassign [::table::identify $table $x $y] row _
		event generate [winfo parent $table] <<TableDropRow>> -data [list $Vars(drag:row) $row]
	}

	array unset Vars drag:*
}

} ;# namespace scrolledtable

# vi:set ts=3 sw=3:
