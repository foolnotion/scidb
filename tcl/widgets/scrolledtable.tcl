# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
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
		-usescale		0
		-layout			right
		-lock				{}
		-popupcmd		{}
		-takefocus		1
		-sortable		1
		-fixedrows		0
		-lineBasedMenu	1
		-configurable	no
		-height			10
		-hidebar			0
	}
	array set opts $args

	set top $path.top
	set tb  $top.table
	set sb  $top.scrollbar
	set sc  $top.scale
	set sq  $top.square

	namespace eval [namespace current]::$tb {}
	variable [namespace current]::${tb}::

	array set {} {
		start					0
		height				0
		size					0
		minheight			0
		active				-1
		selection			{}
		minsize				{}
		columns				{}
		base					{}
		variant				{}
		after					{}
		mousewheel:after	{}
		mousewheel:list	{}
	}

	set (scale)				$sc
	set (scrollbar)		$sb
	set (popupcmd)			$opts(-popupcmd)
	set (lock)				$opts(-lock)
	set (takefocus)		$opts(-takefocus)
	set (theme)				[::theme::currentTheme]
	set (lineBasedMenu)	$opts(-lineBasedMenu)
	set (hidebar)			$opts(-hidebar)
	set (usescale)			$opts(-usescale)

	set (layout) $opts(-layout)
	foreach attr {-popupcmd -lock -usescale -layout -hidebar -lineBasedMenu} { array unset opts $attr }

	if {![winfo exists $path]} {
		ttk::frame $path -takefocus 0
	}
	ttk::frame $top -takefocus 0
	pack $top -fill both -expand yes

	table::table $tb                                  \
		-moveable 1                                    \
		-fillcolumn end                                \
		-highlightcolor $Defaults(highlight)           \
		-separatorcolor $Defaults(separatorcolor)      \
		-labelbackground theme,background              \
		{*}[array get opts]                            \
		;
	::bind $tb <Destroy> [namespace code [list TableOptions $tb]]
	
	if {$(usescale)} {
		tk::scale $sc                                    \
			-orient horizontal                            \
			-from 0                                       \
			-showvalue 0                                  \
			-takefocus 0                                  \
			-width 10                                     \
			-command [namespace code [list SetStart $tb]] \
			;
		::bind $sc <ButtonRelease-1> [list ::table::focus $tb]
		::bind $sc <ButtonPress-1> [namespace code [list StopMouseWheel $tb]]
		set (slider) [$sc cget -sliderlength]
	}
	
	ttk::scrollbar $sb  \
		-orient vertical \
		-takefocus 0     \
		-command [namespace code [list Scroll $tb]] \
		;
	::bind $sb <Any-Button> [list ::tooltip::hide]
	::bind $sb <ButtonPress-1> [namespace code [list StopMouseWheel $tb]]
	if {$(takefocus)} {
		::bind $sb <ButtonPress-1> +[list ::table::focus $tb]
	}
	ttk::frame $sq -borderwidth 1 -relief sunken

	if {$(layout) eq "right"} {
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

	foreach {id args} $columns {
		if {$(lock) eq $id} { lappend args -lock left }
		::table::addcol $tb $id {*}$args
		lappend (columns) $id
	}

	::bind $tb <<TableFill>>					 [namespace code [list TableFill $tb %d]]
	::bind $tb <<TableRebuild>>				 [namespace code [list TableRebuild $tb]]
	::bind $tb <<TableResized>>				 [namespace code [list TableResized $tb %d]]
	::bind $tb <<TableSelected>>				 [namespace code [list TableSelected $tb %d]]
	::bind $tb <<TableInvoked>>				 [namespace code [list TableInvoked $tb %d]]
	::bind $tb <<TableActivated>>				 [namespace code [list TableActivated $tb %d]]
	::bind $tb <<TableToggleButton>>        [namespace code [list TableToggleButton $tb %d]]
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
	if {$(usescale)} {
		::bind $tb <<TableScroll>>				+[namespace code [list ConfigureScale $tb]]
		::bind $sc <Configure>					 [namespace code [list ConfigureScale $tb]]
	}
	::table::bind $tb <Shift-Down>			 [namespace code [list ShiftScroll $tb down]]
	::table::bind $tb <Shift-Up>				 [namespace code [list ShiftScroll $tb up]]
	::table::bind $tb <Shift-Prior>			 [namespace code [list ShiftScroll $tb prior]]
	::table::bind $tb <Shift-Next>			 [namespace code [list ShiftScroll $tb next]]

	::bind $tb.t <ButtonPress-1>		+[namespace code [list ScanMark $tb %x %y]]
	::bind $tb.t <Button1-Motion>		+[namespace code [list ScanDrag $tb %x %y]]
	::bind $tb.t <ButtonRelease-1>	+[namespace code [list MoveRow $tb %x %y]]

	if {[tk windowingsystem] eq "x11"} {
		::table::bind $tb <Button-4> [namespace code [list MouseWheel $path up 10 %s]]
		::table::bind $tb <Button-4> {+ break }
		::table::bind $tb <Button-5> [namespace code [list MouseWheel $path down 10 %s]]
		::table::bind $tb <Button-5> {+ break }
		::table::bind $tb <Control-Button-4> [namespace code [list MouseWheel $path back]]
		::table::bind $tb <Control-Button-5> [namespace code [list MouseWheel $path forward]]
	} else {
		::table::bind $tb <MouseWheel> [namespace code [list \
			[list MouseWheel $path {[expr {%D < 0 ? "up" : "down"}]} 10]]]
		::table::bind $tb <Control-MouseWheel> [namespace code [list \
			[list MouseWheel $path {[expr {%D < 0 ? "back" : "forward"}]} 10]]]
		::table::bind $tb <MouseWheel> {+ break }
	}

	set stopcmd [namespace code [list MouseWheel $path stop]]
	::table::bind $tb <ButtonPress-1> +$stopcmd
	::table::bind $tb <ButtonPress-2> +$stopcmd
	::table::bind $tb <ButtonPress-3> +$stopcmd

	foreach seq {<Shift-Up> <Shift-Down> <ButtonPress-1> <ButtonRelease-1>} {
		::table::bind $tb $seq {+ break }
	}

	if {[llength $(popupcmd)]} {
		::table::bind $tb <ButtonPress-3> +[namespace code [list PopupMenu $tb %y]]
	}

	TableResized $tb 0
	ShowActive $tb
	return $tb
}


proc update {path base variant size} {
	set table $path.top.table
	variable ${table}::

	if {![info exists (variant)]} {
		set (variant) $variant
		set (base) $base
	}
	if {$(base) ne $base || $(variant) ne $variant} {
		::table::activate $table none
		::table::select $table none

		if {[string length $(base)]} {
			set (start:$(base):$(variant)) $(start)
			set (active:$(base):$(variant)) $(active)
			set (selection:$(base):$(variant)) $(selection)
		}
	} else {
		set (start:$(base):$(variant)) $(start)
		set (active:$(base):$(variant)) $(active)
		set (selection:$(base):$(variant)) $(selection)
	}
	if {![info exists (start:$base:$variant)]} {
		set (start:$base:$variant) 0
		set (active:$base:$variant) -1
		set (selection:$base:$variant) {}
	}
	set oldSize $(size)
	set (size) $size
	::table::clear $table $(size) $(height)

	set (start) [expr {max(0, min($(start:$base:$variant), $(size) - $(height)))}]
	set (active) $(active:$base:$variant)
	set (selection) $(selection:$base:$variant)
	set (base) $base
	set (variant) $variant

	if {$(active) >= 0} {
		set (active) [expr {min($(start) + $size - 1, $(active))}]
	}
	if {[llength $(selection)]} {
		if {$size == 0} {
			set (selection) {}
		else
			set (selection) [expr {min($(start) + $size - 1, $(selection))}]
		}
	}

	set height [expr {min([::table::height $table], $(height))}]
	TableResized $table $height
	# if not already done by TableResized
	if {$(start) + $height < $(size)} { TableFill $table }
}


proc base {path} {
	return [set [namespace current]::${path}.top.table::(base)]
}


proc variant {path} {
	return [set [namespace current]::${path}.top.table::(variant)]
}


proc tablePath {path} {
	return [::table::tablePath $path.top.table]
}


proc scrolledtablePath {table} {
	return [winfo parent [winfo parent $table]]
}


proc height {path} {
	return [::table::height $path.top.table]
}


proc gridsize {path} {
	return [::table::gridsize $path.top.table]
}


proc visibleColumns {path} {
	return [::table::visibleColumns $path.top.table]
}


proc forget {path base variant} {
	set table $path.top.table
	variable ${table}::

	if {$(base) eq $base && $(variant) eq $variant} {
		array unset {} *:$base:$variant
		set (base) {}
		set (variant) {}
		set (size) 0
	}
}


proc scroll {path position {units 1}} {
	set table $path.top.table
	variable ${table}::

	if {$(size) == 0} { return }

	switch $position {
		back			{ SetStart $table [expr {$(start) - $(height)}] }
		forward		{ SetStart $table [expr {$(start) + $(height)}] }
		selection	{ if {[llength $(selection)]} { TableScroll $table see } }
		home			{ TableScroll $table home }
		end			{ TableScroll $table end }

		up - down	{
#			if {$units > $(height)/2} { set units [expr {max(1, $(height)/2)}] }
			if {$position eq "up"} { set dir [expr {-$units}] } else { set dir $units }
			set start [expr {max(0, min($(size) - 1, $(start) + $dir))}]
			if {$start == $(start)} { return }
			::tooltip::hide
			SetStart $table $start
		}

		default		{
			if {[string is integer -strict $position]} {
				set start [expr {max(0, min($(size) - 1, $position))}]
				if {$start == $(start)} { return }
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
	variable ${table}::

	if {$(size) == 0} { return }
	if {$position eq "end"} {
		if {$(size) == 0} { return }
		set position [expr {$(size) - 1}]
	}
	if {![expr {$(start) <= $position && $position <= $(start) + $(height)}]} {
		set start [expr {min($(size) - $(height), $position)}]
		if {$start != $(start)} {
			::table::select $table none
			set (start) $start
			TableFill $table
			ShowSelection $table
			ConfigureScrollbar $table
			ConfigureScale $table
		}
	}
	activate $path [expr {$position - $(start)}]
}


proc refresh {path} {
	TableFill $path.top.table
}


proc clear {path {first -1} {last -1}} {
	set table $path.top.table
	variable ${table}::

	::table::clear $table $first $last
	ConfigureScrollbar $table
	ConfigureScale $table
}


proc clearColumn {path id} {
	::table::clearColumn $path.top.table $id
}


proc fill {path first {last -1}} {
	set table $path.top.table
	variable ${table}::

	if {$last == -1} { set last $first }
	set start $(start)
	TableFill $table [list [expr {$first - $start}] [expr {$last - $start}]] false
}


proc selection {path} {
	set table $path.top.table
	variable ${table}::

	if {[llength $(selection)] == 0} { return -1 }
	return [expr {$(selection) - $(start)}]
}


proc active {path} {
	set table $path.top.table
	variable ${table}::

	return $(active)
}


proc index {path} {
	set table $path.top.table
	variable ${table}::

	if {[llength $(selection)] == 0} { return -1 }
	return $(selection)
}


proc firstRow {path} {
	set table $path.top.table
	variable ${table}::

	return $(start)
}


proc lastRow {path} {
	set table $path.top.table
	variable ${table}::

	return [expr {$(start) + $(height)}]
}


proc indexToRow {path index} {
	set table $path.top.table
	variable ${table}::

	return [expr {$index - $(start)}]
}


proc rowToIndex {path row} {
	set table $path.top.table
	variable ${table}::

	return [expr {$row + $(start)}]
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


proc configure {path args} {
	::table::configure $path.top.table {*}$args
}


proc at {path y} {
	set table $path.top.table
	variable ${table}::

	set row [::table::at $table $y]
	if {![string is digit -strict $row]} { return $row }
	return [expr {$row + $(start)}]
}


proc countOptions {id} {
	return [::table::countOptions $id]
}


proc getOptions {id} {
	return [::table::getOptions $id]
}


proc setOptions {id options} {
	::table::setOptions $id $options
}


proc loadOptions {id options} {
	::table::loadOptions $id $options false
}


proc bindOptions {id arrName nameList} {
	::table::bindOptions $id $arrName $nameList
}


proc setColumnMininumWidth {path id width} {
	return [::table::setColumnMininumWidth $path.top.table $id $width]
}


proc setState {path row state} {
	set table $path.top.table
	variable ${table}::

	::table::setState $table [expr {$row + $(start)}] $state
}


proc columnNo {path id} {
	set table $path.top.table
	variable ${table}::

	return [lsearch -exact $(columns) $id]
}


proc selectionIsVisible? {path} {
	set table $path.top.table
	variable ${table}::

	if {[llength $(selection)] == 0} { return false }
	return [expr {$(start) <= $(selection) && $(selection) < $(start) + $(height)}]
}


proc updateColumn {path selection {see 0}} {
	set table $path.top.table
	variable ${table}::

	if {$selection < 0} { return }
	set (selection) $selection

	if {$see} {
		SetStart $table [expr {max(0, $selection - $(height)/2)}]
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
	variable ${table}::
	variable Defaults

	if {$(layout) eq $dir} { return }
	set (layout) $dir
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
	set table $path.top.table
	variable ${table}::
	variable Defaults

	set parent ${path}.top
	set sc ${parent}.scale
	set height [::table::computeHeight $parent.table $rows]
	if {$sc in [grid slaves $parent]} {
		incr height [winfo reqheight $sc]
		incr height [expr {2*$Defaults(scale:pady)}]
	}
	return $height
}


proc linespace {path} {
	return [::table::linespace $path.top.table]
}


proc borderwidth {path} {
	return [::table::borderwidth $path.top.table]
}


proc activate {path row} {
	set table $path.top.table
	variable ${table}::

	switch -- $row {
		end  { set row [expr {$(height) - 1}] }
		none { set row -1 }
	}
	if {$row == -1 || 0 > $row || $row >= $(size)} {
		set (active) -1
		::table::activate $table -1 true
	} else {
		set (active) [expr {$row + $(start)}]
		::table::activate $table $row true
	}
}


proc select {path row} {
	set table $path.top.table
	variable ${table}::

	switch -- $row {
		end  { set row [expr {$(height) - 1}] }
		none { set row -1 }
	}
	if {$row < 0} {
		set (selection) {}
		::table::select $table none
	} else {
		set (selection) [expr {$(start) + $row}]
		::table::select $table $row
	}
}


proc setSelection {path row} {
	set table $path.top.table
	variable ${table}::

	switch -- $row {
		end  { set row [expr {$(height) - 1}] }
		none { set row -1 }
	}
	if {$row < 0} {
		set (selection) {}
		::table::setSelection $table none
	} else {
		set (selection) [expr {$(start) + $row}]
		::table::setSelection $table $row
	}
}


proc focus {path} {
	set table $path.top.table
	variable ${table}::

	if {$(takefocus)} {
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
	variable ${table}::

	if {$(theme) ne [::theme::currentTheme]} {
		after idle [event generate $table <<TableLayout>>]
		set (theme) [::theme::currentTheme]
	}
}


proc ConfigureScale {table} {
	variable ${table}::

	if {![winfo exists $(scale)]} { return }
	set len [expr {[winfo width $(scale)] - 4}]
	if {$(height) > 0 && $(size) > 0} {
		set len [expr {max($(slider), min($len, $len*double($(height))/double($(size))))}]
	}
	$(scale) configure -sliderlength $len
	$(scale) set $(start)
}


proc ConfigureScrollbar {table} {
	after idle [namespace code [list ScrollToStart $table]]
}


proc ScrollToStart {table} {
	if {![winfo exists $table]} { return }
	variable ${table}::
	Scroll $table set $(start) false
}


proc TableOptions {table} {
	event generate [winfo parent [winfo parent $table]] <<TableOptions>>
}


proc TableVisit {table data} {
	variable ${table}::

	set data [list $(base) $(variant) {*}$data]
	event generate [winfo parent [winfo parent $table]] <<TableVisit>> -data $data
}


proc TableHide {table data} {
	event generate [winfo parent [winfo parent $table]] <<TableHide>> -data $data
}


proc TableShow {table data} {
	event generate [winfo parent [winfo parent $table]] <<TableShow>> -data $data
}


proc TableMinSize {table minsize} {
	variable ${table}::
	variable Defaults

	if {[llength $minsize] == 0} { return }
	lassign $minsize minwidth minheight
	if {$(layout) eq "right"} {
		incr minwidth [winfo width $(scrollbar)]
	} else {
		incr minheight [expr {[winfo height $(scale)] + 2*$Defaults(scale:pady)}]
	}
	set minsize [list $minwidth $minheight]
	set parent [winfo parent [winfo parent $table]]
	event generate $parent <<TableMinSize>> -data [list $minsize [::table::gridsize $table]]
}


proc TableScroll {table action} {
	variable ${table}::

	::tooltip::hide
	if {$(size) == 0} { return }
	set active $(active)

	if {$active == -1} { 
		switch $action {
			home				{ set active 0 }
			end				{ set active [expr {$(start) + $(size) - 1}] }
			up - next		{ set active [expr {$(start) + $(height) - 1}] }
			down - prior	{ set active $(start) }
			see				{ set active [expr {[llength $(selection)] ? $(selection) : 0}] }
		}
		set active [expr {max(0, min($active, $(size) - 1))}]
		switch $action {
			home	{ set start $active }
			end	{ set start [expr $active - $(height) + 1] }

			up - down - next - prior { set start $(start) }

			see {
				if {[::table::selection $table] == -1 && [llength $(selection)]} {
					set start [expr {$(selection) - $(height)/2}]
				} else {
					set start $(start)
				}
			}
		}
	} else {
		switch $action {
			home	{ set active 0 }
			end	{ set active [expr {$(start) + $(size) - 1}] }
			up		{ incr active -1 }
			down	{ incr active }
			prior	{ set active [expr {max(0, $(active)) - $(height)}] }
			next	{ incr active $(height) }
			see	{ set active [expr {[llength $(selection)] ? $(selection) : 0}] }
		}
		set active [expr {max(0, min($active, $(size) - 1))}]
		switch $action {
			home - prior - up { set start $active }
			end - next - down { set start [expr $active - $(height) + 1] }
			
			see {
				if {[::table::selection $table] == -1 && [llength $(selection)]} {
					set start [expr {$(selection) - $(height)/2}]
				} else {
					set start $(start)
				}
			}
		}
	}

	if {$start != $(start)} {
		SetStart $table $start
	}
	if {$active != $(active)} {
		set (active) $active
		::table::activate $table [expr {$active - $start}]
		event generate [winfo parent [winfo parent $table]] <<TableActivated>> -data $active
	}
}


proc TableActivated {table number} {
	if {![winfo exists $table.t]} { return }
	variable ${table}::

	set active $(active)

	if {$number == -1} {
		set (active) -1
	} else {
		incr number $(start)
		set (active) $number

		if {$(start) > $number || $number >= $(start) + $(height)} {
			SetStart $table [expr {max(0, min($number, $(size) - $(height)))}]
		}
	}

	if {$active != $(active)} {
		event generate [winfo parent [winfo parent $table]] <<TableActivated>> -data $(active)
	}
}


proc TableSelected {table number} {
	variable ${table}::

	set (selection) [expr {$number + $(start)}]
	event generate [winfo parent [winfo parent $table]] <<TableSelected>> -data $(selection)
}


proc TableRebuild {table} {
	event generate [winfo parent [winfo parent $table]] <<TableRebuild>>
}


proc TableToggleButton {table number} {
	variable ${table}::

	set number [expr {$number + $(start)}]
	event generate [winfo parent [winfo parent $table]] <<TableToggleButton>> -data $number
}


proc TableInvoked {table shiftIsHeldDown} {
	variable ${table}::
	event generate [winfo parent [winfo parent $table]] <<TableInvoked>> -data $shiftIsHeldDown
}


proc TableResized {table height} {
	variable ${table}::

	set (height) $height
	if {[winfo exists $(scale)]} {
		$(scale) configure \
			-bigincrement $height \
			-to [expr {$(size) - $height}]
		ConfigureScale $table
	}
	ConfigureScrollbar $table
	::table::select $table none
	::table::setRows $table [expr {min($height, $(size))}]

	if {$(start) + $height >= $(size)} {
		SetStart $table $(start) yes
	} else {
		SetHighlighting $table
	}

	event generate [winfo parent [winfo parent $table]] <<TableResized>> -data $height
}


proc SetStart {table start {force no}} {
	variable ${table}::

	if {!$force} {
		if {$(start) - $start == 1} {
			return [Scroll $table up]
		} elseif {$(start) - $start == -1} {
			return [Scroll $table down]
		}
	}
	Scroll $table set $start $force
}


proc ShiftScroll {table action} {
	Scroll $table $action
	ConfigureScrollbar $table
	ConfigureScale $table
}


proc StopMouseWheel {table} {
	variable ${table}::

	after cancel $(mousewheel:after)
	set (mousewheel:after) {}
}


proc MouseWheel {path dir {units 0} {state 0}} {
	set table $path.top.table
	variable ${table}::
	variable ::table::shiftMask

	# vertical scrolling is a slow operation, so we have to collect the operations

	after cancel $(mousewheel:after)
	set (mousewheel:after) {}

	if {$dir eq "stop"} {
		set (mousewheel:list) {}
	} elseif {[expr {($state & $shiftMask) != 0}]} {
		set (mousewheel:list) {}
		$path.top.table.t xview scroll [expr {$dir == "up" ? -10 : 10}] units
	} else {
		lappend (mousewheel:list) [list $dir $units]
		set (mousewheel:after) [after 5 [namespace code [list DoMouseWheel $path]]]
	}
}


proc DoMouseWheel {path} {
	set table $path.top.table
	if {![winfo exists $table]} { return }
	variable ${table}::

	if {[llength $(mousewheel:list)] == 0} { return }

	lassign [lindex $(mousewheel:list) 0] position units
	set (mousewheel:list) [lreplace $(mousewheel:list) end end]

	switch $position {
		up - back {
			if {$(start) == 0} { return [MouseWheel $path stop] }
		}
		down - forward {
			if {$(start) + $(height) == $(size)} { return [MouseWheel $path stop] }
		}
	}

	if {[llength $(mousewheel:list)] > 0} {
		set (mousewheel:after) [after 5 [namespace code [list DoMouseWheel $path]]]
	}

	scroll $path $position $units
}


proc Scroll {table action args} {
	variable ${table}::

	if {![winfo exists $(scrollbar)]} { return }

	set force no

	switch $action {
		set		{ lassign $args start force }
		moveto	{ set start [expr {int($args*$(size) + 0.5)}] }
		up			{ set start [expr {$(start) - 1}] }
		down		{ set start [expr {$(start) + 1}] }
		prior		{ set start [expr {$(start) - $(height)}] }
		next		{ set start [expr {$(start) + $(height)}] }

		scroll {
			lassign $args number unit
			switch $unit {
				units { set start [expr {$(start) + $number}] }
				pages { set start [expr {$(start) + $number*$(height)}] }
			}
		}
	}

	set start [expr {max(0, min($start, $(size) - $(height)))}]
	set first [expr {$(size) <= 1 ? 0.0 : double($start)/double($(size) - 1)}]
	set last  [expr {$(size) <= 1 ? 1.0 : double($start + $(height))/double($(size))}]

	if {$(hidebar)} {
		set parent [winfo parent $table]
		if {$first <= 0 && $last >= 1} {
			if {$(scrollbar) in [grid slaves $parent]} {
				grid remove $(scrollbar)
			}
		} else {
			if {$(scrollbar) ni [grid slaves $parent]} {
				after idle [list grid $(scrollbar)]
			}
		}
	}
	$(scrollbar) set $first $last

	set oldStart $(start)
	if {$start == $oldStart && !$force} { return }
	set (start) $start
	::table::select $table none

	if {$force || abs($oldStart - $start) != 1} {
		TableFill $table
	} elseif {$start < $oldStart} {
		::table::scroll $table down
		TableFill $table {0 1}
	} else {
		::table::scroll $table up
		TableFill $table [list [expr {$(height) - 1}] $(height)]
	}

	ShowSelection $table
	ShowActive $table

	if {$force || $start != $oldStart} {
		event generate [winfo parent [winfo parent $table]] <<TableScroll>> -data $start
	}
}


proc TableFill {table {range {0 100000}} {hilite true}} {
	variable ${table}::

	if {$(size) == 0} { return }
	lassign $range first last
	set last [min $last $(height)]
	if {$first < 0} { set first 0 }
	if {$last < $first} { return }
	if {$(start) + $first >= $(size)} { return }
	set last [expr {min($last, $(size))}]
	event generate [winfo parent [winfo parent $table]] <<TableFill>> \
		-data [list $table $(base) $(variant) $(start) $first $last $(columns)]
	if {$hilite} { SetHighlighting $table }
}


proc SetHighlighting {table} {
	variable ${table}::

	if {$(start) > $(active) || $(active) >= $(start) + $(height)} { set active -1 }
	ShowSelection $table
}


proc PopupMenu {table y} {
	variable ${table}::

	::tooltip::hide
	if {![info exists (variant)]} { return }
	set row [::table::at $table $y]

	switch $row {
		none		{ return }
		outside	{ set index outside }

		default {
			set index [expr {$(start) + $row}]
			if {$(lineBasedMenu)} {
				set (active) $index
				::table::activate $table $row
			}
		}
	}

	if {$(takefocus)} {
		::table::focus $table
	}
	::update idletasks
	set menu $table.menu
	catch { destroy $menu }
	menu $menu -tearoff false
	set base $(base)
	set variant $(variant)
	{*}$(popupcmd) [winfo parent [winfo parent $table]] $menu $base $variant $index

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
	variable ${table}::

	if {$(layout) ne "right"} { return }

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
	variable ${table}::

	lassign [::table::identify $table $x $y] row _

	if {$row >= 0} {
		set (drag:click:x) $x
		set (drag:click:y) $y
		set (drag:x) [$table.t canvasx $x]
		set (drag:y) [$table.t canvasy $y]
		set (drag:motion) 0
		set (drag:drop) {}
		set (drag:row) $row
	}
}


proc ScanDrag {table x y} {
	variable ${table}::

	if {![info exists (drag:x)]} { return }

	if {!$(drag:motion)} {
		if {abs($x - $(drag:click:x)) > 4 || abs($y - $(drag:click:y)) > 4} {
			set (drag:motion) 1
			set (drag:selection) [$table.t selection get]
			$table.t dragimage clear
			foreach col [::table::columns $table] {
				catch { $table.t dragimage add i$(drag:row) $col elemBrd }
			}
			$table.t dragimage configure -visible yes
		}
	}

	if {$(drag:motion)} {
		set x [expr {[$table.t canvasx $x] - $(drag:x)}]
		set y [expr {[$table.t canvasx $y] - $(drag:y)}]

		$table.t dragimage offset $x $y
	}
}


proc MoveRow {table x y} {
	variable ${table}::

	if {![info exists (drag:x)]} { return }

	if {$(drag:motion)} {
		$table.t dragimage configure -visible no
		$table.t dragimage clear

		lassign [::table::identify $table $x $y] row _
		event generate [winfo parent $table] <<TableDropRow>> -data [list $(drag:row) $row]
	}

	array unset drag:*
}


proc ShowSelection {table} {
	variable ${table}::

	if {[llength $(selection)] == 0} { return }
	if {$(start) <= $(selection) && $(selection) < $(start) + $(height)} {
		::table::select $table [expr {$(selection) - $(start)}]
	}
}


proc ShowActive {table} {
	variable ${table}::

	if {$(active) >= 0} {
		if {$(start) <= $(active) && $(active) < $(start) + $(height)} {
			::table::activate $table [expr {$(active) - $(start)}]
		} else {
			set (active) -1
			::table::activate $table none
		}
	}
}

} ;# namespace scrolledtable

# vi:set ts=3 sw=3:
