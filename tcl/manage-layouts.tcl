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
# Copyright: (C) 2017-2018 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source manage-layouts

namespace eval application {
namespace eval layout {
namespace eval mc {

set Rename				"Rename"
set Delete				"Delete"
set Replace				"Replace"
set Load					"Load"
set Linked				"Linked with"
set CannotOpenFile	"Cannot read file '%s'."
set RestoreOldLayout	"Restore to old layout"
set ReplaceTip			"Overwrite current layout with this one"

}

array set Options {
	borderwidth	5
	padding		7
	width			30
}

variable layoutVariants $::layoutVariants


proc open {twm id layoutVariant layoutName} {
	variable layoutVariants
	variable Options
	variable {}

	set (variant:sel) $layoutVariant
	set (variant:ori) $layoutVariant
	set (variant:rpl) $layoutVariant
	set (layout:list:ori) [[namespace parent]::twm::inspectLayout $twm]
	set (layout:list:sav) [[namespace parent]::twm::savedLayout $twm]
	set (layout:index) -1
	set (name:cur) $layoutName
	set (name:ori) [[namespace parent]::twm::currentLayoutName $twm]
	set (name:rpl) $layoutName
	set force $::twm::Options(deiconify:force)
	set ::twm::Options(deiconify:force) 1
	set (twm) $twm
	set (id) $id

	set dlg $twm.layout
	tk::toplevel $dlg -class Scidb
	wm withdraw $dlg

	pack [set top [ttk::frame $dlg.top]] -expand yes -fill both
	set lt [ttk::frame $top.lt -borderwidth 0]
	set rt [ttk::frame $top.rt -borderwidth 0]
	set layout [tk::frame $rt.layout -background [::colors::lookup layout,background]]
	set myTWM [twm::twm $layout.manage \
		-makepane [namespace current]::MakePane \
		-buildpane [namespace current]::BuildPane \
		-resizing [namespace current]::Resizing \
		-borderwidth $Options(borderwidth) \
		-state readonly \
		-disableclose yes \
	]
	pack $myTWM -padx $Options(padding) -pady $Options(padding)
	bind $myTWM <<TwmHeader>> [namespace code [list HeaderChanged $myTWM %d]]
	[namespace parent]::twm::loadInitialLayout $myTWM $twm

	set (list:variants) $lt.variants
	set (list:names) $lt.names

	ttk::tcombobox $(list:variants) \
		-state readonly \
		-showcolumns {variant} \
		-exportselection no \
		-placeicon yes \
		;
	$(list:variants) addcol image -id icon -justify center -width 20
	$(list:variants) addcol text  -id variant

	grid $(list:variants) -row 1 -column 1 -sticky nswe
	grid rowconfigure $lt {2} -minsize $::theme::pady

	set (variants:values) {}
	foreach v $layoutVariants {
		if {$v eq $layoutVariant || [llength [[namespace parent]::twm::glob $id $v]] > 0} {
			set variant [[namespace parent]::twm::toVariant $v]
			set name $::mc::VariantName($variant)
			$(list:variants) listinsert [list $::icon::16x16::variant($variant) $name]
			lappend (variants:values) [list $v $name]
		}
	}
	$(list:variants) resize -force
	set variant [[namespace parent]::twm::toVariant $layoutVariant]
	$(list:variants) set $::mc::VariantName($variant)
	bind $(list:variants) <<ComboboxCurrent>> [namespace code SelectVariant]

	set (load:cmd) [namespace code [list LoadLayout $myTWM]]
	tk::listbox $(list:names) \
		-width $Options(width) \
		-height 0 \
		-listvariable [namespace current]::(var:names) \
		;
	UpdateLayoutList [[namespace parent]::twm::glob $id $layoutVariant]
	SelectLayout

	set (button:ren) $lt.ren
	set (button:del) $lt.del
	set (button:res) $lt.res
	set (button:rpl) $lt.rpl
	set (button:rev) $dlg.revert

	ttk::button $(button:ren) \
		-style aligned.TButton \
		-text "$mc::Rename..." \
		-image $::icon::16x16::exchange \
		-compound left \
		-command [namespace code [list Rename [winfo toplevel $myTWM]]] \
		;
	ttk::button $(button:del) \
		-style aligned.TButton \
		-text "$mc::Delete..." \
		-image $::icon::16x16::delete \
		-compound left \
		-command [namespace code [list Delete [winfo toplevel $myTWM]]] \
		;
	ttk::button $(button:res) \
		-style aligned.TButton \
		-text $mc::Load \
		-image $::icon::16x16::refresh \
		-compound left \
		-command [namespace code Load] \
		;
	ttk::button $(button:rpl) \
		-style aligned.TButton \
		-text $mc::Replace \
		-image $::icon::16x16::copy \
		-compound left \
		-command [namespace code Replace] \
		;
	::tooltip $(button:rpl) [namespace current]::mc::ReplaceTip

	if {[llength $(var:names)] == 0} {
		foreach type {ren del res rpl} {
			$(button:$type) configure -state disabled
		}
	}
	if {$layoutVariant ne "normal"} {
		$(button:del) configure -state disabled
	}

	if {$id ne "board"} {
		set names [[namespace parent]::twm::glob board]
		if {[llength $names]} {
			after idle [namespace code RetrieveLink]
			set names [linsert $names 0 "\u2014"]
			set linkframe [ttk::frame $lt.link -borderwidth 0]
			ttk::label $linkframe.lbl -text "${mc::Linked}:"
			set (list:links) $linkframe.cb
			ttk::combobox $(list:links) \
				-values $names \
				-textvariable [namespace current]::(var:link) \
				-state readonly \
				;
			::tooltip $linkframe.lbl [namespace parent]::twm::mc::LinkLayoutTip
			grid $linkframe.lbl -row 0 -column 0
			grid $linkframe.cb  -row 0 -column 2 -sticky ew
			grid columnconfigure $linkframe {1} -minsize $::theme::padx
			grid columnconfigure $linkframe {2} -weight 1
			bind $linkframe.cb <<ComboboxSelected>> [namespace code SetLink]
		}
	}

	bind $(list:names) <<ListboxSelect>> $(load:cmd)

	lassign [[namespace parent]::twm::workArea $twm] (width) (height)
	if {$id ne "board"} {
		set mainTWM [[namespace parent]::twm::getTWM games]
		lassign [$mainTWM dimension] width height
		set h [expr {int(double($height)*(double($(width))/double($width)))}]
		if {$h > $(height)} {
			set (width) [expr {double($(width))*(double($(height))/$h)}]
		} else {
			set (height) $h
		}
	}
	set (width) [expr {int(($(width)*4.0)/9.0 + 0.5)}]
	set (height) [expr {int(($(height)*4.0)/9.0 + 0.5)}]

	grid $lt -row 1 -column 1 -sticky nsew
	grid $rt -row 1 -column 3 -sticky nsew
	grid columnconfigure $top {0 2 4} -minsize $::theme::padX
	grid rowconfigure $top {0 2} -minsize $::theme::padY

	grid $(list:names) -row 3  -column 1 -sticky nswe
	grid $(button:ren) -row 5  -column 1 -sticky we
	grid $(button:del) -row 7  -column 1 -sticky we
	grid $(button:res) -row 9  -column 1 -sticky we
	grid $(button:rpl) -row 11 -column 1 -sticky we
	grid rowconfigure $lt {4 6 8 10} -minsize 2
	grid rowconfigure $lt {3} -weight 1

	if {[info exists linkframe]} {
		grid $linkframe -row 13 -column 1 -sticky wes
		grid rowconfigure $lt {12} -minsize $::theme::pady
	}

	set padding [expr {2*($Options(borderwidth) + $Options(padding))}]
	grid $layout -row 1 -column 1 -sticky nsew
	grid columnconfigure $rt {1} -minsize [expr {$(width) + $padding}]
	grid rowconfigure $rt {1} -minsize [expr {$(height) + $padding}]

	set title [set [namespace parent]::twm::mc::ManageLayouts]
	if {$layoutVariant ne "normal"} {
		append title " \[$::mc::VariantName([[namespace parent]::twm::toVariant $layoutVariant])\]"
	}

	::widget::dialogButtons $dlg {close revert}
	$dlg.close configure -command [list destroy $dlg]
	$dlg.revert configure -state disabled -command [namespace code Revert]
	::tooltip $dlg.revert [namespace current]::mc::RestoreOldLayout
	wm resizable $dlg no no
	wm transient $dlg .application
	wm protocol $dlg WM_DELETE_WINDOW [list destroy $dlg]
	wm title $dlg $title
	::util::place $dlg -parent $twm -position center
	wm deiconify $dlg
	focus $(list:names)
	::ttk::grabWindow $dlg
	tkwait window $dlg
	::ttk::releaseGrab $dlg
	set ::twm::Options(deiconify:force) $force
}


proc RetrieveLink {} {
	variable {}

	if {$(id) eq "board"} { return }
	set link [[namespace parent]::twm::getLink $(id) [GetActiveLayout]]
	if {[string length $link] == 0} { set link "\u2014" }
	set (var:link) $link
}


proc SetLink {} {
	variable {}

	set name [GetActiveLayout]
	if {[string length $name] == 0} { return }
	if {[$(list:links) current] == 0} { set link "" } else { set link $(var:link) }
	[namespace parent]::twm::setLink $(id) $name $link
}


proc NameFromUid {uid}		{ return [lindex [split $uid :] 0] }
proc NumberFromUid {uid}	{ return [lindex [split $uid :] 1] }


proc TitleFromUid {uid} {
	set name [NameFromUid $uid]
	set title [set [namespace parent]::twm::mc::Pane($name)]
	if {$name eq "analysis" && [set number [NumberFromUid $uid]] > 1} {
		append title " ($number)"
	}
	return $title
}


proc MakePane {myTWM parent type uid} {
	variable {}

	set name [TitleFromUid $uid]
	set frame [tk::frame $parent.$uid -borderwidth 0 -takefocus 0]
	set result [list $frame $name [[namespace parent]::twm::priority $(twm) $uid] no]
	if {$type ne "pane"} {
		set closable [expr {$uid ne "editor" && $uid ne [[namespace parent]::twm::getId $(twm)]}]
		lappend result $closable yes yes
	}
	return $result
}


proc BuildPane {myTWM frame uid width height} {
	variable {}

	switch [NameFromUid $uid] {
		analysis	{ $frame configure -background [::colors::lookup analysis,layout:background] }
		editor	{ $frame configure -background [::colors::lookup pgn,background] }
		games		{ $frame configure -background [::colors::lookup scrolledtable,stripes] }
		tree		{ $frame configure -background [::colors::lookup tree,emphasize] }
		eco		{ $frame configure -background [::colors::lookup eco,stripes] }

		board {
			variable ::board::colors

			pack [set w [tk::canvas $frame.c -borderwidth 0 -takefocus 0]] -fill both -expand yes
			if {[llength $colors(hint,background-color)]} {
				$w configure -background $colors(hint,background-color)
			} else {
				::theme::configureBackground $w
			}
			bind $w <Configure> [list ::board::setBackground $w window %w %h]
			bind $w <Configure> +[namespace code [list MakeBoard $w %w %h]]
			$w xview moveto 0
			$w yview moveto 0
			MakeBoard $w $width $height
		}

		default {
			$frame configure -background [::colors::lookup tree,stripes]
		}
	}

	if {[$myTWM ispane [$myTWM leaf $uid]]} {
		::tooltip $frame [namespace parent]::twm::mc::Pane([NameFromUid $uid])
	}
}


proc HeaderChanged {myTWM frame} {
	if {[$myTWM flat? $frame]} {
		::tooltip $frame [namespace parent]::twm::mc::Pane([NameFromUid [$myTWM id $frame]])
	}
}


proc MakeBoard {w width height} {
	variable {}

	set cols [expr {$(variant:sel) eq "dropchess" ? 10 : 8}]
	set size [expr {max(1, (min(($width - 20)/$cols,($height - 20)/8)))}]
	set offs [expr {$(variant:sel) eq "dropchess" ? $size - 1 : -1}]
	set x [expr {($width - ($size*$cols + 2))/2 + $offs}]
	set y [expr {($height - ($size*8 + 2))/2 - 1}]
	if {[winfo exists $w.diagram]} {
		board::diagram::resize $w.diagram $size
		$w coords board $x $y
	} else {
		board::diagram::new $w.diagram $size -empty yes -bordersize 2 -bordertype lines
		$w create window $x $y -anchor nw -window $w.diagram -tags board
	}
	if {$(variant:sel) eq "dropchess"} {
		set xw [expr {$x - $size - 5}]
		set yw [expr {$y + 1}]
		set xb [expr {$x + $size*8 + 7}]
		set yb [expr {$y + $size*3 - 3}]
		if {![winfo exists $w.holding-w]} {
			::board::holding::new $w.holding-w w $size
			::board::holding::new $w.holding-b b $size
			$w create window $xw $yw -anchor nw -window $w.holding-w -tags holding-w
			$w create window $xb $yb -anchor nw -window $w.holding-b -tags holding-b
		} else {
			::board::holding::resize $w.holding-w $size
			::board::holding::resize $w.holding-b $size
			$w itemconfigure holding-w -state normal
			$w itemconfigure holding-b -state normal
			$w coords holding-w $xw $yw
			$w coords holding-b $xb $yb
		}
	} elseif {[winfo exists $w.holding-w]} {
		$w itemconfigure holding-w -state hidden
		$w itemconfigure holding-b -state hidden
	}
}


proc Resizing {myTWM toplevel width height} {
	variable Options
	variable {}

	if {$(id) eq "board"} {
		lassign [winfo workarea .application] _ _ ww wh
		lassign [winfo extents .application] ew1 ew2 eh1 eh2
		set adjustedWidth [expr {min($width, $ww - $ew1 - $ew2)}]
		set adjustedHeight [expr {min($height, $wh - $eh1 - $eh2)}]
		set fh [expr {double($(width))/double($adjustedWidth)}]
		set fv [expr {double($(height))/double($adjustedHeight)}]
		set f  [expr {min($fh, $fv)}]
		set fh [expr {$f*(double($adjustedWidth)/double($width))}]
		set fv [expr {$f*(double($adjustedHeight)/double($height))}]
		set w  [expr {int($fh*double($width) + 0.5)}]
		set h  [expr {int($fv*double($height) + 0.5)}]
	} else {
		set f [expr {double($(width))/double($width)}]
		set w [expr {int($f*double($width) + 0.5)}]
		set h $(height)
	}

	return [list $w $h]
}


proc SelectVariant {} {
	variable {}

	set i [lsearch -exact -index 1 $(variants:values) [$(list:variants) get variant]]
	set variant [lindex $(variants:values) $i 0]

	if {$variant ne $(variant:sel)} {
		set active [GetActiveLayout]
		set names {}
		foreach name [[namespace parent]::twm::glob $(id) $variant] {
			lappend names $name
		}
		set (variant:sel) $variant
		UpdateLayoutList $names
		UpdateButtonStates
		SelectLayout $active
	}
}


proc UpdateLayoutList {{names {}}} {
	variable {}

	if {[llength $names]} {
		set (var:names) $names
	}
	for {set i 0} {$i < [llength $(var:names)]} {incr i} {
		if {$(variant:sel) ne $(variant:ori) || [lindex $(var:names) $i] ne $(name:cur)} {
			set state normal
		} elseif {$(name:rpl) ne $(name:cur) || ![[namespace parent]::twm::testLayoutStatus $(twm)]} {
			set state changed
		} else {
			set state current
		}
		set color [::colors::lookup layout-manager:$state]
		$(list:names) itemconfigure $i -foreground $color -selectforeground $color
	}
}


proc GetActiveLayout {} {
	variable {}

	set i [$(list:names) curselection]
	if {[llength $i] == 0} { return "" }
	return [lindex $(var:names) $i]
}


proc SelectLayout {{active ""}} {
	variable {}

	set index [lsearch $(var:names) $active]
	if {$index == -1} { set index [lsearch $(var:names) $(name:cur)] }
	if {$index == -1 && [llength $(var:names)]} { set index 0 }
	$(list:names) activate $index
	$(list:names) selection clear 0 end
	if {$index >= 0} {
		$(list:names) selection set $index
		$(list:names) see [expr {max(0,$index)}]
		after idle $(load:cmd)
	}
	RetrieveLink
}


proc UpdateButtonStates {} {
	variable {}

	set name [GetActiveLayout]

	set eq1 [expr {$(variant:sel) eq $(variant:ori)}]
	set eq2 [expr {$name ne $(name:cur)}]
	set eq3 [[namespace parent]::twm::testLayoutStatus $(twm)]
	set eq  [expr {$eq1 && ($eq2 || !$eq3)}]
	$(button:res) configure -state [::makeState $eq]

	set eq [expr {$(variant:sel) ne $(variant:rpl) || $name ne $(name:rpl)}]
	$(button:rpl) configure -state [::makeState $eq]

	set eq [[namespace parent]::twm::actualLayoutIsEqTo $(twm) $(layout:list:ori)]
	set eq [expr {$eq && $(name:cur) eq $(name:ori)}]
	$(button:rev) configure -state [::makeState !$eq]
}


proc LoadLayout {myTWM} {
	variable {}

	set name [GetActiveLayout]
	if {[string length $name] == 0} { return }
	set filename [[namespace parent]::twm::makeFilename $(id) $(variant:sel) $name]
	if {![file exists $filename]} {
		set filename [[namespace parent]::twm::makeFilename $(id) normal $name]
	}
	if {![file exists $filename]} {
		set msg [format $mc::CannotOpenFile $filename]
		return [dialog::error -parent $(list:names) -message $msg -topmost yes]
	}
	$myTWM load [lindex [::file::gets $filename -encoding utf-8] 3]
	RetrieveLink
	UpdateLayoutList
	UpdateButtonStates
}


proc Delete {parent} {
	variable {}

	set name [GetActiveLayout]
	if {[string length $name] == 0} { return }

	if {[[namespace parent]::twm::deleteLayout $(twm) $name $parent $(variant:sel)]} {
		set i [lsearch $(var:names) $name]
		if {$i >= 0} {
			UpdateLayoutList [lreplace $(var:names) $i $i]
			set i [expr {max(0,$i - 1)}]
			$(list:names) selection clear 0 end
			$(list:names) selection set $i
			$(list:names) see $i
			if {$(name:ori) eq $name} { set (name:ori) "" }
			if {$(name:rpl) eq $name} { set (name:rpl) "" }
		}
	}
}


proc Rename {parent} {
	variable {}

	set oldName [GetActiveLayout]
	if {[string length $oldName] == 0} { return }
	set newName [[namespace parent]::twm::renameLayout $(twm) $oldName $parent]
	if {[string length $newName] > 0} {
		set i [lsearch $(var:names) $oldName]
		if {$i >= 0} {
			UpdateLayoutList [lsort [lreplace $(var:names) $i $i $newName]]
			set i [lsearch $(var:names) $newName]
			$(list:names) selection clear 0 end
			$(list:names) selection set $i
			$(list:names) see $i
		}
	}
	set (name:cur) $newName
	if {$(name:ori) eq $oldName} { set (name:ori) $newName }
	if {$(name:rpl) eq $oldName} { set (name:rpl) $newName }
}


proc Replace {} {
	variable {}

	set name [GetActiveLayout]
	if {[string length $name] == 0} { return }
	[namespace parent]::twm::replaceLayout $(twm) $(variant:sel) $name
	set (variant:rpl) $(variant:sel)
	set (name:rpl) $name
	UpdateLayoutList
	UpdateButtonStates
}


proc Load {} {
	variable {}

	set name [GetActiveLayout]
	if {[string length $name] == 0} { return }
	[namespace parent]::twm::loadLayout $(twm) $name
	set eq [[namespace parent]::twm::actualLayoutIsEqTo $(twm) $(layout:list:ori)]
	set (variant:rpl) $(variant:ori)
	set (name:cur) $name
	set (name:rpl) $name
	UpdateLayoutList
	UpdateButtonStates
}


proc Revert {} {
	variable {}

	if {[[namespace parent]::twm::restoreLayout \
			$(twm) $(variant:ori) $(name:ori) $(layout:list:ori) $(layout:list:sav)]} {
		set (variant:rpl) $(variant:ori)
		set (name:cur) $(name:ori)
		set (name:rpl) $(name:ori)
	}
	UpdateLayoutList
	UpdateButtonStates
}

} ;# namespace layout
} ;# namespace application

# vi:set ts=3 sw=3:
