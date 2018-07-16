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
set ShrinkColumn				"Shrink column width"
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
event add <<TableRebuild>>		TableRebuild
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

array set ColorLookup {
	background					white
	foreground					black
	selectionbackground		#ffdd76
	selectionforeground		black
	disabledforeground		#555555
	activebackground			#e5e5e5
	labelforeground			black
	labelbackground			#d9d9d9
}
#	activebackground			#e5e5e5
#	activebackground			#d4d8d9
#	activebackground			#ffdc9d

array set Defaults {
	-width                  0
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
	-configurable				1
	-showlines					0
	-linethickness				2
	-linecolor					{}
	-showrootchildbuttons	0
	-showrootbutton			0
	-treecolumn					{}
	-buttonimage				{}
	-imagepadx					{2 2}
	-imagepady					{0 0}
	-padx							{2 2}
	-pady							{0 0}
	-height						10
	-stripes						{}
	-highlightcolor			{}
	-labelcommand				{}
	-columns						{}
	-background					table,background
	-foreground					table,foreground
	-selectionbackground		table,selectionbackground
	-selectionforeground		table,selectionforeground
	-disabledforeground		table,disabledforeground
	-activebackground			table,activebackground
	-labelforeground			table,labelforeground
	-labelbackground			table,labelbackground
}

variable Eraser [::icon::makeStateSpecificIcons $::colormenu::icon::16x16::eraser]
variable Colors {black white gray50 darkviolet darkBlue blue2 blue darkGreen darkRed red2 red #68480a}
variable RecentColors
variable WidgetMap
variable IdMap
variable Bindings

set KeyFitColumns			<Control-Key-comma>
set KeyOptimizeColumns	<Control-Key-period>
set KeySqueezeColumns	<Control-Key-numbersign>

set shiftMask 1


proc table {args} {
	variable icon::13x13::checked
	variable icon::13x13::unchecked
	variable icon::13x13::none
	variable Defaults
	variable Colors
	variable KeyFitColumns
	variable KeyOptimizeColumns
	variable KeySqueezeColumns

	set parent [lindex $args 0]
	set table [tk::frame $parent]

	namespace eval $table {}
	variable ${table}::Vars
	variable ColorLookup
	variable WidgetMap
	variable IdMap

	set Vars(menucmd) {}
	array set opts [lrange $args 1 end]
	if {[info exists opts(-id)]} { set Vars(id) $opts(-id) } else { set Vars(id) $table }
	if {[info exists opts(-menucmd)]} { set Vars(menucmd) $opts(-menucmd) }
	namespace eval $Vars(id) {}
	variable ${Vars(id)}::Options
	set IdMap($table) $Vars(id)
	set WidgetMap($Vars(id)) $table

	if {![info exists Options]} {
		array set Options [array get Defaults]
		array set Options [lrange $args 1 end]
		if {[info exists Options(-id)]} {
			array unset Options -id
		}
	} else {
		set opts(-labelcommand) {}
		array set opts [lrange $args 1 end]
		foreach attr {	-labelcommand -takefocus -showlines -linethickness -linecolor
							-showrootchildbuttons -showrootbutton -treecolumn -buttonimage} {
			if {[info exists opts($attr)]} { set Options($attr) $opts($attr) }
		}
		if {[info exists opts(-id)]} { set Vars(id) $opts(-id) }
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
	set Vars(treecolumn)		$Options(-treecolumn)
	set Vars(detach)			0

	if {$Options(-showlines)} { set Vars(detach) 1 }

	set background [lookupColor $Options(-background)]
	set showrsb $Options(-showrootchildbuttons)
	set showrb $Options(-showrootbutton)

	treectrl $table.t                          \
		-width $Options(-width)                 \
		-takefocus $Options(-takefocus)         \
		-highlightthickness 0                   \
		-borderwidth $Options(-borderwidth)     \
		-relief sunken                          \
		-showheader yes                         \
		-showbuttons $Options(-showlines)       \
		-linethickness $Options(-linethickness) \
		-linestyle solid                        \
		-selectmode single                      \
		-showroot no                            \
		-showlines $Options(-showlines)         \
		-showrootlines no                       \
		-showrootchildbuttons $showrsb          \
		-showrootbutton $showrb                 \
		-columnresizemode realtime              \
		-itemprefix i                           \
		-xscrollincrement 1                     \
		-keepuserwidth no                       \
		-fullstripes $Options(-fullstripes)     \
		-background $background                 \
		-buttonimage $Options(-buttonimage)     \
		;
	if {[string length $Options(-linecolor)]} { $table.t configure -linecolor $Options(-linecolor) }
	$table.t column dragconfigure -enable yes
	$table.t notify install <ColumnDrag-receive>
	$table.t notify install <Header-enter>
	$table.t notify install <Header-leave>
	$table.t notify install <Item-enter>
	$table.t notify install <Item-leave>
	$table.t notify install <Column-resized>
	$table.t notify bind Table <ColumnDrag-receive> [namespace code [list MoveColumn $table %C %b]]
	$table.t notify bind Table <Header-enter> [namespace code [list VisitHeader $table enter %C %I]]
	$table.t notify bind Table <Header-leave> [namespace code [list VisitHeader $table leave %C %I]]
	$table.t notify bind Table <Item-enter> [namespace code [list VisitItem $table enter %C %I %M]]
	$table.t notify bind Table <Item-leave> [namespace code [list VisitItem $table leave %C %I %M]]
	$table.t notify bind Table <Column-resized> [namespace code [list UpdateColunnWidth $table %C %w]]

	foreach attr {	-showbuttons -showlines -showrootbutton -showrootchildbuttons -linethickness \
						-linecolor -fullstripes -buttonimage} {
		array unset Options $attr
	}

	setColumnBackground $table tail [lookupColor $Options(-stripes)] [lookupColor $background]
	set activeBackground [list [lookupColor $Options(-activebackground)] {active} {} {}]
	$table.t state define deleted
	$table.t state define warning
	$table.t state define check
	$table.t state define nocheck
	$table.t element create elemIco image
	lappend colors [lookupColor $Options(-selectionbackground)] selected
	if {[llength $Options(-highlightcolor)]} {
		lappend colors [lookupColor $Options(-highlightcolor)] active
	}
	$table.t element create elemSel rect -fill $colors
	$table.t element create elemImg rect -fill $colors
	$table.t element create elemChk image -image [list $checked check $unchecked nocheck $none {}]
	$table.t element create elemBrd border  \
		-filled no                           \
		-relief raised                       \
		-thickness 1                         \
		-background $activeBackground        \
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
	::bind $table.t <Home>					[namespace code [list ScrollVert $table home]]
	::bind $table.t <End>					[namespace code [list ScrollVert $table end]]
	::bind $table.t <Prior>					[namespace code [list ScrollVert $table prior]]
	::bind $table.t <Next>					[namespace code [list ScrollVert $table next]]
	::bind $table.t <Up>						[namespace code [list ScrollVert $table up]]
	::bind $table.t <Down>					[namespace code [list ScrollVert $table down]]
	::bind $table.t <Control-Home>		[namespace code [list ScrollVert $table see]]
	::bind $table.t <Key-space>			[namespace code [list SetSelection $table %s]]
	::bind $table.t <Left>					[list $table.t xview scroll -5 units]
	::bind $table.t <Right>					[list $table.t xview scroll +5 units]
	::bind $table.t <Control-Left>		[list $table.t xview moveto 0.0]
	::bind $table.t <Control-Right>		[list $table.t xview moveto 1.0]
	::bind $table.t <<ThemeChanged>>		[namespace code [list ThemeChanged $table]]

	if {[tk windowingsystem] eq "x11"} {
		::table::bind $table <Button-4> [namespace code [list ScrollHorz $table.t -10 %s]]
		::table::bind $table <Button-4> {+ break }
		::table::bind $table <Button-5> [namespace code [list ScrollHorz $table.t +10 %s]]
		::table::bind $table <Button-5> {+ break }
	} else {
		::table::bind $table <MouseWheel> [namespace code [list \
			[list ScrollHorz $table.t {[expr {%D < 0 ? -10 : 10}]} %s]]]
		::table::bind $table <MouseWheel> {+ break }
	}

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
	if {$Options(-takefocus) eq 1} {
		::bind $table.sb <Any-Button> +[namespace code [list focus $table]]
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
	variable IdMap

	set optId $IdMap($table)
	variable ${optId}::Options

	array set opts {
		-text						{}
		-textvar					{}
		-image					{}
		-tooltip					{}
		-tooltipvar				{}
		-nameingroup			{}
		-associated				{}
		-menu						{}
		-group					{}
		-groupvar				{}
		-checkbutton			0
		-foreground				{}
		-disabledforeground	{}
	}

	set keys [array names opts]
	array set opts $args
	if {[info exists Options(-visible:$id)]} {
		foreach key [array names opts] {
			if {[info exists Options($key:$id)]} {
				set opts($key) $Options($key:$id)
			}
		}
	}

	set labelText {}
	set labelImage {}

	if {[llength $opts(-image)]} {
		set labelImage $opts(-image)
	} elseif {[llength $opts(-textvar)]} {
		set labelText [set $opts(-textvar)]
		set trace \
			"variable $opts(-textvar) write { [namespace current]::SetText $table $id $opts(-textvar) }"
		trace add {*}$trace
		::bind $table.t <Destroy> +[list trace remove {*}$trace]
	} else {
		set labelText $opts(-text)
	}

	$table.t column create                                  \
		-tag $id                                             \
		-expand yes                                          \
		-steady yes                                          \
		-image $labelImage                                   \
		-text $labelText                                     \
		-font $Options(-labelfont)                           \
		-textcolor [lookupColor $Options(-labelforeground)]  \
		-background [lookupColor $Options(-labelbackground)] \
		-textpadx $Options(-padx)                            \
		-textpady $Options(-pady)                            \
		-imagepadx $Options(-imagepadx)                      \
		-imagepady $Options(-imagepady)                      \
		-borderwidth $Options(-labelborderwidth)             \
		-button no                                           \
		-uniform uniform                                     \
		;

	if {$id eq $Vars(treecolumn)} {
		$table.t configure -treecolumn $id
	}

	ConfigureColumn $table $id {*}$args

	set foreground $opts(-foreground)
	if {[llength $foreground] == 0} { set foreground $Options(-foreground) }
	set disabledforeground $opts(-disabledforeground)
	if {[llength $disabledforeground] == 0} { set disabledforeground $Options(-disabledforeground) }

	set Vars(tooltip:$id) $opts(-tooltip)
	set Vars(tooltipvar:$id) $opts(-tooltipvar)
	set Vars(nameingroup:$id) $opts(-nameingroup)
	set Vars(associated:$id) $opts(-associated)
	set Vars(menu:$id) $opts(-menu)
	set Vars(group:$id) $opts(-group)
	set Vars(groupvar:$id) $opts(-groupvar)
	set Vars(tags:$id) {}
	lappend Vars(styles) $id style$id
	lappend Vars(columns) $id

	set Vars(ellipsis:$id) 0
	if {[llength $Vars(tooltip:$id)] == 0 && [llength $opts(-text)]} {
		set Vars(tooltip:$id) $opts(-text)
		set Vars(ellipsis:$id) 1
	}
	if {[llength $Vars(tooltipvar:$id)] == 0 && [llength $opts(-textvar)]} {
		set Vars(tooltipvar:$id) $opts(-textvar)
		set Vars(ellipsis:$id) 1
	}

	incr Vars(size)

	foreach opt [array names opts] {
		if {$opt eq "-foreground" || $opt ni $keys} {
			set Options($opt:$id) $opts($opt)
		}
	}

	MakeStyles $table $id $foreground $disabledforeground $opts(-checkbutton)
}


proc insert {table index list} {
	variable ${table}::Vars
	variable IdMap

	set optId $IdMap($table)
	variable ${optId}::Options

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


proc setElement {table index id value} {
	variable ${table}::Vars

	if {$index >= $Vars(height)} { return }

	if {[string index $value 0] eq "@" && [lindex $value 0] eq "@"} {
		$table.t item element configure $index $id elemTxt$id -text ""
		$table.t item element configure $index $id elemIco -image [lindex $value 1]
	} else {
		$table.t item element configure $index $id elemIco -image {}
		$table.t item element configure $index $id elemTxt$id -text $value
	}
}


proc itemconfigure {table index args} {
	variable ${table}::Vars

	if {$index < $Vars(height)} {
		$table.t item configure $index {*}$args
	}
}


proc configureItem {table index id args} {
	$table.t item element configure $index $id elemTxt$id {*}$args
}


proc lookupColor {color} {
	variable ColorLookup

	if {[info exists ColorLookup($color)]} { return $ColorLookup($color) }
	return $color
}


proc configureCheckEntry {m} { return $m }


proc getFont {table} {
	variable IdMap

	set optId $IdMap($table)
	variable ${optId}::Options
	return [set ${optId}::Options(-font)]
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


proc bindOptions {id arrName nameList} {
	variable Bindings

	set Bindings($id) [list $arrName $nameList]

	if {[info exists ${id}::Options]} {
		variable ${id}::Options
		foreach attr $nameList {
			catch { set ${arrName}($attr) $Options($attr) }
		}
	}
}


proc countOptions {id} {
	return [array size ${id}::Options]
}


proc getOptions {id} {
	variable Bindings

	set options [array get ${id}::Options]
	if {[info exists Bindings($id)]} {
		array set arr $options
		lassign $Bindings($id) arrName nameList
		foreach attr $nameList { set arr($attr) [set ${arrName}($attr)] }
		set options [array get arr]
	}
	return $options
}


proc setOptions {id options} {
	variable WidgetMap
	variable Bindings

	if {![info exists WidgetMap($id)]} {
		namespace eval ${id} {}
		variable ${id}::Options
		array set Options $options
		if {[info exists Bindings($id)]} {
			lassign $Bindings($id) arrName nameList
			array set opts $options
			foreach attr $nameList {
				catch { set Options($attr) $opts($attr) }
			}
		}
	} else {
		variable ${id}::Options
		array set opts $options

		if {[info exists Bindings($id)]} {
			lassign $Bindings($id) arrName nameList
			foreach attr $nameList {
				catch { set ${arrName}($attr) $opts($attr) }
			}
		}

		set table $WidgetMap($id)

		if {![ArrayEqual Options $options]} {
			if {[winfo exists $table]} {
				foreach attr [array names opts -visible:*] {
					if {$Options($attr) != $opts($attr)} {
						set ev [expr {$Options($attr) ? "TableHide" : "TableShow"}]
						event generate $table <<$ev>> -data [lindex [split $attr :] 1]
					}
				}
			}
			array set Options $options
			if {[winfo exists $table]} {
				variable ${table}::Vars
				set active $Vars(active)
				set selection $Vars(selection)
				Reconfigure $table $id
				event generate $table <<TableFill>> -data [list 0 $Vars(height)]
				if {$active >= 0} {
					activate $table $active
					see $table $active
				}
				if {$selection >= 0} {
					select $table $selection
				}
			}
		}

		if {[winfo exists $table]} { event generate $table <<TableRebuild>> }
	}
}


proc setHeight {table height {cmd {}}} {
	variable ${table}::Vars

	set oldHeight $Vars(height)
	set Vars(height) $height
	set Vars(rows) [min $Vars(rows) $height]
	set selection $Vars(selection)

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

	if {$selection < $height} {
		select $table $selection
	}
}


proc setColumnMininumWidth {table id width} {
	variable ${table}::Vars
	variable IdMap

	set optId $IdMap($table)
	variable ${optId}::Options

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


proc hideColumn {table id} {
	variable ${table}::Vars
	variable IdMap

	set optId $IdMap($table)
	variable ${optId}::Options

	lappend ids $id {*}$Vars(associated:$id)
	foreach id $ids {
		set Options(-visible:$id) 0
		$table.t column configure $id -visible 0
		set i [lsearch -exact $Vars(visible) $id]
		if {$i >= 0} { set Vars(visible) [lreplace $Vars(visible) $i $i] }
	}
	foreach id $ids {
		event generate $table <<TableHide>> -data $id
	}
	after idle [namespace code [list UpdateColunnWidths $table]]
}


proc showColumn {table id} {
	variable ${table}::Vars
	variable IdMap

	set optId $IdMap($table)
	variable ${optId}::Options

	lappend ids $id {*}$Vars(associated:$id)
	foreach id $ids {
		set Options(-visible:$id) 1
		$table.t column configure $id -visible 1
	}
	set Vars(visible) {}
	foreach i $Vars(columns) {
		if {$Options(-visible:$i)} { lappend Vars(visible) $i }
	}
	foreach id $ids {
		event generate $table <<TableShow>> -data $id
	}
	event generate $table <<TableFill>> -data [list 0 $Vars(rows)]
	after idle [namespace code [list UpdateColunnWidths $table]]
}


proc doSelection {table} {
	variable ${table}::Vars

	lassign [winfo pointerxy $table] x y
	set x [expr {$x - [winfo rootx $table]}]
	set y [expr {$y - [winfo rooty $table]}]
	lassign [::table::identify $table $x $y] row
	activate $table $row true
}


proc keepFocus {table {flag {}}} {
	variable ${table}::Vars

	if {[llength $flag] == 0} { return $Vars(keep) }
	set Vars(keep) $flag
}


proc height {table} {
	return [set ${table}::Vars(height)]
}


proc computeHeight {table rows} {
	variable ${table}::Vars
	return [expr {[$table.t headerheight] + 2*[$table.t cget -borderwidth] + $rows*$Vars(linespace)}]
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
	variable IdMap

	set optId $IdMap($table)
	return [set ${optId}::Options(-borderwidth)]
}


proc selection {table} {
	return [set ${table}::Vars(selection)]
}


proc active {table} {
	return [set ${table}::Vars(active)]
}


proc focus {table} {
	if {[$table.t cget -takefocus] eq 1} {
		::focus $table.t
	}
}


proc see {table row} {
	$table.t see $row
}


proc bind {table sequence script} {
	::bind $table.t $sequence $script
}


proc configure {table args} {
	variable ${table}::Vars

	if {[llength $args] % 2 == 0} {
		$table.t configure {*}$args
	} else {
		set id [lindex $args 0]
		set args [lrange $args 1 end]

		foreach {attr value} $args {
			switch -- $attr {
				-labelfont	{ $table.t column configure $id -font $value }
				default		{ $table.t element configure elemTxt$id $attr $value }
			}
		}
	}
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
	return [list $row [lindex $info 3] [lindex $info 1] [lindex $info 2]]
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


proc refresh {table} {
	variable ${table}::Vars
	event generate $table <<TableFill>> -data [list 0 $Vars(height)]
}


proc clear {table {first -1} {last -1}} {
	variable ${table}::Vars

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
	set t $table.t

	for {set row $first} {$row < $last} {incr row} {
		set item [$t item id $row]
		if {[llength $item]} {
			foreach id $Vars(visible) {
				catch {
					$t item element configure $row $id elemIco -image {}
					$t item element configure $row $id elemTxt$id -text ""
				}
			}
		}
	}
}


proc clearColumn {table id} {
	variable ${table}::Vars
	variable IdMap

	set optId $IdMap($table)
	variable ${optId}::Options

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
	variable IdMap

	set optId $IdMap($table)
	variable ${optId}::Options
	return [set ${optId}::Options(-visible:$id)]
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

	if {$row == -1} { return }
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
	variable IdMap
	variable options

	set optId $IdMap($table)
	variable ${optId}::Options

	set padx $options(element:padding)
	if {$Options(-ellipsis:$id)} { set squeeze "x" } else { set squeeze "" }

	$table.t style layout $style elemTxt$id \
		-pady $Options(-pady) \
		-padx [list $padx $padx] \
		-squeeze $squeeze \
		-sticky w \
		-indent yes \
		;
	# we don't use detach if it does not have a tree column, otherwise the item is not centering
	$table.t style layout $style elemImg -union elemIco -iexpand nswe -indent no -detach $Vars(detach)
	$table.t style layout $style elemIco -height $Vars(linespace) -indent no -detach $Vars(detach)
}


proc ConfigureColumn {table id args} {
	variable ${table}::Vars
	variable IdMap

	set optId $IdMap($table)
	variable ${optId}::Options

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
		-background				{}
		-selectionforeground	{}
		-stripes					{}
	}
	set opts(-order) [llength $Vars(columns)]

	set keys [array names opts]
	foreach {key val} $args {
		if {$key in $keys} { set opts($key) $val }
	}
	if {[info exists Options(-visible:$id)]} {
		foreach key $keys {
			if {[info exists Options($key:$id)]} {
				set opts($key) $Options($key:$id)
			}
		}
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
	if {[llength $opts(-lastwidth)] == 0} { set opts(-lastwidth) 0 }
	if {$opts(-lastwidth) > 0} { set width $opts(-lastwidth) }
	set stripes $opts(-stripes)
	if {[llength $stripes] == 0} { set stripes $Options(-stripes) }
	if {[llength $stripes]} {
		set colors [list [lookupColor $stripes] [lookupColor $opts(-background)]]
	} else {
		set colors [lookupColor $opts(-background)]
	}
	set justify $opts(-justify)
#	if {[llength $labelImage]} { set justify center } else { set justify left }

	$table.t column configure $id   \
		-width $width                \
		-minwidth $minwidth          \
		-maxwidth $maxwidth          \
		-lock $opts(-lock)           \
		-justify $justify            \
		-itemjustify $opts(-justify) \
		-resize $resizable           \
		-squeeze $squeeze            \
		-visible $opts(-visible)     \
		-weight $weight              \
		-itembackground $colors      \
		;

	if {$opts(-visible)} {
		lappend Vars(visible) $id
		if {$minwidth > 0} {
			incr Vars(minwidth) $minwidth
		} elseif {[llength $width]} {
			incr Vars(minwidth) $width
		}
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
		set next [lindex $columns end]
		for {set i [expr {$n - 2}]} {$i >= 0} {incr i -1} {
			set prev [lindex $columns $i]
			# catch possible problem with locked columns
			if {$prev ne $next} { catch { $table.t column move $prev $next } }
			set next $prev
		}
	}

	foreach opt [array names opts] { set Options($opt:$id) $opts($opt) }
}


proc SbSet {sb first last} {
	variable Priv

	set parent [winfo parent $sb]
	set state ""

	if {$first <= 0 && $last >= 1.0} {
		if {$sb in [grid slaves $parent]} {
			grid remove $sb
			set state hide
		}
	} else {
		if {$sb ni [grid slaves $parent]} {
			grid $sb
			set state show
		}
	}

	$sb set $first $last

	if {[llength $state]} {
		event generate [winfo parent $sb] <<TableScrollbar>> -data $state
	}
}


proc Configure {table w h} {
	variable ${table}::Vars

	if {$w <= 1} { return }

	if {$Vars(init)} {
		set Vars(init) 0
		GenerateTableMinSizeEvent $table
	}

	set h [winfo height $table.t]
	set hdrHeight [$table.t headerheight]
	set tableHeight [expr {$h - $hdrHeight - 2*[$table.t cget -borderwidth]}]
	set height [expr {$tableHeight/$Vars(linespace)}]
	if {$height < 0} { set height 0 }
	set Vars(labelHeight) $hdrHeight
	setHeight $table $height
	after idle [namespace code [list UpdateColunnWidths $table]]
	event generate $table <<TableConfigured>>
}


proc ConfigureOnce {table w h} {
	variable ${table}::Vars

	if {$w <= 1} { return }

	if {$Vars(init)} {
		set Vars(init) 0
		GenerateTableMinSizeEvent $table
	}

	set Vars(labelHeight) [$table.t headerheight]
	::bind $table.t <Configure> {}
}


proc UpdateColunnWidth {table column width} {
	variable ${table}::Vars
	variable IdMap

	set optId $IdMap($table)
	variable ${optId}::Options

	set column [lindex $Vars(columns) $column]
	set Options(-lastwidth:$column) $width
	event generate $table <<TableOptions>>
}


proc UpdateColunnWidths {table} {
	if {![winfo exists $table]} { return }

	variable ${table}::Vars
	variable IdMap

	set optId $IdMap($table)
	variable ${optId}::Options

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
	if {![winfo exists $table]} { return }
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


proc MakeStyles {table id foreground disabledForeground isCheckButton} {
	variable ${table}::Vars
	variable IdMap
	variable options

	set optId $IdMap($table)
	variable ${optId}::Options

	if {$isCheckButton} {
		$table.t element create elemTxt$id text -lines 1 -font $Options(-font)
		SetForeground $table $id

		$table.t style create style$id
		$table.t style elements style$id [list elemSel elemImg elemBrd elemChk elemIco elemTxt$id]
		setDefaultLayout $table $id style$id
		$table.t style layout style$id elemSel -iexpand nswe -detach yes -indent no
		$table.t style layout style$id elemBrd -iexpand xy -detach yes -indent no
		$table.t style layout style$id elemChk -expand nws -padx {4 0} -indent yes
	} else {
		$table.t element create elemTxt$id text -lines 1 -font $Options(-font)
		SetForeground $table $id

		$table.t style create style$id
		$table.t style elements style$id [list elemSel elemImg elemBrd elemIco elemTxt$id]
		setDefaultLayout $table $id style$id
		$table.t style layout style$id elemSel -iexpand nswe -detach yes -indent no
		$table.t style layout style$id elemBrd -iexpand xy -detach yes -indent no
	}
}


proc ShowColumn {table id} {
	variable IdMap

	set optId $IdMap($table)
	variable ${optId}::Options

	if {$Options(-visible:$id)} {
		showColumn $table $id
	} else {
		hideColumn $table $id
	}
}


proc MoveColumn {table column before} {
	variable ${table}::Vars
	variable IdMap

	set optId $IdMap($table)
	variable ${optId}::Options

	$table.t column move $column $before
	foreach id $Vars(columns) {
		set Options(-order:$id) [$table.t column order $id]
	}
	event generate $table <<TableOptions>>
}


proc Activate {table row force send} {
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
		if {$row < $Vars(height) && ([::focus] eq "$table.t")} {
			$table.t activate $row
			event generate $table <<TableActivated>> -data $row
		}
	}
}


proc FocusOut {table} {
	variable ${table}::Vars

	if {!$Vars(keep)} { Deactivate $table }
}


proc Highlight {table x y} {
	variable ${table}::Vars

	focus $table
	::tooltip::hide
	set Vars(header) 0
	set id [$table.t identify $x $y]
	if {$id eq ""} { return }

	switch [lindex $id 0] {
		item {
			switch [lindex $id 2] {
				column {
					set row [$table.t item order [lindex $id 1] -visible]
					set elem [lindex $id 5]
					if {$elem eq "elemChk"} {
						set states [$table.t item state get $row]
						if {"nocheck" in $states} {
							$table.t item state set $row {check !nocheck}
							event generate $table <<TableCheckbutton>> -data [list $row 1]
						} elseif {"check" in $states} {
							$table.t item state set $row {!check nocheck}
							event generate $table <<TableCheckbutton>> -data [list $row 0]
						}
					}
					if {$row < $Vars(rows)} { Activate $table $row false true }
				}
				
				button {
					set row [$table.t item order [lindex $id 1] -visible]
					event generate $table <<TableToggleButton>> -data $row
				}

				default {
					if {[$table.t item cget [lindex $id 1] -forcedepth] >= 0} {
						set row [$table.t item order [lindex $id 1] -visible]
						if {$row < $Vars(rows)} { Activate $table $row false true }
					}
				}
			}
		}

		header {
			::TreeCtrl::ButtonPress1Header $table.t $id $x $y 0
			if {[$table.t header dragcget -enable]} {
				if {[$table.t column cget [lindex $id 1] -lock] eq "none"} {
					ttk::setCursor $table.t link
				}
			}
			set Vars(header) 1
		}
	}
}


proc Release {table x y} {
	variable ${table}::Vars

	if {$Vars(header)} {
		::TreeCtrl::Release1 $table.t $x $y
		if {[$table.t header dragcget -enable]} {
			ttk::setCursor $table.t {}
		}
	}
}


proc SetSelection {table args} {
	variable ${table}::Vars

	set active $Vars(active)
	if {$active == -1} { return }

	set shiftIsHeldDown 0

	if {[llength $args] == 3} {
		lassign $args x y state
		set id [$table.t identify $x $y]
		if {[llength $id] == 0} { return }
		if {[lindex $id 0] eq "header"} { return }
		set row [$table.t item order [lindex $id 1] -visible]
		if {$row >= $Vars(rows)} { return }
		if {$state & 1} { set shiftIsHeldDown 1 }
	} elseif {[lindex $args 0] & 1} {
		if {$active < 0} { return }
		set shiftIsHeldDown 1
	}

	select $table $active
	event generate $table <<TableSelected>> -data $active
	event generate $table <<TableInvoked>> -data $shiftIsHeldDown
}


proc ScrollHorz {table units state} {
	variable shiftMask

	if {[expr {($state & $shiftMask) != 0}]} {
		$table.t xview scroll $units units
	}
}


proc ScrollVert {table action} {
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


proc Tooltip {table mode {id {}}} {
	variable ${table}::Vars

	if {[llength $id]} {
		set id [$table.t column tag names $id]
		if {[string length $id] && $Vars(ellipsis:$id) && ![$table.t column ellipsis $id]} { return }
		set focus [::focus]
		if {![llength $focus] || [winfo toplevel $table] ne [winfo toplevel $focus]} {
			set mode hide
		}
	}

	switch $mode {
		show {
			if {[llength $Vars(tooltipvar:$id)]} {
				::tooltip::showvar $table.t $Vars(tooltipvar:$id)
			} elseif {[string length $Vars(tooltip:$id)]} {
				::tooltip::show $table.t $Vars(tooltip:$id)
			}
		}

		hide {
			::tooltip::hide true
		}
	}
}


proc VisitHeader {table mode item column} {
	variable ${table}::Vars

	if {$mode eq "enter"} {
		Tooltip $table show $item
	} else {
		Tooltip $table hide
	}

	VisitItem $table $mode $column "" -1
}


proc VisitItem {table mode column item member} {
	variable ${table}::Vars

	if {[string length $column] == 0} { return }
	if {[catch { set row [$table.t item tag names $item] }]} { return }
	if {$row >= $Vars(rows)} { return }
	set id [$table.t column tag names $column]
	event generate $table <<TableVisit>> -data [list $mode $id $row $column $item $member]
}


proc ToggleStretchable {table id} {
	variable ${table}::Vars
	variable IdMap

	set optId $IdMap($table)
	variable ${optId}::Options

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
	variable IdMap

	after idle [list catch [list namespace delete [namespace current]::$table]]
	after idle [list catch [list namespace delete [namespace current]::$IdMap($table)]]
}


proc GetStripes {table id} {
	variable IdMap

	set optId $IdMap($table)
	variable ${optId}::Options

	if {[llength $Options(-stripes)] == 0} { return {} }
	if {[llength $Options(-stripes:$id)] == 0} { return $Options(-stripes) }
	return $Options(-stripes:$id)
}


proc PopupMenu {table x y X Y} {
	variable ${table}::Vars
	variable ColorLookup
	variable IdMap
	variable Visible_
	variable options

	set optId $IdMap($table)
	variable ${optId}::Options

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
	::tooltip::hide

	array unset Visible_
	set tail 0
	set optimize 0
	set ignore {}
	set groups {}
	foreach i [$table.t column list] {
		set cid [$table.t column tag names $i]
		if {$Options(-optimizable:$cid)} {
			set optimize 1
		}
		if {$cid eq "tail"} {
			set tail 1
		} elseif {$Options(-removable:$cid)} {
			if {[string length [set g $Vars(groupvar:$cid)]] > 0} {
				set t 1
				if {[llength $g] == 0} {
					set g $Vars(group:$cid)
					set t 0
				}
				set entry [list $t $g]
				if {$entry ni $groups} { lappend groups $entry }
				lappend groupmember($g) $cid
				lappend ignore {*}$Vars(associated:$cid)
			} else {
				lappend groupmember() $cid
				set entry [list 1 ""]
				if {$entry ni $groups} { lappend groups $entry }
			}
		}
	}
	set k [lsearch -exact -index 1 $groups ""]
	if {$k >= 0} {
		set e [lindex $groups $k]
		set groups [lreplace $groups $k $k]
		lappend groups $e
	}

	$menu add command                                                  \
		-background [lookupColor $options(menu:headerbackground)]       \
		-foreground [lookupColor $options(menu:headerforeground)]       \
		-activebackground [lookupColor $options(menu:headerbackground)] \
		-activeforeground [lookupColor $options(menu:headerforeground)] \
		-font $options(menu:headerfont)                                 \
		-state disabled                                                 \
		;
	$menu add separator

	if {$id ne "tail"} {
		set count 0
		foreach item $Vars(menu:$id) {
			set type [lindex $item 0]
			array set opts [lrange $item 1 end]
			if {[info exists opts(-labelvar)]} {
				set opts(-label) [set $opts(-labelvar)]
				array unset opts -labelvar
			}
			if {![info exists opts(-state)] || [eval $opts(-state)] eq "normal"} {
				if {$type ne "separator" || ($count > 0 && [$menu type end] ne "separator")} {
					incr count
					array unset opts -state
					$menu add $type {*}[array get opts]
					switch $type {
						radiobutton { ::theme::configureRadioEntry $menu }
						checkbutton { ::theme::configureCheckEntry $menu }
					}
				}
			}
			unset opts
		}

		if {$count && [$menu type end] ne "separator"} { $menu add separator }
	}

	set needsSeparator 0

	if {$tail || [llength $groups]} {
		set subm [menu $menu.mShowColumn -tearoff false]
		::bind $subm <Destroy> [list ::tooltip::tooltip clear $subm*]
		$menu add cascade -menu $subm -label $mc::ShowColumn
		set needsSeparator 1

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
			foreach cid $groupmember($name) {
				if {$cid ni $ignore} {
					if {[llength $Vars(nameingroup:$cid)]} {
						set text [set $Vars(nameingroup:$cid)]
					} elseif {[llength $Vars(tooltipvar:$cid)]} {
						set text [set $Vars(tooltipvar:$cid)]
					} elseif {[llength $Vars(tooltip:$cid)]} {
						set text $Vars(tooltip:$cid)
					} else {
						set text [$table.t column cget $cid -text]
					}
					if {[string length $name]} { set m $subm.$index } else { set m $subm }
					$m add checkbutton \
						-label $text \
						-command [namespace code [list ShowColumn $table $cid]] \
						-variable [namespace current]::${optId}::Options(-visible:$cid) \
						;
					configureCheckEntry $m
				}
			}
			if {[string length $name]} { incr index }
		}
		if {$tail} {
			$subm add checkbutton \
				-label $mc::FillColumn \
				-command [namespace code [list ShowColumn $table $id]] \
				-variable [namespace current]::${optId}::Options(-visible:$id) \
				;
		}
	}

	if {$id ne "tail"} {
		if {$Options(-removable:$id)} {
			set needsSeparator 1
			$menu add command \
				-label $mc::Hide \
				-command [namespace code [list hideColumn $table $id]] \
				;
		}
		if {$Options(-configurable)} {
			set needsSeparator 1
			$menu add command \
				-label "$mc::Configure..." \
				-command [namespace code [list OpenConfigureDialog $table $id $header]] \
				;
		}
	}

	if {$needsSeparator} { $menu add separator }

	if {$id ne "tail"} {
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
				-label $mc::ShrinkColumn \
				-command [list $table.t column shrink $id] \
				;
			$menu add command \
				-label $mc::ExpandColumn \
				-command [list $table.t column expand $id yes] \
				;
		}

		if {	!$Options(-pixels:$id)
			&& (	($Options(-maxwidth:$id) == 0 && $Options(-minwidth:$id) > 0)
				|| $Options(-maxwidth:$id) > $Options(-minwidth:$id))} {
			if {[$menu type end] ne "separator"} { $menu add separator }
			$menu add checkbutton \
				-label $mc::AutoStretchColumn \
				-variable [namespace current]::${optId}::Options(-stretch:$id) \
				-command [namespace code [list ToggleStretchable $table $id]] \
				;
			configureCheckEntry $menu
		}
	}

	$menu entryconfigure 0 -label $header

	if {$optimize} {
		if {[$menu type end] ne "separator"} { $menu add separator }
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
	}

	if {[$menu type end] eq "separator"} { $menu delete end }
	if {[llength $Vars(menucmd)]} { {*}$Vars(menucmd) $menu }

	::bind $menu <<MenuUnpost>> [list event generate $table <<TablePopdown>>]
	tk_popup $menu $X $Y

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
	variable IdMap

	set optId $IdMap($table)
	variable ${optId}::Options

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
	variable IdMap

	set optId $IdMap($table)
	variable ${optId}::Options

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
	::util::place $top -parent $table -position center
	wm deiconify $top
	::focus $tbl.bforeground
	ttk::grabWindow $top
	tkwait window $top
	ttk::releaseGrab $top
	keepFocus $table false
}


proc ConfigureDialog {table id dlg} {
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
	$canv configure -background [lookupColor $background]
	$canv create text 75 10 -text $text -fill [lookupColor $foreground] -tag abcd -font TkDefaultFont
	if {$preview eq "foreground"} {
		::bind $canv <<ChooseColorSelected>> "$canv itemconfigure abcd -fill %d"
	} else {
		::bind $canv <<ChooseColorSelected>> "$canv configure -background %d"
	}
	pack $canv -fill x -expand yes
	return $canv
}


proc ChooseColor {parent title what initialColor previewColor background usedColors eraser} {
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
			set backgroundcolor [::dialog::choosecolor::getActualColor [lookupColor $background]]
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
			set embedcmd [namespace code [list MakePreview $initialColor $previewColor foreground]]
		}

		background {
			if {![string match table* $what]} {
				set embedcmd [namespace code [list MakePreview $previewColor $initialColor background]]
			}
		}
	}

	set selection [::colormenu::popup $parent              \
							-class Dialog                        \
							-basecolors $baseColors              \
							-initialcolor $initialColor          \
							-recentcolors [namespace current]::RecentColors($recent) \
							-usedcolors $usedColors              \
							-eraser $eraser                      \
							-geometry last                       \
							-modal true                          \
							-place centeronparent                \
							-embedcmd $embedcmd                  \
							]
	
	if {[llength $selection]} {
		set initialColor [::dialog::choosecolor::getActualColor $initialColor]
		set RecentColors($recent) \
			[::dialog::choosecolor::addToList $RecentColors($recent) $initialColor]
	}

	return $selection
}


proc SelectTableColor {table id parent title which} {
	variable ${table}::Vars
	variable IdMap

	set optId $IdMap($table)
	variable ${optId}::Options

	switch $which {
		foreground - disabledforeground {
			set previewColor $Options(-background)
			set attrs {foreground disabledforeground selectionforeground}
		}

		selectionforeground {
			set previewColor $Options(-selectionbackground)
			set attrs {foreground disabledforeground selectionforeground}
		}

		background - highlightcolor {
			if {[llength $previewColor] == 0} {
				set previewColor $Options(-foreground)
			} else {
				set previewColor $Options(-foreground:$id)
			}
			set attrs background
		}

		selectionbackground {
			if {[llength $previewColor] == 0} {
				set previewColor $Options(-selectionforeground)
			} else {
				set previewColor $Options(-selectionforeground:$id)
			}
			set attrs background
		}
	}

	set usedColors {}
	foreach i $Vars(columns) {
		foreach attr $attrs {
			set color [::dialog::choosecolor::getActualColor [lookupColor $Options(-$attr:$i)]]
			if {[llength $color] && $color ni $usedColors} {
				lappend usedColors $color
			}
		}
	}

	set initialColor [lookupColor $Options(-$which)]
	set previewColor [lookupColor $previewColor]

	set parent $parent.b$which
	set color [ChooseColor \
		$parent             \
		[set mc::$title]    \
		table-$which        \
		$initialColor       \
		$previewColor       \
		{}                  \
		$usedColors         \
		false               \
	]
	if {![winfo exists $parent]} { return } ;# may happen if parent is closed

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
				set colors [list [lookupColor $color] selected]
				if {[llength $Options(-highlightcolor)]} {
					lappend colors [lookupColor $Options(-highlightcolor)] active
				}
				$table.t element configure elemSel -fill $colors
				$table.t element configure elemImg -fill $colors
			}

			highlightcolor {
				set colors [list \
					[lookupColor $Options(-selectionbackground)] selected \
					[lookupColor $Options(-highlightcolor)] active \
				]
				$table.t element configure elemSel -fill $colors
				$table.t element configure elemImg -fill $colors
			}
		}
	}
}


proc SelectColor {table id parent title which} {
	variable ${table}::Vars
	variable IdMap

	set optId $IdMap($table)
	variable ${optId}::Options

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

	set initialColor [lookupColor $initialColor]
	set previewColor [lookupColor $previewColor]

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
	if {![winfo exists $parent]} { return } ;# may happen if parent is closed
	if {[llength $color] == 0} { return }
	if {$color eq "erase"} { set color {} }
	set Options(-$which:$id) $color

	switch $which {
		foreground - disabledforeground - selectionforeground { SetForeground $table $id }
		background { SetBackground $table }
	}
}


proc SelectTableStripes {table id parent} {
	variable ${table}::Vars
	variable IdMap

	set optId $IdMap($table)
	variable ${optId}::Options

	if {[llength $Options(-stripes)]} { set eraser true } else { set eraser false }

	set color [ChooseColor                 \
		$parent                             \
		$mc::Stripes                        \
		table-stripes                       \
		[lookupColor $Options(-stripes)]    \
		[lookupColor $Options(-foreground)] \
		[lookupColor $Options(-background)] \
		{}                                  \
		$eraser                             \
	]
	if {![winfo exists $parent]} { return } ;# may happen if parent is closed

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
	variable ${table}::Vars
	variable IdMap

	set optId $IdMap($table)
	variable ${optId}::Options

	set foreground $Options(-foreground:$id)
	if {[llength $foreground] == 0} { set foreground $Options(-foreground) }
	set background $Options(-background:$id)
	if {[llength $background] == 0} { set background $Options(-background) }
	if {[llength $Options(-stripes:$id)]} { set eraser true } else { set eraser false }

	set color [ChooseColor                   \
		$parent                               \
		$mc::Stripes                          \
		stripes                               \
		[lookupColor [GetStripes $table $id]] \
		[lookupColor $foreground]             \
		[lookupColor $background]             \
		{}                                    \
		$eraser                               \
	]
	if {![winfo exists $parent]} { return } ;# may happen if parent is closed

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
	variable ${table}::Vars
	variable IdMap

	set optId $IdMap($table)
	variable ${optId}::Options

	foreach attr {	minwidth maxwidth foreground background
						selectionforeground disabledforeground stripes} {
		set Options(-$attr:$id) $Vars($attr:$id:menu)
	}
	foreach attr {foreground background selectionbackground disabledforeground stripes highlightcolor} {
		set Options(-$attr) $Vars($attr:menu)
	}

	set colors [list [lookupColor $Options(-selectionbackground)] selected]
	if {[llength $Options(-highlightcolor)]} {
		lappend colors [lookupColor $Options(-highlightcolor)] active
	}
	$table.t element configure elemSel -fill $colors
	$table.t element configure elemImg -fill $colors

	SetBackground $table
	foreach id $Vars(columns) { SetForeground $table $id }
}


proc SetForeground {table id} {
	variable IdMap

	set optId $IdMap($table)
	variable ${optId}::Options

	foreach color {foreground selectionforeground disabledforeground} {
		if {![info exists Options(-$color:$id)] || [llength $Options(-$color:$id)] == 0} {
			set Options(-$color:$id) $Options(-$color)
		}
	}

	set colors [list \
		[lookupColor $Options(-disabledforeground:$id)] deleted \
		[lookupColor $Options(-selectionforeground:$id)] selected \
		[lookupColor $Options(-foreground:$id)] {} \
	]
	$table.t element configure elemTxt$id -fill $colors
}


proc SetBackground {table} {
	variable IdMap

	set optId $IdMap($table)
	variable ${optId}::Options

	foreach id [$table.t column list -visible] {
		set id [$table.t column tag names $id]
		set stripes [GetStripes $table $id]
		set background $Options(-background:$id)
		if {[llength $background] == 0} { set background $Options(-background) }
		setColumnBackground $table $id [lookupColor $stripes] [lookupColor $background]
	}

	setColumnBackground $table $id [lookupColor $Options(-stripes)] [lookupColor $Options(-background)]
}


proc EraseStripes {table id parent} {
	variable RecentColors
	variable IdMap

	set optId $IdMap($table)
	variable ${optId}::Options

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


proc Reconfigure {table id} {
	variable ${table}::Vars

	set Vars(order) [lrepeat [llength $Vars(columns)] {}]
	set Vars(visible) {}
	set Vars(minwidth) 0
	set Vars(maxwidth) 0

	select $table none
	activate $table none

	foreach col $Vars(columns) {
		ConfigureColumn $table $col {}
	}
}


proc AcceptSettings {table id} {
	variable ${table}::Vars
	variable IdMap

	set optId $IdMap($table)
	variable ${optId}::Options

	foreach which {minwidth maxwidth} { set Options(-$which:$id) $Vars($which:$id:menu) }
	event generate $table <<TableOptions>>
}


proc ArrayEqual {lhs rhs} {
	upvar 1 $lhs foo
	array set bar $rhs

	if {[array size foo] != [array size bar]} { return 0 }
	if {[array size foo] == 0} { return 1 }
	set keys [lsort -unique [concat [array names foo] [array names bar]]]
	if {[llength $keys] != [array size foo]} { return 0 }
	foreach key $keys { if {$foo($key) ne $bar($key)} { return 0 } }
	return 1
}

namespace eval icon {
namespace eval 13x13 {

set none [image create photo -width 13 -height 13]

set checked [image create photo -data {
	R0lGODlhDQANABEAACwAAAAADQANAIEAAAB/f3/f39////8CJ4yPNgHtLxYYtNbIbJ146jZ0
	gzeCIuhQ53NJVNpmryZqsYDnemT3BQA7
}]

set unchecked [image create photo -data {
	R0lGODlhDQANABEAACwAAAAADQANAIEAAAB/f3/f39////8CIYyPNgHtLxYYtNbIrMZTX+l9
	WThwZAmSppqGmADHcnRaBQA7
}]

} ;# namespace 13x13
} ;# namespace icon
} ;# namespace table

# vi:set ts=3 sw=3:
