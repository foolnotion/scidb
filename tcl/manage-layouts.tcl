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


proc open {twm id layoutVariant currentLayout link} {
	variable layoutVariants
	variable Options
	variable {}

	set (variant:current) $layoutVariant
	set (layout:list:old) [[namespace parent]::twm::inspectLayout $twm]
	set (layout:name:cur) $currentLayout
	set (layout:name:old) [[namespace parent]::twm::currentLayout $twm]
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
			$(list:variants) listinsert \
				[list $::icon::16x16::variant($variant) $::mc::VariantName($variant)]
			lappend (variants:values) [list $v $::mc::VariantName($variant)]
		}
	}
	$(list:variants) resize -force
	set variant [[namespace parent]::twm::toVariant $layoutVariant]
	$(list:variants) set $::mc::VariantName($variant)
	bind $(list:variants) <<ComboboxCurrent>> [namespace code SelectVariant]

	set (load:cmd) [namespace code [list LoadLayout $myTWM]]
	set (var:names) [[namespace parent]::twm::glob $id $layoutVariant]
	tk::listbox $(list:names) \
		-width $Options(width) \
		-height 0 \
		-listvariable [namespace current]::(var:names) \
		;
	SelectLayout

	set (button:ren) $lt.ren
	set (button:del) $lt.del
	set (button:res) $lt.res
	set (button:rpl) $lt.rpl
	set (button:rev) $dlg.revert

	ttk::button $(button:ren) \
		-style aligned.TButton \
		-text $mc::Rename \
		-image $::icon::16x16::exchange \
		-compound left \
		-command [namespace code [list Rename [winfo toplevel $myTWM]]] \
		;
	ttk::button $(button:del) \
		-style aligned.TButton \
		-text $mc::Delete \
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
			set (var:link) $link
			if {[string length $(var:link)] == 0} { set (var:link) "\u2014" }
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
	$dlg.revert configure \
		-state disabled \
		-command [namespace code [list Revert $twm]] \
		;
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


proc SelectLayout {} {
	variable {}

	set index [lsearch $(var:names) $(layout:name:cur)]
	if {$index == -1 && [llength $(var:names)]} { set index 0 }
	$(list:names) activate $index
	$(list:names) selection clear 0 end
	if {$index >= 0} {
		$(list:names) selection set $index
		after idle $(load:cmd)
	}
	$(list:names) see [expr {max(0,$index)}]
}


proc SetLink {} {
	variable {}

	if {[$(list:links) current] == 0} { set link "" } else { set link $(var:link) }
	[namespace parent]::twm::setLink $(id) $(layout:name:cur) $link
}


proc NameFromUid {uid}		{ return [lindex [split $uid :] 0] }
proc NumberFromUid {uid}	{ return [lindex [split $uid :] 1] }


proc TitleFromUid {uid} {
	set name [NameFromUid $uid]
	if {$name eq "analysis"} {
		set title [set [namespace parent]::twm::mc::Pane($name)]
		if {[set number [NumberFromUid $uid]] > 1} { append title " ($number)" }
	} else {
		set title [set [namespace parent]::twm::mc::Pane($name)]
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
			bind $w <Configure> +[namespace code [list ResizeBoard $w %w %h]]
			$w xview moveto 0
			$w yview moveto 0
			set size [expr {max(1, (min($width,$height) - 20)/8)}]
			board::diagram::new $w.diagram $size -empty 1 -bordersize 2 -bordertype lines -bordercolor white
			set x [expr {($width - ($size*8 + 2))/2}]
			set y [expr {($height - ($size*8 + 2))/2}]
			$w create window $x $y -anchor nw -window $w.diagram -tags board
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


proc ResizeBoard {w width height} {
	set size [expr {max(1, (min($width,$height) - 20)/8)}]
	board::diagram::resize $w.diagram $size
	set x [expr {($width - ($size*8 + 2))/2}]
	set y [expr {($height - ($size*8 + 2))/2}]
	$w coords board $x $y
}


proc Resizing {myTWM toplevel width height} {
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
		set h $height
	}

	return [list $w $h]
}


proc SelectVariant {} {
	variable {}

	set variant [$(list:variants) get variant]
	set i [lsearch -exact -index 1 $(variants:values) $variant]
	set variant [lindex $(variants:values) $i 0]

	if {$variant ne $(variant:current)} {
		set names {}
		foreach name [[namespace parent]::twm::glob $(id) $variant] {
			lappend names $name
		}
		set (var:names) $names
		$(button:res) configure -state [::makeState [expr {$(variant:current) eq $variant}]]
		$(button:ren) configure -state [::makeState [expr {$variant eq "normal"}]]
		set (variant:current) $variant
		SelectLayout
	}
}


proc LoadLayout {myTWM} {
	variable {}

	if {[llength [$(list:names) curselection]] == 0} { return }

	set name [$(list:names) get [$(list:names) curselection]]
	set filename [[namespace parent]::twm::makeFilename $(id) $(variant:current) $name]
	if {![file exists $filename]} {
		set filename [[namespace parent]::twm::makeFilename $(id) normal $name]
	}
	if {![file exists $filename]} {
		set msg [format $mc::CannotOpenFile $filename]
		return [dialog::error -parent $(list:names) -message $msg -topmost yes]
	}
	set ::application::twm::SetupFunc [list $myTWM load]
	after idle [list set ::application::twm::SetupFunc {}]
	$myTWM load [lindex [::file::gets $filename -encoding utf-8] 3]
	set state [::makeState [expr {$(variant:current) eq $(variant:current)}]]
	if {	[[namespace parent]::twm::currentLayout $(twm)] eq $name
		&& [[namespace parent]::twm::testLayoutStatus $(twm)]} {
		set state disabled
	}
	$(button:res) configure -state $state
	$(button:rpl) configure -state normal
}


proc Delete {parent} {
	variable {}

	set name [$(list:names) get [$(list:names) curselection]]
	if {[[namespace parent]::twm::deleteLayout $(twm) $name $parent $(variant:current)]} {
		set i [lsearch $(var:names) $name]
		if {$i >= 0} {
			set (var:names) [lreplace $(var:names) $i $i]
			set i [expr {$i > 0 ? $i - 1 : 0}]
			$(list:names) selection clear 0 end
			$(list:names) selection set $i
			$(list:names) see $i
		}
	}
}


proc Rename {parent} {
	variable {}

	set name [$(list:names) get [$(list:names) curselection]]
	set newName [[namespace parent]::twm::renameLayout $(twm) $name $parent]
	if {[string length $newName] > 0} {
		set i [lsearch $(var:names) $name]
		if {$i >= 0} {
			set (var:names) [lsort [lreplace $(var:names) $i $i $newName]]
			set i [lsearch $(var:names) $newName]
			$(list:names) selection clear 0 end
			$(list:names) selection set $i
			$(list:names) see $i
		}
	}
}


proc Replace {} {
	variable {}

	set name [$(list:names) get [$(list:names) curselection]]
	[namespace parent]::twm::replaceLayout $(twm) $(variant:current) $name
	set eq [[namespace parent]::twm::actualLayoutIsEqTo $(twm) $(layout:list:old)]
	$(button:rev) configure -state [::makeState [expr {!$eq}]]
	$(button:rpl) configure -state disabled
}


proc Load {} {
	variable {}

	set name [$(list:names) get [$(list:names) curselection]]
	[namespace parent]::twm::loadLayout $(twm) $name
	set eq [[namespace parent]::twm::actualLayoutIsEqTo $(twm) $(layout:list:old)]
	$(button:rev) configure -state [::makeState [expr {!$eq}]]
	$(button:rpl) configure -state normal
	$(button:res) configure -state disabled
}


proc Revert {} {
	variable {}

	[namespace parent]::twm::restoreLayout $(twm) $(variant:current) $(layout:name:old) $(layout:list:old)
	$(button:res) configure -state [::makeState [expr {$(variant:current) eq $variant}]]
	$(button:rpl) configure -state normal
	$(button:rev) configure -state disabled
}

} ;# namespace layout
} ;# namespace application

# vi:set ts=3 sw=3:
