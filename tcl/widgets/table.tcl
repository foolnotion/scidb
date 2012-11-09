# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# ======================================================================
# Copyright: (C) 2009-2012 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

package require Tk 8.5
package require tktreectrl 2.2
package require tooltip
package provide table

namespace eval table {
namespace eval mc {

set Ok							"&Ok"
set Cancel						"&Cancel"
set Column						"Column"
set Table						"Table"
set Configure					"Configure"
set Hide							"Hide"
set ShowColumn					"Show Column"
set Foreground					"Foreground"
set Background					"Background"
set DisabledForeground		"Deleted Foreground"
set SelectionForeground		"Selection Foreground"
set SelectionBackground		"Selection Background"
set HighlightColor			"Highlight Background"
set Stripes						"Stripes"
set MinWidth					"Minimal Width"
set MaxWidth					"Maximal Width"
set Separator					"Separator"
set AutoStretchColumn		"Auto stretch column"
set FillColumn					"- Fill Column -"
set Preview						"Preview"
set OptimizeColumn			"Optimize column width"
set OptimizeColumns			"Optimize all columns"
set FitColumnWidth			"Fit column width"
set FitColumns					"Fit all columns"
set ExpandColumn				"Expand column width"
set SqueezeColumns			"Squeeze all columns"

set AccelFitColumns			"Ctrl+,"
set AccelOptimizeColumns	"Ctrl+."
set AccelSqueezeColumns		"Ctrl+#"

} ;# namespace mc

namespace export table

namespace import ::tcl::mathfunc::max
namespace import ::tcl::mathfunc::min

event add <<TableFill>>			TableFill
event add <<TableResized>>		TableResized
event add <<TableSelected>>	TableSelected
event add <<TableInvoked>>		TableInvoked
event add <<TableActivated>>	TableActivated
event add <<TableScroll>>		TableScroll
event add <<TableHide>>			TableHide
event add <<TableShow>>			TableShow
event add <<TableStripes>>		TableStripes
event add <<TableMinSize>>		TableMinSize
event add <<TableOptions>>		TableOptions
event add <<TableVisit>>		TableVisit
event add <<TableScrollbar>>	TableScrollbar
event add <<TablePopdown>>		TablePopdown
event add <<TableMenu>>			TableMenu

array set options {
	menu:headerbackground	#ffdd76
	menu:headerforeground	black
	menu:headerfont			TkHeadingFont
	element:padding			2
}

array set Defaults {
	-width                  0
	-background					white
	-foreground					black
	-selectionbackground		#ffdd76
	-selectionforeground		black
	-disabledforeground		#999999
	-labelforeground			black
	-labelbackground			#d9d9d9
	-borderwidth				1
	-labelfont					TkTextFont
	-labelrelief				raised
	-labelanchor				w
	-labelborderwidth			1
	-font							TkTextFont
	-showlabels					1
	-moveable					0
	-fillcolumn					0
	-fullstripes				1
	-listmode					0
	-takefocus          		1
	-fixedrows					0
	-imagepadx					{2 2}
	-imagepady					{0 0}
	-padx							{2 2}
	-pady							{0 0}
	-height						10
	-stripes						{}
	-highlightcolor			{}
	-labelcommand				{}
	-columns						{}
}

variable Eraser [::icon::makeStateSpecificIcons $::colormenu::icon::16x16::eraser]
variable Colors {black white gray50 darkviolet darkBlue blue2 blue darkGreen darkRed red2 red #68480a}
variable RecentColors

set KeyFitColumns			<Control-Key-comma>
set KeyOptimizeColumns	<Control-Key-period>
set KeySqueezeColumns	<Control-Key-numbersign>


proc table {args} {
	variable Defaults
	variable KeyFitColumns
	variable KeyOptimizeColumns
	variable KeySqueezeColumns

	set parent [lindex $args 0]
	set table [tk::frame $parent]

	namespace eval [namespace current]::$table {}
	variable ${table}::Vars
	variable ${table}::Options

	if {![info exists Options]} {
		array set Options [array get Defaults]
		array set Options [lrange $args 1 end]
	} else {
		set opts(-labelcommand) {}
		array set opts [lrange $args 1 end]
		set Options(-labelcommand) $opts(-labelcommand)
		unset opts

		foreach key [array names Defaults] {
			if {![info exists Options($key)]} {
				set Options($key) $Defaults($key)
			}
		}
	}

	set Vars(charwidth)		[font measure $Options(-font) "0"]
	set Vars(linespace)		[font metrics $Options(-font) -linespace]
	set Vars(labelHeight)	0
	set Vars(minwidth)		0
	set Vars(minheight)		0
	set Vars(height)			0
	set Vars(rows)				0
	set Vars(init)				1
	set Vars(keep)				0
	set Vars(size)				0
	set Vars(header)			0
	set Vars(active)			-1
	set Vars(selection)		-1
	set Vars(columns)			{}
	set Vars(visible)			{}
	set Vars(order)			{}
	set Vars(styles)			{}

	treectrl $table.t                      \
		-width $Options(-width)             \
		-takefocus $Options(-takefocus)     \
		-highlightthickness 0               \
		-borderwidth $Options(-borderwidth) \
		-relief sunken                      \
		-showheader yes                     \
		-showbuttons no                     \
		-selectmode single                  \
		-showroot no                        \
		-showlines no                       \
		-showrootlines no                   \
		-columnresizemode realtime          \
		-itemprefix i                       \
		-xscrollincrement 1                 \
		-keepuserwidth no                   \
		-fullstripes $Options(-fullstripes) \
		-background $Options(-background)   \
		;
	setColumnBackground $table tail $Options(-stripes) $Options(-background)
	$table.t state define deleted
	$table.t element create elemIco image
	set colors [list $Options(-selectionbackground) selected]
	if {[llength $Options(-highlightcolor)]} { lappend colors $Options(-highlightcolor) active }
	$table.t element create elemSel rect -fill $colors
	$table.t element create elemImg rect -fill $colors
	$table.t element create elemBrd border  \
		-filled no                           \
		-relief raised                       \
		-thickness 1                         \
		-background {#e5e5e5 {active} {} {}} \
		;

	if {$Options(-fixedrows)} {
		::bind $table.t <Configure>		[namespace code [list ConfigureOnce $table %w %h]]
	} else {
		::bind $table.t <Configure>		[namespace code [list Configure $table %w %h]]
	}

	::bind $table.t <Destroy>				[namespace code [list Cleanup $table]]
	::bind $table.t <ButtonPress-1>		[namespace code [list Highlight $table %x %y]]
	::bind $table.t <ButtonRelease-1>	[namespace code [list Release $table %x %y]]
	::bind $table.t <ButtonPress-3>		[namespace code [list PopupMenu $table %x %y %X %Y]]
	::bind $table.t <Double-Button-1>	[namespace code [list SetSelection $table %x %y %s]]
	::bind $table.t <FocusIn>				[namespace code [list FocusIn $table]]
	::bind $table.t <FocusOut>				[namespace code [list FocusOut $table]]
	::bind $table.t <Home>					[namespace code [list Scroll $table home]]
	::bind $table.t <End>					[namespace code [list Scroll $table end]]
	::bind $table.t <Prior>					[namespace code [list Scroll $table prior]]
	::bind $table.t <Next>					[namespace code [list Scroll $table next]]
	::bind $table.t <Up>						[namespace code [list Scroll $table up]]
	::bind $table.t <Down>					[namespace code [list Scroll $table down]]
	::bind $table.t <Key-space>			[namespace code [list SetSelection $table %s]]
	::bind $table.t <<ThemeChanged>>		[namespace code [list ThemeChanged $table]]

	set toplevel [winfo toplevel $parent]
	::bind $toplevel $KeyFitColumns [namespace code [list fitColumns $toplevel]]
	::bind $toplevel $KeyOptimizeColumns [namespace code [list optimizeColumns $toplevel]]
	::bind $toplevel $KeySqueezeColumns [namespace code [list squeezeColumns $toplevel]]

	foreach seq {<Double-Button-1> <Up> <Down>} {
		::bind $table.t $seq {+ break }
	}

	ttk::scrollbar $table.sb -orient horizontal -command [list $table.t xview]
	after idle [list $table.t xview moveto 0.0]
	$table.t notify bind $table.sb <Scroll-x> [namespace code { SbSet %W %l %u }]
	::bind $table.sb <Any-Button> [list ::tooltip::hide]
	if {$Options(-takefocus)} {
		::bind $table.sb <Any-Button> +[list ::focus $table.t]
	}

	grid $table.t  -row 1 -column 1 -sticky nsew
	grid $table.sb -row 2 -column 1 -sticky ew
	grid columnconfigure $table 1 -weight 1
	grid rowconfigure $table 1 -weight 1

	unset Options(-labelcommand)
	unset Options(-takefocus)

	return $table
}


proc addcol {table id args} {
	variable ${table}::Vars
	variable ${table}::Options

	set index [llength $Vars(columns)]

	array set opts {
		-visible					1
		-minwidth				0
		-maxwidth				0
		-lastwidth				0
		-stretch   				0
		-removable				0
		-ellipsis            0
		-optimizable			1
		-fixed					0
		-pixels					0
		-width					10
		-justify					left
		-lock                none
		-image					{}
		-text						{}
		-textvar					{}
		-tooltip					{}
		-tooltipvar				{}
		-group					{}
		-groupvar				{}
		-menu						{}
		-foreground				{}
		-background				{}
		-selectionforeground	{}
		-disabledforeground	{}
		-stripes					{}
	}

	if {[info exists Options(-visible:$id)]} {
		array set opts {
			-text			{}
			-textvar		{}
			-image		{}
			-tooltip		{}
			-tooltipvar	{}
			-menu			{}
			-group		{}
			-groupvar	{}
		}
		array set opts $args
		foreach {key val} [array get Options *:$id] {
			set opts([lindex [split $key ":"] 0]) $val
		}
	} else {
		set opts(-order) $index
		array set opts $args
	}

	set labelText {}
	set labelImage {}

	if {[llength $opts(-image)]} {
		set labelImage $opts(-image)
	} elseif {[llength $opts(-textvar)]} {
		set labelText [set $opts(-textvar)]
		set trace "variable $opts(-textvar) write { [namespace current]::SetText $table $id $opts(-textvar) }"
		trace add {*}$trace
		::bind $table.t <Destroy> +[list trace remove {*}$trace]
	} else {
		set labelText $opts(-text)
	}
	if {$opts(-minwidth) == $opts(-maxwidth)} { set resizable no } else { set resizable yes }
	if {$opts(-maxwidth) <= 0} { set maxwidth {} } else { set maxwidth $opts(-maxwidth) }
	set opts(-pixels) [string match {*px} $opts(-width)]
	if {$opts(-pixels)} {
		set width [lindex [split $opts(-width) px] 0]
		set minwidth $opts(-minwidth)
		if {[string match {*px} $minwidth]} {
			set minwidth [lindex [split $opts(-width) px] 0]
		}
		incr width 4
		if {$minwidth} { incr minwidth 4 }
		set opts(-ellipsis) 0
		set squeeze 0
	} else {
		set width [expr {$Vars(charwidth)*$opts(-width)}]
		set minwidth $opts(-minwidth)
		if {[string match {*px} $minwidth]} {
			set minwidth [lindex [split $opts(-minwidth) px] 0]
			if {!$resizable} {
				set minwidth [expr {max($minwidth, $opts(-width)*$Vars(charwidth))}]
			}
		} else {
			if {!$resizable} {
				set minwidth [expr {max($minwidth, $opts(-width))}]
			}
			set minwidth [expr {$Vars(charwidth)*$minwidth}]
		}
		if {[llength $maxwidth]} {
			set maxwidth [expr {$Vars(charwidth)*$maxwidth}]
		}
		set width [expr {max($width, $minwidth)}]
		set squeeze 1
	}
	if {[llength $maxwidth]} {
		set maxwidth [expr {max($minwidth, $maxwidth)}]
	}
	if {$opts(-stretch)} { lassign {{} 1} width weight } else { set weight 0 }
	if {$opts(-lastwidth)} {
		set width $opts(-lastwidth)
	}
	set stripes $opts(-stripes)
	if {[llength $stripes] == 0} { set stripes $Options(-stripes) }
	if {[llength $stripes]} {
		set colors [list $stripes $opts(-background)]
	} else {
		set colors $opts(-background)
	}

	set justify $opts(-justify)
#	if {[llength $labelImage]} {
#		set justify center
#	} else {
#		set justify left
#	}

	$table.t column create                      \
		-tag $id                                 \
		-expand yes                              \
		-steady yes                              \
		-minwidth $minwidth                      \
		-maxwidth $maxwidth                      \
		-width $width                            \
		-lock $opts(-lock)                       \
		-image $labelImage                       \
		-text $labelText                         \
		-font $Options(-labelfont)               \
		-textcolor $Options(-labelforeground)    \
		-background $Options(-labelbackground)   \
		-textpadx $Options(-padx)                \
		-textpady $Options(-pady)                \
		-imagepadx $Options(-imagepadx)          \
		-imagepady $Options(-imagepady)          \
		-justify $justify                        \
		-borderwidth $Options(-labelborderwidth) \
		-button no                               \
		-itemjustify $opts(-justify)             \
		-resize $resizable                       \
		-squeeze $squeeze                        \
		-visible $opts(-visible)                 \
		-weight $weight                          \
		-uniform uniform                         \
		-itembackground $colors                  \
		;
	$table.t column dragconfigure -enable yes
	$table.t notify install <ColumnDrag-receive>
	$table.t notify install <Header-enter>
	$table.t notify install <Header-leave>
	$table.t notify install <Item-enter>
	$table.t notify install <Item-leave>
	$table.t notify install <Column-resized>
	$table.t notify bind Table <ColumnDrag-receive> [namespace code [list MoveColumn $table %C %b]]
	$table.t notify bind Table <Header-enter> [namespace code [list Tooltip $table show %C %x %y]]
	$table.t notify bind Table <Header-leave> [namespace code [list Tooltip $table hide]]
	$table.t notify bind Table <Item-enter> [namespace code [list VisitItem $table enter %C %I %x %y]]
	$table.t notify bind Table <Item-leave> [namespace code [list VisitItem $table leave %C %I]]
	$table.t notify bind Table <Column-resized> [namespace code [list UpdateColunnWidth $table %C %w]]

	set foreground $opts(-foreground)
	if {[llength $foreground] == 0} { set foreground $Options(-foreground) }
	set disabledforeground $opts(-disabledforeground)
	if {[llength $disabledforeground] == 0} { set disabledforeground $Options(-disabledforeground) }

	set Vars(tooltip:$id) $opts(-tooltip)
	set Vars(tooltipvar:$id) $opts(-tooltipvar)
	set Vars(menu:$id) $opts(-menu)
	set Vars(group:$id) $opts(-group)
	set Vars(groupvar:$id) $opts(-groupvar)
	set Vars(tags:$id) {}
	lappend Vars(styles) $id style$id
	lappend Vars(columns) $id
	if {$opts(-visible)} {
		lappend Vars(visible) $id
		if {$minwidth > 0} {
			incr Vars(minwidth) $minwidth
		} elseif {[llength $width]} {
			incr Vars(minwidth) $width
		}
	}

	set Vars(ellipsis:$id) 0
	if {[llength $Vars(tooltip:$id)] == 0 && [llength $opts(-text)]} {
		set Vars(tooltip:$id) $opts(-text)
		set Vars(ellipsis:$id) 1
	}
	if {[llength $Vars(tooltipvar:$id)] == 0 && [llength $opts(-textvar)]} {
		set Vars(tooltipvar:$id) $opts(-textvar)
		set Vars(ellipsis:$id) 1
	}

	set order $opts(-order)
	while {$order >= [llength $Vars(order)]} { lappend Vars(order) {} }
	if {[llength [lindex $Vars(order) $order]] == 0} {
		lset Vars(order) $order $id
	} else {
		lappend Vars(order) $id
	}
	set columns {}
	foreach i $Vars(order) {
		if {[llength $i]} { lappend columns $i }
	}
	set n [llength $columns]
	if {$n > 1} {
		set next [lindex $columns end-1]
		for {set i [expr {$n - 2}]} {$i >= 0} {incr i -1} {
			set prev [lindex $columns $i]
			$table.t column move $prev $next
			set next $prev
		}
	}

	unset opts(-text)
	unset opts(-textvar)
	unset opts(-tooltip)
	unset opts(-tooltipvar)
	unset opts(-group)
	unset opts(-groupvar)
	unset opts(-image)
	unset opts(-menu)

	foreach opt [array names opts] { set Options($opt:$id) $opts($opt) }
	incr Vars(size)

	MakeStyles $table $id $foreground $disabledforeground
}


proc insert {table index list} {
	variable ${table}::Vars
	variable ${table}::Options

	if {$index >= $Vars(height)} { return }

	set col 0
	foreach id $Vars(columns) {
		if {$Options(-visible:$id)} {
			set item [lindex $list $col]
			if {[string index $item 0] eq "@" && [lindex $item 0] eq "@"} {
				$table.t item element configure $index $id elemTxt$id -text ""
				$table.t item element configure $index $id elemIco -image [lindex $item 1]
			} else {
				$table.t item element configure $index $id elemIco -image {}
				$table.t item element configure $index $id elemTxt$id -text $item
			}
		}
		incr col
	}

	set Vars(rows) [max $Vars(rows) [expr {$index + 1}]]
}


proc tablePath {table} {
	return $table.t
}


proc columns {table} {
	return [set ${table}::Vars(columns)]
}


proc visibleColumns {table} {
	return [set ${table}::Vars(visible)]
}


proc defaultStyles {table} {
	return [set ${table}::Vars(styles)]
}


proc getOptions {table} {
	return [array get ${table}::Options]
}


proc setOptions {table options} {
	namespace eval [namespace current]::${table} {}
	array set [namespace current]::${table}::Options $options
}


proc setHeight {table height {cmd {}}} {
	variable ${table}::Vars

	set oldHeight $Vars(height)
	set Vars(height) $height
	set Vars(rows) [min $Vars(rows) $height]

	if {$height < $oldHeight} {
		for {set row $height} {$row < $oldHeight} {incr row} {
			$table.t item delete $row
		}
		if {$Vars(selection) >= $height} { set Vars(selection) -1 }
		if {$Vars(active) >= $height} { set Vars(active) -1 }

		event generate $table <<TableResized>> -data $height
	} elseif {$height > $oldHeight} {
		for {set row $oldHeight} {$row < $height} {incr row} {
			set item [$table.t item create]
			$table.t item lastchild root $item
			$table.t item configure $item -tag $row
			if {[llength $cmd]} {
				eval $cmd $table $item $row
			} else {
				$table.t item style set $item {*}$Vars(styles)
			}
		}

		event generate $table <<TableResized>> -data $height
		event generate $table <<TableFill>> -data [list $oldHeight $height]
	} else {
		event generate $table <<TableResized>> -data $height
	}
}


proc setColumnMininumWidth {table id width} {
	variable ${table}::Vars
	variable ${table}::Options

	if {[string match {*px} $width]} {
		set width [lindex [split $width px] 0]
		incr width 4
	} else {
		set width [expr {$Vars(charwidth)*$width}]
		set Options(-minwidth:$id) $width
	}
	set w [$table.t column cget $id -minwidth]
	$table.t column configure $id -minwidth $width
	return $w
}


proc doSelection {table} {
	variable ${table}::Vars

	lassign [winfo pointerxy $table] x y
	set x [expr {$x - [winfo rootx $table]}]
	set y [expr {$y - [winfo rooty $table]}]
	lassign [::table::identify $table $x $y] row
	::table::activate $table $row true
}


proc keepFocus {table {flag {}}} {
	variable ${table}::Vars

	if {[llength $flag] == 0} { return $Vars(keep) }
	set Vars(keep) $flag
}


proc height {table} {
	return [set ${table}::Vars(height)]
}


proc gridsize {table} {
	return [set ${table}::Vars(linespace)]
}


proc overhang {table} {
	variable ${table}::Vars
	return [expr {[$table.t header bbox 0] - 2*[$table.t cget -borderwidth]}]
}


proc linespace {table} {
	return [set ${table}::Vars(linespace)]
}


proc borderwidth {table} {
	return [set ${table}::Options(-borderwidth)]
}


proc selection {table} {
	return [set ${table}::Vars(selection)]
}


proc active {table} {
	return [set ${table}::Vars(active)]
}


proc focus {table} {
	if {[$table.t cget -takefocus]} {
		::focus $table.t
	}
}


proc see {table row} {
	$table.t see $row
}


proc bind {table sequence script} {
	::bind $table.t $sequence $script
}


proc configure {table id args} {
	$table.t element configure elemTxt$id {*}$args
}


proc setState {table row state} {
	$table.t item state set $row $state
}


proc setEnabled {table row flag} {
	$table.t item enabled $row $flag
}


proc at {table y} {
	variable ${table}::Vars

	if {$y <= $Vars(labelHeight)} { return none }
	set row [expr {($y - $Vars(labelHeight))/$Vars(linespace)}]
	if {$row < 0} { return none }
	if {$row >= $Vars(rows)} { return outside }
	return $row
}


proc identify {table x y} {
	variable ${table}::Vars

	set info [$table.t identify $x $y]
	if {[lindex $info 0] ne "item"} { return {-1 -1} }
	set row [$table.t item tag names [lindex $info 1]]
	if {$row >= $Vars(rows)} { set row -1 }
	return [list $row [lindex $info 3]]
}


proc scrolldistance {table y} {
	set y1 [lindex [set hbox [$table.t bbox header]] 3]
	set y2 [winfo height $table.t]

	if {$y < $y1} { return [expr {$y - $y1}] }
	if {$y > $y2} { return [expr {$y - $y2}] }

	return 0
}


proc used {table id} {
	variable ${table}::Vars

	set list {}
	for {set row 0} {$row < $Vars(height)} {incr row} {
		if {[llength [$table.t item id $row]]} {
			set img {}
			catch { set img [$table.t item element cget $row $id elemIco -image] }
			if {[llength $img] && $img ni $list} { lappend list $img }
		}
	}
	return $list
}


proc clear {table {first -1} {last -1}} {
	variable ${table}::Vars
	variable ${table}::Options

	if {$first < 0} {
		set first 0
		set last $Vars(rows)
		set Vars(rows) 0
	} elseif {$last < 0} {
		set last [min [expr {$first + 1}] $Vars(rows)]
	}

	select $table none
	activate $table none

	set Vars(rows) $first

	for {set row $first} {$row < $last} {incr row} {
		set item [$table.t item id $row]
		if {[llength $item]} {
			foreach id $Vars(visible) {
				catch {
					$table.t item element configure $row $id elemIco -image {}
					$table.t item element configure $row $id elemTxt$id -text ""
				}
			}
		}
	}
}


proc clearColumn {table id} {
	variable ${table}::Vars
	variable ${table}::Options

	if {$Options(-visible:$id)} {
		for {set row 0} {$row < $Vars(height)} {incr row} {
			set item [$table.t item id $row]
			if {[llength $item]} {
				catch {
					$table.t item element configure $row $id elemIco -image {}
					$table.t item element configure $row $id elemTxt$id -text ""
				}
			}
		}
	}
}


proc visible? {table id} {
	return [set [namespace current]::${table}::Options(-visible:$id)]
}


proc fitColumns {w} {
	FitColumns [FindActiveTableWindow [winfo toplevel $w]] fit
}


proc optimizeColumns {w} {
	FitColumns [FindActiveTableWindow [winfo toplevel $w]] optimize
}


proc squeezeColumns {w} {
	FitColumns [FindActiveTableWindow [winfo toplevel $w]] squeeze
}


proc setRows {table rows} {
	set ${table}::Vars(rows) $rows
}


proc scroll {table dir} {
	variable ${table}::Vars

	if {$Vars(rows) == 0} { return }
	set last [expr {$Vars(height) - 1}]

	switch $dir {
		up {
			$table.t item delete 0
			for {set row 1} {$row <= $last} {incr row} {
				set item [$table.t item id $row]
				$table.t item tag remove $item $row
				$table.t item tag add $item [expr {$row - 1}]
			}
			set item [$table.t item create]
			$table.t item configure $item -tags $last
			$table.t item style set $item {*}$Vars(styles)
			$table.t item lastchild root $item
		}

		down {
			$table.t item delete $last
			for {set row $last} {$row > 0} {incr row -1} {
				set item [$table.t item id [expr {$row - 1}]]
				$table.t item tag add $item $row
				$table.t item tag remove $item [expr {$row - 1}]
			}
			set item [$table.t item create]
			$table.t item configure $item -tags 0
			$table.t item style set $item {*}$Vars(styles)
			$table.t item firstchild root $item
		}
	}
}


proc select {table row} {
	variable ${table}::Vars
	variable ${table}::Options

	if {$row eq "none"} { set row -1 }
	if {$row == $Vars(selection)} { return }
	if {$row < 0} { set row -1 }

	if {$Vars(selection) != -1} {
		$table.t selection clear $Vars(selection)
	}

	if {$row >= 0} {
		$table.t selection add $row
	}

	set Vars(selection) $row
}


proc setSelection {table row} {
	variable ${table}::Vars

	if {$row == $Vars(selection)} { return }

	select $table $row
	event generate $table <<TableSelected>> -data $row
}


proc activate {table row {force false}} {
	variable ${table}::Vars

	if {$row eq "none" || $row < 0} { set row -1 }
	Activate $table $row $force false
}


proc setScrollCommand {table cmd} {
	$table.t configure -yscrollcommand $cmd
}


proc setColumnBackground {table id stripes background} {
	if {[llength $stripes]} {
		$table.t column configure $id -itembackground [list $stripes $background]
	} else {
		$table.t column configure $id -itembackground $background
	}
}


proc setColumnJustification {table id justification} {
	$table.t column configure $id -itemjustify $justification
}


proc setDefaultLayout {table id style} {
	variable ${table}::Vars
	variable ${table}::Options
	variable options

	set padx $options(element:padding)
	if {$Options(-ellipsis:$id)} { set squeeze "x" } else { set squeeze "" }

	$table.t style layout $style elemTxt$id \
		-pady $Options(-pady) \
		-padx [list $padx $padx] \
		-squeeze $squeeze \
		-sticky w \
		;
	$table.t style layout $style elemImg -union elemIco -iexpand nswe
	$table.t style layout $style elemIco -height $Vars(linespace) -padx [list $padx 0]
}


proc SbSet {sb first last} {
	if {$first <= 0 && $last >= 1} {
		grid remove $sb
		set state hide
	} else {
		grid $sb
		set state show
	}
	$sb set $first $last
	event generate [winfo parent $sb] <<TableScrollbar>> -data $state
}


proc Configure {table w h} {
	variable ${table}::Vars
	variable ${table}::Options

	if {$w <= 1} { return }

	if {$Vars(init)} {
		set Vars(init) 0
		GenerateTableMinSizeEvent $table
	}

	set hdrHeight [$table.t headerheight]
	set tableHeight [expr {$h - $hdrHeight - 2*[$table.t cget -borderwidth]}]
	set height [expr {$tableHeight/$Vars(linespace)}]
	if {$height < 0} { set height 0 }
	set Vars(labelHeight) $hdrHeight
	setHeight $table $height
	after idle [namespace code [list UpdateColunnWidths $table]]
}


proc ConfigureOnce {table w h} {
	variable ${table}::Vars

	if {$w <= 1} { return }

	if {$Vars(init)} {
		set Vars(init) 0
		GenerateTableMinSizeEvent $table
	}

	set Vars(labelHeight) [$table.t headerheight]
	bind $table <Configure> {}
}


proc UpdateColunnWidth {table column width} {
	variable ${table}::Vars
	variable ${table}::Options

	set column [lindex $Vars(columns) $column]
	set Options(-lastwidth:$column) $width
	event generate $table <<TableOptions>>
}


proc UpdateColunnWidths {table} {
	variable ${table}::Vars
	variable ${table}::Options

	foreach id $Vars(columns) {
		if {$Options(-visible:$id)} {
			set bbox [$table.t column bbox $id]
			if {[llength $bbox]} {
				lassign $bbox x1 y1 x2 y2
				set Options(-lastwidth:$id) [expr {$x2 - $x1}]
			} else {
				set Options(-lastwidth:$id) 0
			}
		} else {
			set Options(-lastwidth:$id) 0
		}
	}
}


proc ThemeChanged {table} {
	variable ${table}::Vars

	foreach id $Vars(columns) {
		$table.t column configure $id -background [ttk::style lookup [::theme::currentTheme] -background]
	}

	after idle [namespace code [list GenerateTableMinSizeEvent $table]]
}


proc GenerateTableMinSizeEvent {table} {
	variable ${table}::Vars

	set minwidth 0
	foreach id $Vars(visible) { incr minwidth [$table.t column minimumwidth $id] }
	incr minwidth 2	;# minimum width of trail column

	set Vars(minheight) [expr {$Vars(linespace) + [$table.t headerheight]}]
	set Vars(minwidth) $minwidth

	event generate $table <<TableMinSize>> -data [list $minwidth $Vars(minheight)]
}


proc SetText {table id var args} {
	$table.t column configure $id -text [set $var]
}


proc MakeStyles {table id foreground disabledForeground} {
	variable ${table}::Vars
	variable ${table}::Options
	variable options

	$table.t element create elemTxt$id text -lines 1 -font $Options(-font)
	SetForeground $table $id

	$table.t style create style$id
	$table.t style elements style$id [list elemSel elemImg elemBrd elemIco elemTxt$id]
	setDefaultLayout $table $id style$id
	$table.t style layout style$id elemSel -union elemTxt$id -iexpand nswe
	$table.t style layout style$id elemBrd -iexpand xy -detach yes
}


proc MoveColumn {table column before} {
	variable ${table}::Vars
	variable ${table}::Options

	$table.t column move $column $before
	foreach id $Vars(columns) {
		set Options(-order:$id) [$table.t column order $id]
	}
	event generate $table <<TableOptions>>
}


proc Activate {table row force send} {
	variable ${table}::Options
	variable ${table}::Vars

	if {$Vars(keep)} { return }
	if {$Vars(active) == $row} { return }
	set Vars(active) $row

	if {$row < 0} {
		$table.t activate root
	} elseif {$row < $Vars(height) && ($force || [::focus] eq "$table.t")} {
		$table.t activate $row
		if {$send} { event generate $table <<TableActivated>> -data $row }
	}
}


proc Deactivate {table} {
	variable ${table}::Vars

	set row $Vars(active)
	if {$row == -1} { return }
	$table.t activate root
}


proc FocusIn {table} {
	variable ${table}::Vars

	if {$Vars(active) != -1} {
		set row $Vars(active)
		set Vars(active) -1
		Activate $table $row false true
	}
}


proc FocusOut {table} {
	variable ${table}::Vars

	if {!$Vars(keep)} { Deactivate $table }
}


proc Highlight {table x y} {
	variable ${table}::Vars
	variable ${table}::Options

	focus $table
	::tooltip::hide
	set Vars(header) 0
	set id [$table.t identify $x $y]
	if {$id eq ""} { return }

	switch [lindex $id 0] {
		item {
			set row [$table.t item order [lindex $id 1] -visible]
			if {$row < $Vars(rows)} { Activate $table $row false true }
		}

		header {
			::TreeCtrl::ButtonPress1Header $table.t $id $x $y 0
			$table.t configure -cursor hand2
			set Vars(header) 1
		}
	}
}


proc Release {table x y} {
	variable ${table}::Vars

	if {$Vars(header)} {
		::TreeCtrl::Release1 $table.t $x $y
		$table.t configure -cursor {}
	}
}


proc SetSelection {table args} {
	variable ${table}::Vars

	set invoke 0

	if {[llength $args] == 3} {
		lassign $args x y state
		set id [$table.t identify $x $y]
		if {[llength $id] == 0} { return }
		if {[lindex $id 0] eq "header"} { return }
		set row [$table.t item order [lindex $id 1] -visible]
		if {$row >= $Vars(rows)} { return }
		if {$state & 1} { set invoke 1 }
	} elseif {[lindex $args 0] & 1} {
		if {$Vars(active) < 0} { return }
		set invoke 1
	}

	select $table $Vars(active)
	event generate $table <<TableSelected>> -data $Vars(active)
	if {$invoke} { event generate $table <<TableInvoked>> -data $Vars(active) }
}


proc Scroll {table action} {
	variable ${table}::Vars

	if {$Vars(rows) == 0} { return }

	switch $action {
		home {
			Activate $table 0 false true
			event generate $table <<TableScroll>> -data home
		}

		end {
			Activate $table [expr {$Vars(rows) - 1}] false true
			event generate $table <<TableScroll>> -data end
		}

		up {
			if {$Vars(active) > 0} {
				Activate $table [expr {$Vars(active) - 1}] false true
			} elseif {$Vars(active) == -1} {
				Activate $table [expr {$Vars(rows) - 1}] false true
			} else {
				event generate $table <<TableScroll>> -data up
			}
		}

		down {
			if {$Vars(active) == -1} {
				Activate $table 0 false true
			} elseif {$Vars(active) < [expr {$Vars(rows) - 1}]} {
				Activate $table [expr {$Vars(active) + 1}] false true
			} else {
				event generate $table <<TableScroll>> -data down
			}
		}

		prior {
			if {$Vars(active) > 0} {
				Activate $table 0 false true
			} elseif {$Vars(active) == -1} {
				Activate $table 0 false true
			} else {
				event generate $table <<TableScroll>> -data prior
			}
		}

		next {
			if {$Vars(active) == -1} {
				Activate $table [expr {$Vars(rows) - 1}] false true
			} elseif {$Vars(active) < [expr {$Vars(rows) - 1}]} {
				Activate $table [expr {$Vars(rows) - 1}] false true
			} else {
				event generate $table <<TableScroll>> -data next
			}
		}

		see {
			event generate $table <<TableScroll>> -data see
		}
	}
}


proc Tooltip {table mode {id {}} {x 0} {y 0}} {
	variable ${table}::Vars

	if {[llength $id]} {
		set id [$table.t column tag names $id]
		if {$Vars(ellipsis:$id) && ![$table.t column ellipsis $id]} { return }
		set focus [::focus]
		if {![llength $focus] || [winfo toplevel $table] ne [winfo toplevel $focus]} {
			set mode hide
		}
	}

	switch $mode {
		show {
			if {[llength $Vars(tooltipvar:$id)]} {
				::tooltip::showvar $table.t $Vars(tooltipvar:$id)
			} else {
				::tooltip::show $table.t $Vars(tooltip:$id)
			}
		}

		hide {
			::tooltip::hide true
		}
	}
}


proc VisitItem {table mode column item {x {}} {y {}}} {
	variable ${table}::Vars

	if {[string length $column] == 0} { return }
	if {[catch { set row [$table.t item tag names $item] }]} { return }
	if {$row >= $Vars(rows)} { return }
	set id [$table.t column tag names $column]
	event generate $table <<TableVisit>> -data [list $mode $id $row]
}


proc Hide {table id} {
	variable ${table}::Options
	variable ${table}::Vars

	$table.t column configure $id -visible 0
	set Options(-visible:$id) 0
	set i [lsearch -exact $Vars(visible) $id]
	if {$i >= 0} { set Vars(visible) [lreplace $Vars(visible) $i $i] }
	event generate $table <<TableHide>> -data $id
	after idle [namespace code [list UpdateColunnWidths $table]]
}


proc Show {table id} {
	variable ${table}::Options
	variable ${table}::Vars

	$table.t column configure $id -visible 1
	set Options(-visible:$id) 1
	set Vars(visible) {}
	foreach i $Vars(columns) {
		if {$Options(-visible:$i)} { lappend Vars(visible) $i }
	}
	event generate $table <<TableShow>> -data $id
	event generate $table <<TableFill>> -data [list 0 $Vars(rows)]
	after idle [namespace code [list UpdateColunnWidths $table]]
}


proc ToggleStretchable {table id} {
	variable ${table}::Options
	variable ${table}::Vars

	set options {}
	set weight [expr {$Options(-stretch:$id) ? 1 : 0}]
	lappend options -weight $weight
	if {$weight} {
		lappend options -uniform uniform
	} else {
		lassign [$table.t column bbox $id] x0 y0 x1 y1
		lappend options -width [expr {$x1 - $x0}]
		lappend options -uniform {}
	}
	$table.t column configure $id {*}$options
	event generate $table <<TableOptions>>
}


proc Cleanup {table} {
	after idle [list namespace delete [namespace current]::$table]
}


proc GetStripes {table id} {
	variable ${table}::Options

	if {[llength $Options(-stripes)] == 0} { return {} }
	if {[llength $Options(-stripes:$id)] == 0} { return $Options(-stripes) }
	return $Options(-stripes:$id)
}


proc PopupMenu {table x y X Y} {
	variable ${table}::Vars
	variable ${table}::Options
	variable options

	set action [::TreeCtrl::CursorAction $table.t $x $y]
	if {$action eq ""} {
		set id [$table.t identify $x $y]
		if {[lindex $id 0] ne "header"} {
			focus $table
			event generate $table <<TableMenu>> -x $x -y $y -rootx $X -rooty $Y
			return
		}
		set id [lindex $id 1]
		set header $mc::FillColumn
	} else {
		if {[lindex $action 1] ne "header"} { return }
		set id [$table.t column tag names [lindex $action 2]]
		if {[llength $Vars(tooltip:$id)]} {
			set header $Vars(tooltip:$id)
		} elseif {[llength $Vars(tooltipvar:$id)]} {
			set header [set $Vars(tooltipvar:$id)]
		} else {
			set header [$table.t column cget $id -text]
		}
	}

	keepFocus $table true
	set menu $table.__menu__${id}__
	catch { destroy $menu }
	menu $menu -tearoff 0 -disabledforeground black
	set count 0
	::tooltip::hide

	$menu add command                                    \
		-background $options(menu:headerbackground)       \
		-foreground $options(menu:headerforeground)       \
		-activebackground $options(menu:headerbackground) \
		-activeforeground $options(menu:headerforeground) \
		-font $options(menu:headerfont)                   \
		-state disabled                                   \
		;
	$menu add separator

	if {$id ne "tail"} {
		foreach item $Vars(menu:$id) {
			set type [lindex $item 0]
			array set opts [lrange $item 1 end]
			if {[info exists opts(-labelvar)]} {
				set opts(-label) [set $opts(-labelvar)]
				array unset opts -labelvar
			}
			$menu add $type {*}[array get opts]
			if {$type eq "radiobutton"} {
				::theme::configureRadioEntry $menu $opts(-label)
			}
			unset opts
		}

		if {$Options(-removable:$id)} {
			$menu add command \
				-label $mc::Hide \
				-command [namespace code [list Hide $table $id]] \
				;
		}

		if {	!$Options(-pixels:$id)
			&& $Options(-optimizable:$id)
			&& (	$Options(-maxwidth:$id) == 0
				|| $Options(-maxwidth:$id) >= $Options(-width:$id))} {
			$menu add command \
				-label $mc::OptimizeColumn \
				-command [list $table.t column optimize $id] \
				;
			$menu add command \
				-label $mc::FitColumnWidth \
				-command [list $table.t column fit $id] \
				;
			$menu add command \
				-label $mc::ExpandColumn \
				-command [list $table.t column expand $id yes] \
				;
		}
		$menu add command \
			-label "$mc::Configure..." \
			-command [namespace code [list OpenConfigureDialog $table $id $header]]

		if {	!$Options(-pixels:$id)
			&& (	($Options(-maxwidth:$id) == 0 && $Options(-minwidth:$id) > 0)
				|| $Options(-maxwidth:$id) > $Options(-minwidth:$id))} {
			$menu add separator
			$menu add check \
				-label $mc::AutoStretchColumn \
				-variable [namespace current]::${table}::Options(-stretch:$id) \
				-command [namespace code [list ToggleStretchable $table $id]] \
				;
		}
	}

	incr count
	array set hidden {}
	set groups {}
	set tail 0
	foreach i [$table.t column list] {
		set id [$table.t column tag names $i]
		if {!$Options(-visible:$id)} {
			if {$id eq "tail"} {
				set tail 1
			} else {
				set g $Vars(groupvar:$id)
				set t 1
				if {[llength $g] == 0} {
					set g $Vars(group:$id)
					set t 0
				}
				set entry [list $t $g]
				set k [lsearch -exact $groups $entry]
				if {$k == -1} { lappend groups $entry }
				lappend hidden($g) $id
			}
		}
	}
	set k [lsearch -exact $groups ""]
	if {$k >= 0} {
		set e [lindex $groups $k]
		set groups [lreplace $groups $k $k]
		lappend groups $e
	}

	$menu entryconfigure 0 -label $header

	if {$id ne "tail"} { $menu add separator }

	if {$Options(-listmode)} {
		$menu add command \
			-label $mc::OptimizeColumns \
			-command [namespace code [list FitColumns $table optimize]] \
			;
		$menu add command \
			-label $mc::FitColumns \
			-command [namespace code [list FitColumns $table fit]] \
			;
		$menu add command \
			-label $mc::SqueezeColumns \
			-command [namespace code [list FitColumns $table squeeze]] \
			;
	} else {
		$menu add command \
			-label $mc::OptimizeColumns \
			-accelerator $mc::AccelOptimizeColumns \
			-command [namespace code [list FitColumns $table optimize]] \
			;
		$menu add command \
			-label $mc::FitColumns \
			-accelerator $mc::AccelFitColumns \
			-command [namespace code [list FitColumns $table fit]] \
			;
		$menu add command \
			-label $mc::SqueezeColumns \
			-accelerator $mc::AccelSqueezeColumns \
			-command [namespace code [list FitColumns $table squeeze]] \
			;
	}

	if {$tail || [llength $groups]} {
		set subm [menu $menu.mShowColumn -tearoff false]
		::bind $subm <Destroy> [list ::tooltip::tooltip clear $subm*]
		$menu add cascade -menu $subm -label $mc::ShowColumn
		incr count

		set index 0
		foreach group $groups {
			lassign $group type name
			if {[string length $name]} {
				menu $subm.$index -tearoff false
				if {$type} {
					set text [set $name]
				} else {
					set text $name
				}
				$subm add cascade -menu $subm.$index -label $text
				incr index
			}
		}

		set index 0
		foreach group $groups {
			set name [lindex $group 1]
			foreach id $hidden($name) {
				if {[llength $Vars(tooltipvar:$id)]} {
					set text [set $Vars(tooltipvar:$id)]
				} elseif {[llength $Vars(tooltip:$id)]} {
					set text $Vars(tooltip:$id)
				} else {
					set text [$table.t column cget $id -text]
				}
				if {[string length $name]} {
					set m $subm.$index
				} else {
					set m $subm
				}
				$m add command -label $text -command [namespace code [list Show $table $id]]
			}
			if {[string length $name]} { incr index }
		}
		if {$tail} {
			$subm add command -label $mc::FillColumn -command [namespace code [list Show $table $id]]
		}
	}

	if {$count} {
		::bind $menu <<MenuUnpost>> [list event generate $table <<TablePopdown>>]
		tk_popup $menu $X $Y
	}

	keepFocus $table false
}


proc FindActiveTableWindow {w} {
	set first ""

	foreach child [winfo children $w] {
		if {[winfo class $child] eq "TreeCtrl"} {
			if {[::focus] eq $child} {
				return [winfo parent $child]
			} else {
				set first [winfo parent $child]
			}
		} else {
			set result [FindActiveTableWindow $child]
			if {[llength $result]} { return $result }
		}
	}

	return $first
}


proc FitColumns {table action} {
	variable ${table}::Vars
	variable ${table}::Options

	if {$action eq "squeeze"} {
		$table.t column squeeze
	} else {
		set columns {}
		foreach id $Vars(visible) {
			if {	!$Options(-pixels:$id)
				&& $Options(-optimizable:$id)
				&& (	$Options(-maxwidth:$id) == 0
					|| $Options(-maxwidth:$id) >= $Options(-width:$id))} {
				lappend columns $id
			}
		}
		$table.t column $action $columns
	}

	after idle [namespace code [list UpdateColunnWidths $table]]
}


proc OpenConfigureDialog {table id header} {
	variable ${table}::Vars
	variable ${table}::Options

	keepFocus $table true
	foreach attr {	minwidth maxwidth foreground background
						selectionforeground disabledforeground stripes} {
		set Vars($attr:$id:menu) $Options(-$attr:$id)
	}
	foreach attr {foreground background selectionbackground disabledforeground stripes highlightcolor} {
		set Vars($attr:menu) $Options(-$attr)
	}
	if {$Vars(minwidth:$id:menu) == 0} {
		set Vars(minwidth:$id:menu) $Options(-width:$id)
		if {$Vars(maxwidth:$id:menu) == 0} { set Vars(maxwidth:$id:menu) $Options(-width:$id) }
	}

	set top [tk::toplevel $table.__configure__${id}__ -class Dialog]
	::bind $top <Alt-Key> [list tk::AltKeyInDialog $top %A]
	set f [ttk::frame $top.f]
	
	set col [ttk::labelframe $f.col -text "$mc::Column $header"]
	set tbl [ttk::labelframe $f.tbl -text $mc::Table]

	ttk::button $col.bstripes \
		-text $mc::Stripes \
		-command [namespace code [list SelectStripes $table $id $col.bstripes]]
#	ttk::button $col.berasestripes \
#		-image $icon::iconEraser \
#		-command [namespace code [list EraseStripes $table $id $col.berasestripes]]
	foreach text {Foreground Background DisabledForeground SelectionForeground} {
		set attr [string tolower $text]
		ttk::button $col.b$attr \
			-text [set mc::$text] \
			-command [namespace code [list SelectColor $table $id $col.b$attr $text $attr]]
	}
	foreach text {MinWidth MaxWidth} {
		set attr [string tolower $text]
		ttk::label $col.l$attr -text [set mc::$text]
		::ttk::spinbox $col.s$attr  \
			-background white \
			-from 0 \
			-to 99 \
			-increment 1 \
			-width 3 \
			-justify right \
			-textvariable [namespace current]::${table}::Vars($attr:$id:menu) \
			-exportselection false \
			;
		::validate::spinboxInt $col.s$attr
		::bind $col.s$attr <FocusIn>  {+ %W configure -validate key }
		::bind $col.s$attr <FocusOut> [list $col.s$attr selection clear]
	}

	ttk::button $tbl.bstripes \
		-text $mc::Stripes \
		-command [namespace code [list SelectTableStripes $table $id $tbl.bstripes]]
#	ttk::button $tbl.berasestripes \
#		-image $icon::iconEraser \
#		-command [namespace code [list EraseStripes $table $id $tbl.berasestripes]]
	foreach text {	Foreground Background DisabledForeground
						SelectionForeground SelectionBackground HighlightColor} {
		set attr [string tolower $text]
		ttk::button $tbl.b$attr \
			-text [set mc::$text] \
			-command [namespace code [list SelectTableColor $table $id $tbl $text $attr]]
	}

	grid $col.bstripes					-row  2 -column 1 -sticky we -columnspan 3
#	grid $col.berasestripes				-row  2 -column 5 -sticky we
	grid $col.bforeground				-row  4 -column 1 -sticky we -columnspan 3
	grid $col.bbackground				-row  6 -column 1 -sticky we -columnspan 3
	grid $col.bdisabledforeground		-row  8 -column 1 -sticky we -columnspan 3
	grid $col.bselectionforeground	-row 10 -column 1 -sticky we -columnspan 3
	grid columnconfigure $col {0 2 4} -minsize $::theme::padding
	grid columnconfigure $col {1 3} -weight 1
	if {$Options(-pixels:$id)} {
		grid rowconfigure $col {1 3 5 7 9 11} -minsize $::theme::padding
	} else {
		grid $col.lminwidth			-row 12 -column 1 -sticky w
		grid $col.sminwidth			-row 12 -column 3 -sticky we
		grid $col.lmaxwidth			-row 14 -column 1 -sticky w
		grid $col.smaxwidth			-row 14 -column 3 -sticky we
		grid rowconfigure $col {1 3 5 7 9 11 13 15} -minsize $::theme::padding
		grid rowconfigure $col {11 13} -minsize [expr {$::theme::padding + 3}]
	}

	grid $tbl.bstripes					-row  2 -column 1 -sticky we
#	grid $tbl.berasestripes				-row  2 -column 3 -sticky we
	grid $tbl.bforeground				-row  4 -column 1 -sticky we
	grid $tbl.bbackground				-row  6 -column 1 -sticky we
	grid $tbl.bdisabledforeground		-row  8 -column 1 -sticky we
	grid $tbl.bselectionforeground	-row 10 -column 1 -sticky we
	grid $tbl.bselectionbackground	-row 12 -column 1 -sticky we
	grid $tbl.bhighlightcolor			-row 14 -column 1 -sticky we
	grid columnconfigure $tbl {0 2} -minsize $::theme::padding
	grid columnconfigure $tbl 1 -weight 1
	grid rowconfigure $tbl {1 3 5 7 9 11 13 15} -minsize $::theme::padding

	grid $f.col -row 1 -column 1 -sticky wens
	grid $f.tbl -row 1 -column 3 -sticky wens
	grid rowconfigure $f {0 2} -minsize $::theme::padding
	grid columnconfigure $f {0 2 4} -minsize $::theme::padding

	pack $f -fill x
	::widget::dialogButtons $top {ok cancel}
	$top.cancel configure -command "[namespace current]::ResetColors $table $id; destroy $top"
	$top.ok configure -command "[namespace current]::AcceptSettings $table $id; destroy $top"
	::bind $top <Return> "
		if {\[$top.ok cget -state\] eq {normal}} {
			focus $top.ok
			event generate $top.ok <Key-space>
		}
	"
	::bind $top <Escape> [list $top.cancel invoke]
	ConfigureDialog $table $id $top

	wm withdraw $top
	wm title $top [tk appname]
	wm protocol $top WM_DELETE_WINDOW [namespace code [list destroy $top]]
	wm transient $top [winfo toplevel $table]
	wm resizable $top false false
	if {[tk windowingsystem] eq "aqua"} {
		catch { ::tk::unsupported::MacWindowStyle style $top moveableModal {} }
	}
	::util::place $top center $table
	wm deiconify $top
	::focus $tbl.bforeground
	ttk::grabWindow $top
	tkwait window $top
	ttk::releaseGrab $top
	keepFocus $table false
}


proc ConfigureDialog {table id dlg} {
	variable ${table}::Options

	set col $dlg.f.col
	set tbl $dlg.f.tbl

	set stripes [GetStripes $table $id]
	
	if {[llength $stripes] == 0} {
		$col.bbackground configure -state normal
		$tbl.bbackground configure -state disabled
#		$tbl.berasestripes configure -state disabled
	} else {
		$col.bbackground configure -state disabled
		$tbl.bbackground configure -state normal
#		$tbl.berasestripes configure -state normal
	}
}


proc MakePreview {foreground background preview path} {
	set text [set [namespace current]::mc::Preview]
	set canv [tk::canvas $path.coords -width 150 -height 20 -borderwidth 1 -relief sunken]
	$canv configure -background $background
	$canv create text 75 10 -text $text -fill $foreground -tag abcd -font TkDefaultFont
	if {$preview eq "foreground"} {
		::bind $canv <<ChooseColorSelected>> "$canv itemconfigure abcd -fill %d"
	} else {
		::bind $canv <<ChooseColorSelected>> "$canv configure -background %d"
	}
	pack $canv -fill x -expand yes
	return $canv
}


proc ChooseColor {parent title what initialcolor previewcolor background usedColors eraser} {
	variable RecentColors
	variable Colors

	switch -glob $what {
		*foreground	{ set which foreground }
		*stripes		{ set which stripes }
		default		{ set which background }
	}

	if {$which eq "stripes"} { set recent stripes } else { set recent $parent:$which }
	if {![info exists RecentColors($recent)]} { set RecentColors($recent) [lrepeat 6 {}] }
	set baseColors {}
	set embedcmd {}

	switch $which {
		stripes {
			set backgroundcolor [::dialog::choosecolor::getActualColor $background]
			scan $backgroundcolor "\#%2x%2x%2x" r g b
			lassign [::dialog::choosecolor::rgb2hsv $r $g $b] h s v
			if {$v < 0.5} { set incr 0.1 } else { set incr -0.02 }
			for {set i 1} {$i <= 6} {incr i} {
				set vv [expr {min(1.0, max(0, $v + $i*$incr))}]
				lassign [::dialog::choosecolor::hsv2rgb $h $s $vv] r g b
				set color [format "#%02x%02x%02x" $r $g $b]
				if {$color ni $baseColors} { lappend baseColors $color }
			}
		}
		
		foreground {
			set baseColors $Colors
			set embedcmd [namespace code [list MakePreview $initialcolor $previewcolor foreground]]
		}

		background {
			if {![string match table* $what]} {
				set embedcmd [namespace code [list MakePreview $previewcolor $initialcolor background]]
			}
		}
	}

	set selection [::colormenu::popup $parent              \
							-class Dialog                        \
							-basecolors $baseColors              \
							-initialcolor $initialcolor          \
							-recentcolors [namespace current]::RecentColors($recent) \
							-usedcolors $usedColors              \
							-eraser $eraser                      \
							-geometry last                       \
							-modal true                          \
							-place centeronparent                \
							-embedcmd $embedcmd                  \
							]
	
	if {[llength $selection]} {
		set initialcolor [::dialog::choosecolor::getActualColor $initialcolor]
		set RecentColors($recent) \
			[::dialog::choosecolor::addToList $RecentColors($recent) $initialcolor]
	}

	return $selection
}


proc SelectTableColor {table id parent title which} {
	variable ${table}::Options
	variable ${table}::Vars

	switch $which {
		foreground - disabledforeground {
			set previewcolor $Options(-background)
			set attrs {foreground disabledforeground selectionforeground}
		}

		selectionforeground {
			set previewcolor $Options(-selectionbackground)
			set attrs {foreground disabledforeground selectionforeground}
		}

		background - highlightcolor {
			set previewcolor $Options(-foreground:$id)
			if {[llength $previewcolor] == 0} {
				set previewcolor $Options(-foreground)
			}
			set attrs background
		}

		selectionbackground {
			set previewcolor $Options(-selectionforeground:$id)
			if {[llength $previewcolor] == 0} {
				set previewcolor $Options(-selectionforeground)
			}
			set attrs background
		}
	}

	set usedColors {}
	foreach i $Vars(columns) {
		foreach attr $attrs {
			set color [::dialog::choosecolor::getActualColor $Options(-$attr:$i)]
			if {[llength $color] && $color ni $usedColors} {
				lappend usedColors $color
			}
		}
	}

	set parent $parent.b$which
	set color [ChooseColor \
		$parent             \
		[set mc::$title]    \
		table-$which        \
		$Options(-$which)   \
		$previewcolor       \
		{}                  \
		$usedColors         \
		false               \
	]

	if {[llength $color]} {
		set Options(-$which) $color

		switch $which {
			foreground - disabledforeground - selectionforeground {
				foreach id $Vars(columns) { SetForeground $table $id }
			}

			background {
				SetBackground $table
			}

			selectionbackground {
				set colors [list $color selected]
				if {[llength $Options(-highlightcolor)]} { lappend colors $Options(-highlightcolor) active }
				$table.t element configure elemSel -fill $colors
				$table.t element configure elemImg -fill $colors
			}

			highlightcolor {
				set colors [list $Options(-selectionbackground) selected $Options(-highlightcolor) active]
				$table.t element configure elemSel -fill $colors
				$table.t element configure elemImg -fill $colors
			}
		}
	}
}


proc SelectColor {table id parent title which} {
	variable ${table}::Options
	variable ${table}::Vars

	set previewColor {}
	set usedColors {}

	switch $which {
		selectionforeground { set previewColor $Options(-selectionbackground) }

		foreground - disabledforeground {
			set previewColor $Options(-background:$id)
			if {[llength $previewColor] == 0} { set previewColor $Options(-background) }
		}

		background {
			set previewColor $Options(-foreground:$id)
			if {[llength $previewColor] == 0} { set previewColor $Options(-foreground) }
		}
	}

	if {$which eq "background"} {
		set attrs background
	} else {
		set attrs {foreground disabledforeground selectionforeground}
	}

	foreach i $Vars(columns) {
		foreach attr $attrs {
			set color [::dialog::choosecolor::getActualColor $Options(-$attr:$i)]
			if {[llength $color] && $color ni $usedColors} {
				lappend usedColors $color
			}
		}
	}

	set initialColor $Options(-$which:$id)
	if {[llength $initialColor] == 0} {
		set initialColor $Options(-$which)
		set eraser false
	} else {
		set eraser true
	}

	set color [ChooseColor \
		$parent             \
		[set mc::$title]    \
		column-$which       \
		$initialColor       \
		$previewColor       \
		{}                  \
		$usedColors         \
		$eraser             \
	]
	if {[llength $color] == 0} { return }
	if {$color eq "erase"} { set color {} }
	set Options(-$which:$id) $color

	switch $which {
		foreground - disabledforeground - selectionforeground { SetForeground $table $id }
		background { SetBackground $table }
	}
}


proc SelectTableStripes {table id parent} {
	variable ${table}::Options
	variable ${table}::Vars

	if {[llength $Options(-stripes)]} { set eraser true } else { set eraser false }

	set color [ChooseColor   \
		$parent               \
		$mc::Stripes          \
		table-stripes         \
		$Options(-stripes)    \
		$Options(-foreground) \
		$Options(-background) \
		{}                    \
		$eraser               \
	]

	if {$color eq "erase"} {
		set Options(-stripes) {}
		SetBackground $table
	} elseif {[llength $color]} {
		set Options(-stripes) $color
		SetBackground $table
	}

	ConfigureDialog $table $id [winfo toplevel $parent]
}


proc SelectStripes {table id parent} {
	variable ${table}::Options
	variable ${table}::Vars

	set foreground $Options(-foreground:$id)
	if {[llength $foreground] == 0} { set foreground $Options(-foreground) }
	set background $Options(-background:$id)
	if {[llength $background] == 0} { set background $Options(-background) }
	if {[llength $Options(-stripes:$id)]} { set eraser true } else { set eraser false }

	set color [ChooseColor     \
		$parent                 \
		$mc::Stripes            \
		stripes                 \
		[GetStripes $table $id] \
		$foreground             \
		$background             \
		{}                      \
		$eraser                 \
	]

	if {$color eq "erase"} {
		set Options(-stripes:$id) {}
		SetBackground $table
	} elseif {[llength $color]} {
		set Options(-stripes:$id) $color
		SetBackground $table
	}

	ConfigureDialog $table $id [winfo toplevel $parent]
}


proc ResetColors {table id} {
	variable ${table}::Options
	variable ${table}::Vars

	foreach attr {	minwidth maxwidth foreground background
						selectionforeground disabledforeground stripes} {
		set Options(-$attr:$id) $Vars($attr:$id:menu)
	}
	foreach attr {foreground background selectionbackground disabledforeground stripes highlightcolor} {
		set Options(-$attr) $Vars($attr:menu)
	}

	set colors [list $Options(-selectionbackground) selected]
	if {[llength $Options(-highlightcolor)]} { lappend colors $Options(-highlightcolor) active }
	$table.t element configure elemSel -fill $colors
	$table.t element configure elemImg -fill $colors

	SetBackground $table
	foreach id $Vars(columns) { SetForeground $table $id }
}


proc SetForeground {table id} {
	variable ${table}::Options

	set foreground $Options(-foreground:$id)
	if {[llength $foreground] == 0} { set foreground $Options(-foreground) }
	set selected $Options(-selectionforeground:$id)
	if {[llength $selected] == 0} { set selected $Options(-selectionforeground) }
	set disabled $Options(-disabledforeground:$id)
	if {[llength $disabled] == 0} { set disabled $Options(-disabledforeground) }
	set colors [list $disabled deleted $selected selected $foreground {}]

	$table.t element configure elemTxt$id -fill $colors
}


proc SetBackground {table} {
	variable ${table}::Options

	foreach id [$table.t column list -visible] {
		set id [$table.t column tag names $id]
		set stripes [GetStripes $table $id]
		set background $Options(-background:$id)
		if {[llength $background] == 0} { set background $Options(-background) }
		setColumnBackground $table $id $stripes $background
	}

	setColumnBackground $table $id $Options(-stripes) $Options(-background)
}


proc EraseStripes {table id parent} {
	variable ${table}::Options
	variable RecentColors

	if {![info exists RecentColors(stripes)]} { set RecentColors(stripes) [lrepeat 6 {}] }
	if {[lindex $data 0] eq "erase"} {
		set color [lindex $data 1]
		if {$color ne ""} {
			set n [lsearch -exact $RecentColors(stripes) $color]
			if {$n == -1} { set n end }
			set RecentColors(stripes) [linsert [lreplace $RecentColors(stripes) $n $n] 0 $color]
		}
	}

	if {[llength $id]} {
		set Options(-stripes:$id) {}
	} else {
		set Options(-stripes) {}
	}

	SetBackground $table
	ConfigureDialog $table $id [winfo toplevel $parent]
}


proc AcceptSettings {table id} {
	variable ${table}::Vars
	variable ${table}::Options

	foreach which {minwidth maxwidth} { set Options(-$which:$id) $Vars($which:$id:menu) }
	event generate $table <<TableOptions>>
}

} ;# namespace table

# vi:set ts=3 sw=3:
